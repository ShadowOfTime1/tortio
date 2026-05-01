#!/usr/bin/env bash
# Заливает уже опубликованный GitHub Release vX.Y.Z в указанные треки Google
# Play через Play Developer API. Использует service account из
# ~/.config/tortio/play-sa.json (см. memory reference_play_console_api.md).
#
# Usage:  ./play_release.sh <version> <track> [<track>...] [-n "notes"]
# Tracks: internal | alpha | beta | production
# Example:
#   ./play_release.sh 0.1.6 internal alpha
#   ./play_release.sh 0.1.6 internal -n "Hotfix: dark theme contrast"
#
# Если -n не передан — release notes берутся из commit message git-тега
# vX.Y.Z (release.sh создаёт его как "vX.Y.Z <message>").
#
# Internal публикуется мгновенно. Alpha/Beta/Production уходят на review
# Google (1-7 дней).
set -euo pipefail

NOTES=""
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--notes) NOTES="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,16p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    -*) echo "Unknown flag: $1" >&2; exit 1 ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

if [[ ${#ARGS[@]} -lt 2 ]]; then
  echo "Usage: $0 <version> <track> [<track>...] [-n \"notes\"]" >&2
  echo "Tracks: internal | alpha | beta | production" >&2
  exit 1
fi

VERSION="${ARGS[0]}"
TRACKS=("${ARGS[@]:1}")

SA="${TORTIO_PLAY_SA:-$HOME/.config/tortio/play-sa.json}"
VENV="${TORTIO_PLAY_VENV:-$HOME/.config/tortio/venv}"

if [[ ! -f "$SA" ]]; then
  echo "Service account not found: $SA" >&2; exit 1
fi
if [[ ! -x "$VENV/bin/python" ]]; then
  echo "Python venv not found: $VENV (see reference_play_console_api memory)" >&2; exit 1
fi

# Default notes: extract message from "vX.Y.Z message" tag commit
if [[ -z "$NOTES" ]]; then
  RAW=$(git log -1 --format=%s "v${VERSION}" 2>/dev/null || true)
  NOTES="${RAW#v${VERSION} }"
  [[ -z "$NOTES" || "$NOTES" == "$RAW" ]] && NOTES="Release ${VERSION}"
fi

AAB="/tmp/tortio-v${VERSION}.aab"
echo ">> Downloading AAB v${VERSION} from GitHub Release..."
gh release download "v${VERSION}" \
  --repo ShadowOfTime1/tortio \
  --pattern "app-play-release.aab" \
  --output "$AAB" --clobber

echo ">> Uploading to Play tracks: ${TRACKS[*]}"
"$VENV/bin/python" - "$SA" "$AAB" "$VERSION" "$NOTES" "${TRACKS[@]}" <<'PY'
import sys
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.errors import HttpError

sa, aab, version, notes, *tracks = sys.argv[1:]
PKG = 'com.tortio.app'

creds = service_account.Credentials.from_service_account_file(
    sa, scopes=['https://www.googleapis.com/auth/androidpublisher']
)
svc = build('androidpublisher', 'v3', credentials=creds, cache_discovery=False)

edit = svc.edits().insert(packageName=PKG, body={}).execute()
eid = edit['id']
print(f'   edit: {eid}')

vc = None
try:
    media = MediaFileUpload(aab, mimetype='application/octet-stream', resumable=True)
    bundle = svc.edits().bundles().upload(packageName=PKG, editId=eid, media_body=media).execute()
    vc = bundle['versionCode']
    print(f'   uploaded versionCode: {vc}')
except HttpError as e:
    msg = str(e)
    # APK уже в библиотеке — переиспользуем существующий versionCode
    if 'already' in msg.lower() or 'apkUpgradeVersionConflict' in msg:
        bundles = svc.edits().bundles().list(packageName=PKG, editId=eid).execute()
        if bundles.get('bundles'):
            vc = max(b['versionCode'] for b in bundles['bundles'])
            print(f'   AAB already in library, reusing versionCode: {vc}')
        else:
            raise
    else:
        raise

release_notes = [
    {'language': 'ru-RU', 'text': notes[:500]},
    {'language': 'en-US', 'text': notes[:500]},
]
for track in tracks:
    svc.edits().tracks().update(
        packageName=PKG, editId=eid, track=track,
        body={'releases': [{
            'name': f'{version} (auto)',
            'versionCodes': [str(vc)],
            'status': 'completed',
            'releaseNotes': release_notes,
        }]}
    ).execute()
    print(f'   {track}: set to {vc}')

svc.edits().commit(packageName=PKG, editId=eid).execute()
print('   committed.')
PY

rm -f "$AAB"
echo ">> Done."
