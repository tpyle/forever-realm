-- A hunter pet of a non-hunter (Hunter Stance): the client decides from the player's real class that the pet is not a
-- hunter pet (HasPetUI() returns true, false), so it hides the pet's happiness and loyalty: C_PetInfo.GetPetHappiness and
-- GetPetLoyalty return nothing. The stable values still reach the client, and the server keeps the summoned pet's happiness
-- in them current (Player::UpdateStablePetHappiness, every 12 s loyalty tick). This shows them on the two happiness faces
-- (pet frame, pet tab of the character window) and the pet tab's loyalty text.
--
-- Only those two frames are changed (their own methods), never HasPetUI or C_PetInfo: other code that checks for a hunter
-- pet keeps the client's answer. A real hunter's pet is left to the client.

local _, ns = ...

local DAMAGE = { 75, 100, 125 }     -- unhappy, content, happy (Pet::GetHappinessDamageMod)

local function IsClientHunterPet()
    local hasUI, isHunterPet = HasPetUI()
    return hasUI and isHunterPet
end

-- the summoned pet's stable entry: same creature and name among the active pets
local function CurrentPetInfo()
    if not UnitExists("pet") or IsClientHunterPet() or not C_StableInfo or not C_StableInfo.GetActivePetList then return nil end
    local okGuid, creatureID = pcall(function()
        local guid = UnitGUID("pet")
        return guid and tonumber((select(6, strsplit("-", guid))))
    end)
    if not okGuid then creatureID = nil end
    local name = UnitName("pet")
    local ok, pets = pcall(C_StableInfo.GetActivePetList)
    if not ok or not pets then return nil end
    for _, info in ipairs(pets) do
        if info.name == name and (not creatureID or info.creatureID == creatureID) then
            return info
        end
    end
    return nil
end

local function Stats()
    local info = CurrentPetInfo()
    local happiness = info and info.happinessLevel
    if not happiness or not DAMAGE[happiness] then return nil end
    local loyaltyRate = happiness == 1 and -1 or 1
    return happiness, DAMAGE[happiness], loyaltyRate
end

local patched = {}
local function Patch(frame)
    if not frame or patched[frame] then return end
    patched[frame] = true
    local blizzardStats, blizzardShouldShow = frame.GetHappinessStats, frame.ShouldShow
    frame.GetHappinessStats = function(self)
        if not self.stabledPetID and not IsClientHunterPet() then
            local happiness, damage, rate = Stats()
            if happiness then return happiness, damage, rate end
        end
        return blizzardStats(self)
    end
    frame.ShouldShow = function(self, happiness)
        if not self.stabledPetID and not IsClientHunterPet() then
            return happiness ~= nil and DAMAGE[happiness] ~= nil
        end
        return blizzardShouldShow(self, happiness)
    end
end

local function Update()
    for _, name in ipairs({ "PetFrameHappiness", "PetPaperDollPetHappinessInfo" }) do
        local frame = _G[name]
        if frame then
            Patch(frame)
            if frame.UpdateHappiness then pcall(frame.UpdateHappiness, frame) end
        end
    end
end

-- the pet tab's "Level 18 Wolf (Rebellious)"
local hookedLevel = false
local function HookLevel()
    if hookedLevel or not PaperDollFrame_SetPetLevel then return end
    hookedLevel = true
    hooksecurefunc("PaperDollFrame_SetPetLevel", function()
        if IsClientHunterPet() or not PetCharacterLevelText then return end
        local loyalty = C_PetInfo.GetPetLoyalty and C_PetInfo.GetPetLoyalty()
        if loyalty and loyalty ~= "" then return end
        local info = CurrentPetInfo()
        if info and info.loyaltyName and info.loyaltyName ~= "" then
            PetCharacterLevelText:SetText(PetCharacterLevelText:GetText() .. " "
                .. HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(PARENS_TEMPLATE:format(info.loyaltyName)))
        end
    end)
end

local ticker
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("ADDON_LOADED")
events:RegisterUnitEvent("UNIT_PET", "player")
events:SetScript("OnEvent", function()
    HookLevel()
    Update()
    -- the stable values change without an event the happiness faces listen to
    if not ticker then ticker = C_Timer.NewTicker(5, Update) end
end)
