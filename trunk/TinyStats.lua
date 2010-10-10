--   ----------------------------------------
--  |  TinyStats by TheVaan and ArcaneMagus  |
--  | based on TMS and TCS - for all classes |
--   ----------------------------------------
--
-- File version: @file-revision@
-- Project: @project-revision@
--

local AceAddon = LibStub("AceAddon-3.0")
local media = LibStub:GetLibrary("LibSharedMedia-3.0")
TinyStats = AceAddon:NewAddon("TinyStats", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("TinyStats")
local LGT = LibStub:GetLibrary("LibGroupTalents-1.0");
local isInFight = false
--Localize buff names
local hasteBuffs = {
	bloodlust = GetSpellInfo(2825),
	heroism = GetSpellInfo(32182),
	wrathOfAir = GetSpellInfo(2895),
	elementalMastery = GetSpellInfo(64701),
	moonkinAura = GetSpellInfo(24907),
	concentrationAura = GetSpellInfo(19746),
	crusaderAura = GetSpellInfo(32223),
	devotionAura = GetSpellInfo(465),
	retributionAura = GetSpellInfo(7294),
	shaodowResistanceAura = GetSpellInfo(19876),
	frostResistanceAura = GetSpellInfo(19888),
	fireResistanceAura = GetSpellInfo(19891)
}

local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local TSBroker = ldb:NewDataObject("TinyStats", { 
	type = "data source",
	label = "TinyStats", 
	icon = "Interface\\Icons\\Ability_Mage_ArcaneBarrage",
	text = "--"
	})
	
TinyStats.fonts = {}

TinyStats.defaults = {
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
		HighestSpelldmg = 0,
		HighestSpellCrit = 0,
		HighestSpellHaste = 0,
		HighestSpellHastePerc = 0,
		HighestSpellHit = 0,
		HighestMP5if = 0,
		HighestMP5 = 0,
		HighestAp = 0,
		HighestMeleeCrit = 0,
		FastestMh = 500,
		FastestOh = 500,
		HighestMeleeHit = 0,
		Style = {
			Spelldmg = true,
			SpellCrit = true,
			Haste = true,
			HastePerc = false,
			SpellHit = false,
			MP5 = false,
			Ap = true,
			MeleeCrit = true,
			Speed = true,
			MeleeHit = false,
		},
		Color = {
			sp = {
				r = 1.0,
				g = 0.9372549019607843,
				b = 0
			},
			spellCrit = {
				r = 1.0,
				g = 0,
				b = 1.0
			},
			spellHit = {
				r = 0,
				g = 0.803921568627451,
				b = 0
			},
			haste = {
				r = 0.1176470588235294,
				g = 0.5647058823529412,
				b = 1.0
			},
			mp5 = {
				r = 1.0,
				g = 1.0,
				b = 1.0
			},
			ap = {
				r = 1,
				g = 0.803921568627451,
				b = 0
			},
			meleeCrit = {
				r = 1,
				g = 0,
				b = 0.6549019607843137
			},
			speed = {
				r = 0,
				g = 0.611764705882353,
				b = 1
			},
			meleeHit = {
				r = 0.07058823529411765,
				g = 0.7686274509803921,
				b = 0
			}
		}
	}
}

TinyStats.tsframe = CreateFrame("Frame","TinyStatsFrame",UIParent)
TinyStats.tsframe:SetWidth(100)
TinyStats.tsframe:SetHeight(15)
TinyStats.tsframe:SetFrameStrata("BACKGROUND")
TinyStats.tsframe:EnableMouse(true)
TinyStats.tsframe:RegisterForDrag("LeftButton")

TinyStats.strings = {
	spString = TinyStats.tsframe:CreateFontString(),
	spellCritString = TinyStats.tsframe:CreateFontString(),
	spellHitString = TinyStats.tsframe:CreateFontString(),
	hasteString = TinyStats.tsframe:CreateFontString(),
	mp5String = TinyStats.tsframe:CreateFontString(),
	apString = TinyStats.tsframe:CreateFontString(),
	meleeCritString = TinyStats.tsframe:CreateFontString(),
	speedString = TinyStats.tsframe:CreateFontString(),
	meleeHitString = TinyStats.tsframe:CreateFontString(),

	spRecordString = TinyStats.tsframe:CreateFontString(),
	spellCritRecordString = TinyStats.tsframe:CreateFontString(),
	spellHitRecordString = TinyStats.tsframe:CreateFontString(),
	hasteRecordString = TinyStats.tsframe:CreateFontString(),
	mp5RecordString = TinyStats.tsframe:CreateFontString(),
	apRecordString = TinyStats.tsframe:CreateFontString(),
	meleeCritRecordString = TinyStats.tsframe:CreateFontString(),
	speedRecordString = TinyStats.tsframe:CreateFontString(),
	meleeHitRecordString = TinyStats.tsframe:CreateFontString(),
}

function TinyStats:SetStringColors()
	local c = self.db.char.Color
	self.strings.spString:SetTextColor(c.sp.r, c.sp.g, c.sp.b, 1.0)
	self.strings.spellCritString:SetTextColor(c.spellCrit.r, c.spellCrit.g, c.spellCrit.b, 1.0)
	self.strings.spellHitString:SetTextColor(c.spellHit.r, c.spellHit.g, c.spellHit.b, 1.0)
	self.strings.hasteString:SetTextColor(c.haste.r, c.haste.g, c.haste.b, 1.0)
	self.strings.mp5String:SetTextColor(c.mp5.r, c.mp5.g, c.mp5.b, 1.0)
	self.strings.apString:SetTextColor(c.ap.r, c.ap.g, c.ap.b, 1.0)
	self.strings.meleeCritString:SetTextColor(c.meleeCrit.r, c.meleeCrit.g, c.meleeCrit.b, 1.0)
	self.strings.speedString:SetTextColor(c.speed.r, c.speed.g, c.speed.b, 1.0)
	self.strings.meleeHitString:SetTextColor(c.meleeHit.r, c.meleeHit.g, c.meleeHit.b, 1.0)
	
	self.strings.spRecordString:SetTextColor(c.sp.r, c.sp.g, c.sp.b, 1.0)
	self.strings.spellCritRecordString:SetTextColor(c.spellCrit.r, c.spellCrit.g, c.spellCrit.b, 1.0)
	self.strings.spellHitRecordString:SetTextColor(c.spellHit.r, c.spellHit.g, c.spellHit.b, 1.0)
	self.strings.hasteRecordString:SetTextColor(c.haste.r, c.haste.g, c.haste.b, 1.0)
	self.strings.mp5RecordString:SetTextColor(c.mp5.r, c.mp5.g, c.mp5.b, 1.0)
	self.strings.apRecordString:SetTextColor(c.ap.r, c.ap.g, c.ap.b, 1.0)
	self.strings.meleeCritRecordString:SetTextColor(c.meleeCrit.r, c.meleeCrit.g, c.meleeCrit.b, 1.0)
	self.strings.speedRecordString:SetTextColor(c.speed.r, c.speed.g, c.speed.b, 1.0)
	self.strings.meleeHitRecordString:SetTextColor(c.meleeHit.r, c.meleeHit.g, c.meleeHit.b, 1.0)
end

function TinyStats:SetTextAnchors()
	local offsetX, offsetY = 3, 0
	if (not self.db.char.Style.vertical) then
		self.strings.spString:SetPoint("TOPLEFT", self.tsframe)
		self.strings.spellCritString:SetPoint("TOPLEFT", self.strings.spString, "TOPRIGHT", offsetX, offsetY)
		self.strings.spellHitString:SetPoint("TOPLEFT", self.strings.spellCritString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hasteString:SetPoint("TOPLEFT", self.strings.spellHitString, "TOPRIGHT", offsetX, offsetY)
		self.strings.mp5String:SetPoint("TOPLEFT", self.strings.hasteString, "TOPRIGHT", offsetX, offsetY)
		self.strings.apString:SetPoint("TOPLEFT", self.strings.mp5String, "TOPRIGHT", offsetX, offsetY)
		self.strings.meleeCritString:SetPoint("TOPLEFT", self.strings.apString, "TOPRIGHT", offsetX, offsetY)
		self.strings.speedString:SetPoint("TOPLEFT", self.strings.meleeCritString, "TOPRIGHT", offsetX, offsetY)
		self.strings.meleeHitString:SetPoint("TOPLEFT", self.strings.speedString, "TOPRIGHT", offsetX, offsetY)
		
		self.strings.spRecordString:SetPoint("TOPLEFT", self.strings.spString, "BOTTOMLEFT")
		self.strings.spellCritRecordString:SetPoint("TOPLEFT", self.strings.spRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.spellHitRecordString:SetPoint("TOPLEFT", self.strings.spellCritRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hasteRecordString:SetPoint("TOPLEFT", self.strings.spellHitRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.mp5RecordString:SetPoint("TOPLEFT", self.strings.hasteRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.apRecordString:SetPoint("TOPLEFT", self.strings.apString, "BOTTOMLEFT")
		self.strings.meleeCritRecordString:SetPoint("TOPLEFT", self.strings.apRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.speedRecordString:SetPoint("TOPLEFT", self.strings.meleeCritRecordString, "TOPRIGHT", offsetX, offsetY)
		self.strings.meleeHitRecordString:SetPoint("TOPLEFT", self.strings.speedRecordString, "TOPRIGHT", offsetX, offsetY)
	else
		self.strings.spString:SetPoint("TOPLEFT", self.tsframe)
		self.strings.spellCritString:SetPoint("TOPLEFT", self.strings.spString, "BOTTOMLEFT")
		self.strings.spellHitString:SetPoint("TOPLEFT", self.strings.spellCritString, "BOTTOMLEFT")
		self.strings.hasteString:SetPoint("TOPLEFT", self.strings.spellHitString, "BOTTOMLEFT")
		self.strings.mp5String:SetPoint("TOPLEFT", self.strings.hasteString, "BOTTOMLEFT")
		self.strings.apString:SetPoint("TOPLEFT", self.strings.mp5String, "BOTTOMLEFT")
		self.strings.meleeCritString:SetPoint("TOPLEFT", self.strings.apString, "BOTTOMLEFT")
		self.strings.speedString:SetPoint("TOPLEFT", self.strings.meleeCritString, "BOTTOMLEFT")
		self.strings.meleeHitString:SetPoint("TOPLEFT", self.strings.speedString, "BOTTOMLEFT")
		
		self.strings.spRecordString:SetPoint("TOPLEFT", self.strings.spString, "TOPRIGHT", offsetX, offsetY)
		self.strings.spellCritRecordString:SetPoint("TOPLEFT", self.strings.spellCritString, "TOPRIGHT", offsetX, offsetY)
		self.strings.spellHitRecordString:SetPoint("TOPLEFT", self.strings.spellHitString, "TOPRIGHT", offsetX, offsetY)
		self.strings.hasteRecordString:SetPoint("TOPLEFT", self.strings.hasteString, "TOPRIGHT", offsetX, offsetY)
		self.strings.mp5RecordString:SetPoint("TOPLEFT", self.strings.mp5String, "TOPRIGHT", offsetX, offsetY)
		self.strings.apRecordString:SetPoint("TOPLEFT", self.strings.apString, "TOPRIGHT", offsetX, offsetY)
		self.strings.meleeCritRecordString:SetPoint("TOPLEFT", self.strings.meleeCritString, "TOPRIGHT", offsetX, offsetY)
		self.strings.speedRecordString:SetPoint("TOPLEFT", self.strings.speedString, "TOPRIGHT", offsetX, offsetY)
		self.strings.meleeHitRecordString:SetPoint("TOPLEFT", self.strings.meleeHitString, "TOPRIGHT", offsetX, offsetY)
	end
end

function TinyStats:OnInitialize()
	local AceConfigReg = LibStub("AceConfigRegistry-3.0")
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")
	
	self.db = LibStub("AceDB-3.0"):New("TinyStats", TinyStats.defaults, "char")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TinyStats", self:Options(), "tscmd")
	media.RegisterCallback(self, "LibSharedMedia_Registered")
	
	self:RegisterChatCommand("ts", function() AceConfigDialog:Open("TinyStats") end)	
	self:RegisterChatCommand("tinystats", function() AceConfigDialog:Open("TinyStats") end)	
	self.optionsFrame = AceConfigDialog:AddToBlizOptions("TinyStats", "TinyStats")
	self.db:RegisterDefaults(self.defaults)
	local version = GetAddOnMetadata("TinyStats","Version")
	DEFAULT_CHAT_FRAME:AddMessage("|cffffd700TinyStats |cff00ff00~v"..version.."~|cffffd700: "..L["Open the configuration menu with /ts or /tinystats"].."|r")
end

function TinyStats:OnEnable()
	self:LibSharedMedia_Registered()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("ADDON_LOADED", "OnEvent")
	self:RegisterEvent("VARIABLES_LOADED", "OnEvent")
	self:RegisterEvent("UNIT_AURA", "OnEvent")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "OnEvent")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "OnEvent")
	self:RegisterEvent("UNIT_LEVEL", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "OnEvent")
end

function TinyStats:LibSharedMedia_Registered()
	media:Register("font", "BaarSophia", [[Interface\Addons\TinyStats\Fonts\BaarSophia.ttf]])
	media:Register("font", "LucidaSD", [[Interface\Addons\TinyStats\Fonts\LucidaSD.ttf]])
	media:Register("font", "Teen", [[Interface\Addons\TinyStats\Fonts\Teen.ttf]])
	media:Register("font", "Vera", [[Interface\Addons\TinyStats\Fonts\Vera.ttf]])
	
	for k, v in pairs(media:List("font")) do
		self.fonts[v] = v
	end
end

function TinyStats:OnEvent(event, arg1)
	if (event == "ADDON_LOADED") then
		self.tsframe:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.char.xPosition, self.db.char.yPosition)
		local font = media:Fetch("font", self.db.char.Font)
		for k, fontObject in pairs(self.strings) do
			fontObject:SetFontObject(GameFontNormal)
			fontObject:SetFont(font, self.db.char.Size, self.db.char.FontEffect)
			fontObject:SetJustifyH("LEFT")
			fontObject:SetJustifyV("MIDDLE")
		end
		self.strings.spString:SetText(" ")
		self.strings.spString:SetHeight(self.strings.spString:GetStringHeight())
		self.strings.spString:SetText("")
		self:SetTextAnchors()
		self:SetStringColors()
	end
	if ((event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_ENTERING_WORLD")) then
		self.tsframe:SetAlpha(self.db.char.outOfCombatAlpha)
		isInFight = false
	end
	if (event == "PLAYER_REGEN_DISABLED") then
		self.tsframe:SetAlpha(self.db.char.inCombatAlpha)
		isInFight = true
	end
	if (self.db.char.FrameLocked == true) then
		local fixed = "|cffFF0000"..L["Text is fixed. Uncheck Lock Frame in the options to move!"].."|r"
		self.tsframe:SetScript("OnDragStart", function() DEFAULT_CHAT_FRAME:AddMessage(fixed) end)
	end
	if (event == "UNIT_AURA" and arg1 == "player") then
		self:ScheduleTimer("Stats", .8)
	end
  	self:Stats()
end