@echo off

set path=%~dp0;%path%

chcp 936

REM Set up prog to be the path of this script, including following symlinks,
REM and set up progdir to be the fully-qualified pathname of its directory.
set prog=%~f0

REM Build AAB file
del work\unsign.aab /F /Q
java -jar bundletool-all-1.15.6.jar build-bundle m --modules=work\base.zip,work\InstallDynamicFeature.zip --output=work\unsign.aab --config=path-to-BundleConfig.json
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:OK
ECHO "The AAB file is generated at work\unsign.aab"
ECHO [STEP 3] command success
GOTO END

:ERROR
ECHO [STEP 3] command failed
GOTO END

:END
IF %ERRORLEVEL% GEQ 0 EXIT /B %ERRORLEVEL%
EXIT /B 0
