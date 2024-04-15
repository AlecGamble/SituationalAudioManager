local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")

local override = {}

override.name = "Arena"

override.configOptions = {
    name = "",
    type = 'group',
    inline = true,
    disabled = function() return SAM.db.profile.overrides[override.name] == nil or SAM.db.profile.overrides[override.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[override.name] == nil or SAM.db.profile.overrides[override.name].active == false end,
    args = {
        header = {
            name = "Arena Volume Settings",
            type = 'header',
            order = 10,
        },
        descriptionMessage = {
            name = "Volume settings to be used during Arena matches.",
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
                return SAM.db.profile.overrides[override.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].masterVolume = v
                -- AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
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
                return SAM.db.profile.overrides[override.name].musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].musicVolume = v
                -- AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
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
                return SAM.db.profile.overrides[override.name].sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].sfxVolume = v
                -- AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
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
                return SAM.db.profile.overrides[override.name].ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].ambienceVolume = v
                -- AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
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
                return SAM.db.profile.overrides[override.name].dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].dialogVolume = v
                --AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
            end,
        }
    }
}

function override:InitializeDefaultValues()
    SAM.db.profile.overrides[override.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarMasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarMusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarSfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarAmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarDialogVolume)),
        initialized = true,
    }
end

function override:ValidateSettings()
    if not SAM.db.profile.overrides[override.name] then
        override:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[override.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[override.name].masterVolume))
    SAM.db.profile.overrides[override.name].musicVolume = max(0, min(1, SAM.db.profile.overrides[override.name].musicVolume))
    SAM.db.profile.overrides[override.name].sfxVolume = max(0, min(1, SAM.db.profile.overrides[override.name].sfxVolume))
    SAM.db.profile.overrides[override.name].ambienceVolume = max(0, min(1, SAM.db.profile.overrides[override.name].ambienceVolume))
    SAM.db.profile.overrides[override.name].dialogVolume = max(0, min(1, SAM.db.profile.overrides[override.name].dialogVolume))
end

function override:ApplyAudioSettings()
    SetCVar(AudioProfileManager.KEY_CVarMasterVolume, SAM.db.profile.overrides[override.name].masterVolume)
    SetCVar(AudioProfileManager.KEY_CVarMusicVolume, SAM.db.profile.overrides[override.name].musicVolume)
    SetCVar(AudioProfileManager.KEY_CVarSfxVolume, SAM.db.profile.overrides[override.name].sfxVolume)
    SetCVar(AudioProfileManager.KEY_CVarAmbienceVolume, SAM.db.profile.overrides[override.name].ambienceVolume)
    SetCVar(AudioProfileManager.KEY_CVarDialogVolume, SAM.db.profile.overrides[override.name].dialogVolume)
end

-- TODO: 
function override:ShouldBeActive(eventName)
    local inInstance, instanceType = IsInInstance()

    if not inInstance then
        return false
    end

    if  (eventName == "PLAYER_ENTERING_WORLD") or 
        (eventName == "CINEMATIC_STOP" and SAM.db.profile.overrides.cutscene == true) or 
        (eventName == "TALKINGHEAD_CLOSE" and SAM.db.profile.overrides.voiceover == true) or 
        (eventName == "ADDON_UPDATE")
    then
        if instanceType == "arena" then
            return true
        end
    end
end

AudioProfileManager:RegisterOverride(override)