-- Class trainers added for Classic 1.60 that have no trainer_class, so the core's class check (Creature::CanTrainPlayerClass)
-- could not tell their class: set it from their title. trainer_class also lets them reset talents for their class.
-- Apply to the `world` database; restart worldserver. Entries: 173819,244808,246152,246344,246389,248415,251507,252359,252373,252377,252379,252382,252389,254081,254082,254084,254086,254087,254088,257446,258113,262558,262560,270459
UPDATE creature_template SET trainer_class = CASE subname
    WHEN 'Warrior Trainer' THEN 1  WHEN 'Paladin Trainer' THEN 2  WHEN 'Hunter Trainer' THEN 3
    WHEN 'Rogue Trainer'   THEN 4  WHEN 'Priest Trainer'  THEN 5  WHEN 'Shaman Trainer' THEN 7
    WHEN 'Mage Trainer'    THEN 8  WHEN 'Warlock Trainer' THEN 9  WHEN 'Druid Trainer'  THEN 11 END
WHERE entry IN (173819,244808,246152,246344,246389,248415,251507,252359,252373,252377,252379,252382,252389,254081,254082,254084,254086,254087,254088,257446,258113,262558,262560,270459);
