#!/bin/bash
# Downloads the release in release.txt and runs its update script (see README).
exec bash "$(dirname "$0")/tools/rom.sh" update
