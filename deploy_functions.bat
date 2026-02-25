@echo off
cd /d "C:\Users\Archanaa\Desktop\resqnow_admin"
echo Deploying Cloud Functions...
call firebase deploy --only functions --force
pause
