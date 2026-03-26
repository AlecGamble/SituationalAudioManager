local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)

local DefaultContext = 
{
    name = "Default",
    key = "default",
    menuOrder = 1,
    priority = 0,
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

function DefaultContext:IsActive()
    return true
end

SituationalAudioManager:RegisterContext(DefaultContext)
return DefaultContext