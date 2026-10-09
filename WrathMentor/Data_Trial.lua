-- Vault of Archavon, Trial of the Crusader, Onyxia's Lair
local WM = WrathMentor

WM:AddRaid("voa", "Vault of Archavon", { "Vault of Archavon" }, {
    {
        name = "Archavon the Stone Watcher",
        tldr = "Spread out for Rock Shards, step out of the Choking Cloud trail after Crushing Leap, and have the off-tank ready to pick him up when Stomp throws the main tank. Enrage after 5 minutes.",
        start = {
            "Main tank pulls Archavon and faces him away from the raid. An off-tank stands ready close by.",
            "Raid spreads out before the pull.",
        },
        general = {
            "Rock Shards: he throws shards at a player - stay spread out so nobody else is hit.",
            "Crushing Leap: he leaps to a random player and leaves a Choking Cloud trail. Move out of the trail.",
            "Stomp: he picks up the main tank, removes ALL threat, damages them for 8 seconds, then throws them across the room. The off-tank must pick him up immediately.",
            "Rock Shards every 15 seconds, Crushing Leap/Choking Cloud every 30 seconds, Stomp every 45 seconds. Berserk after 5 minutes wipes the raid, so this is a DPS check.",
        },
        tank = {
            "Main tank: face Archavon away from the raid. Stomp (every 45 seconds) picks you up, damages you for 8 seconds, wipes all threat and throws you - get back fast and re-taunt once he's on the off-tank.",
            "Off-tank: stay close and taunt him the moment Stomp starts so he doesn't run into the raid.",
        },
        heal = {
            "Keep the main tank alive through the 8-second Stomp damage (Impale) - spot heal + cooldown if needed.",
            "Rock Shards (every 15 seconds) hit the target and anyone near them - heal the spread raid.",
            "Move out of Choking Cloud yourself; it reduces hit chance and damages.",
        },
        dps = {
            "Stay spread (Rock Shards) and step out of Choking Cloud after each Crushing Leap.",
            "Hold DPS for a second after Stomp until the off-tank has him.",
            "Berserk at 5 minutes - use cooldowns early.",
        },
        abilities = {
            { id = 58678, name = "Rock Shards", desc = "Shards thrown at a player that hit those close to them. Stay spread." },
            { id = 60894, name = "Crushing Leap", desc = "He leaps to a random player; it leaves a trail behind." },
            { kind = "debuff", id = 58965, name = "Choking Cloud", desc = "The poison trail left by Crushing Leap. Move out." },
            { id = 60880, name = "Stomp", desc = "Picks up the main tank, removes all threat, damages then throws them. Off-tank takes over." },
        },
    },
    {
        name = "Emalon the Storm Watcher",
        aliases = { "Tempest Minion" },
        tldr = "Melee run out for Lightning Nova, everyone spread for Chain Lightning, and about every 40 seconds ALL DPS switch to the Tempest Minion that got Overcharge and kill it before 10 stacks (it explodes for raid-wipe damage).",
        start = {
            "Emalon starts with 4 Tempest Minions. The OFF-TANK pulls first and grabs the minions and Emalon, moving to one side of the room.",
            "The main tank then takes Emalon from the off-tank and drags him to the opposite side - keep Emalon and the minions AWAY from each other because of Lightning Nova.",
            "Do not start DPS until both tanks have their targets.",
        },
        general = {
            "Overcharge about every 40 seconds: a random Tempest Minion is healed to full and gets a stacking buff (bigger and +20% damage). It gains another stack every 2 seconds. At 10 stacks it explodes (Overcharged Blast) for massive nature damage to the raid and usually wipes it. ALL DPS must swap to that Minion and kill it before it reaches 10 stacks.",
            "Lightning Nova is a long cast that hurts more the closer you are: melee run away from Emalon as soon as it starts; the off-tank stays far from the boss with the minions.",
            "Chain Lightning: stay spread out. A Nature Resistance Totem helps with Chain Lightning and Lightning Nova.",
            "When the minion dies Emalon summons a new one; the off-tank grabs it. There is a 6-minute enrage.",
        },
        tank = {
            "Off-tank: hold all Tempest Minions together, far from Emalon (Lightning Nova range), and pick up each new minion as it spawns.",
            "Main tank: keep Emalon on the opposite side, facing away. Step away a bit during Lightning Nova if you can without losing him.",
        },
        heal = {
            "Chain Lightning hits clumped players - stay spread.",
            "Lightning Nova (every 40 seconds) does less damage the further you are - melee run out, healers stay at range.",
            "When the Overcharged minion is dying near 10 stacks, be ready for raid damage if it isn't killed in time.",
        },
        dps = {
            "Overcharge (about every 40 seconds): a minion heals to full and stacks a buff every 2 seconds - EVERYONE switches and kills it before 10 stacks.",
            "Otherwise DPS Emalon. Melee run out when Lightning Nova starts casting.",
            "Berserk at 6 minutes.",
        },
        abilities = {
            { kind = "buff", id = 64218, name = "Overcharge", desc = "A random Tempest Minion is healed and stacks a buff every 2 seconds. Kill it before 10 stacks." },
            { ids = { 65279, 64216 }, name = "Lightning Nova", desc = "A long cast; more damage the closer you are to Emalon. Run away." },
            { ids = { 64213, 64215 }, name = "Chain Lightning", desc = "Lightning that jumps between players. Stay spread." },
        },
    },
    {
        name = "Koralon the Flame Watcher",
        tldr = "Two tanks stay stacked together to split Meteor Fists, healers watch Burning Breath raid damage, everyone moves out of Flaming Cinder fire, and burn him because Burning Fury grows every 20 seconds.",
        start = {
            "Tank Koralon away from fire patches and turn him away from the raid so melee can engage.",
            "Have an off-tank stand right next to the main tank for Meteor Fists. Bring a Fire Resistance Aura (Paladin) or Totem (Shaman) - all his damage is fire.",
        },
        general = {
            "Burning Fury: every 20 seconds he gains a stacking damage buff (a soft enrage). Kill him quickly.",
            "Meteor Fists hits the tank and splits damage with other targets: keep the off-tank next to the main tank (or alternate raid cooldowns on the main tank if solo tanking).",
            "Burning Breath: raid-wide damage - healers watch for it.",
            "Flaming Cinder: flame patches on the ground - move out of them.",
        },
        tank = {
            "Two tanks stand on top of each other in front of Koralon so Meteor Fists (every 45 seconds) is split between you.",
            "Face him away from the raid (Burning Breath) and move him out of Flaming Cinder patches.",
        },
        heal = {
            "Burning Breath (every 45 seconds) and Burning Fury stacks mean raid damage goes up over time - pace mana but expect a hard finish.",
            "Fire Resistance Aura/Totem helps.",
            "Heal tanks through Meteor Fists.",
        },
        dps = {
            "Move out of Flaming Cinder (every 30 seconds).",
            "Burning Fury makes him stronger all fight - use cooldowns early and keep damage high.",
            "Never stand in front of him.",
        },
        abilities = {
            { ids = { 66725, 68161 }, name = "Meteor Fists", desc = "Hits the tank in front of him and splits damage with others near the target." },
            { ids = { 66665, 68160 }, name = "Burning Breath", desc = "Raid-wide fire damage. Heal through it." },
            { ids = { 66684, 67332, 66681 }, name = "Flaming Cinder", desc = "Fire patches on the ground. Move out." },
            { kind = "buff", id = 66721, name = "Burning Fury", desc = "A stacking damage buff every 20 seconds (soft enrage)." },
        },
    },
    {
        name = "Toravon the Ice Watcher",
        tldr = "Kill the Frozen Orbs, heal everyone up before Whiteout (about every 40 seconds), taunt-swap on Frostbite stacks, and stay out of Freezing Ground.",
        start = {
            "Two tanks so they can taunt off each other. Healers spread out among the raid.",
        },
        general = {
            "Frozen Orbs appear (#{1/3} every 30 seconds) and pulse frost damage: kill them.",
            "Whiteout about every 40 seconds increases the Frost damage everyone takes for the rest of the fight. Healers make sure everyone is healthy before it is cast.",
            "Tanks taunt off each other to deal with stacks of Frostbite.",
            "Freezing Ground is cast throughout the fight: stay out of it.",
        },
        tank = {
            "Two tanks taunt-swap on Frostbite stacks (it slows attacks and deals frost damage).",
            "Keep him out of Freezing Ground patches and away from Frozen Orbs' targets.",
        },
        heal = {
            "Whiteout (25 seconds in, then every 40 seconds) hits everyone and adds a stacking frost-damage-taken debuff - top everyone before each one; it gets harder every time.",
            "Frozen Orbs (#{1/3} every 30 seconds) pulse frost damage until killed.",
        },
        dps = {
            "Kill Frozen Orbs as soon as they spawn, then back to Toravon.",
            "Stay out of Freezing Ground.",
            "Whiteout stacks make the fight a soft DPS race.",
        },
        abilities = {
            { id = 72034, name = "Whiteout", desc = "Big frost damage that also raises the frost damage you take. Heal up beforehand." },
            { id = 72090, name = "Freezing Ground", desc = "Frozen ground effects. Don't stand in them." },
        },
    },
}, "AzerothCore boss scripts (timers), Icy Veins and wowtbc.gg guides")

WM:AddRaid("toc", "Trial of the Crusader", { "Trial of the Crusader" }, {
    {
        name = "Northrend Beasts",
        aliases = { "Gormok the Impaler", "Acidmaw", "Dreadscale", "Icehowl" },
        tldr = "Three beasts in a row: Gormok (casters stay 15 yards away, kill Snobolds), the worms Acidmaw and Dreadscale (opposite debuffs cancel each other), then Icehowl (dodge the charge).",
        start = {
            "Gormok comes first, then the two worms together, then Icehowl. Assign tanks: two on Gormok (Impale swap), one per worm, then two on Icehowl.",
            "Everyone knows which worm is mobile: DREADSCALE starts MOBILE, ACIDMAW starts STATIONARY. They swap after burrowing.",
        },
        general = {
            "## Gormok the Impaler",
            "Casters stay at least 15 yards from him to avoid Staggering Stomp. Tanks taunt off each other for Impale.",
            "Snobold Vassals jump onto a random player about every 20 seconds and attack them - kill the Snobold fast. Avoid the Fire Bombs they throw.",
            "## Acidmaw and Dreadscale",
            "One worm is mobile, the other stationary; they switch after burrowing. The mobile worm only applies its debuff to its tank - tanks must kite the mobile one. The stationary worm puts its debuff on a random group of players.",
            "Their debuffs cancel each other: if you get Paralytic Toxin from Acidmaw, run to the tank of Dreadscale (they have Burning Bile) to remove it. If Dreadscale is mobile and you're hit by Burning Bile, run to the tank on Acidmaw to remove the Paralytic Toxin.",
            "Stay spread but not too far from Dreadscale, so the Paralytic Toxin doesn't freeze you. Kill Acidmaw first and don't stand in front of the worms.",
            "## Icehowl",
            "Melee stand at max melee range to avoid Whirl. Spread for Arctic Breath. Healers watch tank spikes from Ferocious Butt and top everyone off after Arctic Breath so nobody dies to Massive Crash. If Icehowl charges you, get out of the way.",
        },
        tank = {
            "Gormok: two tanks swap at 2-3 Impale stacks (bleed). Keep him facing away; casters stay 15 yards away for Staggering Stomp.",
            "Worms: one tank per worm. The mobile worm's tank kites it; when they burrow and swap (stationary/mobile), tanks adjust. Tanks also cleanse each other's debuffs by standing together when needed.",
            "Icehowl: tank him at the edge; he Ferocious Butts (big stun hit) and periodically charges a player across the room after Massive Crash.",
        },
        heal = {
            "Gormok: heal Impale bleeds and Fire Bomb victims; free Snobold targets by getting the Snobold killed.",
            "Worms: Paralytic Toxin (Acidmaw) slows then paralyzes; Burning Bile (Dreadscale) is fire damage. Players with opposite debuffs touch each other to remove both.",
            "Icehowl: Arctic Breath and Whirl damage; after Massive Crash everyone is dazed - top the charge target.",
        },
        dps = {
            "Gormok: kill Snobold Vassals on players (they jump on someone every ~20 seconds), then Gormok. Move out of Fire Bombs.",
            "Worms: kill both close together (they enrage when one dies); stay spread so Slime Pools and spray only hit one target.",
            "Icehowl: when he charges a player after Massive Crash, everyone gets out of his path. Melee at max range for Whirl.",
            "Heroic: each beast has a timer - the next one arrives even if the current one isn't dead.",
        },
        abilities = {
            { id = 67648, name = "Staggering Stomp", desc = "Gormok's stomp: interrupts casters within 15 yards for 8 seconds." },
            { id = 67477, name = "Impale", desc = "Bleeding stacking strike on Gormok's tank. Swap." },
            { kind = "debuff", id = 66823, name = "Paralytic Toxin", desc = "Acidmaw's paralysing debuff. Cancelled by Burning Bile." },
            { kind = "debuff", id = 66869, name = "Burning Bile", desc = "Dreadscale's fire debuff. Cancelled by Paralytic Toxin." },
            { id = 66770, name = "Ferocious Butt", desc = "Icehowl's tank hit." },
            { id = 67345, name = "Whirl", desc = "Icehowl's melee whirl. Melee stay at max range." },
            { id = 66689, name = "Arctic Breath", desc = "Icehowl's frost breath damage. Spread." },
            { id = 66683, name = "Massive Crash", desc = "Icehowl's crash after a charge. Be healthy." },
        },
        hard = {
            "Heroic mode: each phase is on a TIMER. The next beast can spawn before the previous one dies - keep DPS high.",
            "A Paladin can use Hand of Protection to remove the Impale debuff during the phase 2 transition.",
            "Gormok's Snobold Vassals and Fire Bombs are more dangerous on heroic - kill Snobolds quickly and avoid the bombs.",
        },
    },
    {
        name = "Lord Jaraxxus",
        tldr = "Tank him in the middle and spread around him. Interrupt Fel Fireball, dispel Nether Power, heal Incinerate Flesh and run to the edge with Legion Flame. On heroic kill Nether Portals and Infernal Eruptions at once.",
        start = {
            "Tank Jaraxxus in the center of the room. Everyone spreads out around him before the pull (Fel Lightning).",
            "Assign an interrupter for Fel Fireball, dispellers (Mages can Spellsteal) for Nether Power, and healers to focus the Incinerate Flesh target.",
        },
        general = {
            "Spread out to help with Fel Lightning. Interrupt Fel Fireball. Dispel Nether Power (Mages: Spellsteal).",
            "Incinerate Flesh is a healing-absorb shield on a random player, not direct damage - spam heal through it to clear it before it expires, or it triggers Burning Inferno (raid-wide fire damage) when it runs out.",
            "If you are targeted by Legion Flame, run toward the edge of the room.",
            "Fire Resistance Aura (Paladin) helps with raid damage.",
        },
        tank = {
            "Tank Jaraxxus in the center facing away; he hits hard and gains Nether Power stacks (spell power) if not dispelled.",
            "Off-tank: pick up the Mistress of Pain and Felflame Infernals from portals/volcanoes (every minute).",
        },
        heal = {
            "Incinerate Flesh: a random player gets a large heal-absorb - heal it off before it expires or it explodes for raid-wide Burning Inferno.",
            "Legion Flame targets must run to the edge; heal them. Fel Lightning chains between nearby players - stay spread.",
            "Mistress of Pain's Spinning Pain Spike and Infernals' Fel Inferno add burst damage.",
        },
        dps = {
            "Interrupt Fel Fireball every time; Mages Spellsteal (or purge) Nether Power stacks.",
            "Kill the Mistress of Pain and Infernals when they spawn (heroic: kill the Nether Portal and Infernal Volcano themselves).",
            "Legion Flame on you: run to the edge so the fire trail stays away from the raid.",
        },
        abilities = {
            { id = 66532, name = "Fel Fireball", desc = "A big fire cast. Interrupt it." },
            { id = 66528, name = "Fel Lightning", desc = "Lightning that hurts players standing near each other. Stay spread." },
            { kind = "debuff", id = 66237, name = "Incinerate Flesh", desc = "Absorbs the next chunk of healing on a random player and halves their damage done. If it isn't healed away before it expires, it explodes into Burning Inferno - raid-wide fire damage." },
            { kind = "debuff", id = 66197, name = "Legion Flame", desc = "Fire on a player that burns the ground. Run to the edge." },
            { kind = "buff", id = 66228, name = "Nether Power", desc = "Jaraxxus' buff. Dispel or Spellsteal it." },
        },
        hard = {
            "On normal mode, Nether Portal is just a visual warning that a single Mistress of Pain is about to spawn - kill her quickly when she appears. Infernal Eruption separately summons a Volcano that spawns Infernals that charge and AoE - CC or kill them.",
            "On heroic, both the Nether Portal and the Infernal Eruption's Volcano become attackable and keep spawning adds (a Mistress of Pain and Infernals respectively) until destroyed - kill the portal/volcano itself as fast as possible instead of only the adds it drops.",
            "The Mistress of Pain gains Mistress's Kiss: if you get it, cast a spell from a non-primary school to trigger it.",
            "Jaraxxus also gains Touch of Jaraxxus: another reason to stay spread out.",
        },
    },
    {
        name = "Faction Champions",
        tldr = "A PvP-style fight against NPC champions: use crowd control everywhere, kill the healers first (Restoration Shaman, Discipline Priest), then the Rogue, then the melee. Start with a Warrior AoE fear to pop their trinkets.",
        start = {
            "If you can, start with an AoE fear from a Warrior to make the NPCs waste their trinkets.",
            "Everyone should use every crowd-control ability they have, especially early when things are hectic.",
        },
        general = {
            "The NPCs reset their aggro table throughout the fight: if you are not a tank, be ready to kite and use defensive cooldowns.",
            "Recommended kill order: Restoration Shaman, Discipline Priest, then the Rogue.",
            "After those three are dead, focus the melee NPCs and crowd control the rest.",
            "Healers watch players targeted by the Rogue.",
        },
        tank = {
            "Pick up the melee champions; they reset threat often, so taunt and use AoE threat constantly.",
            "Peel for healers: stuns, Hand of Protection, taunts on whoever is chasing them.",
        },
        heal = {
            "Damage comes in PvP-style bursts on random players; keep instant heals and cooldowns ready.",
            "Dispel crowd control on your raid (fears, polymorphs) and the enemy healers' buffs if you can purge.",
            "Watch the players the Rogue and Warrior jump on.",
        },
        dps = {
            "Kill order: Restoration Shaman > Discipline Priest > Rogue (or your raid's order); crowd-control the others the whole time.",
            "Interrupt enemy healers and use stuns/silences on them.",
            "Purge/Spellsteal their buffs and break their shields. Champions have diminishing returns on CC like players.",
        },
        abilities = {},
        hard = {
            "Heroic mode: same plan as normal; champions hit harder and last longer, so coordinated crowd control matters even more. Stay disciplined on kill order: Restoration Shaman, Discipline Priest, Rogue.",
        },
    },
    {
        name = "Twin Val'kyr",
        aliases = { "Fjola Lightbane", "Eydis Darkbane" },
        tldr = "Fjola (light) and Eydis (dark) share one health pool. Half the raid attunes to light, half to dark; soak orbs of YOUR colour only; swap colours for the matching vortex and opposite for the shields.",
        start = {
            "Split the raid into two halves: half attune to the LIGHT buff and half to the DARK buff at the start. The light half damages Eydis Darkbane; the dark half damages Fjola Lightbane.",
            "Everyone soaks the Concentrated Essence orbs that roam the room that match your attunement and avoids the other colour.",
        },
        general = {
            "Soaking enough orbs gives Empowered Light or Empowered Darkness (depending on the colour).",
            "Light Vortex / Dark Vortex: swap colours to match the boss casting it, then swap back when the cast ends.",
            "Shield of Lights / Shield of Darkness: swap to the OPPOSITE colour of the boss and break the shield so you can interrupt Twin's Pact, then switch back.",
            "When one boss casts its shield, the other gains Power of the Twins - that tank needs focus healing.",
            "Doorway strategy: assign 2-3 soakers to handle the orbs and stack the rest of the raid at the entrance.",
            "Fire Resistance Aura and Shadow Resistance Aura help mitigate raid damage.",
        },
        tank = {
            "One tank on each Val'kyr; keep them near each other so damage dealers can swap targets.",
            "During Shield of Lights/Darkness the OTHER twin gains Power of the Twins (hits much harder) - use a cooldown if you're on that one.",
        },
        heal = {
            "Pick your essence like everyone else and soak only your color's orbs.",
            "During each Vortex, make sure you have the matching essence; heal those who didn't.",
            "Heroic: Touch of Light/Darkness DoTs - change to the matching essence to cancel them.",
        },
        dps = {
            "Light essence: attack Eydis (dark). Dark essence: attack Fjola (light).",
            "Shield phase: switch to the essence OPPOSITE the shielded twin, break the shield fast, and interrupt Twin's Pact.",
            "Vortex: switch to the SAME color as the vortex before it ends.",
            "Berserk at 10 minutes on normal, 6 minutes on heroic.",
        },
        abilities = {
            { ids = { 65875, 65876 }, name = "Twin's Pact", desc = "A big heal/buff cast by a Val'kyr. Interrupt it after breaking the shield." },
            { id = 66046, name = "Light Vortex", desc = "Fjola's vortex. Swap to light to avoid it." },
            { id = 66058, name = "Dark Vortex", desc = "Eydis' vortex. Swap to dark to avoid it." },
            { kind = "buff", id = 65858, name = "Shield of Lights", desc = "Fjola's shield. Swap colours opposite of her to break it." },
            { kind = "buff", id = 65874, name = "Shield of Darkness", desc = "Eydis' shield. Swap colours opposite of her to break it." },
            { kind = "debuff", id = 65950, name = "Touch of Light", desc = "Heroic: a light effect on a player." },
            { kind = "debuff", id = 66001, name = "Touch of Darkness", desc = "Heroic: a dark effect on a player." },
        },
        hard = {
            "Heroic mode: each Val'kyr gains an ability - Touch of Darkness (Eydis) and Touch of Light (Fjola). As long as your dark and light players are kept separated from each other, this is not a threat.",
            "When targeted by a Touch, switch your essence colour to the opposite temporarily to neutralise it, then switch back (it hurts nearby allies like Searing Light on XT-002).",
            "Assign a mobile healer (a Druid works well) as the ball collector to gather the dangerous concentrated essences for their side.",
            "Berserk at 6 minutes on heroic (10 minutes on normal). If the Val'kyr keep getting powered up they will kill everyone.",
        },
    },
    {
        name = "Anub'arak",
        tldr = "P1: kill Frost Spheres to make Permafrost, tank Burrowers on Permafrost. P2 (burrowed): kill Scarabs and kite Pursuing Spikes onto Permafrost. P3 at 30%: Leeching Swarm - keep everyone under 50% health and use Bloodlust.",
        start = {
            "Off-tanks pick up the Nerubian Burrowers (#{1/2} every 45 seconds; heroic #{2/4}) and tank them on Permafrost near Anub'arak so they can be cleaved.",
            "Assign one DPS to kill the floating Frost Spheres so Permafrost appears on the ground.",
        },
        general = {
            "## Phase 1",
            "Frost Spheres: kill them to spawn Permafrost. On heroic you're limited to 6 Frost Spheres, on normal they respawn.",
            "Heal players with Penetrating Cold and watch tank spike damage from Freezing Slash.",
            "Tank Burrowers on top of Permafrost so they can't use Submerge. Burrowers apply Expose Weakness (heroic: also Shadow Strike - interrupt it).",
            "## Phase 2 (starts when Anub'arak burrows)",
            "Kill the Scarabs; they pursue random targets and randomly enrage (faster attacks, immune to slows and stuns).",
            "If Anub'arak Pursues you, kite the Pursuing Spikes as long as possible and then stand on Permafrost. When he reaches you he casts Impale, but it fails if he's beneath a Permafrost patch (which it consumes).",
            "## Phase 3 (below 30% health)",
            "Anub'arak uses Leeching Swarm the whole time - it leeches the target's current health every second, so healers must keep players alive WITHOUT over-healing: keep everyone under 50% health. Save Bloodlust for this phase.",
            "On heroic he keeps spawning Burrowers.",
        },
        tank = {
            "Main tank: Freezing Slash (frost hit + 3-second freeze) - keep cooldowns rolling.",
            "Off-tank: pick up the Nerubian Burrowers (#{1/2} every 45 seconds; heroic #{2/4}) and hold them ON Permafrost so they can't burrow (Submerge) and heal.",
            "Phase 3: in heroic Burrowers keep coming - keep collecting them.",
        },
        heal = {
            "Penetrating Cold on #{2/5} players: frost damage over time - heal through it.",
            "Phase 2 (submerged, 1 minute): heal the Pursuing Spikes target and Scarab bites.",
            "Phase 3 (30%): Leeching Swarm drains a % of CURRENT health - keep everyone below about 50% so the boss heals less, but never let anyone drop too low. Big HoTs/shields.",
        },
        dps = {
            "Phase 1: assigned DPS shoot Frost Spheres so they fall and leave Permafrost where the Burrowers/Spikes will be. Then Anub'arak.",
            "Phase 2: kill the Swarm Scarabs; if Pursuing Spikes chase you, run to a Permafrost patch to stop them.",
            "Phase 3: Bloodlust/Heroism and all cooldowns - Leeching Swarm heals him from the raid.",
            "Enrage at 10 minutes.",
        },
        abilities = {
            { id = 66012, name = "Freezing Slash", desc = "Tank hit that freezes them for 3 seconds. Heal the spike." },
            { kind = "debuff", id = 66013, name = "Penetrating Cold", desc = "A frost damage-over-time on random players (more on heroic)." },
            { kind = "debuff", id = 66118, name = "Leeching Swarm", desc = "In phase 3 he drains the raid's health and heals himself. Keep health under 50%." },
            { ids = { 65919, 67858, 67859, 67860 }, name = "Impale", desc = "He impales a player after Pursuing Spikes. Fails on Permafrost." },
            { id = 66134, name = "Shadow Strike", desc = "Heroic: Burrowers' cast. Interrupt it." },
            { ids = { 67322, 53421 }, name = "Submerge", desc = "Burrowers use this; tank them on Permafrost to stop it." },
        },
        hard = {
            "Heroic mode: 4 Nerubian Burrowers instead of 2, limited to 6 Frost Spheres, Burrowers gain Shadow Strike (interrupt it) and keep spawning in phase 3.",
            "Penetrating Cold hits more players and hits harder on heroic. A Paladin's Hand of Protection on a Pursued player makes them immune to Pursuing Spikes - use it right before a Permafrost patch, then run into the patch just before it ends to keep Permafrost available.",
        },
    },
}, "AzerothCore boss scripts (timers, add counts), Icy Veins and wowtbc.gg guides")

WM:AddRaid("ony", "Onyxia's Lair", { "Onyxia's Lair" }, {
    {
        name = "Onyxia",
        aliases = { "Onyxian Whelp", "Onyxian Lair Guard" },
        tldr = "P1: tank her with her back to the wall, everyone else at her sides. P2 (65%): ranged burn, AoE whelps, melee kill Lair Guards, and run out of the Deep Breath path. P3 (40%): fears and lava - keep the tank feared-free.",
        start = {
            "Tank her against a wall facing AWAY from the raid so Tail Sweep and Wing Buffet can't knock players into the whelp eggs.",
            "Everyone except the tank stands at her sides: NOT in front (Flame Breath, Wing Buffet) and NOT behind (Tail Sweep).",
            "Do not touch the whelp eggs. A Priest or Shaman must be ready to remove fear from the tank in phase 3.",
        },
        general = {
            "## Phase 1 (100% to 65%)",
            "Onyxia uses Flame Breath, Cleave, Wing Buffet and Tail Sweep. Melee stay to her sides. Tail Sweep knocks players back and into the egg cave - that spawns extra whelps.",
            "## Phase 2 (65% to 40%)",
            "She takes off and can't be hit by melee. She casts Fireball on a random target and nearby allies. Deep Breath: at random times she emotes; note her position and direction and get out of her path - it kills anything in the line.",
            "A big wave of Onyxian Whelps pours out of the side caves at the start of the phase and more keep coming, plus an Onyxian Lair Guard about every 46 seconds (Blast Nova, Ignite Weapon).",
            "Ranged DPS burn Onyxia down but must AoE the whelps when they come; melee focus the Lair Guards. A tank gathers whelps for AoE, with healers close by.",
            "## Phase 3 (40%)",
            "She lands and casts Bellowing Roar - a raid-wide fear for about 3 seconds followed by lava eruptions. Finish adds while the tank repositions her at the wall.",
            "Similar to phase 1, plus periodic fears, eruption damage and occasional whelps. Remove fear from the tank (Priest Fear Ward / Shaman Tremor Totem) - if a feared tank runs into the raid, her next breath can wipe you.",
        },
        tank = {
            "Phase 1/3: tank her with her back to the wall, facing away from the raid. Fear Ward/Tremor Totem for Bellowing Roar in phase 3.",
            "Phase 2: one tank gathers the Onyxian Whelps for AoE; another picks up each Onyxian Lair Guard (about every 46 seconds) and holds it away from casters (Blast Nova).",
            "When she lands (40%), taunt her immediately and turn her back to the wall.",
        },
        heal = {
            "Phase 1: Flame Breath/Cleave on the tank only; stand at her sides.",
            "Phase 2: Fireballs on random players and whelp damage; stay near the whelp tank for AoE heals.",
            "Phase 3: Bellowing Roar fears everyone (keep the tank fear-protected); lava eruptions damage the raid.",
        },
        dps = {
            "Phase 1: attack from her sides, never front or back.",
            "Phase 2: ranged keep hitting her; AoE the whelps; melee kill the Lair Guards. Watch for Deep Breath (every 40-60 seconds) and move out of her line.",
            "Phase 3: burn her, stay out of the eruptions, and stand at her sides again.",
        },
        abilities = {
            { ids = { 68970, 18435 }, name = "Flame Breath", desc = "A frontal cone of massive fire damage. Only the tank is in front." },
            { id = 18500, name = "Wing Buffet", desc = "A frontal knockback attack." },
            { id = 68867, name = "Tail Sweep", desc = "Knocks back and damages players behind her. Can throw you into the whelp cave." },
            { ids = { 18392, 68926 }, name = "Fireball", desc = "Fire damage on a target and those near them in phase 2." },
            { ids = { 17086, 18351 }, spellName = "Breath", name = "Deep Breath", desc = "She flies across the room; anything in the line dies. Move out of her path." },
            { kind = "debuff", id = 18431, name = "Bellowing Roar", desc = "A raid-wide fear. Remove fear from the tank." },
            { id = 68958, name = "Blast Nova", desc = "Onyxian Lair Guards' AoE blast." },
        },
    },
}, "AzerothCore boss script (timers), Icy Veins and Warcraft Wiki")
