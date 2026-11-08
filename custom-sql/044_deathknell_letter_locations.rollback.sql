-- Apply to the `world` database; restart worldserver. Restores the texts from 042.
UPDATE quest_template SET LogDescription = 'Speak to Mordecai Vale in Deathknell.',
    QuestDescription = 'Mordecai Vale claims the elements still answer him, $N, though he no longer draws breath. He has asked for you. Find him in Deathknell before you go about any other business here.'
    WHERE ID = 9100309;
UPDATE quest_template SET LogDescription = 'Speak to Agatha Fenwick in Deathknell.',
    QuestDescription = 'Agatha Fenwick has been asking after you, $N. She speaks of the wild as though it had never turned its back on us. Find her in Deathknell before you go about any other business here.'
    WHERE ID = 9100310;
