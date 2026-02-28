#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/flake-update-flow.sh [--commit] [--push] [--message "<commit message>"]

Options:
  --commit              Commit flake.lock after build/apply wait
  --push                Push main to origin (implies --commit)
  --message <message>   Commit message (default: "chore: update flake inputs")
  -h, --help            Show this help
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

do_commit=false
do_push=false
commit_message="chore: update flake inputs"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --commit)
      do_commit=true
      shift
      ;;
    --push)
      do_push=true
      do_commit=true
      shift
      ;;
    --message)
      if [[ $# -lt 2 ]]; then
        echo "Error: --message requires a value" >&2
        usage
        exit 1
      fi
      commit_message="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

cd "${REPO_ROOT}"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is not clean. Commit/stash changes before running this flow." >&2
  git status --short
  exit 1
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "${current_branch}" != "main" ]]; then
  echo "Switching branch: ${current_branch} -> main"
  git checkout main
fi

echo "[1/5] Sync main with origin"
git fetch origin
git pull --ff-only origin main

echo "[2/5] Run make flake-update"
make flake-update

echo "[3/5] Run make build"
make build

echo "[4/5] Run make apply manually in another terminal:"
echo "      make apply"
read -r -p "Press Enter after apply is complete..."

if [[ "${do_commit}" == "false" ]]; then
  echo "[5/5] Commit/push skipped (run with --commit or --push to enable)"
  exit 0
fi

if [[ -z "$(git status --porcelain -- flake.lock)" ]]; then
  echo "[5/5] No flake.lock change detected. Nothing to commit."
  exit 0
fi

echo "[5/5] Commit flake.lock"
git add flake.lock
git commit -m "${commit_message}"

if [[ "${do_push}" == "true" ]]; then
  echo "Push main -> origin"
  git push origin main
fi

echo "Done."
