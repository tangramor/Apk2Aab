@echo off

set path=%~dp0;%path%

chcp 936

REM Set up prog to be the path of this script, including following symlinks,
REM and set up progdir to be the fully-qualified pathname of its directory.
set prog=%~f0

REM The keystore file
set keystore=%1

REM The store password
set storepass=%2

REM The key password
set keypass=%3

REM Key Alias
set keyalias=%4

if "%keyalias%"=="" (
    ECHO %~n0: No keystore related parameters provided >&2
    ECHO %~n0: Usage: step4_sign_aab.bat work\keystore storepass keypass keyalias >&2
    EXIT /B 1
)

REM Sign AAB file
jarsigner -digestalg SHA1 -sigalg SHA1withRSA -keystore %keystore% -storepass %storepass% -keypass %keypass% work\unsign.aab %keyalias%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

move work\unsign.aab work\signed.aab
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:OK
ECHO [STEP 4] command success
GOTO END

:ERROR
ECHO [STEP 4] command failed
GOTO END

:END
IF %ERRORLEVEL% GEQ 0 EXIT /B %ERRORLEVEL%
EXIT /B 0
