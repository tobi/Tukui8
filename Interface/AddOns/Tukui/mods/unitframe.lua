--[[--------------------------------------------------------------------
	oUF_Tukz
	
	I'd like to thank Haste for his awesome oUF framework, without which 
	this layout would do absolutely nothing. I'd also like to thank Caellian 
	for his cleanly written oUF_Caellian which helped me as a guide to write 
	this layout. 

	Supported Units:
		Player
		Pet
		Target
		Target Target
		Focus
		Party 
		Vehicule
		Raid10
		Raid25
		Raid40
		Raid15

	Required Dependencies:
		oUF
	
----------------------------------------------------------------------]]

------------------------------------------------------------------------
--	Layout Start here
------------------------------------------------------------------------

------------------------------------------------------------------------
--	Textures and Medias
------------------------------------------------------------------------

local settings = Tukz.oUF
local mediaPath = [=[Interface\Addons\Tukui\media\]=]

local floor = math.floor
local format = string.format

local normTex = mediaPath..[=[normTex]=]
local glowTex = mediaPath..[=[glowTex]=]
local bubbleTex = mediaPath..[=[bubbleTex]=]
local buttonTex = mediaPath..[=[buttonTex]=]
local highlightTex = mediaPath..[=[highlightTex]=]
local borderTex = mediaPath..[=[border]=]

local backdrop = {
	bgFile = BLANK_TEXTURE,
	insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local backdrop2 = {
	bgFile = BLANK_TEXTURE,
	edgeFile = BLANK_TEXTURE, 
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local font = settings.font
local fontn = mediaPath..[=[Russel Square LT.ttf]=]
local font2 = [=[Fonts\ARIALN.ttf]=]
local _, class = UnitClass("player")


local playerdebuffsonly = settings.playerdebuffsonly
local auratextscale = settings.auratextscale
local totdebuffs = settings.totdebuffs
local unitcastbar = settings.unitcastbar
local targetpowerpvponly = settings.targetpowerpvponly
local cblatency = settings.cblatency
local auratimer = settings.auratimer
local lowThreshold = settings.lowThreshold
local highThreshold = settings.highThreshold
local hidefocustarget = settings.showfocustarget
local showtotalhpmp = settings.showtotalhpmp
local cbicons = settings.cbicons
local debuffcolorbytype = settings.debuffcolorbytype

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

local colors = setmetatable({
	power = setmetatable({
		["MANA"] = {0.31, 0.45, 0.63},
		["RAGE"] = {0.69, 0.31, 0.31},
		["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {0.65, 0.63, 0.35},
		["RUNES"] = {0.55, 0.57, 0.61},
		["RUNIC_POWER"] = {0, 0.82, 1},
		["AMMOSLOT"] = {0.8, 0.6, 0},
		["FUEL"] = {0, 0.55, 0.5},
		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	}, {__index = oUF.colors.power}),
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {__index = oUF.colors.happiness}),
	runes = setmetatable({
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.33, 0.59, 0.33},
		[3] = {0.31, 0.45, 0.63},
		[4] = {0.84, 0.75, 0.65},
	}, {__index = oUF.colors.runes}),
}, {__index = oUF.colors})

oUF.colors.tapped = {0.55, 0.57, 0.61}
oUF.colors.disconnected = {0.84, 0.75, 0.65}

oUF.colors.smooth = {0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.15, 0.15, 0.15}

local runeloadcolors = {
	[1] = {.69,.31,.31},
	[2] = {.69,.31,.31},
	[3] = {.33,.59,.33},
	[4] = {.33,.59,.33},
	[5] = {.31,.45,.63},
	[6] = {.31,.45,.63},
}

------------------------------------------------------------------------
--	Fonction (don't edit this if you don't know what you are doing!)
------------------------------------------------------------------------

local SetUpAnimGroup = function(self)
	self.anim = self:CreateAnimationGroup("Flash")
	self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
	self.anim.fadein:SetChange(1)
	self.anim.fadein:SetOrder(2)

	self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
	self.anim.fadeout:SetChange(-1)
	self.anim.fadeout:SetOrder(1)
end

local Flash = function(self, duration)
	if not self.anim then
		SetUpAnimGroup(self)
	end

	self.anim.fadein:SetDuration(duration)
	self.anim.fadeout:SetDuration(duration)
	self.anim:Play()
end

local StopFlash = function(self)
	if self.anim then
		self.anim:Finish()
	end
end

local Menu = function(self)
	local unit = self.unit:gsub("(.)", string.upper, 1) 
	if _G[unit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
	elseif (self.unit:match("party")) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

local SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1.25, -1.25)
	return fs
end

local ShortValue = function(value)
	if value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end
end

local PostUpdateHealth = function(self, event, unit, bar, min, max)
	if not UnitIsConnected(unit) then
		bar:SetValue(0)
		bar.value:SetText("|cffD7BEA5"..ouf_offline.."|r")
	elseif UnitIsDead(unit) then
		bar.value:SetText("|cffD7BEA5"..ouf_dead.."|r")
	elseif UnitIsGhost(unit) then
		bar.value:SetText("|cffD7BEA5"..ouf_ghost.."|r")
	else
		if min ~= max then
			local r, g, b
			r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			if unit == "player" and self:GetAttribute("normalUnit") ~= "pet" then
				if showtotalhpmp == true then
					bar.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", ShortValue(min), ShortValue(max))
				else
					bar.value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", min, r * 255, g * 255, b * 255, floor(min / max * 100))
				end
			elseif unit == "target" then
				if showtotalhpmp == true then
					bar.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", ShortValue(min), ShortValue(max))
				else
					bar.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
				end
			else
				bar.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
			end
		else
			if unit ~= "player" and unit ~= "pet" then
				bar.value:SetText("|cff559655"..ShortValue(max).."|r")
			else
				bar.value:SetText("|cff559655"..max.."|r")
			end
		end
	end
end

local PostNamePosition = function(self)
	self.Info:ClearAllPoints()
	if (self.Power.value:GetText() and UnitIsEnemy("player", "target") and targetpowerpvponly == true) or (self.Power.value:GetText() and targetpowerpvponly == false) then
		self.Info:SetPoint("CENTER", 0, -32.5)
	else
		self.Power.value:SetAlpha(0)
		self.Info:SetPoint("LEFT", 4, -32.5)
	end
end

local PreUpdatePower = function(self, event, unit)
	if(self.unit ~= unit) then return end
	local _, pType = UnitPowerType(unit)
	
	local color = self.colors.power[pType]
	if color then
		self.Power:SetStatusBarColor(color[1], color[2], color[3])
	end
end

local PostUpdatePower = function(self, event, unit, bar, min, max)
	if self.unit ~= "player" and self.unit ~= "pet" and self.unit ~= "target" then return end

	local pType, pToken = UnitPowerType(unit)
	local color = colors.power[pToken]

	if color then
		bar.value:SetTextColor(color[1], color[2], color[3])
	end

	if min == 0 then
		bar.value:SetText()
	elseif not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit) then
		bar.value:SetText()
	elseif UnitIsDead(unit) or UnitIsGhost(unit) then
		bar.value:SetText()
	elseif min == max and (pType == 2 or pType == 3 and pToken ~= "POWER_TYPE_PYRITE") then
		bar.value:SetText()
	else
		if min ~= max then
			if pType == 0 then
				if unit == "target" then
					if showtotalhpmp == true then
						bar.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
					else
						bar.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), ShortValue(max - (max - min)))
					end
				elseif unit == "player" and self:GetAttribute("normalUnit") == "pet" or unit == "pet" then
					if showtotalhpmp == true then
						bar.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
					else
						bar.value:SetFormattedText("%d%%", floor(min / max * 100))
					end
				else
					if showtotalhpmp == true then
						bar.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
					else
						bar.value:SetFormattedText("%d%% |cffD7BEA5-|r %d", floor(min / max * 100), max - (max - min))
					end
				end
			else
				bar.value:SetText(max - (max - min))
			end
		else
			if unit == "pet" or unit == "target" then
				bar.value:SetText(ShortValue(min))
			else
				bar.value:SetText(min)
			end
		end
	end
	if self.Info then
		if self.unit == "target" then PostNamePosition(self) end
	end
end

do
	local f = CreateFrame("Frame")
	local entering

	f:RegisterEvent("UNIT_ENTERED_VEHICLE")
	f:RegisterEvent("UNIT_EXITED_VEHICLE")
	
	local delay = 0.5
	local OnUpdate = function(self, elapsed)
		self.elapsed = (self.elapsed or delay) - elapsed
		if self.elapsed <= 0 then
			local petframe = oUF_Tukz_pet
			petframe:PLAYER_ENTERING_WORLD()
			self:SetScript("OnUpdate", nil)
			if entering and petframe.PostEnterVehicle then
				petframe:PostEnterVehicle("enter")
			elseif not entering and petframe.PostExitVehicle then
				petframe:PostExitVehicle("exit")
			end
		end
	end

	f:SetScript("OnEvent", function(self, event, unit)
		if unit == "player" then
			if event == "UNIT_ENTERED_VEHICLE" then
				entering = true
			else
				entering = false
			end
			f.elapsed = delay
			f:SetScript("OnUpdate", OnUpdate)
		end
	end)
end

local EnterVehicle = function(self, event)
	if event == "enter" then
		self.Info:Hide()
	end
end

local ExitVehicle = function(self, event)
	if event == "exit" then
		self.Info:Show()
	end
end

local delay = 0
local viperAspectName = GetSpellInfo(34074)
local UpdateManaLevel = function(self, elapsed)
	delay = delay + elapsed
	if self.parent.unit ~= "player" or delay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end
	delay = 0

	local percMana = UnitMana("player") / UnitManaMax("player") * 100

	if AotV then
		local viper = UnitBuff("player", viperAspectName)
		if percMana >= highThreshold and viper then
			self.ManaLevel:SetText("|cffaf5050GO HAWK|r")
			Flash(self, 0.3)
		elseif percMana <= lowThreshold and not viper then
			self.ManaLevel:SetText("|cffaf5050GO VIPER|r")
			Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			StopFlash(self)
		end
	else
		if percMana <= lowThreshold then
			self.ManaLevel:SetText("|cffaf5050"..ouf_lowmana.."|r")
			Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			StopFlash(self)
		end
	end
end

local UpdateDruidMana = function(self)
	if self.unit ~= "player" then return end

	local num, str = UnitPowerType("player")
	if num ~= 0 then
		local min = UnitPower("player", 0)
		local max = UnitPowerMax("player", 0)

		local percMana = min / max * 100
		if percMana <= lowThreshold then
			self.FlashInfo.ManaLevel:SetText("|cffaf5050"..ouf_lowmana.."|r")
			Flash(self.FlashInfo, 0.3)
		else
			self.FlashInfo.ManaLevel:SetText()
			StopFlash(self.FlashInfo)
		end

		if min ~= max then
			if self.Power.value:GetText() then
				self.DruidMana:SetPoint("LEFT", self.Power.value, "RIGHT", 1, 0)
				self.DruidMana:SetFormattedText("|cffD7BEA5-|r %d%%|r", floor(min / max * 100))
			else
				self.DruidMana:SetPoint("LEFT", 4, -32.5)
				self.DruidMana:SetFormattedText("%d%%", floor(min / max * 100))
			end
		else
			self.DruidMana:SetText()
		end

		self.DruidMana:SetAlpha(1)
	else
		self.DruidMana:SetAlpha(0)
	end
end

local UpdateCPoints = function(self, event, unit)
	if unit == PlayerFrame.unit and unit ~= self.CPoints.unit then
	--if oUF_Tukz_player.unit == unit or PlayerFrame.unit == unit then
		self.CPoints.unit = unit
	end
end

local FormatCastbarTime = function(self, duration)
	if self.channeling then
		self.Time:SetFormattedText("%.1f ", duration)
	elseif self.casting then
		self.Time:SetFormattedText("%.1f ", self.max - duration)
	end
end

local UpdateReputationColor = function(self, event, unit, bar)
	local name, id = GetWatchedFactionInfo()
	bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 1)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 1)), s % hour
	elseif s >= minute then
		if s <= minute * 1 then
			return format('%d:%02d', floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 1)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 1), s - floor(s)
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

local CreateAuraTimer = function(self,elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
--				if type(time) == "string" or time >= 10 then
					self.remaining:SetText(time)
--				else
--					self.remaining:SetFormattedText("%.1f", time)
--				end
				self.remaining:SetTextColor(0.84, 0.75, 0.65)
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

local HideAura = function(self)
	if self.unit == "player" then
		if settings.noPlayerAuras then
			self.Buffs:Hide()
			self.Debuffs:Hide()
		else
			BuffFrame:Hide()
			TemporaryEnchantFrame:Hide()
		end
	elseif self.unit == "pet" and settings.noPetAuras then
		self.Auras:Hide()
	elseif self.unit == "target" and settings.noTargetAuras then
		self.Buffs:Hide()
		self.Debuffs:Hide()
	end
end

local CancelAura = function(self, button)
	if button == "RightButton" and not self.debuff then
		CancelUnitBuff("player", self:GetID())
	end
end

local CreateAura = function(self, button, icons)
	button.backdrop = CreateFrame("Frame", nil, button)
	button.backdrop:SetPoint("TOPLEFT", button, "TOPLEFT", -3.5, 3)
	button.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -3.5)
	button.backdrop:SetFrameStrata("BACKGROUND")
	button.backdrop:SetBackdrop {
		edgeFile = glowTex, edgeSize = 5,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	button.backdrop:SetBackdropColor(0, 0, 0, 0)
	button.backdrop:SetBackdropBorderColor(0, 0, 0)

	button.count:SetPoint("BOTTOMRIGHT", -1, 2)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(fontn, 10, "OUTLINE")
	button.count:SetTextColor(0.84, 0.75, 0.65)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	icons.disableCooldown = true
	icons.showDebuffType = true

	button.overlay:SetTexture(buttonTex)
	button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
	button.overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	button.overlay:SetTexCoord(0, 1, 0.02, 1)
	button.overlay.Hide = function(self) end

	if icons ~= self.Enchant then
		button.remaining = SetFontString(button, fontn, auratextscale, "OUTLINE")
		if self.unit == "player" then
			button:SetScript("OnMouseUp", CancelAura)
		end
	else
		button.remaining = SetFontString(button, fontn, auratextscale, "OUTLINE")
		button.overlay:SetVertexColor(0.33, 0.59, 0.33)
	end
	button.remaining:SetPoint("TOPLEFT", 1, -1)
end

local CreateEnchantTimer = function(self, icons)
	for i = 1, 2 do
		local icon = icons[i]
		if icon.expTime then
			icon.timeLeft = icon.expTime - GetTime()
			icon.remaining:Show()
		else
			icon.remaining:Hide()
		end
		icon:SetScript("OnUpdate", CreateAuraTimer)
	end
end

local UpdateAura = function(self, icons, unit, icon, index)
	local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
	if unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle" then
		if icon.debuff and debuffcolorbytype == false then
			icon.overlay:SetVertexColor(0.69, 0.31, 0.31)
		elseif icon.debuff and debuffcolorbytype == true then
			-- do nothing, color by type
		else
			icon.overlay:SetVertexColor(1, 1, 1)
		end
	else
		if UnitIsEnemy("player", unit) then
			if icon.debuff then
				icon.icon:SetDesaturated(true)
			end
		end
		icon.overlay:SetVertexColor(1, 1, 1)
	end

	if duration and duration > 0 then
		if auratimer == true then
		icon.remaining:Show()
		else
		icon.remaining:Hide()
		end
	else
		icon.remaining:Hide()
	end

	icon.duration = duration
	icon.timeLeft = expirationTime
	icon.first = true
	icon:SetScript("OnUpdate", CreateAuraTimer)
end

local HidePortrait = function(self, unit)
	if self.unit == "target" then
		if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
			self.Portrait:SetAlpha(0)
		else
			self.Portrait:SetAlpha(1)
		end
	end
end

local PostUpdateThreat = function(self, event, unit, status)
	if not status or status == 0 then
		self.ThreatFeedbackFrame:SetBackdropBorderColor(0, 0, 0)
		self.ThreatFeedbackFrame:Show()
	end
end

------------------------------------------------------------------------
--	Layout Style
------------------------------------------------------------------------

------------------------------------------------------------------------
--	Health and Power and LuaTexts
------------------------------------------------------------------------

local SetStyle = function(self, unit)
	self.menu = Menu
	self.colors = colors
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("type2", "menu")

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)
	self.MoveableFrames = true
	self.Health = CreateFrame("StatusBar", self:GetName().."_Health", self)
	if unit then
		self.Health:SetFrameLevel(5)
	elseif self:GetAttribute("unitsuffix") then
		self.Health:SetFrameLevel(5)
	elseif not unit then
		self.Health:SetFrameLevel(2)
	end
	
	self.Health:SetHeight((unit == "player" or unit == "target") and 26  
	or self:GetParent():GetName():match("oUF_Party") and 37
		or (unit == "focus") and 19
		or (unit == "targettarget" or unit == "focustarget") and 18
		or (unit == "pet") and 16
		or (unit and unit:find("arena%d")) and 22
		or self:GetAttribute("unitsuffix") == "pet" and 10 or 16)
	
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(normTex)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	if showsmooth == true then
		self.Health.colorSmooth = true
		self.Health.Smooth = true
	end	
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	self.Health.colorClassPet = false    
	self.Health.colorClass = true
	
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(normTex)
    self.Health.bg:SetAlpha(1)
	self.Health.bg.multiplier = 0.3


	
	self.Health.value = SetFontString(self.Health, font,(unit == "player" or unit == "target") and 12 or 12)
	if unit == "player" or unit == "target" then
		self.Health.value:SetPoint("RIGHT", -4, -32.5)
	else
		self.Health.value:Hide()
	end

	if unit ~= "player" then
		self.Info = SetFontString(self.Health, font, unit == "target" and 12 or 12)
		if unit == "target" then
			self.Info:SetPoint("LEFT", 1, 0)
			self:Tag(self.Info, "[GetNameColor][NameLong] [DiffColor][level] [shortclassification]")
		elseif (unit and unit:find("arena%d")) then
			self.Info = SetFontString(self.Health, font, 12, "OUTLINE")
			self.Info:SetPoint("CENTER", 0, 1)
			self:Tag(self.Info, "[GetNameColor][NameLong]")
		elseif (self:GetParent():GetName():match"oUF_MainTank" or self:GetParent():GetName():match"oUF_MainAssist") then
			self.Info = SetFontString(self.Health, font, 12, "OUTLINE")
			self.Info:SetPoint("CENTER", 0, 1)
			self:Tag(self.Info, "[GetNameColor][NameLong]")		
		elseif unit == "pet" then
			self.Info:SetPoint("CENTER", 0, -23)
			self:Tag(self.Info, "[GetNameColor][NameLong] [DiffColor][level] [shortclassification]")
		elseif unit == "targettarget" then
			self.Info = SetFontString(self.Health, font, unit == "targettarget" and 11 or 11)
			self.Info:SetPoint("CENTER", 0, -18)
			self:Tag(self.Info, "[GetNameColor][NameMedium]")
		elseif unit == "focustarget" then
			self.Info = SetFontString(self.Health, font, unit == "focustarget" and 11 or 11)
			self.Info:SetPoint("CENTER", 0, -18)
			self:Tag(self.Info, "[GetNameColor][NameMedium]")
		else
			self.Info:SetPoint("CENTER", 1, 1)
			self:Tag(self.Info, "[NameMedium]")
		end
	end

	if not (self:GetAttribute("unitsuffix") == "pet") then
		self.Power = CreateFrame("StatusBar", self:GetName().."_Power", self)
		self.Power:SetHeight((unit == "player" or unit == "target") and 8 or 5)
		self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
		self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
		self.Power:SetStatusBarTexture(normTex)
		if (unit and unit:find("arena%d")) then
			self.Power:SetHeight(6)
		end
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorPower = true
		self.Power.colorClass = true
		self.Power.colorReaction = true

		self.Power.frequentUpdates = true
		if showsmooth == true then
			self.Power.Smooth = true
		end
		self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetTexture(normTex)
		self.Power.bg:SetAlpha(1)
		self.Power.bg.multiplier = 0.4

		self.Power.value = SetFontString(self.Health, font, (unit == "player" or unit == "target") and 12 or 12)
			if (unit == "player") or (unit == "target" and targetpowerpvponly == true) or (unit == "target" and targetpowerpvponly == false) then
				self.Power.value:SetPoint("LEFT", 4, -32.5)
			else
				self.Power.value:Hide()
			end
	end

	if unit == "player" then
		self.Combat = self.Health:CreateTexture(nil, "OVERLAY")
		self.Combat:SetHeight(24)
		self.Combat:SetWidth(24)
		self.Combat:SetPoint("CENTER")
		self.Combat:SetVertexColor(0.69, 0.31, 0.31)

		self.FlashInfo = CreateFrame("Frame", "FlashInfo", self)
		self.FlashInfo:SetScript("OnUpdate", UpdateManaLevel)
		self.FlashInfo.parent = self
		self.FlashInfo:SetToplevel(true)
		self.FlashInfo:SetAllPoints(self.Health)

		self.FlashInfo.ManaLevel = SetFontString(self.FlashInfo, font, 12)
		self.FlashInfo.ManaLevel:SetPoint("CENTER", 0, -32.5)
		
		if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
			self.Resting = self.Health:CreateTexture(nil, "OVERLAY")
			self.Resting:SetHeight(20)
			self.Resting:SetWidth(20)
			self.Resting:SetPoint("TOPLEFT", 2.5, -2)
			self.Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			self.Resting:SetTexCoord(0, 0.5, 0, 0.421875)
		end
		
		self.Status = SetFontString(self.Power, font, 12)
		self.Status:SetPoint("CENTER", 0, -14)
		self.Status:SetTextColor(0.69, 0.31, 0.31, 0)
		self:Tag(self.Status, "[pvp]")
	
		self:SetScript("OnEnter", function(self) self.FlashInfo.ManaLevel:Hide() self.Status:SetAlpha(1); UnitFrame_OnEnter(self) end)
		self:SetScript("OnLeave", function(self) self.FlashInfo.ManaLevel:Show() self.Status:SetAlpha(0); UnitFrame_OnLeave(self) end)

------------------------------------------------------------------------
--	Runes 
------------------------------------------------------------------------	
	
		if class == "DEATHKNIGHT" then
			self.Runes = CreateFrame('Frame', nil, self)
			self.Runes:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 0.5)
			self.Runes:SetHeight(8)
			self.Runes:SetWidth(250)
			self.Runes:SetBackdrop(backdrop)
			self.Runes:SetBackdropColor(0.08, 0.08, 0.08)
			self.Runes.anchor = "TOPLEFT"
			self.Runes.growth = "RIGHT"
            self.Runes.height = 7
            self.Runes.width = 250 / 6 - 0.85
            self.Runes.spacing = 1
			self.Runes.runeMap = {[3] = 3} 

			for i = 1, 6 do
				self.Runes[i] = CreateFrame('StatusBar', nil, self.Runes)
				self.Runes[i]:SetStatusBarTexture(normTex)
				self.Runes[i]:SetStatusBarColor(unpack(runeloadcolors[i]))	
			end

			self.Runes.FrameBackdrop = CreateFrame("Frame", nil, self.Runes)
			self.Runes.FrameBackdrop:SetPoint("TOPLEFT", self.Runes, "TOPLEFT", -3.5, 3)
			self.Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", self.Runes, "BOTTOMRIGHT", 3.5, -3)
			self.Runes.FrameBackdrop:SetFrameStrata("BACKGROUND")
			self.Runes.FrameBackdrop:SetBackdrop {
				edgeFile = glowTex, edgeSize = 5,
				insets = {left = 3, right = 3, top = 3, bottom = 3}
			}
			self.Runes.FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
			self.Runes.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)
		end

------------------------------------------------------------------------
--	Extra condition (druid mana in cat and bear form)
------------------------------------------------------------------------

		if class == "DRUID" then
			CreateFrame("Frame"):SetScript("OnUpdate", function() UpdateDruidMana(self) end)
			self.DruidMana = SetFontString(self.Health, font, 12)
			self.DruidMana:SetTextColor(1, 0.49, 0.04)
		end
	end

------------------------------------------------------------------------
--	Vehicule Swap
------------------------------------------------------------------------

	if unit == "pet" then
		self.PostEnterVehicle = EnterVehicle
		self.PostExitVehicle = ExitVehicle
	end

------------------------------------------------------------------------
--	Experience / reputation
------------------------------------------------------------------------	

	if unit == "player" or unit =="pet" then
			self.Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
			self.Experience:SetStatusBarTexture(normTex)
			self.Experience:SetStatusBarColor(0.55, 0.57, 0.61)
			self.Experience:SetBackdrop(backdrop)
			self.Experience:SetBackdropColor(0, 0, 0)
			if unit == "player" then
				self.Experience:SetHeight(17)
				self.Experience:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 2, -3)
				self.Experience:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", -2, -3)
			elseif unit == "pet" then
				self.Experience:SetHeight(14)
				self.Experience:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -25)
				self.Experience:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, 4)
			end
			self.Experience:SetAlpha(0)

			self.Experience:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
			self.Experience:HookScript("OnLeave", function(self) self:SetAlpha(0) end)

			self.Experience.bg = self.Experience:CreateTexture(nil, "BORDER")
			self.Experience.bg:SetAllPoints(self.Experience)
			self.Experience.bg:SetTexture(normTex)
			self.Experience.bg:SetVertexColor(0.15, 0.15, 0.15)

			self.Experience.Tooltip = true
	end

	if unit == "player" then
		if UnitLevel("player") == MAX_PLAYER_LEVEL then
			self.Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self.Power)
			self.Reputation:SetHeight(17)
			self.Reputation:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 2, -3)
			self.Reputation:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", -2, -3)
			self.Reputation:SetStatusBarTexture(normTex)
			self.Reputation:SetBackdrop(backdrop)
			self.Reputation:SetBackdropColor(0, 0, 0)
			self.Reputation:SetAlpha(0)

			self.Reputation:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
			self.Reputation:HookScript("OnLeave", function(self) self:SetAlpha(0) end)

			self.Reputation.bg = self.Reputation:CreateTexture(nil, "BORDER")
			self.Reputation.bg:SetAllPoints(self.Reputation)
			self.Reputation.bg:SetTexture(normTex)
			self.Reputation.bg:SetVertexColor(0.15, 0.15, 0.15)

			self.Reputation.PostUpdate = UpdateReputationColor
			self.Reputation.Tooltip = true
		end
	end
	
------------------------------------------------------------------------
--   Threat Bar (this idea is from Zakriel)
------------------------------------------------------------------------
	if showthreat == true then
	   if unit == "player" then
		  self.ThreatBar = CreateFrame("StatusBar", self:GetName()..'_ThreatBar', UIParent)
		  self.ThreatBar:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 34, 20)
		  self.ThreatBar:SetHeight(19)
		  self.ThreatBar:SetWidth(tinfowidth - 4)
		  
		  self.ThreatBar:SetStatusBarTexture(normTex)
		  self.ThreatBar:SetBackdrop(backdrop)
		  self.ThreatBar:SetBackdropColor(0, 0, 0, 0)
	   
		  self.ThreatBar.Text = SetFontString(self.ThreatBar, font2, 12)
		  self.ThreatBar.Text:SetPoint("RIGHT", self.ThreatBar, "RIGHT", -30, 1 )
	
		  self.ThreatBar.Title = SetFontString(self.ThreatBar, font2, 12)
		  self.ThreatBar.Title:SetText(ouf_threattext)
		  self.ThreatBar.Title:SetPoint("LEFT", self.ThreatBar, "LEFT", 30, 1 )
				  
		  self.ThreatBar.bg = self.ThreatBar:CreateTexture(nil, 'BORDER')
		  self.ThreatBar.bg:SetAllPoints(self.ThreatBar)
		  self.ThreatBar.bg:SetTexture(0.1,0.1,0.1)
	   
		  self.ThreatBar.useRawThreat = false
	   end
	end
	
------------------------------------------------------------------------
--   Totems
------------------------------------------------------------------------   

    if class == "SHAMAN" and unit == "player" then
        self.TotemBar = {}
            for i = 1, 4 do
                self.TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self.Health)
                if (i == 1) then
                   self.TotemBar[i]:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 1)
                else
                   self.TotemBar[i]:SetPoint("TOPLEFT", self.TotemBar[i-1], "TOPRIGHT", 1, 0)
                end
                self.TotemBar[i]:SetStatusBarTexture(normTex)
                self.TotemBar[i]:SetHeight(8)
                self.TotemBar[i]:SetWidth(250 / 4 - 0.85)
                self.TotemBar[i]:SetBackdrop(backdrop)
                self.TotemBar[i]:SetBackdropColor(0, 0, 0)
                self.TotemBar[i]:SetMinMaxValues(0, 1)

                self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
                self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
                self.TotemBar[i].bg:SetTexture(normTex)
                self.TotemBar[i].bg.multiplier = 0.6
                				
				self.TotemBar[i].FrameBackdrop = CreateFrame("Frame", nil, self.TotemBar[i])
				self.TotemBar[i].FrameBackdrop:SetPoint("TOPLEFT", self.TotemBar[i], "TOPLEFT", -3.5, 3.5)
				self.TotemBar[i].FrameBackdrop:SetPoint("BOTTOMRIGHT", self.TotemBar[i], "BOTTOMRIGHT", 3.5, -3)
				self.TotemBar[i].FrameBackdrop:SetFrameStrata("BACKGROUND")
				self.TotemBar[i].FrameBackdrop:SetBackdrop {
					edgeFile = glowTex, edgeSize = 4,
					insets = {left = 3, right = 3, top = 3, bottom = 3}
				}
				self.TotemBar[i].FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
				self.TotemBar[i].FrameBackdrop:SetBackdropBorderColor(0, 0, 0)
            end
    end

------------------------------------------------------------------------
--	Auras
------------------------------------------------------------------------	
	
	if unit == "player" or unit == "target" or unit == "targettarget" then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetHeight(26)
		self.Debuffs:SetWidth(250)
		self.Debuffs.size = 26
		self.Debuffs.spacing = 2
		self.Debuffs.num = 36
		self.Debuffs.numDebuffs = 36

		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetHeight(26)
		self.Buffs:SetWidth(250)
		self.Buffs.size = 26
		self.Buffs.spacing = 2
		self.Buffs.num = 9
		self.Buffs.numBuffs = 9
		
			if unit == "player" then
				self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -0.5, 30)
				self.Buffs.initialAnchor = "TOPLEFT"
				self.Buffs["growth-y"] = "UP"	
				self.Debuffs:SetPoint("TOPLEFT", self, "TOPLEFT", -0.5, 60)
				self.Debuffs.initialAnchor = "TOPRIGHT"
				self.Debuffs["growth-y"] = "UP"
				self.Debuffs["growth-x"] = "LEFT"
			end
			if unit == "targettarget" and totdebuffs == true then
				self.Debuffs:SetHeight(20)
				self.Debuffs:SetWidth(22 * 6)
				self.Debuffs.size = 20
				self.Debuffs.spacing = 2
				self.Debuffs.num = 6
				self.Debuffs.numDebuffs = 6
							
				self.Debuffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0.5, 24)
				self.Debuffs.initialAnchor = "TOPLEFT"
				self.Debuffs["growth-y"] = "UP"
			end
			if unit == "target" then
				self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -0.5, 30)
				self.Buffs.initialAnchor = "TOPLEFT"
				self.Buffs["growth-y"] = "UP"

	
				self.Debuffs:SetPoint("TOPLEFT", self, "TOPLEFT", -0.5, 60)
				self.Debuffs.initialAnchor = "TOPRIGHT"
				self.Debuffs["growth-y"] = "UP"
				self.Debuffs["growth-x"] = "LEFT"
				self.Debuffs.onlyShowPlayer = playerdebuffsonly
	
				self.CPoints = {}
				self.CPoints.unit = PlayerFrame.unit
				for i = 1, 5 do
					self.CPoints[i] = self.Health:CreateTexture(nil, "OVERLAY")
					self.CPoints[i]:SetHeight(12)
					self.CPoints[i]:SetWidth(12)
					self.CPoints[i]:SetTexture(bubbleTex)
					if i == 1 then
						self.CPoints[i]:SetPoint("TOPLEFT", -15, 1.5)
						self.CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
					else
						self.CPoints[i]:SetPoint("TOP", self.CPoints[i-1], "BOTTOM", 1)
					end
				end
				self.CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
				self.CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
				self.CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
				self.CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
				self:RegisterEvent("UNIT_COMBO_POINTS", UpdateCPoints)
			end
			if(unit and unit:find("arena%d")) then
				self.Debuffs = CreateFrame("Frame", nil, self)
				self.Debuffs.num = 5
				self.Debuffs.size = 28
				self.Debuffs:SetPoint("TOPRIGHT", self, "TOPRIGHT", 34, -1)
				self.Debuffs.initialAnchor = "TOPRIGHT"
				self.Debuffs["growth-x"] = "RIGHT"
				self.Debuffs["growth-y"] = "DOWN"
				self.Debuffs:SetHeight(24)
				self.Debuffs:SetWidth(175)
				self.Debuffs.spacing = 3
			end			
			
			if (unit == "player" or unit == "target") and (charportrait == true) then
				self.Portrait = CreateFrame("PlayerModel", nil, self)
				self.Portrait:SetFrameLevel(8)
				self.Portrait:SetHeight(57)
				self.Portrait:SetWidth(33)
				self.Portrait:SetAlpha(1)
				if unit == "player" then
					self.Health:SetPoint("TOPLEFT", 34,0)
					self.Health:SetPoint("TOPRIGHT")
					self.Portrait:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -34,0)
				elseif unit == "target" then
					self.Health:SetPoint("TOPLEFT")
					self.Health:SetPoint("TOPRIGHT", -34,0)
					self.Portrait:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT", 34,0)
				end
				--self.Portrait:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, 35)
				--self.Portrait:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, 35)
				table.insert(self.__elements, HidePortrait)
			end

------------------------------------------------------------------------
--	Combat text over HealthBar
------------------------------------------------------------------------	

		self.CombatFeedbackText = SetFontString(self.Health, font, 18, "OUTLINE")
		self.CombatFeedbackText:SetPoint("CENTER", 0, 1)
		self.CombatFeedbackText.colors = {
			DAMAGE = {0.69, 0.31, 0.31},
			CRUSHING = {0.69, 0.31, 0.31},
			CRITICAL = {0.69, 0.31, 0.31},
			GLANCING = {0.69, 0.31, 0.31},
			STANDARD = {0.84, 0.75, 0.65},
			IMMUNE = {0.84, 0.75, 0.65},
			ABSORB = {0.84, 0.75, 0.65},
			BLOCK = {0.84, 0.75, 0.65},
			RESIST = {0.84, 0.75, 0.65},
			MISS = {0.84, 0.75, 0.65},
			HEAL = {0.33, 0.59, 0.33},
			CRITHEAL = {0.33, 0.59, 0.33},
			ENERGIZE = {0.31, 0.45, 0.63},
			CRITENERGIZE = {0.31, 0.45, 0.63},
		}

	end

------------------------------------------------------------------------
--	Castbar
------------------------------------------------------------------------	

	if not (self:GetAttribute("unitsuffix") == "pet") and (unitcastbar == true) then
		self.Castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
		self.Castbar:SetStatusBarTexture(normTex)
		self.Castbar:SetStatusBarColor(0.31, 0.45, 0.63, 0.5)

		self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.bg:SetAllPoints(self.Castbar)
		self.Castbar.bg:SetTexture(normTex)
		self.Castbar.bg:SetVertexColor(0.15, 0.15, 0.15)

		if unit == "player" then
			self.Castbar:SetFrameLevel(6)
			self.Castbar:SetHeight(17)
			self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 2, -3)
			self.Castbar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", -2, -3)
		elseif unit == "target" then
			self.Castbar:SetFrameLevel(6)
			self.Castbar:SetHeight(17)
			self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 2, -3)
			self.Castbar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", -2, -3)
		elseif unit == "focus" then
			self.Castbar:SetFrameLevel(6)
			self.Castbar:SetHeight(24)
			self.Castbar:SetWidth(240)
			self.Castbar:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
			self.Castbar:SetBackdrop(backdrop)
			self.Castbar:SetStatusBarColor(6/255, 137/255, 0/255)
			self.Castbar:SetBackdropColor(1,1,1,0.6)

		else
			self.Castbar:Hide()
		end

		if unit == "player" or unit == "target" or unit == "focus" then
			self.Castbar.Time = SetFontString(self.Castbar, font, 12)
			self.Castbar.Time:SetPoint("RIGHT", -2, 1)
			self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.Time:SetJustifyH("RIGHT")
			self.Castbar.CustomTimeText = FormatCastbarTime

			self.Castbar.Text = SetFontString(self.Castbar, font, 12)
			self.Castbar.Text:SetPoint("LEFT", 3, 1)
			self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -2, 2)
			self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			if cbicons == true then
				self.Castbar.Icon = self.Castbar:CreateTexture(nil, "ARTWORK")
				self.Castbar.Icon:SetHeight(28.5)
				self.Castbar.Icon:SetWidth(28.5)
				self.Castbar.Icon:SetTexCoord(0, 1, 0, 1)
				if unit == "player" then
					if charportrait == true then
						self.Castbar.Icon:SetPoint("LEFT", -82.5, 26.5)
					else
						self.Castbar.Icon:SetPoint("LEFT", -46.5, 26.5)
					end
				elseif unit == "target" then
					if charportrait == true then
						self.Castbar.Icon:SetPoint("RIGHT", 82.5, 26.5)
					else
						self.Castbar.Icon:SetPoint("RIGHT", 46.5, 26.5)
					end
				elseif unit == "focus" then
					self.Castbar.Icon:SetHeight(30)
					self.Castbar.Icon:SetWidth(30)
					self.Castbar.Icon:SetPoint("CENTER", 0, 40)
				end

				self.IconOverlay = self.Castbar:CreateTexture(nil, "OVERLAY")
				self.IconOverlay:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -1.5, 1)
				self.IconOverlay:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", 1, -1)
				self.IconOverlay:SetTexture(buttonTex)
				self.IconOverlay:SetVertexColor(1, 1, 1)

				self.IconBackdrop = CreateFrame("Frame", nil, self)
				self.IconBackdrop:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -4, 3)
				self.IconBackdrop:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", 3, -3.5)
				self.IconBackdrop:SetParent(self.Castbar)
				self.IconBackdrop:SetBackdrop({
				  edgeFile = glowTex, edgeSize = 4,
				  insets = {left = 3, right = 3, top = 3, bottom = 3}
				})
				self.IconBackdrop:SetBackdropColor(0, 0, 0, 0)
				self.IconBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
			end
		end
		
		if unit == "player" and cblatency == true then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.SafeZone:SetTexture(normTex)
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		end
	end

------------------------------------------------------------------------
--	Raid or Party Leader
------------------------------------------------------------------------

	if not unit or unit == "player" then
		self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetHeight(14)
		self.Leader:SetWidth(14)
		self.Leader:SetPoint("TOPLEFT", 0, 10)
	end
		
------------------------------------------------------------------------
--      Master Looter
------------------------------------------------------------------------

        if not unit or unit == "player" then
                self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
                self.MasterLooter:SetHeight(14)
                self.MasterLooter:SetWidth(14)
                local MLAnchorUpdate = function (self)
                        if self.Leader:IsShown() then
                                self.MasterLooter:SetPoint("TOPLEFT", 14, 10)
                        else
                                self.MasterLooter:SetPoint("TOPLEFT", 0, 10)
                        end
                end
                self:RegisterEvent("PARTY_LEADER_CHANGED", MLAnchorUpdate)
                self:RegisterEvent("PARTY_MEMBERS_CHANGED", MLAnchorUpdate)
        end

------------------------------------------------------------------------
--	Arena Trinket
------------------------------------------------------------------------	
	if t_arena == true then
		if (unit and unit:find('arena%d') and (not unit:find("arena%dtarget"))) then
			self.Trinket = CreateFrame("Frame", nil, self)
			self.Trinket:SetHeight(31)
			self.Trinket:SetWidth(31)
			self.Trinket:SetPoint("TOPRIGHT", self, "TOPLEFT", -4, 1)
		end
	end
------------------------------------------------------------------------
--	Unitframes Width/Height
------------------------------------------------------------------------

	if unit == "player" or unit == "target" then
		self:SetAttribute("initial-height", 57)
		self:SetAttribute("initial-width", 250)
	elseif unit == "targettarget" or unit == "focustarget" then
		self:SetAttribute("initial-height", 37)
		self:SetAttribute("initial-width", 131)
        self.Power:Hide()        
	elseif unit == "focus" then
		self:SetAttribute("initial-height", 19)
		self:SetAttribute("initial-width", tinfowidth - 4)
		self.Power:Hide()
	elseif unit == "pet" then
		self:SetAttribute("initial-height", 42)
		self:SetAttribute("initial-width", 131)
	elseif (unit and unit:find("arena%d")) then
		self:SetAttribute("initial-height", 29)
		self:SetAttribute("initial-width", 200)
	elseif(self:GetParent():GetName():match"oUF_MainTank" or self:GetParent():GetName():match"oUF_MainAssist") then
		if t_mt_power == true then
			self.Power:SetHeight(2)
			self.Power.value:Hide()
			self.Health:SetHeight(17)
		else
			self.Power:Hide()
			self.Health:SetHeight(20)
		end
		
		self:SetAttribute("initial-height", 20)
		self:SetAttribute("initial-width", 100)
	else
		self:SetAttribute("initial-height", 37)
		self:SetAttribute("initial-width", 249)		
	end
	
------------------------------------------------------------------------
--	RaidIcons
------------------------------------------------------------------------

		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetHeight(14)
		self.RaidIcon:SetWidth(14)
		self.RaidIcon:SetPoint("TOP", 0, 8)

------------------------------------------------------------------------
--	Background texture and textures border
------------------------------------------------------------------------

	self.FrameBackdrop = CreateFrame("Frame", nil, self)
	self.FrameBackdrop:SetPoint("TOPLEFT", self, "TOPLEFT", -4.5, 4)
	self.FrameBackdrop:SetFrameStrata("BACKGROUND")
	self.FrameBackdrop:SetBackdrop {
	  edgeFile = glowTex, edgeSize = 5,
	  insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	self.FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
	self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)

	if unit == "player" or unit == "target" then
	local Panel1 = CreateFrame("Frame", nil, self)
	Panel1:SetFrameLevel(20)
	Panel1:SetFrameStrata("MEDIUM")
	Panel1:SetHeight(21)
	Panel1:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
	Panel1:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, 1)
	Panel1:SetScale(1)
	Panel1:SetBackdrop(backdrop2)
	Panel1:SetBackdropColor(0.1,0.1,0.1,0)
	Panel1:SetBackdropBorderColor(0.4,0.4,0.4,1)
	self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -4)
	
	local Panel2 = CreateFrame("Frame", nil, self)
	Panel2:SetFrameLevel(2)
	Panel2:SetFrameStrata("MEDIUM")
	Panel2:SetHeight(21)
	Panel2:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 2, 1)
	Panel2:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", -2, -1)
	Panel2:SetScale(1)
	Panel2:SetBackdrop(backdrop2)
	Panel2:SetBackdropColor(0.1,0.1,0.1,1)
	Panel2:SetBackdropBorderColor(0.4,0.4,0.4,0)

	
	elseif unit == "targettarget" or unit == "focustarget" then
	local Panel3 = CreateFrame("Frame", nil, self)
	Panel3:SetFrameLevel(20)
	Panel3:SetFrameStrata("MEDIUM")
	Panel3:SetHeight(18)
	Panel3:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
	Panel3:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, 1)
	Panel3:SetScale(1)
	Panel3:SetBackdrop(backdrop2)
	Panel3:SetBackdropColor(0.1,0.1,0.1,0)
	Panel3:SetBackdropBorderColor(0.4,0.4,0.4,1)
	self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -4)
	
	local Panel4 = CreateFrame("Frame", nil, self)
	Panel4:SetFrameLevel(2)
	Panel4:SetFrameStrata("MEDIUM")
	Panel4:SetHeight(21)
	Panel4:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 2, 2)
	Panel4:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", -2, 2)
	Panel4:SetScale(1)
	Panel4:SetBackdrop(backdrop2)
	Panel4:SetBackdropColor(0.1,0.1,0.1,1)
	Panel4:SetBackdropBorderColor(0.4,0.4,0.4,0)
	
	elseif unit == "pet" then
	local Panel5 = CreateFrame("Frame", nil, self)
	Panel5:SetFrameLevel(20)
	Panel5:SetFrameStrata("MEDIUM")
	Panel5:SetHeight(18)
	Panel5:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
	Panel5:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, 1)
	Panel5:SetScale(1)
	Panel5:SetBackdrop(backdrop2)
	Panel5:SetBackdropColor(0.1,0.1,0.1,0)
	Panel5:SetBackdropBorderColor(0.4,0.4,0.4,1)
	self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -4)
	
	local Panel6 = CreateFrame("Frame", nil, self)
	Panel6:SetFrameLevel(2)
	Panel6:SetFrameStrata("MEDIUM")
	Panel6:SetHeight(21)
	Panel6:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 2, 2)
	Panel6:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", -2, 2)
	Panel6:SetScale(1)
	Panel6:SetBackdrop(backdrop2)
	Panel6:SetBackdropColor(0.1,0.1,0.1,1)
	Panel6:SetBackdropBorderColor(0.4,0.4,0.4,0)

	elseif unit =="focus" then
		self.FrameBackdrop:SetAlpha(0)
		self.Health.bg.multiplier = 0.13
	else
		self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -4.5)
	end
	self.ThreatFeedbackFrame = self.FrameBackdrop
	
	self.outsideRangeAlpha = 0.3
	self.inRangeAlpha = 1
	self.SpellRange = true

	self.BarFade = false


	self.PostUpdateHealth = PostUpdateHealth
	self.PreUpdatePower = PreUpdatePower
	self.PostUpdatePower = PostUpdatePower
	self.PostCreateAuraIcon = CreateAura
	self.PostCreateEnchantIcon = CreateAura
	self.PostUpdateAuraIcon = UpdateAura
	self.PostUpdateEnchantIcons = CreateEnchantTimer
	self.PostUpdateThreat = PostUpdateThreat

	self:SetScale(settings.scale)
	if self.Auras then self.Auras:SetScale(settings.scale) end
	if self.Buffs then self.Buffs:SetScale(settings.scale) end
	if self.Debuffs then self.Debuffs:SetScale(settings.scale) end

	HideAura(self)
	return self
end

oUF:RegisterStyle("Tukz", SetStyle)
oUF:SetActiveStyle("Tukz")

local cfg = settings.coords

oUF:Spawn("player", "oUF_Tukz_player"):SetPoint("BOTTOM", UIParent, cfg.playerX, cfg.playerY)
oUF:Spawn("target", "oUF_Tukz_target"):SetPoint("BOTTOM", UIParent, cfg.targetX, cfg.targetY)

oUF:Spawn("pet", "oUF_Tukz_pet"):SetPoint("BOTTOM", cfg.petX, cfg.petY)
oUF:Spawn("focus", "oUF_Tukz_focus"):SetPoint("BOTTOMRIGHT", cfg.focusX, cfg.focusY)
oUF:Spawn("targettarget", "oUF_Tukz_targettarget"):SetPoint("BOTTOM", cfg.totX, cfg.totY)
if hidefocustarget == true then oUF:Spawn("focustarget", "oUF_Tukz_focustarget"):SetPoint("BOTTOM", cfg.foctarX, cfg.foctarY) end

if t_arena == true then
	if not IsAddOnLoaded("Gladius") then
		local arena = {}
		for i = 1, 5 do
			arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
			if i == 1 then
				arena[i]:SetPoint("BOTTOM", UIParent, "BOTTOM", ArenaX, ArenaY)
			else
				arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 25)
			end
		end
	end
end

local party = oUF:Spawn("header", "oUF_PartyHide")
party:SetAttribute("showParty", false)

if t_mt == true then
	local tank = oUF:Spawn("header", "oUF_MainTank")
	tank:SetManyAttributes("showRaid", true, "groupFilter", "MAINTANK", "yOffset", 5, "point" , "BOTTOM")
	tank:SetPoint("BOTTOM", UIParent, "BOTTOM", MTX, MTY)
	tank:SetAttribute("template", "oUF_tukzMtt")
	tank:Show()

	local assist = oUF:Spawn("header", "oUF_MainAssist")
	assist:SetManyAttributes("showRaid", true, "groupFilter", "MAINASSIST", "yOffset", 5, "point", "BOTTOM")
	assist:SetPoint("TOP", tank, "BOTTOM", 0, -30)
	assist:SetAttribute("template", "oUF_tukzMtt")
	assist:Show()
end



