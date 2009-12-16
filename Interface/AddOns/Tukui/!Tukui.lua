-- Setup the UI when the user types /configure
-- This will include:
---------------------
-- Fix UI Variables
-- Setup Chat Frames
-- Print the current resolution to chat
-- etc

BLANK_TEXTURE			= "Interface\\AddOns\\Tukui\\media\\WHITE64X64"

local L = GetLocale()

-- Function to create "Panels" with the standard color scheme
function CreatePanel(height, width, x, y, anchorPoint, anchorPointRel, anchor, level, parent, strata)
	local Panel = CreateFrame("Frame", _, parent)
	Panel:SetFrameLevel(level)
	Panel:SetFrameStrata(strata)
	Panel:SetHeight(height)
	Panel:SetWidth(width)
	Panel:SetPoint(anchorPoint, anchor, anchorPointRel, x, y)
	Panel:SetBackdrop( { 
	  bgFile = BLANK_TEXTURE, 
	  edgeFile = BLANK_TEXTURE, 
	  tile = false, tileSize = 0, edgeSize = 1, 
	  insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	Panel:SetBackdropColor(0.1,0.1,0.1,1)
	Panel:SetBackdropBorderColor(0.6,0.6,0.6,1)
end 

if(AutoScale==true) then
	local scalefix = CreateFrame("Frame")
    scalefix:RegisterEvent("PLAYER_LOGIN")
    scalefix:SetScript("OnEvent", function()
        local index = GetCurrentResolution();
		local resolution = select(index, GetScreenResolutions());
        if(resolution == "1680x1050" or resolution == "1920x1080" or resolution == "1920x1200" or resolution == "1600x900" or resolution == "2048x1152" or resolution == "1776x1000" or resolution == "2560x1600") then
			SetCVar("useUiScale", 1)
            SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"));
			if(LoginMsg==true) then
					if(L=="ruRU") then
					    print(" ")
						print("Добро пожаловать в Tukui V8 под патч 3.3!  www.tukui.org")
						print(" ")
						print("Текущее разрешение:", resolution);
						print(" ")
						print("Разрешение вашего экрана поддерживается.. Наслаждайтесь!")
						print("Не забудьте |cffFF0000/configure|r если это Ваше первое использование!")
						print(" ")
						print("Введите |cffFF0000/uihelp|r для большей информации!")
						print(" ")					
					elseif(L=="frFR") then
						print("Bienvenue sur Tukui V8 pour le patch 3.3 ! http://www.tukui.org")
						print(" ")
						print("Votre résolution:", resolution);
						print(" ")
						print("Votre résolution est bonne ... bon jeu !")
						print("N'oubliez pas de taper /configure si c'est votre première utilisation.")
						print(" ")
						print("Pour plus d'informations, tapez /uihelp")
						print(" ")
					elseif(L=="deDE") then	
						print(" ")
						print("Willkommen bei Tukui V8 für Patch 3.3 !  www.tukui.org")
						print(" ")
						print("Aktuelle Auflösung:", resolution);
						print(" ")
						print("Deine Auflösung wird unterstützt... Viel Spass !")
						print("Nicht vergessen |cffFF0000/configure|r wenn du diese Meldung das erste mal siehst!")
						print(" ")
						print("Für mehr Infos |cffFF0000/uihelp|r eintippen!")
						print(" ")						
					else
						print(" ")
						print("Welcome on Tukui V8 for patch 3.3 !  www.tukui.org")
						print(" ")
						print("Current resolution:", resolution);
						print(" ")
						print("Your screen resolution is supported... Enjoy !")
						print("Don't forget to |cffFF0000/configure|r if it's the first time you use it!")
						print(" ")
						print("Type |cffFF0000/uihelp|r for more infos!")
						print(" ")
					end
			end
        else
			print(resolution);
            SetCVar("useUiScale", 0)
			StaticPopup_Show("DISABLE_UI")
        end
    end)
end

local function DisableTukui()
        DisableAddOn("Tukui"); 
		ReloadUI()
		FCF_ResetChatWindows()
		SetCVar("chatLocked", 0)
end


--------------------------------------------------------------------
-- CREDIT : FatalEntity for /configure command 
--------------------------------------------------------------------

local function TukuiConfig()
	-- Setup Basic InGame settings
	SetCVar("useUiScale", 1)
	SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
	SetCVar("buffDurations", 1)
	SetCVar("chatLocked", 1)
	SetCVar("showClock", 0)
	SetCVar("lootUnderMouse", 1)
	SetCVar("scriptErrors", 0)
	SetCVar("autoSelfCast", 1)
	SetCVar("secureAbilityToggle", 0)
		
	SetMultisampleFormat(1)

	FCF_ResetChatWindows()
	FCF_DockFrame(ChatFrame2)
	FCF_OpenNewWindow("Spam")

	FCF_OpenNewWindow("Loot")
	FCF_UnDockFrame(ChatFrame4)
	FCF_SetLocked(ChatFrame4, 1);
	ChatFrame4:Show();

	
	-- Show class colors
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "GUILD_OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	
	-- Setup chat
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_AddChannel(ChatFrame3, "Trade")
	ChatFrame_AddChannel(ChatFrame3, "General")
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
		
	-- Setup the spam chat frame
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	
	-- Setup the right chat
	ChatFrame_RemoveAllMessageGroups(ChatFrame4);
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")
		
	-- Setup General, Trade, and LFG colors
	ChangeChatColor("CHANNEL2", 0/255, 153/255, 204/255)
	ChangeChatColor("CHANNEL4", 0/255, 153/255, 204/255)

	ReloadUI()
end

-- Create confirmation popup
if(L=="ruRU") then
	StaticPopupDialogs["CONFIGURE_UI"] = {
	  text = "Tukui настройка по умолчанию. Продолжаем?",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = TukuiConfig,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
elseif(L=="frFR") then
	StaticPopupDialogs["CONFIGURE_UI"] = {
	  text = "Appliquer les paramètres par défaut de Tukui?",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = TukuiConfig,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
elseif(L=="deDE") then
	StaticPopupDialogs["CONFIGURE_UI"] = {
	  text = "Möchtest du wirklich die Tukui Standard Konfiguration laden?",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = TukuiConfig,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}	
else
	StaticPopupDialogs["CONFIGURE_UI"] = {
	  text = "Tukui default configuration. Do you wish to proceed?",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = TukuiConfig,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
end

SLASH_CONFIGURE1 = "/Configure"
SlashCmdList["CONFIGURE"] = function() StaticPopup_Show("CONFIGURE_UI") end

if(L=="ruRU") then
	StaticPopupDialogs["DISABLE_UI"] = {
	  text = "Tukui не работает под этим разрешением, отключаем Tukui? (Cancel если желаете попробовать другое разрешение)",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = DisableTukui,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
elseif(L=="frFR") then
	StaticPopupDialogs["DISABLE_UI"] = {
	  text = "Tukui ne fonctionne pas avec cette résolution, voulez-vous désactiver Tukui? (Annuler si vous souhaitez essayer une autre résolution)",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = DisableTukui,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
elseif(L=="deDE") then
	  StaticPopupDialogs["DISABLE_UI"] = {
	  text = "Tukui läuft nicht auf deiner Auflösung, möchtest du Tukui deaktivieren? (Abbrechen, wenn du eine andere Auflösung testen möchtest)",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = DisableTukui,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
else
	StaticPopupDialogs["DISABLE_UI"] = {
	  text = "Tukui don't work for this resolution, do you want to disable Tukui? (Cancel if you want to try another resolution)",
	  button1 = ACCEPT,
	  button2 = CANCEL,
	  OnAccept = DisableTukui,
	  timeout = 0,
	  whileDead = 1,
	  hideOnEscape = 1
	}
end


if(L=="ruRU") then
	StaticPopupDialogs["DISABLE_RAID"] = {
	  text = "2 активных раскладки рейдовых фреймов, выберите раскладку. Введите /dps для танка/дамагера или /heal для хилера",
	  timeout = 0,
	  whileDead = 1,
	}
elseif(L=="frFR") then
	StaticPopupDialogs["DISABLE_RAID"] = {
	  text = "2 modèles de raid sont actuellement actifs, tapez /dps pour activer le modèle *dps-tank* ou /heal pour activer le modèle *soin*",
	  timeout = 0,
	  whileDead = 1,
	}
elseif(L=="deDE") then	
	StaticPopupDialogs["DISABLE_RAID"] = {
	  text = "2 Raid Layouts sind aktiv, bitte wähle ein Layout aus. /dps für das dps-tank Raid Layout oder /heal für das Heiler Raid Layout",
	  timeout = 0,
	  whileDead = 1,
	}	
else
	StaticPopupDialogs["DISABLE_RAID"] = {
	  text = "2 raid layouts are active, please select a layout. Type /dps for dps-tank raid layout or /heal for healing raid layout",
	  timeout = 0,
	  whileDead = 1,
	}
end
	
-- tempory fix for an error in tukui since V5

function PetActionButton_OnEvent (self, event, ...)
if ( event == "UPDATE_BINDINGS" ) then
-- DO NOTHING, DAM STUPID ERROR THAT I WANT TO DELETE FROM BLIZZARD DEFAULT UI
return;
end
end

-------------------------------------------------------------------
-- modify position of some frames
-------------------------------------------------------------------

hooksecurefunc(WatchFrame,"SetPoint",function(_,_,parent) -- quest watch frame
	if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
		WatchFrame:ClearAllPoints();
		WatchFrame:SetPoint("TOPRIGHT","UIParent","TOPRIGHT",qPosX,qPosY);
	end
end);


hooksecurefunc(DurabilityFrame,"SetPoint",function(self,_,parent) -- durability frame
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
        DurabilityFrame:ClearAllPoints();
        DurabilityFrame:SetPoint("BOTTOM",UIParent,"BOTTOM",0,160);
    end
end);

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(_,_,parent) -- vehicle seat indicator
    if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
        VehicleSeatIndicator:ClearAllPoints();
        VehicleSeatIndicator:SetPoint("BOTTOM",UIParent,"BOTTOM",0,160);
    end
end);

------------------------------------------------------------------------
--	UI HELP
------------------------------------------------------------------------

-- Print Help Messages
local function UIHelp()
	if (L=="ruRU") then
		print(" ")
		print("|cff00ff00Основные комманды|r")
		print("|cffFF0000/tcdt|r - Tukui Arena Enemy Cooldown Tracker - Легкий трекер ПвП способностей врага. (Только иконка)")
		print("|cffFF0000/rl|r - Перезагружает интерфейс пользователя.")
		print("|cffFF0000/gm|r - Послать запрос ГМу, открывает окно помощи.")
		print("|cffFF0000/frame|r - Определяет имя выбранного фрейма. (полезно для мододелов)")
		print("|cffFF0000/abshow|r - Открывает правые панели.")
		print("|cffFF0000/abhide|r - Прячет правые панели.")
		print("|cffFF0000/abconfig|r - Показывает все спелл-бары (3, 4, 5 и панель питомца).")
		print("|cffFF0000/setscale|r - Устанавливает пиксель-идеальный UIScale под Ваше разрешение если автоматический UIScale отключен.")
		print("|cffFF0000/heal|r - Активирует хилерскую раскладку рейдовых фреймов. (Вам нужны oUF_Tukz_Group_heal с tukui.org для этого)")
		print("|cffFF0000/dps|r - Активирует танк/дамагер раскладку рейдовых фреймов.")
		print(" ")
		print("|cff00ff00Информация:|r")
		print("|cffFF0000>|r Правый клик по мини-карте для меню отслеживания.")
		print("|cffFF0000>|r Средний клик по мини-карте для календаря.")
		print("|cffFF0000>|r Левый клик по состоянию на tPanels для отображения статов персонажа.")
		print("|cffFF0000>|r Левый клик по деньгам на tPanels для отображения сумок.")
		print("|cffFF0000>|r Левый клик по времени на tPanels для отображения календаря. Если Вас пригласили на событие то текст времени заменяется приглашением.")
		print("|cffFF0000>|r Левый клик по Гильдии на tPanels для отображения Гильдии.")
		print("|cffFF0000>|r Левый клик по друзьям на tPanels для отображения друзей.")
		print(" ")
		print("|cff00ff00Первое использование:|r")
		print("|cffFF0000>|r /configure автоматически настроит Tukui.")
	elseif(L=="frFR") then
		print("|cff00ff00Commandes Générales|r")
		print("|cffFF0000/tcdt|r - Tukui Arena Enemy Cooldown Tracker - Suivi de sort ennemi pour arêne")
		print("|cffFF0000/rl|r - Recharge votre interface.")
		print("|cffFF0000/gm|r - Pour parler à un GM.")
		print("|cffFF0000/frame|r - Détecte le nom de ce que vous pointez avec votre souris")
		print("|cffFF0000/abshow|r - Affiche les barres de droite selon vos paramètres.")
		print("|cffFF0000/abhide|r - Cache les barres de droite.")
		print("|cffFF0000/abconfig|r - Affiche toutes les barres de droite pour une configuration des sorts.")
		print("|cffFF0000/setscale|r - Change votre échelle d'interface vers une échelle adéquate avec tukui.")
		print("|cffFF0000/heal|r - Active le modèle raid pour soigneur")
		print("|cffFF0000/dps|r - Active le modèle raid pour les *DPS* et *Tank*.")
		print(" ")
		print("|cff00ff00Informations additionnelles :|r")
		print("|cffFF0000>|r Clique droit sur la mini-carte pour afficher le menu *Suivi*.")
		print("|cffFF0000>|r Clique du bouton milieu pour afficher le calendrier.")
		print(" ")
		print("|cff00ff00Première utilisation de Tukui? :|r")
		print("|cffFF0000>|r Tapez /configure pour configurer automatiquement Tukui.")
	elseif(L=="deDE") then
		print(" ")
		print("|cff00ff00Allgemeine Slash Commands|r")
		print("|cffFF0000/tcdt|r - Tukui Arena Gegner Cooldown Anzeige - Low-memory PVP Gegner Cooldown Anzeige. (Nur Icon)")
		print("|cffFF0000/rl|r - Läd das Interface erneut.")
		print("|cffFF0000/gm|r - GM Tickets erstellen oder WoW in-game Hilfe zeigen.")
		print("|cffFF0000/frame|r - Name des Frames anzeigen, über dem sich deine Maus momentan befindet.")
		print("|cffFF0000/abshow|r - Zeige die Balken auf der rechten Seite mit deinen Einstellungen.")
		print("|cffFF0000/abhide|r - Die Balken auf der rechten Seite verstecken.")
		print("|cffFF0000/abconfig|r - Alle Aktionsleisten anzeigen (Leiste 3,4,5 und die Begleiter Leiste, wenn verfügbar).")
		print("|cffFF0000/setscale|r - Ein UIScale für das Pixel Perfect Interface und deine momentane Auflösung setzten. (Wenn automatische UI Skalierung ausgeschaltet ist.")
		print("|cffFF0000/heal|r - Heiler Raid Layout aktivieren.")
		print("|cffFF0000/dps|r - Schadens/Tank Layout aktivieren.")
		print(" ")
		print("|cff00ff00Allgemeine Interface Infos :|r")
		print("|cffFF0000>|r Rechtsklick auf die Minimap um etwas anderes zu verfolgen.")
		print("|cffFF0000>|r Mittlere Maustaste auf die Minimap um den Kalender zu öffnen.")
		print("|cffFF0000>|r Linksklick auf die tPanels Haltbarkeits Anzeige um Character Infos anzuzeigen.")
		print("|cffFF0000>|r Linksklick auf die tPanels Gold Anzeige um die Taschen zu öffnen.")
		print("|cffFF0000>|r Linksklick auf die tPanels Zeit Anzeige um den Kalender zu öffnen. Wenn ihr zu einem Ereignis eingeladen wurded, ist die Zeitanzeige mit einem Einladungs Text überschrieben.")
		print("|cffFF0000>|r Linksklick auf die tPanels Gilden Anzeige um die Gilden-Details zu öffnen.")
		print("|cffFF0000>|r Linksklick auf die tPanels Freundes Anzeige um die Freundes-Liste zu öffnen.")
		print(" ")
		print("|cff00ff00Tukui Anfänger :|r")
		print("|cffFF0000>|r /configure um Tukui automatisch zu konfigurieren.")		
	else
		print(" ")
		print("|cff00ff00General Slash Commands|r")
		print("|cffFF0000/tcdt|r - Tukui Arena Enemy Cooldown Tracker - Low-memory enemy PVP cooldown tracker. (Icon only)")
		print("|cffFF0000/rl|r - Reloads your User Interface.")
		print("|cffFF0000/gm|r - Send GM tickets or show WoW in-game help.")
		print("|cffFF0000/frame|r - Detect frame name you currently mouseover. (very useful for lua editor)")
		print("|cffFF0000/abshow|r - Show right panels with your setting.")
		print("|cffFF0000/abhide|r - Hide right panels.")
		print("|cffFF0000/abconfig|r - Show all bars to put your spells (bar 3,4,5 and pet if available).")
		print("|cffFF0000/setscale|r - Set a pixel perfect UIScale for your current resolution if automatic UIScale is turned off.")
		print("|cffFF0000/heal|r - Enable healing raid layout. (you need oUF_Tukz_Group_heal from tukui.org for this)")
		print("|cffFF0000/dps|r - Enable Dps/Tank raid layout.")
		print(" ")
		print("|cff00ff00General Interface Infos :|r")
		print("|cffFF0000>|r Rightclick the Minimap to select your current tracking.")
		print("|cffFF0000>|r Middleclick the Minimap to show calendar.")
		print("|cffFF0000>|r Leftclick on tPanels durability to show character stats and stuff.")
		print("|cffFF0000>|r Leftclick on tPanels gold to show bags.")
		print("|cffFF0000>|r Leftclick on tPanels time to show calendar. If you got an invite for an event, text time is replaced with a calendar invitation string.")
		print("|cffFF0000>|r Leftclick on tPanels guild to show guild frame.")
		print("|cffFF0000>|r Leftclick on tPanels friends to show friend frame.")
		print(" ")
		print("|cff00ff00First time tukui user :|r")
		print("|cffFF0000>|r /configure to automatically configure Tukui.")
	end
end

SLASH_UIHELP1 = "/UIHelp"
SlashCmdList["UIHELP"] = UIHelp	
------------------------------------------------------------------------
--	AUTO SCALING UI
------------------------------------------------------------------------
SlashCmdList["TUKZSETSCALE"] = function(scale1) Tukz_SetScale(scale1); end
SLASH_TUKZSETSCALE1 = "/setscale";
	function Tukz_SetScale(scale1)
	scale1 = tonumber(scale1)
		if (scale1 == nil) then
			SetCVar("useUIScale",1);
			SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"));
		else
			SetCVar("useUIScale",1);
			SetCVar("uiScale",scale1);
		end
	end


local function FRAME()
	ChatFrame1:AddMessage(GetMouseFocus():GetName()) 
end

SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = FRAME

local function HEAL()
	DisableAddOn("Tukui_Dps_Layout"); 
	EnableAddOn("Tukui_Heal_Layout"); 
	ReloadUI();
end

SLASH_HEAL1 = "/heal"
SlashCmdList["HEAL"] = HEAL

local function DPS()
	DisableAddOn("Tukui_Heal_Layout"); 
	EnableAddOn("Tukui_Dps_Layout");
	ReloadUI();
end

SLASH_DPS1 = "/dps"
SlashCmdList["DPS"] = DPS

local function GM()
	ToggleHelpFrame()
end

------------------------------------------------------------------------
--	Game Master command
------------------------------------------------------------------------

SLASH_GM1 = "/gm"
SlashCmdList["GM"] = GM

------------------------------------------------------------------------
--	ReloadUI command
------------------------------------------------------------------------

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

------------------------------------------------------------------------
--	GM ticket fix
------------------------------------------------------------------------
TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", 0,0)



