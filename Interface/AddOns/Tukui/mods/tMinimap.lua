Addon = CreateFrame("Frame")

--------------------------------------------------------------------
-- MINIMAP BORDER
--------------------------------------------------------------------

	local mPanel = CreateFrame("Frame", mapborder, Minimap)
	mPanel:SetFrameLevel(0)
	mPanel:SetFrameStrata("background")
	mPanel:SetHeight(144)
	mPanel:SetWidth(144)
	mPanel:SetPoint("center",-0.5,0)
	mPanel:SetScale(1)
	
	mPanel:SetBackdrop( { 
	  bgFile = BLANK_TEXTURE, 
	  edgeFile = BLANK_TEXTURE, 
	  tile = false, tileSize = 0, edgeSize = 1, 
	  insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	mPanel:SetBackdropColor(.1,.1,.1,1)
	mPanel:SetBackdropBorderColor(.6,.6,.6,1)
	mPanel:Show()

--------------------------------------------------------------------
-- MINIMAP ROUND TO SQUARE AND MINIMAP SETTING
--------------------------------------------------------------------

Minimap:SetScale(1)
Minimap:SetFrameStrata("BACKGROUND")
Minimap:ClearAllPoints()
Minimap:SetPoint(minimapposition, UIParent, minimapposition_x, minimapposition_y)	

-- Hide Border
MinimapBorder:Hide()
MinimapBorderTop:Hide()

-- Hide Zoom Buttons
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()

-- Hide Voice Chat Frame
MiniMapVoiceChatFrame:Hide()

-- Hide Game Time
GameTimeFrame:Hide()

-- Hide Zone Frame
MinimapZoneTextButton:Hide()

-- Hide Tracking Button
MiniMapTracking:Hide()

-- Hide Mail Button
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOPRIGHT", Minimap, 3, 4)
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture("Interface\\AddOns\\Tukui\\media\\mail")

-- Move battleground icon
MiniMapBattlefieldFrame:ClearAllPoints()
MiniMapBattlefieldFrame:SetPoint("BOTTOMRIGHT", Minimap, 3, 0)

-- Hide world map button
MiniMapWorldMapButton:Hide()

-- shitty 3.3 flag to hide
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

function UpdateLFG()
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 3, 0)
end
hooksecurefunc("MiniMapLFG_UpdateIsShown", UpdateLFG)

-- Enable mouse scrolling
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end)

Minimap:SetScript("OnMouseUp", function(self, btn)
	if btn == "RightButton" then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
	elseif btn == "MiddleButton" then
		GameTimeFrame:Click() 
	else
		Minimap_OnClick(self)
	end
end)

-- Set Square Map Mask
Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
--Minimap:SetMaskTexture("Interface\\AddOns\\tMinimap\\Mask-SQUARE")











	
