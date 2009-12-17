local AddOn = CreateFrame("Frame")
local OnEvent = function(self, event, ...) self[event](self, event, ...) end
AddOn:SetScript("OnEvent", OnEvent)

local player = UnitName("player")
local ChatFrameEditBox = ChatFrameEditBox
local ChatFrame1 = ChatFrame1
local replace = string.gsub
local find = string.find
local _G = _G

chatfont 				= "fonts\\ARIALN.ttf"

local replaceschan = {
	['Гильдия'] = '[Г]',
	['Группа'] = '[Гр]',
	['Рейд'] = '[Р]',
	['Лидер рейда'] = '[ЛР]',
	['Объявление рейду'] = '[ОР]',
	['Офицер'] = '[О]',
	['Поле боя'] = '[ПБ]',
	['Лидер поля боя'] = '[ЛПБ]', 
	['Guilde'] = '[G]',
	['Groupe'] = '[GR]',
	['Chef de raid'] = '[RL]',
	['Avertissement Raid'] = '[AR]',
	['Officier'] = '[O]',
	['Champs de bataille'] = '[CB]',
	['Chef de bataille'] = '[CDB]',
	['Guild'] = '[G]',
	['Party'] = '[P]',
	['Party Leader'] = '[PL]',
	['Raid'] = '[R]',
	['Raid Leader'] = '[RL]',
	['Raid Warning'] = '[RW]',
	['Officer'] = '[O]',
	['Battleground'] = '[B]',
	['Battleground Leader'] = '[BL]',
	['(%d+)%. .-'] = '[%1]',
}

-- editbox background
local x=({ChatFrameEditBox:GetRegions()})
x[6]:SetAlpha(0)
x[7]:SetAlpha(0)
x[8]:SetAlpha(0)

-- Player entering the world
local function PLAYER_ENTERING_WORLD()
	local TimeNotAtBottom = { }
	
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton:SetScript("OnShow", function(self) self:Hide() end)
	
	for i = 1, NUM_CHAT_WINDOWS do
		-- Hide chat buttons
		_G["ChatFrame"..i.."UpButton"]:Hide()
		_G["ChatFrame"..i.."DownButton"]:Hide()
		_G["ChatFrame"..i.."BottomButton"]:Hide()
		_G["ChatFrame"..i.."UpButton"]:SetScript("OnShow", function(self) self:Hide() end)
		_G["ChatFrame"..i.."DownButton"]:SetScript("OnShow", function(self) self:Hide() end)
		_G["ChatFrame"..i.."BottomButton"]:SetScript("OnShow", function(self) self:Hide() end)
		
		-- Hide chat textures backdrop
		if ChatLock == true then
			for j = 1, #CHAT_FRAME_TEXTURES do
				_G["ChatFrame"..i..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
			end
		end

		-- Stop the chat frame from fading out
		_G["ChatFrame"..i]:SetFading(false)
		if ChatLock == true then
			-- Change the chat frame font 
			_G["ChatFrame"..i]:SetFont(chatfont, 12)
		end
		-- Allow for scrolling through the chat
		-- Also force chat to the bottom after 30 seconds
		TimeNotAtBottom[i] = 0
		_G["ChatFrame"..i]:SetScript("OnMouseWheel", function(self, ...)
			if arg1 > 0 then
				self:ScrollUp()
				TimeNotAtBottom[i] = 0
				self:SetScript("OnUpdate", function(self, t)
					if TimeNotAtBottom[i] < 30 then
						TimeNotAtBottom[i] = TimeNotAtBottom[i] + t
					else
						self:ScrollToBottom()
						self:SetScript("OnUpdate", nil)
					end
				end)
			elseif arg1 < 0 then
				if IsShiftKeyDown() then
					self:ScrollToBottom()
					self:SetScript("OnUpdate", nil)
				else
					self:ScrollDown()
					if self:AtBottom() then
						self:SetScript("OnUpdate", nil)
					else
						TimeNotAtBottom[i] = 0
					end
				end
			end
		end)
		_G["ChatFrame"..i]:EnableMouseWheel(true)
		_G["ChatFrame"..i]:SetFrameStrata("LOW")
		_G["ChatFrame"..i]:SetUserPlaced(true)
			
	end
	
	-- Remember last channel
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
	
	-- Texture and align the chat edit box
	local left, mid, right = select(6, ChatFrameEditBox:GetRegions())
	left:Hide(); mid:Hide(); right:Hide()
	ChatFrameEditBox:ClearAllPoints();
	
	ChatFrameEditBox:SetPoint("BOTTOMLEFT", ChatFrame1, "BOTTOMLEFT", -2, -33)
	ChatFrameEditBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 4, -33)

	-- Disable alt key usage
	ChatFrameEditBox:SetAltArrowKeyMode(false)
	
	-- Align the text to the right on cf3
	ChatFrame4:SetJustifyH("RIGHT")
	
	if ChatLock == true then
		SetCVar("chatLocked", 1)
		-- Position the general chat frame
		ChatFrame1:ClearAllPoints()
		ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, 31, 48)
		ChatFrame1:SetWidth(tinfowidth + 1)
		ChatFrame1:SetHeight(111)
		
		-- Position the combatlog
		ChatFrame4:ClearAllPoints()
		ChatFrame4:SetPoint("BOTTOMRIGHT", UIParent, -31, 48)
		ChatFrame4:SetWidth(tinfowidth + 1)
		ChatFrame4:SetHeight(111)
	else
		SetCVar("chatLocked", 0)
	end
end

AddOn:RegisterEvent("PLAYER_ENTERING_WORLD")
AddOn["PLAYER_ENTERING_WORLD"] = PLAYER_ENTERING_WORLD

-- Get colors for player classes
local function ClassColors(class)
	if not class then return end
	class = (replace(class, " ", "")):upper()
	local c = RAID_CLASS_COLORS[class]
	if c then
		return string.format("%02x%02x%02x", c.r*255, c.g*255, c.b*255)
	end
end

-- For /Who and Player Logins
function CHAT_MSG_SYSTEM(...)
	local login = select(3, find(arg1, "^|Hplayer:(.+)|h%[(.+)%]|h has come online."))
	local classColor = "999999"
	local foundColor = true
			
	if login then
		local found = false
		if GetNumFriends() > 0 then ShowFriends() end
		
		for friendIndex = 1, GetNumFriends() do
			local friendName, _, class = GetFriendInfo(friendIndex)
			if friendName == login then
				classColor = ClassColors(class)
				found = true
				break
			end
		end
		
		if not found then
			if IsInGuild() then GuildRoster() end
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(guildIndex)
				if guildMemberName == login then
					classColor = ClassColors(class)
					break
				end
			end
		end
		
	end
	
	if login then
		-- Hook the message function
		local AddMessageOriginal = ChatFrame1.AddMessage
		local function AddMessageHook(frame, text, ...)
			text = replace(text, "^|Hplayer:(.+)|h%[(.+)%]|h", "|Hplayer:%1|h|cff"..classColor.."%2|r|h")
			ChatFrame1.AddMessage = AddMessageOriginal
			return AddMessageOriginal(frame, text, ...)
		end
		ChatFrame1.AddMessage = AddMessageHook
	end
	
end
AddOn:RegisterEvent("CHAT_MSG_SYSTEM")
AddOn["CHAT_MSG_SYSTEM"] = CHAT_MSG_SYSTEM

-- Hook into the AddMessage function
local AddMessageOriginal = ChatFrame1.AddMessage
local function AddMessageHook(frame, text, ...)
	-- chan text smaller or hidden
	for k,v in pairs(replaceschan) do
		text = text:gsub('|h%['..k..'%]|h', '|h'..v..'|h')
	end
	text = replace(text, "has come online.", "is now |cff298F00online|r !")
	text = replace(text, "|Hplayer:(.+)|h%[(.+)%]|h has earned", "|Hplayer:%1|h%2|h has earned")
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h whispers:", "From [|Hplayer:%1:%2|h%3|h]:")
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h says:", "[|Hplayer:%1:%2|h%3|h]:")	
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h yells:", "[|Hplayer:%1:%2|h%3|h]:")	
	return AddMessageOriginal(frame, text, ...)
end
ChatFrame1.AddMessage = AddMessageHook

-----------------------------------------------------------------------------
-- copy url
-----------------------------------------------------------------------------

local color = "BD0101"
local pattern = "[wWhH][wWtT][wWtT][\46pP]%S+[^%p%s]"

function string.color(text, color)
	return "|cff"..color..text.."|r"
end

function string.link(text, type, value, color)
	return "|H"..type..":"..tostring(value).."|h"..tostring(text):color(color or "ffffff").."|h"
end

StaticPopupDialogs["LINKME"] = {
	text = "URL COPY",
	button2 = CANCEL,
	hasEditBox = true,
    	hasWideEditBox = true,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	whileDead = 1,
	maxLetters = 255,
}

local function f(url)
	return string.link("["..url.."]", "url", url, color)
end

local function hook(self, text, ...)
	self:f(text:gsub(pattern, f), ...)
end

for i = 1, NUM_CHAT_WINDOWS do
	if ( i ~= 2 ) then
		local frame = _G["ChatFrame"..i]
		frame.f = frame.AddMessage
		frame.AddMessage = hook
	end
end

local f = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(self, link, text, button)
	local type, value = link:match("(%a+):(.+)")
	if ( type == "url" ) then
		local dialog = StaticPopup_Show("LINKME")
		local editbox = _G[dialog:GetName().."WideEditBox"]  
		editbox:SetText(value)
		editbox:SetFocus()
		editbox:HighlightText()
		local button = _G[dialog:GetName().."Button2"]
            
		button:ClearAllPoints()
           
		button:SetPoint("CENTER", editbox, "CENTER", 0, -30)
	else
		f(self, link, text, button)
	end
end

-----------------------------------------------------------------------------
-- copy chat
-----------------------------------------------------------------------------

--Creat Frame--
local function CreatCopyFrame()
	frame = CreateFrame("Frame", "CopyFrame", UIParent)
	frame:SetBackdrop({
		bgFile = BLANK_TEXTURE, 
		edgeFile = BLANK_TEXTURE,    
		edgeSize = 1, 
		insets = {top = -1, left = -1, bottom = -1, right = -1}
	})
	
	frame:SetBackdropColor(.1,.1,.1)
	frame:SetWidth(700)
	frame:SetHeight(190)
	frame:SetScale(0.77)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:Hide()
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

	editBox = CreateFrame("EditBox", "CopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(999)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(690)
	editBox:SetHeight(190)

	scrollArea:SetScrollChild(editBox)

	local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

	isf = true
end

--GetChatText Function--
local function GetChatText(id)
	id = (tonumber(id) or 1)
	if id > NUM_CHAT_WINDOWS or id == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("Copy: Invalid Chat Frame ID")
		return 
	end
	
	local tab = {}
	local chatid = _G[format("ChatFrame%d",  id)]
	local lines = { chatid:GetRegions() }

    for i=#lines, 1, -1 do
        if lines[i]:GetObjectType() == "FontString" then
            table.insert(tab, lines[i]:GetText())
        end
    end
	
    str = table.concat(tab, "\n")

	if not isf then CreatCopyFrame() end
	frame:Show()
	editBox:SetText(str)
end

--SlashCmd--
SLASH_COPY1 = "/copy"
SlashCmdList["COPY"] = function(id) GetChatText(id) end

------------------------------------------------------------------------
--	No more click on item chat link
------------------------------------------------------------------------

local orig1, orig2 = {}, {}
local GameTooltip = GameTooltip

local linktypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}


local function OnHyperlinkEnter(frame, link, ...)
	local linktype = link:match("^([^:]+)")
	if linktype and linktypes[linktype] then
		GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end

	if orig1[frame] then return orig1[frame](frame, link, ...) end
end

local function OnHyperlinkLeave(frame, ...)
	GameTooltip:Hide()
	if orig2[frame] then return orig2[frame](frame, ...) end
end


local _G = getfenv(0)
for i=1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	orig1[frame] = frame:GetScript("OnHyperlinkEnter")
	frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)

	orig2[frame] = frame:GetScript("OnHyperlinkLeave")
	frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
end

