@echo off

taskkill /F /IM vrmonitor.exe /T

timeout /T 5 /nobreak

shutdown.exe -s -t 00

