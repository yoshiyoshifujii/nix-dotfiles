#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/flake-update-flow.sh pre
  scripts/flake-update-flow.sh post [--no-push] [--message "<commit message>"]

Options:
  pre                   Run brew update/upgrade + flake update + stage lock + build
  post                  Commit and optionally push after manual make apply
  --no-push             Skip push in post phase
  --message <message>   Commit message (default: "chore(deps): update flake inputs")
  -h, --help            Show this help
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

phase=""
do_push=true
commit_message="chore(deps): update flake inputs"

while [[ $# -gt 0 ]]; do
  case "$1" in
    pre|post)
      if [[ -n "${phase}" ]]; then
        echo "Error: phase already set to '${phase}'" >&2
        usage
        exit 1
      fi
      phase="$1"
      shift
      ;;
    --no-push)
      do_push=false
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

if [[ -z "${phase}" ]]; then
  echo "Error: phase is required (pre or post)" >&2
  usage
  exit 1
fi

cd "${REPO_ROOT}"

if [[ "${phase}" == "pre" && -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is not clean. Commit/stash changes before running this flow." >&2
  git status --short
  exit 1
fi

if [[ "${phase}" == "pre" ]]; then
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "${current_branch}" != "main" ]]; then
    echo "Switching branch: ${current_branch} -> main"
    git checkout main
  fi

  echo "[1/5] Sync main with origin"
  git fetch origin
  git pull --ff-only origin main

  echo "[2/5] Run brew update/upgrade"
  brew update
  brew upgrade

  echo "[3/5] Run make flake-update"
  make flake-update

  echo "[4/5] Stage flake.lock before build"
  git add flake.lock

  echo "[5/5] Run make build"
  make build

  echo
  echo "Build succeeded. Next step (manual):"
  echo "  make apply"
  echo
  echo "After apply completes, run:"
  echo "  make flake-update-flow-post"
  exit 0
fi

if [[ -z "$(git status --porcelain -- flake.lock)" ]]; then
  echo "No flake.lock change detected. Nothing to commit."
  exit 0
fi

echo "Commit flake.lock"
git add flake.lock
git commit -m "${commit_message}"

if [[ "${do_push}" == "true" ]]; then
  echo "Push main -> origin"
  git push origin main
else
  echo "Push skipped (--no-push)"
fi

echo "Done."
