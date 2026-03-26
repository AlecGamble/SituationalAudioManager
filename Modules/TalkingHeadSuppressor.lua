local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local TalkingHeadSuppressorModule = SituationalAudioManager:NewModule("TalkingHeadSuppressor", "AceEvent-3.0")

local original_PlaySound = PlaySound

-- function TalkingHeadSuppressorModule:OnEnable()
--     if SituationalAudioManager.db.profile.disableTalkingHead then
--         self:ApplySuppression()

--         PlaySound = function(soundKitID, channel, ...)
--             if self.supress and channel == "Talking Head" then
--                 return
--             end
--             return original_PlaySound(soundKitID, channel, ...)
--         end
--     else
--         self:SetEnabledState(false)
--         return nil
--     end
-- end

-- function TalkingHeadSuppressorModule:OnDisable()
--     self:RemoveSupression()
-- end

-- function TalkingHeadSuppressorModule:ApplySuppression()
--     self.supress = true
--     TalkingHeadFrame:Hide()
--     TalkingHeadFrame:SetScript("OnShow", TalkingHeadFrame.Hide)
-- end

-- function TalkingHeadSuppressorModule:RemoveSupression()
--     self.supress = false
--     TalkingHeadFrame:Show()
--     TalkingHeadFrame:SetScript("OnShow", nil)
-- end