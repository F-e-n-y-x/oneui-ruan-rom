# Ruan Fixes (branch `fixes`)

Small signed fix packs for the One UI Ruan ROM on the Redmi Pad Pro 5G, installable without reflashing.

**Users: don't download anything here.** Open **Settings > Ruan Fixes** on the tablet; it fetches
`index.json`, checks its signature (`index.json.sig`) and each pack's sha256, and installs the packs
that apply to your build. Packs are Magisk modules (`packs/*.zip`) and are removed automatically once
a ROM build that already contains the fix is installed.

This branch is written by `port/scripts/fixpack.py`; do not edit it by hand (the signature would break).
