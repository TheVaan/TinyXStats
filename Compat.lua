-- TinyXStats Compatibility Layer
-- Provides version-specific API wrappers for different WoW versions

local Compat = {}
TinyXStats.Compat = Compat

-- Version detection
local function GetWoWVersion()
    local version, build, date, tocVersion = GetBuildInfo()
    local projectID = WOW_PROJECT_ID or 0
    
    -- WOW_PROJECT_ID constants:
    -- WOW_PROJECT_MAINLINE = 1 (Retail)
    -- WOW_PROJECT_CLASSIC = 2 (Classic)
    -- WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5 (TBC Classic)
    -- WOW_PROJECT_WRATH_CLASSIC = 11 (Wrath Classic)
    -- WOW_PROJECT_CATACLYSM_CLASSIC = 14 (Cata Classic)
    -- WOW_PROJECT_MOP_CLASSIC = 16 (MoP Classic)
    
    if projectID == 1 then
        return "RETAIL"
    elseif projectID == 2 then
        return "CLASSIC"
    elseif projectID == 5 then
        return "TBC_CLASSIC"
    elseif projectID == 11 then
        return "WRATH_CLASSIC"
    elseif projectID == 14 then
        return "CATA_CLASSIC"
    elseif projectID == 16 then
        return "MOP_CLASSIC"
    else
        -- Fallback: try to detect from tocVersion
        if tocVersion >= 110000 then
            return "RETAIL"
        elseif tocVersion >= 50000 then
            return "CLASSIC"
        elseif tocVersion >= 40000 then
            return "CATA_CLASSIC"
        elseif tocVersion >= 30000 then
            return "WRATH_CLASSIC"
        elseif tocVersion >= 20000 then
            return "TBC_CLASSIC"
        else
            return "UNKNOWN"
        end
    end
end

local WoWVersion = GetWoWVersion()
Compat.WoWVersion = WoWVersion

-- Helper function to safely call APIs
local function SafeCall(func, ...)
    if func then
        local success, result = pcall(func, ...)
        if success then
            return result
        end
    end
    return nil
end

-- Spell Power / Spell Damage
function Compat.GetSpellPower()
    -- Use GetSpellBonusDamage for all versions (works across all WoW versions)
    local spelldamage = 0
    for i = 2, 7 do
        local damage = SafeCall(GetSpellBonusDamage, i)
        if damage and damage > spelldamage then
            spelldamage = damage
        end
    end
    local healing = SafeCall(GetSpellBonusHealing)
    if healing and healing > spelldamage then
        spelldamage = healing
    end
    return spelldamage
end

-- Attack Power
function Compat.GetAttackPower(isRanged)
    if isRanged then
        local base, buff, debuff = UnitRangedAttackPower("player")
        return (base or 0) + (buff or 0) + (debuff or 0)
    else
        local base, buff, debuff = UnitAttackPower("player")
        return (base or 0) + (buff or 0) + (debuff or 0)
    end
end

-- Crit Chance
function Compat.GetCritChance(isSpell)
    if isSpell then
        if WoWVersion == "RETAIL" or WoWVersion == "MOP_CLASSIC" then
            -- Retail/MoP: Use GetSpellCritChance with school
            local critchance = 0
            for i = 2, 7 do
                local crit = SafeCall(GetSpellCritChance, i)
                if crit and crit > critchance then
                    critchance = crit
                end
            end
            return critchance
        else
            -- Classic: Use GetSpellCritChance
            local critchance = 0
            for i = 2, 7 do
                local crit = SafeCall(GetSpellCritChance, i)
                if crit and crit > critchance then
                    critchance = crit
                end
            end
            return critchance
        end
    else
        -- Melee crit
        local crit = SafeCall(GetCritChance, "player")
        return crit or 0
    end
end

-- Haste
function Compat.GetHaste()
    if WoWVersion == "RETAIL" or WoWVersion == "MOP_CLASSIC" then
        -- Retail/MoP: Use UnitSpellHaste directly (returns percentage as decimal, e.g. 0.15 for 15%)
        local hasteperc = UnitSpellHaste("player") or 0
        -- Calculate rating from percentage if needed
        local CR = SafeCall(GetCombatRating, CR_HASTE_SPELL) or 0
        local CRB = SafeCall(GetCombatRatingBonus, CR_HASTE_SPELL) or 0
        local haste = 0
        if CRB > 0 and CR > 0 and hasteperc > 0 then
            haste = CR / CRB * hasteperc
        end
        return math.floor(haste + 0.5), string.format("%.2f", hasteperc * 100)
    else
        -- Classic/TBC/Wrath: Use Combat Rating
        local CR = SafeCall(GetCombatRating, CR_HASTE_SPELL) or 0
        local CRB = SafeCall(GetCombatRatingBonus, CR_HASTE_SPELL) or 0
        local hasteperc = SafeCall(UnitSpellHaste, "player") or 0
        local haste = 0
        
        if CRB > 0 and CR > 0 and hasteperc > 0 then
            haste = CR / CRB * hasteperc
        end
        
        return math.floor(haste + 0.5), string.format("%.2f", hasteperc * 100)
    end
end

-- Mastery
function Compat.GetMastery()
    if WoWVersion == "RETAIL" or WoWVersion == "MOP_CLASSIC" then
        local mastery = SafeCall(GetMasteryEffect)
        if mastery then
            return string.format("%.2f", mastery)
        end
    end
    return nil
end

-- Versatility
function Compat.GetVersatility()
    if WoWVersion == "RETAIL" then
        -- Retail: Use GetCombatRating with versatility ID
        local rating = SafeCall(GetCombatRating, 29) or 0
        return string.format("%.2f", rating / 130)
    else
        return nil
    end
end

-- Weapon Speed
function Compat.GetWeaponSpeed()
    local mainSpeed, offSpeed = UnitAttackSpeed("player")
    return mainSpeed, offSpeed
end

-- Ranged Weapon Speed
function Compat.GetRangedSpeed()
    if SafeCall(IsRangedWeapon) then
        local speed = SafeCall(UnitRangedDamage, "player")
        if speed and speed > 0 then
            return string.format("%.2f", speed)
        end
    end
    return nil
end

-- Mana Regeneration
function Compat.GetManaRegen()
    local base, casting = GetManaRegen()
    return base or 0, casting or 0
end

-- Power Regeneration (Focus, Energy, etc.)
function Compat.GetPowerRegen()
    local regen = SafeCall(GetPowerRegen)
    return regen or 0
end

-- Defense Stats
function Compat.GetDefenseStats()
    local missChance = select(2, UnitRace("player")) == "NightElf" and 7 or 5
    local PlayerLevel = UnitLevel("player")
    local BossLevel = UnitLevel("player")
    local defenseDiff = (BossLevel - PlayerLevel) * 0.20
    missChance = math.max(0, missChance - defenseDiff)
    
    local dodgeChance = math.max(0, (SafeCall(GetDodgeChance) or 0) - defenseDiff)
    local parryChance = math.max(0, (SafeCall(GetParryChance) or 0) - defenseDiff)
    local blockChance = math.max(0, (SafeCall(GetBlockChance) or 0) - defenseDiff)
    local TAvoidance = missChance + dodgeChance + parryChance + blockChance
    
    return string.format("%.2f", TAvoidance), 
           string.format("%.2f", dodgeChance), 
           string.format("%.2f", parryChance), 
           string.format("%.2f", blockChance)
end

-- Specialization
function Compat.GetSpecialization()
    if WoWVersion == "RETAIL" or WoWVersion == "MOP_CLASSIC" then
        return SafeCall(GetSpecialization)
    else
        return nil
    end
end

function Compat.GetSpecializationRole(spec)
    if WoWVersion == "RETAIL" or WoWVersion == "MOP_CLASSIC" then
        if spec then
            return SafeCall(GetSpecializationRole, spec, false, false)
        end
    end
    return nil
end

function Compat.GetActiveSpecGroup()
    if WoWVersion == "RETAIL" or WoWVersion == "MOP_CLASSIC" then
        return SafeCall(GetActiveSpecGroup) or 1
    else
        -- Classic: Always return 1 (no dual spec)
        return 1
    end
end

-- Check if API is available
function Compat.HasMastery()
    return WoWVersion == "RETAIL" or WoWVersion == "MOP_CLASSIC"
end

function Compat.HasVersatility()
    return WoWVersion == "RETAIL"
end

function Compat.HasSpecialization()
    return WoWVersion == "RETAIL" or WoWVersion == "MOP_CLASSIC"
end

return Compat
