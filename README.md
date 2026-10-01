WRATH MENTOR v2.18.1  -  in-game tactics for every WotLK raid (WoW 3.3.5a)
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
  shows your current live target if it's this boss (100% accurate) - that's the only way it ever
  shows a model; a stored creature ID alone is never enough on its own, since this client doesn't
  reliably support showing a model from an ID without targeting it (confirmed: it reports
  success even when it silently fails to update, so it can't be trusted). Once you've targeted
  a boss and seen its model, that model stays remembered for the rest of the session - leave
  its page, browse other bosses, come back later with no target at all, and it's still there.
  Other bosses' pages correctly show nothing for themselves in the meantime (it only ever shows
  on the page of whichever boss it's actually displaying). Turn it off with the "Show the 3D
  boss model preview" checkbox in Settings, or /wm models.

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

  Which channel it sends to: if you currently have a chat box open (pressed Enter, or a
  channel-specific key) - raid, party, say, yell, guild, officer, whatever - it sends there,
  same as if you'd typed it yourself. With no chat box open, it falls back to raid if you're in
  one, otherwise party if you're in one, otherwise it's just printed locally for you to read.

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

SETTINGS
  Settings is its own window - not Blizzard's Interface/AddOns options panel - movable, closable
  with the X or Escape, same look as the main tactics window. Open it with /wm config, the
  "Settings" button in the main window, or right-clicking the minimap button. It has checkboxes
  for the chat TL;DR announcement, the 3D model preview and the minimap button; sliders for the
  tactics window's size and opacity; the "Send to chat" content picker; test/reset buttons; the
  everyday command list; and the GitHub/Warperia links (shown as plain text you can still click
  and copy - no visible box around them). Changes apply immediately - there's no separate "Okay"
  step. "Defaults" in the top-right resets everything back to its starting values. The command
  list only shows everyday commands - the two diagnostic ones (/wm modeltest, /wm checklinks)
  are left off on purpose so they're not something people stumble into; both still work fine
  typed directly, they're just not advertised.

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
  /wm config                   opens/closes the Settings window (also lists every command, one
                                per line, in its own scrolling box near the bottom)
  /wm send [raid|party|say]    send the selected boss to chat (Strategy/Hard Mode/TL;DR - see Settings)
  /wm checklinks               report resolved ability links
  /wm reset                    reset window position/size
  This same list is also shown inside the Settings window itself, so you don't have to come back
  here to check it.

EDITING THE DATA
  Open Data_*.lua in a text editor. Boss fields:
    name, aliases, tldr, start, general, tank, heal, dps, abilities, hard
  Line tags:   "[10] text" = only in 10-man,  "[25] text" = only in 25-man,
               "#{a/b}" = a in 10-man / b in 25-man,  "## Title" = sub-heading inside a list.
  Ability:     { ids = { 10-man id, 25-man id }, name = "Exact Spell Name", desc = "..." }
  Boss names must match the in-game NPC name (English client) for the chat announcement to trigger.
  Personal notes are stored in your saved variables, keyed by raid and boss name.

ABOUT THE npcId FIELD
  Some bosses in the Data_*.lua files still have an npcId = <creature ID> line left over from an
  earlier attempt at showing a model without targeting the boss first. It's no longer used for
  anything - this client doesn't reliably support that approach (it reports success even when it
  silently fails to actually change the model, which was causing the wrong boss's model to get
  stuck showing), so the addon only ever shows a model when you've actually targeted that boss.
  The field is harmless to leave in the data files; it's just inert.

LINKS
  GitHub:   https://github.com/saranwrap04/Wrath-Mentor
  Warperia: https://warperia.com/addon-wotlk/wrath-mentor/
  Both are also shown at the bottom of the in-game Settings window, as real copyable text boxes
  (click one, Ctrl+A, Ctrl+C) - always in the same place regardless of how long the command
  list above them is, since that list scrolls within its own fixed-height box.

Main addon window

<img width="1057" height="854" alt="Screenshot 2026-10-01 090125" src="https://github.com/user-attachments/assets/d1185377-fada-4242-a69e-d2a3abfbd5e6" />
<img width="1059" height="850" alt="Screenshot 2026-10-01 090138" src="https://github.com/user-attachments/assets/f2661653-e216-4599-bd35-63194c987a52" />
<img width="1055" height="849" alt="Screenshot 2026-10-01 090152" src="https://github.com/user-attachments/assets/e92304b4-9b55-4ce0-b3c3-3a293cc47b5a" />
<img width="1056" height="851" alt="Screenshot 2026-10-01 090201" src="https://github.com/user-attachments/assets/dde80643-2f4e-4ce2-8f5d-d72de7a69abf" />
<img width="1056" height="858" alt="Screenshot 2026-10-01 090212" src="https://github.com/user-attachments/assets/ba8d2cf7-6ad3-4eb6-bd1d-48b45edb5f29" />

Settings Window

<img width="781" height="986" alt="Screenshot 2026-10-01 090229" src="https://github.com/user-attachments/assets/0ab2c800-fc32-4970-b022-214097364ba3" />

Show TL;DR in chat when i target a boss

<img width="660" height="49" alt="Screenshot 2026-10-01 090314" src="https://github.com/user-attachments/assets/2e77b776-dad1-4f30-8b47-ef189c79e77c" />
