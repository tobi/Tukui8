function tAutoInvite_OnLoad()
  this:RegisterEvent("CHAT_MSG_WHISPER");
end

function tAutoInvite_OnEvent()
	if (arg1 == "invite" or arg1 == "inv") then
		InviteUnit(arg2);
	end
end