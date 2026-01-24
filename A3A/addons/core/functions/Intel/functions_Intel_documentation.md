Function: A3A_fnc_placeIntel.sqf
What it does: This function places physical intel objects (desk and intel item) on a specified marker, selecting an appropriate building within the marker's radius. It handles the creation, positioning, and initialization of the intel desk and the large or medium intel item. It also sets up a trap for large computer intel with a probability based on war tier. The function ensures the intel is cleaned up when the marker is no longer active.

How it does that:

1. Parameter Initialization and Validation: The function takes two parameters: the marker name and a boolean indicating if the intel is large. It first checks if the marker is a valid military location (airport, outpost, or military base). If not, it logs an error and exits.

Sqf

Apply
params["_marker", "_isLarge"];

ServerDebug_2("Spawning %2 intel on marker %1", _marker, if (_isLarge) then {"large"} else {"medium"});

if(!(_marker in airportsX || {_marker in outposts || {_marker in milbases}})) exitWith
{
    Error_1("Marker %1 is not suited to have intel!", _marker);
};
2. Building Selection: It determines the side controlling the marker, calculates a search radius based on marker size, and defines lists of suitable building types. It then uses nearestObjects to find all buildings of those types within the radius.

Sqf

Apply
private _side = sidesX getVariable _marker;
private _size = markerSize _marker;
private _radius = sqrt ((_size select 0) * (_size select 0) + (_size select 1) * (_size select 1));

private _listStaticTower = ["Land_Cargo_Tower_V1_F", ...];
// ... other building lists ...

private _searchArray = _listvnslum
	+ _listStaticTower
    + _listvnbarracks06f
    + _listvncontroltower01F
    + _listControlTower02F
    + _listBarracks
    + _listStaticHQ
    + _listEnochRadar
    + _listGuardhouse
    + _listBarracksLivonia
    + _listBarracksGmEastern
    + _listBarracksGmWestern;

private _allBuildings = nearestObjects [getMarkerPos _marker, _searchArray, _radius, true];
3. Desk Placement Parameters: A random building is selected from the list. The function then determines the spawn position and rotation for the desk based on the building's type, using buildingPos and adjusting for orientation.

Sqf

Apply
private _building = selectRandom _allBuildings;
private _buildingType = typeOf _building;

private _spawnParameters = switch (true) do {
	case (_buildingType in _listStaticTower): {[_building buildingPos 9, -90]};
    case (_buildingType in _listBarracksGmEastern): {[_building buildingPos 8, 0]};
    // ... other cases ...
    case (_buildingType in _listvnslum): {
        private _zpos = _building buildingPos 21;
        private _pos = _zpos getPos [0.5, (getDir _building) + 110];
        _pos set[2, _zpos #2];
        [_pos, 0]
    };
};
if (_spawnParameters isEqualType true) exitWith { Error_1("No spawn parameters for building %1", typeOf _building) };
4. Desk Creation and Physics: The desk is created using the faction's placeIntel_desk class and set to the determined position and direction. It's given an initial downward velocity to simulate falling, then sleeps for 5 seconds to let it settle, after which simulation is disabled to prevent floating or bouncing.

Sqf

Apply
private _faction = Faction(_side);
(_faction get "placeIntel_desk") params ["_classname_desk","_azimuth"];
private _desk = createVehicle [_classname_desk, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_desk setDir (getDir _building + (_spawnParameters select 1) + _azimuth);
if (surfaceIsWater (_spawnParameters select 0)) then {
	_desk setPosASLW (_spawnParameters select 0);
} else {
	_desk setPosATL (_spawnParameters select 0);
};
_desk setVelocity [0, 0, -1];

sleep 5;
_desk enableSimulation false;
5. Intel Item Creation: The actual intel item (document or laptop) is spawned based on the _isLarge flag. It is positioned relative to the desk using BIS_fnc_relPosObject. The item is disabled from simulation and damage, and variables are set for its side and marker. A flag action is added remotely to allow players to interact with it.

Sqf

Apply
(
	_faction get (["placeIntel_itemMedium","placeIntel_itemLarge"] select _isLarge)
) params ["_intelType","_azimuth","_isComputer"];

private _intel = createVehicle [_intelType, [0,0,0], [], 0, "CAN_COLLIDE"];
[_desk, _intel, [0.5, 0, 0.82], _azimuth] call BIS_fnc_relPosObject;
_intel enableSimulation false;
_intel allowDamage false;
_intel setVariable ["side", _side, true];
_intel setVariable ["marker", _marker, true];

private _intelSize = switch (true) do {
	case (!_isLarge): { "Intel_Medium" };
	case (!_isComputer): { "Intel_Encrypted" };
	default { "Intel_Large" };
};
[_intel, _intelSize] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_intel];
6. Trap Logic for Large Computers: If the intel is a large computer, a light is attached for visibility. There's a chance (scaling with tierWar) to spawn a DemoCharge_F under the laptop. The bomb is stored in a variable and given a hold-action for disarming by engineers.

Sqf

Apply
if (_isLarge && {_isComputer}) then {
	private _light = "#lightpoint" createVehicle (getPos _intel);
	// ... light settings ...
	_light lightAttachObject [_intel, [0,0,0]];

	private _isTrap = (random 100 < (20 + (4 * tierWar)));
	if(_isTrap) then
	{
		private _bomb = "DemoCharge_F" createVehicle [0,0,0];
		// ... bomb setup ...
		_intel setVariable ["trapBomb", _bomb, true];
		[
			_bomb,
			localize "STR_antistasi_actions_bomb_disarm",
			// ... hold action parameters ...
		] remoteExec ["BIS_fnc_holdActionAdd", 0, _bomb];
	};
};
7. Building Lifecycle Management: The building is linked to the intel and desk. An event handler is added to the building's "Killed" event. When the building is destroyed, it cleans up the intel and bomb (if present), re-enables simulation on the desk, and removes the event handler. Additionally, a spawn script waits for the marker to despawn (status 2), then deletes the desk and intel, and removes the event handler from the building if it still exists.

Sqf

Apply
_building setVariable ["A3A_buildingIntel", _intel];
_building setVariable ["A3A_buildingDesk", _desk];

private _ehId = _building addEventHandler ["Killed", {
	params ["_building"];
	// ... cleanup logic ...
	_building removeEventHandler ["Killed",_thisEventHandler];
}];

_nil = [_marker, _desk, _intel, _building, _ehId] spawn {
	params ["_marker", "_desk", "_intel", "_building", "_ehId"];
	waitUntil {sleep 10; (spawner getVariable _marker == 2)};
	// ... delete objects and event handler ...
	terminate _thisScript;
};
Where it leads:

Called Functions:

Faction(_side): Retrieves faction-specific configuration.
BIS_fnc_relPosObject: Positions the intel item relative to the desk.
A3A_fnc_flagaction (remoteExec): Adds the interaction flag to the intel item.
BIS_fnc_holdActionAdd (remoteExec): Adds the bomb disarm action if a trap is present.
Dependent Functions: Functions that call fn_placeIntel to spawn intel on a marker (e.g., mission reward systems).

Larger System: This is a core part of the intelligence system, enabling players to physically locate and interact with intel items on the map. The trap mechanic adds a risk/reward element to large intel. The cleanup logic ties the intel's existence to the marker's active state.

Global Variables Modified: None directly, but it modifies the state of objects (desk, intel, bomb) which have variables (side, marker, trapBomb) set.

Synchronization/Network Implications: The desk is created locally on the server (implied by the function's likely server-only execution). The flagaction and hold action for the bomb are executed remotely on all clients (remoteExec [_, 0, _intel]). The light is likely created locally where the desk is, but since the desk is server-owned, it's fine. The bomb's hold action is remote to all (0).

Function: A3A_fnc_searchEncryptedIntel.sqf
What it does: This function handles the searching/decryption process for a large, encrypted intel item (e.g., a laptop). It is a continuous loop that requires player presence, displays progress, randomly introduces errors/actions for the player to complete, and handles enemy AI reactions. Success leads to receiving large intel rewards; failure resets the process.

How it does that:

1. Initialization and Cleanup: It removes the initial search action from the intel object. It uncaptivates any nearby friendly players to allow combat.

Sqf

Apply
params [["_intel", objNull, [objNull]], "", ["_id", -1, [0]]];

[_intel, _id] remoteExecCall ["removeAction", 0, _intel];

{
    [_x, false] remoteExec ["setCaptive", owner _x];
} forEach ([200, 0, _intel, teamPlayer] call A3A_fnc_distanceUnits);
2. Variable Setup: It retrieves the marker and side from the intel object. It defines a point goal and a points-per-second rate, which scales inversely with tierWar (higher war tier = slower decryption). It also calculates probabilities for "No Attack", "Small Attack", and "Large Attack" based on whether the location is an airport and the war tier.

Sqf

Apply
private _marker = _intel getVariable "marker";
private _side = _intel getVariable "side";
private _isAirport = (_marker in airportsX);

private _neededPoints = 500 + random 500;
private _pointsPerSecond = switch (true) do {
    case (tierWar > 4): {25 - tierWar * 2};
    case (tierWar > 2): {25 - tierWar};
    default {25};
};

private _noAttackChance = ...; // Calculated based on _isAirport and tierWar
private _largeAttackChance = ...;
private _attack = selectRandomWeighted ["No", _noAttackChance, "Small", 0.6, "Large", _largeAttackChance];
3. Main Loop (while): The loop runs until _pointSum >= _neededPoints.

Player Presence Check: Every second, it checks if any capable (non-downed) players are within 20m. If not, the loop breaks, the point sum resets to 0, and a hint is sent to nearby players.
Sqf

Apply
while {_pointSum <= _neededPoints} do {
    sleep 1;
    // ...
    private _playerList = [20, 0, _intel, teamPlayer] call A3A_fnc_distanceUnits;
    if({[_x] call A3A_fnc_canFight} count _playerList == 0) exitWith
    {
        _pointSum = 0;
        // Send hint to nearby players...
    };
Error/Action Generation: If ActionNeeded is false, a chance (increasing over time) generates an error. A random error type is chosen (1-4), each with specific text, action text, and time. A hold action is added to the intel object (remote to all) that must be completed to clear the error. The _errorText variable is used for hints.
Sqf

Apply
    private _actionNeeded = _intel getVariable ["ActionNeeded", false];
    if (!_actionNeeded) then {
        _errorChance = _errorChance + ((1 + (0.1 * tierWar)) * _timeDiff);
        if (random 500 < _errorChance) then {
            _actionNeeded = true;
            _intel setVariable ["Actionneeded", _actionNeeded, true];
            // ... select error and set _errorText, _actionText, _actionTime ...
            [_intel, _actionText, "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
                "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
                "_this distance _target < 3", "_caller distance _target < 3",
                {}, {}, {
                    _this params ["_intel", "", "_id"];
                    _intel setVariable ["Actionneeded", false, true];
                    [_intel, _id] remoteExecCall ["BIS_fnc_holdActionRemove", 0, _intel]
                }, {}, [], _actionTime, 0, true, false
            ] remoteExecCall ["BIS_fnc_holdActionAdd", 0, _intel];
        };
    };
Enemy Movement: Every 10 iterations (10 seconds), AI units from Invaders and Occupants within 300m are ordered to move to the intel position.
Sqf

Apply
    if(_enemyCounter > 10) then {
        {
            _x doMove (getPos _intel);
        } forEach ([300, 0, _intel, Invaders] call A3A_fnc_distanceUnits);
        // ...
        _enemyCounter = 0;
    } else { _enemyCounter = _enemyCounter + 1 };
Progress Hints: If an action is needed, an error hint is sent to players within 25m. If not, points are added and a progress hint is sent.
Sqf

Apply
    if (_actionNeeded) then {
        [
            localize "STR_intel_search_intel_header"
            , _errorText
        ] remoteExec ["A3A_fnc_customHint", (_intel nearEntities ["CAManBase", 25]) select {isPlayer _x}];
    } else {
        _pointSum = _pointSum + (_pointsPerSecond * _timeDiff);
        // Send progress hint...
    };
};
4. Completion or Failure: If points are reached, A3A_fnc_selectIntel is called for "Large" intel, and players within 50m receive score and money. If the loop exits due to failure (no players), the actions are removed and a flag action is set to allow re-searching.

Sqf

Apply
if (_pointSum >= _neededPoints) then {
    ["Large", _side] remoteExec ["A3A_fnc_selectIntel", 2];
    // Reward players...
} else {
    _intel remoteExecCall ["removeAllActions", 0, _intel];
    [_intel, "Intel_Large"] remoteExec ["A3A_fnc_flagaction",0, _intel];
};
Where it leads:

Called Functions:

A3A_fnc_distanceUnits: Finds nearby units.
A3A_fnc_canFight: Checks if a unit is capable.
BIS_fnc_holdActionAdd (remoteExecCall): Adds interactive error actions.
BIS_fnc_holdActionRemove (remoteExecCall): Removes them.
A3A_fnc_selectIntel (remoteExec): Handles the actual reward selection.
A3A_fnc_customHint (remoteExec): Sends UI hints to players.
Dependent Functions: Any interaction with "encrypted" large intel objects calls this function.

Larger System: This function creates a dynamic, event-driven mini-game for securing large intel, preventing simple capture and encouraging teamwork and defense. It links the intel system directly to combat (AI attacks) and player interaction.

Global Variables Modified: _intel has its variable ActionNeeded toggled.

Synchronization/Network Implications: The search loop is local to the server (if executed server-side). All UI hints, hold actions, and AI movement commands are executed remotely on clients. The state (ActionNeeded) is set globally via setVariable to ensure consistency.

Function: A3A_fnc_searchIntelOnDocument.sqf
What it does: This is a simple function that handles the immediate retrieval of medium intel from a physical document. It grants the reward, notifies nearby players, and deletes the document object.

How it does that:

1. Retrieval and Reward: It gets the side from the document's variable. It shows a standard success hint, calls A3A_fnc_selectIntel for "Medium" intel, and gives score and money to players within 50m.

Sqf

Apply
params ["_intel"];

private _side = _intel getVariable "side";
[(localize "STR_intel_search_intel_header"), (localize "STR_intel_documents_taken_description")] call A3A_fnc_customHint;
["Medium", _side] remoteExec ["A3A_fnc_selectIntel", 2];
{
    [5,_x] call A3A_fnc_addScorePlayer;
    [100,_x] call A3A_fnc_addMoneyPlayer;
} forEach ([50,0,_intel,teamPlayer] call A3A_fnc_distanceUnits);
2. Cleanup: The document object is deleted immediately after rewards are granted.

Sqf

Apply
deleteVehicle _intel;
Where it leads:

Called Functions:

A3A_fnc_customHint: Displays the hint locally to the caller.
A3A_fnc_selectIntel: Remotely executes to select and broadcast the intel result.
A3A_fnc_addScorePlayer / A3A_fnc_addMoneyPlayer: Modifies player stats.
A3A_fnc_distanceUnits: Finds nearby players for rewards.
Dependent Functions: Functions that handle player interaction with medium intel objects.

Larger System: Serves as the endpoint for medium physical intel. It's a straightforward transaction within the larger intel economy.

Global Variables Modified: None on the server. Player variables are modified on each client via remote calls.

Synchronization/Network Implications: selectIntel is called remotely on the server (index 2), which then broadcasts results. Player rewards are executed on each individual client.

Function: A3A_fnc_searchIntelOnLaptop.sqf
What it does: This function handles the download process for a large, non-encrypted (laptop) intel. It is a continuous loop similar to searchEncryptedIntel but with different mechanics: it handles a potential bomb trap, different error types that change the laptop texture, and a UAV Hacker bonus. It also manages AI attacks.

How it does that:

1. Trap Check: First, it checks if a trapBomb variable is set on the intel. If yes, it triggers the trap sequence: changes texture, warns players, and after a random delay, detonates the bomb, destroying the laptop and killing nearby players.

Sqf

Apply
params ["_intel", "_searchAction"];

private _bomb = _intel getVariable ["trapBomb", objNull];
private _isTrap = !(isNull _bomb);
if(_isTrap) exitWith
{
    // ... warn players, play sound ...
    private _timeOut = time + 2 + (random 3);
	waitUntil {_timeOut < time};
    // ... Detonate bomb, delete intel ...
};
2. Initialization: It removes the search action and retrieves marker and side. It defines _isHardOutpost. It calculates pointsPerSecond (faster than encrypted intel, scales with tierWar). It uncaptivates nearby players.

Sqf

Apply
[_intel, _searchAction] remoteExec ["removeAction", [teamPlayer, civilian], _intel];

private _marker = _intel getVariable "marker";
private _side = _intel getVariable "side";
private _isHardOutpost = (_marker in airportsX || {_marker in milbases});

// Calculate pointsPerSecond based on tierWar
private _pointsPerSecond = 25;
if(tierWar > 4) then { _pointsPerSecond = _pointsPerSecond - (tierWar * 2); }
// ...

// Uncaptivate players
{
    private _friendly = _x;
    if (captive _friendly) then
    {
        [_friendly,false] remoteExec ["setCaptive",0,_friendly];
        _friendly setCaptive false;
    };
} forEach ([200, 0, _intel, teamPlayer] call A3A_fnc_distanceUnits);
3. Main Loop (while):

Player Presence: Checks for players within 20m. If none, exits loop and resets.
Error Generation: If ActionNeeded is false, a chance (scales with tierWar) generates an error. Errors are types like "Err_Sml_01" to "Err_Lar_01". The laptop texture is changed to match the error (laptop_error1.paa etc.). An action is added to fix the error. Upon fixing, texture reverts to downloading. A penalty can be applied (though code shows 0 penalty currently).
Enemy Movement: Similar to encrypted intel, enemies are moved to the intel every 10 seconds.
Progress: If no action needed, points are added. If a player has the "UAVHacker" trait, points are doubled. Progress hints are sent to all players on the same side within 20m.
Sqf

Apply
while {_pointSum <= _neededPoints} do {
    sleep 1;
    // ... Player check ...

    // Error generation
    if(!_actionNeeded) then {
        _errorChance = _errorChance + ((1 + (0.1 * tierWar)) * _timeDiff);
        if(random 1000 < _errorChance) then {
            // ... Set texture, add action with penalty subtraction ...
            _intel setObjectTextureGlobal [0, _picturePath];
            // ... Add action ...
            _pointSum = _pointSum - _penalty;
        };
    };

    // Enemy movement
    // ...

    // Progress
    if(_actionNeeded) then {
        // Send error hint via petros...
    }
    else {
        private _UAVHacker = (_playerList findIf {_x getUnitTrait "UAVHacker"} != -1);
        if(_UAVHacker) then { _pointSum = _pointSum + ((_pointsPerSecond * 2) * _timeDiff); }
        else { _pointSum = _pointSum + (_pointsPerSecond * _timeDiff); };
        // Send progress hint...
    };
};
4. Completion or Failure: If points are reached, texture changes to "complete", selectIntel is called for "Large" type, rewards are given. If failed (player left), texture reverts to default laptop and a flag action is added for re-trying.

Sqf

Apply
if(_pointSum >= _neededPoints) then {
    _intel setObjectTextureGlobal [0, QPATHTOFOLDER(Pictures\Intel\laptop_complete.paa)];
    ["Large", _side] remoteExec ["A3A_fnc_selectIntel", 2];
    // ... Rewards ...
}
else {
    // Texture revert, removeAllActions, add flagaction
    _intel setObjectTextureGlobal [0, "a3\structures_f\items\electronics\data\electronics_screens_laptop_co.paa"];
    _intel remoteExec ["removeAllActions", [teamPlayer, civilian], _intel];
    [_intel, "Intel_Large"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian], _intel];
};
Where it leads:

Called Functions:

A3A_fnc_distanceUnits: Finds nearby units.
BIS_fnc_holdActionAdd / addAction (remoteExec): Adds interactive error actions.
A3A_fnc_selectIntel (remoteExec): Handles reward selection.
A3A_fnc_commsMP (remoteExec): Sends hints via Petros.
Dependent Functions: Interactions with laptop-type large intel.

Larger System: Provides a distinct experience for laptop intel (visual feedback via textures, trap risk, skill-based bonus). It integrates with the trait system ("UAVHacker").

Global Variables Modified: _intel texture, ActionNeeded variable. Bomb trap deletes the intel and bomb.

Synchronization/Network Implications: The loop runs on the server. Texture changes (setObjectTextureGlobal) are global. Actions are remote. Hints are sent to specific clients.

Function: A3A_fnc_searchIntelOnLeader.sqf
What it does: This function handles searching a squad leader's corpse for small intel. It's a timed action with an animation loop, a cancel option, and a chance to spawn "belongings" (props) on the corpse if not enough exist. It rewards the caller if intel is found.

How it does that:

1. Setup and Animation: It calculates a search time. It sets flags on the caller to track state (intelSearchTime, intelAnimsDone, intelFound, cancelIntelSearch). It plays a random medic animation on the caller and adds a "Cancel" action.

Sqf

Apply
params ["_squadLeader", "_caller", "_searchAction"];

private _timeForSearch = 10 + random 15;
private _side = _squadLeader getVariable "side";

_caller setVariable ["intelSearchTime",time + _timeForSearch];
// ... set other variables ...
_caller playMoveNow selectRandom medicAnims;
private _cancelAction = _caller addAction [(localize "STR_cancel_search_action"), {(_this select 1) setVariable ["cancelIntelSearch",true]},nil,6,true,true,"","(isPlayer _this)"];
2. Animation Loop (Event Handler): An AnimDone event handler is added to the caller. This handler loops as long as the caller can fight, time remains, search isn't cancelled, and the caller isn't in a vehicle. It re-plays medic animations. Crucially, if the caller is in a house, it uses a different calculation for belongings position. It spawns props on the corpse (_squadLeader) if the belongings array is smaller than a random target count.

Sqf

Apply
_caller addEventHandler
[
    "AnimDone",
    {
        private _caller = _this select 0;
        if (
            // Condition: Can fight, time left, not cancelled, not in vehicle
        ) then {
            _caller playMoveNow selectRandom medicAnims;
            private _squadLeader = _caller getVariable ["A3A_searchedSquadLeader", objNull];
            if (!isNull _squadLeader) then {
                private _belongings = _squadLeader getVariable ["A3A_belongings", []];
                private _belongingsCount = round random [1,2,4];
                if ((count _belongings) < _belongingsCount) then {
                    // Calculate position (in house or outside)
                    private _position = [(getPos _squadLeader), 0.7, (random 360)] call SCRT_fnc_misc_extendPosition;
                    if (_squadLeader call SCRT_fnc_misc_isInHouse) then {
                        private _height = (getPosATL _squadLeader) select 2;
                        _position = [_position select 0, _position select 1, _height];
                    };
                    // Spawn belonging
                    private _belonging = [(selectRandom belongings), _position, (random 360)] call SCRT_fnc_misc_createBelonging;
                    _belongings pushBack _belonging; 
                    _squadLeader setVariable ["A3A_belongings", _belongings];
                };
            };
        }
        else {
            // Cleanup event handler, set anims done flag
            _caller removeEventHandler ["AnimDone", _thisEventHandler];
            _caller setVariable ["intelAnimsDone",true];
            // Check conditions for success (can fight, not cancelled, not in vehicle)
            if (
                ([_caller] call A3A_fnc_canFight) &&                //Can fight
                {!(_caller getVariable ["cancelIntelSearch",false]) &&   //Not cancelled
                {(isNull objectParent _caller)}}                     //Not in vehicle
            ) then {
                _caller setVariable ["intelFound",true];
            };
        };
    }
];
3. Completion and Reward: The script waits for intelAnimsDone to be true. It cleans up local variables. If the search was cancelled, a hint is shown. If not cancelled and intelFound is true, it checks the squad leader's hasIntel variable. If true, grants rewards and calls selectIntel. If false, calls A3A_fnc_showNoIntelMessage.

Sqf

Apply
waitUntil {sleep 0.5; _caller getVariable ["intelAnimsDone", false]};

// Cleanup variables
// ...

if(_wasCancelled) exitWith { ... };

if(_caller getVariable ["intelFound", false]) then {
    private _hasIntel = _squadLeader getVariable ["hasIntel", false];
    if(_hasIntel) then {
        [(localize "STR_intel_search_intel_header"), (localize "STR_intel_search_success_description")] call A3A_fnc_customHint;
        ["Small", _side] remoteExec ["A3A_fnc_selectIntel", 2];
        // ... Rewards ...
    }
    else {
        [] call A3A_fnc_showNoIntelMessage;
    };
}
else
{
    _squadLeader setVariable ["intelSearchDone", nil, true];
};
4. Belongings Cleanup: After a timeout (60 seconds), the spawned props on the squad leader are deleted.

Sqf

Apply
private _bTimeOut = time + 60;
waitUntil {sleep 0.5; time > _bTimeOut};

private _belongings = _squadLeader getVariable ["A3A_belongings", []];
if (_belongings isNotEqualTo []) then {
    _nil = [_belongings] spawn {
        params ["_props"];
        sleep random [30,45,60];
        {deleteVehicle _x} forEach _props;
        terminate _thisScript;
    };
};
_squadLeader setVariable ["A3A_belongings", nil];
Where it leads:

Called Functions:

A3A_fnc_canFight: Checks caller state.
SCRT_fnc_misc_extendPosition / SCRT_fnc_misc_isInHouse / SCRT_fnc_misc_createBelonging: Prop spawning logic.
A3A_fnc_selectIntel (remoteExec): Handles small intel rewards.
A3A_fnc_showNoIntelMessage: Displays the "no intel found" message.
Dependent Functions: Interaction with squad leader corpses.

Larger System: Provides a physical search mechanic for small intel. The prop system adds immersion and visual clutter. It ties small intel directly to infantry combat results.

Global Variables Modified: Caller variables (local), Squad Leader variables (intelSearchDone, A3A_belongings).

Synchronization/Network Implications: The search is local to the caller's client. The hasIntel check and variable updates on the squad leader are server-authoritative (likely). Prop spawning is local but stored in a public variable on the squad leader.

Function: A3A_fnc_selectIntel.sqf
What it does: This function serves as the central randomizer and reward distributor for all intel types (Small, Medium, Large, Civilian). It selects a random outcome based on type, calculates rewards, executes the logic (e.g., adding keys, money, weapons), and broadcasts the result text to players.

How it does that:

1. Definition and Setup: It defines integer constants for intel outcomes (e.g., TIME_LEFT, WEAPON, MONEY). It takes _intelType and _side as parameters. It retrieves the faction configuration and name. It initializes a trader quest check, where there's a chance to trigger the trader quest based on intel type.

Sqf

Apply
#define TIME_LEFT               101
#define WEAPON                  300
// ... other defines ...

params ["_intelType", "_side"];

private _faction = Faction(_side);
private _text = "";
private _sideName = _faction get "name";
private _intelContent = -1;

// Trader quest trigger
if (!disableTrader && {!isTraderQuestCompleted && {!isTraderQuestAssigned}}) then {
    private _thresholds = createHashMapFromArray [ ... ];
    if (random 100 < (_thresholds get _intelType)) then {
        [] remoteExec ["SCRT_fnc_trader_prepareTraderQuest", 2];
        _text = format [ ... ];
        _intelContent = DEALER;
    };
};
2. Weapon Helper Function: A local function _fnc_addWeapon is defined. It selects a random not-unlocked weapon, finds compatible magazines, calculates quantity based on minWeaps or A3A_guestItemLimit, and adds them to the arsenal via jn_fnc_arsenal_addItem.

Sqf

Apply
private _fnc_addWeapon = {
    private _notYetUnlocked = allWeapons - unlockedWeapons;
    private _newWeapon = selectRandom _notYetUnlocked;
    private _magazine = selectRandom compatibleMagazines _newWeapon;
    private _quantity = ...; // Logic for quantity
    [
        _newWeapon call jn_fnc_arsenal_itemType,
        _newWeapon,
        _quantity
    ] call jn_fnc_arsenal_addItem;
    // ... Add magazines ...
    private _return = [getText (configFile >> "CfgWeapons" >> _newWeapon >> "displayName"), _quantity];
    _return;
};
3. Selection Logic (Switch): If no text is set (trader quest didn't trigger), it switches on _intelType.

Civilian: Randomly selects MONEY, WEAPON, DECRYPTION_KEY, or TRAITOR. Executes logic (add money, add key to occupantsRadioKeys, call weapon func, set traitorIntel).
Small: Randomly selects TIME_LEFT, REVEAL_ZONE_SMALL, DEF_RESOURCES, etc. Calculates specifics:
TIME_LEFT: Calculates attack time based on A3A_resourcesAttackOcc/Inv.
DEF_RESOURCES: Calculates defense resource fraction and selects localized string.
DECRYPTION_KEY: Adds key to correct side's variable.
RIVALS: Adds progress to rivals reveal.
Medium: Randomly selects KEY_PACK, REVEAL_ZONE_MEDIUM, CONVOYS, CONVOY_ROUTE.
KEY_PACK: Adds multiple keys.
CONVOY_ROUTE: Starts a convoy mission if not active, else gives money.
Large: Randomly selects WEAPON, TRAITOR, MONEY, REVEAL_ZONE_LARGE, RIVALS.
WEAPON: Calls _fnc_addWeapon.
MONEY: Calculates money based on tierWar.
Sqf

Apply
switch (true) do {
    case (_intelType isEqualTo "Civilian"): {
        _intelContent = selectRandomWeighted [ ... ];
        switch (_intelContent) do { ... }
    };
    case (_intelType isEqualTo "Small"): {
        // Logic for Small
    };
    // ... Medium and Large cases ...
};
4. Broadcast: If _text is not empty, it executes A3A_fnc_showIntel remotely on [civilian, teamPlayer].

Sqf

Apply
if (_text isNotEqualTo "") then {
    [_text, true] remoteExec ["A3A_fnc_showIntel", [civilian, teamPlayer]];
};
Where it leads:

Called Functions:

Faction(_side): Gets faction data.
jn_fnc_arsenal_addItem: Adds weapons/mags to arsenal.
A3U_fnc_revealRandomZones: Random zone reveal.
SCRT_fnc_rivals_addProgressToRivalsLocationReveal / SCRT_fnc_rivals_revealLocation: Rivals logic.
A3A_fnc_showIntel (remoteExec): Broadcasts message.
A3A_fnc_scheduler (remoteExec): Starts convoy mission.
Dependent Functions: All intel retrieval functions (search...) call this to process the result.

Larger System: The core of the intel reward system. It centralizes randomness, handles global variables (radio keys, traitor status, rivals progress), and integrates with the arsenal, mission system, and economy.

Global Variables Modified: occupantsRadioKeys, invaderRadioKeys, traitorIntel. Modifies the unlockedWeapons array indirectly via arsenal functions.

Synchronization/Network Implications: This runs on the server. Changes to global variables are synchronized via publicVariable (if used) or are server-authoritative. remoteExec calls are used to broadcast the result text.

Function: A3A_fnc_showIntel.sqf
What it does: This function displays a formatted text block on the screen using the dynamic text system, simulating the "Intel" pop-up. It optionally plays a success sound.

How it does that:

1. Text Formatting: It takes the input text and prepends the localized header "INTEL". It then spawns a bis_fnc_dynamicText call, positioning it on the left side of the screen (safeZoneX, 0.2 * safeZoneW).

Sqf

Apply
params ["_text", ["_hasSound", false]];

if(_text == "") exitWith {};

private _outText = localize "STR_intel_header";
_outText = format ["%1 %2", _outText, _text];

private _layer = ["A3A_infoLeft"] call BIS_fnc_rscLayer;
[_outText, [safeZoneX, (0.2 * safeZoneW)], [0.25, 0.5], 30, 0, 0, _layer] spawn bis_fnc_dynamicText;
2. Sound: If _hasSound is true, it plays the "Success" UI sound locally.

Sqf

Apply
if (_hasSound) then {
	playSound "A3AP_UiSuccess";
};
Where it leads:

Called Functions:

BIS_fnc_rscLayer: Gets the rendering layer.
bis_fnc_dynamicText: Displays the text.
Dependent Functions: Called by fn_selectIntel and other intel retrieval scripts to show the final result.

Larger System: The visual output layer for the intel system. It provides standard UI feedback for all intel rewards.

Global Variables Modified: None.

Synchronization/Network Implications: Runs locally on the client that receives the remoteExec call. No network traffic is generated from this function itself.

Function: A3A_fnc_showNoIntelMessage.sqf
What it does: This function displays a "No Intel" message when a search fails. It checks for translations of a specific string to determine if a localized array of alternate messages is available. If available, it picks a random message from that array; otherwise, it falls back to a generic message.

How it does that:

1. Translation Check: It checks a global variable GVAR(HaveIntelTranslations). If nil, it sets it by comparing the localized text of two strings: STR_antistasi_dialogs_generic_button_yes_text and STR_antistasi_intel_translated. If they match, translations are considered available.

Sqf

Apply
if (isNil QGVAR(HaveIntelTranslations)) then {
    GVAR(HaveIntelTranslations) = 
        (localize "STR_antistasi_dialogs_generic_button_yes_text")
        isEqualTo
        (localize "STR_antistasi_intel_translated");
};
2. Message Selection: It selects the message. If translations are not available, it uses STR_intel_search_failure_description. If available, it formats STR_intel_search_failure_alternate_description with a random string from configFile >> "A3A" >> "IntelMessages" >> "notFound".

Sqf

Apply
private _message = if !GVAR(HaveIntelTranslations) then {
    // Generic fallback
    localize "STR_intel_search_failure_description";
} else {
    // Random alternate message
    format[
        localize "STR_intel_search_failure_alternate_description", 
        selectRandom getArray(configFile >> "A3A" >> "IntelMessages" >> "notFound")
    ];
};
3. Display: It calls A3A_fnc_customHint with the header and the selected message.

Sqf

Apply
[localize "STR_intel_search_intel_header", _message] call A3A_fnc_customHint;
Where it leads:

Called Functions:

A3A_fnc_customHint: Displays the hint.
Dependent Functions: Called by fn_searchIntelOnLeader and potentially others when an intel search yields no results.

Larger System: Enhances UI feedback for failed actions, replacing a static message with dynamic variety.

Global Variables Modified: GVAR(HaveIntelTranslations).

Synchronization/Network Implications: Runs locally on the client calling it. Relies on local config parsing and localization.

