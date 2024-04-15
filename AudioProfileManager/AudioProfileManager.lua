local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:NewModule("AudioProfileManager", "AceEvent-3.0")

AudioProfileManager.KEY_CVar_MasterVolume = "Sound_MasterVolume"
AudioProfileManager.KEY_CVar_MusicVolume = "Sound_MusicVolume"
AudioProfileManager.KEY_CVar_SfxVolume = "Sound_SFXVolume"
AudioProfileManager.KEY_CVar_AmbienceVolume = "Sound_AmbienceVolume"
AudioProfileManager.KEY_CVar_DialogVolume = "Sound_DialogVolume"

AudioProfileManager.KEY_Event_CinematicStart = "CINEMATIC_START"
AudioProfileManager.KEY_Event_CinematicStop = "CINEMATIC_STOP"
AudioProfileManager.KEY_Event_MovieStart = "PLAY_MOVIE"
AudioProfileManager.KEY_Event_MovieStop = "STOP_MOVIE"
AudioProfileManager.KEY_Event_TalkingHeadStart = "TALKINGHEAD_REQUESTED"
AudioProfileManager.KEY_Event_TalkingHeadStop = "TALKINGHEAD_CLOSE"
AudioProfileManager.KEY_Event_PlayerEnteringWorld = "PLAYER_ENTERING_WORLD"

AudioProfileManager.Overrides = {}
AudioProfileManager.DefaultAudioProfile = {} -- initialized in Default.lua but keeping this for clarity

AudioProfileManager.ActiveVolumeController = nil

function AudioProfileManager:OnInitialize()
    self:UpdateAppliedOverrides()
    self:RegisterConfig()
end

function AudioProfileManager:OnEnable()
    -- TODO: find a more elegant approach where overrides / modules register for events and apply themselves
    -- probably make them submodules of this module
    AudioProfileManager:RegisterEvent("CINEMATIC_START", AudioProfileManager.UpdateActiveVolumeController)
    AudioProfileManager:RegisterEvent("CINEMATIC_STOP", AudioProfileManager.UpdateActiveVolumeController)
    AudioProfileManager:RegisterEvent("PLAY_MOVIE", AudioProfileManager.UpdateActiveVolumeController)
    AudioProfileManager:RegisterEvent("TALKINGHEAD_REQUESTED", AudioProfileManager.UpdateActiveVolumeController)
    AudioProfileManager:RegisterEvent("TALKINGHEAD_CLOSE", AudioProfileManager.UpdateActiveVolumeController)
    AudioProfileManager:RegisterEvent("PLAYER_ENTERING_WORLD", AudioProfileManager.UpdateActiveVolumeController)

    SAM.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
end

function AudioProfileManager:OnDisable()
    AudioProfileManager:UnregisterEvent("CINEMATIC_START")
    AudioProfileManager:UnregisterEvent("CINEMATIC_STOP")
    AudioProfileManager:UnregisterEvent("PLAY_MOVIE")
    AudioProfileManager:UnregisterEvent("TALKINGHEAD_REQUESTED")
    AudioProfileManager:UnregisterEvent("TALKINGHEAD_CLOSE")
    AudioProfileManager:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function AudioProfileManager:ValidateSettings()
    -- check for uninitialized settings and initialize them
    if SAM.db.profile.defaultVolumeSettings == nil or not SAM.db.profile.defaultVolumeSettings.initialized then
        AudioProfileManager.DefaultAudioProfile:InitializeDefaultValues()
    end

    for k, override in pairs(AudioProfileManager.Overrides) do
        if override.active and override.initialized == false then -- this should not be possible but just in case
            override:InitializeDefaultValues()
        end
    end

    -- ensure settings are valid
    AudioProfileManager.DefaultAudioProfile:ValidateSettings()

    for k, override in pairs(AudioProfileManager.Overrides) do
        override:ValidateSettings()
    end
end

function AudioProfileManager:RegisterOverride(override)
    AudioProfileManager.Overrides[override.name] = override
end

function AudioProfileManager:RefreshConfig()
    self.UpdateActiveVolumeController("ADDON_REQUEST")
end

function AudioProfileManager.UpdateActiveVolumeController(eventName)
    -- Fix for System Default Output Device not updating
    if SAM.db.profile.restartOnReload and eventName == "PLAYER_ENTERING_WORLD" then
        Sound_GameSystem_RestartSoundSystem()
    end

    -- Fix for cutscenes not playing
    if (eventName == "CINEMATIC_START" or eventName == "PLAY_MOVIE") and SAM.db.profile.fixCutsceneBug and GetCVar(AudioProfileManager.KEY_CVar_MasterVolume) == 0 then
        SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, 0.001)
    end
    
    -- TODO: Replace with a system where overrides subscribe to their own events and activate themselves
    -- apply profile
    for k, override in pairs(AudioProfileManager.Overrides) do
        if SAM.db.profile.overrides[override.name] and SAM.db.profile.overrides[override.name].active and override:ShouldBeActive(eventName) then
            AudioProfileManager.ActiveVolumeController = override
            AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
            return nil
        end
    end

    -- if no appropriate override was found then fall back to the default one
    if AudioProfileManager.DefaultAudioProfile then
        AudioProfileManager.ActiveVolumeController = AudioProfileManager.DefaultAudioProfile
        AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
        return nil
    end
end

function AudioProfileManager:ApplyAudioSettings()
    if AudioProfileManager.ActiveVolumeController == nil then
        return nil
    end

    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
end