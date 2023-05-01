--- Initialization of Log4g MMC GUI on server and client.
-- It's based on [Derma](https://wiki.facepunch.com/gmod/Derma_Basic_Guide) UI system that comes with the game itself.
-- @script MMC
-- @license Apache License 2.0
-- @copyright GrayWolf64
if SERVER then
    Log4g.RegisterPackage("log4g-mmc", "0.0.5-beta")
    include"log4g/mmc-gui/server/ClientGUI.lua"
    AddCSLuaFile"log4g/mmc-gui/client/MMCDerma.lua"
    AddCSLuaFile"log4g/mmc-gui/client/MMCGUI.lua"
elseif CLIENT then
    include"log4g/mmc-gui/client/MMCGUI.lua"
end