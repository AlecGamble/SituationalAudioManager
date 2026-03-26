local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local TalkingHeadSuppressorModule = SituationalAudioManager:NewModule("TalkingHeadSuppressor", "AceEvent-3.0")
local Logger = LibStub("LibSituationalLogger-1.0")

function TalkingHeadSuppressorModule:OnEnable()
    if not SituationalAudioManager.db.profile.disableTalkingHead then
        self:SetEnabledState(false)
        return
    end

    self.supressing = true
    -- hide here in case there
    self:Supress()

    if TalkingHeadFrame and TalkingHeadFrame.PlayCurrent then
        hooksecurefunc(TalkingHeadFrame, "PlayCurrent", function()
            if self.supressing then
                self:Supress()
            end
        end)
    end

    
end

function TalkingHeadSuppressorModule:OnDisable()
    self.supressing = false
end

function TalkingHeadSuppressorModule:Supress()
    Logger:Log(Logger.LogLevels.verbose, "Supressing talking head frame.")
    TalkingHeadFrame:Hide()
    local vo = TalkingHeadFrame.voHandle
    if vo then
        StopSound(vo, 0)
    end
end