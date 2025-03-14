local show_foldsigns = true

local M = {
    offset = -2,
    foldsigns = {
        close = '+',
        open = '-',
        seps = { '│', '┃' },
    }
}

function M.setsign(line, sign)
    vim.api.nvim_buf_set_extmark(
        0, M.ns, line, 0,
        { virt_text_win_col = M.offset - M.numberwidth, virt_text = { { sign, 'FoldColumn' } } }
    )
end

function M.toggle_foldsigns()
    show_foldsigns = not show_foldsigns
    if show_foldsigns then
        M.foldsign()
    else
        vim.api.nvim_buf_clear_namespace(0, M.ns, 0, -1)
    end
end

function M.foldsign()
    if not show_foldsigns then
        return
    end
    local topline = vim.fn.line('w0') - 1
    local botline = vim.fn.line('w$')
    vim.api.nvim_buf_clear_namespace(0, M.ns, topline, botline)

    local numberwidth = #tostring(vim.fn.line('$'))
    if numberwidth < vim.o.numberwidth - 1 then numberwidth = vim.o.numberwidth -1 end
    M.numberwidth = numberwidth

    local pre = 0
    for i = topline, botline do
        local foldlevel = vim.fn.foldlevel(i)
        if foldlevel > 0 then
            local foldtext = ' '
            local foldclosed = vim.fn.foldclosed(i)
            if foldclosed > 0 and i == foldclosed then
                foldtext = M.foldsigns.close
            elseif foldlevel > pre then
                foldtext = M.foldsigns.open
            else
                foldtext = M.foldsigns.seps[foldlevel] or M.foldsigns.seps[#M.foldsigns.seps]
            end
            M.setsign(i - 1, foldtext)
        end
        pre = foldlevel
    end
end

function M.setup(opt)
    M.ns = vim.api.nvim_create_namespace('foldsign')
    if opt and opt.foldsigns then M.foldsigns = opt.foldsigns end
    if opt and opt.offset ~= nil then M.offset = opt.offset end
    vim.cmd('au VimEnter,WinEnter,BufWinEnter,ModeChanged,CursorMoved,CursorHold * lua require("nvim-foldsign").foldsign()')
end

return M
