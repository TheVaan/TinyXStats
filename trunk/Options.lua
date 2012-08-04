--
-- File version: @file-revision@
-- Project: @project-revision@
--
if not TinyXStats then return end

local AddonName = "TinyXStats"
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(AddonName)
local media = LibStub:GetLibrary("LibSharedMedia-3.0")
local currentBuild = select(4, GetBuildInfo())

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
						if IsShiftKeyDown() then
							self.db.profile.debug = not self.db.profile.debug
							print(AddonName,"- Debug:",self.db.profile.debug)
						else
							self.db.char.FrameHide = false
							self.frame:ClearAllPoints() self.frame:SetPoint("CENTER", UIParent, "CENTER")
						end
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
					spaceline1 = {
						name = "\n",
						type = 'description',
						order = 2,
					},
					spelldmg = {
						hidden = function() return not self.defaults.char.Style.SP[TinyXStats.PlayerRole] end,
						name = STAT_SPELLPOWER,
						desc = STAT_SPELLPOWER.." "..SHOW.."/"..HIDE,
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
						order = 3
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 4,
					},
					ap = {
						hidden = function() return not self.defaults.char.Style.AP[TinyXStats.PlayerRole] end,
						name = STAT_ATTACK_POWER,
						desc = STAT_ATTACK_POWER.." "..SHOW.."/"..HIDE,
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
						order = 3,
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 4,
					},
					crit = {
						hidden = function() return not self.defaults.char.Style.Crit[TinyXStats.PlayerRole] end,
						name = SPELL_CRIT_CHANCE,
						desc = SPELL_CRIT_CHANCE.." "..SHOW.."/"..HIDE,
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
						order = 5
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 6,
					},
					haste = {
						hidden = function() return not self.defaults.char.Style.Haste[TinyXStats.PlayerRole] end,
						name = SPELL_HASTE,
						desc = SPELL_HASTE.." "..SHOW.."/"..HIDE.."\n"..L["(Only rating or percentage display possible!)"],
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
						order = 7
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 8,
					},
					speed = {
						hidden = function() return not self.defaults.char.Style.Speed[TinyXStats.PlayerRole] end,
						name = WEAPON_SPEED,
						desc = WEAPON_SPEED.." "..SHOW.."/"..HIDE,
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
						order = 7,
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 8,
					},
					hasteperc = {
						hidden = function() return not self.defaults.char.Style.Haste[TinyXStats.PlayerRole] end,
						name = L["Percent Haste"],
						desc = L["Percent Haste"].." "..SHOW.."/"..HIDE.."\n"..L["(Only rating or percentage display possible!)"],
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
						order = 9
					},
					hit = {
						hidden = function() return not self.defaults.char.Style.Hit[TinyXStats.PlayerRole] end,
						name = STAT_HIT_CHANCE,
						desc = STAT_HIT_CHANCE.." "..SHOW.."/"..HIDE,
						width = 'double',
						type = 'toggle',
						get = function() return self.db.char.Style.Hit[TinyXStats.PlayerRole] end,
						set = function(info, value)
							if(value) then
								self.db.char.Style.Hit[TinyXStats.PlayerRole] = true
							else
								self.db.char.Style.Hit[TinyXStats.PlayerRole] = false
							end
							self:Stats()
						end,
						disabled = function() return InCombatLockdown() end,
						order = 10
					},
					hitcolor = {
						hidden = function() return not self.defaults.char.Style.Hit[TinyXStats.PlayerRole] end,
						name = "",
						desc = "",
						width = 'half',
						type = 'color',
						get = function()
							local c = self.db.char.Color.hit
							return c.r, c.g, c.b
						end,
						set = function(info, r, g, b)
							local c = self.db.char.Color.hit
							c.r, c.g, c.b = r, g, b
							self:SetStringColors()
							self:Stats()
						end,
						order = 11,
					},
					mastery = {
						hidden = function() return not (self.defaults.char.Style.Mastery[TinyXStats.PlayerRole] and self.Mastery) end,
						name = STAT_MASTERY,
						desc = STAT_MASTERY.." "..SHOW.."/"..HIDE,
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
						order = 12
					},
					masterycolor = {
						hidden = function() return not (self.defaults.char.Style.Mastery[TinyXStats.PlayerRole] and self.Mastery) end,
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 13,
					},
					spirit = {
						hidden = function() return not self.defaults.char.Style.Spirit[TinyXStats.PlayerRole] end,
						name = ITEM_MOD_SPIRIT_SHORT,
						desc = ITEM_MOD_SPIRIT_SHORT.." "..SHOW.."/"..HIDE,
						width = 'double',
						type = 'toggle',
						get = function() return self.db.char.Style.Spirit[TinyXStats.PlayerRole] end,
						set = function(info, value)
							if(value) then
								self.db.char.Style.Spirit[TinyXStats.PlayerRole] = true
							else
								self.db.char.Style.Spirit[TinyXStats.PlayerRole] = false
							end
							self:Stats()
						end,
						disabled = function() return InCombatLockdown() end,
						order = 14
					},
					spiritcolor = {
						hidden = function() return not self.defaults.char.Style.Spirit[TinyXStats.PlayerRole] end,
						name = "",
						desc = "",
						width = 'half',
						type = 'color',
						get = function()
							local c = self.db.char.Color.spirit
							return c.r, c.g, c.b
						end,
						set = function(info, r, g, b)
							local c = self.db.char.Color.spirit
							c.r, c.g, c.b = r, g, b
							self:SetStringColors()
							self:Stats()
						end,
						order = 15,
					},
					mp5 = {
						hidden = function() return not self.defaults.char.Style.Spirit[TinyXStats.PlayerRole] end,
						name = ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["out of combat"],
						desc = ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["out of combat"].." "..SHOW.."/"..HIDE,
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
						order = 16
					},
					mp5color = {
						hidden = function() return not self.defaults.char.Style.Spirit[TinyXStats.PlayerRole] end,
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 17,
					},
					mp5ic = {
						hidden = function() return not self.defaults.char.Style.Spirit[TinyXStats.PlayerRole] end,
						name = ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["in combat"],
						desc = ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["in combat"].." "..SHOW.."/"..HIDE,
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
						order = 18
					},
					mp5auto = {
						hidden = function() return not self.defaults.char.Style.Spirit[TinyXStats.PlayerRole] end,
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
						order = 19
					},
					fr = {
						hidden = function() return not self.defaults.char.Style.Fr[TinyXStats.PlayerRole] end,
						name = STAT_FOCUS_REGEN,
						desc = STAT_FOCUS_REGEN.." "..SHOW.."/"..HIDE,
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
						order = 16,
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 17,
					},
					DC = {
						hidden = function() return not self.defaults.char.Style.DC[TinyXStats.PlayerRole] end,
						name = STAT_DODGE,
						desc = STAT_DODGE.." "..SHOW.."/"..HIDE,
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
						order = 20
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 21,
					},
					PC = {
						hidden = function() return TinyXStats:HideTankStat("PC") end,
						name = STAT_PARRY,
						desc = STAT_PARRY.." "..SHOW.."/"..HIDE,
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
						order = 22
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 23,
					},
					BC = {
						hidden = function() return TinyXStats:HideTankStat("BC") end,
						name = STAT_BLOCK,
						desc = STAT_BLOCK.." "..SHOW.."/"..HIDE,
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
						order = 24
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 25,
					},
					TA = {
						hidden = function() return not self.defaults.char.Style.TA[TinyXStats.PlayerRole] end,
						name = L["Total Avoidance"],
						desc = L["Total Avoidance"].." "..SHOW.."/"..HIDE,
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
						order = 25
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
							self:SetStringColors()
							self:Stats()
						end,
						order = 26,
					},
					header1 = {
						name = "",
						type = 'header',
						order = 30
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
						order = 31
					},
					resetrecords = {
						name = L["Reset records"],
						desc = L["Clears your current records"],
						type = 'execute',
						func = function()
							if IsShiftKeyDown() then
								TinyXStatsDB = {}
							else
								local spec = "Spec"
								if currentBuild  >= 50000 then
									spec = spec..GetActiveSpecGroup()
								else
									spec = spec..GetActiveTalentGroup()
								end
								for stat, num in pairs(self.defaults.char[spec]) do
									--if string.find(stat,"Highest") then
										self.db.char[spec][stat] = num
									--end
								end
								self:Stats()
							end
						end,
						disabled = function() return InCombatLockdown() end,
						order = 32
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
							self:SetStringColors()
							self:Stats()
						end,
						disabled = function() return InCombatLockdown() end,
						order = 33,
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
						order = 1
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
						order = 2
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
						order = 3
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
						order = 4
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
						order = 5
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
							self:SetTextAnchors()
						end,
						disabled = function() return InCombatLockdown() or self.db.char.FrameHide end,
						order = 6
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
						order = 7
					},
					LDBtext = {
						name = L["Broker Text"],
						desc = L["Displays stats in the LDB text field."],
						--width = 'full',
						type = 'toggle',
						get = function() return self.db.char.Style.LDBtext end,
						set = function(info, value)
							if(value) then
								self.db.char.Style.LDBtext = true
							else
								self.db.char.Style.LDBtext = false
							end
							self:SetBroker()
							self:Stats()
						end,
						disabled = function() return InCombatLockdown() end,
						order = 8
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
						order = 9
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
						order = 21
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