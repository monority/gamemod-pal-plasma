-- PlasmaCutterDurability settings
-- Edit this file, then restart the game.
-- Vanilla Plasma Multicutter max durability ("Resistance") = 850

return {
    ENABLED = true,
    DEBUG = false,

    TOOL_STATIC_ID = "LaserMiningTool",

    ---------------------------------------------------------------------------
    -- Max durability ("Resistance" totale)
    ---------------------------------------------------------------------------
    -- Absolute max. If > 0, this wins.
    TARGET_MAX_DURABILITY = 8500,

    -- Used only when TARGET_MAX_DURABILITY = 0.
    -- New max = VANILLA_MAX_DURABILITY * DURABILITY_MULTIPLIER
    DURABILITY_MULTIPLIER = 10,
    VANILLA_MAX_DURABILITY = 850,

    ---------------------------------------------------------------------------
    -- Current durability
    ---------------------------------------------------------------------------
    -- true = keep current durability topped up to max
    INFINITE_DURABILITY = true,

    ---------------------------------------------------------------------------
    -- Performance
    ---------------------------------------------------------------------------
    -- 1500–3000 ms is enough; lower only if refill feels late while mining.
    CHECK_INTERVAL_MS = 2000,
    BOOTSTRAP_DELAY_MS = 3000,
    ONLY_EQUIPPED = true,
}
