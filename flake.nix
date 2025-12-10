{
  description = "flake for ubuntu nix in docker";

  inputs = {
    # Nixpkgs: pick whichever branch/channel you like
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # Define a Home Manager configuration for a user named "zed".
      homeConfigurations.zed = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          {
            home.username = "zed";
            home.homeDirectory = "/home/zed";
            home.stateVersion = "24.11";

            home.packages = with pkgs; [
              nettools
            ];

            programs.fish = {
              enable = true;
              interactiveShellInit = ''
                set fish_greeting
          
                functions = {
                  starship_transient_prompt_func.body = ''starship module time'';
                  prompt_newline = {
                    onEvent = "fish_postexec";
                    body = ''echo'';
                  };
                };

                fish_vi_key_bindings
                bind yy fish_clipboard_copy
                bind -M visual y fish_clipboard_copy
                # bind -M default p forward-char-passive fish_clipboard_paste backward-char-passive
                # bind -M default P fish_clipboard_paste
          
                function _aichat_fish
                    set -l text (commandline)
                    if test -n "$text"
                        commandline -r ""                     # clear your input
                        printf '\r\e[2C\e[K'                 # show icon at col 3, clear rest of line
                        set -l out (aichat -e -- "$text")     # run AI
                        commandline -r "$out"                 # replace with AI output
                        commandline -f repaint                 # redraw prompt (overwrites the icon)
                    end
                end
                bind \ee _aichat_fish
          
              '';
              plugins = [
                {
                  name = "bass";
                  src = pkgs.fishPlugins.bass.src;
                }
              ];
            };

            programs.neovim = {
              enable = true;
              extraLuaConfig = ''
                vim.opt.number = true
                vim.opt.shortmess:append("I")
              '';
            };

            programs.fzf = {
                enable = true;
                enableZshIntegration = true;
            };

            programs.bat = {
                enable = true;
            };

            programs.starship = {
                enable = true;
                enableFishIntegration = true;
                enableTransience = true;
            
                settings = {
                  # ─ Global options ─────────────────────────────────────────────────────────
                  right_format = "$cmd_duration"; # right-prompt → 27 ms
            
                  # Palette (same hex codes you used in Oh-My-Posh) ─────────────────────────
                  palette = "catppuccin";
            
                  palettes.catppuccin = {
                    blue = "#8AADF4";
                    green = "#a6da95";
                    lavender = "#B7BDF8";
                    mauve = "#c6a0f6";
                    os = "#ACB0BE";
                    peach = "#F5A97F";
                    pink = "#F5BDE6";
                    sapphire = "#7dc4e4";
                    yellow = "#eed49f";
                    sky = "#91d7e3";
                    flamingo = "#f0c6c6";
                    rosewater = "#4dbd6";
                    maroon = "#ee99a0";
                    teal = "#8bd5ca";
                  };
            
                  # ─ What gets printed on the left prompt line ─────────────────────────────
                  format = ''
                    $os $username@$hostname $directory $git_branch$line_break$character
                  '';
            
                  add_newline = false;
            
                  # 1 • Current time (18:49) -------------------------------------------------
                  time = {
                    disabled = false;
                    time_format = "%H:%M";
                    style = "fg:yellow";
                    format = "[$time]($style) "; # trailing space ␠
                  };
            
                  # 2 • OS icon (snow-flake Nix) --------------------------------------------
                  os = {
                    disabled = false;
                    style = "fg:sky";
                    format = "[$symbol]($style)";
                    symbols = {
                      NixOS = "";
                      Ubuntu = "";
                      Arch = "";
                      Fedora = "";
                      Debian = "";
                    };
                  };
            
                  # 3 • user@host ------------------------------------------------------------
                  username = {
                    show_always = true;
                    style_user = "fg:pink";
                    style_root = "fg:red";
                    format = "[$user]($style)";
                  };
                  hostname = {
                    ssh_only = false;
                    style = "fg:mauve";
                    format = "[$hostname]($style)"; # trailing space
                  };
            
                  # 4 • Path (“~/workspace/…”) ----------------------------------------------
                  directory = {
                    truncation_length = 0;
                    truncate_to_repo = false;
                    home_symbol = "~";
                    style = "fg:flamingo";
                    read_only = " ";
                    read_only_style = "fg:flamingo";
                    format = "[$read_only]($read_only_style)[$path]($style)";
                    repo_root_format = "[$read_only]($read_only_style)[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($repo_root_style)";
                    before_repo_root_style = "fg:flamingo";
                    repo_root_style = "fg:teal";
                  };
            
                  # 5 • Git HEAD -------------------------------------------------------------
                  git_branch = {
                    symbol = " ";
                    style = "fg:teal";
                    format = "[$symbol$branch]($style) ";
                  };
            
                  container = {
                    symbol = " ";
                    style = "fg:maroon";
                    format = "[$symbol$container]($style) ";
                  };
            
                  # ── second line: prompt symbol ❯  ─────────────────────────────────────────
                  character = {
                    success_symbol = "[❯](green)";
                    error_symbol = "[❯](fg:red)";
                    vimcmd_symbol = "[❮](fg:peach)";
                    vimcmd_visual_symbol = "[❮](fg:mauve)";
                    vimcmd_replace_symbol = "[❮](fg:sky)";
                    vimcmd_replace_one_symbol = "[❮](fg:pink)";
                  };
            
                  # ── right prompt: elapsed time (27 ms) ───────────────────────────────────
                  cmd_duration = {
                    min_time = 0; # always display
                    show_milliseconds = true;
                    style = "fg:peach";
                    format = "[$duration]($style)";
                  };
                };
              };
        ];
      };
    };
}
