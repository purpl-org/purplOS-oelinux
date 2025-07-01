#!/bin/bash

systemctl stop anki-robot.target
sleep 4
cd /data/data/com.anki.victor/persistent
rm -f onboarding/onboardingState.json
rm -f token/token.jwt
sync
systemctl start anki-robot.target
