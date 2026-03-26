local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local CutseneBugFixModule = SituationalAudioManager:NewModule("CutsceneBugFix", "AceEvent-3.0")
local Logger = LibStub("LibSituationalLogger-1.0")

function CutseneBugFixModule:OnEnable()
    self:RegisterEvent("CINEMATIC_START", "OnCutsceneStart")
    self:RegisterEvent("PLAY_MOVIE", "OnCutsceneStart")
    self:RegisterEvent("CINEMATIC_STOP", "OnCutsceneEnd")
    self:RegisterEvent("STOP_MOVIE", "OnCutsceneEnd")
end

function CutseneBugFixModule:OnDisable()
    self:UnregisterEvent("CINEMATIC_START")
    self:UnregisterEvent("PLAY_MOVIE")
    self:UnregisterEvent("CINEMATIC_STOP")
    self:UnregisterEvent("STOP_MOVIE")
end

function CutseneBugFixModule:OnCutsceneStart()
    if SituationalAudioManager.db.profile.fixCutsceneBug then
        local volume = tonumber(GetCVar("Sound_MasterVolume"))
        if volume <= 0 then
            SetCVar("Sound_MasterVolume", 0.001)
        end
    end
end

function CutseneBugFixModule:OnCutsceneEnd()
    SituationalAudioManager:RefreshSettings("CUTSCENE_BUG_FIX_END")
end