-- Binding Variables
BINDING_HEADER_TTELL = "TTell"
BINDING_NAME_TELLTARGET = "Whisper Target"

-- TTell Variables
TTell = {}

local debug = 0

function TTell:OnLoad()
	-- Slash Commands
	SlashCmdList["TELLTARGET"] = function(msg)
		TTell:Slash_TellTarget(msg);
	end
	SLASH_TELLTARGET1 = "/tt"
	SLASH_TELLTARGET2 = "/wt"

	SlashCmdList["RETELLTARGET"] = function(msg)
		TTell:Slash_ReTellTarget(msg);
	end
	SLASH_RETELLTARGET1 = "/rt"

	-- Secure Functon Hook
	hooksecurefunc("ChatEdit_OnSpacePressed", TTell.OnSpacePressed);

	this:RegisterEvent("ADDON_LOADED");
end

function TTell:OnEvent()
	if ( event == "ADDON_LOADED" and arg1 == "TTell" and debug) then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF0099FFTTell " .. version .. " loaded.");
	end
end

function TTell:Debug(msg)
	if ( debug == 1 ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF0099FFTTell Debug: |cFFFF7000" .. msg);
	end
end

function TTell:OnSpacePressed()
	TTell:Debug("Function Call - TTell:OnSpacePressed()");

	-- Get editBox contents
	local text = strlower(DEFAULT_CHAT_FRAME.editBox:GetText());

	if ( strsub(text, 1, 1) ~= "/"  or strlen(text) > 4 ) then
		return;
	end

	-- See if the editBox contains '/tt ' or '/wt '
	if ( strmatch(text, "^/[tw]t $") ) then
		TTell:Debug("String Match - |cFF00FF00/tt or /wt");
		TTell:TellTarget();
	-- See if the editBox contains '/rt '
	elseif ( strmatch(text, "^/rt $") ) then
		TTell:Debug("String Match - |cFF00FF00/rt");
		TTell:ReTellTarget();
	else
		TTell:Debug("String Match - Not Found!");
		return;
	end
end

function TTell:TellTarget()
	TTell:Debug("Function Call - TTell:TellTarget()");

	if ( UnitIsPlayer("target") and UnitIsFriend("player", "target") ) then
		DEFAULT_CHAT_FRAME.editBox:Hide();
		DEFAULT_CHAT_FRAME.editBox:SetAttribute("chatType", "WHISPER");
		DEFAULT_CHAT_FRAME.editBox:SetAttribute("tellTarget", string.gsub(GetUnitName("target", "true"), "%s", "", 2));
		if ( not DEFAULT_CHAT_FRAME.editBox:IsShown() ) then
			ChatFrame_OpenChat("");
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cFF0099FFtChat: |cFFFFFF00Missing or invalid target.");
	end
end

function TTell:Slash_TellTarget(msg)
	TTell:Debug("Function Call - TTell:Slash_TellTarget()");

	if ( UnitIsPlayer("target") and UnitIsFriend("player", "target") ) then
		SendChatMessage(msg, "WHISPER", GetDefaultLanguage("player"), string.gsub(GetUnitName("target", "true"), "%s", "", 2));
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cFF0099FFtChat: |cFFFFFF00Missing or invalid target.");
	end
end

function TTell:ReTellTarget()
	TTell:Debug("Function Call - TTell:ReTellTarget()");

	local lastTold = ChatEdit_GetLastToldTarget();
	if ( lastTold ~= "" ) then
		DEFAULT_CHAT_FRAME.editBox:Hide();
		DEFAULT_CHAT_FRAME.editBox:SetAttribute("chatType", "WHISPER");
		DEFAULT_CHAT_FRAME.editBox:SetAttribute("tellTarget", lastTold);
		if ( not DEFAULT_CHAT_FRAME.editBox:IsShown() ) then
			ChatFrame_OpenChat("");
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cFF0099FFtChat: |cFFFFFF00No previous tell/whisper target.");
	end
end

function TTell:Slash_ReTellTarget(msg)
	TTell:Debug("Function Call - TTell:Slash_ReTellTarget()");

	local lastTold = ChatEdit_GetLastToldTarget();
	if ( lastTold ~= "" ) then
		SendChatMessage(msg, "WHISPER", GetDefaultLanguage("player"), lastTold);
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cFF0099FFtChat: |cFFFFFF00No previous tell/whisper target.");
	end
end