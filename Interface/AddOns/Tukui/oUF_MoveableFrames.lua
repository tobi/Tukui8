--[[

	Written By:  Derkyle
	
	Allows users to move custom oUF layout frames
	
	Usage:
		[object].MoveableFrames = true   //sets the frame to be movable, must be done in the layout creation	
		Several additional functions are provided below for BlackListing/Whitelisting Frames or declaring Header frames.
	
	NOTE: To move a frame you have to use the slash command /mvf

	WARNING: Authors you MUST make sure your frames and objects are created with NAMES. 
	If no names are provided then the library will return errors.
	The library cannot possibly know how to save/restore a frame or object with no name.
	
--]]

if oUF == nil then return end

local blacklist = {}
local whitelist = {}
local headerlist = {}

--global locked variable
oUF_MF_locked = true

local function SaveLayout(frame)

	if frame == nil then
		DEFAULT_CHAT_FRAME:AddMessage("oUF_MoveableFrames: (ERROR) The [frame/object] your are attempting to reposition has no name.")
		return
	end
	if oUF_MF == nil then oUF_MF = {} end

	local opt = oUF_MF[frame] or nil;

	if opt == nil then 
		oUF_MF[frame] = {};
		opt = oUF_MF[frame];
	end

	local f = getglobal(frame);
	local scale = f:GetEffectiveScale();
	opt.PosX = f:GetLeft() * scale;
	opt.PosY = f:GetTop() * scale;
	--opt.Width = f:GetWidth();
	--opt.Height = f:GetHeight();

end

local function RestoreLayout(frame)
	
	if frame == nil then return end
	if oUF_MF == nil then oUF_MF = {} end

	local f = getglobal(frame);
	local opt = oUF_MF[frame] or nil;

	if opt == nil then return end

	local x = opt.PosX;
	local y = opt.PosY;
	local s = f:GetEffectiveScale();

		if x == nil or y == nil then
		f:ClearAllPoints();
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
		return 
		end

	--calculate the scale
	x,y = x/s,y/s;

	--set the location
	f:ClearAllPoints();
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y);

end

local function Update(object, event, unit)
	if ( object.MoveableFrames ) then
		--in the event that the initial load didn't reposition the frames
		--run a one time event just in case
		if (not object.MoveableFrames_RuneOnce) then
			object.MoveableFrames_RuneOnce = true
			RestoreLayout(object:GetName())
		end
	end
end

local function Enable(object)
	if object:GetName() == nil then return end
	
	--BLACKLIST: check only for enabled objects and not custom ones
	if blacklist[object:GetName()] ~= nil then
		--a match is found so lets remove any data relevant to it
		--object:IsUserPlaced() returns true/false if a user moved an frame
		object:SetUserPlaced(false) --will remove it from the layout-local.txt
		if oUF_MF[object:GetName()] ~= nil then oUF_MF[object:GetName()] = nil end --remove it from the local library DB
		object:SetMovable(false);
		object.isMoving = nil
		return
	end

	if ( object.MoveableFrames ) then
		
		object:EnableMouse(true);
		object:SetMovable(true);
		object:SetClampedToScreen(true);

		--add dragging
		object:SetScript("OnMouseDown", function(frame, button)
				--only move if the frames are unlocked
				if not oUF_MF_locked then
					frame.isMoving = true
					frame:StartMoving()
				end
			end)

		object:SetScript("OnMouseUp", function(frame, button) 

				if( frame.isMoving ) then

					frame.isMoving = nil
					frame:StopMovingOrSizing()

					SaveLayout(frame:GetName())
				end

			end)
		
		--restore any positions we have saved
		RestoreLayout(object:GetName())

		return true
	end
end

local function Disable(object)

	--remove the moving functions
	object:SetScript("OnMouseDown", nil)
	object:SetScript("OnMouseUp", nil)
	
end

--[[
	These two functions will allow layout authors to designate which frames (custom or not) they want to be movable.
	
	BLKLST or BlackList:	Use this function if you want a frame to be added to a list of frames that cannot be moved.
							Note: That blacklisted frames will have any position data stored automatically deleted.
	
	WHTLST or WhiteList:	Use this function if you want a frame to be added to a list of frames that can be moved.
							Note: A profile will be automatically created both localy by Blizzard and by the library.
							These local profiles will be used to make sure a position is moved correctly to where a user
							has defined it to be displayed.
							WARNING: THIS DOES NOT WORK WELL WITH HEADERS, INSTEAD USE THE HEADER FUNCTIONS BELOW
--]]

function oUF_MoveableFrames_BLKLST(frame)
	if frame == nil then return end
	
	local frameName
	
	if type(frame) == "string" then
		frameName = frame
	elseif type(frame) == "table" then
		frameName = frame:GetName()
	end
	
	if frameName == nil then
		DEFAULT_CHAT_FRAME:AddMessage("oUF_MoveableFrames: (ERROR) Frame could not be added to BLKLST.")
		return
	end
	
	--add it to the blacklist table
	blacklist[frameName] = true
end

function oUF_MoveableFrames_WHTLST(frame)
	if frame == nil then return end
	
	local frameName
	
	if type(frame) == "string" then
		frameName = frame
	elseif type(frame) == "table" then
		frameName = frame:GetName()
	end
	
	if frameName == nil then
		DEFAULT_CHAT_FRAME:AddMessage("oUF_MoveableFrames: (ERROR) Frame could not be added to WHTLST.")
		return
	end
	
	--add it to the whitelist table
	whitelist[frameName] = true
end

--[[
	HEADERS:
	This function will create a movable anchor for headers.  The anchor position will be stored and the frame will be 
	repositioned based on the anchor position.  Please note that the frame will have it's SetPoint set to the anchor.
	
	WARNING:  Please pass the exact name of the header frame as it will be used to getglobal and SetPoint.  Failure to
	do so will result in errors.  It is imperative that your header frames as well as the other frames or objects in your
	layout have names.  You have been warned.
	
	Example: oUF_MoveableFrames_HEADER("oUF_Party", "This is the party frame anchor.", 23, -34)
	
	NOTE: ofsx and ofsy are initial coordinates, if the user moves the anchor then the default positions will be replaced.
--]]

function oUF_MoveableFrames_HEADER(frame, desc, ofsx, ofsy)
	if frame == nil then return end
	
	local frameName
	
	if type(frame) == "string" then
		frameName = frame
	elseif type(frame) == "table" then
		frameName = frame:GetName()
	end
	
	if frameName == nil then
		DEFAULT_CHAT_FRAME:AddMessage("oUF_MoveableFrames: (ERROR) Frame could not be added to HEADER.")
		return
	end
	
	frameName = frameName.."AnchorFrm"
	
	if oUF_MF[frameName] == nil then
		oUF_MF[frameName] = {}
		oUF_MF[frameName].PosX = ofsx
		oUF_MF[frameName].PosY = ofsy
	end
	
	headerlist[frameName] = true

	--create the anchor
	local frameAnchor = CreateFrame("Frame", frameName, UIParent)
	
	frameAnchor:SetWidth(25)
	frameAnchor:SetHeight(25)
	frameAnchor:SetMovable(true)
	frameAnchor:SetClampedToScreen(true)
	frameAnchor:EnableMouse(true)
	frameAnchor.desc = desc or frameName --store the description
	
	frameAnchor:ClearAllPoints()
	frameAnchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", oUF_MF[frameName].PosX, oUF_MF[frameName].PosY)
	frameAnchor:SetFrameStrata("DIALOG")
	
	frameAnchor:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frameAnchor:SetBackdropColor(0.75,0,0,1)
	frameAnchor:SetBackdropBorderColor(0.75,0,0,1)

	frameAnchor:SetScript("OnLeave",function(self)
		GameTooltip:Hide()
	end)

	frameAnchor:SetScript("OnEnter",function(self)
	
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(OUF_MF_TipAnchor(self))
		GameTooltip:ClearLines()

		GameTooltip:AddLine(self:GetName())
		GameTooltip:AddLine(self.desc)
		GameTooltip:Show()
	end)

	frameAnchor:SetScript("OnMouseDown", function(frame, button)
		if frame:IsMovable() then
			frame.isMoving = true
			frame:StartMoving()
		end
	end)

	frameAnchor:SetScript("OnMouseUp", function(frame, button) 
		if( frame.isMoving ) then
			frame.isMoving = nil
			frame:StopMovingOrSizing()
			SaveLayout(frame:GetName())
		end
	end)
	
	frameAnchor:Hide() -- hide it by default
			
	--setpoint to the newly created anchor
	getglobal(frame):ClearAllPoints()
	getglobal(frame):SetPoint("TOPLEFT", frameAnchor, "BOTTOMRIGHT", 0, 0)

	--just in case on load up (call me anal but it's better to be safe then sorry)
	RestoreLayout(frameName)
end

--tooltip position correction
function OUF_MF_TipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end
----------------------------------------
----------------------------------------

oUF:AddElement('MoveableFrames', Update, Enable, Disable)

local eventFrame = CreateFrame("Frame", nil, UIParent)
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
	
		--do all the objects in the style OUF
		for i, frame in ipairs(oUF.objects) do Enable(frame) end
		
		--WHITELIST: Enable custom items
		for i, value in pairs(whitelist) do
			if getglobal(i) ~= nil then
				getglobal(i).MoveableFrames = true
				Enable(getglobal(i))
			end
		end
		
		--HEADERS: Restore custom header positions
		for i, value in pairs(headerlist) do
			RestoreLayout(i)
		end
		
	end
end)

local function SlashCommand(cmd)
	if oUF_MF_locked then
		oUF_MF_locked = false
		for i, value in pairs(headerlist) do
			getglobal(i):Show()
		end
		DEFAULT_CHAT_FRAME:AddMessage("oUF_MoveableFrames: Frames are now [UNLOCKED].")
	else
		oUF_MF_locked = true
		for i, value in pairs(headerlist) do
			getglobal(i):Hide()
		end
		DEFAULT_CHAT_FRAME:AddMessage("oUF_MoveableFrames: Frames are now [LOCKED].")
	end
	return true
end

SLASH_OUFMOVEABLEFRAMES1 = "/mvf";
SlashCmdList["OUFMOVEABLEFRAMES"] = SlashCommand;