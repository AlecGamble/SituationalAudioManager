local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local Logger = LibStub("LibSituationalLogger-1.0")

local VoiceoverContext = 
{
    name = "Talking Heads",
    key = "talking_heads",
    menuOrder = 7,
    priority = 13,
    overrides = 
    {
        "MasterVolume",
        "MusicVolume",
        "SFXVolume",
        "AmbienceVolume",
        "DialogVolume",
        "GameplaySFXVolume"
    },
    isTalkingHeadActive = false
}

function VoiceoverContext:OnEnable()
    SituationalAudioManager:RegisterEvent("TALKINGHEAD_REQUESTED", function() self:OnTalkingHeadStart() end)
    SituationalAudioManager:RegisterEvent("TALKINGHEAD_CLOSE", function() self:OnTalkingHeadEnd() end)
end

function VoiceoverContext:OnTalkingHeadStart()
    self.isTalkingHeadActive = true
    Logger:Log(Logger.LogLevels.verbose, "Update triggered from TALKINGHEAD_REQUESTED")
    SituationalAudioManager.SettingsEngine:Apply()
end

function VoiceoverContext:OnTalkingHeadEnd()
    self.isTalkingHeadActive = false
    Logger:Log(Logger.LogLevels.verbose, "Update triggered from TALKINGHEAD_CLOSE")
    SituationalAudioManager.SettingsEngine:Apply()
end

function VoiceoverContext:IsActive()
    return self.isTalkingHeadActive
end

SituationalAudioManager:RegisterContext(VoiceoverContext)
return VoiceoverContext