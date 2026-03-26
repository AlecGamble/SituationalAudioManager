local MAJOR, MINOR = "LibSituationalLogger-1.0", 1
local Logger = LibStub:NewLibrary(MAJOR, MINOR)
if not Logger then return end

-- keep 2000 log messages at a time
Logger.MAX_LOG_COUNT = 2000

Logger.Types = 
{
    info = 1,
    warning = 2,
    error = 3
}

local chatPrefixes = 
{
    [Logger.Types.info] = "[|cff1abc9cSituational Audio Manager|r] Info:", 
    [Logger.Types.warning] = "[|cff1abc9cSituational Audio Manager|r] |cfff1c40fWarning:|r", 
    [Logger.Types.error] = "[|cff1abc9cSituational Audio Manager|r] |cffe74c3cError:|r",
}

local logPrefixes = 
{
    [Logger.Types.info] = "[Situational Audio Manager] Info:", 
    [Logger.Types.warning] = "[Situational Audio Manager] Warning:", 
    [Logger.Types.error] = "[Situational Audio Manager] Error:",
}

Logger.LogLevels = 
{
    public = 1,
    debug = 2,
    verbose = 3
}

local logLevelOrder = { "public", "debug", "verbose" }

Logger.LogLevel = Logger.LogLevels.public
Logger.Initialized = false
Logger.Buffer = {}

-- Will be assigned by the addon during OnInitialize
Logger.db = nil

------------------------------------------------
-- Utils
------------------------------------------------
local function formatString(msg, ...)
    if(select("#", ...) > 0) then
        return string.format(msg, ...)
    end
    return msg
end

local function timestamp()
    return date("%Y-%m-%d %H:%M:%S")
end

------------------------------------------------
-- Log to chat window
------------------------------------------------
local function LogToChat(msg)
    print(msg)
end

------------------------------------------------
-- Log to file
------------------------------------------------
local function LogToFile(msg)
    if not Logger.db then 
        return 
    end

    table.insert(Logger.db.logs, msg)
    
    if #Logger.db.logs > Logger.MAX_LOG_COUNT then
        local excess = #Logger.db.logs - Logger.MAX_LOG_COUNT
        for i = 1, excess do
            table.remove(Logger.db.logs, i)
        end
    end
end

function Logger:_log(logType, level, msg, ...)
    if self.initialised and logType == Logger.Types.info and level > self.db.LogLevel then
        return
    end

    local msg = formatString(msg, ...)
    local chatPrefix = chatPrefixes[logType]
    local logPrefix = logPrefixes[logType]
    local chatMsg = string.format("[%s]%s %s", timestamp(), chatPrefix, msg)
    local logMsg = string.format("[%s]%s %s", timestamp(), logPrefix, msg)

    if not self.initialised then
        table.insert(self.Buffer, { level = level, chatMsg = chatMsg, logMsg = logMsg })
        return
    end

    LogToChat(chatMsg)
    LogToFile(logMsg)
end

------------------------------------------------
-- Public API
------------------------------------------------
function Logger:Log(level, msg, ...)
    self:_log(Logger.Types.info, level, msg, ...)
end

function Logger:LogWarning(msg, ...)
    self:Warning(msg, ...)
end

function Logger:Warning(msg, ...)
    self:_log(Logger.Types.warning, Logger.LogLevels.public, msg, ...)
end

function Logger:LogError(msg, ...)
    self:Error(msg, ...)
end

function Logger:Error(msg, ...)
    self:_log(Logger.Types.error, Logger.LogLevels.public, msg, ...)
end

------------------------------------------------
-- Initialisation
------------------------------------------------
function Logger:Initialise(db)
    self.db = db
    self.db.logs = self.db.logs or {}
    self.db.LogLevel = self.db.LogLevel or 0
    self.initialised = true

    for _, entry in ipairs(self.Buffer) do
        if (entry.level or 0) <= self.db.LogLevel then
            LogToChat(entry.chatMsg)
        end
        LogToFile(entry.logMsg)
    end

    self.Buffer = {}
end

local function PrintInvalidLogLevelMessage(input)
    Logger:Error("Invalid log level \"%s\". Valid logging levels:", input or "")
    for _, key in ipairs(logLevelOrder) do
        print(string.format("%s (%d)", key, Logger.LogLevels[key]))
    end
end

function Logger:SetLogLevel(input)
    local logLevel = input and input:trim():lower()
    -- if no log level is set, reset to default
    if not logLevel or logLevel == "" then
        PrintInvalidLogLevelMessage(input)
        return
    end

    local id = tonumber(logLevel)
    if id then
        for key, value in pairs(self.LogLevels) do
            if id == value then
                logLevel = key
            end
        end
    end

    local logLevelValue = self.LogLevels[logLevel]
    if not logLevelValue then
        PrintInvalidLogLevelMessage(input)
        return
    end

    self.db.LogLevel = logLevelValue
    self:Log(self.LogLevels.public, "Setting Log Level to %s.", logLevel)
end

return Logger