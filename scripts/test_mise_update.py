"""Offline checks: python3 -m unittest discover -s scripts -p 'test_mise_update.py'."""

import contextlib
import importlib.util
import io
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("mise_update", Path(__file__).with_name("mise-update.py"))
update = importlib.util.module_from_spec(spec)
spec.loader.exec_module(update)


class UpdateTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.directory = self.root / "home/files/mise"
        self.directory.mkdir(parents=True)
        self.config = self.directory / "config.toml"
        self.lock = self.directory / "mise.lock"
        self.config.write_text('[settings]\nlocked = true\nlockfile = true\n[tools]\njava = "temurin-25.0.1"\nnode = "26.0.0"\n')
        self.lock.write_text('# original lock\n')
        self.original = (self.config.read_bytes(), self.lock.read_bytes())
        self.selectors = []

    def run_mise(self, command, **kwargs):
        if command[1] == "latest":
            self.selectors.append(command[2])
            version = "temurin-25.0.2" if command[2].startswith("java@") else "27.0.0"
            return subprocess.CompletedProcess(command, 0, version + "\n")
        self.assertEqual(command, ["mise", "lock", "--global"])
        work = Path(kwargs["cwd"])
        self.assertEqual(kwargs["env"]["MISE_GLOBAL_CONFIG_FILE"], str(work / "config.toml"))
        self.assertEqual(kwargs["env"]["MISE_LOCKED"], "0")
        (work / "mise.lock").write_text('[[tools.java]]\nversion = "temurin-25.0.2"\n[[tools.node]]\nversion = "27.0.0"\n')
        return subprocess.CompletedProcess(command, 0)

    def execute(self, write, runner=None):
        with patch.object(update, "ROOT", self.root), patch.object(update.subprocess, "run", side_effect=runner or self.run_mise), contextlib.redirect_stdout(io.StringIO()):
            update.update(write)

    def test_preview_preserves_files_and_java_series(self):
        self.execute(False)
        self.assertEqual(self.selectors, ["java@temurin-25", "node"])
        self.assertEqual(self.original, (self.config.read_bytes(), self.lock.read_bytes()))

    def test_write_updates_both_files(self):
        self.execute(True)
        self.assertIn('node = "27.0.0"', self.config.read_text())
        self.assertIn('locked = true', self.config.read_text())
        self.assertIn('version = "27.0.0"', self.lock.read_text())

    def test_lock_failure_preserves_both_files(self):
        def fail_lock(command, **kwargs):
            if command[1] == "lock":
                raise subprocess.CalledProcessError(1, command)
            return self.run_mise(command, **kwargs)
        with self.assertRaises(subprocess.CalledProcessError):
            self.execute(True, fail_lock)
        self.assertEqual(self.original, (self.config.read_bytes(), self.lock.read_bytes()))

    def test_stale_lock_preserves_both_files(self):
        def stale_lock(command, **kwargs):
            result = self.run_mise(command, **kwargs)
            if command[1] == "lock":
                (Path(kwargs["cwd"]) / "mise.lock").write_text('[[tools.node]]\nversion = "26.0.0"\n')
            return result
        with self.assertRaises(ValueError):
            self.execute(True, stale_lock)
        self.assertEqual(self.original, (self.config.read_bytes(), self.lock.read_bytes()))


if __name__ == "__main__":
    unittest.main()
