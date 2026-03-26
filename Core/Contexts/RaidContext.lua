local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)

local RaidContext = 
{
    name = "Raid",
    key = "raid",
    menuOrder = 6,
    priority = 12,
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

function RaidContext:IsActive()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "raid"
end

SituationalAudioManager:RegisterContext(RaidContext)
return RaidContext