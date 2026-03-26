local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)

local GeneralPage = {}

function GeneralPage:GetOptions()
    return {
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
                get = function()
                    return SituationalAudioManager.db.profile.fixCutsceneBug
                end,
                set = function(_, v)
                    SituationalAudioManager.db.profile.fixCutsceneBug = v
                    if v then
                        SituationalAudioManager:EnableModule("CutsceneBugFix")
                    else
                        SituationalAudioManager:DisableModule("CutsceneBugFix")
                    end
                end
            },
            cutsceneOverrideMessage = {
                name = "If you want to have no volume |cffff8000except|r for cutscenes use a cutscene override in |cffffd800Volume Settings|r instead.",
                type = 'description',
                order = 9,
            },
            testPlayMovieButton = {
            name = "Test Play Movie",
            type = 'execute',
            order = 10,
            func = function()
                -- seems to need to be triggered manually when calling MovieFrame_PlayMovie
                SituationalAudioManager.Contexts["cutscene"]:OnCutsceneStart()
                MovieFrame_PlayMovie(MovieFrame, 960)
            end
        }
            --,
            -- disableTalkingHeadHeader = {
            --     name = "Disable Talking Head Popups",
            --     type = 'header',
            --     order = 10
            -- },
            -- disableTalkingHead = {
            --     name = "Disable Talking Head Popups",
            --     desc = "",
            --     descStyle = "inline",
            --     width = "full",
            --     type = 'toggle',
            --     order = 11,
            --     get = function() 
            --         return SituationalAudioManager.db.profile.disableTalkingHead
            --     end,
            --     set = function(_, v)
            --         SituationalAudioManager.db.profile.disableTalkingHead = v
            --         if v then
            --             SituationalAudioManager:EnableModule("TalkingHeadSuppressor")
            --         else
            --             SituationalAudioManager:DisableModule("TalkingHeadSuppressor")
            --         end
            --     end,
            -- }
        }
    }
end

SituationalAudioManager.ConfigPages = SituationalAudioManager.ConfigPages or {}
SituationalAudioManager.ConfigPages.GeneralPage = GeneralPage