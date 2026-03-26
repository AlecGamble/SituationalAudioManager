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
    SituationalAudioManager:RegisterEvent("CINEMATIC_START", function() self:OnCinematicStart() end)
    SituationalAudioManager:RegisterEvent("PLAY_MOVIE", function() self:OnMovieStart() end)
    SituationalAudioManager:RegisterEvent("CINEMATIC_STOP", function() self:OnCinematicEnd() end)
    SituationalAudioManager:RegisterEvent("STOP_MOVIE", function() self:OnCinematicEnd() end)
end

function CutsceneContext:OnCinematicStart()
    self.isInCutscene = true
    SituationalAudioManager:RefreshSettings("CINEMATIC_START")
end

function CutsceneContext:OnMovieStart()
    self.isInCutscene = true
    SituationalAudioManager:RefreshSettings("PLAY_MOVIE")
end

function CutsceneContext:OnCinematicEnd()
    self.isInCutscene = false
    SituationalAudioManager:RefreshSettings("CINEMATIC_STOP")
end

function CutsceneContext:OnMovieEnd()
    self.isInCutscene = false
    SituationalAudioManager:RefreshSettings("STOP_MOVIE")
end

function CutsceneContext:IsActive()
    return self.isInCutscene
end

SituationalAudioManager:RegisterContext(CutsceneContext)
return CutsceneContext