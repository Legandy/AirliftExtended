------------------------------------------------------------------------------
-- @file AirliftExtended_en_US.sql
-- @brief English localization for Airlift Extended.
-- @author Legandy
------------------------------------------------------------------------------

INSERT OR REPLACE INTO LocalizedText 
    (Language, Tag, Text) 
VALUES 
    ('en_US', 'LOC_LGY_AE_TITLE', 'Airlift Extended'),
    ('en_US', 'LOC_LGY_AE_DESCRIPTION', 'Lets Airstrips join the same Airlift network as Aerodrome+Airport.[NEWLINE][NEWLINE]Aerodrome/Airport is untouched -- vanilla Airlift behavior there is unchanged. An Airstrip becomes airlift-eligible once you''ve researched Rapid Deployment AND own at least one completed Airport somewhere in your empire.[NEWLINE][NEWLINE]Airlifting at or near an Airstrip costs 10 Oil (Settlers, Builders, and Great People are exempt). Insufficient Oil deals damage scaled to the shortfall instead -- 5 damage per point of Oil short, up to 50 at zero Oil.'),
    ('en_US', 'LOC_LGY_AE_TEASER', 'Lets Airstrips join the Aerodrome airlift network, with a fuel cost.'),
    ('en_US', 'LOC_LGY_AE_UNIT_LOST_TITLE', 'Unit Lost: Crash Landing'),
    ('en_US', 'LOC_LGY_AE_UNIT_LOST_SUMMARY', 'A unit was lost after airlifting without enough Oil to refuel.'),
    ('en_US', 'LOC_LGY_AE_INSUFFICIENT_OIL', 'Insufficient');