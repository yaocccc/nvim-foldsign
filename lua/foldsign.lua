local M = {
    foldsigns = {
        closed = '+',
        opened = '-',
        folding = { '│', '┃' },
    }
}

function M.setsign(line, sign)
    vim.api.nvim_buf_set_extmark(
        0,
        M.ns,
        line,
        0,
        { virt_text_win_col = -2 - M.numberwidth, virt_text = { { sign, 'FoldColumn' } } }
    )
end

function M.foldsign()
    local topline = vim.fn.line('w0') - 1
    local botline = vim.fn.line('w$')
    vim.api.nvim_buf_clear_namespace(0, M.ns, topline, botline)

    local numberwidth = #tostring(vim.fn.line('$'))
    if numberwidth < vim.o.numberwidth then numberwidth = vim.o.numberwidth end
    M.numberwidth = numberwidth

    local pre = 0
    for i = topline, botline do
        local foldlevel = vim.fn.foldlevel(i)
        if foldlevel > 0 then
            local foldtext = ' '
            local foldclosed = vim.fn.foldclosed(i)
            if foldclosed > 0 and i == foldclosed then
                foldtext = M.foldsigns.closed
            elseif foldlevel > pre then
                foldtext = M.foldsigns.opened
            else
                foldtext = M.foldsigns.folding[foldlevel] or M.foldsigns.folding[#M.foldsigns.folding]
            end
            M.setsign(i - 1, foldtext)
        end
        pre = foldlevel
    end
end

function M.setup(opt)
    M.ns = vim.api.nvim_create_namespace('foldsign')
    if opt.foldsigns ~= nil then M.foldsigns = opt.foldsigns end
    vim.cmd('au VimEnter,WinEnter,BufWinEnter,ModeChanged,CursorMoved,CursorHold * lua require("foldsign").foldsign()')
end

return M
