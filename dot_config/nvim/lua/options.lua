local opt = vim.opt

-- Line number
opt.number = true

-- tab & indent
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- searching
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- visual
opt.showmode = true
opt.cursorline = true

-- files
opt.backup = false
opt.writebackup = true
opt.swapfile = false
opt.undofile = true
opt.autoread = true

opt.runtimepath:append("~/plugins")


