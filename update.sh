git pull origin main
#cd poky/poky
#git pull origin master
#cd ../../
#cd poky/meta-openembedded
#git pull origin master
#cd ../../
cd anki/wired
git pull origin main --recurse-submodules
cd ../../
cd anki/vic-cloudless
git pull origin main
cd ../../
cd anki/victor 
git pull --no-recurse-submodules origin main
cd ../../
cd poky/victor/meta-vicos-mods/recipes-extended/purplpkg
git pull origin purplOS-oelinux
cd ../../../../

git add .

git commit -m "Update Submodules (Performed by update.sh)"

git push origin main
