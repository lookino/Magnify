local _G = getfenv(0)

local function StartDriftFixer()
  local driftFixer = CreateFrame("Frame")
  local initialized = false

  driftFixer:SetScript("OnUpdate", function()
    if not WorldMapFrame:IsShown() then return end

    -- One-time setup for ShaguTweaks coordinates
    if not initialized and IsAddOnLoaded("ShaguTweaks") and WorldMapButton and WorldMapButton.coords and WorldMapButton.player then
      initialized = true

      WorldMapButton.coords:SetParent(WorldMapFrame)
      WorldMapButton.coords:ClearAllPoints()
      WorldMapButton.coords:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 10, 10)
      WorldMapButton.coords:SetFrameStrata("FULLSCREEN_DIALOG")
      WorldMapButton.coords:SetScale(1)
      WorldMapButton.coords.text:Show()
      WorldMapButton.coords:Show()

      WorldMapButton.player:SetParent(WorldMapFrame)
      WorldMapButton.player:ClearAllPoints()
      WorldMapButton.player:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", -10, 10)
      WorldMapButton.player:SetFrameStrata("FULLSCREEN_DIALOG")
      WorldMapButton.player:SetScale(1)
      WorldMapButton.player.text:Show()
      WorldMapButton.player:Show()
    end

    -- Continuous repositioning to prevent zoom drift
    if IsAddOnLoaded("ShaguTweaks") and WorldMapButton and WorldMapButton.coords and WorldMapButton.player then
      WorldMapButton.coords:ClearAllPoints()
      WorldMapButton.coords:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 10, 10)

      WorldMapButton.player:ClearAllPoints()
      WorldMapButton.player:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", -10, 10)
    end

    -- LevelRange tooltip
    if IsAddOnLoaded("LevelRange-Turtle") and LevelRangeTooltip then
      LevelRangeTooltip:ClearAllPoints()
      LevelRangeTooltip:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 10, 50)
      LevelRangeTooltip:SetFrameStrata("TOOLTIP")
    end
  end)

  -- Override LevelRange tooltip positioning directly
  if IsAddOnLoaded("LevelRange-Turtle") and LevelRangeTooltip and not LevelRangeTooltip._magnifyOverride then
    LevelRangeTooltip._magnifyOverride = true

    local originalSetPoint = LevelRangeTooltip.SetPoint
    LevelRangeTooltip.SetPoint = function(self, anchor, parent, relAnchor, x, y)
      originalSetPoint(self, "BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 10, 50)
      self:SetFrameStrata("TOOLTIP")
    end
  end
end

local function HandleAddons()
	-- Cartographer
	if IsAddOnLoaded('Cartographer') then
		local goToButton = _G['CartographerGoToButton']
		if goToButton then
			CartographerGoToButton:ClearAllPoints()
			CartographerGoToButton:SetPoint('TOPLEFT', WorldMapPositioningGuide, 12, -35)
		end

		local optionsButton = _G['CartographerOptionsButton']
		if optionsButton then
			CartographerOptionsButton:ClearAllPoints()
			CartographerOptionsButton:SetPoint('TOPRIGHT', WorldMapPositioningGuide, -12, -35)
		end

		local holder = _G['CartographerLookNFeelOverlayHolder']
		if holder then
			WorldMapButton:SetParent(holder)
		end
	end

 -- ShaguTweaks scroll frame layout
  if IsAddOnLoaded('ShaguTweaks') and WorldMapFrameScrollFrame then
    local offsetY = -48
    if ShaguTweaks_config and ShaguTweaks_config["WorldMap Window"] == 1 then
      offsetY = WORLDMAP_WINDOWED == 1 and -24 or -48
    end
    WorldMapFrameScrollFrame:SetPoint('TOP', WorldMapFrame, 0, offsetY)
  end
	
	
	-- pfQuest
	if IsAddOnLoaded('pfQuest') then
		local dropdown = _G['pfQuestMapDropdown']
		if dropdown then
			dropdown:ClearAllPoints()
			dropdown:SetParent(WorldMapFrame)
			dropdown:SetFrameStrata('FULLSCREEN_DIALOG')

			if WORLDMAP_WINDOWED and WORLDMAP_WINDOWED == 1 then
				dropdown:SetPoint('TOPRIGHT', 'WorldMapPositioningGuide', 0, -36)
			else
				dropdown:SetPoint('TOPRIGHT', 'WorldMapPositioningGuide', 0, -80)
			end
		end
	end

	if IsAddOnLoaded('pfUI') then
		if pfUI.map then
			WorldMapFrameScrollFrame:SetPoint('TOP', WorldMapFrame, 0, -48)
		end
	end
end

local handler = CreateFrame('Frame')
handler:RegisterEvent('PLAYER_ENTERING_WORLD')
handler:SetScript('OnEvent', HandleAddons)

local WorldMapFrame_OldMinimize = WorldMapFrame_Minimize
function WorldMapFrame_Minimize()
	WorldMapFrame_OldMinimize()

	if WorldMapFrameScrollFrame then
		MAGNIFY_MIN_ZOOM = 0.7

		WorldMapFrameScrollFrame:SetWidth(702)
		WorldMapFrameScrollFrame:SetHeight(468)
		WorldMapFrameScrollFrame:SetPoint('TOP', WorldMapFrame, 2, -24)
		WorldMapFrameScrollFrame:SetScrollChild(WorldMapDetailFrame)

		WorldMapButton:SetScale(1)

		WorldMapFrameAreaFrame:ClearAllPoints()
		WorldMapFrameAreaFrame:SetPoint('TOP', WorldMapFrame, 0, -15)

		Magnify_ResetZoom()
	end

	HandleAddons()
end

local WorldMapFrame_OldMaximize = WorldMapFrame_Maximize
function WorldMapFrame_Maximize()
	WorldMapFrame_OldMaximize()

	if WorldMapFrameScrollFrame then
		MAGNIFY_MIN_ZOOM = 1

		WorldMapFrameScrollFrame:SetWidth(1002)
		WorldMapFrameScrollFrame:SetHeight(668)
		WorldMapFrameScrollFrame:SetPoint('TOP', WorldMapFrame, 0, -70)
		WorldMapFrameScrollFrame:SetScrollChild(WorldMapDetailFrame)

		WorldMapFrameAreaFrame:ClearAllPoints()
		WorldMapFrameAreaFrame:SetPoint('TOP', WorldMapFrame, 0, -60)

		Magnify_ResetZoom()
	end

	HandleAddons()
end

-- Start drift fixer once
StartDriftFixer()
