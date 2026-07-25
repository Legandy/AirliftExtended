------------------------------------------------------------------------------
-- @file AirliftExtended_de_DE.sql
-- @brief German localization for Airlift Extended.
-- @author Legandy
------------------------------------------------------------------------------

INSERT OR REPLACE INTO LocalizedText 
    (Language, Tag, Text) 
VALUES 
    ('de_DE', 'LOC_LGY_AE_TITLE', 'Lufttransport Erweitert'),
    ('de_DE', 'LOC_LGY_AE_DESCRIPTION', 'Lässt Landepisten demselben Lufttransport-Netzwerk beitreten wie Flugplatz+Flughafen.[NEWLINE][NEWLINE]Flugplatz/Flughafen bleiben unberührt -- das normale Verhalten bleibt unverändert. Eine Landepiste wird für den Lufttransport nutzbar, sobald Sie ''Schnelle Eingreiftruppe'' erforscht haben UND mindestens einen fertigen Flughafen irgendwo in Ihrem Reich besitzen.[NEWLINE][NEWLINE]Der Lufttransport an oder nahe einer Landepiste kostet 10 Öl (Siedler, Handwerker und Große Persönlichkeiten sind ausgenommen). Unzureichendes Öl verursacht stattdessen Schaden, der entsprechend der Fehlmenge skaliert wird – 5 Schaden pro fehlendem Ölpunkt, bis zu 50 bei null Öl.'),
    ('de_DE', 'LOC_LGY_AE_TEASER', 'Lässt Landepisten dem Flugplatz-Lufttransportnetzwerk beitreten, mit Treibstoffkosten.'),
    ('de_DE', 'LOC_LGY_AE_UNIT_LOST_TITLE', 'Einheit verloren: Bruchlandung'),
    ('de_DE', 'LOC_LGY_AE_UNIT_LOST_SUMMARY', 'Eine Einheit ist beim Lufttransport ohne ausreichendes Öl zum Auftanken verloren gegangen.'),
    ('de_DE', 'LOC_LGY_AE_INSUFFICIENT_OIL', 'Unzureichend');