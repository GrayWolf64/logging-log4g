if SERVER then
    include("log4g/mmc-gui/server/ClientGUIConfigurator.lua")
    include("log4g/mmc-gui/server/ClientGUIManagement.lua")
    include("log4g/mmc-gui/server/ClientGUISummaryData.lua")
    AddCSLuaFile("log4g/mmc-gui/client/ClientGUI.lua")
elseif CLIENT then
    include("log4g/mmc-gui/client/ClientGUI.lua")
end