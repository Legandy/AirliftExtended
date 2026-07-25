------------------------------------------------------------------------------
-- @file AirliftExtended_Gameplay.lua
-- @brief Manages gameplay logic for airlift fuel costs, damage, unit destruction,
--        Oil-cost/crash floating text, and the crash-landing notification.
-- @author Legandy
------------------------------------------------------------------------------

--- The amount of Oil charged for a single Airstrip-eligible airlift
--- @type integer
local OIL_COST_PER_AIRLIFT = 10;

--- The maximum crash-landing damage dealt when a unit airlifts with zero Oil available
--- Scales linearly with the Oil shortfall 
--- See ExtAirlift_OnUnitAirlifted
--- @type integer
local MAX_CRASH_DAMAGE = 50;

--- Unit types exempt from Airstrip airlift Oil costs:
--- @type table<string, boolean>
local EXEMPT_UNIT_TYPES = {
    -- Standard Civilians
    ["UNIT_SETTLER"] = true,
    ["UNIT_BUILDER"] = true,
    ["UNIT_ARCHAEOLOGIST"] = true,
    ["UNIT_NATURALIST"] = true,

    -- Peaceful Great People (Great General / Great Admiral excluded)
    ["UNIT_GREAT_PROPHET"] = true,
    ["UNIT_GREAT_SCIENTIST"] = true,
    ["UNIT_GREAT_ENGINEER"] = true,
    ["UNIT_GREAT_MERCHANT"] = true,
    ["UNIT_GREAT_WRITER"] = true,
    ["UNIT_GREAT_ARTIST"] = true,
    ["UNIT_GREAT_MUSICIAN"] = true,
};

print("AirliftExtended OIL: local human player is", tostring(Game.GetLocalPlayer()));

--- Checks the landing plot and its 6 neighbors for an Airstrip improvement
---
--- @param pUnit table The unit that is being airlifted.
--- @return boolean True if an Airstrip is located at or adjacent to the unit's plot, false otherwise.
function ExtAirlift_IsAirstripNearby(pUnit)
    local airstripInfo = GameInfo.Improvements["IMPROVEMENT_AIRSTRIP"];
    if airstripInfo == nil then
        return false;
    end

    local unitX = pUnit:GetX();
    local unitY = pUnit:GetY();

    local pPlot = Map.GetPlot(unitX, unitY);
    if pPlot ~= nil and pPlot:GetImprovementType() == airstripInfo.Index then
        return true;
    end

    for direction = 0, 5 do
        local pAdjacentPlot = Map.GetAdjacentPlot(unitX, unitY, direction);
        if pAdjacentPlot ~= nil and pAdjacentPlot:GetImprovementType() == airstripInfo.Index then
            return true;
        end
    end

    return false;
end

--- Determines if a unit is exempt from airlift Oil costs
--- Uses an explicit type list
---
--- @param pUnit table The unit to evaluate.
--- @return boolean True if the unit is a listed civilian type or peaceful Great Person.
function ExtAirlift_IsExemptUnit(pUnit)
    local unitTypeInfo = GameInfo.Units[pUnit:GetType()];
    if unitTypeInfo == nil then
        return false;
    end
    return EXEMPT_UNIT_TYPES[unitTypeInfo.UnitType] == true;
end

--- Event handler triggered when a unit completes an airlift.
---
--- Charges Oil for airlifts that land at/near an Airstrip (Aerodrome/Airport airlifts are untouched)
--- Also fires the mod's Oil-cost floating text, and, on insufficient Oil,
--- damages or destroys the unit and shows the crash notification. 
--- Three outcomes:
---   1. Oil >= OIL_COST_PER_AIRLIFT: full charge, no damage. Floating text: "-10[ICON_RESOURCE_OIL]".
---   2. 0 < Oil < OIL_COST_PER_AIRLIFT: partial charge, damage scaled to the shortfall.
---      Floating text: "-<oilConsumed>[ICON_RESOURCE_OIL]", followed by the vanilla damage floater.
---   3. Oil == 0: no charge, full damage. Floating text: "Insufficient[ICON_RESOURCE_OIL]",
---      followed by the vanilla damage floater.
--- In all damage cases, ChangeDamage() is always called (even when lethal) so the vanilla
--- damage floater still appears before the unit is explicitly destroyed for reliable cleanup.
---
--- @param playerID number The ID of the player owning the unit.
--- @param unitID number The ID of the airlifted unit.
--- @param ... any Additional event arguments passed by the game engine.
--- @return nil
function ExtAirlift_OnUnitAirlifted(playerID, unitID, ...)
    print("AirliftExtended OIL: UnitAirlifted fired", playerID, unitID, ...);

    local pPlayer = Players[playerID];
    if pPlayer == nil then
        return;
    end

    local pUnitsMgr = pPlayer:GetUnits();
    if pUnitsMgr == nil then
        return;
    end

    local pUnit = pUnitsMgr:FindID(unitID);
    if pUnit == nil then
        return;
    end

    if ExtAirlift_IsExemptUnit(pUnit) then
        print("AirliftExtended OIL: unit exempt (civilian / peaceful Great Person), no charge");
        return;
    end

    if not ExtAirlift_IsAirstripNearby(pUnit) then
        print("AirliftExtended OIL: landed at/near Aerodrome only, vanilla airlift, no charge");
        return;
    end

    local pResources = pPlayer:GetResources();
    if pResources == nil then
        return;
    end

    local oilInfo = GameInfo.Resources["RESOURCE_OIL"];
    if oilInfo == nil then
        return;
    end

    local currentOil = pResources:GetResourceAmount(oilInfo.Index);
    local unitX = pUnit:GetX();
    local unitY = pUnit:GetY();

    if currentOil >= OIL_COST_PER_AIRLIFT then
        pResources:ChangeResourceAmount(oilInfo.Index, -OIL_COST_PER_AIRLIFT);
        print("AirliftExtended OIL: charged", OIL_COST_PER_AIRLIFT, "Oil, remaining:", currentOil - OIL_COST_PER_AIRLIFT);

        -- Full charge, no damage: just the Oil cost.
        local floatingText = "[COLOR_Civ6Red]-" .. OIL_COST_PER_AIRLIFT .. "[ICON_RESOURCE_OIL][ENDCOLOR]";

        local bTextSuccess, textErr = pcall(function()
            Game.AddWorldViewText(EventSubTypes.DAMAGE, floatingText, unitX, unitY, 0);
        end);

        if not bTextSuccess then
            print("AirliftExtended OIL: floating text call failed:", tostring(textErr));
        end

        return;
    end

    -- Partial fuel: consume whatever Oil is available, then take damage scaled to the
    -- shortfall -- 5 damage per point short (MAX_CRASH_DAMAGE / OIL_COST_PER_AIRLIFT).
    local oilShortfall = OIL_COST_PER_AIRLIFT - currentOil;
    local scaledDamage = math.floor(oilShortfall * (MAX_CRASH_DAMAGE / OIL_COST_PER_AIRLIFT));
    local oilConsumed = currentOil;

    if oilConsumed > 0 then
        pResources:ChangeResourceAmount(oilInfo.Index, -oilConsumed);
    end

    -- Oil-related floating text only 
    -- the damage number itself is already shown automatically by the engine's own combat visualization when ChangeDamage() runs
    -- Fired BEFORE ChangeDamage() so this text appears first, with the vanilla damage floater following it.
    local floatingText;
    if oilConsumed > 0 then
        floatingText = "[COLOR_Civ6Red]-" .. oilConsumed .. "[ICON_RESOURCE_OIL][ENDCOLOR]";
    else
        floatingText = "[COLOR_Civ6Red]" .. Locale.Lookup("LOC_LGY_AE_INSUFFICIENT_OIL") .. "[ICON_RESOURCE_OIL][ENDCOLOR]";
    end

    local bTextSuccess, textErr = pcall(function()
        Game.AddWorldViewText(EventSubTypes.DAMAGE, floatingText, unitX, unitY, 0);
    end);

    if not bTextSuccess then
        print("AirliftExtended OIL: floating text call failed:", tostring(textErr));
    end

    -- Check lethality BEFORE applying anything 
    -- ChangeDamage alone doesn't reliably
    -- trigger full death cleanup. 100 is every unit's max HP, universal regardless of type/era.
    local wouldBeLethal = (pUnit:GetDamage() + scaledDamage) >= 100;

    -- Apply the damage regardless of lethality so the vanilla damage floater always shows.
    pUnit:ChangeDamage(scaledDamage);

    if wouldBeLethal then
        print("AirliftExtended OIL: had", currentOil, "Oil (short", oilShortfall, "), damage", scaledDamage, "lethal, destroying unit");
        pUnitsMgr:Destroy(pUnit);
    else
        print("AirliftExtended OIL: had", currentOil, "Oil (short", oilShortfall, "), dealt", scaledDamage, "damage");
    end

    if wouldBeLethal then
        local bNotifySuccess, notifyErr = pcall(function()
            local crashNotificationHash = DB.MakeHash("NOTIFICATION_LGY_AE_CRASH");
            NotificationManager.SendNotification(playerID, crashNotificationHash, Locale.Lookup("LOC_LGY_AE_UNIT_LOST_TITLE"), Locale.Lookup("LOC_LGY_AE_UNIT_LOST_SUMMARY"), unitX, unitY);
        end);
        if not bNotifySuccess then
            print("AirliftExtended OIL: notification call failed:", tostring(notifyErr));
        else
            print("AirliftExtended OIL: unit died from crash landing, notification sent");
        end
    end
end

Events.UnitAirlifted.Add(ExtAirlift_OnUnitAirlifted);