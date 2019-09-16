@echo off

CMD /C "EXIT /B 0"

:: check for listener.js existance
call :checkExistingDirectory "listener.js" "listener.js is required...Existing"
IF %retVal% == 1 GOTO :EOF

:: check for NPM
CMD /C "npm install -h 1>NUL 2>&1"
IF NOT %ERRORLEVEL% == 0 (
	ECHO [!] NPM is not installed...Exiting
	GOTO :EOF
) else (
	:: install asar package globally
	echo [*] Installing asar dependency...
	CMD /C "npm install asar -g 1>NUL 2>&1"
)

SET "slackDir=%LOCALAPPDATA%\slack"
call :checkExistingDirectory %slackDir% "Slack directory is missing...Slack not installed maybe?"
IF %retVal% == 1 GOTO :EOF

:: search for app folder in slack directory
FOR /F "tokens=*" %%g IN ('DIR /B /A:D %slackDir% ^| FINDSTR /C:"app"') DO (SET "slackAppDir=%%g")
SET "slackResourcesDir=%slackDir%\%slackAppDir%\resources"
call :checkExistingDirectory %slackResourcesDir% "Resources directory not found...Exiting"
IF %retVal% == 1 GOTO :EOF

:: generate a name for a temporary directory
:createTempDir
SET "tempDir=%TMP%\temp-%RANDOM%"
IF EXIST %tempDir% GOTO :createTempDir

MKDIR %tempDir%

:: copy app.asar archive and app.asar.unpacked
echo [*] Copying necessary files...
COPY /V %slackResourcesDir%\app.asar %tempDir% 1>NUL
ROBOCOPY %slackResourcesDir%\app.asar.unpacked %tempDir%\app.asar.unpacked /E 1>NUL

:: extract archive
CMD /C "ASAR extract %tempDir%\app.asar %tempDir%\app"

:: insert listener code for loading slack theme
SET "jsFile=%tempDir%\app\dist\ssb-interop.bundle.js"
FINDSTR /I /C:"earlduque" %jsFile% >NUL
IF NOT %ERRORLEVEL% == 0 (
	ECHO .>> %jsFile%
	TYPE listener.js >> %jsFile%
)

:: pack the new asar archive
ECHO [*] Packing new archive...
CMD /C "ASAR pack %tempDir%\app %tempDir%\app.asar"

:: replace the old one
COPY /V /Y %tempDir%\app.asar %slackResourcesDir%\app.asar 1>NUL

ECHO [*] Cleaning up...
RMDIR /S /Q %tempDir% >NUL 2>&1

ECHO [*] Dark theme installed...Please restart slack.
EXIT /B 0

:checkExistingDirectory
	IF NOT EXIST %~1 (
		ECHO [!] %~2
		SET retVal=1
		GOTO :EOF
	)
	SET retVal=0
	EXIT /B 0
