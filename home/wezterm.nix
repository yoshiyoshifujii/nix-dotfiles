{ pkgs, ... }:
{
  # ============================================================
  # WezTerm ターミナル設定
  # ============================================================

  xdg.configFile."wezterm/wezterm.lua".text =
    builtins.readFile ./files/wezterm/wezterm.lua;

  xdg.configFile."wezterm/appearance.lua".text =
    pkgs.lib.replaceStrings
      [ "@MESLO_FONT_DIR@" ]
      [ "${pkgs.meslo-lgs-nf}/share/fonts/truetype" ]
      (builtins.readFile ./files/wezterm/appearance.lua);

  xdg.configFile."wezterm/tmux.lua".text =
    builtins.readFile ./files/wezterm/tmux.lua;
}
