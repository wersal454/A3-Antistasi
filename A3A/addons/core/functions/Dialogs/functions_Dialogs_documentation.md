Function Name: fn_clearForest.sqf
What it does: This function allows the commander (theBoss) to clear forest vegetation near the rebel HQ spawn point. It removes trees and bushes within 70 meters of the respawn marker and sets a global variable to notify other systems. This is used to create clear areas for building, vehicle movement, or strategic positioning.

How it does that:

1. Command Role Validation
Sqf

Apply
if (player != theBoss) exitWith {
    [localize "STR_A3A_Dialogs_clear_forest_header", localize "STR_A3A_Dialogs_clear_forest_only_comm"] call SCRT_fnc_misc_deniedHint;
};
The function first checks if the calling player is the current commander (theBoss). If not, it displays a localized denial message using SCRT_fnc_misc_deniedHint and exits immediately. This ensures only commanders can perform this action.

2. Vegetation Removal
Sqf

Apply
{[_x,true] remoteExec ["hideObjectGlobal",2]} forEach (nearestTerrainObjects [getMarkerPos respawnTeamPlayer,["tree","bush","small tree"],70]);
getMarkerPos respawnTeamPlayer gets the position of the rebel HQ respawn marker
nearestTerrainObjects searches for terrain objects of types "tree", "bush", and "small tree" within 70 meters
For each found object, it executes hideObjectGlobal remotely with parameter true (to hide the object) on server (option 2)
This effectively removes visible vegetation from the area
3. Global State Update
Sqf

Apply
chopForest = true;
publicVariable "chopForest";
Sets a global variable chopForest to true and broadcasts it to all clients. This allows other systems (like AI pathfinding or other clients) to know that vegetation has been cleared in this area.

4. User Feedback
Sqf

Apply
playSound "A3AP_UiSuccess";
[localize "STR_A3A_Dialogs_clear_forest_header", localize "STR_A3A_Dialogs_clear_forest_success"] call A3A_fnc_customHint;
Plays a success sound and displays a confirmation message to the player using A3A_fnc_customHint.

Where it leads:

Calls SCRT_fnc_misc_deniedHint - Displays denial message for non-commanders
Calls A3A_fnc_customHint - Shows success confirmation to player
Calls remote hideObjectGlobal on server - Hides terrain objects globally
Modifies global variable chopForest - Affects systems that check for cleared areas
Potential dependencies: Systems that use chopForest variable, pathfinding algorithms that respect hidden vegetation
Synchronization implications:

Remote execution to server ensures vegetation hiding is networked to all clients
Public variable broadcast synchronizes state across all connected clients
Hidden objects persist for the mission session
Function Name: fn_createDialog_shouldLoadPersonalSave.sqf
What it does: This function creates a confirmation dialog about whether to load a player's personal save data. It displays different messages depending on whether autosave is enabled or disabled, shows the autosave interval if enabled, and provides options for the player's choice. It also triggers the actual save loading process.

How it does that:

1. Base Save Message Construction
Sqf

Apply
private _saveString = [
    localize "STR_A3A_Dialogs_create_dialog_save_personal_save_1",
    localize "STR_A3A_Dialogs_create_dialog_save_personal_save_2"
] joinString "";
Creates a base message string by joining two localized strings together, forming a general message about personal saves.

2. Conditional Message Based on Autosave Setting
Sqf

Apply
_saveString = if (autoSave) then { 
    [
        _saveString,
        localize "STR_A3A_Dialogs_create_dialog_save_personal_save_3",
        (autoSaveInterval/60) toFixed 0,
        " ",
        localize "STR_A3A_Dialogs_create_dialog_save_personal_save_4"
    ] joinString "" 
} else { 
    [_saveString,localize "STR_A3A_Dialogs_create_dialog_save_personal_save_5"] joinString "" 
};
Checks global autoSave variable
If autosave is enabled: Appends information about autosave interval (converted from seconds to minutes)
If autosave is disabled: Appends message indicating autosave is disabled
Uses toFixed 0 to format the interval as an integer
3. Display Information to Player
Sqf

Apply
[localize "STR_A3A_Dialogs_create_dialog_save_personal_save_header", _saveString] call A3A_fnc_customHint;
Displays the formatted message in a custom hint dialog with a header.

4. Initiate Save Loading
Sqf

Apply
[getPlayerUID player, player] remoteExecCall ["A3A_fnc_loadPlayer", 2];
Gets the player's Steam UID
Calls A3A_fnc_loadPlayer remotely on the server (option 2) to load the player's personal save data
Uses remoteExecCall for one-way execution without return value
5. Trigger Credits
Sqf

Apply
[] spawn A3A_fnc_credits;
Starts the credits sequence in a spawned script (doesn't block main execution).

Where it leads:

Calls A3A_fnc_customHint - Displays save information to player
Calls A3A_fnc_loadPlayer on server - Loads personal save data (persists player stats, gear, etc.)
Calls A3A_fnc_credits - Shows game credits sequence
Depends on: autoSave and autoSaveInterval global variables
Modified by: Player save data loaded by A3A_fnc_loadPlayer
Global variables:

Reads: autoSave, autoSaveInterval
Network: Executes server-side function for save loading
Function Name: fn_fastTravelRadio.sqf
What it does: A comprehensive fast travel system that allows players to teleport themselves or their group to various locations. It includes extensive validation for commander permissions, enemy proximity, vehicle restrictions, limited fast travel modes, rally points, and trader access. It supports both individual and headless client (HC) group fast travel.

How it does that:

1. Marker Preparation
Sqf

Apply
private _markersX = markersX + [respawnTeamPlayer];
Creates a list of travelable markers by combining the global markersX array with the rebel HQ respawn point.

2. Configuration Validation
Sqf

Apply
private _titleStr = "Fast Travel";
if (limitedFT == 3) exitWith {[_titleStr, "Fast travel is disabled for this server."] call A3A_fnc_customHint};
Checks limitedFT variable (3 = disabled) and exits with appropriate message if fast travel is completely disabled.

3. Additional Markers
Sqf

Apply
if (!isNil "traderMarker") then {
    _markersX pushBack traderMarker;
};

if (!isNil "isRallyPointPlaced" && {isRallyPointPlaced}) then {
    _markersX pushBack rallyPointMarker;
};
Conditionally adds trader marker and rally point marker to travel destinations if they exist and are active.

4. Headless Client Detection
Sqf

Apply
if (count hcSelected player > 1) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_error_only_one_hc"] call SCRT_fnc_misc_deniedHint
};

private _groupX = nil;
if (count hcSelected player == 1) then {
    _groupX = hcSelected player select 0; 
    _esHC = true;
} else {
    _groupX = group player;
};
Validates only one HC group is selected
Determines if traveling for a HC group or the player's group
Sets _esHC flag to indicate headless client context
5. Travel Authority Validation
Sqf

Apply
if (!_esHC and {(limitedFT == 1 or limitedFT == 2)}) then {_checkForPlayer = true};
private _boss = leader _groupX;

if (_boss != player and {!_esHC}) then {_groupX = player};

if (_esHC && {{isPlayer _x} count units _groupX > 1}) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_error_player"] call SCRT_fnc_misc_deniedHint;
};
Sets validation flag based on limited fast travel mode
Adjusts group reference if player isn't group leader
Prevents HC group fast travel if it contains players (must be pure AI group)
6. AI Control Validation
Sqf

Apply
if (player != player getVariable ["owner",player]) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_controlai"] call SCRT_fnc_misc_deniedHint;
};
Ensures player isn't controlling another unit (like in Zeus mode).

7. Towing Restriction
Sqf

Apply
if (!_esHC and !isNil {vehicle player getVariable "SA_Tow_Ropes"}) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_towing"] call SCRT_fnc_misc_deniedHint;
};
Prevents fast travel while towing with SA Tow Ropes mod.

8. Punishment Check
Sqf

Apply
if (!isNil "A3A_FFPun_Jailed" && {(getPlayerUID player) in A3A_FFPun_Jailed}) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_ff"] call SCRT_fnc_misc_deniedHint;
};
Checks if player is jailed for friendly fire and prevents travel.

9. Vehicle State Validation
Sqf

Apply
private _units = units _groupX;

if (_units findIf {
    vehicle _x != _x and ((!isPlayer (driver vehicle _x) && isNull (driver vehicle _x)) or !canMove vehicle _x or vehicle _x isKindOf "Boat")
} != -1) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_multiple"] call SCRT_fnc_misc_deniedHint;
};
Checks group units for invalid vehicle states: missing driver, non-moving vehicles, or boats (which can't fast travel).

10. Destination Selection
Sqf

Apply
positionTel = [];

[localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_click"] call A3A_fnc_customHint;
if (!visibleMap) then {openMap true};
showCommandingMenu "";
onMapSingleClick "positionTel = _pos; true";

waitUntil {sleep 1; (count positionTel > 0) or {not visiblemap}};
onMapSingleClick "";
Initializes empty position array
Instructs player to click on map
Sets up map click handler to capture position
Waits for either position selection or map closed
Clears click handler when done
11. Rally Point Special Handling
Sqf

Apply
private _positionTel = positionTel;
private _earlyEscape = false;

if (count _positionTel > 0) then {
    private _base = [_markersX, _positionTel] call BIS_fnc_nearestPosition;
    if (!isNil "rallyPointMarker" && {_base == rallyPointMarker}) then {
        [] spawn SCRT_fnc_rally_travelToRallyPoint;
        openMap false;
        _earlyEscape = true;
    };
};

if (_earlyEscape) exitWith {};
If nearest marker is rally point, calls specialized rally travel function and exits early.

12. Enemy Proximity Checks (Multiple Scenarios)
Sqf

Apply
private _areEnemiesNearby = false;

if (_esHC && {_units findIf {[getPosATL _x] call A3A_fnc_enemyNearCheck} != -1}) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_enemiesnear_group"] call SCRT_fnc_misc_deniedHint;
};

if (!_esHC && {!fastTravelEnemyCheck && {[getPosATL player] call A3A_fnc_enemyNearCheck}}) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_enemiesnear_individual"] call SCRT_fnc_misc_deniedHint;
};

if (!_esHC && {fastTravelEnemyCheck && {_units findIf {[getPosATL _x] call A3A_fnc_enemyNearCheck} != -1}}) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_enemiesnear_group"] call SCRT_fnc_misc_deniedHint;
};
Three different enemy check scenarios based on HC status and fastTravelEnemyCheck setting:

HC groups: Check all units in group
Individual with enemy check disabled: Only check player
Individual with enemy check enabled: Check all group units
13. Driver Restriction
Sqf

Apply
if (!_esHC && {vehicle player != player && {driver vehicle player != player}}) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_only_drivers"] call SCRT_fnc_misc_deniedHint;
};
Individual travel only allowed for drivers of vehicles (not passengers).

14. Empty Click Validation
Sqf

Apply
if (_positionTel isEqualTo []) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_missclick"] call SCRT_fnc_misc_deniedHint;
};
Handles case where map click wasn't captured properly.

15. Destination Marker Resolution
Sqf

Apply
private _base = [_markersX, _positionTel] call BIS_Fnc_nearestPosition;
Finds nearest valid travel marker to clicked position.

16. Trader Access Validation
Sqf

Apply
if (_base == traderMarker && {isTraderQuestAssigned || !isTraderQuestCompleted}) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_trader_locked"] call SCRT_fnc_misc_deniedHint;
};
Prevents travel to trader if quest is active or incomplete.

17. Limited Fast Travel Validation (Mode 1)
Sqf

Apply
private _rebelMarkers = if (!isNil "traderMarker") then {["Synd_HQ", traderMarker]} else {["Synd_HQ"]};
private _isValidTargetLocation = (_base in (_rebelMarkers + airportsX + milbases));

if (_checkForPlayer && limitedFT == 1 && !_isValidTargetLocation) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_limited"] call SCRT_fnc_misc_deniedHint;
};
Mode 1: Only allows travel to rebel HQ, trader, airports, or military bases.

18. Limited Fast Travel Validation (Mode 2)
Sqf

Apply
private _withinBoundaries = true;
if (limitedFT == 2) then {
    private _rebelLocations = (_rebelMarkers + airportsX + milbases) select { sidesX getVariable _x == teamPlayer };
    private _nearestPosition = [_rebelLocations, player] call BIS_Fnc_nearestPosition;
    private _distanceToNearest = player distance getMarkerPos _nearestPosition;
    _withinBoundaries = _distanceToNearest < 50;    
};
if (_checkForPlayer && limitedFT == 2 && (!_isValidTargetLocation or !_withinBoundaries)) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_limited_to_between_destinations"] call SCRT_fnc_misc_deniedHint;
};
Mode 2: Requires player to be within 50m of a valid rebel location to start fast travel.

19. Enemy Zone Restrictions
Sqf

Apply
if ((sidesX getVariable [_base,sideUnknown]) in [Occupants, Invaders]) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_enemy_zone"] call SCRT_fnc_misc_deniedHint; 
    openMap [false,false];
};
if (_base in forcedSpawn) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_enemy_attack"] call SCRT_fnc_misc_deniedHint; 
    openMap [false,false];
};

if ([getMarkerPos _base] call A3A_fnc_enemyNearCheck) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_enemy_surrounding"] call A3A_fnc_customHint; 
    openMap [false,false];
};
Multiple restrictions:

Can't travel to enemy-controlled zones
Can't travel to markers under attack (forcedSpawn)
Can't travel to destination with enemies nearby
20. Fast Travel Execution
Sqf

Apply
if (_positionTel distance getMarkerPos _base < 500) then {
    private _positionX = [getMarkerPos _base, 10, random 360] call BIS_Fnc_relPos;
    private _distanceX = round (((position _boss) distance _positionX)/200);
    private _forcedX = false;
    
    if (!_esHC) then {
        disableUserInput true; 
        cutText [format [localize "STR_hints_FT_timer", _distanceX],"BLACK",1]; 
        sleep 1;
    } else {
        [localize "STR_A3A_Dialogs_fast_travel_header", format [localize "STR_A3A_Dialogs_fast_travel_moving_hc_group",groupID _groupX]] call A3A_fnc_customHint; 
        sleep _distanceX;
    };
Checks distance to ensure click wasn't too far from marker
Calculates travel time based on distance (scaled by 200)
For individual: Disables input, shows black screen with timer
For HC: Shows message and waits for travel duration
21. Timer Animation (Individual)
Sqf

Apply
if (!_esHC) then {
    private _timePassed = 0;
    while {_timePassed < _distanceX} do {
        cutText [format [localize "STR_hints_FT_timer", (_distanceX - _timePassed)],"BLACK",0.0001];
        sleep 1;
        _timePassed = _timePassed + 1;
    };
};
Updates black screen timer every second for individual travel.

22. Limited Mode Validation During Travel
Sqf

Apply
private _exit = false;
if (limitedFT == 1 or limitedFT == 2) then {
    _vehicles = [];
    {if (vehicle _x != _x) then {_vehicles pushBackUnique (vehicle _x)}} forEach units _groupX;
    {if ((vehicle _x) in _vehicles) exitWith {_checkForPlayer = true}} forEach (call A3A_fnc_playableUnits);
};

if (_checkForPlayer and !_isValidTargetLocation) exitWith {
    [localize "STR_A3A_Dialogs_fast_travel_header", format [localize "STR_A3A_Dialogs_fast_travel_cancel",groupID _groupX]] call A3A_fnc_customHint;
};
During travel, re-validates destination permissions if limited modes active.

23. Unit Position Updates
Sqf

Apply
private _movedUnits = units _groupX;
private _ftUnits = [];
{
    private _unit = _x;
    if (!isPlayer _unit or {_unit == player}) then {
        _unit allowDamage false;
        _ftUnits pushBack _unit;
        if (_unit != vehicle _unit) then {
            if (driver vehicle _unit == _unit) then {
                sleep 3;
                _radiusX = 10;
                private _roads = [];
                while {true} do {
                    _roads = _positionX nearRoads _radiusX;
                    if (count _roads > 0) exitWith {};
                    _radiusX = _radiusX + 10;
                };
                _road = _roads select 0;
                private _pos = position _road findEmptyPosition [(sizeOf typeOf vehicle _unit) / 2, 100, typeOf (vehicle _unit)];
                if (_pos isEqualTo []) exitWith {
                    [localize "STR_A3A_Dialogs_fast_travel_header", localize "STR_A3A_Dialogs_fast_travel_no_empty_position"] call SCRT_fnc_misc_deniedHint
                };
                vehicle _unit setPos _pos;
            };
            if ((vehicle _unit isKindOf "StaticWeapon") and (!isPlayer (leader _unit))) then {
            private _pos = _positionX findEmptyPosition [10,100,typeOf (vehicle _unit)];
            vehicle _unit setPosATL _pos;
            };
        } else {
            if (!(_unit getVariable ["incapacitated",false])) then {
                _positionX = _positionX findEmptyPosition [1,50,typeOf _unit];
                _unit setPosATL _positionX;
                if (isPlayer leader _unit) then {_unit setVariable ["rearming",false]};
                _unit doWatch objNull;
                _unit doFollow leader _unit;
            } else {
                _positionX = _positionX findEmptyPosition [1,50,typeOf _unit];
                _unit setPosATL _positionX;
            };
        };
    };
} forEach _movedUnits;
Comprehensive unit positioning:

Temporarily disables damage during move
For drivers: Finds nearby road and calculates empty position
For static weapons: Finds empty position nearby
For infantry: Sets position, adjusts rearming state, sets watch/follow behavior
Handles incapacitated units separately
24. Post-Travel Cleanup
Sqf

Apply
if (!_esHC) then {
    disableUserInput false;
    cutText [localize "STR_hints_FT_dest","BLACK IN",1]
} else {
    [localize "STR_A3A_Dialogs_fast_travel_header", format [localize "STR_A3A_Dialogs_fast_travel_arrived_hc",groupID _groupX]] call A3A_fnc_customHint;
};

if (_forcedX) then {
    forcedSpawn deleteAt (forcedSpawn find _base);
};
    
sleep 5;
{_x allowDamage true} forEach _ftUnits;
Re-enables input and fades screen in
Shows HC arrival confirmation
Removes marker from forced spawn list if needed
Re-enables damage after 5 second safety period
Where it leads:

Calls SCRT_fnc_misc_deniedHint - Multiple denial messages (permission, enemy, distance, etc.)
Calls A3A_fnc_customHint - Status updates and information
Calls A3A_fnc_enemyNearCheck - Multiple times for proximity validation
Calls SCRT_fnc_rally_travelToRallyPoint - Specialized rally point travel
Calls A3A_fnc_playableUnits - Gets all playable units for validation
Calls BIS_fnc_nearestPosition - Finds nearest travel marker
Calls BIS_Fnc_relPos - Calculates offset position
Depends on: limitedFT, fastTravelEnemyCheck, markersX, traderMarker, isRallyPointPlaced, rallyPointMarker, forcedSpawn, teamPlayer, Occupants, Invaders
Modified by: positionTel (global), forcedSpawn (deletion), unit positions and states
Global variables:

Reads: limitedFT, fastTravelEnemyCheck, markersX, traderMarker, isRallyPointPlaced, rallyPointMarker, forcedSpawn, teamPlayer, Occupators, Invaders, A3A_FFPun_Jailed
Writes: positionTel
Modifies: Unit positions, unit damage states, forcedSpawn array
Network implications:

Extensive use of remoteExec for position updates
Client-side input blocking for individual travel
Synchronous execution across group members
Function Name: fn_mineDialog.sqf
What it does: Handles minefield creation or removal dialog actions. It calculates and deducts resources (money and HR), sets up the minefield creation parameters, and triggers the actual minefield building or clearing process via remote execution.

How it does that:

1. Parameter Extraction and Resource Calculation
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_typeX", "_position"];

private _moneyCost = minefieldCost select 0;
private _hrCost = minefieldCost select 1;
private _quantity = minefieldCost select 2;
private _mine = minefieldCost select 3;

if (_typeX == "delete") then {
    _moneyCost = _moneyCost - (server getVariable FactionGet(reb,"unitExp"));
    _hrCost = 1;
};
Extracts operation type ("delete" or mine type) and position
Gets base costs from global minefieldCost array
For deletion: Adjusts money cost (reduced by explosive specialist cost) and sets HR cost to 1
2. Resource Deduction
Sqf

Apply
[-_hrCost,-_moneyCost] remoteExec ["A3A_fnc_resourcesFIA",2];
Remotes resource deduction to server. Negative values deduct resources.

3. Deletion Handling
Sqf

Apply
if (_typeX == "delete") exitWith {
    closeDialog 0;
    closeDialog 0;
    [localize "STR_A3A_Dialogs_mineDialog_header", localize "STR_A3A_Dialogs_mineDialog_desc"] call A3A_fnc_customHint;
    [[],"A3A_fnc_mineSweep"] remoteExec ["A3A_fnc_scheduler",2];
};
For minefield deletion:

Closes dialog twice (possible double-close for safety)
Shows confirmation hint
Schedules mine sweep operation on server via scheduler
4. Quantity Validation for Creation
Sqf

Apply
private _quantityMax = if (_typeX == "ATMine") then {
    20;
} else {
    40;
};

if (_quantity > _quantityMax) then {
    _quantity = _quantityMax;
};

if (_quantity isEqualTo -1) then {
    _quantity = _quantityMax;
};
Sets maximum mine quantities: 20 for AT mines, 40 for others. Clamps or sets default if invalid.

5. Minefield Creation
Sqf

Apply
[[_typeX,_position,_quantity,_mine],"A3A_fnc_buildMinefield"] remoteExec ["A3A_fnc_scheduler",2];

closeDialog 0;
closeDialog 0;
Creates minefield via remote scheduled function
Closes dialog twice
Executes minefield building on server
Where it leads:

Calls A3A_fnc_customHint - Displays status messages
Calls A3A_fnc_resourcesFIA on server - Deducts resources
Calls A3A_fnc_mineSweep via scheduler - Handles minefield deletion
Calls A3A_fnc_buildMinefield via scheduler - Creates minefield
Depends on: minefieldCost global array, FactionGet(reb,"unitExp") resource value
Modified by: Player resources (money/HR)
Global variables:

Reads: minefieldCost
Modifies: Player resources via remote function
Network implications:

All operations remotely executed on server
Scheduled execution for heavy operations (minefield creation/removal)
Function Name: fn_moveHQObject.sqf
What it does: Allows players to move HQ assets (static weapons, supplies, etc.) within their base area. It handles physics manipulation, attachment to player, temporary mass reduction, and automatic placement on valid surfaces. Includes restrictions for commanders vs regular players and various validation checks.

How it does that:

1. Parameter Validation
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_thingX", "_playerX", "_id"];

private _isStatic = (_thingX isKindOf "StaticWeapon");
Extracts object, player, and action ID parameters. Determines if object is a static weapon.

2. Command Authority Check (Non-Static)
Sqf

Apply
if (!_isStatic && {player != theBoss}) exitWith {
    [localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_only_comm"] call SCRT_fnc_misc_deniedHint;
};
Non-static objects (supplies, etc.) can only be moved by commanders.

3. Already Moving Check
Sqf

Apply
if (!(isNull attachedTo _thingX)) exitWith {
    [localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_already_moved"] call SCRT_fnc_misc_deniedHint;
};
Prevents moving objects already attached to another unit.

4. Vehicle Restriction
Sqf

Apply
if (vehicle _playerX != _playerX) exitWith {
    [localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_veh"] call SCRT_fnc_misc_deniedHint;
};
Player must be on foot, not in a vehicle.

5. Attached Objects Limit
Sqf

Apply
if (([_playerX] call A3A_fnc_countAttachedObjects) > 0) exitWith {
    [localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_already_attached"] call SCRT_fnc_misc_deniedHint;
};
Prevents carrying multiple objects simultaneously.

6. Proximity to HQ Center
Sqf

Apply
private _sites = markersX select {sidesX getVariable [_x,sideUnknown] == teamPlayer};
private _markerX = [_sites,_playerX] call BIS_fnc_nearestPosition;
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _positionX = getMarkerPos _markerX;

if (_playerX distance2D _positionX > (_size + 5)) exitWith {
    [localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_closer_center"] call A3A_fnc_customHint;
};
Finds nearest friendly marker, gets its size, and ensures player is within marker bounds plus 5m.

7. Captive State Adjustment
Sqf

Apply
if (captive _playerX) then { _playerX setCaptive false };
Breaks stealth if player is in captive state.

8. Object State Preparation
Sqf

Apply
_thingX setVariable ["objectBeingMoved", true];
if !(_isStatic) then { _thingX removeAction _id };
if (_isStatic) then { _thingX lock true };

if (isNil {_thingX getVariable "A3A_originalMass"}) then { _thingX setVariable ["A3A_originalMass", getMass _thingX] };
[_thingX, 1e-12] remoteExecCall ["setMass", 0];
Sets moving flag on object
Removes move action from non-static objects
Locks static weapons
Records original mass if not already stored
Sets mass to near-zero (1e-12) for easier movement
9. Attachment Calculation
Sqf

Apply
private _spacing = 2 max (1 - (boundingBoxReal _thingX select 0 select 1));
private _height = 0.1 - (boundingBoxReal _thingX select 0 select 2);
_thingX attachTo [_playerX, [0, _spacing, _height]];
Calculates attachment offset based on object bounding box to prevent clipping.

10. Placement Function Definition
Sqf

Apply
private _fnc_placeObject = {
    params [["_thingX", objNull], ["_playerX", objNull], ["_dropObjectActionIndex", -1]];

    if (isNull _thingX) exitWith {Error("trying to place invalid HQ object")};
    if (isNull _playerX) exitWith {Error("trying to place HQ object with invalid player")};

    if (!(_thingX getVariable ["objectBeingMoved", false])) exitWith {};

    if (_playerX == attachedTo _thingX) then {
        _playerX setVelocity [0,0,0];
        _thingX setVelocity [0,0,0];
        detach _thingX;
    };

    if (_dropObjectActionIndex != -1) then {
        _playerX removeAction _dropObjectActionIndex;
    };

    // Can't find a case where this is ever true, but we'll make sure
    if (local _thingX) then {
        if (isNull group _thingX) then { [_thingX, 2] remoteExec ["setOwner", 2] }
        else { [group _thingX, 2] remoteExec ["setGroupOwner", 2] };
    };

    // Some objects never lose (and even regain) their velocity when detached, becoming lethal
    // On a DS, object locality changes when detached, so we have to remoteexec
    [_thingX, [0,0,0]] remoteExec ["setVelocity", _thingX];

    // Without this, non-unit objects often hang in mid-air
    [_thingX, surfaceNormal position _thingX] remoteExec ["setVectorUp", _thingX];

    // Place on closest surface
    private _pos = getPosASL _thingX;
    private _intersects = lineIntersectsSurfaces [_pos, _pos vectorAdd [0,0,-100], _thingX];
    if (count _intersects > 0) then {
        _thingX setPosASL (_intersects select 0 select 0);
    };

    if (_thingX isKindOf "StaticWeapon") then { _thingX lock false };

    _thingX setVariable ["objectBeingMoved", false];

    [_thingX, _thingX getVariable "A3A_originalMass"] remoteExecCall ["setMass", _thingX];
};
Comprehensive placement function:

Validates parameters
Checks moving state
Detaches object, zeroing velocities first
Removes drop action
Transfers object ownership if needed (for dedicated server)
Zeroes velocity to prevent lethal impact
Aligns object with surface normal
Finds ground intersection for proper placement
Unlocks static weapons
Restores original mass
Clears moving flag
11. Drop Action
Sqf

Apply
private _actionX = _playerX addAction [localize "STR_antistasi_actions_drop_here", {
    (_this select 3) params ["_thingX", "_fnc_placeObject"];

    [_thingX, player, (_this select 2)] call _fnc_placeObject;
}, [_thingX, _fnc_placeObject],6,true,true,"",""];
Adds drop action to player with reference to object and placement function.

12. Movement Validation Loop
Sqf

Apply
waitUntil {sleep 1;
    (_playerX != attachedTo _thingX)
    or (vehicle _playerX != _playerX)
    or (_playerX distance2D _positionX > (_size-3))
    or !([_playerX] call A3A_fnc_canFight)
    or (!isPlayer _playerX)
    or (_isStatic and {count crew _thingX > 0})
};

[_thingX, _playerX, _actionX] call _fnc_placeObject;
Monitors for termination conditions:

Player no longer attached
Enters vehicle
Moves outside marker bounds
Can't fight (unconscious)
Stops being player (respawn?)
Static weapon gains crew Calls placement function when any condition met.
13. Non-Static Re-Add Action
Sqf

Apply
if !(_isStatic) then { _thingX addAction [localize "STR_antistasi_actions_move_this_asset", A3A_fnc_moveHQObject,nil,0,false,true,"","(_this == theBoss)"] };
Re-adds move action for non-static objects with commander-only condition.

14. Post-Placement Validation
Sqf

Apply
if (vehicle _playerX != _playerX) exitWith {
    [localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_veh"] call SCRT_fnc_misc_deniedHint;
};

if  (_playerX distance2D _positionX > (_size - 3)) exitWith {
    [localize "STR_A3A_Dialogs_moveHQObject_header", localize "STR_A3A_Dialogs_moveHQObject_error_far_center"] call SCRT_fnc_misc_deniedHint;
};
Final validation after placement for edge cases.

Where it leads:

Calls A3A_fnc_countAttachedObjects - Validates attachment limit
Calls A3A_fnc_sizeMarker - Gets marker size for boundary check
Calls A3A_fnc_canFight - Checks if player can fight (not unconscious)
Calls SCRT_fnc_misc_deniedHint - Multiple denial messages
Calls A3A_fnc_customHint - Proximity validation message
Calls BIS_fnc_nearestPosition - Finds nearest HQ marker
Depends on: theBoss commander variable, markersX, sidesX
Modified by: Object position, mass, ownership, lock state
Global variables:

Reads: theBoss, markersX, sidesX, teamPlayer
Modifies: Object position, mass, ownership, lock state, object variables
Network implications:

Remote mass setting for initial reduction
Remote velocity and vector setting
Object ownership transfers for DS compatibility
Heavy network usage during object manipulation
Function Name: fn_persistentSave.sqf
What it does: Handles persistent save button functionality. Differentiates between commander and regular players: commanders trigger server-wide save loop, while regular players trigger personal save to server, close dialog, and show confirmation.

How it does that:

1. Commander vs Player Logic
Sqf

Apply
if (player == theBoss) then {
    [] remoteExecCall ["A3A_fnc_saveLoop", 2];
} else {
    [getPlayerUID player, player] remoteExecCall ["A3A_fnc_savePlayer", 2];
    closeDialog 0;
    hintC (localize "STR_hints_personal_save_success");
};
Checks if player is commander (theBoss)
If commander: Calls server-wide save loop remotely
If regular player: Saves personal data, closes dialog, shows hint
Where it leads:

Calls A3A_fnc_saveLoop on server - Server-wide persistent save
Calls A3A_fnc_savePlayer on server - Personal player save
Depends on: theBoss commander variable
Modified by: Save data (server and player)
Global variables:

Reads: theBoss
Network: Executes server-side save functions
Function Name: fn_skiptime.sqf
What it does: Allows commander to skip time forward by specified hours, with comprehensive validation for enemy proximity, active missions, HQ attacks, and player location. Includes multiple abort conditions with detailed notifications.

How it does that:

1. Command Authority Check
Sqf

Apply
params [["_hours", 6]];

if (player != theBoss) exitWith {
    [
        localize "STR_notifiers_fail_type",
        localize "STR_params_rest_header",  
        parseText localize "STR_params_rest_commander_only", 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
Validates commander authority with 30-second notification message.

2. Enemy Proximity Check
Sqf

Apply
private _rebelSpawners = units teamPlayer select { _x getVariable ["spawner",false] };
private _isEnemyNear = _rebelSpawners findIf { [getPosATL _x] call A3A_fnc_enemyNearCheck } != -1;

if (_isEnemyNear) exitWith {
    [
        localize "STR_notifiers_fail_type",
        localize "STR_params_rest_header",  
        parseText localize "STR_params_rest_enemies_near", 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
Checks all rebel spawner units for enemy proximity using A3A_fnc_enemyNearCheck.

3. Active Mission Checks
Sqf

Apply
if ("rebelAttack" in A3A_activeTasks) exitWith {
    [
        localize "STR_notifiers_fail_type",
        localize "STR_params_rest_header",  
        parseText localize "STR_params_rest_counterattack_in_progress", 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
if ("invaderPunish" in A3A_activeTasks) exitWith {
    [
        localize "STR_notifiers_fail_type",
        localize "STR_params_rest_header",  
        parseText localize "STR_params_rest_punishment_in_progress", 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
if ("DEF_HQ" in A3A_activeTasks) exitWith {
    [
        localize "STR_notifiers_fail_type",
        localize "STR_params_rest_header",  
        parseText localize "STR_params_rest_hq_under_attack", 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
if ("RIV_ENC" in A3A_activeTasks || {"RIV_ATT" in A3A_activeTasks}) exitWith {
    [
        localize "STR_notifiers_fail_type",
        localize "STR_params_rest_header",  
        parseText format [localize "STR_params_rest_rivals", A3A_faction_riv get "name", A3A_faction_reb get "name"], 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
Checks A3A_activeTasks for various mission types that prevent time skip.

4. Player Location Validation
Sqf

Apply
private _posHQ = getMarkerPos respawnTeamPlayer;
private _allPlayersInRadius = (allPlayers - (entities "HeadlessClient_F")) findIf {(_x distance _posHQ > 100) && {side _x isEqualTo teamPlayer}} == -1;

if (!_allPlayersInRadius) exitWith {
    [
        localize "STR_notifiers_fail_type",
        localize "STR_params_rest_header",  
        parseText localize "STR_params_all_players_near", 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
Ensures all non-HC rebel players are within 100m of HQ.

5. Time Skip Execution
Sqf

Apply
_hours remoteExec ["A3A_fnc_resourcecheckSkipTime", 0];
closeDialog 0; 
closeDialog 0;
Remotes hours to server for time skip execution on all clients (option 0)
Closes dialog twice for safety
Where it leads:

Calls SCRT_fnc_ui_showMessage - Shows abort notifications
Calls A3A_fnc_enemyNearCheck - Checks enemy proximity
Calls A3A_fnc_resourcecheckSkipTime on server - Executes time skip
Depends on: theBoss, teamPlayer, A3A_activeTasks, respawnTeamPlayer
Modified by: Game time on all clients
Global variables:

Reads: theBoss, teamPlayer, A3A_activeTasks, respawnTeamPlayer
Network: Broadcasts time skip to all clients
Function Name: fn_squadOptions.sqf
What it does: Creates the squad options dialog for recruiting specialized squads (assault, engineering, support). It sets up tooltip costs for each squad type and validates radio availability before displaying the dialog.

How it does that:

1. Radio Requirement Check
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!([player] call A3A_fnc_hasRadio)) exitWith {
    [localize "STR_A3A_Dialogs_squadOptions_header", localize "STR_A3A_reinf_addFIASquadHC_error_radio"] call SCRT_fnc_misc_deniedHint;
};
Validates player has radio before allowing squad options.

2. Dialog Creation
Sqf

Apply
#ifdef UseDoomGUI
    ERROR("Disabled due to UseDoomGUI Switch.")
#else
    _nul = createDialog "squadOptions";
#endif
Creates squadOptions dialog, disabled if UseDoomGUI switch is active.

3. UI Element Setup
Sqf

Apply
sleep 1;
disableSerialization;

private _display = findDisplay 100;

if (str (_display) == "no display") exitWith {};
Waits for dialog creation, gets display reference, validates existence.

4. Cost Calculations and Tooltips
Sqf

Apply
private _costs = 0;
private _costHR = 0;

{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach FactionGet(reb,"groupSquad");
(_display displayCtrl 104) ctrlSetTooltip format [localize "STR_dialog_cost_hire", _costs, _costHR, A3A_faction_civ get "currencySymbol"];
Calculates total cost and HR for each squad type by summing unit costs from faction data, then sets tooltip on corresponding control.

Where it leads:

Calls A3A_fnc_hasRadio - Validates radio availability
Calls SCRT_fnc_misc_deniedHint - Shows denial if no radio
Depends on: FactionGet(reb,"groupSquad"), FactionGet(reb,"groupSquadEng"), etc.
Modified by: Dialog display (no persistent state changes)
Global variables:

Reads: Faction data for costs
UI: Creates dialog and sets control properties
Function Name: fn_squadRecruit.sqf
What it does: Creates squad recruitment dialog for specialized units (medium, AT, sniper, support vehicles). Sets up tooltips with costs and validates radio availability before display.

How it does that:

1. Radio Requirement Check
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!([player] call A3A_fnc_hasRadio)) exitWith {
    [localize "STR_antistasi_dialogs_squad_recruitment_menu_frame_text", localize "STR_A3A_reinf_addFIASquadHC_error_radio"] call SCRT_fnc_misc_deniedHint;
};
Ensures player has radio for squad recruitment.

2. Dialog Creation
Sqf

Apply
#ifdef UseDoomGUI
    ERROR("Disabled due to UseDoomGUI Switch.")
#else
    createDialog "squadRecruit";
#endif
Creates squadRecruit dialog, disabled if UseDoomGUI.

3. UI Initialization
Sqf

Apply
sleep 1;
disableSerialization;

private _display = findDisplay 100;

if (str (_display) == "no display") exitWith {};
Waits for dialog, gets display, validates.

4. Cost Calculations for Each Squad Type
Sqf

Apply
private _crewCost = server getVariable FactionGet(reb,"unitCrew");

private _costs = 0;
private _costHR = 0;

_costs = 0;
_costHR = 0;
{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach FactionGet(reb,"groupMedium");
(_display displayCtrl 105) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates costs for medium squad by summing unit costs from faction data.

5. Specialized Squad Calculations
Sqf

Apply
_costs = 0;
_costHR = 0;
{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach FactionGet(reb,"groupAT");
(_display displayCtrl 106) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates AT squad costs.

Sqf

Apply
_costs = 0;
_costHR = 0;
{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach FactionGet(reb,"groupSniper");
(_display displayCtrl 107) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates sniper squad costs.

6. Vehicle-Based Squad Calculations
Sqf

Apply
_costHR = 2;
_costs = 2*_crewCost + ([(FactionGet(reb, "staticMGs")) # 0] call A3A_fnc_vehiclePrice);
(_display displayCtrl 108) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates crew + vehicle costs for mortar support squad (staticMGs).

Sqf

Apply
_costs = 0;
_costHR = 0;
{_costs = _costs + (server getVariable _x); _costHR = _costHR +1} forEach FactionGet(reb,"groupCrew");
(_display displayCtrl 112) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates crew squad costs.

Sqf

Apply
_costHR = 2;
_costs = 2*_crewCost + ([(FactionGet(reb,"vehiclesAT")) # 0] call A3A_fnc_vehiclePrice);
(_display displayCtrl 109) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates AT vehicle crew (2 crew) + vehicle costs.

Sqf

Apply
_costHR = 2;
_costs = 2*_crewCost + ([(FactionGet(reb,"vehiclesTruck")) # 0] call A3A_fnc_vehiclePrice) + ([(FactionGet(reb,"staticAA")) # 0] call A3A_fnc_vehiclePrice);
(_display displayCtrl 110) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates combined transport + AA defense costs.

Sqf

Apply
_costHR = 2;
_costs = 2*_crewCost + ([(FactionGet(reb,"staticMortars")) # 0] call A3A_fnc_vehiclePrice);
(_display displayCtrl 111) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates mortar crew + vehicle costs.

Sqf

Apply
_costHR = 2;
_costs = 2*_crewCost + ([FactionGet(reb,"vehiclesLightArmed") # 0] call A3A_fnc_vehiclePrice);
(_display displayCtrl 112) ctrlSetTooltip format [localize "STR_dialog_cost_hire",_costs,_costHR, A3A_faction_civ get "currencySymbol"];
Calculates light armed vehicle crew + vehicle costs.

Where it leads:

Calls A3A_fnc_hasRadio - Validates radio
Calls SCRT_fnc_misc_deniedHint - Denial message
Calls A3A_fnc_vehiclePrice - Gets vehicle prices
Depends on: Faction data, server variable costs
Modified by: Dialog display (UI only)
Global variables:

Reads: Faction data, server variables for costs
UI: Creates dialog and sets tooltips
Function Name: fn_unit_recruit.sqf
What it does: Creates unit recruitment dialog for individual units (rifleman, MG, medic, engineer, etc.). Sets up tooltips with unit costs for each type.

How it does that:

1. Dialog Creation
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

#ifdef UseDoomGUI
    ERROR("Disabled due to UseDoomGUI Switch.")
#else
    createDialog "unitRecruit";
#endif
Creates unitRecruit dialog, disabled if UseDoomGUI switch active.

2. UI Initialization
Sqf

Apply
sleep 1;
disableSerialization;

private _display = findDisplay 100;

if (str (_display) == "no display") exitWith {};
Waits for dialog, gets display, validates.

3. Cost Tooltips Setup
Sqf

Apply
private _childControl = _display displayCtrl 104;
(_display displayCtrl 104) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitRifle"),A3A_faction_civ get "currencySymbol"];
Sets tooltip for rifleman control (Ctrl 104) with rifleman cost from faction data.

4. Unit Type Cost Tooltips
Sqf

Apply
(_display displayCtrl 105) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitMG"),A3A_faction_civ get "currencySymbol"];
Machine gunner cost (Ctrl 105).

Sqf

Apply
(_display displayCtrl 126) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitMedic"),A3A_faction_civ get "currencySymbol"];
Medic cost (Ctrl 126).

Sqf

Apply
(_display displayCtrl 107) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitEng"),A3A_faction_civ get "currencySymbol"];
Engineer cost (Ctrl 107).

Sqf

Apply
(_display displayCtrl 108) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitExp"),A3A_faction_civ get "currencySymbol"];
Explosives specialist cost (Ctrl 108).

Sqf

Apply
(_display displayCtrl 109) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitGL"),A3A_faction_civ get "currencySymbol"];
Grenadier cost (Ctrl 109).

Sqf

Apply
(_display displayCtrl 110) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitSniper"),A3A_faction_civ get "currencySymbol"];
Sniper cost (Ctrl 110).

Sqf

Apply
(_display displayCtrl 111) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitLAT"),A3A_faction_civ get "currencySymbol"];
Light anti-tank cost (Ctrl 111).

Sqf

Apply
(_display displayCtrl 112) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitAT"),A3A_faction_civ get "currencySymbol"];
Heavy anti-tank cost (Ctrl 112).

Sqf

Apply
(_display displayCtrl 113) ctrlSetTooltip format [localize "STR_dialog_cost_hire_no_HR",server getVariable FactionGet(reb,"unitAA"),A3A_faction_civ get "currencySymbol"];
Anti-air cost (Ctrl 113).

Where it leads:

Depends on: Faction data for unit costs
Modified by: Dialog display (UI only)
Global variables:

Reads: Faction data and server variables for unit costs
UI: Creates dialog and sets tooltips