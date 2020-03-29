-- TinyXStats @project-version@ by @project-author@
-- Project revision: @project-revision@
--
-- TinyCasterStats.lua:
-- File revision: @file-revision@
-- Last modified: @file-date-iso@
-- Author: @file-author@

local debug = false
--@debug@
debug = true
--@end-debug@

local AddonName = "TinyXStats"
local AceAddon = LibStub("AceAddon-3.0")
local media = LibStub("LibSharedMedia-3.0")
TinyXStats = AceAddon:NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local ldb = LibStub("LibDataBroker-1.1");
local TSBroker = ldb:NewDataObject(AddonName, {
	type = "data source",
	label = AddonName,
	icon = "Interface\\Icons\\Ability_Mage_ArcaneBarrage",
	text = "--"
	})

local isInFight = false
local SpecChangedPause = GetTime()

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "",
	tile = false, tileSize = 16, edgeSize = 0,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local function Debug(...)
	if debug then
		local text = ""
		for i = 1, select("#", ...) do
			if type(select(i, ...)) == "boolean" then
				text = text..(select(i, ...) and "true" or "false").." "
			else
				text = text..(select(i, ...) or "nil").." "
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cFFCCCC99"..AddonName..": |r"..text)
	end
end

TinyXStats.fonts = {}

TinyXStats.defaults = {
	char = {
		Font = "Vera",
		FontEffect = "none",
		Size = 12,
		FrameLocked = true,
		yPosition = 200,
		xPosition = 200,
		inCombatAlpha = 1,
		outOfCombatAlpha = .3,
		RecordMsg = true,
		RecordSound = false,
		RecordSoundFile = "Fanfare3",
		Spec1 = {
			HighestSpelldmg = 0,
			HighestAp = 0,
			HighestCrit = "0.00",
			HighestHaste = 0,
			HighestHastePerc = "0.00",
			FastestMh = 500,
			FastestOh = 500,
			FastestRs = 500,
			HighestMP5if = 0,
			HighestMP5 = 0,
			HighestFr = "0.00",
			HighestMastery = "0.00",
			HighestDC = "0.00",
			HighestPC = "0.00",
			HighestBC = "0.00",
			HighestTA = "0.00",
			HighestVersatility = "0.00"
		},
		Spec2 = {
			HighestSpelldmg = 0,
			HighestAp = 0,
			HighestCrit = "0.00",
			HighestHaste = 0,
			HighestHastePerc = "0.00",
			FastestMh = 500,
			FastestOh = 500,
			FastestRs = 500,
			HighestMP5if = 0,
			HighestMP5 = 0,
			HighestFr = "0.00",
			HighestMastery = "0.00",
			HighestDC = "0.00",
			HighestPC = "0.00",
			HighestBC = "0.00",
			HighestTA = "0.00",
			HighestVersatility = "0.00"
		},
		Style = {
			SP = {
				healer = true,
				caster = true
			},
			AP = {
				melee = true,
				hunter = true,
				tank = true
			},
			Crit = {
				healer = true,
				caster = true,
				melee = true,
				hunter = true,
				tank = true
			},
			Haste = {
				healer = true,
				caster = true,
				melee = true,
				hunter = true,
				tank = true
			},
			HastePerc = {},
			Speed = {
				melee = true,
				hunter = true,
				tank = true
			},
			Mastery = {
				healer = true,
				caster = true,
				melee = true,
				hunter = true,
				tank = true
			},
			Fr = {
				hunter = true
			},
			DC = {
				tank = true
			},
			PC = {
				tank = true
			},
			BC = {
				tank = true
			},
			TA = {
				tank = true
			},
			Versatility = {
				healer = true,
				caster = true,
				melee = true,
				hunter = true,
				tank = true
			},
			MP5 = {
				healer = true,
				caster = true
			},
			MP5ic = {},
			MP5auto = {},
			showRecords = true,
			showRecordsLDB = true,
			vertical = false,
			labels = false
		},
		Color = {
			sp = {
				r = 1.0,
				g = 0.803921568627451,
				b = 0
			},
			ap = {
				r = 1,
				g = 0.803921568627451,
				b = 0
			},
			crit = {
				r = 1.0,
				g = 0,
				b = 0.6549019607843137
			},
			haste = {
				r = 0,
				g = 0.611764705882353,
				b = 1.0
			},
			mp5 = {
				r = 1.0,
				g = 1.0,
				b = 1.0
			},
			mastery = {
				r = 1.0,
				g = 1.0,
				b = 1.0
			},
			fr = {
				r = 0.9,
				g = 0.9,
				b = 0.9
			},
			dc = {
				r = 0.0,
				g = 1.0,
				b = 0.788235294117647
			},
			pc = {
				r = 1.0,
				g = 0.5098039215686274,
				b = 0.0
			},
			bc = {
				r = 0.9098039215686274,
				g = 0.0,
				b = 1.0
			},
			ta = {
				r = 0.6941176470588235,
				g = 1,
				b = 0
			},
			versatility = {
				r = 1,
				g = 0.72156862745098,
				b = 0.0313725490196078
			}
		},
		DBver = 3
	}
}

TinyXStats.frame = CreateFrame("Frame",AddonName.."Frame",UIParent)
TinyXStats.frame:SetWidth(100)
TinyXStats.frame:SetHeight(15)
TinyXStats.frame:SetFrameStrata("BACKGROUND")
TinyXStats.frame:EnableMouse(true)
TinyXStats.frame:RegisterForDrag("LeftButton")

TinyXStats.string = TinyXStats.frame:CreateFontString()

function TinyXStats:SetDragScript()
	if self.db.char.FrameLocked then
		self.frame:SetMovable(false)
		fixed = "|cffFF0000"..L["Text is fixed. Uncheck Lock Frame in the options to move!"].."|r"
		self.frame:SetScript("OnDragStart", function() DEFAULT_CHAT_FRAME:AddMessage(fixed) end)
		self.frame:SetScript("OnEnter", nil)
		self.frame:SetScript("OnLeave", nil)
	else
		self.frame:SetMovable(true)
		self.frame:SetScript("OnDragStart", function() self.frame:StartMoving() end)
		self.frame:SetScript("OnDragStop", function() self.frame:StopMovingOrSizing() self.db.char.xPosition = self.frame:GetLeft() self.db.char.yPosition = self.frame:GetBottom() end)
		self.frame:SetScript("OnEnter", function() self.frame:SetBackdrop(backdrop) end)
		self.frame:SetScript("OnLeave", function() self.frame:SetBackdrop(nil) end)
	end
end

function TinyXStats:SetFrameVisible()

	if self.db.char.FrameHide then
		self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -1000, -1000)
	else
		self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.char.xPosition, self.db.char.yPosition)
	end

end

function TinyXStats:InitializeFrame()
	local font = media:Fetch("font", self.db.char.Font)
	self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.char.xPosition, self.db.char.yPosition)
	self.string:SetPoint("TOPLEFT", self.frame,"TOPLEFT", 0, 0)
	self.string:SetFontObject(GameFontNormal)
	if not self.string:SetFont(font, self.db.char.Size, self.db.char.FontEffect) then
		self.string:SetFont("Fonts\\FRIZQT__.TTF", self.db.char.Size, self.db.char.FontEffect)
	end
	self.string:SetJustifyH("LEFT")
	self.string:SetJustifyV("MIDDLE")

	self:SetDragScript()
	self:SetFrameVisible()
	self:Stats()
end

function TinyXStats:OnInitialize()
	local AceConfigReg = LibStub("AceConfigRegistry-3.0")
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")

	self.db = LibStub("AceDB-3.0"):New(AddonName.."DB", TinyXStats.defaults, "char")
	LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, self:Options(), "tscmd")
	media.RegisterCallback(self, "LibSharedMedia_Registered")

	self:RegisterChatCommand("txs", function() AceConfigDialog:Open(AddonName) end)
	self:RegisterChatCommand(AddonName, function() AceConfigDialog:Open(AddonName) end)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions(AddonName, AddonName)
	self.db:RegisterDefaults(self.defaults)

	local version = GetAddOnMetadata(AddonName,"Version")
	local loaded = L["Open the configuration menu with /txs or /TinyXStats"].."|r"
	DEFAULT_CHAT_FRAME:AddMessage("|cffffd700"..AddonName.." |cff00ff00~v"..version.."~|cffffd700: "..loaded)

	TSBroker.OnClick = function(frame, button)	AceConfigDialog:Open(AddonName)	end
	TSBroker.OnTooltipShow = function(tt) tt:AddLine(AddonName) end

end

function TinyXStats:OnEnable()
	self:LibSharedMedia_Registered()
	self:InitializeFrame()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("UNIT_AURA", "OnEvent")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "OnEvent")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "OnEvent")
	self:RegisterEvent("UNIT_LEVEL", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "OnEvent")
end

function TinyXStats:LibSharedMedia_Registered()
	media:Register("font", "BaarSophia", [[Interface\Addons\TinyXStats\Fonts\BaarSophia.ttf]])
	media:Register("font", "LucidaSD", [[Interface\Addons\TinyXStats\Fonts\LucidaSD.ttf]])
	media:Register("font", "Teen", [[Interface\Addons\TinyXStats\Fonts\Teen.ttf]])
	media:Register("font", "Vera", [[Interface\Addons\TinyXStats\Fonts\Vera.ttf]])
	media:Register("sound", "Fanfare1", [[Interface\Addons\TinyXStats\Sound\Fanfare.ogg]])
	media:Register("sound", "Fanfare2", [[Interface\Addons\TinyXStats\Sound\Fanfare2.ogg]])
	media:Register("sound", "Fanfare3", [[Interface\Addons\TinyXStats\Sound\Fanfare3.ogg]])

	for k, v in pairs(media:List("font")) do
		self.fonts[v] = v
	end
end

local orgSetActiveSpecGroup = SetActiveSpecGroup;
function SetActiveSpecGroup(...)
	SpecChangedPause = GetTime() + 60
	TinyXStats:ScheduleTimer("Stats", 62)
	Debug("Set SpecChangedPause")
	return orgSetActiveSpecGroup(...)
end

function TinyXStats:OnEvent(event, arg1)
	Debug(event,arg1)
	if ((event == "PLAYER_TALENT_UPDATE") or (event == "PLAYER_ENTERING_WORLD")) then
		self:ScheduleTimer("GetUnitRole", 3)
	end
	if ((event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_ENTERING_WORLD")) then
		self.frame:SetAlpha(self.db.char.outOfCombatAlpha)
		isInFight = false
	end
	if (event == "PLAYER_REGEN_DISABLED") then
		self.frame:SetAlpha(self.db.char.inCombatAlpha)
		isInFight = true
	end
	if (event == "UNIT_AURA" and arg1 == "player") then
		self:ScheduleTimer("Stats", .8)
	end
	if (event ~= "UNIT_AURA") then
		self:Stats()
	end

end

local function HexColor(stat)

	local c = TinyXStats.db.char.Color[stat]
	local hexColor = string.format("|cff%2X%2X%2X", 255*c.r, 255*c.g, 255*c.b)
	return hexColor

end

local function MsgRecord(name,value)
	if (TinyXStats.db.char.RecordMsg == true) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["Record broken!"]..": "..name..": |c00ffef00"..value.."|r")
		return true
	end
end

local function SetRecordLabel(label)
	if not TinyXStats.db.char.Style.labels or TinyXStats.db.char.Style.vertical then
		label = ""
	end
	return label
end

local function SetLabel(color,label)
	local style = TinyXStats.db.char.Style
	TinyXStats.CString = TinyXStats.CString..HexColor(color)..(style.labels and label or "")
	TinyXStats.RString = TinyXStats.RString..HexColor(color)..SetRecordLabel(label)
	TinyXStats.ldbString = TinyXStats.ldbString..HexColor(color)..(style.labels and label or "")
	TinyXStats.ldbRecord = TinyXStats.ldbRecord..HexColor(color)..(style.labels and label or "")
end

local function SetValues(Value,Highest)
	TinyXStats.CString = TinyXStats.CString..Value
	TinyXStats.RString = TinyXStats.RString..Highest
	TinyXStats.ldbString = TinyXStats.ldbString..Value.." "
	TinyXStats.ldbRecord = TinyXStats.ldbRecord..Highest.." "
end

local function FormatRString()
	if TinyXStats.db.char.Style.vertical then
		if TinyXStats.db.char.Style.showRecords then
			TinyXStats.CString = TinyXStats.CString.." ("..TinyXStats.RString..")|n"
			TinyXStats.RString = ""
		else
			TinyXStats.CString = TinyXStats.CString.."|n"
			TinyXStats.RString = ""
		end
	else
		TinyXStats.CString = TinyXStats.CString.." "
		TinyXStats.RString = TinyXStats.RString.." "
	end
end

function TinyXStats:HideTankStat(Stat)
	if TinyXStats.defaults.char.Style[Stat][TinyXStats.PlayerRole] then
		if TinyXStats.class ~= "WARRIOR" and TinyXStats.class ~= "PALADIN" then
			if Stat == "BC" then
				return true
			elseif Stat == "PC" and TinyXStats.class == "DRUID" then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return true
	end
end

local function GetAttackPower()
	local base, buff, debuff
	if TinyXStats.PlayerRole == "hunter" then
		base, buff, debuff = UnitRangedAttackPower("player")
	else
		base, buff, debuff = UnitAttackPower("player")
	end
	local pow = base + buff + debuff
	return pow
end

local function GetSpellDamage()
	local spelldamage = 0
	for i = 2, 7, 1 do -- Start at 2 to skip physical damage , MAX_SPELL_SCHOOLS
		if (spelldamage < GetSpellBonusDamage(i)) then
			spelldamage = GetSpellBonusDamage(i)
		end
	end
	if (spelldamage < GetSpellBonusHealing()) then
		spelldamage = GetSpellBonusHealing()
	end
	return spelldamage
end

local function GetCrit()
	local critchance = 0
	if TinyXStats.PlayerRole == "healer" or TinyXStats.PlayerRole == "caster" then
		for i = 2, 7, 1 do
			if (critchance < GetSpellCritChance(i)) then
				critchance = GetSpellCritChance(i)
			end
		end
	else
		critchance = GetCritChance("player")
	end
	return critchance
end

local function GetHaste()
	-- berechnet den Faktor Tempo/prozent ~128,05 bei lvl 85
	local CR = GetCombatRating(CR_HASTE_SPELL)
	local CRB = GetCombatRatingBonus(CR_HASTE_SPELL)
	local FaktorHastePercent = 0

	if (CRB and CRB > 0 and CR and CR > 0) then--  Division by zero fix ?
		FaktorHastePercent = CR/CRB
	end

	local hasteperc = UnitSpellHaste("player")
	local haste = hasteperc * FaktorHastePercent

	return string.format("%.0f",haste), string.format("%.2f",hasteperc)
end

local function GetWeaponSpeed(spec)
	local speed, fastestSpeed = 500, 500
	local mainSpeed, offSpeed = UnitAttackSpeed("player")
	if (offSpeed == nil) then
		if (mainSpeed > 0) then
			mainSpeed = string.format("%.2f", mainSpeed)
			speed = mainSpeed
			fastestSpeed = TinyXStats.db.char[spec].FastestMh
		else
			speed = 500
			mainSpeed = 500
		end
	else
		if (mainSpeed > 0) then
			mainSpeed = string.format("%.2f", mainSpeed)
			offSpeed = string.format("%.2f", offSpeed)
			speed = mainSpeed.."s "..offSpeed
		else
			speed = 500
			mainSpeed = 500
			offSpeed = nil
			fastestSpeed = 500
		end
		fastestSpeed = TinyXStats.db.char[spec].FastestMh.."s "..TinyXStats.db.char[spec].FastestOh
	end
	return mainSpeed, offSpeed, speed, fastestSpeed
end

local function GetRangedSpeed(spec)

	local fastestSpeed = TinyXStats.db.char[spec].FastestRs

	if IsRangedWeapon() then
		local speed = UnitRangedDamage("player")
		if speed > 0.00 then
			return string.format("%.2f",speed ),fastestSpeed
		else
			return 500, fastestSpeed
		end
	else
		return NOT_APPLICABLE, fastestSpeed
	end

end

local function GetDefense()
	local missChance = select(2, UnitRace("player")) == "NightElf" and 7 or 5
	local PlayerLevel = UnitLevel("player");
	local BossLevel   = UnitLevel("player");
	local defenseDiff = (BossLevel - PlayerLevel) * 0.20 -- bei 85-85 * 0.20 = 0
	local missChance = max(0, missChance - defenseDiff)
	local dodgeChance = max(0, GetDodgeChance() - defenseDiff)
	local parryChance = max(0, GetParryChance() - defenseDiff)
	local blockChance = max(0, GetBlockChance() - defenseDiff)
	local TAvoidance  = missChance + dodgeChance + parryChance + blockChance
	return string.format("%.2f", TAvoidance), string.format("%.2f", dodgeChance), string.format("%.2f", parryChance), string.format("%.2f", blockChance)
end

local function GetMastery()
	local mastery
	if (UnitLevel("player") >= SHOW_MASTERY_LEVEL) then
		mastery = GetMasteryEffect();
		mastery = format("%.2f", mastery);
	end
	return mastery
end

function TinyXStats:GetUnitRole()
	self.class = select(2, UnitClass("player"))
	local role
	local Talent = GetSpecialization()
	if Talent then
		role = GetSpecializationRole(Talent, false, false);
	end
	if not role then
		if self.class == "HUNTER" then
			role = "hunter"
		elseif GetAttackPower() > GetSpellDamage() then
			role = "melee"
		else
			role = "caster"
		end
	else
		if role == "HEALER" then
			role = "healer"
		elseif role == "TANK" then
			role = "tank"
		elseif role == "DAMAGER" then
			if self.class == "HUNTER" then
				role = "hunter"
			elseif (self.class == "MAGE" or self.class == "WARLOCK" or self.class == "PRIEST") then
				role = "caster"
			elseif (self.class == "SHAMAN" and Talent == 1) then
				role = "caster"
			elseif (self.class == "DRUID" and Talent == 1) then
				role = "caster"
			else
				role = "melee"
			end
		end
	end
	if (not self.PlayerRole or self.PlayerRole ~= role) then
		self.PlayerRole = role
		self:Stats()
	end

	Debug("you are:", role)
	return role
end

function TinyXStats:Stats()
	Debug("Stats()")
	local style = self.db.char.Style
	local mastery = GetMastery()
	local versatility = string.format("%.2f",GetCombatRating(29)/130)
	local spec = "Spec"..GetActiveSpecGroup()
	local spelldmg = GetSpellDamage()
	local pow = GetAttackPower()
	local crit = string.format("%.2f",GetCrit())
	local haste, hasteperc = GetHaste()
	local mainSpeed, offSpeed, speed, fastestSpeed = 500, nil, 500, 500
	if style.Speed[self.PlayerRole] then
		if self.PlayerRole == "hunter" then
			speed, fastestSpeed = GetRangedSpeed(spec)
		else
			mainSpeed, offSpeed, speed, fastestSpeed = GetWeaponSpeed(spec)
		end
	end
	local base, casting = GetManaRegen()
	base = floor(base * 5.0)
	casting = floor(casting * 5.0)
	local fr = string.format("%.2f", GetPowerRegen() or 0)
	local DodgeChance,BlockChance,ParryChance,TAavoidance = 0,0,0,0
	if self.PlayerRole == "tank" then
		TAvoidance,DodgeChance,ParryChance,BlockChance = GetDefense()
	end

	local recordIsBroken = false

	if SpecChangedPause <= GetTime() then
		if (style.SP[self.PlayerRole] and tonumber(spelldmg) > tonumber(self.db.char[spec].HighestSpelldmg)) then
			self.db.char[spec].HighestSpelldmg = spelldmg
			recordIsBroken = MsgRecord(STAT_SPELLPOWER,spelldmg) or recordIsBroken
		end
		if (style.AP[self.PlayerRole] and tonumber(pow) > tonumber(self.db.char[spec].HighestAp)) then
			self.db.char[spec].HighestAp = pow
			recordIsBroken = MsgRecord(STAT_ATTACK_POWER,pow) or recordIsBroken
		end
		if (style.Haste[self.PlayerRole] or style.HastePerc[self.PlayerRole]) then
			if (tonumber(haste) > tonumber(self.db.char[spec].HighestHaste) or tonumber(hasteperc) > tonumber(self.db.char[spec].HighestHastePerc)) then
				self.db.char[spec].HighestHaste = haste
				self.db.char[spec].HighestHastePerc = hasteperc
				recordIsBroken = MsgRecord(SPELL_HASTE,haste) or recordIsBroken
				recordIsBroken = MsgRecord(L["Percent Haste"],hasteperc) or recordIsBroken
			end
		end
		if (style.Speed[self.PlayerRole]) then
			if self.PlayerRole == "hunter" then
				if (tonumber(speed) and (tonumber(speed) < tonumber(self.db.char[spec].FastestRs))) then
					self.db.char[spec].FastestRs = speed
					recordIsBroken = MsgRecord(STAT_ATTACK_SPEED,speed) or recordIsBroken
					fastestSpeed = self.db.char[spec].FastestRs
				end
			else
				if (tonumber(mainSpeed) < tonumber(self.db.char[spec].FastestMh)) then
					self.db.char[spec].FastestMh = mainSpeed
					recordIsBroken = MsgRecord(WEAPON_SPEED..(offSpeed and " (MainHand)" or ""),mainSpeed) or recordIsBroken
					fastestSpeed = self.db.char[spec].FastestMh
				end
				if (offSpeed and (tonumber(offSpeed) < tonumber(self.db.char[spec].FastestOh))) then
					self.db.char[spec].FastestOh = offSpeed
					recordIsBroken = MsgRecord(WEAPON_SPEED.." (OffHand)",offSpeed) or recordIsBroken
					fastestSpeed = self.db.char[spec].FastestMh.."s "..self.db.char[spec].FastestOh
				end
			end
		end
		if (style.Crit[self.PlayerRole] and tonumber(crit) > tonumber(self.db.char[spec].HighestCrit)) then
			self.db.char[spec].HighestCrit = crit
			recordIsBroken = MsgRecord(SPELL_CRIT_CHANCE,crit) or recordIsBroken
		end
		if (style.Mastery[self.PlayerRole] and mastery) and (tonumber(mastery) > tonumber(self.db.char[spec].HighestMastery)) then
			self.db.char[spec].HighestMastery = mastery
			recordIsBroken = MsgRecord(STAT_MASTERY,mastery) or recordIsBroken
		end
		if (style.MP5[self.PlayerRole] or style.MP5ic[self.PlayerRole] or style.MP5auto[self.PlayerRole]) then
			if (tonumber(base) > tonumber(self.db.char[spec].HighestMP5)) then
				self.db.char[spec].HighestMP5 = base
				recordIsBroken = MsgRecord(ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["out of combat"],base) or recordIsBroken
			end
			if (tonumber(casting) > tonumber(self.db.char[spec].HighestMP5if)) then
				self.db.char[spec].HighestMP5if = casting
				recordIsBroken = MsgRecord(ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["in combat"],casting) or recordIsBroken
			end
		end
		if (style.Fr[self.PlayerRole] and tonumber(fr) > tonumber(self.db.char[spec].HighestFr)) then
			self.db.char[spec].HighestFr = fr
			recordIsBroken = MsgRecord(STAT_FOCUS_REGEN,fr) or recordIsBroken
		end
		if (style.DC[self.PlayerRole] and tonumber(DodgeChance) > tonumber(self.db.char[spec].HighestDC)) then
			self.db.char[spec].HighestDC = DodgeChance
			recordIsBroken = MsgRecord(STAT_DODGE,DodgeChance) or recordIsBroken
		end
		if (style.PC[self.PlayerRole] and not TinyXStats:HideTankStat("PC")) and tonumber(ParryChance) > tonumber(self.db.char[spec].HighestPC) then
			self.db.char[spec].HighestPC = ParryChance
			recordIsBroken = MsgRecord(STAT_PARRY,ParryChance) or recordIsBroken
		end
		if (style.BC[self.PlayerRole] and not TinyXStats:HideTankStat("BC")) and tonumber(BlockChance) > tonumber(self.db.char[spec].HighestBC) then
			self.db.char[spec].HighestBC = BlockChance
			recordIsBroken = MsgRecord(STAT_BLOCK,BlockChance) or recordIsBroken
		end
		if (style.TA[self.PlayerRole] and tonumber(TAvoidance) > tonumber(self.db.char[spec].HighestTA)) then
			self.db.char[spec].HighestTA = TAvoidance
			recordIsBroken = MsgRecord(L["Total Avoidance"],TAvoidance) or recordIsBroken
		end
		if (style.Versatility[self.PlayerRole] and tonumber(versatility) > tonumber(self.db.char[spec].HighestVersatility)) then
			self.db.char[spec].HighestVersatility = versatility
			recordIsBroken = MsgRecord(STAT_VERSATILITY,versatility) or recordIsBroken
		end
	else
		Debug("rekords skipped SpecChangedPause")
	end

	if ((recordIsBroken == true) and (self.db.char.RecordSound == true)) then
		PlaySoundFile(media:Fetch("sound", self.db.char.RecordSoundFile),"Master")
	end

	self.ldbString = ""
	self.ldbRecord = ""
	self.CString = ""
	self.RString = ""

	if (style.SP[self.PlayerRole]) then
		SetLabel("sp",L["Sp:"])
		SetValues(spelldmg,self.db.char[spec].HighestSpelldmg)
		FormatRString()
	end
	if (style.AP[self.PlayerRole]) then
		SetLabel("ap",L["Ap:"])
		SetValues(pow,self.db.char[spec].HighestAp)
		FormatRString()
	end
	if (style.Haste[self.PlayerRole]) then
		SetLabel("haste",L["Haste:"])
		SetValues(haste,self.db.char[spec].HighestHaste)
		FormatRString()
	elseif (style.HastePerc[self.PlayerRole]) then
		SetLabel("haste",SPELL_HASTE_ABBR..":")
		SetValues(hasteperc.."%",self.db.char[spec].HighestHastePerc.."%")
		FormatRString()
	elseif (style.Speed[self.PlayerRole]) then
		SetLabel("haste",L["Speed:"])
		SetValues(speed.."s",fastestSpeed.."s")
		FormatRString()
	end
	if (style.MP5[self.PlayerRole]) then
		SetLabel("mp5",L["MP5:"])
		SetValues(base.."mp5",self.db.char[spec].HighestMP5.."mp5")
		FormatRString()
	end
	if (style.MP5ic[self.PlayerRole]) then
		SetLabel("mp5",L["MP5-ic:"])
		SetValues(casting.."mp5",self.db.char[spec].HighestMP5if.."mp5")
		FormatRString()
	end
	if (style.MP5auto[self.PlayerRole]) then
		SetLabel("mp5",L["MP5:"])
		if (isInFight) then
			SetValues(casting.."mp5",self.db.char[spec].HighestMP5if.."mp5")
		else
			SetValues(base.."mp5",self.RString..self.db.char[spec].HighestMP5.."mp5")
		end
		FormatRString()
	end
	if (style.Fr[self.PlayerRole]) then
		SetLabel("fr",L["FR:"])
		SetValues(fr,self.db.char[spec].HighestFr)
		FormatRString()
	end
	if (style.Crit[self.PlayerRole]) then
		SetLabel("crit",L["Crit:"])
		SetValues(crit.."%",self.db.char[spec].HighestCrit.."%")
		FormatRString()
	end
	if (style.Mastery[self.PlayerRole] and mastery) then
		SetLabel("mastery",L["Mas:"])
		SetValues(mastery.."%",self.db.char[spec].HighestMastery.."%")
		FormatRString()
	end
	if (style.DC[self.PlayerRole]) then
		SetLabel("dc",L["DC:"])
		SetValues(DodgeChance.."%",self.db.char[spec].HighestDC.."%")
		FormatRString()
	end
	if (style.PC[self.PlayerRole] and not TinyXStats:HideTankStat("PC")) then
		SetLabel("pc",L["PC:"])
		SetValues(ParryChance.."%",self.db.char[spec].HighestPC.."%")
		FormatRString()
	end
	if (style.BC[self.PlayerRole] and not TinyXStats:HideTankStat("BC")) then
		SetLabel("bc",L["BC:"])
		SetValues(BlockChance.."%",self.db.char[spec].HighestBC.."%")
		FormatRString()
	end
	if (style.TA[self.PlayerRole]) then
		SetLabel("ta",L["TA:"])
		SetValues(TAvoidance.."%",self.db.char[spec].HighestTA.."%")
		FormatRString()
	end
	if (style.Versatility[self.PlayerRole]) then
		SetLabel("versatility",L["Vers:"])
		SetValues(versatility.."%",self.db.char[spec].HighestVersatility.."%")
		FormatRString()
	end

	if style.showRecords then
		if not style.vertical then
			self.CString = self.CString.."|n"..self.RString
		end
	end

	if style.showRecordsLDB then
		self.ldbString = self.ldbString.."|n"..self.ldbRecord
	end

	self.string:SetText(self.CString)

	TSBroker.text = self.ldbString.."|r"
	
end
