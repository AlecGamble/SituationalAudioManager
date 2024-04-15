local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local DungeonVolumeController = AudioProfileManager:NewModule("DungeonVolumeController", "AceEvent-3.0")

DungeonVolumeController.name = "Dungeon"
DungeonVolumeController.priority = 10

DungeonVolumeController.configOptions = {
    name = "",
    type = 'group',
    inline = true,
    disabled = function() return SAM.db.profile.overrides[DungeonVolumeController.name] == nil or SAM.db.profile.overrides[DungeonVolumeController.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[DungeonVolumeController.name] == nil or SAM.db.profile.overrides[DungeonVolumeController.name].active == false end,
    args = {
        header = {
            name = "Dungeon Volume Settings",
            type = 'header',
            order = 10,
        },
        descriptionMessage = {
            name = "Volume settings to be used during Dungeon instances.",
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].masterVolume = v
                if AudioProfileManager.ActiveVolumeController == DungeonVolumeController then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].musicVolume = v
                if AudioProfileManager.ActiveVolumeController == DungeonVolumeController then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].sfxVolume = v
                if AudioProfileManager.ActiveVolumeController == DungeonVolumeController then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].ambienceVolume = v
                if AudioProfileManager.ActiveVolumeController == DungeonVolumeController then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].dialogVolume = v
                if AudioProfileManager.ActiveVolumeController == DungeonVolumeController then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
            end,
        }
    }
}

function DungeonVolumeController:InitializeDefaultValues()
    SAM.db.profile.overrides[DungeonVolumeController.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_SfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_DialogVolume)),
        initialized = true,
    }
end

function DungeonVolumeController:ValidateSettings()
    if not SAM.db.profile.overrides[DungeonVolumeController.name] then
        DungeonVolumeController:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[DungeonVolumeController.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[DungeonVolumeController.name].masterVolume))
    SAM.db.profile.overrides[DungeonVolumeController.name].musicVolume = max(0, min(1, SAM.db.profile.overrides[DungeonVolumeController.name].musicVolume))
    SAM.db.profile.overrides[DungeonVolumeController.name].sfxVolume = max(0, min(1, SAM.db.profile.overrides[DungeonVolumeController.name].sfxVolume))
    SAM.db.profile.overrides[DungeonVolumeController.name].ambienceVolume = max(0, min(1, SAM.db.profile.overrides[DungeonVolumeController.name].ambienceVolume))
    SAM.db.profile.overrides[DungeonVolumeController.name].dialogVolume = max(0, min(1, SAM.db.profile.overrides[DungeonVolumeController.name].dialogVolume))
end

function DungeonVolumeController:ApplyAudioSettings()
    SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, SAM.db.profile.overrides[DungeonVolumeController.name].masterVolume)
    SetCVar(AudioProfileManager.KEY_CVar_MusicVolume, SAM.db.profile.overrides[DungeonVolumeController.name].musicVolume)
    SetCVar(AudioProfileManager.KEY_CVar_SfxVolume, SAM.db.profile.overrides[DungeonVolumeController.name].sfxVolume)
    SetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume, SAM.db.profile.overrides[DungeonVolumeController.name].ambienceVolume)
    SetCVar(AudioProfileManager.KEY_CVar_DialogVolume, SAM.db.profile.overrides[DungeonVolumeController.name].dialogVolume)
end

function DungeonVolumeController:ShouldBeActive(eventName)
    local inInstance, instanceType = IsInInstance()

    if not inInstance then
        return false
    end

    if eventName == "PLAYER_ENTERING_WORLD" or eventName == "CINEMATIC_STOP" or eventName == "TALKINGHEAD_CLOSE" or eventName == "ADDON_UPDATE" then
        if instanceType == "party" then
            return true
        end
    end

    return false
end

function DungeonVolumeController:Subscribe()
    DungeonVolumeController:RegisterEvent("PLAYER_ENTERING_WORLD", DungeonVolumeController.Test)
end

function DungeonVolumeController:Unsubscribe()
    DungeonVolumeController:UnregisterEvent("PLAYER_ENTERING_WORLD", DungeonVolumeController.Test)
end

function DungeonVolumeController.Test(event)
end

AudioProfileManager:RegisterOverride(DungeonVolumeController)