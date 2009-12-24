if t_arena == true then
	local trinkets, arenaGUID = {}, {}
	 
	do
		local Update = function(self, event, ...)
			if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
				local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName = ...
				if ( eventType == "SPELL_CAST_SUCCESS" ) then
					if( arenaGUID[sourceGUID] ) then
						-- enemy trinket usage
						if( ( spellID == 59752 or spellID == 42292 ) ) then
							TrinketUsed(arenaGUID[sourceGUID])
						end
					end
				end
			elseif (event == "ARENA_OPPONENT_UPDATE") then
				local unit, type = ...
				if ( type == "seen" ) then
					if (UnitExists(unit) and UnitIsPlayer(unit)) then
						arenaGUID[UnitGUID(unit)] = unit
						if ( UnitFactionGroup(unit) == "Horde" ) then
							trinkets[unit].Icon:SetTexture(UnitLevel(unit) == 80 and "Interface\\Addons\\Tukui\\media\\INV_Jewelry_Necklace_38" or "Interface\\Addons\\Tukui\\media\\INV_Jewelry_TrinketPVP_02")
						else
							trinkets[unit].Icon:SetTexture(UnitLevel(unit) == 80 and "Interface\\Addons\\Tukui\\media\\INV_Jewelry_Necklace_37" or "Interface\\Addons\\Tukui\\media\\INV_Jewelry_TrinketPVP_01")
						end
					end
				end
			end
		end

		local frame = CreateFrame("Frame")
		frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		frame:RegisterEvent("ARENA_OPPONENT_UPDATE")
		frame:SetScript("OnEvent", Update)

		function TrinketUsed(unit)
			CooldownFrame_SetTimer(trinkets[unit].cooldownFrame, GetTime(), 120, 1)
		end
	 
		local Enable = function(self)
			if (self.Trinket) then
				self.Trinket.cooldownFrame = CreateFrame("Cooldown", nil, self.Trinket)
				self.Trinket.cooldownFrame:SetAllPoints(self.Trinket)
				self.Trinket.Icon = self.Trinket:CreateTexture(nil, "BORDER")
				self.Trinket.Icon:SetAllPoints(self.Trinket)
				self.Trinket.Icon:SetTexCoord(0, 1, 0, 1)
				trinkets[self.unit] = self.Trinket
			end
		end
	 
		local Disable = function(self)
			if (self.Trinket) then
				trinkets[self.unit] = nil
			end
		end
	 
		oUF:AddElement('Trinket', Update, Enable, Disable)
	end
end