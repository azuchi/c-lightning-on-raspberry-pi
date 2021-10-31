#!/usr/bin/env bash

APP_ROOT="$(readlink -f $(dirname "${BASH_SOURCE[0]}"))"

# Change directory permission
chmod 700 $APP_ROOT/tor/data/lightningd
