@echo off
:: ─────────────────────────────────────────────────────────────────────────────
::  melcom's Galaxy Plugin Scout  –  Launcher
::  Double-click this file to start the analyser & updater.
::  Doppelklick auf diese Datei um den Analyser & Updater zu starten.
:: ─────────────────────────────────────────────────────────────────────────────
title melcom's Galaxy Plugin Scout

:: Try to enable ANSI colours in Windows Console
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0GalaxyPluginScout.ps1"
set "GPS_EXIT=%ERRORLEVEL%"

if not "%GPS_EXIT%"=="0" (
    echo.
    echo [!] The tool exited with an error ^(code %GPS_EXIT%^). Scroll up for details.
    echo.
    pause
)