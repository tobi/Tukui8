function tAutoInvite_OnLoad()
  this:RegisterEvent("CHAT_MSG_WHISPER");
  end
function tAutoInvite_OnEvent()

if (arg1 == "invite") then
	InviteUnit(arg2);
	SendChatMessage("invite inc", "WHISPER", nil , arg2);
	end
end