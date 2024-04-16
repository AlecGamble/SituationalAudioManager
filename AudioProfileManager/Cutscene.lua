local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local CutsceneVolumeController = AudioProfileManager:NewModule("CutsceneVolumeController", "AceEvent-3.0")

CutsceneVolumeController.name = "Cutscene"

CutsceneVolumeController.configOptions = {
    name = "Cutscene",
    type = 'group',
    disabled = function() return SAM.db.profile.overrides[CutsceneVolumeController.name] == nil or SAM.db.profile.overrides[CutsceneVolumeController.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[CutsceneVolumeController.name] == nil or SAM.db.profile.overrides[CutsceneVolumeController.name].active == false end,
    args = {
        header = {
            name = "Cutscene Volume Settings",
            type = 'header',
            order = 1,
        },
        descriptionMessage = {
            name = "The volume at which to play cutscenes. Only the master volume channel is used to determine cutscene volume.",
            type = 'description',
            order = 2,
        },
        masterVolume = {
            name = "Volume",
            type = 'range',
            order = 3,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[CutsceneVolumeController.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[CutsceneVolumeController.name].masterVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        },
        testButton = {
            name = "Test",
            type = 'execute',
            order = 4,
            func = function()
                -- seems to need to be triggered manually when calling MovieFrame_PlayMovie
                AudioProfileManager.OnCutsceneStart()
                MovieFrame_PlayMovie(MovieFrame, 960)
            end
        }
    }
}

function CutsceneVolumeController:InitializeDefaultValues()
    SAM.db.profile.overrides[self.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)),
        initialized = true,
    }
end

function CutsceneVolumeController:ValidateSettings()
    if not SAM.db.profile.overrides[self.name] then
        self:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[self.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[self.name].masterVolume))
end

function CutsceneVolumeController:ApplyAudioSettings()
    local targetVolume = SAM.db.profile.overrides[self.name].masterVolume
    SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, (targetVolume <= 0 and SAM.db.profile.fixCutsceneBug) and 0.001 or targetVolume)
end

function CutsceneVolumeController:Subscribe()
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStart, CutsceneVolumeController.OnCutsceneStart)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStart, CutsceneVolumeController.OnCutsceneStart)
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStop, CutsceneVolumeController.OnCutsceneStop)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStop, CutsceneVolumeController.OnCutsceneStop)
end

function CutsceneVolumeController:Unsubscribe()
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStart)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStart)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStop)
end

function CutsceneVolumeController.OnCutsceneStart()
    AudioProfileManager.Flags.InCutscene = true
    CutsceneVolumeController:ApplyAudioSettings()
end

function CutsceneVolumeController.OnCutsceneStop()
    AudioProfileManager.Flags.InCutscene = false
end

AudioProfileManager:RegisterOverride(CutsceneVolumeController)