#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$0";)")
cd "$SCRIPT_DIR"

set -e

echo "SECRETS"
base64 -w 0 secrets.env
echo ""

echo "GOOGLE_SERVICE_JSON"
base64 -w 0 android/app/google-services.json
echo ""

echo "ANDOID_KEYSTORE"
base64 -w 0 android/app/strumok.jks
echo ""