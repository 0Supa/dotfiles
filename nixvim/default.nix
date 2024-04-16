{
  globals.mapleader = " ";

  opts = {
    mouse = "a";

    expandtab = true;
    shiftwidth = 4;
    smartindent = true;
    tabstop = 4;
    completeopt = "menu,noinsert,preview";
    hidden = true;
    ignorecase = true;
    joinspaces = false;
    scrolloff = 4;
    shiftround = true;
    sidescrolloff = 8;
    smartcase = true;
    splitright = true;
    wildmode = "list:longest";
    list = true;
    number = true;
    relativenumber = true;
    wrap = true;
    undofile = true;
    clipboard = "unnamedplus";
    cursorline = true;
    spell = true;
  };

  colorschemes = {
    catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = true;
      };
    };
  };

  plugins = {
    bufferline.enable = true;

    telescope.enable = true;
    treesitter.enable = true;
    luasnip.enable = true;

    lualine = {
      enable = true;
      iconsEnabled = false;
    };

    oil = {
      enable = true;
      settings = {
        columns = [
          "type"
          "mtime"
        ];
      };
    };

    lsp = {
      enable = true;
      servers = {
        tsserver.enable = true;
        lua-ls.enable = true;
        gopls.enable = true;
      };
    };

    cmp = {
      enable = true;
      autoEnableSources = true;
    };
    cmp-nvim-lsp.enable = true;
    cmp-path.enable = true;
    cmp-buffer.enable = true;
    cmp-nvim-lua.enable = true;
  };

  keymaps = [
    {
      key = "<leader>g";
      action = "<cmd>Telescope live_grep<CR>";
    }
  ];
}
