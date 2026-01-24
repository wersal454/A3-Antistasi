Function Name: fn_actionRevive.sqf What it does: This function handles the complete medical revive action performed by a medic (player or AI) on an incapacitated unit. It validates that the action can begin, manages a timed progress bar with animations, spawns visual medical props, consumes medical supplies, and handles cancellation or failure conditions. Finally, it applies the mechanical results of a successful revive, such as setting health and handling prisoner states.

How it does that: The function is divided into three main phases: input validation, the active waiting loop (progress), and the final resolution.

Parameter and State Validation: The function begins by extracting arguments and performing a series of safety checks to ensure the revive is valid.
Sqf

Apply
params ["_cured", "_medic"];
private _player = isPlayer _medic;
private _inPlayerGroup = if !(_player) then {if ({isPlayer _x} count (units group _medic) > 0) then {true} else {false}} else {false};
private _isMedic = [_medic] call A3A_fnc_isMedic;

if (captive _medic) then { _medic setCaptive false };
It determines if the medic is a player or AI, and if they are in a player's group (for chat messages).
It checks A3A_fnc_isMedic to determine if the medic receives a speed bonus.
It forces the medic out of captivity (safety mechanic).
It then checks a sequence of fail conditions:
Death: if !(alive _cured) exitWith - Checks if the target is dead.
Incapable: if !([_medic] call A3A_fnc_canFight) exitWith - Checks if the medic is stunned or dead.
Attached: if !(isNull attachedTo _cured) exitWith - Prevents reviving if the target is being carried or transported.
Not Incapacitated: if !(_cured getVariable ["incapacitated",false]) exitWith - Ensures the target actually needs help.
Supply Check: It calculates available medical items by merging global faction arrays with standard Arma items (items _medic).
Sqf

Apply
private _medkits = ["Medikit"] + (A3A_faction_reb get "mediKits");
private _hasMedkit = (count (_medkits arrayIntersect (items _medic + items _cured)) > 0);
If no Medikit is found, it looks for First Aid Kits (FAKs). If neither exists, the action exits.
Active Revive Loop (Progress): Once validated, the function sets up the timing and visual state.
Sqf

Apply
private _timer = if (_isMedic) then { time + (A3A_reviveTime / 2) } else { time + A3A_reviveTime };
_medic setVariable ["helping", true];
_medic playMoveNow selectRandom medicAnims;
Timer: Calculates the end time based on whether the unit is a medic (50% faster).
Animation: Plays a random healing animation (medicAnims).
Action Handling:
If Player: Adds a "Cancel Revive" action to the medic and sets a variable on the cured unit so they know who is helping them.
If AI: Disables AI behaviors (FSM, MOVE, etc.) to prevent them from walking away.
Event Handler & Visuals (The "Wait"): An AnimDone event handler is added to keep the medic looping through healing animations.
Sqf

Apply
private _animHandler = _medic addEventHandler ["AnimDone", {
    // ... plays animation ...
    // ... spawns medical props (syringes, bandages) near the patient ...
}];
Props: Checks a variable A3A_medProps. If the count is low, it uses SCRT_fnc_misc_createBelonging to spawn physical medical items around the patient to simulate treatment.
Wait Loop:
Sqf

Apply
waitUntil {
    sleep 1;
    !([_medic] call A3A_fnc_canFight)
    or (time > _timer)
    or (_medic getVariable ["cancelRevive", false])
    or !(alive _cured)
};
Monitors 4 conditions: Medic becomes unable to fight, timer expires, cancellation flag is set, or the patient dies.
Cleanup & Resolution: After the loop breaks, the function cleans up the active state.
Sqf

Apply
// Remove props via spawn with delay
if (_props isNotEqualTo []) then { _nil = [_props] spawn { ... deleteVehicle _x ... }; };
_medic removeEventHandler ["AnimDone", _animHandler];
_medic playMoveNow "AinvPknlMstpSnonWnonDnon_medicEnd";
// ... re-enable AI ...
// ... remove cancel action ...
It deletes the medical props after a random delay (30-60s).
It removes the event handler and plays the "stand up" animation.
It restores AI capabilities or removes the UI action.
Final Outcome:
Sqf

Apply
if (_medic getVariable ["cancelRevive",false]) exitWith { ... };
if !(alive _cured) exitWith { ... };
if (!([_medic] call A3A_fnc_canFight)) exitWith { ... };

// Success
if (_isMedic) then {_cured setDamage 0} else {_cured setDamage 0.25};
if (!_hasMedkit) then { ... removeItem ... };
_cured setVariable ["incapacitated",false,true];
Checks for failure conditions (cancelled, dead, interrupted).
Success: Sets damage (0 for medics, 0.25 for others). Consums a FAK. Sets incapacitated to false.
Prisoner Logic: If the revived unit is an enemy (Occupants/Invaders) and not in the medic's group, it forces them into a surrendering state.
Where it leads:

Called by: A3A_fnc_help (AI logic) or player action ["Heal", ...] (Player interaction).
Dependencies:
A3A_fnc_isMedic: Checks trait/config for speed bonus.
A3A_fnc_canFight: Checks stun/incapacitation status.
SCRT_fnc_misc_createBelonging: Spawns visual medical props.
SCRT_fnc_misc_extendPosition: Calculates safe pos for props.
SCRT_fnc_misc_updateRichPresence: Updates Discord status for players.
Global Variables: Reads/Writes A3A_medProps, helping, cancelRevive, A3A_cured, helped, incapacitated.
Network: remoteExec is used inside the event handler (via SCRT_fnc_misc_createBelonging) to create objects on all machines. setVariable is broadcasted with true for global sync.
Function Name: fn_carry.sqf What it does: This function allows a unit to physically pick up and carry an incapacitated unit. It attaches the target to the carrier, plays specific animations, and monitors the state to automatically drop the target if the carrier becomes incapacitated, enters a vehicle, or the timeout expires.

How it does that:

Validation:

Sqf

Apply
params ["_carry", "_carrier"];
if (!alive _carry) exitWith { ... };
if !(_carry getVariable ["incapacitated",false]) exitWith { ... };
if !(isNull attachedTo _carry) exitWith { ... };
Checks if the target is alive, actually incapacitated, and not already attached to someone else.
Execution:

Sqf

Apply
_carrier playMoveNow "AcinPknlMstpSrasWrflDnon";
[_carry,"AinjPpneMrunSnonWnonDb"] remoteExec ["switchMove",_carry];
_carry setVariable ["helped",_carrier,true];
[_carry,"remove"] remoteExec ["A3A_fnc_flagaction",0,_carry];
_carry attachTo [_carrier, [0,1.1,0.092]];
_carry setDir 180;
Carrier: Plays the "carry" animation.
Carried: Remotely executes switchMove to the "dragged" animation on the target machine.
Attachment: Attaches the target to the carrier at a specific offset (behind and slightly up).
Flag Action: Removes the "Help/Carry" action from the target (to prevent stacking actions).
Action: Adds a "Release" action to the carrier.
Monitoring (WaitUntil):

Sqf

Apply
waitUntil {
    sleep 0.5; 
    (!alive _carry) or 
    !([_carrier] call A3A_fnc_canFight) or 
    !(_carry getVariable ["incapacitated",false]) or 
    ({!isNull _x} count attachedObjects _carrier == 0) or 
    (time > _timeOut) or 
    (vehicle _carrier != _carrier)
};
Triggers for Drop:
Target dies.
Carrier is killed/stunned (canFight).
Target is revived by someone else (variable reset).
Target is detached manually (count check).
Carrier enters a vehicle (vehicle _carrier != _carrier).
Cleanup:

Sqf

Apply
if (count attachedObjects _carrier != 0) then {detach _carry};
_carrier playMove "amovpknlmstpsraswrfldnon";
[_carry,"UnconsciousReviveDefault"] remoteExec ["switchMove",_carry];
[_carry,"heal1"] remoteExec ["A3A_fnc_flagaction",0,_carry];
sleep 5;
_carry setVariable ["helped",objNull,true];
Detaches the unit if still attached.
Resets carrier animation.
Restores the "Heal" flag action to the target.
Waits 5 seconds before clearing the helped variable (allows a window for immediate revive).
Where it leads:

Called by: Player action "Carry" or AI logic in A3A_fnc_help.
Dependencies:
A3A_fnc_canFight: Used in the loop to check if carrier is alive/functional.
A3A_fnc_flagaction: Used to manage action availability on the incapacitated unit.
SCRT_fnc_misc_updateRichPresence: Updates status.
Global Variables: Modifies helped (on target) and owner (implied by action condition).
Network: Heavily uses remoteExec for switchMove (anim changes) and flagaction (UI updates) to ensure visual sync across clients.
Function Name: fn_handleDamage.sqf What it does: This is the primary event handler attached to rebel units and players. It intercepts damage to handle helmet popping, trigger contact reports, manage the transition from healthy to unconscious, and handle the "downed" state (bleeding out).

How it does that:

Helmet Popping (Visuals):

Sqf

Apply
private _randomNumber = [1,100] call BIS_fnc_randomNum;
if (_damage >= 1 && {_hitPoint == "hithead"} && {helmetLossChance >= _randomNumber}) then 
{
    removeHeadgear _unit;
    [_unit, ["HelmetLoss", 150, 1, 0, 0]] remoteExec ["say3D", 0];
};
Checks for a headshot lethal enough to kill (>1 damage) and rolls against helmetLossChance. If successful, removes helmet and plays a sound globally.
AI Reaction & Contact Reports:

Sqf

Apply
if (_part == "" && _damage > 0.1) then
{
    if (!isPlayer (leader group _unit) && dam < 1.0) then { ... spawn A3A_fnc_unitGetToCover ... };
    if (side group _injurer == Occupants or side group _injurer == Invaders) then { ... [A3A_fnc_underAttack] remoteExec ... };
}
Get To Cover: If the unit is AI and takes significant damage (but isn't dying yet), they run to cover.
Under Attack: If the victim is a garrison unit and the attacker is enemy, it triggers a server-side "Under Attack" event (updates map markers/tasks).
ACE Medical Handover:

Sqf

Apply
if (A3A_hasACEMedical) exitWith {};
If ACE is running, this function stops here. ACE handles all medical logic (unconsciousness, death). The rest of this function is vanilla/legacy support.
Unconsciousness Logic (Vanilla):

Sqf

Apply
private _makeUnconscious = {
    params ["_unit", "_injurer"];
    _unit setVariable ["incapacitated",true,true];
    _unit setUnconscious true;
    moveOut _unit; // Eject from vehicle
    [_unit,_fromside] spawn A3A_fnc_unconscious;
};
This local function defines what happens when a unit goes down.
It sets the incapacitated flag, forces the "unconscious" state engine flag, ejects them from vehicles, and spawns the fn_unconscious loop (which handles the timer and UI).
Damage Processing Loop:

Full Body Hit (_part == ""):
If damage > 1: Checks for civilian (non-lethal cap) or enemy. Caps damage at 0.9 and calls _makeUnconscious.
If already unconscious: Accumulates overallDamage. If total > 1, unit dies. If not, caps damage at 0.9 (prevents death while down).
While Alive:
If damage > 0.25 and unit is helping someone else: cancelRevive.
If damage > 0.25 and unit is unassisted: Calls A3A_fnc_askHelp.
Body Part Hits (Head/Body): Similar logic to above, caps damage and triggers unconsciousness if critical.
Return Value:

Sqf

Apply
_damage
Returns the (potentially modified) damage value to the engine.
Where it leads:

Attached to: Units via A3A_fnc_initRevive.
Dependencies:
A3A_fnc_unitGetToCover: AI reaction.
A3A_fnc_unconscious: Starts the downed state loop.
A3A_fnc_askHelp: Requests AI assistance.
A3A_fnc_respawn: Called if damage accumulation exceeds threshold.
A3A_fnc_underAttack: Updates map intelligence.
Global Variables: Reads A3A_hasACEMedical, helmetLossChance. Writes incapacitated, helpFailed, overallDamage.
Network: remoteExec for sound and map updates.
Function Name: fn_handleDamageAAF.sqf What it does: This is the event handler for enemy AI (Occupants/Invaders). It manages their AI behavior (flanking/suppression), helmet popping for players hitting them, contact reports for PvP players, and handles their unconscious state (death or surrender).

How it does that:

Player-Specific Visuals & Intel:

Sqf

Apply
if (side group _injurer == teamPlayer) then {
    // Helmet popping logic ...
    // Contact report generation ...
    if (_part == "" && side group _unit == Occupants) then {
        private _marker = _unit getVariable ["markerX",""];
        // ... remoteExec A3A_fnc_underAttack
    }
}
Helmet popping only happens if hit by a rebel.
Contact reports are generated if the enemy is part of a garrison and hit by a rebel.
AI Group Reaction:

Sqf

Apply
if (time > _groupX getVariable ["movedToCover",0]) then {
    {[_x,_injurer] spawn A3A_fnc_unitGetToCover} forEach units _groupX;
}
If the enemy group hasn't moved to cover recently (120s cooldown), the entire group is ordered to get to cover when one member is hit.
ACE Handover:

Sqf

Apply
if (A3A_hasACEMedical) exitWith {};
Unconsciousness Logic (AAF):

Sqf

Apply
private _makeUnconscious = {
    params ["_unit", "_injurer"];
    _unit setVariable ["incapacitated",true,true];
    _unit setUnconscious true;
    moveOut _unit;
    // Leader transfer logic:
    if (_unit == leader (group _unit)) then { ... select new leader ... };
    [_unit, group _unit, _injurer] spawn A3A_fnc_AIreactOnKill;
    [_unit,_injurer] spawn A3A_fnc_unconsciousAAF;
};
Sets state, ejects from vehicle.
Crucial: Explicitly handles transferring group leadership if the leader goes down (prevents AI freezing).
Spawns unconsciousAAF (handles the bleed out timer and AI help requests).
Damage Management:

Full Body: Caps damage at 0.9. If already unconscious, adds to overallDamage. If total > 0.5, unit dies (AAF are tougher than rebels, requiring 1.5 total damage to kill).
Part Hits: Caps damage at 0.9. Triggers unconsciousness only on Head/Body if not already down.
Interruption: If damaged while helping, cancels the help action.
Where it leads:

Attached to: Enemy AI units.
Dependencies:
A3A_fnc_unconsciousAAF: Handles the specific AAF downed loop.
A3A_fnc_AIreactOnKill: Handles group suppression/morale.
A3A_fnc_underAttack: Intel reporting.
A3A_fnc_unitGetToCover: AI evasion.
Global Variables: Writes incapacitated, overallDamage, movedToCover (on group).
Network: remoteExec for intel updates.
Function Name: fn_initRevive.sqf What it does: This is a simple initialization function used to attach the core HandleDamage event handler to a unit and set up initial state variables.

How it does that:

Sqf

Apply
params["_unit"];
_unit setVariable ["respawning",false"];
[_unit] remoteExecCall ["A3A_fnc_punishment_FF_addEH",_unit,false];
_unit addEventHandler ["HandleDamage", A3A_fnc_handleDamage];
Sets respawning flag to false.
Adds a Friendly Fire punishment event handler (detached logic for tracking violations).
Adds the main fn_handleDamage (for rebels) or relies on fn_handleDamageAAF if the unit is an enemy.
Where it leads:

Called by: A3A_fnc_FIAinit (for rebels) or during unit creation in A3A_fnc_createUnit.
Dependencies: A3A_fnc_punishment_FF_addEH, A3A_fnc_handleDamage.
Network: remoteExecCall to apply FF EH specifically to the unit on its machine.
Function Name: fn_isMedic.sqf What it does: Checks if a unit qualifies as a medic, allowing them to revive faster and heal to full health.

How it does that:

Sqf

Apply
private _unit = _this select 0;
if (_unit getUnitTrait "Medic") exitWith {true};
if (getNumber (configfile >> "CfgVehicles" >> (typeOf _unit) >> "attendant") == 2) exitWith {true};
false
Checks the Medic unit trait (set via ACE or unit attributes).
Checks the vehicle config for attendant = 2 (standard Arma medic flag for AI classes).
Where it leads:

Called by: fn_actionRevive (time calculation), fn_unconscious (healing amount).
Function Name: fn_respawn.sqf What it does: Forces a player unit to respawn immediately, handling the transition of removing them from the world and triggering the respawn menu.

How it does that:

Sqf

Apply
params ["_unit"];
if (!local _unit) exitWith {};
if (_unit getVariable "respawning") exitWith {};
// ... validation ...

_unit setVariable ["respawning",true];
["A3A_infoCenter"] call BIS_fnc_rscLayer; // Shows "Respawning" text
if (captive _unit) then { ... setCaptive false ... };
_unit setDamage 1;
Prevents double-triggering via respawning variable.
Displays a localized "Respawning" hint.
Removes captivity (just in case).
Sets damage to 1 (death), which triggers the engine's respawn system.
Where it leads:

Called by: fn_handleDamage (if bleedout or lethal damage), fn_unconscious (if player chooses to respawn), or UI buttons.
Function Name: fn_selfRevive.sqf What it does: Allows a player to revive themselves from an incapacitated state, provided they have a specific "Self Revive Kit" (backpack item) and the cooldown has expired.

How it does that:

Validation:

Sqf

Apply
if !(player getVariable ["incapacitated", false]) exitWith {};
private _hasFAKs = _firstAidKits arrayIntersect items player;
if (_hasFAKs isEqualTo []) exitWith { ... };
if (time < player getVariable ["A3A_selfReviveTimeout", -1]) exitWith { ... };
Checks for the incapacitated state.
Checks inventory for FAKs (defined by faction).
Checks a 5-minute timeout variable.
Execution:

Sqf

Apply
player setVariable ["incapacitated", false, true];
player setDamage 0.5;
player removeItem selectRandom _hasFAKs;
private _timeout = missionNamespace getVariable ["A3A_selfReviveTimeout", 300];
player setVariable ["A3A_selfReviveTimeout", _timeout + time];
Clears the unconscious state.
Sets damage to 50% (wounded).
Consumes a FAK.
Sets the cooldown timer.
Visual Effects:

Sqf

Apply
private _handle = ppEffectCreate ["ColorCorrections", 1537];
handle ppEffectAdjust [ ... desaturation ... ];
A3A_selfRevivePPHandle = _handle;
Applies a heavy post-process effect (grayscale/desaturated) to simulate shock.
Sets a high aim coefficient (recoil) to punish the player for fighting immediately.
Cleanup Timer:

Sqf

Apply
_timeout spawn {
    sleep _this;
    [false] call A3A_fnc_selfReviveReset;
};
Starts a separate thread to wait for the timeout duration, then calls fn_selfReviveReset to remove the visual effects.
Where it leads:

Called by: Keybind (Q/H) while unconscious.
Dependencies:
fn_selfReviveReset: Cleans up effects after timer.
Global Variables: Writes incapacitated, A3A_selfReviveTimeout, A3A_selfRevivePPHandle.
Network: setVariable with true broadcasts the incapacitated state change.
Function Name: fn_selfReviveReset.sqf What it does: Cleans up the visual effects and state variables associated with fn_selfRevive.

How it does that:

Sqf

Apply
params [["_instant", true]];
if (!isNil "A3A_selfRevivePPHandle") then {
    if (!_instant) then { ... fade effect out over 10s ... };
    _handle ppEffectEnable false;
    ppEffectDestroy _handle;
};
player setVariable ["A3A_selfReviveTimeout", nil];
if (getCustomAimCoef player > 1) then { player setCustomAimCoef 1 };
Destroys the ColorCorrections PP effect.
Removes the timeout variable (allowing immediate self-revive if used via script/box).
Resets aim coefficient to 1 (normal).
Where it leads:

Called by: fn_selfRevive (after timeout), fn_unconscious (if unit dies or gets healed), A3A_fnc_removeAfter (medical box usage).
Function Name: fn_unconscious.sqf What it does: This is the main loop for an incapacitated player. It manages the 7.5-minute bleedout timer, displays UI prompts for self-revive or possession, requests AI help, and handles the final outcome (death, revive, or possession).

How it does that:

Setup:

Sqf

Apply
params ["_unit", "_injurer"];
private _bleedOut = time + 450; // 7.5 minutes
_unit setBleedingremaining 300;
Sets the 7.5 minute timer and resets bleeding to 5 minutes (meaning the player will bleed out visually before the timer expires if not bandaged).
Visuals & Effects:

Sqf

Apply
// Color correction and film grain adjustments
[] call _fnc_applyPostEffect;
// Start countdown UI if self-revive is available
[] call _fnc_selfReviveCountdownStart;
Initial State Management:

Sqf

Apply
_unit spawn { sleep 5; _this allowDamage true; }; // Re-enable godmode from HandleDamage
respawnMenu = (findDisplay 46) displayAddEventHandler ["KeyDown", SCRT_fnc_common_unconsciousEventHandler];
if (_injurer != Invaders) then { _unit setCaptive true }; // Don't capture if insta-killed by Alien/CSAT.
Sets up the "Unconscious" key handler (blocks movement, allows Q/H keys).
Sets captive status to prevent AI from targeting.
The Loop (WaitUntil):

Sqf

Apply
while {time < _bleedOut && _unit getVariable ["incapacitated",false] && alive _unit} do {
    // Request Help Logic:
    _helper = _unit getVariable ["helped", objNull];
    if (isNull _helper and _nextRequest < time) then {
        _helper = [_unit] call A3A_fnc_askHelp;
        // ... exponential backoff logic ...
    };

    // UI Updates (Possess/Self Revive):
    _textX = format [ ... ];
    ["A3A_infoCenter"] call BIS_fnc_rscLayer ... spawn bis_fnc_dynamicText;

    // Bleedout Adjustment:
    if !(isNull attachedTo _unit) then {_bleedOut = _bleedOut + 3}; // Attached units bleed slower
    sleep 3;
}
Loop Body:
Checks if someone is already helping (helped variable). If not, calls A3A_fnc_askHelp to find an AI medic.
Updates the on-screen text (e.g., "Bleeding out in 2:00", "Q to Self-Revive", "Press H to Possess Nearby Unit").
Extends bleedout timer if being dragged/carrying (prevents dying while being moved).
Plays random injured sounds.
Loop Exit & Resolution:

Bleedout (time > _bleedOut):
Sqf

Apply
if (time > _bleedOut) exitWith {
    if (_isPlayer) then { _unit call A3A_fnc_respawn; }
    else { _unit setDamage 1; };
};
Alive & Conscious (Revived):
Sqf

Apply
if (alive _unit) then {
    _unit setUnconscious false;
    _unit switchMove "unconsciousoutprone"; // Stand up animation
    _unit setBleedingRemaining 0;
    [] call _fnc_selfReviveCountdownStop;
    [] call SCRT_fnc_misc_updateRichPresence;
};
Cleanup:
Removes key handler.
Removes flag actions.
Removes PP effects.
Stops countdown timer.
Where it leads:

Called by: fn_handleDamage (player) or fn_handleDamageAAF (AI version).
Dependencies:
A3A_fnc_askHelp: Finds AI to heal player.
A3A_fnc_respawn: If timer expires.
SCRT_fnc_common_unconsciousEventHandler: Key inputs (Q/H).
SCRT_fnc_misc_updateRichPresence: Updates Discord.
Global Variables: Modifies bleedingremaining, respawnMenu, A3A_selfReviveTimeout (consumed if used), originalBody (if possessed).
Network: remoteExec for flag actions (heal1) so AI can interact.
Function Name: fn_unconsciousAAF.sqf What it does: The AI version of the unconscious loop. It manages the AI bleedout timer, requests help from other AI, and handles death or surrender.

How it does that:

Setup & Timer:

Sqf

Apply
private _bleedOutTime = if (surfaceIsWater (position _unit)) then {time + 60} else {time + 300};
AI bleed out in 5 minutes (or 1 minute if in water).
Help Request Loop:

Sqf

Apply
while { (alive _unit) && (time < _bleedOutTime) && (_unit getVariable ["incapacitated",false]) } do {
    private _helped = _unit getVariable ["helped",objNull];
    if (isNull _helped and _nextRequest < time) then {
        [_unit] call A3A_fnc_askHelp;
        _nextRequest = time + (2 + (_unit getVariable ["helpFailed", 0]))^2;
    };
    sleep 3;
}
Every few seconds (scaling with failures), it calls askHelp to find a nearby AI medic.
Resolution:

Death (Timer Expiry):
Sqf

Apply
if (time >= _bleedOutTime) exitWith {
    // ... credit killer ...
    _unit setDamage 1;
};
Revival (Alive):
Sqf

Apply
if (alive _unit) then {
    _unit setUnconscious false;
    _unit playMoveNow "unconsciousoutprone";
    if (_unit getVariable ["surrendering", false]) exitWith { ... spawn surrenderAction ... };
    if (captive _unit) then { _unit setCaptive false; };
};
Wakes up.
Checks for surrendering flag (set by actionRevive if revived by enemy).
If surrendering, calls A3A_fnc_surrenderAction.
Otherwise, removes captivity if they were held.
Where it leads:

Called by: fn_handleDamageAAF.
Dependencies:
A3A_fnc_askHelp: AI help logic.
A3A_fnc_surrenderAction: If captured/revived by enemy.
Global Variables: Reads surrendering. Writes overallDamage.
Network: remoteExec for flag actions (adding "Interact" or "Heal" flags).