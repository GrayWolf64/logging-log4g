--- Initialization of Log4g MMC GUI on server and client.
-- It's based on [Derma](https://wiki.facepunch.com/gmod/Derma_Basic_Guide) UI system that comes with the game itself.
-- @script MMC-Init
if SERVER then
    include("log4g/mmc-gui/server/ClientGUIConfigurator.lua")
    include("log4g/mmc-gui/server/ClientGUISummaryData.lua")
    AddCSLuaFile("log4g/mmc-gui/client/ClientGUIDerma.lua")
    AddCSLuaFile("log4g/mmc-gui/client/ClientGUI.lua")
elseif CLIENT then
    include("log4g/mmc-gui/client/ClientGUI.lua")
end