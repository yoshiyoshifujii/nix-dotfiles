#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly DEFAULT_COMMIT_MESSAGE="chore(deps): update flake inputs"

usage() {
  cat <<'USAGE'
Usage:
  scripts/flake-update-flow.sh pre
  scripts/flake-update-flow.sh post [--no-push] [--message "<commit message>"]

Options:
  pre                   Run sync + flake update + stage lock + build
  post                  Commit and optionally push after manual make apply
  --no-push             Skip push in post phase
  --message <message>   Commit message (default: "chore(deps): update flake inputs")
  -h, --help            Show this help
USAGE
}

log() {
  printf '%s\n' "$*"
}

err() {
  printf 'Error: %s\n' "$*" >&2
}

run_step() {
  local label="$1"
  shift
  log "${label}"
  "$@"
}

parse_args() {
  PHASE=""
  DO_PUSH=true
  COMMIT_MESSAGE="${DEFAULT_COMMIT_MESSAGE}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      pre|post)
        if [[ -n "${PHASE}" ]]; then
          err "phase already set to '${PHASE}'"
          usage
          exit 1
        fi
        PHASE="$1"
        shift
        ;;
      --no-push)
        DO_PUSH=false
        shift
        ;;
      --message)
        if [[ $# -lt 2 ]]; then
          err "--message requires a value"
          usage
          exit 1
        fi
        COMMIT_MESSAGE="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        err "unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  if [[ -z "${PHASE}" ]]; then
    err "phase is required (pre or post)"
    usage
    exit 1
  fi
}

ensure_clean_worktree() {
  if [[ -n "$(git status --porcelain)" ]]; then
    err "working tree is not clean. Commit/stash changes before running this flow."
    git status --short
    exit 1
  fi
}

checkout_main_if_needed() {
  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "${current_branch}" != "main" ]]; then
    log "Switching branch: ${current_branch} -> main"
    git checkout main
  fi
}

run_pre() {
  ensure_clean_worktree
  checkout_main_if_needed

  run_step "[1/4] Sync main with origin" git fetch origin
  git pull --ff-only origin main

  run_step "[2/4] Run make flake-update" make flake-update
  run_step "[3/4] Stage flake.lock before build" git add flake.lock
  run_step "[4/4] Run make build" make build

  log
  log "Build succeeded. Next step (manual):"
  log "  make apply"
  log
  log "After apply completes, run:"
  log "  make flake-update-flow-post"
}

run_post() {
  if [[ -z "$(git status --porcelain -- flake.lock)" ]]; then
    log "No flake.lock change detected. Nothing to commit."
    return 0
  fi

  run_step "Commit flake.lock" git add flake.lock
  git commit -m "${COMMIT_MESSAGE}"

  if [[ "${DO_PUSH}" == "true" ]]; then
    run_step "Push main -> origin" git push origin main
  else
    log "Push skipped (--no-push)"
  fi

  log "Done."
}

main() {
  parse_args "$@"
  cd "${REPO_ROOT}"

  case "${PHASE}" in
    pre) run_pre ;;
    post) run_post ;;
    *)
      err "unsupported phase: ${PHASE}"
      exit 1
      ;;
  esac
}

main "$@"
