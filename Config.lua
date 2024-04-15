local addonName, addonTable = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local Module = Addon:NewModule("Config", "AceConsole-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")

Module.options = {
    name = "Situational Audio Manager",
    type = 'group',
    args = {
        home = {
            name = "Home",
            type = 'group',
            order = 10,
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
                    .."By default your audio configuration will have been automatically imported into the Default tab which the addon will use to set your volume. |cffff8000Whilst using the addon you must set your volume preferences via the addon and not the blizzard options interface as those settings will be overriden!!|r\n\n"
                    .."If you would like to override the volume settings for a partiular activity or cutscenes, select overrides to add under General and then adjust their settings on the relevant tabs.\n\n"
                    .."Multiple profiles can be set up to allow you to switch between various presets.\n\n"
                    .."If you have any requests for further features or more overrides please let me know and I'll do my best to implement them!\n\n"
                    .."Thanks and enjoy!",
                    type = 'description',
                    order = 3
                }
            }
        },
        general = {
            name = "General",
            type = 'group',
            order = 20,
            args={
                generalDescription = {
                    name = "Below are some settings and fixes for audio related bugs which I have personally found useful but are not related to managing audio profiles.",
                    type = 'description',
                    order = 0,
                },
                restartSystemAudioHeader = {
                    name = "System Default Output Device Bug Fix",
                    type = 'header',
                    order = 1
                },
                restartSystemAudioDescription = {
                    name = "|cffff8000Bug:|r System Default output device in audio settings does not update if the system audio output is changed whilst the game is running (i.e. plugging in or removing a headset).",
                    type = 'description',
                    order =  2
                },
                restartButton = {
                    name = "Manual Restart",
                    type = 'execute',
                    desc = "Restarts the audio engine.",
                    descStyle = "inline",
                    order = 4,
                    func = function()
                        Sound_GameSystem_RestartSoundSystem()
                    end
                },
                restartOnReloadToggle = {
                    name = "Restart On Entering World",
                    desc = "Restarts the audio system whenever you exit a loading screen.",
                    descStyle = "inline",
                    width = "full",
                    type = 'toggle',
                    order = 3,
                    set = function(info, value)
                        Addon.db.profile.restartOnReload = value
                    end,
                    get = function(value)
                        return Addon.db.profile.restartOnReload
                    end,
                },
                restartAudioSlashCommandDescription = {
                    name = "\nSlash Command: /sam restart",
                    type = 'description',
                    order =  5
                },
                fixCutsceneBugHeader = {
                    name = "Cutscene Black Screen Bug Fix",
                    type = 'header',
                    order = 6
                },
                fixCutsceneBugMessage = {
                    name = "|cffff8000Bug:|r Loading a cutscene with 0% master volume gets stuck on a black screen which you have to skip and miss your cutscene! :(.",
                    type = 'description',
                    order = 7,
                },
                fixCutsceneBugToggle = {
                    name = "Fix Cutscene Bug",
                    desc = "Sets volume to 0.0001 for cutscenes if it would otherwise be 0%.",
                    descStyle = "inline",
                    width = "full",
                    type = 'toggle',
                    order = 8,
                    get = function(info)
                        return SAM.db.profile.fixCutsceneBug
                    end,
                    set = function(info, v)
                        SAM.db.profile.fixCutsceneBug = v
                    end
                },
                cutsceneOverrideMessage = {
                    name = "If you want to have no volume |cffff8000except|r for cutscenes use a cutscene override in |cffffd800Volume Settings|r instead.",
                    type = 'description',
                    order = 9,
                },
            }
        },
    },
    plugins = {
    }
}

function Module:OnInitialize()
    -- Add Ace managed user profiles tab
    self.options.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Addon.db) }

    AceConfig:RegisterOptionsTable("SituationalAudioManager_Options", self.options)
    Addon.optionsFrame = AceConfigDialog:AddToBlizOptions("SituationalAudioManager_Options", "Situational Audio Manager")
end