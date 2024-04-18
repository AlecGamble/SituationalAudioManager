local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)

SAM.LogLevel = 0

SAM.LogLevels = {
    Always = 0,
    Verbose = 1
}

function SAM:Log(msg, logLevel)
    if logLevel <= SAM.LogLevel then
        local hours, minutes = GetGameTime()
        local time = string.format("%02d:%02d", hours, minutes)
        print(time.." [|cffff8000SAM|r] "..msg)
    end
end

function SAM:LogWarning(msg, logLevel)
    if logLevel <= SAM.LogLevel then
        local hours, minutes = GetGameTime()
        local time = string.format("%02d:%02d", hours, minutes)
        print(time.." [|cffff8000SAM|r] |cffe74c3cWarning:|r "..msg)
    end
end



function SAM:SetLogLevel(logLevel)
    if SAM.LogLevels[logLevel] == nil then
        local msg = "No such log level ("..logLevel..") exists. Try one of these:"
        for k, v in pairs(SAM.LogLevels) do
            msg = msg.."\n"..k
        end
        SAM:Log(msg, SAM.LogLevels.Always)
        return
    end

    SAM.LogLevel = SAM.LogLevels[logLevel]
end