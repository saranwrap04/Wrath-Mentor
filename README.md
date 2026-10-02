*Always download zip from the code to use the latest addon version*

WRATH MENTOR v3.0.0
In-game raid tactics for every Wrath of the Lich King raid boss (WoW 3.3.5a).
By Saranwrap

Raids: Naxxramas, The Obsidian Sanctum, The Eye of Eternity, Ulduar, Vault of Archavon,
Trial of the Crusader, Onyxia's Lair, Icecrown Citadel, The Ruby Sanctum.


INSTALL
  1. Close the game.
  2. Delete any old "WrathMentor" folder in <WoW folder>\Interface\AddOns\
  3. Copy the new "WrathMentor" folder there (keep the "textures" folder inside it).
  4. Start the game. Your settings and notes are kept.


QUICK START
  /wm            open the tactics window
  /wm lich       open a boss directly (part of the name is enough)
  Left-click the minimap button to open the window, right-click it for Settings.


THE TACTICS WINDOW
  - Pick a raid and a boss in the list on the left.
  - All / Tank / Healer / DPS: show only the tips for your role.
  - 10 / 25: switch the text between the 10-man and 25-man version.
  - Each boss page has: TL;DR, how to start the fight, strategy, role tips, hard mode / heroic,
    then the full list of boss abilities and buffs & debuffs.
  - Ability names are links: hover for the spell tooltip, click to open it, shift-click to link
    it in chat. Blue = ability, green = buff, red = debuff.
  - Notes: your own notes for the selected boss. Press Save. Bosses with notes are shown in blue
    in the list.
  - Copy: shows the page as plain text so you can select it and press Ctrl+C.
  - Resize the window by dragging the bottom-right corner.


3D BOSS MODEL
  Target the boss to load its 3D model in the top-right corner of its page. The model stays
  available for the rest of the session, even after you drop the target. Until then, the spot
  shows the Wrath Mentor artwork with a "Target <boss>" reminder.
  Turn it off in Settings or with /wm models.


CHAT ANNOUNCEMENT
  When you target a raid boss, you get a chat line with its TL;DR and a link to its guide
  (shift-click the link to open it). Only you see it, and it shows once per fight.
  Settings: turn it on/off, choose raid instances only, and press "Test" to see it now.


SEND TO CHAT
  "Send to chat" posts the selected boss to your group. Choose what it sends in Settings:
    Strategy    strategy + ability links (default)
    Hard Mode   hard mode section + ability links
    TL;DR       one short summary line
  Where it goes: the chat box you have open (raid, party, say, guild...). With no chat box open
  it goes to raid, or party, or only your own chat window if you are solo.
  "Test send to chat" in Settings shows you exactly what would be posted. Nothing is sent.


SETTINGS  (/wm config)
  - Chat announcement on/off, raid instances only, Test button
  - 3D model preview on/off
  - Minimap button on/off
  - Window size and window opacity sliders
  - Send to chat content: Strategy / Hard Mode / TL;DR, and Test send to chat
  - Default settings: puts every setting back to default
  - Reset position/size: puts the window back in the middle at its default size


COMMANDS
  /wm                          open / close the window
  /wm <boss name>              open a boss (partial names work: /wm sapph, /wm yogg)
  /wm role all|tank|heal|dps   role filter
  /wm size 10|25               10-man or 25-man text
  /wm notes                    open / close the notes box
  /wm announce                 chat announcement on / off
  /wm models                   3D model preview on / off
  /wm minimap                  minimap button on / off
  /wm send [raid|party|say]    send the selected boss to chat
  /wm config                   open / close Settings
  /wm reset                    reset window position and size
  /wm help                     list the commands in chat

  Troubleshooting:
  /wm modeltest                explains why a 3D model is not showing
  /wm checklinks               shows how many ability links work on your client


EDITING THE TACTICS
  The text lives in the Data_*.lua files (one per raid group). Boss fields:
    name, aliases, tldr, start, general, tank, heal, dps, hard, abilities
  "[10] text" / "[25] text"   line only shown in 10-man / 25-man
  "#{a/b}"                    a in 10-man, b in 25-man
  "## Title"                  sub-heading inside a section
  Ability: { ids = { 10-man id, 25-man id }, name = "Exact Spell Name", desc = "..." }
  Boss names must match the in-game name (English client) for the chat announcement to work.
  The npcId field in some bosses is no longer used and can be ignored.


LINKS
  GitHub:   https://github.com/saranwrap04/Wrath-Mentor
  Warperia: https://warperia.com/addon-wotlk/wrath-mentor/

<img width="1049" height="999" alt="Screenshot 2026-10-02 080328" src="https://github.com/user-attachments/assets/e213a213-4a30-4230-a611-057f498014e0" />
<img width="1051" height="1004" alt="Screenshot 2026-10-02 080350" src="https://github.com/user-attachments/assets/7784414a-8f7c-4e6f-8210-bba2a647db65" />
<img width="1046" height="1003" alt="Screenshot 2026-10-02 080410" src="https://github.com/user-attachments/assets/0e30d382-fa50-45f4-9a30-bd2e45c21a7d" />
<img width="1049" height="999" alt="Screenshot 2026-10-02 080425" src="https://github.com/user-attachments/assets/984e9661-fd28-41d0-84db-676d1fab3cf9" />
<img width="794" height="1002" alt="Screenshot 2026-10-02 080444" src="https://github.com/user-attachments/assets/e0f6155a-90a5-45b7-b001-10a5c1ecda67" />
<img width="664" height="56" alt="Screenshot 2026-10-02 080452" src="https://github.com/user-attachments/assets/4647bf29-359f-471f-9420-a1b497f26483" />
<img width="1254" height="1254" alt="Wrath Mentor Emblem" src="https://github.com/user-attachments/assets/2408bdf3-f565-4e78-99a8-c444019d6f71" />
<img width="150" height="150" alt="Wrath Mentor 150x150" src="https://github.com/user-attachments/assets/dc5943dc-b9db-4f75-84cc-98dae63fb9c2" />
<img width="1254" height="1254" alt="Wrath Mentor Icon v2" src="https://github.com/user-attachments/assets/767107fe-9b18-483a-a8ea-97b860f705aa" />
