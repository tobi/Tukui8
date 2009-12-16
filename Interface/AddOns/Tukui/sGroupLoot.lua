--[[
	
	sGroupLoot
	Copyright (c) 2009, Nils Ruesch
	All rights reserved.
	
]]

UIParent:UnregisterEvent("START_LOOT_ROLL");
UIParent:UnregisterEvent("CANCEL_LOOT_ROLL");

local GFHCName, GFHCHeight = GameFontHighlightCenter:GetFont();
local grouplootlist, grouplootbars, grouplootrolls = {}, {}, {};
local rollstrings = { [(LOOT_ROLL_PASSED_AUTO):gsub("%%1$s", "(.+)"):gsub("%%2$s", "(.+)")] = "pass", [(LOOT_ROLL_PASSED_AUTO_FEMALE):gsub("%%1$s", "(.+)"):gsub("%%2$s", "(.+)")] = "pass", [(LOOT_ROLL_PASSED):gsub("%%s", "(.+)")] = "pass", [(LOOT_ROLL_GREED):gsub("%%s", "(.+)")] = "greed", [(LOOT_ROLL_NEED):gsub("%%s", "(.+)")] = "need", [(LOOT_ROLL_DISENCHANT):gsub("%%s", "(.+)")] = "dis" };

local function OnEvent(self, event, ...)
	if ( event == "CHAT_MSG_LOOT" ) then
		local msg = ...;
		for string, roll in pairs(rollstrings) do
			local _, _, player, item = string.find(msg, string);
			if ( player and item ) then
				local rollId;
				for index, value in ipairs(grouplootbars) do
					if ( value.rollId and item == value.rollLink ) then
						rollId = value.rollId;
						if ( not grouplootrolls[rollId] ) then
							grouplootrolls[rollId] = {};
						end
						if ( not grouplootrolls[rollId][roll] ) then
							grouplootrolls[rollId][roll] = {};
							grouplootrolls[rollId][roll].count = 0;
						end
						if ( not grouplootrolls[rollId][roll][player] ) then
							grouplootrolls[rollId][roll].count = grouplootrolls[rollId][roll].count+1;
							grouplootrolls[rollId][roll][player] = true;
						end
						if ( roll == "need" ) then
							value.needtext:SetText(grouplootrolls[rollId][roll].count);
						elseif ( roll == "greed" ) then
							value.greedtext:SetText(grouplootrolls[rollId][roll].count);
						elseif ( roll == "dis" ) then
							value.distext:SetText(grouplootrolls[rollId][roll].count);
						else
							value.passtext:SetText(grouplootrolls[rollId][roll].count);
						end
						return;
					end
				end
			end
		end
		return;
	end
	local rollId, rollTime = ...;
	table.insert(grouplootlist, { rollId = rollId, rollTime = rollTime });
	self:UpdateGroupLoot();
end

local function BarOnUpdate(self, elapsed)
	if ( self.rollId ) then
		local left = GetLootRollTimeLeft(self.rollId);
		local min, max = self:GetMinMaxValues();
		if ( (left < min) or (left > max) ) then
			left = min;
		end
		self:SetValue(left);
		
		if ( GameTooltip:IsOwned(self) ) then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
			GameTooltip:SetLootRollItem(self.rollId);
		end
		CursorOnUpdate(self);
	end
end

local function BarOnEvent(self, event, ...)
	local rollId = ...;
	if ( self.rollId and rollId == self.rollId ) then
		for index, value in ipairs(grouplootlist) do
			if ( self.rollId == value.rollId ) then
				tremove(grouplootlist, index);
				break;
			end
		end
		grouplootrolls[self.rollId] = nil;
		StaticPopup_Hide("CONFIRM_LOOT_ROLL", self.rollId);
		self.rollId = nil;
		sGroupLoot:UpdateGroupLoot();
	end
end

local function BarOnClick(self)
	HandleModifiedItemClick(self.rollLink);
end

local function BarOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip:SetLootRollItem(self.rollId);
	CursorUpdate(self);
end

local function BarOnLeave(self)
	GameTooltip:Hide();
	ResetCursor();
end

local function BarButtonOnClick(self, button)
	RollOnLoot(self:GetParent().rollId, self.type);
end

local function BarButtonOnEnter(self)
	local rolltext;
	if ( self.roll == "need" ) then
		rolltext = NEED;
	elseif ( self.roll == "greed" ) then
		rolltext = GREED;
	elseif ( self.roll == "dis" ) then
		rolltext = ROLL_DISENCHANT;
	else
		rolltext = PASS;
	end
	local rollId = self:GetParent().rollId;
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:SetText(rolltext);
	if ( grouplootrolls[rollId] and grouplootrolls[rollId][self.roll] ) then
		for index, value in pairs(grouplootrolls[rollId][self.roll]) do
			if ( index ~= "count" ) then
				GameTooltip:AddLine(index, 1, 1, 1);
			end
		end
	end
	GameTooltip:Show();
end

local function BarButtonOnLeave(self)
	GameTooltip:Hide();
end

local frame = CreateFrame("Frame", "sGroupLoot", UIParent);
frame:RegisterEvent("CHAT_MSG_LOOT");
frame:RegisterEvent("START_LOOT_ROLL");
frame:SetScript("OnEvent", OnEvent);

function frame:UpdateGroupLoot()
	for index, value in ipairs(grouplootbars) do
		value:Hide();
	end
	table.sort(grouplootlist, function(a, b)
		return a.rollId < b.rollId;
	end);
	local bar, texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDE, color;
	for index, value in ipairs(grouplootlist) do
		bar = grouplootbars[index];
		if ( not bar ) then
			bar = CreateFrame("StatusBar", "sGroupLootBar"..index, UIParent);
			bar:EnableMouse(1);
			bar:SetWidth(250);
			bar:SetHeight(25);
			bar:SetStatusBarTexture("Interface\\AddOns\\Tukui\\media\\statusbar");
			if ( index == 1 ) then
				bar:SetPoint("TOP", 0, -350);
			else
				bar:SetPoint("TOP", grouplootbars[index-1], "BOTTOM", 0, -4);
			end
			bar:SetScript("OnUpdate", BarOnUpdate);
			bar:RegisterEvent("CANCEL_LOOT_ROLL");
			bar:SetScript("OnEvent", BarOnEvent);
			bar:SetScript("OnMouseUp", BarOnClick);
			bar:SetScript("OnEnter", BarOnEnter);
			bar:SetScript("OnLeave", BarOnLeave);
			
			bar.background = bar:CreateTexture(nil, "BORDER");
			bar.background:SetAllPoints();
			bar.background:SetTexture("Interface\\AddOns\\Tukui\\media\\statusbar");
			bar.background:SetVertexColor(0.1, 0.1, 0.1, 1);
			
			bar.pass = CreateFrame("Button", "$parentPassButton", bar);
			bar.pass.type = 0;
			bar.pass.roll = "pass";
			bar.pass:SetWidth(28);
			bar.pass:SetHeight(28);
			bar.pass:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
			bar.pass:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down");
			bar.pass:SetPoint("RIGHT", -5, 1);
			bar.pass:SetScript("OnClick", BarButtonOnClick);
			bar.pass:SetScript("OnEnter", BarButtonOnEnter);
			bar.pass:SetScript("OnLeave", BarButtonOnLeave);
			bar.passtext = bar.pass:CreateFontString("$parentText", "ARTWORK");
			bar.passtext:SetFont(GFHCName, GFHCHeight, "OUTLINE");
			bar.passtext:SetShadowColor(1, 1, 1, 0);
			bar.passtext:SetPoint("CENTER");
			
			bar.greed = CreateFrame("Button", "$parentGreedButton", bar);
			bar.greed.type = 2;
			bar.greed.roll = "greed";
			bar.greed:SetWidth(28);
			bar.greed:SetHeight(28);
			bar.greed:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up");
			bar.greed:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Down");
			bar.greed:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Highlight");
			bar.greed:SetPoint("RIGHT", bar.pass, "LEFT", -2, -4);
			bar.greed:SetScript("OnClick", BarButtonOnClick);
			bar.greed:SetScript("OnEnter", BarButtonOnEnter);
			bar.greed:SetScript("OnLeave", BarButtonOnLeave);
			bar.greedtext = bar.greed:CreateFontString("$parentText", "ARTWORK");
			bar.greedtext:SetFont(GFHCName, GFHCHeight, "OUTLINE");
			bar.greedtext:SetShadowColor(1, 1, 1, 0);
			bar.greedtext:SetPoint("CENTER", 0, 3);
			
			bar.need = CreateFrame("Button", "$parentNeedButton", bar);
			bar.need.type = 1;
			bar.need.roll = "need";
			bar.need:SetWidth(28);
			bar.need:SetHeight(28);
			bar.need:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up");
			bar.need:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Down");
			bar.need:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight");
			bar.need:SetPoint("RIGHT", bar.greed, "LEFT", -2, 2);
			bar.need:SetScript("OnClick", BarButtonOnClick);
			bar.need:SetScript("OnEnter", BarButtonOnEnter);
			bar.need:SetScript("OnLeave", BarButtonOnLeave);
			bar.needtext = bar.need:CreateFontString("$parentText", "ARTWORK");
			bar.needtext:SetFont(GFHCName, GFHCHeight, "OUTLINE");
			bar.needtext:SetShadowColor(1, 1, 1, 0);
			bar.needtext:SetPoint("CENTER", 0, 1);
			
			bar.dis = CreateFrame("Button", "$parentDisenchantButton", bar);
			bar.dis.type = 3;
			bar.dis.roll = "dis";
			bar.dis:SetWidth(28);
			bar.dis:SetHeight(28);
			bar.dis:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-DE-Up");
			bar.dis:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-DE-Down");
			bar.dis:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-DE-Highlight");
			bar.dis:SetPoint("RIGHT", bar.need, "LEFT", -2, 2);
			bar.dis:SetScript("OnClick", BarButtonOnClick);
			bar.dis:SetScript("OnEnter", BarButtonOnEnter);
			bar.dis:SetScript("OnLeave", BarButtonOnLeave);
			bar.distext = bar.dis:CreateFontString("$parentText", "ARTWORK");
			bar.distext:SetFont(GFHCName, GFHCHeight, "OUTLINE");
			bar.distext:SetShadowColor(1, 1, 1, 0);
			bar.distext:SetPoint("CENTER", 0, 1);
			
			bar.text = bar:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightLeft");
			bar.text:SetPoint("LEFT", 5, 0);
			bar.text:SetPoint("RIGHT", bar.dis, "LEFT");
			
			bar.border = {};
			bar.border.topleft = bar:CreateTexture(nil, "OVERLAY");
			bar.border.topleft:SetTexture("Interface\\AddOns\\Tukui\\media\\border2");
			bar.border.topleft:SetPoint("TOPLEFT", -2, 2);
			bar.border.topleft:SetWidth(8);
			bar.border.topleft:SetHeight(8);
			bar.border.topleft:SetTexCoord(0, 1/3, 0, 1/3);
			bar.border.bottomleft = bar:CreateTexture(nil, "OVERLAY");
			bar.border.bottomleft:SetTexture("Interface\\AddOns\\Tukui\\media\\border2");
			bar.border.bottomleft:SetPoint("BOTTOMLEFT", -2, -2);
			bar.border.bottomleft:SetWidth(8);
			bar.border.bottomleft:SetHeight(8);
			bar.border.bottomleft:SetTexCoord(0, 1/3, 2/3, 1);
			bar.border.topright = bar:CreateTexture(nil, "OVERLAY");
			bar.border.topright:SetTexture("Interface\\AddOns\\Tukui\\media\\border2");
			bar.border.topright:SetPoint("TOPRIGHT", 2, 2);
			bar.border.topright:SetWidth(8);
			bar.border.topright:SetHeight(8);
			bar.border.topright:SetTexCoord(2/3, 1, 0, 1/3);
			bar.border.bottomright = bar:CreateTexture(nil, "OVERLAY");
			bar.border.bottomright:SetTexture("Interface\\AddOns\\Tukui\\media\\border2");
			bar.border.bottomright:SetPoint("BOTTOMRIGHT", 2, -2);
			bar.border.bottomright:SetWidth(8);
			bar.border.bottomright:SetHeight(8);
			bar.border.bottomright:SetTexCoord(2/3, 1, 2/3, 1);
			bar.border.top = bar:CreateTexture(nil, "OVERLAY");
			bar.border.top:SetTexture("Interface\\AddOns\\Tukui\\media\\border2");
			bar.border.top:SetPoint("TOPLEFT", bar.border.topleft, "TOPRIGHT");
			bar.border.top:SetPoint("TOPRIGHT", bar.border.topright, "TOPLEFT");
			bar.border.top:SetHeight(8);
			bar.border.top:SetTexCoord(1/3, 2/3, 0, 1/3);
			bar.border.bottom = bar:CreateTexture(nil, "OVERLAY");
			bar.border.bottom:SetTexture("Interface\\AddOns\\Tukui\\media\\border2");
			bar.border.bottom:SetPoint("BOTTOMLEFT", bar.border.bottomleft, "BOTTOMRIGHT");
			bar.border.bottom:SetPoint("BOTTOMRIGHT", bar.border.bottomright, "BOTTOMLEFT");
			bar.border.bottom:SetHeight(8);
			bar.border.bottom:SetTexCoord(1/3, 2/3, 2/3, 1);
			bar.border.left = bar:CreateTexture(nil, "OVERLAY");
			bar.border.left:SetTexture("Interface\\AddOns\\Tukui\\media\\border2");
			bar.border.left:SetPoint("TOPLEFT", bar.border.topleft, "BOTTOMLEFT");
			bar.border.left:SetPoint("BOTTOMLEFT", bar.border.bottomleft, "TOPLEFT");
			bar.border.left:SetWidth(8);
			bar.border.left:SetTexCoord(0, 1/3, 1/3, 2/3);
			bar.border.right = bar:CreateTexture(nil, "OVERLAY");
			bar.border.right:SetTexture("Interface\\AddOns\\Tukui\\media\\border2");
			bar.border.right:SetPoint("TOPRIGHT", bar.border.topright, "BOTTOMRIGHT");
			bar.border.right:SetPoint("BOTTOMRIGHT", bar.border.bottomright, "TOPRIGHT");
			bar.border.right:SetWidth(8);
			bar.border.right:SetTexCoord(2/3, 1, 1/3, 2/3);
			
			bar.hasItem = 1; -- Brauch man für die Funktion CursorUpdate.
			
			tinsert(grouplootbars, bar);
		end
		
		texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDE = GetLootRollItemInfo(value.rollId);
		color = ITEM_QUALITY_COLORS[quality];
		
		if ( bindOnPickUp ) then
			bar.border.topleft:SetVertexColor(1, 1, 1, 1);
			bar.border.bottomleft:SetVertexColor(1, 1, 1, 1);
			bar.border.topright:SetVertexColor(1, 1, 1, 1);
			bar.border.bottomright:SetVertexColor(1, 1, 1, 1);
			bar.border.top:SetVertexColor(1, 1, 1, 1);
			bar.border.bottom:SetVertexColor(1, 1, 1, 1);
			bar.border.left:SetVertexColor(1, 1, 1, 1);
			bar.border.right:SetVertexColor(1, 1, 1, 1);
		else
			bar.border.topleft:SetVertexColor(1, 1, 1, 1);
			bar.border.bottomleft:SetVertexColor(1, 1, 1, 1);
			bar.border.topright:SetVertexColor(1, 1, 1, 1);
			bar.border.bottomright:SetVertexColor(1, 1, 1, 1);
			bar.border.top:SetVertexColor(1, 1, 1, 1);
			bar.border.bottom:SetVertexColor(1, 1, 1, 1);
			bar.border.left:SetVertexColor(1, 1, 1, 1);
			bar.border.right:SetVertexColor(1, 1, 1, 1);
		end

		if ( canNeed ) then
			GroupLootFrame_EnableLootButton(bar.need)
		else
			GroupLootFrame_DisableLootButton(bar.need)
		end
		
		if ( canGreed ) then
			GroupLootFrame_EnableLootButton(bar.greed)
		else
			GroupLootFrame_DisableLootButton(bar.greed)
		end
		
		if ( canDE ) then
			GroupLootFrame_EnableLootButton(bar.dis)
		else
			GroupLootFrame_DisableLootButton(bar.dis)
		end
		
		bar:SetStatusBarColor(color.r, color.g, color.b, 1);
		bar:SetMinMaxValues(0, value.rollTime);
		
		bar.passtext:SetText(grouplootrolls[value.rollId] and grouplootrolls[value.rollId]["pass"] and grouplootrolls[value.rollId]["pass"].count or "");
		bar.greedtext:SetText(grouplootrolls[value.rollId] and grouplootrolls[value.rollId]["greed"] and grouplootrolls[value.rollId]["greed"].count or "");
		bar.needtext:SetText(grouplootrolls[value.rollId] and grouplootrolls[value.rollId]["need"] and grouplootrolls[value.rollId]["need"].count or "");
		bar.distext:SetText(grouplootrolls[value.rollId] and grouplootrolls[value.rollId]["dis"] and grouplootrolls[value.rollId]["dis"].count or "");
		bar.text:SetText(count > 1 and name.." x"..count or name);
		
		bar.rollId = value.rollId;
		bar.rollLink = GetLootRollItemLink(value.rollId);
		
		bar:Show();
	end
end
