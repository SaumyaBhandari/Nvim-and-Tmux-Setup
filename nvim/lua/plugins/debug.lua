-- debug.lua
-- DAP configuration for Neovim using lazy.nvim

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Creates a beautiful debugger UI
    "rcarriga/nvim-dap-ui",

    -- Required dependency for nvim-dap-ui
    "nvim-neotest/nvim-nio",

    -- Installs the debuggers for you
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        "chrome",
        "node2",
      },
    })

    -- Basic keymaps for debugging
    vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
    vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: Set Breakpoint with Condition" })
    vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
    vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })

    -- Define visual signs in the gutter for breakpoints
    vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" })
    vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bg = "#3e4452" })
    
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "➜", texthl = "DapStopped", linehl = "DapStopped", numhl = "" })

    -- Dap UI setup
    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
    })

    -- Toggle to see last session result
    vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle DAP UI" })

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Node adapter configuration (for backend attachment)
    dap.adapters.node2 = {
      type = "executable",
      command = "node",
      args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
    }

    -- Chrome adapter configuration (for frontend attachment)
    dap.adapters.chrome = {
      type = "executable",
      command = "node",
      args = { vim.fn.stdpath("data") .. "/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js" },
    }

    local js_config = {
      {
        name = "Attach Node to port 9229 (Backend)",
        type = "node2",
        request = "attach",
        port = 9229,
        address = "localhost",
        localRoot = "${workspaceFolder}",
        remoteRoot = "/app",
        sourceMaps = true,
      },
      {
        name = "Attach Chrome to port 9222 (Frontend)",
        type = "chrome",
        request = "attach",
        port = 9222,
        webRoot = "${workspaceFolder}",
        sourceMaps = true,
      }
    }

    dap.configurations.javascript = js_config
    dap.configurations.typescript = js_config
    dap.configurations.javascriptreact = js_config
    dap.configurations.typescriptreact = js_config
  end,
}
