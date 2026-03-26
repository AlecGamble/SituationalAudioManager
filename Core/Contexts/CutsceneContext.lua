local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local Logger = LibStub("LibSituationalLogger-1.0")

local CutsceneContext = 
{
    name = "Cutscene",
    key = "cutscene",
    menuOrder = 4,
    priority = 100,
    overrides = 
    {
        "MasterVolume",
    },
    isInCutscene = false
}

function CutsceneContext:OnEnable()
    SituationalAudioManager:RegisterEvent("CINEMATIC_START", function() self:OnCutsceneStart() end)
    SituationalAudioManager:RegisterEvent("PLAY_MOVIE", function() self:OnCutsceneStart() end)
    SituationalAudioManager:RegisterEvent("CINEMATIC_STOP", function() self:OnCutsceneEnd() end)
    SituationalAudioManager:RegisterEvent("STOP_MOVIE", function() self:OnCutsceneEnd() end)
end

function CutsceneContext:OnCutsceneStart()
    self.isInCutscene = true
    Logger:Log(Logger.LogLevels.verbose, "Update triggered from CINEMATIC_START or PLAY_MOVIE")
    SituationalAudioManager.SettingsEngine:Apply()
end

function CutsceneContext:OnCutsceneEnd()
    self.isInCutscene = false
    Logger:Log(Logger.LogLevels.verbose, "Update triggered from CINEMATIC_STOP or STOP_MOVIE")
    SituationalAudioManager.SettingsEngine:Apply()
end

function CutsceneContext:IsActive()
    return self.isInCutscene
end

SituationalAudioManager:RegisterContext(CutsceneContext)
return CutsceneContext