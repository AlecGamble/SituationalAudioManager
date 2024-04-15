local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local CutsceneVolumeController = AudioProfileManager:NewModule("CutsceneVolumeController", "AceEvent-3.0")

CutsceneVolumeController.name = "Cutscene"

CutsceneVolumeController.configOptions = {
    name = "",
    type = 'group',
    inline = true,
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
            end,
        },
        testButton = {
            name = "Test",
            type = 'execute',
            order = 4,
            func = function()
                AudioProfileManager.UpdateActiveVolumeController("CINEMATIC_START")
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
    if SAM.db.profile.overrides[self.name].masterVolume == 0 and SAM.db.profile.fixCutsceneBug and GetCVar(AudioProfileManager.KEY_CVar_MasterVolume) == 0 then
        SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, 0.001)
    else
        SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, SAM.db.profile.overrides[self.name].masterVolume)
    end
end

function CutsceneVolumeController:ShouldBeActive(eventName)
    if eventName == AudioProfileManager.KEY_Event_CinematicStart or eventName == AudioProfileManager.KEY_Event_MovieStart then
        return true
    end

    return false
end

function CutsceneVolumeController:Subscribe()
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStart, self.UpdateEvent)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStart, self.UpdateEvent)
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStop, self.UpdateEvent)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStop, self.UpdateEvent)
end

function CutsceneVolumeController:Unsubscribe()
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStart, self.UpdateEvent)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStart, self.UpdateEvent)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStop, self.UpdateEvent)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStop, self.UpdateEvent)
end

function CutsceneVolumeController.UpdateEvent(event)
    if eventName == AudioProfileManager.KEY_Event_CinematicStart or eventName == AudioProfileManager.KEY_Event_MovieStart then
        AudioProfileManager.ActiveVolumeController = CutsceneVolumeController
    elseif eventName == AudioProfileManager.KEY_Event_CinematicStop or eventName == AudioProfileManager.KEY_Event_MovieStop then
        AudioProfileManager.UpdateActiveVolumeController(AudioProfileManager.KEY_Event_CinematicStop)
    end
end

AudioProfileManager:RegisterOverride(CutsceneVolumeController)