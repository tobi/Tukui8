
-- credit fatalentity

BUFF_FLASH_TIME_ON = 0.2;
BUFF_FLASH_TIME_OFF = 0.1;
BUFF_MIN_ALPHA = 0.8;
BUFF_WARNING_TIME = 31;
BUFF_DURATION_WARNING_TIME = 60;
BUFFS_PER_ROW = 16;
BUFF_MAX_DISPLAY = 32;
BUFF_ACTUAL_DISPLAY = 0;
DEBUFF_MAX_DISPLAY = 16
DEBUFF_ACTUAL_DISPLAY = 0;
BUFF_ROW_SPACING = 0;
CONSOLIDATED_BUFFS_PER_ROW = 4;
CONSOLIDATED_BUFF_ROW_HEIGHT = 0;


-- Style Temporary Enchant Icons
TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", -22, -180)
ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT",-12,7)
ConsolidatedBuffsIcon:SetAlpha(0)

-- Function to create "Panels" with the standard color scheme
function BuffPanel(height, width, x, y, anchorPoint, anchorPointRel, anchor, level, parent, strata)
	local bPanel = CreateFrame("Frame", _, parent)
	bPanel:SetFrameLevel(level)
	bPanel:SetFrameStrata(strata)
	bPanel:SetHeight(height)
	bPanel:SetWidth(width)
	bPanel:SetPoint(anchorPoint, anchor, anchorPointRel, x, y)
	bPanel:SetBackdrop( { 
	  bgFile = BLANK_TEXTURE, 
	  edgeFile = BLANK_TEXTURE, 
	  tile = false, tileSize = 0, edgeSize = 1, 
	  insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	bPanel:SetBackdropColor(0.1,0.1,0.1,1)
	bPanel:SetBackdropBorderColor(0.6,0.6,0.6,1)
	return bPanel
end 

-- Style Temporary Enchant Icons
local dummy = function() return end

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", -22, -180)
TemporaryEnchantFrame.SetPoint = dummy

ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT",-12,7)
ConsolidatedBuffsIcon:SetAlpha(0)
ConsolidatedBuffs.SetPoint = dummy

for i = 1, 2 do
	local TempBG = BuffPanel(30, 30, -2, 2, "TOPLEFT", "TOPLEFT", _G["TempEnchant"..i], 0, _G["TempEnchant"..i], "BACKGROUND")
	
	_G["TempEnchant"..i.."Border"]:Hide()
	_G["TempEnchant"..i.."Icon"]:SetTexCoord(.1, .9, .1, .9)
	
	if i == 1 then
		TempEnchant1:ClearAllPoints()
		TempEnchant2:ClearAllPoints()
		TempEnchant1:SetPoint("TOPRIGHT")
		TempEnchant2:SetPoint("TOPLEFT", TempEnchant1, "TOPLEFT", -38,0)
	end
	
	_G["TempEnchant"..i]:SetHeight(26)
	_G["TempEnchant"..i]:SetWidth(26)
	
	_G["TempEnchant"..i.."Duration"]:ClearAllPoints()
	_G["TempEnchant"..i.."Duration"]:SetPoint("BOTTOM", 0, -16)
	_G["TempEnchant"..i.."Duration"]:SetFont("Fonts\\FRIZQT__.TTF", 12)
	
end

-- Style Aura Icons
local function StyleBuffs(buttonName, index, debuff)

	local buff		= _G[buttonName..index]
	local icon		= _G[buttonName..index.."Icon"]
	local border	= _G[buttonName..index.."Border"]
	local Duration	= _G[buttonName..index.."Duration"]
	if icon and not _G[buttonName..index.."bPanel"] then
		icon:SetTexCoord(.1, .9, .1, .9)
		
		buff:SetHeight(26)
		buff:SetWidth(26)
		
		Duration:ClearAllPoints()
		Duration:SetPoint("BOTTOM", 0, -16)
		Duration:SetFont("Fonts\\FRIZQT__.TTF",12)
		
		_G[buttonName..index.."bPanel"] = BuffPanel(30, 30, -2, 2, "TOPLEFT", "TOPLEFT", buff, 0, buff, "BACKGROUND")

		if debuff then
			_G[buttonName..index.."bPanel"]:SetBackdropBorderColor(134/255, 12/255, 12/255)
		end
	end
	if border then border:Hide() end
end


function UpdateBuffAnchors()
		local buff, previousBuff, aboveBuff;
		local numBuffs = 0;

		for i = 1, BUFF_ACTUAL_DISPLAY do
			buff = _G["BuffButton"..i];
			if ( buff.consolidated ) then
				if ( buff.parent == BuffFrame ) then
					buff:SetParent(ConsolidatedBuffsContainer);
					buff.parent = ConsolidatedBuffsContainer;
				end
			else
				numBuffs = numBuffs + 1;
				index = numBuffs;
				if ( buff.parent ~= BuffFrame ) then
					buff.count:SetFontObject(NumberFontNormal);
					buff:SetParent(BuffFrame);
					buff.parent = BuffFrame;
				end
				buff:ClearAllPoints();
					if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
					-- New row
						if ( index == BUFFS_PER_ROW+1 ) then
							buff:SetPoint("TOPRIGHT",UIParent, "TOPRIGHT", -180, -79)
						else
							buff:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -180, -22)
						end
						aboveBuff = buff;
					elseif ( index == 1 ) then
						buff:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -180, -22);
					else
						buff:SetPoint("RIGHT", previousBuff, "LEFT", -9, 0);
					end
					previousBuff = buff;
			end
		end
end

function UpdateDebuffAnchors(buttonName, index)
		local debuff = _G[buttonName..index];
		StyleBuffs(buttonName, index, true)
		debuff:ClearAllPoints()
		
		if index == 1 then
			debuff:SetPoint("TOPRIGHT",UIParent, "TOPRIGHT", -180, -136)
		else
			debuff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -9, 0)
		end
end

function UpdateBuffBorder(buttonName, index)
		local buff = _G[buttonName..index];
		StyleBuffs(buttonName, index, false)
end

hooksecurefunc("AuraButton_Update", UpdateBuffBorder)
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)

