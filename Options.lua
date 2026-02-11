-- TinyXStats @project-version@ by @project-author@
-- Project revision: @project-revision@
--
-- Options.lua:
-- File revision: @file-revision@
-- Last modified: @file-date-iso@
-- Author: @file-author@

if not TinyXStats then return end

local AddonName = "TinyXStats"
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)
local media = LibStub("LibSharedMedia-3.0")
local Compat = TinyXStats.Compat

TinyXStats.fonteffects = {
    ["none"] = L["NONE"],
    ["OUTLINE"] = L["OUTLINE"],
    ["THICKOUTLINE"] = L["THICKOUTLINE"]
}
TinyXStats.RoleLocale = {
    healer = HEALER,
    caster = PLAYERSTAT_SPELL_COMBAT,
    melee = PLAYERSTAT_MELEE_COMBAT,
    hunter = PLAYERSTAT_RANGED_COMBAT,
    tank = PLAYERSTAT_DEFENSES
}

function TinyXStats:Options()
    local GetAddOnMetadata = GetAddOnMetadata or (C_AddOns and C_AddOns.GetAddOnMetadata)
    local show = string.lower(SHOW)
    local hide = string.lower(HIDE)
    local options = {
        name = AddonName.." "..GetAddOnMetadata(AddonName,"Version"),
        handler = TinyXStats,
        type = 'group',
        args = {
            reset = {
                name = L["Reset position"],
                desc = L["Resets the frame's position"],
                type = "execute",
                func = function()
                        self.db.char.FrameHide = false
                        self.frame:ClearAllPoints() self.frame:SetPoint("CENTER", UIParent, "CENTER")
                    end,
                disabled = function() return InCombatLockdown() end,
                order = 1
            },
            lock = {
                name = L["Lock Frame"],
                desc = L["Locks the position of the text frame"],
                type = 'toggle',
                get = function() return self.db.char.FrameLocked end,
                set = function(info, value)
                    if(value) then
                        self.db.char.FrameLocked = true
                    else
                        self.db.char.FrameLocked = false
                    end
                    self:SetDragScript()
                end,
                disabled = function() return InCombatLockdown() end,
                order = 2
            },
            style = {
                name = STAT_CATEGORY_ATTRIBUTES,
                desc = L["Select which stats to show"],
                type = 'group',
                order = 10,
                args = {
                    hader = {
                        name = function() return TinyXStats.RoleLocale[TinyXStats.PlayerRole] end,
                        type = 'header',
                        order = 1,
                    },
                    spelldmg = {
                        hidden = function() return not self.defaults.char.Style.SP[TinyXStats.PlayerRole] end,
                        name = STAT_SPELLPOWER,
                        desc = STAT_SPELLPOWER.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.SP[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.SP[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.SP[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 2,
                    },
                    spelldmgcolor = {
                        hidden = function() return not self.defaults.char.Style.SP[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.sp
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.sp
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 3,
                    },
                    ap = {
                        hidden = function() return not self.defaults.char.Style.AP[TinyXStats.PlayerRole] end,
                        name = STAT_ATTACK_POWER,
                        desc = STAT_ATTACK_POWER.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.AP[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.AP[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.AP[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 4,
                    },
                    apcolor = {
                        hidden = function() return not self.defaults.char.Style.AP[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.ap
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.ap
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 5,
                    },
                    haste = {
                        hidden = function() return not self.defaults.char.Style.Haste[TinyXStats.PlayerRole] end,
                        name = SPELL_HASTE,
                        desc = SPELL_HASTE.." "..show.."/"..hide.."\n"..L["(Only rating or percentage display possible!)"],
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.Haste[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.Haste[TinyXStats.PlayerRole] = true
                                self.db.char.Style.HastePerc[TinyXStats.PlayerRole] = false
                            else
                                self.db.char.Style.Haste[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 6,
                    },
                    hastecolor = {
                        hidden = function() return not self.defaults.char.Style.Haste[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.haste
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.haste
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 7,
                    },
                    hasteperc = {
                        hidden = function() return not self.defaults.char.Style.Haste[TinyXStats.PlayerRole] end,
                        name = L["Percent Haste"],
                        desc = L["Percent Haste"].." "..show.."/"..hide.."\n"..L["(Only rating or percentage display possible!)"],
                        width = 'full',
                        type = 'toggle',
                        get = function() return self.db.char.Style.HastePerc[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.HastePerc[TinyXStats.PlayerRole] = true
                                self.db.char.Style.Haste[TinyXStats.PlayerRole] = false
                            else
                                self.db.char.Style.HastePerc[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 8,
                    },
                    speed = {
                        hidden = function() return not self.defaults.char.Style.Speed[TinyXStats.PlayerRole] end,
                        name = WEAPON_SPEED,
                        desc = WEAPON_SPEED.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.Speed[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.Speed[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.Speed[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 9,
                    },
                    speedcolor = {
                        hidden = function() return not self.defaults.char.Style.Speed[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.haste
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.haste
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 10,
                    },
                    mp5 = {
                        hidden = function() return not self.defaults.char.Style.MP5[TinyXStats.PlayerRole] end,
                        name = ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["out of combat"],
                        desc = ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["out of combat"].." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.MP5[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.MP5[TinyXStats.PlayerRole] = true
                                self.db.char.Style.MP5auto[TinyXStats.PlayerRole] = false
                            else
                                self.db.char.Style.MP5[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 11,
                    },
                    mp5color = {
                        hidden = function() return not self.defaults.char.Style.MP5[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.mp5
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.mp5
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 12,
                    },
                    mp5ic = {
                        hidden = function() return not self.defaults.char.Style.MP5[TinyXStats.PlayerRole] end,
                        name = ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["in combat"],
                        desc = ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["in combat"].." "..show.."/"..hide,
                        width = 'full',
                        type = 'toggle',
                        get = function() return self.db.char.Style.MP5ic[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.MP5ic[TinyXStats.PlayerRole] = true
                                self.db.char.Style.MP5auto[TinyXStats.PlayerRole] = false
                            else
                                self.db.char.Style.MP5ic[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 13,
                    },
                    mp5auto = {
                        hidden = function() return not self.defaults.char.Style.MP5[TinyXStats.PlayerRole] end,
                        name = ITEM_MOD_MANA_REGENERATION_SHORT.." ("..L["automatic"]..")",
                        desc = L["Automatically selects which mana regeneration to show"],
                        width = 'full',
                        type = 'toggle',
                        get = function() return self.db.char.Style.MP5auto[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.MP5[TinyXStats.PlayerRole] = false
                                self.db.char.Style.MP5ic[TinyXStats.PlayerRole] = false
                                self.db.char.Style.MP5auto[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.MP5auto[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 14,
                    },
                    fr = {
                        hidden = function() return not self.defaults.char.Style.Fr[TinyXStats.PlayerRole] end,
                        name = STAT_FOCUS_REGEN,
                        desc = STAT_FOCUS_REGEN.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.Fr[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.Fr[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.Fr[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 15,
                    },
                    frcolor = {
                        hidden = function() return not self.defaults.char.Style.Fr[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.fr
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.fr
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 16,
                    },
                    crit = {
                        hidden = function() return not self.defaults.char.Style.Crit[TinyXStats.PlayerRole] end,
                        name = CRIT_CHANCE,
                        desc = CRIT_CHANCE.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.Crit[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.Crit[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.Crit[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 17,
                    },
                    critcolor = {
                        hidden = function() return not self.defaults.char.Style.Crit[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.crit
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.crit
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 18,
                    },
                    mastery = {
                        hidden = function() return not Compat.HasMastery() or not self.defaults.char.Style.Mastery[TinyXStats.PlayerRole] end,
                        name = STAT_MASTERY,
                        desc = STAT_MASTERY.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.Mastery[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.Mastery[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.Mastery[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 19,
                    },
                    masterycolor = {
                        hidden = function() return not Compat.HasMastery() or not self.defaults.char.Style.Mastery[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.mastery
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.mastery
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 20,
                    },
                    versatility = {
                        hidden = function() return not Compat.HasVersatility() end,
                        name = STAT_VERSATILITY,
                        desc = STAT_VERSATILITY.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.Versatility[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.Versatility[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.Versatility[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 21,
                    },
                    versatilitycolor = {
                        hidden = function() return not Compat.HasVersatility() or not self.defaults.char.Style.Versatility[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.versatility
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.versatility
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 22,
                    },
                    DC = {
                        hidden = function() return not self.defaults.char.Style.DC[TinyXStats.PlayerRole] end,
                        name = STAT_DODGE,
                        desc = STAT_DODGE.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.DC[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.DC[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.DC[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 23,
                    },
                    dccolor = {
                        hidden = function() return not self.defaults.char.Style.DC[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.dc
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.dc
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 24,
                    },
                    PC = {
                        hidden = function() return TinyXStats:HideTankStat("PC") end,
                        name = STAT_PARRY,
                        desc = STAT_PARRY.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.PC[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.PC[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.PC[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 25,
                    },
                    pccolor = {
                        hidden = function() return TinyXStats:HideTankStat("PC") end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.pc
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.pc
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 26,
                    },
                    BC = {
                        hidden = function() return TinyXStats:HideTankStat("BC") end,
                        name = STAT_BLOCK,
                        desc = STAT_BLOCK.." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.BC[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.BC[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.BC[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 27,
                    },
                    bccolor = {
                        hidden = function() return TinyXStats:HideTankStat("BC") end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.bc
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.bc
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 28,
                    },
                    TA = {
                        hidden = function() return not self.defaults.char.Style.TA[TinyXStats.PlayerRole] end,
                        name = L["Total Avoidance"],
                        desc = L["Total Avoidance"].." "..L["(miss + doge + parry + block)"].." "..show.."/"..hide,
                        width = 'double',
                        type = 'toggle',
                        get = function() return self.db.char.Style.TA[TinyXStats.PlayerRole] end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.TA[TinyXStats.PlayerRole] = true
                            else
                                self.db.char.Style.TA[TinyXStats.PlayerRole] = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 29,
                    },
                    tacolor = {
                        hidden = function() return not self.defaults.char.Style.TA[TinyXStats.PlayerRole] end,
                        name = "",
                        desc = "",
                        width = 'half',
                        type = 'color',
                        get = function()
                            local c = self.db.char.Color.ta
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = self.db.char.Color.ta
                            c.r, c.g, c.b = r, g, b
                            self:Stats()
                        end,
                        order = 30,
                    },
                    header1 = {
                        name = "",
                        type = 'header',
                        order = 31,
                    },
                    showrecords = {
                        name = L["Show records"],
                        desc = L["Whether or not to show record values"],
                        width = 'full',
                        type = 'toggle',
                        get = function() return self.db.char.Style.showRecords end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.showRecords = true
                            else
                                self.db.char.Style.showRecords = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 32,
                    },
                    showrecordsldb = {
                        name = L["Show records on Broker"],
                        desc = L["Whether or not to show record values on Broker"],
                        width = 'full',
                        type = 'toggle',
                        get = function() return self.db.char.Style.showRecordsLDB end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.showRecordsLDB = true
                            else
                                self.db.char.Style.showRecordsLDB = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 33,
                    },
                    resetrecords = {
                        name = L["Reset records"],
                        desc = L["Clears your current records"],
                        type = 'execute',
                        func = function()
                            local spec = "Spec"..GetActiveSpecGroup()
                            for stat, num in pairs(self.defaults.char[spec]) do
                                self.db.char[spec][stat] = num
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 34,
                    },
                    resetcolor = {
                        name = L["Reset colors"],
                        desc = L["Clears your current color settings"],
                        type = 'execute',
                        func = function()
                            for stat, c in pairs(self.defaults.char.Color) do
                                self.db.char.Color[stat].r = c.r
                                self.db.char.Color[stat].g = c.g
                                self.db.char.Color[stat].b = c.b
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 35,
                    }
                }
            },
            text = {
                name = L["Text"],
                desc = L["Text settings"],
                type = 'group',
                order = 11,
                args = {
                    oocalpha = {
                        name = L["Text Alpha"].." "..L["out of combat"],
                        desc = L["Alpha of the text"].." ("..L["out of combat"]..")",
                        width = 'full',
                        type = 'range',
                        min = 0,
                        max = 1,
                        step = 0.01,
                        isPercent = true,
                        get = function() return self.db.char.outOfCombatAlpha end,
                        set = function(info, newValue)
                            self.db.char.outOfCombatAlpha = newValue
                            self.frame:SetAlpha(self.db.char.outOfCombatAlpha)
                        end,
                        disabled = function() return InCombatLockdown() or self.db.char.FrameHide end,
                        order = 1,
                    },
                    icalpha = {
                        name = L["Text Alpha"].." "..L["in combat"],
                        desc = L["Alpha of the text"].." ("..L["in combat"]..")",
                        width = 'full',
                        type = 'range',
                        min = 0,
                        max = 1,
                        step = 0.01,
                        isPercent = true,
                        get = function() return self.db.char.inCombatAlpha end,
                        set = function(info, newValue)
                            self.db.char.inCombatAlpha = newValue
                            self.frame:SetAlpha(self.db.char.inCombatAlpha)
                        end,
                        disabled = function() return InCombatLockdown() or self.db.char.FrameHide end,
                        order = 2,
                    },
                    barfontsize = {
                        name = FONT_SIZE,
                        width = 'full',
                        type = 'range',
                        min = 6,
                        max = 32,
                        step = 1,
                        get = function() return self.db.char.Size end,
                        set = function(info, newValue)
                            self.db.char.Size = newValue
                            local font = media:Fetch("font", self.db.char.Font)
                            for k, fontObject in pairs(self.strings) do
                                fontObject:SetFont(font, self.db.char.Size, self.db.char.FontEffect)
                            end
                            self:InitializeFrame()
                        end,
                        disabled = function() return InCombatLockdown() or self.db.char.FrameHide end,
                        order = 3,
                    },
                    font = {
                        name = L["Font"],
                        type = 'select',
                        get = function() return self.db.char.Font end,
                        set = function(info, newValue)
                            self.db.char.Font = newValue
                            local font = media:Fetch("font", self.db.char.Font)
                            for k, fontObject in pairs(self.strings) do
                                fontObject:SetFont(font, self.db.char.Size, self.db.char.FontEffect)
                            end
                        end,
                        values = self.fonts,
                        disabled = function() return InCombatLockdown() or self.db.char.FrameHide end,
                        order = 4,
                    },
                    fonteffect = {
                        name = L["Font border"],
                        type = 'select',
                        get = function() return self.db.char.FontEffect end,
                        set = function(info, newValue)
                            self.db.char.FontEffect = newValue
                            local font = media:Fetch("font", self.db.char.Font)
                            for k, fontObject in pairs(self.strings) do
                                fontObject:SetFont(font, self.db.char.Size, self.db.char.FontEffect)
                            end
                        end,
                        values = self.fonteffects,
                        disabled = function() return InCombatLockdown() or self.db.char.FrameHide end,
                        order = 5,
                    },
                    vertical = {
                        name = L["Display stats vertically"],
                        desc = L["Whether or not to show stats vertically"],
                        width = 'full',
                        type = 'toggle',
                        get = function() return self.db.char.Style.vertical end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.vertical = true
                            else
                                self.db.char.Style.vertical = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() or self.db.char.FrameHide end,
                        order = 6,
                    },
                    labels = {
                        name = L["Show labels"],
                        desc = L["Whether or not to show labels for each stat"],
                        width = 'full',
                        type = 'toggle',
                        get = function() return self.db.char.Style.labels end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.Style.labels = true
                            else
                                self.db.char.Style.labels = false
                            end
                            self:Stats()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 7,
                    },
                    hide = {
                        name = L["Hide Frame"],
                        desc = L["Hide the text frame (to show stats only in the LDB text field)"],
                        type = 'toggle',
                        get = function() return self.db.char.FrameHide end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.FrameHide = true
                            else
                                self.db.char.FrameHide = false
                            end
                            self:SetFrameVisible()
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 8,
                    },
                    spaceline4 = {
                        name = " ",
                        type = 'description',
                        order = 20,
                    },
                    record = {
                        name = L["Announce records"],
                        desc = L["Whether or not to display a message when a record is broken"],
                        type = 'toggle',
                        get = function() return self.db.char.RecordMsg end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.RecordMsg = true
                            else
                                self.db.char.RecordMsg = false
                            end
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 21,
                    },
                    recordSound = {
                        name = L["Play sound on record"],
                        desc = L["Whether or not to play a sound when a record is broken"],
                        type = 'toggle',
                        get = function() return self.db.char.RecordSound end,
                        set = function(info, value)
                            if(value) then
                                self.db.char.RecordSound = true
                            else
                                self.db.char.RecordSound = false
                            end
                        end,
                        disabled = function() return InCombatLockdown() end,
                        order = 22,
                    },
                    spaceline5 = {
                        name = " ",
                        type = 'description',
                        order = 30,
                    },
                    selectSound = {
                        name = L["Sound"],
                        type = 'select',
                        dialogControl = "LSM30_Sound",
                        get = function() return self.db.char.RecordSoundFile end,
                        set = function(info, value) self.db.char.RecordSoundFile = value end,
                        values = AceGUIWidgetLSMlists.sound,
                        disabled = function() return InCombatLockdown() end,
                        order = 31,
                    },
                }
            },
        }
    }

    return options
end
