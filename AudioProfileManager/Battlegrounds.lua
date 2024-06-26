local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local BattlegroundsVolumeController = AudioProfileManager:NewModule("BattlegroundsVolumeController", "AceEvent-3.0")

BattlegroundsVolumeController.name = "Battlegrounds"
BattlegroundsVolumeController.instanceName = "pvp"

BattlegroundsVolumeController.configOptions = {
    name = "Battlegrounds",
    type = 'group',
    disabled = function() return SAM.db.profile.overrides[BattlegroundsVolumeController.name] == nil or SAM.db.profile.overrides[BattlegroundsVolumeController.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[BattlegroundsVolumeController.name] == nil or SAM.db.profile.overrides[BattlegroundsVolumeController.name].active == false end,
    args = {
        header = {
            name = "Battlegrounds Volume Settings",
            type = 'header',
            order = 10,
        },
        descriptionMessage = {
            name = "Volume settings to be used during Battlegrounds matches.",
            type = 'description',
            order = 11,
        },
        masterVolume = {
            name = "Master Volume",
            type = 'range',
            order = 12,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[BattlegroundsVolumeController.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[BattlegroundsVolumeController.name].masterVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        },
        musicVolume = {
            name = "Music Volume",
            type = 'range',
            order = 13,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[BattlegroundsVolumeController.name].musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[BattlegroundsVolumeController.name].musicVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        },
        sfxVolume = {
            name = "SFX Volume",
            type = 'range',
            order = 14,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[BattlegroundsVolumeController.name].sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[BattlegroundsVolumeController.name].sfxVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        },
        ambienceVolume = {
            name = "Ambience Volume",
            type = 'range',
            order = 15,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[BattlegroundsVolumeController.name].ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[BattlegroundsVolumeController.name].ambienceVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        },
        dialogVolume = {
            name = "Dialog Volume",
            type = 'range',
            order = 16,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[BattlegroundsVolumeController.name].dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[BattlegroundsVolumeController.name].dialogVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        }
    }
}

function BattlegroundsVolumeController:InitializeDefaultValues()
    SAM.db.profile.overrides[self.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_SfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_DialogVolume)),
        initialized = true,
    }
end

function BattlegroundsVolumeController:ValidateSettings()
    if not SAM.db.profile.overrides[self.name] then
        self:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[self.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[self.name].masterVolume))
    SAM.db.profile.overrides[self.name].musicVolume = max(0, min(1, SAM.db.profile.overrides[self.name].musicVolume))
    SAM.db.profile.overrides[self.name].sfxVolume = max(0, min(1, SAM.db.profile.overrides[self.name].sfxVolume))
    SAM.db.profile.overrides[self.name].ambienceVolume = max(0, min(1, SAM.db.profile.overrides[self.name].ambienceVolume))
    SAM.db.profile.overrides[self.name].dialogVolume = max(0, min(1, SAM.db.profile.overrides[self.name].dialogVolume))
end

function BattlegroundsVolumeController:ApplyAudioSettings(instant)
    SAM:Log("Applying: "..self.name, SAM.LogLevels.Verbose)

    AudioProfileManager.ActiveProfile = self.name

    if SAM.db.profile.blendBetweenAudioProfiles and not instant then
        AudioProfileManager:BlendToNewAudioProfile(
            SAM.db.profile.overrides[self.name].masterVolume,
            SAM.db.profile.overrides[self.name].musicVolume,
            SAM.db.profile.overrides[self.name].sfxVolume,
            SAM.db.profile.overrides[self.name].ambienceVolume,
            SAM.db.profile.overrides[self.name].dialogVolume
        )
    else
        AudioProfileManager:SetAudioProfile(
            SAM.db.profile.overrides[self.name].masterVolume,
            SAM.db.profile.overrides[self.name].musicVolume,
            SAM.db.profile.overrides[self.name].sfxVolume,
            SAM.db.profile.overrides[self.name].ambienceVolume,
            SAM.db.profile.overrides[self.name].dialogVolume
        )
    end
end

function BattlegroundsVolumeController:Subscribe()
    SAM:Log("Subscribed to: "..self.name, SAM.LogLevels.Verbose)
    self:RegisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld, BattlegroundsVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop, BattlegroundsVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStop, BattlegroundsVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStop, BattlegroundsVolumeController.OnEnterWorld)
    self:RegisterMessage(AudioProfileManager.KEY_Event_AddonRequest, BattlegroundsVolumeController.OnEnterWorld)
end

function BattlegroundsVolumeController:Unsubscribe()
    SAM:Log("Unsubscribed from: "..self.name, SAM.LogLevels.Verbose)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStop)
    self:UnregisterMessage(AudioProfileManager.KEY_Event_AddonRequest)
end

function BattlegroundsVolumeController.OnEnterWorld()
    if AudioProfileManager.ActiveProfile == BattlegroundsVolumeController.name then return end

    -- being in a battleground should not override cutscenes or talking heads
    if AudioProfileManager.Flags.InCutscene or AudioProfileManager.Flags.InVoiceover then return end

    local inInstance, instanceType = IsInInstance()

    if not inInstance then return end

    if instanceType == "pvp" then
        DungeonVolumeController:ApplyAudioSettings()
    end
end

AudioProfileManager:RegisterOverride(BattlegroundsVolumeController)