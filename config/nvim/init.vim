set clipboard+=unnamedplus
lua << EOF
require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  -- Other plugins
end)

vim.api.nvim_set_keymap('n', '<Leader>f', '<cmd>Telescope find_files<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>g', '<cmd>Telescope live_grep<cr>', {noremap = true})
EOF

