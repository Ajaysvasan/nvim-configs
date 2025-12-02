-- lua/ajay/dashboard.lua

local M = {}

-- Assassin's Creed Logo ASCII Art
local logo = [[
                      ███
                     █████
                    ███████
                   █████████
                  ███████████
                 █████████████
                ███████████████
               █████████████████
              ███████████████████
             █████████▀ ▀█████████
            █████████     █████████
           █████████       █████████
          ████████           ████████
         ████████             ████████
        ████████               ████████
       ███████                   ███████
      ██████                       ██████
     █████                           █████
    ████         ▄▄▄▄▄▄▄▄▄▄▄          ████
   ███         ███████████████         ███
  ██          █████████████████          ██
 ██          ███████████████████          ██
             ███████████████████
              █████████████████
               ███████████████
                 ███████████
                   ███████
]]

local title = [[
    ═══════════════════════════════════
    ║  ASSASSIN'S CREED - NEOVIM    ║
    ═══════════════════════════════════
]]

-- Gaming quotes
local quotes = {
  "Nothing is true, everything is permitted. - Assassin's Creed",
  "It's dangerous to go alone! Take this. - The Legend of Zelda",
  "War. War never changes. - Fallout",
  "The cake is a lie. - Portal",
  "Would you kindly? - BioShock",
  "Stay awhile and listen. - Diablo",
  "A man chooses, a slave obeys. - BioShock",
  "Requiescat in pace. - Assassin's Creed II",
  "Do you get to the Cloud District very often? - Skyrim",
  "The right man in the wrong place can make all the difference. - Half-Life 2",
  "We all make choices, but in the end our choices make us. - BioShock",
  "Had to be me. Someone else might have gotten it wrong. - Mass Effect 3",
  "I used to be an adventurer like you... - Skyrim",
  "Truth is... the game was rigged from the start. - Fallout: New Vegas",
  "Stand amongst the ashes of a trillion dead souls and ask if honor matters. - Mass Effect 3",
  "Even in dark times, we cannot relinquish the things that make us human. - Assassin's Creed",
}

function M.setup()
  -- Create custom dashboard
  local alpha_ok, alpha = pcall(require, "alpha")
  if not alpha_ok then
    vim.notify("Alpha not installed. Run :Lazy sync", vim.log.levels.WARN)
    return
  end

  local dashboard = require("alpha.themes.dashboard")

  -- Set header
  dashboard.section.header.val = vim.split(logo .. "\n" .. title, "\n")
  
  -- Random quote
  math.randomseed(os.time())
  local quote = quotes[math.random(#quotes)]
  dashboard.section.footer.val = "💀 " .. quote

  -- Set menu
  dashboard.section.buttons.val = {
    dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
    dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
    dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
    dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
    dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
  }

  -- Set highlight colors
  dashboard.section.header.opts.hl = "Type"
  dashboard.section.buttons.opts.hl = "Keyword"
  dashboard.section.footer.opts.hl = "Constant"

  -- Send config to alpha
  alpha.setup(dashboard.opts)

  -- Disable folding on alpha buffer
  vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
  ]])
end

return M
