#!/bin/bash
# Downloads the release in release.txt and runs its install script (see README).
exec bash "$(dirname "$0")/tools/rom.sh" install
