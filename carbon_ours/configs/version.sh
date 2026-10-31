#
# Copyright (c) 2026 ALRIGROUP and its affiliates.
# Engineered and maintained by ALRI Development.
#
# This code is licensed under the ARGLP - ALRI GROUP LICENSE PERMISSIVE
# found in the LICENSE file in the root directory of this source tree
# and at: https://github.com/alrigroup/licenses
#
# UN1CA Carbon (Release: IX • One UI 9.0 • Android 17 • SDK 37)

export UN1CA_NAME="UN1CA Carbon"
export NPL_VERSION="Carbon_IX-1.0"
export NPL_BUILD_TYPE="Official"
export NPL_CODENAME="Carbon"
export NPL_MAINTAINER="ALRI Development (Lead: AlexsAR)"
export NPL_MAINTAINERS="ALRI Development (Lead: AlexsAR)"
export ROM_PORTER="ALRI Development (Lead: AlexsanderALRI)"

# Configurable Telemetry Debloater (default: true)
export DEBLOAT_TELEMETRY="${DEBLOAT_TELEMETRY:-true}"

# Only the below variable(s) need to be changed!
VERSION_MAJOR=1
VERSION_MINOR=3
VERSION_PATCH=0

# The below variables will be generated automatically
#
# Version name
ROM_VERSION="UN1CA_Carbon_IX_${VERSION_MAJOR}.${VERSION_MINOR}"
# Append "+" to version name if commits have been added since the last tag
LATEST_TAG="$(git describe --tags --abbrev=0 2> /dev/null)"
if [ "$LATEST_TAG" ]; then
    if [[ "$(git rev-list --count "$LATEST_TAG...HEAD" 2> /dev/null)" =~ 0*[1-9][0-9]* ]]; then
        ROM_VERSION+="+"
    fi
fi
# Append current commit hash to version name
ROM_VERSION+="-$(git rev-parse --short HEAD 2> /dev/null || echo "null")"
# Append "-dirty" to version name if uncommitted changes are detected
if [ "$(git --no-optional-locks status -uno --porcelain 2> /dev/null)" ]; then
    ROM_VERSION+="-dirty"
fi
