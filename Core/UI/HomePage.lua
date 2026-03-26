local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)

local HomePage = {}

function HomePage:GetOptions()
    return {
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
                imageCoords = {0, 1, 0, 1},
            },
            welcomeMessage = {
                name = "Welcome to the Situational Audio Manager (SAM for short)!\n\n"
                .."This addon is designed to allow seamless transition between various audio balancing profiles depending on what type of content you are enjoying. For example you might want to hear the game music during a raid but listen to your own music when doing world content or have the game muted except for cutscenes.\n\n"
                .."By default your audio configuration will have been automatically imported into the Volume Settings tab which the addon will use to set your volume. |cffff8000Whilst using the addon you must set your volume preferences via the addon and not the blizzard options interface as those settings will be overriden!!|r\n\n"
                .."If you would like to override the volume settings for a partiular activity or cutscenes, select overrides to add in the Volume Settings tab and change the settings as you wish.\n\n"
                .."Multiple profiles can be set up to allow you to switch between various presets and can be changed easily with the slash command below:\n\nSlash Command: /SAM Profile <profile name>.\n\n"
                .."If you have any requests for further features or more overrides please let me know and I'll do my best to implement them!\n\n"
                .."Thanks and enjoy!",
                type = 'description',
                order = 3
            }
        }
    }
end

SituationalAudioManager.ConfigPages = SituationalAudioManager.ConfigPages or {}
SituationalAudioManager.ConfigPages.HomePage = HomePage