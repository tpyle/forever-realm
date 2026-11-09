#!/usr/bin/env python3
"""Generates server/etc/*.conf from the stock *.conf.dist plus the settings below.

The database password comes from .db_pass (gitignored), so the generated files never
need to be committed. Run it after changing SETTINGS or after a new build installs
new .conf.dist files, then restart the server it changed.

    tools/apply_config.py           write server/etc/*.conf
    tools/apply_config.py --check   only report whether they are up to date
"""
import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ETC = ROOT / "server" / "etc"
DB = '"127.0.0.1;3306;trinity;{password};{database}"'

SETTINGS = {
    "worldserver.conf": {
        "LoginDatabaseInfo": DB.replace("{database}", "auth"),
        "WorldDatabaseInfo": DB.replace("{database}", "world"),
        "CharacterDatabaseInfo": DB.replace("{database}", "characters"),
        "HotfixDatabaseInfo": DB.replace("{database}", "hotfixes"),
        "DataDir": '"/opt/wow/forever/server/data"',
        "LogsDir": '"/opt/wow/forever/server/logs"',
        # Realm 70 is "Trinity" in auth.realmlist. Port 8125 leaves 8085 to the WotLK server.
        "RealmID": "70",
        "WorldServerPort": "8125",
        "Realm.CfgContentSetID": "137",
        "Realm.SuperDistrictID": "2",
        # The realm is on 70862; also let 70790 clients in. Must match bnetserver.conf, or
        # character creation hangs on the finish button (the client's realm query gets nothing).
        "Realm.AlsoAcceptBuilds": '"70790"',
        # No auth key is known for 70862 (see sql/custom/auth/2026_11_07_00_auth_classic_70862.sql).
        "Network.SkipBuildAuthKeyCheck": "1",
        "Network.EnterEncryptedModeRegionGroup": "8",
        # Every primary profession (the tutor NPC teaches past the client's limit of two).
        "MaxPrimaryTradeSkill": "11",
        # Learns playercreateinfo_spell_custom at creation, e.g. Holy Light for new paladin races.
        "PlayerStart.AllSpells": "1",
        "PlayerSave.Stats.MinLevel": "1",
        "AccountInstancesPerHour": "5",
        "Classic.GuildFinder": "1",
        "Classic.Shop.Enabled": "1",
        # DBErrors.log only: the console line floods the journal at startup.
        "Logger.sql.sql": "5,DBErrors",
        # World scaling (core WorldScale.h, custom-sql 055): a creature below the player fights, shows and rewards as the
        # player's level. As the WotLK realm's mod-worldscale: scale up only, dungeons and raids too, elites yes, bosses
        # no, aggro as if 5 levels below. Kill experience: half way from what the creature pays a player of its own level
        # to what an equal level creature pays the player (level 1 creature, level 5 player: 50 -> 70, pays 60).
        # Applies to creatures as they spawn.
        "WorldScale.Enable": "1",
        "WorldScale.Dungeons": "1",
        "WorldScale.Raids": "1",
        "WorldScale.AffectElites": "1",
        "WorldScale.AffectWorldBosses": "0",
        "WorldScale.MinMultiplier": "0.05",
        "WorldScale.MaxMultiplier": "20.0",
        "WorldScale.KillXPFraction": "0.5",
        "WorldScale.Aggro.LevelsBelow": "5",
        # Quests (custom-sql 057): the client shows a quest at the player's level (never below its own); one below the player
        # pays half way from its experience at its own level to a quest of the player's level (level 4 quest, level 6 player).
        "WorldScale.Quests": "1",
        "WorldScale.QuestXPFraction": "0.5",
        # Kill experience in a group: each member earns what they would alone (the WotLK realm's setting), not a share
        # of the group's. Nothing still for a creature that is gray to them.
        "WorldScale.GroupXPSplit": "0",
    },
    "bnetserver.conf": {
        "LoginDatabaseInfo": DB.replace("{database}", "auth"),
        "LogsDir": '"/opt/wow/forever/server/logs"',
        # Let's Encrypt certificate, copied in by tools/letsencrypt/forever-bnet.sh.
        "CertificatesFile": '"./wow.cert.pem"',
        "PrivateKeyFile": '"./wow.key.pem"',
        "LoginREST.ExternalAddress": "wow.thomaspyle.com",
        "LoginREST.LocalAddress": "wow.thomaspyle.com",
        "Realm.CfgContentSetID": "137",
        "Realm.SuperDistrictID": "2",
        "Realm.AlsoAcceptBuilds": '"70790"',
    },
}

SETTING_LINE = re.compile(r"^([A-Za-z][\w.]*)\s*=")


def render(dist_text, settings, password):
    """Returns dist_text with each setting replaced, or appended when the .dist lacks it."""
    values = {key: value.replace("{password}", password) for key, value in settings.items()}
    pending = dict(values)
    lines = []
    for line in dist_text.splitlines():
        match = SETTING_LINE.match(line)
        if match and match.group(1) in values:
            key = match.group(1)
            if key not in pending:
                sys.exit(f"{key} appears twice in the .dist file")
            line = f"{key} = {pending.pop(key)}"
        lines.append(line)

    if pending:
        lines += ["", "# Settings the stock .conf.dist does not have, added by tools/apply_config.py"]
        lines += [f"{key} = {value}" for key, value in pending.items()]
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--check", action="store_true", help="report differences without writing")
    args = parser.parse_args()

    password = (ROOT / ".db_pass").read_text().strip()
    stale = False
    for name, settings in SETTINGS.items():
        target = ETC / name
        text = render((ETC / f"{name}.dist").read_text(), settings, password)
        if target.exists() and target.read_text() == text:
            print(f"{name}: up to date")
            continue

        stale = True
        if args.check:
            print(f"{name}: differs")
        else:
            target.write_text(text)
            target.chmod(0o600)
            print(f"{name}: written (restart its server to apply)")

    return 1 if args.check and stale else 0


if __name__ == "__main__":
    sys.exit(main())
