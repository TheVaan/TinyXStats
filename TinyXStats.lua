--   ----------------------------------------
--  |    TinyXStats by TheVaan and Marhu_    |
--  | based on TMS and TCS - for all classes |
--   ----------------------------------------
--
-- File version: @file-revision@
-- Project: @project-revision@
--
local AddonName = "TinyXStats"
local AceAddon = LibStub("AceAddon-3.0")
local media = LibStub:GetLibrary("LibSharedMedia-3.0")
TinyXStats = AceAddon:NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(AddonName)
local LGT --= LibStub:GetLibrary("LibGroupTalents-1.0");

local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local TSBroker = ldb:NewDataObject(AddonName, {
	type = "data source",
	label = AddonName,
	icon = "Interface\\Icons\\Ability_Mage_ArcaneBarrage",
	text = "--"
	})

local isInFight = false
local SpecChangedPause = GetTime()
local MasteryName = GetSpellInfo(86474)
local currentBuild = select(4, GetBuildInfo())
if currentBuild  < 50000 then
	LGT = LibStub:GetLibrary("LibGroupTalents-1.0");
end

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "",
	tile = false, tileSize = 16, edgeSize = 0,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local function Debug(...)
	if TinyXStats.db.profile.debug then
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
			HighestHit = "0.00",
			HighestMP5if = 0,
			HighestMP5 = 0,
			HighestSpirit = 0,
			HighestFr = "0.00",
			HighestMastery = "0.00",
			HighestDC = "0.00",
			HighestPC = "0.00",
			HighestBC = "0.00",
			HighestTA = "0.00"
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
			HighestHit = "0.00",
			HighestMP5if = 0,
			HighestMP5 = 0,
			HighestSpirit = 0,
			HighestFr = "0.00",
			HighestMastery = "0.00",
			HighestDC = "0.00",
			HighestPC = "0.00",
			HighestBC = "0.00",
			HighestTA = "0.00"
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
				caster = true
			},
			HastePerc = {},
			Speed = {
				melee = true,
				hunter = true,
				tank = true
			},
			Hit = {
				caster = true,
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
			Spirit = {
				healer = true,
				caster = true
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
			MP5 = {},
			MP5ic = {},
			MP5auto = {},
			showRecords = true,
			vertical = false,
			labels = false,
			LDBtext = true
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
			hit = {
				r = 0.07058823529411765,
				g = 0.7686274509803921,
				b = 0
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
			spirit = {
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
			}
		},
	}
}

TinyXStats.frame = CreateFrame("Frame",AddonName.."Frame",UIParent)
TinyXStats.frame:SetWidth(100)
TinyXStats.frame:SetHeight(15)
TinyXStats.frame:SetFrameStrata("BACKGROUND")
TinyXStats.frame:EnableMouse(true)
TinyXStats.frame:RegisterForDrag("LeftButton")

TinyXStats.strings = {
	spString = TinyXStats.frame:CreateFontString(),
	apString = TinyXStats.frame:CreateFontString(),
	hasteString = TinyXStats.frame:CreateFontString(),
	hitString = TinyXStats.frame:CreateFontString(),
	critString = TinyXStats.frame:CreateFontString(),
	masteryString = TinyXStats.frame:CreateFontString(),
	spiritString = TinyXStats.frame:CreateFontString(),
	mp5String = TinyXStats.frame:CreateFontString(),
	dcString = TinyXStats.frame:CreateFontString(),
	bcString = TinyXStats.frame:CreateFontString(),
	pcString = TinyXStats.frame:CreateFontString(),
	taString = TinyXStats.frame:CreateFontString(),
	
	spRecordString = TinyXStats.frame:CreateFontString(),
	apRecordString = TinyXStats.frame:CreateFontString(),
	hasteRecordString = TinyXStats.frame:CreateFontString(),
	hitRecordString = TinyXStats.frame:CreateFontString(),
	critRecordString = TinyXStats.frame:CreateFontString(),
	masteryRecordString = TinyXStats.frame:CreateFontString(),
	spiritRecordString = TinyXStats.frame:CreateFontString(),
	mp5RecordString = TinyXStats.frame:CreateFontString(),
	dcRecordString = TinyXStats.frame:CreateFontString(),
	bcRecordString = TinyXStats.frame:CreateFontString(),
	pcRecordString = TinyXStats.frame:CreateFontString(),
	taRecordString = TinyXStats.frame:CreateFontString()
}

function TinyXStats:SetStringColors()
	local c = self.db.char.Color
	self.strings.spString:SetTextColor(c.sp.r, c.sp.g, c.sp.b, 1.0)
	self.strings.apString:SetTextColor(c.ap.r, c.ap.g, c.ap.b, 1.0)
	self.strings.critString:SetTextColor(c.crit.r, c.crit.g, c.crit.b, 1.0)
	self.strings.hasteString:SetTextColor(c.haste.r, c.haste.g, c.haste.b, 1.0)
	self.strings.hitString:SetTextColor(c.hit.r, c.hit.g, c.hit.b, 1.0)
	self.strings.masteryString:SetTextColor(c.mastery.r, c.mastery.g, c.mastery.b, 1.0)
	self.strings.spiritString:SetTextColor(c.spirit.r, c.spirit.g, c.spirit.b, 1.0)
	self.strings.mp5String:SetTextColor(c.mp5.r, c.mp5.g, c.mp5.b, 1.0)
	self.strings.dcString:SetTextColor(c.dc.r, c.dc.g, c.dc.b, 1.0)
	self.strings.bcString:SetTextColor(c.bc.r, c.bc.g, c.bc.b, 1.0)
	self.strings.pcString:SetTextColor(c.pc.r, c.pc.g, c.pc.b, 1.0)
	self.strings.taString:SetTextColor(c.ta.r, c.ta.g, c.ta.b, 1.0)

	self.strings.spRecordString:SetTextColor(c.sp.r, c.sp.g, c.sp.b, 1.0)
	self.strings.apRecordString:SetTextColor(c.ap.r, c.ap.g, c.ap.b, 1.0)
	self.strings.critRecordString:SetTextColor(c.crit.r, c.crit.g, c.crit.b, 1.0)
	self.strings.hasteRecordString:SetTextColor(c.haste.r, c.haste.g, c.haste.b, 1.0)
	self.strings.hitRecordString:SetTextColor(c.hit.r, c.hit.g, c.hit.b, 1.0)
	self.strings.masteryRecordString:SetTextColor(c.mastery.r, c.mastery.g, c.mastery.b, 1.0)
	self.strings.spiritRecordString:SetTextColor(c.spirit.r, c.spirit.g, c.spirit.b, 1.0)
	self.strings.mp5RecordString:SetTextColor(c.mp5.r, c.mp5.g, c.mp5.b, 1.0)
	self.strings.dcRecordString:SetTextColor(c.dc.r, c.dc.g, c.dc.b, 1.0)
	self.strings.bcRecordString:SetTextColor(c.bc.r, c.bc.g, c.bc.b, 1.0)
	self.strings.pcRecordString:SetTextColor(c.pc.r, c.pc.g, c.pc.b, 1.0)
	self.strings.taRecordString:SetTextColor(c.ta.r, c.ta.g, c.ta.b, 1.0)
end

function TinyXStats:SetTextAnchors()
	local offsetX, offsetY = 0, 0
	if (not self.db.char.Style.vertical) then
		self.strings.spString:SetPoint("TOPLEFT", self.frame,"TOPLEFT", offsetX, offsetY)
		self.strings.apString:SetPoint("TOPLEFT", self.strings.spString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hasteString:SetPoint("TOPLEFT", self.strings.apString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hitString:SetPoint("TOPLEFT", self.strings.hasteString, "TOPRIGHT", offsetX, offsetY)
		self.strings.critString:SetPoint("TOPLEFT", self.strings.hitString, "TOPRIGHT", offsetX, offsetY)
		self.strings.masteryString:SetPoint("TOPLEFT", self.strings.critString, "TOPRIGHT", offsetX, offsetY)
		self.strings.spiritString:SetPoint("TOPLEFT", self.strings.masteryString, "TOPRIGHT", offsetX, offsetY)
		self.strings.mp5String:SetPoint("TOPLEFT", self.strings.spiritString, "TOPRIGHT", offsetX, offsetY)
		self.strings.dcString:SetPoint("TOPLEFT", self.strings.mp5String, "TOPRIGHT", offsetX, offsetY)
		self.strings.pcString:SetPoint("TOPLEFT", self.strings.dcString, "TOPRIGHT", offsetX, offsetY)
		self.strings.bcString:SetPoint("TOPLEFT", self.strings.pcString, "TOPRIGHT", offsetX, offsetY)
		self.strings.taString:SetPoint("TOPLEFT", self.strings.bcString, "TOPRIGHT", offsetX, offsetY)

		self.strings.spRecordString:SetPoint("TOPLEFT", self.strings.spString, "BOTTOMLEFT")
		self.strings.apRecordString:SetPoint("TOPLEFT", self.strings.spRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hasteRecordString:SetPoint("TOPLEFT", self.strings.apRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hitRecordString:SetPoint("TOPLEFT", self.strings.hasteRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.critRecordString:SetPoint("TOPLEFT", self.strings.hitRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.masteryRecordString:SetPoint("TOPLEFT", self.strings.critRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.spiritRecordString:SetPoint("TOPLEFT", self.strings.masteryRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.mp5RecordString:SetPoint("TOPLEFT", self.strings.spiritRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.dcRecordString:SetPoint("TOPLEFT", self.strings.mp5RecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.pcRecordString:SetPoint("TOPLEFT", self.strings.dcRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.bcRecordString:SetPoint("TOPLEFT", self.strings.pcRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.taRecordString:SetPoint("TOPLEFT", self.strings.bcRecordString, "TOPRIGHT", offsetX, offsetY)
	else
		self.strings.spString:SetPoint("TOPLEFT", self.frame,"TOPLEFT", offsetX, offsetY)
		self.strings.apString:SetPoint("TOPLEFT", self.strings.spString, "BOTTOMLEFT")
		self.strings.hasteString:SetPoint("TOPLEFT", self.strings.apString, "BOTTOMLEFT")
		self.strings.hitString:SetPoint("TOPLEFT", self.strings.hasteString, "BOTTOMLEFT")
		self.strings.critString:SetPoint("TOPLEFT", self.strings.hitString, "BOTTOMLEFT")
		self.strings.masteryString:SetPoint("TOPLEFT", self.strings.critString, "BOTTOMLEFT")
		self.strings.spiritString:SetPoint("TOPLEFT", self.strings.masteryString, "BOTTOMLEFT")
		self.strings.mp5String:SetPoint("TOPLEFT", self.strings.spiritString, "BOTTOMLEFT")
		self.strings.dcString:SetPoint("TOPLEFT", self.strings.mp5String, "BOTTOMLEFT")
		self.strings.pcString:SetPoint("TOPLEFT", self.strings.dcString, "BOTTOMLEFT")
		self.strings.bcString:SetPoint("TOPLEFT", self.strings.pcString, "BOTTOMLEFT")
		self.strings.taString:SetPoint("TOPLEFT", self.strings.bcString, "BOTTOMLEFT")

		self.strings.spRecordString:SetPoint("TOPLEFT", self.strings.spString, "TOPRIGHT", offsetX, offsetY)
		self.strings.apRecordString:SetPoint("TOPLEFT", self.strings.apString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hasteRecordString:SetPoint("TOPLEFT", self.strings.hasteString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hitRecordString:SetPoint("TOPLEFT", self.strings.hitString, "TOPRIGHT", offsetX, offsetY)
		self.strings.critRecordString:SetPoint("TOPLEFT", self.strings.critString, "TOPRIGHT", offsetX, offsetY)
		self.strings.masteryRecordString:SetPoint("TOPLEFT", self.strings.masteryString, "TOPRIGHT", offsetX, offsetY)
		self.strings.spiritRecordString:SetPoint("TOPLEFT", self.strings.spiritString, "TOPRIGHT", offsetX, offsetY)
		self.strings.mp5RecordString:SetPoint("TOPLEFT", self.strings.mp5String, "TOPRIGHT", offsetX, offsetY)
		self.strings.dcRecordString:SetPoint("TOPLEFT", self.strings.dcString, "TOPRIGHT", offsetX, offsetY)
		self.strings.pcRecordString:SetPoint("TOPLEFT", self.strings.pcString, "TOPRIGHT", offsetX, offsetY)
		self.strings.bcRecordString:SetPoint("TOPLEFT", self.strings.bcString, "TOPRIGHT", offsetX, offsetY)
		self.strings.taRecordString:SetPoint("TOPLEFT", self.strings.taString, "TOPRIGHT", offsetX, offsetY)
	end
end

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

function TinyXStats:SetBroker()

	if self.db.char.Style.LDBtext then
		TSBroker.label = ""
	else
		TSBroker.label = AddonName
	end
		
end

function TinyXStats:InitializeFrame()
	self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.char.xPosition, self.db.char.yPosition)
	local font = media:Fetch("font", self.db.char.Font)
	for k, fontObject in pairs(self.strings) do
		fontObject:SetFontObject(GameFontNormal)
		if not fontObject:SetFont(font, self.db.char.Size, self.db.char.FontEffect) then
			fontObject:SetFont("Fonts\\FRIZQT__.TTF", self.db.char.Size, self.db.char.FontEffect)
		end
		fontObject:SetJustifyH("LEFT")
		fontObject:SetJustifyV("MIDDLE")
	end
	self.strings.spString:SetText(" ")
	self.strings.spString:SetHeight(self.strings.spString:GetStringHeight())
	self.strings.spString:SetText("")
	self:SetTextAnchors()
	self:SetStringColors()
	self:SetDragScript()
	self:SetFrameVisible()
	self:SetBroker()
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

local orgSetActiveSpecGroup
if currentBuild  > 50000 then
	orgSetActiveSpecGroup = SetActiveSpecGroup;
else
	orgSetActiveSpecGroup = _G.SetActiveTalentGroup;
end
function SetActiveSpecGroup(...)	
	SpecChangedPause = GetTime() + 60
	TinyXStats:ScheduleTimer("Stats", 62)
	Debug("Set SpecChangedPause")
	return orgSetActiveSpecGroup(...)
end
function SetActiveTalentGroup(...)	
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
	-- If no ranged attack then set to n/a
	local hasRelic = UnitHasRelicSlot("player");	
	local rangedTexture = GetInventoryItemTexture("player", 18);
	local fastestSpeed = TinyXStats.db.char[spec].FastestRs
	if ( rangedTexture and not hasRelic ) then
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

local function GetHit()
	local CombatRating = 0
	local HitModifier = 0
	if TinyXStats.PlayerRole == "healer" or TinyXStats.PlayerRole == "caster" then
		CombatRating = GetCombatRatingBonus(CR_HIT_SPELL) or 0;
		HitModifier = GetSpellHitModifier() or 0;
	else
		CombatRating = GetCombatRatingBonus(CR_HIT_MELEE) or 0;
		HitModifier = GetHitModifier() or 0;
	end
	return string.format("%.2f", CombatRating + HitModifier);
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

function TinyXStats:GetUnitRole()
	self.class = select(2, UnitClass("player"))
	local role
	if currentBuild  >= 50000 then
		local Talent = GetSpecialization()
		if Talent then 
			role = GetSpecializationRole(Talent, false, false);
		end
		if not role then
			if GetAttackPower() > GetSpellDamage() then
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
				elseif (class == "DRUID" and Talent == 1) then
					role = "caster"
				else
					role = "melee"
				end
			end
		end
		if (not self.PlayerRole or self.PlayerRole ~= role) then
			self.PlayerRole = role
			if GetMasteryEffect() then
				self.Mastery = GetMasteryEffect()
			end
			self:Stats()
		end
	else
		if self.class == "HUNTER" then
			role = "hunter"
		else
			role = LGT:GetUnitRole("player",true)
		end
		if not role then
			if GetAttackPower() > GetSpellDamage() then
				role = "melee"
			else
				role = "caster"
			end
		end
		if (not self.PlayerRole or self.PlayerRole ~= role) then
			self.PlayerRole = role
			self.Mastery = GetSpellInfo(MasteryName)
			self:Stats()
		end
	end
	
	Debug("you are:", role, self.Mastery)
	return role
end

function TinyXStats:Stats()
	Debug("Stats()")
	local style = self.db.char.Style
	local mastery = string.format("%.2f", GetMastery())
	local spec = "Spec"
	if currentBuild >= 50000 then
		spec = spec..GetActiveSpecGroup()
		mastery = string.format("%.2f", GetMasteryEffect())
	else
		spec = spec..GetActiveTalentGroup()
	end
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
	local hit = GetHit()
	local s, spirit = UnitStat("player", 5)
	local base, casting = GetManaRegen()
	base = floor(base * 5.0)
	casting = floor(casting * 5.0)
	local fr = string.format("%.2f", GetPowerRegen() or 0)
	local DodgeChance,BlockChance,ParryChance,TAavoidance = 0,0,0,0
	if self.PlayerRole == "tank" then
		TAvoidance,DodgeChance,ParryChance,BlockChance = GetDefense()
	end
	
	local recordBroken = "|cffFF0000"..L["Record broken!"]..": "
	local recordIsBroken = false
	
	if SpecChangedPause <= GetTime() then
		if (style.SP[self.PlayerRole] and tonumber(spelldmg) > tonumber(self.db.char[spec].HighestSpelldmg)) then
			self.db.char[spec].HighestSpelldmg = spelldmg
			if (self.db.char.RecordMsg == true) then
				DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_SPELLPOWER..": |c00ffef00"..self.db.char[spec].HighestSpelldmg.."|r")
				recordIsBroken = true
			end
		end
		if (style.AP[self.PlayerRole] and tonumber(pow) > tonumber(self.db.char[spec].HighestAp)) then
			self.db.char[spec].HighestAp = pow
			if (self.db.char.RecordMsg == true) then
				DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_ATTACK_POWER..": |c00ffef00"..self.db.char[spec].HighestAp.."|r")
				recordIsBroken = true
			end
		end
		if (style.Haste[self.PlayerRole] or style.HastePerc[self.PlayerRole]) then
			if (tonumber(haste) > tonumber(self.db.char[spec].HighestHaste) or tonumber(hasteperc) > tonumber(self.db.char[spec].HighestHastePerc)) then
				self.db.char[spec].HighestHaste = haste
				self.db.char[spec].HighestHastePerc = hasteperc
				if (self.db.char.RecordMsg == true) then
					DEFAULT_CHAT_FRAME:AddMessage(recordBroken..SPELL_HASTE..": |c00ffef00"..self.db.char[spec].HighestHaste.."|r")
					DEFAULT_CHAT_FRAME:AddMessage(recordBroken..L["Percent Haste"]..": |c00ffef00"..self.db.char[spec].HighestHastePerc.."%|r")
					recordIsBroken = true
				end
			end
		end
		if (style.Speed[self.PlayerRole]) then
			if self.PlayerRole == "hunter" then
				if (tonumber(speed) and (tonumber(speed) < tonumber(self.db.char[spec].FastestRs))) then
					self.db.char[spec].FastestRs = speed
					if (self.db.char.RecordMsg == true) then
						DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_ATTACK_SPEED..": |c00ffef00"..self.db.char[spec].FastestRs.."|r")
						recordIsBroken = true
					end
					fastestSpeed = self.db.char[spec].FastestRs
				end
			else
				if (tonumber(mainSpeed) < tonumber(self.db.char[spec].FastestMh)) then
					self.db.char[spec].FastestMh = mainSpeed
					if (self.db.char.RecordMsg == true) then
						DEFAULT_CHAT_FRAME:AddMessage(recordBroken..WEAPON_SPEED..(offSpeed and " (MainHand)" or "")..": |c00ffef00"..self.db.char[spec].FastestMh.."|r")
						recordIsBroken = true
					end
					fastestSpeed = self.db.char[spec].FastestMh
				end
				if (offSpeed and (tonumber(offSpeed) < tonumber(self.db.char[spec].FastestOh))) then
					self.db.char[spec].FastestOh = offSpeed
					if (self.db.char.RecordMsg == true) then
						DEFAULT_CHAT_FRAME:AddMessage(recordBroken..WEAPON_SPEED.." (OffHand): |c00ffef00"..self.db.char[spec].FastestOh.."|r")
						recordIsBroken = true
					end
					fastestSpeed = self.db.char[spec].FastestMh.."s "..self.db.char[spec].FastestOh
				end
			end
		end
		if (style.Hit[self.PlayerRole] and tonumber(hit) > tonumber(self.db.char[spec].HighestHit)) then
			self.db.char[spec].HighestHit = hit
			if (self.db.char.RecordMsg == true) then
				DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_HIT_CHANCE..": |c00ffef00"..self.db.char[spec].HighestHit.."%|r")
				recordIsBroken = true
			end
		end
		if (style.Crit[self.PlayerRole] and tonumber(crit) > tonumber(self.db.char[spec].HighestCrit)) then
			self.db.char[spec].HighestCrit = crit
			if (self.db.char.RecordMsg == true) then
				DEFAULT_CHAT_FRAME:AddMessage(recordBroken..SPELL_CRIT_CHANCE..": |c00ffef00".. self.db.char[spec].HighestCrit.."%|r")
				recordIsBroken = true
			end
		end
		if (style.Mastery[self.PlayerRole] and self.Mastery) then
			if (tonumber(mastery) > tonumber(self.db.char[spec].HighestMastery)) then
				self.db.char[spec].HighestMastery = mastery
				if (self.db.char.RecordMsg == true) then
					DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_MASTERY..": |c00ffef00"..self.db.char[spec].HighestMastery.."|r")
					recordIsBroken = true
				end
			end
		end
		if (style.Spirit[self.PlayerRole] and tonumber(spirit) > tonumber(self.db.char[spec].HighestSpirit)) then
			self.db.char[spec].HighestSpirit = spirit
			if (self.db.char.RecordMsg == true) then
				DEFAULT_CHAT_FRAME:AddMessage(recordBroken..ITEM_MOD_SPIRIT_SHORT..": |c00ffef00"..self.db.char[spec].HighestSpirit.."|r")
				recordIsBroken = true
			end
		end
		if (style.MP5[self.PlayerRole] or style.MP5ic[self.PlayerRole] or style.MP5auto[self.PlayerRole]) then
			if (tonumber(base) > tonumber(self.db.char[spec].HighestMP5)) then
				self.db.char[spec].HighestMP5 = base
				if (self.db.char.RecordMsg == true) then
					DEFAULT_CHAT_FRAME:AddMessage(recordBroken..ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["out of combat"]..": |c00ffef00"..self.db.char[spec].HighestMP5.."|r")
					recordIsBroken = true
				end
			end
			if (tonumber(casting) > tonumber(self.db.char[spec].HighestMP5if)) then
				self.db.char[spec].HighestMP5if = casting
				if (self.db.char.RecordMsg == true) then
					DEFAULT_CHAT_FRAME:AddMessage(recordBroken..ITEM_MOD_MANA_REGENERATION_SHORT.." "..L["in combat"]..": |c00ffef00"..self.db.char[spec].HighestMP5if.."|r")
					recordIsBroken = true
				end
			end
		end
		if (style.Fr[self.PlayerRole] and tonumber(fr) > tonumber(self.db.char[spec].HighestFr)) then
			self.db.char[spec].HighestFr = fr
			if (self.db.char.RecordMsg == true) then
				DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_FOCUS_REGEN..": |c00ffef00"..self.db.char[spec].HighestFr.."|r")
				recordIsBroken = true
			end
		end
		if (style.DC[self.PlayerRole] and tonumber(DodgeChance) > tonumber(self.db.char[spec].HighestDC)) then
			self.db.char[spec].HighestDC = DodgeChance
			if (self.db.char.RecordMsg == true) then
				DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_DODGE..": |c00ffef00"..self.db.char[spec].HighestDC.."|r")
				recordIsBroken = true
			end
		end
		if (style.PC[self.PlayerRole] and not TinyXStats:HideTankStat("PC")) then
			if tonumber(ParryChance) > tonumber(self.db.char[spec].HighestPC) then
				self.db.char[spec].HighestPC = ParryChance
				if (self.db.char.RecordMsg == true) then
					DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_PARRY..": |c00ffef00"..self.db.char[spec].HighestPC.."|r")
					recordIsBroken = true
				end
			end
		end
		if (style.BC[self.PlayerRole] and not TinyXStats:HideTankStat("BC")) then
			if tonumber(BlockChance) > tonumber(self.db.char[spec].HighestBC) then
				self.db.char[spec].HighestBC = BlockChance
				if (self.db.char.RecordMsg == true) then
					DEFAULT_CHAT_FRAME:AddMessage(recordBroken..STAT_BLOCK..": |c00ffef00"..self.db.char[spec].HighestBC.."|r")
					recordIsBroken = true
				end
			end
		end
		if (style.TA[self.PlayerRole] and tonumber(TAvoidance) > tonumber(self.db.char[spec].HighestTA)) then
			self.db.char[spec].HighestTA = TAvoidance
			if (self.db.char.RecordMsg == true) then
				DEFAULT_CHAT_FRAME:AddMessage(recordBroken..L["Total Avoidance"]..": |c00ffef00"..self.db.char[spec].HighestTA.."|r")
				recordIsBroken = true
			end
		end
	else
		Debug("rekords skipped SpecChangedPause")
	end
	
	if ((recordIsBroken == true) and (self.db.char.RecordSound == true)) then
		PlaySoundFile(media:Fetch("sound", self.db.char.RecordSoundFile),"Master")
	end
	
	local ldbString = ""
	local ldbRecord = ""
	
	if (style.showRecords) then ldbRecord = "|n" end
	
	if (style.SP[self.PlayerRole]) then
		local spTempString = " "
		local spRecordTempString = " "
		ldbString = ldbString..HexColor("sp")
		if (style.labels) then
			spTempString = spTempString..L["Sp:"]
			ldbString = ldbString..L["Sp:"]
		end
		spTempString = spTempString..spelldmg
		ldbString = ldbString..spelldmg.." "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("sp")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["Sp:"]
				end
				spRecordTempString = spRecordTempString.."("..self.db.char[spec].HighestSpelldmg..")"
				ldbRecord = ldbRecord..self.db.char[spec].HighestSpelldmg.." "
			else
				if (style.labels) then
					spRecordTempString = spRecordTempString..L["Sp:"]
					ldbRecord = ldbRecord..L["Sp:"]
				end
				spRecordTempString = spRecordTempString..self.db.char[spec].HighestSpelldmg
				ldbRecord = ldbRecord..self.db.char[spec].HighestSpelldmg.." "
			end
		end
		self.strings.spString:SetText(spTempString)
		self.strings.spRecordString:SetText(spRecordTempString)
	else
		self.strings.spString:SetText("")
		self.strings.spRecordString:SetText("")
	end
	if (style.AP[self.PlayerRole]) then
		local apTempString = " "
		local apRecordTempString = " "
		ldbString = ldbString..HexColor("ap")
		if (style.labels) then
			apTempString = apTempString..L["Ap:"]
			ldbString = ldbString..L["Ap:"]
		end
		apTempString = apTempString..pow
		ldbString = ldbString..pow.." "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("ap")
			if (style.vertical) then
				apRecordTempString = apRecordTempString.."("..self.db.char[spec].HighestAp..")"
				if (style.labels) then
					ldbRecord = ldbRecord..L["Ap:"]
				end
				ldbRecord = ldbRecord..self.db.char[spec].HighestAp.." "
			else
				if (style.labels) then
					apRecordTempString = apRecordTempString..L["Ap:"]
					ldbRecord = ldbRecord..L["Ap:"]
				end
				apRecordTempString = apRecordTempString..self.db.char[spec].HighestAp
				ldbRecord = ldbRecord..self.db.char[spec].HighestAp.." "
			end
		end
		self.strings.apString:SetText(apTempString)
		self.strings.apRecordString:SetText(apRecordTempString)
	else
		self.strings.apString:SetText("")
		self.strings.apRecordString:SetText("")
	end
	if (style.Haste[self.PlayerRole]) then
		local hasteTempString = " "
		local hasteRecordTempString = " "
		ldbString = ldbString..HexColor("haste")
		if (style.labels) then
			hasteTempString = hasteTempString..L["Haste:"]
			ldbString = ldbString..L["Haste:"]
		end
		hasteTempString = hasteTempString..haste
		ldbString = ldbString..haste.." "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("haste")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["Haste:"]
				end
				hasteRecordTempString = hasteRecordTempString.."("..self.db.char[spec].HighestHaste..")"
				ldbRecord = ldbRecord..self.db.char[spec].HighestHaste.." "
			else
				if (style.labels) then
					hasteRecordTempString = hasteRecordTempString..L["Haste:"]
					ldbRecord = ldbRecord..L["Haste:"]
				end
				hasteRecordTempString = hasteRecordTempString..self.db.char[spec].HighestHaste
				ldbRecord = ldbRecord..self.db.char[spec].HighestHaste.." "
			end
		end
		self.strings.hasteString:SetText(hasteTempString)
		self.strings.hasteRecordString:SetText(hasteRecordTempString)
	elseif (style.HastePerc[self.PlayerRole]) then
		local hasteTempString = " "
		local hasteRecordTempString = " "
		ldbString = ldbString..HexColor("haste")
		if (style.labels) then
			hasteTempString = hasteTempString..SPELL_HASTE_ABBR..":"
			ldbString = ldbString..SPELL_HASTE_ABBR..":"
		end
		hasteTempString = hasteTempString..hasteperc.."%"
		ldbString = ldbString..hasteperc.."% "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("haste")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..SPELL_HASTE_ABBR..":"
				end
				hasteRecordTempString = hasteRecordTempString.."("..self.db.char[spec].HighestHastePerc.."%)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestHastePerc.."% "
			else
				if (style.labels) then
					hasteRecordTempString = hasteRecordTempString..SPELL_HASTE_ABBR..":"
					ldbRecord = ldbRecord..SPELL_HASTE_ABBR..":"
				end
				hasteRecordTempString = hasteRecordTempString..self.db.char[spec].HighestHastePerc.."%"
				ldbRecord = ldbRecord..self.db.char[spec].HighestHastePerc.."% "
			end
		end
		self.strings.hasteString:SetText(hasteTempString)
		self.strings.hasteRecordString:SetText(hasteRecordTempString)
	elseif (style.Speed[self.PlayerRole]) then
		local hasteTempString = " "
		local hasteRecordTempString = " "
		ldbString = ldbString..HexColor("haste")
		if (style.labels) then
			hasteTempString = hasteTempString..L["Speed:"]
			ldbString = ldbString..L["Speed:"]
		end
		hasteTempString = hasteTempString..speed.."s"
		ldbString = ldbString..speed.."s "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("haste")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["Speed:"]
				end
				hasteRecordTempString = hasteRecordTempString.."("..fastestSpeed.."s)"
				ldbRecord = ldbRecord..fastestSpeed.."s "
			else
				if (style.labels) then
					hasteRecordTempString = hasteRecordTempString..L["Speed:"]
					ldbRecord = ldbRecord..L["Speed:"]
				end
				hasteRecordTempString = hasteRecordTempString..fastestSpeed.."s"
				ldbRecord = ldbRecord..fastestSpeed.."s "
			end
		end
		self.strings.hasteString:SetText(hasteTempString)
		self.strings.hasteRecordString:SetText(hasteRecordTempString)
	else
		self.strings.hasteString:SetText("")
		self.strings.hasteRecordString:SetText("")
	end
	if (style.Hit[self.PlayerRole]) then
		local hitTempString = " "
		local hitRecordTempString = " "
		ldbString = ldbString..HexColor("hit")
		if (style.labels) then
			hitTempString = hitTempString..L["Hit:"]
			ldbString = ldbString..L["Hit:"]
		end
		hitTempString = hitTempString..hit.."%"
		ldbString = ldbString..hit.."% "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("hit")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["Hit:"]
				end
				hitRecordTempString = hitRecordTempString.."("..self.db.char[spec].HighestHit.."%)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestHit.."% "
			else
				if (style.labels) then
					hitRecordTempString = hitRecordTempString..L["Hit:"]
					ldbRecord = ldbRecord..L["Hit:"]
				end
				hitRecordTempString = hitRecordTempString..self.db.char[spec].HighestHit.."%"
				ldbRecord = ldbRecord..self.db.char[spec].HighestHit.."% "
			end
		end
		self.strings.hitString:SetText(hitTempString)
		self.strings.hitRecordString:SetText(hitRecordTempString)
	else
		self.strings.hitString:SetText("")
		self.strings.hitRecordString:SetText("")
	end
	if (style.Crit[self.PlayerRole]) then
		local critTempString = " "
		local critRecordTempString = " "
		ldbString = ldbString..HexColor("crit")
		if (style.labels) then
			critTempString = critTempString..L["Crit:"]
			ldbString = ldbString..L["Crit:"]
		end
		critTempString = critTempString..crit.."%"
		ldbString = ldbString..crit.."% "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("crit")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["Crit:"]
				end
				critRecordTempString = critRecordTempString.."("..self.db.char[spec].HighestCrit.."%)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestCrit.."% "
			else
				if (style.labels) then
					critRecordTempString = critRecordTempString..L["Crit:"]
					ldbRecord = ldbRecord..L["Crit:"]
				end
				critRecordTempString = critRecordTempString..self.db.char[spec].HighestCrit.."%"
				ldbRecord = ldbRecord..self.db.char[spec].HighestCrit.."% "
			end
		end
		self.strings.critString:SetText(critTempString)
		self.strings.critRecordString:SetText(critRecordTempString)
	else
		self.strings.critString:SetText("")
		self.strings.critRecordString:SetText("")
	end
	if (style.Mastery[self.PlayerRole] and self.Mastery) then
		local masteryTempString = " "
		local masteryRecordTempString = " "
		ldbString = ldbString..HexColor("mastery")
		if (style.labels) then
			masteryTempString = masteryTempString..L["Mas:"]
			ldbString = ldbString..L["Mas:"]
		end
		masteryTempString = masteryTempString..mastery.."%"
		ldbString = ldbString..mastery.."% "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("mastery")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["Mas:"]
				end
				masteryRecordTempString = masteryRecordTempString.."("..self.db.char[spec].HighestMastery.."%)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestMastery.."% "
			else
				if (style.labels) then
					masteryRecordTempString = masteryRecordTempString..L["Mas:"]
					ldbRecord = ldbRecord..L["Mas:"]
				end
				masteryRecordTempString = masteryRecordTempString..self.db.char[spec].HighestMastery.."%"
				ldbRecord = ldbRecord..self.db.char[spec].HighestMastery.."% "
			end
		end
		self.strings.masteryString:SetText(masteryTempString)
		self.strings.masteryRecordString:SetText(masteryRecordTempString)
	else
		self.strings.masteryString:SetText("")
		self.strings.masteryRecordString:SetText("")
	end
	if (style.Spirit[self.PlayerRole]) then
		local spiritTempString = " "
		local spiritRecordTempString = " "
		ldbString = ldbString..HexColor("spirit")
		if (style.labels) then
			spiritTempString = spiritTempString..L["Spi:"]
			ldbString = ldbString..L["Spi:"]
		end
		spiritTempString = spiritTempString..spirit
		ldbString = ldbString..spirit.." "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("spirit")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["Spi:"]
				end
				spiritRecordTempString = spiritRecordTempString.."("..self.db.char[spec].HighestSpirit..")"
				ldbRecord = ldbRecord..self.db.char[spec].HighestSpirit.." "
			else
				if (style.labels) then
					spiritRecordTempString = spiritRecordTempString..L["Spi:"]
					ldbRecord = ldbRecord..L["Spi:"]
				end
				spiritRecordTempString = spiritRecordTempString..self.db.char[spec].HighestSpirit
				ldbRecord = ldbRecord..self.db.char[spec].HighestSpirit.." "
			end
		end
		self.strings.spiritString:SetText(spiritTempString)
		self.strings.spiritRecordString:SetText(spiritRecordTempString)
	else
		self.strings.spiritString:SetText("")
		self.strings.spiritRecordString:SetText("")
	end
		
	local mp5TempString = " "
	local mp5RecordTempString = " "
	
	if (style.MP5[self.PlayerRole]) then
		ldbString = ldbString..HexColor("mp5")
		if (style.labels) then
			mp5TempString = mp5TempString..L["MP5:"]
			ldbString = ldbString..L["MP5:"]
		end
		mp5TempString = mp5TempString..base.."mp5 "
		ldbString = ldbString..base.."mp5 "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("mp5")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["MP5:"]
				end
				mp5RecordTempString = mp5RecordTempString.."("..self.db.char[spec].HighestMP5.."mp5)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestMP5.."mp5 "
			else
				if (style.labels) then
					mp5RecordTempString = mp5RecordTempString..L["MP5:"]
					ldbRecord = ldbRecord..L["MP5:"]
				end
				mp5RecordTempString = mp5RecordTempString..self.db.char[spec].HighestMP5.."mp5 "
				ldbRecord = ldbRecord..self.db.char[spec].HighestMP5.."mp5 "
			end
		end
		self.strings.mp5String:SetText(mp5TempString)
		self.strings.mp5RecordString:SetText(mp5RecordTempString)
	end
	if (style.MP5ic[self.PlayerRole]) then
		ldbString = ldbString..HexColor("mp5")
		if (style.labels) then
			mp5TempString = mp5TempString..L["MP5-ic:"]
			ldbString = ldbString..L["MP5-ic:"]
		end
		mp5TempString = mp5TempString..casting.."mp5 "
		ldbString = ldbString..casting.."mp5 "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("mp5")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["MP5-ic:"]
				end
				mp5RecordTempString = mp5RecordTempString.."("..self.db.char[spec].HighestMP5if.."mp5)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestMP5if.."mp5 "
			else
				if (style.labels) then
					mp5RecordTempString = mp5RecordTempString..L["MP5-ic:"]
					ldbRecord = ldbRecord..L["MP5-ic:"]
				end
				mp5RecordTempString = mp5RecordTempString..self.db.char[spec].HighestMP5if.."mp5 "
				ldbRecord = ldbRecord..self.db.char[spec].HighestMP5if.."mp5 "
			end
		end
		self.strings.mp5String:SetText(mp5TempString)
		self.strings.mp5RecordString:SetText(mp5RecordTempString)
	end
	if (style.MP5auto[self.PlayerRole]) then
		ldbString = ldbString..HexColor("mp5")
		if (style.labels) then
			mp5TempString = mp5TempString..L["MP5:"]
			ldbString = ldbString..L["MP5:"]
		end
		if (isInFight) then
			mp5TempString = mp5TempString..casting.."mp5"
			ldbString = ldbString..casting.."mp5 "
		else
			mp5TempString = mp5TempString..base.."mp5"
			ldbString = ldbString..base.."mp5 "
		end
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("mp5")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["MP5:"]
				end
				if (isInFight) then
					mp5RecordTempString = mp5RecordTempString.."("..self.db.char[spec].HighestMP5if.."mp5)"
					ldbRecord = ldbRecord..self.db.char[spec].HighestMP5if.."mp5"
				else
					mp5RecordTempString = mp5RecordTempString.."("..self.db.char[spec].HighestMP5.."mp5)"
					ldbRecord = ldbRecord..self.db.char[spec].HighestMP5.."mp5"
				end
			else
				if (style.labels) then
					mp5RecordTempString = mp5RecordTempString..L["MP5:"]
					ldbRecord = ldbRecord..L["MP5:"]
				end
				if (isInFight) then
					mp5RecordTempString = mp5RecordTempString..self.db.char[spec].HighestMP5if.."mp5"
					ldbRecord = ldbRecord..self.db.char[spec].HighestMP5if.."mp5"
				else
					mp5RecordTempString = mp5RecordTempString..self.db.char[spec].HighestMP5.."mp5"
					ldbRecord = ldbRecord..self.db.char[spec].HighestMP5.."mp5"
				end
			end
		end
		self.strings.mp5String:SetText(mp5TempString)
		self.strings.mp5RecordString:SetText(mp5RecordTempString)
	end
	if (style.Fr[self.PlayerRole]) then
		ldbString = ldbString..HexColor("fr")
		if (style.labels) then
			mp5TempString = mp5TempString..L["FR:"]
			ldbString = ldbString..L["FR:"]
		end
		mp5TempString = mp5TempString..fr
		ldbString = ldbString..fr.." "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("fr")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["FR:"]
				end
				mp5RecordTempString = mp5RecordTempString.."("..self.db.char[spec].HighestFr..")"
				ldbRecord = ldbRecord..self.db.char[spec].HighestFr.." "
			else
				if (style.labels) then
					mp5RecordTempString = mp5RecordTempString..L["FR:"]
					ldbRecord = ldbRecord..L["FR:"]
				end
				mp5RecordTempString = mp5RecordTempString..self.db.char[spec].HighestFr
				ldbRecord = ldbRecord..self.db.char[spec].HighestFr.." "
			end
		end
		self.strings.mp5String:SetText(mp5TempString)
		self.strings.mp5RecordString:SetText(mp5RecordTempString)
	end
	if (not style.MP5[self.PlayerRole] and
		not style.MP5ic[self.PlayerRole] and
		not style.MP5auto[self.PlayerRole] and
		not style.Fr[self.PlayerRole]) then
			self.strings.mp5String:SetText("")
			self.strings.mp5RecordString:SetText("")
	end
	if (style.DC[self.PlayerRole]) then
		local dcTempString = " "
		local dcRecordTempString = " "
		ldbString = ldbString..HexColor("dc")
		if (style.labels) then
			dcTempString = dcTempString..L["DC:"]
			ldbString = ldbString..L["DC:"]
		end
		dcTempString = dcTempString..DodgeChance.."%"
		ldbString = ldbString..DodgeChance.."% "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("dc")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["DC:"]
				end
				dcRecordTempString = dcRecordTempString.."("..self.db.char[spec].HighestDC.."%)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestDC.."% "
			else
				if (style.labels) then
					dcRecordTempString = dcRecordTempString..L["DC:"]
					ldbRecord = ldbRecord..L["DC:"]
				end
				dcRecordTempString = dcRecordTempString..self.db.char[spec].HighestDC.."%"
				ldbRecord = ldbRecord..self.db.char[spec].HighestDC.."% "
			end
		end
		self.strings.dcString:SetText(dcTempString)
		self.strings.dcRecordString:SetText(dcRecordTempString)
	else
		self.strings.dcString:SetText("")
		self.strings.dcRecordString:SetText("")
	end
	if (style.PC[self.PlayerRole] and not TinyXStats:HideTankStat("PC")) then
		local pcTempString = " "
		local pcRecordTempString = " "
		ldbString = ldbString..HexColor("pc")
		if (style.labels) then
			pcTempString = pcTempString..L["PC:"]
			ldbString = ldbString..L["PC:"]
		end
		pcTempString = pcTempString..ParryChance.."%"
		ldbString = ldbString..ParryChance.."% "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("pc")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["PC:"]
				end
				pcRecordTempString = pcRecordTempString.."("..self.db.char[spec].HighestPC.."%)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestPC.."% "
			else
				if (style.labels) then
					pcRecordTempString = pcRecordTempString..L["PC:"]
					ldbRecord = ldbRecord..L["PC:"]
				end
				pcRecordTempString = pcRecordTempString..self.db.char[spec].HighestPC.."%"
				ldbRecord = ldbRecord..self.db.char[spec].HighestPC.."% "
			end
		end
		self.strings.pcString:SetText(pcTempString)
		self.strings.pcRecordString:SetText(pcRecordTempString)
	else
		self.strings.pcString:SetText("")
		self.strings.pcRecordString:SetText("")
	end
	if (style.BC[self.PlayerRole] and not TinyXStats:HideTankStat("BC")) then
		local bcTempString = " "
		local bcRecordTempString = " "
		ldbString = ldbString..HexColor("bc")
		if (style.labels) then
			bcTempString = bcTempString..L["BC:"]
			ldbString = ldbString..L["BC:"]
		end
		bcTempString = bcTempString..BlockChance.."%"
		ldbString = ldbString..BlockChance.."% "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("bc")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["BC:"]
				end
				bcRecordTempString = bcRecordTempString.."("..self.db.char[spec].HighestBC.."%)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestBC.."% "
			else
				if (style.labels) then
					bcRecordTempString = bcRecordTempString..L["BC:"]
					ldbRecord = ldbRecord..L["BC:"]
				end
				bcRecordTempString = bcRecordTempString..self.db.char[spec].HighestBC.."%"
				ldbRecord = ldbRecord..self.db.char[spec].HighestBC.."% "
			end
		end
		self.strings.bcString:SetText(bcTempString)
		self.strings.bcRecordString:SetText(bcRecordTempString)
	else
		self.strings.bcString:SetText("")
		self.strings.bcRecordString:SetText("")
	end
	if (style.TA[self.PlayerRole]) then
		local taTempString = " "
		local taRecordTempString = " "
		ldbString = ldbString..HexColor("ta")
		if (style.labels) then
			taTempString = taTempString..L["TA:"]
			ldbString = ldbString..L["TA:"]
		end
		taTempString = taTempString..TAvoidance.."%"
		ldbString = ldbString..TAvoidance.."% "
		if (style.showRecords) then
			ldbRecord = ldbRecord..HexColor("ta")
			if (style.vertical) then
				if (style.labels) then
					ldbRecord = ldbRecord..L["TA:"]
				end
				taRecordTempString = taRecordTempString.."("..self.db.char[spec].HighestTA.."%)"
				ldbRecord = ldbRecord..self.db.char[spec].HighestTA.."% "
			else
				if (style.labels) then
					taRecordTempString = taRecordTempString..L["TA:"]
					ldbRecord = ldbRecord..L["TA:"]
				end
				taRecordTempString = taRecordTempString..self.db.char[spec].HighestTA.."%"
				ldbRecord = ldbRecord..self.db.char[spec].HighestTA.."% "
			end
		end
		self.strings.taString:SetText(taTempString)
		self.strings.taRecordString:SetText(taRecordTempString)
	else
		self.strings.taString:SetText("")
		self.strings.taRecordString:SetText("")
	end

	if (style.LDBtext) then
		TSBroker.text = ldbString..ldbRecord.."|r"
	else
		TSBroker.text = ""
	end
end

