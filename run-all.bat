@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo Running all procedures from README.md
echo ========================================
echo.

echo [1.1] Starting PostgreSQL via Docker...
docker-compose down -v
docker-compose up -d
if %errorlevel% neq 0 (
    echo ERROR: Failed to start PostgreSQL
    pause
    exit /b 1
)
echo Waiting for PostgreSQL to start...
timeout /t 5 /nobreak >nul
echo PostgreSQL started!
echo.

echo [1.2] Checking notice table in Init.sql...
echo Table is already created in Init.sql and will be initialized on first startup
echo.

echo [1.3] Compiling InsertData program...
set POSTGRESQL_JAR=
set FOUND_COUNT=0
set TEMP_FILE=%TEMP%\postgresql_jar_search.txt

REM Starting search with graphical progress indicator
set PS_SCRIPT=%TEMP%\search_postgresql.ps1
(
echo $tempFile = '%TEMP_FILE%'
echo Write-Host 'Searching for postgresql*.jar on drive C:...' -ForegroundColor Cyan
echo $files = @^(^)
echo $count = 0
echo Get-ChildItem -Path C:\ -Filter postgresql*.jar -Recurse -ErrorAction SilentlyContinue ^| ForEach-Object {
echo     $count++
echo     $files += $_.FullName
echo     if ^($count %% 10^) -eq 0 {
echo         Write-Progress -Activity 'Searching for postgresql*.jar files' -Status "Found files: $count" -PercentComplete -1
echo     }
echo }
echo Write-Progress -Activity 'Searching for postgresql*.jar files' -Completed
echo if ^($files.Count -gt 0^) {
echo     $files ^| Out-File -FilePath $tempFile -Encoding UTF8
echo }
echo Write-Host "Search completed! Found files: $count" -ForegroundColor Green
) > "%PS_SCRIPT%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" 2>nul
del "%PS_SCRIPT%" 2>nul
if not exist "%TEMP_FILE%" (
    echo Searching using standard command...
    dir /s /b C:\postgresql*.jar 2>nul > "%TEMP_FILE%"
)
if exist "%TEMP_FILE%" (
    for /f "delims=" %%i in ('type "%TEMP_FILE%"') do (
        set /a FOUND_COUNT+=1
        echo   [!FOUND_COUNT!] %%i
    )
)
if %FOUND_COUNT% GTR 0 (
    echo.
    echo Found files: %FOUND_COUNT%
    echo.
    set /p JAR_CHOICE="Enter file number (1-%FOUND_COUNT%) or enter file path manually: "
    if "!JAR_CHOICE!"=="" (
        echo ERROR: No selection specified
        del "%TEMP_FILE%" 2>nul
        pause
        exit /b 1
    )
    set /a JAR_NUM=!JAR_CHOICE! 2>nul
    if !JAR_NUM! GEQ 1 if !JAR_NUM! LEQ %FOUND_COUNT% (
        set CURRENT_NUM=0
        for /f "delims=" %%i in ('type "%TEMP_FILE%"') do (
            set /a CURRENT_NUM+=1
            if !CURRENT_NUM! EQU !JAR_NUM! (
                set POSTGRESQL_JAR=%%i
            )
        )
    ) else (
        set POSTGRESQL_JAR=!JAR_CHOICE!
    )
    del "%TEMP_FILE%" 2>nul
) else (
    echo postgresql*.jar files not found on drive C:
    echo.
    set /p POSTGRESQL_JAR="Enter path to postgresql.jar file: "
    del "%TEMP_FILE%" 2>nul
)
if "%POSTGRESQL_JAR%"=="" (
    echo ERROR: Path to postgresql.jar not specified
    pause
    exit /b 1
)
if not exist "%POSTGRESQL_JAR%" (
    echo ERROR: File not found: %POSTGRESQL_JAR%
    pause
    exit /b 1
)
echo Using file: %POSTGRESQL_JAR%
javac -cp "target/classes;%POSTGRESQL_JAR%" -d target/classes src/main/java/org/example/InsertData.java
if %errorlevel% neq 0 (
    echo ERROR: Failed to compile InsertData
    pause
    exit /b 1
)
echo InsertData compiled successfully!
echo.

echo [1.4] Compiling ReadInfoMessages program...
javac -cp "target/classes;%POSTGRESQL_JAR%" -d target/classes src/main/java/org/example/ReadInfoMessages.java
if %errorlevel% neq 0 (
    echo ERROR: Failed to compile ReadInfoMessages
    pause
    exit /b 1
)
echo ReadInfoMessages compiled successfully!
echo.

echo [1.5] Compiling ReadWarnMessages program...
javac -cp "target/classes;%POSTGRESQL_JAR%" -d target/classes src/main/java/org/example/ReadWarnMessages.java
if %errorlevel% neq 0 (
    echo ERROR: Failed to compile ReadWarnMessages
    pause
    exit /b 1
)
echo ReadWarnMessages compiled successfully!
echo.

echo ========================================
echo Starting all programs...
echo ========================================
echo.

echo Starting InsertData (writing to database)...
start "InsertData" cmd /k "java -cp target/classes;%POSTGRESQL_JAR% org.example.InsertData"

timeout /t 2 /nobreak >nul

echo Starting ReadInfoMessages (reading INFO messages)...
start "ReadInfoMessages" cmd /k "java -cp target/classes;%POSTGRESQL_JAR% org.example.ReadInfoMessages"

timeout /t 2 /nobreak >nul

echo Starting ReadWarnMessages (reading WARN messages)...
start "ReadWarnMessages" cmd /k "java -cp target/classes;%POSTGRESQL_JAR% org.example.ReadWarnMessages"

echo.
echo ========================================
echo All programs started!
echo ========================================
echo.
echo Running processes:
echo - InsertData: adds messages to database
echo - ReadInfoMessages: reads and deletes INFO messages
echo - ReadWarnMessages: reads and updates WARN messages
echo.
echo To stop, close the program windows or press Ctrl+C in each window
echo.
pause

