local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local Config = SituationalAudioManager:NewModule("Config", "AceConsole-3.0")
local OverrideRegistry = SituationalAudioManager.OverrideRegistry

SituationalAudioManager.ConfigPages = SituationalAudioManager.ConfigPages or {}
------------------------------------------------
-- Genrate controls from registry
------------------------------------------------

local function BuildCVarConfig()
    local options = {}

    for _, def in pairs(OverrideRegistry) do
    end

    return options
end

------------------------------------------------
-- AceConfig Config Table
------------------------------------------------

Config.options = {
    type = "group",
    name = "Situational Audio Manager",
    args = {},
    plugins = {}
}

------------------------------------------------
-- Register with AceConfig
------------------------------------------------

function Config:OnInitialize()
    for key, page in pairs(SituationalAudioManager.ConfigPages) do
        Config.options.args[key] = page:GetOptions()
    end

    -- Add Ace managed user profiles tab
    self.options.plugins.profiles = {
        profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(SituationalAudioManager.db) 
    }

    AceConfig:RegisterOptionsTable("SituationalAudioManager_Options", self.options)
    SituationalAudioManager.optionsFrame = AceConfigDialog:AddToBlizOptions("SituationalAudioManager_Options", "Situational Audio Manager")
end

function Config:Show(...)
    AceConfigDialog:Open("SituationalAudioManager_Options", ...)
end

SituationalAudioManager.Config = Config