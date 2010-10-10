--
-- File version: @file-revision@
-- Project: @project-revision@
--

if not TinyStats then return end

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("TinyStats")
local media = LibStub:GetLibrary("LibSharedMedia-3.0")

TinyStats.fonteffects = {
	["none"] = L["NONE"],
	["OUTLINE"] = L["OUTLINE"],
	["THICKOUTLINE"] = L["THICKOUTLINE"],
}

function TinyStats:Options()
	local options = {
		name = "TinyStats",
	    handler = TinyStats,
	    type = 'group',
	    args = {
			reset = {
				name = L["Reset position"],
				desc = L["Resets the frame's position"],
				type = "execute",
				func = function() tsframe:ClearAllPoints()	tsframe:SetPoint("CENTER", UIParent, "CENTER") end,
				disabled = function() return InCombatLockdown() end,
				order = 1,
			},
			lock = {
				name = L["Lock Frame"],
				desc = L["Locks the position of the text frame"],
				type = 'toggle',
				get = function() return self.db.char.FrameLocked end,
				set = function(info, value)				
					if(value) then
						self.db.char.FrameLocked = true
						tsframe:SetMovable(false)
						fixed = "|cffFF0000"..L["Text is fixed. Uncheck Lock Frame in the options to move!"].."|r"
						tsframe:SetScript("OnDragStart", function() DEFAULT_CHAT_FRAME:AddMessage(fixed) end)
					else
						self.db.char.FrameLocked = false
						tsframe:SetMovable(true)
						tsframe:SetScript("OnDragStart", function() tsframe:StartMoving() end)
						tsframe:SetScript("OnDragStop", function() tsframe:StopMovingOrSizing() self.db.char.xPosition = tsframe:GetLeft() self.db.char.yPosition = tsframe:GetBottom() end)
					end
				end,
				disabled = function() return InCombatLockdown() end,
				order = 2,
			},
			record = {
				name = L["Show new records"],
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
				order = 3,
			},
			text = {
				name = L["Text"],
				desc = L["Text settings"],
				type = 'group',
				order = 1,
				args = {			
					hader = {
						name = L["Text settings"],
						type = 'header',
						order = 1,
					},
					spaceline1 = {
						name = "\n",
						type = 'description',
						order = 2,
					},
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
							tsframe:SetAlpha(self.db.char.outOfCombatAlpha)
						end,
						disabled = function() return InCombatLockdown() end,
						order = 3,
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
							tsframe:SetAlpha(self.db.char.inCombatAlpha)
						end,
						disabled = function() return InCombatLockdown() end,
						order = 4,
					},
					font = {
						name = L["Font"],
						type = 'select',
						get = function() return self.db.char.Font end,
						set = function(info, newValue)
							self.db.char.Font = newValue
							local font = media:Fetch("font", self.db.char.Font)
							tsstring:SetFont(font, self.db.char.Size, self.db.char.FontEffect)
						end,
						values = self.fonts,
						order = 5,
					},
					spaceline2 = {
						name = "",
						type = 'description',
						order = 6,
					},
					fonteffect = {
						name = L["Font border"],
						type = 'select',
						get = function() return self.db.char.FontEffect end,
						set = function(info, newValue)
							self.db.char.FontEffect = newValue
							local font = media:Fetch("font", self.db.char.Font)
							tsstring:SetFont(font, self.db.char.Size, self.db.char.FontEffect)
						end,
						values = self.fonteffects,
						order = 7,
					},
					barfontsize = {
						name = L["Font size"],
						width = 'full',
						type = 'range',
						min = 6,
						max = 32,
						step = 1,
						get = function() return self.db.char.Size end,
						set = function(info, newValue)
							self.db.char.Size = newValue
							local font = media:Fetch("font", self.db.char.Font)
							tsstring:SetFont(font, self.db.char.Size, self.db.char.FontEffect)
						end,
						order = 8,
					},
				},
			},
			style = {
				name = L["Stats"],
				desc = L["Select which stats to show"],
				type = 'group',
				order = 2,
				args = {
					hader = {
						name = L["Stats"],
						type = 'header',
						order = 1,
					},
					spaceline3 = {
						name = "\n",
						type = 'description',
						order = 2,
					},
--					fill in
--					stats here
					spaceline4 = {
						name = "\n",
						type = 'description',
						order = 99,
					},
					resetrecords = {
						name = L["Reset records"],
						desc = L["Clears your current records"],
						type = 'execute',
						func = function()
							self.db.char.HighestSpelldmg = 0
							self.db.char.HighestSpellCrit = 0
							self.db.char.HighestHaste = 0
							self.db.char.HighestHastePerc = 0
							self.db.char.HighestSpellHit = 0
							self.db.char.HighestMP5if = 0
							self.db.char.HighestMP5 = 0
							self.db.char.HighestAp = 0
							self.db.char.HighestMeleeCrit = 0
							self.db.char.FastestMh = 500
							self.db.char.FastestOh = 500
							self.db.char.HighestMeleeHit = 0
							self:Stats()
						end,
						disabled = function() return InCombatLockdown() end,
						order = 100,
					},
				},
			},
		},
	}
	return options
end