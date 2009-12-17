--[[
		This is the file where all options is available for Tukui
		You don't need do relaunch wow.exe after a change, just save the file and /rl in game
--]]

----------------------------------------------------------------------------------------
-- UnitFrame options
----------------------------------------------------------------------------------------

Tukz = {oUF = {
unitcastbar = true, 			-- enable castbar
cblatency = false, 				-- castbar latency
cbicons = true, 				-- castbar icons
auratimer = false, 				-- true to enable timer aura on player or target
auratextscale = 10, 			-- set font size on aura
noPlayerAuras = true, 			-- true to disable oUF buffs/debuffs on the player frame
noTargetAuras = false, 			-- true to disable oUF buffs/debuffs on the target frame
scale = 1, 						-- scale of the unitframes (dont edit this or pixel perfect is gone)
lowThreshold = 20, 				-- low mana threshold for all mana classes
highThreshold = 80, 			-- high mana treshold for hunters
targetpowerpvponly = true, 		-- mana text on pvp enemy target only
totdebuffs = false, 			-- show tot debuff (if true, you need to move pet frame)
playerdebuffsonly = false, 		-- my debuff on target only
showfocustarget = false, 		-- show focus target
showtotalhpmp = false,			-- show total mana / total hp text on player and target.
debuffcolorbytype = false,		-- debuff by color type

font = [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=],

coords = {
	playerX = -225,
	playerY = 60, 

	targetX = 225, 
	targetY = 60, 
	
	totX = 0,
	totY = 60,
	
	petX = 0,
	petY = 104,
	
	focusX = -34,
	focusY = 20,
	
	foctarX = 0,
	foctarY = 224,
}}}

-- grid options (healer mode)
gridposX = 18									-- horizontal unit #1 position value
gridposY = -290									-- vertical unit #1 position value
gridposZ = "TOPLEFT"							-- position grid X,Y values from
gridonly = false								-- Replace 10, 15 mans default layout by grid layout 
showsymbols = true 								-- for grid mode only (healer layout only)
gridaggro = false								-- show "aggro" text on grid unit if a player have aggro from a creature.
raidunitdebuffwatch = false						-- show "dangerous unit debuff" in raid on different encounter. (note: PVE SUX LOL)
gridhealthvertical = true						-- set health bar vertically on 25/40 mans layout 

-- extra options
showrange = true								-- show range on raid unit
showsmooth = true								-- smooth bar animation
showthreat = true								-- show target threat via tpanels left info bar
charportrait = false					 		-- enable portrait

-- priest only plugin
ws_show_time = false 						-- show time remaining on weakened soul bar
ws_show_player = true 						-- show a weakened soul debuff on you
if_warning = true							-- innerfire warning icon when not active and in combat


----------------------------------------------------------------------------------------
-- ARENA
----------------------------------------------------------------------------------------

-- enemy cooldown tracker (mostly interrupt by default)
-- spellIDs edit is via tcooldowntracker.lua
arenatracker = true

-- enable arena enemy unitframe, Alpha, feel free to complete finnish it if you want
t_arena = true

-- position of arena enemy unitframe (from bottom-middle screen)					
ArenaX = 252		-- position X (left/right) on UI
ArenaY = 260		-- position Y (up/down) on UI

-- enable a keybind as a set focus key on arena frame or unit mouseover
focuskey = false
arenamodifier = "shift" -- shift, alt or ctrl
arenamouseButton = "3" -- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any

----------------------------------------------------------------------------------------
-- Panels config (you can't have more than 6 active panels)
----------------------------------------------------------------------------------------

-- position legend : [0=disabled] [1=leftbar, left] [2=leftbar, middle] [3=leftbar, right]
-- position legend : [4=rightbar, left] [5=rightbar, middle] [6=rightbar, right] 

local myname, _ = UnitName("player")
if myname == "Tukz" then
   fps_ms = 5
   mem = 4
   armor = 2
   gold = 0
   wowtime = 6
   friends = 3
   guild = 1
   bags = 0
elseif myname == "Tùkz" then
   fps_ms = 5
   mem = 4
   armor = 2
   gold = 0
   wowtime = 6
   friends = 3
   guild = 1
   bags = 0
else -- default config
   fps_ms = 0
   mem = 2
   armor = 0
   gold = 5
   wowtime = 4
   friends = 1
   guild = 3
   bags = 6
end

tfontsize = 12					-- font size of tpanels stat text

bar345rightpanels = true 		-- show panels background on buttons, right side

time24 = false 					-- set the local or server time in 12h or 24h mode
localtime = true 				-- set local or server time 

tinfowidth = 370				-- set de width of left and right infos bars + chatframe width

----------------------------------------------------------------------------------------
-- Tukz Action bars options
----------------------------------------------------------------------------------------

  -- number of bars you want to show on the right side?
  rightbarnumber = 0 	-- (need to be set at : 0, 1, 2 or 3)
  
  -- right bars and pet on mouseover ?
  rightbars_on_mouseover = 0 -- 1 if you want mouseover
  
  -- space between button
  padding = 4
  petpadding = -4 --(negative numbers because petbar it set to vertical instead of horizontal)
  stancepadding = 1

  -- shapeshift
  move_shapeshift = 1
  lock_shapeshift = 0
  hide_shapeshift = 0
  
  -- scale values
  bar1scale = 1 * 0.72
  bar2scale = 1 * 0.72
  bar3scale = 0.8
  bar45scale = 0.8
  petscale = 1
  shapeshiftscale = 1
 
  -- hide hot key?
  hide_hotkey = 1
  
----------------------------------------------------------------------------------------
-- Tooltip options
----------------------------------------------------------------------------------------

mouseover_units = false 				-- show players, world objects, etc on mouseover
hide_units = false						-- always hide only units (npc, players, etc)
hide_units_combat = false				-- hide units if in combat (useful when mouseover is active)
hide_all_tooltips = false 				-- i don't recommend enabling this, this was a only request for a friend

ttposX = -32 							-- LEFT(-) and RIGHT(+) position via posZ anchor
ttposY = 48 							--  UP(+) and DOWN(-) position via posZ anchor
ttposZ = "BOTTOMRIGHT" 					-- align to
  
----------------------------------------------------------------------------------------
-- Minimap options
----------------------------------------------------------------------------------------

minimapposition = "TOPRIGHT"
minimapposition_x = -22
minimapposition_y = -22

----------------------------------------------------------------------------------------
-- QUEST WATCH FRAME DEFAULT POSITION
----------------------------------------------------------------------------------------

-- default position from topright
qPosX = -300
qPosY = -300

----------------------------------------------------------------------------------------
-- General options
----------------------------------------------------------------------------------------

AutoScale = true              	-- enable auto-scale and auto-detect comptability of Tukui
LoginMsg = true               	-- enable login msg
ChatLock = true 			  	-- chat locked with Tukui setting? (you need to restart wow)
