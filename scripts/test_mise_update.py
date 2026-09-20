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


class PureCoreTest(unittest.TestCase):
    def test_selector_preserves_java_major_version(self):
        # Given
        pin = update.ToolPin("java", "temurin-25.0.1")
        # When
        selector = update.latest_selector(pin)
        # Then
        self.assertEqual(selector, "java@temurin-25")

    def test_selector_uses_explicit_java_override(self):
        # Given
        pin = update.ToolPin("java", "temurin-25.0.1")
        # When
        selector = update.latest_selector(pin, "temurin")
        # Then
        self.assertEqual(selector, "java@temurin")

    def test_selector_uses_tool_name_for_non_java_tools(self):
        # Given
        pin = update.ToolPin("node", "26.0.0")
        # When
        selector = update.latest_selector(pin)
        # Then
        self.assertEqual(selector, "node")

    def test_selector_rejects_unknown_java_distribution_without_override(self):
        # Given
        pin = update.ToolPin("java", "other-25")
        # When / Then
        with self.assertRaisesRegex(ValueError, "Specify --java-selector"):
            update.latest_selector(pin)

    def test_parse_pins_rejects_non_string_versions(self):
        # Given
        config = '[tools]\nnode = ["25", "26"]\n'
        # When / Then
        with self.assertRaisesRegex(ValueError, "Unsupported tool configuration: node"):
            update.parse_pins(config)

    def test_parse_latest_accepts_java_version_with_build_suffix(self):
        # Given
        output = "temurin-25.0.3+9.0.LTS"
        # When
        pin = update.parse_latest("java", output)
        # Then
        self.assertEqual(pin, update.ToolPin("java", output))

    def test_parse_latest_strips_surrounding_whitespace(self):
        # Given
        output = " 27.0.0\n"
        # When
        pin = update.parse_latest("node", output)
        # Then
        self.assertEqual(pin, update.ToolPin("node", "27.0.0"))

    def test_parse_latest_rejects_empty_output(self):
        # Given
        output = ""
        # When / Then
        with self.assertRaisesRegex(ValueError, "Invalid version returned for node"):
            update.parse_latest("node", output)

    def test_parse_latest_rejects_multiple_versions(self):
        # Given
        output = "26.0.0\n27.0.0"
        # When / Then
        with self.assertRaisesRegex(ValueError, "Invalid version returned for node"):
            update.parse_latest("node", output)

    def test_parse_latest_rejects_quoted_version(self):
        # Given
        output = '"26.0.0"'
        # When / Then
        with self.assertRaisesRegex(ValueError, "Invalid version returned for node"):
            update.parse_latest("node", output)

    def test_render_replaces_requested_version(self):
        # Given
        config = '[tools]\nnode = "26.0.0"\n'
        pins = (update.ToolPin("node", "27.0.0"),)
        # When
        rendered = update.render_config(config, pins)
        # Then
        self.assertEqual(rendered, '[tools]\nnode = "27.0.0"\n')

    def test_render_preserves_comments(self):
        # Given
        config = '# pins\n[tools]\nnode = "26.0.0" # keep\n'
        pins = (update.ToolPin("node", "27.0.0"),)
        # When
        rendered = update.render_config(config, pins)
        # Then
        self.assertEqual(rendered, '# pins\n[tools]\nnode = "27.0.0" # keep\n')

    def test_render_preserves_settings(self):
        # Given
        config = '[settings]\nlocked = true\n[tools]\nnode = "26.0.0"\n'
        pins = (update.ToolPin("node", "27.0.0"),)
        # When
        rendered = update.render_config(config, pins)
        # Then
        self.assertEqual(rendered, '[settings]\nlocked = true\n[tools]\nnode = "27.0.0"\n')

    def test_render_returns_same_result_for_same_inputs(self):
        # Given
        config = '[tools]\nnode = "26.0.0"\n'
        pins = (update.ToolPin("node", "27.0.0"),)
        # When
        first = update.render_config(config, pins)
        second = update.render_config(config, pins)
        # Then
        self.assertEqual(first, second)

    def test_validate_lock_accepts_matching_version(self):
        # Given
        pins = (update.ToolPin("node", "27.0.0"),)
        lock = b'[[tools.node]]\nversion = "27.0.0"\n'
        # When
        result = update.validate_lock(pins, lock)
        # Then
        self.assertIsNone(result)

    def test_validate_lock_rejects_mismatched_version(self):
        # Given
        pins = (update.ToolPin("node", "27.0.0"),)
        lock = b'[[tools.node]]\nversion = "26.0.0"\n'
        # When / Then
        with self.assertRaisesRegex(ValueError, "Lockfile does not contain node@27"):
            update.validate_lock(pins, lock)


class UpdateTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        directory = self.root / "home/files/mise"
        directory.mkdir(parents=True)
        self.config = directory / "config.toml"
        self.lock = directory / "mise.lock"
        self.config.write_text(
            '[settings]\nlocked = true\nlockfile = true\n[tools]\n'
            'java = "temurin-25.0.1"\nnode = "26.0.0"\n'
        )
        self.lock.write_text('# original lock\n')

    def snapshot(self):
        return self.config.read_bytes(), self.lock.read_bytes()

    def run_mise(self, command, **kwargs):
        """Simulate mise without embedding assertions shared by unrelated tests."""
        if command[1] == "latest":
            version = "temurin-25.0.2" if command[2].startswith("java@") else "27.0.0"
            return subprocess.CompletedProcess(command, 0, version + "\n")
        if command[1] == "lock":
            work = Path(kwargs["cwd"])
            (work / "mise.lock").write_text(
                '[[tools.java]]\nversion = "temurin-25.0.2"\n'
                '[[tools.node]]\nversion = "27.0.0"\n'
            )
            return subprocess.CompletedProcess(command, 0)
        raise RuntimeError(f"Unexpected command: {command}")

    def execute(self, write, runner=None):
        with (
            patch.object(update, "ROOT", self.root),
            patch.object(update.subprocess, "run", side_effect=runner or self.run_mise) as mise,
            contextlib.redirect_stdout(io.StringIO()),
        ):
            update.update(write)
        return mise.call_args_list

    def test_preview_preserves_repository_files(self):
        # Given
        original = self.snapshot()
        # When
        self.execute(False)
        # Then
        self.assertEqual(self.snapshot(), original)

    def test_preview_resolves_configured_tools_with_java_series(self):
        # Given: setUp provides Temurin 25 and Node pins.
        # When
        calls = self.execute(False)
        # Then
        self.assertEqual(
            [call.args[0] for call in calls],
            [["mise", "latest", "java@temurin-25"], ["mise", "latest", "node"]],
        )

    def test_write_saves_resolved_config_version(self):
        # Given: the fake mise resolves Node to 27.0.0.
        # When
        self.execute(True)
        # Then
        self.assertIn('node = "27.0.0"', self.config.read_text())

    def test_write_saves_generated_lockfile(self):
        # Given: the fake mise generates a lockfile for the resolved versions.
        # When
        self.execute(True)
        # Then
        self.assertIn('version = "27.0.0"', self.lock.read_text())

    def test_write_locks_global_config(self):
        # Given: setUp provides writable repository files.
        # When
        calls = self.execute(True)
        # Then
        self.assertEqual(calls[-1].args[0], ["mise", "lock", "--global"])

    def test_write_targets_temporary_config(self):
        # Given: setUp provides writable repository files.
        # When
        calls = self.execute(True)
        lock_call = calls[-1]
        # Then
        self.assertEqual(
            lock_call.kwargs["env"]["MISE_GLOBAL_CONFIG_FILE"],
            str(Path(lock_call.kwargs["cwd"]) / "config.toml"),
        )

    def test_write_disables_locked_mode_for_lock_generation(self):
        # Given: the repository config enables locked mode.
        # When
        calls = self.execute(True)
        # Then
        self.assertEqual(calls[-1].kwargs["env"]["MISE_LOCKED"], "0")

    def test_lock_failure_preserves_repository_files(self):
        # Given
        original = self.snapshot()

        def fail_lock(command, **kwargs):
            if command[1] == "lock":
                raise subprocess.CalledProcessError(1, command)
            return self.run_mise(command, **kwargs)

        # When
        with self.assertRaises(subprocess.CalledProcessError):
            self.execute(True, fail_lock)
        # Then
        self.assertEqual(self.snapshot(), original)

    def test_stale_lock_preserves_repository_files(self):
        # Given
        original = self.snapshot()

        def stale_lock(command, **kwargs):
            result = self.run_mise(command, **kwargs)
            if command[1] == "lock":
                (Path(kwargs["cwd"]) / "mise.lock").write_text(
                    '[[tools.node]]\nversion = "26.0.0"\n'
                )
            return result

        # When
        with self.assertRaises(ValueError):
            self.execute(True, stale_lock)
        # Then
        self.assertEqual(self.snapshot(), original)

    def test_concurrent_edit_prevents_publishing(self):
        # Given
        edited = self.config.read_bytes() + b"# concurrent edit\n"
        expected = (edited, self.lock.read_bytes())

        def edit_source(command, **kwargs):
            result = self.run_mise(command, **kwargs)
            if command[1] == "lock":
                self.config.write_bytes(edited)
            return result

        # When
        with self.assertRaisesRegex(ValueError, "Source files changed"):
            self.execute(True, edit_source)
        # Then
        self.assertEqual(self.snapshot(), expected)


if __name__ == "__main__":
    unittest.main()
