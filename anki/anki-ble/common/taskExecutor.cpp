#include <functional>
#include "taskExecutor.h"
#include <algorithm>
#include <fcntl.h>
#include <unistd.h>
#include <future>
#include <atomic>

namespace Anki
{

TaskExecutor::TaskExecutor(struct ev_loop* loop)
    : _loop(loop)
    , _pipeFileDescriptors{-1, -1}
    , _pipeWatcher(nullptr)
    , _timerWatcher(nullptr)
    , _taskExecuteThread(nullptr)
    , _syncTaskDone(false)
    , _executing(true)
{
  (void) pipe2(_pipeFileDescriptors, O_NONBLOCK);

  if (loop) {
    InitWatchers();
  } else {
    std::promise<void> initDone;
    std::future<void> initFuture = initDone.get_future();
    _taskExecuteThread = new std::thread([this, &initDone]() {
      _loop = ev_loop_new(EVBACKEND_SELECT);
      InitWatchers();
      initDone.set_value();
      ev_loop(_loop, 0);
      DestroyWatchers();
      ev_loop_destroy(_loop); _loop = nullptr;
    });
    initFuture.wait();
  }
}

TaskExecutor::~TaskExecutor()
{
  StopExecution();
  if (_pipeFileDescriptors[1] >= 0) close(_pipeFileDescriptors[1]);
  if (_pipeFileDescriptors[0] >= 0) close(_pipeFileDescriptors[0]);
}

void TaskExecutor::WakeUpBackgroundThread(const char c)
{
  if (_pipeFileDescriptors[1] >= 0) {
    char buf[1] = {c};
    (void) write(_pipeFileDescriptors[1], buf, sizeof(buf));
  }
}

void TaskExecutor::StopExecution()
{
  _executing = false;

  {
    std::lock_guard<std::mutex> lock(_taskQueueMutex);
    _taskQueue.clear();
  }
  {
    std::lock_guard<std::mutex> lock(_taskDeferredQueueMutex);
    _deferredTaskQueue.clear();
  }

  WakeUpBackgroundThread('q');

  try {
    if (_taskExecuteThread && _taskExecuteThread->joinable()) {
      _taskExecuteThread->join();
    }
  } catch (...) {}
}

void TaskExecutor::Wake(std::function<void()> task)
{
  if (!_executing) return;
  WakeAfter(std::move(task), std::chrono::time_point<std::chrono::steady_clock>::min());
}

void TaskExecutor::WakeSync(std::function<void()> task)
{
  if (!_executing) return;
  if (std::this_thread::get_id() == _loop_thread_id) {
    task();
    return;
  }
  std::lock_guard<std::mutex> lock(_addSyncTaskMutex);
  if (!_executing) return;

  TaskHolder taskHolder;
  taskHolder.sync = true;
  taskHolder.task = std::move(task);
  taskHolder.when = std::chrono::time_point<std::chrono::steady_clock>::min();
  _syncTaskDone = false;

  AddTaskHolder(std::move(taskHolder));

  std::unique_lock<std::mutex> lk(_syncTaskCompleteMutex);
  _syncTaskCondition.wait(lk, [this]{return _syncTaskDone || !_executing;});
}

void TaskExecutor::WakeAfter(std::function<void()> task, std::chrono::time_point<std::chrono::steady_clock> when)
{
  if (!_executing) return;
  TaskHolder taskHolder{false, std::move(task), when};

  if (std::chrono::steady_clock::now() >= when) {
    AddTaskHolder(std::move(taskHolder));
  } else {
    AddTaskHolderToDeferredQueue(std::move(taskHolder));
  }
}

void TaskExecutor::AddTaskHolder(TaskHolder taskHolder)
{
  std::lock_guard<std::mutex> lock(_taskQueueMutex);
  if (!_executing) return;
  _taskQueue.push_back(std::move(taskHolder));
  WakeUpBackgroundThread();
}

void TaskExecutor::AddTaskHolderToDeferredQueue(TaskHolder taskHolder)
{
  std::lock_guard<std::mutex> lock(_taskDeferredQueueMutex);
  if (!_executing) return;
  _deferredTaskQueue.push_back(std::move(taskHolder));
  std::sort(_deferredTaskQueue.begin(), _deferredTaskQueue.end());
  WakeUpBackgroundThread();
}

void TaskExecutor::CommonCallback() {
  if (_executing) {
    ProcessTaskQueue();
    ProcessDeferredQueue();
  } else {
    if (_loop && _taskExecuteThread) {
      ev_unloop(_loop, EVUNLOOP_ALL);
    }
  }
}

void TaskExecutor::PipeWatcherCallback(ev::io& w, int revents)
{
  if (revents & ev::READ) {
    char buf[1];
    ssize_t bytesRead;
    do {
      bytesRead = read(w.fd, buf, sizeof(buf));
    } while (bytesRead > 0);
  }
  CommonCallback();
}

void TaskExecutor::TimerWatcherCallback(ev::timer& w, int revents)
{
  CommonCallback();
}

void TaskExecutor::InitWatchers()
{
  _loop_thread_id = std::this_thread::get_id();
  _pipeWatcher = new ev::io(_loop);
  _pipeWatcher->set<TaskExecutor, &TaskExecutor::PipeWatcherCallback>(this);
  _timerWatcher = new ev::timer(_loop);
  _timerWatcher->set<TaskExecutor, &TaskExecutor::TimerWatcherCallback>(this);
  _pipeWatcher->start(_pipeFileDescriptors[0], ev::READ);
}

void TaskExecutor::DestroyWatchers()
{
  delete _timerWatcher; _timerWatcher = nullptr;
  delete _pipeWatcher; _pipeWatcher = nullptr;
}

void TaskExecutor::Execute()
{
  _loop = ev_loop_new(EVBACKEND_SELECT);
  InitWatchers();
  ev_loop(_loop, 0);
  DestroyWatchers();
  ev_loop_destroy(_loop); _loop = nullptr;
}

void TaskExecutor::ProcessTaskQueue()
{
  std::vector<TaskHolder> taskQueue;
  {
    std::lock_guard<std::mutex> lock(_taskQueueMutex);
    taskQueue = std::move(_taskQueue);
    _taskQueue.clear();
  }
  for (auto const& taskHolder : taskQueue) {
    if (_executing) {
      taskHolder.task();
      if (taskHolder.sync) {
        std::lock_guard<std::mutex> lk(_syncTaskCompleteMutex);
        _syncTaskDone = true;
        _syncTaskCondition.notify_one();
      }
    }
  }
}

void TaskExecutor::ProcessDeferredQueue()
{
  std::lock_guard<std::mutex> lock(_taskDeferredQueueMutex);
  bool endLoop = false;
  while (_executing && !_deferredTaskQueue.empty() && !endLoop) {
    auto now = std::chrono::steady_clock::now();
    auto& taskHolder = _deferredTaskQueue.back();
    if (now >= taskHolder.when) {
      AddTaskHolder(std::move(taskHolder));
      _deferredTaskQueue.pop_back();
    } else {
      endLoop = true;
      using ev_tstamp_duration = std::chrono::duration<ev_tstamp, std::ratio<1, 1>>;
      ev_tstamp_duration duration =
          std::chrono::duration_cast<ev_tstamp_duration>(taskHolder.when - std::chrono::steady_clock::now());
      ev_tstamp after = duration.count();
      _timerWatcher->start(after);
    }
  }
}

} // namespace Anki
