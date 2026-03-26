local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)

local BattlegroundsContext = 
{
    name = "Battlegrounds",
    key = "battlegrounds",
    menuOrder = 3,
    priority = 9,
    overrides = 
    {
        "MasterVolume",
        "MusicVolume",
        "SFXVolume",
        "AmbienceVolume",
        "DialogVolume",
        "GameplaySFXVolume"
    }
}

function BattlegroundsContext:IsActive()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "pvp"
end

SituationalAudioManager:RegisterContext(BattlegroundsContext)
return BattlegroundsContext