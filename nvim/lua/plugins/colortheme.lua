return {
  'shaunsingh/nord.nvim',
  lazy = false,    -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- Example config in lua
    vim.g.nord_contrast = true                   -- Make sidebars and popup menus like nvim-tree and telescope have a different background
    vim.g.nord_borders = false                   -- Enable the border between vertically split windows visible
    vim.g.nord_disable_background = true         -- Disable background color so NeoVim can use your terminal background
    vim.g.set_cursorline_transparent = false     -- Set cursorline transparent/visible
    vim.g.nord_italic = false                    -- Enables/disables italics
    vim.g.nord_enable_sidebar_background = false -- Re-enables the background of the sidebar if disabled
    vim.g.nord_uniform_diff_background = true    -- Enables/disables colorful backgrounds in diff mode
    vim.g.nord_bold = false                      -- Enables/disables bold

    -- Load the colorscheme
    require('nord').set()

    -- Function to get inverted color
    local function invert_color(color)
      local inverted = 0xFFFFFF - color -- Subtract from white (RGB: 255,255,255)
      return string.format("#%06x", inverted) -- Convert back to hex
    end

    -- Function to update cursor color in insert mode
    local function update_cursor_color()
      local bg = vim.api.nvim_get_hl_by_name("Normal", true).background
      if bg then
        local inverted_bg = invert_color(bg)
        vim.api.nvim_set_hl(0, "Cursor", { fg = inverted_bg, bg = inverted_bg })
      end
    end

    -- Autocommands to toggle cursor color
    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = update_cursor_color
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
      callback = function()
        vim.api.nvim_set_hl(0, "Cursor", { fg = "NONE", bg = "NONE" }) -- Reset to default
      end
    })

    -- Toggle background transparency
    local bg_transparent = true
    local function toggle_transparency()
      bg_transparent = not bg_transparent
      vim.g.nord_disable_background = bg_transparent
      vim.cmd [[colorscheme nord]]
    end

    vim.keymap.set('n', '<leader>bg', toggle_transparency, { noremap = true, silent = true })
  end,
}

