# Apk2Aab

A bunch of Windows batch scripts to convert an Android App Package (APK) to Android App Bundle (AAB).

You can replace the jar/exe files to match your requiremnts. Current these files' version:

- aapt2.exe: 2.19-6739378
- android_30.jar: 30
- apktool.jar: 2.8.1
- bundletool-all-1.15.6.jar: 1.15.6
- unzip.exe: 5.51
- zip.exe: 3.0

## Usage

Put your original apk file and assets zip file under **work** folder.

### Step 1

Execute `step1_build_base.bat`. It will depack the `work\<original_apk>.apk` file and build the **work\base.zip** file.

Usage: `step1_decode.bat work\<APKFile> <versioncode>(optional) <versionname>(optional) <minsdkver>(optional) <targetsdkver>(optional)`

Example: `step1_decode.bat work\original_apk.apk 1 1.0.0 19 30`

### Step 2

Execute `step2_build_dynamicfeature.bat`. It will depack the `work\<dynamic_assets>.zip` file and build the **work\InstallDynamicFeature.zip** file.

Usage: `step2_build_dynamicfeature.bat work\<dynamic_assets>.zip <packagename>`

Example: `step2_build_dynamicfeature.bat work\FoAAB03.zip com.test.game`

### Step 3

Execute `step3_build_aab.bat`. It will combine the **base.zip** and **InstallDynamicFeature.zip** files to create the **work\unsign.aab** file.

Usage: `step3_build_aab.bat`

### Step 4

Execute `step4_sign_aab.bat`. It will sign the **unsign.aab** file with the keystore file and store it in the **work\signed.aab** file.

Usage: `step4_sign_aab.bat work\<keystore> <storepass> <keypass> <keyalias>`

Example: `step4_sign_aab.bat work\test.keystore mypassword mypassword mykey`

