local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)

local DungeonContext = 
{
    name = "Dungeon",
    key = "dungeon",
    menuOrder = 5,
    priority = 11,
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

function DungeonContext:IsActive()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "party"
end

SituationalAudioManager:RegisterContext(DungeonContext)
return DungeonContext