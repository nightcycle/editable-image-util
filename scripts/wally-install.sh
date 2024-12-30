#!/usr/bin/env bash
ROJO_PROJECT="$1"
wally install
rojo sourcemap "$ROJO_PROJECT" --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages