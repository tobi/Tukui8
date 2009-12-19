if select(2, UnitClass("Player")) == "PRIEST" then
	
	if if_warning == true then
		local InnerFire = CreateFrame("Frame", _, UIParent)
			InnerFire:SetPoint("CENTER", UIParent, "CENTER", 0,200);
			InnerFire:SetFrameStrata("LOW");
			InnerFire:SetWidth(40);
			InnerFire:SetHeight(40);
			InnerFire:SetBackdrop({
			bgFile = BLANK_TEXTURE,
			edgeFile = BLANK_TEXTURE,
			tile = true,
			tileSize = 16,
			edgeSize = 1,
			insets = {top=1, right=1, bottom=1, left=1},
		  });
			InnerFire:SetBackdropColor(0.1,0.1,0.1,0)
			InnerFire:SetBackdropBorderColor(0.6,0.6,0.6,1)

			InnerFire.icon = InnerFire:CreateTexture(nil,"BACKGROUND")
			InnerFire.icon:SetTexture("Interface\\AddOns\\Tukui\\media\\innerfire")
			InnerFire.icon:SetPoint("center",InnerFire,"center",0,0)
			InnerFire.icon:SetWidth(40);
			InnerFire.icon:SetHeight(40);
			

		local function InnerFireCheck(self, event, unit, spell)
				inCombat = UnitAffectingCombat("player")
				if UnitLevel("player") >= 70 then
					if not UnitBuff("player", ifbuff) and inCombat then
						self:Show()
						PlaySound("RaidWarning")
					else
						self:Hide()
					end
				else
					self:Hide()
				end
		end

		InnerFire:SetScript("OnEvent", InnerFireCheck)
		InnerFire:RegisterEvent("UNIT_AURA")
		InnerFire:RegisterEvent("PLAYER_ENTERING_WORLD")
		InnerFire:RegisterEvent("PLAYER_REGEN_ENABLED")
		InnerFire:RegisterEvent("PLAYER_REGEN_DISABLED")
	end
end