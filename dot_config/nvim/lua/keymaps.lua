for k, v in pairs({
    ['vv'] = '<S-v>',
    ['<F2>'] = ':FzfLua files<CR>',
    [':f'] = ':FzfLua ',
    ['<F3>'] = ':Yazi<CR>',
}) do 
    vim.api.nvim_set_keymap('n', k, v, {})
end
