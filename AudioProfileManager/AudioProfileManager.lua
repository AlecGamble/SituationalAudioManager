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
AudioProfileManager.KEY_Event_AddonRequest = "SAM_UPDATE_ADDON_REQUEST"

AudioProfileManager.Overrides = {}
AudioProfileManager.DefaultAudioProfile = {} -- initialized in Default.lua but keeping this for clarity
AudioProfileManager.Flags = {
    InCutscene = false,
    InVoiceover = false,
    IsBlending = false
}

AudioProfileManager.ActiveProfile = ""

AudioProfileManager.VolumeSettings = {
    masterVolume = 0,
    musicVolume = 0,
    sfxVolume = 0,
    ambienceVolume = 0,
    dialogVolume = 0
}

AudioProfileManager.TargetVolumeSettings = {
    masterVolume = 0,
    musicVolume = 0,
    sfxVolume = 0,
    ambienceVolume = 0,
    dialogVolume = 0
}

AudioProfileManager.BlendingFrame = CreateFrame("Frame")
AudioProfileManager.AnimationGroup = AudioProfileManager.BlendingFrame:CreateAnimationGroup()
AudioProfileManager.BlendAnimation = AudioProfileManager.AnimationGroup:CreateAnimation("Animation")

function AudioProfileManager:OnInitialize()
    self:UpdateAppliedOverrides()
    self:RegisterConfig()

    self.BlendAnimation:SetScript("OnUpdate", AudioProfileManager.OnBlendTick)
    self.BlendAnimation:SetScript("OnFinished", AudioProfileManager.OnBlendComplete)
    self.BlendAnimation:SetDuration(2)
    self.BlendAnimation:SetSmoothing("NONE")
end

function AudioProfileManager:OnEnable()
    SAM:Log("AudioProfileManager:OnEnable", SAM.LogLevels.Verbose)
    SAM.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")

    self:ValidateSettings()

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
    -- ensure settings are valid
    self.DefaultAudioProfile:ValidateSettings()

    for k, override in pairs(self.Overrides) do 
        if SAM.db.profile.overrides[override.name] and SAM.db.profile.overrides[override.name].active then
            override:ValidateSettings()
        end
    end
end

function AudioProfileManager:RegisterOverride(override)
    AudioProfileManager.Overrides[override.name] = override
end

function AudioProfileManager:RefreshConfig()
    self:ValidateSettings()
    self:UpdateAppliedOverrides()

    for k, override in pairs(self.Overrides) do
        override:Unsubscribe()

        for k, override in pairs(self.Overrides) do
            if SAM.db.profile.overrides[override.name] and SAM.db.profile.overrides[override.name].active then
                override:Subscribe()
            end
        end
    end

    local inInstance, instanceType = IsInInstance()

    if not inInstance then
        self.DefaultAudioProfile:ApplyAudioSettings()
    elseif instanceType == "none" or instanceType == nil then -- unknown instances i.e. scenarios
        self.DefaultAudioProfile:ApplyAudioSettings(true)
    else
        local overrideInstanceFound = false
        for k, override in pairs(self.Overrides) do
            if override.instanceName == instanceType and SAM.db.profile.overrides[override.name] and SAM.db.profile.overrides[override.name].active then
                override:ApplyAudioSettings(true)
                overrideInstanceFound = true
            end

            if not overrideInstanceFound then
                self.DefaultAudioProfile:ApplyAudioSettings(true)
            end
        end
    end
end

function AudioProfileManager.OnEnterWorld()
    -- Fix for System Default Output Device not updating
    if SAM.db.profile.restartOnReload then
        -- SAM:Log("Restarting Sound System", SAM.LogLevels.Always)
        -- Sound_GameSystem_RestartSoundSystem()
    end
end

function AudioProfileManager.OnCutsceneStart()
    -- Fix for cutscenes not playing
    if SAM.db.profile.fixCutsceneBug and tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)) <= 0 then
        SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, 0.001)
    end
end

function AudioProfileManager:ApplyAudioSettings(masterVolume, musicVolume, sfxVolume, ambienceVolume, dialogVolume)
    SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, masterVolume)
    SetCVar(AudioProfileManager.KEY_CVar_MusicVolume, musicVolume)
    SetCVar(AudioProfileManager.KEY_CVar_SfxVolume, sfxVolume)
    SetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume, ambienceVolume)
    SetCVar(AudioProfileManager.KEY_CVar_DialogVolume, dialogVolume)
end

function AudioProfileManager:BlendToNewAudioProfile(masterVolume, musicVolume, sfxVolume, ambienceVolume, dialogVolume)
    self.TargetVolumeSettings.masterVolume = masterVolume
    self.TargetVolumeSettings.musicVolume = musicVolume
    self.TargetVolumeSettings.sfxVolume = sfxVolume
    self.TargetVolumeSettings.ambienceVolume = ambienceVolume
    self.TargetVolumeSettings.dialogVolume = dialogVolume

    if self.AnimationGroup:IsPlaying() then
        self.AnimationGroup:Stop()
    end

    self.AnimationGroup:Play()
end

function AudioProfileManager:SetAudioProfile(masterVolume, musicVolume, sfxVolume, ambienceVolume, dialogVolume)
    self.TargetVolumeSettings.masterVolume, self.VolumeSettings.masterVolume = masterVolume, masterVolume
    self.TargetVolumeSettings.musicVolume, self.VolumeSettings.musicVolume = musicVolume, musicVolume
    self.TargetVolumeSettings.sfxVolume, self.VolumeSettings.sfxVolume = sfxVolume, sfxVolume
    self.TargetVolumeSettings.ambienceVolume, self.VolumeSettings.ambienceVolume = ambienceVolume, ambienceVolume
    self.TargetVolumeSettings.dialogVolume, self.VolumeSettings.dialogVolume = dialogVolume, dialogVolume

    AudioProfileManager:ApplyAudioSettings(masterVolume, musicVolume, sfxVolume, ambienceVolume, dialogVolume)
end

function AudioProfileManager.OnBlendComplete()
    AudioProfileManager.VolumeSettings.masterVolume = AudioProfileManager.TargetVolumeSettings.masterVolume
    AudioProfileManager.VolumeSettings.musicVolume = AudioProfileManager.TargetVolumeSettings.musicVolume
    AudioProfileManager.VolumeSettings.sfxVolume = AudioProfileManager.TargetVolumeSettings.sfxVolume
    AudioProfileManager.VolumeSettings.ambienceVolume = AudioProfileManager.TargetVolumeSettings.ambienceVolume
    AudioProfileManager.VolumeSettings.dialogVolume = AudioProfileManager.TargetVolumeSettings.dialogVolume

    AudioProfileManager:ApplyAudioSettings(AudioProfileManager.VolumeSettings.masterVolume, AudioProfileManager.VolumeSettings.musicVolume, AudioProfileManager.VolumeSettings.sfxVolume, AudioProfileManager.VolumeSettings.ambienceVolume, AudioProfileManager.VolumeSettings.dialogVolume)
end

function AudioProfileManager.OnBlendTick(self)
    local function clamp(x,l,u)
        return min(max(x,l),u)
    end

    local function clamp01(x)
        return clamp(x,0,1)
    end

    local function lerp(a,b,t)
        t=clamp01(t)
        return (1-t)*a+t*b
    end

    local masterVolume = lerp(AudioProfileManager.VolumeSettings.masterVolume, AudioProfileManager.TargetVolumeSettings.masterVolume, self:GetSmoothProgress())
    local musicVolume = lerp(AudioProfileManager.VolumeSettings.musicVolume, AudioProfileManager.TargetVolumeSettings.musicVolume, self:GetSmoothProgress())
    local sfxVolume = lerp(AudioProfileManager.VolumeSettings.sfxVolume, AudioProfileManager.TargetVolumeSettings.sfxVolume, self:GetSmoothProgress())
    local ambienceVolume = lerp(AudioProfileManager.VolumeSettings.ambienceVolume, AudioProfileManager.TargetVolumeSettings.ambienceVolume, self:GetSmoothProgress())
    local dialogVolume = lerp(AudioProfileManager.VolumeSettings.dialogVolume, AudioProfileManager.TargetVolumeSettings.dialogVolume, self:GetSmoothProgress())

    AudioProfileManager:ApplyAudioSettings(masterVolume, musicVolume, sfxVolume, ambienceVolume, dialogVolume)
end



