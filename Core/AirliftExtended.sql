------------------------------------------------------------------------------
-- @file AirliftExtended.sql
-- @brief Database modifications for properties and notifications.
-- @author Legandy
------------------------------------------------------------------------------


-- Adds an independent source of the "PROPERTY_AIRLIFT" flag for Airstrips.
-- Requirements for Airlift network expansion:
-- Rapid Deployment civic researched.
-- Player owns at least one completed Airport anywhere in their empire.
-- AI civs are equally eligible once they qualify.


INSERT INTO Types (Type, Kind) VALUES
('MODIFIER_EXTAIRLIFT_ADJUST_PROPERTY', 'KIND_MODIFIER');

INSERT INTO DynamicModifiers (ModifierType, EffectType, CollectionType) VALUES
('MODIFIER_EXTAIRLIFT_ADJUST_PROPERTY', 'EFFECT_ADJUST_IMPROVEMENT_PROPERTY', 'COLLECTION_PLAYER_IMPROVEMENTS');

INSERT INTO Modifiers (ModifierId, ModifierType, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_EXTAIRLIFT_AIRSTRIP', 'MODIFIER_EXTAIRLIFT_ADJUST_PROPERTY', 'REQSET_EXTAIRLIFT_OWNER', 'REQSET_EXTAIRLIFT_PLOT_IS_AIRSTRIP');

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_EXTAIRLIFT_AIRSTRIP', 'Key', 'PROPERTY_AIRLIFT'),
('MODIFIER_EXTAIRLIFT_AIRSTRIP', 'Amount', 1);

INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_AIRPORT', 'MODIFIER_EXTAIRLIFT_AIRSTRIP');

INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('REQSET_EXTAIRLIFT_OWNER', 'REQUIREMENTSET_TEST_ALL');

INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('REQSET_EXTAIRLIFT_OWNER', 'REQ_EXTAIRLIFT_HAS_RAPID_DEPLOYMENT');

INSERT INTO Requirements (RequirementId, RequirementType) VALUES
('REQ_EXTAIRLIFT_HAS_RAPID_DEPLOYMENT', 'REQUIREMENT_PLAYER_HAS_CIVIC');

INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES
('REQ_EXTAIRLIFT_HAS_RAPID_DEPLOYMENT', 'CivicType', 'CIVIC_RAPID_DEPLOYMENT');

INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('REQSET_EXTAIRLIFT_PLOT_IS_AIRSTRIP', 'REQUIREMENTSET_TEST_ALL');

INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('REQSET_EXTAIRLIFT_PLOT_IS_AIRSTRIP', 'REQ_EXTAIRLIFT_PLOT_IS_AIRSTRIP');

INSERT INTO Requirements (RequirementId, RequirementType) VALUES
('REQ_EXTAIRLIFT_PLOT_IS_AIRSTRIP', 'REQUIREMENT_PLOT_IMPROVEMENT_TYPE_MATCHES');

INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES
('REQ_EXTAIRLIFT_PLOT_IS_AIRSTRIP', 'ImprovementType', 'IMPROVEMENT_AIRSTRIP');

-- Custom Notification for Crash Landing

INSERT INTO Types (Type, Kind) VALUES
('NOTIFICATION_LGY_AE_CRASH', 'KIND_NOTIFICATION');

INSERT INTO Notifications (NotificationType, SeverityType, Icon, VisibleInUI, ShowIconSinglePlayer) VALUES
('NOTIFICATION_LGY_AE_CRASH', 'MID', 'ICON_NOTIFICATION_LGY_AE_CRASH', 1, 1);