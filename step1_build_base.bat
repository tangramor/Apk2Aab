@echo off

set path=%~dp0;%path%

@REM chcp 65001
chcp 936

REM Set up prog to be the path of this script, including following symlinks,
REM and set up progdir to be the fully-qualified pathname of its directory.
set prog=%~f0

REM The APK file to build
set apk=%1

set versioncode=%2
set versionname=%3
set minsdkver=%4
set targetsdkver=%5

if "%versioncode%"=="" (
	set versioncode=1
)

if "%versionname%"=="" (
	set versionname=1.0
)

if "%minsdkver%"=="" (
	set minsdkver=19
)

if "%targetsdkver%"=="" (
	set targetsdkver=30
)

if "%apk%"=="" (
	ECHO %~n0: No APK file provided >&2
	ECHO %~n0: "Usage: step1_decode.bat work\<APKFile> <versioncode>(optional) <versionname>(optional) <minsdkver>(optional) <targetsdkver>(optional)" >&2
    ECHO %~n0: "Example: step1_decode.bat work\Demo.apk 1 1.0 19 30" >&2
	EXIT /B 1
)

mkdir work

REM Clean up decode_apk_dir
rd work\decode_apk_dir /Q /S

REM Unpack 
call apktool d %apk% -s -o work\decode_apk_dir >&2

REM Clean up compiled_resources.zip
del work\compiled_resources.zip /F /Q

REM Compile resources
aapt2 compile --dir work\decode_apk_dir\res -o work\compiled_resources.zip
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM Clean up base.bak
del work\base.apk /F /Q

REM Link resources
aapt2 link --proto-format -o work\base.apk -I android_30.jar --min-sdk-version %minsdkver% --target-sdk-version %targetsdkver% --version-code %versioncode% --version-name %versionname% --manifest work\decode_apk_dir\AndroidManifest.xml -R work\compiled_resources.zip --auto-add-overlay
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM Clean up base folder
rd work\base /S /Q

REM Unpack base.apk
unzip -d work\base work\base.apk

REM Copy resources to base
mkdir work\base\manifest
move work\base\AndroidManifest.xml work\base\manifest\
xcopy work\decode_apk_dir\assets work\base\assets /y /e /i
xcopy work\decode_apk_dir\lib work\base\lib /y /e /i
xcopy work\decode_apk_dir\unknown\ work\base\root\ /y /e /i
xcopy work\decode_apk_dir\kotlin\ work\base\root\kotlin\ /y /e /i
xcopy work\decode_apk_dir\original\META-INF work\base\root\META-INF /y /e /i
del work\base\root\META-INF\*.RSA work\base\root\META-INF\*.SF base\root\META-INF\*.MF
mkdir work\base\dex
xcopy work\decode_apk_dir\*.dex work\base\dex

REM Clean up base.zip
del work\base.zip /F /Q

REM Compress base to zip file
cd work\base\
zip -r -UN=UTF8 ..\base.zip .\
cd ..\..

:OK
ECHO [STEP 1] command success
GOTO END

:ERROR
ECHO [STEP 1] command failed
GOTO END

:END
IF %ERRORLEVEL% GEQ 0 EXIT /B %ERRORLEVEL%
EXIT /B 0
