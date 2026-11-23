#!/usr/bin/env bash
# artifact.cafe — zero-Node publish helper.
#
# This is the fallback for environments without Node/npx. When Node is
# available, prefer `npx artifact-cafe publish .` (same behavior, richer
# output). This script speaks the same /api/v1 contract as the npm CLI:
#
#   scan → ignore rules → entry → manifest (sha256) → create session →
#   presigned PUT uploads → finalize → print review URL → write config.
#
# Requires: bash, curl, jq, and one of {shasum, sha256sum}.
set -euo pipefail

DEFAULT_API_URL="https://artifact.cafe"
UPLOAD_TIMEOUT=120

DIR="."
TITLE=""
DESCRIPTION=""
ENTRY=""
ARTIFACT_ID_FLAG=""
API_URL_FLAG=""
CLIENT="${ARTIFACT_CAFE_AGENT:-}"
JSON=0
OPEN=1

usage() {
  cat <<'USAGE'
Usage: publish.sh [dir] [options]

Publishes a folder of static files as an artifact for review.

Options:
  --title <text>       Artifact title
  --description <text> Share-card summary (overrides the entry HTML)
  --entry <file>       Entry file (default: index.html, else the only .html file
                       in the folder root, else artifact.cafe makes one)
  --artifact <id>      Publish a new version to an existing artifact id
  --client <name>      Agent name for attribution (e.g. claude-code, cursor)
  --api-url <url>      API base (default: $ARTIFACT_CAFE_URL, else the folder config,
                       else https://artifact.cafe)
  --json               Machine-readable output
  --no-open            Don't open the review URL in a browser
  -h, --help           Show this help

Credentials, in this order (the script takes no secret as a flag):
  ARTIFACT_CAFE_API_KEY      Account key (ack_) or agent token (aat_). If it is
                             not set: the key that `artifact-cafe login` stored.
  .artifactcafe/config.json  Publish token of the artifact of this folder
  ARTIFACT_CAFE_TOKEN        Publish token of one artifact
With no credential, a new artifact is anonymous and expires after 24 hours.
USAGE
  exit "${1:-1}"
}

die() {
  if [[ "$JSON" -eq 1 ]]; then
    jq -n --arg m "$1" '{error:$m}' >&2
  else
    echo "error: $1" >&2
  fi
  exit 1
}

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || die "requires $cmd (not found on PATH)"
done

# sha256 helper — macOS ships shasum, most Linux ship sha256sum.
if command -v sha256sum >/dev/null 2>&1; then
  sha256_of() { sha256sum "$1" | awk '{print $1}'; }
elif command -v shasum >/dev/null 2>&1; then
  sha256_of() { shasum -a 256 "$1" | awk '{print $1}'; }
else
  die "requires sha256sum or shasum"
fi

# byte size of a file — BSD (macOS) vs GNU stat differ.
if stat -f%z . >/dev/null 2>&1; then
  size_of() { stat -f%z "$1"; }
else
  size_of() { stat -c%s "$1"; }
fi

# A flag that takes a value must have one.
need_value() { [[ $# -ge 2 && "$2" != --* ]] || die "$1 needs a value. Run publish.sh --help."; }

# Parse args. First non-flag positional is the directory.
DIR_SET=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)    need_value "$@"; TITLE="$2"; shift 2 ;;
    --description) need_value "$@"; DESCRIPTION="$2"; shift 2 ;;
    --entry)    need_value "$@"; ENTRY="$2"; shift 2 ;;
    --artifact) need_value "$@"; ARTIFACT_ID_FLAG="$2"; shift 2 ;;
    --client)   need_value "$@"; CLIENT="$2"; shift 2 ;;
    --api-url)  need_value "$@"; API_URL_FLAG="$2"; shift 2 ;;
    --json)     JSON=1; shift ;;
    --no-open)  OPEN=0; shift ;;
    -h|--help)  usage 0 ;;
    -*)         die "unknown option: $1" ;;
    *)          [[ "$DIR_SET" -eq 0 ]] && { DIR="$1"; DIR_SET=1; shift; } || die "unexpected argument: $1" ;;
  esac
done

[[ -d "$DIR" ]] || die "not a directory: $DIR"
DIR="$(cd "$DIR" && pwd)"

log() { [[ "$JSON" -eq 1 ]] || echo "$@"; }

# ── MIME map — kept in sync with the artifact-cafe CLI ────────────────────
mime_for() {
  local ext
  ext="$(printf '%s' "${1##*.}" | tr '[:upper:]' '[:lower:]')"
  case "$ext" in
    html|htm)  echo "text/html" ;;
    css)       echo "text/css" ;;
    csv)       echo "text/csv" ;;
    js|mjs)    echo "text/javascript" ;;
    json|map)  echo "application/json" ;;
    txt)       echo "text/plain" ;;
    md|markdown) echo "text/markdown" ;;
    xml)       echo "application/xml" ;;
    svg)       echo "image/svg+xml" ;;
    png)       echo "image/png" ;;
    jpg|jpeg)  echo "image/jpeg" ;;
    gif)       echo "image/gif" ;;
    webp)      echo "image/webp" ;;
    avif)      echo "image/avif" ;;
    ico)       echo "image/x-icon" ;;
    woff)      echo "font/woff" ;;
    woff2)     echo "font/woff2" ;;
    ttf)       echo "font/ttf" ;;
    otf)       echo "font/otf" ;;
    pdf)       echo "application/pdf" ;;
    mp4)       echo "video/mp4" ;;
    webm)      echo "video/webm" ;;
    mp3)       echo "audio/mpeg" ;;
    wav)       echo "audio/wav" ;;
    wasm)      echo "application/wasm" ;;
    *)         echo "application/octet-stream" ;;
  esac
}

# ── Ignore rules — kept in sync with the artifact-cafe CLI ────────────────
# Secrets and junk never leave the machine; the API enforces size limits.
ignored_file() {
  local base="$1"
  case "$base" in
    .DS_Store|.env|.env.*|.git*|artifact-cafe.json) return 0 ;;
    *.pem|*.key) return 0 ;;
  esac
  return 1
}

# ── Scan ───────────────────────────────────────────────────────────────────
# Prune ignored directories (node_modules, .artifactcafe, .git*), then filter
# files. Paths are relative to DIR with forward slashes.
MANIFEST_NDJSON="$(mktemp)"
IGNORED_LIST="$(mktemp)"
trap 'rm -f "$MANIFEST_NDJSON" "$IGNORED_LIST"' EXIT

file_count=0

while IFS= read -r -d '' abs; do
  rel="${abs#"$DIR"/}"
  base="${abs##*/}"
  if ignored_file "$base"; then
    printf '%s\n' "$rel" >>"$IGNORED_LIST"
    continue
  fi
  size="$(size_of "$abs")"
  if [[ "$size" -le 0 ]]; then
    printf '%s\n' "$rel" >>"$IGNORED_LIST"
    continue
  fi
  hash="sha256_$(sha256_of "$abs")"
  mime="$(mime_for "$rel")"
  jq -n --arg p "$rel" --arg h "$hash" --argjson s "$size" --arg m "$mime" \
    '{path:$p,hash:$h,size:$s,mimeType:$m}' >>"$MANIFEST_NDJSON"
  file_count=$((file_count + 1))
done < <(
  find "$DIR" -type d \( -name node_modules -o -name .artifactcafe -o -name '.git*' \) -prune -o \
    -type f -print0
)

[[ "$file_count" -gt 0 ]] || die "Nothing to publish in $DIR (after ignore rules)."

FILES_JSON="$(jq -s 'sort_by(.path)' "$MANIFEST_NDJSON")"
IGNORED_JSON="$(jq -R -s 'split("\n") | map(select(length > 0))' "$IGNORED_LIST")"
skipped_count="$(jq 'length' <<<"$IGNORED_JSON")"
if [[ "$skipped_count" -gt 0 ]]; then
  preview="$(awk 'NR<=5{printf "%s%s",(NR>1?", ":""),$0} END{if(NR>5)printf ", …"}' "$IGNORED_LIST")"
  log "  ignoring $skipped_count item(s): $preview"
fi

# ── Resolve entry ──────────────────────────────────────────────────────────
have_path() { jq -e --arg p "$1" 'any(.[]; .path == $p)' >/dev/null <<<"$FILES_JSON"; }
if [[ -n "$ENTRY" ]]; then
  have_path "$ENTRY" || die "Entry file \"$ENTRY\" not found in the publish folder."
elif have_path "index.html"; then
  ENTRY="index.html"
else
  # As in the CLI: one HTML file at the root is the entry. With none, the server makes the entry.
  root_html="$(jq -r '[.[] | select(.mimeType == "text/html" and (.path | contains("/") | not))] | map(.path) | @tsv' <<<"$FILES_JSON")"
  n=0; [[ -n "$root_html" ]] && n="$(awk -F'\t' '{print NF}' <<<"$root_html")"
  if [[ "$n" -eq 1 ]]; then
    ENTRY="$root_html"
  elif [[ "$n" -gt 1 ]]; then
    die "Multiple HTML files found ($root_html). Pass --entry <file>."
  fi
fi

# ── Config & auth ──────────────────────────────────────────────────────────
CONFIG_DIR="$DIR/.artifactcafe"
CONFIG_FILE="$CONFIG_DIR/config.json"
# A symbolic link would send the config writes to another folder.
for f in "$CONFIG_DIR" "$CONFIG_FILE" "$CONFIG_DIR/.gitignore"; do
  if [[ -L "$f" ]]; then die "refusing to write through a symbolic link: $f"; fi
done
cfg() { [[ -f "$CONFIG_FILE" ]] && jq -r --arg k "$1" '.[$k] // empty' "$CONFIG_FILE" 2>/dev/null || true; }
CFG_ARTIFACT_ID="$(cfg artifactId)"
CFG_TOKEN="$(cfg publishToken)"
CFG_API_URL="$(cfg apiUrl)"

PROJECT_CONFIG=""
cursor="$DIR"
while true; do
  if [[ -f "$cursor/artifact-cafe.json" ]]; then
    PROJECT_CONFIG="$cursor/artifact-cafe.json"
    break
  fi
  [[ -e "$cursor/.git" ]] && break
  parent="$(dirname "$cursor")"
  [[ "$parent" == "$cursor" ]] && break
  cursor="$parent"
done

ARTIFACT_ID="${ARTIFACT_ID_FLAG:-$CFG_ARTIFACT_ID}"
API_URL="${API_URL_FLAG:-${ARTIFACT_CAFE_URL:-${CFG_API_URL:-$DEFAULT_API_URL}}}"
API_URL="${API_URL%/}"

if [[ -z "$ARTIFACT_ID" && -n "$PROJECT_CONFIG" ]]; then
  die "Project workspace defaults require the npm CLI: npx artifact-cafe@latest publish \"$DIR\" --json"
fi

# Credential order, as in the npm CLI: the account key, then the folder token,
# then ARTIFACT_CAFE_TOKEN. The folder token is good only for its own artifact.
origin="$(sed -E 's#^([^:/]+://[^/]+).*#\1#' <<<"$API_URL")"
KEY="${ARTIFACT_CAFE_API_KEY:-}"
KEY_SOURCE="ARTIFACT_CAFE_API_KEY"
CREDENTIALS="$HOME/.artifactcafe/credentials"
if [[ -z "$KEY" && -f "$CREDENTIALS" ]]; then
  KEY="$(jq -r --arg o "$origin" '.keys[$o] // empty' "$CREDENTIALS" 2>/dev/null || true)"
  KEY_SOURCE="the stored login in ~/.artifactcafe/credentials"
fi
FOLDER_SOURCE="the publish token in .artifactcafe/config.json"
FOLDER_TOKEN=""
if [[ -n "$ARTIFACT_ID" && "$ARTIFACT_ID" == "$CFG_ARTIFACT_ID" ]]; then
  FOLDER_TOKEN="$CFG_TOKEN"
fi
TOKEN="${KEY:-${FOLDER_TOKEN:-${ARTIFACT_CAFE_TOKEN:-}}}"
# The source of TOKEN, never its value, names the credential in an error.
if [[ -n "$KEY" ]]; then
  SOURCE="$KEY_SOURCE"
elif [[ -n "$FOLDER_TOKEN" ]]; then
  SOURCE="$FOLDER_SOURCE"
else
  SOURCE="ARTIFACT_CAFE_TOKEN"
fi

# ── Create publish session ─────────────────────────────────────────────────
aid_json="null"; [[ -n "$ARTIFACT_ID" ]] && aid_json="$(jq -n --arg a "$ARTIFACT_ID" '$a')"
body="$(
  jq -n \
    --argjson aid "$aid_json" \
    --arg entry "$ENTRY" \
    --argjson files "$FILES_JSON" \
    --arg title "$TITLE" \
    --arg description "$DESCRIPTION" \
    --arg agent "$CLIENT" \
    --arg runid "${ARTIFACT_CAFE_RUN_ID:-}" \
    '{
      artifactId: $aid,
      files: $files,
      source: ({type:"cli"}
        + (if $agent == "" then {} else {agent:$agent} end)
        + (if $runid == "" then {} else {runId:$runid} end))
    }
    + (if $entry == "" then {} else {entryPath:$entry} end)
    + (if $title == "" then {} else {title:$title} end)
    + (if $description == "" then {} else {description:$description} end)'
)"

# POST path body: sets STATUS and OUT. curl reads the credential header from
# stdin, so the credential is not in the process list.
post() {
  local resp
  resp="$(curl -sS -X POST ${TOKEN:+-H @-} -H "content-type: application/json" \
    --data "$2" -w $'\n%{http_code}' "$API_URL$1" <<<"${TOKEN:+authorization: Bearer $TOKEN}")" \
    || die "could not reach $API_URL — is the API up?"
  STATUS="${resp##*$'\n'}"
  OUT="${resp%$'\n'*}"
}

ok_or_die() { # dies on non-2xx with structured error
  if [[ "$STATUS" -lt 200 || "$STATUS" -ge 300 ]]; then
    local code msg
    code="$(jq -r '.code // "http_'"$STATUS"'"' <<<"$OUT" 2>/dev/null || echo "http_$STATUS")"
    msg="$(jq -r '.message // empty' <<<"$OUT" 2>/dev/null || true)"
    if [[ ("$STATUS" == 401 || "$STATUS" == 403) && -n "$TOKEN" ]]; then
      die "$origin refused the credential from $SOURCE: ${msg:-unauthorized} [$code] Run \`npx artifact-cafe@latest login\` on a machine with Node, or set ARTIFACT_CAFE_API_KEY to a valid key."
    fi
    die "${msg:-request failed} [$code]"
  fi
}

log "  publishing $file_count file(s) from $DIR"
post "/api/v1/publish" "$body"
# An account key is good only for artifacts of its account. If the API refuses
# the key, use the publish token one time, as the CLI does: the artifact can be anonymous.
RETRY_TOKEN="${FOLDER_TOKEN:-${ARTIFACT_CAFE_TOKEN:-}}"
if [[ ("$STATUS" == 401 || "$STATUS" == 403) && -n "$KEY" && "$KEY" != aat_* \
  && -n "$RETRY_TOKEN" && "$RETRY_TOKEN" != "$KEY" ]]; then
  TOKEN="$RETRY_TOKEN"
  if [[ -n "$FOLDER_TOKEN" ]]; then SOURCE="$FOLDER_SOURCE"; else SOURCE="ARTIFACT_CAFE_TOKEN"; fi
  post "/api/v1/publish" "$body"
fi
ok_or_die
session="$OUT"
SESSION_ID="$(jq -r '.publishSessionId' <<<"$session")"
UP_COUNT="$(jq -r '.filesToUpload | length' <<<"$session")"
SKIP_UNCHANGED="$(jq -r '.skippedFiles | length' <<<"$session")"

msg="  uploading $UP_COUNT file(s)"
[[ "$SKIP_UNCHANGED" -gt 0 ]] && msg+=", $SKIP_UNCHANGED unchanged"
log "$msg"

# ── Upload each new blob via its presigned PUT ─────────────────────────────
# The presign signs content-type + content-length; curl sets content-length
# from --data-binary, and we send the matching content-type.
while IFS=$'\t' read -r up_path up_url; do
  [[ -n "$up_path" ]] || continue
  abs="$DIR/$up_path"
  mime="$(mime_for "$up_path")"
  # The query of a presigned URL holds its signature, so the error names only the host.
  up_host="${up_url#*://}"; up_host="${up_host%%[/?]*}"
  curl -fsS --max-time "$UPLOAD_TIMEOUT" -X PUT \
    -H "content-type: $mime" -H "Expect:" \
    --data-binary @"$abs" "$up_url" >/dev/null \
    || die "upload to the storage host $up_host failed for $up_path"
done < <(jq -r '.filesToUpload[] | [.path, .uploadUrl] | @tsv' <<<"$session")

# ── Finalize ───────────────────────────────────────────────────────────────
post "/api/v1/publish/$SESSION_ID/finalize" ""
ok_or_die
result="$OUT"
URL="$(jq -r '.url' <<<"$result")"
VERSION="$(jq -r '.versionNumber' <<<"$result")"
NEW_TOKEN="$(jq -r '.publishToken // empty' <<<"$result")"
CLAIM_URL="$(jq -r '.claimUrl // empty' <<<"$result")"
RESULT_ARTIFACT_ID="$(jq -r '.artifactId' <<<"$result")"
VISIBILITY="$(jq -r '.visibility // empty' <<<"$result")"
EXPIRES_AT="$(jq -r '.expiresAt // empty' <<<"$result")"
AUTO_DELETE_AT="$(jq -r '.autoDeleteAt // empty' <<<"$result")"

# Who can open the review URL. Only `workspace`/`private` need saying —
# on public/unlisted "anyone with the link" is the point of the link.
ACCESS_NOTE=""
case "$VISIBILITY" in
  workspace) ACCESS_NOTE="Access: workspace members only — anyone else needs \`artifact-cafe share <email>\` to open it." ;;
  private)   ACCESS_NOTE="Access: private — you, the workspace's admins, and anyone you \`artifact-cafe share\` it with." ;;
esac

DESTINATION="anonymous"
DESTINATION_SOURCE="anonymous-default"
DESTINATION_LABEL="Anonymous"
if [[ -n "$ARTIFACT_ID" ]]; then
  DESTINATION="existing-artifact"
  DESTINATION_SOURCE="artifact-config"
  DESTINATION_LABEL="Existing artifact"
elif [[ "$TOKEN" == aat_* ]]; then
  DESTINATION="workspace"
  DESTINATION_SOURCE="agent-token"
  DESTINATION_LABEL="Agent token's workspace"
elif [[ "$TOKEN" == ack_* ]]; then
  DESTINATION="personal"
  DESTINATION_SOURCE="personal-default"
  DESTINATION_LABEL="Personal"
fi

# ── Persist config for a new artifact (never print the token) ──────────────
# An agent token gets no publish token, but the next run must publish a new
# version of the same artifact.
if [[ -n "$NEW_TOKEN" || -z "$ARTIFACT_ID" ]]; then
  slug="${URL##*/a/}"
  mkdir -p "$CONFIG_DIR"
  ( umask 177
    jq -n --arg id "$RESULT_ARTIFACT_ID" --arg slug "$slug" --arg url "$URL" \
      --arg api "$API_URL" --arg tok "$NEW_TOKEN" \
      '{artifactId:$id, slug:$slug, url:$url, apiUrl:$api}
        + (if $tok == "" then {} else {publishToken:$tok} end)' \
      >"$CONFIG_FILE" )
  chmod 600 "$CONFIG_FILE" 2>/dev/null || true
fi
# Git then ignores the token, with no change to the .gitignore of the folder.
if [[ -f "$CONFIG_FILE" && ! -f "$CONFIG_DIR/.gitignore" ]]; then
  printf '*\n' >"$CONFIG_DIR/.gitignore"
fi

# ── Output ─────────────────────────────────────────────────────────────────
if [[ "$JSON" -eq 1 ]]; then
  jq -n \
    --arg id "$RESULT_ARTIFACT_ID" --argjson v "$VERSION" --arg url "$URL" \
    --arg destination "$DESTINATION" --arg source "$DESTINATION_SOURCE" \
    --arg claim "$CLAIM_URL" --argjson session "$session" --argjson ignored "$IGNORED_JSON" \
    --arg visibility "$VISIBILITY" --arg expires "$EXPIRES_AT" --arg autodelete "$AUTO_DELETE_AT" \
    '{
      artifactId:$id, versionNumber:$v, url:$url,
      destination:$destination, destinationSource:$source,
      visibility: (if $visibility == "" then null else $visibility end),
      expiresAt: (if $expires == "" then null else $expires end),
      autoDeleteAt: (if $autodelete == "" then null else $autodelete end),
      filesUploaded: ($session.filesToUpload | map(.path)),
      skippedFiles: $session.skippedFiles,
      ignored: $ignored
    } + (if $claim == "" then {} else {claimUrl:$claim} end)'
elif [[ "$VERSION" == "1" ]]; then
  echo ""
  echo "✓ Published to artifact.cafe"
  echo ""
  echo "Destination: $DESTINATION_LABEL"
  echo ""
  if [[ -n "$CLAIM_URL" ]]; then
    echo "For you (shown once — open it to claim and share this artifact):"
    echo "$CLAIM_URL"
  else
    echo "Review URL:"
    echo "$URL"
  fi
  if [[ -n "$ACCESS_NOTE" ]]; then
    echo ""
    echo "$ACCESS_NOTE"
  fi
  echo ""
else
  echo ""
  echo "✓ Published v$VERSION"
  echo "Destination: $DESTINATION_LABEL"
  echo ""
  echo "$URL"
  if [[ -n "$ACCESS_NOTE" ]]; then
    echo ""
    echo "$ACCESS_NOTE"
  fi
  echo ""
fi
if [[ "$JSON" -eq 0 && -n "$EXPIRES_AT" ]]; then
  kind="Anonymous artifact"; [[ -n "$AUTO_DELETE_AT" ]] && kind="Temporary artifact"
  echo "$kind — expires at $EXPIRES_AT. All versions, comments, files, and artifact data will be automatically deleted."
  echo ""
fi

# Best-effort browser open for interactive terminals only.
if [[ "$OPEN" -eq 1 && "$JSON" -eq 0 && -t 1 ]]; then
  if command -v open >/dev/null 2>&1; then open "$URL" >/dev/null 2>&1 || true
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$URL" >/dev/null 2>&1 || true
  fi
fi
