#!/usr/bin/env bash

KEYSTORE_NAME="strumok.jks"
KEYSTORE_ALIAS="strumok"

if [ -e $KEYSTORE_NAME ]; then
    echo "Keystore already exists"
    exit 0
fi

keytool -genkeypair -v -keystore $KEYSTORE_NAME -alias $KEYSTORE_ALIAS -keyalg RSA -keysize 2048 -validity 3650


