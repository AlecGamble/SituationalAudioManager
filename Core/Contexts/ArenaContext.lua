local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)

local ArenaContext = 
{
    name = "Arena",
    key = "arena",
    menuOrder = 2,
    priority = 10,
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

function ArenaContext:IsActive()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "arena"
end

SituationalAudioManager:RegisterContext(ArenaContext)
return ArenaContext