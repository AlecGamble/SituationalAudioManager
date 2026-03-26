local addonName, addonTable = ...

local Utils = {}

------------------------------------------------
-- Maths Utils
------------------------------------------------

function Utils.clamp(x,l,u)
    return min(max(x,l),u)
end

function Utils.clamp01(x)
    return Utils.clamp(x,0,1)
end

function Utils.lerp(a,b,t)
    t = Utils.clamp01(t)
    return (1-t)*a+t*b
end

addonTable.Utils = Utils