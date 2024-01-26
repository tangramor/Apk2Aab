@echo off

set path=%~dp0;%path%

setlocal enabledelayedexpansion
@REM chcp 65001
chcp 936

REM Set up prog to be the path of this script, including following symlinks,
REM and set up progdir to be the fully-qualified pathname of its directory.
set prog=%~f0

REM The APK file to build
set dynamiczip=%1

set packagename=%2

if "%packagename%"=="" (
	ECHO %~n0: No Dynamic assets Zip file and Package name provided >&2
	ECHO %~n0: Usage: step2_build_dynamicfeature.bat work\dynamic_assets.zip com.wjmt.aixiang.gp >&2
	EXIT /B 1
)

REM Clean up aab
rd work\aab /Q /S

mkdir work\aab\InstallDynamicFeature

unzip -d work\aab\InstallDynamicFeature %dynamiczip%

(
echo ^<?xml version="1.0" encoding="utf-8"?^>
echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"
echo     xmlns:dist="http://schemas.android.com/apk/distribution"
echo     package="%packagename%"
echo     platformBuildVersionCode="30"
echo     platformBuildVersionName="10"
echo     split="InstallDynamicFeature"
echo     android:compileSdkVersion="30"
echo     android:compileSdkVersionCodename="10" ^>
echo     ^<dist:module dist:type="asset-pack" ^>
echo         ^<dist:fusing dist:include="true" /^> 
echo         ^<dist:delivery^>
echo             ^<dist:install-time /^>
echo         ^</dist:delivery^>
echo     ^</dist:module^>
echo ^</manifest^>
) > work\aab\InstallDynamicFeature\AndroidManifest.xml

mkdir work\aab\InstallDynamicFeature\res

aapt2 compile --dir work\aab\InstallDynamicFeature\res -o work\aab\InstallDynamicFeature\compileres.zip
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

rd work\aab\InstallDynamicFeature\res /Q /S

REM Clean up work\aab\InstallDynamicFeature\compileres.apk
del work\aab\InstallDynamicFeature\compileres.apk /F /Q

REM Link resources
aapt2 link --proto-format -o work\aab\InstallDynamicFeature\compileres.apk -I android_30.jar --manifest work\aab\InstallDynamicFeature\AndroidManifest.xml -R work\aab\InstallDynamicFeature\compileres.zip --auto-add-overlay
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

del work\aab\InstallDynamicFeature\AndroidManifest.xml /F /Q
del work\aab\InstallDynamicFeature\compileres.zip /F /Q
@REM move work\aab\InstallDynamicFeature\AndroidManifest.xml work\aab\
@REM move work\aab\InstallDynamicFeature\compileres.zip work\aab\

REM Unpack compileres.apk
mkdir work\aab\InstallDynamicFeature\compileresPath
unzip -d work\aab\InstallDynamicFeature\compileresPath work\aab\InstallDynamicFeature\compileres.apk

REM Copy resources
mkdir work\aab\InstallDynamicFeature\manifest
move work\aab\InstallDynamicFeature\compileresPath\AndroidManifest.xml work\aab\InstallDynamicFeature\manifest\

REM Clean up unpack folder
rd work\aab\InstallDynamicFeature\compileresPath /S /Q

del work\aab\InstallDynamicFeature\compileres.apk /F /Q
@REM move work\aab\InstallDynamicFeature\compileres.apk work\aab\

cd work\aab\InstallDynamicFeature
zip -r -UN=UTF8 ..\..\InstallDynamicFeature.zip .\
cd ..\..\..

:OK
ECHO [STEP 2] command success
GOTO END

:ERROR
ECHO [STEP 2] command failed
GOTO END

:END
IF %ERRORLEVEL% GEQ 0 EXIT /B %ERRORLEVEL%
EXIT /B 0
