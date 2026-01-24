fn_AIdrag.sqf
Function Name: A3A_fnc_AIdrag
File: A3A/addons/core/functions/AI/fn_AIdrag.sqf

What it does: Handles the dragging of an injured/unconscious unit by a medic to a specified position. It creates a synthetic dummy unit to serve as a physical attachment point for the medic and target, then moves the dummy to the target position while simulating dragging animations and checking for interruptions.

How it does that:

1. Parameter Validation and Initial Setup:

Sqf

Apply
params ["_medic", "_target", "_dragPos"];
_medic setUnitPos "MIDDLE";
_medic playAction "grabDrag";
The function takes three parameters: the medic unit, the target unit to be dragged, and the position (array) where to drag them. It sets the medic's unit position to "MIDDLE" and plays the grab drag action to start the animation.

2. Wait for Drag Animation:

Sqf

Apply
_timeOut = time + 5;
waitUntil {sleep 0.3; ((animationState _medic) == "AmovPercMstpSlowWrflDnon_AcinPknlMwlkSlowWrflDb_2") or ((animationState _medic) == "AmovPercMstpSnonWnonDnon_AcinPknlMwlkSnonWnonDb_2") or !([_medic] call A3A_fnc_canFight) or (_timeOut < time)};
if !([_medic] call A3A_fnc_canFight) exitWith {};
Sets a 5-second timeout. Waits 0.3 seconds between checks for either the medic reaching the correct animation state or one of the following conditions:

Medic can no longer fight
Timeout expired If the medic can't fight, the function exits immediately.
3. Set Target to Dragged Pose:

Sqf

Apply
[_target,"AinjPpneMrunSnonWnonDb"] remoteExecCall ["switchMove", _target];
_medic disableAI "ANIM";
_medic stop false;
Sets the target's animation to the dragged pose remotely. Disables the medic's AI animation control and sets stop to false to ensure movement isn't blocked.

4. Create Dummy Helper Unit:

Sqf

Apply
private _dummyGrp = createGroup [civilian, true];
private _dummy = _dummyGrp createUnit ["C_man_polo_1_F", [0,0,20], [], 0, "FORM"];
_dummy setUnitPos "MIDDLE";
_dummy forceWalk true;
_dummy switchMove "AmovPknlMstpSlowWnonDnon";
_dummy setSkill 0;
[_dummy,true] remoteExec ["hideObjectGlobal",2];
_dummy allowdammage false;
_dummy setBehaviour "CARELESS";
_dummy disableAI "FSM";
_dummy disableAI "SUPPRESSION";
_dummy setPosATL (getPosATL _medic);
Creates a civilian group and a dummy unit at a high position. Configures the dummy:

Force walks (prevents running animations)
Switches to a neutral kneeling pose to avoid weapon stow animation
Sets skill to 0
Hides the dummy globally
Makes it invulnerable
Sets behavior to CARELESS
Disables FSM and suppression AI
Moves it to the medic's position
5. Attach Medic and Target to Dummy:

Sqf

Apply
_medic attachTo [_dummy, [0, -0.2, 0]];
_medic setDir 180;
_target attachTo [_dummy, [0,-1.1, 0.092]];
_target setDir 0;
Attaches the medic to the dummy at an offset of -0.2m in front (relative to dummy's direction) and the target at -1.1m behind. Sets the medic's direction to 180° (backward) and target to 0°.

6. Move Dummy to Target Position:

Sqf

Apply
_dummy doMove _dragPos;
[_medic] spawn {sleep 1; (_this select 0) playMove "AcinPknlMwlkSrasWrflDb"};
Commands the dummy to move to the drag position. After 1 second, the medic switches to a backwards walking animation.

7. Movement Monitoring Loop:

Sqf

Apply
private _timeOut = time + 30;
private _lastPos = getPosATL _dummy;
sleep 1;
while {true} do
{
    sleep 1;
    if (!([_medic] call A3A_fnc_canFight) or (!alive _target) or (unitReady _dummy) or (_timeOut < time) or (_medic != vehicle _medic) or (_medic getVariable ["cancelRevive",false])) exitWith {};
    if (_lastPos distance _dummy < 0.1) exitWith {};
    _lastPos = getPosATL _dummy;
};
Monitors the dragging process:

30-second timeout
Checks every second for exit conditions:
Medic can't fight
Target is dead
Dummy is ready (reached destination)
Timeout expired
Medic entered a vehicle
"cancelRevive" variable set on medic
Also checks for getting stuck (if dummy hasn't moved more than 0.1m since last check)
8. Cleanup and Release:

Sqf

Apply
detach _target;
detach _medic;
deleteVehicle _dummy;
_medic enableAI "ANIM";
_medic playAction "released";
[_target, "UnconsciousReviveDefault"] remoteExecCall ["switchMove", _target];
Detaches both units, deletes the dummy, re-enables medic's AI animation control, plays release action, and sets target to the default unconscious pose.

Where it leads:

Calls: A3A_fnc_canFight - Used repeatedly to check if medic can continue fighting
Network calls: remoteExecCall with switchMove on _target (first and last calls) to synchronize animations across network
Modified globals: None
Dependencies: Requires A3A_fnc_canFight function to exist
Synchronization: Uses remoteExecCall for animation synchronization to ensure all clients see the same state. The dummy unit is created server-side (via createUnit), so drag physics are handled server-side but visual animations are synchronized.
System integration: This function is called by the revive system when a medic needs to drag an unconscious unit to a safer location. It's part of the medical system that prevents immediate death and allows tactical retreats.
Key Technical Details:
Uses synthetic unit (dummy) to avoid issues with attaching units directly to each other
Dummy is hidden and invulnerable to prevent interference
Animation switching uses remoteExecCall for network synchronization
Timeout mechanisms prevent infinite loops
Stuck detection prevents infinite dragging if physics fails
fn_airbomb.sqf
Function Name: A3A_fnc_airbomb
File: A3A/addons/core/functions/AI/fn_airbomb.sqf

What it does: Creates and launches bombs for airstrikes, handling different bomb types (HE, Cluster, Napalm, Chemical) with appropriate effects and timings. It schedules bomb drops based on aircraft speed and distance, simulating a proper bomb run.

How it does that:

1. Parameter Validation:

Sqf

Apply
params ["_plane", "_bombType", "_bombCount", "_bombRunLength", ["_isRivals", false]];
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Debug_1("Executing on: %1", clientOwner);
Receives plane object, bomb type string, bomb count, run length, and optional rivals flag. Includes debug info and fixed line numbers for error tracking.

2. Validate Bomb Run Length:

Sqf

Apply
if(_bombRunLength < 100) then {_bombRunLength = 100};
Ensures minimum run length of 100 meters to prevent scheduling errors.

3. Check for Vietnam Mod Support:

Sqf

Apply
private _hasVn = (side _plane == Invaders && "VN" isEqualTo ((A3A_Inv_template splitString "_") select 0)) 
    || (side _plane == Occupants && {"VN" isEqualTo ((A3A_Occ_template splitString "_") select 0)})
    || (side _plane == teamPlayer && {"VN" isEqualTo ((A3A_Reb_template splitString "_") select 0)});
Checks if the faction uses Vietnam mod templates by parsing the template strings. Determines if special VN ammo should be used.

4. Bomb Type Configuration:

Sqf

Apply
private _ammo = "";
private _bombOffset = 0;
switch (_bombType) do {
    case ("HE"):
    {
        _ammo = "Bo_Mk82";
        _bombOffset = 180;
    };
    // ... other cases
    default
    {
        Error_1("Invalid bomb type, given was %1", _bombType);
    };
};
if(_ammo == "") exitWith {};
Uses switch statement to set:

_ammo: Projectile classname
_bombOffset: Distance from plane to start bombs (meters)
Valid types: HE (180m offset), CLUSTER (10m), NAPALM (50/170m), CHEMICAL (25m). Exits if invalid type.

5. Calculate Bombing Parameters:

Sqf

Apply
private _speedInMeters = (speed _plane) / 3.6;
private _metersPerBomb = _bombRunLength / _bombCount;
private _timeBetweenBombs = (_metersPerBomb / _speedInMeters) - 0.05;
Converts speed from km/h to m/s. Calculates distance between bombs based on run length and count. Calculates time interval, subtracting 0.05s for scheduling buffer.

6. Rivals Offset Handling:

Sqf

Apply
if (!_isRivals) then {
    sleep ((_timeBetweenBombs / 2) + (_bombOffset / _speedInMeters));
};
If not rivals, sleeps before starting bombs. Calculates initial delay as half the time between bombs plus offset distance divided by speed.

7. Chemical Bomb Logic:

Sqf

Apply
if (_bombType isEqualTo "CHEMICAL") then {
    for "_i" from 1 to _bombCount do {
        if (isNil "_plane" || {!(alive _plane)}) exitWith {};
        sleep _timeBetweenBombs;
        private _bombPos = (getPos _plane) vectorAdd [0, 0, -6];
        _bomb = _ammo createvehicle _bombPos;
        waituntil {!isnull _bomb};
        _bomb setDir (getDir _plane);
        _bomb setVelocity [0,0,-50];
        
        [_bomb, _plane] spawn {
            params ["_lBomb", "_plane"];
            private _pos = [];
            private _pitchBank = [];
            while {(getPosATL _lBomb) select 2 > 1} do {
                _pos = getPos _lBomb;
                _pitchBank = _lBomb call BIS_fnc_getPitchBank;
            };
            playSound3D ["A3\Sounds_f\weapons\explosion\explosion_mine_1.wss", _lBomb];
            deleteVehicle _lBomb;
            _pos remoteExec ["SCRT_fnc_effect_createSmallExplosionEffect", 0];
            [[_pos select 0, _pos select 1, 0], (getDir _plane), _pitchBank, (side _plane)] remoteExec  ["SCRT_fnc_support_chemicalBomb", 2];
        };
    };
}
For chemical bombs:

Creates bomb 6m below plane
Sets velocity downward (-50m/s)
Spawns monitoring script that:
Waits for bomb to reach 1m altitude
Plays explosion sound
Deletes bomb
Creates explosion effect remotely (all clients)
Calls chemical bomb effect function on server (side 2)
8. Standard Bomb Logic:

Sqf

Apply
for "_i" from 1 to _bombCount do {
    sleep _timeBetweenBombs;
    if (alive _plane) then {
        private _bombPos = (getPosATL _plane) vectorAdd [0, 0, -5];
        _bomb = _ammo createvehicle _bombPos;
        _bomb setDir (getDir _plane);
        _bomb setVelocity [0,0,-50];
        _bomb setShotParents [_plane, driver _plane];
        if (_bombType == "NAPALM" && !_hasVn) then
        {
            [_bomb, _bombPos] spawn
            {
                params ["_bomb", "_bombPos"];
                while {!isNull _bomb} do
                {
                    _bombPos = getPosATL _bomb;
                    sleep 0.1;
                };
                [_bombPos] remoteExec ["A3A_fnc_napalm",2];
            };
        };
    };
};
For other bomb types:

Creates bomb 5m below plane
Sets direction and velocity
Sets shot parents to plane and pilot
For non-VN napalm:
Spawns monitoring script that tracks bomb position until null
Calls napalm effect on server when bomb is destroyed
Where it leads:

Calls: BIS_fnc_getPitchBank - Gets pitch and bank of bomb during chemical drop
Network calls:
remoteExec to SCRT_fnc_effect_createSmallExplosionEffect on all clients (chemical)
remoteExec to SCRT_fnc_support_chemicalBomb on server (chemical)
remoteExec to A3A_fnc_napalm on server (napalm)
Modified globals: None
Dependencies: Requires A3A_fnc_napalm function, SCRT_fnc_support_chemicalBomb, SCRT_fnc_effect_createSmallExplosionEffect
Synchronization: All explosions and effects are synchronized via remote execution. Bombs are created locally but effects are networked.
System integration: Called by the air support system when calling airstrikes. Handles the physical bomb creation and visual/audio effects. Part of the support system that AI groups can request.
Key Technical Details:
Different offsets for different bomb types to prevent collisions
Chemical bombs have special handling with local effect creation before detonation
Napalm uses position tracking to call effect after detonation
Buffer time between bombs prevents scheduling issues
Plane death/nil check prevents errors if plane is destroyed mid-bombing
fn_AIreactOnKill.sqf
Function Name: A3A_fnc_AIreactOnKill
File: A3A/addons/core/functions/AI/fn_AIreactOnKill.sqf

What it does: Handles AI group reactions when a unit is downed or killed. Triggers support calls, adjusts group behavior (fleeing), and has units perform specific reactions like suppressing fire, using smoke/flares, or charging.

How it does that:

1. Parameter Validation and Timeout Check:

Sqf

Apply
params ["_unit", "_group", "_killer"];
if (_unit getVariable ["downedTimeout", 0] > time) exitWith {};         
_unit setVariable ["downedTimeout", time + 1200];
Accepts killed/downed unit, its group, and killer. Exits if unit already processed within last 20 minutes (prevents duplicate reactions). Sets timeout for 20 minutes ahead.

2. Killer Validation:

Sqf

Apply
if((isNil "_killer") || {(isNull _killer) || {side (group _killer) == side _group}}) exitWith {};
Exits if:

Killer is nil or null
Killer is on same side (collision or friendly fire)
3. Add to Recent Damage Tracking:

Sqf

Apply
[side _group, getPosATL _unit, 10, _killer] remoteExec ["A3A_fnc_addRecentDamage", 2];
Remotely adds the kill to a recent damage tracking system on server (side 2) for 10 meter radius. Helps with response targeting.

4. Check Active Group Members:

Sqf

Apply
private _enemy = objNull;
private _activeGroupMembers = (units _group) select {_x call A3A_fnc_canFight};
if(count _activeGroupMembers == 0) exitWith {};
Filters group to units that can fight. If none, exits as no reaction possible.

5. Call for Support:

Sqf

Apply
if(_group getVariable ["A3A_canCallSupportAt", -1] < time) then {
    if (radiomanSupport isEqualTo false) then { // use radioman
        [_group, _killer] spawn A3A_fnc_callForSupportInfantry;
    } else { // use SL
        [_group, _killer] spawn A3A_fnc_callForSupport;
    };
};
Checks if group can call support (cooldown expired). Spawns either:

callForSupportInfantry - Uses radioman with animations
callForSupport - Uses squad leader
6. Artillery Support (if enabled):

Sqf

Apply
if (PATCOM_ARTILLERY_MANAGER) then {
    [getPos _killer, (random 150), "HE", (round (1 + tierWar / 2)), _group] call A3A_fnc_artilleryFireMission;
};
If artillery manager enabled, calls artillery mission at killer's position with HE rounds. Number of rounds scales with war tier.

7. Adjust Fleeing Behavior:

Sqf

Apply
if (!fleeing leader _group and random 1 < 0.5) then
{
    private _courage = leader _group skill "courage";
    _group allowFleeing (2 - _courage - count _activeGroupMembers / count units _group);
};
50% chance to adjust fleeing probability based on:

Leader's courage skill (higher = less fleeing)
Ratio of active members (more survivors = less fleeing)
8. Reaction Loop (Group-Wide):

Sqf

Apply
if (_group getVariable ["A3A_reactingToKill", false]) exitWith {};
_group setVariable ["A3A_reactingToKill", true];
{
    if !(_x call A3A_fnc_canFight) then { continue };
    private _enemy = _x findNearestEnemy _x;
    
    // Fleeing behavior
    if (fleeing _x && !isNull _enemy && (_x distance _enemy < 50) && (vehicle _x == _x)) exitWith {
        private _fleeChance = switch (true) do {
            case (_x getVariable ["isRival", false]): { random 25 };
            case (side _x == Occupants): { sqrt aggressionOccupants * 2 };
            default { sqrt aggressionInvaders * 2 };
        };
        // Clamp between 8-25
        if (_fleeChance < 8) then { _fleeChance = 8 } else {
            if (_fleeChance > 25) then { _fleeChance = 25 };
        };
        if ((random 100) < _fleeChance) then {
            [_x] spawn SCRT_fnc_common_panicFlee;
        } else {
            [_x] spawn A3A_fnc_surrenderAction;
        }
    };
    // Other reactions
    if (_x getVariable ["helping", false]) exitWith {};
    if (!isNull _enemy && (primaryWeapon _x in allMachineGuns)) exitWith {
        if (random 100 < 40) then { [_x,_enemy] spawn A3A_fnc_suppressingFire };
    };
    // Flare/Smoke conditions
    private _noNvgIndex = (units _group) findIf {hmd _x == "" || {getArray (configFile >> "CfgWeapons" >> (hmd _x) >> "visionMode") isEqualTo ["Normal","Normal"]}};
    if (sunOrMoon == 1 || _noNvgIndex == -1) exitWith {
        if (random 100 < 35) then { [_x,_x,_enemy] spawn A3A_fnc_chargeWithSmoke };
    };
    if (primaryWeapon _x in allGrenadeLaunchers) exitWith {
        [_x, side (group _x), _enemy] spawn A3A_fnc_useFlares;
    };
    sleep (1 + random 1);
} forEach _activeGroupMembers;
_group setVariable ["A3A_reactingToKill", nil];
Iterates through active members with reaction lock. Each unit:

Fleeing check: If fleeing and enemy < 50m away, calculate flee chance based on aggression (8-25% clamp). Calls panic flee or surrender.
Helping check: Skip if already helping.
Suppressing fire: If unit has MG and enemy exists, 40% chance to call suppressing fire.
Smoke charge: If no NVGs or daytime, 35% chance to call charge with smoke.
Flares: If unit has grenade launcher, calls flares.
Where it leads:

Calls:
A3A_fnc_canFight - Multiple times to check unit state
A3A_fnc_addRecentDamage - Remote to server
A3A_fnc_callForSupportInfantry - Spawned for support
A3A_fnc_callForSupport - Spawned for support
A3A_fnc_artilleryFireMission - Called for artillery
SCRT_fnc_common_panicFlee - Spawned for fleeing units
A3A_fnc_surrenderAction - Spawned for fleeing units
A3A_fnc_suppressingFire - Spawned for MG units
A3A_fnc_chargeWithSmoke - Spawned for smoke charge
A3A_fnc_useFlares - Spawned for flare units
Network calls: remoteExec to A3A_fnc_addRecentDamage on server (side 2)
Modified globals:
downedTimeout on killed unit
A3A_reactingToKill on group (set/unset)
A3A_canCallSupportAt on group (when called)
radiomanSupport (read, not modified)
Dependencies: Requires all called functions
Synchronization: Group-wide reaction lock prevents overlapping reactions. Remote execution for damage tracking.
System integration: Triggered by the death/damage event handler system. Part of AI squad tactics, coordinating responses to losses. Works with support system, aggression system, and morale system.
Key Technical Details:
Uses continue to skip non-fightable units
Clamps flee chance between 8-25% to prevent extreme reactions
Reaction lock (A3A_reactingToKill) prevents multiple triggers
Different flee chances for rivals vs occupants/invaders
Atmosphere-based reactions (day vs night, NVG availability)
fn_artySupport.sqf
Function Name: A3A_fnc_artySupport
File: A3A/addons/core/functions/AI/fn_artySupport.sqf

What it does: Handles player-triggered artillery support requests. Allows selection of artillery units, ammunition type, strike type (normal/barrage), position, and round count. Coordinates multiple artillery pieces and manages firing sequences.

How it does that:

1. Validate Selected Groups:

Sqf

Apply
if (count hcSelected player == 0) exitWith {[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_must_select"] call A3A_fnc_customHint;};

private ["_groups","_artyArray","_artyRoundsArr","_hasAmmunition","_areReady","_hasArtillery","_areAlive","_soldierX","_veh","_typeAmmunition","_typeArty","_positionTel","_artyArrayDef1","_artyRoundsArr1","_piece","_isInRange","_positionTel2","_rounds","_roundsMax","_markerX","_size","_forcedX","_textX","_mrkFinal","_mrkFinal2","_timeX","_eta","_countX","_pos","_ang"];
Checks if player has selected HC units. If not, shows custom hint and exits. Declares many variables for tracking artillery state.

2. Gather All Selected Units:

Sqf

Apply
_groups = hcSelected player;
_fdc = leader (_groups select 0);
_unitsX = [];
{_groupX = _x;
{_unitsX pushBack _x} forEach units _groupX;
} forEach _groups;
Gets selected HC groups. Takes first group's leader as FDC (Fire Direction Center). Flattens all group members into single array.

3. Check Artillery Capability:

Sqf

Apply
_hasAmmunition = 0;
_areReady = false;
_hasArtillery = false;
_areAlive = false;

{
_soldierX = _x;
_veh = vehicle _soldierX;
if ((_veh != _soldierX) and (not(_veh in _artyArray))) then
	{
	if (( "Artillery" in (getArray (configfile >> "CfgVehicles" >> typeOf _veh >> "availableForSupportTypes")))) then
		{
		_hasArtillery = true;
		if ((canFire _veh) and (alive _veh) and (isNil "typeAmmunition")) then
			{
			_areAlive = true;
#ifdef UseDoomGUI
	ERROR("Disabled due to UseDoomGUI Switch.")
#else
			createDialog "mortarType";
#endif
			waitUntil {!dialog or !(isNil "typeAmmunition")};
			if !(isNil "typeAmmunition") then
				{
				_typeAmmunition = typeAmmunition;
				{
				if (_x select 0 == _typeAmmunition) then
					{
					_hasAmmunition = _hasAmmunition + 1;
					};
				} forEach magazinesAmmo _veh;
				};
			if (_hasAmmunition > 0) then
				{
				if (unitReady _veh) then
					{
					_areReady = true;
					_artyArray pushBack _veh;
					_artyRoundsArr pushBack (((magazinesAmmo _veh) select 0)select 1);
					};
				};
			};
		};
	};
} forEach _unitsX;
Iterates through all selected units:

Gets vehicle, checks if it's a unit
Checks if vehicle has "Artillery" in availableForSupportTypes
If yes, sets _hasArtillery = true
If artillery is alive, fireable, and type not selected yet:
Sets _areAlive = true
Opens "mortarType" dialog (unless DoomGUI enabled)
Waits for user to select ammo type
Counts available magazines of selected type
If >0 and unit ready, adds to artillery arrays
Tracks: has artillery capability, alive artillery, ammunition available, ready units
4. Validation Checks:

Sqf

Apply
if (!_hasArtillery) exitWith {[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_must_select_2"] call A3A_fnc_customHint;};
if (!_areAlive) exitWith {[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_no_capability"] call A3A_fnc_customHint;};
if ((_hasAmmunition < 2) and (!_areReady)) exitWith {[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_no_ammo"] call A3A_fnc_customHint;};
if (!_areReady) exitWith {[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_busy"] call A3A_fnc_customHint;};
if (_typeAmmunition == "") exitWith {[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_modset"] call A3A_fnc_customHint;};
if (isNil "_typeAmmunition") exitWith {};
Series of validation checks with custom hints:

No artillery units selected
No capable artillery (all dead/broken)
Insufficient ammunition (needs at least 2 unless ready)
No ready artillery units
No ammunition type selected
Type variable nil
5. Select Strike Type:

Sqf

Apply
hcShowBar false;
hcShowBar true;

if (_typeAmmunition != "2Rnd_155mm_Mo_LG") then
	{
	closedialog 0;
#ifdef UseDoomGUI
	ERROR("Disabled due to UseDoomGUI Switch.")
#else
	createDialog "strikeType";
#endif
	}
else
	{
	typeArty = "NORMAL";
	};

waitUntil {!dialog or (!isNil "typeArty")};
if (isNil "typeArty") exitWith {};
_typeArty = typeArty;
typeArty = nil;
Hides/shows HC bar. If not laser-guided rounds, opens strike type dialog. Otherwise defaults to "NORMAL". Waits for selection.

6. Position Selection:

Sqf

Apply
positionTel = [];
[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_select_pos"] call A3A_fnc_customHint;
if (!visibleMap) then {openMap true};
onMapSingleClick "positionTel = _pos;";
waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
onMapSingleClick "";
if (!visibleMap) exitWith {};
_positionTel = positionTel;
Prompts for position selection. Opens map if not visible. Uses onMapSingleClick to capture click. Waits until position selected or map closed.

7. Filter Artillery in Range:

Sqf

Apply
_artyArrayDef1 = [];
_artyRoundsArr1 = [];
for "_i" from 0 to (count _artyArray) - 1 do
	{
	_piece = _artyArray select _i;
	_isInRange = _positionTel inRangeOfArtillery [[_piece], ((getArtilleryAmmo [_piece]) select 0)];
	if (_isInRange) then
		{
		_artyArrayDef1 pushBack _piece;
		_artyRoundsArr1 pushBack (_artyRoundsArr select _i);
		};
	};
if (count _artyArrayDef1 == 0) exitWith {[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_out_of_bounds"] call A3A_fnc_customHint;};
Iterates through artillery pieces, checks if target position is in range using inRangeOfArtillery. Adds in-range pieces to filtered arrays. Exits if none in range.

8. Create Marker and Handle Barrage:

Sqf

Apply
_mrkFinal = createMarkerLocal [format ["Arty%1", random 100], _positionTel];
_mrkFinal setMarkerShapeLocal "ICON";
_mrkFinal setMarkerTypeLocal "hd_destroy";
_mrkFinal setMarkerColorLocal "ColorRed";

if (_typeArty == "BARRAGE") then
	{
	_mrkFinal setMarkerTextLocal (localize "STR_markers_arty_barrage_starting_pos");
	positionTel = [];
	[localize "STR_A3A_ai_artySupport_header", localize "STR_A3A_ai_artySupport_second_pos"] call A3A_fnc_customHint;
	if (!visibleMap) then {openMap true};
	onMapSingleClick "positionTel = _pos;";
	waitUntil {sleep 1; (count positionTel > 0) or (!visibleMap)};
	onMapSingleClick "";
	_positionTel2 = positionTel;
	};
if ((_typeArty == "BARRAGE") and (isNil "_positionTel2")) exitWith {deleteMarkerLocal _mrkFinal};
Creates local marker at position. If barrage, prompts for second position. Creates second marker. Deletes first marker if barrage incomplete.

9. Select Round Count:

Sqf

Apply
if (_typeArty != "BARRAGE") then
	{
	if (_typeAmmunition != "2Rnd_155mm_Mo_LG") then
		{
		closedialog 0;
#ifdef UseDoomGUI
	ERROR("Disabled due to UseDoomGUI Switch.")
#else
		_nul = createDialog "roundsNumber";
#endif
		}
	else
		{
		roundsX = 1;
		};
	waitUntil {!dialog or (!isNil "roundsX")};
	};

if ((isNil "roundsX") and (_typeArty != "BARRAGE")) exitWith {deleteMarkerLocal _mrkFinal};

if (_typeArty != "BARRAGE") then
	{
	_mrkFinal setMarkerTextLocal (localize "STR_markers_arty_strike");
	_rounds = roundsX;
	_roundsMax = _rounds;
	roundsX = nil;
	}
else
	{
	_rounds = round (_positionTel distance _positionTel2) / 10;
	_roundsMax = _rounds;
	};
For normal strikes, opens round count dialog (or defaults to 1 for laser-guided). For barrage, calculates rounds as distance between points / 10. Stores max rounds.

10. Force Spawn Check:

Sqf

Apply
_markerX = [markersX,_positionTel] call BIS_fnc_nearestPosition;
_size = [_markerX] call A3A_fnc_sizeMarker;
_forcedX = false;
if ((not(_markerX in forcedSpawn)) and (_positionTel distance (getMarkerPos _markerX) < _size) and ((spawner getVariable _markerX != 0))) then
	{
	_forcedX = true;
	forcedSpawn pushBack _markerX;
	publicVariable "forcedSpawn";
	};
Finds nearest marker to target. If marker is active (not 0) and not already forced, adds to forcedSpawn array and publicizes.

11. Communication and ETA:

Sqf

Apply
_textX = format [localize "STR_chats_mortar_barrage", mapGridPosition _positionTel, round _rounds];
[theBoss,"sideChat",_textX] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
Sends chat message to players about barrage start.

12. Barrage Setup:

Sqf

Apply
if (_typeArty == "BARRAGE") then
	{
	_mrkFinal2 = createMarkerLocal [format ["Arty%1", random 100], _positionTel2];
	_mrkFinal2 setMarkerShapeLocal "ICON";
	_mrkFinal2 setMarkerTypeLocal "hd_destroy";
	_mrkFinal2 setMarkerColorLocal "ColorRed";
	_mrkFinal2 setMarkerTextLocal (localize "STR_markers_arty_barrage_ending_pos");
	_ang = [_positionTel,_positionTel2] call BIS_fnc_dirTo;
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_positionTel, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_timeX = time + _eta;
	_textX = format [localize "STR_chats_mortar_barrage_confirm",round _eta];
	[_fdc,"sideChat",_textX]remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	[_timeX, _fdc] spawn {...};
	```
Creates second marker, calculates direction between points. Gets ETA from first artillery piece. Spawns monitoring script for communication.

**13. Fire Sequence:**
```sqf
for "_i" from 0 to (count _artyArrayDef1) - 1 do
	{
	if (_rounds > 0) then
		{
		_piece = _artyArrayDef1 select _i;
		_countX = _artyRoundsArr1 select _i;
		
		[_fdc,"sideChat",localize "STR_chats_shot_over"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
		[] spawn { sleep 1; [player,"sideChat",localize "STR_chats_shot_out"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]] };

		if (_countX >= _rounds) then
			{
			if (_typeArty != "BARRAGE") then
				{
				_piece commandArtilleryFire [_pos,_typeAmmunition,_rounds];
				}
			else
				{
				for "_r" from 1 to _rounds do
					{
					_piece commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = 0;
			}
		else
			{
			if (_typeArty != "BARRAGE") then
				{
				_piece commandArtilleryFire [[_pos,random 10,random 360] call BIS_fnc_relPos,_typeAmmunition,_countX];
				}
			else
				{
				for "_r" from 1 to _countX do
					{
					_piece commandArtilleryFire [_pos,_typeAmmunition,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
					
				};
			_rounds = _rounds - _countX;
			};
		};
	};
Iterates through artillery pieces:

For normal fire: Fire all requested rounds at once
For barrage: Fire 1 round at a time, reposition along direction with slight randomness (±5°)
If piece has enough rounds, fire all; otherwise fire what it has and continue with next piece
Communication messages for shot fired/impact
14. Completion Monitoring:

Sqf

Apply
if (_typeArty != "BARRAGE") then
	{
	[_fdc,"sideChat",localize "STR_chats_rounds_complete"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	waitUntil {sleep 1; time > (_timeX - 5)};
	[_fdc,"sideChat",localize "STR_chats_splash_over"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	waitUntil {sleep 1; time > (_timeX + 5)};
	[player,"sideChat",localize "STR_chats_splash_out"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	};
Monitors ETA, sends warning/splash messages at appropriate times.

15. Cleanup:

Sqf

Apply
sleep 10;
deleteMarkerLocal _mrkFinal;
if (_typeArty == "BARRAGE") then {deleteMarkerLocal _mrkFinal2};
if (_forcedX) then {
	sleep 20;
	if (_markerX in forcedSpawn) then {
		forcedSpawn = forcedSpawn - [_markerX];
		publicVariable "forcedSpawn";
	};
};
Waits 10 seconds, deletes markers, removes marker from forcedSpawn after 20 seconds.

Where it leads:

Calls:
A3A_fnc_customHint - Multiple times for messages
A3A_fnc_commsMP - Remote for chat messages
BIS_fnc_nearestPosition - Finds nearest marker
A3A_fnc_sizeMarker - Gets marker size
BIS_fnc_dirTo - Calculates direction (barrage)
BIS_fnc_relPos - Calculates relative positions (barrage)
Network calls: remoteExec to A3A_fnc_commsMP for player communication
Modified globals:
forcedSpawn - Adds/removes markers
typeAmmunition - Read and set via dialog
typeArty - Read and set via dialog
roundsX - Read and set via dialog
Dependencies: Requires dialogs mortarType, strikeType, roundsNumber (unless DoomGUI)
Synchronization: All markers are local to executing player. Forced spawn array is public variable for global state. Firing commands are local to artillery units but effects are global.
System integration: Called by player through HC interface. Part of player-controlled support system. Works with spawn system (forcedSpawn), combat system (artillery fire), and communication system.
Key Technical Details:
Uses DoomGUI preprocessor directive for alternative GUI
Local markers for player visibility
Public variable for forced spawn synchronization
Handles both normal and barrage fire modes
Calculates barrage as line of fire with spread
Manages cooldown via forced spawn array
fn_askHelp.sqf
Function Name: A3A_fnc_askHelp
File: A3A/addons/core/functions/AI/fn_askHelp.sqf

What it does: Checks if a unit should ask for help and returns the unit that can help them (medic or nearby non-medic). Prioritizes medics and validates that helper can fight, isn't busy, and has necessary items.

How it does that:

1. Check Already Helped:

Sqf

Apply
params ["_target"];
private _helped = _unit getVariable ["helped", objNull];
if !(isNull _helped) exitWith { _helped };
Receives target unit. Checks if target already has someone helping them. Returns the helper if exists.

2. Player Group Check:

Sqf

Apply
if (!isPlayer _target and {units _target findIf { isPlayer _x and {_x getVariable ["incapacitated", false]} } != -1}) exitWith { objNull };
If target is not a player but group contains incapacitated player, exit with null. Prevents AI from helping players when player's own group should handle it.

3. Dangerous Position Check:

Sqf

Apply
private _enemy = _target findNearestEnemy _target;
if (!isPlayer _target and (_target distance _enemy < 100 or {[objNull, "VIEW"] checkVisibility [eyePos _enemy, eyePos _target] > 0})) exitWith { objNull };
For non-players, if enemy is within 100m or visible, exit. Abandons unit in immediate danger.

4. Check First Aid Kit Need:

Sqf

Apply
private _firstAidKits = ["FirstAidKit","Medikit"] + (A3A_faction_reb get "firstAidKits") + (A3A_faction_reb get "mediKits");
private _unitNeedsFAK = count (_firstAidKits arrayIntersect items _target) == 0;
Builds list of medical items from config. Checks if target has any medical items.

5. Separate Medics and Non-Medics:

Sqf

Apply
private _units = units group _target;
private _medics = _units select { [_x] call A3A_fnc_isMedic };
_units = _units - _medics;
Gets all group members. Filters medics using isMedic. Removes medics from regular units array.

6. Helper Validation Function:

Sqf

Apply
private _fnc_canHelp = {
    params ["_unit"];
    if ((isPlayer _unit) or (vehicle _unit != _unit) or (_unit distance _target > 100)) exitWith { false };
    if !([_unit] call A3A_fnc_canFight) exitWith { false };
    if (currentCommand _unit == "STOP") exitWith { false };
    if ((_unit getVariable ["maneuvering", false]) or (_unit getVariable ["helping", false]) or (_unit getVariable ["rearming", false])) exitWith { false };
    if (_unitNeedsFAK and {count (_firstAidKits arrayIntersect items _unit) == 0}) exitWith { false };
    true;
};
Defines validation function. Unit must be:

AI (not player)
Not in vehicle
Within 100m
Able to fight
Not stopped
Not maneuvering, helping, or rearming
Have required medical items if target needs them
7. Prioritize Medics:

Sqf

Apply
private _index = _medics findIf { _x call _fnc_canHelp };
if (_index != -1) exitWith {
    ServerDebug_2("Sending medic %1 to assist target %2", _medics select _index, _target);
    [_target, _medics select _index] spawn A3A_fnc_help;
    _medics select _index;
};
First checks medics. If valid medic found, spawns A3A_fnc_help and returns medic.

8. Fallback to Non-Medics:

Sqf

Apply
if !(_target getVariable ["incapacitated", false]) exitWith { objNull };

private _index = _units findIf { _x call _fnc_canHelp };
if (_index != -1) exitWith {
    ServerDebug_2("Sending non-medic %1 to assist target %2", _units select _index, _target);
    [_target, _units select _index] spawn A3A_fnc_help;
    _units select _index;
};
Only proceeds if target is incapacitated. Checks non-medics. If found, spawns help and returns helper.

9. No Help Available:

Sqf

Apply
objNull;
Returns null if no helper found.

Where it leads:

Calls:
A3A_fnc_isMedic - Checks if unit is medic
A3A_fnc_canFight - Checks if unit can fight
A3A_fnc_help - Spawned to initiate helping action
Network calls: None directly
Modified globals: helped variable on target (set by help function)
Dependencies: Requires isMedic, canFight, help functions
Synchronization: No network operations. Runs locally on server/HC.
System integration: Called by the medical system when a unit is incapacitated. Part of AI assistance chain that manages self-healing and team assistance.
Key Technical Details:
Uses findIf for efficient searching
Validates item ownership with array intersection
Prioritizes medics over regular units
Includes debug logging
Returns helper unit for caller to track
fn_assaultBuilding.sqf
Function Name: A3A_fnc_assaultBuilding
File: A3A/addons/core/functions/AI/fn_assaultBuilding.sqf

What it does: Commands a unit to assault a specific building by moving to nearest building position to a target. Prevents multiple units from assaulting same building simultaneously.

How it does that:

1. Parameter Validation and Setup:

Sqf

Apply
params ["_unit", "_nearX", "_building"];
_unit setVariable ["maneuvering",true];
_building setVariable ["assaulted",true];
Receives unit, target (enemy unit), and building to assault. Sets maneuvering flag on unit and assaulted flag on building to prevent duplicates.

2. Get Building Positions:

Sqf

Apply
private _buildingPos = _building buildingPos -1;
private _targetPos = if (_buildingPos isEqualTo []) then {position _nearX} else {[_buildingPos,_nearX] call BIS_fnc_nearestPosition};
Gets all building positions. If none, uses enemy's position. Otherwise finds nearest building position to enemy.

3. Move to Target:

Sqf

Apply
_timeOut = time + 60;
_unit doMove _targetPos;
Sets 60-second timeout. Commands unit to move to target position.

4. Assault Monitoring:

Sqf

Apply
while {true} do {
	if (time > _timeOut) exitWith {};
	if (!([_unit] call A3A_fnc_canFight) or {!([_nearX] call A3A_fnc_canFight)}) exitWith {};
	sleep 5;
};
Monitors every 5 seconds until:

Timeout
Unit can't fight
Target can't fight
5. Cleanup:

Sqf

Apply
_building setVariable ["assaulted",false];
_unit setVariable ["maneuvering",false];
_unit call A3A_fnc_recallGroup;
Clears building assault flag, clears unit maneuvering flag, recalls unit to group.

Where it leads:

Calls:
A3A_fnc_canFight - Checks unit and target state
BIS_fnc_nearestPosition - Finds nearest building position
A3A_fnc_recallGroup - Recalls unit to group
Network calls: None
Modified globals:
maneuvering on unit (set/clear)
assaulted on building (set/clear)
Dependencies: Requires canFight, recallGroup functions
Synchronization: No network operations. Building flags prevent concurrent assaults.
System integration: Called by attackDrillAI when buildings need to be cleared. Part of assault tactics.
Key Technical Details:
Uses buildingPos -1 for all positions
Single building flag prevents multiple units targeting same building
60-second timeout for assault completion
Unit returns to group after assault
fn_attackDrillAI.sqf
Function Name: A3A_fnc_attackDrillAI
File: A3A/addons/core/functions/AI/fn_attackDrillAI.sqf

What it does: Main AI combat behavior system for enemy groups. Manages unit roles (movable, base of fire, flankers), detects threats, calls support, and executes tactical maneuvers (flanking, assault, hiding) based on group state.

How it does that:

1. Initialization:

Sqf

Apply
if !(isNil {_groupX getVariable "A3A_AIScriptHandle"}) exitWith {};
_groupX setVariable ["A3A_AIScriptHandle", _thisScript];
Checks if group already has AI script running. Sets script handle variable.

2. Enemy Detection and Setup:

Sqf

Apply
_objectivesX = _groupX call A3A_fnc_enemyList;
_groupX setVariable ["objectivesX",_objectivesX];
_groupX setVariable ["taskX","Patrol"];
private _sideX = side _groupX;
private _friendlies = if ((_sideX == Occupants) or (_sideX == teamPlayer)) then {[_sideX,civilian]} else {[_sideX]};
Gets enemy list, sets up group task as patrol, determines friendly sides for proximity checks.

3. Classify Unit Roles:

Sqf

Apply
{
if (alive _x) then
	{
	_result = _x call A3A_fnc_typeOfSoldier;
	_x setVariable ["maneuvering",false];
	if (_result == "Normal") then
		{
		_movable pushBack _x;
		_flankers pushBack _x;
		}
	else
		{
		if (_result == "StaticMortar") then
			{
			_mortarsX pushBack _x;
			}
		else
			{
			if (_result == "StaticGunner") then
				{
				_mgs pushBack _x;
				};
			_movable pushBack _x;
			_baseOfFire pushBack _x;
			};
		};
	};
} forEach (units _groupX);
Classifies each unit:

Normal: Added to movable and flankers
StaticMortar: Added to mortars
StaticGunner: Added to MGs, movable, and base of fire
Others: Added to movable and base of fire
4. Handle Static Weapons:

Sqf

Apply
if (count _mortarsX == 1) then
	{
	_mortarsX append ((units _groupX) select {_x getVariable ["typeOfSoldier",""] == "StaticBase"});
	if (count _mortarsX > 1) then
		{
		_mortarsX spawn A3A_fnc_staticMGDrill;
		}
	else
		{
		_movable pushBack (_mortarsX select 0);
		_flankers pushBack (_mortarsX select 0);
		};
	};
If exactly one mortar, adds static base units. If >1 mortar, spawns static MG drill. Otherwise adds mortar to movable/flankers.

5. Handle Transport Vehicles:

Sqf

Apply
{
if (vehicle _x != _x) then
	{
	if !(vehicle _x isKindOf "Air") then
		{
		if ((assignedVehicleRole _x) select 0 == "Cargo") then
			{
			if (isNull(_groupX getVariable ["transporte",objNull])) then {_groupX setVariable ["transporte",vehicle _x]};
			};
		};
	};
} forEach units _groupX;
Sets group transport vehicle if any unit is cargo in ground vehicle.

6. Main Combat Loop:

Sqf

Apply
while {true} do
	{
	if !(isPlayer (leader _groupX)) then
		{
		// Update arrays
		_movable = _movable select {[_x] call A3A_fnc_canFight};
		_baseOfFire = _baseOfFire select {[_x] call A3A_fnc_canFight};
		_flankers = _flankers select {[_x] call A3A_fnc_canFight};
		_objectivesX = _groupX call A3A_fnc_enemyList;
		_groupX setVariable ["objectivesX",_objectivesX];
Main loop (only runs for AI groups):

Filters arrays to alive/fightable units
Updates enemy list
7. Threat Detection:

Sqf

Apply
if !(_objectivesX isEqualTo []) then
	{
	private _air = objNull;
	private _tank = objNull;
	{
		_eny = assignedVehicle (_x select 4);
		if (_eny isKindOf "Tank" and canFire _eny and count (weapons _eny) > 1) exitWith { _tank = _eny };
		if (_eny isKindOf "Air" and canFire _eny and count (weapons _eny) > 1) exitWith { _air = _eny };
	} forEach _objectivesX;
	```
Checks for enemy armor/air threats.

**8. Support Calls:**
```sqf
if !(isNull _air) then
	{
		_groupX setVariable ["taskX","Hide"];
		_taskX = "Hide";
	};
if !(isNull _tank) then
	{
		_groupX setVariable ["taskX","Hide"];
		_taskX = "Hide";
	};
if (_numObjectives > 2 * _numNearFriends and !isNull _nearX) then
	{
		_groupX setVariable ["taskX","Hide"];
		_taskX = "Hide";
	};
Sets task to "Hide" if:

Air threat
Tank threat
Too many enemies (2x friendlies)
9. Task Execution (Patrol):

Sqf

Apply
if (_taskX == "Patrol") then
	{
	if ((_nearX distance _LeaderX < 150) and !(isNull _nearX)) then
		{
		_groupX setVariable ["taskX","Assault"];
		_taskX = "Assault";
		}
	};
If patrol and enemy within 150m, switch to Assault.

10. Task Execution (Assault):

Sqf

Apply
if (_taskX == "Assault") then
	{
	if (_nearX distance _LeaderX < 50) then
		{
		_groupX setVariable ["taskX","AssaultClose"];
		_taskX = "AssaultClose";
		}
	else
		{
		if (_nearX distance _LeaderX > 150) then
			{
			_groupX setVariable ["taskX","Patrol"];
			}
		else
			{
			if !(isNull _nearX) then
				{
				{
				[_x,_nearX] call A3A_fnc_suppressingFire;
				} forEach _baseOfFire select {(_x getVariable ["typeOfSoldier",""] == "MGMan") or (_x getVariable ["typeOfSoldier",""] == "StaticGunner")};
				// Flare/Smoke logic
				};
			};
		};
	};
Assault logic:

If <50m, switch to AssaultClose
If >150m, switch to Patrol
Otherwise, suppress with MGs and handle flares/smoke
11. Task Execution (AssaultClose):

Sqf

Apply
if (_taskX == "AssaultClose") then
	{
	if (_nearX distance _LeaderX > 150) then
		{
		_groupX setVariable ["taskX","Patrol"];
		}
	else
		{
		if (_nearX distance _LeaderX > 50) then
			{
			_groupX setVariable ["taskX","Assault"];
			}
		else
			{
			if !(isNull _nearX) then
				{
				_flankers = _flankers select {!(_x getVariable ["maneuvering",false])};
				if (count _flankers != 0) then
					{
					{
					[_x,_x,_nearX] spawn A3A_fnc_chargeWithSmoke;
					} forEach (_baseOfFire select {(_x getVariable ["typeOfSoldier",""] == "Normal")});
					if ([getPosASL _nearX] call A3A_fnc_isBuildingPosition) then
						{
						// Building assault logic
						};
					}
				else
					{
					[_flankers,_nearX] spawn A3A_fnc_doFlank;
					};
				};
			};
		};
	};
Close assault:

If >150m, patrol
If >50m, assault
Otherwise, charge with smoke, assault building or flank
12. Transport Management:

Sqf

Apply
if (!isNull(_groupX getVariable ["transporte",objNull]) and !(_groupX getVariable ["A3A_forceDismount",false])) then
	{
	(units _groupX select {vehicle _x == _x}) allowGetIn true;
	};
Allows get-in if transport exists and not forced dismounted.

13. Cleanup and Delay:

Sqf

Apply
sleep 30;
_movable =  (_groupX getVariable ["movable",[]]) select {alive _x};
if ((_movable isEqualTo []) or (isNull _groupX)) exitWith {};
Sleeps 30 seconds, cleans up arrays, exits if no units or group destroyed.

Where it leads:

Calls: All functions in the AI tactical suite:
A3A_fnc_enemyList - Gets enemies
A3A_fnc_typeOfSoldier - Classifies units
A3A_fnc_staticMGDrill - For static weapons
A3A_fnc_canFight - Checks units
A3A_fnc_suppressingFire - For MG fire
A3A_fnc_useFlares - For night combat
A3A_fnc_chargeWithSmoke - For close combat
A3A_fnc_isBuildingPosition - For building check
A3A_fnc_destroyBuilding - For buildings
A3A_fnc_assaultBuilding - For buildings
A3A_fnc_doFlank - For flanking
A3A_fnc_hideInBuilding - For hiding
A3A_fnc_recallGroup - For recall
A3A_fnc_autoRearm - For rearming
Network calls: None
Modified globals:
A3A_AIScriptHandle on group
maneuvering on units
objectivesX on group
taskX on group
movable on group
baseOfFire on group
flankers on group
transporte on group
autoRearm on group (rebel groups)
autoRearmed on group (rebel groups)
A3A_forceDismount on group
Dependencies: Requires all called functions
Synchronization: No network operations. Runs locally on server/HC for each AI group.
System integration: Core AI combat controller. Runs continuously for enemy groups. Interfaces with support system, tactics system, and unit management.
Key Technical Details:
30-second main loop for performance
Dynamic role reclassification
Multiple task states (Patrol, Assault, AssaultClose, Hide)
Prevents overlap with maneuvering flags
Handles static weapons separately
Manages transport vehicles
Integrates with rearmin system for rebels
fn_attackHeli.sqf
Function Name: A3A_fnc_attackHeli
File: A3A/addons/core/functions/AI/fn_attackHeli.sqf

What it does: Maintains persistent attack helicopter behavior, preventing easy kills on first pass and avoiding hover after targets destroyed. Manages waypoint recreation to keep heli active.

How it does that:

1. Initialization:

Sqf

Apply
params ["_vehicle", "_group", "_targPos"];
_group setVariable ["A3A_AIScriptHandle", _thisScript];
Receives helicopter, crew group, and target position. Sets script handle.

2. Clear Existing Waypoints:

Sqf

Apply
while {count waypoints _group > 0} do { deleteWaypoint [_group, 0] };
_group setBehaviourStrong "COMBAT";
Clears all waypoints, sets combat behavior.

3. Check for Gunner:

Sqf

Apply
private _noGunner = isNull gunner _vehicle;
Determines if helicopter has gunner.

4. Create Initial Attack Waypoint:

Sqf

Apply
private _wayPos = _targPos getPos [300 + random 100, random 360];
private _destroyWP = _group addWaypoint [_wayPos, 0];
_destroyWP setWaypointType "SAD";
Creates waypoint 300-400m from target in random direction. Sets as SAD (Search and Destroy).

5. Attack Loop:

Sqf

Apply
private _approach = true;
private _timeout = time + 60 + (_vehicle distance2d _targPos) / 50;
while {true} do {
    sleep 10;
    if !(alive _vehicle and canFire _vehicle and canMove _vehicle) exitWith {};
    if !((_noGunner or gunner _vehicle call A3A_fnc_canFight) and driver _vehicle call A3A_fnc_canFight) exitWith {};
    
    if (_approach and { _vehicle distance2d _wayPos < 300}) then { _timeout = -1; _approach = false };
    if (currentWaypoint _group > 0 or time > _timeout ) then {
        _wayPos = _targPos getPos [50 + random 100, random 360];
        _destroyWP setWaypointPosition [_wayPos, 0];
        _group setCurrentWaypoint _destroyWP;
        _timeout = time + 300;
   };
};
Checks every 10 seconds:

Exits if heli dead/unable to fight
Exits if crew can't fight
Switches from approach to attack after reaching waypoint
Recreates waypoint every 300 seconds or if waypoint complete
6. Cleanup:

Sqf

Apply
ServerInfo("Attack heli aborted due to damage");
_group setVariable ["A3A_AIScriptHandle", nil];
[_vehicle] spawn A3A_fnc_VEHDespawner;
[_group] spawn A3A_fnc_enemyReturnToBase;
Logs abort, clears script handle, despawns vehicle and returns crew to base.

Where it leads:

Calls:
A3A_fnc_canFight - Checks crew state
A3A_fnc_VEHDespawner - Despawns vehicle
A3A_fnc_enemyReturnToBase - Returns crew
Network calls: None
Modified globals: A3A_AIScriptHandle on group
Dependencies: Requires canFight, VEHDespawner, enemyReturnToBase
Synchronization: No network operations. Waypoint management is local to group.
System integration: Called when attack heli support is requested. Prevents heli from being too passive.
Key Technical Details:
10-second check interval
Dynamic waypoint recreation
Tracks approach phase vs attack phase
300-second timeout for waypoint refresh
Crew death checks prevent zombie helis
fn_autoLoot.sqf
Function Name: A3A_fnc_autoLoot
File: A3A/addons/core/functions/AI/fn_autoLoot.sqf

What it does: AI unit automatically loots weapons and equipment from nearby weapon holders, dead bodies, and containers, then stores them in a transport vehicle. Prioritizes better weapons and fills vehicle inventory.

How it does that:

1. Initial Validation:

Sqf

Apply
params ["_unit", "_truckX"];
if ((isPlayer _unit) or (player != leader group player)) exitWith {};
if !([_unit] call A3A_fnc_canFight) exitWith {};
if (_unit getVariable ["helping",false]) exitWith {};
_rearming = _unit getVariable "rearming";
if (_rearming) exitWith {_unit groupChat localize "STR_chats_autoloot_rearm_heal_in_progress"; _unit setVariable ["rearming",false]};
if (_unit == gunner _truckX) exitWith {_unit groupChat localize "STR_chats_autoloot_rearm_gun_manning"};
if (!canMove _truckX) exitWith {_unit groupChat localize "STR_chats_autoloot_load_vehicle"};
Validates:

AI unit in player group
Can fight
Not helping
Not already rearming
Not gunner of truck
Truck can move
2. Find Nearby Loot Containers:

Sqf

Apply
private _objectsX = [];
private _hasBox = false;
private _weaponX = "";
private _weaponsX = [];
private _bigTimeOut = time + 120;
_objectsX = nearestObjects [_unit, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 50];
if (count _objectsX == 0) exitWith {_unit groupChat localize "STR_chats_autoloot_no_bodies"};
Finds weapon holders within 50m. 120-second timeout for entire process.

3. Find Best Weapon:

Sqf

Apply
_target = objNull;
_distanceX = 51;
{
_objectX = _x;
if (_unit distance _objectX < _distanceX) then
	{
	if ((count weaponCargo _objectX > 0) and !(_objectX getVariable ["busy",false])) then
		{
		_weaponsX = weaponCargo _objectX;
		for "_i" from 0 to (count _weaponsX - 1) do
			{
			_potential = _weaponsX select _i;
			_basePossible = [_potential] call BIS_fnc_baseWeapon;
			if ((_basePossible in allRifles) or (_basePossible in allSniperRifles) or (_basePossible in allMachineGuns) or (_potential in allMissileLaunchers) or (_potential in allRocketLaunchers)) then
				{
				_target = _objectX;
				_distanceX = _unit distance _objectX;
				_weaponX = _potential;
				};
			};
		};
	};
} forEach _objectsX;
Searches all containers for best weapon (rifles, snipers, MGs, launchers). Prioritizes closest container with valid weapon.

4. Take Weapon:

Sqf

Apply
if (isNull _target) exitWith {_unit groupChat localize "STR_chats_autoloot_no_loot"};
_target setVariable ["busy",true];
_unit setVariable ["rearming",true];
_unit groupChat localize "STR_chats_autoloot_start_looting";
_unit action ["GetOut",_truckX];
[_unit] orderGetin false;
If no loot, exits. Sets busy flag, moves unit out of vehicle.

5. Move to Weapon:

Sqf

Apply
_continuar = true;
while {_continuar and ([_unit] call A3A_fnc_canFight) and (_unit getVariable "rearming") and (alive _truckX) and (_bigTimeout > time)} do
	{
		if (isNull _target) exitWith {_continuar = false};
		_unit doMove (getPosATL _target);
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if (_unit distance _target < 3) then
			{
			_unit action ["TakeWeapon",_target,_weaponX];
			sleep 3;
			};
		_target setVariable ["busy",false];
		...
	};
Main loop until weapon taken or conditions fail. Moves to weapon, takes it if within 3m.

6. Find Magazines:

Sqf

Apply
_tempPrimary = primaryWeapon _unit;
if (_tempPrimary != "") then
	{
	_magazines = getArray (configFile / "CfgWeapons" / _tempPrimary / "magazines");
	_victims = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
	_hasBox = false;
	_distanceX = 51;
	{
	_victim = _x;
	if (({_x in _magazines} count (magazines _victim) > 0) and (_unit distance _victim < _distanceX)) then
		{
		_target = _victim;
		_hasBox = true;
		_distanceX = _victim distance _unit;
		};
	} forEach _victims;
	...
	};
Finds dead bodies with matching magazines for primary weapon.

7. Looting from Dead Bodies:

Sqf

Apply
if ((_hasBox) and (_unit getVariable "rearming")) then
	{
		...
		if (_unit distance _target < 3) then
			{
			{if (!(_x in unlockedMagazines) and !(_x in unlockedItems)) then {_unit addItemToUniform _x}} forEach (uniformItems _target);
			if (backPack _target != "") then
				{
				_unit addBackpack ((backpack _target) call A3A_fnc_basicBackpack);
				{if (!(_x in unlockedMagazines) and !(_x in unlockedItems)) then {_unit addItemToBackpack _x}} forEach backpackItems _target;
				removeBackpack _target;
				};
			_unit addVest (vest _target);
			{if (!(_x in unlockedMagazines) and !(_x in unlockedItems)) then {_unit addItemToVest _x}} forEach vestItems _target;
			_unit action ["rearm",_target];
			removeVest _target;
			if (((headgear _target) in allArmoredHeadgear) and !((headgear _target) in unlockedItems)) then
				{
				_unit addHeadgear (headGear _target);
				removeHeadgear _target;
				};
			{if !(_x in unlockedItems) then {_unit linkItem _x}} forEach assignedItems _target;
			{if !(_x in unlockedItems) then {_target unlinkItem _x}} forEach assignedItems _target;
			};
		_target setVariable ["busy",false];
	};
Takes uniform items, backpack, vest, headgear, and assigned items from dead body if unlocked.

8. Return to Truck and Store:

Sqf

Apply
_unit doMove (getPosATL _truckX);
_timeOut = time + 60;
waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (!alive _truckX) or (_unit distance _truckX < 8) or (_timeOut < time)};
if ((alive _truckX) and ([_unit] call A3A_fnc_canFight)) then
	{
		if (_tempPrimary != "") then
			{
			_unit action ["DropWeapon",_truckX,_tempPrimary];
			sleep 3;
			};
		if (secondaryWeapon _unit != "") then
			{
			_unit action ["DropWeapon",_truckX,secondaryWeapon _unit];
			sleep 3;
			};
		{_truckX addItemCargoGlobal [_x,1]} forEach ((assignedItems _unit) + (vestItems _unit) + (backPackItems _unit) + [headgear _unit,backpack _unit,vest _unit]);
		removeBackpackGlobal _unit;
		removeVest _unit;
		{_unit unlinkItem _x} forEach assignedItems _unit;
		removeAllItemsWithMagazines _unit;
		{_unit removeWeaponGlobal _x} forEach weapons _unit;
		removeHeadgear _unit;
	};
Returns to truck, drops weapons, stores items in truck, clears unit loadout.

9. Next Loot Target:

Sqf

Apply
_target = objNull;
_distanceX = 51;
{
	_objectX = _x;
	if (_unit distance _objectX < _distanceX) then
		{
		if ((count weaponCargo _objectX > 0) and !(_objectX getVariable ["busy",false])) then
			{
			_weaponsX = weaponCargo _objectX;
			for "_i" from 0 to (count _weaponsX - 1) do
				{
				_potential = _weaponsX select _i;
				_basePossible = [_potential] call BIS_fnc_baseWeapon;
				if ((not(_basePossible in unlockedWeapons)) and ((_basePossible in allRifles) or (_basePossible in allSniperRifles) or (_basePossible in allMachineGuns) or (_potential in allMissileLaunchers) or (_potential in allRocketLaunchers))) then
					{
					_target = _objectX;
					_distanceX = _unit distance _objectX;
					_weaponX = _potential;
					};
				};
			};
		};
	} forEach _objectsX;
	};
Finds next weapon, excluding unlocked weapons.

10. Completion:

Sqf

Apply
if (!_continuar) then {
	_unit groupChat localize "STR_chats_autoloot_no_more_weapons";
};
_unit doFollow player;
_unit setVariable ["rearming",false];
_unit setUnitLoadout _originalLoadout;
Returns unit to player group, clears rearming flag, restores original loadout.

Where it leads:

Calls:
A3A_fnc_canFight - Multiple checks
BIS_fnc_baseWeapon - Get base weapon
A3A_fnc_basicBackpack - Convert backpack
Network calls: None
Modified globals: rearming on unit (set/clear)
Dependencies: Requires canFight, basicBackpack functions
Synchronization: No network operations. Local to unit.
System integration: Called by player command or auto-rearm system. Part of looting system that manages equipment and supplies.
Key Technical Details:
120-second timeout for entire process
Busy flags prevent multiple units looting same container
Unlocked items check prevents taking basic gear
Loadout restoration ensures unit can still fight
Truck inventory management for team supplies
fn_autoRearm.sqf
Function Name: A3A_fnc_autoRearm
File: A3A/addons/core/functions/AI/fn_autoRearm.sqf

What it does: AI unit automatically rearms itself from nearby containers, dead bodies, and crates. Finds better weapons, magazines, launchers, NVGs, radios, helmets, vests, backpacks, and FAKs based on needs.

How it does that:

1. Initial Validation:

Sqf

Apply
params ["_unit"];
if (isPlayer _unit) exitWith {};
if !([_unit] call A3A_fnc_canFight) exitWith {};
private _inPlayerGroup = (isPlayer (leader _unit));
if (_unit getVariable ["helping",false]) exitWith {if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_rearm_heal_in_progress"}};
private _rearming = _unit getVariable ["rearming",false];
if (_rearming) exitWith {if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_rearm_in_progress"; _unit setVariable ["rearming",false]}}; // Reset rearming variable
if (vehicle _unit != _unit) exitWith {};
_unit setVariable ["rearming",true];
Validates:

Not player
Can fight
Not helping
Not already rearming
Not in vehicle
Sets rearming flag
2. Check Custom Loadout:

Sqf

Apply
private _unitType = _unit getVariable "unitType";
private _customLoadout = rebelLoadouts get _unitType;
private _loadoutPrimaryWeapon = if (!isNil "_customLoadout") then { (_customLoadout select 0) select 0 } else { "" };
Gets unit's custom loadout if rebel.

3. Find Nearby Containers:

Sqf

Apply
private _nearbyContainers = nearestObjects [_unit, ["ReammoBox_F","LandVehicle","WeaponHolderSimulated","GroundWeaponHolder","WeaponHolder"], _maxDistance];
if (boxX in _nearbyContainers) then {_nearbyContainers = _nearbyContainers - [boxX]};
Finds ammo boxes, vehicles, weapon holders. Excludes boxX (HQ supply box).

4. Better Weapon Search:

Sqf

Apply
private _primaryWeapon = primaryWeapon _unit;
private _primaryWeaponWeight = [[_primaryWeapon, ["PrimaryWeaponsCatchAll", "Weapons"]] call A3A_fnc_itemArrayWeight, 0] select (_primaryWeapon isEqualTo "");
private _validPrimaryWeapons = allRifles + allSniperRifles + allMachineGuns + allSMGs + allShotguns;
private _secondaryWeapon = secondaryWeapon _unit;

if ((!isNil "_customLoadout" && {_primaryWeapon != _loadoutPrimaryWeapon}) || {isNil "_customLoadout"}) then {
	_needsRearm = true;
	if (count _nearbyContainers > 0) then {
		{
			_potentialContainer = _x;
			if (_unit distance _potentialContainer < _maxDistance) then {
				if ((count weaponCargo _potentialContainer > 0) && !(_potentialContainer getVariable ["busy",false])) then {
					_containerWeapons = weaponCargo _potentialContainer;
					for "_i" from 0 to (count _containerWeapons - 1) do {
						_potentialWeapon = _containerWeapons select _i;
						_potentialWeaponWeight = [_potentialWeapon, ["PrimaryWeaponsCatchAll", "Weapons"]] call A3A_fnc_itemArrayWeight;
						_baseWeapon = [_potentialWeapon] call BIS_fnc_baseWeapon;
						if (!(_baseWeapon in ["hgun_PDW2000_F","hgun_Pistol_01_F","hgun_ACPC2_F"]) && (_baseWeapon in _validPrimaryWeapons) && (_potentialWeaponWeight > _primaryWeaponWeight)) then {
							_selectedContainer = _potentialContainer;
							_foundItem = true;
							_selectedWeapon = _potentialWeapon;
							};
						};
					};
				};
		} forEach _nearbyContainers;
	};
	...
};
Searches for better weapons (higher weight) than current. Excludes specific pistols.

5. Take Better Weapon:

Sqf

Apply
if ((_foundItem) && (_unit getVariable "rearming")) then {
	_unit stop false;
	if (!((alive _selectedContainer) || (_selectedContainer isKindOf "ReammoBox_F"))) then {_selectedContainer setVariable ["busy",true]};
	_unit doMove (getPosATL _selectedContainer);
	if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_better_weapon"};
	_timeOut = time + 60;
	waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) || (isNull _selectedContainer) || (_unit distance _selectedContainer < 3) || (_timeOut < time) || (unitReady _unit)};
	if ((unitReady _unit) && ([_unit] call A3A_fnc_canFight) && (_unit distance _selectedContainer > 3) && (_selectedContainer isKindOf "ReammoBox_F") && (!isNull _selectedContainer)) then {_unit setPos position _selectedContainer};
	if (_unit distance _selectedContainer < 3) then {
		_unit action ["TakeWeapon",_selectedContainer,_selectedWeapon];
		sleep 5;
		if (primaryWeapon _unit isEqualTo _selectedWeapon) then {
			if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_better_weapon_confirm"};
			if (_selectedContainer isKindOf "ReammoBox_F") then {_unit action ["rearm",_selectedContainer]};
		};
	};
	_selectedContainer setVariable ["busy",false];
};
Moves to container, takes weapon, rearms if needed.

6. Magazine Check:

Sqf

Apply
_foundItem = false;
_targetMagazines = 4;
if (_primaryWeapon in allMachineGuns) then {_targetMagazines = 2};
_primaryMagazines = getArray (configFile / "CfgWeapons" / _primaryWeapon / "magazines");
if ({_x in _primaryMagazines} count (magazines _unit) < _targetMagazines) then {
	_needsRearm = true;
	_foundItem = false;
	// Search containers for magazines
	// Search dead bodies for magazines
	...
};
Checks magazine count. Needs 4 magazines for normal weapons, 2 for MGs.

7. Magazine Acquisition:

Sqf

Apply
if ((_foundItem) && (_unit getVariable "rearming")) then {
	_unit stop false;
	if (!((alive _selectedContainer) || (_selectedContainer isKindOf "ReammoBox_F"))) then {_selectedContainer setVariable ["busy",true]};
	_unit doMove (getPosATL _selectedContainer);
	...
	if (_unit distance _selectedContainer < 3) then {
		_unit action ["rearm",_selectedContainer];
		if ({_x in _primaryMagazines} count (magazines _unit) >= _targetMagazines) then {
			if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_rearming_confirm"};
		} else {
			if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_rearming_confirm_partially"};
		};
	};
	_selectedContainer setVariable ["busy",false"];
};
Rearms from container, gives partial confirmation.

8. Secondary Weapon (Launcher):

Sqf

Apply
_foundItem = false;
if ((_secondaryWeapon == "") && (loadAbs _unit < 340)) then {
	// Search for missile/rocket launchers
	...
	if ((_foundItem) && (_unit getVariable "rearming")) then {
		...
		_unit action ["TakeWeapon",_selectedContainer,_selectedWeapon];
		sleep 3;
		if (secondaryWeapon _unit == _selectedWeapon) then {
			if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_secondary_weapon_confirm"};
			if (_selectedContainer isKindOf "ReammoBox_F") then {sleep 3;_unit action ["rearm",_selectedContainer]};
		};
		...
	};
};
Finds launcher if no launcher and weight under 340.

9. Launcher Magazines:

Sqf

Apply
if (_secondaryWeapon != "") then {
	_primaryMagazines = getArray (configFile / "CfgWeapons" / _secondaryWeapon / "magazines");
	if ({_x in _primaryMagazines} count (magazines _unit) < 2) then {
		_needsRearm = true;
		// Search for magazines
		...
	};
};
Checks launcher needs 2 magazines.

10. Radio, NVGs, Helmet, Vests, Backpack, FAKs:

Sqf

Apply
// Radio check and acquire
// NVGs check and acquire
// Helmet check and acquire (armored)
// Vests check and acquire (armor comparison)
// Backpack check and acquire
// FAKs check and acquire (medics need 10, others 1)
Sequential checks for equipment, each with similar search and acquisition logic.

11. Completion:

Sqf

Apply
_unit doFollow (leader _unit);
if (!_needsRearm) then {if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_rearm_no_need"}} else {if (_inPlayerGroup) then {_unit groupChat localize "STR_chats_autoloot_rearm_done"}};
_unit setVariable ["rearming",false];
Returns to group, gives feedback, clears rearming flag.

Where it leads:

Calls:
A3A_fnc_canFight - Multiple checks
BIS_fnc_baseWeapon - Get base weapon
A3A_fnc_itemArrayWeight - Get weapon weight
A3A_fnc_getRadio - Get radio from unit
A3A_fnc_hasARadio - Check if unit has radio
Network calls: None
Modified globals: rearming on unit
Dependencies: Requires canFight, itemArrayWeight, getRadio, hasARadio
Synchronization: No network operations. Busy flags prevent conflicts.
System integration: Called by auto-rearm system or player command. Manages AI equipment and supplies.
Key Technical Details:
Comprehensive equipment check sequence
Weight-based weapon comparison
Busy flags for container synchronization
Load-based equipment limits (340 weight for launchers)
Partial rearm feedback
Unlocked item exclusion
fn_callForSupport.sqf
Function Name: A3A_fnc_callForSupport
File: A3A/addons/core/functions/AI/fn_callForSupport.sqf

What it does: Simulates squad leader calling for support by temporarily reducing his skill (simulating radio use), then requests appropriate support based on target and reveal value.

How it does that:

1. Parameter Validation:

Sqf

Apply
params ["_group", "_target"];
private _side = side _group;
Receives group and target to support against.

2. Faction Defeat Check:

Sqf

Apply
if ((_side isEqualTo Occupants && areOccupantsDefeated) || {(_side isEqualTo Invaders && areInvadersDefeated)}) exitWith {
    Info_1("%1 faction had been defeated earlier, aborting calling support.", _side);
};
Exits if faction already defeated.

3. Side Validation:

Sqf

Apply
if(_side != Occupants && {_side != Invaders}) exitWith {
    Error_2("Non-enemy group %1 of side %2 managed to call callForSupport", _group, _side);
};
Only occupants and invaders can call this.

4. Leader and Rival Check:

Sqf

Apply
private _groupLeader = leader _group;
private _isRival = _groupLeader getVariable ["isRival", false];
if (_isRival) then {
    Error("Rivals are not using general supports, aborting.");
};
Rivals use different support system.

5. Leader State Check:

Sqf

Apply
if !(_groupLeader call A3A_fnc_canFight) exitWith {};
Leader must be able to fight.

6. Cooldown Check:

Sqf

Apply
if((_group getVariable ["A3A_canCallSupportAt", -1]) > time) exitWith {};
Exits if cooldown active.

7. Set Cooldown and Simulate Radio:

Sqf

Apply
private _timeToCallSupport = (10 + random 5) / A3A_balancePlayerScale;
_group setVariable ["A3A_canCallSupportAt", time + 15*_timeToCallSupport];

ServerDebug_4("Leader of %1 (side %2) is starting to request support against %3 (type %4)", _group, _side, _target, typeof _target);

//Lower skill of group leader to simulate radio communication
private _oldSkill = skill _groupLeader;
private _oldCourage = _groupLeader skill "courage";
_groupLeader setSkill (_oldSkill - 0.2);
Calculates call time (10-15s) scaled by player count. Sets cooldown. Lowers leader skill by 0.2.

8. Wait for Radio Call:

Sqf

Apply
sleep _timeToCallSupport;

//Reset leader skill
_groupLeader setSkill _oldSkill;
_groupLeader setskill ["courage", _oldCourage];
_groupLeader setskill ["commanding", _oldCourage];
Sleeps while radio is "used". Resets skills.

9. Check Leader Survival:

Sqf

Apply
if(_groupLeader call A3A_fnc_canFight) then
{
    private _revealed = [getPosATL _groupLeader, side _group] call A3A_fnc_calculateSupportCallReveal;
    ServerDebug_2("%1 managed to request support, reveal value is %2", _group, _revealed);
    [_side, _target, getPosATL _groupLeader, _group knowsAbout _target, _revealed] remoteExec ["A3A_fnc_requestSupport", 2];
}
else
{
    ServerDebug_1("%1 failed to request support as the leader is dead or down", _group);
    _group setVariable ["A3A_canCallSupportAt", nil];
};
If leader survives, calculates reveal value and requests support on server. Otherwise resets cooldown.

Where it leads:

Calls:
A3A_fnc_canFight - Check leader state
A3A_fnc_calculateSupportCallReveal - Calculate reveal
A3A_fnc_requestSupport - Remote to server
Network calls: remoteExec to A3A_fnc_requestSupport on server (side 2)
Modified globals:
A3A_canCallSupportAt on group (set/clear)
Leader skills (temporary)
Dependencies: Requires canFight, calculateSupportCallReveal, requestSupport
Synchronization: Remote execution for support request. Skill changes are local.
System integration: Called by AIreactOnKill when group needs support. Part of AI support system.
Key Technical Details:
Skill reduction simulates radio use
15x cooldown on call time prevents spam
Reveal value affects support effectiveness
Leader death cancels support
fn_callForSupportInfantry.sqf
Function Name: A3A_fnc_callForSupportInfantry
File: A3A/addons/core/functions/AI/fn_callForSupportInfantry.sqf

What it does: Simulates radioman calling for support with animations and sounds. Similar to leader call but uses specific radioman unit with immersive animations.

How it does that:

1. Find Radioman:

Sqf

Apply
private _radiomanIndex = (units _group) findIf {(_x getVariable "unitType") in (FactionGet(all,"Radiomen"))};
if (_radiomanIndex isEqualTo -1) exitWith {
    Info_1("%1 Group has no capabilities to call support, no radiomen in squad, aborting.", str _group);
};
private _radioMan = (units _group) select _radiomanIndex;
Finds radioman in group based on unitType in radiomen faction list.

2. Validate Radioman:

Sqf

Apply
if !(_radioMan call A3A_fnc_canFight) exitWith {};
if((_group getVariable ["A3A_canCallSupportAt", -1]) > time) exitWith {};
Checks radioman can fight and cooldown.

3. Setup Radio Call:

Sqf

Apply
private _timeToCallSupport = (15 + random 15) / A3A_balancePlayerScale;
_group setVariable ["A3A_canCallSupportAt", time + 15*_timeToCallSupport];

{_radioMan disableAI _x} forEach ["ANIM","AUTOTARGET","FSM","MOVE","TARGET"];
_radioMan setVariable ["callAnimsDone",false];
_radioMan setVariable ["timeToCall",_timeToCallSupport];
_radioMan setVariable ["callSuccess",false];
_radioMan playMoveNow "Acts_SupportTeam_Front_ToKneelLoop";
Disables AI, sets variables, plays kneel animation.

4. Play Sounds:

Sqf

Apply
_radioMan spawn {
    sleep random 3;
    playSound3D [(selectRandom radioSoundsIn), _this, false, getPosASL _this, 3, 1, 30];
};
Plays random radio sound 3D at radioman position.

5. Animation Loop:

Sqf

Apply
_radioMan addEventHandler ["AnimDone", {
    params ["_supportCaller"];
    if (([_supportCaller] call A3A_fnc_canFight) && {(time <= (_supportCaller getVariable ["timeToCall",time])) && {_supportCaller == vehicle _supportCaller}}) then {
        _supportCaller spawn {
            sleep random 3;
            playSound3D [(selectRandom radioSoundsMid), _this, false, getPosASL _this, 3, 1, 30];
        };
        _supportCaller playMoveNow "Acts_SupportTeam_Front_KneelLoop";
    } else {
        _supportCaller removeEventHandler ["AnimDone",_thisEventHandler];
        _supportCaller setVariable ["callAnimsDone",true];
        if (([_supportCaller] call A3A_fnc_canFight) && {_supportCaller == vehicle _supportCaller}) then {
            _supportCaller playMoveNow "Acts_SupportTeam_Front_FromKneelLoop";
            _supportCaller spawn {
                sleep random 3;
                playSound3D [(selectRandom radioSoundsOut), _this, false, getPosASL _this, 3, 1, 30];
            };
            _supportCaller setVariable ["callSuccess",true];
        };
    };
}];
On animation done:

If still calling, play mid sound and loop kneel
If done, play outro sound, set success flag
6. Wait for Completion:

Sqf

Apply
waitUntil {sleep 0.5; (_radioMan getVariable ["callAnimsDone",true])};
_radioMan setVariable ["radioAnimsDone",nil];
_radioMan setVariable ["timeToCall", nil];
{_radioMan enableAI _x} forEach ["ANIM","AUTOTARGET","FSM","MOVE","TARGET"];
Waits for animation completion, re-enables AI.

7. Request Support:

Sqf

Apply
if(_radioMan getVariable ["callSuccess",true]) then {
    private _revealed = [getPosATL _radioMan, side _group] call A3A_fnc_calculateSupportCallReveal;
    ServerDebug_2("%1 managed to request support, reveal value is %2", _group, _revealed);
    [_side, _target, getPosATL _radioMan, _group knowsAbout _target, _revealed] remoteExec ["A3A_fnc_requestSupport", 2];
} else {
    ServerDebug_1("%1 failed to request support as the leader is dead or down", _group);
    _group setVariable ["A3A_canCallSupportAt", nil];
};
If successful, request support. Otherwise reset cooldown.

Where it leads:

Calls:
A3A_fnc_canFight - Check radioman state
A3A_fnc_calculateSupportCallReveal - Calculate reveal
A3A_fnc_requestSupport - Remote to server
Network calls: remoteExec to A3A_fnc_requestSupport on server (side 2)
Modified globals:
A3A_canCallSupportAt on group
Multiple temporary variables on radioman
Dependencies: Same as callForSupport
Synchronization: Event handler for animation. 3D sounds.
System integration: Alternative to callForSupport for groups with radiomen. Called by AIreactOnKill.
Key Technical Details:
Animation-based call with sound effects
Random timing for sounds
Success/failure based on radioman survival
Re-enables AI after completion
fn_canConquer.sqf
Function Name: A3A_fnc_canConquer
File: A3A/addons/core/functions/AI/fn_canConquer.sqf

What it does: Determines if a unit can conquer a marker (capture territory). Checks if unit can fight, isn't in air vehicle, and is within 1.5x marker size of marker position.

How it does that:

1. Check Unit State:

Sqf

Apply
params ["_unit", "_markerX"];
if !([_unit] call A3A_fnc_canFight) exitWith {false};
if (vehicle _unit isKindOf "Air") exitWith {false};
Checks unit can fight and isn't in air vehicle.

2. Distance Check:

Sqf

Apply
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _positionX = getMarkerPos _markerX;
if (_unit distance2D _positionX > (_size * 1.5)) exitWith {false};
Gets marker size and position. Checks if unit is within 1.5x size distance.

3. Return True:

Sqf

Apply
true
Returns true if all checks pass.

Where it leads:

Calls:
A3A_fnc_canFight - Check unit state
A3A_fnc_sizeMarker - Get marker size
Network calls: None
Modified globals: None
Dependencies: Requires canFight, sizeMarker
Synchronization: No network operations.
System integration: Used by conquest system to check if unit can capture markers.
Key Technical Details:
Simple boolean check
1.5x distance multiplier for capture radius
fn_canFight.sqf
Function Name: A3A_fnc_canFight
File: A3A/addons/core/functions/AI/fn_canFight.sqf

What it does: Simple boolean check if a unit can fight. Checks alive, not captive, not incapacitated, not surrendered.

How it does that:

1. State Checks:

Sqf

Apply
params ["_unit"];
if (!alive _unit) exitWith {false};         // also works as a null check
if (captive _unit) exitWith {false};
if (_unit getVariable ["incapacitated",false]) exitWith {false};
if (_unit getVariable ["surrendered",false]) exitWith {false};
true
Checks:

Alive (also null-safe)
Not captive (surrendered to enemy)
Not incapacitated (downed/unconscious)
Not surrendered (gave up)
Where it leads:

Calls: None
Network calls: None
Modified globals: None
Dependencies: None
Synchronization: No network operations.
System integration: Fundamental state check used throughout AI system.
Key Technical Details:
Null-safe (alive null = false)
Uses unit variables for incapacitated/surrendered states
fn_captureX.sqf
Function Name: A3A_fnc_captureX
File: A3A/addons/core/functions/AI/fn_captureX.sqf

What it does: Handles capturing AI units (recruit or release). Manages player recruitment, AI surrender, and group management.

How it does that:

1. Parameter Parsing:

Sqf

Apply
params ["_unit", "_playerX", "_recruiting", "_recruitToSquad"];
Receives unit, player, recruitment flag, and squad join flag.

2. Remove Action:

Sqf

Apply
[_unit,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
Removes capture action remotely.

3. State Check:

Sqf

Apply
if (!alive _unit) exitWith {};
private _sideX = side (group _unit);
private _interrogated = _unit getVariable ["interrogated", false];
Checks unit alive, gets side, checks if interrogated.

4. Recruitment Logic:

Sqf

Apply
if (_recruiting) then {
	_playerX globalChat localize "STR_recruit_text";
	private _chance = switch (true) do {
		case ("militia" isEqualTo _unitPrefix): { 60; };
		case (_sideX == Occupants): { 40; };
		case (_sideX == Invaders): { 20; };
		default { 0; };
	};
	if (_interrogated) then { _chance = _chance / 2 };
	if (random 100 < _chance) then
	{
		if (_recruitToSquad && {count units _playerX < 10}) then {
			_joinPlyGroup = true;
		};
		_modAggro = [1, 30];
		_response = localize "STR_recruit_success_text";
		_modHR = true;
		_fleeSide = teamPlayer;
	}
	else
    {
		_response =  localize "STR_recruit_fail_text";
		_modAggro = [0, 0];
	};
}
else {
	// Release logic
	...
	_modAggro = [-3, 30];
	[player, _sideX] call SCRT_fnc_common_givePrisonerReleasePaycheck;
	[5,player] call A3A_fnc_addScorePlayer;
};
Calculates recruitment chance based on unit type and faction (militia 60%, occupants 40%, invaders 20%). Halves if interrogated. Handles success/failure. For release, gives payoff and score.

5. Communication:

Sqf

Apply
sleep 2;
_unit globalChat _response;
Unit responds after 2 seconds.

6. Handle Recruitment Success:

Sqf

Apply
if (_joinPlyGroup) then {
	// Preserve identity
	private _nameUnit = (name _unit) splitString " ";
	private _identityUnit = createHashMapFromArray [
		["face", face _unit],
		["speaker", _unit getVariable "A3U_PoW_speaker"],
		["firstName", _nameUnit select 0],
		["lastName", _nameUnit select 1]
	];
	private _uniformUnit = uniform _unit;
	private _posUnit = position _unit;
	deleteVehicle _unit;

	private _recruit = [group player, "loadouts_reb_militia_Unarmed", _posUnit, [], 0, "NONE", _identityUnit] call A3A_fnc_createUnit;
	[_recruit, true] spawn A3A_fnc_FIAinit;
	_recruit setUnitLoadout [ [], [], [], [_uniformUnit, []], [], [], "", "", [], ["","","","","",""] ];
	_recruit disableAI "AUTOCOMBAT";
	sleep 1;
	_recruit setVariable ["unitType", "loadouts_reb_militia_Rifleman", true];
}
Creates new unit preserving identity (face, speaker, name) and uniform. Disables autocombat, sets unitType for garrison/dismiss.

7. Handle Release:

Sqf

Apply
else {
	[_unit, _fleeSide] remoteExec ["A3A_fnc_fleeToSide", _unit];
	private _group = group _unit;
	sleep 100;
	if (alive _unit && {!(_unit getVariable ["incapacitated", false])}) then
	{
		([_sideX] + _modAggro) remoteExec ["A3A_fnc_addAggression",2];
		if (_modHR) then { [1,0] remoteExec ["A3A_fnc_resourcesFIA",2] };
	};
	deleteVehicle _unit;
	deleteGroup _group;
};
Sends unit to flee side, waits 100 seconds, applies aggression/resource changes, deletes unit and group.

Where it leads:

Calls:
A3A_fnc_flagaction - Remote remove action
SCRT_fnc_common_givePrisonerReleasePaycheck - Give payment
A3A_fnc_addScorePlayer - Add score
A3A_fnc_createUnit - Create new recruit
A3A_fnc_FIAinit - Initialize recruit
A3A_fnc_fleeToSide - Remote flee
A3A_fnc_addAggression - Remote aggression
A3A_fnc_resourcesFIA - Remote resources
Network calls: Multiple remoteExec calls for effects
Modified globals: None
Dependencies: Multiple functions
Synchronization: Remote executions for game state changes.
System integration: Part of prisoner/recruit system. Called by player interaction.
Key Technical Details:
HashMap for identity preservation
Multiple remoteExec for game effects
100-second delay for consequences
Team size check for squad joining
UnitType variable for garrison system
fn_chargeWithSmoke.sqf
Function Name: A3A_fnc_chargeWithSmoke
File: A3A/addons/core/functions/AI/fn_chargeWithSmoke.sqf

What it does: Orders unit to throw smoke grenade at enemy position to provide cover during charge. Checks smoke availability, line of sight, and distance.

How it does that:

1. Parameter Validation:

Sqf

Apply
params ["_unit", "_helped", "_enemy"];
if !(_unit call A3A_fnc_canFight) exitWith {false};
if (vehicle _unit != _unit) exitWith {false};
Checks unit can fight and isn't in vehicle.

2. Smoke Cooldown:

Sqf

Apply
if (time < _unit getVariable ["smokeUsed",time - 1]) exitWith {false};
_unit setVariable ["smokeUsed",time + 60];
Checks if smoke used in last 60 seconds. Sets cooldown.

3. Find Smoke Magazines:

Sqf

Apply
private _smokeMags = magazines _unit select { _x in A3A_smokeMuzzleHM };
if (isNil "_enemy") then { _enemy = _unit findNearestEnemy _unit };
Gets smoke magazines from unit's inventory. Finds nearest enemy if not provided.

4. Line of Sight and Distance Check:

Sqf

Apply
if (!isNull _enemy and {_enemy distance _unit > random 75}) then
{
    if (behaviour _unit == "COMBAT" or isPlayer _helped or {([objNull, "VIEW"] checkVisibility [eyePos _enemy, eyePos _helped]) > 0}) then
    {
        _muzzle = A3A_smokeMuzzleHM get selectRandom _smokeMags;
        _unit disableAI "PATH";
        _unit doWatch getPosATL _enemy;
        _unit doTarget _enemy;
        sleep (abs (_unit getRelDir _enemy) / 90);
        _unit disableAI "MOVE";
        _unit setDir ((_unit getDir _enemy) - 10 + random 20);
        _unit forceWeaponFire [_muzzle,_muzzle];
        sleep 1;
        _unit enableAI "MOVE";
        _unit enableAI "PATH";
        _unit doWatch objNull;
        _unit doFollow (leader _unit);
        _return = true;
    };
};
Checks enemy >75m away (random) and either:

Unit in combat
Helped is player
Line of sight exists
Then:

Disables PATH AI
Targets enemy
Sleeps for rotation time
Disables MOVE AI
Aims with slight random offset
Fires smoke
Re-enables AI
Returns to group
5. Return Result:

Sqf

Apply
_return
Returns true if smoke thrown, false otherwise.

Where it leads:

Calls:
A3A_fnc_canFight - Check unit state
Network calls: None
Modified globals: smokeUsed on unit (cooldown)
Dependencies: Requires canFight
Synchronization: No network operations.
System integration: Called by combat tactics when needing smoke cover.
Key Technical Details:
60-second smoke cooldown
Random distance check (75m+)
Line of sight validation
AI state management for animation control
Random aim offset (±10°)

Function Name: fn_combatLanding.sqf
What it does: This function manages a helicopter performing a combat landing, unloading its cargo group, and either transitioning to an attack role or returning to base. It is designed for high-risk insertion scenarios, utilizing a custom bezier curve landing path to avoid obstacles and calculate a safe approach.

How it does that:

Parameter Validation & Initialization: The function accepts the helicopter object, crew group, cargo group, destination for troops, origin/base position, and the specific landing position.

Sqf

Apply
params ["_helicopter", "_crewGroup", "_cargoGroup", "_posDestination", "_originPos", "_landPos"];
private _vehType = typeOf _helicopter;
Fastrope Fallback Logic: It checks if the landing zone has obstacles (trees/buildings) taller than 2 meters within a radius of the helicopter's size. If obstacles are detected, it aborts the landing and switches to A3A_fnc_fastrope.

Sqf

Apply
private _forceFastrope = false;
if (_vehType in vehFastRope) then {
    {
        if ((visiblePosition _x) select 2 > 2) exitWith { _forceFastrope = true };
    } forEach (nearestTerrainObjects [_landPos, [], (sizeof _vehType)]);
};
if (_forceFastrope) exitWith {
    // ... logs error and spawns fastrope
};
Combat Preparations: It enables radar for attack/transport aircraft. It attaches the current script handle to both groups (A3A_AIScriptHandle) to prevent conflicting AI scripts (like RTB instructions) from interfering during the unloading process. It creates a landing pad helper object at the target position to serve as the precise landing coordinate.

Sqf

Apply
_helicopter setVehicleRadar 1;
_crewGroup setVariable ["A3A_AIScriptHandle", _thisScript];
_cargoGroup setVariable ["A3A_AIScriptHandle", _thisScript];
private _landPad = createVehicle [_helipadClass, _landPos, [], 0, "NONE"];
Initial Approach & Flare Deployment: The crew group is given a waypoint to the landing area. The helicopter climbs to a mid-height (100m or 150m based on climate). As it approaches (within 800m and then 675m), it fires flares (CMFlareLauncher variants) to mask the landing from ground threats.

Sqf

Apply
private _midHeight = [100, 150] select (A3A_climate isEqualTo "tropical");
_helicopter flyInHeight _midHeight;
waitUntil {sleep 1; (_helicopter distance2D _landPos) < 800};
while {_helicopter distance2D _landPos > 675} do {
    [_helicopter, "CMFlareLauncher"] call BIS_fnc_fire;
    // ... more flare calls
    sleep 0.3;
};
Bezier Curve Landing Path Calculation: The function calculates a smooth landing path using vector math. It determines start, mid, and end positions in ASL (Above Sea Level). It calculates the initial velocity and estimates the total landing time. It defines the maximum descent angle based on speed.

Sqf

Apply
private _endPos = getPosASL _landPad;
private _startPos = getPosASL _helicopter;
private _midPos = _endPos vectorAdd [0,0,_midHeight];
private _initialVelocity = (velocity _helicopter);
private _landingTime = (_startPos distance _midPos)/_initialVelocity * 1.35;
private _maxAngle = ((_initialVelocity * _initialVelocity/3600) * 35) min 35;
Execution of Custom Landing: A loop runs until the interval reaches 1. It iteratively updates the helicopter's position and velocity transformation to follow the calculated curve. It calculates an angle target based on sine of the interval to create a swooping descent. It forces landing gear down and applies the transformation every 0.001 seconds.

Sqf

Apply
while {_interval < 0.9999} do {
    // ... angle calculations (sin/cos logic)
    _helicopter action ["LandGear", _helicopter];
    _helicopter setVelocityTransformation [ _lineStart, _lineEnd, ... ];
    sleep 0.001;
    _interval = _interval + (((time - _time)/_landingTime) * (1 - (_interval / 2)));
};
Unloading: Once the landing loop finishes, the engine stays on, doors are opened via A3A_fnc_HeliDoors, and the cargo group is forced out. If a unit is stuck in the vehicle, Eject action is triggered. The group is unassigned from the vehicle.

Sqf

Apply
[_helicopter, "open"] spawn A3A_fnc_HeliDoors;
_cargoGroup leaveVehicle _helicopter;
{ if ((vehicle _x) isEqualTo _helicopter) then { _x action ["Eject", _helicopter]; }; unassignVehicle _x; } forEach units _cargoGroup;
Post-Landing Logic (Attack vs. RTB): The function waits until the cargo group is fully out. It then checks the helicopter type and armament.

Attack Mode: If the helicopter is an attack type or a transport with heavy weapons, it retracts gear and calls A3A_fnc_attackHeli to engage targets.
RTB Mode: If unarmed/transport, it creates a waypoint back to the originPos with a deleteVehicle statement, fires more flares during egress, and retracts gear.
Sqf

Apply
if (_vehType in FactionGet(all,"vehiclesHelisAttack") + ... || {_weapons > 2 ...}) exitWith {
    _helicopter action ["LandGearUp", _helicopter];
    [_helicopter, _crewGroup, _posDestination] spawn A3A_fnc_attackHeli;
};
// RTB
private _vehWP1 = _crewGroup addWaypoint [_originPos, 0];
_vehWP1 setWaypointStatements ["true", "if (local this and alive this) then { deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList }"];
Where it leads:

Calls:
A3A_fnc_fastrope: If terrain is obstructed.
BIS_fnc_fire: To fire flares.
A3A_fnc_smokeCoverAuto: Deploys smoke at landing site.
A3A_fnc_HeliDoors: Opens/closes helicopter doors.
A3A_fnc_attackDrillAI: Initializes AI combat behavior for the disembarked cargo group.
A3A_fnc_attackHeli: Handover to attack script if the helicopter has weapons.
Dependencies: Requires vehFastRope global variable and FactionGet system. Depends on A3A_climate for landing height.
Global State: Modifies A3A_AIScriptHandle on _crewGroup and _cargoGroup. Creates a landing pad vehicle (_landPad).
Network: Executed on Server or HC (Headless Client). Uses remoteExec inside A3A_fnc_fastrope.
Function Name: fn_coverage.sqf
What it does: Identifies a suitable cover position for a unit relative to an enemy. It scans for nearby objects (buildings, rocks, vehicles) that provide adequate concealment (width > 2m, height > 2m) and returns a position behind that object relative to the enemy.

How it does that:

Parameter Extraction: Takes the unit seeking cover and the enemy position.

Sqf

Apply
params ["_unit", "_enemyX"];
private _posBehind = (position _unit) getPos [5,_enemyX getDir _unit];
Object Scanning: It looks for objects within 30 meters of a position 5 meters behind the unit (to find cover in the direction away from the enemy). It filters out objects already marked as usedForCover by the unit's group to prevent multiple units crowding the same spot. It also filters out roads (likely to avoid hiding behind small curbs).

Sqf

Apply
private _objectsX = (nearestObjects [_posBehind, [], 30]) select {!(_x in (_groupX getVariable ["usedForCover",[]]))};
private _roads = _posBehind nearRoads 30;
Object Filtering & Classification: It iterates through potential objects, excluding "fake" objects (particles, flies, markers) and invalid classes (animals, bullets). It checks if the object is not an enemy or friendly. It calculates the bounding box of the object.

Classification: It separates objects into _big (empty type) and _small (specific types) based on dimensions. Only objects wider than 2m, thick than 0.5m, and taller than 2m are considered viable.
Sqf

Apply
private _ancho = abs ((_p2 select 0) - (_p1 select 0));
private _grueso = abs ((_p2 select 1) - (_p1 select 1));
private _alto = abs ((_p2 select 2) - (_p1 select 2));
if (_ancho > 2 && _grueso > 0.5 && _alto > 2) then { ... pushback ... };
Selection & Logic Flow:

If no cover is found, it returns an empty array.
It prioritizes _big objects over _small ones.
It selects the nearest object to the unit using BIS_fnc_nearestPosition.
Sqf

Apply
if ((count _big == 0) and (count _small == 0)) exitWith {[]};
if !(_big isEqualTo []) then {_objectX = [_big,_unit] call BIS_fnc_nearestPosition} else {_objectX = [_small,_unit] call BIS_fnc_nearestPosition};
Marking and Output:

If the selected object is not a House, it is added to the group's usedForCover array.
A scheduled script spawns to remove the object from the list after 60 seconds (preventing permanent locking of a cover spot).
Final Position: It calculates a position 2 meters past the object relative to the enemy (hiding behind the object).
Sqf

Apply
_groupX setVariable ["usedForCover",_arr];
[_objectX,_groupX] spawn { sleep 60; ... remove from array ... };
private _pos = _posEnemy getPos [(_objectX distance _posEnemy) + 2, _posEnemy getDir _objectX];
Where it leads:

Calls:
BIS_fnc_nearestPosition: To find the closest cover object.
Dependencies: Used by AI scripts (unitGetToCover usually) that require environmental protection.
Global State: Modifies usedForCover variable on the group (temporary).
Network: Local execution only.
Function Name: fn_destroyBuilding.sqf
What it does: An engineer unit plants a Satchel Charge on a building and detonates it after a timeout, provided the area is safe (no friendlies nearby). This is used for assault breaching.

How it does that:

Setup & Disable AI: The function sets maneuvering flags and disables the unit's AI targeting, suppression, and cover behaviors to prevent the AI from overriding the movement command. It stops the unit and orders it to move to the building.

Sqf

Apply
_engineerX setVariable ["maneuvering",true];
_engineerX disableAI "TARGET";
_engineerX disableAI "AUTOTARGET";
doStop _engineerX;
_engineerX doMove (getPos _building);
Movement Validation: A loop waits until the unit is within 3m of the building or visually has line of sight to it (using lineIntersectsObjs). It also checks if the unit canFight.

Sqf

Apply
while {true} do {
    if !([_engineerX] call A3A_fnc_canFight) exitWith {};
    _arrayObjs = lineIntersectsObjs [(eyePos _engineerX),(_engineerX modelToWorld [0,3,0]),objNull,_engineerX,false,32];
    if (_building in _arrayObjs) exitWith {};
    sleep 1;
};
Error Recovery (Abort): If the unit stops being able to fight (dies/incapacitated) before planting, the AI is re-enabled, the unit is recalled, and the assaulted variable on the building is reset.

Sqf

Apply
if !([_engineerX] call A3A_fnc_canFight) exitWith {
    _engineerX enableAI "TARGET";
    // ... re-enable all AI ...
    _engineerX call A3A_fnc_recallGroup;
    _building setVariable ["assaulted",false];
};
Planting Charge: The unit plays the "PutDown" animation. A SatchelCharge_Remote_Ammo is created at the unit's position. The required magazine (Satchel Charge) is removed from the unit's inventory.

Sqf

Apply
_engineerX playActionNow "PutDown";
private _mineX = "SatchelCharge_Remote_Ammo" createVehicle (getposATL _engineerX);
private _mag = (magazines _engineerX select {(_x call BIS_fnc_itemType) select 0 == "Mine"}) select 0;
_engineerX removeMagazineGlobal _mag;
Safety Check & Detonation: The engineer moves back to the leader or is recalled. A 60-second timer starts. The function waits until:

No friendlies (side _x == _side) are within 20m of the building.
OR the timer expires.
OR the engineer dies.
If the timer hasn't expired (meaning friendlies are safe), the charge is detonated (setDamage 1).
Sqf

Apply
private _timeOut = time + 60;
waitUntil {sleep 5; ({(side _x == _side) and (_x distance _building < 20)} count allUnits == 0) or (time > _timeOut) or !(alive _engineerX)};
if (time <= _timeOut) then {_mineX setDamage 1};
Cleanup: Re-enables all AI behaviors and recalls the unit.

Sqf

Apply
_engineerX enableAI "TARGET";
_engineerX call A3A_fnc_recallGroup;
Where it leads:

Calls:
A3A_fnc_canFight: Checks unit status.
A3A_fnc_recallGroup: Returns unit to squad formation.
Dependencies: Requires the unit to have a Satchel Charge magazine.
Global State: Modifies maneuvering and assaulted variables.
Network: Local execution.
Function Name: fn_doFlank.sqf
What it does: Orders a group of units to flank a target (_nearX). It splits the group into two sub-groups, sending them to positions 45 degrees left and right of the target direction. After reaching the flanking position or if the target is dead, it recalls the units.

How it does that:

Coordinate Calculation: Uses the group leader to calculate the bearing (_ang) and distance to the target. It adds 45 and subtracts 45 degrees to create two flanking waypoints (_pos1, _pos2) at 1.3x the distance to ensure they pass the target.

Sqf

Apply
private _ang = _LeaderX getDir _nearX;
private _dist = (_LeaderX distance _nearX) * 1.3;
private _pos1 = _LeaderX getPos [_dist,_ang + 45];
private _pos2 = _LeaderX getPos [_dist,_ang - 45];
Unit Assignment & Movement: Iterates through all units in the list. It alternates the target position based on the index (floor (_forEachIndex/2)). Sets the maneuvering variable and issues the doMove command.

Sqf

Apply
private _pos = if (floor (_forEachIndex/2) == (_forEachIndex / 2)) then {_pos1} else {_pos2};
_x doMove _pos;
Tracking & Dynamic Re-routing: For each unit, a separate script is spawned to monitor progress.

If the unit gets very close to the flank point (distance < 3m) and the target is still alive, it switches the unit's move command directly to the target's position (closing in for the kill).
It stops if the target or the unit dies.
Sqf

Apply
[_x,_nearX,_pos] spawn {
    params ["_unit", "_nearX", "_pos"];
    // ...
    if (_unit distance _pos < 3) then {_unit doMove (position _nearX)};
};
Group Recall: The main thread waits for a timeout (60s) or until the target canFight returns false. Once the flanking maneuver is effectively over, it calls A3A_fnc_recallGroup on all units to return them to normal behavior.

Sqf

Apply
waitUntil {sleep 5; !([_nearX] call A3A_fnc_canFight) or (time > _timeOut)};
{_x call A3A_fnc_recallGroup} forEach _unitsX;
Where it leads:

Calls:
A3A_fnc_canFight: To check target status.
A3A_fnc_recallGroup: To return units to formation.
Dependencies: Used by higher-level AI tactics.
Network: Local execution.
Function Name: fn_enemyGarrison.sqf
What it does: Assigns an enemy group to a specific marker, adding them to the garrison system (count and resource tracking) and initiating a local patrol loop. It also sets up a despawn trigger for when the marker changes side.

How it does that:

Validation & Localization: Checks if the group is local to the machine (server/HC). If not, it remote executes the function to the group's leader. Validates the marker still belongs to the group's side.

Sqf

Apply
if (!local _group) exitWith { ... remoteExec ... };
if (sidesX getVariable _marker != side _group) exitWith { ... };
Script Cleanup: Terminates any existing AI script handles (A3A_AIScriptHandle) and despawner handles on the group to prevent conflicts.

Sqf

Apply
private _AIScriptHandle = _group getVariable "A3A_AIScriptHandle";
if (!isNil "_AIScriptHandle") then { terminate _AIScriptHandle; };
Garrison Integration: Collects the unit types (from unitType variable) and sends them to A3A_fnc_garrisonUpdate on the server (ID 2). This updates the global garrison counts and resource pools.

Sqf

Apply
private _unitTypes = units _group apply { _x getVariable "unitType" };
[_unitTypes, side _group, _marker, 0] remoteExec ["A3A_fnc_garrisonUpdate", 2];
Resource Management: If the units came from the legacy/ambient pool (paid for by the Commander), it deducts the resource cost immediately.

Sqf

Apply
if (leader _group getVariable ["A3A_resPool", "legacy"] == "legacy") then {
    [count units _group * -10, side _group, "legacy"] remoteExec ["A3A_fnc_addEnemyResources", 2];
};
Unit State Update: Marks units with A3A_resPool: "garrison", markerX, and clears spawner. This flags them as permanent garrison units.

Sqf

Apply
_x setVariable ["A3A_resPool", "garrison", true];
_x setVariable ["markerX", _marker, true];
Patrol Loop: A scheduled script runs to create a continuous patrol. It sets the waypoint position to a random radius within the marker (_mrkSize) and updates it every 30 seconds if the unit is unitReady.

Sqf

Apply
while {!isNull leader _group} do {
    if (unitReady leader _group) then {
        _wp setWaypointPosition [markerPos _marker, _mrkSize];
        _group setCurrentWaypoint _wp;
    };
    sleep 30;
};
Despawn Logic: A second scheduled script waits for the marker's spawner variable to become 2 (despawned/empty). Once triggered, it deletes all units in the group.

Sqf

Apply
while {spawner getVariable _marker != 2} do { sleep 10 };
{ deleteVehicle _x } forEach units _group;
Where it leads:

Calls:
A3A_fnc_enemyReturnToBase: Called if marker validation fails.
A3A_fnc_garrisonUpdate: Updates global garrison count on server.
A3A_fnc_addEnemyResources: Adjusts commander resources.
Dependencies: Relies on spawner network variable and sidesX markers.
Global State: Modifies A3A_resPool, markerX, spawner, A3A_AIScriptHandle, A3A_despawnerHandle.
Network: Heavy use of remoteExec for server-side garrison updates.
Function Name: fn_enemyList.sqf
What it does: Generates a list of visible enemy targets for a group, sorts them by distance, and stores them in a group variable for use by AI decision-making.

How it does that:

Target Acquisition: Uses nearTargets on the group leader with a 500m radius. This returns an array of potential targets visible to the leader's sensors.

Sqf

Apply
private _objectivesX = (_LeaderX nearTargets 500) select { ... };
Filtering: Filters the list to include only targets whose side (_x select 2) matches the list of enemy sides defined by BIS_fnc_enemySides. It also checks if the target canFight.

Sqf

Apply
private _enemySides = _sideX call BIS_fnc_enemySides;
select {(_x select 2) in _enemySides and {[_x select 4] call A3A_fnc_canFight}};
Sorting: The filtered list is sorted by distance to the group leader using BIS_fnc_sortBy.

Sqf

Apply
_objectivesX = [_objectivesX,[_LeaderX],{_input0 distance (_x select 0)},"ASCEND"] call BIS_fnc_sortBy;
Storage: The sorted array is saved to the group variable objectivesX and returned.

Sqf

Apply
_groupX setVariable ["objectivesX",_objectivesX];
Where it leads:

Calls:
BIS_fnc_enemySides: Determines valid enemy sides.
A3A_fnc_canFight: Validates target status.
BIS_fnc_sortBy: Orders targets by distance.
Dependencies: Used by unitGetToCover, attackDrillAI, and other tactical decision functions.
Global State: Sets objectivesX variable on the group.
Network: Local execution.
Function Name: fn_enemyReturnToBase.sqf
What it does: Commands an enemy group to retreat to the nearest unspawned base. It handles both foot infantry and vehicle groups differently. If a valid marker is provided and has capacity, it garrisons the troops there instead of fully despawning.

How it does that:

Input Validation: Checks for null groups or empty units.

Sqf

Apply
if (isNull _group) exitWith {};
if (units _group isEqualTo []) exitWith { deleteGroup _group };
Script & Waypoint Cleanup: Terminates existing AI scripts and deletes current waypoints to ensure the retreat command is the only active order.

Sqf

Apply
private _AIScriptHandle = _group getVariable "A3A_AIScriptHandle";
if (!isNil "_AIScriptHandle") then { terminate _AIScriptHandle; };
while {count waypoints _group > 0} do { deleteWaypoint [_group, 0] };
Vehicle Logic: If the group is in a vehicle:

It spawns despawners for the vehicle and group.
It determines the nearest suitable base based on vehicle type (Air -> airportsX, Ground -> outposts).
Disables AUTOCOMBAT for safety, sets behavior to AWARE, and sets a waypoint to the base.
Sqf

Apply
if (vehicle leader _group != leader _group) exitWith {
    [_group] spawn A3A_fnc_groupDespawner;
    [vehicle leader _group] spawn A3A_fnc_vehDespawner;
    _marker = [_group, airportsX + ["CSAT_carrier", "NATO_carrier"]] call _fnc_nearestBase;
    // ... set waypoint ...
};
Foot Infantry Logic - Garrison Check: If a marker is provided, it performs sanity checks:

Is there garrison space left? (garrisonSize)
Does the marker still belong to the group's side?
Is the group close enough? If checks pass, it calls A3A_fnc_enemyGarrison.
Sqf

Apply
if (_marker != "") then {
    if (([_marker] call A3A_fnc_garrisonSize) - count (garrison getVariable [_marker, []]) <= 0) exitWith { _marker = "" };
    // ...
};
if (_marker != "") exitWith { [_group, _marker] call A3A_fnc_enemyGarrison };
Foot Infantry Logic - Retreat: If no marker is provided or checks fail, it finds the nearest unspawned friendly base from a list (outposts, airports, etc.). If none found, the group surrenders. Otherwise, it disables combat/targeting AI, sets behavior to AWARE, and moves to the base.

Sqf

Apply
_marker = [_group, outposts + airportsX + milbases + ...] call _fnc_nearestBase;
if (isNil "_marker") exitWith {
    { _x spawn A3A_fnc_surrenderAction } forEach units _group;
};
{ _x disableAI "AUTOCOMBAT"; _x disableAI "TARGET"; } forEach units _group;
Despawn Trigger: For foot troops retreating to a base, A3A_fnc_groupDespawner is spawned to handle deletion when the units reach the area or are no longer needed.

Sqf

Apply
[_group] spawn A3A_fnc_groupDespawner;
Where it leads:

Calls:
A3A_fnc_groupDespawner: Handles group deletion.
A3A_fnc_vehDespawner: Handles vehicle deletion.
A3A_fnc_enemyGarrison: If garrisoning is valid.
A3A_fnc_surrenderAction: If no retreat location exists.
A3A_fnc_garrisonSize: Checks capacity.
Dependencies: Relies on sidesX, spawner, garrison, and marker arrays (airportsX, etc.).
Global State: Modifies AI capabilities (disables AI modes) and waypoint data.
Network: Uses remoteExec inside A3A_fnc_enemyGarrison.

Function Name: fn_fastrope.sqf
What it does: This function performs a fastrope operation from a helicopter, where AI units rappel down from a hovering helicopter to the ground. It's used for tactical insertions and extractions, typically during missions where helicopters need to drop troops quickly without landing. The function handles helicopter positioning, unit deployment, and post-extraction cleanup. It's specifically designed for transport helicopters rather than attack helicopters.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_veh", "_groupX", "_positionX", "_posOrigin", "_heli", ["_landPos", []], ["_reinf", false]];
_veh: The transport helicopter performing the fastrope (typically a transport helicopter like a Mohawk)
_groupX: The infantry group being deployed
_positionX: The target position where the troops should be inserted
_posOrigin: The origin position (where the helicopter should return to after extraction)
_heli: The helicopter object (same as _veh typically, but kept separate for network context)
_landPos: Optional pre-defined landing position (default: empty array)
_reinf: Boolean flag indicating if this is a reinforcement mission (default: false)
Vehicle Type Check and Setup:

Sqf

Apply
private _vehType = typeOf _veh;

if (_vehType in FactionGet(all,"vehiclesHelisAttack") + FactionGet(all,"vehiclesHelisLightAttack") + FactionGet(all,"vehiclesPlanesTransport")) then {
    _veh setVehicleRadar 1;
};
Retrieves the vehicle type class name
If the vehicle is an attack helicopter or transport plane, enables its radar (sets to mode 1)
This ensures the vehicle can detect enemies during approach
Uses FactionGet macro to get faction-specific vehicle lists
Reference Point Calculation:

Sqf

Apply
private _xRef = 2;
private _yRef = 1;
private _dist = if (_reinf) then {30} else {100 + random 100};
_xRef and _yRef: These are offset coordinates used when attaching units to the helicopter for fastroping
_dist: Distance from target position where helicopter should position itself
For reinforcements: 30m (tighter drop)
For normal insertions: 100m ± random 100m (more variability)
Landing Position Calculation:

Sqf

Apply
if (_landPos isEqualTo []) then {
    _landpos = [_positionX, _dist, _dist, 2, 0, 5, 0] call BIS_fnc_findSafePos;
    _landpos set [2,0]
};
If no pre-defined landing position provided, calculates a safe position using BIS_fnc_findSafePos
Parameters: center position, minimum distance, maximum distance, alignment, terrain gradation, vehicle, object
Sets altitude to 0 (sea level) for ground positioning
The function finds a position that's not in water, not too steep, and clear of obstacles
Helicopter Crew Behavior:

Sqf

Apply
{_x setBehaviour "CARELESS";} forEach units _heli;
Sets all crew in the helicopter to "CARELESS" behavior mode
This prevents them from engaging targets or taking defensive actions
Important for the helicopter to focus on positioning rather than combat
Waypoint Creation:

Sqf

Apply
private _wp = _heli addWaypoint [_landpos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "FULL";
_wp setWaypointCompletionRadius 3;
Creates a waypoint at the calculated landing position
Type: MOVE (direct flight path)
Behavior: CARELESS (won't engage threats)
Speed: FULL (maximum speed)
Completion radius: 3m (very precise positioning required)
Approach Wait Condition:

Sqf

Apply
waitUntil {sleep 1; (not alive _veh) or (_veh distance _landpos < 550) or !(canMove _veh)};
Waits until helicopter is within 550m of the landing position
Also breaks if vehicle is destroyed or can't move
Checks every second
Hover Preparation:

Sqf

Apply
_veh flyInHeight 12;

waitUntil {sleep 1; (not alive _veh) or ((speed _veh < 2) and (speed _veh > -1)) or !(canMove _veh)};

_veh setVelocity [0,0,0];
Sets hover altitude to 12m above ground
Waits until helicopter is virtually stationary (speed between -1 and 2 km/h)
Forces velocity to zero to ensure stable hover for rappelling
Door Opening:

Sqf

Apply
if (canMove _veh) then {
    [_veh, "open"] spawn A3A_fnc_HeliDoors;
};
Opens cargo doors using the HeliDoors function
Only if vehicle is still operational
Smoke Cover Deployment:

Sqf

Apply
[_veh] call A3A_fnc_smokeCoverAuto;
Automatically deploys smoke grenades from the helicopter
Provides visual cover for troops during deployment
Unit Deployment Loop:

Sqf

Apply
{
    if (!alive _x) then { continue };

    [_veh,_x,_xRef,_yRef] spawn {
        private ["_veh","_unit","_d","_xRef","_yRef"];
        _veh = _this select 0;
        _unit = _this select 1;
        _xRef = _this select 2;
        _yRef = _this select 3;
        waitUntil {((speed _veh < 1) and (speed _veh > -1))};
        _d = -1;
        unassignVehicle _unit;
        moveOut _unit;
        if (!(alive _veh) or (getPos _veh)#2 < 5) exitWith {};
        _veh setVectorUp [0,0,1];
        [_unit,"gunner_standup01"] remoteExec ["switchmove"];
        _unit attachTo [_veh, [_xRef,_yRef,_d]];
        while {((getposATL _unit select 2) > 1) and (alive _veh) and (alive _unit) and (speed _veh < 10) and (speed _veh > -10)} do {
            _unit attachTo [_veh, [2,1,_d]];
            _d = _d - 0.35;
            sleep 0.005;
        };
        detach _unit;
        [_unit,""] remoteExec ["switchMove"];
        sleep 0.5;
    };
    sleep (2 + random 2);
} forEach units _groupX;
For each unit in the group:
Spawns a script to handle individual unit's rappel
Waits for helicopter to be stable
Removes unit from vehicle assignment
Moves unit out of vehicle
Ensures vehicle is at safe altitude (>5m)
Orients helicopter upright
Sets rappelling animation (gunner_standup01)
Attaches unit to helicopter at offset coordinates
Continuously lowers unit while maintaining attachment
Adjusts Y-position every 0.005 seconds
Detaches when reaching ground (altitude ≤ 1m)
Clears animation
Provides spacing between units (2-4 seconds random)
Post-Deployment Wait:

Sqf

Apply
waitUntil {sleep 1; (not alive _veh) or ((count assignedCargo _veh == 0) and (([_veh] call A3A_fnc_countAttachedObjects) == 0))};
Waits until helicopter has no assigned cargo units
Also waits until no objects are attached to the helicopter
Confirms all units have successfully deployed
Extraction Preparation:

Sqf

Apply
sleep 3;
_veh flyInHeight 175;

if (canMove _veh) then {
    [_veh, "close"] spawn A3A_fnc_HeliDoors;
};
3-second delay for visual separation
Ascends to 175m for safe extraction flight
Closes doors if vehicle is operational
Mission-Specific Waypoint Setup:

Sqf

Apply
if !(_reinf) then
{
    private _wp2 = _groupX addWaypoint [(position (leader _groupX)), 0];
    _wp2 setWaypointType "MOVE";
    _wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI"];
    _wp2 = _groupX addWaypoint [_positionX, 1];
    _wp2 setWaypointType "MOVE";
    _wp2 setWaypointStatements ["true","if !(local this) exitWith {}; {if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
    _wp2 = _groupX addWaypoint [_positionX, 2];
    _wp2 setWaypointType "SAD";
}
else
{
    private _wp2 = _groupX addWaypoint [_positionX, 0];
    _wp2 setWaypointType "MOVE";
};
If not reinforcement:
Move to current leader position (brief regrouping)
Execute attack drill AI script
Move to target position, revealing all enemies
Set SAD (Seek and Destroy) at target position
If reinforcement:
Move directly to target position
Weapon System Check:

Sqf

Apply
private _weapons = count weapons _helicopter;
private _driverturret = _helicopter weaponsTurret [0];
private _gunnerturret = _helicopter weaponsTurret [-1];
private _weaponsturret = count _driverturret + count _gunnerturret;

if (_veh in FactionGet(all,"vehiclesHelisAttack") + FactionGet(all,"vehiclesHelisLightAttack")) exitWith {
    [_veh, _heli, _positionX] spawn A3A_fnc_attackHeli;
};
Counts weapons on the helicopter
Checks driver and gunner turrets
If vehicle is an attack helicopter, transitions to attack mode instead of transport mode
Calls fn_attackHeli for combat mission
Return Home:

Sqf

Apply
private _wp3 = _heli addWaypoint [_posOrigin, 1];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "NORMAL";
_wp3 setWaypointBehaviour "CARELESS";
_wp3 setWaypointStatements ["true", "if !(local this) exitWith {}; deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
{_x setBehaviour "CARELESS";} forEach units _heli;
Creates return waypoint to origin position
Normal speed, careless behavior
Important: Waypoint statement deletes helicopter and all crew when reached
All helicopter crew set to careless behavior
Where it leads:

Functions Called:

A3A_fnc_HeliDoors - Opens/closes helicopter doors
A3A_fnc_smokeCoverAuto - Deploys smoke cover automatically
A3A_fnc_countAttachedObjects - Counts objects attached to vehicle
A3A_fnc_attackHeli - Switches to attack helicopter mode (if applicable)
A3A_fnc_attackDrillAI - Executes attack drill for deployed troops
Global Variables Modified:

None directly, but may affect:
Mission state through A3A_fnc_attackDrillAI
Unit behavior through waypoints
Dependencies:

Requires FactionGet macro for vehicle type checking
Depends on BIS_fnc_findSafePos for positioning
Requires helicopter to be local for crew operations
Network Implications:

Uses remoteExec for animation changes across network
Unit detachment and repositioning happens locally
Helicopter deletion occurs when waypoint is reached on its locality
Error Handling:

Checks vehicle survival and mobility throughout
Exits early if vehicle is destroyed or immobilized
Avoids placing dead units underground (getPos _veh #2 < 5)
Continues even if individual units die during deployment
Edge Cases:

Empty landPos triggers safe position calculation
Reinforcements use tighter drop distance (30m vs 100-200m)
Attack helicopters switch to combat mode instead of transport
Units dieing during rappel stops their individual script but continues with others
Function Name: fn_fastropeVTOL.sqf
What it does: Performs a fastrope operation specifically for VTOL (Vertical Take-Off and Landing) aircraft, which have different handling characteristics than traditional helicopters. The function includes custom flight path calculations for the VTOL's unique approach and landing capabilities, and uses a more complex bezier curve trajectory for landing.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_veh", "_groupX", "_positionX", "_posOrigin", "_heli"];
Same basic parameters as fn_fastrope but no optional parameters
_veh: The VTOL aircraft (e.g., V-44X Blackfish, Y-32 Xi'an)
_groupX: Infantry group to deploy
_positionX: Target position
_posOrigin: Origin position for return
_heli: The aircraft object
Vehicle Setup:

Sqf

Apply
private _vehType = typeOf _veh;
_veh setVehicleRadar 1;
Always enables radar for VTOL (unlike helicopter version which checks type)
VTOLs are typically armed transport aircraft
Reinforcement Flag:

Sqf

Apply
private _reinf = if (count _this > 5) then {_this select 5} else {false};
Checks if _reinf parameter was passed
Defaults to false if not provided
Used for adjusting drop distance
Reference Points and Distance:

Sqf

Apply
private _xRef = 2;
private _yRef = 1;
private _landpos = [];
private _dist = if (_reinf) then {30} else {100 + random 100};
Similar offset coordinates for unit attachment
Landing distance calculated same way as helicopter version
Landing Position Calculation:

Sqf

Apply
_landpos = [_positionX, _dist, _dist, 2, 0, 5, 0] call BIS_fnc_findSafePos;
_landpos set [2,0];
Finds safe position using BIS function
Sets altitude to 0 (ground level)
Crew Behavior:

Sqf

Apply
{_x setBehaviour "CARELESS";} forEach units _heli;
Same as helicopter version - prevents crew from engaging
Waypoint Creation:

Sqf

Apply
private _wp = _heli addWaypoint [_landpos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "FULL";
_wp setWaypointCompletionRadius 3;
Same waypoint setup as helicopter version
Approach Wait:

Sqf

Apply
waitUntil {sleep 1; (not alive _veh) or (_veh distance _landpos < 550) or !(canMove _veh)};
Waits until within 550m of landing position
Climate-Based Height:

Sqf

Apply
private _midHeight = [100, 150] select (A3A_climate isEqualTo "tropical");
_veh flyInHeight _midHeight;
Adjusts mid-approach height based on climate
Tropical climates use 150m (more clearance)
Other climates use 100m
VTOL-Specific Flight Path:

Sqf

Apply
private _endPos = _landpos;
private _startPos = getPosASL _veh;
private _midPos = _endPos vectorAdd [0,0,_midHeight];
private _initialVelocity = (velocity _veh);
_initialVelocity set [2, 0];
private _velocityVector = +_initialVelocity;
_initialVelocity = vectorMagnitude _initialVelocity;
private _initialSpeed = speed _veh/3.6;
private _distance = _startPos distance _midPos;
private _landingTime = _distance/_initialVelocity * 1.35;
private _maxAngle = ((_initialVelocity * _initialVelocity/3600) * 35) min 35;
Calculates 3D positions: start (current), mid (ascent point), end (landing)
Gets initial velocity and normalizes to horizontal plane
Calculates initial speed in m/s
Calculates distance and estimated landing time
Calculates maximum pitch angle based on initial velocity (capped at 35°)
Bezier Curve Setup:

Sqf

Apply
private _startToMidVector = _midPos vectorDiff _startPos;
private _midToEndVector = _endPos vectorDiff _midPos;
private _vectorDir = vectorDir _veh;
private _vectorUp = vectorUp _veh;
private _interval = 0;
private _time = 0;
private _angleStep = 0.25;
private _angleTarget = 0;
private _angleIs = 0;
private _angleDiff = 0;
private _heightDiff = 0;
private _driver = driver _veh;
Calculates vector differences for bezier curve segments
Initializes control variables for curve progression
Gets current vehicle orientation
Retrieves driver for VTOL vectoring actions
Bezier Curve Looop:

Sqf

Apply
while {_interval < 0.7777} do
{
    _vectorDir = vectorDir _veh;
    _vectorUp = vectorUp _veh;

    _angleTarget = sin (_interval * 180) * _maxAngle;
    _angleIs = (asin (_vectorDir select 2));
    _angleDiff = _angleTarget - _angleIs;
    if(_angleDiff > _angleStep) then {_angleDiff = _angleStep;};
    if(_angleDiff < -_angleStep) then {_angleDiff = -_angleStep;};

    _backFactor = -tan (_angleDiff);
    _vectorUp = _vectorUp vectorAdd (_vectorDir vectorMultiply _backFactor);

    _heightDiff = (sin (_angleIs + _angleDiff)) - (_vectorDir select 2);
    _vectorDir = _vectorDir vectorAdd [0, 0, _heightDiff];

    private _lineStart = _startPos vectorAdd (_startToMidVector vectorMultiply _interval);
    private _lineEnd = _midPos vectorAdd (_midToEndVector vectorMultiply _interval);
    
    _veh setVelocityTransformation
    [
        _lineStart,
        _lineEnd,
        _velocityVector,
        _velocityVector,
        _vectorDir,
        _vectorDir,
        _vectorUp,
        _vectorUp,
        _interval
    ];

    _time = time;
    sleep 0.001;
    _interval = _interval + (((time - _time)/_landingTime) * (1 - (_interval / 2)));
    _velocityVector = _lineEnd vectorDiff _lineStart;
    _velocityVector = (vectorNormalized _velocityVector) vectorMultiply (_initialSpeed * (1 - _interval));

    if(!canMove _veh || !alive _driver) exitWith {};
};
Bezier curve loop running until 77.77% complete:
Gets current orientation
Calculates target pitch angle based on interval (sine wave pattern)
Gets current pitch angle from direction vector
Calculates difference, clamping to step size (0.25°)
Calculates back-factor for vector adjustment
Adjusts vertical vector based on angle difference
Calculates height adjustment
Adjusts direction vector for pitch
Calculates current position along bezier curve (lineStart and lineEnd)
Uses setVelocityTransformation for smooth path following
Sleeps 0.001 seconds between updates
Progresses interval based on time elapsed vs estimated landing time
Recalculates velocity vector based on current position
Reduces speed as interval increases (braking curve)
Exits if vehicle or driver is invalid
VTOL Vectoring Setup:

Sqf

Apply
_veh flyInHeight 15;
_veh setVelocity [0,0,0];
sleep 0.5;
_driver action ["VTOLVectoring", _veh];
_driver action ["VectoringUp", _veh];
_driver action ["VectoringUp", _veh];

_veh setVelocity [0,0,0];
Sets final hover height (15m)
Stops all movement
Activates VTOL vectoring mode (enables directed thrust)
Applies upward vectoring twice (ensures activation)
Resets velocity to zero
Door Opening:

Sqf

Apply
if (canMove _veh) then {
    [_veh, "open"] spawn A3A_fnc_HeliDoors;
};
Opens doors if vehicle operational
Uses same door system as helicopter
Driver AI Disabling:

Sqf

Apply
_driver disableAI "MOVE";
_driver disableAI "PATH";
_driver action ["VectoringUp", _veh];
_driver action ["VectoringUp", _veh];
Disables driver's move and path AI (prevents interference)
Maintains upward vectoring
Unit Deployment:

Sqf

Apply
if (alive _veh && canMove _veh) then
{
    [_veh] call A3A_fnc_smokeCoverAuto;
    {
    _veh setVelocity [0,0,0];
    _veh setVectorUp [0,0,1];
    [_veh,_x,_xRef,_yRef] spawn
        {
        private ["_veh","_unit","_d","_xRef","_yRef"];
        _veh = _this select 0;
        _unit = _this select 1;
        _xRef = _this select 2;
        _yRef = _this select 3;
        waitUntil {((speed _veh < 1) and (speed _veh > -1))};
        _d = -1;
        unassignVehicle _unit;
        moveOut _unit;
        if (!(alive _veh) or (getPos _veh)#2 < 5) exitWith {};
        _veh setVectorUp [0,0,1];
        [_unit,"gunner_standup01"] remoteExec ["switchmove"];
        _unit attachTo [_veh, [_xRef,_yRef,_d]];
        while {((getposATL _unit select 2) > 1) and (alive _veh) and (alive _unit) and (canMove _veh) and (speed _veh < 10) and (speed _veh > -10)} do
            {
            _unit attachTo [_veh, [2,1,_d]];
            _d = _d - 0.35;
            private _driver = driver _veh;
            _veh setVectorUp [0,0,1];
            _driver action ["VectoringUp", _veh];
            _veh setVelocity [0,0,0];
            sleep 0.005;
            };
        detach _unit;
        [_unit,""] remoteExec ["switchMove"];
        sleep 0.5;
        };
    sleep (2 + random 2);
    } forEach units _groupX;
};
Similar to helicopter deployment but with additional VTOL-specific actions:
Maintains upward vectoring during deployment
Ensures vehicle remains upright
Stops velocity frequently
Continues vectoring actions during the entire rappel process
Post-Deployment Cleanup:

Sqf

Apply
_driver action ["VTOLVectoringCancel", _veh];
_driver enableAI "MOVE";
_driver enableAI "PATH";

waitUntil {sleep 1; (not alive _veh) or ((count assignedCargo _veh == 0) and (([_veh] call A3A_fnc_countAttachedObjects) == 0))};

sleep 3;
_veh flyInHeight 175;

if (canMove _veh) then {
    [_veh, "close"] spawn A3A_fnc_HeliDoors;
};
Cancels VTOL vectoring mode
Re-enables driver AI
Waits for deployment completion
Ascends and closes doors
Waypoint Setup:

Sqf

Apply
if !(_reinf) then {
    // ... same as helicopter version
} else {
    private _wp2 = _groupX addWaypoint [_positionX, 0];
    _wp2 setWaypointType "MOVE";
};
Same infantry waypoint logic as helicopter version
Weapon System Check:

Sqf

Apply
private _weapons = count weapons _veh;
private _driverturret = _veh weaponsTurret [0];
private _gunnerturret = _veh weaponsTurret [-1];
private _weaponsturret = count _driverturret + count _gunnerturret;

if (_veh in FactionGet(all,"vehiclesTransportAir") && _weapons > 2 || _weaponsturret > 2) exitWith {
    [_veh, _heli, _positionX] spawn A3A_fnc_attackHeli;
};

if (_veh in FactionGet(all,"vehiclesHelisAttack") + FactionGet(all,"vehiclesHelisLightAttack")) exitWith {
    [_veh, _heli, _positionX] spawn A3A_fnc_attackHeli;
};
VTOL-Specific Logic:
Checks if VTOL is in transport category AND has more than 2 weapons
Or if turret weapons exceed 2 (assuming first 2 are non-combat systems)
If armed, switches to attack helicopter mode
Also checks if vehicle is in attack helicopter categories
Return Home:

Sqf

Apply
private _wp3 = _heli addWaypoint [_posOrigin, 1];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "NORMAL";
_wp3 setWaypointBehaviour "CARELESS";
_wp3 setWaypointStatements ["true", "if !(local this) exitWith {}; deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
{_x setBehaviour "CARELESS";} forEach units _heli;
Same cleanup logic as helicopter version
Deletes VTOL and crew on return
Where it leads:

Functions Called:

A3A_fnc_HeliDoors - Door control (same as helicopter version)
A3A_fnc_smokeCoverAuto - Smoke deployment
A3A_fnc_countAttachedObjects - Object counting
A3A_fnc_attackHeli - Attack mode (if armed)
BIS_fnc_findSafePos - Position finding
BIS_fnc_sortBy (indirectly) - For infantry waypoints
Global Variables Modified:

A3A_climate - Used for height calculation
Mission state through attack drill script
Dependencies:

Requires VTOL aircraft (V-44X, Y-32 Xi'an, etc.)
More computationally intensive than helicopter version
Requires driver for vectoring actions
Network Implications:

Uses remoteExec for animations
Driver actions are local to pilot
Vectoring requires driver locality
Error Handling:

Extensive checks for vehicle and driver status
Exits bezier loop if vehicle/driver becomes invalid
Checks altitude to avoid underground placement
Edge Cases:

No optional _reinf parameter defaults to false
Tropical climates use higher approach altitude
Armed VTOLs switch to combat mode
Complex bezier calculation may need tuning for different VTOL types
Function Name: fn_findSafeRoadToUnload.sqf
What it does: Finds a safe road position for vehicle unloading or rendezvous. It searches for roads near a destination, excludes unsafe or inappropriate roads (forests, rocks, tall grass), and ensures the road isn't too close to blacklisted positions. The function sorts results based on whether the goal is maximum safety (far from destination) or maximum efficiency (closest to destination).

How it does that:

Parameter Validation:

Sqf

Apply
params ["_destinationX", "_originX", "_safe", "_blacklist"];
_destinationX: Target position for unloading
_originX: Origin position (used for distance calculations)
_safe: Boolean flag for safety vs efficiency priority
_blacklist: Array of positions to avoid
Blacklist Initialization:

Sqf

Apply
if (count _blackList == 0) then {_blackList = [[0,0,0]]};
If blacklist is empty, adds a dummy position at world origin
Prevents errors in distance checks
Radius Calculation:

Sqf

Apply
private _radiusX = if (!_safe) then {400} else {50};
private _dif = (_destinationX select 2) - (_originX select 2);

if (_dif > 0) then {
    _radiusX = _radiusX + (_dif * 2);
};
If not safe mode (efficiency): 400m radius
If safe mode: 50m radius (closer to destination, less scanning)
Adjusts radius based on elevation difference
Higher elevation difference increases search radius
Road Search Loop:

Sqf

Apply
private _roads = [];
private _roadsTmp = nil;
private _road = nil;
private _ok = nil;
while {count _roads == 0} do {
    _roadsTmp = (_destinationX nearRoads _radiusX) select {surfaceType (position _x) != "#GdtForest" && {surfaceType (position _x)!= "#GdtRock" && {surfaceType (position _x)!= "#GdtGrassTall"}}};
    {
        _road = _x;
        _ok = true;
        {
            if (position _road distance2D _x < 150) exitWith {_ok = false};
        } forEach _blacklist;
        if (_ok) then {_roads pushBack _road};
    } forEach _roadsTmp;
    _radiusX = _radiusX + 50;
};
Roads Loop:
Find roads within current radius
Filter out roads with inappropriate surface types:
Forest (#GdtForest)
Rock (#GdtRock)
Tall grass (#GdtGrassTall)
For each valid road:
Check distance to all blacklist positions
If any blacklist position is within 150m, reject road
Otherwise, add to results
If no roads found, increase radius by 50m and repeat
Result Sorting:

Sqf

Apply
if (!_safe) then {
    _roads = [_roads,[],{_originX distance _x},"ASCEND"] call BIS_fnc_sortBy;
} else {
    _roads = [_roads,[],{_destinationX distance _x},"DESCEND"] call BIS_fnc_sortBy;
};
Efficiency mode (not safe): Sort by distance from origin (ASCEND)
Picks road closest to origin for quick unloading
Safety mode: Sort by distance from destination (DESCEND)
Picks road farthest from destination for maximum safety
Return Position:

Sqf

Apply
private _result = position (_roads select 0);
_result
Returns position of the first road in sorted list
Position is 3D vector [x, y, z]
Where it leads:

Functions Called:

BIS_fnc_sortBy - Sorts roads by distance
nearRoads (BIS) - Finds roads in radius
surfaceType (BIS) - Gets terrain surface type
Global Variables Modified:

None directly
Dependencies:

Requires road network near destination
Depends on terrain surface type definitions
Network Implications:

Pure calculation function, no network calls
Runs locally on calling machine
Error Handling:

Loop continues until at least one road is found
Always returns a road position (if road network exists)
Dummy blacklist entry ensures blacklist check works
Edge Cases:

No roads in area: Loops until radius is large enough
All roads blacklisted: Continues expanding radius
No terrain surface matching: Includes all roads
Elevation difference: Increases search radius dynamically
Function Name: fn_fleeToSide.sqf
What it does: Orders a fleeing unit to move toward the nearest friendly position for their side. For enemy units fleeing from combat, this directs them toward unspawned outposts, airports, resources, factories, seaports, or military bases. For friendly units (teamPlayer), it directs them toward the respawn marker. Can optionally prevent the unit from becoming captive and disable panic behaviors.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_unit", "_side", ["_noCaptive", false], ["_isPanic", false]];
_unit: The fleeing unit
_side: The side the unit belongs to (e.g., east, west, resistance)
_noCaptive: Prevents unit from being marked as captive (default: false)
_isPanic: Indicates if unit is in panic state (default: false)
Target Position Selection:

Sqf

Apply
private _marker = respawnTeamPlayer;
if (_side != teamPlayer) then {
    private _potentials = (outposts + airportsX + resourcesX + factories + seaports + milbases);
    _potentials = _potentials select { sidesX getVariable [_x, sideUnknown] == _side };
    _potentials = _potentials select { spawner getVariable _x != 0 };        // only flee to unspawned locations
    if (count _potentials == 0) exitWith {};
    _marker = [_potentials, _unit] call BIS_fnc_nearestPosition;
};
If unit is on teamPlayer side: Use respawn marker position
If enemy unit:
Build array of all potential locations (outposts, airports, resources, factories, seaports, military bases)
Filter by side ownership using sidesX global variable
Filter by spawn state using spawner global variable (only unspawned locations)
If no valid locations, function exits early
Find nearest position to unit using BIS_fnc_nearestPosition
Panic State Handling:

Sqf

Apply
if (!_isPanic) then {
    // In case unit was surrendered
    _unit enableAI "ANIM";
    _unit enableAI "MOVE";
    _unit stop false;
    _unit switchMove "";
};
If not in panic state (normal fleeing):
Re-enable animation AI
Re-enable movement AI
Release from stop command
Clear current animation
If panic state, unit remains in panic behavior
Captive State Handling:

Sqf

Apply
if (_noCaptive) then {
    _unit setVariable ["canBeIncapacitated", false, true];
    _unit setCaptive false;
};
If noCaptive flag is true:
Set canBeIncapacitated variable to false (prevents being downed)
Set unit as not captive (prevents surrender)
This ensures unit remains combat-capable while fleeing
Movement Command:

Sqf

Apply
_unit doMove (getMarkerPos _marker);
Issues doMove command to waypoint position
Unit will pathfind to the target position
Where it leads:

Functions Called:

BIS_fnc_nearestPosition - Finds nearest valid location
Global Variables Modified:

respawnTeamPlayer - Read for friendly side
outposts, airportsX, resourcesX, factories, seaports, milbases - Read for enemy side
sidesX - Read for side ownership
spawner - Read for spawn state
Unit variables: canBeIncapacitated, captive state
Dependencies:

Requires global arrays for location types
Requires sidesX and spawner global variables
Depends on mission state for valid locations
Network Implications:

setVariable with true parameter makes variable public
doMove is local to unit's machine
No remote execution
Error Handling:

Exits early if no valid positions for enemy side
If no positions found, unit receives no movement command
Unit remains at current position
Edge Cases:

Friendly side: Always uses respawn marker (may be at HQ)
Enemy side with no valid locations: No movement command issued
Panic state: May override normal fleeing behavior
noCaptive allows armed retreat rather than surrender
Function Name: fn_guardDog.sqf
What it does: Controls an animal unit (dog) that acts as a security guard. The dog patrols around its leader, detects nearby enemy units, reveals them to the group, and barks occasionally. It can also make captured enemy units flee if they get too close. The dog is immune to capture and uses special behaviors.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_dog"];
_dog: The animal unit to control
Dog Initialization:

Sqf

Apply
private _groupX = group _dog;
private _spotted = objNull;

_dog setVariable ["BIS_fnc_animalBehaviour_disable", true];
_dog disableAI "FSM";
_dog setBehaviour "CARELESS";
_dog setRank "PRIVATE";
_dog setVariable ["isAnimal", true, true];
Stores dog's group reference
Initializes _spotted to track detected units
Disables BIS animal behavior FSM
Disables FSM (Finite State Machine) AI
Sets behavior to "CARELESS" (won't engage)
Sets rank to private
Marks unit as animal (public variable)
Main Loop:

Sqf

Apply
while {alive _dog} do
{
Runs continuously while dog is alive
Leader Check:

Sqf

Apply
if ((_dog == leader _groupX) and (!captive _dog)) then {[_dog,true] remoteExec ["setCaptive",0,_dog]; _dog setCaptive true};
If dog is group leader (unusual) and not captive:
Set captive to true (public)
Make dog captive
Prevents dog from being killed if it leads group
No Target State:

Sqf

Apply
if (isNull _spotted) then
{
    sleep 10;
    _dog moveTo getPosATL leader _groupX;
    {
    _spotted = _x;
    if ((captive _spotted) and (vehicle _spotted == _spotted)) then
        {
        [_spotted,false] remoteExec ["setCaptive",0,_spotted]; _spotted setCaptive false;
        };
    } forEach ([20,0,position _dog,teamPlayer] call A3A_fnc_distanceUnits);

    if ((random 10 < 1) and (isNull _spotted)) then
        {
        playSound3D [selectRandom A3A_sounds_dogBark,_dog, false, getPosASL _dog, 1, 1, 100];
        };
    if (_dog distance (leader _groupX) > 50) then {_dog setPos position (leader _groupX)};
}
If no unit currently spotted:
Sleep 10 seconds
Move toward leader position
Check for nearby units within 20m of dog:
If unit is captive and not in vehicle:
Make unit non-captive (causes them to flee)
Clear captive state publicly
Random 10% chance to bark if no target
If dog is >50m from leader, teleport to leader position
Target Spotted State:

Sqf

Apply
else
{
    _dog doWatch _spotted;
    (leader _groupX) reveal [_spotted,4];
    playSound3D [A3A_sounds_dogBark select (floor random 5),_dog, false, getPosASL _dog, 1, 1, 100];
    _dog moveTo getPosATL _spotted;
    if (_spotted distance _dog > 100) then {_spotted = objNull};
    sleep 3;
};
If unit is currently spotted:
Dog watches the target
Leader reveals target to group with high knowledge (4)
Play specific bark sound
Move toward target
If target moves >100m away, clear target
Sleep 3 seconds before next check
Where it leads:

Functions Called:

A3A_fnc_distanceUnits - Finds units within distance
playSound3D - Plays bark sounds
Global Variables Modified:

A3A_sounds_dogBark - Read for bark sounds
teamPlayer - Used in distance check
Unit variables: isAnimal (public), captive state
Dependencies:

Requires animal unit type
Requires dog bark sound array
Depends on teamPlayer side definition
Network Implications:

setCaptive uses remoteExec for public execution
Sound plays locally (3D positional)
doWatch and moveTo are local to dog's machine
Error Handling:

Loop ends when dog dies
Teleports dog back to leader if too far
Clears target if it moves too far
Edge Cases:

Dog becomes leader (rare): Makes it captive for protection
No enemy in range: Patrols around leader
Captive enemy nearby: Causes them to flee
Target moves >100m away: Loses target and patrols again
Function Name: fn_hasRadio.sqf
What it does: Determines if a unit should be considered as having a radio capability. This is a general check that considers multiple factors: global radio availability, individual radio items, and specific faction mechanics (like IFA GL units acting as radio operators).

How it does that:

Parameter Validation:

Sqf

Apply
params ["_unit"];
_unit: The unit to check for radio capability
Radio Check Logic:

Sqf

Apply
haveRadio || {_unit call A3A_fnc_hasARadio};
Returns true if either condition is met:
haveRadio global variable is true (global radio availability)
Unit has a radio item via A3A_fnc_hasARadio
Where it leads:

Functions Called:

A3A_fnc_hasARadio - Checks if unit has physical radio item
Global Variables Modified:

haveRadio - Read for global radio availability
Dependencies:

Requires haveRadio global variable
Requires A3A_fnc_hasARadio function
Network Implications:

Pure local check, no network calls
Global variable is server-synced
Error Handling:

No explicit error handling
Returns false if global variable is false and unit has no radio
Edge Cases:

Global radio enabled: All units have radio regardless of items
IFA mod: Uses GL units as radio operators (handled in hasARadio)
ACE medical: May affect radio item detection
Function Name: fn_HeliDoors.sqf
What it does: Controls the cargo doors of various helicopter types. It accepts "open" or "close" commands and animates the appropriate doors for each helicopter model. The function handles multiple different helicopter variants with different door animations.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_helicopter", "_state"];
_helicopter: The helicopter to control
_state: "open" or "close"
State Translation:

Sqf

Apply
switch _state do
{
    case "open": { _state = 1; };
    case "close": { _state = 0; };
};
Converts string commands to numeric animation states
"open" = 1, "close" = 0
Door Animations:

Sqf

Apply
_helicopter animateDoor ["Door_Cargo", _state];        // Mi-24V (CSLA) cargo doors
_helicopter animateDoor ["door_2_2_source", _state];   // VBH 1 (GM) right door
_helicopter animateDoor ["door_2_1_source", _state];   // VBH 1 (GM) left door
_helicopter animateDoor ["Door_Back_L", _state];       // Mohawk back door Left
_helicopter animateDoor ["Door_Back_R", _state];       // Mohawk back door Right
_helicopter animateDoor ["door_cargo_left", _state];   // Cougar
_helicopter animateDoor ["Door_L", _state];            // Ghosthawk
_helicopter animateDoor ["Door_L_source", _state];     // Huron front door
_helicopter animateDoor ["Door_rear_source", _state];  // Huron rear door
_helicopter animateDoor ["door_1", _state];            // Wildcat
_helicopter animateDoor ["Door_4_source", _state];     // Taru right door
_helicopter animateDoor ["Door_5_source", _state];     // Taru left door
_helicopter animate ["dvere1_posunZ",_state];          // Orca
_helicopter animate ["side_door", _state];             // Mi-17 (CSLA) side door
sleep 0.3; 
_helicopter animateDoor ["Door_1_source", _state];     // Y-32 Xi'an/V-44X
_helicopter animateDoor ["cargoramp_source", _state];  // CH-53G (GM) ramp
_helicopter animateDoor ["CargoRamp_Open", _state];    // Cougar
_helicopter animateDoor ["door_cargo_right", _state];  // Cougar
_helicopter animateDoor ["Door_R", _state];            // Ghosthawk
_helicopter animateDoor ["Door_R_source", _state];     // Huron front door
_helicopter animateDoor ["door_2", _state];            // Wildcat
_helicopter animateDoor ["Door_6_source", _state];     // Taru ramp
_helicopter animate ['vrata_right_big', _state];       // Mi-17 (CSLA) rear door
_helicopter animate ['vrata_left_big', _state];        // Mi-17 (CSLA) still rear door
_helicopter animate ['vrata_right_small', _state];     // Mi-17 (CSLA) yep stil door
_helicopter animate ['vrata_left_small', _state];      // Mi-17 (CSLA) reeeeeaaar door
_helicopter animate ["dvere2_posunZ",_state];          // Orca
First group: Immediate animations
Mi-24V (CSLA): "Door_Cargo"
VBH 1 (GM): Left and right doors
Mohawk: Back doors (left/right)
Cougar: Cargo doors
Ghosthawk: Side doors
Huron: Front and rear doors
Wildcat: Single door
Taru: Right/left doors
Orca: "dvere1_posunZ"
Mi-17 (CSLA): Side door "side_door"
0.3 second delay
Second group: Delayed animations
Y-32 Xi'an/V-44X: Front door
CH-53G (GM): Cargo ramp
Cougar: Ramp and right door
Ghosthawk: Right door
Huron: Front door
Wildcat: Door 2
Taru: Ramp door
Mi-17 (CSLA): Multiple rear doors
Orca: "dvere2_posunZ"
Where it leads:

Functions Called:

None directly (uses BIS animateDoor and animate)
Global Variables Modified:

None
Dependencies:

Requires helicopter with corresponding animation names
Network Implications:

Animations are local to helicopter's machine
No network calls
Error Handling:

No explicit error handling
Missing animation names are silently ignored by game engine
Edge Cases:

Different helicopter mods may have different animation names
Dual animation sets for some helicopters (immediate and delayed)
CT (Cessna) helicopter may not have all doors
Function Name: fn_help.sqf
What it does: Medic AI function that handles medical assistance to wounded units. The medic can either help another unit or self-heal. It includes movement to target, potential drag-to-cover operations, smoke deployment for cover, and suppression fire from nearby units. The function handles both incapacitated units (revive) and regular wounded units (heal).

How it does that:

Parameter Validation:

Sqf

Apply
params ["_unit", "_medicX"];
_unit: The wounded unit to help
_medicX: The medic unit performing the help
Initial Checks:

Sqf

Apply
if !(isNull (_unit getVariable ["helped",objNull])) exitWith {};
if (isPlayer _medicX) exitWith {};
if (_medicX getVariable ["helping",false]) exitWith {};
Exit if unit is already being helped
Exit if medic is a player (players handle their own healing)
Exit if medic is already helping another unit
Variable Setup:

Sqf

Apply
_unit setVariable ["helped",_medicX];
_medicX setVariable ["helping",true];
_medicX setVariable ["maneuvering",true];

private _cured = false;
private _isPlayerGroup = if ({isPlayer _x} count units _unit > 0) then {true} else {false};
Mark unit as being helped by this medic
Mark medic as currently helping
Mark medic as maneuvering (used by other systems)
Initialize cure status
Check if unit is in a player group (for dialogue)
Can Help Function:

Sqf

Apply
private _fnc_canHelp = {
    params ["_medic", "_target"];
    (alive _target)
    and (_medic call A3A_fnc_canFight)
    and (isNull objectParent _medic)
    and (_medic == _target getVariable ["helped",objNull])
    and (isNull attachedTo _target)
    and !(_medicX getVariable ["cancelRevive",false])
    and !(_unit getVariable ["A3A_blockRevive",false])
};
Checks if medic can still help:
Target is alive
Medic can fight (not downed)
Medic not in a vehicle
Medic is still assigned to this target
Target not being dragged or loaded
Revive not cancelled
Revive not blocked
Heal Function:

Sqf

Apply
private _fnc_doHeal = {
    params ["_medic", "_target"];
    _medic stop true;
    _target stop true;
    private _cured = if (_target getVariable ["incapacitated",false]) then { 
        [_target,_medic] call A3A_fnc_actionRevive;
    } else {
        _medic action ["HealSoldier",_unit];
        sleep 10; true;
    };
    if (_cured && _medic != _target && _isPlayerGroup) then {
        _medic groupChat format ["You are ready %1",name _target];
    };
    _medic stop false;
    _target stop false;
    _target doFollow leader _target;
    _medic doFollow leader _medic;
    _cured;
};
Heal process:
Stop both units from moving
If target is incapacitated: Call actionRevive
If target is just wounded: Use "HealSoldier" action (10 second wait)
If successful and different units in player group: Medic announces completion
Release both units from stop
Both units follow their group leaders
Return cure status
Non-Self Help:

Sqf

Apply
if (_medicX != _unit) then
{
    // Unit notification if not incapacitated
    if !(_unit getVariable ["incapacitated",false]) then
    {
        if (_isPlayerGroup) then {_unit groupChat format ["Comrades, this is %1. I'm hurt!", name _unit]};
        playSound3D [(selectRandom injuredSounds),_unit,false, getPosASL _unit, 1, 1, 50];
    };

    // Medic announcement
    if (_isPlayerGroup) then {
        _medicX groupChat format ["Wait a minute comrade %1, I will patch you up.", name _unit]
    };

    // Player hint
    if (player == _unit) then {
        ["Medical", format ["%1 is on the way to help you.", name _medicX]] call A3A_fnc_customHint;
    };

    Debug_2("Medic %1 helping %2", _medicX, _unit);

    // Smoke deployment
    private _enemy = _medicX findNearestEnemy _unit;
    if ((_unit getVariable ["incapacitated", false]) and (!isNull _enemy)) then
    {
        if (random 100 < 35) then {
            [_medicX,_unit,_enemy] call A3A_fnc_chargeWithSmoke;
        };

        // Get smoke/suppression help from nearby AI squadmates
        private _nearFriends = units _medicX select { (_x != _medicX) and (_x call A3A_fnc_canFight) and (_x distance _unit < 50) and !(_x getVariable ["helping",false]) and (!isPlayer _x) };
        {
            if (random 100 > 40) then { continue };
            if (random 100 > 65) then {
                [selectRandom _nearFriends, _unit, _enemy] spawn A3A_fnc_chargeWithSmoke;
            } else {
                [selectRandom _nearFriends, _enemy] spawn A3A_fnc_suppressingFire;
            };
        } forEach _nearFriends;
    };

    Debug_1("Medic %1 moving to target", _medicX);

    // Movement to target
    _medicX stop false;
    _medicX forceSpeed -1;
    _medicX doMove getPosATL _unit;
    _timeOut = time + 60;
    waitUntil { sleep 1; !([_medicX, _unit] call _fnc_canHelp) or (unitReady _medicX) or (_medicX distance _unit <= 2) or (time > _timeOut) };

    // Check if reached or abandoned
    if (!([_medicX, _unit] call _fnc_canHelp) or (_unit distance _medicX > 3)) exitWith {
        private _canHelp = [_medicX, _unit] call _fnc_canHelp;
        Debug_4("Medic %1 abandoned at distance %2, ready %3, canHelp %4", _medicX, _unit distance _medicX, unitReady _medicX, _canHelp);

        if (_unit getVariable ["incapacitated", false]) then {
            private _failCount = _unit getVariable ["helpFailed", 0];
            _unit setVariable ["helpFailed", _failCount + 1];
        };
    };

    // Drag to cover if incapacitated
    if ((_unit getVariable ["incapacitated",false]) and (!isNull _enemy)) then
    {
        _coverX = [_unit,_enemy] call A3A_fnc_coverage;
        if (count _coverX == 3) then {
            Debug_1("Medic %1 dragging target", _medicX);
            [_medicX, _unit, _coverX] call A3A_fnc_AIdrag;
        };
    };

    Debug_1("Medic %1 healing target", _medicX);

    if ([_medicX, _unit] call _fnc_canHelp) then {
        _cured = [_medicX, _unit] call _fnc_doHeal;
    };
}
Non-self-help flow:
Notify wounded unit (if not incapacitated)
Medic announces help
Player receives hint
Check for enemy and deploy smoke (35% chance)
Get help from nearby AI squadmates:
40% skip each squadmate
65% chance smoke, 35% chance suppression fire
Move to target position
Wait up to 60 seconds to reach target
If can't reach or help abandoned:
Increment fail counter for incapacitated units
If incapacitated and enemy present:
Find cover
Drag to cover if valid cover found
Perform healing if still able
Track cure status
Self-Heal:

Sqf

Apply
else
{
    // Self-heal + smoke stuff
    if (random 100 < 35) then {
        [_medicX,_medicX] call A3A_fnc_chargeWithSmoke;
    };
    if ([_medicX] call A3A_fnc_canFight) then
    {
        _medicX action ["HealSoldierSelf",_medicX];
        sleep 10;
    };
    _medicX setVariable ["helped",objNull];
    _cured = true;
};
Self-heal flow:
35% chance to deploy smoke for self
If can fight: Use self-heal action
Clear helped variable
Mark as cured
Cleanup:

Sqf

Apply
_medicX setUnitPos "AUTO";
_medicX doFollow leader _unit;

if (_medicX == _unit getVariable ["helped",objNull]) then { _unit setVariable ["helped",objNull,true] };

_medicX setVariable ["helping",false];
_medicX setVariable ["maneuvering",false];

if (_medicX getVariable ["cancelRevive",false]) then {
    _medicX setVariable ["cancelRevive",false];
    sleep 15;
};

_cured
Reset medic to auto position
Medic follows wounded unit's group leader
Clear helped variable if medic was assigned
Clear helping and maneuvering flags
If revive was cancelled, clear flag and wait 15 seconds
Return cure status
Where it leads:

Functions Called:

A3A_fnc_canFight - Check if unit can fight
A3A_fnc_actionRevive - Revive incapacitated unit
A3A_fnc_chargeWithSmoke - Deploy smoke grenade
A3A_fnc_customHint - Show UI hint
A3A_fnc_coverage - Find cover position
A3A_fnc_AIdrag - Drag unit to cover
A3A_fnc_suppressingFire - Provide suppressing fire
Global Variables Modified:

Unit variables: helped, helping, maneuvering, cancelRevive, helpFailed, A3A_blockRevive, incapacitated
injuredSounds - Read for hurt sounds
Dependencies:

Requires medical system variables
Requires combat capability checks
Depends on revive system
Network Implications:

setVariable with true parameter for public variables
remoteExec not used directly
Local actions executed locally
Error Handling:

Extensive checks before starting
Timeout after 60 seconds
Fail counter for unsuccessful revives
Cancelled revive detection
Edge Cases:

Medic and target same unit
Incapacitated vs regular wounded
Player group vs AI group
No enemy present (no smoke)
No cover available
Medic killed during process
Unit dies during process
Function Name: fn_hideInBuilding.sqf
What it does: Orders infantry units to move into building positions for garrisoning. It finds nearby buildings with available positions, assigns units to those positions, and manages AI behavior to keep them in place. The function tracks occupied positions to prevent multiple units from claiming the same spot.

How it does that:

Parameter Validation:

Sqf

Apply
private _unitsX = _this;
Function accepts array of units as single parameter (no named params)
Assumes _this contains unit array
Building Search:

Sqf

Apply
private _buildings = (nearestTerrainObjects [(leader (_unitsX select 0)),["House"],100]) select {count (_x buildingPos -1) > 0};
if (_buildings isEqualTo []) exitWith {};
Finds houses within 100m of first unit's leader
Filters to buildings with at least one building position
Exits if no suitable buildings found
Position Assignment:

Sqf

Apply
private _groupX = group (_unitsX select 0);
private _buildingPos = [];
private _occupiedX = _groupX getVariable ["occupiedX",[]];
private _exit = false;

{
_bld = _x;
{
if !(_x in _occupiedX) then
    {
    _buildingPos pushBack _x;
    _occupiedX pushBack _x;
    if (count _unitsX == count _buildingPos) exitWith {_exit = true};
    };
} forEach (_bld buildingPos -1);
if (_exit) exitWith {};
} forEach _buildings;
Get group and previously occupied positions
For each building:
For each building position:
If position not occupied:
Add to available positions
Mark as occupied
If we have enough positions for all units, exit
Exit if enough positions found
Continue through buildings until enough positions or no more buildings
Final Validation:

Sqf

Apply
if (_buildingPos isEqualTo []) exitWith {};
if (count _unitsX > count _buildingPos) then {_buildingPos resize (count _unitsX)};
_groupX setVariable ["occupiedX",_occupiedX];
Exit if no positions found
If more units than positions, resize array (some units won't get positions)
Update group's occupied positions variable
Unit Movement:

Sqf

Apply
{
_pos = _buildingPos select _forEachIndex;
if (isNil "_pos") exitWith {};
_x setVariable ["maneuvering",true];
_x disableAI "TARGET";
_x disableAI "AUTOTARGET";
_x disableAI "SUPPRESSION";
_x disableAI "CHECKVISIBLE";
_x disableAI "COVER";
_x disableAI "AUTOCOMBAT";
_x doMove _pos;
[_x,_pos] spawn
    {
    params ["_unit", "_pos"];
    _timeOut = time + 60;
    waitUntil {sleep 1; (_unit distance _pos < 1.5) or !(alive _unit) or (time > _timeOut) or !(_unit getVariable ["maneuvering",false])};
    _unit enableAI "TARGET";
    _unit enableAI "AUTOTARGET";
    _unit enableAI "SUPPRESSION";
    _unit enableAI "CHECKVISIBLE";
    _unit enableAI "COVER";
    _unit enableAI "AUTOCOMBAT";
    if (time > _timeOut) exitWith {};
    if !(alive _unit) exitWith {};
    if !(_unit getVariable ["maneuvering",false]) exitWith {};
    _unit forceSpeed 0;
    };
} forEach _unitsX;
For each unit with a position:
Mark as maneuvering
Disable combat AI behaviors:
Targeting
Auto-targeting
Suppression reaction
Visibility checks
Cover seeking
Auto-combat
Move to building position
Spawn script to wait for arrival:
Wait until: within 1.5m, dead, timeout (60s), or maneuvering cancelled
Re-enable all AI behaviors
If not timed out and still alive and maneuvering:
Force speed to 0 (freeze in place)
Where it leads:

Functions Called:

None directly (uses BIS nearestTerrainObjects, buildingPos)
Global Variables Modified:

Group variable: occupiedX (tracks occupied positions)
Unit variables: maneuvering
Dependencies:

Requires buildings with available positions
Depends on group variable system
Network Implications:

setVariable with false parameter for group variable
doMove and forceSpeed are local
AI enable/disable is local
Error Handling:

Exits if no buildings found
Exits if no building positions found
Timeouts after 60 seconds
Handles unit death during movement
Edge Cases:

More units than building positions
Building positions already occupied
Units die during movement
Building is destroyed
Multiple groups using same area

Function Name: 
fn_inmuneConvoy.sqf
What it does: This function manages the visibility of a vehicle to enemy players and handles automatic "stuck" detection and correction for AI convoy vehicles. It acts as a persistent server-side loop that tracks a specific vehicle. If the vehicle is part of a convoy or mission objective, it becomes permanently "revealed" (visible on map). If not, it checks the actual knowledge of the vehicle by the player side. Additionally, it attempts to teleport vehicles that haven't moved significantly to a nearby road to prevent them from getting stuck in terrain.

How it does that:

Initialization & Validation:

The function checks if it is running on a client with an interface. If so, it exits immediately (server-only logic).
It retrieves arguments _veh, _text, and _stuckHacks.
It determines if the vehicle is a convoy or mission objective by comparing the text marker against localized strings (STR_marker_convoy_objective, etc.).
It waits until the vehicle has a driver, ensuring the logic can proceed.
Sqf

Apply
if (!isServer and hasInterface) exitWith{};
private ["_pos","_side","_newPos","_road"];
params ["_veh", "_text", ["_stuckHacks", true]];
private _convoy = (_text == (localize "STR_marker_convoy_objective")) or (_text == (localize "STR_marker_convoy_objective_space")) or (_text == (localize "STR_marker_mission_vehicle")) or (_text == (localize "STR_marker_supply_box"));
waitUntil {sleep 1; (not(isNull driver _veh)) or _convoy};
Revelation Loop (Visibility Management):

A while loop runs as long as the vehicle is alive.
Revealing: If the vehicle is not yet revealed (!revealed), it checks if the player side knows about it (knowsAbout > 1.4) or if a debug variable revealX is true, or if it's a convoy. If true, it sets the vehicle variable revealed to true and executes A3A_fnc_vehicleMarkers remotely on teamPlayer and civilian to show the map marker.
Hiding: If the vehicle is revealed, it checks if the player side has lost knowledge (knowsAbout <= 1.4) and it is not a convoy. If true, it sets revealed to false.
Sqf

Apply
while {alive _veh} do {
    if (!(_veh getVariable ["revealed",false])) then {
        if ((teamPlayer knowsAbout _veh > 1.4) or revealX or _convoy) then {
            _veh setVariable ["revealed",true,true];
            [_veh,_text] remoteExec  ["A3A_fnc_vehicleMarkers",[teamPlayer,civilian]];
        };
    } else {
        if ((teamPlayer knowsAbout _veh <= 1.4) and !(revealX) and !(_convoy)) then {
            _veh setVariable ["revealed",false,true];
        };
    };
Stuck Detection and Correction:

Every 60 seconds, it records the vehicle's position and compares it to the previous position.
If the vehicle has moved less than 5 meters and is not a supply box, it triggers the stuck logic.
Air Units: If the vehicle is an aircraft ("Air") and is touching the ground, it forces all assigned cargo to disembark.
Ground Units: If the current waypoint is the final waypoint (destination reached), the stuck hacks are disabled (_stuckHacks = false) to prevent interfering with mission completion.
Bridge/Terrain Logic: It checks if any players are within 500m. If not, it looks for specific bridge objects nearby. If bridges are found, it calculates the direction to the next waypoint and moves the vehicle 100 meters forward in that direction.
Road Teleport: It searches for the nearest road (BIS_fnc_nearestRoad) within 100 meters. If a road is found, it teleports the vehicle to the road's position and hides nearby trees/bushes (hideObjectGlobal) to prevent visual popping.
Sqf

Apply
    _pos = getPosATL _veh;
    sleep 60;
    _newPos = getPosATL _veh;
    _driverX = driver _veh;
    if (_stuckHacks and {(_newPos distance _pos < 5) and (_text != (localize "STR_marker_supply_box")) and !(isNull _driverX)}) then {
        if (_veh isKindOf "Air") then {
            if (isTouchingGround _veh) then {
                {
                    unAssignVehicle _x;
                    moveOut _x;
                    sleep 1.5;
                } forEach assignedCargo _veh;
            };
        } else {
            if (not(_veh isKindOf "Ship")) then {
                if (currentWaypoint (group _driverX) >= count waypoints (group _driverX)) exitWith {
                    _stuckHacks = false;
                };
                if ({_x distance _newPos < 500} count (allPlayers - (entities "HeadlessClient_F")) == 0) then {
                    _bridges = nearestObjects [_newPos, ["Land_Bridge_01_PathLod_F","Land_Bridge_Asphalt_PathLod_F","Land_Bridge_Concrete_PathLod_F","Land_Bridge_HighWay_PathLod_F","Land_BridgeSea_01_pillar_F","Land_BridgeWooden_01_pillar_F"], 50];
                    if !(_bridges isEqualTo []) then {
                        _nextWaypoint = currentWaypoint (group _driverX);
                        _wpPos = waypointPosition ((waypoints (group _driverX)) select _nextWaypoint);
                        _ang = [_newPos, _wpPos] call BIS_fnc_DirTo;
                        _newPos = _newPos getPos [100,_ang];
                    };
                    _road = [_newPos,100] call BIS_fnc_nearestRoad;
                    if (!isNull _road) then {
                        _veh setPos getPos _road;
                        {
                            [_x,true] remoteExec ["hideObjectGlobal",2]
                        } foreach (nearestTerrainObjects [position _road,["tree","bush"],15]);
                    };
                };
            };
        };
    };
};
Where it leads:

Calls: A3A_fnc_vehicleMarkers (remotely) to display the map marker.
Calls: BIS_fnc_DirTo to calculate the direction to the next waypoint.
Calls: BIS_fnc_nearestRoad to find a valid road position for teleportation.
Depends on: Global variables teamPlayer, debug (revealX), and vehicle variable revealed.
System Context: This is used for AI-controlled logistics, reinforcements, and patrols. It ensures that convoys remain visible on the map for players to intercept and prevents AI vehicles from getting permanently stuck on terrain features.
Synchronization: It executes remoteExec on teamPlayer and civilian sides to synchronize map markers. It uses setVariable with the public flag (3rd argument true) to broadcast state changes.
Function Name: 
fn_interrogate.sqf
What it does: This function handles the logic for a player interrogating a surrendered unit. It performs a probability check to determine if the interrogation yields useful intelligence (zone locations or faction intel) or if the unit refuses to talk. It also manages the visual and auditory feedback for the player.

How it does that:

Action Removal & Validation:

It removes the "Interrogate" action from the unit immediately to prevent duplicate triggers.
It checks if the unit is alive and if they have already been interrogated. If so, it exits.
Sqf

Apply
[_unit, _actionID] remoteExec ["removeAction", [teamPlayer, civilian], _unit];
if (!alive _unit) exitWith {};
if (_unit getVariable ["interrogated", false]) exitWith {};
_unit setVariable ["interrogated", true, true];
Audio-Visual Feedback:

The interrogating player speaks a random phrase from the localized strings.
It identifies the side of the unit (Occupants or Invaders) and calculates a "chance" value based on global aggression levels (aggressionOccupants, aggressionInvaders). Higher aggression increases the chance of success.
Sqf

Apply
_player globalChat (selectRandom [...]);
private _side = side (group _unit);
private _chance = 120 - ([aggressionOccupants, aggressionInvaders] select (_side == Invaders));
Probability Check:

It sleeps for 4 seconds (dramatic pause).
It rolls a random number (0-100). If it is less than _chance, the interrogation succeeds.
Success Logic:
If hideEnemyMarkers is true, it calls A3U_fnc_revealRandomZones (debug/cheat feature) to reveal map zones.
It checks if the unit has the variable hasIntel set to true.
With Intel: The unit speaks a success phrase. If the unit is a rival (isRival), it calls SCRT_fnc_rivals_selectIntel. Otherwise, it calls A3A_fnc_selectIntel to spawn intel items/resources.
Without Intel: The unit speaks a phrase indicating they have no knowledge.
Failure Logic (Refusal):
If the roll fails, the unit speaks a refusal phrase.
Sqf

Apply
if (random 100 < _chance) then {
    if (hideEnemyMarkers) then {
        [1, "An interrogated soldier gave us some intel about zone locations."] call A3U_fnc_revealRandomZones;
    };
    if(_unit getVariable ["hasIntel", false]) then {
        _unit globalChat (...);
        _unit setVariable ["hasIntel", false, true];
        if (_unit getVariable ["isRival", false]) then {
            [] remoteExecCall ["SCRT_fnc_rivals_selectIntel", 2];
        } else {
            ["Small", _side] remoteExec ["A3A_fnc_selectIntel", 2];
        };
    } else {
        _unit globalChat (...);
    };
} else {
    _unit globalChat (...);
};
Where it leads:

Calls: A3U_fnc_revealRandomZones (conditional).
Calls: SCRT_fnc_rivals_selectIntel (if rival unit).
Calls: A3A_fnc_selectIntel (if standard unit).
Depends on: Global variables hideEnemyMarkers, aggressionOccupants, aggressionInvaders.
System Context: Part of the prisoner/resistance mechanics. It rewards players for capturing enemies alive rather than killing them.
Synchronization: Uses remoteExec to remove the action globally. Updates hasIntel with the public flag. Spawns intel remotely on the server (owner 2).
Function Name: 
fn_isBuildingPosition.sqf
What it does: This function checks if a specific 3D position is located inside a building. It uses line-of-sight intersection tests upward and downward from the position to detect "Building" class objects.

How it does that:

Coordinate Conversion:

It accepts a position array. If the Z-coordinate is 0 (meaning it's an ATL position), it converts it to ASL (Above Sea Level) for accurate raycasting.
Sqf

Apply
params ["_pos"];
if ((_pos select 2) == 0) then {_pos = ATLtoASL _pos};
Roof Detection:

It casts a line from the position upwards by 20 meters (lineIntersectsWith).
It checks the first object intersected. If it is a "BUILDING" (class), it sets _Inbuilding to true.
Sqf

Apply
private _Roof = lineIntersectsWith [_pos, [(_pos select 0), (_pos select 1), (_pos select 2) + 20]];
If (count _Roof > 0) then {
    _Inbuilding = (_Roof select 0) isKindOf "BUILDING";
};
Floor Detection (Fallback):

If no roof was found, it casts a line downwards by 20 meters.
It checks the first object intersected. If it is a "BUILDING", it sets _Inbuilding to true.
Sqf

Apply
If (!_Inbuilding) then {
    private _Down = lineIntersectsWith [_pos, [(_pos select 0), (_pos select 1), (_pos select 2) - 20]];
    if (count _Down > 0) then {
        _Inbuilding = (_Down select 0) isKindOf "BUILDING";
    };
};
Return Value:

Returns the boolean _Inbuilding.
Where it leads:

Calls: BIS_fnc_lineIntersectsWith (engine command).
System Context: Used by AI scripts (like fn_hideInBuilding) to determine if a unit has successfully entered a building or if they are simply under a roof/terrain feature. It is a geometric helper, not a high-level gameplay function.
Synchronization: Local only. No network implications.
Function Name: 
fn_landThreatEval.sqf
What it does: Calculates a threat value for a specific map marker or position relative to a specific side. This function is used by AI to decide whether an area is too well-defended to attack or infiltrate. It counts friendly static weapons, garrison units, and nearby fortifications (FIA outposts).

How it does that:

Input Handling:

It accepts a marker name or a position array. If it's a marker, it gets the position.
Initializes _threat to 0.
Sqf

Apply
params ["_markerX", "_sideX"];
private _threat = 0;
private _positionX = if (_markerX isEqualType []) then {_markerX} else {getMarkerPos _markerX};
Static Fortification Calculation:

It counts markers in roadblocksFIA, watchpostsFIA, etc., within distanceSPWN.
It multiplies this count by 2 and adds it to the threat.
Sqf

Apply
_threat = _threat + 2 * ({
    (isOnRoad getMarkerPos _x) and (getMarkerPos _x distance _positionX < distanceSPWN)
} count roadblocksFIA + watchpostsFIA + aapostsFIA + atpostsFIA + hmgpostsFIA);
Garrison and Static Weapon Calculation:

It iterates through markers (markersX) excluding cities, controls, and the FIA outposts already counted.
It filters for markers where the controlling side (sidesX) is not the side passed into the function (i.e., enemy territory).
Garrison Units: Retrieves the garrison array for the marker and adds (count garrison) / 8 to the threat (a rough weight per soldier).
Static Weapons: Checks staticsToSave located within the marker area.
Adds 1 for each mortar.
Adds 2 for each AT static.
Sqf

Apply
{
    if (getMarkerPos _x distance _positionX < distanceSPWN) then {
        _analyzed = _x;
        _garrison = garrison getVariable [_analyzed,[]];
        _threat = _threat + (floor((count _garrison)/8));
        _staticsX = staticsToSave select {_x inArea _analyzed};
        if (count _staticsX > 0) then {
            _threat = _threat + ({typeOf _x in FactionGet(reb,"staticMortars")} count _staticsX) + (2*({typeOf _x in FactionGet(reb,"staticAT")} count _staticsX));
        };
    };
} forEach ((markersX - citiesX - controlsX - watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - hmgpostsFIA) select {sidesX getVariable [_x,sideUnknown] != _sideX});
Where it leads:

Calls: FactionGet to retrieve specific static weapon classnames.
Depends on: Global arrays roadblocksFIA, staticsToSave, markersX. Global variables garrison, sidesX.
System Context: Used by the CSAT/AAF commanders when deciding spawn locations for attacks or reinforcements. If the threat is too high, they will spawn fewer units or cancel the attack.
Synchronization: This reads state variables. It does not modify them. It runs on the server.
Function Name: 
fn_liberatedeserter.sqf
What it does: Handles the logic when a player interacts with a "deserter" unit (a friendly AI that spawned in a hideout). It makes the unit join the player's group and enables standard AI behaviors.

How it does that:

Exit on Death:

If the deserter is dead, it simply removes the flag action (visual interaction point).
Sqf

Apply
params ["_unit", "_playerX"];
if (!alive _unit) exitWith {
    [_unit,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
};
Action Removal:

Removes the flag action immediately to prevent multiple interactions.
Sqf

Apply
[_unit,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
Captive State Handling:

Ensures the player is not in "captive" (surrendered) mode, as they are initiating an action.
Makes the deserter speak a "flee" phrase.
Sqf

Apply
if (captive _playerX) then { _playerX setCaptive false };
_playerX globalChat (localize "STR_chats_loot_flee_player");
Group Join & Synchronization:

Sleeps for 3 seconds.
Orders the deserter to join the player's group.
Waits up to 10 seconds for the join to propagate locally to the deserter and synchronize with the group.
Sqf

Apply
sleep 3;
[_unit] join group _playerX;
private _timeout = 10;
waituntil {sleep 1; _timeout = _timeout-1; _timeout < 0 or (local _unit and group _unit == group _playerX)};
if (_timeout < 0) exitWith {};
AI Activation:

Makes the deserter speak a response.
Enables all suppressed AI behaviors (MOVE, AUTOTARGET, TARGET, ANIM).
Sets the deserter to no longer be captive.
Sqf

Apply
_unit globalChat (localize "STR_chats_loot_flee_response");
_unit enableAI "MOVE";
_unit enableAI "AUTOTARGET";
_unit enableAI "TARGET";
_unit enableAI "ANIM";
if (captive _unit) then { _unit setCaptive false };
Where it leads:

Calls: A3A_fnc_flagaction (remote) to remove the action.
System Context: Part of the "Garrison" and "Deserter" mission types. These units provide additional manpower to the player.
Synchronization: Uses remoteExec for flag actions. The joinGroup command is network synchronized automatically by the engine.
Function Name: 
fn_liberateFlee.sqf
What it does: Handles the liberation of a unit that immediately flees away from the combat zone. Unlike liberatePOW, this unit does not join the player's group but runs to a safe side and despawns, granting resources.

How it does that:

Validation & Action Removal:

Checks if the unit is alive. Removes the flag action.
Sqf

Apply
params ["_unit", "_playerX"];
if (!alive _unit) exitWith {
    [_unit,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
};
[_unit,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
Animation & Interaction:

Unsets player captive status.
Plays a "MountSide" animation on the player (hugging/helping the unit).
Rotates the unit to face the player.
Makes the unit speak a response.
Sqf

Apply
_playerX playMove "MountSide";
sleep 5;
_playerX playMove "";
_unit globalChat (localize "STR_chats_loot_flee_response");
AI Activation:

Enables all movement and combat AI behaviors.
Calls A3A_fnc_FIAInit (which sets up basic rebel unit stats/traits).
Sqf

Apply
_unit enableAI "MOVE";
_unit enableAI "AUTOTARGET";
_unit enableAI "TARGET";
_unit enableAI "ANIM";
[_unit, true] spawn A3A_fnc_FIAInit;
if (captive _unit) then { _unit setCaptive false };
Fleeing Logic (Sub-script):

Spawns a separate thread to handle the fleeing process.
Waits until the unit is no longer captive or dead (captive usually drops when they start moving or taking damage).
If alive and not captive:
Waits 2 seconds, then broadcasts a "freedom" chat message remotely.
Calls A3A_fnc_fleeToSide (sets waypoints towards the nearest safe zone).
Waits 30 seconds (presumed travel time).
Grants resources (A3A_fnc_resourcesFIA).
Deletes the unit to save performance.
Sqf

Apply
[_unit] spawn {
    params ["_prisoner"];
    waitUntil { sleep 0.5; !captive _prisoner || {!alive _prisoner}};
    if (alive _prisoner && {!captive _prisoner}) then {
        sleep 2;
        private _text = selectRandom [...];
        [_prisoner, "sideChat", _text] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
        [_prisoner, teamPlayer, false] remoteExec ["A3A_fnc_fleeToSide", _prisoner];
        sleep 30;
        [1,0] remoteExec ["A3A_fnc_resourcesFIA",2];
        deleteVehicle _prisoner;
    };
};
Where it leads:

Calls: A3A_fnc_flagaction, A3A_fnc_FIAInit, A3A_fnc_commsMP, A3A_fnc_fleeToSide, A3A_fnc_resourcesFIA.
System Context: Used for "Rescue Fleeing Refugees" or similar missions.
Synchronization: Heavy use of remoteExec for chat, movement logic, and resource updates.
Function Name: 
fn_liberatePOW.sqf
What it does: Handles the liberation of a Prisoner of War (POW). The unit joins the player's group and follows them, unlike liberateFlee where the unit runs away immediately.

How it does that:

Setup & Animation:

Validates unit, removes action, unsets player captive.
Player plays "MountSide" animation.
POW speaks a response.
Sqf

Apply
params ["_unit", "_playerX"];
// ... validation ...
_playerX playMove "MountSide";
sleep 5;
_playerX playMove "";
Group Joining:

Joins the unit to the player's group.
Waits up to 10 seconds for the join to process locally.
Sqf

Apply
[_unit] join group _playerX;
private _timeout = 10;
waituntil {sleep 1; _timeout = _timeout-1; _timeout < 0 or (local _unit and group _unit == group _playerX)};
if (_timeout < 0) exitWith {};
Final Activation:

Removes the flag action again (safety check).
Enables AI movement and combat capabilities.
Initializes the unit as an FIA rebel.
Removes captive status.
Sqf

Apply
[_unit,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
_unit globalChat (localize "STR_chats_loot_flee_response");
_unit enableAI "MOVE";
_unit enableAI "AUTOTARGET";
_unit enableAI "TARGET";
_unit enableAI "ANIM";
[_unit, true] spawn A3A_fnc_FIAInit;
if (captive _unit) then { _unit setCaptive false };
Where it leads:

Calls: A3A_fnc_flagaction, A3A_fnc_FIAInit.
System Context: Used for "Rescue POW" missions. The player must escort the POW back to HQ.
Synchronization: Uses remoteExec for flag actions. joinGroup is engine synchronized.
Function Name: 
fn_liberaterefugee.sqf
What it does: Handles the liberation of a refugee unit. Similar to liberatePOW, the refugee joins the player's group to be escorted safely.

How it does that:

Initialization:

Validates unit, removes action, unsets player captive.
Player says a phrase, sleeps for 3 seconds.
Sqf

Apply
params ["_unit", "_playerX"];
// ... validation ...
_playerX globalChat (localize "STR_chats_loot_flee_player");
sleep 3;
Group Joining:

Joins the unit to the player's group.
Waits up to 10 seconds for synchronization.
Sqf

Apply
[_unit] join group _playerX;
private _timeout = 10;
waituntil {sleep 1; _timeout = _timeout-1; _timeout < 0 or (local _unit and group _unit == group _playerX)};
if (_timeout < 0) exitWith {};
Activation:

Refugee speaks.
AI behaviors enabled (MOVE, AUTOTARGET, etc.).
Initializes as FIA unit.
Removes captive status.
Sqf

Apply
_unit globalChat (localize "STR_chats_loot_flee_response");
_unit enableAI "MOVE";
_unit enableAI "AUTOTARGET";
_unit enableAI "TARGET";
_unit enableAI "ANIM";
[_unit] spawn A3A_fnc_FIAInit;
if (captive _unit) then { _unit setCaptive false };
Where it leads:

Calls: A3A_fnc_flagaction, A3A_fnc_FIAInit.
System Context: Used for "Rescue Refugees" missions.
Synchronization: remoteExec for actions, engine synchronization for group join.
Function Name: 
fn_mineSweep.sqf
What it does: Spawns an AI unit with a truck assigned to automatically find and disarm mines on the map. It manages the unit's travel to mine locations, the disarming animation, and the collection of mine parts into the truck.

How it does that:

Cost & Spawn:

Calculates the cost of an explosive specialist unit and a light transport truck.
Deducts the cost from the FIA resources.
Creates a group and a unit (typeExp - Explosive Specialist).
Creates the truck at a findEmptyPosition location.
Sqf

Apply
_costs = (server getVariable _typeExp) + ([_typeVeh] call A3A_fnc_vehiclePrice);
[-1,-1*_costs] remoteExec ["A3A_fnc_resourcesFIA",2];
_groupX = createGroup teamPlayer;
_unit = [_groupX, _typeExp, getMarkerPos respawnTeamPlayer, [], 0, "NONE"] call A3A_fnc_createUnit;
_truckX = _typeVeh createVehicle _pos;
Assignment & Initialization:

Initializes the truck with A3A_fnc_AIVEHinit.
Initializes the unit with A3A_fnc_FIAinit.
Assigns the truck to the group and orders the unit to get in.
Assigns the group to the High Command system (theBoss hcSetGroup).
Sqf

Apply
[_truckX, teamPlayer] call A3A_fnc_AIVEHinit;
[_unit] spawn A3A_fnc_FIAinit;
_groupX addVehicle _truckX;
[_unit] orderGetIn true;
theBoss hcSetGroup [_groupX];
Main Loop (Task Management):

Return to Base Logic: The loop checks if the unit is ready. If the truck has ammo (magazineCargo) and is near base, it transfers ammo to the global arsenal (A3A_fnc_ammunitionTransfer) and sleeps.
Mine Detection: It scans for mines (allmines) within 100m of the unit.
No Mines Found: If no mines are nearby, it waits until the unit becomes "not ready" (presumably moving via HC waypoint).
Sqf

Apply
_minesX = allmines select {(_x distance _unit) < 100};
if (count _minesX == 0) then {
    waitUntil {sleep 1;(!alive _unit) or (!unitReady _unit)};
}
Mines Found:
Ejects the unit from the truck.
Sorts mines by distance (closest first).
Iterates through the list.
Moves the unit to the mine position (doMove).
Waits until within 8m or timeout.
Disarming: Executes action ["Deactivate",_unit,_mineX].
Collection: Checks for WeaponHolderSimulated (the dropped mine parts) and adds the magazine to the truck cargo using addMagazineCargoGlobal.
Deletes the mine and the weapon holder.
Sqf

Apply
_unit doMove position _mineX;
// ... wait ...
_unit action ["Deactivate",_unit,_mineX];
sleep 3;
_toDelete = nearestObjects [position _unit, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 9];
if (count _toDelete > 0) then {
    _wh = _toDelete select 0;
    if (alive _truckX) then {_truckX addMagazineCargoGlobal [((magazineCargo _wh) select 0),1]};
    deleteVehicle _mineX;
    deleteVehicle _wh;
};
Where it leads:

Calls: A3A_fnc_resourcesFIA, A3A_fnc_createUnit, A3A_fnc_AIVEHinit, A3A_fnc_FIAinit, A3A_fnc_ammunitionTransfer.
System Context: A player-requested support action. It automatically clears fields of mines.
Synchronization: Resource changes are remoteExec. The unit actions are local to the unit (server or HC). Magazine cargo updates are global.
Function Name: 
fn_mortyAI.sqf
What it does: This is a "crew" script for a static mortar team (2 units). It manages the assembly and disassembly of the mortar. The mortar is created, the gunner mounts it, and if the spotter moves too far or combat becomes intense, the mortar is packed up again.

How it does that:

Initialization:

Identifies the two crew members (morty0 - spotter, morty1 - gunner).
Retrieves the backpack configuration (dissasembleTo) for the specific mortar type.
Sets a variable on the spotter defining their role (StaticMortar).
Sqf

Apply
params ["_groupX", "_typeX"];
private _morty0 = units _groupX select 0;
private _morty1 = units _groupX select 1;
(getArray (configFile/"CfgVehicles"/_typeX/"assembleInfo"/"dissasembleTo")) params ["_b0", "_b1"];
_morty0 setVariable ["typeOfSoldier", if (_typeX in FactionGet(reb,"staticMGs")) then { "StaticGunner" } else { "StaticMortar" }];
Assembly Loop:

Loop runs while both units are alive.
Wait Condition: Waits until both units are unitReady (finished previous orders/moving).
Placement: Finds an empty position near the spotter for the mortar.
Creation: Creates the mortar vehicle.
Backpack Removal: Removes the mortar backpacks from both units (simulating the physical assembly).
Assignment: Assigns morty1 as the gunner and forces them to get in.
Sqf

Apply
waitUntil {sleep 1; {((unitReady _x) and (alive _x))} count units _groupX == count units _groupX};
_pos = getPosATL _morty0 findEmptyPosition [1,30,_typeX];
_mortarX = _typeX createVehicle _pos;
removeBackpackGlobal _morty0;
removeBackpackGlobal _morty1;
_morty1 assignAsGunner _mortarX;
[_morty1] orderGetIn true;
[_morty1] allowGetIn true;
Disassembly Logic:

Wait Condition: Waits until a unit dies OR morty0 (spotter) is no longer ready (meaning he is moving).
Check: If both are alive and the spotter is moving, it implies the team is repositioning. The mortar is disassembled.
Restoration: Backpacks are added back to the units.
Cleanup: The gunner is unassigned, moved out, and the mortar vehicle is deleted.
Sqf

Apply
waitUntil {sleep 1; ({!(alive _x)} count units _groupX != 0) or !(unitReady _morty0)};
if (({(alive _x)} count units _groupX == count units _groupX) and !(unitReady _morty0)) then {
    _morty0 addBackpackGlobal _b0;
    _morty1 addBackpackGlobal _b1;
    unassignVehicle _morty1;
    moveOut _morty1;
    deleteVehicle _mortarX;
};
Where it leads:

Depends on: FactionGet for static weapon config.
System Context: Used for AI-controlled mortar teams (rebels or enemies). It allows them to be mobile but requires them to stop and set up to fire.
Synchronization: Backpacks and vehicle creation are handled globally (via Global suffix commands or engine synchronization).
Function Name: 
fn_napalm.sqf
What it does: The server-side controller for a napalm strike. It manages the timing of audio (explosion and burning sounds), spawns fire particles on relevant clients, and applies damage to objects within the radius.

How it does that:

Setup & Validation:

Runs only on the server.
Ensures _pos has a Z coordinate.
Defines duration (90 seconds) and radius (30m).
Registers the napalm instance in a namespace (A3A_NapalmRegister) with a unique ID to track active effects.
Sqf

Apply
if (!isServer) exitWith {false};
private _endTime = serverTime + 90;
private _napalmRadius = 30;
isNil {
    _napalmID = [localNamespace,"A3A_NapalmRegister","IDCounter",-1] call A3A_fnc_getNestedObject;
    _napalmID = _napalmID + 1;
    [localNamespace,"A3A_NapalmRegister","IDCounter",_napalmID] call A3A_fnc_setNestedObject;
    _storageNamespace = [localNamespace,"A3A_NapalmRegister",str _napalmID,"active",true] call A3A_fnc_setNestedObject;
};
Audio Thread:

Plays the initial explosion sound (expl_big_3) locally at the position.
Spawns a separate thread that loops a burning sound (fire1_loop) until the end time minus the audio duration. This ensures continuous audio feedback.
Sqf

Apply
playSound3D ["a3\sounds_f\weapons\explosion\expl_big_3.wss",_pos, false, AGLToASL _pos, 5, 0.6, 3000];
[_pos,_endTime,_cancellationTokenUUID] spawn {
    // ... loops playSound3D while serverTime < _audioEndTime ...
};
Visual Effect & Damage Loop:

Hiding Objects: Hides trees/bushes near the impact to prevent visual clipping with the fire.
Main Loop: Runs every 5 seconds until _endTime.
Particle Rendering:
Filters allPlayers to find those who haven't rendered this specific napalm instance yet.
Marks them as processed in _storageNamespace.
Remotely executes A3A_fnc_napalmParticles on those clients.
Damage Application:
Finds all objects near the position.
Filters them to ensure they aren't currently being damaged by another napalm instance (using A3A_napalm_processing variable to prevent overlap).
Sets a processing timestamp on the object.
Remotely executes A3A_fnc_napalmDamage on the specific owner of the object (0 = server, >0 = client owner).
Sqf

Apply
while {_endTime > serverTime && !([_cancellationTokenUUID] call _fnc_cancelRequested)} do {
    // Particle Rendering Logic
    isNil {
        _allRenderers = _allRenderers select { ... };
        { _storageNamespace setVariable [getPlayerUID _x, true]; } forEach _allRenderers;
    };
    { [_pos, _startTime,_cancellationTokenUUID] remoteExec ["A3A_fnc_napalmParticles",_x]; } forEach _allRenderers;

    // Damage Logic
    private _victims = (_pos nearObjects ["All", _napalmRadius]);
    private _crew = [];
    { _crew append crew _x; } forEach _victims;
    _victims append _crew;
    isNil {
        _victims = _victims select { !isNull _x && {(_x getVariable ["A3A_napalm_processing",0]) < serverTime}};
        { _x setVariable ["A3A_napalm_processing",serverTime + 30]; } forEach _victims;
    };
    {
        private _owner = owner _x;
        if (_owner isEqualTo 0) then { _owner = 2; };
        [_x, true,_cancellationTokenUUID] remoteExecCall ["A3A_fnc_napalmDamage",_owner];
    } forEach _victims;
    uiSleep 5;
};
Where it leads:

Calls: A3A_fnc_getNestedObject, A3A_fnc_setNestedObject, A3A_fnc_napalmParticles, A3A_fnc_napalmDamage.
System Context: Used for weapon effects (air strikes, mortars, scripted events).
Synchronization: Uses remoteExec to trigger effects on clients. Uses a local namespace for tracking state.
Function Name: 
fn_napalmDamage.sqf
What it does: Applies damage and effects to a single object hit by napalm. It handles different damage logic for infantry (killing/medics), vehicles (burning/immobilizing), and objects (destruction).

How it does that:

Validation:

Checks if object is null, dead, damage disabled, or hidden.
Defines damage parameters: _overKill (to prevent healing fixing it instantly), _timeToLive (6s), _totalTicks (3 ticks of damage).
Sqf

Apply
if (isNull _victim) exitWith {false};
if (isNil { if (!alive _victim || {!isDamageAllowed _victim} || {isObjectHidden _victim}) exitWith {nil}; 1; }) exitWith {true};
Dynamic Function Compilation (Per Object Type):

Uses a switch statement based on the object kind to generate specific SQF code strings for init, onTick, and final actions.
CAManBase (Infantry):
If ACE Medical is active: Uses ace_medical_fnc_addDamageToUnit with specific hit selection ("Body").
If Vanilla: Adds damage directly.
Plays random injured sounds (A3A_sounds_soundInjured_max) every 2 ticks.
AllVehicles:
Clears all cargo (weapons, mags, items).
Applies damage to HitHull (capped at 0.8 to prevent destruction) and other hitpoints.
Sets thermal inertia (setVehicleTIPars) to heat up the vehicle.
If the vehicle has a horn, plays the horn sound intermittently to simulate distress.
Buildings/ReammoBox: Applies damage (capped at 0.5 for buildings) and eventually deletes the object if it's a crate.
Sqf

Apply
switch (true) do {
    case (_victim isKindOf "CAManBase"): {
        if (A3A_hasACEMedical) then {
            _fnc_onTick = _fnc_onTick + '[ _victim, 1*'+ str _damagePerTick +' , "Body", "grenade"] call ace_medical_fnc_addDamageToUnit;';
        } else {
            _fnc_onTick = _fnc_onTick + '_victim setDamage [(damage _victim + '+ str _damagePerTick +') min 1, true];';
        };
        // ... sound logic ...
    };
    case (_victim isKindOf "AllVehicles"): {
        _fnc_init = _fnc_init + 'clearMagazineCargoGlobal _victim; ...';
        _fnc_onTick = _fnc_onTick + '_victim setHitPointDamage ["HitHull",(((_victim getHitPointDamage "HitHull") + ' + str _damagePerTick + ') min 0.8) ...];';
        // ... thermal and horn logic ...
    };
    // ... other cases ...
};
Execution:

Compiles the generated strings into functions.
Spawns a thread that sleeps a random amount (to desync effects), calls init, loops through damage ticks (sleeping between them), and calls final.
Sqf

Apply
[_victim,_cancellationTokenUUID,_timeBetweenTicks,_totalTicks,compile _fnc_init,compile _fnc_onTick, compile _fnc_final] spawn {
    // ... loop ...
    [_victim, _tickCount] call _fnc_onTick;
    uiSleep _timeBetweenTicks;
};
Where it leads:

Calls: ace_medical_fnc_addDamageToUnit (if ACE).
System Context: Called by fn_napalm to damage specific objects.
Synchronization: Logic is local to the object's owner.
Function Name: 
fn_napalmParticles.sqf
What it does: Generates the visual fire and smoke particle effects on the client. It creates light sources, fire particles (red/yellow/white), and manages their lifecycle (dimming and deletion).

How it does that:

Setup:

Runs only on clients (hasInterface).
Creates two light sources (#lightpoint): A primary orange light and an accent white light.
Sets light properties (brightness, color, ambient).
Sqf

Apply
if (!hasInterface) exitWith {false};
private _lightPrimary = "#lightpoint" createVehicleLocal [ _pos#0, _pos#1, _pos#2 + 10];
_lightPrimary setLightBrightness 21.4;
// ... set color/ambient ...
Particle Source Creation:

Creates three #particlesource objects:
_fireRed: Large red billboards (base fire).
_fireYellow: Yellow billboards (inner flame).
_fireWhite: Small white particles (smoke/embers).
Each has specific setParticleParams defining shape, size, velocity, and color gradient.
setParticleCircle defines the spread radius (20m).
Sqf

Apply
private _fireRed = "#particlesource" createVehicleLocal _posAdj;
_fireRed setParticleParams [["a3\data_f\ParticleEffects\Universal\Universal.p3d", 16, 1, 12, 0], "", "Billboard", 1, 2 + random 3, [0, 0, 5], _velocity, 1, 1.1, 1, 0, [1 + (random 1.1)], [_colour + [0], _colour + [_alpha], _colour + [0]], [1000], 1, 0, "", "", 1];
_fireRed setParticleCircle [20, [0, 0, 0]];
Light Dimming & Cleanup:

Spawns a thread to handle the accent light dimming over 75 seconds.
Creates a list of effects with their lifetimes.
Loops through the list, sleeping until it's time to delete a specific effect (e.g., White fire dies at 10s, Red fire at 90s).
Sqf

Apply
[_lightAccent,_startTime,_cancellationTokenUUID] spawn {
    // ... dims brightness ...
};
private _effectLifetimes = [
    [10,_fireWhite],
    [90,_fireRed],
    // ...
];
_effectLifetimes sort true;
while {count _effectLifetimes > 0} do {
    uiSleep ((_startTime + _effectLifetimes#0#0 - serverTime) max 0.01);
    deleteVehicle (_effectLifetimes#0#1);
    _effectLifetimes deleteAt 0;
};
Where it leads:

System Context: Visual client-side component of the napalm effect.
Synchronization: Local only.
Function Name: 
fn_nearEnemy.sqf
What it does: A utility function that returns the first living, non-vehicle enemy unit found in a group's cached objective list.

How it does that:

Retrieval:

Takes the group (_this) as input.
Retrieves the objectivesX variable (an array of targets).
Iterates through the array.
Checks if the entity (_eny) is equal to its vehicle (meaning they are not inside a vehicle).
Exits the loop immediately upon finding a match and returns the unit.
Sqf

Apply
private _groupX = _this;
private _result = objNull;
_enemiesX = _groupX getVariable ["objectivesX",[]];
if (count _enemiesX > 0) then {
    for "_i" from 0 to (count _enemiesX) - 1 do {
        _eny = (_enemiesX select _i) select 4;
        if (vehicle _eny == _eny) exitWith {_result = _eny};
    };
};
_result
Where it leads:

System Context: Used by AI logic to determine who to shoot at if they need a specific target.
Synchronization: Local only. Reads group variables.

fn_orbitalLanding.sqf
Function Name: fn_orbitalLanding.sqf

What it does: This function performs a coordinated orbital drop deployment of a group using one or more landing pods. It handles the logistics of assigning units to pods based on seat capacity, calculating landing positions, executing the drop animation (including particle effects and explosive charges to simulate atmospheric entry), managing unit safety during the drop, and post-landing behavior (opening doors, providing smoke cover, and issuing attack orders).

It is typically called by mission systems (like QRF or reinforcement scripts) to deploy infantry groups from high altitude, bypassing the need for standard transport aircraft.

How it does that:

Parameter Validation & Initialization: The function begins by extracting parameters and performing basic calculations.

Parameters: _pod (object, the main pod to use), _groupX (group, the units to deploy), _positionX (array/vector, the target drop location), _posOrigin (array/vector, the spawn origin, unused here but passed).
Calculations: It generates a randomized landing offset (_dist) to avoid clustering and determines the final landing coordinate (_landpos).
Code:
Sqf

Apply
params ["_pod", "_groupX", "_positionX", "_posOrigin"];

_dist = 1 + random 100;
_landpos = _positionX getPos [_dist, random 360];
Pre-Drop Safety & Seat Analysis: Units are made invulnerable to prevent instant death during the rapid descent. The pod's seat capacity is calculated to determine deployment logic.

Logic: Disable damage on all units in the group.
Logic: Use BIS_fnc_crewCount to determine available seats, including cargo.
Code:
Sqf

Apply
{
    _x allowDamage false;
} forEach units _groupX;

private _podseats = 0;
_podseats = [typeOf _pod, true] call BIS_fnc_crewCount;
private _groupcount = count (units _groupX);
Standard Deployment (Seats >= Group Size): If the pod has enough room for the entire group, units are assigned as cargo.

Logic: Iterate through units and assign them to the pod's cargo seats.
Code:
Sqf

Apply
if (_podseats >= _groupcount) then {
    {
        _x assignAsCargo _pod;
        _x moveInCargo _pod;
    } forEach units _groupX;
};
Waypoint Setup: Pre-configures the group's immediate post-drop behavior. The group will move to the target and enter combat mode (SAD - Search and Destroy).

Waypoint 1 (Move to Leader): Forces the group to organize initially.
Waypoint 2 (Move to Target): Sets the destination and triggers an attack drill upon arrival.
Waypoint 3 (SAD): Sets the group to seek and destroy enemies at the target location.
Code:
Sqf

Apply
private _wp2 = _groupX addWaypoint [(position (leader _groupX)), 0];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI"];

_wp2 = _groupX addWaypoint [_positionX, 1];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true","if !(local this) exitWith {}; {if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];

_wp2 = _groupX addWaypoint [_positionX, 2];
_wp2 setWaypointType "SAD";
The Drop Sequence (Multiple Seats): This block executes the visual and physical drop. It is skipped if the pod only has 1 seat (handled later).

Preparation: Sets pod behavior and locks it.
Positioning: Teleports the pod to 3000m altitude.
Effects: Calls SCRT_fnc_effect_orbitalDropEffect (visuals) and spawns an explosive charge (DemoCharge_Remote_Ammo_Scripted) to simulate atmospheric entry friction/damage.
Impact: The pod is set to 1m altitude instantly (simulating a hard crash landing).
Recovery: Re-enables damage for units/pod, waits, and opens pod doors via A3A_fnc_PodsDoors.
Smoke: Calls A3A_fnc_smokeCoverAuto to deploy smoke grenades for cover.
Code Snippet (Impact Simulation):
Sqf

Apply
_bomb = "DemoCharge_Remote_Ammo_Scripted" createVehicle [0,0,0];
_bomb setPosWorld (position _pod); 
_bomb setDamage 1;

sleep 0.2;
_pod setPos [(getPos _pod select 0),(getPos _pod select 1),1];
Post-Drop Ejection: If the group was loaded into the pod, they must be removed.

Logic: Toggles Eject and leaveVehicle actions on alternating units to prevent all exiting at the exact same coordinate.
Code:
Sqf

Apply
if (_podseats >= _groupcount) then {
    private _second = false;
    {
        if (_second) then {
            _x action ["Eject", _pod];
            unassignVehicle _x;
            _second = false;
        } else {
            _second = true;
            _x leaveVehicle _pod;
        };
        private _second = true; // (Note: This line in the original code resets the variable inside the loop, effectively toggling it every iteration)
    } forEach units _groupX;
};
Handling Insufficient Seats / Single Seat Logic: If the group is too large for the pod or the pod is a single-seater (like a dedicated drop pod).

Single Seat Case (_podseats == 1): For every unit in the group, it creates a new pod and spawns the dedicated single-pod drop function (fn_orbitalLandingSinglePod).
Multi-Seat Shortage (_podseats < _groupcount): If there are too many units for one pod but more than one seat, it simply teleports the excess units to a safe position near the pod. This is a fallback for when logic fails or pods don't support the unit count.
Code:
Sqf

Apply
if (_podseats < _groupcount) then {
    if (_podseats == 1) then {
        {
            _podX = typeOf _pod createVehicle position _x;
            [_podX, _pod, _dist, _x, _positionX, _posOrigin] spawn A3A_fnc_orbitalLandingSinglePod;
            sleep 2;
        } forEach units _groupX;
    } else {
        {
            _SafeMovePos = [getPos _pod, 1, 3, 3, 1, 20, 0] call BIS_fnc_findSafePos;
            _x setPos _SafeMovePos;
            sleep 0.02;
        } forEach units _groupX;	
    };
};
Cleanup: Handles deletion of temporary objects and scheduling despawning.

Logic: If the pod was a 1-seater, the original placeholder pod is deleted.
Logic: Schedules despawning of the drop pod(s) and the single-pod instance variable (though _podX is local to the loop scope, the despawner call targets the main _pod usually).
Code:
Sqf

Apply
if (_podseats == 1) then {
    deleteVehicle driver _pod;
    deleteVehicle _pod;
};
[_podX] spawn A3A_fnc_VEHDespawner;
[_pod] spawn A3A_fnc_VEHDespawner;
Where it leads:

Functions Called:

BIS_fnc_crewCount: Determines the seating capacity of the pod class.
A3A_fnc_attackDrillAI: Called via waypoint statement; initializes combat tactics for the group.
SCRT_fnc_effect_orbitalDropEffect: (External dependency) Creates visual effects for the orbital drop.
A3A_fnc_PodsDoors: Opens the pod doors after landing.
A3A_fnc_smokeCoverAuto: Deploys smoke cover around the pod.
BIS_fnc_findSafePos: Used to find a safe landing spot for excess units.
A3A_fnc_orbitalLandingSinglePod: Spawns per unit if the pod is a 1-seater.
A3A_fnc_VEHDespawner: Scheduled to clean up the pod vehicle(s) later.
Dependencies:

Input: Relies on the SCRT mod for effects (or a dummy function if not present).
Global Variables: Modifies unit invulnerability temporarily.
Network: Creates units/vehicles locally (must be called on server or HC for persistency). The drop effects are visual and local to clients.
Larger System Integration: This function is part of the reinforcement/response system. It allows AI to deploy troops directly to a battlefield without traditional airfields or low-altitude flyovers, simulating sci-fi/halo-style reinforcements. It integrates with the attackDrillAI system to ensure troops are combat-ready immediately upon landing.

fn_orbitalLandingSinglePod.sqf
Function Name: fn_orbitalLandingSinglePod.sqf

What it does: This is a helper function specifically designed to handle the orbital drop of a single unit within its own pod. It is spawned when fn_orbitalLanding encounters a pod type with only 1 seat (e.g., a dedicated drop pod like the HEV from Halo or similar mods).

How it does that:

Parameter Extraction: Accepts the specific pod object, the unit to be carried, and location data.

Code:
Sqf

Apply
params ["_podX", "_pod", "_dist", "_x", "_positionX", "_posOrigin"];
Pod Configuration & Positioning: Sets up the pod for the drop. It recreates the pod vehicle (redundant if _podX was already created in the parent function, but safe).

Logic: Locks the pod, sets invulnerability, calculates a landing position relative to the main group's landpos (with randomization to spread impacts).
Code:
Sqf

Apply
_podX allowDamage false;
_podX lock 2;
_podX setVehicleLock "LOCKED";

_landPos = _positionX getPos [_dist, random 360];

_podX = typeOf _pod createVehicle position _x;
_podX setPos [((_landpos select 0) + random 30),((_landpos select 1) - random 30), 3000];
_podX setVelocity [0,0,-135];
Unit Embarkation: Assigns the specific unit to the new pod.

Code:
Sqf

Apply
_x moveInAny _podX;
Drop Execution (Visuals & Physics): Similar to the main function, it simulates atmospheric entry.

Effects: Calls SCRT_fnc_effect_orbitalDropEffect.
Impact: Spawns a scripted explosive charge to simulate friction/impact. Sets velocity to 0.
Landing: Teleports the pod to ground level (0.5m).
Code:
Sqf

Apply
_bomb = "DemoCharge_Remote_Ammo_Scripted" createVehicle [0,0,0];
_bomb setPosWorld (position _podX); 
_bomb setDamage 1;

sleep 0.05;

_podX setPos [(getPos _podX select 0),(getPos _podX  select 1),0.5];
Unit Recovery & Ejection: Re-enables damage, opens the pod, waits for the unit to stabilize, and ejects them.

Logic: Opens doors immediately, waits for dust/smoke to settle (1.55s), then ejects the unit.
Code:
Sqf

Apply
sleep 0.45;
[_podX, "open"] spawn A3A_fnc_PodsDoors;

sleep 1.55;

_x action ["Eject", _podX];
_x leaveVehicle _podX;
Cleanup: Schedules the single-pod vehicle for despawning.

Code:
Sqf

Apply
[_podX] spawn A3A_fnc_VEHDespawner;
Where it leads:

Functions Called:

SCRT_fnc_effect_orbitalDropEffect: Visuals for the drop.
A3A_fnc_PodsDoors: Opens the pod.
A3A_fnc_VEHDespawner: Deletes the pod after a delay.
Dependencies:

Called directly from fn_orbitalLanding when a 1-seat pod is detected.
Modifies the position and state of the _x unit (the passenger).
Larger System Integration: This function allows the orbital drop system to scale. Instead of limiting orbital drops to pod capacities (e.g., 4 or 8 men), it enables dropping a squad of 10 by spawning 10 individual pods, each following the same logic but independently.

fn_paradrop.sqf
Function Name: fn_paradrop.sqf

What it does: This function orchestrates a standard infantry paradrop from an air vehicle (plane or helicopter). It handles the aircraft's flight path to the drop zone, manages pilot AI (preventing them from engaging), ensures the aircraft slows down appropriately, performs the actual unit ejection (including parachute creation), and manages post-drop behavior (smoke cover, combat readiness).

How it does that:

Parameter & Pilot Setup: Extracts arguments and disables pilot combat AI to prevent the transport from attacking targets during the drop run.

Logic: Gets the pilot group, disables targeting AI, sets behavior to "CARELESS".
Code:
Sqf

Apply
params [ ["_vehicle", objNull, [objNull]], ... ];
private _groupPilot = group driver _vehicle;
{
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x setBehaviour "CARELESS";
} foreach (units _groupPilot);
Flight Configuration: Configures the vehicle based on type (Helicopter vs Plane).

Logic: Sets flyInHeight (650m for planes, 500m for helis). Sets direction and velocity for planes to ensure forward momentum.
Code:
Sqf

Apply
_vehicle flyInHeight 650;
_vehicle setCollisionLight false;
if(_vehicle isKindOf "Helicopter") then {
    _vehicle flyInHeight 500;
} else {
    _vehicle setDir (_originPosition getDir _targetPosition);
    _vehicle setVelocityModelSpace [0, 100, 0];
};
Drop Zone Calculation: Finds a suitable drop position near the target, ensuring it isn't over water.

Logic: Loops up to 10 times to find a valid surface position within 150-300m of the target.
Code:
Sqf

Apply
private _dropPos = _targetPosition;
for "_i" from 1 to 10 do {
    private _testPos = _dropPos getPos [random 150 + 150, random 360];
    if !(surfaceIsWater _testPos) exitWith { _dropPos = _testPos };
};
Waypoint Generation: Creates waypoints for the pilot group: Entry point, Drop point, and Exit point. Entry/Exit points are at 500m altitude to create a smooth flight path.

Logic: Calculates angles and positions 100m before and 300m after the drop zone.
Code:
Sqf

Apply
private _wp = _groupPilot addWaypoint [_entryPos, 0];
_wp setWaypointType "MOVE";
// ... additional waypoints for exit/origin
Speed Limiting (Crucial Step): The function actively manages the vehicle's speed as it approaches the drop zone to prevent overshooting.

Logic: Uses limitSpeed to slow the vehicle down progressively based on distance (3000m, 2000m, 1500m). VTOLs and Helis have different speed profiles.
Code:
Sqf

Apply
if (_vehType in FactionGet(all,"vehiclesTransportAir")) then {
    waitUntil {sleep 1; (_vehicle distance2D _dropPos) < 3000};
    _vehicle limitSpeed ((0.8 * (getNumber(configOf _vehicle >> "maxSpeed"))) min 500);
    // ... further steps
};
Flare Deployment: Spawns a background script to fire flares as the vehicle gets close to the drop zone (visual effect and distraction).

Logic: Waits until distance < 800m, then loops firing various flare launchers every 0.3s until the vehicle is very close (675m).
Code:
Sqf

Apply
[_vehicle, _dropPos] spawn {
    params ["_vehicle", "_dropPos"];
    waitUntil {sleep 1; (_vehicle distance2D _dropPos) < 800};
    while {_vehicle distance2D _dropPos > 675} do {
        [_vehicle, "CMFlareLauncher"] call BIS_fnc_fire;
        // ... more flare calls
        sleep 0.3;
    };
};
Unit Ejection & Parachute Creation: Waits for the vehicle to reach the drop point (waypoint index > 0), then ejects units.

Logic:
Calculates troop velocity based on vehicle velocity (20% forward speed, negative Z).
Alternates unit positions (left/right of vehicle) to prevent parachute collisions.
Sets unit position and velocity.
Parachute Script: A sub-spawn handles the parachute logic.
Waits for altitude to drop below 120m.
Creates Steerable_Parachute_F.
Moves unit into parachute.
Smoke Cover: If not "lowTech", creates a smoke grenade attached to the unit, deploys it upon ground contact, and deletes the chute.
Code Snippet (Unit Ejection):
Sqf

Apply
{
    unAssignVehicle _x;
    private _pos = if (_forEachIndex % 2 == 0) then {_vehicle modeltoWorld [7, -20, -5]} else {_vehicle modeltoWorld [-7, -20, -5]};
    _x setPosASL AGLtoASL _pos;
    _x setVelocity _troopVelocity;
    _x spawn { /* parachute logic */ };
    sleep 0.5;
} forEach units _groupJumper;
Post-Drop Aircraft & Group Behavior:

Aircraft: Fires more flares, then flies back to origin.
Ground Group: If the vehicle is an attack heli, it switches to A3A_fnc_attackHeli. Otherwise, it waits for the leader to land, deletes pilot waypoints, and adds combat waypoints (Move -> SAD). If marked as reinforcement (_isReinforcement), it skips the SAD waypoint.
Code (Group Combat Logic):
Sqf

Apply
waitUntil { sleep 1; isTouchingGround leader _groupJumper };
sleep 10; // wait for others
_wpMove = _groupJumper addWaypoint [_targetPosition, 0];
_wpMove setWaypointType "MOVE";
// ... SAD waypoint added if not reinforcement
Where it leads:

Functions Called:

FactionGet: Retrieves faction vehicle lists for type checking.
BIS_fnc_fire: Used for firing flares.
AGLtoASL / modeltoWorld: Coordinate conversions for ejection.
A3A_fnc_attackHeli: Called if the vehicle is an attack heli (drops troops then attacks).
A3A_fnc_attackDrillAI: Called via spawn on the jumper group after landing (if not reinforcement).
Dependencies:

Global Variables: A3A_factionEquipFlags, disableAutoSmokeCover (checks for "lowTech" flag).
Config: Reads maxSpeed from vehicle config.
Network: Spawns units and vehicles locally; needs to run on server for persistent groups.
Larger System Integration: This is the core infantry deployment function for air transport. It is used by QRF, reinforcements, and mission scripts to get troops to the field without them walking. It handles the complex "runway" logic of air vehicles automatically.

fn_PodsDoors.sqf
Function Name: fn_PodsDoors.sqf

What it does: A utility function that opens or closes the doors of various drop pod vehicle types. It supports multiple animation names to be compatible with different mods (Vanilla, OPTRE, SW, CIS).

How it does that:

Parameter Parsing: Extracts the pod object and the desired state ("open" or "close").

Logic: Converts string states to numerical values (1 for open, 0 for close).
Code:
Sqf

Apply
params ["_pod", "_state"];
switch _state do { case "open": { _state = 1;}; case "close": { _state = 0;}; };
Animation Execution: Applies animation commands to the vehicle. It attempts multiple animation names to cover different vehicle classes.

Logic: Uses animateDoor and animate for common animation sources.
Covered Types:
Taru (Vanilla): Door_4_source, Door_5_source, Door_6_source.
OPTRE HEV: Doors.
SW CIS Droid: deploy.
SW Republic/Empire: open_door, open_door_2, Ramp.
Code:
Sqf

Apply
_pod animateDoor ["Door_4_source", _state];
_pod animateDoor ["Door_5_source", _state];
_pod animate ["Door_4_source", _state];
// ... more animation calls
_pod animateDoor ["Door_6_source", _state]; // Taru ramp
Where it leads:

Functions Called:

None directly (uses BIS commands).
Dependencies:

Requires the target object to be a vehicle with compatible memory points (anim sources).
Called by fn_orbitalLanding and fn_orbitalLandingSinglePod.
Larger System Integration: This abstracts the complexity of different vehicle mod definitions. Without this, the orbital drop script would need specific logic for every pod type. It ensures mod compatibility.

fn_rearmCall.sqf
Function Name: fn_rearmCall.sqf

What it does: A simple wrapper function that iterates through a list of units (passed via _this), and for each unit, calls the appropriate auto-rearm or auto-loot function. It staggers the execution with a random sleep to prevent performance spikes.

How it does that:

Iteration & Type Check: Checks if the unit is on foot or in a vehicle.
Logic: If the unit is not in a vehicle (vehicle _x == _x), spawn A3A_fnc_autoRearm. If inside a vehicle, spawn A3A_fnc_autoLoot (looting the vehicle).
Code:
Sqf

Apply
{
    if (vehicle _x == _x) then {[_x] spawn A3A_fnc_autoRearm} else {[_x,vehicle _x] spawn A3A_fnc_autoLoot};
    sleep (3 + random 5);
} forEach _this;
Where it leads:

Functions Called:

A3A_fnc_autoRearm: Handles rearming a foot soldier.
A3A_fnc_autoLoot: Handles looting a vehicle.
Dependencies:

Input: A list of units (array).
Execution: Runs on the server or HC.
Larger System Integration: Used in supply logistics or after combat to ensure AI units are equipped. It provides a batch processing method for rearming groups.

fn_recallGroup.sqf
Function Name: fn_recallGroup.sqf

What it does: This function issues movement orders to a group to move them to their current waypoint destination. It is used to "recall" or "recall" a group that has stalled or been distracted, forcing them to continue their path rather than idling.

How it does that:

Input Parsing: Accepts a group or a single unit. Normalizes input into an array of units.

Logic: If input is a group, gets units. Excludes a mortar unit variable if present.
Code:
Sqf

Apply
private _groupX = _this;
private _array = if (_groupX isEqualType grpNull) then {((units _groupX) - [_groupX getVariable ["mortarX",objNull]])} else {[_groupX]};
Movement Logic: Iterates through units. Leaders move to the current waypoint position; subordinates follow the leader.

Logic:
Resets speed limit (forceSpeed -1).
Clears "maneuvering" state.
If unit is leader: doMove to current waypoint position.
If unit is subordinate: doFollow the leader.
Code:
Sqf

Apply
{
    _x forceSpeed -1;
    _x setVariable ["maneuvering",false];
    if (_x == leader _x) then {
        _wp = currentWaypoint group _x;
        _dest = waypointPosition [group _x,_wp];
        _x doMove _dest;
    } else {
        _x doFollow leader _x;
    };
} forEach _array;
Group State Reset: Clears the "occupiedX" variable on the group (likely indicating they are free to move).

Code:
Sqf

Apply
(group (_array select 0)) setVariable ["occupiedX",[]];
Where it leads:

Functions Called:

None (uses BIS commands doMove, doFollow, waypointPosition).
Dependencies:

Relies on the group having an active waypoint.
Relies on the mortarX variable if the group contains a mortar team.
Larger System Integration: Used by AI command scripts to ensure groups don't get stuck in building garrisons or combat animations and actually traverse the map.

fn_smokeCoverAuto.sqf
Function Name: fn_smokeCoverAuto.sqf

What it does: Automatically deploys smoke cover around a vehicle. It checks if smoke cover is disabled globally, if the vehicle is alive/local, and if smoke was recently used. It prefers using the vehicle's own smoke launchers; if unavailable, it creates manual smoke grenades on the ground.

How it does that:

Validation: Checks global config and vehicle state.

Logic: Exits if disableAutoSmokeCover is true, vehicle is dead, or not local to the machine.
Code:
Sqf

Apply
if (disableAutoSmokeCover) exitWith {};
if !(alive _veh) exitWith {};
if !(local _veh) exitWith {};
Cooldown Check: Uses a vehicle variable _smoked to prevent spam.

Logic: If current time is less than the stored time in _smoked, exit.
Code:
Sqf

Apply
private _smoked = _veh getVariable ["smoked",0];
if (time < _smoked) exitWith {};
_veh setVariable ["smoked",time + 120]; // 2 minute cooldown
Smoke Deployment: Checks if the vehicle has SmokeLauncher weapons. If so, fires them. If not, spawns smoke grenades in a circle around the vehicle.

Logic (Launchers): Iterates through turrets, looks for "SmokeLauncher", fires it.
Logic (Grenades): Creates 9 smoke grenades at random offsets (28-30m radius) around the vehicle.
Code (Grenades):
Sqf

Apply
private ["_pos","_smokeX"];
_typeSmoke = selectRandom allSmokeGrenades;
for "_i" from 0 to 8 do {
    _pos = position _veh getPos [(28 + random 2),_i*40];
    _smokeX = _typeSmoke createVehicle [_pos select 0, _pos select 1,getPos _veh select 2];
};
Where it leads:

Functions Called:

BIS_fnc_fire: Used to fire vehicle smoke launchers.
Dependencies:

Global Variables: disableAutoSmokeCover, allSmokeGrenades.
Config: Vehicle turret weapons.
Network: Spawns objects locally; must run where the vehicle is local.
Larger System Integration: Used by fn_orbitalLanding and general AI survival scripts to increase unit survivability during ambushes or landings. It acts as a reactive defense measure.

A3A/addons/core/functions/AI/fn_rearmCall.sqf
Function Name: fn_rearmCall.sqf
What it does: This function orchestrates the rearm or auto-looting of individual units within a group. It determines whether each unit should perform self-rearmment or vehicle looting based on whether they are currently inside a vehicle. The function processes units sequentially with a randomized delay between each unit's action to prevent performance spikes and synchronization issues. It's primarily called by UI interactions (buttons) and other mission systems that need to trigger equipment resupply for AI or player-controlled units.

Context: The function is called in two main scenarios:

Through the dialog UI (r1Button and autoLootButtonClicked cases), where players can select units and trigger rearm/loot operations
Directly from other mission systems that need to automatically manage unit equipment states
How it does that: The function iterates through each unit passed as the parameter (_this), performing a type check to determine the appropriate action, then executes that action with a delay.

Implementation Breakdown:
1. Parameter Processing and Loop Structure:

Sqf

Apply
{
	// ... body of loop ...
} forEach _this;
The function uses a forEach loop to process each element in _this (the input array)
Each iteration represents one unit (or vehicle) that needs rearm/loot processing
The loop implicitly processes _x as the current iteration variable
2. Unit/Vehicle Type Detection:

Sqf

Apply
if (vehicle _x == _x) then {[_x] spawn A3A_fnc_autoRearm} else {[_x,vehicle _x] spawn A3A_fnc_autoLoot};
Condition Check: vehicle _x == _x determines if the unit is outside a vehicle
When true: Unit is dismounted, needs personal equipment rearm
When false: Unit is mounted in a vehicle, needs vehicle loot collection
Dismounted Case: Spawns A3A_fnc_autoRearm with just the unit as parameter
Mounted Case: Spawns A3A_fnc_autoLoot with both unit and vehicle as parameters
3. Execution Delay:

Sqf

Apply
sleep (3 + random 5);
Applies a random delay between 3 to 8 seconds (3 + 0-5)
Prevents synchronization issues between multiple unit processing
Reduces performance impact by spreading computational load
Creates a staggered execution pattern for better visual and network performance
4. Loop Completion:

The forEach loop automatically continues until all elements in _this are processed
No explicit return value is needed since all operations are spawned as separate processes
The original calling context receives no direct feedback, as all operations are asynchronous
Parameter Validation and Edge Cases:
Input Type: _this expects an array, but SQF is dynamically typed
If a single unit (object) is passed, it's automatically treated as a single-element array
If grpNull or other invalid types are passed, the loop may throw errors
Vehicle Check: vehicle _x == _x is robust for all entity types
Works with any vehicle type (car, helicopter, tank, boat)
Handles cases where _x itself is a vehicle (though not typical in this context)
Empty Arrays: If _this is empty, the loop simply doesn't execute
Mixed Input: Can accept mixed arrays of units and vehicles, though this is unlikely in practice
Called Functions:
A3A_fnc_autoRearm

Purpose: Automatically rearms a single dismounted unit with available weapons and ammunition
Called when: Unit is not in a vehicle
Parameters: [unit] - the unit to rearm
Expected behavior: Searches for nearby gear/ammunition and reassigns to the unit
A3A_fnc_autoLoot

Purpose: Automatically loots items from nearby vehicles or crates into the unit's inventory
Called when: Unit is inside a vehicle
Parameters: [unit, vehicle] - both the unit and their vehicle
Expected behavior: Transfers usable items from vehicle to unit's inventory
Dependencies and System Integration:
This function depends on:

No direct global variables are modified
No network synchronization is required (operations are local to the client/server that calls it)
The spawned child functions handle all logic and side effects
Functions that depend on this:

UI Dialog Actions (from r1Button and autoLootButtonClicked in the dialog):
r1Button calls with units group player when no specific units are selected
r1Button calls with groupselectedUnits player when units are selected
autoLootButtonClicked calls with selected units from the AI listbox
Any mission system that needs to trigger automatic equipment management for groups of units
Global Variables Modified:

None directly in this function
The spawned functions (autoRearm and autoLoot) may modify global state through inventory management, but that's handled elsewhere
Synchronization/Network Implications:

All operations are spawned (asynchronous), so they don't block the calling thread
Since spawning happens locally, each unit's processing is independent
If called on a server, each spawned function runs server-side
If called on a client, each spawned function runs client-side (for player-controlled units)
No network traffic is generated by this function itself - the spawned functions handle any needed network operations
Complete Flow:
Input Reception: Function receives an array in _this (either from UI or other code)
Iteration Setup: forEach loop begins processing each element
Type Detection: For each unit (_x), checks if it's inside a vehicle
Action Selection: Based on vehicle check, spawns either autoRearm or autoLoot
Delay Application: Sleeps 3-8 seconds to stagger execution
Loop Continuation: Returns to step 3 for next unit
Completion: Loop ends when all units processed, function returns nothing
Usage Examples:
From UI Button (dismounted units):

Sqf

Apply
// When "Auto Rearm" button clicked with no units selected
if (count groupselectedUnits player == 0) then {
    nul = (units group player) spawn A3A_fnc_rearmCall;
} else {
    nul = (groupselectedUnits player) spawn A3A_fnc_rearmCall;
};
From UI Button (mounted/loot mode):

Sqf

Apply
// When "Auto Loot" button clicked
private _units = [];
{
    units pushBack (objectFromNetId (_aiListBox lbData _x));
} forEach lbSelection _aiListBox;
_units spawn A3A_fnc_rearmCall;
Direct Function Call:

Sqf

Apply
// Manually rearm a specific group of units
_someUnits = [unit1, unit2, unit3];
_someUnits spawn A3A_fnc_rearmCall;
Performance Considerations:
The randomized sleep prevents batch processing spikes
Spawning operations ensures non-blocking execution
No heavy computation or complex algorithms are used
Memory usage is minimal (only loop variables and parameters)
Error Handling:
No explicit error handling in this function
If invalid units are passed, they will be processed but may fail in the spawned functions
If _x is objNull or grpNull, the vehicle check will produce unexpected results
The spawned functions are expected to handle their own error conditions
Constants and Configuration:
No hardcoded constants
Uses standard SQF operators (==, spawn, sleep, random)
The delay values (3 and 5) are magic numbers that could be parameterized in future iterations
A3A/addons/core/functions/AI/fn_recallGroup.sqf
Function Name: fn_recallGroup.sqf
What it does: This function manages the recall and reorganization of a military group, resetting their AI behavior states, clearing maneuver flags, and redirecting them to specific waypoints. It handles both individual units and entire groups, ensuring proper formation and command structure during the recall process. The function also clears any occupied positions that the group might have been holding.

Context: This function is typically called during mission state transitions, such as:

When a group needs to be pulled back from an active engagement
During base reorganization or garrison updates
When AI commanders order tactical retreats or repositioning
In response to changing mission objectives or threat levels
How it does that: The function accepts either a group or a single unit, normalizes the input to an array of units, then applies a series of state changes and movement orders to each unit. It operates in a unit-by-unit manner while preserving the group's command structure.

Implementation Breakdown:
1. Parameter Assignment and Type Normalization:

Sqf

Apply
private _groupX = _this;
private _array = if (_groupX isEqualType grpNull) then {((units _groupX) - [_groupX getVariable ["mortarX",objNull]])} else {[_groupX]};
Line 1: Assigns input to _groupX for clarity
Line 2: Type-checking and array creation:
if (_groupX isEqualType grpNull): Checks if input is a group object
Group Case: ((units _groupX) - [_groupX getVariable ["mortarX",objNull]])
Gets all units in the group using units _groupX
Removes any mortar unit stored in the group's "mortarX" variable (likely to exclude special units)
Returns filtered array of regular combat units
Single Unit Case: [_groupX] - wraps the unit in an array for consistent processing
2. State Reset for Each Unit:

Sqf

Apply
{
_x forceSpeed -1;
_x setVariable ["maneuvering",false];
Force Speed Reset: forceSpeed -1 sets the unit's speed to default/recommended speed
-1 is the special value for "let the engine decide" based on unit type and situation
Clears any speed overrides from previous orders
Maneuver Flag Clear: setVariable ["maneuvering",false]
Removes the "maneuvering" status from the unit's namespace
This flag likely controls dynamic AI behavior in other parts of the system
Setting to false indicates the unit is not currently engaged in complex maneuvers
3. Leadership/Formation Logic:

Sqf

Apply
if (_x == leader _x) then
{
    _wp = currentWaypoint group _x;
    _dest = waypointPosition [group _x,_wp];
    _x doMove _dest;
}
else
{
    _x doFollow leader _x;
};
Leader Check: if (_x == leader _x) determines if the current unit is the group leader
Leader Path:
Waypoint Retrieval: _wp = currentWaypoint group _x;
Gets the current waypoint index of the unit's group
Destination Calculation: _dest = waypointPosition [group _x,_wp];
Retrieves the position of the current waypoint
Uses array notation: [group object, waypoint index]
Movement Order: _x doMove _dest;
Directs the leader unit to move to the waypoint destination
Uses doMove for immediate action rather than waypoint-based movement
Non-Leader Path:
Follow Order: _x doFollow leader _x;
Directs subordinate units to follow their group leader
Ensures formation integrity during recall
4. Final Group State Update:

Sqf

Apply
} forEach _array;
(group (_array select 0)) setVariable ["occupiedX",[]];
Loop Completion: The forEach loop processes all units in _array
Occupied Positions Clear: After processing all units:
(group (_array select 0)): Gets the group from the first unit in the array
setVariable ["occupiedX",[]]: Clears any occupied positions recorded for this group
Assumes all units belong to the same group (which they should in this context)
Parameter Validation and Edge Cases:
Input Validation:

Group Input: Accepts grpNull or any group object
Unit Input: Accepts any unit object (not objNull)
Type Safety: Uses isEqualType for robust type checking
Empty Groups: If group has no units after mortar exclusion, _array will be empty
Single Unit Groups: Works correctly with groups of size 1
Edge Cases:

Mortar Unit Handling:

Mortar units (identified via mortarX variable) are excluded from processing
If mortarX doesn't exist, getVariable returns objNull
Removing objNull from the units array is a no-op since units are never objNull
Leader Determination:

_x == leader _x works reliably for all units
In groups where leader has died and no replacement was appointed, leader _x might return an unexpected unit
Waypoint Safety:

waypointPosition [group _x,_wp] expects valid waypoint index
If _wp is 0 (no current waypoint), this might return [0,0,0] or cause errors
Error handling is not present - assumes valid waypoint state
Array Index Safety:

(_array select 0) assumes _array is not empty
If all units were excluded (e.g., group with only mortar units), this would cause an error
Should have a check for empty array before this line
Network Synchronization:

doMove and doFollow are local commands
For multiplayer, each client executes these locally for its units
No network synchronization is performed by this function
Called Functions:
This function does not call any other functions directly. It uses built-in SQF commands exclusively.

Dependencies and System Integration:
This function depends on:

Global Variables/State:
mortarX variable on group (if present)
maneuvering variable on each unit
occupiedX variable on group
These are namespace variables set elsewhere in the mission system
Functions that depend on this:

Command/Control Systems: AI commander systems that need to recall garrisoned or combat units
Base Management: Functions that reorganize forces when base ownership changes
Mission Scripts: Scripts that need to pull back units from certain areas
Reinforcement Systems: When sending new units, old units might be recalled to make room
Global Variables Modified:

Unit-Level:
maneuvering variable (set to false for each unit)
Group-Level:
occupiedX variable (cleared to [] for the group)
Synchronization/Network Implications:

All operations are local - no network traffic is generated
Each client/server executes the commands locally for its units
For multiplayer:
If called on server for server-controlled units, it works correctly
If called on client for client-controlled units, it works correctly
If called on server for client-controlled units, commands are ignored or delayed
No automatic synchronization of group state across clients
Complete Flow:
Input Reception: Function receives either a group or a unit in _this
Type Normalization: Converts input to array of units, excluding mortar units if present
Loop Initialization: Sets up to process each unit in the normalized array
State Reset: For each unit:
Resets movement speed to default
Clears maneuver flag
Leadership Decision: For each unit:
Checks if unit is group leader
If leader: Gets current waypoint and moves to destination
If subordinate: Follows the group leader
Group State Clear: After all units processed:
Clears occupied positions variable for the group
Function Exit: No return value, all operations are executed immediately
Usage Examples:
Recalling an entire group:

Sqf

Apply
// Recall the entire garrison group
private _garrisonGroup = [12345] call A3A_fnc_getGarrison;
_garrisonGroup spawn A3A_fnc_recallGroup;
Recalling a single unit:

Sqf

Apply
// Recall a specific soldier
private _soldier = someUnit;
_soldier spawn A3A_fnc_recallGroup;
From reinforcement system:

Sqf

Apply
// When new units arrive, recall old ones
if (_oldGarrisonCount > 0) then {
    {
        _x spawn A3A_fnc_recallGroup;
    } forEach _oldGroups;
};
Performance Considerations:
Minimal Computational Load: Uses only basic SQF commands
Immediate Execution: No spawning or delays, executes synchronously
Group Size Impact: Processing time scales linearly with group size
No Heavy Calculations: No complex algorithms or intensive operations
Error Handling:
No explicit error handling for invalid inputs
Mortar exclusion might fail silently if mortarX variable contains non-unit value
Empty array issue in final line could cause script error
Waypoint retrieval assumes valid waypoint state
Missing Safety Checks:

Sqf

Apply
// Suggested improvements (not in current implementation)
if (count _array > 0) then {
    (group (_array select 0)) setVariable ["occupiedX",[]];
};
Constants and Configuration:
Magic Numbers: -1 for default speed, but this is a standard SQF convention
Variable Names: mortarX, maneuvering, occupiedX are mission-specific and defined elsewhere
No Parameterization: All behavior is hardcoded
Comparison with Similar Functions:
Unlike fn_rearmCall, this function executes synchronously (no spawn)
Unlike fn_rearmCall, this function directly modifies state variables
More complex logic than fn_rearmCall due to leadership/formation decisions
Potential Issues and Limitations:
Leader Death Scenario: If leader has died but group hasn't reassigned, waypoint commands might fail
Mixed Groups: If group contains both infantry and vehicles, behavior might be unexpected
Network Timing: In multiplayer, commands might execute at slightly different times on different clients
State Consistency: If maneuvering or occupiedX are used by other scripts concurrently, race conditions could occur

Function Name: fn_staticMGDrill.sqf
What it does:
Manages the dynamic mounting/dismounting behavior for static weapon gunners (MG and mortar operators). The function runs in a continuous loop while the gunner is alive, handling the mounting process when enemies are detected and the dismounting process when threats are eliminated or the gunner becomes incapacitated. It coordinates between a gunner unit and a helper unit to establish the static weapon, manages the mounting animation, handles weapon deployment, and tracks both units' participation in the group's flanker system.

How it does that:
The function begins by identifying the gunner and helper unit from the input array, distinguishing between MG gunners and mortar operators based on their unit type variables. It initializes key variables including group association, mounted status, vehicle object reference, side information, faction data, and backpack states. The main loop continuously checks the gunner's alive status, helper status, vehicle status, and group objectives.

Code Implementation:
Sqf

Apply
private ["_gunner","_helperX"];
private _isMortar = false;
{if (_x getVariable ["typeOfSoldier",""] == "StaticGunner") then {_gunner = _x} else {_helperX = _x}} forEach _this;
{if (_x getVariable ["typeOfSoldier",""] == "StaticMortar") then {_gunner = _x;_isMortar = true} else {_helperX = _x}} forEach _this;
private _groupX = group _gunner;
private _mounted = false;
private _veh = objNull;
private _sideX = side _groupX;
private _faction = Faction(_sideX);
private _typeVehX = selectRandom (if !(_isMortar) then { _faction get "staticMGs" } else { _faction get "staticMortars" });
private _backpckG = backPack _gunner;
private _backpckA = backpack _helperX;
Explanation:

Initializes _gunner and _helperX to null values
Uses two separate loops to identify units with "StaticGunner" or "StaticMortar" soldier types
The second loop overwrites findings to handle the case where mortar units might be identified first
_isMortar flag tracks whether dealing with mortar or MG units
Retrieves group, side, and faction information
Selects random static weapon type from faction configuration
Stores original backpack configurations for restoration during dismount
Main Loop Implementation:
Sqf

Apply
while {(alive _gunner)} do
{
	if (!(alive _helperX) and !(_mounted)) exitWith {};
	if (!(isNull _veh) and !(alive _veh)) exitWith {};
	_objectivesX = _groupX getVariable ["objectivesX",[]];
	_enemyX = objNull;
	if (!(_objectivesX isEqualTo []) and (((_objectivesX select 0) select 4) distance _gunner > 150))  then
		{
		// Enemy detection logic
		};
Explanation:

Continuous loop running while gunner remains alive
Early exit conditions: helper dies before mounting, or vehicle gets destroyed
Retrieves group objectives (pre-computed by higher-level AI system)
Initializes enemyX to null for tracking detected enemies
Enemy Detection Logic:
Sqf

Apply
if !(_isMortar) then
	{
	{
	_eny = _x select 4;
	if !(_eny isKindOf "Tank") then
		{
		if  (([objNull, "VIEW"] checkVisibility [eyePos _eny, eyePos _gunner]) > 0) then
			{
			_enemyX = _eny;
			};
		};
	if !(isNull _enemyX) exitWith {};
	} forEach _objectivesX;
	}
else
	{
	_enemyX = ((_objectivesX select 0) select 4);
	};
Explanation:

For MG units: Iterates through objectives, finds first visible non-tank enemy
Uses checkVisibility to verify line of sight between enemy and gunner
For mortar units: Takes the primary objective enemy directly (mortars don't require direct line of sight)
Exits loop once first valid enemy is found
Mounting Process:
Sqf

Apply
if !(isNull _enemyX) then
{
	if !(_mounted) then
		{
		if !(_gunner getVariable ["maneuvering",false]) then
			{
			if (([_gunner] call A3A_fnc_canFight) and ([_helperX] call A3A_fnc_canFight)) then
				{
				_gunner setVariable ["maneuvering",true];
				_gunner playMoveNow selectRandom medicAnims;
				_gunner setVariable ["timeToBuild",time + 30];
				_gunner addEventHandler ["AnimDone",
					{
					private _gunner = _this select 0;
					if ((time > _gunner getVariable ["timeToBuild",0]) or !([_gunner] call A3A_fnc_canFight)) then
						{
						_gunner removeEventHandler ["AnimDone",_thisEventHandler];
						_gunner setVariable ["maneuvering",false];
						}
					else
						{
						_gunner playMoveNow selectRandom medicAnims;
						};
					}];
				waitUntil {sleep 0.5; !(_gunner getVariable ["maneuvering",false])};
				_gunner setVariable ["timeToBuild",nil];
				if ([_gunner] call A3A_fnc_canFight) then
					{
					private _veh = _typeVehX createVehicle [0,0,1000];
					_veh setPos position (_gunner);
					removeBackpackGlobal _gunner;
					removeBackpackGlobal _helperX;
					_groupX addVehicle _veh;
					_gunner assignAsGunner _veh;
					[_gunner] orderGetIn true;
					[_gunner] allowGetIn true;
					_gunner moveInGunner _veh;
					[_veh, side _groupX] call A3A_fnc_AIVEHinit;
					_mounted = true;
					if (_isMortar) then {_groupX setVariable ["mortarsX",_gunner]};
					sleep 60;
					};
				};
			};
		}
Explanation:

Mounting only triggers when not already mounted and enemy is detected
Prevents concurrent maneuvers with maneuvering variable
Checks both units can fight using A3A_fnc_canFight
Plays mounting animation (using medic animations as placeholder for deployment animation)
Adds timed animation handler that repeats the animation until 30 seconds pass or combat ability is lost
After animation completes, creates vehicle at gunner position (moved away from 0,0,1000 to prevent spawning issues)
Removes backpacks (critical for mortar assembly mechanics)
Assigns gunner as vehicle gunner and moves them into the vehicle
Initializes vehicle with faction-specific AI behavior via A3A_fnc_AIVEHinit
Sets mounted flag and mortar tracking variable
60-second cooldown after mounting
Dismounting Logic:
Sqf

Apply
if (_gunner getVariable ["maneuvering",false]) then
	{
	if (([_gunner] call A3A_fnc_canFight) and ([_helperX] call A3A_fnc_canFight)) then
		{
		[_gunner] orderGetIn false;
		[_gunner] allowGetIn false;
		waitUntil {sleep 1; (vehicle _gunner == _gunner) or !(alive _gunner)};
		if (alive _gunner) then
			{
			_mounted = false;
			_gunner addBackpackGlobal _backpckG;
			_helperX addBackpackGlobal _backpckA;
			deleteVehicle _veh;
			_gunner call A3A_fnc_recallGroup;
			if (_isMortar) then {_groupX setVariable ["mortarsX",objNull]};
			};
		};
	};
Explanation:

Dismounting triggers when maneuvering flag is set (by combat logic elsewhere)
Orders gunner out of vehicle and disables get-in orders
Waits for gunner to exit vehicle or become dead
If alive, restores backpacks, deletes the vehicle, and recalls the gunner back to group control
Clears mortar tracking variable for mortar units
No Enemy Present Logic:
Sqf

Apply
else
{
	if (_mounted) then
		{
		if (([_gunner] call A3A_fnc_canFight) and ([_helperX] call A3A_fnc_canFight)) then
			{
			[_gunner] orderGetIn false;
			[_gunner] allowGetIn false;
			_veh = vehicle _gunner;
			moveOut _gunner;
			_mounted = false;
			_gunner addBackpackGlobal _backpckG;
			_helperX addBackpackGlobal _backpckA;
			deleteVehicle _veh;
			_gunner call A3A_fnc_recallGroup;
			if (_isMortar) then {_groupX setVariable ["mortarsX",objNull]};
			};
		};
	};
Explanation:

Executes when no enemy is detected but weapon is already mounted
Gracefully dismounts the weapon if both units remain combat-capable
Uses same restoration logic as maneuvering dismount
Cleanup Logic:
Sqf

Apply
if (alive _gunner) then
{
	[_gunner] orderGetIn false;
	[_gunner] allowGetIn false;
	moveOut _gunner;
	_gunner setVariable ["maneuvering",false];
	_flankers = _groupX getVariable ["flankers",[]];
	_flankers pushBack _gunner;
	_groupX setVariable ["flankers",_flankers];
	_gunner call A3A_fnc_recallGroup;
};
if (alive _helperX) then
{
	_helperX setVariable ["maneuvering",false];
	_flankers = _groupX getVariable ["flankers",[]];
	_flankers pushBack _helperX;
	_groupX setVariable ["flankers",_flankers];
	_helperX call A3A_fnc_recallGroup;
};
Explanation:

Runs when gunner dies or main loop exits
Forces both units out of vehicles and clears maneuvering state
Adds both units to group's "flankers" array for tactical repositioning
Recalls both units back to standard group behavior
Where it leads:

Calls A3A_fnc_canFight (12 calls) - checks if unit is combat-effective
Calls A3A_fnc_AIVEHinit (1 call) - initializes AI vehicle behavior
Calls A3A_fnc_recallGroup (3 calls) - returns unit to group AI control
Depends on typeOfSoldier variable (set by 
fn_typeOfSoldier.sqf
)
Depends on Faction() function for faction configuration
Called by mission scripts or group AI systems when static weapon units are present
Modifies group variable mortarsX for mortar tracking
Modifies group variable flankers for tactical positioning
Uses global medicAnims array for animation selection
Network implications: Uses removeBackpackGlobal, addBackpackGlobal which are global operations
Error handling: Multiple exit conditions prevent infinite loops or script failures
Function Name: fn_suppressingFire.sqf
What it does:
Orders a unit to provide suppressive fire toward an enemy unit. Implements cooldowns to prevent spam, checks for player presence in group to avoid AI interfering with human player actions, verifies line of sight, and uses Arma's built-in suppression system.

How it does that:
The function validates input parameters, checks group composition for player presence, implements a cooldown timer, verifies line of sight to the target, then issues suppression commands.

Code Implementation:
Sqf

Apply
params ["_unit", "_eny"];
Explanation:

Accepts two parameters: the unit to fire, and the enemy target
Uses SQF params for automatic type checking and validation
Parameter Validation and Early Exit Conditions:
Sqf

Apply
if ({isPlayer _x} count (units group _unit) > 0) exitWith {};
if (time < _unit getVariable ["supressing",time - 1]) exitWith {};
if (([objNull, "VIEW"] checkVisibility [eyePos _eny, eyePos _unit]) == 0) exitWith {};
Explanation:

First condition: If the unit's group contains any player, exit immediately (prevent AI interference with human play)
Second condition: Checks cooldown variable supressing - if current time is less than stored time, exit (prevents command spam)
Third condition: Uses checkVisibility with "VIEW" memory point to verify line of sight from enemy to unit (value 0 means no visibility)
Command Execution:
Sqf

Apply
_unit setVariable ["supressing",time + 60];
_unit commandSuppressiveFire _eny;
_unit suppressFor 10;
Explanation:

Sets cooldown for 60 seconds
Issues command-level suppression (Arma AI will fire in bursts toward target)
Uses suppressFor to activate Arma's suppression system for 10 seconds (increases enemy suppression status)
Where it leads:

Calls no other A3A functions directly
Uses Arma's built-in commandSuppressiveFire and suppressFor commands
Interacts with variable supressing (note: misspelled - should be "suppressing") for cooldown tracking
No network implications (local execution only)
No persistent state modifications
Typical call sites: Various AI combat scripts, like fn_mortyAI, fn_chargeWithSmoke, or custom AI behaviors
Function Name: fn_surrenderAction.sqf
What it does:
Handles the complete surrender process for a unit. Converts the unit into a captive, strips their equipment into a surrender crate, assigns them to a surrender-specific group, handles special cases like rival units with laptops, updates city support based on faction, spawns timed cleanup, and sets up event handlers for post-surrender behavior.

How it does that:
The function performs locality validation, checks surrender state, handles special unit types (dogs), validates combat state, then executes a multi-step surrender process including equipment transfer, group reassignment, crate creation, support changes, and cleanup spawning.

Code Implementation:
Sqf

Apply
params ["_unit"];
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Explanation:

Standard function header with includes for debugging
Accepts unit parameter
Locality Validation:
Sqf

Apply
if !(local _unit) exitWith {
    Error("Function miscalled with non-local unit");
	[_unit] remoteExec ["A3A_fnc_surrenderAction", _unit];
};
Explanation:

Checks if unit is local to this machine (critical for hardware execution and event handlers)
If not local, logs error and re-executes the function on the unit's local machine via remoteExec
State Validation and Early Exit:
Sqf

Apply
if (_unit getVariable ["surrendered", false]) exitWith {};
_unit setVariable ["surrendered", true, true];

if (typeOf _unit == "Fin_random_F") exitWith {};		// dogs do not surrender?
if (!alive _unit) exitWith {};							// Used to happen with ACE, seems to be fixed
if (lifeState _unit == "INCAPACITATED") exitWith {
    Info("Unit attempted to surrender while incapacitated");
	_unit setVariable ["surrendered", false, true];
};
Explanation:

Checks if already surrendered (prevent double-processing)
Sets surrendered flag with JIP persistence (third parameter true)
Special case: Dogs (unit type "Fin_random_F") cannot surrender
Validates unit is alive
Prevents incapacitated units from surrendering (resets surrender flag if attempted)
Unit State Modification:
Sqf

Apply
private _unitSide = side group _unit;
_unit allowDamage false;		// give players a couple of seconds to stop shooting
_unit setCaptive true;
_unit stop true;
_unit disableAI "MOVE";
_unit disableAI "AUTOTARGET";
_unit disableAI "TARGET";
_unit disableAI "ANIM";
_unit setSkill 0;
unassignVehicle _unit;			// stop them getting back into vehicles
[_unit] orderGetin false;
_unit setUnitPos "UP";
_unit playMoveNow "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";		// hands up?
_unit setVariable ["A3U_PoW_unitType", _unit getVariable "unitType", true]; // in case the original unitType is needed for something else in the future
_unit setVariable ["A3U_PoW_speaker", speaker _unit, true];
_unit setSpeaker "NoVoice";
Explanation:

Captures original side for later use
Disables damage to prevent immediate death after surrender (gives players time to stop shooting)
Sets captive flag (prevents AI targeting)
Stops unit movement and disables all AI behaviors (move, target, auto-target, animation)
Removes unit skill (prevents any combat capability)
Unassigns from vehicles and prevents re-boarding
Forces standing position and plays surrender animation
Preserves original unit type and speaker in persistent variables
Removes voice to prevent annoying surrender shouts
Spawner Prevention:
Sqf

Apply
if (_unit getVariable ["spawner", false]) then { _unit setVariable ["spawner", nil, true] };
Explanation:

Prevents surrendered units from spawning garrisons (if they were marked as spawners)
Clears the spawner flag with JIP persistence
Group Reassignment:
Sqf

Apply
private _grpIdx = allGroups findIf { local _x && (side _x == _unitSide) && {_x getVariable ["surrenderGroup", false]} };
if (_grpIdx == -1) then {
	private _grp = createGroup _unitSide;
	_grp setVariable ["surrenderGroup", true, true];
	[_unit] joinSilent _grp;
} else {
	[_unit] joinSilent (allGroups select _grpIdx);
};
Explanation:

Searches for existing surrender group on same side and local to this machine
If none exists, creates new group and marks it as surrender group
If exists, joins existing group using joinSilent (no group chatter)
Groups are side-specific (Occupants/Invaders/Resistance) to maintain side affiliation
Surrender Crate Creation:
Sqf

Apply
private _surrenderCrateType = if (_unit getVariable ["isRival", false]) then {
	A3A_faction_riv get "surrenderCrate"
} else {
	(Faction(_unitSide)) get "surrenderCrate"
};
private _boxX = _surrenderCrateType createVehicle position _unit;
_boxX allowDamage false;
clearMagazineCargoGlobal _boxX;
clearWeaponCargoGlobal _boxX;
clearItemCargoGlobal _boxX;
clearBackpackCargoGlobal _boxX;
Explanation:

Determines crate type based on faction (rivals vs standard)
Creates crate at unit's position
Prevents crate destruction
Clears all cargo slots (weapon, magazine, item, backpack)
Special Rival Case:
Sqf

Apply
if (_unit getVariable ["hasLaptop", false] && {!(_unit getVariable ["hasLaptopSpawned", false])}) then
{
	[_unit] call SCRT_fnc_rivals_createLaptop;
	_unit setVariable ["hasLaptopSpawned", true, true]; //not sure if it should be broadcasted
};
Explanation:

Checks if rival unit has laptop and hasn't already spawned it
Calls rival-specific function to create laptop
Marks laptop as spawned with JIP persistence
Equipment Transfer to Crate:
Sqf

Apply
private _loadout = getUnitLoadout _unit;
for "_i" from 0 to 2 do {
	if !(_loadout select _i isEqualTo []) then {
		_boxX addWeaponWithAttachmentsCargoGlobal [_loadout select _i, 1];
	};
};
{_boxX addMagazineCargoGlobal [_x,1]} forEach (magazines _unit);
{_boxX addItemCargoGlobal [_x,1]} forEach (assignedItems _unit);
{_boxX addItemCargoGlobal [_x,1]} forEach (items _unit);
{_boxX addItemCargoGlobal [_x,1]} forEach [vest _unit, headgear _unit, goggles _unit];
private _backpack = backpack _unit;
if (_backpack != "") then {
	// because backpacks are often subclasses containing items
	_backpack = _backpack call A3A_fnc_basicBackpack;
	_boxX addBackpackCargoGlobal [_backpack, 1];
};
_unit setUnitLoadout [ [], [], [], [uniform _unit, []], [], [], "", "", [], ["","","","","",""] ];
Explanation:

Gets complete unit loadout array
Transfers primary, secondary, and handgun weapons (with attachments) to crate
Transfers all magazines, assigned items (like GPS, radio), and items
Transfers vest, headgear, and goggles
For backpacks: Uses A3A_fnc_basicBackpack to get base class, transfers single backpack
Strips unit completely, leaving only uniform (which may be faction-specific)
Dropped Weapon Cleanup:
Sqf

Apply
{
	_boxX addWeaponWithAttachmentsCargoGlobal [(weaponsItemsCargo _x) select 0, 1];
	deleteVehicle _x;
} forEach nearestObjects [_unit,["WeaponHolderSimulated"],5,true];
Explanation:

Finds all weapon holders (simulated) within 5 meters of unit
Adds first weapon from each holder to crate
Deletes the weapon holder object
Prevents duplicate weapons on ground
City Support Updates:
Sqf

Apply
if (_unitSide == Occupants) then {
	[-2, 0, getPos _unit] remoteExec ["A3A_fnc_citySupportChange", 2];
} else {
	[0, 1, getPos _unit] remoteExec ["A3A_fnc_citySupportChange", 2];
};
Explanation:

Updates city support based on surrendered unit's side
Occupant surrender reduces support by 2, Invader surrender increases support by 1
Executes on server (owner 2) for global effect
Marker Zone Check:
Sqf

Apply
private _markerX = _unit getVariable "markerX";
if (!isNil "_markerX") then { [_markerX, _unitSide] remoteExec ["A3A_fnc_zoneCheck", 2] };
Explanation:

Checks if unit was associated with a marker (likely for garrison units)
Triggers zone check on server to update garrison status
Timed Cleanup Spawning:
Sqf

Apply
[_unit] spawn A3A_fnc_postmortem;
[_boxX] spawn A3A_fnc_postmortem;
Explanation:

Spawns cleanup functions for both unit and crate
postmortem handles delayed deletion and final resource calculations
Damage Handler Setup:
Sqf

Apply
sleep 3;				// Also protects against box kills
_unit allowDamage true;
private _handlerDamage = _unit addEventHandler ["HandleDamage", {
	// If unit gets injured after the delay, run away
	params ["_unit","_part","_damage"];
	if (_damage < 0.2) exitWith {};
	[_unit, "remove"] remoteExec ["A3A_fnc_flagaction", [teamPlayer, civilian], _unit];
	[_unit, side group _unit] spawn A3A_fnc_fleeToSide;
	_unit removeEventHandler ["HandleDamage", _thisEventHandler];
	nil;
}];
_unit setVariable ["A3U_PoW_EH_HandleDamage", _handlerDamage, true];
Explanation:

Waits 3 seconds before re-enabling damage (protects from accidental box explosions)
Adds damage event handler that triggers if damage exceeds 0.2
Handler removes flag action and makes unit flee to side
Removes itself after execution
Stores handler reference in variable for potential removal
Final Flag Actions:
Sqf

Apply
if (_unit getVariable ["isRival", false]) then {
	[_unit,"captureRivals"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
} else {
	[_unit,"captureX"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
};
Explanation:

Adds capture flag action to unit (allows players to lead POWs)
Rivals get different flag action for special handling
Executed on all players (teamPlayer, civilian) but only triggers on the unit
Where it leads:

Calls SCRT_fnc_rivals_createLaptop (1 call, conditional) - creates laptop for rivals
Calls A3A_fnc_basicBackpack (1 call, conditional) - gets base backpack class
Calls A3A_fnc_citySupportChange (1 call, remote) - updates city support
Calls A3A_fnc_zoneCheck (1 call, remote, conditional) - updates garrison zones
Calls A3A_fnc_postmortem (2 calls) - spawns cleanup
Calls A3A_fnc_fleeToSide (1 call, conditional) - makes unit flee if damaged
Calls A3A_fnc_flagaction (1 call, remote) - adds capture action
Depends on A3A_fnc_typeOfSoldier for unit classification
Depends on Faction() function for surrender crate type
Called by various sources: fn_AIreactOnKill, fn_chargeWithSmoke, mission scripts, player interactions
Modifies: surrendered, spawner, A3U_PoW_unitType, A3U_PoW_speaker, hasLaptopSpawned, A3U_PoW_EH_HandleDamage variables
Network implications: Multiple remoteExec calls for server-side updates, local changes to unit state
Error handling: Locality validation, state checks, conditional execution paths
Function Name: fn_typeOfSoldier.sqf
What it does:
Classifies a unit into a specific soldier type (Medic, Engineer, ATMan, AAMan, MGMan, Sniper, StaticMortar, StaticGunner, StaticBase, or Normal) based on their inventory, traits, and equipment. Used by many AI systems to determine unit roles and capabilities. Caches the result in the unit's typeOfSoldier variable for performance.

How it does that:
Uses a switch statement with multiple checks to determine unit type. Checks are ordered from specific to general: medical trait, mines, secondary weapon (AT/AA), primary weapon type (MG/sniper), and static weapon assembly info. Implements helper functions for each check type.

Code Implementation:
Helper Functions Definition:
Sqf

Apply
private _fnc_isRight = {
    if (_soldierType isEqualTo "") exitWith { false };
    if (_soldierType isEqualTo "ATMan") exitWith { false };
    if (_soldierType isEqualTo "AAMan") exitWith { false };
    if (_soldierType isEqualTo "Engineer") exitWith { false };
    true
};
Explanation:

Checks if _soldierType is valid and not one of the specific combat types
Used to prevent re-classifying already classified units
This is a bug: it should check against the cached value, not _soldierType
Sqf

Apply
private _fnc_haveMines = {
    (magazines _unit) findIf { (_x call BIS_fnc_itemType) # 0 == "Mine" } != -1
};
Explanation:

Checks if unit magazines contain any mine type
Uses BIS function to get item type
Returns true if at least one mine is found
Sqf

Apply
private _fnc_isAT = {
    if (secondaryWeapon _unit == "") exitWith { false };

    private _sWBase = [secondaryWeapon _unit] call BIS_fnc_baseWeapon;
    private _magTypeAT = (getArray MAGS(_sWBase)) # 0;

    if ((magazinesAmmoFull _unit) findIf { _x # 0 == _magTypeAT } == -1)
    exitWith { false };

    private _ammo = getText MAG_AMMO(_magTypeAT);
    _isAA = getNumber AIRLOCK(_ammo) != 0;

    !_isAA
};
Explanation:

Checks for secondary weapon (launcher)
Gets base weapon class (removes variants)
Gets first magazine type for that weapon
Checks if unit has any of that magazine type
Determines if ammunition is AA-capable (airLock > 0)
Returns true only if it's an AT (non-AA) launcher
Sqf

Apply
private _fnc_isMortar = {
    private _return = false;
    private _backpack = backpack _unit;

    if (_backpack == "")
    then
    {
        private _vehicle = vehicle _unit;

        if !(_vehicle isKindOf "StaticWeapon") exitWith {};

        _return = _vehicle isKindOf "StaticMortar";
        _isStaticGunner = !_return;
    }
    else
    {
        if !(isClass ASSEMBLE_INFO(_backpack)) exitWith {};

        private _backpackWeapon = getText ASSEMBLE_WEAPON(_backpack);

        if (_backpackWeapon == "") exitWith { _isStaticBase = true; };

        _return = _backpackWeapon isKindOf "StaticMortar";
        _isStaticGunner = !_return;
    };

    _return
};
Explanation:

Checks for static weapon identification
If no backpack: checks if unit is in a static weapon (mortar or MG)
If backpack exists: checks assembleInfo config for weapon type
Sets _isStaticGunner and _isStaticBase flags for later use
Returns true for mortar, false for MG
Main Classification Logic:
Sqf

Apply
private _unit = _this;

private _soldierType = _unit getVariable ["typeOfSoldier", ""];
private _toSet = true;

_soldierType = switch (true)
do
{
    case (call _fnc_isRight): { _toSet = false; _soldierType };
    case ([_unit] call A3A_fnc_isMedic): { "Medic" };
    case (call _fnc_haveMines): { "Engineer" };

    private _isAA = false;

    case (call _fnc_isAT): { "ATMan" };
    case (_isAA): { "AAMan" };

    private _pWBase = [primaryWeapon _unit] call BIS_fnc_baseWeapon;

    case (_pWBase in allMachineGuns): { "MGMan" };
    case (_pWBase in allSniperRifles): { "Sniper" };

    private _isStaticGunner = false;
    private _isStaticBase = false;

    case (call _fnc_isMortar): { "StaticMortar" };
    case (_isStaticGunner): { "StaticGunner" };
    case (_isStaticBase): { "StaticBase" };

    default { "Normal" };
};
Explanation:

Retrieves cached typeOfSoldier variable
Uses switch(true) to evaluate each case in order
Case order is critical: more specific types checked first
Medic check uses A3A_fnc_isMedic (checks medical items and trait)
Engineer check looks for mines
ATMan check uses helper function
Bug: _isAA is set but never updated, so AAMan case never triggers
MGMan checks against allMachineGuns global array
Sniper checks against allSniperRifles global array
Static checks use helper function that sets multiple flags
Default returns "Normal"
Sqf

Apply
if (_toSet) then { _unit setVariable ["typeOfSoldier", _soldierType]; };
Explanation:

Sets the variable only if _toSet is true (not if already classified with a valid type)
Bug: Due to _fnc_isRight logic, units already classified as ATMan/AAMan/Engineer won't be re-classified
Sqf

Apply
_soldierType
Explanation:

Returns the determined soldier type
Where it leads:

Calls A3A_fnc_isMedic (1 call) - checks if unit is a medic
Uses BIS functions: BIS_fnc_itemType, BIS_fnc_baseWeapon
Uses config queries: MAGS, MAG_AMMO, AIRLOCK, ASSEMBLE_INFO, ASSEMBLE_WEAPON
Depends on global arrays: allMachineGuns, allSniperRifles
Called by: fn_staticMGDrill, fn_mortyAI, fn_enemyGarrison, fn_garrisonInfo, mission scripts
Modifies: typeOfSoldier variable (unit-specific)
Error handling: Multiple exit conditions in helper functions, safe config access
Note: The _isAA bug means AA-man units get misclassified (likely as normal or ATMan)
Function Name: fn_undercoverAI.sqf
What it does:
Manages AI units going undercover when near an undercover player leader. The function dresses AI in civilian clothing, disables their combat AI, and periodically checks if they're still near the leader. If the leader gets exposed or the AI leaves the area, the AI is restored to combat state.

How it does that:
Validates unit conditions (non-player, has player leader, leader is undercover), then executes a temporary disguise process with continuous monitoring of the leader's undercover status and the AI's proximity and equipment.

Code Implementation:
Initial Validation:
Sqf

Apply
params ["_unit"];
if (isPlayer _unit) exitWith {};
private _leader = _unit getVariable ["owner",leader group _unit];
if (!isPlayer _leader) exitWith {};
if (!captive _leader) exitWith {};
if (captive _unit) exitWith {};
Explanation:

Exits if unit is a player (only for AI)
Gets leader from unit's owner variable or group leader
Validates leader is a player and is currently captive (undercover)
Exits if unit is already undercover
Undercover State Setup:
Sqf

Apply
[_unit,true] remoteExec ["setCaptive",_unit];
_unit setCaptive true;
_unit disableAI "TARGET";
_unit disableAI "AUTOTARGET";

private _oldBehaviour = combatBehaviour _unit;		// actually the same as behaviour _unit?

_unit setCombatBehaviour "CARELESS";
_unit setUnitPos "UP";
Explanation:

Sets captive status via remoteExec for network sync
Disables targeting and auto-targeting AI
Saves original combat behavior
Sets behavior to CARELESS (won't engage enemies)
Forces standing position
Equipment Stripping:
Sqf

Apply
private _loadOut = getUnitLoadout _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeAllWeapons _unit;			// also removes magazines
removeGoggles _unit;
removeVest _unit;

_unit addHeadgear (selectRandom (A3A_faction_civ get "headgear"));
_unit forceAddUniform (selectRandom (A3A_faction_civ get "uniforms"));
Explanation:

Backs up complete loadout
Removes all items, assigned items (radio, GPS, etc.), weapons, magazines, goggles, vest
Adds random civilian headgear and uniform from faction configuration
Uses forceAddUniform to override any existing uniform
Monitoring Loop:
Sqf

Apply
while {captive _leader && {captive _unit}} do{
	sleep 1;
	if ((vehicle _unit != _unit) and (not((typeOf vehicle _unit) in undercoverVehicles))) exitWith {};
	if ((primaryWeapon _unit != "") or (secondaryWeapon _unit != "") or (handgunWeapon _unit != "")) exitWith {};
};
Explanation:

Continues while both leader and unit remain undercover
Checks every second
Exit conditions:
Unit is in a vehicle not in undercoverVehicles list
Unit somehow gets weapons back (shouldn't happen with removal)
Uses undercoverVehicles global array
Exit State Restoration:
Sqf

Apply
if (!captive _unit) then {
	_unit groupChat (selectRandom [
		localize "STR_outpost_ai_spotted_1",
		localize "STR_outpost_ai_spotted_2",
		localize "STR_outpost_ai_spotted_3"
	]);
} else {
	[_unit,false] remoteExec ["setCaptive",_unit]; 
	_unit setCaptive false
};
if (captive _leader) then {sleep 5};
_unit setCombatBehaviour _oldBehaviour;
_unit enableAI "TARGET";
_unit enableAI "AUTOTARGET";
_unit setUnitPos "AUTO";
Explanation:

If unit exposed (not captive), plays random group chat message
If unit still undercover but loop ended (leader exposed), removes captive status
If leader still undercover after unit loop ends, waits 5 seconds (gives time for re-distancing)
Restores original combat behavior, re-enables targeting AI, resets unit position
Loadout Restoration:
Sqf

Apply
// Remove backpack if changed, prevents static/device dupe exploits
if (_loadOut#5 isNotEqualTo [] and { backpack _unit != _loadOut#5#0 }) then { _loadOut set [5, []] };
_unit setUnitLoadout _loadOut;
Explanation:

Checks if backpack was changed during undercover (exploit prevention)
Clears backpack from loadout array if modified
Restores original loadout
Where it leads:

Uses global variable undercoverVehicles
Uses faction data from A3A_faction_civ
Called by: Player undercover system, mission scripts when AI needs to follow undercover players
Modifies: setCaptive status, AI abilities, loadout, position
Network implications: Uses remoteExec for captive syncing, unit locality matters
Error handling: Multiple exit conditions, safe state restoration
Function Name: fn_unitGetToCover.sqf
What it does:
Directs a unit to move to the nearest cover position away from an enemy. Uses a coverage finding system to calculate safe positions, temporarily disables AI behaviors during movement, and re-enables them after reaching cover or timeout.

How it does that:
Validates unit conditions (non-player, on foot, not in combat, can fight), finds enemy, calculates cover using coverage function, then moves unit to cover with AI disabled for precision.

Code Implementation:
Initial Validation:
Sqf

Apply
private _unit = _this select 0;

if (isPlayer _unit) exitWith {};
if (_unit != vehicle _unit) exitWith {};
if (behaviour _unit isEqualTo "COMBAT" or {behaviour _unit isEqualTo "STEALTH"}) exitWith {};
if !([_unit] call A3A_fnc_canFight) exitWith {};
Explanation:

Exits if unit is player
Exits if not on foot (in vehicle)
Exits if already in combat or stealth behavior
Exits if unit cannot fight (injured, suppressed, etc.)
Enemy Selection:
Sqf

Apply
private _enemy = if (count _this > 1) then {_this select 1} else {_unit findNearestEnemy _unit};

if (isNull _enemy) exitWith {};
if (_unit distance _enemy < 300) exitWith {};
if (random 100 < 35) then {[_unit,_unit,_enemy] call A3A_fnc_chargeWithSmoke};
Explanation:

Uses provided enemy or finds nearest enemy automatically
Exits if no enemy found
Exits if enemy is too close (within 300m) - not worth repositioning
35% chance to call smoke charge function to provide smoke cover
Cover Calculation:
Sqf

Apply
_coverX = [_unit,_enemy] call A3A_fnc_coverage;

if (_coverX isEqualTo []) exitWith {};
Explanation:

Calls A3A_fnc_coverage to find suitable cover position
Exits if no cover found
Movement Execution:
Sqf

Apply
_unit stop false;
_unit forceSpeed -1;
{_unit disableAI _x} forEach ["AUTOTARGET","FSM","TARGET","SUPPRESSION","AUTOCOMBAT","WEAPONAIM","COVER","CHECKVISIBLE"];
_unit setUnitPos "MIDDLE";
_unit setCombatMode "BLUE";
_unit doMove _coverX;
Explanation:

Enables movement (stop false)
Sets speed to automatic (forceSpeed -1)
Disables multiple AI features for precise movement control
Sets unit to crouch position ("MIDDLE") - lower profile during movement
Sets combat mode to "BLUE" (never fire)
Uses doMove for direct movement command
Movement Completion Monitor:
Sqf

Apply
[_unit,_coverX] spawn {
	params ["_unit", "_coverX"];
	private _timeOut = time + 15;
	waitUntil {sleep 0.5; (_unit distance _coverX < 1) or (time > _timeOut)};
	if (_unit distance _coverX < 1) then {
		sleep 1;
		_unit stop true;
		_unit forceSpeed 0;
		_unit setCombatMode "YELLOW";
		_unit setUnitPos "AUTO";
		_unit doWatch (_unit findNearestEnemy _unit);
		sleep 30;
	};
	{_unit enableAI _x} forEach ["AUTOTARGET","FSM","TARGET","SUPPRESSION","AUTOCOMBAT","WEAPONAIM","COVER","CHECKVISIBLE"];
	_unit setCombatMode "YELLOW";
	_unit forceSpeed -1;
	_unit stop false;
	_unit setUnitPos "AUTO";
};
Explanation:

Spawns separate monitoring thread
Timeout of 15 seconds for movement
If reached cover: stops unit, sets speed to 0, combat mode to YELLOW (open fire), auto position, watches nearest enemy, waits 30 seconds of cover holding
Regardless of success/failure: re-enables all disabled AI features, restores combat mode to YELLOW, enables movement, sets auto position
Where it leads:

Calls A3A_fnc_canFight (1 call) - checks combat capability
Calls A3A_fnc_chargeWithSmoke (1 call, 35% chance) - provides smoke cover
Calls A3A_fnc_coverage (1 call) - finds cover position
Called by: fn_mortyAI, fn_chargeWithSmoke, other AI combat scripts
Modifies: AI capabilities, movement state, combat mode, position
Network implications: Local execution only
Error handling: Multiple exit conditions, spawn thread for asynchronous completion
Note: The 30-second cover hold might be excessive but gives units time to engage from cover
Function Name: fn_useFlares.sqf
What it does:
Makes a unit fire a flare into the air to illuminate the area around an enemy. Implements cooldown, limits flare count per unit, checks for existing flares in area, and creates flares at appropriate height with random velocity.

How it does that:
Validates unit and enemy conditions, checks cooldown and flare count, selects flare type from faction, calculates launch position, creates flare with random velocity, and plays sound effect.

Code Implementation:
Initial Setup and Validation:
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
	["_unit", objNull], 
	["_side", sideUnknown],
	["_enemy", objNull]
];

sleep random 5;

if (time < _unit getVariable ["smokeUsed",time - 1]) exitWith {};
if (vehicle _unit != _unit) exitWith {};
if (!isNull _enemy && {_enemy distance _unit > 450}) exitWith {};
if (!(_unit call A3A_fnc_canFight)) exitWith {};
Explanation:

Random 0-5 second delay prevents multiple units firing flares simultaneously
Checks cooldown variable smokeUsed (shared with smoke functions)
Exits if unit is in vehicle
Exits if enemy is too far (>450m) or too close
Exits if unit cannot fight
Flare Management:
Sqf

Apply
private _flares = _unit getVariable ["remainingFlares", round random [1,2,3]];
if (_flares <= 0) exitWith {};

_unit setVariable ["smokeUsed", time + 60];
_unit setVariable ["remainingFlares", (_flares - 1)];
Explanation:

Gets remaining flares (1-3 random if not set)
Exits if no flares left
Sets 60-second cooldown
Decrements flare count
Faction and Flare Selection:
Sqf

Apply
private _target = if (!isNull _enemy) then {_enemy} else {_unit};
private _faction = if (_side != sideUnknown) then {
	Faction(_side);
} else {
	Warning("For some reason side is sideUnknown, taking fallback route.");
	A3A_faction_occ;
};
private _flares = _faction get "flares";
Explanation:

Uses enemy position or unit position as target
Determines faction from provided side or uses Occupants as fallback
Gets flare class list from faction config
Position Calculation and Flare Creation:
Sqf

Apply
if (nearestObjects [(position _target), _flares, 100, true] isNotEqualTo []) exitWith {};

private _initialFlarePosition = _target getPos [random 25,random 360];
_initialFlarePosition set [2, (((getPosATL _target) select 2) + (random [150,175,200]))]; 

private _flare = createVehicle [selectRandom _flares, _initialFlarePosition, [], 0, "CAN_COLLIDE"];
_flare setVelocity [-10+random 10, -10+random 10, -0.000001];

playSound3D [(selectRandom flareSounds), _flare, false,  getPosASL _flare, 1.5, 1, 450, 0];
Explanation:

Exits if another flare already exists within 100m of target
Calculates launch position 0-25m from target at random angle
Sets altitude: target's altitude + 150-200m (typical flare height)
Creates flare vehicle at calculated position
Sets downward velocity (-10 to 10 in X/Y, slight downward in Z)
Plays 3D sound from flare position with attenuation
Where it leads:

Calls A3A_fnc_canFight (1 call) - checks combat capability
Uses faction config via Faction() - gets flare types
Uses global flareSounds array for audio
Called by: fn_mortyAI, fn_chargeWithSmoke, other night combat scripts
Modifies: smokeUsed, remainingFlares variables
Network implications: Local execution only (flares are localized objects)
Error handling: Multiple validation checks, side fallback
Function Name: fn_VANTinfo.sqf
What it does:
Provides airborne vehicle (VANT) reconnaissance, revealing enemy positions to nearby friendly groups. Runs continuously for an airborne vehicle, periodically scans for enemy units within 500m and reveals them to nearby friendly vehicle groups.

How it does that:
In an infinite loop while vehicle is alive, periodically gathers nearby enemies, finds friendly vehicle groups, and uses reveal command to improve their detection of enemies.

Code Implementation:
Parameter Setup:
Sqf

Apply
params ["_veh", "_markerX", "_sideX"];

private _positionX = getMarkerPos _markerX;
private _enemiesS = if (_sideX == Invaders) then {Occupants} else {Invaders};
private ["_groups","_knownX","_groupX"];
Explanation:

Accepts vehicle, marker position, and side
Calculates position from marker
Determines enemy side based on sideX (Opposing side)
Declares variables for groups, known enemies, and group loops
Main Monitoring Loop:
Sqf

Apply
while {alive _veh} do {
	_knownX = [];
	_groups = [];
	_enemiesX = [distanceSPWN,0,_positionX,_sideX] call A3A_fnc_distanceUnits;
	sleep 60;
	_groups = allGroups select {(leader _x in _enemiesX) and ((vehicle leader _x) != (leader _x))};
	_knownX = allUnits select {((side _x == teamPlayer) or (side _x == _enemiesS)) and (alive _x) and (_x distance _positionX < 500)};
	{
		_groupX = _x;
		{
		_groupX reveal [_x,1.4];
		} forEach _knownX;
	} forEach _groups;
};
Explanation:

Continues while vehicle is alive
Uses A3A_fnc_distanceUnits to get spawn-capable units in area (not relevant for VANT but used for efficiency)
60-second scan interval
Finds groups where leader is in spawn area AND leader is in a vehicle (airborne group)
Finds all alive units within 500m that are either resistance or enemy side
For each group: Reveals each known enemy with knowledge level 1.4 (Arma reveal system)
Where it leads:

Calls A3A_fnc_distanceUnits (1 call per loop) - gets spawnable units in area
Called by: VANT support system, airborne reconnaissance missions
Modifies: No persistent variables
Network implications: Local execution only (reveal is local)
Error handling: Minimal (just vehicle alive check)
Function Name: fn_vehicleConvoyTravel.sqf
What it does:
Manages convoy vehicle movement along a predefined route, with speed adjustments based on convoy spacing. Implements collision prevention, stuck detection, and waypoint navigation for vehicles in a convoy formation.

How it does that:
Sets up driver group, creates waypoints for route navigation, monitors vehicle position relative to route and convoy vehicles, adjusts speed based on following distance, handles stuck conditions, and cleans up on completion or failure.

Code Implementation:
Parameter Validation:
Sqf

Apply
params ["_vehicle", "_route", "_convoy", "_maxSpeed", ["_critical", false]];

private _error = call {
    if (count _route == 0) exitWith { "No route specified" };
    if !(alive _vehicle) exitWith { "Dead or missing vehicle input" };
    if !(alive driver _vehicle) exitWith { "Dead or missing driver in vehicle" };
};
if (!isNil "_error") exitWith {
    _convoy deleteAt (_convoy find _vehicle);
    Error(_error);
};
Explanation:

Accepts vehicle, route positions, convoy array, max speed, and critical flag
Validates route has points, vehicle exists, driver is alive
If validation fails, removes vehicle from convoy array and logs error
Driver and Crew Separation:
Sqf

Apply
private _driverGroup = group driver _vehicle;
private _crewGroup = grpNull;
if (count units _driverGroup > 1) then {
    _crewGroup = createGroup (side _driverGroup);
    (units _driverGroup - [driver _vehicle]) joinSilent _crewGroup;
};
_driverGroup setBehaviour "CARELESS";
_vehicle setEffectiveCommander (driver _vehicle);
Explanation:

Gets driver's group
If group has multiple units (crew + driver), creates separate crew group
Moves non-driver units to new group
Sets driver group behavior to CARELESS (won't react to threats)
Sets driver as effective commander
Navigation Setup:
Sqf

Apply
private _destination = _route select (count _route - 1);
private _accuracy = 50;
private _currentNode = 0;
private _nextPos = _route select _currentNode;
private _waypoint = _driverGroup addWaypoint [ATLToASL _nextPos, -1, 0];
_driverGroup setCurrentWaypoint _waypoint;
private _timeout = time + (_vehicle distance2d _nextPos);
Explanation:

Destination is last route point
50m accuracy for waypoint completion
Start at first route point
Creates waypoint at first position
Sets as current waypoint
Sets initial timeout based on distance to first point
Main Movement Loop:
Sqf

Apply
while {true} do
{
    sleep 0.5;
    private _vehIndex = _convoy find _vehicle;

    // Exit conditions
    if (!canMove _vehicle || !alive driver _vehicle || { lifestate driver _vehicle == "INCAPACITATED" }) exitWith {
        ServerInfo("Vehicle or driver died during travel, abandoning");
    };
    if (_vehIndex == -1) exitWith {};				// external abort
    if (_vehicle distance _destination < 100) exitWith {
        ServerDebug("Vehicle arrived at destination");
    };
Explanation:

0.5 second update interval
Gets convoy index for following logic
Exit if: vehicle cannot move, driver dead, driver incapacitated, removed from convoy, reached destination
Waypoint Transition:
Sqf

Apply
    while {_vehicle distance _nextPos < _accuracy} do
    {
        _currentNode = _currentNode + 1;
        _nextPos = _route select _currentNode;
        _waypoint setWaypointPosition [ATLToASL _nextPos, -1];
        _driverGroup setCurrentWaypoint _waypoint;
        _timeout = time + (_vehicle distance2d _nextPos);
    };
    if (!_critical && time > _timeout) exitWith {
        ServerInfo("Vehicle stuck during travel, abandoning");
    };
Explanation:

When within 50m of current waypoint, advances to next route point
Updates waypoint position and current waypoint
Resets timeout based on new distance
Exits if not critical and timeout exceeded (stuck condition)
Stuck Prevention Hack:
Sqf

Apply
    if (unitReady driver _vehicle) then {
        _vehicle setPosWorld (getPosWorld _vehicle vectorAdd vectorDir _vehicle);
        _driverGroup setCurrentWaypoint _waypoint;
    };
Explanation:

If driver indicates ready (but not moving), moves vehicle 1m forward
Resets current waypoint to retry navigation
Works around Arma pathfinding bugs
Speed Adjustment by Convoy Spacing:
Sqf

Apply
    if (_vehIndex == 0) then { _vehicle limitSpeed _maxSpeed } else
    {
        private _followVeh = _convoy select (_vehIndex - 1);
        private _dist = _vehicle distance _followVeh;

        // prevent some off-road passing
        if (_dist < 50) then {
            private _followDir = (getPos _vehicle) vectorFromTo (getPos _followVeh);
            private _targDir = (getpos _vehicle) vectorFromTo _nextPos;
            if (_followDir vectorDotProduct _targDir <= 0) then {_dist = 0};
        };

        private _speed = if (_dist < 30) then { linearConversion [15,30,_dist,0.01,_maxSpeed,true] }
            else { linearConversion [30,60,_dist,_maxSpeed,2*_maxSpeed,true] };
        _vehicle limitSpeed _speed;
        if (_dist < 30) then { _timeout = time + (_vehicle distance2d _nextPos) };
    };
Explanation:

Lead vehicle maintains max speed
Following vehicles adjust speed based on distance to vehicle in front
Off-road passing prevention: if following direction is opposite to target direction, treat as zero distance
Speed calculation:
If <30m: Linear conversion between 0.01 and max speed
If 30-60m: Linear conversion between max speed and 2x max speed
Resets timeout if dangerously close (<30m)
Cleanup:
Sqf

Apply
// Remove from convoy array
_convoy deleteAt (_convoy find _vehicle);

// Merge driver/crew back together
if (!isNull _driverGroup && !isNull _crewGroup) then {
    (units _crewGroup) joinSilent _driverGroup;
    _driverGroup setBehaviour "AWARE";
};
Explanation:

Removes vehicle from convoy array
Merges crew back into driver group
Restores group behavior to AWARE
Where it leads:

Calls ServerInfo and ServerDebug for logging
Called by: Convoy mission scripts, vehicle transport systems
Modifies: Convoy array, group behavior, vehicle speed limits, positions
Network implications: Local execution (movement is local)
Error handling: Comprehensive validation, multiple exit conditions, cleanup on exit
Function Name: fn_vehicleMarkers.sqf
What it does:
Creates and updates a local map marker for a vehicle. Provides visual tracking of vehicle position on map, with different icon types and colors based on vehicle type and side. Includes notification when enemy vehicle is spotted.

How it does that:
Creates a local marker based on vehicle type and side, updates its position periodically, and deletes it when vehicle is destroyed or conditions change.

Code Implementation:
Initial Setup:
Sqf

Apply
params ["_veh", "_text"];

private ["_mrkFinal","_pos","_side","_typeX","_newPos","_road","_friendlies"];

private _convoy = false;
if (_text == (localize "STR_marker_convoy_objective") or {_text == (localize "STR_marker_mission_vehicle") or {_text == (localize "STR_marker_supply_box")}}) then {
	_convoy = true
};
Explanation:

Gets vehicle and marker text
Determines if vehicle is part of convoy based on marker text
Side and Icon Type Determination:
Sqf

Apply
private _side = side (group (driver _veh));
private _formatX = "";
private _color = colorOccupants;
private _typeX = switch (true) do {
	case (_veh isKindOf "Truck" or {_veh isKindOf "Car"}): {
		"_motor_inf"
	};
	case (_veh isKindOf "Wheeled_APC_F"): {
		"_mech_inf"
	};
	case (_veh isKindOf "Tank"): {
		"_armor"
	};
	case (_veh isKindOf "Plane_Base_F"): {
		"_plane"
	};
	case (_veh isKindOf "UAV_02_base_F"): {
		"_uav"
	};
	case (_veh isKindOf "Helicopter"): {
		"_air"
	};
	case (_veh isKindOf "Boat_F"): {
		"_naval"
	};
	default {
		"_unknown"
	};
};
Explanation:

Gets side from driver's group
Determines vehicle icon type based on vehicle class
Supports trucks/cars, APCs, tanks, planes, UAVs, helicopters, boats
Side and Color Determination:
Sqf

Apply
switch (true) do {
	case (_side in [teamPlayer, sideUnknown]): {
		_enemyX = false;
		_formatX = "n";
		_color = colorTeamPlayer;
	};
	case (_side == civilian): {
		_enemyX = false;
		_formatX = "b";
		_color = colorCivilian;
	};
	case (_side == Occupants): {
		_formatX = "b";
		_color = colorOccupants;
	};
	case (_side == Invaders): {
		_formatX = "o";
		_color = colorInvaders;
	};
};

_typeX = format ["%1%2",_formatX,_typeX];
Explanation:

Format prefix: "n" for resistance/unknown, "b" for friendly/civilian, "o" for enemy
Colors: Correspond to side colors
Combines prefix and icon type
Enemy Spotting Notification:
Sqf

Apply
if ((side group (driver _veh) != teamPlayer) && {side driver _veh != sideUnknown}) then {
	["TaskSucceeded", ["", format [localize "STR_notifiers_vehicle_spotted",_text]]] spawn BIS_fnc_showNotification
};
Explanation:

If vehicle is not player-controlled and not unknown side, show notification
Marker Creation:
Sqf

Apply
private _mrkFinal = createMarkerLocal [format ["%2%1", random 100,_text], position _veh];
_mrkFinal setMarkerShapeLocal "ICON";
_mrkFinal setMarkerTypeLocal _typeX;
_mrkFinal setMarkerColorLocal _color;
_mrkFinal setMarkerTextLocal _text;
Explanation:

Creates local marker with random ID
Sets icon, color, and text
Position Update Loop:
Sqf

Apply
while {(alive _veh) and {!(isNull _veh) and {(revealX or _convoy or (_veh getVariable ["revealed",false]))}}} do {
	_pos = getPos _veh;
	_mrkFinal setMarkerPosLocal _pos;
	sleep 60;
};

deleteMarkerLocal _mrkFinal;
Explanation:

Updates position every 60 seconds while conditions met:
Vehicle alive and not null
Either: global reveal flag, is convoy, or vehicle revealed flag set
Deletes marker when conditions fail
Where it leads:

Uses global variables: revealX, colorOccupants, colorInvaders, colorTeamPlayer, colorCivilian
Uses localized strings for marker text and notifications
Called by: Reconnaissance systems, convoy tracking, mission objectives
Modifies: Creates and deletes local markers
Network implications: Local only (markers are client-side)
Error handling: None apparent (simple loop with deletion)
Function Name: fn_mortyAI.sqf (Not in list but referenced)
Note: This function was referenced in the CfgFunctions.hpp but not provided. Based on naming and context, it likely manages mortar AI, but cannot be documented without the source file.

Function Name: fn_chargeWithSmoke.sqf (Not in list but referenced)
Note: This function was referenced in 
fn_unitGetToCover.sqf
 but not provided. Based on context, it likely makes units charge under smoke cover.

Final Notes on System Integration:
Data Flow:

fn_typeOfSoldier → provides soldier classification used by fn_staticMGDrill, fn_mortyAI, fn_enemyGarrison
fn_surrenderAction → triggered by combat functions when units are defeated
fn_undercoverAI → triggered when AI follows undercover players
fn_unitGetToCover → called by combat AI when taking fire
fn_useFlares → called by night combat AI for illumination
fn_vehicleConvoyTravel → used by convoy missions
fn_vehicleMarkers → used by reconnaissance systems
fn_VANTinfo → used by airborne reconnaissance
Common Patterns:

All functions use params for parameter validation
Most implement cooldown/limiting systems
Heavy use of A3A_fnc_canFight for combat capability checks
Extensive use of spawn for asynchronous operations
Reliance on faction configuration via Faction() and A3A_faction_* globals
Error Handling:

Early exits for invalid states
Locality checks for hardware-dependent operations
Cleanup code in most functions
Fallback configurations for missing data
Performance Considerations:

Sleep statements used to prevent loop spam
Caching of expensive computations (e.g., typeOfSoldier in variable)
Local execution for visual/debug features
Minimal network traffic (remoteExec used sparingly)
Network Architecture:

Server-side for game state changes (support changes, zone checks)
Local execution for AI behavior and visuals
JIP persistence for important flags (surrendered, etc.)
Remote execution for player-facing actions (notifications, flag actions)

Function Name: fn_staticMGDrill.sqf
What it does:
Manages the dynamic mounting/dismounting behavior for static weapon gunners (MG and mortar operators). The function runs in a continuous loop while the gunner is alive, handling the mounting process when enemies are detected and the dismounting process when threats are eliminated or the gunner becomes incapacitated. It coordinates between a gunner unit and a helper unit to establish the static weapon, manages the mounting animation, handles weapon deployment, and tracks both units' participation in the group's flanker system.

How it does that:
The function begins by identifying the gunner and helper unit from the input array, distinguishing between MG gunners and mortar operators based on their unit type variables. It initializes key variables including group association, mounted status, vehicle object reference, side information, faction data, and backpack states. The main loop continuously checks the gunner's alive status, helper status, vehicle status, and group objectives.

Code Implementation:
Sqf

Apply
private ["_gunner","_helperX"];
private _isMortar = false;
{if (_x getVariable ["typeOfSoldier",""] == "StaticGunner") then {_gunner = _x} else {_helperX = _x}} forEach _this;
{if (_x getVariable ["typeOfSoldier",""] == "StaticMortar") then {_gunner = _x;_isMortar = true} else {_helperX = _x}} forEach _this;
private _groupX = group _gunner;
private _mounted = false;
private _veh = objNull;
private _sideX = side _groupX;
private _faction = Faction(_sideX);
private _typeVehX = selectRandom (if !(_isMortar) then { _faction get "staticMGs" } else { _faction get "staticMortars" });
private _backpckG = backPack _gunner;
private _backpckA = backpack _helperX;
Explanation:

Initializes _gunner and _helperX to null values
Uses two separate loops to identify units with "StaticGunner" or "StaticMortar" soldier types
The second loop overwrites findings to handle the case where mortar units might be identified first
_isMortar flag tracks whether dealing with mortar or MG units
Retrieves group, side, and faction information
Selects random static weapon type from faction configuration
Stores original backpack configurations for restoration during dismount
Main Loop Implementation:
Sqf

Apply
while {(alive _gunner)} do
{
	if (!(alive _helperX) and !(_mounted)) exitWith {};
	if (!(isNull _veh) and !(alive _veh)) exitWith {};
	_objectivesX = _groupX getVariable ["objectivesX",[]];
	_enemyX = objNull;
	if (!(_objectivesX isEqualTo []) and (((_objectivesX select 0) select 4) distance _gunner > 150))  then
		{
		// Enemy detection logic
		};
Explanation:

Continuous loop running while gunner remains alive
Early exit conditions: helper dies before mounting, or vehicle gets destroyed
Retrieves group objectives (pre-computed by higher-level AI system)
Initializes enemyX to null for tracking detected enemies
Enemy Detection Logic:
Sqf

Apply
if !(_isMortar) then
	{
	{
	_eny = _x select 4;
	if !(_eny isKindOf "Tank") then
		{
		if  (([objNull, "VIEW"] checkVisibility [eyePos _eny, eyePos _gunner]) > 0) then
			{
			_enemyX = _eny;
			};
		};
	if !(isNull _enemyX) exitWith {};
	} forEach _objectivesX;
	}
else
	{
	_enemyX = ((_objectivesX select 0) select 4);
	};
Explanation:

For MG units: Iterates through objectives, finds first visible non-tank enemy
Uses checkVisibility to verify line of sight between enemy and gunner
For mortar units: Takes the primary objective enemy directly (mortars don't require direct line of sight)
Exits loop once first valid enemy is found
Mounting Process:
Sqf

Apply
if !(isNull _enemyX) then
{
	if !(_mounted) then
		{
		if !(_gunner getVariable ["maneuvering",false]) then
			{
			if (([_gunner] call A3A_fnc_canFight) and ([_helperX] call A3A_fnc_canFight)) then
				{
				_gunner setVariable ["maneuvering",true];
				_gunner playMoveNow selectRandom medicAnims;
				_gunner setVariable ["timeToBuild",time + 30];
				_gunner addEventHandler ["AnimDone",
					{
					private _gunner = _this select 0;
					if ((time > _gunner getVariable ["timeToBuild",0]) or !([_gunner] call A3A_fnc_canFight)) then
						{
						_gunner removeEventHandler ["AnimDone",_thisEventHandler];
						_gunner setVariable ["maneuvering",false];
						}
					else
						{
						_gunner playMoveNow selectRandom medicAnims;
						};
					}];
				waitUntil {sleep 0.5; !(_gunner getVariable ["maneuvering",false])};
				_gunner setVariable ["timeToBuild",nil];
				if ([_gunner] call A3A_fnc_canFight) then
					{
					private _veh = _typeVehX createVehicle [0,0,1000];
					_veh setPos position (_gunner);
					removeBackpackGlobal _gunner;
					removeBackpackGlobal _helperX;
					_groupX addVehicle _veh;
					_gunner assignAsGunner _veh;
					[_gunner] orderGetIn true;
					[_gunner] allowGetIn true;
					_gunner moveInGunner _veh;
					[_veh, side _groupX] call A3A_fnc_AIVEHinit;
					_mounted = true;
					if (_isMortar) then {_groupX setVariable ["mortarsX",_gunner]};
					sleep 60;
					};
				};
			};
		}
Explanation:

Mounting only triggers when not already mounted and enemy is detected
Prevents concurrent maneuvers with maneuvering variable
Checks both units can fight using A3A_fnc_canFight
Plays mounting animation (using medic animations as placeholder for deployment animation)
Adds timed animation handler that repeats the animation until 30 seconds pass or combat ability is lost
After animation completes, creates vehicle at gunner position (moved away from 0,0,1000 to prevent spawning issues)
Removes backpacks (critical for mortar assembly mechanics)
Assigns gunner as vehicle gunner and moves them into the vehicle
Initializes vehicle with faction-specific AI behavior via A3A_fnc_AIVEHinit
Sets mounted flag and mortar tracking variable
60-second cooldown after mounting
Dismounting Logic:
Sqf

Apply
if (_gunner getVariable ["maneuvering",false]) then
	{
	if (([_gunner] call A3A_fnc_canFight) and ([_helperX] call A3A_fnc_canFight)) then
		{
		[_gunner] orderGetIn false;
		[_gunner] allowGetIn false;
		waitUntil {sleep 1; (vehicle _gunner == _gunner) or !(alive _gunner)};
		if (alive _gunner) then
			{
			_mounted = false;
			_gunner addBackpackGlobal _backpckG;
			_helperX addBackpackGlobal _backpckA;
			deleteVehicle _veh;
			_gunner call A3A_fnc_recallGroup;
			if (_isMortar) then {_groupX setVariable ["mortarsX",objNull]};
			};
		};
	};
Explanation:

Dismounting triggers when maneuvering flag is set (by combat logic elsewhere)
Orders gunner out of vehicle and disables get-in orders
Waits for gunner to exit vehicle or become dead
If alive, restores backpacks, deletes the vehicle, and recalls the gunner back to group control
Clears mortar tracking variable for mortar units
No Enemy Present Logic:
Sqf

Apply
else
{
	if (_mounted) then
		{
		if (([_gunner] call A3A_fnc_canFight) and ([_helperX] call A3A_fnc_canFight)) then
			{
			[_gunner] orderGetIn false;
			[_gunner] allowGetIn false;
			_veh = vehicle _gunner;
			moveOut _gunner;
			_mounted = false;
			_gunner addBackpackGlobal _backpckG;
			_helperX addBackpackGlobal _backpckA;
			deleteVehicle _veh;
			_gunner call A3A_fnc_recallGroup;
			if (_isMortar) then {_groupX setVariable ["mortarsX",objNull]};
			};
		};
	};
Explanation:

Executes when no enemy is detected but weapon is already mounted
Gracefully dismounts the weapon if both units remain combat-capable
Uses same restoration logic as maneuvering dismount
Cleanup Logic:
Sqf

Apply
if (alive _gunner) then
{
	[_gunner] orderGetIn false;
	[_gunner] allowGetIn false;
	moveOut _gunner;
	_gunner setVariable ["maneuvering",false];
	_flankers = _groupX getVariable ["flankers",[]];
	_flankers pushBack _gunner;
	_groupX setVariable ["flankers",_flankers];
	_gunner call A3A_fnc_recallGroup;
};
if (alive _helperX) then
{
	_helperX setVariable ["maneuvering",false];
	_flankers = _groupX getVariable ["flankers",[]];
	_flankers pushBack _helperX;
	_groupX setVariable ["flankers",_flankers];
	_helperX call A3A_fnc_recallGroup;
};
Explanation:

Runs when gunner dies or main loop exits
Forces both units out of vehicles and clears maneuvering state
Adds both units to group's "flankers" array for tactical repositioning
Recalls both units back to standard group behavior
Where it leads:

Calls A3A_fnc_canFight (12 calls) - checks if unit is combat-effective
Calls A3A_fnc_AIVEHinit (1 call) - initializes AI vehicle behavior
Calls A3A_fnc_recallGroup (3 calls) - returns unit to group AI control
Depends on typeOfSoldier variable (set by 
fn_typeOfSoldier.sqf
)
Depends on Faction() function for faction configuration
Called by mission scripts or group AI systems when static weapon units are present
Modifies group variable mortarsX for mortar tracking
Modifies group variable flankers for tactical positioning
Uses global medicAnims array for animation selection
Network implications: Uses removeBackpackGlobal, addBackpackGlobal which are global operations
Error handling: Multiple exit conditions prevent infinite loops or script failures
Function Name: fn_suppressingFire.sqf
What it does:
Orders a unit to provide suppressive fire toward an enemy unit. Implements cooldowns to prevent spam, checks for player presence in group to avoid AI interfering with human player actions, verifies line of sight, and uses Arma's built-in suppression system.

How it does that:
The function validates input parameters, checks group composition for player presence, implements a cooldown timer, verifies line of sight to the target, then issues suppression commands.

Code Implementation:
Sqf

Apply
params ["_unit", "_eny"];
Explanation:

Accepts two parameters: the unit to fire, and the enemy target
Uses SQF params for automatic type checking and validation
Parameter Validation and Early Exit Conditions:
Sqf

Apply
if ({isPlayer _x} count (units group _unit) > 0) exitWith {};
if (time < _unit getVariable ["supressing",time - 1]) exitWith {};
if (([objNull, "VIEW"] checkVisibility [eyePos _eny, eyePos _unit]) == 0) exitWith {};
Explanation:

First condition: If the unit's group contains any player, exit immediately (prevent AI interference with human play)
Second condition: Checks cooldown variable supressing - if current time is less than stored time, exit (prevents command spam)
Third condition: Uses checkVisibility with "VIEW" memory point to verify line of sight from enemy to unit (value 0 means no visibility)
Command Execution:
Sqf

Apply
_unit setVariable ["supressing",time + 60];
_unit commandSuppressiveFire _eny;
_unit suppressFor 10;
Explanation:

Sets cooldown for 60 seconds
Issues command-level suppression (Arma AI will fire in bursts toward target)
Uses suppressFor to activate Arma's suppression system for 10 seconds (increases enemy suppression status)
Where it leads:

Calls no other A3A functions directly
Uses Arma's built-in commandSuppressiveFire and suppressFor commands
Interacts with variable supressing (note: misspelled - should be "suppressing") for cooldown tracking
No network implications (local execution only)
No persistent state modifications
Typical call sites: Various AI combat scripts, like fn_mortyAI, fn_chargeWithSmoke, or custom AI behaviors
Function Name: fn_surrenderAction.sqf
What it does:
Handles the complete surrender process for a unit. Converts the unit into a captive, strips their equipment into a surrender crate, assigns them to a surrender-specific group, handles special cases like rival units with laptops, updates city support based on faction, spawns timed cleanup, and sets up event handlers for post-surrender behavior.

How it does that:
The function performs locality validation, checks surrender state, handles special unit types (dogs), validates combat state, then executes a multi-step surrender process including equipment transfer, group reassignment, crate creation, support changes, and cleanup spawning.

Code Implementation:
Sqf

Apply
params ["_unit"];
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Explanation:

Standard function header with includes for debugging
Accepts unit parameter
Locality Validation:
Sqf

Apply
if !(local _unit) exitWith {
    Error("Function miscalled with non-local unit");
	[_unit] remoteExec ["A3A_fnc_surrenderAction", _unit];
};
Explanation:

Checks if unit is local to this machine (critical for hardware execution and event handlers)
If not local, logs error and re-executes the function on the unit's local machine via remoteExec
State Validation and Early Exit:
Sqf

Apply
if (_unit getVariable ["surrendered", false]) exitWith {};
_unit setVariable ["surrendered", true, true];

if (typeOf _unit == "Fin_random_F") exitWith {};		// dogs do not surrender?
if (!alive _unit) exitWith {};							// Used to happen with ACE, seems to be fixed
if (lifeState _unit == "INCAPACITATED") exitWith {
    Info("Unit attempted to surrender while incapacitated");
	_unit setVariable ["surrendered", false, true];
};
Explanation:

Checks if already surrendered (prevent double-processing)
Sets surrendered flag with JIP persistence (third parameter true)
Special case: Dogs (unit type "Fin_random_F") cannot surrender
Validates unit is alive
Prevents incapacitated units from surrendering (resets surrender flag if attempted)
Unit State Modification:
Sqf

Apply
private _unitSide = side group _unit;
_unit allowDamage false;		// give players a couple of seconds to stop shooting
_unit setCaptive true;
_unit stop true;
_unit disableAI "MOVE";
_unit disableAI "AUTOTARGET";
_unit disableAI "TARGET";
_unit disableAI "ANIM";
_unit setSkill 0;
unassignVehicle _unit;			// stop them getting back into vehicles
[_unit] orderGetin false;
_unit setUnitPos "UP";
_unit playMoveNow "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";		// hands up?
_unit setVariable ["A3U_PoW_unitType", _unit getVariable "unitType", true]; // in case the original unitType is needed for something else in the future
_unit setVariable ["A3U_PoW_speaker", speaker _unit, true];
_unit setSpeaker "NoVoice";
Explanation:

Captures original side for later use
Disables damage to prevent immediate death after surrender (gives players time to stop shooting)
Sets captive flag (prevents AI targeting)
Stops unit movement and disables all AI behaviors (move, target, auto-target, animation)
Removes unit skill (prevents any combat capability)
Unassigns from vehicles and prevents re-boarding
Forces standing position and plays surrender animation
Preserves original unit type and speaker in persistent variables
Removes voice to prevent annoying surrender shouts
Spawner Prevention:
Sqf

Apply
if (_unit getVariable ["spawner", false]) then { _unit setVariable ["spawner", nil, true] };
Explanation:

Prevents surrendered units from spawning garrisons (if they were marked as spawners)
Clears the spawner flag with JIP persistence
Group Reassignment:
Sqf

Apply
private _grpIdx = allGroups findIf { local _x && (side _x == _unitSide) && {_x getVariable ["surrenderGroup", false]} };
if (_grpIdx == -1) then {
	private _grp = createGroup _unitSide;
	_grp setVariable ["surrenderGroup", true, true];
	[_unit] joinSilent _grp;
} else {
	[_unit] joinSilent (allGroups select _grpIdx);
};
Explanation:

Searches for existing surrender group on same side and local to this machine
If none exists, creates new group and marks it as surrender group
If exists, joins existing group using joinSilent (no group chatter)
Groups are side-specific (Occupants/Invaders/Resistance) to maintain side affiliation
Surrender Crate Creation:
Sqf

Apply
private _surrenderCrateType = if (_unit getVariable ["isRival", false]) then {
	A3A_faction_riv get "surrenderCrate"
} else {
	(Faction(_unitSide)) get "surrenderCrate"
};
private _boxX = _surrenderCrateType createVehicle position _unit;
_boxX allowDamage false;
clearMagazineCargoGlobal _boxX;
clearWeaponCargoGlobal _boxX;
clearItemCargoGlobal _boxX;
clearBackpackCargoGlobal _boxX;
Explanation:

Determines crate type based on faction (rivals vs standard)
Creates crate at unit's position
Prevents crate destruction
Clears all cargo slots (weapon, magazine, item, backpack)
Special Rival Case:
Sqf

Apply
if (_unit getVariable ["hasLaptop", false] && {!(_unit getVariable ["hasLaptopSpawned", false])}) then
{
	[_unit] call SCRT_fnc_rivals_createLaptop;
	_unit setVariable ["hasLaptopSpawned", true, true]; //not sure if it should be broadcasted
};
Explanation:

Checks if rival unit has laptop and hasn't already spawned it
Calls rival-specific function to create laptop
Marks laptop as spawned with JIP persistence
Equipment Transfer to Crate:
Sqf

Apply
private _loadout = getUnitLoadout _unit;
for "_i" from 0 to 2 do {
	if !(_loadout select _i isEqualTo []) then {
		_boxX addWeaponWithAttachmentsCargoGlobal [_loadout select _i, 1];
	};
};
{_boxX addMagazineCargoGlobal [_x,1]} forEach (magazines _unit);
{_boxX addItemCargoGlobal [_x,1]} forEach (assignedItems _unit);
{_boxX addItemCargoGlobal [_x,1]} forEach (items _unit);
{_boxX addItemCargoGlobal [_x,1]} forEach [vest _unit, headgear _unit, goggles _unit];
private _backpack = backpack _unit;
if (_backpack != "") then {
	// because backpacks are often subclasses containing items
	_backpack = _backpack call A3A_fnc_basicBackpack;
	_boxX addBackpackCargoGlobal [_backpack, 1];
};
_unit setUnitLoadout [ [], [], [], [uniform _unit, []], [], [], "", "", [], ["","","","","",""] ];
Explanation:

Gets complete unit loadout array
Transfers primary, secondary, and handgun weapons (with attachments) to crate
Transfers all magazines, assigned items (like GPS, radio), and items
Transfers vest, headgear, and goggles
For backpacks: Uses A3A_fnc_basicBackpack to get base class, transfers single backpack
Strips unit completely, leaving only uniform (which may be faction-specific)
Dropped Weapon Cleanup:
Sqf

Apply
{
	_boxX addWeaponWithAttachmentsCargoGlobal [(weaponsItemsCargo _x) select 0, 1];
	deleteVehicle _x;
} forEach nearestObjects [_unit,["WeaponHolderSimulated"],5,true];
Explanation:

Finds all weapon holders (simulated) within 5 meters of unit
Adds first weapon from each holder to crate
Deletes the weapon holder object
Prevents duplicate weapons on ground
City Support Updates:
Sqf

Apply
if (_unitSide == Occupants) then {
	[-2, 0, getPos _unit] remoteExec ["A3A_fnc_citySupportChange", 2];
} else {
	[0, 1, getPos _unit] remoteExec ["A3A_fnc_citySupportChange", 2];
};
Explanation:

Updates city support based on surrendered unit's side
Occupant surrender reduces support by 2, Invader surrender increases support by 1
Executes on server (owner 2) for global effect
Marker Zone Check:
Sqf

Apply
private _markerX = _unit getVariable "markerX";
if (!isNil "_markerX") then { [_markerX, _unitSide] remoteExec ["A3A_fnc_zoneCheck", 2] };
Explanation:

Checks if unit was associated with a marker (likely for garrison units)
Triggers zone check on server to update garrison status
Timed Cleanup Spawning:
Sqf

Apply
[_unit] spawn A3A_fnc_postmortem;
[_boxX] spawn A3A_fnc_postmortem;
Explanation:

Spawns cleanup functions for both unit and crate
postmortem handles delayed deletion and final resource calculations
Damage Handler Setup:
Sqf

Apply
sleep 3;				// Also protects against box kills
_unit allowDamage true;
private _handlerDamage = _unit addEventHandler ["HandleDamage", {
	// If unit gets injured after the delay, run away
	params ["_unit","_part","_damage"];
	if (_damage < 0.2) exitWith {};
	[_unit, "remove"] remoteExec ["A3A_fnc_flagaction", [teamPlayer, civilian], _unit];
	[_unit, side group _unit] spawn A3A_fnc_fleeToSide;
	_unit removeEventHandler ["HandleDamage", _thisEventHandler];
	nil;
}];
_unit setVariable ["A3U_PoW_EH_HandleDamage", _handlerDamage, true];
Explanation:

Waits 3 seconds before re-enabling damage (protects from accidental box explosions)
Adds damage event handler that triggers if damage exceeds 0.2
Handler removes flag action and makes unit flee to side
Removes itself after execution
Stores handler reference in variable for potential removal
Final Flag Actions:
Sqf

Apply
if (_unit getVariable ["isRival", false]) then {
	[_unit,"captureRivals"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
} else {
	[_unit,"captureX"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
};
Explanation:

Adds capture flag action to unit (allows players to lead POWs)
Rivals get different flag action for special handling
Executed on all players (teamPlayer, civilian) but only triggers on the unit
Where it leads:

Calls SCRT_fnc_rivals_createLaptop (1 call, conditional) - creates laptop for rivals
Calls A3A_fnc_basicBackpack (1 call, conditional) - gets base backpack class
Calls A3A_fnc_citySupportChange (1 call, remote) - updates city support
Calls A3A_fnc_zoneCheck (1 call, remote, conditional) - updates garrison zones
Calls A3A_fnc_postmortem (2 calls) - spawns cleanup
Calls A3A_fnc_fleeToSide (1 call, conditional) - makes unit flee if damaged
Calls A3A_fnc_flagaction (1 call, remote) - adds capture action
Depends on A3A_fnc_typeOfSoldier for unit classification
Depends on Faction() function for surrender crate type
Called by various sources: fn_AIreactOnKill, fn_chargeWithSmoke, mission scripts, player interactions
Modifies: surrendered, spawner, A3U_PoW_unitType, A3U_PoW_speaker, hasLaptopSpawned, A3U_PoW_EH_HandleDamage variables
Network implications: Multiple remoteExec calls for server-side updates, local changes to unit state
Error handling: Locality validation, state checks, conditional execution paths
Function Name: fn_typeOfSoldier.sqf
What it does:
Classifies a unit into a specific soldier type (Medic, Engineer, ATMan, AAMan, MGMan, Sniper, StaticMortar, StaticGunner, StaticBase, or Normal) based on their inventory, traits, and equipment. Used by many AI systems to determine unit roles and capabilities. Caches the result in the unit's typeOfSoldier variable for performance.

How it does that:
Uses a switch statement with multiple checks to determine unit type. Checks are ordered from specific to general: medical trait, mines, secondary weapon (AT/AA), primary weapon type (MG/sniper), and static weapon assembly info. Implements helper functions for each check type.

Code Implementation:
Helper Functions Definition:
Sqf

Apply
private _fnc_isRight = {
    if (_soldierType isEqualTo "") exitWith { false };
    if (_soldierType isEqualTo "ATMan") exitWith { false };
    if (_soldierType isEqualTo "AAMan") exitWith { false };
    if (_soldierType isEqualTo "Engineer") exitWith { false };
    true
};
Explanation:

Checks if _soldierType is valid and not one of the specific combat types
Used to prevent re-classifying already classified units
This is a bug: it should check against the cached value, not _soldierType
Sqf

Apply
private _fnc_haveMines = {
    (magazines _unit) findIf { (_x call BIS_fnc_itemType) # 0 == "Mine" } != -1
};
Explanation:

Checks if unit magazines contain any mine type
Uses BIS function to get item type
Returns true if at least one mine is found
Sqf

Apply
private _fnc_isAT = {
    if (secondaryWeapon _unit == "") exitWith { false };

    private _sWBase = [secondaryWeapon _unit] call BIS_fnc_baseWeapon;
    private _magTypeAT = (getArray MAGS(_sWBase)) # 0;

    if ((magazinesAmmoFull _unit) findIf { _x # 0 == _magTypeAT } == -1)
    exitWith { false };

    private _ammo = getText MAG_AMMO(_magTypeAT);
    _isAA = getNumber AIRLOCK(_ammo) != 0;

    !_isAA
};
Explanation:

Checks for secondary weapon (launcher)
Gets base weapon class (removes variants)
Gets first magazine type for that weapon
Checks if unit has any of that magazine type
Determines if ammunition is AA-capable (airLock > 0)
Returns true only if it's an AT (non-AA) launcher
Sqf

Apply
private _fnc_isMortar = {
    private _return = false;
    private _backpack = backpack _unit;

    if (_backpack == "")
    then
    {
        private _vehicle = vehicle _unit;

        if !(_vehicle isKindOf "StaticWeapon") exitWith {};

        _return = _vehicle isKindOf "StaticMortar";
        _isStaticGunner = !_return;
    }
    else
    {
        if !(isClass ASSEMBLE_INFO(_backpack)) exitWith {};

        private _backpackWeapon = getText ASSEMBLE_WEAPON(_backpack);

        if (_backpackWeapon == "") exitWith { _isStaticBase = true; };

        _return = _backpackWeapon isKindOf "StaticMortar";
        _isStaticGunner = !_return;
    };

    _return
};
Explanation:

Checks for static weapon identification
If no backpack: checks if unit is in a static weapon (mortar or MG)
If backpack exists: checks assembleInfo config for weapon type
Sets _isStaticGunner and _isStaticBase flags for later use
Returns true for mortar, false for MG
Main Classification Logic:
Sqf

Apply
private _unit = _this;

private _soldierType = _unit getVariable ["typeOfSoldier", ""];
private _toSet = true;

_soldierType = switch (true)
do
{
    case (call _fnc_isRight): { _toSet = false; _soldierType };
    case ([_unit] call A3A_fnc_isMedic): { "Medic" };
    case (call _fnc_haveMines): { "Engineer" };

    private _isAA = false;

    case (call _fnc_isAT): { "ATMan" };
    case (_isAA): { "AAMan" };

    private _pWBase = [primaryWeapon _unit] call BIS_fnc_baseWeapon;

    case (_pWBase in allMachineGuns): { "MGMan" };
    case (_pWBase in allSniperRifles): { "Sniper" };

    private _isStaticGunner = false;
    private _isStaticBase = false;

    case (call _fnc_isMortar): { "StaticMortar" };
    case (_isStaticGunner): { "StaticGunner" };
    case (_isStaticBase): { "StaticBase" };

    default { "Normal" };
};
Explanation:

Retrieves cached typeOfSoldier variable
Uses switch(true) to evaluate each case in order
Case order is critical: more specific types checked first
Medic check uses A3A_fnc_isMedic (checks medical items and trait)
Engineer check looks for mines
ATMan check uses helper function
Bug: _isAA is set but never updated, so AAMan case never triggers
MGMan checks against allMachineGuns global array
Sniper checks against allSniperRifles global array
Static checks use helper function that sets multiple flags
Default returns "Normal"
Sqf

Apply
if (_toSet) then { _unit setVariable ["typeOfSoldier", _soldierType]; };
Explanation:

Sets the variable only if _toSet is true (not if already classified with a valid type)
Bug: Due to _fnc_isRight logic, units already classified as ATMan/AAMan/Engineer won't be re-classified
Sqf

Apply
_soldierType
Explanation:

Returns the determined soldier type
Where it leads:

Calls A3A_fnc_isMedic (1 call) - checks if unit is a medic
Uses BIS functions: BIS_fnc_itemType, BIS_fnc_baseWeapon
Uses config queries: MAGS, MAG_AMMO, AIRLOCK, ASSEMBLE_INFO, ASSEMBLE_WEAPON
Depends on global arrays: allMachineGuns, allSniperRifles
Called by: fn_staticMGDrill, fn_mortyAI, fn_enemyGarrison, fn_garrisonInfo, mission scripts
Modifies: typeOfSoldier variable (unit-specific)
Error handling: Multiple exit conditions in helper functions, safe config access
Note: The _isAA bug means AA-man units get misclassified (likely as normal or ATMan)
Function Name: fn_undercoverAI.sqf
What it does:
Manages AI units going undercover when near an undercover player leader. The function dresses AI in civilian clothing, disables their combat AI, and periodically checks if they're still near the leader. If the leader gets exposed or the AI leaves the area, the AI is restored to combat state.

How it does that:
Validates unit conditions (non-player, has player leader, leader is undercover), then executes a temporary disguise process with continuous monitoring of the leader's undercover status and the AI's proximity and equipment.

Code Implementation:
Initial Validation:
Sqf

Apply
params ["_unit"];
if (isPlayer _unit) exitWith {};
private _leader = _unit getVariable ["owner",leader group _unit];
if (!isPlayer _leader) exitWith {};
if (!captive _leader) exitWith {};
if (captive _unit) exitWith {};
Explanation:

Exits if unit is a player (only for AI)
Gets leader from unit's owner variable or group leader
Validates leader is a player and is currently captive (undercover)
Exits if unit is already undercover
Undercover State Setup:
Sqf

Apply
[_unit,true] remoteExec ["setCaptive",_unit];
_unit setCaptive true;
_unit disableAI "TARGET";
_unit disableAI "AUTOTARGET";

private _oldBehaviour = combatBehaviour _unit;		// actually the same as behaviour _unit?

_unit setCombatBehaviour "CARELESS";
_unit setUnitPos "UP";
Explanation:

Sets captive status via remoteExec for network sync
Disables targeting and auto-targeting AI
Saves original combat behavior
Sets behavior to CARELESS (won't engage enemies)
Forces standing position
Equipment Stripping:
Sqf

Apply
private _loadOut = getUnitLoadout _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeAllWeapons _unit;			// also removes magazines
removeGoggles _unit;
removeVest _unit;

_unit addHeadgear (selectRandom (A3A_faction_civ get "headgear"));
_unit forceAddUniform (selectRandom (A3A_faction_civ get "uniforms"));
Explanation:

Backs up complete loadout
Removes all items, assigned items (radio, GPS, etc.), weapons, magazines, goggles, vest
Adds random civilian headgear and uniform from faction configuration
Uses forceAddUniform to override any existing uniform
Monitoring Loop:
Sqf

Apply
while {captive _leader && {captive _unit}} do{
	sleep 1;
	if ((vehicle _unit != _unit) and (not((typeOf vehicle _unit) in undercoverVehicles))) exitWith {};
	if ((primaryWeapon _unit != "") or (secondaryWeapon _unit != "") or (handgunWeapon _unit != "")) exitWith {};
};
Explanation:

Continues while both leader and unit remain undercover
Checks every second
Exit conditions:
Unit is in a vehicle not in undercoverVehicles list
Unit somehow gets weapons back (shouldn't happen with removal)
Uses undercoverVehicles global array
Exit State Restoration:
Sqf

Apply
if (!captive _unit) then {
	_unit groupChat (selectRandom [
		localize "STR_outpost_ai_spotted_1",
		localize "STR_outpost_ai_spotted_2",
		localize "STR_outpost_ai_spotted_3"
	]);
} else {
	[_unit,false] remoteExec ["setCaptive",_unit]; 
	_unit setCaptive false
};
if (captive _leader) then {sleep 5};
_unit setCombatBehaviour _oldBehaviour;
_unit enableAI "TARGET";
_unit enableAI "AUTOTARGET";
_unit setUnitPos "AUTO";
Explanation:

If unit exposed (not captive), plays random group chat message
If unit still undercover but loop ended (leader exposed), removes captive status
If leader still undercover after unit loop ends, waits 5 seconds (gives time for re-distancing)
Restores original combat behavior, re-enables targeting AI, resets unit position
Loadout Restoration:
Sqf

Apply
// Remove backpack if changed, prevents static/device dupe exploits
if (_loadOut#5 isNotEqualTo [] and { backpack _unit != _loadOut#5#0 }) then { _loadOut set [5, []] };
_unit setUnitLoadout _loadOut;
Explanation:

Checks if backpack was changed during undercover (exploit prevention)
Clears backpack from loadout array if modified
Restores original loadout
Where it leads:

Uses global variable undercoverVehicles
Uses faction data from A3A_faction_civ
Called by: Player undercover system, mission scripts when AI needs to follow undercover players
Modifies: setCaptive status, AI abilities, loadout, position
Network implications: Uses remoteExec for captive syncing, unit locality matters
Error handling: Multiple exit conditions, safe state restoration
Function Name: fn_unitGetToCover.sqf
What it does:
Directs a unit to move to the nearest cover position away from an enemy. Uses a coverage finding system to calculate safe positions, temporarily disables AI behaviors during movement, and re-enables them after reaching cover or timeout.

How it does that:
Validates unit conditions (non-player, on foot, not in combat, can fight), finds enemy, calculates cover using coverage function, then moves unit to cover with AI disabled for precision.

Code Implementation:
Initial Validation:
Sqf

Apply
private _unit = _this select 0;

if (isPlayer _unit) exitWith {};
if (_unit != vehicle _unit) exitWith {};
if (behaviour _unit isEqualTo "COMBAT" or {behaviour _unit isEqualTo "STEALTH"}) exitWith {};
if !([_unit] call A3A_fnc_canFight) exitWith {};
Explanation:

Exits if unit is player
Exits if not on foot (in vehicle)
Exits if already in combat or stealth behavior
Exits if unit cannot fight (injured, suppressed, etc.)
Enemy Selection:
Sqf

Apply
private _enemy = if (count _this > 1) then {_this select 1} else {_unit findNearestEnemy _unit};

if (isNull _enemy) exitWith {};
if (_unit distance _enemy < 300) exitWith {};
if (random 100 < 35) then {[_unit,_unit,_enemy] call A3A_fnc_chargeWithSmoke};
Explanation:

Uses provided enemy or finds nearest enemy automatically
Exits if no enemy found
Exits if enemy is too close (within 300m) - not worth repositioning
35% chance to call smoke charge function to provide smoke cover
Cover Calculation:
Sqf

Apply
_coverX = [_unit,_enemy] call A3A_fnc_coverage;

if (_coverX isEqualTo []) exitWith {};
Explanation:

Calls A3A_fnc_coverage to find suitable cover position
Exits if no cover found
Movement Execution:
Sqf

Apply
_unit stop false;
_unit forceSpeed -1;
{_unit disableAI _x} forEach ["AUTOTARGET","FSM","TARGET","SUPPRESSION","AUTOCOMBAT","WEAPONAIM","COVER","CHECKVISIBLE"];
_unit setUnitPos "MIDDLE";
_unit setCombatMode "BLUE";
_unit doMove _coverX;
Explanation:

Enables movement (stop false)
Sets speed to automatic (forceSpeed -1)
Disables multiple AI features for precise movement control
Sets unit to crouch position ("MIDDLE") - lower profile during movement
Sets combat mode to "BLUE" (never fire)
Uses doMove for direct movement command
Movement Completion Monitor:
Sqf

Apply
[_unit,_coverX] spawn {
	params ["_unit", "_coverX"];
	private _timeOut = time + 15;
	waitUntil {sleep 0.5; (_unit distance _coverX < 1) or (time > _timeOut)};
	if (_unit distance _coverX < 1) then {
		sleep 1;
		_unit stop true;
		_unit forceSpeed 0;
		_unit setCombatMode "YELLOW";
		_unit setUnitPos "AUTO";
		_unit doWatch (_unit findNearestEnemy _unit);
		sleep 30;
	};
	{_unit enableAI _x} forEach ["AUTOTARGET","FSM","TARGET","SUPPRESSION","AUTOCOMBAT","WEAPONAIM","COVER","CHECKVISIBLE"];
	_unit setCombatMode "YELLOW";
	_unit forceSpeed -1;
	_unit stop false;
	_unit setUnitPos "AUTO";
};
Explanation:

Spawns separate monitoring thread
Timeout of 15 seconds for movement
If reached cover: stops unit, sets speed to 0, combat mode to YELLOW (open fire), auto position, watches nearest enemy, waits 30 seconds of cover holding
Regardless of success/failure: re-enables all disabled AI features, restores combat mode to YELLOW, enables movement, sets auto position
Where it leads:

Calls A3A_fnc_canFight (1 call) - checks combat capability
Calls A3A_fnc_chargeWithSmoke (1 call, 35% chance) - provides smoke cover
Calls A3A_fnc_coverage (1 call) - finds cover position
Called by: fn_mortyAI, fn_chargeWithSmoke, other AI combat scripts
Modifies: AI capabilities, movement state, combat mode, position
Network implications: Local execution only
Error handling: Multiple exit conditions, spawn thread for asynchronous completion
Note: The 30-second cover hold might be excessive but gives units time to engage from cover
Function Name: fn_useFlares.sqf
What it does:
Makes a unit fire a flare into the air to illuminate the area around an enemy. Implements cooldown, limits flare count per unit, checks for existing flares in area, and creates flares at appropriate height with random velocity.

How it does that:
Validates unit and enemy conditions, checks cooldown and flare count, selects flare type from faction, calculates launch position, creates flare with random velocity, and plays sound effect.

Code Implementation:
Initial Setup and Validation:
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
	["_unit", objNull], 
	["_side", sideUnknown],
	["_enemy", objNull]
];

sleep random 5;

if (time < _unit getVariable ["smokeUsed",time - 1]) exitWith {};
if (vehicle _unit != _unit) exitWith {};
if (!isNull _enemy && {_enemy distance _unit > 450}) exitWith {};
if (!(_unit call A3A_fnc_canFight)) exitWith {};
Explanation:

Random 0-5 second delay prevents multiple units firing flares simultaneously
Checks cooldown variable smokeUsed (shared with smoke functions)
Exits if unit is in vehicle
Exits if enemy is too far (>450m) or too close
Exits if unit cannot fight
Flare Management:
Sqf

Apply
private _flares = _unit getVariable ["remainingFlares", round random [1,2,3]];
if (_flares <= 0) exitWith {};

_unit setVariable ["smokeUsed", time + 60];
_unit setVariable ["remainingFlares", (_flares - 1)];
Explanation:

Gets remaining flares (1-3 random if not set)
Exits if no flares left
Sets 60-second cooldown
Decrements flare count
Faction and Flare Selection:
Sqf

Apply
private _target = if (!isNull _enemy) then {_enemy} else {_unit};
private _faction = if (_side != sideUnknown) then {
	Faction(_side);
} else {
	Warning("For some reason side is sideUnknown, taking fallback route.");
	A3A_faction_occ;
};
private _flares = _faction get "flares";
Explanation:

Uses enemy position or unit position as target
Determines faction from provided side or uses Occupants as fallback
Gets flare class list from faction config
Position Calculation and Flare Creation:
Sqf

Apply
if (nearestObjects [(position _target), _flares, 100, true] isNotEqualTo []) exitWith {};

private _initialFlarePosition = _target getPos [random 25,random 360];
_initialFlarePosition set [2, (((getPosATL _target) select 2) + (random [150,175,200]))]; 

private _flare = createVehicle [selectRandom _flares, _initialFlarePosition, [], 0, "CAN_COLLIDE"];
_flare setVelocity [-10+random 10, -10+random 10, -0.000001];

playSound3D [(selectRandom flareSounds), _flare, false,  getPosASL _flare, 1.5, 1, 450, 0];
Explanation:

Exits if another flare already exists within 100m of target
Calculates launch position 0-25m from target at random angle
Sets altitude: target's altitude + 150-200m (typical flare height)
Creates flare vehicle at calculated position
Sets downward velocity (-10 to 10 in X/Y, slight downward in Z)
Plays 3D sound from flare position with attenuation
Where it leads:

Calls A3A_fnc_canFight (1 call) - checks combat capability
Uses faction config via Faction() - gets flare types
Uses global flareSounds array for audio
Called by: fn_mortyAI, fn_chargeWithSmoke, other night combat scripts
Modifies: smokeUsed, remainingFlares variables
Network implications: Local execution only (flares are localized objects)
Error handling: Multiple validation checks, side fallback
Function Name: fn_VANTinfo.sqf
What it does:
Provides airborne vehicle (VANT) reconnaissance, revealing enemy positions to nearby friendly groups. Runs continuously for an airborne vehicle, periodically scans for enemy units within 500m and reveals them to nearby friendly vehicle groups.

How it does that:
In an infinite loop while vehicle is alive, periodically gathers nearby enemies, finds friendly vehicle groups, and uses reveal command to improve their detection of enemies.

Code Implementation:
Parameter Setup:
Sqf

Apply
params ["_veh", "_markerX", "_sideX"];

private _positionX = getMarkerPos _markerX;
private _enemiesS = if (_sideX == Invaders) then {Occupants} else {Invaders};
private ["_groups","_knownX","_groupX"];
Explanation:

Accepts vehicle, marker position, and side
Calculates position from marker
Determines enemy side based on sideX (Opposing side)
Declares variables for groups, known enemies, and group loops
Main Monitoring Loop:
Sqf

Apply
while {alive _veh} do {
	_knownX = [];
	_groups = [];
	_enemiesX = [distanceSPWN,0,_positionX,_sideX] call A3A_fnc_distanceUnits;
	sleep 60;
	_groups = allGroups select {(leader _x in _enemiesX) and ((vehicle leader _x) != (leader _x))};
	_knownX = allUnits select {((side _x == teamPlayer) or (side _x == _enemiesS)) and (alive _x) and (_x distance _positionX < 500)};
	{
		_groupX = _x;
		{
		_groupX reveal [_x,1.4];
		} forEach _knownX;
	} forEach _groups;
};
Explanation:

Continues while vehicle is alive
Uses A3A_fnc_distanceUnits to get spawn-capable units in area (not relevant for VANT but used for efficiency)
60-second scan interval
Finds groups where leader is in spawn area AND leader is in a vehicle (airborne group)
Finds all alive units within 500m that are either resistance or enemy side
For each group: Reveals each known enemy with knowledge level 1.4 (Arma reveal system)
Where it leads:

Calls A3A_fnc_distanceUnits (1 call per loop) - gets spawnable units in area
Called by: VANT support system, airborne reconnaissance missions
Modifies: No persistent variables
Network implications: Local execution only (reveal is local)
Error handling: Minimal (just vehicle alive check)
Function Name: fn_vehicleConvoyTravel.sqf
What it does:
Manages convoy vehicle movement along a predefined route, with speed adjustments based on convoy spacing. Implements collision prevention, stuck detection, and waypoint navigation for vehicles in a convoy formation.

How it does that:
Sets up driver group, creates waypoints for route navigation, monitors vehicle position relative to route and convoy vehicles, adjusts speed based on following distance, handles stuck conditions, and cleans up on completion or failure.

Code Implementation:
Parameter Validation:
Sqf

Apply
params ["_vehicle", "_route", "_convoy", "_maxSpeed", ["_critical", false]];

private _error = call {
    if (count _route == 0) exitWith { "No route specified" };
    if !(alive _vehicle) exitWith { "Dead or missing vehicle input" };
    if !(alive driver _vehicle) exitWith { "Dead or missing driver in vehicle" };
};
if (!isNil "_error") exitWith {
    _convoy deleteAt (_convoy find _vehicle);
    Error(_error);
};
Explanation:

Accepts vehicle, route positions, convoy array, max speed, and critical flag
Validates route has points, vehicle exists, driver is alive
If validation fails, removes vehicle from convoy array and logs error
Driver and Crew Separation:
Sqf

Apply
private _driverGroup = group driver _vehicle;
private _crewGroup = grpNull;
if (count units _driverGroup > 1) then {
    _crewGroup = createGroup (side _driverGroup);
    (units _driverGroup - [driver _vehicle]) joinSilent _crewGroup;
};
_driverGroup setBehaviour "CARELESS";
_vehicle setEffectiveCommander (driver _vehicle);
Explanation:

Gets driver's group
If group has multiple units (crew + driver), creates separate crew group
Moves non-driver units to new group
Sets driver group behavior to CARELESS (won't react to threats)
Sets driver as effective commander
Navigation Setup:
Sqf

Apply
private _destination = _route select (count _route - 1);
private _accuracy = 50;
private _currentNode = 0;
private _nextPos = _route select _currentNode;
private _waypoint = _driverGroup addWaypoint [ATLToASL _nextPos, -1, 0];
_driverGroup setCurrentWaypoint _waypoint;
private _timeout = time + (_vehicle distance2d _nextPos);
Explanation:

Destination is last route point
50m accuracy for waypoint completion
Start at first route point
Creates waypoint at first position
Sets as current waypoint
Sets initial timeout based on distance to first point
Main Movement Loop:
Sqf

Apply
while {true} do
{
    sleep 0.5;
    private _vehIndex = _convoy find _vehicle;

    // Exit conditions
    if (!canMove _vehicle || !alive driver _vehicle || { lifestate driver _vehicle == "INCAPACITATED" }) exitWith {
        ServerInfo("Vehicle or driver died during travel, abandoning");
    };
    if (_vehIndex == -1) exitWith {};				// external abort
    if (_vehicle distance _destination < 100) exitWith {
        ServerDebug("Vehicle arrived at destination");
    };
Explanation:

0.5 second update interval
Gets convoy index for following logic
Exit if: vehicle cannot move, driver dead, driver incapacitated, removed from convoy, reached destination
Waypoint Transition:
Sqf

Apply
    while {_vehicle distance _nextPos < _accuracy} do
    {
        _currentNode = _currentNode + 1;
        _nextPos = _route select _currentNode;
        _waypoint setWaypointPosition [ATLToASL _nextPos, -1];
        _driverGroup setCurrentWaypoint _waypoint;
        _timeout = time + (_vehicle distance2d _nextPos);
    };
    if (!_critical && time > _timeout) exitWith {
        ServerInfo("Vehicle stuck during travel, abandoning");
    };
Explanation:

When within 50m of current waypoint, advances to next route point
Updates waypoint position and current waypoint
Resets timeout based on new distance
Exits if not critical and timeout exceeded (stuck condition)
Stuck Prevention Hack:
Sqf

Apply
    if (unitReady driver _vehicle) then {
        _vehicle setPosWorld (getPosWorld _vehicle vectorAdd vectorDir _vehicle);
        _driverGroup setCurrentWaypoint _waypoint;
    };
Explanation:

If driver indicates ready (but not moving), moves vehicle 1m forward
Resets current waypoint to retry navigation
Works around Arma pathfinding bugs
Speed Adjustment by Convoy Spacing:
Sqf

Apply
    if (_vehIndex == 0) then { _vehicle limitSpeed _maxSpeed } else
    {
        private _followVeh = _convoy select (_vehIndex - 1);
        private _dist = _vehicle distance _followVeh;

        // prevent some off-road passing
        if (_dist < 50) then {
            private _followDir = (getPos _vehicle) vectorFromTo (getPos _followVeh);
            private _targDir = (getpos _vehicle) vectorFromTo _nextPos;
            if (_followDir vectorDotProduct _targDir <= 0) then {_dist = 0};
        };

        private _speed = if (_dist < 30) then { linearConversion [15,30,_dist,0.01,_maxSpeed,true] }
            else { linearConversion [30,60,_dist,_maxSpeed,2*_maxSpeed,true] };
        _vehicle limitSpeed _speed;
        if (_dist < 30) then { _timeout = time + (_vehicle distance2d _nextPos) };
    };
Explanation:

Lead vehicle maintains max speed
Following vehicles adjust speed based on distance to vehicle in front
Off-road passing prevention: if following direction is opposite to target direction, treat as zero distance
Speed calculation:
If <30m: Linear conversion between 0.01 and max speed
If 30-60m: Linear conversion between max speed and 2x max speed
Resets timeout if dangerously close (<30m)
Cleanup:
Sqf

Apply
// Remove from convoy array
_convoy deleteAt (_convoy find _vehicle);

// Merge driver/crew back together
if (!isNull _driverGroup && !isNull _crewGroup) then {
    (units _crewGroup) joinSilent _driverGroup;
    _driverGroup setBehaviour "AWARE";
};
Explanation:

Removes vehicle from convoy array
Merges crew back into driver group
Restores group behavior to AWARE
Where it leads:

Calls ServerInfo and ServerDebug for logging
Called by: Convoy mission scripts, vehicle transport systems
Modifies: Convoy array, group behavior, vehicle speed limits, positions
Network implications: Local execution (movement is local)
Error handling: Comprehensive validation, multiple exit conditions, cleanup on exit
Function Name: fn_vehicleMarkers.sqf
What it does:
Creates and updates a local map marker for a vehicle. Provides visual tracking of vehicle position on map, with different icon types and colors based on vehicle type and side. Includes notification when enemy vehicle is spotted.

How it does that:
Creates a local marker based on vehicle type and side, updates its position periodically, and deletes it when vehicle is destroyed or conditions change.

Code Implementation:
Initial Setup:
Sqf

Apply
params ["_veh", "_text"];

private ["_mrkFinal","_pos","_side","_typeX","_newPos","_road","_friendlies"];

private _convoy = false;
if (_text == (localize "STR_marker_convoy_objective") or {_text == (localize "STR_marker_mission_vehicle") or {_text == (localize "STR_marker_supply_box")}}) then {
	_convoy = true
};
Explanation:

Gets vehicle and marker text
Determines if vehicle is part of convoy based on marker text
Side and Icon Type Determination:
Sqf

Apply
private _side = side (group (driver _veh));
private _formatX = "";
private _color = colorOccupants;
private _typeX = switch (true) do {
	case (_veh isKindOf "Truck" or {_veh isKindOf "Car"}): {
		"_motor_inf"
	};
	case (_veh isKindOf "Wheeled_APC_F"): {
		"_mech_inf"
	};
	case (_veh isKindOf "Tank"): {
		"_armor"
	};
	case (_veh isKindOf "Plane_Base_F"): {
		"_plane"
	};
	case (_veh isKindOf "UAV_02_base_F"): {
		"_uav"
	};
	case (_veh isKindOf "Helicopter"): {
		"_air"
	};
	case (_veh isKindOf "Boat_F"): {
		"_naval"
	};
	default {
		"_unknown"
	};
};
Explanation:

Gets side from driver's group
Determines vehicle icon type based on vehicle class
Supports trucks/cars, APCs, tanks, planes, UAVs, helicopters, boats
Side and Color Determination:
Sqf

Apply
switch (true) do {
	case (_side in [teamPlayer, sideUnknown]): {
		_enemyX = false;
		_formatX = "n";
		_color = colorTeamPlayer;
	};
	case (_side == civilian): {
		_enemyX = false;
		_formatX = "b";
		_color = colorCivilian;
	};
	case (_side == Occupants): {
		_formatX = "b";
		_color = colorOccupants;
	};
	case (_side == Invaders): {
		_formatX = "o";
		_color = colorInvaders;
	};
};

_typeX = format ["%1%2",_formatX,_typeX];
Explanation:

Format prefix: "n" for resistance/unknown, "b" for friendly/civilian, "o" for enemy
Colors: Correspond to side colors
Combines prefix and icon type
Enemy Spotting Notification:
Sqf

Apply
if ((side group (driver _veh) != teamPlayer) && {side driver _veh != sideUnknown}) then {
	["TaskSucceeded", ["", format [localize "STR_notifiers_vehicle_spotted",_text]]] spawn BIS_fnc_showNotification
};
Explanation:

If vehicle is not player-controlled and not unknown side, show notification
Marker Creation:
Sqf

Apply
private _mrkFinal = createMarkerLocal [format ["%2%1", random 100,_text], position _veh];
_mrkFinal setMarkerShapeLocal "ICON";
_mrkFinal setMarkerTypeLocal _typeX;
_mrkFinal setMarkerColorLocal _color;
_mrkFinal setMarkerTextLocal _text;
Explanation:

Creates local marker with random ID
Sets icon, color, and text
Position Update Loop:
Sqf

Apply
while {(alive _veh) and {!(isNull _veh) and {(revealX or _convoy or (_veh getVariable ["revealed",false]))}}} do {
	_pos = getPos _veh;
	_mrkFinal setMarkerPosLocal _pos;
	sleep 60;
};

deleteMarkerLocal _mrkFinal;
Explanation:

Updates position every 60 seconds while conditions met:
Vehicle alive and not null
Either: global reveal flag, is convoy, or vehicle revealed flag set
Deletes marker when conditions fail
Where it leads:

Uses global variables: revealX, colorOccupants, colorInvaders, colorTeamPlayer, colorCivilian
Uses localized strings for marker text and notifications
Called by: Reconnaissance systems, convoy tracking, mission objectives
Modifies: Creates and deletes local markers
Network implications: Local only (markers are client-side)
Error handling: None apparent (simple loop with deletion)