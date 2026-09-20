#!/usr/bin/env python3
"""Resolve tool pins, then publish config and lock only after successful locking."""

import argparse
import os
from pathlib import Path
import re
import subprocess
import tempfile
import tomllib
from typing import NamedTuple


ROOT = Path(__file__).resolve().parents[1]


class ToolPin(NamedTuple):
    tool: str
    version: str


# Pure core: all inputs are explicit; no filesystem, environment, or process access.
def parse_pins(config: str) -> tuple[ToolPin, ...]:
    tools = tomllib.loads(config)["tools"]
    for tool, version in tools.items():
        if not isinstance(version, str):
            raise ValueError(f"Unsupported tool configuration: {tool}")
    return tuple(ToolPin(tool, version) for tool, version in tools.items())


def latest_selector(pin: ToolPin, java_selector: str | None = None) -> str:
    if pin.tool != "java":
        return pin.tool
    match = re.match(r"(temurin-\d+)\.", pin.version)
    if not java_selector and not match:
        raise ValueError("Specify --java-selector for this Java distribution")
    return "java@" + (java_selector or match[1])


def parse_latest(tool: str, output: str) -> ToolPin:
    version = output.strip()
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9.+_-]*", version):
        raise ValueError(f"Invalid version returned for {tool}: {version!r}")
    return ToolPin(tool, version)


def render_config(config: str, pins: tuple[ToolPin, ...]) -> str:
    original = dict(parse_pins(config))
    updated = config
    for tool, version in pins:
        old = original[tool]
        pattern = rf'(?m)^(\s*{re.escape(tool)}\s*=\s*)"{re.escape(old)}"'
        updated, count = re.subn(pattern, lambda m: f'{m[1]}"{version}"', updated)
        if count != 1:
            raise ValueError(f"Expected one plain version assignment for {tool}")
    return updated


def validate_lock(pins: tuple[ToolPin, ...], lock: bytes) -> None:
    locked = tomllib.loads(lock.decode())["tools"]
    for tool, version in pins:
        if not any(entry["version"] == version for entry in locked.get(tool, [])):
            raise ValueError(f"Lockfile does not contain {tool}@{version}")


# Effectful shell: acquire inputs, call the pure core, then publish results.
def resolve_pin(pin: ToolPin, selector: str, work: Path, env: dict[str, str]) -> ToolPin:
    result = subprocess.run(["mise", "latest", selector], cwd=work, env=env,
                            check=True, capture_output=True, text=True)
    return parse_latest(pin.tool, result.stdout)


def publish(config: Path, lock: Path, original: str, original_lock: bytes,
            updated: str, new_lock: bytes) -> None:
    if config.read_text() != original or lock.read_bytes() != original_lock:
        raise ValueError("Source files changed during update; refusing to overwrite")
    config.write_text(updated)
    lock.write_bytes(new_lock)


def update(write=False, java_selector=None):
    directory = ROOT / "home/files/mise"
    config = directory / "config.toml"
    lock = directory / "mise.lock"
    original = config.read_text()
    original_lock = lock.read_bytes()
    pins = parse_pins(original)
    selectors = tuple(latest_selector(pin, java_selector) for pin in pins)
    with tempfile.TemporaryDirectory(prefix="mise-update-") as temporary:
        work = Path(temporary)
        # Use a temporary global config: never write Home Manager's Nix symlinks.
        env = dict(os.environ, MISE_GLOBAL_CONFIG_FILE=str(work / "config.toml"),
                   MISE_LOCKED="0", MISE_YES="1")
        (work / "config.toml").write_text(original)
        (work / "mise.lock").write_bytes(original_lock)
        resolved = tuple(resolve_pin(pin, selector, work, env)
                         for pin, selector in zip(pins, selectors, strict=True))
        updated = render_config(original, resolved)
        for old, new in zip(pins, resolved, strict=True):
            print(f"{old.tool}: {old.version} -> {new.version}", flush=True)
        if not write:
            print("Preview only. Use --write to update config.toml and mise.lock.")
            return
        (work / "config.toml").write_text(updated)
        subprocess.run(["mise", "lock", "--global"], cwd=work, env=env, check=True)
        new_lock = (work / "mise.lock").read_bytes()
        validate_lock(resolved, new_lock)
        publish(config, lock, original, original_lock, updated, new_lock)
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
