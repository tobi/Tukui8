
  -- tukz 2009
  -- tActionBars is based on rActionBarStyler by Zork.
  
  ---------------------------------------------------
  -- CREATE ALL THE HOLDER FRAMES
  ---------------------------------------------------
  
  -- position table for the default frame holder positions
  -- those are use if the bar is set to not movable or if there is no value in the layout-cache.txt for that frame yet
 
if not (IsAddOnLoaded("Dominos") or IsAddOnLoaded("Bartender4") or IsAddOnLoaded("Macaroon") or IsAddOnLoaded("XBar")) then

  -- space between button
  padding = 4
  petpadding = -4 --(negative numbers because petbar it set to vertical instead of horizontal)
  stancepadding = 1

  -- scale values
  bar1scale = 1 * 0.72
  bar2scale = 1 * 0.72
  bar3scale = 0.8
  bar45scale = 0.8
  petscale = 1
  shapeshiftscale = 1  
  
  frame_positions = {
    [1]  =  { a = "BOTTOM",         x = -140, y = 19  },  --fbar1_button_system_1
    [2]  =  { a = "BOTTOM",         x = -230,    y = 15 },  --fbar1_button_system_0
    [3]  =  { a = "BOTTOM",         x = 149,  y = 9.5  },  --fbar2_button_system_1
    [4]  =  { a = "BOTTOM",         x = 251,    y = 15  },  --fbar2_button_system_0
    [5]  =  { a = "RIGHT",         x = -98,    y = 232 },  --fbar3
    [6]  =  { a = "RIGHT",          x = -20,   y = 0   },  --fbar45
    [9]  =  { a = "RIGHT",         x = -120,    y = 163 },  --petbar
    [10] =  { a = "BOTTOM",         x = -337,    y = 142 },  --shapeshift
    [11] =  { a = "BOTTOM",         x = 0,    y = 150 },  --my own vehicle exit button
  }
 
  -- Frame to hold the ActionBar1 and the BonusActionBar
  local fbar1 = CreateFrame("Frame","rABS_Bar1Holder",UIParent)
  if button_system == true then
    fbar1:SetWidth(264)
    fbar1:SetHeight(116)
    fbar1:SetPoint(frame_positions[1].a,frame_positions[1].x,frame_positions[1].y)  
  else
    fbar1:SetWidth(518)
    fbar1:SetHeight(58)
    fbar1:SetPoint(frame_positions[2].a,frame_positions[2].x,frame_positions[2].y)  
  end
  fbar1:Show()
  
  -- Frame to hold the MultibarLeft
  local fbar2 = CreateFrame("Frame","rABS_Bar2Holder",UIParent)
  if button_system == true then
    fbar2:SetWidth(264)
    fbar2:SetHeight(116)
    fbar2:SetPoint(frame_positions[3].a,frame_positions[3].x,frame_positions[3].y)
  else
    fbar2:SetWidth(518)
    fbar2:SetHeight(58)
    fbar2:SetPoint(frame_positions[4].a,frame_positions[4].x,frame_positions[4].y)  
  end
  fbar2:Show()

  -- Frame to hold the MultibarRight
  local fbar3 = CreateFrame("Frame","rABS_Bar3Holder",UIParent)
  fbar3:SetWidth(58)
  fbar3:SetHeight(58)
  fbar3:SetPoint(frame_positions[5].a,frame_positions[5].x,frame_positions[5].y)
  fbar3:Show()  
  
  -- Frame to hold the right bars
  local fbar45 = CreateFrame("Frame","rABS_Bar45Holder",UIParent)
  fbar45:SetWidth(190) -- size the width here
  fbar45:SetHeight(518) -- size the height here
  fbar45:SetPoint(frame_positions[6].a,frame_positions[6].x,frame_positions[6].y) 
  
  
  -- Frame to hold the pet bars  
  local fpet = CreateFrame("Frame","rABS_PetBarHolder",UIParent)
  fpet:SetWidth(53) -- size the width here
  fpet:SetHeight(53) -- size the height here
  fpet:SetPoint(frame_positions[9].a,frame_positions[9].x,frame_positions[9].y)
  
  
  -- Frame to hold the shapeshift bars  
  local fshift = CreateFrame("Frame","rABS_ShapeShiftHolder",UIParent)
  fshift:SetWidth(50) -- size the width here
  fshift:SetHeight(50) -- size the height here
  fshift:SetPoint(frame_positions[10].a,frame_positions[10].x,frame_positions[10].y) 
  
  ---------------------------------------------------
  -- CREATE MY OWN VEHICLE EXIT BUTTON
  ---------------------------------------------------
  
  local fveb = CreateFrame("Frame","rABS_VEBHolder",UIParent)
  fveb:SetWidth(40) -- size the width here
  fveb:SetHeight(40) -- size the height here
  fveb:SetPoint(frame_positions[11].a,frame_positions[11].x,frame_positions[11].y) 
  
  local veb = CreateFrame("BUTTON", "rABS_VehicleExitButton", fveb, "SecureActionButtonTemplate");
  veb:SetWidth(40)
  veb:SetHeight(40)
  veb:SetPoint("CENTER",0,0)
  veb:RegisterForClicks("AnyUp")
  veb:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
  veb:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
  veb:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
  veb:SetScript("OnClick", function(self) VehicleExit() end)
  veb:RegisterEvent("UNIT_ENTERING_VEHICLE")
  veb:RegisterEvent("UNIT_ENTERED_VEHICLE")
  veb:RegisterEvent("UNIT_EXITING_VEHICLE")
  veb:RegisterEvent("UNIT_EXITED_VEHICLE")
  veb:SetScript("OnEvent", function(self,event,...)
    local arg1 = ...;
    if(((event=="UNIT_ENTERING_VEHICLE") or (event=="UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
      veb:SetAlpha(1)
    elseif(((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and arg1 == "player") then
      veb:SetAlpha(0)
    end
  end)  
  veb:SetAlpha(0)
 
  ---------------------------------------------------
  -- MOVE STUFF INTO POSITION
  ---------------------------------------------------
  
  local i,f
    
  --bar1
  for i=1, 12 do
    _G["ActionButton"..i]:SetParent(fbar1);
  end
  ActionButton1:ClearAllPoints()
  ActionButton1:SetPoint("BOTTOMLEFT",fbar1,"BOTTOMLEFT",10,10);  
  for i=2, 12 do
    local b = _G["ActionButton"..i]
	local b2 = _G["ActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT",b2,"RIGHT",padding,0)
  end 

  --bonus bar  
  BonusActionBarFrame:SetParent(fbar1)
  BonusActionBarFrame:SetWidth(0.01)
  BonusActionBarTexture0:Hide()
  BonusActionBarTexture1:Hide()
  BonusActionButton1:ClearAllPoints()
  BonusActionButton1:SetPoint("BOTTOMLEFT", fbar1, "BOTTOMLEFT", 10, 10);
for i=2, 12 do
  local b = _G["BonusActionButton"..i]
  local b2 = _G["BonusActionButton"..i-1]
  b:ClearAllPoints()
  b:SetPoint("LEFT",b2,"RIGHT",padding,0)
end
  
  --bar2
  MultiBarBottomLeft:SetParent(fbar2)
  MultiBarBottomLeftButton1:ClearAllPoints()
  MultiBarBottomLeftButton1:SetPoint("BOTTOMLEFT", fbar2, "BOTTOMLEFT", 10, 10);
  for i=2, 12 do
    local b = _G["MultiBarBottomLeftButton"..i]
	local b2 = _G["MultiBarBottomLeftButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT",b2,"RIGHT",padding,0)
  end 
  
  --bar3
  MultiBarBottomRight:SetParent(fbar3)
  MultiBarBottomRightButton1:ClearAllPoints()
  MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", fbar3, "BOTTOMLEFT", 10, 10);
  for i=2, 12 do
    local b = _G["MultiBarBottomRightButton"..i]
	local b2 = _G["MultiBarBottomRightButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("TOP",b2,"BOTTOM",0,-4)
  end 
  
  --shift
  ShapeshiftBarFrame:SetParent(fshift)
  ShapeshiftBarFrame:SetWidth(0.01)
  ShapeshiftButton1:ClearAllPoints()
  ShapeshiftButton1:SetPoint("BOTTOMLEFT",fshift,"BOTTOMLEFT",10,10)
  local function rABS_MoveShapeshift()
    ShapeshiftButton1:SetPoint("BOTTOMLEFT",fshift,"BOTTOMLEFT",10,10)
  end
  for i=2, 10 do
    local b = _G["ShapeshiftButton"..i]
	local b2 = _G["ShapeshiftButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT",b2,"RIGHT",stancepadding,0)
  end 
  hooksecurefunc("ShapeshiftBar_Update", rABS_MoveShapeshift); 
  
  --possess bar
  PossessBarFrame:SetParent(fshift)
  PossessButton1:ClearAllPoints()
  PossessButton1:SetPoint("BOTTOMLEFT", fshift, "BOTTOMLEFT", 10, 10);
  
    --totem bar (idea borrowed from avis57, author of Movable Totem Frame add-on)
  if select(2, UnitClass("Player")) == "SHAMAN" then
    MultiCastSummonSpellButton:SetParent(fshift)
    for i=1, 4 do
      _G["MultiCastSlotButton"..i]:SetParent(fshift)
    end
    for i=1, 3 do
      local b = _G["MultiCastActionPage"..i]
      b:SetParent(fshift)
      b:SetWidth(0.01)
    end
    MultiCastFlyoutFrame:SetParent(fshift)
    MultiCastRecallSpellButton:SetParent(fshift)

    MultiCastSummonSpellButton:ClearAllPoints()
    MultiCastSummonSpellButton:SetPoint("BOTTOMLEFT",fshift,"BOTTOMLEFT",10,10)

    MultiCastSlotButton1:ClearAllPoints()
    MultiCastSlotButton1:SetPoint("LEFT",MultiCastSummonSpellButton,"RIGHT",stancepadding,0)
    for i=2, 4 do
      local b = _G["MultiCastSlotButton"..i]
      local b2 = _G["MultiCastSlotButton"..i-1]
      b:ClearAllPoints()
      b:SetPoint("LEFT",b2,"RIGHT",stancepadding,0)
    end

    for i=1, 12 do
      local b = _G["MultiCastActionButton"..i], b2
      b:ClearAllPoints()
      if i % 4 == 1 then
        b:SetPoint("LEFT",MultiCastSummonSpellButton,"RIGHT",stancepadding,0)
      else
        b2 = _G["MultiCastActionButton"..i-1]
        b:SetPoint("LEFT",b2,"RIGHT",stancepadding,0)
      end
    end

    MultiCastRecallSpellButton:ClearAllPoints()
    MultiCastRecallSpellButton:SetPoint("LEFT",MultiCastActionButton4,"RIGHT",stancepadding,0)

    local dummy = function() return end
    for i=1, 4 do
      local b = _G["MultiCastSlotButton"..i]
      b.SetParent = dummy
      b.SetPoint = dummy
    end
    MultiCastRecallSpellButton.SetParent = dummy
    MultiCastRecallSpellButton.SetPoint = dummy
  end
  
  --pet
  PetActionBarFrame:SetParent(fpet)
  PetActionBarFrame:SetWidth(0.01)
  PetActionButton1:ClearAllPoints()
  PetActionButton1:SetPoint("BOTTOMLEFT",fpet,"BOTTOMLEFT",10,10)
  for i=2, 10 do
    local b = _G["PetActionButton"..i]
	local b2 = _G["PetActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("TOP",b2,"BOTTOM",0,petpadding)
  end 

  --right bars
  MultiBarRight:SetParent(fbar45);
  MultiBarLeft:SetParent(fbar45);
  MultiBarRight:ClearAllPoints()
  MultiBarRight:SetPoint("TOPRIGHT",-10,-10)
  MultiBarLeft:ClearAllPoints()
  MultiBarLeft:SetPoint("TOPRIGHT",-50,-10)
  for i=2, 12 do
    local b = _G["MultiBarRightButton"..i]
	local b2 = _G["MultiBarRightButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("TOP",b2,"BOTTOM",0,-4)
  end 
  for i=2, 12 do
    local b = _G["MultiBarLeftButton"..i]
	local b2 = _G["MultiBarLeftButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("TOP",b2,"BOTTOM",0,-4)
  end 
  
  ---------------------------------------------------
  -- ACTIONBUTTONS MUST BE HIDDEN
  ---------------------------------------------------
  
  -- hide actionbuttons when the bonusbar is visible (rogue stealth and such)
  local function rABS_showhideactionbuttons(alpha)
    local f = "ActionButton"
    for i=1, 12 do
      _G[f..i]:SetAlpha(alpha)
    end
  end
  BonusActionBarFrame:HookScript("OnShow", function(self) rABS_showhideactionbuttons(0) end)
  BonusActionBarFrame:HookScript("OnHide", function(self) rABS_showhideactionbuttons(1) end)
  if BonusActionBarFrame:IsShown() then
    rABS_showhideactionbuttons(0)
  end

  ---------------------------------------------------
  -- MAKE THE DEFAULT BARS UNVISIBLE
  ---------------------------------------------------
  
  local FramesToHide = {
    MainMenuBar,
    VehicleMenuBar,
  }  
  
  local function rABS_HideDefaultFrames()
    for _, f in pairs(FramesToHide) do
      f:SetScale(0.001)
      f:SetAlpha(0)
    end
  end  
  rABS_HideDefaultFrames(); 

  ---------------------------------------------------
  -- SCALING
  ---------------------------------------------------

  fbar1:SetScale(bar1scale)
  fbar2:SetScale(bar2scale)
  fbar3:SetScale(bar3scale)
  fbar45:SetScale(bar45scale)
  
  fpet:SetScale(petscale)
  fshift:SetScale(shapeshiftscale)

  ---------------------------------------------------
  -- MOVABLE FRAMES
  ---------------------------------------------------
  
  -- func
  local function rABS_MoveThisFrame(f,moveit,lock)
    if moveit == true then
      f:SetMovable(true)
      f:SetUserPlaced(true)
      if lock ~= 1 then
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton","RightButton")
        f:SetScript("OnDragStart", function(self) if IsShiftKeyDown() and IsAltKeyDown() then self:StartMoving() end end)
        f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
      end
    else
      f:IsUserPlaced(false)
    end  
  end
  
  -- calls
  rABS_MoveThisFrame(fshift,move_shapeshift,lock_shapeshift)

  if hide_shapeshift == true then
    fshift:SetScale(0.001)
    fshift:SetAlpha(0)
  end
   
  if hide_pet == true then
    fpet:SetScale(0.001)
    fpet:SetAlpha(0)
  end
  
	if rightbarnumber == 0 then
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",0,163)
		MultiBarBottomRight:SetScale(0.001)
		MultiBarBottomRight:SetAlpha(0)
		MultiBarLeft:SetScale(0.001)
		MultiBarLeft:SetAlpha(0)
		MultiBarRight:SetScale(0.001)
		MultiBarRight:SetAlpha(0)
	elseif rightbarnumber == 1 then
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",-60,163)
		MultiBarBottomRight:SetScale(0.001)
		MultiBarBottomRight:SetAlpha(0)
		MultiBarLeft:SetScale(0.001)
		MultiBarLeft:SetAlpha(0)
		MultiBarRight:SetScale(1)
		MultiBarRight:SetAlpha(1)
	elseif rightbarnumber == 2 then
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",-90,163)
		MultiBarBottomRight:SetScale(0.001)
		MultiBarBottomRight:SetAlpha(0)
		MultiBarLeft:SetScale(1)
		MultiBarLeft:SetAlpha(1)
		MultiBarRight:SetScale(1)
		MultiBarRight:SetAlpha(1)
	elseif rightbarnumber == 3 then
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",-120,163)
		MultiBarBottomRight:SetScale(1)
		MultiBarBottomRight:SetAlpha(1)
		MultiBarLeft:SetScale(1)
		MultiBarLeft:SetAlpha(1)
		MultiBarRight:SetScale(1)
		MultiBarRight:SetAlpha(1)
	end
	
------------------------------------------------------------------------
--	RIGHTBARS 
------------------------------------------------------------------------

SlashCmdList["ABCONFIG"] = function()
		MultiBarBottomRight:SetScale(1)
		MultiBarBottomRight:SetAlpha(1)
		MultiBarLeft:SetScale(1)
		MultiBarLeft:SetAlpha(1)
		MultiBarRight:SetScale(1)
		MultiBarRight:SetAlpha(1)
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",-120,163)
		fpet:SetScale(petscale)
		fpet:SetAlpha(1)
end
SLASH_ABCONFIG1 = "/abconfig"

SlashCmdList["ABSHOW"] = function()
	if rightbarnumber == 0 then
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",0,163)
		fpet:SetScale(petscale)
		fpet:SetAlpha(1)
		MultiBarBottomRight:SetScale(0.001)
		MultiBarBottomRight:SetAlpha(0)
		MultiBarLeft:SetScale(0.001)
		MultiBarLeft:SetAlpha(0)
		MultiBarRight:SetScale(0.001)
		MultiBarRight:SetAlpha(0)
	elseif rightbarnumber == 1 then
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",-60,163)
		fpet:SetScale(petscale)
		fpet:SetAlpha(1)
		MultiBarBottomRight:SetScale(0.001)
		MultiBarBottomRight:SetAlpha(0)
		MultiBarLeft:SetScale(0.001)
		MultiBarLeft:SetAlpha(0)
		MultiBarRight:SetScale(1)
		MultiBarRight:SetAlpha(1)
	elseif rightbarnumber == 2 then
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",-90,163)
		fpet:SetScale(petscale)
		fpet:SetAlpha(1)
		MultiBarBottomRight:SetScale(0.001)
		MultiBarBottomRight:SetAlpha(0)
		MultiBarLeft:SetScale(1)
		MultiBarLeft:SetAlpha(1)
		MultiBarRight:SetScale(1)
		MultiBarRight:SetAlpha(1)
	elseif rightbarnumber == 3 then
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",-120,163)
		fpet:SetScale(petscale)
		fpet:SetAlpha(1)
		MultiBarBottomRight:SetScale(1)
		MultiBarBottomRight:SetAlpha(1)
		MultiBarLeft:SetScale(1)
		MultiBarLeft:SetAlpha(1)
		MultiBarRight:SetScale(1)
		MultiBarRight:SetAlpha(1)
	end
end
SLASH_ABSHOW1 = "/abshow"
SLASH_ABSHOW2 = "/abtoggle"

SlashCmdList["ABHIDE"] = function()
		MultiBarBottomRight:SetScale(0.001)
		MultiBarBottomRight:SetAlpha(0)
		MultiBarLeft:SetScale(0.001)
		MultiBarLeft:SetAlpha(0)
		MultiBarRight:SetScale(0.001)
		MultiBarRight:SetAlpha(0)
		fpet:ClearAllPoints()
		fpet:SetPoint("RIGHT",0,163)
		fpet:SetScale(petscale)
		fpet:SetAlpha(1)
end
SLASH_ABHIDE1 = "/abhide"

  local function rABS_showhidepet(alpha)
    for i=1, NUM_PET_ACTION_SLOTS do
      local pb = _G["PetActionButton"..i]
      pb:SetAlpha(alpha)
    end;
  end

local function rABS_showhiderightbar(alpha)
  if rightbarnumber == 3 then
    if MultiBarLeft:IsShown() then
      for i=1, 12 do
        local pb = _G["MultiBarLeftButton"..i]
        pb:SetAlpha(alpha)
      end
	  MultiBarLeft:SetAlpha(alpha)
    end
    if MultiBarRight:IsShown() then
      for i=1, 12 do
        local pb = _G["MultiBarRightButton"..i]
        pb:SetAlpha(alpha)
      end
	  MultiBarRight:SetAlpha(alpha)
    end
	if MultiBarBottomRight:IsShown() then
      for i=1, 12 do
        local pb = _G["MultiBarBottomRightButton"..i]
        pb:SetAlpha(alpha)
      end
	  MultiBarBottomRight:SetAlpha(alpha)
    end
  end
  if rightbarnumber == 2 then
    if MultiBarLeft:IsShown() then
      for i=1, 12 do
        local pb = _G["MultiBarLeftButton"..i]
        pb:SetAlpha(alpha)
      end
	  MultiBarLeft:SetAlpha(alpha)
    end
    if MultiBarRight:IsShown() then
      for i=1, 12 do
        local pb = _G["MultiBarRightButton"..i]
        pb:SetAlpha(alpha)
      end
	  MultiBarRight:SetAlpha(alpha)
    end
  end
  if rightbarnumber == 1 then
    if MultiBarRight:IsShown() then
      for i=1, 12 do
        local pb = _G["MultiBarRightButton"..i]
        pb:SetAlpha(alpha)
      end
	  MultiBarRight:SetAlpha(alpha)
    end
  end
end

if rightbars_on_mouseover == true then
	MultiBarLeft:SetAlpha(0)
	MultiBarRight:SetAlpha(0)
	MultiBarBottomRight:SetAlpha(0)
    fbar45:EnableMouse(true)
    fbar45:SetScript("OnEnter", function(self) rABS_showhiderightbar(1) rABS_showhidepet(1) end)
    fbar45:SetScript("OnLeave", function(self) rABS_showhiderightbar(0) rABS_showhidepet(0) end)
    for i=1, 12 do
      local pb = _G["MultiBarLeftButton"..i]
      pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) rABS_showhiderightbar(1) rABS_showhidepet(1) end)
      pb:HookScript("OnLeave", function(self) rABS_showhiderightbar(0) rABS_showhidepet(0) end)
      local pb = _G["MultiBarRightButton"..i]
      pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) rABS_showhiderightbar(1) rABS_showhidepet(1) end)
      pb:HookScript("OnLeave", function(self) rABS_showhiderightbar(0) rABS_showhidepet(0) end)
      local pb = _G["MultiBarBottomRightButton"..i]
      pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) rABS_showhiderightbar(1) rABS_showhidepet(1) end)
      pb:HookScript("OnLeave", function(self) rABS_showhiderightbar(0) rABS_showhidepet(0) end)
    end
	for i=1, NUM_PET_ACTION_SLOTS do
      local pb = _G["PetActionButton"..i]
      pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) rABS_showhidepet(1) rABS_showhiderightbar(1) end)
      pb:HookScript("OnLeave", function(self) rABS_showhidepet(0) rABS_showhiderightbar(0) end)
    end
end

end
  
  

