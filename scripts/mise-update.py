#!/usr/bin/env python3
"""Resolve tool pins, then publish config and lock only after successful locking."""

import argparse
import os
from pathlib import Path
import re
import subprocess
import tempfile
import tomllib


ROOT = Path(__file__).resolve().parents[1]


def update(write=False, java_selector=None):
    directory = ROOT / "home/files/mise"
    config = directory / "config.toml"
    lock = directory / "mise.lock"
    original = config.read_text()
    original_lock = lock.read_bytes()
    tools = tomllib.loads(original)["tools"]
    updated = original
    with tempfile.TemporaryDirectory(prefix="mise-update-") as temporary:
        work = Path(temporary)
        # Use a temporary global config: never write Home Manager's Nix symlinks.
        env = dict(os.environ, MISE_GLOBAL_CONFIG_FILE=str(work / "config.toml"),
                   MISE_LOCKED="0", MISE_YES="1")
        (work / "config.toml").write_text(original)
        (work / "mise.lock").write_bytes(original_lock)
        for tool, old in tools.items():
            if not isinstance(old, str):
                raise ValueError(f"Unsupported tool configuration: {tool}")
            selector = tool
            if tool == "java":
                match = re.match(r"(temurin-\d+)\.", old)
                if not java_selector and not match:
                    raise ValueError("Specify --java-selector for this Java distribution")
                selector = "java@" + (java_selector or match[1])
            result = subprocess.run(["mise", "latest", selector], cwd=work, env=env,
                                    check=True, capture_output=True, text=True)
            version = result.stdout.strip()
            if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9.+_-]*", version):
                raise ValueError(f"Invalid version returned for {tool}: {version!r}")
            print(f"{tool}: {old} -> {version}", flush=True)
            pattern = rf'(?m)^(\s*{re.escape(tool)}\s*=\s*)"{re.escape(old)}"'
            updated, count = re.subn(pattern, lambda m: f'{m[1]}"{version}"', updated)
            if count != 1:
                raise ValueError(f"Expected one plain version assignment for {tool}")
        if not write:
            print("Preview only. Use --write to update config.toml and mise.lock.")
            return
        (work / "config.toml").write_text(updated)
        subprocess.run(["mise", "lock", "--global"], cwd=work, env=env, check=True)
        new_lock = (work / "mise.lock").read_bytes()
        locked = tomllib.loads(new_lock.decode())["tools"]
        for tool, version in tomllib.loads(updated)["tools"].items():
            if not any(entry["version"] == version for entry in locked.get(tool, [])):
                raise ValueError(f"Lockfile does not contain {tool}@{version}")
        if config.read_text() != original or lock.read_bytes() != original_lock:
            raise ValueError("Source files changed during update; refusing to overwrite")
        config.write_text(updated)
        lock.write_bytes(new_lock)
    print("Updated. Review git diff -- home/files/mise, then run make build.")
    print("After a successful build: make apply && make mise-install")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="save resolved pins and lockfile")
    parser.add_argument("--java-selector", help="Java selector, e.g. temurin-25 or temurin")
    args = parser.parse_args()
    try:
        update(args.write, args.java_selector)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"mise update failed: {error}\n{getattr(error, 'stderr', '') or ''}")


if __name__ == "__main__":
    main()
