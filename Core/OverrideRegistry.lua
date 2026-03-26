local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)

SituationalAudioManager.OverrideRegistry = 
{
    MasterVolume = 
    {
        Name = "Master Volume",
        CVar = "Sound_MasterVolume",
        Control = 
        {
            Label = "Master Volume",
            Type = "range",
            Min = 0, Max = 1, Step = 0.01
        },
        Fade = true,
        Handler = "VolumeHandler"
    },
    MusicVolume = 
    {
        Name = "Music",
        CVar = "Sound_MusicVolume",
        Control = 
        {
            Label = "Music",
            Type = "range",
            Min = 0, Max = 1, Step = 0.01
        },
        Fade = true,
        Handler = "VolumeHandler"
    },
    SFXVolume = 
    {
        Name = "Effects",
        CVar = "Sound_SFXVolume",
        Control = 
        {
            Label = "Effects",
            Type = "range",
            Min = 0, Max = 1, Step = 0.01
        },
        Fade = true,
        Handler = "VolumeHandler"
    },
    AmbienceVolume = {
        Name = "Ambience",
        CVar = "Sound_MasterVolume",
        Control = 
        {
            Label = "Ambience",
            Type = "range",
            Min = 0, Max = 1, Step = 0.01
        },
        Fade = true,
        Handler = "VolumeHandler"
    },
    DialogVolume = 
    {
        Name = "Dialog",
        CVar = "Sound_DialogVolume",
        Control = 
        {
            Label = "Dialog",
            Type = "range",
            Min = 0, Max = 1, Step = 0.01
        },
        Fade = false,
        Handler = "VolumeHandler"
    },
    GameplaySFXVolume = 
    {
        Name = "Gameplay Sound Effects",
        CVar = "Sound_DialogVolume",
        Control = 
        {
            Label = "Gameplay Sound Effects",
            Type = "range",
            Min = 0, Max = 1, Step = 0.01
        },
        Fade = true,
        Handler = "VolumeHandler"
    },
}