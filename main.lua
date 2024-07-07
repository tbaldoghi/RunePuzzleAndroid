-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")

display.setStatusBar(display.hiddenStatusBar)
display.setDefault("background", 0, 0, 0)
math.randomseed(os.time())
composer.gotoScene("scenes.menu")
