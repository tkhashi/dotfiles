return {
  {
    "uga-rosa/translate.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("translate").setup({
        default = {
          command = "google", -- または 'deepl'
          -- 必要に応じてAPIキーを設定
          -- api_key = 'YOUR_API_KEY',
          target_lang = "JA",
        },
      })
    end,
  },
}
