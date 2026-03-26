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
    SituationalAudioManager:RefreshSettings("TALKINGHEAD_REQUESTED")
end

function VoiceoverContext:OnTalkingHeadEnd()
    self.isTalkingHeadActive = false
    SituationalAudioManager:RefreshSettings("TALKINGHEAD_CLOSE")
end

function VoiceoverContext:IsActive()
    return self.isTalkingHeadActive
end

SituationalAudioManager:RegisterContext(VoiceoverContext)
return VoiceoverContext