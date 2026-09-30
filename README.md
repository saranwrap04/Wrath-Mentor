WRATH MENTOR v2.15.3  -  in-game tactics for every WotLK raid (WoW 3.3.5a)
by Saranwrap
==========================================================================

INSTALL
  Delete any old WrathMentor folder, then copy this "WrathMentor" folder into:
      <WoW folder>\Interface\AddOns\
  Restart the game (or /reload). Your saved settings are kept.

WHAT'S IN THE WINDOW (/wm)
  Left: raid + boss list (bosses with a personal note are tinted blue). The list always starts
  with every raid collapsed when you log in or /reload - it only remembers which boss you last
  had open, not which raids were expanded, and that memory lasts for the rest of that play
  session (opening a boss auto-expands its own raid; the rest stay closed).
  The window can be resized: drag the small grip in the bottom-right corner, or set an overall
  size with the "Tactics window size" slider in Settings, and its opacity with the "Window
  opacity" slider underneath it.
  Row:  Notes  |  Copy
    - Notes opens a side box for your own notes on that boss. Press Save to keep them.
      (Unsaved text is also saved automatically if you change boss, close the box or the window.)
    - Copy shows the whole boss text as plain, selectable text: drag with the mouse to select
      part of it, or press Select all, then Ctrl+C. Press Back to return.
  Top row: All / Tank / Healer / DPS role filter, and 10 / 25 for the 10-man or 25-man version
  of the text (add counts, tank counts, number of marked players, etc.).

  A 3D model preview (when enabled in Settings) sits fixed at the top-right of the window, next
  to the boss's name shown big and centered in WoW's own default Friz Quadrata font. Both stay
  in place rather than scrolling with the text below - 3D model widgets are known to render
  incorrectly (or not at all) when placed inside a scrolling region, so it has to stay pinned to
  actually show up. The model is a static view (no dragging, zooming, or hover tooltip) and
  shows your current live target if it's this boss (100% accurate), otherwise falls back to a
  stored creature ID if the addon has one, or nothing at all if it doesn't. Turn it off with the
  "Show the 3D boss model preview" checkbox in Settings, or /wm models.

  Each boss shows, in order: TL;DR, How to start the fight, Strategy, Tank/Healer/DPS tips, the
  Hard mode / Heroic explanation, and finally the full Boss Abilities / Buffs & Debuffs lists at
  the very end of the page. Whenever the Start, Strategy or Hard mode text mentions one of this
  boss's abilities, buffs or debuffs by name, that name is colored right there in the sentence
  (blue for a plain ability, green for a buff, red for a debuff) and works as its own
  hoverable/clickable link, same as the entries in the full lists at the end - so you can check
  what something does right where it's mentioned, without having to scroll down.

BOSS TARGET ANNOUNCEMENT
  When you target a boss inside a raid, Wrath Mentor posts one chat line with that boss's TL;DR,
  ending in a clickable "[Shift-click to open <Boss>'s guide]" link - hold shift and click it to
  jump straight to that boss's full guide in the window. Inside a fight this posts at most ONCE per
  boss: targeting an add and then the boss again will not post it a second time. It posts again
  after that fight ends (or once for the next boss you pull). Toggle this in Settings ("Show TL;DR
  in chat when I target a boss"), or with /wm announce.

SEND TO CHAT
  "Send to chat" posts the boss's Strategy section by default, in the selected 10/25-man version,
  along with its Abilities and Buffs/Debuffs (as real spell links where the client can resolve
  them - those are clickable for everyone who sees the message, not just you). Change what gets
  sent with the "Send to chat sends" buttons in Settings: Strategy, Hard Mode (same, but the hard
  mode section instead), or TL;DR (just the one-line summary, no ability list, for a quick post).
  One line at a time, throttled so it won't trip chat flood limits.

ABILITY LINKS
  In the Boss Abilities and Buffs & Debuffs lists, each entry is shown with its spell icon next
  to a [Spell Name] link. Hover for the real game tooltip, click to open it, shift-click to put
  the link in chat.
  The same [Spell Name] also appears inline, right where that ability is mentioned by name inside
  the Strategy, Start or Hard mode text - colored the same way (blue/green/red) and working as its
  own small clickable button with the same hover tooltip and click behavior, not just decorative
  colored text. Every mention gets this, not only the first one.
  A link (and its icon) is only shown when this client confirms the spell ID has the expected name,
  so a wrong ID can never show a wrong spell or icon. Abilities without a confirmed ID show a plain
  question-mark icon and appear as plain white text instead of a link (and are never linkified in
  the prose either, for the same reason).
  /wm checklinks tells you how many abilities linked on your client.

BUFFS & DEBUFFS
  Right below Boss abilities, a separate "Buffs & Debuffs" section lists the fight's stacking marks,
  curses, diseases, shields and self-buffs the same way - spell icon, hover for the tooltip, click to
  open it, shift-click to link it in chat. Buff names show in green, debuff names in red, so you can
  tell them apart from across the room. Bosses with no status-effect abilities simply have no section
  here - only the boss abilities list shows. The Copy view lists these under their own
  "BUFFS & DEBUFFS" heading, separate from "BOSS ABILITIES".

COMMANDS
  /wm                          open / close
  /wm <boss name>              open a boss (partial names work: /wm lich, /wm sapph, /wm yogg)
  /wm role all|tank|heal|dps   role filter
  /wm size 10|25               choose 10-man or 25-man text
  /wm notes                    open / close the notes box
  /wm announce                 toggle the chat announcement when you target a boss (once per fight)
  /wm models                   toggle the 3D boss model preview on or off
  /wm minimap                  toggle the minimap button on or off
  /wm modeltest                print a step-by-step diagnostic if the 3D model preview isn't showing
  /wm config                   settings panel (also lists every command, right at the bottom)
  /wm send [raid|party|say]    send the selected boss to chat (Strategy/Hard Mode/TL;DR - see Settings)
  /wm checklinks               report resolved ability links
  /wm reset                    reset window position/size
  This same list is also shown inside the Settings panel itself, so you don't have to come back
  here to check it.

EDITING THE DATA
  Open Data_*.lua in a text editor. Boss fields:
    name, aliases, tldr, start, general, tank, heal, dps, abilities, hard
  Line tags:   "[10] text" = only in 10-man,  "[25] text" = only in 25-man,
               "#{a/b}" = a in 10-man / b in 25-man,  "## Title" = sub-heading inside a list.
  Ability:     { ids = { 10-man id, 25-man id }, name = "Exact Spell Name", desc = "..." }
  Boss names must match the in-game NPC name (English client) for the chat announcement to trigger.
  Personal notes are stored in your saved variables, keyed by raid and boss name.

ICON
  icon.png (150x150) is a preview/listing image for this addon. WoW 3.3.5a loads textures as
  .blp or .tga, not .png, so it is not loaded in-game - it's for CurseForge/WoWInterface-style
  listings or your addon manager.

ADDING MORE 3D MODELS
  Add npcId = <creature ID> right after a boss's "name" line in its Data_*.lua file (e.g.
  npcId = 15956 for Anub'Rekhan). This is the boss's NPC/creature ID, not a spell ID - find it
  on a site like Warcraft Wiki or Wowhead ("npc=15956" in the page URL). 14 Naxxramas bosses
  have this set already; the rest are still open. Note that npcId is only ever a fallback:
  whenever you have the selected boss actually targeted in-game, the preview uses that live
  target instead and ignores npcId entirely, since that's always guaranteed correct. A boss
  with no npcId and no live target just shows nothing instead of a blank frame or, worse, the
  wrong model.

LINKS
  GitHub:   https://github.com/saranwrap04/Wrath-Mentor
  Warperia: https://warperia.com/addon-wotlk/wrath-mentor/
  Both are also shown at the bottom of the in-game Settings panel.
<img width="1083" height="851" alt="Screenshot 2026-09-30 184216" src="https://github.com/user-attachments/assets/2f3d50c6-9bdc-4cc6-8d5b-741ded0a2b2e" />
<img width="1075" height="854" alt="Screenshot 2026-09-30 184225" src="https://github.com/user-attachments/assets/1d3e1d83-fe50-4776-9019-d0610538c03f" />
<img width="1076" height="853" alt="Screenshot 2026-09-30 184233" src="https://github.com/user-attachments/assets/fc6ebbe9-7c54-416d-8180-9dd76a339ba8" />
<img width="824" height="755" alt="Screenshot 2026-09-30 184249" src="https://github.com/user-attachments/assets/1e19724c-a0b4-4b3b-9ddc-86464043ce2c" />
<img width="660" height="61" alt="Screenshot 2026-09-30 184255" src="https://github.com/user-attachments/assets/6520e671-25f0-4f32-9d5d-36567ce1b783" />

