-- PlasmaCutterDurability v1.0
-- Raises Plasma Multicutter max durability ("Resistance") and optionally refills it.

local config = require("config")

local PREFIX = "[PlasmaCutterDurability]"
local TOOL_ID = config.TOOL_STATIC_ID or "LaserMiningTool"
local CHECK_MS = math.max(500, math.floor(config.CHECK_INTERVAL_MS or 2000))
local BOOTSTRAP_MS = math.max(0, math.floor(config.BOOTSTRAP_DELAY_MS or 3000))
local WANT = nil -- resolved once at start
local INFINITE = config.INFINITE_DURABILITY ~= false
local ONLY_EQUIPPED = config.ONLY_EQUIPPED ~= false

-- WeaponLoadout=3 is enough for an equipped tool; Essential=2 as fallback when discovering.
local EQUIP_TYPES = { 3, 2 }
local ALL_TYPES = { 3, 2, 0 }

local _tick = 0
local _slot = nil
local _dyn = nil
local _pc = nil
local _inventory = nil
local _palUtility = nil
local _staticDone = false
local _maxDone = false
local _missStreak = 0

local function log(msg)
    print(PREFIX .. " " .. tostring(msg) .. "\n")
end

local function dbg(msg)
    if config.DEBUG then log(msg) end
end

local function valid(obj)
    if obj == nil then return false end
    local ok, result = pcall(function() return obj:IsValid() end)
    return ok and result
end

local function asNum(v)
    if type(v) == "number" then return v end
    if v == nil then return nil end
    local n
    pcall(function() n = v.Value end)
    if type(n) == "number" then return n end
    return tonumber(tostring(v))
end

local function writeNum(obj, field, value)
    return pcall(function() obj[field] = value end)
end

local function resolveWant()
    local absolute = tonumber(config.TARGET_MAX_DURABILITY) or 0
    if absolute > 0 then return absolute end
    local mult = tonumber(config.DURABILITY_MULTIPLIER) or 1
    if mult > 1 then
        return (tonumber(config.VANILLA_MAX_DURABILITY) or 850) * mult
    end
    return nil
end

local function getPalUtility()
    if valid(_palUtility) then return _palUtility end
    pcall(function()
        _palUtility = StaticFindObject("/Script/Pal.Default__PalUtility")
    end)
    return valid(_palUtility) and _palUtility or nil
end

-- Cache controller + inventory; refresh only when invalid.
local function getInventoryData()
    if valid(_inventory) then return _inventory end

    if not valid(_pc) then
        pcall(function() _pc = FindFirstOf("PalPlayerController") end)
    end
    if not valid(_pc) then return nil end

    local pawn = nil
    pcall(function() pawn = _pc.Pawn end)
    if not valid(pawn) then
        _inventory = nil
        return nil
    end

    local util = getPalUtility()
    if util then
        pcall(function()
            _inventory = util:GetPlayerState(pawn):GetInventoryData()
        end)
    end
    if not valid(_inventory) then
        pcall(function()
            _inventory = _pc.PlayerState:GetInventoryData()
        end)
    end
    return valid(_inventory) and _inventory or nil
end

local function getDynamic(slot)
    local dyn = nil
    pcall(function()
        local out = {}
        if slot:TryGetDynamicItemData(out) and out.OutDynamicItemData then
            dyn = out.OutDynamicItemData
        end
    end)
    if dyn then return dyn end
    pcall(function()
        local ok, item = slot:TryGetDynamicItemData()
        if ok then dyn = item end
    end)
    return dyn
end

local function slotIsTool(slot)
    if not valid(slot) then return false end
    local empty = true
    pcall(function() empty = slot:IsEmpty() end)
    if empty then return false end
    local name = nil
    pcall(function() name = slot.ItemId.StaticId:ToString() end)
    return name == TOOL_ID
end

local function patchStaticAsset()
    if _staticDone or not WANT then return end

    local asset = nil
    pcall(function()
        asset = StaticFindObject(
            "/Game/Pal/DataAsset/Item/DA_StaticItemDataAsset.DA_StaticItemDataAsset"
        )
    end)
    if not valid(asset) then
        pcall(function() asset = FindFirstOf("PalStaticItemDataAsset") end)
    end
    if not valid(asset) then return end

    local item = nil
    pcall(function()
        local map = asset.StaticItemDataMap
        if not map then return end
        item = map[FName(TOOL_ID)]
        if valid(item) then return end
        for key, value in pairs(map) do
            local name = nil
            pcall(function() name = key:ToString() end)
            if name == TOOL_ID then
                item = value
                return
            end
        end
    end)

    if not valid(item) then return end

    local before = asNum(item.Durability)
    if before and before + 0.5 >= WANT then
        _staticDone = true
        return
    end

    if writeNum(item, "Durability", WANT) then
        log(string.format("static Durability %s -> %.0f", tostring(before), WANT))
        _staticDone = true
    end
end

local function findToolSlot(inventoryData)
    local types = ONLY_EQUIPPED and EQUIP_TYPES or ALL_TYPES
    for _, invType in ipairs(types) do
        local container = nil
        pcall(function()
            local out = {}
            if inventoryData:TryGetContainerFromInventoryType(invType, out) then
                container = out.OutContainer
            end
        end)
        if valid(container) then
            local count = 0
            pcall(function() count = container:Num() end)
            for i = 0, count - 1 do
                local slot = nil
                pcall(function() slot = container:Get(i) end)
                if slotIsTool(slot) then return slot end
            end
        end
    end
    return nil
end

-- Hot path: only touch dynamic Durability / MaxDurability.
local function patchCached()
    if not valid(_dyn) then
        _dyn = getDynamic(_slot)
        if not _dyn then return end
    end

    local cur = asNum(_dyn.Durability)
    local max = asNum(_dyn.MaxDurability)
    if not cur or not max or max <= 0 then
        _dyn = nil
        return
    end

    -- Raise instance max once.
    if WANT and not _maxDone and max + 0.5 < WANT then
        writeNum(_dyn, "MaxDurability", WANT)
        max = asNum(_dyn.MaxDurability) or max
        if max + 0.5 >= WANT then
            _maxDone = true
            writeNum(_dyn, "Durability", WANT)
            dbg(string.format("MaxDurability -> %.0f", WANT))
            return
        end
        -- Write may be ignored; keep trying a few times via _maxDone staying false.
        dbg(string.format("MaxDurability still %.0f", max))
    elseif WANT and max + 0.5 >= WANT then
        _maxDone = true
    end

    if INFINITE and cur < max - 0.05 then
        writeNum(_dyn, "Durability", max)
        dbg(string.format("refill %.1f -> %.1f", cur, max))
    end
end

local function scanOnce()
    if config.ENABLED == false then return end

    if not _staticDone then
        patchStaticAsset()
    end

    -- Fast path: cached slot still valid.
    if slotIsTool(_slot) then
        _missStreak = 0
        patchCached()
        return
    end

    -- Slot lost (unequipped / swapped) — clear caches.
    _slot = nil
    _dyn = nil
    _maxDone = false

    -- Back off rediscovery when tool not equipped (every 4th tick).
    _missStreak = _missStreak + 1
    if _missStreak > 1 and (_missStreak % 4) ~= 1 then
        return
    end

    local inventoryData = getInventoryData()
    if not inventoryData then
        _pc = nil
        _inventory = nil
        return
    end

    _slot = findToolSlot(inventoryData)
    if _slot then
        _missStreak = 0
        _dyn = getDynamic(_slot)
        dbg("slot cached")
        patchCached()
    end
end

local function tick()
    _tick = _tick + 1
    local ok, err = pcall(scanOnce)
    if not ok then
        log("ERROR: " .. tostring(err))
        _slot = nil
        _dyn = nil
        _pc = nil
        _inventory = nil
    end
end

local function startLoop()
    WANT = resolveWant()
    log(string.format(
        "v1.0 ready | tool=%s max=%s infinite=%s interval=%dms",
        TOOL_ID,
        WANT and string.format("%.0f", WANT) or "vanilla",
        tostring(INFINITE),
        CHECK_MS
    ))

    if type(LoopAsync) ~= "function" then
        log("ERROR: LoopAsync unavailable")
        return
    end

    LoopAsync(CHECK_MS, function()
        if type(ExecuteInGameThread) == "function" then
            ExecuteInGameThread(tick)
        else
            tick()
        end
        return false
    end)
end

log("loaded — edit Scripts/config.lua")

if type(ExecuteWithDelay) == "function" then
    ExecuteWithDelay(BOOTSTRAP_MS, startLoop)
else
    startLoop()
end
