#!/usr/bin/env bash
# Аналог release.ps1 для Linux/macOS.
# Использование: ./release.sh <version> [message]
# Пример:        ./release.sh 1.9.0 "fix weight scaling"
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <version> [message]" >&2
  echo "Example: $0 1.9.0 'fix weight scaling'" >&2
  exit 1
fi

VERSION="$1"
MESSAGE="${2:-release}"

# Bump версии в pubspec.yaml. Build-номер всегда +1, как в предыдущих релизах.
sed -i "s/^version: .*/version: ${VERSION}+1/" pubspec.yaml

echo "Version updated to ${VERSION}"

git add .
git commit -m "v${VERSION} ${MESSAGE}"
git push
git tag "v${VERSION}"
git push --tags

echo "Done! Check https://github.com/ShadowOfTime1/tortio/actions"
