WRATH MENTOR v2.3.1  -  in-game tactics for every WotLK raid (WoW 3.3.5a)
==========================================================================

INSTALL
  Delete any old WrathMentor folder, then copy this "WrathMentor" folder into:
      <WoW folder>\Interface\AddOns\
  Restart the game (or /reload). Your saved settings are kept.

WHAT'S IN THE WINDOW (/wm)
  Left: raid + boss list (bosses with a personal note are tinted blue).
  Top row:  All / Tank / Healer / DPS  |  10 / 25  |  Notes  |  Copy
    - Role buttons filter the tips.
    - 10 / 25 switches the text to the 10-man or 25-man version
      (add counts, tank counts, number of marked players, etc.).
    - Notes opens a side box for your own notes on that boss. Press Save to keep them.
      (Unsaved text is also saved automatically if you change boss, close the box or the window.)
    - Copy shows the whole boss text as plain, selectable text: drag with the mouse to select
      part of it, or press Select all, then Ctrl+C. Press Back to return.
  Each boss shows: TL;DR, How to start the fight, Strategy (by phase), Tank/Healer/DPS tips,
  Boss abilities and the Hard mode / Heroic explanation.

BOSS POPUP
  When you target a boss inside a raid, a small popup shows the boss's TL;DR.
  Inside a fight it appears at most ONCE per boss: if you close it, targeting an add and then the
  boss again will not bring it back. It can appear again in the next fight.

SEND TO CHAT
  "Send to chat" (and the Send button on the popup) posts ONLY the Strategy section of the boss,
  in the selected 10/25-man version, one line at a time.

ABILITY LINKS
  Abilities are shown as [Spell Name]. Hover for the real game tooltip, click to open it,
  shift-click to put the link in chat.
  A link is only created when this client confirms the spell ID has the expected name, so a wrong ID
  can never show a wrong spell. Abilities without a confirmed ID appear as plain white text.
  /wm checklinks tells you how many abilities linked on your client.

COMMANDS
  /wm                          open / close
  /wm <boss name>              open a boss (partial names work: /wm lich, /wm sapph, /wm yogg)
  /wm role all|tank|heal|dps   role filter
  /wm size 10|25               choose 10-man or 25-man text
  /wm notes                    open / close the notes box
  /wm quick                    toggle the TL;DR popup when you target a boss (once per fight)
  /wm config                   settings panel (also: right-click the minimap button)
  /wm minimap                  show / hide the minimap button
  /wm send [raid|party|say]    send the selected boss's Strategy section to chat
  /wm checklinks               report resolved ability links
  /wm reset                    reset window positions

  Personal notes are stored in your saved variables, keyed by raid and boss name.

<img width="1070" height="725" alt="Screenshot 2026-09-29 153434" src="https://github.com/user-attachments/assets/ef25c010-97f5-41b8-bc36-50b9137133d5" />

<img width="1068" height="718" alt="Screenshot 2026-09-29 153452" src="https://github.com/user-attachments/assets/208d4907-d194-4c9d-88b2-d144e926bc0d" />

<img width="1071" height="715" alt="Screenshot 2026-09-29 153458" src="https://github.com/user-attachments/assets/f291a783-42cf-4d0a-ac8f-982f745e374d" />

<img width="444" height="180" alt="Screenshot 2026-09-29 153514" src="https://github.com/user-attachments/assets/634b6403-aa02-4a8f-81a3-35673dbac64e" />

<img width="572" height="500" alt="Screenshot 2026-09-29 153530" src="https://github.com/user-attachments/assets/d3e61331-8fb0-498e-bb20-9251a9476553" />

