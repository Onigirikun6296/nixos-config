{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        options = {
          termguicolors = true;
          mouse = "a";
          undofile = true;
          number = true;
          clipboard = "unnamedplus";
          relativenumber = true;
          tabstop = 4;
          shiftwidth = 4;
          expandtab = true;
          autoindent = true;
          smartindent = true;
          conceallevel = 2;
          concealcursor = "nc";
        };
        maps = {
          normal = {
            tt = {
              desc = "Open Terminal";
              action = ":split<Bar>terminal<CR>";
              noremap = true;
            };
            "<Esc>" = {
              action = "<cmd>nohlsearch<CR>";
            };
          };
        };

        lsp = {
          enable = true;
          otter-nvim = {
            enable = true;
          };
        };

        treesitter = {
          enable = true;
          indent.enable = false;
        };

        statusline.lualine = {
          enable = true;
        };

        filetree.nvimTree = {
          enable = true;
          mappings.toggle = "<c-f>";
          openOnSetup = false;
        };

        autopairs.nvim-autopairs = {
          enable = true;
        };

        binds.whichKey = {
          enable = true;
        };

        comments.comment-nvim = {
          enable = true;
        };

        notify.nvim-notify = {
          enable = true;
        };
        ui = {
          colorizer = {
            enable = true;
            setupOpts = {
              filetypes = {
                css = {};
              };
            };
          };
          borders = {
            enable = true;
            plugins = {
              nvim-cmp.enable = true;
              which-key.enable = true;
            };
          };
        };
        autocomplete = {
          nvim-cmp = {
            enable = true;
            mappings = {
              next = "<c-n>";
              previous = "<c-p>";
            };
            setupOpts = {
              window = {
                completion = {
                  cmp.config.window.bordered = {};
                };
                documentation = {
                  cmp.config.window.bordered = {};
                };
              };
            };
            sourcePlugins = [
              "cmp-buffer"
            ];
          };
        };
        snippets = {
          luasnip = {
            enable = true;
          };
        };
       /* - The option definition `vim.languages.ts.format.package' in `/nix/store/slr706w1a2b41qgs75n7kldwqppmvyfl-source/home-manager/nvim.nix' no longer has any effect; please remove it.
       `vim.languages.ts.format.package` is removed, please use `vim.formatter.conform-nvim.formatters.<formatter_name>.command` instead.


       - The option definition `vim.languages.css.format.package' in `/nix/store/slr706w1a2b41qgs75n7kldwqppmvyfl-source/home-manager/nvim.nix' no longer has any effect; please remove it.
       `vim.languages.css.format.package` is removed, please use `vim.formatter.conform-nvim.formatters.<formatter_name>.command` instead. */
        formatter = {
            conform-nvim = {
                enable = true;
            };
        };

        languages = {
          # enableFormat = true;
          enableTreesitter = true;
          nix = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          rust = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          python = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          typescript = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          css = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          html = {
            enable = true;
            treesitter.enable = true;
          };
          clang = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          nu = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
        };
        telescope = {
          enable = true;
        };

        extraPlugins = {
          sonokai = {
            package = pkgs.vimPlugins.sonokai;
          };
          orgmode = {
            package = pkgs-unstable.vimPlugins.orgmode;
            setup =
              /*
              lua
              */
              ''
                require('orgmode').setup({
                  org_agenda_files = '~/orgfiles/**/*',
                  org_default_notes_file = '~/orgfiles/refile.org',
                  notifications = {
                    enabled = false,
                    cron_enabled = true,
                    repeater_reminder_time = false,
                    deadline_warning_reminder_time = false,
                    reminder_time = {1, 5, 10, 60},
                    deadline_reminder = true,
                    scheduled_reminder = true,
                    notifier = function(tasks)
                      local result = {}
                      for _, task in ipairs(tasks) do
                        require('orgmode.utils').concat(result, {
                          string.format('# %s (%s)', task.category, task.humanized_duration),
                          string.format('%s %s %s', string.rep('*', task.level), task.todo,
                                        task.title),
                          string.format('%s: <%s>', task.type, task.time:to_string())
                        })
                      end

                      if not vim.tbl_isempty(result) then
                        require('orgmode.notifications.notification_popup'):new({
                          content = result
                        })
                      end
                    end,
                    cron_notifier = function(tasks)
                      for _, task in ipairs(tasks) do
                        local icon =
                            "${pkgs.kdePackages.oxygen-icons}/share/icons/oxygen/base/64x64/mimetypes/text-calendar.png"
                        local title = string.format('%s (%s)', task.category,
                                                    task.humanized_duration)
                        local subtitle = string.format('%s %s %s', string.rep('*', task.level),
                                                       task.todo, task.title)
                        local date = string.format('%s: %s', task.type, task.time:to_string())

                        -- Linux
                        if vim.fn.executable('notify-send') == 1 then
                          vim.loop.spawn('notify-send', {
                            args = {
                              '-i', icon, string.format('%s\n%s\n%s', title, subtitle, date)
                            }
                          })
                        end

                      end
                    end
                  },
                })

                vim.api.nvim_create_autocmd('BufEnter', {
                  pattern = {'*.org'},
                  group = group,
                  command = 'setlocal nowrap'
                })

              '';
          };
        };
        luaConfigPost = ''
          vim.cmd("set noshowmode")
          vim.cmd("let g:sonokai_style = 'shusia'")
          vim.cmd("let g:sonokai_better_performance = 1")
          vim.cmd("let g:sonokai_enable_italic = 1")
          vim.cmd("let g:sonokai_diagnostic_virtual_text = 'colored'")
          vim.cmd("colorscheme sonokai")
        '';
      };
    };
  };
}
