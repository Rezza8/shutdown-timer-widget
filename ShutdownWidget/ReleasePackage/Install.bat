@echo off
title Shutdown Timer Widget - Installer
echo.
echo ========================================
echo  Shutdown Timer Widget Installer
echo ========================================
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This installer requires Administrator privileges.
    echo Right-click and select "Run as Administrator".
    echo.
    pause
    exit /b 1
)

:: Get script directory
set "SCRIPT_DIR=%~dp0"

:: Run PowerShell installer
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Installer.ps1"

echo.
echo Installation finished.
pause