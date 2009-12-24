local mediaPath = [=[Interface\Addons\Tukui\media\]=]

local fontlol = [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=]
local normTex = mediaPath..[=[normTex]=]
local glowTex = mediaPath..[=[glowTex]=]
local bubbleTex = mediaPath..[=[bubbleTex]=]
local buttonTex = mediaPath..[=[buttonTex]=]
local highlightTex = mediaPath..[=[highlightTex]=]
local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -2, left = -2, bottom = -2, right = -2},
}

-- ------------------------------------------------------------------------
-- local and aurawatch mwahaha
-- ------------------------------------------------------------------------
local select = select
local UnitClass = UnitClass
local UnitIsDead = UnitIsDead
local UnitIsPVP = UnitIsPVP
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification
local UnitReactionColor = UnitReactionColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS


local function createAuraWatch(self,unit)
	local auras = CreateFrame("Frame", nil, self)
    auras:SetAllPoints(self.Health)
	local debuffs = spellIDs

    auras.presentAlpha = 1
    auras.missingAlpha = 0
    auras.icons = {}
    
    for i, sid in pairs(debuffs) do
      local icon = CreateFrame("Frame", nil, auras)
      icon.spellID = sid
	  local cd = CreateFrame("Cooldown", nil, icon)
		  cd:SetAllPoints(icon)
		  cd:SetReverse()
		  icon.cd = cd
      if i > 0 then
        icon.anyUnit = true
        icon:SetWidth(24)
        icon:SetHeight(24)
		cd:SetAlpha(0)
		local tex = icon:CreateTexture(nil, "OVERLAY")
		tex:SetAllPoints(icon)
        tex:SetTexture([=[Interface\AddOns\Tukui\media\aurawatch]=])
		tex:SetVertexColor(0.8, 0.8, 0.8)
		icon:SetPoint("CENTER",0,0)
		local count = icon:CreateFontString(nil, "OVERLAY")
        count:SetFont(fontlol, 12, "THINOUTLINE")
        count:SetPoint("CENTER", 6, 1)
        icon.count = count
	  end
      auras.icons[sid] = icon
    end
    self.AuraWatch = auras
end

-- ------------------------------------------------------------------------
-- reformat everything above 999 in raidframes
-- ------------------------------------------------------------------------
local numberize_raid = function(v)
	if v <= 999 then return v end
	if v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 1000 then
		local value = string.format("%.1fk", v/1000)
		return value
	end
end

-- ------------------------------------------------------------------------
-- aggro
-- ------------------------------------------------------------------------

local function UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then 
		return 
	end

	if (self.Aggro) then
		local threat = UnitThreatSituation(self.unit)
		if (threat == 3) then
			self.Aggro:SetText('|cFFFF0000AGGRO')
			self.Health:SetBackdropColor(0.9, 0, 0) 
		else
			self.Aggro:SetText('')
			self.Health:SetBackdropColor(0, 0, 0) 
		end
	end
end

-- ------------------------------------------------------------------------
-- name update
-- ------------------------------------------------------------------------
local updateName = function(self, event, unit)
	if(self.unit ~= unit) then return end

	local name = UnitName(unit)
    	self.Name:SetText(name)	

    if(self:GetParent():GetName():match"oUF_Group") then -- Truncate Names in Raidframes
	self.Name:SetText(string.sub(name,1,5))
    end
end

-- ------------------------------------------------------------------------
-- health update
-- ------------------------------------------------------------------------
local updateHealth = function(self, event, unit, bar, min, max)  
    local cur, maxhp = min, max
    local missing = maxhp-cur
    
    local d = floor(cur/maxhp*100)
    
	if(UnitIsDead(unit)) then
		bar:SetValue(0)
		bar.value:SetText(ouf_deadheal)
	elseif(UnitIsGhost(unit)) then
		bar:SetValue(0)
		bar.value:SetText(ouf_ghostheal)
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText"D/C"

	elseif(self:GetParent():GetName():match"oUF_Group") then
		if(d < 100) then
			bar.value:SetText("|cffFFFFFF".."-"..numberize_raid(missing))
		else
			bar.value:SetText(" ")
		end

    end

    self:UNIT_NAME_UPDATE(event, unit)
end

local function menu(self)
	if(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, 'cursor')
	end
end

local function CreateStyle(self, unit)

	self.menu = menu
	self.colors = colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self:SetAttribute('*type2', 'menu')
	self:SetAttribute('initial-height', 35)
	self:SetAttribute('initial-width', 55)

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, left = -1, bottom = -1, right = -1}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetAllPoints(self)
	if gridhealthvertical == true then
		self.Health:SetOrientation('VERTICAL')
	end
	self.Health:SetStatusBarTexture(normTex)
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	 

	self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	self.Health.bg:SetTexture(0.3, 0.3, 0.3)
	self.Health.bg.multiplier = (0.3)
		
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("CENTER", self.Health, 0, 7)
    self.Name:SetJustifyH("CENTER")
	self.Name:SetFont(fontlol, 11, "THINOUTLINE")
	self.Name:SetShadowOffset(1, -1)
    self.UNIT_NAME_UPDATE = updateName
	
	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetPoint("CENTER", self.Health, 0, -7)
	self.Health.value:SetFont(fontlol, 11, "THINOUTLINE")
	self.Health.value:SetTextColor(1,1,1)
	self.Health.value:SetShadowOffset(1, -1)
	
	
	if gridaggro == true then
		self.Aggro = self.Health:CreateFontString(nil, 'OVERLAY')
		self.Aggro:SetPoint('CENTER', self, 'TOP')
		self.Aggro:SetFont(fontlol, 11, 'OUTLINE')
		self.Aggro:SetShadowColor(0, 0, 0, 0)
		self.Aggro:SetTextColor(1, 1, 1)
		
		table.insert(self.__elements, UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)
	end

	if showsymbols == true then
		self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetHeight(18)
		self.RaidIcon:SetWidth(18)
		self.RaidIcon:SetPoint('CENTER', self, 'TOP')
		self.RaidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')	
	end
	
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	
	self.outsideRangeAlpha = 0.3
	self.inRangeAlpha = 1.0
	if showrange == true then
		self.Range = true
	else
		self.Range = false
	end

	if showsmooth == true then
		self.Health.Smooth = true
	end
	
	self.PostUpdateHealth = updateHealth
	
	if not unit and raidunitdebuffwatch == true then
		createAuraWatch(self,unit)
    end

end

oUF:RegisterStyle('hRaid40', CreateStyle)
oUF:SetActiveStyle('hRaid40')

--[[
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
strictFiltering = [BOOLEAN] - if true, then characters must match both a group and a class from the groupFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinate (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the ammount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
--]]


local raid = {}
for i = 1, 8 do
	local raidgroup = oUF:Spawn('header', 'oUF_Group'..i)
	raidgroup:SetManyAttributes('groupFilter', tostring(i), 'showRaid', true, 'xOffset', 4, "point", "LEFT")
	raidgroup:SetFrameStrata('BACKGROUND')	
	table.insert(raid, raidgroup)
	if(i == 1) then
		raidgroup:SetPoint(gridposZ, UIParent, gridposZ, gridposX, gridposY)
	else
		raidgroup:SetPoint('TOPLEFT', raid[i-1], 'BOTTOMLEFT', 0, -4)
	end
	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_LOGIN")
	raidToggle:RegisterEvent("RAID_ROSTER_UPDATE")
	raidToggle:RegisterEvent("PARTY_LEADER_CHANGED")
	raidToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
	raidToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		local numraid = GetNumRaidMembers()
		if gridonly == true then
			if numraid < 6 then
				raidgroup:Hide()
			else
				raidgroup:Show()
			end
		else
			if numraid < 16 then
				raidgroup:Hide()
			else
				raidgroup:Show()
			end
		end
	end
end)
end










