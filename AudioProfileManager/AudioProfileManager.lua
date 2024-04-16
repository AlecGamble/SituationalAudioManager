local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:NewModule("AudioProfileManager", "AceEvent-3.0")

-- CVar Keys
AudioProfileManager.KEY_CVar_MasterVolume = "Sound_MasterVolume"
AudioProfileManager.KEY_CVar_MusicVolume = "Sound_MusicVolume"
AudioProfileManager.KEY_CVar_SfxVolume = "Sound_SFXVolume"
AudioProfileManager.KEY_CVar_AmbienceVolume = "Sound_AmbienceVolume"
AudioProfileManager.KEY_CVar_DialogVolume = "Sound_DialogVolume"

-- Event Keys
AudioProfileManager.KEY_Event_CinematicStart = "CINEMATIC_START"
AudioProfileManager.KEY_Event_CinematicStop = "CINEMATIC_STOP"
AudioProfileManager.KEY_Event_MovieStart = "PLAY_MOVIE"
AudioProfileManager.KEY_Event_MovieStop = "STOP_MOVIE"
AudioProfileManager.KEY_Event_VoiceoverStart = "TALKINGHEAD_REQUESTED"
AudioProfileManager.KEY_Event_VoiceoverStop = "TALKINGHEAD_CLOSE"
AudioProfileManager.KEY_Event_PlayerEnteringWorld = "PLAYER_ENTERING_WORLD"
AudioProfileManager.KEY_Event_AddonRequest = "ADDON_REQUEST"

AudioProfileManager.Overrides = {}
AudioProfileManager.DefaultAudioProfile = {} -- initialized in Default.lua but keeping this for clarity
AudioProfileManager.Flags = {
    InCutscene = false,
    InVoiceover = false
}

function AudioProfileManager:OnInitialize()
    self:UpdateAppliedOverrides()
    self:RegisterConfig()
end

function AudioProfileManager:OnEnable()
    SAM.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")

    self.DefaultAudioProfile:Subscribe()

    for k, override in pairs(self.Overrides) do
        if SAM.db.profile.overrides[override.name] and SAM.db.profile.overrides[override.name].active then
            override:Subscribe()
        end
    end

    self:RegisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld, AudioProfileManager.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStart, AudioProfileManager.OnCutsceneStart)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStart, AudioProfileManager.OnCutsceneStart)
end

function AudioProfileManager:OnDisable()
    self:UnregisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStart)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStart)
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

    local inInstance, instanceType = IsInInstance()

    if not inInstance then
        self.DefaultAudioProfile:ApplyAudioSettings()
    elseif instanceType == "none" or instanceType == nil then -- unknown instances i.e. scenarios
        self.DefaultAudioProfile:ApplyAudioSettings()
    else
        local overrideInstanceFound = false
        for k, override in pairs(self.Overrides) do
            if override.instanceName == instanceType and SAM.db.profile.overrides[override.name] and SAM.db.profile.overrides[override.name].active then
                override:ApplyAudioSettings()
                overrideInstanceFound = true
            end

            if not overrideInstanceFound then
                self.DefaultAudioProfile:ApplyAudioSettings()
            end
        end
    end
end

function AudioProfileManager.OnEnterWorld()
    -- Fix for System Default Output Device not updating
    if SAM.db.profile.restartOnReload then
        Sound_GameSystem_RestartSoundSystem()
    end
end

function AudioProfileManager.OnCutsceneStart()
    -- Fix for cutscenes not playing
    if SAM.db.profile.fixCutsceneBug and GetCVar(AudioProfileManager.KEY_CVar_MasterVolume) == 0 then
        SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, 0.001)
    end
end