local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local CutseneBugFixModule = SituationalAudioManager:NewModule("CutsceneBugFix", "AceEvent-3.0")

function CutseneBugFixModule:OnEnable()
    SituationalAudioManager:RegisterEvent("CINEMATIC_START", function() self:OnCutsceneStart() end)
    SituationalAudioManager:RegisterEvent("PLAY_MOVIE", function() self:OnCutsceneStart() end)
    SituationalAudioManager:RegisterEvent("CINEMATIC_STOP", function() self:OnCutsceneEnd() end)
    SituationalAudioManager:RegisterEvent("STOP_MOVIE", function() self:OnCutsceneEnd() end)
end

function CutseneBugFixModule:OnDisable()
    SituationalAudioManager:UnregisterEvent("CINEMATIC_START", function() self:OnCutsceneStart() end)
    SituationalAudioManager:UnregisterEvent("PLAY_MOVIE", function() self:OnCutsceneStart() end)
    SituationalAudioManager:UnregisterEvent("CINEMATIC_STOP", function() self:OnCutsceneEnd() end)
    SituationalAudioManager:UnregisterEvent("STOP_MOVIE", function() self:OnCutsceneEnd() end)
end

function CutseneBugFixModule:OnCutsceneStart()
    if SituationalAudioManager.db.profile.fixCutsceneBug and tonumber(GetCVar("Sound_MasterVolume")) <= 0 then
        SetCVar("Sound_MasterVolume", 0.001)
    end
end

function CutseneBugFixModule:OnCutsceneEnd()
    SituationalAudioManager.SettingsEngine:Apply()
end