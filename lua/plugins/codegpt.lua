return {
  "dpayne/CodeGPT.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("codegpt.config")
    -- Open API key and api endpoint
    local is_thunk = vim.loop.os_gethostname() == "thunk"
    vim.g["codegpt_openai_api_provider"] = "OpenAI" -- or Azure
    if is_thunk then
      vim.g["codegpt_chat_completions_url"] = "http://docker.linetco.com:5000/v1/chat/completions"
    else
      vim.g["codegpt_openai_api_key"] = os.getenv("OPENAI_API_KEY")
    end
    -- clears visual selection after completion
    vim.g["codegpt_clear_visual_selection"] = true
  end,
}
