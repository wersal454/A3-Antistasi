File: A3A/addons/core/functions/proxy/fn_onPlayerRespawn.sqf
Purpose:
This function serves as the primary client-side respawn handler for Antistasi. It is triggered automatically by the Arma 3 engine whenever the player respawns. Its purpose is to sanitize the new unit, transfer all relevant gameplay state (money, score, reputation, hostages) from the old unit, re-apply event handlers for stealth and interaction, reset UI elements, and handle specific edge cases like LAN hosting Zeus access and admin transfers.

Function: A3A_fnc_onPlayerRespawn
1. Initialization and Guard Clauses
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (isDedicated) exitWith {};
params ["_newUnit","_oldUnit"];

if (isNull _oldUnit) exitWith {};

waitUntil {alive _newUnit};
Implementation:

Preprocessing: Includes the standard component header and fixes line numbers for debugging.
Dedicated Server Check: if (isDedicated) exitWith {}; ensures this code never runs on the server process, as it relies on user input and local UI.
Parameter Extraction: params ["_newUnit","_oldUnit"] captures the arguments provided by the engine.
Sanity Check: if (isNull _oldUnit) exitWith {}; handles the very first spawn of a session where there is no previous unit.
State Synchronization: waitUntil {alive _newUnit}; pauses execution. This is critical. The engine triggers the respawn event before the unit is physically placed in the world or fully initialized. Without this wait, accessing inventory or position variables might fail or result in null references.
Context:

Called by the Arma 3 engine upon player death/respawn.
Critical for preventing "Null Pointer Exceptions" on spawn.
2. LAN Host Zeus Workaround
Sqf

Apply
if (isServer) then {
    _oldUnit addEventHandler ["Deleted", {
        [] spawn {
            sleep 1;
            { player assignCurator _x } forEach allCurators;
        };
    }];
};
Implementation:

Local Hosting Check: Only runs if the client is also the server (LAN Host).
Event Handler Attachment: Adds a "Deleted" event handler to the _oldUnit (the corpse).
Delayed Re-assignment: If the corpse is deleted (usually by the engine's garbage collector or a clean-up script), it waits 1 second and then forces the player to re-assign themselves to all available Zeus modules (allCurators).
Why: Bohemia's Zeus module has a bug where deleting the player's body strips them of curator access on LAN hosted games. This reclaims it.
Context:

Solves a specific Arma 3 engine limitation regarding LAN hosting and Zeus.
3. Corpse Cleanup and Variable Reset
Sqf

Apply
removeAllActions _oldUnit;
[_oldUnit] spawn A3A_fnc_postmortem;

_oldUnit setVariable ["incapacitated",false,true];
_newUnit setVariable ["incapacitated",false,true];

[true] call A3A_fnc_selfReviveReset;
Implementation:

Action Removal: removeAllActions cleans up the corpse to prevent menu clutter.
Postmortem Processing: A3A_fnc_postmortem (spawned) handles the loot bag creation (if enabled), corpse cleanup, and removing the unit from the "spawner" array.
Variable Sanitization: Explicitly sets incapacitated to false on both units to prevent stuck-in-animation states.
Revive Reset: A3A_fnc_selfReviveReset resets the self-revive counter/medkit usage, ensuring the player is fresh.
Context:

Essential for performance (garbage collection) and game logic consistency (state reset).
4. TeamPlayer Logic Branch (Rebel/Player)
This block executes if (side group _newUnit == teamPlayer) then { ... }. This handles the majority of the respawn logic for rebels.

4a. Remote AI / Body Snatching Check

Sqf

Apply
_owner = _oldUnit getVariable ["owner",_oldUnit];
if (_owner != _oldUnit) exitWith {
    [localize "STR_A3A_proxy_remoteai_header", localize "STR_A3A_proxy_remoteai_desc"] call A3A_fnc_customHint; 
    selectPlayer _owner; 
    disableUserInput false; 
    deleteVehicle _newUnit
};
Implementation:

Variable Retrieval: Checks if the _oldUnit was a remote AI controlled by the player (via Zeus or AI Squad Management).
Identity Restoration: If the _owner variable is not the unit itself, it means the player was controlling an AI.
Revert: It sends a hint, forces selectPlayer back to the original owner (the AI unit), re-enables input, and deletes the temporary respawn unit.
4b. Penalties and Statistics

Sqf

Apply
_nul = [0,-1,getPos _oldUnit] remoteExec ["A3A_fnc_citySupportChange",2];

_score = _oldUnit getVariable ["score",0];
_punish = _oldUnit getVariable ["punish",0];
_moneyX = _oldUnit getVariable ["moneyX",0];
_moneyX = round (_moneyX - (_moneyX * (deathPenalty / 100)));
// ... (clamped to 0)

_newUnit setVariable ["score",_score - 10,true];
// ... (other variable transfers)
Implementation:

City Support: Calls A3A_fnc_citySupportChange remotely on the server to decrease local support by 1 (hardcoded -1 in the args) because a rebel died.
Money Loss: Retrieves previous money, applies the deathPenalty global variable (percentage), rounds it, and ensures it doesn't go below 0.
Variable Transfer:
Score: Decreases by 10 points (_score - 10).
Punish/Eligible/Rank: Transferred from old to new.
Spawner: The old unit is removed from spawner logic; the new one is added.
Reset: respawning set to false, compromised reset.
4c. Ownership Transfer (Mines and Groups)

Sqf

Apply
_newUnit setRank (_rankX);
_newUnit setVariable ["rankX",_rankX,true];
{
    _newUnit addOwnedMine _x;
} count (getAllOwnedMines (_oldUnit));
{
    if (_x getVariable ["owner", ObjNull] == _oldUnit) then {
        _x setVariable ["owner", _newUnit, true];
    };
} forEach (units group _newUnit);
Implementation:

Rank Synchronization: Explicitly sets rank to prevent UI desync.
Mine Ownership: Iterates through mines owned by the old unit and assigns them to the new unit (prevents friendly fire/triggering).
Group Ownership: Iterates through group members to update owner variables, essential for AI squad management features.
4d. Loss Conditions & HR (Human Resources) Logic This is a complex switch statement dependent on loseHROnDeath (0, 1, or 2).

Sqf

Apply
switch (loseHROnDeath) do
{
    case 0: { call A3A_fnc_checkLossCondition; };
    case 1: {
        call A3A_fnc_checkLossCondition;
        if(tierWar >= 2) exitWith { [-1,0] remoteExec ["A3A_fnc_resourcesFIA",2]; };
    };
    case 2: {
        // ... Similar to case 1 but adds UI warnings via BIS_fnc_dynamicText
    };
};
Implementation:

Case 0: Only checks loss condition (Game Over if resources hit 0).
Case 1: Checks loss + removes 1 HR if War Tier is 2+.
Case 2: Checks loss + removes 1 HR + sends visual warnings to the player about low HR/Death Penalty.
Remote Execution: remoteExec ["A3A_fnc_resourcesFIA",2] sends the HR update to the Server/Headless Client (Owner ID 2).
4e. Boss Transfer

Sqf

Apply
disableUserInput false;
if (_oldUnit == theBoss) then {
    [_newUnit, true] remoteExec ["A3A_fnc_theBossTransfer", 2];
};
Implementation:

Checks if the dead unit held the theBoss variable (Commander).
If true, it remotely executes A3A_fnc_theBossTransfer on the server to assign the new unit as the commander.
4f. Loadout Application

Sqf

Apply
_newUnit setUnitLoadout [[],[],[],[selectRandom ((A3A_faction_civ get "uniforms") + (A3A_faction_reb get "uniforms")), []],[],[],[],"",[],
[(selectRandom unlockedmaps),"","",(selectRandom unlockedCompasses),(selectRandom unlockedwatches),""]];
Implementation:

Strips the unit and gives them a basic loadout.
Crucial Logic: It specifically gives them a Map, Compass, and Watch from the unlocked... arrays. This ensures they can navigate immediately. This is a safeguard in case they forgot to buy one in the Arsenal.
4g. Group Leadership

Sqf

Apply
if (!isPlayer (leader group _newUnit)) then {(group _newUnit) selectLeader _newUnit};
Implementation:

If the player respawns into a group currently led by an AI (e.g., after dying and the game auto-promoted an AI), force the player to be the leader.
4h. Event Handlers (The "Stealth" and Interaction System) The function re-applies a chain of event handlers to the _newUnit. These are the core of Antistasi's stealth and interaction mechanics.

FIRED Event Handler:

Checks if the player is captive (sneaking).
If they fire, it checks for nearby enemies (300m) or if they are in a "hostile" city zone (population density check).
If conditions are met, it removes captive status globally.
If in a vehicle, it propagates the loss of captivity to all crew members.
InventoryOpened Event Handler:

Checks if player is captive.
Triggers if opening a dead body or enemy ammobox.
Performs knowsAbout check (AI awareness) or City Zone check.
If caught, removes captive.
HandleHeal Event Handler:

Similar logic to above, but triggered when the player heals (potentially looting a medical crate or healing an NPC).
WeaponAssembled Event Handler:

Triggers when a bipod/weapon is deployed.
Initializes the vehicle via A3A_fnc_AIVEHinit.
If it is a static weapon, adds it to staticsToSave (persists across restarts).
Warns the player if they deploy inside a friendly zone (can attract air support).
WeaponDisassembled Event Handler:

Triggers when a static weapon is packed up.
Calls A3A_fnc_postmortem on the resulting backpacks to handle cleanup/loot logic.
Killed Event Handler (Rivals):

If the killer is a Rival (dynamic faction), it triggers SCRT_fnc_rivals_reduceActivity.
4i. UI and Utility Spawns

Sqf

Apply
[] spawn A3A_fnc_unitTraits;
[] spawn A3A_fnc_statistics;
call A3A_fnc_dropObject;
Implementation:

Traits: Applies role traits (Medic, Engineer, etc.).
Statistics: Updates the HUD (UI) with the new money, score, etc.
Drop Object: Ensures the player isn't carrying a movable object (like a crate) upon respawn, which would glitch geometry.
5. Non-TeamPlayer Logic (Enemy/AI Respawn)
Sqf

Apply
} else {
    _oldUnit setVariable ["spawner",nil,true];
    _newUnit setVariable ["spawner",true,true];
    [_newUnit] call A3A_fnc_dress;
    if (A3A_hasACE) then {[] call A3A_fnc_ACEpvpReDress};
};
Implementation:

If the respawned unit is not a rebel (e.g., someone switched sides or is playing as a duplicate unit), it performs a simplified reset.
Swaps spawner variables to ensure the new unit is tracked by the spawn system.
Calls A3A_fnc_dress to apply generic loadout.
If ACE is loaded, calls ACEpvpReDress to handle ACE specific inventory setups.
6. Client-Side Gameplay Settings
Sqf

Apply
if (fatigueEnabled isEqualTo false) then { 
    _newUnit enableFatigue false; 
}; 
 
if (staminaEnabled isEqualTo false) then { 
    _newUnit enableStamina false; 
}; 
 
private _newWeaponSway = swayEnabled / 100;
_newunit setCustomAimCoef _newWeaponSway;
Implementation:

Fatigue: Checks the global fatigueEnabled variable. If 0/false, disables stamina recovery drain.
Stamina: Checks staminaEnabled. If 0/false, disables the sprinting limit.
Sway: Reads swayEnabled (an integer like 1-100), divides by 100 to get a coefficient (e.g., 0.5), and applies it to setCustomAimCoef. This allows servers to control weapon handling difficulty.
Where it leads: Function Dependencies
Calls:

A3A_fnc_customHint: Displays UI notifications (Zeus transfer, warnings).
A3A_fnc_postmortem: Handles corpse cleanup and loot creation.
A3A_fnc_selfReviveReset: Resets client revive state.
A3A_fnc_citySupportChange: Updates global reputation/server variables.
A3A_fnc_checkLossCondition: Checks global resources for Game Over state.
A3A_fnc_resourcesFIA: Updates HR/Money on server.
A3A_fnc_theBossTransfer: Updates commander status.
A3A_fnc_punishment_FF_addEH: Adds Friendly Fire tracking.
A3A_fnc_outOfBounds: Starts the "Leave Area" death timer.
A3A_fnc_dropObject: Clears carried items.
A3A_fnc_statistics: Updates UI.
A3A_fnc_unitTraits: Sets role attributes.
A3A_fnc_dress: Applies loadout.
A3A_fnc_ACEpvpReDress: Applies ACE loadout.
A3A_fnc_AIVEHinit: Initializes vehicles (Static weapons).
SCRT_fnc_rivals_reduceActivity: Lowers rival activity (Rivals mod).
Modified Global Variables:

deathPenalty: Used to calculate money loss.
loseHROnDeath: Controls the switch statement logic.
tierWar: Checks for unlock states.
staticsToSave: Array modified if a static weapon is assembled.
theBoss: Checked and reassigned.
unlockedmaps, unlockedCompasses, unlockedwatches: Read for loadout.
fatigueEnabled, staminaEnabled, swayEnabled: Read for gameplay settings.
Network Implications:

Server Authority: Most state changes (money, HR, score, boss status) are remoteExec'd to the Server (Owner ID 2) to prevent cheating and ensure database saving.
JIP Compatibility: Variables are set on the new unit with true (global sync) so that other clients (and the server) know the state of the player (e.g., incapacitated, captive).
UI: Dynamic text warnings are remoteExec'd or called locally depending on the setting (Case 1 vs Case 2).