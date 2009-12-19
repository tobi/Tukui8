
--[[
		This file is for adding of deleting a spellID for a specific encounter on Grid layout.
		
		The best way to add or delete spell is to go at www.wowhead.com, search for a spell :
		Example : Incinerate Flesh from Lord Jaraxxus -> http://www.wowhead.com/?spell=67049
		Take the number ID at the end of the URL, and add it to the list
		
		That's it, That's all! 
		
		Tukz
		
		NOTE : AURAWATCH IS DISABLED BY DEFAULT, ENABLE IT IN TUKUI.CONFIG!
--]]


--------------------------------------------------------------------------------------------
-- Grid encounter aura watch for raid
--------------------------------------------------------------------------------------------

-- Icecrown Citadel "most dangerous" spellID's addition is from Mynd from Last Resort Guild
if raidunitdebuffwatch == true then
	spellIDs = {
			  
			 --Naxxramas
			  27808, --Frost Blast
			  32407, --Strange Aura
			  28408, --Chains of Kel'Thuzad

			 --Ulduar
			  66313, --Fire Bomb
			  63134, --Sara's Blessing
			  62717, --Slag Pot
			  63018, --Searing Light
			  64233, --Gravity Bomb
			  63495, --Static Disruption

			 --Trial of the Crusader
			  66406, --Snobolled!
			  67574, --Pursued by Anub'arak
			  68509, --Penetrating Cold
			  67651, --Arctic Breath
			  68127, --Legion Flame
			  67049, --Incinerate Flesh
			  66869, --Burning Bile
			  66823, --Paralytic Toxin

			 -- Icecrown Citadel
			  71224, --Mutilated infection
			  71822, --Shadow resonance
			  70447, --Ooze root lol
			  72293, --mark-of-the-fallen-champion
			  72448, --rune-of-blood
			  71473, --essence-of-the-vampyr-queen
			  71624, --delirious-slash
			  70923, --uncontrollable-frenzy
			  70588, --suppression
			  71738, --corrosion
			  71733, --acid-burst
			  72108, --death-and-decay
			  71289, --dominate-mind
			  69762, --unchained-magic
			  69651, --wounding-strike

			 --Other debuff
			  6215,  --Fear
			  67479, --Impale
			 
			 -- a Testing spell for tukz when coding
			  --552, -- priest abolish disease buff
			}
end