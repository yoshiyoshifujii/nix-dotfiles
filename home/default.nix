{ config, pkgs, username, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = { ... }: {
      home.username = username;
      home.stateVersion = "24.05";

      home.packages = [
        pkgs.meslo-lgs-nf
      ];

      xdg.configFile."wezterm/wezterm.lua".text = ''
        local wezterm = require("wezterm")
        return {
          font_dirs = { "${pkgs.meslo-lgs-nf}/share/fonts/truetype" },
          font = wezterm.font("MesloLGS NF", { weight = "Regular" }),
          font_size = 13.0,
          color_scheme = "3024 Night",
          font_rasterizer = "FreeType",
          freetype_load_target = "Normal",
          freetype_render_target = "Normal",
          window_background_opacity = 0.8,
        }
      '';
    };
  };
}
