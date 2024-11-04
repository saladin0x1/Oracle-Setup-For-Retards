@echo off
:: Enable color support in Windows Command Prompt
:: Set color variables
set "COLOR_SUCCESS=0a"
set "COLOR_ERROR=0c"
set "COLOR_PROMPT=0b"
set "COLOR_INFO=09"
set "COLOR_RESET=07"
set "COLOR_HEADER=0e"

:: Define log file path
set LOGFILE=oracle_setup_log.txt
echo Oracle XE 21c Setup Log > %LOGFILE%
echo ========================= >> %LOGFILE%

:: Function to print with color
setlocal EnableDelayedExpansion
for /f "tokens=*" %%A in ('echo prompt $E ^& for %%C in (1) do rem') do set "ESC=%%A"
echo.

:: Header
echo %ESC%[!COLOR_HEADER!mOracle XE 21c Database Setup%ESC%[!COLOR_RESET!m
echo.
echo This script will help you install and set up Oracle XE in Docker.
echo Logs and connection details will be saved in: %LOGFILE%
echo.

:: Step 1: Prompt for Oracle Database Password
echo %ESC%[!COLOR_PROMPT!mPlease enter a password for the Oracle XE 'system' user:%ESC%[!COLOR_RESET!m
set /p ORACLE_PWD="Password: "
echo.

:: Step 2: Check if Docker is installed and log paths
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %ESC%[!COLOR_INFO!mDocker Desktop is not installed. Downloading Docker Desktop...%ESC%[!COLOR_RESET!m
    echo Docker Desktop not found. Attempting to download and install. >> %LOGFILE%

    :: Step 2.1: Download Docker using curl
    curl -L -o DockerDesktopInstaller.exe "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
    if exist DockerDesktopInstaller.exe (
        echo Docker Desktop installer downloaded to %cd%\DockerDesktopInstaller.exe >> %LOGFILE%
        
        echo %ESC%[!COLOR_INFO!mInstalling Docker Desktop. Please wait...%ESC%[!COLOR_RESET!m
        
        :: Loading animation while installing
        start /b "" cmd /c "DockerDesktopInstaller.exe install --quiet" 
        set "LOADER=|/-\" 
        set "COUNT=0"

        :LOOP
        set /a COUNT+=1
        set "CHAR=!LOADER:~%COUNT%,1!"
        if "!CHAR!"=="" set COUNT=0
        cls
        echo %ESC%[!COLOR_INFO!mInstalling Docker Desktop... %CHAR% %ESC%[!COLOR_RESET!m
        timeout /t 1 >nul
        goto LOOP

        :: Wait for installation to complete
        timeout /t 20 >nul

        if %errorlevel% neq 0 (
            echo %ESC%[!COLOR_ERROR!mFailed to install Docker Desktop. Check your internet connection and try again.%ESC%[!COLOR_RESET!m
            echo Docker installation failed. >> %LOGFILE%
            pause
            exit /b
        )
        echo %ESC%[!COLOR_SUCCESS!mDocker Desktop installed successfully.%ESC%[!COLOR_RESET!m >> %LOGFILE%
        
        echo Starting Docker...
        start /b "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        echo Docker Desktop installed at C:\Program Files\Docker\Docker\Docker Desktop.exe >> %LOGFILE%
        
        echo Waiting for Docker to start...
        timeout /t 20 >nul
    ) else (
        echo %ESC%[!COLOR_ERROR!mFailed to download Docker Desktop installer. Check your internet connection.%ESC%[!COLOR_RESET!m
        echo Docker installer download failed. >> %LOGFILE%
        pause
        exit /b
    )
) else (
    echo %ESC%[!COLOR_SUCCESS!mDocker Desktop is already installed.%ESC%[!COLOR_RESET!m >> %LOGFILE%
)

:: Step 3: Pull the Oracle XE 21c Docker image
echo %ESC%[!COLOR_INFO!mPulling Oracle XE 21c Docker image...%ESC%[!COLOR_RESET!m
echo Attempting to pull Oracle XE 21c Docker image... >> %LOGFILE%
docker pull oracle/database:21.3.0-xe >nul 2>&1
if %errorlevel% neq 0 (
    echo %ESC%[!COLOR_ERROR!mCould not pull the Oracle XE image. Ensure Docker Desktop is running and try again.%ESC%[!COLOR_RESET!m
    echo Docker image pull failed. >> %LOGFILE%
    pause
    exit /b
)
echo %ESC%[!COLOR_SUCCESS!mOracle XE Docker image pulled successfully.%ESC%[!COLOR_RESET!m >> %LOGFILE%

:: Step 4: Run Oracle XE container with pre-configured settings
echo %ESC%[!COLOR_INFO!mStarting Oracle XE container...%ESC%[!COLOR_RESET!m
docker run -d -p 1521:1521 -p 5500:5500 --name oracle-xe-container -e ORACLE_PWD=%ORACLE_PWD% oracle/database:21.3.0-xe >nul 2>&1

if %errorlevel% neq 0 (
    echo %ESC%[!COLOR_ERROR!mFailed to start the Oracle XE container.%ESC%[!COLOR_RESET!m
    echo Oracle XE container startup failed. >> %LOGFILE%
    pause
    exit /b
)
echo %ESC%[!COLOR_SUCCESS!mOracle XE container started successfully.%ESC%[!COLOR_RESET!m >> %LOGFILE%
echo Docker container named oracle-xe-container created. >> %LOGFILE%

:: Step 5: Output and log connection details
echo.
echo %ESC%[!COLOR_HEADER!mOracle XE 21c Database is ready!%ESC%[!COLOR_RESET!m
echo ===============================
echo %ESC%[!COLOR_INFO!mConnection details:%ESC%[!COLOR_RESET!m
echo Host: localhost
echo Port: 1521
echo Service: XE
echo Username: system
echo Password: %ORACLE_PWD%
echo.

:: Log connection details to file
echo Oracle XE 21c Database Connection Details >> %LOGFILE%
echo Host: localhost >> %LOGFILE%
echo Port: 1521 >> %LOGFILE%
echo Service: XE >> %LOGFILE%
echo Username: system >> %LOGFILE%
echo Password: %ORACLE_PWD% >> %LOGFILE%
echo. >> %LOGFILE%

echo %ESC%[!COLOR_SUCCESS!mSetup complete. Check oracle_setup_log.txt for details.%ESC%[!COLOR_RESET!m
echo Log saved to %cd%\%LOGFILE%
pause
