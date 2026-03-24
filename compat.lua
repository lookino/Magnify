local _G = getfenv(0)

-- Dynamically update coordinate position based on map mode
local function UpdateCoordinatePosition()
  local yOffset = WORLDMAP_WINDOWED == 1 and -20 or -24

  local myCoords = _G["MagnifyCoordsFrame"]
  local myPlayer = _G["MagnifyPlayerFrame"]

  if myCoords then
    myCoords:ClearAllPoints()
    myCoords:SetPoint("BOTTOMLEFT", WorldMapFrameScrollFrame, "BOTTOMLEFT", 10, yOffset)
  end

  if myPlayer then
    myPlayer:ClearAllPoints()
    myPlayer:SetPoint("BOTTOMRIGHT", WorldMapFrameScrollFrame, "BOTTOMRIGHT", -10, yOffset)
  end
end

-- Custom coordinate replacement
local function ReplaceCoordinates()
  if not WorldMapFrame or not WorldMapDetailFrame then return end

  -- Disable ShaguTweaks coordinate logic if present
  if WorldMapButton.coords then
    WorldMapButton.coords:SetScript("OnUpdate", nil)
    WorldMapButton.coords:Hide()
  end
  if WorldMapButton.player then
    WorldMapButton.player:SetScript("OnUpdate", nil)
    WorldMapButton.player:Hide()
  end

  -- Reuse or create coordinate frames
  local myCoords = _G["MagnifyCoordsFrame"] or CreateFrame("Frame", "MagnifyCoordsFrame", WorldMapFrame)
  local myPlayer = _G["MagnifyPlayerFrame"] or CreateFrame("Frame", "MagnifyPlayerFrame", WorldMapFrame)

  -- Set size and strata only once
  if not myCoords.text then
    myCoords:SetWidth(120)
    myCoords:SetHeight(20)
    myCoords:SetFrameStrata("FULLSCREEN_DIALOG")
    myCoords.text = myCoords:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    myCoords.text:SetTextColor(1, 0.82, 0)  -- gold
    myCoords.text:SetAllPoints()
    myCoords.text:SetJustifyH("LEFT")
    myCoords:Show()
  end

  if not myPlayer.text then
    myPlayer:SetWidth(120)
    myPlayer:SetHeight(20)
    myPlayer:SetFrameStrata("FULLSCREEN_DIALOG")
    myPlayer.text = myPlayer:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    myPlayer.text:SetTextColor(1, 0.82, 0)  -- gold
    myPlayer.text:SetAllPoints()
    myPlayer.text:SetJustifyH("RIGHT")
    myPlayer:Show()
  end

  UpdateCoordinatePosition()

  -- Update coordinates every frame
  local updater = CreateFrame("Frame")
  updater:SetScript("OnUpdate", function()
    if not WorldMapFrame:IsShown() then return end

    -- Cursor coordinates
    local x, y = GetCursorPosition()
    local scale = WorldMapDetailFrame:GetEffectiveScale()
    x = x / scale
    y = y / scale

    local left = WorldMapDetailFrame:GetLeft()
    local top = WorldMapDetailFrame:GetTop()
    local width = WorldMapDetailFrame:GetWidth()
    local height = WorldMapDetailFrame:GetHeight()

    if left and top and width and height then
      local cx = (x - left) / width
      local cy = (top - y) / height
      if cx >= 0 and cy >= 0 and cx <= 1 and cy <= 1 then
        myCoords.text:SetText(string.format("Cursor: %.1f / %.1f", cx * 100, cy * 100))
      else
        myCoords.text:SetText("Cursor: N/A")
      end
    end

    -- Player coordinates
    local px, py = GetPlayerMapPosition("player")
    if px and py and px > 0 and py > 0 then
      myPlayer.text:SetText(string.format("Player: %.1f / %.1f", px * 100, py * 100))
    else
      myPlayer.text:SetText("Player: N/A")
    end
  end)
end

-- Run it after login
local coordInit = CreateFrame("Frame")
coordInit:RegisterEvent("PLAYER_ENTERING_WORLD")
coordInit:SetScript("OnEvent", function()
  ReplaceCoordinates()
end)

-- LevelRange tooltip fix
local function FixLevelRangeTooltip()
  if IsAddOnLoaded("LevelRange-Turtle") and LevelRangeTooltip then
    LevelRangeTooltip:ClearAllPoints()
    LevelRangeTooltip:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 10, 50)
    LevelRangeTooltip:SetFrameStrata("TOOLTIP")

    if not LevelRangeTooltip._magnifyOverride then
      LevelRangeTooltip._magnifyOverride = true
      local originalSetPoint = LevelRangeTooltip.SetPoint
      LevelRangeTooltip.SetPoint = function(self, anchor, parent, relAnchor, x, y)
        originalSetPoint(self, "BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 10, 50)
        self:SetFrameStrata("TOOLTIP")
      end
    end
  end
end

-- Main addon layout handler
local function HandleAddons()
  -- Cartographer
  if IsAddOnLoaded('Cartographer') then
    local goToButton = _G['CartographerGoToButton']
    if goToButton then
      goToButton:ClearAllPoints()
      goToButton:SetPoint('TOPLEFT', WorldMapPositioningGuide, 12, -35)
    end

    local optionsButton = _G['CartographerOptionsButton']
    if optionsButton then
      optionsButton:ClearAllPoints()
      optionsButton:SetPoint('TOPRIGHT', WorldMapPositioningGuide, -12, -35)
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

  -- pfUI
  if IsAddOnLoaded('pfUI') and pfUI.map then
    WorldMapFrameScrollFrame:SetPoint('TOP', WorldMapFrame, 0, -48)
  end

  -- ShaguTweaks-extras map reveal checkbox fix
  local mapReveal = _G["shagutweaks_mapreveal_onmap"]
  if mapReveal then
    mapReveal:SetParent(WorldMapFrame)
    mapReveal:SetFrameStrata('FULLSCREEN_DIALOG')
    mapReveal:ClearAllPoints()
    mapReveal:SetPoint('TOPLEFT', WorldMapFrameScrollFrame, 'TOPLEFT', 1, 19)
  end

  -- Hide ShaguTweaks coordinates (Magnify provides its own)
  if WorldMapButton.coords then
    WorldMapButton.coords:SetScript("OnUpdate", nil)
    WorldMapButton.coords:Hide()
  end
  if WorldMapButton.player then
    WorldMapButton.player:SetScript("OnUpdate", nil)
    WorldMapButton.player:Hide()
  end

  -- Apply coordinate and tooltip fixes
  ReplaceCoordinates()
  FixLevelRangeTooltip()
end

-- Run layout handler on login
local handler = CreateFrame('Frame')
handler:RegisterEvent('PLAYER_ENTERING_WORLD')
handler:SetScript('OnEvent', HandleAddons)

-- Magnify hooks
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
    WorldMapFrameAreaFrame:SetParent(WorldMapFrame)
    WorldMapFrameAreaFrame:ClearAllPoints()
    WorldMapFrameAreaFrame:SetPoint('TOP', WorldMapFrame, 0, -15)
    WorldMapFrameAreaFrame:SetFrameStrata('FULLSCREEN_DIALOG')
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
    WorldMapFrameAreaFrame:SetParent(WorldMapFrame)
    WorldMapFrameAreaFrame:ClearAllPoints()
    WorldMapFrameAreaFrame:SetPoint('TOP', WorldMapFrame, 0, -60)
    WorldMapFrameAreaFrame:SetFrameStrata('FULLSCREEN_DIALOG')
    Magnify_ResetZoom()
  end
  HandleAddons()
end
