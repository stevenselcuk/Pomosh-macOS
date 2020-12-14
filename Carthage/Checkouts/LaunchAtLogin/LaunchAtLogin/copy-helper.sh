#!/bin/bash

LOCATION="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Library/LoginItems/LaunchAtLoginHelper.app"

# By default, use the configured code signing identity for the project/target
IDENTITY="${CODE_SIGN_IDENTITY}"
if [ "$IDENTITY" == "" ]
then
# If a code signing identity is not specified, use ad hoc signing
IDENTITY="-"
fi
echo "Hardening Launch At Login Helper with developer identity \"$IDENTITY\"..."
codesign --verbose --force --deep -o runtime --sign "$IDENTITY" "$LOCATION"
