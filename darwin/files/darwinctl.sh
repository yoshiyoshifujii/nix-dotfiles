set -euo pipefail

repo_root="${DARWINCTL_REPO_ROOT:?DARWINCTL_REPO_ROOT is not set}"

if [ ! -d "$repo_root" ]; then
  echo "Repository not found: $repo_root" >&2
  exit 1
fi

target="${1:-help}"
shift || true

case "$target" in
  help|-h|--help)
    cat <<'EOF'
Usage: darwinctl <command> [args]

Commands:
  help          Show this help
  update        Run make flake-update-flow
  build         Run make build
  apply         Run make apply
  diff          Run make flake-lock-diff
  closure-diff  Run make closure-diff
  post          Run make flake-update-flow-post
  make          Run an arbitrary make target

Examples:
  darwinctl update
  darwinctl apply
  darwinctl post FLOW_ARGS=--no-push
  darwinctl make flake-update-nixpkgs
EOF
    ;;
  update)
    exec /usr/bin/make -C "$repo_root" flake-update-flow "$@"
    ;;
  build)
    exec /usr/bin/make -C "$repo_root" build "$@"
    ;;
  apply)
    exec /usr/bin/make -C "$repo_root" apply "$@"
    ;;
  diff)
    exec /usr/bin/make -C "$repo_root" flake-lock-diff "$@"
    ;;
  closure-diff)
    exec /usr/bin/make -C "$repo_root" closure-diff "$@"
    ;;
  post)
    exec /usr/bin/make -C "$repo_root" flake-update-flow-post "$@"
    ;;
  make)
    exec /usr/bin/make -C "$repo_root" "$@"
    ;;
  *)
    echo "Unknown command: $target" >&2
    echo "Run 'darwinctl help' for usage." >&2
    exit 1
    ;;
esac
