local addonName, addonTable = ...

SAM = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceComm-3.0", "AceTimer-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local KEY_CVarMasterVolume = "Sound_MasterVolume"
local KEY_CVarMusicVolume = "Sound_MusicVolume"
local KEY_CVarSfxVolume = "Sound_SFXVolume"
local KEY_CVarAmbienceVolume = "Sound_AmbienceVolume"
local KEY_CVarDialogVolume = "Sound_DialogVolume"

local appliedOverrides = {}
local unappliedOverrides = {}

local states = 
{
    default = 
    {
        overrideable = false,
        settings = {
            masterVolume = -1,
            musicVolume = -1,
            sfxVolume = -1,
            ambienceVolume = -1,
            dialogVolume = -1,
            initialized = false
        },
        configOptions = {
            name = "Default",
            type = 'group',
            order = 2,
            args = {
                defaultHeader = {
                    name = "Default",
                    type = 'header',
                    order = 1
                },
                descriptionMessage = {
                    name = "The default audio settings to be applied when the conditions for a more specific override are not being met.",
                    type = 'description',
                    order = 2,
                },
                volumeHeader = {
                    name = "Volume Settings",
                    type = 'header',
                    order = 4
                },
                masterVolume = {
                    name = "Master Volume",
                    type = 'range',
                    order = 5,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.default.masterVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.default.masterVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                musicVolume = {
                    name = "Music Volume",
                    type = 'range',
                    order = 6,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.default.musicVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.default.musicVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                sfxVolume = {
                    name = "SFX Volume",
                    type = 'range',
                    order = 7,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.default.sfxVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.default.sfxVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                ambienceVolume = {
                    name = "Ambience Volume",
                    type = 'range',
                    order = 8,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.default.ambienceVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.default.ambienceVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                dialogVolume = {
                    name = "Dialog Volume",
                    type = 'range',
                    order = 9,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.default.dialogVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.default.dialogVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                fixCutsceneBugHeader = {
                    name = "Cutscene Bug",
                    type = 'header',
                    order = 10,
                    disabled = function() return SAM.db.profile.overrides.cutscene == true or SAM.db.profile.states.default.masterVolume ~= 0 end,
                    hidden = function() return SAM.db.profile.overrides.cutscene == true or SAM.db.profile.states.default.masterVolume ~= 0 end,
                },
                fixCutsceneBugMessage = {
                    name = "\n|cffe74c3cWarning:|r selecting 0% master volume without a cutscene override will cause a bug which prevents cutscenes from playing and you will see a black screen. The setting below will fix this by setting the volume to an inaudibly low amount but still allowing the cutscene to play.",
                    type = 'description',
                    order = 11,
                    disabled = function() return SAM.db.profile.overrides.cutscene == true or SAM.db.profile.states.default.masterVolume ~= 0 end,
                    hidden = function() return SAM.db.profile.overrides.cutscene == true or SAM.db.profile.states.default.masterVolume ~= 0 end,
                },
                fixCutsceneBugToggle = {
                    name = "Fix Cutscene Bug",
                    type = 'toggle',
                    order = 12,
                    disabled = function() return SAM.db.profile.overrides.cutscene == true or SAM.db.profile.states.default.masterVolume ~= 0 end,
                    hidden = function() return SAM.db.profile.overrides.cutscene == true or SAM.db.profile.states.default.masterVolume ~= 0 end,
                    get = function(info)
                        return SAM.db.profile.fixCutsceneBug
                    end,
                    set = function(info, v)
                        SAM.db.profile.fixCutsceneBug = v
                    end
                },
            }
        },
        InitializeDefaultValues = function()
            SAM.db.profile.states.default.masterVolume = GetCVar(KEY_CVarMasterVolume)
            SAM.db.profile.states.default.musicVolume = GetCVar(KEY_CVarMusicVolume)
            SAM.db.profile.states.default.sfxVolume = GetCVar(KEY_CVarSfxVolume)
            SAM.db.profile.states.default.ambienceVolume = GetCVar(KEY_CVarAmbienceVolume)
            SAM.db.profile.states.default.dialogVolume = GetCVar(KEY_CVarDialogVolume)
            SAM.db.profile.states.default.initialized = true
        end,
        ValidateSettings = function()
            SAM.db.profile.states.default.masterVolume = max(0, min(1, SAM.db.profile.states.default.masterVolume))
            SAM.db.profile.states.default.musicVolume = max(0, min(1, SAM.db.profile.states.default.musicVolume))
            SAM.db.profile.states.default.sfxVolume = max(0, min(1, SAM.db.profile.states.default.sfxVolume))
            SAM.db.profile.states.default.ambienceVolume = max(0, min(1, SAM.db.profile.states.default.ambienceVolume))
            SAM.db.profile.states.default.dialogVolume = max(0, min(1, SAM.db.profile.states.default.dialogVolume))
        end,
        ApplyAudioSettings = function()
            addonTable.activeState:ValidateSettings()

            SetCVar(KEY_CVarMasterVolume, SAM.db.profile.states.default.masterVolume)
            SetCVar(KEY_CVarMusicVolume, SAM.db.profile.states.default.musicVolume)
            SetCVar(KEY_CVarSfxVolume, SAM.db.profile.states.default.sfxVolume)
            SetCVar(KEY_CVarAmbienceVolume, SAM.db.profile.states.default.ambienceVolume)
            SetCVar(KEY_CVarDialogVolume, SAM.db.profile.states.default.dialogVolume)
        end
    }, 
    cutscene = {
        overrideable = true,
        settings = {
            masterVolume = -1,
            initialized = false
        },
        configOptions = {
            name = "Cutscene",
            type = 'group',
            order = 3,
            disabled = function() return SAM.db.profile.overrides.cutscene == nil or SAM.db.profile.overrides.cutscene == false end,
            hidden = function() return SAM.db.profile.overrides.cutscene == nil or SAM.db.profile.overrides.cutscene == false end,
            args = {
                cutsceneHeader = {
                    name = "Cutscene",
                    type = 'header',
                    order = 1
                },
                descriptionMessage = {
                    name = "The volume at which to play cutscenes, only master volume is used to determine cutscene volume.",
                    type = 'description',
                    order = 2,
                },
                volumeHeader = {
                    name = "Volume Settings",
                    type = 'header',
                    order = 3
                },
                masterVolume = {
                    name = "Volume",
                    type = 'range',
                    order = 4,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.cutscene.masterVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.cutscene.masterVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                testButton = {
                    name = "Test",
                    type = 'execute',
                    order = 5,
                    func = function()
                        UpdateActiveState("CINEMATIC_START")
                        MovieFrame_PlayMovie(MovieFrame, 960)
                    end
                },
                fixCutsceneBugHeader = {
                    name = "Cutscene Bug",
                    type = 'header',
                    order = 6,
                    disabled = function() return SAM.db.profile.states.cutscene.masterVolume ~= 0 end,
                    hidden = function() return SAM.db.profile.states.cutscene.masterVolume ~= 0 end,
                },
                fixCutsceneBugMessage = {
                    name = "\n|cffe74c3cWarning:|r having 0% master volume will cause a bug which prevents cutscenes from playing and you will see a black screen. The setting below will fix this by setting the master volume to an inaudibly low amount but still allowing the cutscene to play.",
                    type = 'description',
                    order = 7,
                    disabled = function() return SAM.db.profile.states.cutscene.masterVolume ~= 0 end,
                    hidden = function() return SAM.db.profile.states.cutscene.masterVolume ~= 0 end,
                },
                fixCutsceneBugToggle = {
                    name = "Fix Cutscene Bug",
                    type = 'toggle',
                    order = 8,
                    disabled = function() return SAM.db.profile.states.cutscene.masterVolume ~= 0 end,
                    hidden = function() return SAM.db.profile.states.cutscene.masterVolume ~= 0 end,
                    get = function(info)
                        return SAM.db.profile.fixCutsceneBug
                    end,
                    set = function(info, v)
                        SAM.db.profile.fixCutsceneBug = v
                    end
                },
            }
        },
        InitializeDefaultValues = function()
            SAM.db.profile.states.cutscene.masterVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.cutscene.initialized = true
        end,
        ValidateSettings = function()
            SAM.db.profile.states.cutscene.masterVolume = max(0, min(1, SAM.db.profile.states.cutscene.masterVolume))
        end,
        ApplyAudioSettings = function()
            if SAM.db.profile.states.cutscene.masterVolume > 0 then
                print("Setting volume to "..SAM.db.profile.states.cutscene.masterVolume.." for cutscene")
                SetCVar(KEY_CVarMasterVolume, SAM.db.profile.states.cutscene.masterVolume)
            elseif SAM.db.profile.fixCutsceneBug == true then
                print("Setting volume to 0.01 for cutscene")
                SetCVar(KEY_CVarMasterVolume, 0.0001)
            end
        end
    },
    raid = {
        overrideable = true,
        settings = {
            masterVolume = -1,
            musicVolume = -1,
            sfxVolume = -1,
            ambienceVolume = -1,
            dialogVolume = -1,
            initialized = false
        },
        configOptions = {
            name = "Raid",
            type = 'group',
            order = 4,
            disabled = function() return SAM.db.profile.overrides.raid == nil or SAM.db.profile.overrides.raid == false end,
            hidden = function() return SAM.db.profile.overrides.raid == nil or SAM.db.profile.overrides.raid == false end,
            args = {
                raidHeader = {
                    name = "Raid",
                    type = 'header',
                    order = 1
                },
                descriptionMessage = {
                    name = "Volume settings to be used during raid instances.",
                    type = 'description',
                    order = 2,
                },
                volumeHeader = {
                    name = "Volume Settings",
                    type = 'header',
                    order = 3
                },
                masterVolume = {
                    name = "Master Volume",
                    type = 'range',
                    order = 4,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.raid.masterVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.raid.masterVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                musicVolume = {
                    name = "Music Volume",
                    type = 'range',
                    order = 5,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.raid.musicVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.raid.musicVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                sfxVolume = {
                    name = "SFX Volume",
                    type = 'range',
                    order = 6,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.raid.sfxVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.raid.sfxVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                ambienceVolume = {
                    name = "Ambience Volume",
                    type = 'range',
                    order = 7,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.raid.ambienceVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.raid.ambienceVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                dialogVolume = {
                    name = "Dialog Volume",
                    type = 'range',
                    order = 8,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.raid.dialogVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.raid.dialogVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                }
            }
        },
        InitializeDefaultValues = function()
            SAM.db.profile.states.raid.masterVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.raid.musicVolume = tonumber(GetCVar(KEY_CVarMusicVolume))
            SAM.db.profile.states.raid.sfxVolume = tonumber(GetCVar(KEY_CVarSfxVolume))
            SAM.db.profile.states.raid.ambienceVolume = tonumber(GetCVar(KEY_CVarAmbienceVolume))
            SAM.db.profile.states.raid.dialogVolume = tonumber(GetCVar(KEY_CVarDialogVolume))
            SAM.db.profile.states.raid.initialized = true
        end,
        ValidateSettings = function()
            SAM.db.profile.states.raid.masterVolume = max(0, min(1, SAM.db.profile.states.raid.masterVolume))
            SAM.db.profile.states.raid.musicVolume = max(0, min(1, SAM.db.profile.states.raid.musicVolume))
            SAM.db.profile.states.raid.sfxVolume = max(0, min(1, SAM.db.profile.states.raid.sfxVolume))
            SAM.db.profile.states.raid.ambienceVolume = max(0, min(1, SAM.db.profile.states.raid.ambienceVolume))
            SAM.db.profile.states.raid.dialogVolume = max(0, min(1, SAM.db.profile.states.raid.dialogVolume))
        end,
        ApplyAudioSettings = function()
            SetCVar(KEY_CVarMasterVolume, SAM.db.profile.states.raid.masterVolume)
            SetCVar(KEY_CVarMusicVolume, SAM.db.profile.states.raid.musicVolume)
            SetCVar(KEY_CVarSfxVolume, SAM.db.profile.states.raid.sfxVolume)
            SetCVar(KEY_CVarAmbienceVolume, SAM.db.profile.states.raid.ambienceVolume)
            SetCVar(KEY_CVarDialogVolume, SAM.db.profile.states.raid.dialogVolume)
        end
    }, 
    dungeon = {
        overrideable = true,
        settings = {
            masterVolume = -1,
            musicVolume = -1,
            sfxVolume = -1,
            ambienceVolume = -1,
            dialogVolume = -1,
            initialized = false
        },
        configOptions = {
            name = "Dungeon",
            type = 'group',
            order = 5,
            disabled = function() return SAM.db.profile.overrides.dungeon == nil or SAM.db.profile.overrides.dungeon == false end,
            hidden = function() return SAM.db.profile.overrides.dungeon == nil or SAM.db.profile.overrides.dungeon == false end,
            args = {
                dungeonHeader = {
                    name = "Dungeon",
                    type = 'header',
                    order = 1
                },
                descriptionMessage = {
                    name = "Volume settings to be used during dungeon instances.",
                    type = 'description',
                    order = 2,
                },
                volumeHeader = {
                    name = "Volume Settings",
                    type = 'header',
                    order = 3
                },
                masterVolume = {
                    name = "Master Volume",
                    type = 'range',
                    order = 4,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.dungeon.masterVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.dungeon.masterVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                musicVolume = {
                    name = "Music Volume",
                    type = 'range',
                    order = 5,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.dungeon.musicVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.dungeon.musicVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                sfxVolume = {
                    name = "SFX Volume",
                    type = 'range',
                    order = 6,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.dungeon.sfxVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.dungeon.sfxVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                ambienceVolume = {
                    name = "Ambience Volume",
                    type = 'range',
                    order = 7,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.dungeon.ambienceVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.dungeon.ambienceVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                dialogVolume = {
                    name = "Dialog Volume",
                    type = 'range',
                    order = 8,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.dungeon.dialogVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.dungeon.dialogVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                }
            }
        },
        InitializeDefaultValues = function()
            SAM.db.profile.states.dungeon.masterVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.dungeon.musicVolume = tonumber(GetCVar(KEY_CVarMusicVolume))
            SAM.db.profile.states.dungeon.sfxVolume = tonumber(GetCVar(KEY_CVarSfxVolume))
            SAM.db.profile.states.dungeon.ambienceVolume = tonumber(GetCVar(KEY_CVarAmbienceVolume))
            SAM.db.profile.states.dungeon.dialogVolume = tonumber(GetCVar(KEY_CVarDialogVolume))
            SAM.db.profile.states.dungeon.initialized = true
        end,
        ValidateSettings = function()
            SAM.db.profile.states.dungeon.masterVolume = max(0, min(1, SAM.db.profile.states.dungeon.masterVolume))
            SAM.db.profile.states.dungeon.musicVolume = max(0, min(1, SAM.db.profile.states.dungeon.musicVolume))
            SAM.db.profile.states.dungeon.sfxVolume = max(0, min(1, SAM.db.profile.states.dungeon.sfxVolume))
            SAM.db.profile.states.dungeon.ambienceVolume = max(0, min(1, SAM.db.profile.states.dungeon.ambienceVolume))
            SAM.db.profile.states.dungeon.dialogVolume = max(0, min(1, SAM.db.profile.states.dungeon.dialogVolume))
        end,
        ApplyAudioSettings = function()
            SetCVar(KEY_CVarMasterVolume, SAM.db.profile.states.dungeon.masterVolume)
            SetCVar(KEY_CVarMusicVolume, SAM.db.profile.states.dungeon.musicVolume)
            SetCVar(KEY_CVarSfxVolume, SAM.db.profile.states.dungeon.sfxVolume)
            SetCVar(KEY_CVarAmbienceVolume, SAM.db.profile.states.dungeon.ambienceVolume)
            SetCVar(KEY_CVarDialogVolume, SAM.db.profile.states.dungeon.dialogVolume)
        end
    },
    battlegrounds = {
        overrideable = true,
        settings = {
            masterVolume = -1,
            musicVolume = -1,
            sfxVolume = -1,
            ambienceVolume = -1,
            dialogVolume = -1,
            initialized = false
        },
        configOptions = {
            name = "Battlegrounds",
            type = 'group',
            order = 6,
            disabled = function() return SAM.db.profile.overrides.battlegrounds == nil or SAM.db.profile.overrides.battlegrounds == false end,
            hidden = function() return SAM.db.profile.overrides.battlegrounds == nil or SAM.db.profile.overrides.battlegrounds == false end,
            args = {
                battlegroundsHeader = {
                    name = "Battlegrounds",
                    type = 'header',
                    order = 1
                },
                descriptionMessage = {
                    name = "Volume settings to be used during battlegrounds instances.",
                    type = 'description',
                    order = 2,
                },
                volumeHeader = {
                    name = "Volume Settings",
                    type = 'header',
                    order = 3
                },
                masterVolume = {
                    name = "Master Volume",
                    type = 'range',
                    order = 2,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.battlegrounds.masterVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.battlegrounds.masterVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                musicVolume = {
                    name = "Music Volume",
                    type = 'range',
                    order = 3,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.battlegrounds.musicVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.battlegrounds.musicVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                sfxVolume = {
                    name = "SFX Volume",
                    type = 'range',
                    order = 4,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.battlegrounds.sfxVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.battlegrounds.sfxVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                ambienceVolume = {
                    name = "Ambience Volume",
                    type = 'range',
                    order = 5,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.battlegrounds.ambienceVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.battlegrounds.ambienceVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                dialogVolume = {
                    name = "Dialog Volume",
                    type = 'range',
                    order = 6,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.battlegrounds.dialogVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.battlegrounds.dialogVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                }
            }
        },
        InitializeDefaultValues = function()
            SAM.db.profile.states.battlegrounds.masterVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.battlegrounds.musicVolume = tonumber(GetCVar(KEY_CVarMusicVolume))
            SAM.db.profile.states.battlegrounds.sfxVolume = tonumber(GetCVar(KEY_CVarSfxVolume))
            SAM.db.profile.states.battlegrounds.ambienceVolume = tonumber(GetCVar(KEY_CVarAmbienceVolume))
            SAM.db.profile.states.battlegrounds.dialogVolume = tonumber(GetCVar(KEY_CVarDialogVolume))
            SAM.db.profile.states.battlegrounds.initialized = true
        end,
        ValidateSettings = function()
            SAM.db.profile.states.battlegrounds.masterVolume = max(0, min(1, SAM.db.profile.states.battlegrounds.masterVolume))
            SAM.db.profile.states.battlegrounds.musicVolume = max(0, min(1, SAM.db.profile.states.battlegrounds.musicVolume))
            SAM.db.profile.states.battlegrounds.sfxVolume = max(0, min(1, SAM.db.profile.states.battlegrounds.sfxVolume))
            SAM.db.profile.states.battlegrounds.ambienceVolume = max(0, min(1, SAM.db.profile.states.battlegrounds.ambienceVolume))
            SAM.db.profile.states.battlegrounds.dialogVolume = max(0, min(1, SAM.db.profile.states.battlegrounds.dialogVolume))
        end,
        ApplyAudioSettings = function()
            SetCVar(KEY_CVarMasterVolume, SAM.db.profile.states.battlegrounds.masterVolume)
            SetCVar(KEY_CVarMusicVolume, SAM.db.profile.states.battlegrounds.musicVolume)
            SetCVar(KEY_CVarSfxVolume, SAM.db.profile.states.battlegrounds.sfxVolume)
            SetCVar(KEY_CVarAmbienceVolume, SAM.db.profile.states.battlegrounds.ambienceVolume)
            SetCVar(KEY_CVarDialogVolume, SAM.db.profile.states.battlegrounds.dialogVolume)
        end
    },
    arena = {
        overrideable = true,
        settings = {
            masterVolume = -1,
            musicVolume = -1,
            sfxVolume = -1,
            ambienceVolume = -1,
            dialogVolume = -1,
            initialized = false
        },
        configOptions = {
            name = "Arena",
            type = 'group',
            order = 7,
            disabled = function() return SAM.db.profile.overrides.arena == nil or SAM.db.profile.overrides.arena == false end,
            hidden = function() return SAM.db.profile.overrides.arena == nil or SAM.db.profile.overrides.arena == false end,
            args = {
                arenaHeader = {
                    name = "Arena",
                    type = 'header',
                    order = 1
                },
                descriptionMessage = {
                    name = "Volume settings to be used during Arena instances.",
                    type = 'description',
                    order = 2,
                },                
                volumeHeader = {
                    name = "Volume Settings",
                    type = 'header',
                    order = 3
                },
                masterVolume = {
                    name = "Master Volume",
                    type = 'range',
                    order = 4,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.arena.masterVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.arena.masterVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                musicVolume = {
                    name = "Music Volume",
                    type = 'range',
                    order = 5,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.arena.musicVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.arena.musicVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                sfxVolume = {
                    name = "SFX Volume",
                    type = 'range',
                    order = 6,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.arena.sfxVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.arena.sfxVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                ambienceVolume = {
                    name = "Ambience Volume",
                    type = 'range',
                    order = 7,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.arena.ambienceVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.arena.ambienceVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                dialogVolume = {
                    name = "Dialog Volume",
                    type = 'range',
                    order = 8,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.arena.dialogVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.arena.dialogVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                }
            }
        },
        InitializeDefaultValues = function()
            SAM.db.profile.states.arena.masterVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.arena.musicVolume = tonumber(GetCVar(KEY_CVarMusicVolume))
            SAM.db.profile.states.arena.sfxVolume = tonumber(GetCVar(KEY_CVarSfxVolume))
            SAM.db.profile.states.arena.ambienceVolume = tonumber(GetCVar(KEY_CVarAmbienceVolume))
            SAM.db.profile.states.arena.dialogVolume = tonumber(GetCVar(KEY_CVarDialogVolume))
            SAM.db.profile.states.arena.initialized = true
        end,
        ValidateSettings = function()
            SAM.db.profile.states.arena.masterVolume = max(0, min(1, SAM.db.profile.states.arena.masterVolume))
            SAM.db.profile.states.arena.musicVolume = max(0, min(1, SAM.db.profile.states.arena.musicVolume))
            SAM.db.profile.states.arena.sfxVolume = max(0, min(1, SAM.db.profile.states.arena.sfxVolume))
            SAM.db.profile.states.arena.ambienceVolume = max(0, min(1, SAM.db.profile.states.arena.ambienceVolume))
            SAM.db.profile.states.arena.dialogVolume = max(0, min(1, SAM.db.profile.states.arena.dialogVolume))
        end,
        ApplyAudioSettings = function()
            SetCVar(KEY_CVarMasterVolume, SAM.db.profile.states.arena.masterVolume)
            SetCVar(KEY_CVarMusicVolume, SAM.db.profile.states.arena.musicVolume)
            SetCVar(KEY_CVarSfxVolume, SAM.db.profile.states.arena.sfxVolume)
            SetCVar(KEY_CVarAmbienceVolume, SAM.db.profile.states.arena.ambienceVolume)
            SetCVar(KEY_CVarDialogVolume, SAM.db.profile.states.arena.dialogVolume)
        end
    },
    voiceover = {
        overrideable = true,
        settings = {
            masterVolume = -1,
            musicVolume = -1,
            sfxVolume = -1,
            ambienceVolume = -1,
            dialogVolume = -1,
            initialized = false
        },
        configOptions = {
            name = "Talking Head",
            type = 'group',
            order = 8,
            disabled = function() return SAM.db.profile.overrides.voiceover == nil or SAM.db.profile.overrides.voiceover == false end,
            hidden = function() return SAM.db.profile.overrides.voiceover == nil or SAM.db.profile.overrides.voiceover == false end,
            args = {
                voiceoverHeader = {
                    name = "Talking Heads",
                    type = 'header',
                    order = 1
                },
                descriptionMessage = {
                    name = "Volume settings to be used when a talking head dialogue is playing.",
                    type = 'description',
                    order = 2,
                },
                volumeHeader = {
                    name = "Volume Settings",
                    type = 'header',
                    order = 3
                },
                masterVolume = {
                    name = "Master Volume",
                    type = 'range',
                    order = 4,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.voiceover.masterVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.voiceover.masterVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                musicVolume = {
                    name = "Music Volume",
                    type = 'range',
                    order = 5,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.voiceover.musicVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.voiceover.musicVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                sfxVolume = {
                    name = "SFX Volume",
                    type = 'range',
                    order = 6,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.voiceover.sfxVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.voiceover.sfxVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                ambienceVolume = {
                    name = "Ambience Volume",
                    type = 'range',
                    order = 7,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.voiceover.ambienceVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.voiceover.ambienceVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                },
                dialogVolume = {
                    name = "Dialog Volume",
                    type = 'range',
                    order = 8,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent=true,
                    get = function(info)
                        return SAM.db.profile.states.voiceover.dialogVolume
                    end,
                    set = function(info, v)
                        SAM.db.profile.states.voiceover.dialogVolume = v
                        addonTable.activeState:ApplyAudioSettings()
                    end,
                }
            }
        },
        InitializeDefaultValues = function()
            SAM.db.profile.states.voiceover.masterVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.voiceover.musicVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.voiceover.sfxVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.voiceover.ambienceVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.voiceover.dialogVolume = tonumber(GetCVar(KEY_CVarMasterVolume))
            SAM.db.profile.states.voiceover.initialized = true
        end,
        ValidateSettings = function()
            SAM.db.profile.states.voiceover.masterVolume = max(0, min(1, SAM.db.profile.states.voiceover.masterVolume))
            SAM.db.profile.states.voiceover.musicVolume = max(0, min(1, SAM.db.profile.states.voiceover.musicVolume))
            SAM.db.profile.states.voiceover.sfxVolume = max(0, min(1, SAM.db.profile.states.voiceover.sfxVolume))
            SAM.db.profile.states.voiceover.ambienceVolume = max(0, min(1, SAM.db.profile.states.voiceover.ambienceVolume))
            SAM.db.profile.states.voiceover.dialogVolume = max(0, min(1, SAM.db.profile.states.voiceover.dialogVolume))
        end,
        ApplyAudioSettings = function()
            SetCVar(KEY_CVarMasterVolume, SAM.db.profile.states.voiceover.masterVolume)
            SetCVar(KEY_CVarMusicVolume, SAM.db.profile.states.voiceover.musicVolume)
            SetCVar(KEY_CVarSfxVolume, SAM.db.profile.states.voiceover.sfxVolume)
            SetCVar(KEY_CVarAmbienceVolume, SAM.db.profile.states.voiceover.ambienceVolume)
            SetCVar(KEY_CVarDialogVolume, SAM.db.profile.states.voiceover.dialogVolume)
        end
    }
}


-- default settings for a new profile
local defaultProfileSettings = {
    profile = {
        name = "Default",
        states = {
            default = states.default.settings,
            cutscene = states.cutscene.settings,
            raid = states.raid.settings,
            dungeon = states.dungeon.settings,
            battlegrounds = states.battlegrounds.settings,
            arena = states.arena.settings,
            voiceover = states.voiceover.settings,
        },
        overrides = {
            cutscene = false,
            raid = false,
            dungeon = false,
            battlegrounds = false,
            arena = false,
            voiceover = false,
        }
    }
}

local generalOptions = {
    name = "General",
    type = 'group',
    order = 1,
    args = {
        welcomeHeader = {
            name = "Introduction",
            type = 'header',
            order = 1
        }, 
        welcomeImage = {
            name = "",
            type = 'description',
            image = 'Interface\\AddOns\\SituationalAudioManager\\Media\\SAM.tga',
            imageWidth = 200,
            imageHeight = 200,
            order = 2,
        },
        welcomeMessage = {
            name = "Welcome to the Situational Audio Manager (SAM for short)!\n\n"
            .."This addon is designed to allow seamless transition between various audio balancing profiles depending on what type of content you are enjoying. For example you might want to hear the game music during a raid but listen to your own music when doing world content or have the game muted except for cutscenes.\n\n"
            .."By default your audio configuration will have been automatically imported into the Default tab which the addon will use to set your volume. |cffff8000Whilst using the addon you must set your volume preferneces via the addon and not the blizzard options interface as those settings will be overriden!!|r\n\n"
            .."If you would like to override the volume settings for a partiular activity or cutscenes, select overrides to add below and then adjust their settings on the relevant tabs.\n\n"
            .."Multiple profiles can be set up to allow you to switch between various presets.\n\n"
            .."If you have any requests for further features or more overrides please let me know and I'll do my best to implement them!\n\n"
            .."Thanks and enjoy!",
            type = 'description',
            order = 3
        },
        overridesHeader = {
            name = "Overrides",
            type = 'header',
            order = 4
        },
        overridesDescription = {
            name = "Add overrides to automatically change the volume settings when entering an activity or cutscene.",
            type = 'description',
            order = 5
        },
        addOveride = {
            name = "Add Override",
            type = 'select',
            order = 6,
            values = unappliedOverrides,
            set = function(info, id)
                SAM.db.profile.overrides[id] = true

                if SAM.db.profile.states[id] == nil or SAM.db.profile.states[id].initialized == false then
                    states[id].InitializeDefaultValues()
                end

                SAM:UpdateAppliedOverrides()
            end
        },
        removeOveride = {
            name = "Remove Override",
            type = 'select',
            order = 7,
            values = appliedOverrides,
            set = function(info, id)
                SAM.db.profile.overrides[id] = false

                SAM:UpdateAppliedOverrides()
            end
        }
    }
}

local options = {
    name = "Situational Audio Manager - Settings",
    type = 'group',
    args = 
    {
        general = generalOptions,
        default = states.default.configOptions,
        cutscene = states.cutscene.configOptions,
        raid = states.raid.configOptions,
        dungeon = states.dungeon.configOptions,
        battlegrounds = states.battlegrounds.configOptions,
        arena = states.arena.configOptions,
        voiceover = states.voiceover.configOptions
    }
}

function SAM:OnInitialize()
    -- setup app
    self.db = LibStub("AceDB-3.0"):New("SituationalAudioManager_Database", defaultProfileSettings, true)
    AceConfig:RegisterOptionsTable("SituationalAudioManager_Options", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("SituationalAudioManager_Options", addonName)

    self.db.RegisterCallback(self, "OnProfileChanged", "UpdateSettings")

    -- add profiles
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AceConfig:RegisterOptionsTable("SituationalAudioManager_Profiles", profiles)
    AceConfigDialog:AddToBlizOptions("SituationalAudioManager_Profiles", "Profiles", addonName)

    SAM:UpdateAppliedOverrides()
    SAM:UpdateSettings()

    -- register chat commands
    self:RegisterChatCommand("sam", "SlashCommand")
    self:RegisterChatCommand("situationalaudiomanager", "SlashCommand")
end

function SAM:UpdateSettings()
    -- make sure the default state has been initialized (i.e. grabbing volume slider values from game settings data)
    if SAM.db.profile.states.default == nil or SAM.db.profile.states.default.initialized == false then
        states.default.InitializeDefaultValues()
    end

    -- Apply values from database back to the game settings.
    SAM:UpdateAppliedOverrides()
    UpdateActiveState("ADDON_UPDATE")
end

function SAM:UpdateAppliedOverrides()
    -- updating lists for applied / unapplied overrides
    for k,v in pairs(states) do 
        if v.overrideable then
            if SAM.db.profile.overrides[k] == true then
                appliedOverrides[k] = v.configOptions.name
                unappliedOverrides[k] = nil
            else
                appliedOverrides[k] = nil
                unappliedOverrides[k] = v.configOptions.name
            end
        end
    end
end

function SAM:OnEnable()
    AceEvent:RegisterEvent("CINEMATIC_START", UpdateActiveState)
    AceEvent:RegisterEvent("CINEMATIC_STOP", UpdateActiveState)
    AceEvent:RegisterEvent("PLAY_MOVIE", UpdateActiveState)
    AceEvent:RegisterEvent("TALKINGHEAD_REQUESTED", UpdateActiveState)
    AceEvent:RegisterEvent("TALKINGHEAD_CLOSE", UpdateActiveState)
    AceEvent:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateActiveState)
end

function SAM:OnDisable()
    AceEvent:UnregisterEvent("CINEMATIC_START")
    AceEvent:UnregisterEvent("CINEMATIC_STOP")
    AceEvent:UnregisterEvent("PLAY_MOVIE")
    AceEvent:UnregisterEvent("TALKINGHEAD_REQUESTED")
    AceEvent:UnregisterEvent("TALKINGHEAD_CLOSE")
    AceEvent:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function SAM:SlashCommand(msg)
    -- unused but getting args in case of desire for further slash commands (i.e. changing profiles)
    local args = {}
    for arg in string.gmatch(msg, "%S+") do
        table.insert(args, arg)
    end

    if #args >= 2 and string.lower(args[1]) == "profile" then
        for k,v in pairs(SAM.db:GetProfiles()) do
            if string.lower(args[2]) == string.lower(v) then
                SAM.db:SetProfile(v)
                return nil
            end
        end
        print("|cffe74c3c[SAM] Warning:|r no profile was found with name \""..args[2].."\". Please make sure one with this name exists in Options > Addons > SituationalAudioManager > Profiles.")
        return nil
    else
        -- must be called twice
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        return nil
    end
end

function UpdateActiveState(eventName)

    local inInstance, instanceType = IsInInstance()

    -- loading in
    if eventName == "PLAYER_ENTERING_WORLD" then
        if not inInstance then
            addonTable.activeState = states.default
        elseif instanceType == "raid" and SAM.db.profile.overrides.raid == true then
            addonTable.activeState = states.raid
        elseif instanceType == "party"  and SAM.db.profile.overrides.dungeon == true then
            addonTable.activeState = states.dungeon
        elseif instanceType == "pvp"  and SAM.db.profile.overrides.battlegrounds == true then
            addonTable.activeState = states.battlegrounds
        elseif instanceType == "arena"  and SAM.db.profile.overrides.arena == true then
            addonTable.activeState = states.arena
        else
            addonTable.activeState = states.default
        end

    -- cutscene start
    elseif (eventName == "CINEMATIC_START" or eventName == "PLAY_MOVIE") and SAM.db.profile.overrides.cutscene == true then             
        addonTable.activeState = states.cutscene

    -- talking head start
    elseif eventName == "TALKINGHEAD_REQUESTED"  and SAM.db.profile.overrides.voiceover == true then
        addonTable.activeState = states.voiceover

    -- cutscene / talking head end
    elseif (eventName == "CINEMATIC_STOP" and SAM.db.profile.overrides.cutscene == true) or (eventName == "TALKINGHEAD_CLOSE" and SAM.db.profile.overrides.voiceover == true) then
        if not inInstance then
            addonTable.activeState = states.default
        elseif instanceType == "raid" and SAM.db.profile.overrides.raid == true  then
            addonTable.activeState = states.raid
        elseif instanceType == "party" and SAM.db.profile.overrides.dungeon == true then
            addonTable.activeState = states.dungeon
        else
            addonTable.activeState = states.default
        end

    -- internal SAM request
    elseif eventName == "ADDON_UPDATE" then
        if not inInstance then
            addonTable.activeState = states.default
        elseif instanceType == "raid" and SAM.db.profile.overrides.raid == true then
            addonTable.activeState = states.raid
        elseif instanceType == "party" and SAM.db.profile.overrides.dungeon == true then
            addonTable.activeState = states.dungeon
        else
            addonTable.activeState = states.default
        end

    -- fallback to default
    else
        addonTable.activeState = states.default                                     
    end
    
    -- validate settings and apply them
    addonTable.activeState:ValidateSettings()
    addonTable.activeState:ApplyAudioSettings()
end