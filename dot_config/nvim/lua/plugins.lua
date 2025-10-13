vim.cmd('packadd vim-jetpack')

require('jetpack.packer').add {
    {'tani/vim-jetpack'},
    {'folke/tokyonight.nvim'},
    {'nvim-lualine/lualine.nvim'},
    {'ibhagwan/fzf-lua'},
    {'cohama/lexima.vim'},
    {'vim-denops/denops.vim'},
    {'github/copilot.vim'},
    {'goolord/alpha-nvim'},
    {'nvim-treesitter/nvim-treesitter'},
    {'yukimura1227/vim-yazi'},
}

local jetpack = require('jetpack')
for _, name in ipairs(jetpack.names()) do
  if not jetpack.tap(name) then
    jetpack.sync()
    break
  end
end

require('104-alpha')

vim.opt.termguicolors = true

require("tokyonight").setup({
    style = "storm",
    transparent = true,
})

vim.cmd("colorscheme tokyonight-storm")

require('lualine').setup{
    options = {
        theme = 'tokyonight'
    },
}

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    disable = {
      'lua',
      'ruby',
      'toml',
      'c_sharp',
      'vue',
      'javascript',
      'typescript',
      'html',
    }
  },
  indent = {
      enable = true,
  },
  ensure_installed = 'all',
}
