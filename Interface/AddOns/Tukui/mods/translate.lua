--[[
		Ceci est pour ceux qui ont des connaissances lua et qui aurait le courage de traduire tukui vers d'autre langue.
		This is for those with lua knowledge, which would have the courage translate Tukui into other languages.
--]]

local L = GetLocale()

if(L=="ruRU") then
       -- translate here for russian
       -- by Asurai

       -- tpanels
    tp_guild = "Гильдия"
    tp_noguild = "Не в Гильдии"
    tp_bags = "Сумки: "
    tp_friends = "Друзья"
    tp_online = "В сети: "
    tp_armor = "Броня"
    tp_earned = "Заработано:"
    tp_spent = "Потрачено:"
    tp_deficit = "Убыток:"
    tp_profit = "Прибыль:"
    tp_wg = "Времени до Озера:"
    tp_friendlist = "Список друзей:"
    tp_inprogress = "Идет"
	tp_unavailable = "Не доступно"

    Slots = {
       [1] = {1, "Голова", 1000},
       [2] = {3, "Плечо", 1000},
       [3] = {5, "Грудь", 1000},
       [4] = {6, "Пояс", 1000},
       [5] = {9, "Запястья", 1000},
       [6] = {10, "Кисти рук", 1000},
       [7] = {7, "Ноги", 1000},
       [8] = {8, "Ступни", 1000},
       [9] = {16, "Правая рука", 1000},
       [10] = {17, "Левая рука", 1000},
       [11] = {18, "Дальний бой", 1000}
    }
       
       -- weakened soul plugin
    wsdebuff = "Ослабленная душа"
       
    -- innerfire plugin
    ifbuff = "Внутренний огонь"
       
    -- ouf_tukz
    ouf_offline = "Вне сети"
    ouf_dead = "Мертв"
    ouf_ghost = "Дух"
    ouf_lowmana = "МАНА"
    ouf_threattext = "Угроза на цели:"
       
    -- ouf_tukz_raid_dps
    ouf_offlinedps = "Вне сети"
    ouf_deaddps = "Мертв"
       
    -- ouf_tukz_raid_heal
    ouf_ghostheal = "ДУХ"
    ouf_deadheal = "МЕРТВ"
	
	targetyou = "|cffff4444>>СМОТРИТ НА ВАС<<|r"
	
elseif(L=="deDE") then
   -- tpanels
   tp_guild = "Gilde"
   tp_noguild = "Keine Gilde"
   tp_bags = "Taschen: "
   tp_friends = "Freunde"
   tp_online = "Online: "
   tp_armor = "Rüstung"
   tp_earned = "Verdient:"
   tp_spent = "Ausgegeben:"
   tp_deficit = "Defizit:"
   tp_profit = "Profit:"
   tp_wg = "Zeit bis Tausendwinter:"
   tp_friendlist = "Freunde:"
   tp_inprogress = "Wird erstellt"
   tp_unavailable = "Nicht verfügbar"

   Slots = {
      [1] = {1, "Helm", 1000},
      [2] = {3, "Schulter", 1000},
      [3] = {5, "Brust", 1000},
      [4] = {6, "Gürtel", 1000},
      [5] = {9, "Armschienen", 1000},
      [6] = {10, "Handschuhe", 1000},
      [7] = {7, "Beine", 1000},
      [8] = {8, "Stiefel", 1000},
      [9] = {16, "Haupthand", 1000},
      [10] = {17, "Nebenhand", 1000},
      [11] = {18, "Fernwaffe", 1000}
   }
   
   -- weakened soul plugin
   wsdebuff = "Geschwächte Seele"
   
   -- inner fire plugin
   ifbuff = "Inneres Feuer"
   
   ouf_offline = "Offline"
   ouf_dead = "Tot"
   ouf_ghost = "Geist"
   ouf_lowmana = "WENIG MANA"
   ouf_threattext = "Aggro am aktuellen Ziel:"
   
   -- ouf_tukz_raid_dps
   ouf_offlinedps = "Offline"
   ouf_deaddps = "Tot"
   
   -- ouf_tukz_raid_heal
   ouf_ghostheal = "GEIST"
   ouf_deadheal = "TOT"
   
   targetyou = "|cffff4444>>DICH<<|r"
		
elseif(L=="frFR") then
	-- tpanels
	tp_guild = "Guilde"
	tp_noguild = "Pas de Guilde"
	tp_bags = "Sacs: "
	tp_friends = "Amis"
	tp_online = "En ligne: "
	tp_armor = "Armure"
	tp_earned = "Gagné:"
	tp_spent = "Depensé:"
	tp_deficit = "Déficit:"
	tp_profit = "Profit:"
	tp_wg = "Prochain Joug D'hiver:"
	tp_friendlist = "Liste d'amis:"
	tp_inprogress = "En cours"
	tp_unavailable = "Pas disponible"

	Slots = {
	[1] = {1, "Tête", 1000},
	[2] = {3, "Épaule", 1000},
	[3] = {5, "Plastron", 1000},
	[4] = {6, "Ceinture", 1000},
	[5] = {9, "Bracelet", 1000},
	[6] = {10, "Mains", 1000},
	[7] = {7, "Jambes", 1000},
	[8] = {8, "Bottes", 1000},
	[9] = {16, "Main droite", 1000},
	[10] = {17, "Main gauche", 1000},
	[11] = {18, "À Distance", 1000}
	}
	
	-- weakened soul plugin
	wsdebuff = "Ame affaiblie"
	
	-- innerfire plugin
	ifbuff = "Feu Intérieur"
	
	-- ouf_tukz
	ouf_offline = "Hors ligne"
	ouf_dead = "Mort"
	ouf_ghost = "Fantome"
	ouf_lowmana = "MANA FAIBLE"
	ouf_threattext = "Menace sur la cible actuelle:"
	
	-- ouf_tukz_raid_dps
	ouf_offlinedps = "Hors ligne"
	ouf_deaddps = "Mort"
	
	-- ouf_tukz_raid_heal
	ouf_ghostheal = "FANTOME"
	ouf_deadheal = "MORT"
	
	targetyou = "|cffff4444>>VOUS CIBLE<<|r"
	
else
	--tpanels
	tp_guild = "Guild"
	tp_noguild = "No Guild"
	tp_bags = "Bags: "
	tp_friends = "Friends"
	tp_online = "Online: "
	tp_armor = "Armor"
	tp_earned = "Earned:"
	tp_spent = "Spent:"
	tp_deficit = "Deficit:"
	tp_profit = "Profit:"
	tp_wg = "Time to Wintergrasp:"
	tp_friendlist = "Friends list:"
	tp_inprogress = "In Progress"
	tp_unavailable = "Unavailable"
	
	Slots = {
		[1] = {1, "Head", 1000},
		[2] = {3, "Shoulder", 1000},
		[3] = {5, "Chest", 1000},
		[4] = {6, "Waist", 1000},
		[5] = {9, "Wrist", 1000},
		[6] = {10, "Hands", 1000},
		[7] = {7, "Legs", 1000},
		[8] = {8, "Feet", 1000},
		[9] = {16, "Main Hand", 1000},
		[10] = {17, "Off Hand", 1000},
		[11] = {18, "Ranged", 1000}
	}
	
	-- weakened soul plugin
	wsdebuff = "Weakened Soul"
	
	-- inner fire plugin
	ifbuff = "Inner Fire"
	
	ouf_offline = "Offline"
	ouf_dead = "Dead"
	ouf_ghost = "Ghost"
	ouf_lowmana = "LOW MANA"
	ouf_threattext = "Threat on current target:"
	
	-- ouf_tukz_raid_dps
	ouf_offlinedps = "Offline"
	ouf_deaddps = "Dead"
	
	-- ouf_tukz_raid_heal
	ouf_ghostheal = "GHOST"
	ouf_deadheal = "DEAD"
	
	-- tooltip
	targetyou = "|cffff4444>>TARGETING YOU<<|r"
end
