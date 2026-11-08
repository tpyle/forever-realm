-- Where to find the Deathknell shaman and druid trainers from 041, for the quests in 042 (their text said only
-- "in Deathknell"). The hunter's stays as it is, like the warrior's Simple Scroll in the same building.
-- Apply to the `world` database; restart worldserver.
UPDATE quest_template SET
    LogDescription = 'Speak to Mordecai Vale by the graveyard in Deathknell.',
    QuestDescription = 'Mordecai Vale claims the elements still answer him, $N, though he no longer draws breath. He has asked for you. Find him by the graveyard before you go about any other business here.'
    WHERE ID = 9100309;
UPDATE quest_template SET
    LogDescription = 'Speak to Agatha Fenwick outside the church in Deathknell.',
    QuestDescription = 'Agatha Fenwick has been asking after you, $N. She speaks of the wild as though it had never turned its back on us. Find her outside the church before you go about any other business here.'
    WHERE ID = 9100310;
