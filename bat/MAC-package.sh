dir=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
echo $dir

###########################
# SetupSDK
###########################

# Set working dir
cd $dir/..

# Static path to Flex SDK
FLEX_SDK="airsdk"
# PATH=$FLEX_SDK\bin;%PATH%
PATH="$FLEX_SDK\bin;$PATH"

###########################
# SetupApp
###########################

# Set working dir
cd $dir/..

# About AIR application packaging
# http://livedocs.adobe.com/flex/3/html/help.html?content=CommandLineTools_5.html#1035959
# http://livedocs.adobe.com/flex/3/html/distributing_apps_4.html#1037515

# NOTICE: all paths are relative to project root

# Your certificate information
CERT_NAME="Fewfre's A801 Tools"
CERT_PASS="Q7#7CBSwVDh1"
CERT_FILE="$dir/fewfre-adobe-publish.p12"
SIGNING_OPTIONS="-storetype pkcs12 -keystore $CERT_FILE -storepass $CERT_PASS"

# Application descriptor
APP_XML="application.xml"

# Files to package
APP_DIR="bin"
FILE_OR_DIR="-C $APP_DIR ."

# Output
AIR_PATH="air"
AIR_NAME="A801Tools"

###########################
# PackageApp
###########################

set AIR_TARGET=
#set AIR_TARGET=-captive-runtime
set OPTIONS=-tsa none

###########################
# Packager
###########################

# Set working dir
cd $dir/..

# AIR output
mkdir -p $AIR_PATH
OUTPUT="$AIR_PATH/$AIR_NAME$AIR_TARGET.air"

# Package
ADT=$dir/../airsdk/bin/adt
chmod +x $ADT
echo Packaging $AIR_NAME$AIR_TARGET.air using certificate $CERT_FILE...
echo "-package $OPTIONS $SIGNING_OPTIONS $OUTPUT $APP_XML $FILE_OR_DIR"
$ADT -package $OPTIONS $SIGNING_OPTIONS $OUTPUT $APP_XML $FILE_OR_DIR
# Making native installer - https://help.adobe.com/en_US/air/build/WS789ea67d3e73a8b22388411123785d839c-8000.html
$ADT -package -target native $AIR_PATH/$AIR_NAME$AIR_TARGET $OUTPUT

# call adt -package -target apk-captive-runtime %SIGNING_OPTIONS% %AIR_PATH%\%AIR_NAME% %OUTPUT%
