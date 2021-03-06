local _, ns = ...
local oUF = ns.oUF or oUF

assert(oUF, "oUF_MovableFrames was unable to locate oUF install.")

-- The DB is organized as the following:
-- {
--    Lily = {
--       player = "CENTER\031UIParent\0310\031-621",
-- }
--}
local _DB
local _LOCK

local _BACKDROP = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background";
}

local print = function(...)
	return print('|cff33ff99oUF_MovableFrames:|r', ...)
end
local round = function(n)
	return math.floor(n * 1e5 + .5) / 1e5
end

local backdropPool = {}

getPoint = function(obj, anchor)
	if(not anchor) then
		local UIx, UIy = UIParent:GetCenter()
		local Ox, Oy = obj:GetCenter()

		-- Frame doesn't really have a positon yet.
		if(not Ox) then return end

		local UIS = UIParent:GetEffectiveScale()
		local OS = obj:GetEffectiveScale()

		local UIWidth, UIHeight = UIParent:GetRight(), UIParent:GetTop()

		local LEFT = UIWidth / 3
		local RIGHT = UIWidth * 2 / 3

		local point, x, y
		if(Ox >= RIGHT) then
			point = 'RIGHT'
			x = obj:GetRight() - UIWidth
		elseif(Ox <= LEFT) then
			point = 'LEFT'
			x = obj:GetLeft()
		else
			x = Ox - UIx
		end

		local BOTTOM = UIHeight / 3
		local TOP = UIHeight * 2 / 3

		if(Oy >= TOP) then
			point = 'TOP' .. (point or '')
			y = obj:GetTop() - UIHeight
		elseif(Oy <= BOTTOM) then
			point = 'BOTTOM' .. (point or '')
			y = obj:GetBottom()
		else
			if(not point) then point = 'CENTER' end
			y = Oy - UIy
		end

		return string.format(
			'%s\031%s\031%d\031%d',
			point, 'UIParent', round(x * UIS / OS),  round(y * UIS / OS)
		)
	else
		local point, parent, _, x, y = anchor:GetPoint()

		return string.format(
			'%s\031%s\031%d\031%d',
			point, 'UIParent', round(x), round(y)
		)
	end
end

local getObjectInformation  = function(obj)
	-- This won't be set if we're dealing with oUF <1.3.22. Due to this we're just
	-- setting it to Unknown. It will only break if the user has multiple layouts
	-- spawning the same unit or change between layouts.
	local style = obj.style or 'Unknown'
	local identifier = obj:GetName() or obj.unit

	-- Are we dealing with header units?
	local isHeader
	local parent = obj:GetParent()
	-- Check for both as we can hit parents with initialConfigFunction, and
	-- SetManyAttributes alone is kinda up to the authors.
	if(parent and parent.initialConfigFunction and parent.SetManyAttributes) then
		isHeader = true

		-- These always have a name, so we might as well abuse it.
		identifier = parent:GetName()
	end

	return style, identifier, isHeader
end

local function restorePosition(obj)
	local style, identifier, isHeader = getObjectInformation(obj)
	-- We've not saved any custom position for this style.
	if(not _DB[style] or not _DB[style][identifier]) then return end

	local scale = obj:GetScale()
	local parent = (isHeader and obj:GetParent())
	local SetPoint = getmetatable(parent or obj).__index.SetPoint;

	-- Hah, a spot you have to use semi-colon!
	-- Guess I've never experienced that as these are usually wrapped in do end
	-- statements.
	(parent or obj).SetPoint = restorePosition;
	(parent or obj):ClearAllPoints();

	-- damn it Blizzard, _how_ did you manage to get the input of this function
	-- reversed. Any sane person would implement this as: split(str, dlm, lim);
	local point, parentName, x, y = string.split('\031', _DB[style][identifier])
	SetPoint(parent or obj, point, parentName, point, x / scale, y / scale)
end

local savePosition = function(obj, anchor)
	local style, identifier, isHeader = getObjectInformation(obj)
	if(not _DB[style]) then _DB[style] = {} end

	if(isHeader) then
		_DB[style][identifier] = getPoint(obj:GetParent(), anchor)
	else
		_DB[style][identifier] = getPoint(obj, anchor)
	end
end

-- Attempt to figure out a more sane name to dispaly.
local smartName = function(obj, header)
	if(type(obj) == 'string') then
		-- Probably what we're after.
		if(obj:match('_')) then
			local name = obj:lower()
			local group, id, subType = name:match('_([%a%d_]+)unitbutton(%d+)(%w+)$')
			if(subType) then
				return group .. id .. subType
			end

			-- odds of this being used is _slim_
			local group, id = name:match('_([%a%d_]+)unitbutton(%d+)$')
			if(id) then
				return group .. id
			end

			local group = name:match('_([%a%d_]+)')
			if(group) then
				return group
			end
		else
			return obj
		end
	else
		if(header) then
			-- XXX: Check the attributes for a valid description.
			local name = header:GetName()
			local group = name:lower():match('_([%a%d_]+)')
			if(group) then
				return group:gsub('frames?', '')
			else
				return name
			end

			return header:GetName()
		else
			local match = (obj.hasChildren and '_([%a_]+)unitbutton(%d+)$') or '_([%a_]+)unitbutton(%d+)(%w+)$'
			local name = obj:GetName()
			if(name) then
				local group, id, subType = name:lower():match(match)
				if(subType) then
					return group .. id .. subType
				elseif(id) then
					return group .. id
				end
			end

			return obj.unit or '<unknown>'
		end
	end
end

do
	local frame = CreateFrame"Frame"
	frame:SetScript("OnEvent", function(self)
		return self[event](self)
	end)

	function frame:VARIABLES_LOADED()
		-- I honestly don't trust the load order of SVs.
		_DB = bb08df87101dd7f2161e5b77cf750f753c58ef1b or {}
		bb08df87101dd7f2161e5b77cf750f753c58ef1b = _DB
		-- Got to catch them all!
		for _, obj in next, oUF.objects do
			restorePosition(obj)
		end

		oUF:RegisterInitCallback(restorePosition)
		self:UnregisterEvent"VARIABLES_LOADED"
		self.VARIABLES_LOADED = nil
	end
	frame:RegisterEvent"VARIABLES_LOADED"

	function frame:PLAYER_REGEN_DISABLED()
		if(_LOCK) then
			print("Anchors hidden due to combat.")
			for k, bdrop in next, backdropPool do
				bdrop:Hide()
			end
			_LOCK = nil
		end
	end
	frame:RegisterEvent"PLAYER_REGEN_DISABLED"
end

local getBackdrop
do
	local OnShow = function(self)
		return self.name:SetText(smartName(self.obj, self.header))
	end

	local OnDragStart = function(self)
		self:StartMoving()

		local frame = self.header or self.obj
		frame:ClearAllPoints();
		frame:SetAllPoints(self);
	end

	local OnDragStop = function(self)
		self:StopMovingOrSizing()
		savePosition(self.obj, self)
	end

	getBackdrop = function(obj, isHeader)
		local header = (isHeader and obj:GetParent())
		if(not (header or obj):GetCenter()) then return end
		if(backdropPool[header or obj]) then return backdropPool[header or obj] end

		local backdrop = CreateFrame"Frame"
		backdrop:SetParent(UIParent)
		backdrop:Hide()

		backdrop:SetBackdrop(_BACKDROP)
		backdrop:SetFrameStrata"TOOLTIP"
		backdrop:SetAllPoints(header or obj)

		backdrop:EnableMouse(true)
		backdrop:SetMovable(true)
		backdrop:RegisterForDrag"LeftButton"

		backdrop:SetScript("OnShow", OnShow)

		local name = backdrop:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		name:SetPoint"CENTER"
		name:SetJustifyH"CENTER"
		name:SetFont(GameFontNormal:GetFont(), 12)
		name:SetTextColor(1, 1, 1)

		backdrop.name = name
		backdrop.obj = obj
		backdrop.header = header

		backdrop:SetBackdropBorderColor(0, .9, 0)
		backdrop:SetBackdropColor(0, .9, 0)

		-- Work around the fact that headers with no units displayed are 0 in height.
		if(header and math.floor(header:GetHeight()) == 0) then
			local height = header:GetChildren():GetHeight()
			header:SetHeight(height)
		end

		backdrop:SetScript("OnDragStart", OnDragStart)
		backdrop:SetScript("OnDragStop", OnDragStop)

		backdropPool[header or obj] = backdrop

		return backdrop
	end
end

do
	local opt = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
	opt:Hide()

	opt.name = "oUF: MovableFrames"
	opt:SetScript("OnShow", function(self)
		local title = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		title:SetPoint('TOPLEFT', 16, -16)
		title:SetText'oUF: MovableFrames'

		local subtitle = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		subtitle:SetHeight(40)
		subtitle:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
		subtitle:SetPoint('RIGHT', self, -32, 0)
		subtitle:SetNonSpaceWrap(true)
		subtitle:SetWordWrap(true)
		subtitle:SetJustifyH'LEFT'
		subtitle:SetText('Note that the initial frame position set by layouts are currently'
		.. ' not saved. This means that a reload of the UI is required to correctly reset'
		.. ' the position after deleting an element.')

		local scroll = CreateFrame("ScrollFrame", nil, self)
		scroll:SetPoint('TOPLEFT', subtitle, 'BOTTOMLEFT', 0, -8)
		scroll:SetPoint("BOTTOMRIGHT", 0, 4)

		local scrollchild = CreateFrame("Frame", nil, self)
		scrollchild:SetPoint"LEFT"
		scrollchild:SetHeight(scroll:GetHeight())
		scrollchild:SetWidth(scroll:GetWidth())

		scroll:SetScrollChild(scrollchild)
		scroll:UpdateScrollChildRect()
		scroll:EnableMouseWheel(true)

		local slider = CreateFrame("Slider", nil, scroll)

		local backdrop = {
			bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		}

		local createOrUpdateMadnessOfGodIhateGUIs
		local OnClick = function(self)
			scroll.value = slider:GetValue()
			_DB[self.style][self.ident] = nil

			if(not next(_DB[self.style])) then
				_DB[self.style] = nil
			end

			return createOrUpdateMadnessOfGodIhateGUIs()
		end

		local OnEnter = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(DELETE)
		end

		function createOrUpdateMadnessOfGodIhateGUIs()
			local data = self.data or {}

			local slideHeight = 0
			local numStyles = 1
			for style, styleData in next, _DB do
				if(not data[numStyles]) then
					local box = CreateFrame('Frame', nil, scrollchild)
					box:SetBackdrop(backdrop)
					box:SetBackdropColor(.1, .1, .1, .5)
					box:SetBackdropBorderColor(.3, .3, .3, 1)

					if(numStyles == 1) then
						box:SetPoint('TOP', 0, -12)
					else
						box:SetPoint('TOP', data[numStyles - 1], 'BOTTOM', 0, -16)
					end
					box:SetPoint'LEFT'
					box:SetPoint('RIGHT', -30, 0)

					local title = box:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
					title:SetPoint('BOTTOMLEFT', box, 'TOPLEFT', 8, 0)
					box.title = title

					data[numStyles] = box
				end

				-- Fetch the box and update it
				local box = data[numStyles]
				box.title:SetText(style)

				local rows = box.rows or {}
				local numFrames = 1
				for unit, points in next, styleData do
					if(not rows[numFrames]) then
						local row = CreateFrame('Button', nil, box)

						row:SetBackdrop(backdrop)
						row:SetBackdropBorderColor(.3, .3, .3)
						row:SetBackdropColor(.1, .1, .1, .5)

						if(numFrames == 1) then
							row:SetPoint('TOP', 0, -8)
						else
							row:SetPoint('TOP', rows[numFrames-1], 'BOTTOM')
						end

						row:SetPoint('LEFT', 6, 0)
						row:SetPoint('RIGHT', -25, 0)
						row:SetHeight(24)

						local anchor = row:CreateFontString(nil, nil, 'GameFontHighlight')
						anchor:SetPoint('RIGHT', -10, 0)
						anchor:SetPoint('TOP', 0, -4)
						anchor:SetPoint'BOTTOM'
						anchor:SetJustifyH'RIGHT'
						row.anchor = anchor

						local label = row:CreateFontString(nil, nil, 'GameFontHighlight')
						label:SetPoint('LEFT', 10, 0)
						label:SetPoint('RIGHT', anchor)
						label:SetPoint('TOP', 0, -4)
						label:SetPoint'BOTTOM'
						label:SetJustifyH'LEFT'
						row.label = label

						local delete = CreateFrame("Button", nil, row)
						delete:SetWidth(16)
						delete:SetHeight(16)
						delete:SetPoint('LEFT', row, 'RIGHT')

						delete:SetNormalTexture[[Interface\Buttons\UI-Panel-MinimizeButton-Up]]
						delete:SetPushedTexture[[Interface\Buttons\UI-Panel-MinimizeButton-Down]]
						delete:SetHighlightTexture[[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]]

						delete:SetScript("OnClick", OnClick)
						delete:SetScript("OnEnter", OnEnter)
						delete:SetScript("OnLeave", GameTooltip_Hide)
						row.delete = delete

						rows[numFrames] = row
					end

					-- Fetch row and update it:
					local row = rows[numFrames]
					local point, _, x, y = string.split('\031', points)
					row.anchor:SetFormattedText('%11s %4s %4s', point, x, y)
					row.label:SetText(smartName(unit))

					row.delete.style = style
					row.delete.ident = unit
					row:Show()

					numFrames = numFrames + 1
				end

				box.rows = rows

				local height = (numFrames * 24) - 8
				slideHeight = slideHeight + height + 16
				box:SetHeight(height)
				box:Show()

				-- Hide left over rows we aren't using:
				while(rows[numFrames]) do
					rows[numFrames]:Hide()
					numFrames = numFrames + 1
				end

				numStyles = numStyles + 1
			end

			-- Hide left over boxes we aren't using:
			while(data[numStyles]) do
				data[numStyles]:Hide()
				numStyles = numStyles + 1
			end

			self.data = data
			local height = slideHeight - scroll:GetHeight()
			if(height > 0) then
				slider:SetMinMaxValues(0, height)
			else
				slider:SetMinMaxValues(0, 0)
			end

			slider:SetValue(scroll.value or 0)
		end

		slider:SetWidth(16)

		slider:SetPoint("TOPRIGHT", -8, -24)
		slider:SetPoint("BOTTOMRIGHT", -8, 24)

		local up = CreateFrame("Button", nil, slider)
		up:SetPoint("BOTTOM", slider, "TOP")
		up:SetWidth(16)
		up:SetHeight(16)
		up:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
		up:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
		up:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
		up:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")

		up:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		up:GetPushedTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		up:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		up:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		up:GetHighlightTexture():SetBlendMode("ADD")

		up:SetScript("OnClick", function(self)
			local box = self:GetParent()
			box:SetValue(box:GetValue() - box:GetHeight()/2)
		end)

		local down = CreateFrame("Button", nil, slider)
		down:SetPoint("TOP", slider, "BOTTOM")
		down:SetWidth(16)
		down:SetHeight(16)
		down:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
		down:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
		down:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
		down:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")

		down:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		down:GetPushedTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		down:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		down:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		down:GetHighlightTexture():SetBlendMode("ADD")

		down:SetScript("OnClick", function(self)
			local box = self:GetParent()
			box:SetValue(box:GetValue() + box:GetHeight()/2)
		end)

		slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		local thumb = slider:GetThumbTexture()
		thumb:SetWidth(16)
		thumb:SetHeight(24)
		thumb:SetTexCoord(1/4, 3/4, 1/8, 7/8)

		slider:SetScript("OnValueChanged", function(self, val, ...)
			local min, max = self:GetMinMaxValues()
			if(val == min) then up:Disable() else up:Enable() end
			if(val == max) then down:Disable() else down:Enable() end

			scroll.value = val
			scroll:SetVerticalScroll(val)
			scrollchild:SetPoint('TOP', 0, val)
		end)

		opt:SetScript("OnShow", function()
			return createOrUpdateMadnessOfGodIhateGUIs()
		end)

		return createOrUpdateMadnessOfGodIhateGUIs()
	end)

	InterfaceOptions_AddCategory(opt)
end

SLASH_OUF_MOVABLEFRAMES1 = '/omf'
SlashCmdList['OUF_MOVABLEFRAMES'] = function(inp)
	if(InCombatLockdown()) then
		return print"Frames cannot be moved while in combat. Bailing out."
	end

	if(inp:match("%S+")) then
		InterfaceOptionsFrame_OpenToCategory'oUF: MovableFrames'
	else
		if(not _LOCK) then
			for k, obj in next, oUF.objects do
				local style, identifier, isHeader = getObjectInformation(obj)
				local backdrop = getBackdrop(obj, isHeader)
				if(backdrop) then backdrop:Show() end
			end

			_LOCK = true
		else
			for k, bdrop in next, backdropPool do
				bdrop:Hide()
			end

			_LOCK = nil
		end
	end
end
-- It's not in your best interest to disconnect me. Someone could get hurt.
