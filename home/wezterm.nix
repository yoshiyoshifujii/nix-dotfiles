{ pkgs, ... }:
{
  home.packages = [
    pkgs.meslo-lgs-nf
    pkgs.nerd-fonts.jetbrains-mono
  ];

  xdg.configFile."wezterm/wezterm.lua".text =
    builtins.readFile ./wezterm/wezterm.lua;

  xdg.configFile."wezterm/appearance.lua".text =
    pkgs.lib.replaceStrings
      [ "@MESLO_FONT_DIR@" ]
      [ "${pkgs.meslo-lgs-nf}/share/fonts/truetype" ]
      (builtins.readFile ./wezterm/appearance.lua);

  xdg.configFile."wezterm/tmux.lua".text =
    builtins.readFile ./wezterm/tmux.lua;
}
