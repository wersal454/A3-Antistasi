AI Functions

Function Name: fn_ai_getNearFriendlyUnits.sqf
What it does: Returns all near friendly AI capable units that the player can control during unconsciousness. This function is specifically designed for the possession system where a player can temporarily take control of an AI unit when their original body is incapacitated. It filters out units that are already being healed or cannot fight, and prioritizes medics.

How it does that:

Initial Check: Immediately exits with empty array if unconsciousPossessAi is false, preventing possession when not allowed.

Apply
if (!unconsciousPossessAi) exitWith {[]};
Unit Selection: Filters the player's squad members with multiple conditions:
Excludes players (AI only)
Excludes Petros (commander unit)
Must be within 200m of player
Not currently in a healing animation
Must be capable of fighting (checked via A3A_fnc_canFight)

Apply
private _units = (units player) select {
    !(isPlayer _x) 
    && _x isNotEqualTo petros
    && {_x inArea [player, 200, 200, 0, false]
    && {!((animationState _x) in (medicAnims apply {toLowerANSI _x})) 
    && {[_x] call A3A_fnc_canFight
}}}};
Sorting: Sorts units by medic trait in descending order (medics first), ensuring the most valuable units (healers) are at the top of the list for possession.

Apply
[_units, [], { _x getUnitTrait "Medic" }, "DESCEND"] call BIS_fnc_sortBy
Where it leads:

Calls A3A_fnc_canFight to check unit combat capability
Calls BIS_fnc_sortBy for sorting
Called by 
fn_common_unconsciousEventHandler.sqf
 when player presses 'T' key while unconscious
Called by 
fn_ai_possessFriendlyUnit.sqf
 (indirectly through the unconscious event handler)
Global variables modified: None (local function)
Network implications: None (client-side only)
Function Name: fn_ai_possessFriendlyUnit.sqf
What it does: Allows the player to temporarily take control of an AI unit when their original body is incapacitated. The possession has a time limit and provides return mechanisms, handling damage events to automatically return control when either the possessed unit or original body takes damage.

How it does that:

Parameter Validation: Takes a single unit parameter and validates it against multiple conditions:
Unit must not be Petros
Unit must not be a player
Unit must be alive and not incapacitated
Unit must be on teamPlayer side
Player must not already be possessing another unit (recursive check)

Apply
params ["_unit"];

if (_unit == Petros) exitWith {
	[localize "STR_control_unit_hint_header", localize "STR_control_unit_error_petros"] call A3A_fnc_customHint;
};
if (isPlayer _unit) exitWith {
	[localize "STR_control_unit_hint_header", localize "STR_control_unit_error_no_player"] call A3A_fnc_customHint;
};
if (!(alive _unit) or (_unit getVariable ["incapacitated",false]))  exitWith {
	[localize "STR_control_unit_hint_header", localize "STR_control_unit_error_alive_only"] call A3A_fnc_customHint;
};
if (side _unit != teamPlayer) exitWith {
	[localize "STR_control_unit_hint_header", format [localize "STR_control_unit_error_rebel_only",A3A_faction_reb get "name"]] call A3A_fnc_customHint;
};

private _owner = player getVariable ["owner",player];
if (_owner!=player) exitWith {
	[localize "STR_control_unit_hint_header", localize "STR_control_unit_error_ai_recursion"] call A3A_fnc_customHint;
};
Setup: Stores original unit identity and sets up control variables:
Saves original body reference
Blocks revive on player temporarily
Marks unit as possessed
Stores player reference on unit

Apply
private _face = face _unit;
private _speaker = speaker _unit;

player setVariable ["originalBody", player];
player setVariable ["A3A_blockRevive", true, true];

_unit setVariable ["owner",player,true];
_unit setVariable ["A3A_player", player];
private _originalBody = player;
Event Handlers: Adds damage handlers to both player and possessed unit for automatic return:
Player damage handler: Returns control to player when player takes damage
Unit damage handler: Returns control when possessed unit takes damage

Apply
private _playerEh = player addEventHandler ["HandleDamage", {
	private _player = _this select 0;
	_player removeEventHandler ["HandleDamage",_thisEventHandler];
	selectPlayer _player;
	(units group player) joinsilent group player;
	group player selectLeader player;
	_player setVariable ["controlReturned", true];
	nil;
}];
Possession: Swaps player to the AI unit and maintains identity:

Apply
selectPlayer _unit;
[_unit, createHashMapFromArray [["face", _face], ["speaker", _speaker]]] call A3A_fnc_setIdentity;
Return Action: Adds action for manual return and checks for:
Time limit expiration
Unit incapacity
Manual return trigger
Original body recovery

Apply
private _returnActionId = _unit addAction [(localize "STR_antistasi_actions_return_control_to_ai"),{
	params ["_unit"];
	private _player = _unit getVariable "A3A_player";
	_unit setVariable ["controlReturned", true];
	selectPlayer _player;
}];
Cleanup: Restores original player state and removes all temporary variables and event handlers:

Apply
selectPlayer _originalBody;
player setVariable ["A3A_blockRevive", nil, true];
player setVariable ["originalBody", nil];
player removeEventHandler ["HandleDamage",_playerEh];
player setVariable ["controlReturned", nil];
Where it leads:

Calls A3A_fnc_customHint for feedback messages
Calls A3A_fnc_canFight to check unit capability
Calls A3A_fnc_flagaction to add heal action to original body
Calls SCRT_fnc_common_unconsciousEventHandler for keyboard events
Called by SCRT_fnc_common_unconsciousEventHandler when 'T' is pressed
Global variables modified: player (originalBody, A3A_blockRevive, controlReturned), _unit (owner, A3A_player, controlReturned)
Network implications: Local variable changes, owner sync (setVariable with true parameter)
Synchronization: Owner is set globally, other systems may detect possession state
Build Functions
Function Name: fn_build_addConstruction.sqf
What it does: Creates a construction object and adds it to the persistent constructions list (constructionsToSave). This list is saved with the game and enforces a maximum limit (LIFO principle - Last In, First Out). If the limit is exceeded, oldest constructions are automatically removed.

How it does that:

Server Verification: Ensures execution only runs on server, rerouting if called locally:

Apply
if (!isServer) exitWith {
    Error("Function miscalled locally, rerouting execution on server...");
    _this remoteExecCall ["SCRT_fnc_build_addConstruction", 2];
};
Safety Check: Verifies the global constructions list exists:

Apply
if (isNil "constructionsToSave") exitWith {
    Error("For some reason constructionsToSave doesn't exist.");
};
Object Creation: Creates the construction vehicle at specified position with collision enabled:

Apply
private _construction = createVehicle [_type, _position, [], 0, "CAN_COLLIDE"];
_construction setDir _direction;
Persistence: Adds to global list and broadcasts:

Apply
constructionsToSave pushBackUnique _construction;
publicVariable "constructionsToSave";
LIFO Management: Calculates excess and removes oldest items:

Apply
private _excessiveConstructions = maxConstructions - (count constructionsToSave);
if(_excessiveConstructions < 0) then {
	private _top = abs _excessiveConstructions;
	for "_i" from 0 to _top do {
		deleteVehicle (constructionsToSave select _i);
		constructionsToSave deleteAt _i;
	};
};
Where it leads:

Calls Error function for logging
Called by 
fn_build_prepareAndStartConstruction.sqf
 via A3A_fnc_buildCreateVehicleCallback
Global variables modified: constructionsToSave
Network implications: publicVariable broadcasts change to all clients
Synchronization: All clients receive updated construction list
Function Name: fn_build_prepareAndStartConstruction.sqf
What it does: Prepares and initiates construction placement. Validates player eligibility, resource availability, and positioning before creating a placement preview that can be confirmed.

How it does that:

Input Validation: Checks construction type and class validity:

Apply
params [["_constructionType", ""], ["_constructionClass", ""]];

if (_constructionClass isEqualTo "") exitWith {
    [localize "STR_A3A_reinf_buildCvc_header", localize "STR_A3A_reinf_build_error_empty"] call SCRT_fnc_misc_deniedHint;
};

if (_constructionType isEqualTo "") exitWith {
    [localize "STR_A3A_reinf_buildCvc_header", localize "STR_A3A_reinf_build_error_empty_type"] call SCRT_fnc_misc_deniedHint;
};
State Checks: Validates current game state:
Checks if already placing a construction
Validates player is not possessing an AI
Checks for enemy proximity

Apply
if (!(isNil "HR_GRG_placing") && {HR_GRG_placing}) exitWith {
    [localize "STR_A3A_reinf_buildCvc_header", localize "STR_A3AP_error_already_placing_generic"] call SCRT_fnc_misc_deniedHint;
};

if (player != player getVariable ["owner",player]) exitWith {
    [localize "STR_A3A_reinf_buildCvc_header", localize "STR_A3AP_error_aicontrol_generic"] call SCRT_fnc_misc_deniedHint;
};

if ([getPosATL player] call A3A_fnc_enemyNearCheck) exitWith {
    [localize "STR_A3A_reinf_buildCvc_header", localize "STR_A3AP_error_enemynear_generic"] call SCRT_fnc_misc_deniedHint;
};
Engineer Selection: Identifies available engineers (player or AI) and checks their status:

Apply
construction_selectedEngineer = objNull;
private _engineers = (units group player) select {_x call A3A_fnc_isEngineer};
// ... categorizes into player, other players, AI
Construction Cost/Time: Sets cost and build time based on type:

Apply
construction_cost = 0;
construction_buildTime = 0;
construction_type = _constructionType;

switch(_constructionType) do {
    case("TRENCH"): {
        construction_cost = 100;
        construction_buildTime = 25;
    };
    // ... other cases
};
Zone Validation: Ensures construction is within friendly territory:

Apply
private _sites = ((markersX - controlsX) + citiesX) select {sidesX getVariable [_x,sideUnknown] == teamPlayer};
private _playerPosition = position player;
construction_nearestFriendlyMarker = [_sites,_playerPosition] call BIS_fnc_nearestPosition;

if (!(_playerPosition inArea construction_nearestFriendlyMarker)) exitWith {
    // ... error message
};
Resource Check: Validates player has enough money:

Apply
private _money = player getVariable "moneyX";

if (_money < construction_cost) exitWith {
    // ... error message
};
Placement Confirmation: Sets up placement preview with callback:

Apply
private _fnc_placed = {
	params ["_vehicle", "_cost"];
    // ... validation checks
    private _type = typeOf _vehicle;
    private _pos = getPosASL _vehicle;
    private _dir = getDir _vehicle;
    deleteVehicle _vehicle;
    [_type, _pos, _dir] spawn A3A_fnc_buildCreateVehicleCallback;
};

[_constructionClass, _fnc_placed, {false}, [construction_cost], nil, nil, nil, _extraMessage] call HR_GRG_fnc_confirmPlacement;
Where it leads:

Calls SCRT_fnc_misc_deniedHint for error messages
Calls A3A_fnc_customHint for success messages
Calls A3A_fnc_isEngineer to check engineer eligibility
Calls A3A_fnc_canFight to check combat status
Calls A3A_fnc_enemyNearCheck for enemy proximity
Calls BIS_fnc_nearestPosition to find nearest friendly marker
Calls HR_GRG_fnc_confirmPlacement for placement UI
Calls A3A_fnc_buildCreateVehicleCallback on confirmation
Called by construction UI system
Global variables modified: construction_selectedEngineer, construction_cost, construction_buildTime, construction_type, construction_nearestFriendlyMarker
Network implications: None (client-side validation)
Synchronization: Global variables are temporary and local to construction process
Function Name: fn_build_removeConstruction.sqf
What it does: Removes a construction object from the persistent constructions list and deletes it from the game world. Used when constructions need to be destroyed or cleaned up.

How it does that:

Server Verification: Ensures server-side execution:

Apply
if (!isServer) exitWith {
    Error("Function miscalled locally, rerouting execution on server...");
    _building remoteExecCall ["SCRT_fnc_build_removeConstruction", 2];
};
List Verification: Checks constructions list exists:

Apply
if (isNil "constructionsToSave") exitWith {
    Error("For some reason constructionsToSave doesn't exist.");
};
Find Index: Locates building in the array:

Apply
private _buildingIndex = constructionsToSave find _building;

if (_buildingIndex == -1) exitWith {
    Error("Can't find building, aborting.");
};
Cleanup: Deletes vehicle and removes from array:

Apply
deleteVehicle _building;
constructionsToSave deleteAt _buildingIndex;
publicVariable "constructionsToSave";
Where it leads:

Calls Error for logging
Called by various destruction systems or construction removal UI
Global variables modified: constructionsToSave
Network implications: publicVariable broadcasts removal to all clients
Synchronization: All clients receive updated construction list
Function Name: fn_build_saveConstruction.sqf
What it does: Saves an already existing construction object to the persistent list (used for pre-existing or spawned constructions). Maintains the same LIFO limit as addConstruction.

How it does that:

Server Verification: Ensures server-side execution:

Apply
if (!isServer) exitWith {
    Error("Function miscalled locally, rerouting execution on server...");
    [_construction] remoteExecCall ["SCRT_fnc_build_saveConstruction", 2];
};
List Verification: Checks constructions list exists:

Apply
if (isNil "constructionsToSave") exitWith {
    Error("For some reason constructionsToSave doesn't exist.");
};
Persistence: Adds to global list and broadcasts:

Apply
constructionsToSave pushBackUnique _construction;
publicVariable "constructionsToSave";
LIFO Enforcement: Removes oldest if limit exceeded:

Apply
private _excessiveConstructions = maxConstructions - (count constructionsToSave);
if(_excessiveConstructions < 0) then {
	private _top = abs _excessiveConstructions;
	for "_i" from 0 to _top do {
		deleteVehicle (constructionsToSave select _i);
		constructionsToSave deleteAt _i;
	};
};
Where it leads:

Calls Error for logging
Called by construction systems when a construction should be saved
Global variables modified: constructionsToSave
Network implications: publicVariable broadcasts update to all clients
Synchronization: All clients receive updated construction list
Function Name: fn_build_updateConstruction.sqf
What it does: Updates an existing construction object's position or properties in the persistent list. Used when a construction is moved or modified.

How it does that:

Server Verification: Ensures server-side execution:

Apply
if (!isServer) exitWith {
    Error("Function miscalled locally, rerouting execution on server...");
    [_building] remoteExecCall ["SCRT_fnc_build_updateConstruction", 2];
};
List Verification: Checks constructions list exists:

Apply
if (isNil "constructionsToSave") exitWith {
    Error("For some reason constructionsToSave doesn't exist.");
};
Find Index: Locates building in the array:

Apply
private _buildingIndex = constructionsToSave find _building;

if (_buildingIndex == -1) exitWith {
    Error("Can't find building, aborting.");
};
Update: Replaces the entry with the updated object:

Apply
constructionsToSave set [_buildingIndex, _building];
publicVariable "constructionsToSave";
Where it leads:

Calls Error for logging
Called when constructions are modified (moved, rotated, etc.)
Global variables modified: constructionsToSave
Network implications: publicVariable broadcasts update to all clients
Synchronization: All clients receive updated construction list
Common Functions
Function Name: fn_common_addActionMove.sqf
What it does: Adds a "Carry crate" action to a vehicle or object, allowing players to carry cargo items. This action is automatically removed when the object is killed.

How it does that:

Check Existing Action: Removes any existing action to prevent duplicates:

Apply
params ["_vehicle"];
private _actionId = _vehicle getVariable ["scrt_moveActionId", Nil];
if(!isnil "_actionId") then {
	_vehicle removeAction _actionId;
};
Add Action: Creates the carry action with specific conditions:
Only for players
Player must own the object (no carrying while possessing AI)
Object must not be attached to anything

Apply
_actionId = _vehicle addAction [
    (localize "STR_antistasi_actions_carry_crate"), 
    SCRT_fnc_common_moveStatic,
    nil,
    0,
    false,
    true,
    "",
    "(isPlayer _this) && {(_this == _this getVariable ['owner',objNull]) && {isNull attachedTo _target}}", 
    4
];
Store Action ID: Saves ID for later removal:

Apply
_vehicle setVariable ["scrt_moveActionId", _actionId, false];
Auto-Remove on Death: Adds event handler to clean up when object is destroyed:

Apply
_vehicle addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	[_unit] remoteExec ["SCRT_fnc_common_removeActionMove",0, _unit];
}];
Where it leads:

Calls SCRT_fnc_common_moveStatic when action is executed
Called by various object spawn systems (crates, supply drops, etc.)
Global variables modified: scrt_moveActionId on object
Network implications: Remote execution for action removal on death
Synchronization: Action addition is local, death handler is networked
Function Name: fn_common_addRandomMoneyCargo.sqf
What it does: Adds a random amount of money magazines to vehicle cargo, with configurable probability and quantity. Used for random loot generation.

How it does that:

Input Validation: Checks if amount is zero:

Apply
params ["_vehicle", "_chance", "_amount"];
if(_amount == 0) exitWith {};
Probability Check: Rolls random chance against probability threshold:

Apply
_probability = random 100;
if(_chance >= _probability) then {
    // Add money
};
Add Money: Selects random money type and adds to cargo:

Apply
_moneyType = selectRandom arrayMoney;
_vehicle addMagazineCargoGlobal [_moneyType, _amount];
Where it leads:

Uses global arrayMoney for money types
Called by loot generation systems for random rewards
Global variables modified: None
Network implications: addMagazineCargoGlobal broadcasts to all clients
Synchronization: Money added globally
Function Name: fn_common_addRandomMoneyMagazine.sqf
What it does: Adds a single random money magazine to a unit's inventory. Used for random unit loot.

How it does that:

Probability Check: Rolls random chance against threshold:

Apply
params ["_soldier", "_chance"];
if(random 100 < _chance) then {
    // Add money
};
Add Money: Selects random money type and adds to unit:

Apply
_moneyType = selectRandom arrayMoney;
_soldier addMagazine [_moneyType, 1];
Where it leads:

Uses global arrayMoney for money types
Called by unit spawn systems for random loot
Global variables modified: None
Network implications: None (unit-specific addition)
Synchronization: Money added to local unit only
Function Name: fn_common_airdropCargo.sqf
What it does: Spawns a parachute-equipped supply drop of a specified object at a location. Creates parachute, attaches object, and handles landing with smoke/chemlight markers.

How it does that:

Parameter Normalization: Converts various input types to position array:

Apply
params [
	["_object", "CargoNet_01_box_F", [""]],
	["_centre", [0, 0, 0], ["", objNull, taskNull, locationNull, [], grpNull], [3]],
	["_height", 100, [0]],
	["_attachTo", [0, 0, -1.2], [[]], [3]]
];

_centre = _centre call {
	if (_this isEqualType objNull) exitWith {getPosASL _this};
	if (_this isEqualType grpNull) exitWith {getPosASL (leader _this)};
	if (_this isEqualType "") exitWith {getMarkerPos _this};
	// ... more conversions
};
Validation: Checks object class and position validity:

Apply
if (!(isClass (configfile >> "cfgVehicles" >> _object)) || _centre isEqualTo [0, 0, 0]) exitWith {
	objNull
};
Create Objects: Creates cargo and parachute at altitude:

Apply
private _obj = createVehicle [_object, [_centre select 0, _centre select 1, (_centre select 2) - 10], [], 0, "NONE"]; 
private _para = createVehicle ["B_parachute_02_F", [0,0,0], [], 0, "NONE"];
Attach and Position: Sets up parachute physics:

Apply
_para setDir getDir _obj;
_para setPos getPos _obj;
_obj lock false;
_obj attachTo [_para, _attachTo];
_para setVectorUp [0,0,1];
Landing Handler: Handles parachute deployment and landing:

Apply
[_obj, _para] spawn {
	params ["_obj","_para"];
	waitUntil {
		sleep 0.01;
		((position _obj) select 2) < 2 
		|| 
		isNull _para 
		|| 
		(count (lineIntersectsWith [getPosASL _obj, (getPosASL _obj) vectorAdd [0, 0, -0.5], _obj, _para])) > 0
	};
	// ... landing physics
	// ... smoke/chemlight placement
	deleteVehicle _para;
};
Where it leads:

Called by supply drop systems, mission rewards
Creates physical objects that persist after landing
Global variables modified: None
Network implications: Object creation is local to caller, but items within cargo are global
Synchronization: Supply drop created where called, not synchronized
Function Name: fn_common_attachLightSource.sqf
What it does: Attaches a light point to an object, providing illumination. Automatically cleans up when object is destroyed or removed.

How it does that:

Parameter Extraction: Takes object, light position, and luminosity:

Apply
params ["_object", "_lightPos", ["_luminosity", 0.4]];
Create Light: Creates local light point and attaches to object:

Apply
_light = "#lightpoint" createVehicleLocal (position _object);
_light lightAttachObject [_object, _lightPos];
Configure Light: Sets brightness, ambient, and color:

Apply
_light setLightBrightness _luminosity;
_light setLightAmbient [1.0, 1.0, 1.0];
_light setLightColor [1.0, 1.0, 1.0];
Auto-Cleanup: Waits for object removal and deletes light:

Apply
waitUntil {sleep 5; isNil "_object" || {!alive _object || isNull _object}};
deleteVehicle _light;
Where it leads:

Called by visual effect systems
Light is local to client, no network synchronization
Global variables modified: None
Network implications: None (local effect)
Synchronization: Each client creates their own light
Function Name: fn_common_buyReviveKitBox.sqf
What it does: Handles purchase of a revive kit box (for self-revival). Manages payment and creates placement preview.

How it does that:

Get Item Info: Retrieves revive kit box details from faction configuration:

Apply
private _reviveBox = FactionGet(reb, "reviveKitBox");
private _itemType = _reviveBox#0;
private _cost = _reviveBox#1;
Payment Check: Determines payment source (personal vs faction funds):

Apply
if (player != theBoss) then {
	_resourcesFIA = player getVariable "moneyX";
} else {
	private _factionMoney = server getVariable "resourcesFIA";
	if (_cost <= _factionMoney) then {
		_resourcesFIA = _factionMoney;
	} else {
		_resourcesFIA = player getVariable "moneyX";
	};
};
Affordability Check: Ensures funds are available:

Apply
if (_resourcesFIA < _cost) exitWith {
    [localize "STR_scrt_stores_buy_item_not_enough_header", format [localize "STR_scrt_stores_buy_item_not_enough", _cost, A3A_faction_civ get "currencySymbol"]] call SCRT_fnc_misc_deniedHint;
};
Placement Setup: Configures placement preview with callback:

Apply
private _fnc_placed = {
	params ["_vehicle", "_cost"];
	// Payment processing
	// Owner assignment
	// Death handler for cleanup
};
[_typeVehX, _fnc_placed, {false}, [_cost], nil, nil, nil, _extraMessage] call HR_GRG_fnc_confirmPlacement;
Where it leads:

Calls SCRT_fnc_misc_deniedHint for insufficient funds
Calls A3A_fnc_resourcesFIA for faction payment
Calls A3A_fnc_resourcesPlayer for personal payment
Calls HR_GRG_fnc_confirmPlacement for placement UI
Called by trader or menu systems
Global variables modified: None (payment functions modify money)
Network implications: Money changes are synchronized via resourcesFIA function
Synchronization: Payment is handled by server, box creation is local
Function Name: fn_common_chemicalDamage.sqf
What it does: Creates a persistent gas effect zone that damages entities within radius. Applies different damage effects based on entity type (man, vehicle, aircraft) and duration.

How it does that:

Configuration: Sets up damage parameters and masks:

Apply
params ["_sourceObject"];
private _affectedEntities = ["Car","Truck","CAManBase","Air", "StaticWeapon"];
private _timeOut = time + 120;
private _gasMasksMap = ["G_RegulatorMask_F", ...] createHashMapFromArray [];
private _coughSounds = ["A3\Sounds_f\characters\human-sfx\Person0\P0_choke_02.wss", ...];
Define Damage Logic: Creates function to apply gas damage to units:

Apply
private _affectMan = {
    params ["_man", "_gasMasksMap", "_coughSounds"];
    if ((goggles _man) in _gasMasksMap) exitWith {};
    private _distMult = (1-((_man distance _sourceObject)/70))/2;
    private _dam = damage _man + _distMult;
    if ((_dam >= 1) && {isPlayer _man}) then {
        _man setDamage 0;
        _man spawn A3A_fnc_respawn;
    } else {
        _man setDamage _dam;
    };
    // Cough sound
};
Create Damage Marker: Visual marker for gas area:

Apply
private _damageMarker = createMarkerLocal [format ["%1damage%2", random 10000, random 10000], (position _sourceObject)];
_damageMarker setMarkerShapeLocal "ELLIPSE";
// ... marker configuration
Main Loop: Periodically checks for entities and applies damage:

Apply
while {time < _timeOut} do {
    // Wind movement of marker
    private _units = nearestObjects [_sourceObject, _affectedEntities, 300];
    _units = (_units select {alive _x && !isObjectHidden _x && isDamageAllowed _x  && {(getPos _x) inArea _damageMarker}}) - [petros];
    {
        // Apply damage based on type
    } forEach _units;
    sleep 5;
};
Cleanup: Removes marker when effect ends:

Apply
deleteMarkerLocal _damageMarker;
Where it leads:

Calls A3A_fnc_respawn for player deaths
Called by chemical weapon support or missions
Global variables modified: None
Network implications: Marker is local, damage is applied to affected entities
Synchronization: Damage applied to entities on their respective localities
Function Name: fn_common_defeatFactionIfPossible.sqf
What it does: Checks if a faction (Invaders or Occupants) has been defeated (no remaining bases) and triggers victory conditions, including global notifications and cleanup.

How it does that:

Check Already Defeated: Skips if faction already defeated:

Apply
params ["_sideX"];
if (areInvadersDefeated && {_sideX == Invaders}) exitWith {};
if (areOccupantsDefeated && {_sideX == Occupants}) exitWith {};
Count Remaining Bases: Calculates all bases still controlled by faction:

Apply
private _remainingBases = { sidesX getVariable [_x, sideUnknown] == _sideX } count airportsX + milbases + outposts + seaports + factories + resourcesX;
Trigger Defeat: If no bases remain, mark as defeated and announce:

Apply
if (_remainingBases < 1) then {
    if (_sideX == Invaders) then {
        areInvadersDefeated = true; 
        publicVariable "areInvadersDefeated";
        // Set carrier marker invisible
        // Send announcement
    };
    // Similar for Occupants
    // Update statistics
};
Cleanup Occupants: For defeated Occupants, remove military administrations:

Apply
{     
    private _milAdministration = [A3A_milAdministrations, _x] call BIS_fnc_nearestPosition;
    [_milAdministration, "SILENT"] call SCRT_fnc_location_removeMilAdmin;
} forEach (milAdministrationsX select {sidesX getVariable [_x, sideUnknown] == Occupants});
Where it leads:

Calls BIS_fnc_nearestPosition for nearest admin
Calls SCRT_fnc_location_removeMilAdmin for admin removal
Calls A3A_fnc_commsMP for announcements
Calls A3A_fnc_statistics for stats update
Called by base capture systems or victory check loops
Global variables modified: areInvadersDefeated, areOccupantsDefeated
Network implications: publicVariable broadcasts defeat status
Synchronization: All clients receive defeat notification
Function Name: fn_common_fillSupplyDrop.sqf
What it does: Populates a supply crate with appropriate ammunition, medical supplies, and throwables based on players' unlocked arsenal items. Used for airdropped supplies.

How it does that:

Setup: Initializes crate and gets player list:

Apply
private _box = _this;
clearItemCargoGlobal _box;
clearMagazineCargoGlobal _box;
// ... clears all cargo
private _players = call SCRT_fnc_misc_getRebelPlayers;
private _aiUnits = (units theBoss) select { !isPlayer _x };
private _affectedEntities = _players + _aiUnits;
Get Unlocked Items: Retrieves arsenal-unlocked magazines and throwables:

Apply
private _unlockedMagazines = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL) select {_x select 1 == -1};
private _unlockedThrowables = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW) select {_x select 1 == -1};
Collect Possible Ammo: Gathers compatible magazines for each player's weapons:

Apply
{
    private _unit = _x;
    private _primaryMagazines = getArray(configfile >> "CfgWeapons" >> primaryWeapon _unit >> "magazines");
    // ... add to _possibleMagazines if unlocked
} forEach _affectedEntities;
Fill Crate: Adds magazines, first aid kits, and random throwables:

Apply
{
    _magCount = round random [4,7,10];
   _box addMagazineCargoGlobal [_x, _magCount];
} forEach _possibleMagazines;
// Add FAKs
// Add random throwables
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers to get players
Uses jna_dataList (JNA arsenal) for unlocked items
Called by supply drop systems
Global variables modified: None
Network implications: addMagazineCargoGlobal broadcasts crate content
Synchronization: All clients see same crate contents
Function Name: fn_common_findSafePositionForVehicle.sqf
What it does: Finds a safe position for vehicle spawning, preferring roads if available, otherwise using BIS_fnc_findSafePos. Returns position and direction.

How it does that:

Parameter Validation: Checks inputs:

Apply
params [["_position", []], ["_classname", ""], ["_radius", 250], ["_ignoreRoads", false]];
if (_position isEqualTo [] || {_classname isEqualTo ""}) exitWith {};
Road Search: Searches for nearby roads with expanding radius:

Apply
private _roads = [];
private _radiusX = 50;
private _iterations = 0;

if (!_ignoreRoads) then {
	while {true} do {
		_roads = _position nearRoads _radiusX;
		if (count _roads > 0) exitWith {};
		if (_iterations > 30) exitWith {};
		_iterations = _iterations + 1;
		_radiusX = _radiusX + 50;
	};
};
Position Selection: Chooses road position or finds safe area:

Apply
if (_roads isEqualTo []) then {
	_vehicleSpawnPosition = [
		_position, //center
		0, //minimal distance
		_radius, //maximumDistance
		7, //object distance
		0, //water mode
		0.45, //maximum terrain gradient
		0, //shore mode
		[], //blacklist positions
		[_position, _position] //default position
	] call BIS_fnc_findSafePos;
} else {
	private _road = selectRandom _roads;
	private _roadCon = roadsConnectedto _road;
	_dirVeh = if(count _roadcon > 0) then {[_road, _roadCon select 0] call BIS_fnc_DirTo} else {random 360};
	_vehicleSpawnPosition = getPos _road;
};
Empty Position: Final check for empty space:

Apply
private _emptyPos = _vehicleSpawnPosition findEmptyPosition [0, _radius, _classname];
if (_emptyPos isNotEqualTo []) then {
	_vehicleSpawnPosition = _emptyPos;
};
Where it leads:

Calls BIS_fnc_DirTo for road direction
Calls BIS_fnc_findSafePos for non-road position
Called by vehicle spawn systems
Global variables modified: None
Network implications: None (pure calculation)
Synchronization: N/A
Function Name: fn_common_fixCupRhsLaunchers.sqf
What it does: Removes broken launcher items from JNA arsenal that have "_loaded" or "_used" suffixes (common issue with CUP/RHS packs). Cleans up arsenal entries.

How it does that:

Check Requirements: Only runs if CUP or RHS factions are loaded:

Apply
if (!("specialCUP" in A3A_factionEquipFlags) && !("specialRHS" in A3A_factionEquipFlags)) exitWith {};
Find Broken Launchers: Searches secondary weapon tab for problematic entries:

Apply
private _brokenLaunchers = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON) select {
    private _weaponClass = toLowerANSI (_x select 0);
    "_loaded" in _weaponClass || {"_used" in _weaponClass}
};
Remove Items: Removes each broken launcher from arsenal:

Apply
{
    private _item = _x select 0;
    private _arsenalTab = [_item] call jn_fnc_arsenal_itemType;
    [_arsenalTab, _item, -1] call jn_fnc_arsenal_removeItem;
} forEach _brokenLaunchers;
Where it leads:

Calls jn_fnc_arsenal_itemType to get item type
Calls jn_fnc_arsenal_removeItem to remove from arsenal
Called by arsenal management systems
Global variables modified: None (modifies JNA arsenal data)
Network implications: Arsenal changes are server-side
Synchronization: All clients see updated arsenal
Function Name: fn_common_getMilAdminGarrisonPositions.sqf
What it does: Returns predefined garrison positions for different military administration building types, categorizing positions for POWs, items, soldiers, and collaborators.

How it does that:

Input Check: Validates building exists:

Apply
params [["_building", objNull, [objNull]]];
if (isNull _building) exitWith {
	[[],[], [], []]
};
Get Building Positions: Retrieves all positions from building:

Apply
private _buildingPositions = [_building] call BIS_fnc_buildingPositions;
Type-Specific Position Mapping: Uses switch statement to map building type to predefined position indices:

Apply
switch(_buildingType) do {
    case "Land_zachytka": {
        _powPositions = [43, 44, 53, 54, 55, 59, 61];
        _itemPositions = [64];
        _soldierPositions = [0,12,13,14,16,17,18,19,20,21,22,23,25,29,34,38,47,49,56,67,68,69,70,71,72,73,74,75,76,77,78,79];
        _collaborantPositions = [24, 28, 50, 51, 63];
    };
    // ... other building types
    default {
        // Fallback: assign all positions to all categories
    };
};
Return Categorized Positions: Returns arrays of indices for each category:

Apply
[
    _buildingPositions,
    _soldierPositions,
    _itemPositions,
	_collaborantPositions,
    _powPositions
];
Where it leads:

Calls BIS_fnc_buildingPositions to get all positions
Called by military administration systems
Global variables modified: None
Network implications: None
Synchronization: N/A
Function Name: fn_common_getNearPlayers.sqf
What it does: Returns list of rebel or civilian players within a specified distance from a center point.

How it does that:

Get All Players: Retrieves all players in mission:

Apply
params ["_distance", "_center"];
private _players = (call BIS_fnc_listPlayers) select {side _x in [teamPlayer, civilian] && {_x distance2D _center <= _distance}};
Filter by Side and Distance: Only includes rebel/civilian players within range:

Apply
private _players = (call BIS_fnc_listPlayers) select {side _x in [teamPlayer, civilian] && {_x distance2D _center <= _distance}};
Where it leads:

Uses BIS_fnc_listPlayers for player list
Called by various systems needing player proximity checks
Global variables modified: None
Network implications: None (client-side calculation)
Synchronization: N/A
Function Name: fn_common_getPromotionThreshold.sqf
What it does: Returns the promotion threshold points required for a specific military rank (e.g., PRIVATE = 0, CORPORAL = 100, etc.).

How it does that:

Create Rank Map: Builds hashmap of rank to point threshold:

Apply
private _rank = _this;
private _promotions = [
	"PRIVATE",
	"CORPORAL",
	"SERGEANT",
	"LIEUTENANT",
	"CAPTAIN",
	"MAJOR",
	"COLONEL"
] createHashMapFromArray [
	0,
	100,
	250,
	500,
	1000,
	1600,
	2500,
	3000
];
Look Up Threshold: Returns threshold or -1 if rank not found:

Apply
_promotions getOrDefault [_rank, -1]
Where it leads:

Called by rank/promotion systems
Global variables modified: None
Network implications: None
Synchronization: N/A
Function Name: fn_common_givePrisonerReleasePaycheck.sqf
What it does: Provides payment to a player for releasing an enemy prisoner under specific conditions (only Occupants, at war level 4+). Payment amount decreases with aggression level.

How it does that:

Condition Check: Validates eligibility criteria:

Apply
params ["_playerX", "_side"];
if(_side != Occupants || {tierWar < 4}) exitWith {};
Calculate Payment: Determines amount based on aggression level:

Apply
private _releasePaycheck = switch (aggressionLevelOccupants) do {
    case 1: { 125; };
    case 2: { 100; };
    case 3: { 50; };
    case 4: { 25; };
    default { 0; };
};
Delayed Payment: Schedules payment with 120-second delay:

Apply
[_playerX,_releasePaycheck] spawn {
    params ["_playerX", "_releasePaycheck"];
    _timeOut = time + 120;
    waitUntil { time > _timeOut; };
    _playerX setVariable ["moneyX", ((_playerX getVariable ["moneyX", 0]) + _releasePaycheck) max 0, true];
    // Send notification
};
Where it leads:

Called by prisoner release systems
Global variables modified: moneyX on player
Network implications: Money change is synchronized via setVariable with owner parameter
Synchronization: Money added to player after delay
Function Name: fn_common_hcTransfer.sqf
What it does: Transfers control of AI squad to Headless Client (HC). Creates new group and assigns to HC.

How it does that:

Check AI Units: Gets alive non-player units in player's group:

Apply
private _aiUnits = (units (group player)) select {!isPlayer _x && {alive _x} && {_x != petros}};
Validation Checks: Validates prerequisites:
HC exists (theBoss)
Both player and HC have radios
Player is in combat-ready state
AI units exist

Apply
if (theBoss isEqualTo objNull) exitWith { ... };
if (!([theBoss] call A3A_fnc_hasRadio)) exitWith { ... };
if (!([player] call A3A_fnc_canFight)) exitWith { ... };
if (count _aiUnits < 1) exitWith { ... };
Create Transfer Group: Creates new group and assigns AI units:

Apply
private _transferGroup = createGroup teamPlayer;
_transferGroup setGroupIdGlobal [format ["SqMilitia-%1",{side (leader _x) == teamPlayer} count allGroups]];
_aiUnits joinSilent _transferGroup;
Assign to HC: Assigns group to Headless Client:

Apply
theBoss hcSetGroup [_transferGroup];
Notification: Informs HC of transfer:

Apply
private _text = format [localize "STR_hints_hc_transfer_success", groupID _transferGroup];
[petros, "hint", _text] remoteExec ["A3A_fnc_commsMP",theBoss];
petros directSay "SentGenReinforcementsArrived";
Where it leads:

Calls A3A_fnc_hasRadio for radio check
Calls A3A_fnc_canFight for combat readiness
Calls A3A_fnc_commsMP for notification
Called by HC transfer menu
Global variables modified: None
Network implications: hcSetGroup assigns group to HC, notification sent via remoteExec
Synchronization: Group ownership transferred to HC
Function Name: fn_common_moveObject.sqf
What it does: Allows player to carry a movable object (like a crate). Handles attachment, movement, and placement with proper physics and anti-float prevention.

How it does that:

Setup: Disables sprint and sets movement state:

Apply
params ["_thingX"];
private _playerX = player;
_playerX allowSprint false;
_thingX setVariable ["objectBeingMoved", true];
_thingX enableSimulationGlobal false;
Undercover Check: Breaks undercover if player was camouflaged:

Apply
if (captive _playerX) then {
	_playerX setVariable ["carryUndercoverBreak", true];
};
Remove Carry Action: Removes the carry action while object is being moved:

Apply
[_thingX] remoteExec ["SCRT_fnc_common_removeActionMove", 0, _thingX];
Attach to Player: Calculates offset and attaches object:

Apply
private _spacing = 2 max (1 - (boundingBoxReal _thingX select 0 select 1));
private _height = 0.1 - (boundingBoxReal _thingX select 0 select 2);
_thingX attachTo [_playerX, [0, _spacing, _height]];
Define Placement Function: Handles object release with physics:

Apply
private _fnc_placeObject = {
	params [["_thingX", objNull], ["_playerX", objNull], ["_dropObjectActionIndex", -1]];
    // ... release logic
    // ... anti-float physics
};
Drop Action: Adds action to drop the object:

Apply
private _actionX = _playerX addAction [(localize "STR_antistasi_actions_drop_here"), {
	(_this select 3) params ["_thingX", "_fnc_placeObject"];
	[_thingX, player, (_this select 2)] call _fnc_placeObject;
}, [_thingX, _fnc_placeObject],0,false,true,"",""];
Wait for Conditions: Monitors for release conditions:

Apply
waitUntil {
	sleep 1; 
	(_playerX != attachedTo _thingX) 
	or {(vehicle _playerX != _playerX) 
	or {(!isPlayer _playerX) 
	or {(isNull _playerX) 
	or {!(alive _playerX)
	or {(_playerX getVariable ["incapacitated",false])}}}}}
};
Cleanup: Restores player abilities and re-adds action:

Apply
_playerX allowSprint true;
_thingX enableSimulationGlobal true;
[_thingX, _playerX, _actionX] call _fnc_placeObject;
[_thingX] remoteExec ["SCRT_fnc_common_addActionMove", 0, _thingX];
Where it leads:

Calls SCRT_fnc_common_removeActionMove to remove carry action
Calls SCRT_fnc_common_addActionMove to re-add carry action after placement
Called by SCRT_fnc_common_moveStatic or similar systems
Global variables modified: objectBeingMoved on object, carryUndercoverBreak on player
Network implications: Remote execution for action removal/addition
Synchronization: Object state changes are local but action management is networked
Function Name: fn_common_moveOutpostStatic.sqf
What it does: Allows moving outpost static weapons (HMG, AA, AT) between positions within outpost marker. Validates movement distance and saves new position.

How it does that:

Setup: Similar to moveObject but for statics:

Apply
params ["_target", "_caller", "_actionId", "_arguments"];
_target setVariable ["objectBeingMoved", true];
private _spacing = 2 max (1 - (boundingBoxReal _target select 0 select 1));
private _height = 0.1 - (boundingBoxReal _target select 0 select 2);
_target attachTo [_caller, [0, _spacing, _height]];
Place Function: Handles placement with distance validation:

Apply
private _fnc_placeObject = {
	params [["_target", objNull], ["_caller", objNull], ["_dropObjectActionIndex", -1]];
    // ... placement logic
    // ... adds back "Move_Outpost_Static" action
};
Find Nearest Outpost: Gets outpost marker for distance validation:

Apply
private _markerX = [(atpostsFIA + aapostsFIA + hmgpostsFIA), _caller] call BIS_fnc_nearestPosition;
private _markerSize = [_markerX] call A3A_fnc_sizeMarker;
private _markerPosition = getMarkerPos _markerX;
Remove Temporary Action: Removes move action while being carried:

Apply
[_target, "remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_target];
Wait for Conditions: Waits for release or distance violation:

Apply
waitUntil {sleep 1; (_caller != attachedTo _target) or (vehicle _caller != _caller) or (_caller distance2D _markerPosition > (_markerSize + 4)) or !([_caller] call A3A_fnc_canFight) or (!isPlayer _caller)};
Distance Check and Save: If moved outside outpost, rejects. Otherwise saves new position:

Apply
if  (_caller distance2D _markerPosition > (_markerSize + 4)) exitWith {
    // Error message
};
// ... save position to staticPositions
Where it leads:

Calls BIS_fnc_nearestPosition for nearest outpost
Calls A3A_fnc_sizeMarker for marker size
Calls A3A_fnc_flagaction for action management
Called by outpost static move action
Global variables modified: staticPositions (saved static positions)
Network implications: remoteExec for flag action, staticPositions saved globally
Synchronization: Static positions synchronized across all clients
Function Name: fn_common_moveStatic.sqf
What it does: Main function for moving static weapons and other objects. Validates move eligibility and handles movement for both portable crates and static weapons.

How it does that:

Input Validation: Validates object exists and side eligibility:

Apply
params ["_thingX"];
if(isNil "_thingX" || {isNull _thingX}) exitWith {};
if !(side player == teamPlayer || {side player == civilian}) exitWith { ... };
Carryable Boxes Check: Handles portable crates separately:

Apply
private _carryableBoxes = [FactionGet(reb,"lootCrate"), ...];
if ((typeOf _thingX) in _carryableBoxes) exitWith {
	[_thingX] call SCRT_fnc_common_moveObject;
};
Vehicle Checks: Ensures static weapon is not occupied:

Apply
if !((crew _thingX) isEqualTo []) exitWith { ... };
if(!(_thingX isKindOf "StaticWeapon")) exitWith { ... };
Movement Logic: Applies same attachment and movement as moveObject:

Apply
_playerX allowSprint false;
_thingX setVariable ["objectBeingMoved", true];
_thingX enableSimulationGlobal false;
private _spacing = 2 max (1 - (boundingBoxReal _thingX select 0 select 1));
private _height = 0.1 - (boundingBoxReal _thingX select 0 select 2);
_thingX attachTo [_playerX, [0, _spacing, _height]];
Save Static Position: If moved within friendly zone, saves position:

Apply
private _sites = markersX select {sidesX getVariable [_x,sideUnknown] == teamPlayer};
private _markerX = [_sites,_playerX] call BIS_fnc_nearestPosition;
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _positionX = getMarkerPos _markerX;

if (_playerX distance2D _positionX < _size) then {
    if (!(_thingX in staticsToSave)) then {
        staticsToSave pushBack _thingX;
        publicVariable "staticsToSave";
    };
    // ... save position to staticPositions
};
Where it leads:

Calls SCRT_fnc_common_moveObject for crate movement
Calls BIS_fnc_nearestPosition for nearest marker
Calls A3A_fnc_sizeMarker for marker size
Called by "Carry crate" action on statics and crates
Global variables modified: objectBeingMoved on object, staticsToSave and staticPositions
Network implications: publicVariable for staticsToSave, remote execution for actions
Synchronization: Static list and positions synchronized globally
Function Name: fn_common_panicFlee.sqf
What it does: Makes an AI unit surrender and flee when panic occurs. Disables combat AI, removes weapons, creates fleeing behavior, and handles zone capture checks.

How it does that:

Setup: Disables AI targeting and combat behaviors:

Apply
_unit disableAI "AUTOTARGET";
_unit disableAI "TARGET";
_unit setSkill 0;
unassignVehicle _unit;
[_unit] orderGetin false;
_unit setUnitPos "UP";
_unit setSpeaker "NoVoice";
Handle Spawner Units: Removes spawner tag to prevent garrison spawning:

Apply
if (_unit getVariable ["spawner", false]) then { _unit setVariable ["spawner", nil, true] };
Group Management: Puts unit in or creates fleeing group:

Apply
private _grpIdx = allGroups findIf { local _x && (side _x == _unitSide) && {_x getVariable ["fleeingGroup", false]} };
if (_grpIdx == -1) then {
	private _grp = createGroup _unitSide;
	_grp setVariable ["fleeingGroup", true, true];
	[_unit] joinSilent _grp;
} else {
	[_unit] joinSilent (allGroups select _grpIdx);
};
Weapon Drop: Creates weapon holders and throws weapons away:

Apply
private _weapons = weaponsItems _unit;
if (count _weapons > 0) then {
	private _weaponHolder = "WeaponHolderSimulated" createVehicle [0,0,0];
	_weaponHolder addWeaponWithAttachmentsCargoGlobal [_weapons select 0, 1];
	// ... position and throw
	// ... create static holder for secondary weapons
};
removeAllWeapons _unit;
Fleeing Animation: Sets fleeing animation:

Apply
_unit switchMove "ApanPercMsprSnonWnonDf";
Zone Support Check: Updates city support if not rival unit:

Apply
if !(_unit getVariable "isRival") then {
	if (_unitSide == Occupants ) then {
		[-2, 0, getPos _unit] remoteExec ["A3A_fnc_citySupportChange", 2];
	} else {
		[0, 1, getPos _unit] remoteExec ["A3A_fnc_citySupportChange", 2];
	};
};
Zone Capture Check: Triggers zone check if unit has marker:

Apply
private _markerX = _unit getVariable "markerX";
if (!isNil "_markerX") then { [_markerX, _unitSide] remoteExec ["A3A_fnc_zoneCheck",2] };
Cleanup and Flee: Spawns postmortem and flee script:

Apply
[_unit] spawn A3A_fnc_postmortem;
[_unit, _unitSide, false, true, true] spawn A3A_fnc_fleeToSide;
Where it leads:

Calls A3A_fnc_citySupportChange for support update
Calls A3A_fnc_zoneCheck for zone capture
Calls A3A_fnc_postmortem for cleanup
Calls A3A_fnc_fleeToSide for fleeing behavior
Called by surrender systems or panic events
Global variables modified: fleeingGroup on group, isRival flag
Network implications: Remote exec for support change and zone check
Synchronization: Support changes and zone checks are server-side
Function Name: fn_common_paradropVehicle.sqf
What it does: Performs paradrop operation with a vehicle and jumpers from an aircraft. Handles aircraft flight path, vehicle drop, parachute deployment, and landing procedures.

How it does that:

Parameter Setup: Extracts aircraft, group, target, and origin:

Apply
params [
    ["_plane", objNull, [objNull]],
    ["_groupJumper", grpNull, [grpNull]],
    ["_target", "", ["", []]],
    ["_originMarker", "", [""]],
    ["_resPool", nil, [""]]
];
Pilot Setup: Disables pilot AI targeting for precision drop:

Apply
private _groupPilot = group driver _plane;
{
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
    _x setBehaviour "CARELESS";
} foreach (units _groupPilot);
Jumper Preparation: Saves and removes jumpers' backpacks:

Apply
{
    _x setVariable ["jumpSave_Backpack", backpack _x];
    _x setVariable ["jumpSave_BackpackItems", backpackItems _x];
    removebackpack _x;
} forEach (units _groupJumper);
Flight Path Calculation: Calculates drop position, entry, and exit points:

Apply
private _dropPos = _targetPosition;
for "_i" from 1 to 10 do {
    private _testPos = _targetPosition getPos [random 150 + 150, random 360];
    if !(surfaceIsWater _testPos) exitWith { _dropPos = _testPos };
};
// Calculate entry and exit positions with attack angle
Waypoint Setup: Sets flight waypoints for pilot:

Apply
private _wp = _groupPilot addWaypoint [_entryPos, -1];
_wp setWaypointType "MOVE";
// ... waypoint configuration
VTOL Speed Reduction: Slows down VTOL/transport aircraft for precise drop:

Apply
if (_vehType in FactionGet(all,"vehiclesTransportAir")) then {
    waitUntil {sleep 1; (_plane distance2D _dropPos) < 3000};
    _plane limitSpeed ((0.8 * (getNumber(configOf _plane >> "maxSpeed"))) min 500);
    // ... progressively slow down
};
Flare Deployment: Launches flares for drop zone marking:

Apply
[_plane, _dropPos] spawn {
    params ["_plane", "_dropPos"];
    waitUntil {sleep 1; (_plane distance2D _dropPos) < 800};
    while {_plane distance2D _dropPos > 675} do {
        [_plane, "CMFlareLauncher"] call BIS_fnc_fire;
        // ... flare types
        sleep 0.3;
    };
};
Vehicle Drop: Spawns APC from plane and sets initial velocity:

Apply
private _apcData = [_initialPos, _dir, _apcClass, _side] call A3A_fnc_spawnVehicle;
private _apc = _apcData select 0;
private _apcCrew = _apcData select 1;
private _apcGroup = _apcData select 2;
// Set velocity matching plane
_apc setVelocity [(_planeVelocity select 0) * 0.2, (_planeVelocity select 1) * 0.2, -1];
Parachute Deployment: Creates parachute and attaches APC:

Apply
private _parachute = createVehicle ["B_Parachute_02_F", [0,0,0], [], 0, "NONE"];
_parachute setDir getDir _apc;
_parachute setPos getPos _apc;
_apc attachTo [_parachute, [0, 0, 1.5]];
Landing Procedures: Handles parachute release and crew setup:

Apply
waitUntil {
    sleep 0.01;
    ((position _apc) select 2) < 2 
    || {isNull _parachute
    || {(count (lineIntersectsWith [getPosASL _apc, (getPosASL _apc) vectorAdd [0, 0, -0.5], _apc, _parachute])) > 0 }}
};
// Release parachute, enable crew AI, assign jumpers to APC
Jumper Deployment: Moves jumpers from aircraft and handles their parachutes:

Apply
{
    unAssignVehicle _x;
    private _pos = if (_forEachIndex % 2 == 0) then {_plane modeltoWorld [7, -20, -5]} else {_plane modeltoWorld [-7, -20, -5]};
    _x setPos _pos;
    _x setVelocity _troopVelocity;
    _x spawn {
        waitUntil {sleep 0.25; ((getPos _this) select 2) < 150};
        _this addBackpack "B_Parachute";
        waitUntil { sleep 0.05; isTouchingGround _this};
        _this addBackpack (_this getVariable "jumpSave_Backpack");
        // ... restore backpack items
    };
    sleep 0.25;
} forEach units _groupJumper;
Exit Maneuver: Re-enables pilot AI and sets return waypoint:

Apply
_plane limitSpeed (2 * getNumber(configOf _plane >> "maxSpeed"));
private _wp2 = _groupPilot addWaypoint [_originPosition, -1];
// ... waypoint setup for return
Where it leads:

Calls A3A_fnc_spawnVehicle for APC creation
Calls BIS_fnc_fire for flare deployment
Calls A3A_fnc_attackHeli if aircraft is attack heli
Calls A3A_fnc_AIVEHinit for APC initialization
Calls A3A_fnc_smokeCoverAuto for smoke cover
Called by paradrop mission or support systems
Global variables modified: jumpSave_Backpack, jumpSave_BackpackItems, dropPosReached, planeDead, apc, hasLaptop, hasLaptopSpawned, canBeInterrogated, hasIntel on units
Network implications: publicVariable for some flags
Synchronization: Group transfers, waypoint synchronization, vehicle spawning
Function Name: fn_common_rebelSalary.sqf
What it does: Distributes a portion of faction income as salary to all active rebel players, calculated per player based on total players and income.

How it does that:

Get Rebel Players: Lists all rebel players:

Apply
params ["_resAdd"];
private _rebels = call SCRT_fnc_misc_getRebelPlayers;
if(_rebels isEqualTo []) exitWith { ... };
Calculate Total Salary: Takes 25% of income for salaries:

Apply
private _rebelsCount = count _rebels;
private _totalSalary = _resAdd / 4;
Distribute Per Player: Splits salary equally and applies to each player:

Apply
_nul = [_totalSalary, _rebelsCount, _rebels] spawn {
    params ["_totalSalary", "_rebelsCount", "_rebels"];
    private _incomePerPlayer = round(_totalSalary / _rebelsCount);
    {
        private _playerMoney = round (((_x getVariable ["moneyX", 0]) + _incomePerPlayer) max 0);
        _x setVariable ["moneyX", _playerMoney, (owner _x)];
        // Send paycheck notification
        sleep 10;
    } forEach _rebels;
};
Adjust Income: Returns reduced income amount:

Apply
_resAdd = _resAdd - _totalSalary;
_resAdd
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_commsMP for paycheck notification
Called by income management systems
Global variables modified: moneyX on players
Network implications: Money changes synchronized via setVariable with owner parameter
Synchronization: Salary distribution with delays
Function Name: fn_common_recon.sqf
What it does: Reveals enemy units in an area and provides visual markers (red ellipses) for the revealed units. Used for reconnaissance and interrogation effects.

How it does that:

Find Enemy Units: Gets nearby enemy units:

Apply
params ["_position", "_radius", "_revealTime", ["_isInterrogation", false]];
private _enemyUnits = (nearestObjects [_position, _affectedEntities, _radius, true]) select { alive _x && {side _x == Occupants || {side _x == Invaders}}};
Create Markers: For each enemy unit, creates a red marker:

Apply
{
    private _entityPosition = position _x;
    _entityPosition = [(_entityPosition select 0) + random 10, (_entityPosition select 1) + random 10, _entityPosition select 2];
    private _revealMarker = createMarker [format ["%1revealedEntity%2", random 10000, random 10000], _entityPosition];
    _revealMarker setMarkerShape "ELLIPSE";
    // ... marker settings
    _markers pushBack _revealMarker;
} forEach _enemyUnits;
Reveal to Friendly Units: Reveals enemies to nearby friendly units:

Apply
private _friendlyUnits = allUnits select {
    side (group _x) == teamPlayer && {_x distance2D _position < 500 && {[_x] call A3A_fnc_canFight}} 
};
{
    private _friendlyUnit = _x;
    {
        private _enemyUnit = _x;
        _friendlyUnit reveal [_enemyUnit, 2.5];
    } forEach _enemyUnits;
} forEach _friendlyUnits;
Send Notification: Alerts nearby players:

Apply
{
    [petros, "support", _revealText] remoteExec ["A3A_fnc_commsMP", _x];
} forEach ([500, _position] call SCRT_fnc_common_getNearPlayers);
Cleanup: Removes markers after timeout:

Apply
waitUntil {sleep 1; time > _timeOut};
{ deleteMarker _x; } forEach _markers;
Where it leads:

Calls A3A_fnc_canFight for combat check
Calls SCRT_fnc_common_getNearPlayers for nearby players
Calls A3A_fnc_commsMP for notification
Called by interrogation or reconnaissance missions
Global variables modified: None
Network implications: Markers are local, notifications via remoteExec
Synchronization: Reveal is per-unit, not networked
Function Name: fn_common_removeActionMove.sqf
What it does: Removes the "Carry crate" action from an object. Simple utility function.

How it does that:

Get Action ID: Retrieves stored action ID:

Apply
params ["_vehicle"];
private _actionId = _vehicle getVariable ["scrt_moveActionId", nil];
Remove Action: If exists, removes it and clears variable:

Apply
if(!isNil "_actionId") then {
    _vehicle removeAction _actionId;
	_vehicle setVariable ["scrt_moveActionId", nil];
};
Where it leads:

Called by object death handlers or other systems
Global variables modified: scrt_moveActionId on object
Network implications: None (local action removal)
Synchronization: N/A
Function Name: fn_common_reveal.sqf
What it does: Handles prisoner revelation. Determines chance of reconnaissance success based on aggression level and triggers recon effect if successful.

How it does that:

Remove Action: Removes reveal action from prisoner:

Apply
params ["_unit", "_player", "_actionID"];
[_unit, _actionID] remoteExec ["removeAction", [teamPlayer, civilian], _unit];
Set Interrogated: Marks unit as interrogated:

Apply
if (_unit getVariable ["interrogated", false]) exitWith {};
_unit setVariable ["interrogated", true, true];
Calculate Success Chance: Based on aggression level (higher aggression = lower chance):

Apply
private _chance = 0;
private _side = side (group _unit);
if (_side == Occupants) then {
	_chance = 100 - aggressionOccupants;
} else {
	_chance = 100 - aggressionInvaders;
};
_chance = _chance + 10; // Base 10% chance
Recon Trigger: If success, spawns recon effect:

Apply
if ((round (random 100)) < _chance) then {
    [(position _unit), 100, 30, true] spawn SCRT_fnc_common_recon;
} else {
	_unit globalChat localize "STR_recruit_fail_text";
};
Where it leads:

Calls SCRT_fnc_common_recon for reconnaissance
Called by prisoner interrogation action
Global variables modified: interrogated on unit
Network implications: Action removal via remoteExec
Synchronization: Interrogation flag synchronized
Function Name: fn_common_revive.sqf
What it does: Instantly revives a unit using a self-revive kit. Removes the kit from inventory and applies partial damage to revived unit.

How it does that:

Remove Kit: Removes self-revive kit from reviver's inventory:

Apply
params [
	["_reviver", objNull, [objNull]],
	["_revivee", objNull, [objNull]]
];
_reviver removeItem "A3AP_SelfReviveKit";
Revive Unit: Sets incapacitated flag false and applies damage:

Apply
_revivee setVariable ["incapacitated",false,true]; 
_revivee setDamage 0.25;
Notify Player: Sends success message and plays sound:

Apply
[localize "STR_A3AP_items_crrk_name", localize "STR_antistasi_actions_crk_used"] call A3A_fnc_customHint;
playSound "A3AP_UiSuccess";
Where it leads:

Calls A3A_fnc_customHint for message
Called by self-revive action
Global variables modified: incapacitated on revivee
Network implications: setVariable with true parameter
Synchronization: Revive state synchronized
Function Name: fn_common_scanHorizon.sqf
What it does: Makes an AI unit scan the horizon by rotating its head to look in four directions (0°, 90°, 180°, 270°) with random intervals.

How it does that:

Main Loop: Continuously scans while unit is alive:

Apply
params ["_man", "_sightHeight"];
while {sleep 1; alive _man} do { 
    { 
        private _relPos = _man getRelPos [700, _x];
        _man lookAt [_relPos select 0, _relPos select 1, _sightHeight]; 
        sleep random [2.5, 4, 5]; 
    } forEach [0, 90, 180, 270]; 
};
Where it leads:

Called by patrol or guard systems
Global variables modified: None
Network implications: None (AI behavior local to unit)
Synchronization: N/A
Function Name: fn_common_selectAndApplyLeaderIntel.sqf
What it does: Adds intelligence properties to specific unit types (traitors, officials, squad leaders). Can grant interrogation capability, intel items, or laptop spawns.

How it does that:

Input Validation: Checks unit validity:

Apply
params ["_unit", "_type", "_isRival"];
if (isNil "_unit" || {isNull _unit}) exitWith {};
Type-Based Assignment: Uses switch statement to assign properties:

Apply
switch (true) do {
	case ("Traitor" in _type);
	case ("Official" in _type): {
		_unit setVariable ["hasIntel", true, true];
		_unit setVariable ["side", _side, true];
		if ((random 100) < 35) then {
			_unit setVariable ["canBeInterrogated", true, true];
		} else {
			[_unit, "Intel_Small"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian], _unit];
		};
	};
	case (_isRival && {_type in FactionGet(all,"SquadLeaders")}) {
		// ... rival leader intel
	};
	case (_type in FactionGet(all,"SquadLeaders")): {
		// ... rebel squad leader intel
	};
	default { /* do nothing */ };
};
Laptop Spawn Setup: For rival leaders, adds death handler to spawn laptop:

Apply
_unit addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	if (_unit getVariable ["hasLaptopSpawned", false]) exitWith { ... };
	[_unit] call SCRT_fnc_rivals_createLaptop;
	_unit setVariable ["hasLaptopSpawned", true, true];
}];
Where it leads:

Calls A3A_fnc_flagaction to add intel action
Calls SCRT_fnc_rivals_createLaptop to create laptop
Called by unit spawn systems for special units
Global variables modified: hasIntel, side, canBeInterrogated, hasLaptop, hasLaptopSpawned on unit
Network implications: setVariable with true parameter, remoteExec for flag action
Synchronization: Intel flags synchronized, flag action added
Function Name: fn_common_set3dIcons.sqf
What it does: Adds 3D icons above incapacitated friendly players within 100m, showing their name and an unconscious icon. Used for finding downed teammates.

How it does that:

Add Draw3D Event: Registers draw event handler:

Apply
if (!hasInterface) exitWith {};
if (!playerIcons) exitWith {};

addMissionEventHandler [
	"Draw3D",
	{
		// ... draw logic
	}
];
Filter Players: Gets incapacitated friendly players within range:

Apply
private _players = (call BIS_fnc_listPlayers - [player]) select {
	alive _x && {side player getFriend side _x > 0.5 && {(lifeState _x) isEqualTo "INCAPACITATED"}}
};
Draw Icons: For each player, draw 3D icon:

Apply
{
	private _distance = player distance _x;
	if (_distance > 100) then { continue; };
	private _position = getPosATLVisual _x;
	_position set [2, (_position select 2) + 1 + (_distance * 0.05)];
	drawIcon3D [
		"a3\ui_f\data\igui\cfg\revive\overlayiconsgroup\u100_ca.paa",
		[1,0,0,1 - (_distance / 100)], 
		_position, 
		1, 
		1, 
		0, 
		[(localize "STR_antistasi_actions_draw3d_unconscious_text"), name _x] joinString " ", 
		1, 
		0.04 - (_distance / 9000), 
		"PuristaMedium"
	];
} forEach _players;
Where it leads:

Uses BIS_fnc_listPlayers for player list
Called by client-side initialization
Global variables modified: None
Network implications: None (visual only)
Synchronization: N/A
Function Name: fn_common_shareFactionMoneyWithMembers.sqf
What it does: TheBoss distributes faction money equally among all members (if membership enabled) or all rebel players. Sends payment notifications.

How it does that:

Get Faction Money: Retrieves faction resources:

Apply
private _resourcesFIA = server getVariable ["resourcesFIA", 0];
if(_resourcesFIA < 10) exitWith { ... };
Get Affected Players: Gets players based on membership setting:

Apply
private _affectedPlayers = call SCRT_fnc_misc_getRebelPlayers;
if (membershipEnabled) then {
    _affectedPlayers = _affectedPlayers select { 
        private _uid = getPlayerUID _x;
        private _isMember = _x call A3A_fnc_isMember;
       _isMember
    };
};
Calculate Per-Player Amount: Divides total money evenly:

Apply
private _playersCount = count _affectedPlayers;
private _sharePerPlayer = round(_resourcesFIA / _playersCount);
Distribute and Notify: Applies money and sends notification:

Apply
{ 
    [_sharePerPlayer] remoteExec ["A3A_fnc_resourcesPlayer", _x];
    private _paycheckText = format [ ... ];
    [petros, "income", _paycheckText] remoteExec ["A3A_fnc_commsMP", _x];
} forEach _affectedPlayers;
Reset Faction Money: Sets faction money to zero:

Apply
server setVariable ["resourcesFIA", 0, true];
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_isMember for membership check
Calls A3A_fnc_resourcesPlayer for payment
Calls A3A_fnc_commsMP for notification
Called by TheBoss money sharing action
Global variables modified: resourcesFIA on server
Network implications: Remote execution for payments, server variable update
Synchronization: Money distributed to players, faction money reset
Function Name: fn_common_sinkShip.sqf
What it does: Sinks a ship (trawler) with realistic sinking animation. Tilts ship, increases mass to simulate water flooding, and creates smoke effects.

How it does that:

Parameter Setup: Gets ship, sink side, time, and smoke option:

Apply
_ship     = [_this, 0, objNull]      call BIS_fnc_param;
_sinkside = [_this, 1, "LEFT BACK"]  call BIS_fnc_param;
_sinktime = [_this, 2, 120]          call BIS_fnc_param;
_smoke    = [_this, 3, TRUE]         call BIS_fnc_param;
Randomize Time: If time is 0, randomize between 60-180 seconds:

Apply
if (_sinktime == 0) then { _sinktime = 60 + random 120 };
Get Center of Mass: Retrieves ship's center of mass:

Apply
_x = getCenterOfMass _ship select 0;
_y = getCenterOfMass _ship select 1;
_z = getCenterOfMass _ship select 2;
Calculate Tilt Values: Based on sink side, calculate new center of mass coordinates:

Apply
switch (_sinkside) do {
    case "LEFT": {
        _x1 = _x - 1.0; _y1 = _y; 
        _x2 = _x - 1.7; _y2 = _y - 2.5;   
        _x3 = _x - 1.7; _y3 = _y;        
        _smokeloc = [-3, 0, -6];
    };
    // ... other cases
};
Create Smoke: Adds smoke particle source if enabled:

Apply
if (_smoke) then {
    _smoke_e = "#particlesource" createVehicle getPosATL _ship;
    _smoke_e setParticleClass "BigDestructionSmoke";
    _smoke_e attachTo [_ship, _smokeloc];
};
Sinking Phases: Three phases of sinking with increasing tilt and mass:

Apply
// Phase 1: Slight tilt
_ship setCenterOfMass [[_x1, _y1, _z1], _sinktime * 0.33];
_ship setMass [ 1500000, _sinktime * 0.33];
sleep (_sinktime * 0.33 + 0.5);

// Phase 2: Water reaches deck
_ship setCenterOfMass [[_x2, _y2, _z2], _sinktime * 0.66];
_ship setMass [ 3300000, _sinktime * 0.66];
sleep (_sinktime * 0.66 + 0.5);

// Phase 3: Final sink
_ship setCenterOfMass [[_x3, _y3, _z3], _sinktime];
_ship setMass [ 7000000, _sinktime];
Final Cleanup: Wait until submerged then disable simulation:

Apply
waitUntil { getPosATL _ship select 2 < 7 };
sleep 20;
_ship enableSimulation FALSE;
Where it leads:

Called by mission scripts or support systems
Global variables modified: None (ship properties only)
Network implications: None (local effect)
Synchronization: N/A
Function Name: fn_common_supplyDrop.sqf
What it does: Drops a payload from a plane with parachute. Handles different drop types (vehicles or supply crates) and fills crates with appropriate content.

How it does that:

Parameter Extraction: Gets plane, payload, and support type:

Apply
params ["_plane", "_payload", "_supportType"];
private _planeVehicle = vehicle _plane;
Create Payload: Spawns payload under plane:

Apply
private _supplyDrop = createVehicle [_payload, [getPos _planeVehicle select 0, getPos _planeVehicle select 1, (getPos _planeVehicle select 2)- 5], [], 0, "NONE"];
waituntil {!isnull _supplyDrop};
sleep 1.5;
Configure Drop Position: Sets parachute attachment point:

Apply
private _paraPos = nil;
switch(_supportType) do {
    case ("VEH_AIRDROP"): {
        _paraPos = [0, 0, -0.1];
    };
    default {
        _supplyDrop remoteExecCall ["SCRT_fnc_common_fillSupplyDrop", 2];
        [_supplyDrop] call A3A_fnc_addLoadAction;
        _paraPos = [0, 0, -0.6];
    };
};
Create and Attach Parachute: Creates parachute and attaches payload:

Apply
private _para = createVehicle ["B_parachute_02_F", [0,0,0], [], 0, "NONE"];
_para setDir getDir _supplyDrop;
_para setPos getPos _supplyDrop;
_supplyDrop attachTo [_para, _paraPos];
Landing Handler: Handles parachute release and landing markers:

Apply
[_supplyDrop, _para] spawn {
    params ["_obj","_para"];
    waitUntil {
        sleep 0.01;
        ((position _obj) select 2) < 2 
        || isNull _para 
        || (count (lineIntersectsWith [getPosASL _obj, (getPosASL _obj) vectorAdd [0, 0, -0.5], _obj, _para])) > 0
    };
    // ... release and smoke markers
};
Where it leads:

Calls SCRT_fnc_common_fillSupplyDrop for crate filling
Calls A3A_fnc_addLoadAction for logistics action
Called by supply drop support systems
Global variables modified: None
Network implications: Payload creation is local, fillSupplyDrop is remote to server
Synchronization: Drop occurs where called
Function Name: fn_common_triggerArtilleryResponseEH.sqf
What it does: Event handler for artillery firing. Detects artillery usage and may trigger enemy response based on detection chance and proximity.

How it does that:

Initial Checks: Validates artillery is alive and belongs to rebels:

Apply
params ["_artillery"];
if (!alive _artillery) exitWith {
    _artillery removeEventHandler ["Fired", _thisEventHandler];
};
if (side _artillery != teamPlayer) exitWith {};
Gunner Check: Ensures gunner is also rebel:

Apply
private _gunner  = gunner _artillery;
if (!isNull _gunner && {side _gunner != teamPlayer}) exitWith {};
Detection Calculation: Checks if position changed and updates detection chance:

Apply
private _dataX = _artillery getVariable ["detection", [position _artillery,0]];
private _positionX = position _artillery;
_chance = _dataX select 1;
if ((_positionX distance (_dataX select 0)) < 300) then {
    _chance = _chance + 2;
} else {
    _chance = 0;
};
Response Trigger: If chance rolls success, reveals artillery and requests support:

Apply
if (random 100 < _chance) then {
    {
        if !(side _x in [Occupants, Invaders]) then { continue };
        [leader _x, [_artillery, 4]] remoteExec ["reveal", leader _x];
    } forEach allGroups;
    // Find nearby bases
    private _airports = airportsX select { ... };
    private _milbases = airportsX select { ... };
    private _bases = _airports + _milbases;
    if (count _bases > 0) then {
        private _base = selectRandom _bases;
        _sideX = sidesX getVariable [_base, sideUnknown];
        private _reveal = [_positionX, _sideX] call A3A_fnc_calculateSupportCallReveal;
        [_sideX, _artillery, markerPos _base, (random [0.5, 2.5, 4]), _reveal] remoteExec ["A3A_fnc_requestSupport", 2];
    };
    _chance = 0;
};
Update Detection: Saves new detection data:

Apply
_artillery setVariable ["detection",[_positionX,_chance]];
Where it leads:

Calls A3A_fnc_calculateSupportCallReveal for reveal calculation
Calls A3A_fnc_requestSupport for support request
Called by artillery fired event
Global variables modified: detection on artillery
Network implications: Remote exec for reveal and support request
Synchronization: Detection state synchronized, support requested server-side
Function Name: fn_common_unconsciousEventHandler.sqf
What it does: Handles keyboard input when player is unconscious. Allows actions like respawn, AI possession, self-revive, and debug mode.

How it does that:

Key Mapping: Handles specific keys:

Apply
params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];
private _handled = false;

if (_key == 35) then { // F10
    if (A3A_selfReviveMethods isEqualTo true) then { [] spawn A3A_fnc_selfRevive };
};
Revive Kits Enabled: Additional key handlers when revive kits enabled:

Apply
if (reviveKitsEnabled) then {
	switch (_key) do {
		case DIK_R: { // R key - respawn
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
			player spawn A3A_fnc_respawn;
		};
		case DIK_T: { // T key - possess AI
			private _nearFriendlyUnits = [] call SCRT_fnc_ai_getNearFriendlyUnits;
			// ... cooldown check
			if (_nearFriendlyUnits isNotEqualTo []) then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
				[_nearFriendlyUnits select 0] spawn SCRT_fnc_ai_possessFriendlyUnit;
			};
		};
		case DIK_Q: { // Q key - self-revive
			if ("A3AP_SelfReviveKit" in (backpackItems player)) then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
				[player, player] call SCRT_fnc_common_revive;
			};
		};
	#if __A3_DEBUG__
		case DIK_F: { // F key - debug force respawn
			player setVariable ["incapacitated",false,true]; 
			player setDamage 0;
		};
	#endif
	};
};
No Revive Kits: Only respawn and AI possession available:

Apply
} else {
	switch (_key) do {
		case DIK_R: {
			// ... respawn
		};
		case DIK_T: {
			// ... possess AI
		};
	#if __A3_DEBUG__
		case DIK_F: {
			// ... debug
		};
	#endif
	};
};
Where it leads:

Calls SCRT_fnc_ai_getNearFriendlyUnits for AI list
Calls SCRT_fnc_ai_possessFriendlyUnit for possession
Calls A3A_fnc_selfRevive for self-revive
Calls A3A_fnc_respawn for respawn
Calls SCRT_fnc_common_revive for kit revive
Called by unconscious status
Global variables modified: None
Network implications: None (local key handling)
Synchronization: N/A
Function Name: fn_common_unflipVehicle.sqf
What it does: Attempts to flip a vehicle back upright if conditions are met (crew empty, adequate help, etc.). Has special handling for heavy vehicles requiring repair sources.

How it does that:

Input Validation: Gets cursor target and checks validity:

Apply
private _vehicle = cursorTarget;
if(isNil "_vehicle" || {isNull _vehicle}) exitWith {};
Type Check: Ensures it's a land vehicle:

Apply
private _hasFlipWarning = _vehicle getVariable ["A3U_hasFlipWarning", false];
if (!(_vehicle isKindOf "LandVehicle") && (!_hasFlipWarning)) exitWith { ... };
Alive Check: Verifies vehicle is intact:

Apply
private _isAlive = alive _vehicle;
if !(alive _vehicle) exitWith { ... };
Crew Check: Ensures vehicle is empty:

Apply
private _crew = crew _vehicle;
if !(_crew isEqualTo []) exitWith { ... };
Heavy Vehicle Check: For vehicles over 10,000kg mass, checks for nearby repair sources:

Apply
if((getMass _vehicle) > 10000) then {
    private _nearVehicles = nearestObjects [(position _vehicle),["Car", "Truck", "Tank"],50];
    _nearVehicles deleteAt (_nearVehicles find _vehicle);
    if (_nearVehicles isEqualTo []) then {
        _escape = true;
    } else {
        if (_nearVehicles findIf {[_x] call HR_GRG_fnc_isRepairSource} != -1) then {
            _hasRepairConditions = true;
        };
    };
};
Helper Check: Counts nearby friendly units:

Apply
private _nearFriendlies = (_vehicle nearEntities ["Man", 35]) select {side _x in [teamPlayer, civilian] && {[_x] call A3A_fnc_canFight}};
private _friendlyCount = count _nearFriendlies;
if (_friendlyCount < unflipPersonCount && {!_hasRepairConditions}) exitWith { ... };
Flip Vehicle: Checks angle and flips if excessive:

Apply
(_vehicle call BIS_fnc_getPitchBank) params ["_vx","_vy"];
if (([_vx,_vy] findIf {_x > 80 || _x < -80}) != -1) then {	
	[_vehicle] spawn {
        params ["_unflippableVehicle"];
        _unflippableVehicle allowDamage false;
        _unflippableVehicle setVectorUp [0,0,1];
        _unflippableVehicle setPosATL [(getPosATL _unflippableVehicle) select 0, (getPosATL _unflippableVehicle) select 1, 0];
        sleep 1;
        _unflippableVehicle allowDamage true;
        terminate _thisScript;
	};
};
Where it leads:

Calls HR_GRG_fnc_isRepairSource for repair check
Calls A3A_fnc_canFight for combat check
Called by unflip action
Global variables modified: A3U_hasFlipWarning on vehicle
Network implications: None (local action)
Synchronization: N/A
Function Name: fn_common_updateArsenal.sqf
What it does: Updates the arsenal (JNA) and sends notification if changes were made. Simple wrapper for arsenal management.

How it does that:

Update Arsenal: Calls arsenal management function:

Apply
private _arsenalUpdateText = [] call A3A_fnc_arsenalManage;
Send Notification: If changes occurred, broadcast update:

Apply
if (_arsenalUpdateText isNotEqualTo "") then {
    _arsenalUpdateText = format [localize "STR_hints_arsenal_transfer_updated", _arsenalUpdateText];
    [petros,"income",_arsenalUpdateText] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
};
Where it leads:

Calls A3A_fnc_arsenalManage for update
Calls A3A_fnc_commsMP for notification
Called by arsenal management systems
Global variables modified: None
Network implications: Notification broadcast
Synchronization: Arsenal changes are server-side, notification to all clients
Composition Functions
Function Name: fn_composition_rivals1.sqf
What it does: Returns composition data for rival camp type 1 (small camp with tents, generators, fences). Used for spawning rival locations.

How it does that:

Return Composition Array: Returns predefined array of objects with positions, classes, directions, and initialization code:

Apply
[
	["Land_Camping_Light_F",[1.48096,-0.681641,-0.00321579],76.3008,1,0,[],"","this enableDynamicSimulation true",true,false], 
	["Land_Campfire_F",[1.61035,1.33447,0.0299988],26.909,1,0,[],"","this enableDynamicSimulation true",true,false], 
	// ... more objects
]
Where it leads:

Called by rival location spawning systems
Global variables modified: None
Network implications: None
Synchronization: N/A
Function Name: fn_composition_rivals2.sqf
What it does: Returns composition data for rival camp type 2 (larger camp with more structures and defenses).

How it does that: Returns predefined array of objects with positions, classes, directions, and initialization code (similar to rivals1).

Where it leads:

Called by rival location spawning systems
Global variables modified: None
Network implications: None
Synchronization: N/A
Function Name: fn_composition_rivals3.sqf
What it does: Returns composition data for rival camp type 3 (compound with building and more complex layout).

How it does that: Returns predefined array of objects with positions, classes, directions, and initialization code (similar to rivals1).

Where it leads:

Called by rival location spawning systems
Global variables modified: None
Network implications: None
Synchronization: N/A
Effect Functions
Function Name: fn_effect_crashingEffects.sqf
What it does: Creates visual and audio effects for a crashing object (like a drop pod or orbital impact). Includes smoke particles, light, and sound effects.

How it does that:

Particle Source Creation: Creates multiple particle sources for smoke and debris:

Apply
private _ps0 = "#particlesource" createVehicleLocal _posATL;
_ps0 setParticleParams [
["\A3\Data_F\ParticleEffects\Universal\Universal", 16, 10, 32], "", "Billboard",
0, 3, [0, 0, 0.25], [0, 0, 0.5], 1, 1, 0.9, 0.3, [3.5],
[[1,1,1, 0.0], [1,1,1, 0.3], [1,1,1, 0.0]],
[0.75], 0, 0, "", "", _ps0, rad -45];
_ps0 setParticleRandom [0.2, [1, 1, 0], [0.5, 0.5, 0], 0, 0.5, [0, 0, 0, 0], 0, 0];
_ps0 setDropInterval 0.03;
Light Source: Creates bright light for impact:

Apply
private _lightSource = "#lightpoint" createVehicleLocal _posATL;
_lightSource setLightColor [1,0.8,0.8];
_lightSource setLightAmbient [1,0.8,0.8];
_lightSource setLightUseFlare true;
_lightSource setLightFlareSize 30;
_lightSource setLightFlareMaxDistance 2500;
_lightSource setLightBrightness 3000;
_lightSource setLightDayLight true;
_lightSource setLightIntensity 1e6;
Attach to Object: Particles and light follow the object:

Apply
_ps0 attachTo [_object, [0, 0, 1]];
_ps1 attachTo [_object, [0, 0, 1]];
_ps2 attachTo [_object, [0, 0, 1]];
_lightSource attachTo [_object, [0, 0, 0]];
Sonic Boom: For orbital drops, plays sound and creates screen shake:

Apply
if (typeOf _object in (_faction get "vehiclesDropPod") ) then {
	setAperture 10;
	waitUntil {sleep 0.1; getPos _object select 2 < 2500};
	playSound3D [QPATHTOFOLDER(Sounds\Misc\Sonic.ogg), _object, false, getPosASL _object, 5, 1, 7000];
	// ... screen shake effect
	setAperture 0;
};
Cleanup: Deletes particles when object lands:

Apply
waitUntil { sleep 0.01; getPos _object select 2 < 3 };
deleteVehicle _ps0;
deleteVehicle _ps1;
deleteVehicle _ps2;
deleteVehicle _lightSource;
Where it leads:

Called by drop pod or crash systems
Global variables modified: None
Network implications: None (local effect)
Synchronization: N/A
Function Name: fn_effect_createBurningDebrisEffect.sqf
What it does: Creates a singular burning debris particle effect at a position for a specified lifetime.

How it does that:

Create Fake Object: Uses empty helipad as particle anchor:

Apply
private _fakeObject = "Land_HelipadEmpty_F" createVehicleLocal _position;
Create Particle Source: Sets up burning debris particle effect:

Apply
_effectEmitter = "#particlesource" createVehicleLocal position _fakeObject;
_effectEmitter setParticleClass "ObjectDestructionShardsBurning"; 
_effectEmitter setParticleCircle [0, [0, 0, 0]];
_effectEmitter setParticleParams [ 
    ["\A3\data_f\ParticleEffects\Shard\shard.p3d",1,0,1,0], 
    "", 
    "spaceObject", 
    1, 
    _lifeTime, 
    [0,0,0], 
    [0,6,0], 
    3,40,7.9,0.05, 
    [1,1,1,0], 
    [[1,1,1,1],[1,1,1,1]], 
    [1,1], 
    0.01, 
    0.08, 
    "", 
    "", 
    _fakeObject, 
    0, 
    true, 
    0.03, 
    [[0,0,0,0]] 
]; 
Cleanup: Removes after lifetime:

Apply
sleep 2;
deleteVehicle _effectEmitter;
deleteVehicle _fakeObject;
Where it leads:

Called by explosion or destruction systems
Global variables modified: None
Network implications: None (local effect)
Synchronization: N/A
Function Name: fn_effect_createGasEffect.sqf
What it does: Attaches a gas/chemical particle effect to an object (like a chemical bomb).

How it does that:

Create Particle Source: Creates billboarding gas particles:

Apply
private _gasEffect = "#particlesource" createVehicleLocal _pos; 
_gasEffect setParticleCircle [0, [0, 0, 0]]; 
_gasEffect setParticleRandom [0, [0.5, 0.5, 0], [0.2, 0.2, 0], 0, 0.25, [0, 0, 0, 0.1], 0, 0]; 
_gasEffect setParticleParams [ 
    ["\A3\Data_F\ParticleEffects\Universal\Universal", 16, 9, 1],  
    "",  
    "Billboard",  
    1,  
    32,  
    [0, 0, 0],  
    [0, 0, 0.5],  
    0,  
    10.2,  
    7.9,  
    0.5,  
    [16, 32, 48],  
    [[0.450, 0.556, 0.215, 0.5], [0.662, 0.768, 0.411, 0.25], [0.921, 0.960, 0.811, 0]],  
    [0.125],  
    1,  
    0,  
    "",  
    "",  
    _object 
];  
_gasEffect setDropInterval 0.4; 
_gasEffect attachTo [_object, [0, 0, 2]]; 
Auto-Cleanup: Removes after 140 seconds:

Apply
private _timeOut = time + 140;
waitUntil {sleep 1; time > _timeOut};
deleteVehicle _gasEffect;
Where it leads:

Called by chemical weapon systems
Global variables modified: None
Network implications: None (local effect)
Synchronization: N/A
Function Name: fn_effect_createSmallExplosionEffect.sqf
What it does: Creates a small explosion effect (grenade-sized) with explosion particles, smoke, and light.

How it does that:

Create Explosion Particles: Grenade explosion particle system:

Apply
private _explosion = "#particlesource" createVehicleLocal _pos; 
_explosion setParticleClass "GrenadeExp";
_explosion setParticleParams [
    [
        "\A3\data_f\ParticleEffects\Universal\Universal",
        16,
        0,
        32,
        0
    ],
    "",
    "Billboard",
    0.3,
    0.3,
    [ 0,0,0 ],
    [ 0,1,0 ],
    0,
    10,
    7.9,
    0.1,
    [ 0.0125 * 0.3 + 4, 0.0125 * 0.3 + 1 ],
    [ [1,1,1,-6],[1,1,1,0] ],
    [ 1 ],
    0.2,
    0.2,
    "",
    "",
    _this,
    0,
    false,
    0.6,
    [ [ 30,30,30,0 ],[ 0,0,0,0 ] ]
];
Create Smoke: Adds smoke trail:

Apply
private _smoke = "#particlesource" createVehicleLocal _pos; 
_smoke setParticleClass "GrenadeSmoke1";
// ... particle parameters
_smoke setDropInterval ( 0.08 );
Create Light: Adds flash of light:

Apply
private _light = "#lightPoint" createVehicleLocal _pos; 
_light setLightAmbient [ 0,0,0 ];
_light setLightBrightness 10;
_light setLightColor [ 1,0.6,0.4 ];
_light setLightIntensity 10000;
// ... attenuation
Cleanup Loop: Removes effects after durations:

Apply
while {count _emitters > 0} do {
    {
        _x params[ "_source", "_length" ];
        if ( time > _time + _length ) then {
            deleteVehicle _source;
            _emitters set[_forEachIndex, objNull];
        };
    } forEach _emitters;
    _emitters = _emitters - [ objNull ];
};
Where it leads:

Called by explosion systems for small blasts
Global variables modified: None
Network implications: None (local effect)
Synchronization: N/A
Function Name: fn_effect_orbitalDropEffect.sqf
What it does: Creates specialized orbital drop effects including sonic boom, screen shake, and particle effects. Similar to crashing effect but optimized for orbital drops.

How it does that:

Particle Creation: Creates multiple particle sources (similar to crashing effect):

Apply
private _ps0 = "#particlesource" createVehicleLocal _posATL;
// ... particle setup
Light Setup: Creates intense light:

Apply
private _lightSource = "#lightpoint" createVehicleLocal _posATL;
_lightSource setLightColor [1,0.8,0.8];
_lightSource setLightAmbient [1,0.8,0.8];
_lightSource setLightUseFlare true;
_lightSource setLightFlareSize 30;
_lightSource setLightFlareMaxDistance 2500;
_lightSource setLightBrightness 3000;
_lightSource setLightDayLight true;
_lightSource setLightIntensity 1e6;
Attach Particles: Particles follow object:

Apply
_ps0 attachTo [_object, [0, 0, 1]];
_ps1 attachTo [_object, [0, 0, 1]];
_ps2 attachTo [_object, [0, 0, 1]];
_lightSource attachTo [_object, [0, 0, 1]];
Sonic Boom: Plays sound at specific altitude:

Apply
waitUntil {sleep 0.1; getPos _object select 2 < 2500};
playSound3D [QPATHTOFOLDER(Sounds\Misc\Sonic.ogg), _object, false, getPosASL _object, 5, 1, 7000];
Screen Shake: Creates screen shake effect on player:

Apply
player spawn {
	for "_i" from 0 to 200 do {
		_vx = vectorup _this select 0;
		_vy = vectorup _this select 1;
		_vz = vectorup _this select 2;
		_coef = 0.01 - (0.0001 * _i);
		_this setvectorup [
		_vx+(-_coef+random (2*_coef)),
		_vy+(-_coef+random (2*_coef)),
		_vz+(-_coef+random (2*_coef))
	];
	sleep (0.01 + random 0.01);
	};
};
Cleanup: Removes when object lands:

Apply
waitUntil { sleep 0.01; getPos _object select 2 < 4 };
deleteVehicle _ps0;
deleteVehicle _ps1;
deleteVehicle _ps2;
deleteVehicle _lightSource;
Where it leads:

Called by orbital drop systems
Global variables modified: None
Network implications: None (local effect)
Synchronization: N/A

(Encounter System)
Constants.inc
What it does: Defines integer constants for event type identification. Used by the encounter selection system to route event execution.

How it does that:

Constant Definition: Each macro represents a unique event ID:
Sqf

Apply
#define CIV_HELI 100
#define CIV_PLANE 200
#define CIV_CONVOY 300
#define POLICE 400
#define POLICE_SKIRMISH 500
#define POLICE_HOSTAGE 600
#define VEH_MOVE 700
#define VEH_PATROL 800
#define VEH_POSTAMBUSH 900
#define VEH_POSTAMBUSHCONVOY 1000
#define VEH_POSTBATTLE 1100
#define VEH_REPAIR 1200
#define VEH_MEDEVAC 1300
#define VEH_SLINGLOADTRANSPORT 1400
#define SKIRMISH_FRONTLINE 1500
#define SPECOPS_AIRDROP 1600
Where it leads:

Used by SCRT_fnc_encounter_selectAndExecuteEvent for event routing
All encounter functions reference these constants
No network implications (compile-time constants)
Synchronization: N/A
fn_encounter_civHeli.sqf
What it does: Creates a civilian helicopter flying over the map. Returns with waypoints for scenic flight. No combat involvement. This event adds civilian life to the world.

How it does that:

Player Selection: Randomly selects a rebel player as event center:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Faction Validation: Checks if civilian faction supports helicopters:
Sqf

Apply
private _civHeli = (A3A_faction_civ getOrDefault ["vehiclesCivHeli", []]);
if (_civHeli isEqualTo []) exitWith { ... reroll ... };
Position Calculation: Determines spawn position 1400-1600m from player and flight destination 2500m away:
Sqf

Apply
private _spawnPosition = [_originPosition, 1400, 1600, 0, 0, 1] call BIS_fnc_findSafePos;
private _finPosition = [_originPosition, 2500, (random 360)] call BIS_fnc_relPos;
Helicopter Spawn: Creates helicopter at calculated position with random altitude:
Sqf

Apply
private _civHeliData = [[(_spawnPosition select 0), (_spawnPosition select 1), 100 + random 200], 0, selectRandom (A3A_faction_civ get "vehiclesCivHeli"), civilian] call A3A_fnc_spawnVehicle;
private _heliVeh = _civHeliData select 0;
[_heliVeh, civilian] call A3A_fnc_AIVEHinit;
Optional Journalist: 30% chance to spawn press unit in cargo:
Sqf

Apply
if (random 100 < 30) then {
    private _civ = [(_civHeliData select 2), A3A_faction_civ get "unitPress", [0,0,0], [],0, "NONE"] call A3A_fnc_createUnit;
    _civ assignAsCargo _heliVeh;
    _civ moveInCargo _heliVeh;
};
Civilian Initialization: Applies civilian behavior to crew:
Sqf

Apply
{[_x] spawn A3A_fnc_civilianInitEH} forEach _heliCrew;
Waypoint Setup: Creates scenic flight pattern:
Two waypoints around origin position (300m radius)
Final waypoint to fly away
Sqf

Apply
{
    private _relativePosition = [_originPosition, 300, _x] call BIS_fnc_relPos;
    _relativePositions pushBack _relativePosition;
} forEach [0, 180];

{
    private _wp = _heliGroup addWaypoint [_x, _forEachIndex];
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE";
} forEach _relativePositions;

private _wp3 = _heliGroup addWaypoint [_finPosition, 3];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "NORMAL";
Altitude Setting: Sets flying height:
Sqf

Apply
_heliVeh flyInHeight (60 + (random 150));
Cleanup Wait: Waits for helicopter to complete waypoints or timeout:
Sqf

Apply
private _timeOut = time + 600;
waitUntil { sleep 5; (currentWaypoint _heliGroup == 3) || (time > _timeOut) || !(canMove _heliVeh) || !alive (driver _heliVeh)};
Despawn: Cleans up helicopter and crew:
Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_spawnVehicle for helicopter creation
Calls A3A_fnc_AIVEHinit for AI initialization
Calls A3A_fnc_civilianInitEH for civilian behavior
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with CIV_HELI constant
Global variables modified: isEventInProgress (set to false at end)
Network implications: None (spawns locally)
Synchronization: N/A
fn_encounter_civPlane.sqf
What it does: Creates a civilian airplane flying over the map. Similar to civilian helicopter but uses plane physics and higher altitude.

How it does that:

Player Selection: Randomly selects rebel player as center:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Faction Validation: Checks civilian faction for planes:
Sqf

Apply
private _civPlane = (A3A_faction_civ getOrDefault ["vehiclesCivPlanes", []]);
if (_civPlane isEqualTo []) exitWith { ... reroll ... };
Position Calculation: Spawn at 2400-2600m, final destination 3500m away:
Sqf

Apply
private _spawnPosition = [_originPosition, 2400, 2600, 0, 0, 1] call BIS_fnc_findSafePos;
private _finPosition = [_originPosition, 3500, (random 360)] call BIS_fnc_relPos;
Plane Spawn: Creates plane at altitude with velocity:
Sqf

Apply
private _height = 150 + (random 150);
_planeVeh flyInHeight _height;
_planeVeh setPosATL (_spawnPosition vectorAdd [0, 0, _height]);
_planeVeh setDir ([_planeVeh, _originPosition] call BIS_fnc_dirTo);
_planeVeh setVelocityModelSpace [0, 100, 0];
Scenic Waypoints: Creates flight path around origin:
Sqf

Apply
private _relativePositions = [];
{
    private _relativePosition = [_originPosition, 300, _x] call BIS_fnc_relPos;
    _relativePositions pushBack _relativePosition;
} forEach [0, 180];

{
    private _wp = _planeGroup addWaypoint [_x, _forEachIndex];
    _wp setWaypointSpeed "NORMAL";
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE";
} forEach _relativePositions;

private _wp3 = _planeGroup addWaypoint [_finPosition, 3];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "NORMAL";
Cleanup Wait: Waits for completion or timeout:
Sqf

Apply
private _timeOut = time + 600;
waitUntil { sleep 5; (currentWaypoint _planeGroup == 3) || (time > _timeOut) || !(canMove _planeVeh) || !alive (driver _planeVeh)};
Despawn: Cleans up resources:
Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_spawnVehicle for plane creation
Calls A3A_fnc_AIVEHinit for AI initialization
Calls A3A_fnc_civilianInitEH for civilian behavior
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with CIV_PLANE constant
Global variables modified: isEventInProgress
Network implications: None (local spawn)
Synchronization: N/A
fn_encounter_fleeingCivConvoy.sqf
What it does: Creates a civilian convoy traveling between two cities. Vehicles spawn on roads and travel along a path. Different from "Vehicle Move" which is enemy convoy.

How it does that:

Player Selection: Randomly selects rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Civilian Faction Check: Ensures civilian faction is appropriate:
Sqf

Apply
private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];
if (_lowCiv || _civNonHuman) exitWith { ... };
City Selection: Finds origin city and destination city:
Sqf

Apply
private _city = if (_originPosition isEqualType "") then {_originPosition} else {[citiesX, _originPosition] call BIS_fnc_nearestPosition};
private _anotherCity = selectRandom (citiesX select {_x != _city});
Road Finding: Spawns convoy near road:
Sqf

Apply
private _spawnPosition = [_originPosition, 600, distanceSPWN, 0, 0, 1] call BIS_fnc_findSafePos;
// ... road search logic
private _road = objNull;
private _radiusX = 5;
while {true} do {
    _road = _spawnPosition nearRoads _radiusX;
    if (count _road > 0) exitWith {};
    _radiusX = _radiusX + 5;
};
private _roadcon = roadsConnectedto (_road select 0);
private _dirveh = if (count _roadcon > 0) then {[_road select 0, _roadcon select 0] call BIS_fnc_dirTo} else {random 360};
private _roadPosition = getPos (_road select 0);
Path Calculation: Uses navGrid to find path between cities:
Sqf

Apply
private _posOrigin = navGrid select ([_city] call A3A_fnc_getMarkerNavPoint) select 0;
private _posDest = navGrid select ([_anothercity] call A3A_fnc_getMarkerNavPoint) select 0;
private _route = [_posOrigin, _posDest] call A3A_fnc_findPath;
_route = _route apply { _x select 0 };			// reduce to position array
if (_route isEqualTo []) then { _route = [_posOrigin, _posDest] };
Convoy Vehicle Spawn: Spawns vehicles along route:
Sqf

Apply
private _fnc_spawnConvoyVehicle = {
    params ["_vehType", "_markName"];
    // ... find location down route
    _pathState = [_route, [10, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute;
    // ... ensure no other vehicles within 10m
    private _veh = createVehicle [_vehType, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];
    private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);
    _veh setVectorDirAndUp [_pathState#1, _vecUp];
    _veh allowDamage false;
    private _group = [_side, _veh] call A3A_fnc_createVehicleCrew;
    {_x allowDamage false; _x disableAI "MINEDETECTION" } forEach (units _group);
    (driver _veh) stop true;
    deleteWaypoint [_group, 0];
    _veh;
};
Convoy Creation: Spawns 3-5 vehicles in convoy:
Sqf

Apply
for '_i' from round random 3 to 5 do {
    private _civVehicles = selectRandomWeighted ((_faction get "vehiclesCivCar") + (_faction get "vehiclesCivIndustrial") + (_faction get "vehiclesCivFuel"));
    private _vehObj = [_civVehicles, "civillian"] call _fnc_spawnConvoyVehicle;
    _convoyobj pushBack _vehObj;
    _convoy pushBack _civVehicles;
};
Convoy Travel: Starts vehicles on convoy travel:
Sqf

Apply
{
    [_x, _route, _convoyobj, 60, false] spawn A3A_fnc_vehicleConvoyTravel;
    sleep 2;
} forEach _convoyobj;
[_convoyobj select 0, localize "STR_marker_civ_convoy", true] spawn A3A_fnc_inmuneConvoy;
Group Setup: Configures groups and waypoints:
Sqf

Apply
{
    [_x, _side] call A3A_fnc_civVEHinit;
    _groups = group driver _x;
    private _wp = _groups addWaypoint [_posDest, 10];
    _wp setWaypointSpeed "NORMAL";
    _wp setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) leaveVehicle (assignedVehicle this)"];
    _wp setWaypointBehaviour "SAFE";
    _civGroups pushBack _groups;
    _vehicles pushBack _x;
} forEach _convoyobj;
Cleanup Wait: Waits for timeout (20 minutes):
Sqf

Apply
private _timeOut = time + 1200;
waitUntil {sleep 5; time > _timeOut};
Despawn: Cleans up all vehicles and groups:
Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _civGroups;
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_getMarkerNavPoint for navGrid positions
Calls A3A_fnc_findPath for route calculation
Calls A3A_fnc_findPosOnRoute for vehicle positioning
Calls A3A_fnc_vehicleConvoyTravel for convoy movement
Calls A3A_fnc_inmuneConvoy for anti-stuck protection
Calls A3A_fnc_civVEHinit for civilian vehicle init
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with CIV_CONVOY constant
Global variables modified: isEventInProgress
Network implications: Local spawn, convoy functions may have networked behavior
Synchronization: Pathfinding is server-side, convoy travel is per-vehicle
fn_encounter_frontlineSkirmish.sqf
What it does: Creates a skirmish between Invaders and Occupants near a frontline outpost. Spawns infantry and vehicles for both sides, with them fighting each other. Used to simulate active frontline combat.

How it does that:

Difficulty Check: Determines difficulty based on war tier:
Sqf

Apply
private _difficult = random 10 < tierWar;
private _difficult2 = random 10 < tierWar;
Player Selection: Random rebel player as center:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Frontline Selection: Finds frontline outposts near player:
Sqf

Apply
private _frontLine = (outposts + milbases + airportsX + resourcesX + factories + citiesX) select {([_x] call A3A_fnc_isFrontlineNoFIA && {sidesX getVariable [_x,sideUnknown] != teamPlayer})};
private _frontlineSitesNearPlayer = ((outposts + milbases + airportsX + resourcesX + factories + citiesX) select {(_x in _frontLine) && {((getMarkerPos _x) distance2D _player <= distanceSPWN*2.5) && {sidesX getVariable [_x,sideUnknown] != teamPlayer}}}) call BIS_fnc_arrayShuffle;
Outpost Selection: Selects random frontline outpost:
Sqf

Apply
private _FrontlineOutpost = selectRandom _frontlineSitesNearPlayer;
Side/Faction Setup: Invaders and Occupants as opposing sides:
Sqf

Apply
private _side = Occupants;
private _side2 = Invaders;
private _faction = Faction(_side);
private _faction2 = Faction(_side2);
private _FrontlineOutpostPosition = getMarkerPos _FrontlineOutpost;
Unit Group Selection: Chooses unit groups based on difficulty:
Sqf

Apply
private _specOpsArray = if (_difficult) then {selectRandom (_faction get "groupSpecOpsRandom")} else {selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)};
private _specOpsArray2 = if (_difficult2) then {selectRandom (_faction2 get "groupSpecOpsRandom")} else {selectRandom ([_faction2, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)};
Battle Position Calculation: Finds two positions for opposing forces:
Sqf

Apply
_skirmishposition = [_FrontlineOutpostPosition, distanceSPWN*0.7, distanceSPWN, 10, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
_skirmishposition2 = [_skirmishposition, 250, 350, 10, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
Group Spawn Function: Complex function to spawn forces:
Sqf

Apply
private _fnc_spawngroups = {
    params ["_amount","_amount2", "_vehiclesAmount" , "_vehiclesAmount2" , "_difficult" , "_difficult2"];
    // Spawn Side 1 (Occupants)
    for "_i" from 1 to _amount do {
        // ... find spawn position
        // ... spawn infantry group
        // ... spawn vehicle
        // ... spawn UAV if difficult
        // ... set patrol loops
    };
    // Spawn Side 2 (Invaders) - similar logic
};
Force Count Calculation: Determines number of groups and vehicles:
Sqf

Apply
private _amount = round random 3;
if (_amount == 0) then { _amount = 1; };
private _amount2 = round random 3;
if (_amount2 == 0) then { _amount2 = 1; };
private _vehiclesAmount = round random 3;
private _vehiclesAmount2 = round random 3;
Execute Spawn: Calls spawn function:
Sqf

Apply
[_amount, _amount2, _vehiclesAmount , _vehiclesAmount2 ,_difficult ,_difficult2] call _fnc_spawngroups;
Mutual Hostility: Sets combat mode for groups:
Sqf

Apply
{_x setCombatMode "YELLOW"} forEach _groups;
Reveal Enemies: Selects random enemies and reveals to opposing forces:
Sqf

Apply
// ... find enemies in area
// ... select 4 random enemies
// ... reveal to groups on both sides
{
    private _group = _x;
    { [_group, [_x, 2]] remoteExec ["reveal", leader _group] } forEach _spottedEnemies;
} forEach _InfGroups;
Cleanup Wait: Waits for timeout or when players leave area:
Sqf

Apply
private _timeOut = time + 1800;
waitUntil {time > _timeOut && (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_skirmishposition, distanceSPWN1, distanceSPWN1] isEqualTo []};
Despawn: Cleans up vehicles and groups:
Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _InfGroups;
{[_x] spawn A3A_fnc_groupDespawner} forEach _InfGroups2;
Where it leads:

Calls A3A_fnc_isFrontlineNoFIA for frontline check
Calls SCRT_fnc_unit_flattenTier for unit tiering
Calls A3A_fnc_spawnGroup for infantry groups
Calls A3A_fnc_spawnVehicle for vehicle creation
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_NATOinit for unit initialization
Calls A3A_fnc_patrolLoop for patrol behavior
Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with SKIRMISH_FRONTLINE constant
Global variables modified: isEventInProgress
Network implications: Group spawning and patrol loops are server-side
Synchronization: Multiple AI groups fighting, localized per AI
fn_encounter_gameEventLoop.sqf
What it does: Server-side loop that periodically checks for random game events. Uses a rolling chance system where probability increases if events don't trigger.

How it does that:

Server Check: Ensures only runs on server:
Sqf

Apply
if(!isServer) exitWith {};
Initialization: Sets initial state:
Sqf

Apply
isEventInProgress = false;
private _chance = 5;
private _isEventProcced = false;
Main Loop: Continuous execution:
Sqf

Apply
while {true} do {
    waitUntil {!isNil "A3A_activePlayerCount"};
    
    if (isEventInProgress || {A3A_activePlayerCount == 0}) then { 
        sleep 450; 
        continue;
    };
    
    _isEventProcced = (random 100) < _chance;
    
    if (_isEventProcced) then {
        Info_1("Event check successful, had the %1 chance.", str _chance);
        isEventInProgress = true;
        _chance = 0;
        [] call SCRT_fnc_encounter_selectAndExecuteEvent;
    } else {
        Info_1("Event hasn't rolled, current roll chance: %1.", str _chance);
        _chance = _chance + (random [1,2,4]);
    };
    
    sleep 450;
};
Where it leads:

Calls SCRT_fnc_encounter_selectAndExecuteEvent when event triggers
Called by server initialization
Global variables modified: isEventInProgress, A3A_activePlayerCount
Network implications: None (server-side only)
Synchronization: Event state synchronized via isEventInProgress (public variable in other functions)
fn_encounter_HeliSlingloadCargo.sqf
What it does: Creates enemy helicopter transporting a cargo container/pod. Helicopter flies to target, drops cargo with parachute, and provides enemy protection. Complex multi-phase event.

How it does that:

Difficulty & Player Setup:
Sqf

Apply
private _difficult = random 10 < tierWar;
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Target Selection: Finds enemy outpost or control point near player:
Sqf

Apply
private _potentialOutposts = (outposts + milbases + airportsX + resourcesX + factories) select {
    sidesX getVariable [_x, sideUnknown] != teamPlayer && {(getMarkerPos _x) distance2D _player < distanceSPWN*5}
};
private _potentialControl = ([controlsX, _player, true] call A3A_fnc_findIfNearAndHostile) select {!isOnRoad (getMarkerPos _x)};
Outpost Selection: Randomly chooses target (40% chance control point, else outpost):
Sqf

Apply
if ((random 100 <= 40) && !(_potentialControl isEqualTo [])) then {
    _outpost = selectRandom _potentialControl;
} else {
    _outpost = selectRandom _potentialOutposts;
};
Spawn Position: Finds spawn position for helicopter (must be friendly to side):
Sqf

Apply
private _potentialspawnPosition = (outposts + milbases + airportsX + resourcesX + factories) select {
    sidesX getVariable [_x, sideUnknown] != teamPlayer && _x != _outpost && sidesX getVariable [_x, sideUnknown] == _side && {(getMarkerPos _x) distance2D _player < distanceSPWN}
};
Helicopter Selection: Chooses transport helicopter:
Sqf

Apply
private _HeliClass = selectRandom (_faction get "vehiclesHelisTransport");
Cargo Type Selection: Finds slingload-capable cargo:
Sqf

Apply
private _ammoBoxType = _faction get "ammobox";
// ... logic to find slingload-compatible cargo
Test for CanSlingLoad: Creates test cargo to verify helicopter capacity:
Sqf

Apply
private _lootCrateTest = [_ammoBoxType, _actualspawnPosition, 20, 5, true] call A3A_fnc_safeVehicleSpawn;
if !(_heliVehicle canSlingLoad _lootCrateTest) exitwith { ... reroll ... };
deleteVehicle _lootCrateTest;
Cargo Selection Logic: Complex logic to find suitable cargo (POD or vehicle):
Sqf

Apply
private _csatPods = ["Land_Pod_Heli_Transport_04_covered_F", ...];
private _regPods = ["B_Slingload_01_Cargo_F", ...];
// Try up to 15 times to find slingloadable cargo
for "_i" from 1 to 15 do {
    private _lootcrateType = selectRandom ((...) + ... + _regPods);
    _lootCrate = _lootcrateType createVehicle _actualspawnPosition;
    deleteVehicle _lootCrate;
    if (_heliVehicle canSlingLoad _lootCrate) exitwith {
        deleteVehicle _lootCrate;
    };
};
Cargo Creation & Setup: Creates actual cargo with appropriate properties:
Sqf

Apply
if (_HeliClass canSlingLoad _lootcrateType) then {
    if (_lootcrateType in _regPods || _lootcrateType in _csatPods || _lootcrateType == _ammoBoxType) then {
        _lootCrate = [_lootcrateType, _actualspawnPosition, 40, 5, true] call A3A_fnc_safeVehicleSpawn;
        [_lootCrate, _side] call A3A_fnc_AIVEHinit;
        [_lootCrate] call A3A_fnc_fillLootCrate;
        [_lootCrate] call A3A_Logistics_fnc_addLoadAction;
    } else {
        // ... for cargo pods with infantry
        _heliInfGroup = [_actualspawnPosition, _side, _specOpsArray] call A3A_fnc_spawnGroup;
        // ... move infantry into pod
    };
} else {
    // ... fallback to ammobox
};
Helicopter Spawn & Sling: Spawns helicopter and attaches cargo:
Sqf

Apply
private _heliVehicleData = [_actualspawnPosition, 90, _HeliClass, _side] call A3A_fnc_spawnVehicle;
private _heliVehicle = _heliVehicleData select 0;
_heliVehicle setSlingLoad _lootCrate;
_lootCrate allowDamage false;
_heliVehicle setVelocity [20,0,0];
Flight Configuration: Sets altitude and speed limits:
Sqf

Apply
private _midHeight = [100, 150] select (A3A_climate isEqualTo "tropical");
_heliVehicle flyInHeight _midHeight;
_heliVehicle limitSpeed 150;
Waypoint Setup: Creates drop waypoint and return waypoint:
Sqf

Apply
private _wpDropPos = [_outpostPosition, 1, 50, 5, 0, 20, 0] call BIS_fnc_findSafePos;
private _wp = _heliGroup addWaypoint [_wpDropPos, 5];
_wp setWaypointSpeed "NORMAL";
_wp setWaypointType "UNHOOK";
_wp setWaypointBehaviour "CARELESS";

private _wp2 = _heliGroup addWaypoint [_actualspawnPosition, 0];
_wp2 setWaypointSpeed "NORMAL";
_wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) leaveVehicle (assignedVehicle this)"];
_wp2 setWaypointBehaviour "CARELESS";
Guard Force: Spawns enemy infantry to guard drop site (if control point):
Sqf

Apply
if (_outpost in _potentialControl) then {
    _SlingloadPositionActuall = [_outpostPosition, 40, 100, 10, 0, 5, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
    _InfGroup = [_SlingloadPositionActuall, _side, _specOpsArray] call A3A_fnc_spawnGroup;
    // ... patrol loop
};
Drop Detection: Waits for cargo to detach:
Sqf

Apply
waitUntil { sleep 2; getSlingLoad _heliVehicle  == objNull || getPos _lootCrate select 2 < 3};
Drop Markers: Creates smoke and chemlights at drop site:
Sqf

Apply
private _smokeGrenade = selectRandom allSmokeGrenades;
private _smoke = _smokeGrenade createVehicle (getPosATL _lootCrate);
_smoke attachTo [_lootCrate, [0,0,0]];

private _chemLight = "Chemlight_green";
private _light = _chemLight createVehicle (getPosATL _lootCrate);
_light attachTo [_lootCrate, [0,0,0]];
sleep 5;
detach _smoke;
detach _light;
Cargo Damage Enable: Allows cargo to be damaged after landing:
Sqf

Apply
_lootCrate allowDamage true;
Cleanup: Waits for completion or timeout:
Sqf

Apply
sleep 360;
// ... despawn all
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_findIfNearAndHostile for control points
Calls BIS_fnc_nearestPosition for nearest marker
Calls A3A_fnc_spawnVehicle for helicopter
Calls A3A_fnc_safeVehicleSpawn for cargo
Calls A3A_fnc_AIVEHinit for vehicle init
Calls A3A_fnc_fillLootCrate for cargo content
Calls A3A_Logistics_fnc_addLoadAction for logistics
Calls A3A_fnc_spawnGroup for guard force
Calls A3A_fnc_NATOinit for unit init
Calls A3A_fnc_patrolLoop for guard patrol
Calls A3A_fnc_inmuneConvoy for anti-stuck
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with VEH_SLINGLOADTRANSPORT constant
Global variables modified: isEventInProgress
Network implications: Helicopter and cargo are networked objects
Synchronization: Slingload attachment is synchronized, drop is local
fn_encounter_MedEvac.sqf
What it does: Creates medical evacuation scenario with crashed vehicle and medical helicopter. Enemy forces guard the crash site. Player can interact with scenario.

How it does that:

Player Selection: Random rebel player as center:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Road Finding: Finds road for crash site:
Sqf

Apply
private _spawnPosition = [_originPosition, 900, distanceSPWN, 0, 0] call BIS_fnc_findSafePos;
private _road = objNull;
private _radiusX = 5;
private _cityPositions = citiesX apply {getMarkerPos _x};
private _militaryPositions = (outposts + milbases + airportsX) apply {getMarkerPos _x};

while {true} do {
    _road = _spawnPosition nearRoads _radiusX;
    if (count _road > 0 && {_road findIf {
        private _roadPos = position _x;
        (_roadPos distance2D _originPosition > 500) &&
        ({_roadPos distance2D _x < 700} count _cityPositions == 0) &&
        ({_roadPos distance2D _x < 700} count _militaryPositions == 0)
    } != -1}) exitWith {};
    _radiusX = _radiusX + 5;
    if (_radiusX > 250) exitWith {_road = [];};
};
Marker Selection: Finds nearest enemy marker for side determination:
Sqf

Apply
private _marker = [((outposts + milbases + airportsX) select {sidesX getVariable [_x, sideUnknown] != teamPlayer}), _originPosition] call BIS_fnc_nearestPosition;
private _side = sidesX getVariable [_marker, Occupants];
private _faction = Faction(_side);
Crashed Vehicle Spawn: Creates damaged vehicle with specific damage pattern:
Sqf

Apply
private _crashedVehicle = createVehicle [_vehicleClass, [_roadPosition select 0, _roadPosition select 1, 1], [], 0, "CAN_COLLIDE"];
_crashedVehicle setDir _dirveh;
_crashedVehicle setDamage 0.7;

// Apply specific wheel damage
private _wheels = ["wheel_1_1_steering", ...];
for "_i" from 1 to (1 + floor random 3) do {
    private _wheel = selectRandom _wheels;
    _crashedVehicle setHit [_wheel, 1];
    _wheels = _wheels - [_wheel];
};

// Track damage
if (random 1 <= 0.7) then {
    _crashedVehicle setHit ["HitLTrack", 1];
} else {
    _crashedVehicle setHit ["HitRTrack", 1];
};

// Engine/Fuel damage
if (random 1 < 0.3) then {
    _crashedVehicle setHit ["HitEngine", 0.5 + random 0.5];
};
if (random 1 < 0.4) then {
    _crashedVehicle setHit ["HitFuel", 0.3 + random 0.7];
};

_crashedVehicle setFuel 0;
Crew Creation & Damage: Creates injured crew units:
Sqf

Apply
private _groupCrew = createGroup _side;
private _seatCount = [_vehicleClass, false] call BIS_fnc_crewCount;
for "_i" from 1 to _seatCount do {
    private _crew = [_groupCrew, _crewClass, _roadPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_crew] call A3A_fnc_NATOinit;
    _crew removeItems "FirstAidKit";
    _crew setDamage 0.9;
};
Crew Positioning: Moves crew out of vehicle and positions around it:
Sqf

Apply
{
    _x doMove _roadPosition;
    removeAllWeapons _x;
    _x leaveVehicle _crashedVehicle;
    doGetOut _x;
    unassignVehicle _x;
} forEach (units _groupCrew);

{
    _x setPos (_crashedVehicle getPos [3 + random 5, random 360]);
} forEach (units _groupCrew);
Medical Vehicle Spawn: Spawns medical vehicle at different road position:
Sqf

Apply
private _roadMedical = _roadPosition nearRoads _radiusX;
// ... find medical vehicle position
private _MedicalVehicleData = [_roadPositionMedical, _dirvehMedical, _MedicalVehicleClass, _side] call A3A_fnc_spawnVehicle;
private _MedicalVehicle = _MedicalVehicleData select 0;
Medical Group Setup: Creates civilian medical group:
Sqf

Apply
private _groupMedevac = createGroup civilian;
{
    removeAllWeapons _x;
    [_x] join _groupMedevac;
} forEach (units _groupMedical);
Medical Waypoint: Sets medical vehicle to go to crash site:
Sqf

Apply
private _wp = _groupMedevac addWaypoint [_roadPosition, 20];
_wp setWaypointCombatMode "SAFE";
if (_MedicalVehicle isKindOf "Air") then {
    _wp setWaypointType "GETOUT";
};
Drop Signals: Creates flare and smoke markers when medical vehicle gets close:
Sqf

Apply
if (!_signalsCreated && (_MedicalVehicle distance2D _crashedVehicle) < 200) then {
    private _flare = "F_40mm_Red" createVehicle _positionCrashedVehicle;
    private _smokeGrenade = "SmokeShellRed" createVehicle _positionCrashedVehicle;
    _signalsCreated = true;
};
Load Injured: Loads injured crew into medical vehicle:
Sqf

Apply
{
    _x assignAsCargo _MedicalVehicle;
    [_x] join _groupMedevac;
} forEach (units _groupCrewInjured);
_groupMedevac addVehicle _MedicalVehicle;
{
    [_x] orderGetIn true;
} forEach (units _groupMedevac);
Return to Base: Sends medical vehicle back to base:
Sqf

Apply
private _wp = _groupMedevac addWaypoint [position _MedicalVehicle, -1];
_wp setWaypointType "GETIN";

private _wp = _groupMedevac addWaypoint [(getMarkerPos _marker), 40];
_wp setWaypointCombatMode "SAFE";
_wp setWaypointType "GETOUT";
Cleanup Wait: Waits for timeout or when players leave:
Sqf

Apply
private _timeOut = time + 1200;
waitUntil { 
    sleep 5; 
    time > _timeOut || 
    {!alive _crashedVehicle || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D (position _crashedVehicle) < 1400} == -1
}}};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls BIS_fnc_nearestPosition for nearest marker
Calls A3A_fnc_spawnVehicle for crashed and medical vehicles
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_createUnit for crew creation
Calls A3A_fnc_NATOinit for unit initialization
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with VEH_MEDEVAC constant
Global variables modified: isEventInProgress
Network implications: Medical vehicle and signals are networked
Synchronization: Medical transport logic is per-unit
fn_encounter_police.sqf
What it does: Creates police vehicle patrol in a city. Police vehicle drives around city waypoints in a cycle. No combat, just police presence.

How it does that:

Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
City Selection: Finds neutral city near player:
Sqf

Apply
private _cities = citiesX select {sidesX getVariable [_x, sideUnknown] != teamPlayer && {spawner getVariable _x != 2} && {!(_x in destroyedSites)}};
private _city = [_cities, _player] call BIS_fnc_nearestPosition;
Road Finding: Finds road in city:
Sqf

Apply
private _road = objNull;
private _radiusX = 5;
while {true} do {
    _road = _cityPosition nearRoads _radiusX;
    if (count _road > 0) exitWith {};
    _radiusX = _radiusX + 5;
};
Police Vehicle Spawn: Spawns police vehicle:
Sqf

Apply
private _policeVehicleClass = selectRandom (A3A_faction_occ get "vehiclesPolice");
private _policeVehicleData = [(getPos (_road select 0)), _dirveh, _policeVehicleClass, Occupants] call A3A_fnc_spawnVehicle;
private _policeVehicle = _policeVehicleData select 0;
_policeVehicle limitSpeed 50;
[_policeVehicle, Occupants] call A3A_fnc_AIVEHinit;
[_policeVehicle, ["BeaconsStart", 1]] remoteExecCall ["animate", 0, _policeVehicle];
Crew Spawn: Spawns police crew:
Sqf

Apply
private _policeVehicleCrew = _policeVehicleData select 1;
{[_x] call A3A_fnc_NATOinit} forEach _policeVehicleCrew;
private _policeGroup = _policeVehicleData select 2;
Cargo Group: Spawns additional police in cargo:
Sqf

Apply
private _typeCargoGroup = [_policeVehicleClass, Occupants] call A3A_fnc_cargoSeats;
private _cargoGroup = [_cityPosition, Occupants, _typeCargoGroup, true,false] call A3A_fnc_spawnGroup;
{
    _x assignAsCargo _policeVehicle;
    _x moveInCargo _policeVehicle;
} forEach (units _cargoGroup);
(units _cargoGroup) join _policeGroup;
Patrol Waypoints: Creates waypoints around city:
Sqf

Apply
private _relativePositions = [];
{
    private _relativePosition = [_cityPosition, 200, _x] call BIS_fnc_relPos;
    _relativePositions pushBack _relativePosition;
} forEach [0, 90, 180];

{
    private _rndPosition = [_x, 0, 100, 0, 0, 0.75] call BIS_fnc_findSafePos;
    private _road = objNull;
    private _radiusX = 5;
    while {true} do {
        _road = _rndPosition nearRoads _radiusX;
        if (count _road > 0) exitWith {};
        _radiusX = _radiusX + 5;
    };
    private _roadPosition = getPos (_road select 0);
    private _wp = _policeGroup addWaypoint [_roadPosition, _forEachIndex];
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE";
} forEach _relativePositions;

private _wp1 = _policeGroup addWaypoint [_cityPosition, 3];
_wp1 setWaypointType "CYCLE";
Cleanup Wait: Waits for vehicle to be despawned or city deactivated:
Sqf

Apply
waitUntil { sleep 5; isNull _policeVehicle || {spawner getVariable _city == 2}};
Despawn: Cleans up:
Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls BIS_fnc_nearestPosition for nearest city
Calls A3A_fnc_spawnVehicle for police vehicle
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_cargoSeats for cargo group type
Calls A3A_fnc_spawnGroup for cargo group
Calls A3A_fnc_NATOinit for unit initialization
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with POLICE constant
Global variables modified: isEventInProgress
Network implications: Police vehicle and beacons are networked
Synchronization: Vehicle animation is remote executed
fn_encounter_policeHostages.sqf
What it does: Creates hostage situation with police vehicle and civilian hostages. Police officer stands guard, another patrols. Hostages are in captivity and can be freed.

How it does that:

Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
City Selection: Finds neutral city:
Sqf

Apply
private _cities = citiesX select {sidesX getVariable [_x, sideUnknown] != teamPlayer && {spawner getVariable _x != 2} && {!(_x in destroyedSites)}};
private _city = selectRandom _cities;
Road Finding: Finds road for scenario:
Sqf

Apply
private _road = objNull;
private _radius = 0;
while {isNull _road && _radius < 300} do {
    _road = selectRandom (_cityPos nearRoads _radius);
    _radius = _radius + 50;
};
Police Vehicle Spawn: Spawns police vehicle left of road:
Sqf

Apply
private _vehiclePos = _roadPos getPos [4, _roadDir - 90]; // 4m left from center
private _vehicleDir = _roadDir;
private _policeVeh = selectRandom (A3A_faction_occ get "vehiclesPolice");
private _vehData = [_vehiclePos, _vehicleDir, _policeVeh, Occupants] call A3A_fnc_spawnVehicle;
private _policeVehicle = _vehData#0;
[_policeVehicle, Occupants] call A3A_fnc_AIVEHinit;
[_policeVehicle, ["BeaconsStart", 1]] remoteExecCall ["animate", 0, _policeVehicle];
Hostage Creation: Creates hostages right of road in line:
Sqf

Apply
private _hostageArea = _roadPos getPos [5, _roadDir + 90]; // 5m right from road
private _hostageDir = _roadDir + 180; // Facing opposite direction
private _hostageGroup = createGroup [civilian, true];
private _hostageCount = 2 + floor random 3;

for "_i" from 0 to (_hostageCount - 1) do {
    private _pos = _hostageArea getPos [1.5 * _i, _hostageDir]; 
    private _hostage = [_hostageGroup, FactionGet(civ, "unitMan"), _pos, [], 0, "NONE"] call A3A_fnc_createUnit;
    _hostage disableAI "PATH";
    _hostage setCaptive true;
    _hostage switchMove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
    _hostage setDir _hostageDir;
};
Static Officer: Police officer standing guard in front of vehicle:
Sqf

Apply
private _frontPos = _policeVehicle getPos [3.5, _vehicleDir];
private _policeGroup = createGroup [Occupants, true];
private _staticCop = [_policeGroup, FactionGet(occ, "unitPoliceGrunt"), _frontPos, [], 0, "NONE"] call A3A_fnc_createUnit;
_staticCop setDir (_vehicleDir - 180);
doStop _staticCop;
Patrolling Officer: Officer that patrols around hostage area:
Sqf

Apply
private _patrolCop = [_policeGroup, FactionGet(occ, "unitPoliceGrunt"), _policeVehicle getPos [-3, _vehicleDir - 90], [], 0, "NONE"] call A3A_fnc_createUnit;

[_patrolCop, _hostageArea] spawn {
    params ["_cop", "_center"];
    while {alive _cop} do {
        private _angle = random 360;
        private _movePos = _center getPos [2 + random 0.5, _angle];
        _cop doMove _movePos;
        waitUntil {unitReady _cop || !alive _cop};
    };
};
Cleanup Wait: Waits for timeout or players to leave:
Sqf

Apply
private _timeOut = time + 1800;
waitUntil {
    sleep 10;
    time > _timeOut || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _roadPos < 1400} == -1}
};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_spawnVehicle for police vehicle
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_createUnit for hostages and police
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with POLICE_HOSTAGE constant
Global variables modified: isEventInProgress
Network implications: Police vehicle animation networked
Synchronization: Hostage states are local (captive)
fn_encounter_policeSkirmish.sqf
What it does: Creates police vs invader skirmish in neutral city. Police forces and invader forces fight each other. Player witnesses battle.

How it does that:

Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
City Selection: Finds neutral city:
Sqf

Apply
private _cities = citiesX select {sidesX getVariable [_x, sideUnknown] != teamPlayer && {spawner getVariable _x != 2} && {!(_x in destroyedSites)}};
private _city = selectRandom _cities;
Frontline Check: Ensures not near frontline:
Sqf

Apply
private _frontLine = (outposts + milbases + airportsX + resourcesX + factories + citiesX) select {([_x] call A3A_fnc_isFrontlineNoFIA && {sidesX getVariable [_x,sideUnknown] != teamPlayer})};
if (_frontLine isEqualTo []) exitWith { ... };
Police Force Spawn Function: Creates police forces:
Sqf

Apply
private _fnc_spawnPoliceForces = {
    params ["_side", "_basePos", "_vehicleTypes", "_unitGroupType"];
    private _numGroups = selectRandom [1, 2];
    for "_i" from 1 to _numGroups do {
        // ... road finding
        // ... vehicle spawn
        // ... cargo group
        // ... waypoint setup
    };
};
Invader Force Spawn Function: Creates invader forces:
Sqf

Apply
private _fnc_spawnForces = {
    params ["_side", "_basePos", "_vehicleTypes", "_unitGroupType"];
    // ... similar to police forces but different vehicles
};
Execute Spawning: Spawns both sides:
Sqf

Apply
// Spawn police forces (Occupants)
[Occupants, _cityPos getPos [100, random 360], (A3A_faction_occ get "vehiclesPolice"), (A3A_faction_occ get "groupPolice")] call _fnc_spawnPoliceForces;

// Spawn invader forces
[Invaders, _cityPos getPos [300, random 360 + 180], (A3A_faction_inv get "vehiclesMilitiaLightArmed") + ..., selectRandom ([A3A_faction_inv, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier)] call _fnc_spawnForces;
Set Hostility: Makes groups attack each other:
Sqf

Apply
{_x setCombatMode "YELLOW"} forEach _groups;
Cleanup Wait: Waits for timeout or players to leave:
Sqf

Apply
private _timeOut = time + 1200;
waitUntil {
    sleep 5;
    time > _timeOut || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _cityPos < 1400} == -1}
};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_isFrontlineNoFIA for frontline check
Calls SCRT_fnc_unit_flattenTier for unit tiering
Calls A3A_fnc_spawnVehicle for vehicles
Calls A3A_fnc_spawnGroup for groups
Calls A3A_fnc_AIVEHinit for vehicle init
Calls A3A_fnc_cargoSeats for cargo type
Calls A3A_fnc_NATOinit for unit init
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with POLICE_SKIRMISH constant
Global variables modified: isEventInProgress
Network implications: Multiple vehicle and group spawns
Synchronization: AI combat is server-side
fn_encounter_postAmbush.sqf
What it does: Creates post-ambush scene with single damaged vehicle and burning effects. No combat, just visual scene of recently destroyed vehicle.

How it does that:

Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Frontline Check: Ensures NOT near frontline:
Sqf

Apply
private _frontLine = (outposts + milbases + airportsX + resourcesX + factories + citiesX) select {([_x] call A3A_fnc_isFrontlineNoFIA && {sidesX getVariable [_x,sideUnknown] != teamPlayer})};
if !(_frontlineSitesNearPlayer isEqualTo []) exitWith { ... reroll ... };
Road Finding: Finds road for ambush site:
Sqf

Apply
private _spawnPosition = [_originPosition, 900, distanceSPWN, 0, 0] call BIS_fnc_findSafePos;
private _road = objNull;
private _radiusX = 5;
while {true} do {
    _road = _spawnPosition nearRoads _radiusX;
    if (count _road > 0 && {_road findIf {(position _x) distance2D _originPosition > 500} != -1}) exitWith {};
    _radiusX = _radiusX + 5;
};
Crater & Smoke Effects: Creates crater and smoke:
Sqf

Apply
private _crater = createVehicle ["CraterLong", _roadPosition, [], 0, "CAN_COLLIDE"];
_crater setDir _dirveh;
_crater setVectorUp surfaceNormal getPos _crater;
_others pushBack _crater;

private _smokeEffect = "test_EmptyObjectForSmoke" createVehicle (getPos _crater); 
_smokeEffect attachTo [_crater,[0,0,-1]];
_others pushBack _smokeEffect;
Damaged Vehicle Spawn: Creates heavily damaged vehicle:
Sqf

Apply
private _crashedVehicle = createVehicle [_vehicleClass, [_roadPosition select 0, _roadPosition select 1, 1], [], 0, "CAN_COLLIDE"];
_crashedVehicle setDir _dirveh;
_crashedVehicle setDamage 0.7;

// Specific wheel damage (1-4 wheels)
for "_i" from 1 to (1 + floor random 3) do {
    private _wheel = selectRandom _wheels;
    _crashedVehicle setHit [_wheel, 1];
    _wheels = _wheels - [_wheel];
};

// Track damage
if (random 1 <= 0.7) then {
    _crashedVehicle setHit ["HitLTrack", 1];
} else {
    _crashedVehicle setHit ["HitRTrack", 1];
};

// Engine/Fuel damage
if (random 1 < 0.3) then {
    _crashedVehicle setHit ["HitEngine", 0.5 + random 0.5];
};
if (random 1 < 0.4) then {
    _crashedVehicle setHit ["HitFuel", 0.3 + random 0.7];
};

_crashedVehicle setFuel 0;
Fire Effects: Creates multiple fire effects around vehicle:
Sqf

Apply
for "_i" from 0 to (random [3,5,6]) do {
    _firePosition = [
        _roadPosition, 
        2,
        25,
        2
    ] call BIS_fnc_findSafePos;

    [_firePosition, 5000] remoteExec ["SCRT_fnc_effect_createBurningDebrisEffect", 0, _crashedVehicle];

    private _fireEffectEmitter = "#particlesource" createVehicle _firePosition;
    [_fireEffectEmitter, "SmallDestructionFire"] remoteExec ["setParticleClass", 0, _fireEffectEmitter];

    private _lightEffectEmitter = "#lightpoint" createVehicle _firePosition; 
    [_lightEffectEmitter, 0.3] remoteExec ["setLightBrightness", 0, _lightEffectEmitter];
    [_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightAmbient", 0, _lightEffectEmitter];
    [_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightColor", 0, _lightEffectEmitter];

    _others append [_fireEffectEmitter, _lightEffectEmitter];
};
Crew Creation & Death: Creates crew that are mostly dead:
Sqf

Apply
private _groupCrew = createGroup _side;
for "_i" from 0 to (random [3,5,6]) do {
    private _crew = [_groupCrew, _crewClass, _roadPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_crew] call A3A_fnc_NATOinit;

    if ((random 100) > 20) then {
        sleep 0.5;
        _crew setDamage 1;
        private _dir = [_crew,_crashedVehicle] call BIS_fnc_dirTo;
        _crew setDir (_dir - 180);
    } else {
        _crew removeItems "FirstAidKit";
        sleep 0.1;
        _crew setDamage 0.8;
    };
};
Cleanup Wait: Waits for timeout or players to leave:
Sqf

Apply
private _timeOut = time + 1200;
waitUntil { 
    sleep 5; 
    time > _timeOut || 
    {!alive _crashedVehicle || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D (position _crashedVehicle) < 1400} == -1
}}};
Despawn: Cleans up all:
Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
{deleteVehicle _x} forEach _others;
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_isFrontlineNoFIA for frontline check
Calls A3A_fnc_spawnVehicle for crashed vehicle
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls SCRT_fnc_effect_createBurningDebrisEffect for fire effect
Calls A3A_fnc_createUnit for crew
Calls A3A_fnc_NATOinit for unit initialization
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with VEH_POSTAMBUSH constant
Global variables modified: isEventInProgress
Network implications: Fire effects are remote executed
Synchronization: Vehicle and effects are networked
fn_encounter_postAmbushConvoy.sqf
What it does: Creates post-ambush convoy scene with multiple damaged vehicles. Convoy vehicles are destroyed/crippled in a line on the road, with burning effects.

How it does that:

Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Frontline Check: Ensures NOT near frontline:
Sqf

Apply
private _frontLine = (outposts + milbases + airportsX + resourcesX + factories + citiesX) select {([_x] call A3A_fnc_isFrontlineNoFIA && {sidesX getVariable [_x,sideUnknown] != teamPlayer})};
if !(_frontlineSitesNearPlayer isEqualTo []) exitWith { ... reroll ... };
Road Segment Selection: Finds multiple connected road segments for convoy:
Sqf

Apply
private _mainRoad = (_road select {(position _x) distance2D _originPosition > 500}) select 0;
private _roadcon = roadsConnectedto _mainRoad;
private _dirveh = if (count _roadcon > 0) then {
    [_mainRoad, _roadcon select 0] call BIS_fnc_dirTo;
} else {
    random 360;
};

private _roadSegments = [_mainRoad];
private _connectedRoads = _roadcon;

while {count _roadSegments < 3 && count _connectedRoads > 0} do {
    private _nextSegment = _connectedRoads select 0;
    if (!(_nextSegment in _roadSegments)) then {
        _roadSegments pushBack _nextSegment;
        _connectedRoads = roadsConnectedto _nextSegment;
    };
};
Convoy Positioning: Calculates positions for each vehicle with spacing:
Sqf

Apply
private _convoyLength = 3;
private _convoySpacing = 15;

{
    private _roadSegment = _x;
    private _roadPosition = getPos _roadSegment;
    private _currentIndex = _forEachIndex;
    private _roadDir = _dirveh;

    if (_currentIndex > 0) then {
        // Offset along initial direction
        _roadPosition = _roadPosition getPos [_convoySpacing * _currentIndex, _roadDir];
        
        // Position correction and direction update
        private _nearestRoad = [_roadPosition, 50, []] call BIS_fnc_nearestRoad;
        if (!isNull _nearestRoad) then {
            _roadPosition = getPos _nearestRoad;
            private _newRoadcon = roadsConnectedto _nearestRoad;
            if (count _newRoadcon > 0) then {
                _roadDir = [_nearestRoad, _newRoadcon select 0] call BIS_fnc_dirTo;
            };
        };
        
        // Lateral offset
        private _latOffset = random [-3.5, 0, 3.5];
        _roadPosition = _roadPosition getPos [_latOffset, _roadDir + 90];
    };
    // ... vehicle creation
} forEach _roadSegments;
Vehicle Type Selection: Lead vehicle is special (supply truck), others are combat vehicles:
Sqf

Apply
if (_currentIndex == 1) then {
    private _specialVehicles = [];
    if (_isFia) then {
        _specialVehicles = (_faction get "vehiclesMilitiaTrucks") + (_faction get "vehiclesFuelTrucks") + (_faction get "vehiclesAmmoTrucks") + (_faction get "vehiclesMedical");
    } else {
        _specialVehicles = (_faction get "vehiclesAA") + (_faction get "vehiclesTrucks") + (_faction get "vehiclesFuelTrucks") + (_faction get "vehiclesAmmoTrucks") + (_faction get "vehiclesRepairTrucks");
    };
    _vehicleClass = selectRandom _specialVehicles;
} else {
    _vehicleClass = if (_isFia) then {
        selectRandom ((_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaAPCs"))
    } else {
        selectRandom ((_faction get "vehiclesAPCs") + (_faction get "vehiclesIFVs") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesLightArmed"))
    };
};
Vehicle Creation & Damage: Creates each vehicle with random damage:
Sqf

Apply
private _vehicle = createVehicle [
    _vehicleClass, 
    _roadPosition vectorAdd [0, 0, 1.5], 
    [], 
    0, 
    "CAN_COLLIDE"
];
_vehicle setDir _roadDir + 180;
// Random displacement and rotation
if (_currentIndex == 1) then {
    private _randomDirOffset = random [0, -25, 25];
    _vehicle setDir (_dir + _randomDirOffset);
    _vehicle setPos (_vehicle modelToWorld [random [-2.5,0,2.5], 0, 0]);
} else {
    private _randomDirOffset = random [-45, 45, 0];
    _vehicle setDir (_dir + _randomDirOffset);
    _vehicle setPos (_vehicle modelToWorld [random [-4.5,0,4.5], 0, 0]);
};
_vehicle setDamage random [0.3, 0.5, 0.7];
Specific Damage for Lead Vehicle: Lead vehicle gets more damage:
Sqf

Apply
if (_currentIndex == 0) then {
    // Wheeled vehicles damage
    private _wheels = [...];
    for "_i" from 1 to (1 + floor random 3) do {
        private _wheel = selectRandom _wheels;
        _vehicle setHit [_wheel, 1];
        _wheels = _wheels - [_wheel];
    };

    // Tracked vehicles damage
    if (random 1 <= 0.7) then {
        _vehicle setHit ["HitLTrack", 1];
    } else {
        _vehicle setHit ["HitRTrack", 1];
    };

    // Additional damage
    if (random 1 <= 0.3) then {
        _vehicle setHit ["HitEngine", 0.5 + random 0.5];
    };

    // Universal damage
    if (random 1 <= 0.4) then {
        _vehicle setHit ["HitFuel", 0.3 + random 0.7];
    };
};
Fire Effects for Lead Vehicle: Creates burning effects for lead vehicle:
Sqf

Apply
if (_currentIndex == 0) then {
    for "_k" from 0 to (random [3,5,6]) do {
        private _firePosition = [...];
        [_firePosition, 5000] remoteExec ["SCRT_fnc_effect_createBurningDebrisEffect", 0, _vehicle];
        // ... fire and light effects
    };
} else {
    // Random chance for secondary vehicles
    if (random 1 <= 0.5) then {
        for "_k" from 0 to (random [3,5,6]) do {
            // ... fire effects
        }
    }
};
Crew Creation: Creates crew with random survival:
Sqf

Apply
private _crewCount = switch (true) do {
    case (_vehicleClass in (...)): { 3 };
    case (_currentIndex == 1 && {_vehicleClass in (...)}): { 2 };
    default { [2,3,4] select _currentIndex };
};

for "_j" from 1 to _crewCount do {
    private _crew = [_groupCrew, _crewClass, _roadPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_crew] call A3A_fnc_NATOinit;
    
    if ((random 100) > (20 + 15 * _currentIndex)) then {
        _crew setDamage 1;
        private _dir = [_crew, _vehicle] call BIS_fnc_dirTo;
        _crew setDir (_dir - 180);
    } else {
        _crew removeItems "FirstAidKit";
        _crew setDamage (0.8 - 0.2 * _currentIndex);
        // ... patrol behavior
    };
};
Cleanup Wait: Waits for timeout or vehicles destroyed or players leave:
Sqf

Apply
private _timeOut = time + 1200;
waitUntil { 
    sleep 5; 
    time > _timeOut || 
    { {alive _x} count _vehicles == 0 || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D (getPos _crater) < 1400} == -1}
}};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_isFrontlineNoFIA for frontline check
Calls BIS_fnc_nearestRoad for road positioning
Calls SCRT_fnc_effect_createBurningDebrisEffect for fire effects
Calls A3A_fnc_spawnVehicle for vehicles
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_createUnit for crew
Calls A3A_fnc_NATOinit for unit initialization
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with VEH_POSTAMBUSHCONVOY constant
Global variables modified: isEventInProgress
Network implications: Fire effects are remote executed, multiple vehicles networked
Synchronization: Vehicle damage and crew states are networked
fn_encounter_postBattle.sqf
What it does: Creates large-scale post-battle scene with multiple damaged vehicles from both sides (winners and losers), burning effects, craters, and survivors wandering around. Complex multi-vehicle scene.

How it does that:

Side Selection: Randomly selects winning side:
Sqf

Apply
private _winningSide = selectRandom [Occupants, Invaders];
private _losingSide = if (_winningSide == Occupants) then {Invaders} else {Occupants};
Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Frontline Selection: Finds frontline outpost near player:
Sqf

Apply
private _frontLine = (outposts + milbases + airportsX + resourcesX + factories + citiesX) select { 
    [_x] call A3A_fnc_isFrontlineNoFIA && 
    {sidesX getVariable [_x,sideUnknown] != teamPlayer}
};
private _frontlineSitesNearPlayer = ((outposts + milbases + airportsX + resourcesX + factories + citiesX) select {
    (_x in _frontLine) && 
    ((getMarkerPos _x) distance2D _player < distanceSPWN*2.5) && 
    {sidesX getVariable [_x,sideUnknown] != teamPlayer}
}) call BIS_fnc_arrayShuffle;
Road Finding: Finds road for battle site:
Sqf

Apply
private _spawnPosition = [_originPosition, 900, distanceSPWN, 0, 0] call BIS_fnc_findSafePos;
private _road = objNull;
private _radiusX = 5;
private _cityPositions = citiesX apply {getMarkerPos _x};
private _militaryPositions = (outposts + milbases + airportsX) apply {getMarkerPos _x};

while {true} do {
    _road = _spawnPosition nearRoads _radiusX;
    if (count _road > 0 && {_road findIf {
        private _roadPos = position _x;
        (_roadPos distance2D _originPosition > 500) &&
        ({_roadPos distance2D _x < 700} count _cityPositions == 0) &&
        ({_roadPos distance2D _x < 700} count _militaryPositions == 0)
    } != -1}) exitWith {};
    _radiusX = _radiusX + 5;
    if (_radiusX > 150) exitWith {_road = [];};
};
Road Direction: Determines road direction:
Sqf

Apply
private _selectedRoad = _road select 0;
private _roadcon = roadsConnectedto _selectedRoad;
private _dirveh = if (count _roadcon > 0) then {
    [_selectedRoad, _roadcon select 0] call BIS_fnc_dirTo
} else {
    random 360
};
private _roadPosition = getPos _selectedRoad;
Background Fire Effects: Creates multiple fire effects around battle area:
Sqf

Apply
for "_i" from 0 to (random [10,12,14]) do {
    _firePosition2 = [
        _roadPosition, 
        1,
        60,
        1
    ] call BIS_fnc_findSafePos;

    [_firePosition2, 5000] remoteExec ["SCRT_fnc_effect_createBurningDebrisEffect", 0];

    private _fireEffectEmitter = "#particlesource" createVehicle _firePosition2;
    [_fireEffectEmitter, "SmallDestructionFire"] remoteExec ["setParticleClass", 0, _fireEffectEmitter];

    private _lightEffectEmitter = "#lightpoint" createVehicle _firePosition2; 
    [_lightEffectEmitter, 0.3] remoteExec ["setLightBrightness", 0, _lightEffectEmitter];
    [_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightAmbient", 0, _lightEffectEmitter];
    [_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightColor", 0, _lightEffectEmitter];

    _others append [_fireEffectEmitter, _lightEffectEmitter];    
};
Survivor Group: Creates group for survivors:
Sqf

Apply
private _surenderGroup = createGroup civilian;
Position Finding Function: Function to find valid spawn positions in ellipse around road:
Sqf

Apply
private _fnc_findPos = {
    params ["_center", "_min", "_max", ["_side", nil]];
    private _pos = [];
    private _majorAxis = _max;        // Major axis along the road
    private _minorAxis = _max * 0.3;  // Minor axis across the road
    private _attempts = 0;

    while {_attempts < 50} do {
        // Generate point in ellipse
        private _angle = random 360;
        private _radius = sqrt(random 1) * _majorAxis;
        private _x = _radius * cos(_angle);
        private _y = _radius * sin(_angle) * (_minorAxis / _majorAxis);

        // Rotate coordinates according to road direction
        private _rotX = _x * cos(_dirveh) - _y * sin(_dirveh);
        private _rotY = _x * sin(_dirveh) + _y * cos(_dirveh);

        // Offset to center
        _pos = [_center#0 + _rotX, _center#1 + _rotY, 0];

        // Check minimum distance from center
        if (_pos distance2D _center < _min) then {_attempts = _attempts + 1; continue;};

        // Determine side relative to road (win or lose)
        if (!isNil "_side") then {
            private _lateralOffset = _rotY;
            if (
                (_side == "win" && _lateralOffset < 0) || 
                (_side == "lose" && _lateralOffset >= 0)
            ) then {_attempts = _attempts + 1; continue;};
        };

        // Check collisions
        if (
            (_spawnedPositions findIf {_x distance2D _pos < 15} != -1) ||
            (count (nearestObjects [_pos, ["All"], 7]) > 0)
        ) then {_attempts = _attempts + 1; continue;};

        _spawnedPositions pushBack _pos;
        break;
    };

    if (_pos isEqualTo []) then {_pos = _center};
    _pos
};
Vehicle Count Calculation: Determines number of vehicles per side:
Sqf

Apply
private _vehicleCountWin = 1 + floor(random 2);
private _vehicleCountLose = _vehicleCountWin + (selectRandom [-1,0,1]);
_vehicleCountLose = (_vehicleCountLose max 1) min 3;
Vehicle Creation Function: Function to create vehicle with effects:
Sqf

Apply
private _fnc_createVehicleWithEffects = {
    params ["_pos", "_dir", "_class", "_side", "_isLoser", "_faction"];
    
    // Create crater with 40% probability
    private _crater = objNull;
    if (random 1 < 0.4 && {_craterPositions findIf {_x distance2D _pos < 10} == -1}) then {
        _crater = createVehicle ["CraterLong", _pos, [], 0, "CAN_COLLIDE"];
        _crater setDir _dir;
        _crater setVectorUp surfaceNormal _pos;
        _craterPositions pushBack _pos;
        _others pushBack _crater;
        private _smokeEffect = "test_EmptyObjectForSmoke" createVehicle (getPos _crater); 
        _smokeEffect attachTo [_crater,[0,0,-1]];
        _others pushBack _smokeEffect;
    };
    
    // Adjust position for vehicle
    private _vehiclePos = if (!isNull _crater) then {
        _crater getPos [random [0,1.5,3], random 360]
    } else {
        _pos
    };
    
    // Create vehicle
    private _vehicle = createVehicle [_class, [_vehiclePos select 0, _vehiclePos select 1, 1.5], [], 0, "CAN_COLLIDE"];
    _vehicle setDir _dir;
    
    // General damage
    _vehicle setDamage random [0.5, 0.7, 0.9];
    _vehicle setFuel 0;
    
    // Specific damage
    if (random 1 <= 0.7) then {
        // Wheel damage
        private _wheels = [...];
        for "_i" from 1 to (1 + floor random 3) do {
            private _wheel = selectRandom _wheels;
            _vehicle setHit [_wheel, 1];
            _wheels = _wheels - [_wheel];
        };

        // Track damage
        if (random 1 <= 0.7) then {
            _vehicle setHit ["HitLTrack", 1];
        } else {
            _vehicle setHit ["HitRTrack", 1];
        };

        // Additional damage
        if (random 1 <= 0.3) then {
            _vehicle setHit ["HitEngine", 0.5 + random 0.5];
        };

        // Universal damage
        if (random 1 <= 0.4) then {
            _vehicle setHit ["HitFuel", 0.3 + random 0.7];
        };
    };
    
    // Check for heavy vehicles
    private _isHeavy = _class in (
        (_faction get "vehiclesAPCs") + 
        (_faction get "vehiclesIFVs") + 
        (_faction get "vehiclesLightTanks") + 
        (_faction get "vehiclesMilitiaAPCs")
    );
    
    // Flip for non-heavy vehicles
    if (!_isHeavy && {random 1 > 0.3}) then {
        _vehicle setVectorUp [random 0.3, random 0.3, 1];
        _vehicle setPosATL (getPosATL _vehicle vectorAdd [0,0,0.5]);
    };
    
    // Initialization and effects
    [_vehicle, _side] call A3A_fnc_AIVEHinit;
    if (random 1 <= 0.3) then {
        [_vehiclePos, 5000] remoteExec ["SCRT_fnc_effect_createBurningDebrisEffect", 0];
    };
    
    _vehicle;
};
Crew Creation Function: Creates crew with random survival and animations:
Sqf

Apply
private _fnc_createCrew = {
    params ["_vehicle", "_class", "_side", "_faction", "_isLoser"];
    
    private _crewGroup = createGroup _side;
    private _crewType = if (_class in (...)) then {
        _faction get "unitCrew"
    } else {
        [(_faction get "unitRifle")] call SCRT_fnc_unit_getTiered
    };

    private _spawnPos = getPos _vehicle getPos [random 5, random 360];
    private _unit = [_crewGroup, _crewType, _spawnPos, [], 5, "NONE"] call A3A_fnc_createUnit;
    
    if (random 1 > 0.5) then {
        _unit setDamage random [0.3, 0.5, 0.7];
        private _anim = selectRandom [
            "Acts_CivilInjuredGeneral_1",
            "Acts_CivilShocked_1",
            "Acts_CivilShocked_2",
            "Acts_SittingWounded_loop"
        ];
        [_unit, _anim] remoteExec ["switchMove", 0];
        _unit disableAI "PATH";
        _unit stop true;
        _unit removeItems "FirstAidKit";
        // ... panic sound loop
    } else {
        _unit setDamage 1;
        _unit setPosATL [_spawnPos#0 + random 3, _spawnPos#1 + random 3, 0];
    };
    [_unit] call A3A_fnc_NATOinit;
    [_unit] joinSilent _surenderGroup;
    _groups pushBack _crewGroup;
};
Spawn Winning Side Vehicles: Loop to spawn winner vehicles:
Sqf

Apply
for "_i" from 1 to _vehicleCountWin do {
    private _spawnPos = [_roadPosition, 10, 60, "win"] call _fnc_findPos;
    private _vehicleClass = if (_isFIA) then {
        selectRandom ((_winFaction get "vehiclesMilitiaLightArmed") + (_winFaction get "vehiclesMilitiaAPCs"))
    } else {
        selectRandom ((_winFaction get "vehiclesAPCs") + 
                    (_winFaction get "vehiclesIFVs") +
                    (_winFaction get "vehiclesLightTanks") + 
                    (_winFaction get "vehiclesLightArmed"))
    };

    private _baseDir = _spawnPos getDir _roadPosition;
    private _vehicleDir = _baseDir + (random [ -15, 0, 15 ]);
    
    private _vehicle = [
        _spawnPos,
        _vehicleDir,
        _vehicleClass,
        _winningSide,
        false,
        _winFaction
    ] call _fnc_createVehicleWithEffects;

    for "_j" from 1 to (2 + floor(random 3)) do {
        [_vehicle, _vehicleClass, _winningSide, _winFaction, false] call _fnc_createCrew;
    };
    _vehicles pushBack _vehicle;
};
Spawn Losing Side Vehicles: Loop to spawn loser vehicles:
Sqf

Apply
for "_i" from 1 to _vehicleCountLose do {
    private _spawnPos = [_roadPosition, 5, 60, "lose"] call _fnc_findPos;
    private _vehicleClass = if (_isFIA) then {
        selectRandom ((_loseFaction get "vehiclesMilitiaLightArmed") + (_loseFaction get "vehiclesMilitiaAPCs"))
    } else {
        selectRandom ((_loseFaction get "vehiclesAPCs") + 
                    (_loseFaction get "vehiclesIFVs") + 
                    (_loseFaction get "vehiclesLightArmed") +
                    (_loseFaction get "vehiclesLightTanks"))
    };

    private _baseDir = _spawnPos getDir _roadPosition;
    private _vehicleDir = _baseDir + (random [ -15, 0, 15 ]);
    
    private _vehicle = [
        _spawnPos,
        _vehicleDir,
        _vehicleClass,
        _losingSide,
        true,
        _loseFaction
    ] call _fnc_createVehicleWithEffects;

    for "_j" from 1 to (2 + floor(random 3)) do {
        [_vehicle, _vehicleClass, _losingSide, _loseFaction, true] call _fnc_createCrew;
    };

    _vehicles pushBack _vehicle;
};
Survivor Spawning: Spawns additional survivors across area:
Sqf

Apply
private _survivorGroup = createGroup _winningSide;
for "_i" from 1 to (2 + floor(random 4)) do {
    private _spawnPos = [_roadPosition, 10, 45] call _fnc_findPos;
    [_survivorGroup, _winFaction, _spawnPos, _roadPosition] call _spawnSurvivor;
};
_groups pushBack _survivorGroup;
Cleanup Wait: Waits for timeout or players leave:
Sqf

Apply
private _timeOut = time + 1200;
waitUntil { 
    sleep 5; 
    time > _timeOut || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _roadPosition < 1400} == -1}
};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_isFrontlineNoFIA for frontline check
Calls SCRT_fnc_unit_flattenTier for unit tiering
Calls SCRT_fnc_effect_createBurningDebrisEffect for fire effects
Calls A3A_fnc_spawnVehicle (via createVehicle) for vehicles
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_createUnit for crew
Calls A3A_fnc_NATOinit for unit initialization
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with VEH_POSTBATTLE constant
Global variables modified: isEventInProgress
Network implications: Multiple fire effects remote executed, many vehicles networked
Synchronization: Vehicle positions and damage are networked
fn_encounter_repair.sqf
What it does: Creates repair scenario with damaged vehicle and repair truck. Repair truck drives to crash site, repairs vehicle, and loads crew for return to base.

How it does that:

Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Frontline Check: Ensures NOT near frontline:
Sqf

Apply
private _frontLine = (outposts + milbases + airportsX + resourcesX + factories + citiesX) select {([_x] call A3A_fnc_isFrontlineNoFIA && {sidesX getVariable [_x,sideUnknown] != teamPlayer})};
if !(_frontlineSitesNearPlayer isEqualTo []) exitWith { ... reroll ... };
Road Finding: Finds road for crash site:
Sqf

Apply
private _spawnPosition = [_originPosition, 900, distanceSPWN, 0, 0] call BIS_fnc_findSafePos;
private _road = objNull;
private _radiusX = 5;
while {true} do {
    _road = _spawnPosition nearRoads _radiusX;
    if (count _road > 0 && {_road findIf {(position _x) distance2D _originPosition > 500} != -1}) exitWith {};
    _radiusX = _radiusX + 5;
};
Marker Selection: Finds nearest enemy marker for side:
Sqf

Apply
private _marker = [(markersX select {sidesX getVariable [_x, sideUnknown] != teamPlayer}), _originPosition] call BIS_fnc_nearestPosition;
private _side = sidesX getVariable [_marker, Occupants];
private _faction = Faction(_side);
Damaged Vehicle Spawn: Creates heavily damaged vehicle:
Sqf

Apply
private _crashedVehicle = createVehicle [_vehicleClass, [_roadPosition select 0, _roadPosition select 1, 1], [], 0, "CAN_COLLIDE"];
_crashedVehicle setDir _dirveh;
_crashedVehicle setDamage 0.7;

// Wheel damage
private _wheels = [...];
for "_i" from 1 to (1 + floor random 3) do {
    private _wheel = selectRandom _wheels;
    _crashedVehicle setHit [_wheel, 1];
    _wheels = _wheels - [_wheel];
};

// Track damage
if (random 1 <= 0.7) then {
    _crashedVehicle setHit ["HitLTrack", 1];
} else {
    _crashedVehicle setHit ["HitRTrack", 1];
};

// Additional damage
if (random 1 < 0.3) then {
    _crashedVehicle setHit ["HitEngine", 0.5 + random 0.5];
};

// Universal damage
if (random 1 < 0.4) then {
    _crashedVehicle setHit ["HitFuel", 0.3 + random 0.7];
};

_crashedVehicle setFuel 0;
[_crashedVehicle, _side] call A3A_fnc_AIVEHinit;
_crashedVehicle setPos (_crashedVehicle modelToWorld [random [1,2,4.5], 0, 0]);
Crew Creation: Creates damaged crew:
Sqf

Apply
private _groupCrew = createGroup _side;
private _seatCount = [_vehicleClass, false] call BIS_fnc_crewCount;
for "_i" from 1 to _seatCount do {
    private _crew = [_groupCrew, _crewClass, _roadPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_crew] call A3A_fnc_NATOinit;
};
Driver Positioning: Positions driver at vehicle side for repair:
Sqf

Apply
private _driver = (units _groupCrew) select 0;
private _position = getPos _crashedVehicle;
private _direction = getDir _crashedVehicle;
_driver setPos [_position select 0, (_position select 1) - 2.5, 0];
_driver setDir (_direction + 90);
Repair Truck Road Finding: Finds road for repair truck:
Sqf

Apply
private _roadRepair = _roadPosition nearRoads _radiusX;
if (count _roadRepair > 0 && {_roadRepair findIf {(position _x) distance2D _originPosition > 500 && (position _x) distance2D _roadPosition > 500} != -1}) exitWith {};
Repair Truck Spawn: Spawns repair truck:
Sqf

Apply
private _repairVehicleData = [_roadPositionRepair, _dirvehRepair, _repairVehicleClass, _side] call A3A_fnc_spawnVehicle;
private _repairVehicle = _repairVehicleData select 0;
[_repairVehicle, _side] call A3A_fnc_AIVEHinit;
_repairVehicle setDir _dirvehRepair;
Repair Waypoint: Sends repair truck to crash site:
Sqf

Apply
private _wp = _groupRepair addWaypoint [_roadPosition, 2];
_wp setWaypointCombatMode "SAFE";
private _timeOut = time + 1200;
waitUntil { 
    sleep 3; 
    time > _timeOut || 
    {!alive _crashedVehicle || 
    {
        (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D (position _crashedVehicle) < 1400} == -1
    } || 
    {
        (_repairVehicle distance2D _crashedVehicle) < 15
    }}
};
Repair Execution: Repairs vehicle:
Sqf

Apply
sleep 60;
_crashedVehicle setDamage 0;
_crashedVehicle setFuel 0.4;
Crew Loading: Loads crew into repaired vehicle:
Sqf

Apply
sleep 2;
_groupCrew addVehicle _crashedVehicle;
private _count = 0;
{
    if (_count > 0) then {
        [_x] orderGetIn true;
    } else {
        _x assignAsDriver _crashedVehicle;
        [_x] orderGetIn true;
        _count = _count + 1;
    };
} forEach (units _groupCrew);
Return to Base: Both vehicles return to base:
Sqf

Apply
sleep 10;
private _nearestBase = [(outposts + milbases + airportsX + factories) select {sidesX getVariable [_x, sideUnknown] == _side}, _marker] call BIS_fnc_nearestPosition;
private _targetMarker = if (isNil "_nearestBase" || {_nearestBase == ""}) then {_marker} else {_nearestBase};

private _wp = _groupRepair addWaypoint [(getMarkerPos _targetMarker), 40];
_wp setWaypointCombatMode "SAFE";
private _wp2 = _groupCrew addWaypoint [(getMarkerPos _targetMarker), 40];
_wp2 setWaypointCombatMode "SAFE";
Cleanup Wait: Waits for timeout or vehicles reach base:
Sqf

Apply
waitUntil { 
    sleep 5; 
    time > _timeOut || 
    {!alive _crashedVehicle || 
    {
        (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D (position _crashedVehicle) < 1400} == -1
    }|| 
    {
        (_repairVehicle distance2D (getMarkerPos _targetMarker)) < 100
    }}
};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_isFrontlineNoFIA for frontline check
Calls BIS_fnc_nearestPosition for nearest marker
Calls A3A_fnc_spawnVehicle for crashed and repair vehicles
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_createUnit for crew
Calls A3A_fnc_NATOinit for unit initialization
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with VEH_REPAIR constant
Global variables modified: isEventInProgress
Network implications: Vehicle positions and repairs are networked
Synchronization: Repair and crew loading are networked actions
fn_encounter_selectAndExecuteEvent.sqf
What it does: Selects a random encounter event and schedules it for execution. Can exclude specific event for rerolling. Routes to appropriate encounter function based on constant.

How it does that:

Parameter Handling: Accepts exclude ID parameter:
Sqf

Apply
params [["_excludeId", -1]];
Event List: Defines all available events:
Sqf

Apply
private _events = [
	[CIV_HELI, CIV_PLANE, CIV_CONVOY, POLICE, POLICE_SKIRMISH, POLICE_HOSTAGE, VEH_MOVE, VEH_PATROL, VEH_POSTAMBUSH, VEH_POSTAMBUSHCONVOY, VEH_POSTBATTLE, VEH_REPAIR, VEH_MEDEVAC, VEH_SLINGLOADTRANSPORT, SKIRMISH_FRONTLINE, SPECOPS_AIRDROP],
	([CIV_HELI, CIV_PLANE, CIV_CONVOY, POLICE, POLICE_SKIRMISH, POLICE_HOSTAGE, VEH_MOVE, VEH_PATROL, VEH_POSTAMBUSH, VEH_POSTAMBUSHCONVOY, VEH_POSTBATTLE, VEH_REPAIR, VEH_MEDEVAC, VEH_SLINGLOADTRANSPORT, SKIRMISH_FRONTLINE, SPECOPS_AIRDROP] select { _x != _excludeId })
] select (_excludeId isNotEqualTo 0);
Weight Calculation: Equal weight for all events:
Sqf

Apply
private _weight = 1 / (count _events); 
private _eventsWithWeights = flatten (_events apply { [_x, _weight] });
Random Selection: Selects event with weighted random:
Sqf

Apply
private _eventType = selectRandomWeighted _eventsWithWeights;
Event Routing: Switch statement to call appropriate function:
Sqf

Apply
switch (_eventType) do {
	case (CIV_HELI): {
		[[], "SCRT_fnc_encounter_civHeli"] call A3A_fnc_scheduler;
	};
	case (CIV_PLANE): {
		[[], "SCRT_fnc_encounter_civPlane"] call A3A_fnc_scheduler;
	};
    // ... all other cases
};
Where it leads:

Calls A3A_fnc_scheduler to execute events on separate thread
Called by SCRT_fnc_encounter_gameEventLoop or for rerolls
Global variables modified: None
Network implications: Scheduler executes on server
Synchronization: Event functions are scheduled and may spawn networked objects
fn_encounter_SpecOpsAirdrop.sqf
What it does: Creates special ops airdrop scenario. First, spec ops group is on ground at target location. When players arrive, a plane drops supply crates. Spec ops guard the drop site.

How it does that:

Difficulty & Player Setup:
Sqf

Apply
private _difficult = random 10 < tierWar;
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Control Point Selection: Finds control point (not outpost) near player:
Sqf

Apply
private _controlsX = ([controlsX, _player, true] call A3A_fnc_findIfNearAndHostile) select {
    private _markerPos = getMarkerPos _x;
    private _distance = _markerPos vectorDistance _originPosition;
    private _isOnRoad = isOnRoad _markerPos;
    !_isOnRoad && (_distance > 600) && (_distance <= 1300);
};
Spec Ops Group Spawn: Spawns spec ops group on ground:
Sqf

Apply
private _specOpsArray = if (_difficult) then {selectRandom (_faction get "groupSpecOpsRandom")} else {selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)}; 
private _InfGroup = [_AirDropPositionActuall, _side, _specOpsArray] call A3A_fnc_spawnGroup;
{[_x] call A3A_fnc_NATOinit} forEach units _InfGroup;
_InfGroup setBehaviourStrong "SAFE";
private _wp = _InfGroup addWaypoint [_AirDropPosition, 50];
_wp setWaypointType "SAD";
[_InfGroup, "Patrol_Attack", 0, 50, 100, true, _AirDropPosition, true] call A3A_fnc_patrolLoop;
Wait for Players: Waits for players to approach:
Sqf

Apply
private _timeOut = time + 1200;
waitUntil { 
    sleep 2; 
    time > _timeOut || 
    {
        (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _AirDropPosition < 1400} == -1
    } || 
    {
        (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _AirDropPosition > 800} == -1
    }
};
Smoke Drop: Drops smoke marker for plane:
Sqf

Apply
private _smokeGrenade = "SmokeShellRed" createVehicle _AirDropPosition;
Plane Spawn: Spawns transport plane:
Sqf

Apply
private _initialPlanePosition = [
    _AirDropPosition,
    2000,
    3000,
    0,
    0,
    1,
    0,
    [],
    [_AirDropPosition, _AirDropPosition]
] call BIS_fnc_findSafePos;
private _height = random [200, 300, 400];
private _direction = [_initialPlanePosition, _AirDropPosition] call BIS_fnc_DirTo;

private _planeType = selectRandom (_faction get "vehiclesPlanesTransport");
private _planeData = [[_initialPlanePosition select 0, _initialPlanePosition select 1, _height], _direction, _planeType, _side] call A3A_fnc_spawnVehicle;
private _planeVeh = _planeData select 0;
_planeVeh setPosATL [getPosATL _planeVeh select 0, getPosATL _planeVeh select 1, _height];
_planeVeh disableAI "TARGET";
_planeVeh disableAI "AUTOTARGET";
_planeVeh flyInHeight 80;

private _minAltASL = ATLToASL [_AirDropPosition select 0, _AirDropPosition select 1, 0];
_planeVeh flyInHeightASL [(_minAltASL select 2) +100, (_minAltASL select 2) +100, (_minAltASL select 2) +100];
Plane Waypoint: Sets plane to fly to drop position:
Sqf

Apply
private _wp1 = group _planeVeh addWaypoint [_dropPosition, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointBehaviour "CARELESS";
Wait for Plane Arrival: Waits for plane to get close:
Sqf

Apply
waitUntil {
    sleep 1;
    (!(isNull _planeVeh) && {_planeVeh inArea [_AirDropPosition, 900, 900, 0, false]}) || time > _timeOut || !(alive _planeVeh) || (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _AirDropPosition < 1400} == -1
};
Plane Speed & Altitude: Reduces altitude for drop:
Sqf

Apply
_planeVeh limitSpeed 200;
_planeVeh flyInHeight 60;
Wait for Drop Position: Waits for plane over drop site:
Sqf

Apply
waitUntil {
    sleep 1;
    (!(isNull _planeVeh) && {_planeVeh inArea [_AirDropPosition, 100, 100, 0, false]}) || time > _timeOut || !(alive _planeVeh) || (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _AirDropPosition < 1400} == -1
};
Cargo Drop: Drops two crates:
Sqf

Apply
if(alive _planeVeh) then {
    // First crate
    private _boxType = selectRandom [
        "CargoNet_01_barrels_F",
        "Land_FoodSacks_01_cargo_brown_F", (selectRandom (_faction get "vehiclesLightArmed"))
    ];
    _planeVeh allowDamage false;
    sleep 1;
    private _box1 = [_boxType,position _planeVeh] call SCRT_fnc_common_airdropCargo;
    _box1 enableRopeAttach true;
    _box1 allowDamage false;
    [_box1] call A3A_Logistics_fnc_addLoadAction;
    [_box1, _side] call A3A_fnc_AIVEHinit;

    driver _planeVeh setCaptive false;
    _planeVeh allowDamage true;

    sleep 1;

    // Second crate
    private _box2Class = [ 
        (["CargoNet_01_barrels_F", "Land_FoodSacks_01_cargo_brown_F"] select (random 100 < 50)),
        _faction get "ammobox"
    ] select _difficult;

    private _box2 = [_box2Class,position _planeVeh] call SCRT_fnc_common_airdropCargo;
    _box2 enableRopeAttach true;
    _box2 allowDamage false;
    [_box2] call A3A_Logistics_fnc_addLoadAction;
    [_box2, _side] call A3A_fnc_AIVEHinit;

    if (_box2Class isEqualTo (_faction get "ammobox")) then {
        [_box2] spawn A3A_fnc_fillLootCrate;
    };

    _vehicles append [_box1, _box2];

    if(sunOrMoon < 1) then {
        [_box1, [0, 0, 1]] remoteExec ["SCRT_fnc_common_attachLightSource", 0, _box1];
        [_box2, [0, 0, 1]] remoteExec ["SCRT_fnc_common_attachLightSource", 0, _box2];
    };

    sleep 5;
    private _finalPosition = [_AirDropPosition, 3000, random 360] call BIS_fnc_relPos;
    private _wp2 = group _planeVeh addWaypoint [_finalPosition, 200];
    _wp2 setWaypointSpeed "FULL";
    _wp2 setWaypointType "MOVE";
    _wp2 setWaypointStatements ["true","deleteVehicle _planeVeh"];

    _planeVeh limitSpeed 1000;
    _planeVeh flyInHeight 200;

    waitUntil { sleep 2; getPos _box1 select 2 < 3 && getPos _box2 select 2 < 3};
    _box1 allowDamage true;
    _box2 allowDamage true;

    private _chemLight = "Chemlight_green";
    private _light1 = _chemLight createVehicle (getPosATL _box1);
    _light1 attachTo [_box1, [0,0,0]];
    private _light2 = _chemLight createVehicle (getPosATL _box2);
    _light2 attachTo [_box2, [0,0,0]];

    _others append [_light1, _light2];

    detach _light1;
    detach _light2;
};
Cleanup Wait: Waits for timeout or players leave:
Sqf

Apply
waitUntil { 
    sleep 5; 
    time > _timeOut ||
    {
        (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _AirDropPosition < 1400} == -1
    }
};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_findIfNearAndHostile for control points
Calls SCRT_fnc_unit_flattenTier for unit tiering
Calls A3A_fnc_spawnGroup for spec ops group
Calls A3A_fnc_patrolLoop for patrol behavior
Calls SCRT_fnc_common_airdropCargo for crate drop
Calls A3A_Logistics_fnc_addLoadAction for logistics
Calls A3A_fnc_AIVEHinit for crate initialization
Calls A3A_fnc_fillLootCrate for crate content
Calls SCRT_fnc_common_attachLightSource for night lights
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with SPECOPS_AIRDROP constant
Global variables modified: isEventInProgress
Network implications: Plane and crates are networked, lights are local
Synchronization: Airdrop is networked, crates are global
fn_encounter_vehicleMove.sqf
What it does: Creates enemy supply convoy traveling from outpost to origin. Vehicle (supply truck) drives along road to destination. Different from civilian convoy.

How it does that:

Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Outpost Selection: Finds enemy outpost near player:
Sqf

Apply
private _potentialOutposts = (outposts + milbases + airportsX + resourcesX + factories) select {
    sidesX getVariable [_x, sideUnknown] != teamPlayer && {(getMarkerPos _x) distance2D _player < distanceSPWN}
};
private _outpost = selectRandom _potentialOutposts;
Road Finding: Finds road near origin:
Sqf

Apply
private _spawnPosition = [_originPosition, 600, distanceSPWN, 0, 0, 1] call BIS_fnc_findSafePos;
private _road = objNull;
private _radiusX = 5;
while {true} do {
    _road = _spawnPosition nearRoads _radiusX;
    if (count _road > 0) exitWith {};
    _radiusX = _radiusX + 5;
};
Truck Selection: Chooses supply truck type:
Sqf

Apply
private _truckClass = selectRandom ((_faction get "vehiclesAmmoTrucks") + (_faction get "vehiclesRepairTrucks") + (_faction get "vehiclesFuelTrucks") + (_faction get "vehiclesMedical"));
Truck Spawn: Spawns truck and sets speed:
Sqf

Apply
private _truckVehicleData = [_roadPosition, _dirveh, _truckClass, _side] call A3A_fnc_spawnVehicle;
private _truckVehicle = _truckVehicleData select 0;
_truckVehicle limitSpeed 50;
[_truckVehicle, _side] call A3A_fnc_AIVEHinit;
Waypoint: Sets truck to drive to outpost:
Sqf

Apply
private _wp = _truckGroup addWaypoint [_outpostPosition, 0];
_wp setWaypointSpeed "LIMITED";
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "SAFE";
Cleanup Wait: Waits for timeout or vehicle destroyed or players leave:
Sqf

Apply
private _timeOut = time + 1800;
waitUntil { 
    sleep 5; 
    time > _timeOut || 
    {isNull _truckVehicle || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D (position _truckVehicle) < distanceSPWN} == -1
}}};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_spawnVehicle for truck creation
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with VEH_MOVE constant
Global variables modified: isEventInProgress
Network implications: Truck is networked object
Synchronization: Vehicle movement is networked
fn_encounter_vehiclePatrol.sqf
What it does: Creates enemy vehicle patrol near player. Vehicle drives around waypoints in area. Different from "Vehicle Move" which has destination.

How it does that:

Player Selection: Random rebel player:
Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);
Frontline Check: Ensures NOT near frontline:
Sqf

Apply
private _frontLine = (outposts + milbases + airportsX + resourcesX + factories + citiesX) select {([_x] call A3A_fnc_isFrontlineNoFIA && {sidesX getVariable [_x,sideUnknown] != teamPlayer})};
if !(_frontLine isEqualTo []) exitWith { ... reroll ... };
Outpost Selection: Finds enemy outpost near player:
Sqf

Apply
private _potentialOutposts = (outposts + milbases + airportsX + resourcesX + factories) select {
    sidesX getVariable [_x, sideUnknown] != teamPlayer && {(getMarkerPos _x) distance2D _player < distanceSPWN}
};
private _spawnPosition = [_originPosition, 600, distanceSPWN, 0, 0, 1] call BIS_fnc_findSafePos;
Road Finding: Finds road:
Sqf

Apply
private _road = objNull;
private _radiusX = 5;
while {true} do {
    _road = _spawnPosition nearRoads _radiusX;
    if (count _road > 0) exitWith {};
    _radiusX = _radiusX + 5;
};
Vehicle Type Selection: Chooses patrol vehicle based on difficulty:
Sqf

Apply
private _isFia = if (random 10 > (tierWar + difficultyCoef)) then {true} else {false};
private _vehicleClass = if (_isFia) then {
    selectRandom ((_faction get "vehiclesMilitiaLightArmed") +  (_faction get "vehiclesMilitiaAPCs") + (_faction get "vehiclesHelisLight"));
} else {
    selectRandom ((_faction get "vehiclesAPCs") +  (_faction get "vehiclesIFVs") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesAirPatrol") + (_faction get "vehiclesHelisLightAttack"));
};
Patrol Vehicle Spawn: Spawns vehicle:
Sqf

Apply
private _patrolVehicle1Data = [_roadPosition, _dirveh, _vehicleClass, _side] call A3A_fnc_spawnVehicle;
private _patrolVehicle1 = _patrolVehicle1Data select 0;
_patrolVehicle1 limitSpeed 50;
[_patrolVehicle1, _side] call A3A_fnc_AIVEHinit;
Cargo Group: Adds infantry to patrol:
Sqf

Apply
private _typeCargoGroup = [_vehicleClass, _side] call A3A_fnc_cargoSeats;
private _cargoGroup = [_roadPosition, _side, _typeCargoGroup, true,false] call A3A_fnc_spawnGroup;
{
    _x assignAsCargo _patrolVehicle1;
    _x moveInCargo _patrolVehicle1;
} forEach (units _cargoGroup);
(units _cargoGroup) join _patrolGroup1;
Patrol Waypoints: Creates circular patrol around area:
Sqf

Apply
private _relativePositions = [];
{
    private _relativePosition = [_roadPosition, random [300,400,600], _x] call BIS_fnc_relPos;
    _relativePositions pushBack _relativePosition;
} forEach [0, 90, 180];

{
    private _rndPosition = [_x, 0, 100, 0, 0, 0.75] call BIS_fnc_findSafePos;
    private _road = objNull;
    private _radiusX = 5;
    while {true} do {
        _road = _rndPosition nearRoads _radiusX;
        if (count _road > 0) exitWith {};
        _radiusX = _radiusX + 5;
    };
    private _roadPosition = getPos (_road select 0);
    private _wp = _patrolGroup1 addWaypoint [_roadPosition, _forEachIndex];
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "AWARE";
} forEach _relativePositions;

private _wp1 = _patrolGroup1 addWaypoint [_roadPosition, 0];
_wp1 setWaypointType "CYCLE";
Cleanup Wait: Waits for timeout or vehicle destroyed or players leave:
Sqf

Apply
private _timeOut = time + 1800;
waitUntil { 
    sleep 5; 
    time > _timeOut || 
    {isNull _patrolVehicle1 || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D (position _patrolVehicle1) < distanceSPWN} == -1
}}};
Where it leads:

Calls SCRT_fnc_misc_getRebelPlayers for player list
Calls A3A_fnc_isFrontlineNoFIA for frontline check
Calls A3A_fnc_spawnVehicle for vehicle creation
Calls A3A_fnc_AIVEHinit for vehicle initialization
Calls A3A_fnc_cargoSeats for cargo type
Calls A3A_fnc_spawnGroup for infantry group
Calls A3A_fnc_NATOinit for unit initialization
Calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner for cleanup
Called by SCRT_fnc_encounter_selectAndExecuteEvent with VEH_PATROL constant
Global variables modified: isEventInProgress
Network implications: Vehicle and group are networked
Synchronization: Patrol behavior is networked

(Garrison, Location, Loot)
fn_garrison_rollOversizeGarrison.sqf
What it does: Rolls for chance to add extra infantry squads to garrison based on faction aggression level. Returns additional squad types that should be included in garrison spawning.

How it does that:

Parameter Extraction: Takes side and marker:
Sqf

Apply
params ["_side", "_marker"];
Faction & Aggression: Gets faction and aggression level:
Sqf

Apply
private _faction = Faction(_side);
private _aggression = if (_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
Chance Calculation: Calculates oversize chance based on aggression (capped at 15%):
Sqf

Apply
private _oversizeChance =  _aggression / 2;
if (_oversizeChance > 15) then {
	_oversizeChance = 15;
};
Roll for Oversize: If roll succeeds, determine number of additional squads:
Sqf

Apply
if ((random 100) < _oversizeChance) then {
    private _squadCount = nil;
    switch (true) do {
        case (_aggression < 50): {
            _squadCount = round (random [1,2,3]);
        };
        case (_aggression > 50): {
            _squadCount = round (random [2,3,4]);
        };
        default {
            _squadCount = round (random [1,2,3]);
        };
    };
    // ... get squad pool and select random squads
    for "_i" from 1 to _squadCount do {
        _additionalGroups pushBack (selectRandom _pool);
    };
};
Return Additional Groups: Returns array of squad classnames:
Sqf

Apply
_additionalGroups
Where it leads:

Calls SCRT_fnc_unit_flattenTier to get squad pool
Called by garrison spawning systems when creating initial garrison
Global variables modified: aggressionOccupants, aggressionInvaders
Network implications: None (pure calculation)
Synchronization: N/A
fn_garrison_rollOversizeVehicle.sqf
What it does: Rolls for chance to add extra vehicle to garrison based on aggression. Returns vehicle data (or empty array if no vehicle) for spawning.

How it does that:

Parameter Extraction: Takes side, marker position, and size:
Sqf

Apply
params ["_side", "_markerPosition", "_size"];
Aggression & Faction: Gets aggression and faction:
Sqf

Apply
private _aggression = if (_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
private _isFia = if (random 10 > (tierWar + difficultyCoef)) then {true} else {false};
private _faction = Faction(_side);
Chance Calculation: Calculates oversize chance (capped at 25%):
Sqf

Apply
private _oversizeChance =  _aggression / 2;
if (_oversizeChance > 25) then {
	_oversizeChance = 25;
};
Roll for Oversize: If roll succeeds, select vehicle:
Sqf

Apply
if ((random 100) < _oversizeChance) then {
    private _vehiclePool = if (_isFia) then {
            (_faction get "vehiclesMilitiaAPCs") + (_faction get "vehiclesMilitiaLightArmed")
    } else {
        (_faction get "vehiclesAPCs") + (_faction get "vehiclesLightArmed") +  (_faction get "vehiclesIFVs")
    };
    private _selectedVehicle = selectRandom _vehiclePool;
    // ... find road position
    // ... spawn vehicle
};
Road Position Finding: Searches for nearby road for vehicle placement:
Sqf

Apply
private _road = nil;
private _radiusX = 5;
while {true} do {
    _road = _markerPosition nearRoads _radiusX;
    if (count _road > 0) exitWith {};
    if (_radiusX > 700) exitWith {};
    _radiusX = _radiusX + 10;
};
Position Determination: Uses road position or finds safe position:
Sqf

Apply
private _position = nil;
if (!isNil "_road") then {
    private _roadcon = roadsConnectedto (_road select 0);
    private _dirveh = if(count _roadcon > 0) then {[_road select 0, _roadcon select 0] call BIS_fnc_DirTo} else {random 360};
    _position = getPos (_road select 0);
} else {
    _position = [_markerPosition, 10, _size, 5, 0, 0.7, 0, [], [_markerPosition, _markerPosition]] call BIS_fnc_findSafePos;
};
Vehicle Spawn: Creates vehicle at determined position:
Sqf

Apply
private _vehicleData = [_position, 0, _selectedVehicle, _side] call A3A_fnc_spawnVehicle;
_return = _vehicleData;
Where it leads:

Calls BIS_fnc_DirTo for road direction
Calls BIS_fnc_findSafePos for non-road position
Calls A3A_fnc_spawnVehicle for vehicle creation
Called by garrison spawning systems
Global variables modified: aggressionOccupants, aggressionInvaders
Network implications: Vehicle spawn is networked
Synchronization: N/A
fn_location_createPatrols.sqf
What it does: Creates patrol units for a location (outpost, base, etc.). Spawns multiple infantry groups with patrol loops around the location. Can spawn guard dogs.

How it does that:

Parameter Extraction: Takes marker, position, side, faction, and patrol count:
Sqf

Apply
params [
	["_marker", "", [""]],
	["_markerPosition", [], [[]]],
	["_side", sideUnknown, [sideUnknown]],
	["_faction", createHashMap, [createHashMap]],
	["_patrolCount", 4, [0]]
];
Group Pool Selection: Gets small infantry group pool:
Sqf

Apply
private _arrayGroups = [_faction, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier;
private _sniperGroup = [_faction get "groupTierSniper"] call SCRT_fnc_unit_getTiered;
Fog Check: Removes first group if fog is thick (sniper groups less effective):
Sqf

Apply
if ([_marker, false] call A3A_fnc_fogCheck < 0.3) then {
	_arrayGroups deleteAt 0;
};
Patrol Loop: Creates specified number of patrol groups:
Sqf

Apply
while {_countX < _patrolCount} do {
	_typeGroup = selectRandom _arrayGroups;
    // ... find spawn position
    // ... spawn group
    // ... random guard dog chance
    // ... patrol loop
    // ... initialization
    _countX = _countX +1;
};
Spawn Position Finding: Finds safe position near location:
Sqf

Apply
_spawnPosition = [_markerPosition, 25, round (_size / 2), 2, 0, -1, 0] call A3A_fnc_getSafePos;
if (_spawnPosition isEqualTo [0,0]) exitWith {
	ServerDebug("Unable to find spawn position for patrol unit.");
};
Group Spawn & Initialization: Spawns group and sets up patrol:
Sqf

Apply
_groupX = [_spawnPosition, _side, _typeGroup, false, true] call A3A_fnc_spawnGroup;
if !(isNull _groupX) then {
    sleep 1;
    if ((random 10 < 2.5) && {_typeGroup isNotEqualTo _sniperGroup}) then {
        _dog = [_groupX, "Fin_random_F",_spawnPosition,[],0,"FORM"] call A3A_fnc_createUnit;
        _dogs pushBack _dog;
        [_dog] spawn A3A_fnc_guardDog;
        sleep 1;
    };
    [_groupX, "Patrol_Area", 25, 150, 300, false, [], false] call A3A_fnc_patrolLoop;
    _groups pushBack _groupX;
    {[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupX;
};
Where it leads:

Calls SCRT_fnc_unit_flattenTier for group pool
Calls A3A_fnc_fogCheck for fog assessment
Calls A3A_fnc_getSafePos for spawn position
Calls A3A_fnc_spawnGroup for group creation
Calls A3A_fnc_createUnit for guard dog
Calls A3A_fnc_guardDog for dog behavior
Calls A3A_fnc_patrolLoop for patrol behavior
Calls A3A_fnc_NATOinit for unit initialization
Called by location spawning systems
Global variables modified: None
Network implications: Patrol groups are networked
Synchronization: N/A
fn_location_removeMilAdmin.sqf
What it does: Removes military administration from active pool and moves it to captured/destroyed list. Handles different removal causes (capture, destroy, silent, loadstat) with different effects.

How it does that:

Parameter Extraction: Takes military administration object and cause:
Sqf

Apply
params [
	["_milAdministration", objNull, [objNull]],
	["_cause", "CAPTURE", [""]]
];
Validation: Checks if object is null or already destroyed:
Sqf

Apply
if (_milAdministration isEqualTo objNull) exitWith {
	Error("For some reason miladministration object is null.");
};

if (_milAdministration in A3A_destroyedMilAdministrations) exitWith {
	Warning("Military administration is already destroyed, aborting.");
};
Event Handler Removal: Removes killed event handler:
Sqf

Apply
_milAdministration removeAllEventHandlers "Killed";
Add to Destroyed List: Adds to global destroyed list:
Sqf

Apply
A3A_destroyedMilAdministrations pushBack _milAdministration;
Marker Update: Finds nearest marker and updates it:
Sqf

Apply
private _mrk = [milAdministrationsX, _milAdministration] call BIS_fnc_nearestPosition;
_mrk setMarkerColor "ColorBlack";
sidesX setVariable [_mrk, teamPlayer, true];
Public Variable Update: Broadcasts change if not loading state:
Sqf

Apply
if (_cause isNotEqualTo "LOADSTAT") then {
	publicVariable "A3A_destroyedMilAdministrations";
};
Cause-Specific Actions: Switch statement for different causes:
Sqf

Apply
switch (_cause) do {
	case "CAPTURE": {
		["TaskSucceeded", ["", (localize "STR_notifiers_miladmin_captured")]] remoteExec ["BIS_fnc_showNotification", teamPlayer];
		["TaskFailed", ["", (localize "STR_notifiers_miladmin_captured")]] remoteExec ["BIS_fnc_showNotification", Occupants];
		[-25, 25, position _milAdministration] remoteExec ["A3A_fnc_citySupportChange",2];
	};
	case "DESTROY": {
		["TaskSucceeded", ["", (localize "STR_notifiers_miladmin_destroyed")]] remoteExec ["BIS_fnc_showNotification", teamPlayer];
		["TaskFailed", ["", (localize "STR_notifiers_miladmin_destroyed")]] remoteExec ["BIS_fnc_showNotification", Occupants];
		[Occupants, 15, 60] remoteExec ["A3A_fnc_addAggression",2];
		[-25, 25, position _milAdministration] remoteExec ["A3A_fnc_citySupportChange",2];

		// Support call for destruction
		private _players = [300, _milAdministration] call SCRT_fnc_common_getNearPlayers;
		if (_players isNotEqualTo []) then {
			private _position = getPos _milAdministration;
			private _reveal = [_position, Occupants] call A3A_fnc_calculateSupportCallReveal;
			[Occupants, (selectRandom _players), _position, 4, _reveal] remoteExec ["A3A_fnc_requestSupport", 2];
		};
	};
	case "SILENT";
	case "LOADSTAT": {
		[_milAdministration] call BIS_fnc_createRuin;
		[_milAdministration, true] remoteExecCall ["hideObject", -clientOwner];
	};
	default {
		Error("Unknown cause of administration removal.");
	};
};
Where it leads:

Calls BIS_fnc_nearestPosition for nearest marker
Calls BIS_fnc_showNotification for notifications
Calls A3A_fnc_citySupportChange for city support
Calls A3A_fnc_addAggression for aggression change
Calls SCRT_fnc_common_getNearPlayers for nearby players
Calls A3A_fnc_calculateSupportCallReveal for reveal calculation
Calls A3A_fnc_requestSupport for support request
Calls BIS_fnc_createRuin for ruin creation
Called by miladmin capture/destroy systems
Global variables modified: A3A_destroyedMilAdministrations, sidesX
Network implications: Multiple remoteExec calls, publicVariable
Synchronization: State changes broadcast to all clients
fn_loot_addActionLoot.sqf
What it does: Adds a "Loot" hold action to a vehicle that allows nearby players to automatically loot area. Manages action lifecycle with event handler for removal on death.

How it does that:

Check Existing Action: Removes any existing loot action:
Sqf

Apply
params ["_vehicle"];
private _lootActionID = _vehicle getVariable ["lootActionID", Nil];
if(!isnil "_lootActionID") then {
	_vehicle removeAction _lootActionID;
};
Add Hold Action: Creates complex hold action with conditions:
Sqf

Apply
_lootActionID = [_vehicle,
	localize "STR_antistasi_actions_loot_around_text",
	"\a3\missions_f_oldman\data\img\holdactions\holdaction_box_ca.paa",
	"\a3\missions_f_oldman\data\img\holdactions\holdaction_box_ca.paa",
	"vehicle player == player && _this distance _target < 5",
	"vehicle player == player && _caller distance _target < 5",
	{},
	{},
	{
		[_this select 0, lootCrateDistance] remoteExec ["SCRT_fnc_loot_gatherLoot", 2];
	},
	{},
	[],
	2,
	5,
	false,
	false
] call BIS_fnc_holdActionAdd;
Store Action ID: Saves action ID on vehicle:
Sqf

Apply
_vehicle setVariable ["lootActionID", _lootActionID, false];
Add Death Handler: Removes action when vehicle dies:
Sqf

Apply
_vehicle addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	[_unit] remoteExec ["SCRT_fnc_loot_removeActionLoot",0, _unit];
}];
Where it leads:

Calls BIS_fnc_holdActionAdd to add action
Calls SCRT_fnc_loot_removeActionLoot for action removal
Called by loot vehicle systems
Global variables modified: lootCrateDistance (settings)
Network implications: Remote execution for action removal on death
Synchronization: Action is local, death handler networked
fn_loot_createLootCrate.sqf
What it does: Creates a purchasable loot crate for players. Handles payment from personal or faction funds and sets up placement preview.

How it does that:

Get Loot Crate Details: Retrieves type and cost:
Sqf

Apply
private _lootCrateType = FactionGet(reb, "lootCrate");
private _cost = lootCratePrice;
Payment Source Check: Determines payment source (personal vs faction):
Sqf

Apply
if (player != theBoss) then {
	_resourcesFIA = player getVariable "moneyX";
} else {
	private _factionMoney = server getVariable "resourcesFIA";
	if (_cost <= _factionMoney) then {
		_resourcesFIA = _factionMoney;
	} else {
		_resourcesFIA = player getVariable "moneyX";
	};
};
Affordability Check: Verifies funds:
Sqf

Apply
if (_resourcesFIA < _cost) exitWith {
    [localize "STR_scrt_stores_buy_item_not_enough_header", format [localize "STR_scrt_stores_buy_item_not_enough", _cost, A3A_faction_civ get "currencySymbol"]] call SCRT_fnc_misc_deniedHint;
};
Placement Setup: Configures placement preview with callback:
Sqf

Apply
private _extraMessage = format [localize "STR_veh_callback_placement_text", localize "STR_veh_callback_placement_text_additive_lootcrate", _cost, A3A_faction_civ get "currencySymbol"];
private _fnc_placed = {
	params ["_vehicle", "_cost"];
	private _factionMoney = server getVariable "resourcesFIA";
	if (player == theBoss && {_cost <= _factionMoney}) then {
		[0,(-1 * _cost)] remoteExec ["A3A_fnc_resourcesFIA",2];
	}
	else {
		[-1 * _cost] call A3A_fnc_resourcesPlayer;
		_vehicle setVariable ["ownerX",getPlayerUID player,true];
	};
	_vehicle addEventHandler ["Killed", { [_this#0] spawn { sleep 10; deleteVehicle (_this#0) } }];
};

[_lootCrateType, _fnc_placed, {false}, [_cost], nil, nil, nil, _extraMessage] call HR_GRG_fnc_confirmPlacement;
Where it leads:

Calls SCRT_fnc_misc_deniedHint for insufficient funds
Calls A3A_fnc_resourcesFIA for faction payment
Calls A3A_fnc_resourcesPlayer for personal payment
Calls HR_GRG_fnc_confirmPlacement for placement UI
Called by loot crate purchase systems
Global variables modified: resourcesFIA (via functions), ownerX on vehicle
Network implications: Payment is server-side, vehicle creation is local
Synchronization: Payment handled by server
fn_loot_gatherLoot.sqf
What it does: Loots all bodies and crates in a radius around a vehicle or position. Transfers items, magazines, weapons, backpacks, and items to the loot vehicle/crate. Handles money distribution and validation.

How it does that:

Parameter Extraction: Takes vehicle, radius, and optional position override:
Sqf

Apply
params ["_vehicle", "_radius", ["_overridePosition",[]]];
Cooldown Check: Prevents spamming with 10-second cooldown:
Sqf

Apply
if ((_time - (_vehicle getVariable ["lastLooted", -10])) < 10) exitWith { ... };
_vehicle setVariable ["lastLooted", _time, true];
Position Determination: Uses vehicle position or override:
Sqf

Apply
private _position = if (!(_overridePosition isEqualTo [])) then {_overridePosition} else {position _vehicle};
Find Lootable Objects: Finds corpses and weapon holders:
Sqf

Apply
private _supplies = (_position nearSupplies _radius) select {
    ((_x isKindOf "Man" && !(alive _x)) || 
    {(typeOf _x) in ([FactionGet(inv, "surrenderCrate"), FactionGet(occ, "surrenderCrate"), FactionGet(riv, "surrenderCrate"), "WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"])}) &&
    !(_x getVariable ["isLooted", false])
};
Unlocked Items Check: Optionally filters out unlocked items:
Sqf

Apply
if ((lootCrateUnlockedItems isEqualTo true)) then {
    _data = [_magazines, _weaponsWithAttachments, _items, _backpacks];
    private _unlocked = [_data] call a3u_fnc_removeUnlockedItems;
    // redefine vars minus returned _data
    _magazines = _magazines - _unlocked;
    // ... etc
};
Transfer Items to Vehicle: Loops through each loot container:
Sqf

Apply
{
    _lootContainer = _x;
    _magazines = magazineCargo _lootContainer;
    _weaponsWithAttachments = weaponsItems _lootContainer;
    _items = itemCargo _lootContainer;
    _backpacks = backpackCargo _lootContainer;

    // Process each type
    if (count _magazines > 0) then {
        {
            if(_x in arrayMoney) then {
                _moneyIndex = arrayMoney find _x;
                if (_moneyIndex isNotEqualTo -1) then {
                    _moneyEarned = _moneyEarned + (arrayMoneyAmount select _moneyIndex);
                };
            } else {
                _vehicle addMagazineCargoGlobal [_x, 1];
            };
        } forEach _magazines;
    };
    // ... process backpacks, items, weapons
} forEach _supplies;
Process Human Corpses: Special handling for dead bodies:
Sqf

Apply
switch (true) do {
    case (_lootContainer isKindOf "Man"): {
        private _assignedItems = assignedItems _lootContainer;
        private _lootContainerMagazines = magazines _lootContainer;
        private _vest = vest _lootContainer;
        private _headgear = headgear _lootContainer;
        private _backpack = backpack _lootContainer;
        private _lootContainerWeapons = weaponsItems _lootContainer;

        // Transfer assigned items
        if (count _assignedItems > 0) then {
            {
                _vehicle addItemCargoGlobal [_x,1];
                _lootContainer unassignItem _x;
                _lootContainer removeItem _x;
            } forEach _assignedItems;
        };

        // Transfer magazines
        if (count _lootContainerMagazines > 0) then {
            {
                if (_x in arrayMoney) then {
                    _moneyIndex = arrayMoney find _x;
                    if(_moneyIndex isNotEqualTo -1) then {
                        _moneyEarned = _moneyEarned + (arrayMoneyAmount select _moneyIndex);
                    };
                } else {
                    _vehicle addMagazineCargoGlobal [_x, 1];
                };
                _lootContainer removeMagazines _x;
            } forEach _lootContainerMagazines;
        };

        // Transfer vest
        if (_vest isNotEqualTo "") then {
            _vehicle addItemCargoGlobal [_vest,1];
            removeVest _lootContainer;
        };

        // Transfer headgear
        if (_headgear isNotEqualTo "") then {
            _vehicle addItemCargoGlobal [_headgear,1];
            removeHeadgear _lootContainer;
        };

        // Transfer backpack
        if (_backpack isNotEqualTo "") then {
            _vehicle addBackpackCargoGlobal [_backpack,1];
            removeBackpackGlobal _lootContainer;
        };

        // Transfer weapons
        if (count _lootContainerWeapons > 0) then {
            {
                _vehicle addWeaponWithAttachmentsCargoGlobal [_x, 1];
                _lootContainer removeWeaponGlobal (_x#0);
            } forEach _lootContainerWeapons;
        };

        removeAllWeapons _lootContainer;
        _lootContainer setVariable ["isLooted", true, true];
    };
    default {
        deleteVehicle _lootContainer;
    };
};
Money Distribution: Distributes found money to all players:
Sqf

Apply
if (_moneyEarned > 0) then {
    _allPlayers = call SCRT_fnc_misc_getRebelPlayers;
    _playersCount = count _allPlayers;
    
    if (_playersCount > 0) then {
        _incomePerPlayer = round(_moneyEarned / _playersCount);
        {
            [_incomePerPlayer, _x] call A3A_fnc_addMoneyPlayer;
        } forEach _allPlayers;

        [localize "STR_antistasi_actions_common_notifications_money_found_title", localize "STR_antistasi_actions_common_notifications_money_found_text"] remoteExecCall ["A3A_fnc_customHint", [teamPlayer, civilian]];
    };
};
Feedback: Play sound and send messages:
Sqf

Apply
private _volume = if (_overridePosition isNotEqualTo []) then {500} else {_radius};
playSound3D ["x\A3A\addons\core\Sounds\Misc\LootSuccess.ogg", _vehicle, false, getPosASL _vehicle, 3, 1, _volume];

{
    localize "STR_antistasi_actions_successful_loot_text" remoteExec ["systemChat", _x];
} forEach ([_radius, _vehicle] call SCRT_fnc_common_getNearPlayers);
Where it leads:

Calls A3A_fnc_enemyNearCheck for safety check
Calls SCRT_fnc_common_getNearPlayers for player list
Calls a3u_fnc_removeUnlockedItems for unlocked item filtering
Calls A3A_fnc_addMoneyPlayer for money distribution
Calls A3A_fnc_customHint for notification
Called by loot action or loot systems
Global variables modified: isLooted, lastLooted on objects, ownerX on vehicle
Network implications: Money distribution and hints are networked
Synchronization: Item transfer uses global cargo methods
fn_loot_removeActionLoot.sqf
What it does: Removes the loot hold action from a vehicle. Simple cleanup function.

How it does that:

Get Action ID: Retrieves stored action ID:
Sqf

Apply
params ["_vehicle"];
private _lootActionID = _vehicle getVariable ["lootActionID", nil];
Remove Action: Removes if exists:
Sqf

Apply
if(!isNil "_lootActionID") then {
	[_vehicle, _lootActionID] call BIS_fnc_holdActionRemove;
	_vehicle setVariable ["lootActionID", nil];
};
Where it leads:

Calls BIS_fnc_holdActionRemove for action removal
Called by vehicle death handler
Global variables modified: lootActionID on vehicle
Network implications: None (local action removal)
Synchronization: N/A
fn_loot_removeActionLoot.sqf (Detailed)
Function Specification
File: 
fn_loot_removeActionLoot.sqf

Location: A3A/addons/scrt/Loot/
Scope: Local
Environment: Any
Parameters: _vehicle (Object)
Returns: Nothing

Detailed Implementation
Parameter Validation
Sqf

Apply
params ["_vehicle"];
Takes one parameter: the vehicle/object from which to remove the loot action
No type checking in this function (caller should validate)
Action ID Retrieval
Sqf

Apply
private _lootActionID = _vehicle getVariable ["lootActionID", nil];
Retrieves the stored hold action ID from the vehicle's variables
Uses getVariable with default nil if action ID doesn't exist
Action Removal Logic
Sqf

Apply
if(!isNil "_lootActionID") then {
	[_vehicle, _lootActionID] call BIS_fnc_holdActionRemove;
	_vehicle setVariable ["lootActionID", nil];
};
Checks if action ID exists (not nil)
Calls BIS_fnc_holdActionRemove with vehicle and action ID
Clears the stored action ID from vehicle variables
Execution Context
This function is designed to be called:

From vehicle death event handlers (as seen in 
fn_loot_addActionLoot.sqf
)
When explicitly cleaning up vehicle actions
From system cleanup procedures
Integration with Loot System
Called by: 
fn_loot_addActionLoot.sqf
 via death event handler
Calls: BIS_fnc_holdActionRemove
Modifies: Vehicle's lootActionID variable (sets to nil)
Scope: Local execution only
Edge Cases Handled
Missing Action ID: If action doesn't exist, function exits silently
Multiple Calls: Safe to call multiple times (idempotent)
Invalid Vehicle: If vehicle is null or doesn't have the variable, exits cleanly
Best Practices
Should always be paired with 
fn_loot_addActionLoot.sqf
Vehicle death event handler is the primary cleanup mechanism
No error logging if action doesn't exist (silent failure)

(Misc, Outpost, Paradrop, Rally)
fn_misc_canAddItemToContainer.sqf
What it does: Replaces buggy BIS canAdd* functions to check if an item can be added to a container (backpack, vest, crate). Calculates mass and compares to container capacity.

How it does that:

Parameter Extraction: Takes container, item, and optional count:
Sqf

Apply
params[
    ["_container",objNull,[objNull]],
    ["_item","",[""]],
    ["_count",1,[0]]
];
Validation: Ensures container exists:
Sqf

Apply
if !assert(!isNull _container) exitWith { false };
Current Load: Gets container's current and max load:
Sqf

Apply
private _load = loadAbs _container;
private _maximum = maxLoad _container;
Full Check: Exits if container is already full:
Sqf

Apply
if (_load >= _maximum) exitWith { false };
Count Check: Exits if count is zero or negative (always true):
Sqf

Apply
if (_count <= 0) exitWith { true };
Mass Calculation: Determines item mass based on config:
Sqf

Apply
private _mass = switch true do {
    case isNumber(configFile >> "CfgWeapons" >> _item >> "ItemInfo" >> "mass"): {
        // It's an item
        getNumber(configFile >> "CfgWeapons" >> _item >> "ItemInfo" >> "mass");
    };

    case isClass(configFile >> "CfgMagazines" >> _item): {
        // It's a magazine
        getNumber(configFile >> "CfgMagazines" >> _item >> "mass");
    };

    case isClass(configFile >> "CfgWeapons" >> _item >> "WeaponSlotsInfo"): {
        // It's a weapon
        private _baseMass = getNumber(configFile >> "CfgWeapons" >> _item >> "WeaponSlotsInfo" >> "mass");
        private _linkedItemsMass = 0;

        // Calculate attachments weights
        "true" configClasses(configFile >> "CfgWeapons" >> _item >> "LinkedItems") apply {
            private _linkedItem = getText(_x >> "item");
            private _linkedItemMass = getNumber(configFile >> "CfgWeapons" >> _linkedItem >> "ItemInfo" >> "mass");

            _linkedItemsMass = _linkedItemsMass + _linkedItemMass;
        };

        _baseMass + _linkedItemsMass;
    };
    default {
        // It's a croak out
        Error_1("SCRT_fnc_misc_canAddItemToContainer(%1): item not item, magazine or weapon", _item);
        -1
    };
};
Final Check: Verifies if item fits:
Sqf

Apply
(_mass >= 0) && { (_load + _mass * _count) <= _maximum };
Where it leads:

Uses loadAbs, maxLoad for container stats
Uses configFile for mass lookup
Called by inventory management systems
Global variables modified: None
Network implications: None (local calculation)
Synchronization: N/A
fn_misc_createBelonging.sqf
What it does: Creates a vehicle/object at specified position with direction. Simple wrapper for createVehicle.

How it does that:

Parameter Extraction: Takes class, position, direction, and special parameter:
Sqf

Apply
params ["_class", "_pos", ["_dir", 0], ["_special", "CAN_COLLIDE"]];
Object Creation: Creates vehicle with parameters:
Sqf

Apply
private _object = createVehicle [_class, _pos, [], 0, _special];		
_object setDir _dir;
Return: Returns created object:
Sqf

Apply
_object
Where it leads:

Simple wrapper for createVehicle
Called by various object creation systems
Global variables modified: None
Network implications: None (local creation)
Synchronization: N/A
fn_misc_deniedHint.sqf
What it does: Shows a denial hint with error sound. Standardized way to show "you can't do this" messages.

How it does that:

Show Hint: Calls custom hint function:
Sqf

Apply
[_this select 0, _this select 1] call A3A_fnc_customHint;
Play Sound: Plays failure sound:
Sqf

Apply
playSound "A3AP_UiFailure";
Where it leads:

Calls A3A_fnc_customHint for message display
Called by validation failures throughout SCRT
Global variables modified: None
Network implications: None (local effects)
Synchronization: N/A
fn_misc_extendPosition.sqf
What it does: Extends a position vector by a distance in a specific direction (azimuth). Used for calculating offset positions.

How it does that:

Parameter Extraction: Takes position, distance, and azimuth:
Sqf

Apply
params ["_x", "_y", "_z"];
Calculate Extended Coordinates: Uses trigonometry:
Sqf

Apply
private _x2 = ((_x select 0) + ((cos (90-_z)) * _y));
private _y2 = ((_x select 1) + ((sin (90-_z)) * _y));
Return: Returns new position with z=0:
Sqf

Apply
[_x2, _y2, 0]
Where it leads:

Uses trigonometric functions
Called by position calculation systems
Global variables modified: None
Network implications: None
Synchronization: N/A
fn_misc_followCamera.sqf
What it does: Creates a camera that follows the player vehicle from behind. Used for cinematic views. Includes CBA optics restart.

How it does that:

Get Target: Gets player vehicle:
Sqf

Apply
private _vehicle = vehicle player;
private _coords = position _vehicle;
Create Camera: Creates camera and sets effect:
Sqf

Apply
private _camera = "camera" camCreate _coords;
_camera cameraEffect ["INTERNAL","BACK"]; 
_camera camSetTarget vehicle player; 
_camera camCommit 0; 
_camera attachTo [_vehicle, [0,-10,20]];
Wait for Menu: Waits for menu to close:
Sqf

Apply
waitUntil {!isMenuOpen};
Cleanup Camera: Terminate and destroy camera:
Sqf

Apply
_camera cameraEffect ["Terminate", "Back"];
camDestroy _camera;
Restart Optics: Restart CBA optics if available:
Sqf

Apply
if !(isNil "CBA_optics_fnc_restartCamera") then {
    [call CBA_fnc_currentUnit, true] call CBA_optics_fnc_restartCamera;
};
Where it leads:

Uses camera functions (camCreate, camSetTarget, etc.)
Calls CBA_optics_fnc_restartCamera if available
Called by camera mode systems
Global variables modified: None
Network implications: None (local camera)
Synchronization: N/A
fn_misc_getAccentColor.sqf
What it does: Returns the current GUI accent color (from profileNamespace) as RGBA array or HTML hex color.

How it does that:

Get RGB Values: Reads from profileNamespace:
Sqf

Apply
private _accentColorRgba = [
	(profilenamespace getvariable ['GUI_BCG_RGB_R',0.376]),
	(profilenamespace getvariable ['GUI_BCG_RGB_G',0.125]),
	(profilenamespace getvariable ['GUI_BCG_RGB_B',0.043]),
	1
];
Convert to Hex: Optionally converts to HTML hex:
Sqf

Apply
if (_isHex) then {
    _accentColorRgba = _accentColorRgba call BIS_fnc_colorRGBAtoHTML;
};
Return: Returns color:
Sqf

Apply
_accentColorRgba
Where it leads:

Uses BIS_fnc_colorRGBAtoHTML for conversion
Called by UI systems for theming
Global variables modified: None
Network implications: None
Synchronization: N/A
fn_misc_getLoadoutName.sqf
What it does: Extracts and formats a loadout name from a string (assumes format loadouts_reb_militia_LOADOUT).

How it does that:

Split String: Splits by underscore:
Sqf

Apply
private _sourceString = _this;
private _stringParts = _sourceString splitString "_";
Extract Loadout Name: Takes 4th part (index 3) and uppercases:
Sqf

Apply
if (_stringParts isEqualTo []) exitWith {_sourceString};
private _result = _stringParts select 3; //loadouts_reb_militia_LOADOUT
_result = toUpperANSI _result;
Return: Returns formatted name:
Sqf

Apply
_result
Where it leads:

Called by loadout management systems
Global variables modified: None
Network implications: None
Synchronization: N/A
fn_misc_getMissionTitle.sqf
What it does: Returns localized map name based on worldName. Supports many maps.

How it does that:

Switch on World Name: Uses switch statement to map worldName to localized string:
Sqf

Apply
switch (toLowerANSI worldName) do {
	case "altis": {
		_title = localize "STR_antistasi_mission_info_Altis_mapname_text";
	};
	case "malden": {
	    _title = localize "STR_antistasi_mission_info_Malden_mapname_text";
	};
	// ... many other cases
	default {
	    _title = "Antistasi Ultimate";
	};
};
Return: Returns localized title:
Sqf

Apply
_title
Where it leads:

Uses localize for localization
Called by mission info systems
Global variables modified: None
Network implications: None
Synchronization: N/A
fn_misc_getRebelPlayers.sqf
What it does: Returns all rebel or civilian players (excludes headless clients).

How it does that:

Filter Players: Gets all players and filters by side:
Sqf

Apply
(allPlayers - entities "HeadlessClient_F") select {side _x in [civilian, teamPlayer]};
Where it leads:

Uses allPlayers and entities
Called by various player list systems
Global variables modified: None
Network implications: None
Synchronization: N/A
fn_misc_getTimeLimit.sqf
What it does: Calculates a time limit based on minutes, applying time multiplier and returning human-readable datetime string.

How it does that:

Apply Multiplier: Calculates actual time limit:
Sqf

Apply
private _timeLimit = _limit * timeMultiplier;
Get Current Date: Gets current date components:
Sqf

Apply
date params ["_year", "_month", "_day", "_hours", "_minutes"];
Calculate Future Date: Adds time limit to current time:
Sqf

Apply
private _dateLimit = if ((_hours + _timeLimit % 60) > 1) then {
    [_year, _month, _day, _hours + (_timeLimit / 60), _minutes + (_timeLimit % 60)];
} else {
    [_year, _month, _day, _hours, _minutes + _timeLimit];
};
Convert to Number and Back: Converts to numeric date for accuracy:
Sqf

Apply
private _dateLimitNum = dateToNumber _dateLimit;
_dateLimit = numberToDate [date select 0, _dateLimitNum];
Format for Display: Converts to time string:
Sqf

Apply
private _displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;
Return: Returns tuple with numeric and display time:
Sqf

Apply
[_dateLimitNum, _displayTime]
Where it leads:

Uses dateToNumber, numberToDate for date math
Calls A3A_fnc_dateToTimeString for formatting
Called by time limit systems
Global variables modified: None
Network implications: None
Synchronization: N/A
fn_misc_getWorldName.sqf
What it does: Returns formatted world name, handling special map names and casing.

How it does that:

Check Cache: Uses stored world name if available:
Sqf

Apply
if (isNil "storedWorldName") then {
	// ... calculate
};
storedWorldName
Switch on World Name: Maps worldName to formatted names:
Sqf

Apply
switch (toLowerANSI worldName) do {
	case "cup_chernarus_a3": {
		storedWorldName = "Chernarus";
	};
	case "blud_vidda":  {
		storedWorldName = "Vidda";
	};
	// ... many other cases
	default {
		storedWorldName = toUpperANSI([worldName, 0, 0] call BIS_fnc_trimString) + ([worldName, 1, count worldName] call BIS_fnc_trimString);
	};
};
Return: Returns cached name:
Sqf

Apply
storedWorldName
Where it leads:

Uses BIS_fnc_trimString for string manipulation
Called by UI and info systems
Global variables modified: storedWorldName
Network implications: None
Synchronization: N/A
fn_misc_getWorldPlaces.sqf
What it does: Returns array of map place names (cities, villages, etc.) with positions and types.

How it does that:

Get Places Config: Accesses world config:
Sqf

Apply
private _placesConfigs = configFile >> "CfgWorlds" >> worldName >> "Names";
private _places = [];
Loop Through Configs: Processes each place:
Sqf

Apply
for "_i" from 0 to (count _placesConfigs) - 1 do { 
    private _place = _placesConfigs select _i; 
    private _name = configName _place; 
    private _position = getArray (_place >> "position"); 
    private _type = getText(_place >> "type"); 
    if(_type in _placesToKeep) then { 
        _places set [_i, [_name, _position, _type]]; 
    }; 
};
Filter and Return: Remove nil entries and return:
Sqf

Apply
_places select {!isNil "_x"}
Where it leads:

Uses configFile to read world config
Called by map analysis systems
Global variables modified: None
Network implications: None
Synchronization: N/A
fn_misc_isInHouse.sqf
What it does: Checks if unit is inside a house (building). Uses line intersection to detect house above unit.

How it does that:

Line Intersection: Casts ray upward from unit:
Sqf

Apply
lineIntersectsSurfaces [
    getPosWorld _this, 
    getPosWorld _this vectorAdd [0, 0, 50], 
    _this, objNull, true, 1, "GEOM", "NONE"
] select 0 params ["","","","_house"];
Check Result: Determines if house was hit:
Sqf

Apply
if (isNil "_house") exitWith {false};
if (_house isKindOf "House") exitWith {true};
false
Where it leads:

Uses lineIntersectsSurfaces for intersection detection
Called by shelter detection systems
Global variables modified: None
Network implications: None
Synchronization: N/A
fn_misc_orbitingCamera.sqf
What it does: Creates an orbiting camera around the player for menu views. Cycles while menu is open.

How it does that:

Camera Setup: Defines orbit parameters:
Sqf

Apply
private _radius = 10;
private _angle = 360;
private _altitude = 50;
private _speed = 0.15;
Initial Camera: Creates and positions camera:
Sqf

Apply
private _coords = [player, _radius, _angle] call BIS_fnc_relPos;
_coords set [2, _altitude];

private _camera = "camera" camCreate _coords;
_camera cameraEffect ["INTERNAL","BACK"];
_camera camPrepareFOV 0.700;
_camera camPrepareTarget player;
_camera camCommitPrepared 0;
Orbit Loop: Cycles camera around player:
Sqf

Apply
while {isMenuOpen} do {      
    _coords = [player, _radius, _angle] call BIS_fnc_relPos;
    _coords set [2, _altitude];

    _camera camPreparePos _coords;
    _camera camCommitPrepared _speed;

    waitUntil {camCommitted _camera || !(isMenuOpen)};

    _camera camPreparePos _coords;
    _camera camCommitPrepared 0;

    _angle = _angle + 1;
};
Cleanup: Destroys camera:
Sqf

Apply
_camera cameraEffect ["Terminate", "Back"];
camDestroy _camera;

// Optics restart
if !(isNil "CBA_optics_fnc_restartCamera") then {
    [call CBA_fnc_currentUnit, true] call CBA_optics_fnc_restartCamera;
};
Where it leads:

Uses camera functions and BIS_fnc_relPos
Called by menu systems for visual appeal
Global variables modified: None
Network implications: None (local camera)
Synchronization: N/A
fn_misc_toggleMenuBlur.sqf
What it does: Enables or disables menu blur post-processing effect.

How it does that:

Parameter Extraction: Takes mode ("on" or "off"):
Sqf

Apply
params ["_mode"];
Switch on Mode: Handles blur on/off:
Sqf

Apply
switch (_mode) do {
    case ("on"): {
        if (isNil "dialog_blur_gui_blur") then {
			dialog_blur = ppEffectCreate ["DynamicBlur", 999];
			dialog_blur ppEffectEnable true;
		};

        dialog_blur ppEffectAdjust [8];
		dialog_blur ppEffectCommit 0.2;
    };
    case ("off"): {
        dialog_blur ppEffectAdjust [0];
		dialog_blur ppEffectCommit 0.3;
    };
};
Where it leads:

Uses ppEffectCreate and post-processing effects
Called by menu open/close systems
Global variables modified: dialog_blur
Network implications: None (local effect)
Synchronization: N/A
fn_misc_tryInitVehicle.sqf
What it does: Initializes vehicle animations and variants from faction data. Handles special case for Invaders needing Rivals data.

How it does that:

Get Faction Data: Gets animations and variants for vehicle:
Sqf

Apply
private _faction = Faction(_side);
private _anims = (_faction get "animations") getOrDefault [(typeOf _vehicle), []];
private _variants = (_faction get "variants") getOrDefault [(typeOf _vehicle), false];
Rivals Special Case: For Invaders, check Rivals faction if no data:
Sqf

Apply
if (_side == Invaders && {_anims isEqualTo []}) then {
    _anims = (A3A_faction_riv get "animations") getOrDefault [(typeOf _vehicle), []];
};
if (_side == Invaders && {(_variants isEqualType false)}) then {
    _variants = (A3A_faction_riv get "variants") getOrDefault [(typeOf _vehicle), false];
};
Exit if No Data: If no animations/variants, exit:
Sqf

Apply
if (_anims isEqualTo [] && _variants isEqualTo false) exitWith {};
Initialize Vehicle: Call BIS function:
Sqf

Apply
[_vehicle, _variants, _anims] call BIS_fnc_initVehicle;
Where it leads:

Uses BIS_fnc_initVehicle for initialization
Called by vehicle spawn systems
Global variables modified: None
Network implications: None (local to vehicle)
Synchronization: N/A
fn_misc_updateRichPresence.sqf
What it does: Updates Discord rich presence status. Simple wrapper for Discord Rich Presence mod.

How it does that:

Check Active: Ensures rich presence is active:
Sqf

Apply
if (!isDiscordRichPresenceActive) exitWith {};
Update Presence: Calls Discord mod update function:
Sqf

Apply
Debug_1("Updating rich presence with these parameters: %1", str _updateArray);
[_updateArray] call (missionNameSpace getVariable ["DiscordRichPresence_fnc_update",{}]);
Where it leads:

Calls DiscordRichPresence_fnc_update
Called by game state systems
Global variables modified: isDiscordRichPresenceActive
Network implications: None
Synchronization: N/A
fn_outpost_cancelOutpostTask.sqf
What it does: Sets global flag to cancel outpost establishment task.

How it does that:

Set Flag: Sets global variable:
Sqf

Apply
cancelEstabTask = true;
Where it leads:

Used by outpost establishment tasks
Global variables modified: cancelEstabTask
Network implications: None
Synchronization: N/A
fn_outpost_createAa.sqf
What it does: Creates AA (Anti-Air) emplacement establishment task. Spawns unit group, drives to location, establishes AA post.

How it does that:

Resource Deduction: Deducts HR and money:
Sqf

Apply
[-_hrCost,-_moneyCost] remoteExec ["A3A_fnc_resourcesFIA",2];
Task Creation: Creates establishment task:
Sqf

Apply
private _taskId = "outpostTask" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_aaempl_deploy_desc", _displayTime],localize "STR_aaempl_deploy_header",_marker],_position,false,0,true,"Move",true] call BIS_fnc_taskCreate;
Spawn Group: Spawns AA group with transport:
Sqf

Apply
_formatX = A3A_faction_reb get "groupAaEmpl";
_groupX = [getMarkerPos respawnTeamPlayer, teamPlayer, _formatX] call A3A_fnc_spawnGroup;
// ... spawn transport truck, add to group
Wait for Arrival: Waits for group to reach location or timeout:
Sqf

Apply
waitUntil {
	sleep 1;
	(!isNil "cancelEstabTask" && {cancelEstabTask}) || 
	{_units findIf {[_x] call A3A_fnc_canFight} == -1 || 
	{{[_x] call A3A_fnc_canFight && {_x distance _position < 35}} count units _groupX > 0 ||
	{(dateToNumber date > _dateLimitNum)}}}
};
Success Logic: If arrived, establish post:
Sqf

Apply
case (_units findIf {[_x] call A3A_fnc_canFight && {_x distance _position < 35}} != -1): {
    // ... add to arrays, set marker, set garrison
    aapostsFIA pushBack _marker;
    sidesX setVariable [_marker,teamPlayer,true];
    markersX pushBack _marker;
    spawner setVariable [_marker,2,true];
    _garrison = A3A_faction_reb get "groupAaEmpl";
    garrison setVariable [_marker,_garrison,true];
    staticPositions setVariable [_marker, [_position, _direction], true];
    ["RebelControlCreated", [_marker, "aaemplacement"]] call EFUNC(Events,triggerEvent);
};
Cleanup: Removes group, truck, marker:
Sqf

Apply
theBoss hcRemoveGroup _groupX;
{
    deleteVehicle _x
} forEach units _groupX;
deleteVehicle _truckX;
deleteGroup _groupX;
Where it leads:

Calls A3A_fnc_resourcesFIA for resource management
Calls BIS_fnc_taskCreate for task creation
Calls A3A_fnc_spawnGroup for group spawning
Calls A3A_fnc_FIAinit for unit initialization
Calls A3A_fnc_citySupportChange for support changes
Called by outpost establishment systems
Global variables modified: estabNetworkId, cancelEstabTask
Network implications: Resource changes, task updates
Synchronization: Task state, resources, marker changes
fn_outpost_createAaDistance.sqf
What it does: Spawns AA emplacement at existing marker (distance variant). Places static AA gun with crew and sandbag defenses.

How it does that:

Get Garrison: Gets garrison for marker:
Sqf

Apply
private _garrison = garrison getVariable [_markerX, []];
Create Defenses: Creates sandbag defenses:
Sqf

Apply
{
    private _relativePosition = [_positionX, 4, _x] call BIS_Fnc_relPos;
    private _sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"];
    _sandbag setDir ([_sandbag, _positionX] call BIS_fnc_dirTo);
    _sandbag setVectorUp surfaceNormal position _sandbag;
    _props pushBack _sandbag;
} forEach [0, 90, 180, 270];
Create Static AA: Spawns AA gun (respects saved position/direction):
Sqf

Apply
//overriden static position and direction
private _staticPositionInfo = staticPositions getVariable [_markerX, []];
if (!(_staticPositionInfo isEqualTo [])) then {
    private _staticPosition = _staticPositionInfo select 0;
    private _staticDirection = _staticPositionInfo select 1;
    _veh = createVehicle [_aaClass, _positionX, [], 0, "CAN_COLLIDE"];
    _veh setPosATL _staticPosition;
    _veh setDir _staticDirection;
} else {
    _veh = _aaClass createVehicle _positionX;
};
Spawn Crew: Spawns garrison crew:
Sqf

Apply
_groupX = [_positionX, teamPlayer, _garrison, true, false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
_groupXUnits apply { [_x,_markerX] spawn A3A_fnc_FIAinitBases; };

// Move one crew member to AA gun
private _crewManIndex = _groupXUnits findIf  {(_x getVariable "unitType") == (A3A_faction_reb get "unitRifle")};
if (_crewManIndex != -1) then {
    private _crewMan = _groupXUnits select _crewManIndex;
    _crewMan moveInGunner _veh;
    [_crewMan, 300] spawn SCRT_fnc_common_scanHorizon;
};
Set Behavior: Configures group behavior:
Sqf

Apply
_groupX setBehaviour "AWARE";
_groupX setCombatMode "YELLOW";
Wait for Despawn: Waits for spawner deactivation or loss:
Sqf

Apply
waitUntil {
	sleep 1; 
	((spawner getVariable _markerX == 2)) or 
	({alive _x} count units _groupX == 0) or (!(_markerX in aapostsFIA))
};

if ({alive _x} count units _groupX == 0) then {
	aapostsFIA = aapostsFIA - [_markerX];
	publicVariable "aapostsFIA";
	markersX = markersX - [_markerX];
	publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", (localize "STR_notifiers_emplacement_lost")]] remoteExec ["BIS_fnc_showNotification", 0];
};
Cleanup: Removes vehicle, group, and defenses:
Sqf

Apply
if (!isNull _veh) then { 
    deleteVehicle _veh;
};

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;

{
	deleteVehicle _x;
} forEach _props;
Where it leads:

Calls BIS_Fnc_relPos for position calculation
Calls A3A_fnc_spawnGroup for group spawning
Calls A3A_fnc_FIAinitBases for unit initialization
Calls SCRT_fnc_common_scanHorizon for AI scanning
Calls A3A_fnc_AIVEHinit for vehicle initialization
Called by garrison spawning systems
Global variables modified: aapostsFIA, markersX, sidesX
Network implications: Public variables, notifications
Synchronization: Marker changes, spawn states
fn_outpost_createAt.sqf
What it does: Similar to AA emplacement but for AT (Anti-Tank) emplacements. Creates establishment task for AT post.

How it does that:

Resource Deduction: Deducts HR and money:
Sqf

Apply
[-_hrCost,-_moneyCost] remoteExec ["A3A_fnc_resourcesFIA",2];
Task Creation: Creates establishment task:
Sqf

Apply
private _taskId = "outpostTask" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_atempl_deploy_desc", _displayTime],localize "STR_atempl_deploy_header",_marker],_position,false,0,true,"Move",true] call BIS_fnc_taskCreate;
Spawn Group: Spawns AT group with transport:
Sqf

Apply
_formatX = A3A_faction_reb get "groupAtEmpl";
_groupX = [getMarkerPos respawnTeamPlayer, teamPlayer, _formatX] call A3A_fnc_spawnGroup;
// ... spawn transport
Wait for Arrival: Similar to AA wait condition:
Sqf

Apply
waitUntil {
	sleep 1;
	(!isNil "cancelEstabTask" && {cancelEstabTask}) || 
	{_units findIf {[_x] call A3A_fnc_canFight} == -1 || 
	{{alive _x && {_x distance _position < 35}} count units _groupX > 0 ||
	{(dateToNumber date > _dateLimitNum)}}}
};
Success Logic: Establish AT post:
Sqf

Apply
case (_units findIf {[_x] call A3A_fnc_canFight && {_x distance _position < 35}} != -1): {
    // ... add to arrays, set marker, set garrison
    atpostsFIA pushBack _marker; 
    publicVariable "atpostsFIA";
    sidesX setVariable [_marker,teamPlayer,true];
    markersX pushBack _marker;
    publicVariable "markersX";
    spawner setVariable [_marker,2,true];
    _garrison = A3A_faction_reb get "groupAtEmpl";
    garrison setVariable [_marker,_garrison,true];
    staticPositions setVariable [_marker, [_position, _direction], true];
    ["RebelControlCreated", [_marker, "atemplacement"]] call EFUNC(Events,triggerEvent);
};
Cleanup: Same as AA cleanup.
Where it leads:

Calls same functions as AA emplacement
Called by outpost establishment systems
Global variables modified: atpostsFIA, markersX, sidesX
Network implications: Same as AA
Synchronization: Same as AA
fn_outpost_createAtDistance.sqf
What it does: Spawns AT emplacement at existing marker. Places static AT gun with crew, sandbags, and camonet.

How it does that:

Create Defenses: Creates sandbags and camonet:
Sqf

Apply
{
    private _relativePosition = [_positionX, 4, _x] call BIS_Fnc_relPos;
    private _sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"];
    _sandbag setDir ([_sandbag, _positionX] call BIS_fnc_dirTo);
    _sandbag setVectorUp surfaceNormal position _sandbag;
    _props pushBack _sandbag;
} forEach [0, 90, 180, 270];

private _camonet = createVehicle ["CamoNet_BLUFOR_open_F", _positionX, [], 0, "CAN_COLLIDE"];
_props pushBack _camonet;
Create Static AT: Spawns AT gun (respects saved position/direction):
Sqf

Apply
//overriden static position and direction
private _staticPositionInfo = staticPositions getVariable [_markerX, []];
if (!(_staticPositionInfo isEqualTo [])) then {
    private _staticPosition = _staticPositionInfo select 0;
    private _staticDirection = _staticPositionInfo select 1;
    _veh = createVehicle [_atClass, _positionX, [], 0, "CAN_COLLIDE"];
    _veh setPosATL _staticPosition;
    _veh setDir _staticDirection;
} else {
    _veh = _atClass createVehicle _positionX;
};
Spawn Crew: Spawns garrison crew and moves one to AT gun:
Sqf

Apply
_groupX = [_positionX, teamPlayer, _garrison, true, false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
_groupXUnits apply { [_x,_markerX] spawn A3A_fnc_FIAinitBases; };

private _crewManIndex = _groupXUnits findIf  {(_x getVariable "unitType") == (A3A_faction_reb get "unitRifle")};
if (_crewManIndex != -1) then {
    private _crewMan = _groupXUnits select _crewManIndex;
    _crewMan moveInGunner _veh;
};
Set Behavior and Wait: Same as AA distance function.

Cleanup: Same as AA distance cleanup.

Where it leads:

Calls same functions as AA distance
Called by garrison spawning systems
Global variables modified: atpostsFIA, markersX, sidesX
Network implications: Same as AA
Synchronization: Same as AA
fn_outpost_createHmg.sqf
What it does: Creates HMG (Heavy Machine Gun) emplacement establishment task. Spawns unit group, drives to location, establishes HMG post.

How it does that:

Resource Deduction: Deducts HR and money:
Sqf

Apply
[-_hrCost,-_moneyCost] remoteExec ["A3A_fnc_resourcesFIA",2];
Task Creation: Creates establishment task:
Sqf

Apply
private _taskId = "outpostTask" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_hmgempl_deploy_desc", _displayTime],localize "STR_hmgempl_deploy_header",_marker],_position,false,0,true,"Move",true] call BIS_fnc_taskCreate;
Spawn Group: Spawns HMG group with transport:
Sqf

Apply
_formatX = A3A_faction_reb get "groupHmgEmpl";
_groupX = [getMarkerPos respawnTeamPlayer, teamPlayer, _formatX] call A3A_fnc_spawnGroup;
// ... spawn transport
Wait for Arrival: Similar wait condition:
Sqf

Apply
waitUntil {
	sleep 1;
	(!isNil "cancelEstabTask" && {cancelEstabTask}) || 
	{_units findIf {[_x] call A3A_fnc_canFight} == -1 || 
	{{alive _x && {_x distance _position < 35}} count units _groupX > 0 ||
	{(dateToNumber date > _dateLimitNum)}}}
};
Success Logic: Establish HMG post:
Sqf

Apply
case (_units findIf {[_x] call A3A_fnc_canFight && {_x distance _position < 35}} != -1): {
    // ... add to arrays, set marker, set garrison
    hmgpostsFIA pushBack _marker; 
    publicVariable "hmgpostsFIA";
    sidesX setVariable [_marker,teamPlayer,true];
    markersX pushBack _marker;
    publicVariable "markersX";
    spawner setVariable [_marker,2,true];
    _garrison = A3A_faction_reb get "groupHmgEmpl";
    garrison setVariable [_marker,_garrison,true];
    staticPositions setVariable [_marker, [_position, _direction], true];
    ["RebelControlCreated", [_marker, "hmgemplacement"]] call EFUNC(Events,triggerEvent);
};
Cleanup: Same cleanup process.
Where it leads:

Calls same functions as AA/AT emplacements
Called by outpost establishment systems
Global variables modified: hmgpostsFIA, markersX, sidesX
Network implications: Same as others
Synchronization: Same as others
fn_outpost_createHmgDistance.sqf
What it does: Spawns HMG emplacement at existing marker. Places static HMG with crew, sandbags, and camonet.

How it does that:

Create Defenses: Creates sandbags and camonet:
Sqf

Apply
{
    private _relativePosition = [_positionX, 4, _x] call BIS_Fnc_relPos;
    private _sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"];
    _sandbag setDir ([_sandbag, _positionX] call BIS_fnc_dirTo);
    _sandbag setVectorUp surfaceNormal position _sandbag;
    _props pushBack _sandbag;
} forEach [0, 90, 180, 270];

private _camonet = createVehicle ["CamoNet_BLUFOR_open_F", _positionX, [], 0, "CAN_COLLIDE"];
_props pushBack _camonet;
Create Static HMG: Spawns HMG gun (respects saved position/direction):
Sqf

Apply
//overriden static position and direction
private _staticPositionInfo = staticPositions getVariable [_markerX, []];
if (!(_staticPositionInfo isEqualTo [])) then {
    private _staticPosition = _staticPositionInfo select 0;
    private _staticDirection = _staticPositionInfo select 1;
    _veh = createVehicle [_mgClass, _positionX, [], 0, "CAN_COLLIDE"];
    _veh setPosATL _staticPosition;
    _veh setDir _staticDirection;
} else {
    _veh = _mgClass createVehicle _positionX;
};
Spawn Crew: Spawns garrison crew and moves one to HMG gun:
Sqf

Apply
_groupX = [_positionX, teamPlayer, _garrison, true, false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
_groupXUnits apply { [_x,_markerX] spawn A3A_fnc_FIAinitBases; };

private _crewManIndex = _groupXUnits findIf  {(_x getVariable "unitType") == (A3A_faction_reb get "unitRifle")};
if (_crewManIndex != -1) then {
    private _crewMan = _groupXUnits select _crewManIndex;
    _crewMan moveInGunner _veh;
    [_crewMan, 300] spawn SCRT_fnc_common_scanHorizon;
};
Set Behavior and Wait: Same as AA distance function.

Cleanup: Same as AA distance cleanup.

Where it leads:

Calls same functions as AA distance
Called by garrison spawning systems
Global variables modified: hmgpostsFIA, markersX, sidesX
Network implications: Same as AA
Synchronization: Same as AA
fn_outpost_createRoadblock.sqf
What it does: Creates roadblock establishment task. Spawns unit group, drives to location, establishes roadblock with barricade.

How it does that:

Resource Deduction: Deducts HR and money:
Sqf

Apply
[-_hrCost,-_moneyCost] remoteExec ["A3A_fnc_resourcesFIA",2];
Task Creation: Creates establishment task:
Sqf

Apply
private _taskId = "outpostTask" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_roadblock_deploy_desc", _displayTime],localize "STR_roadblock_deploy_header",_marker],_position,false,0,true,"Move",true] call BIS_fnc_taskCreate;
Spawn Group: Spawns roadblock group with transport:
Sqf

Apply
private _riflemanType = A3A_faction_reb get "unitRifle";
private _squadType = A3A_faction_reb get "groupSquad";
_formatX = [_riflemanType] + _squadType;
_groupX = [getMarkerPos respawnTeamPlayer, teamPlayer, _formatX] call A3A_fnc_spawnGroup;
// ... spawn transport
Wait for Arrival: Similar wait condition:
Sqf

Apply
waitUntil {
	sleep 1;
	(!isNil "cancelEstabTask" && {cancelEstabTask}) || 
	{_units findIf {[_x] call A3A_fnc_canFight} == -1 || 
	{{alive _x && {_x distance _position < 35}} count units _groupX > 0 ||
	{(dateToNumber date > _dateLimitNum)}}}
};
Success Logic: Establish roadblock:
Sqf

Apply
case (_units findIf {[_x] call A3A_fnc_canFight && {_x distance _position < 35}} != -1): {
    // ... add to arrays, set marker, set garrison
    roadblocksFIA pushBack _marker; 
    publicVariable "roadblocksFIA";
    sidesX setVariable [_marker,teamPlayer,true];
    markersX pushBack _marker;
    publicVariable "markersX";
    spawner setVariable [_marker,2,true];
    _garrison = [_riflemanType] + _squadType;
    garrison setVariable [_marker,_garrison,true];
    ["RebelControlCreated", [_marker, "roadblock"]] call EFUNC(Events,triggerEvent);
};
Cleanup: Same cleanup process.
Where it leads:

Calls same functions as other emplacements
Called by outpost establishment systems
Global variables modified: roadblocksFIA, markersX, sidesX
Network implications: Same as others
Synchronization: Same as others
fn_outpost_createRoadblockDistance.sqf
What it does: Spawns roadblock at existing marker. Places barricade on road and optionally spawns armed vehicle with crew.

How it does that:

Find Road: Searches for nearby road:
Sqf

Apply
private _radiusX = 1;
while {true} do {
    _road = _positionX nearRoads _radiusX;
    if (count _road > 0) exitWith {};
    _radiusX = _radiusX + 5;
};
Calculate Positions: Gets road direction and positions:
Sqf

Apply
private _roadcon = roadsConnectedto (_road select 0);
private _dirveh = if(count _roadcon > 0) then {[_road select 0, _roadcon select 0] call BIS_fnc_DirTo} else {random 360};
private _roadPosition = getPos (_road select 0);
private _barricadePosition = if(count _roadcon > 0) then { getPos (_roadcon select 0); } else {[(_roadPosition select 0) - 2, (_roadPosition select 1) + 2, 0]};
Create Barricade: Creates road barricade:
Sqf

Apply
private _barricade = "Land_Barricade_01_10m_F" createVehicle _barricadePosition;
_barricade setDir _dirveh;
_barricade setVectorUp surfaceNormal position _barricade;
Spawn Vehicle (Optional): Spawns armed vehicle if rifleman in garrison:
Sqf

Apply
if (_riflemanType in _garrison) then {
    _veh = _typeVehX createVehicle getPos (_road select 0);
    _veh setDir _dirveh + 90;
    _veh lock 3;
    [_veh, teamPlayer] call A3A_fnc_AIVEHinit;
};
Spawn Garrison: Spawns roadblock garrison:
Sqf

Apply
_groupX = [_positionX, teamPlayer, _garrison, true, false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;

{
    [_x,_markerX] spawn A3A_fnc_FIAinitBases; 
} forEach _groupXUnits;

// Move crew to vehicle gunner position
private _crewManIndex = _groupXUnits findIf {(_x getVariable "unitType") == (A3A_faction_reb get "unitRifle")};
if (_crewManIndex != -1) then {
    private _crewMan = _groupXUnits select _crewManIndex;
    _crewMan moveInGunner _veh;
    sleep 1;
    _crewMan lookAt (_crewMan getRelPos [100, _dirveh]);
};
Wait for Despawn: Wait for spawner deactivation or loss:
Sqf

Apply
waitUntil {
	sleep 1; 
	((spawner getVariable _markerX == 2)) or 
	({alive _x} count units _groupX == 0) or (!(_markerX in roadblocksFIA))
};

if ({alive _x} count units _groupX == 0) then {
	roadblocksFIA = roadblocksFIA - [_markerX];
	publicVariable "roadblocksFIA";
	markersX = markersX - [_markerX];
	publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", (localize "STR_notifiers_roadblock_lost")]] remoteExec ["BIS_fnc_showNotification", 0];
};
Cleanup: Remove barricade, vehicle, and group:
Sqf

Apply
deleteVehicle _barricade;

if (!isNull _veh) then { 
    deleteVehicle _veh;
};

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;
Where it leads:

Calls BIS_fnc_DirTo for road direction
Calls A3A_fnc_spawnGroup for group spawning
Calls A3A_fnc_FIAinitBases for unit initialization
Calls A3A_fnc_AIVEHinit for vehicle initialization
Called by garrison spawning systems
Global variables modified: roadblocksFIA, markersX, sidesX
Network implications: Same as other emplacements
Synchronization: Same as other emplacements
fn_outpost_createWatchpost.sqf
What it does: Creates watchpost establishment task. Spawns sniper group, drives to location, establishes observation post.

How it does that:

Resource Deduction: Deducts HR and money:
Sqf

Apply
[-_hrCost,-_moneyCost] remoteExec ["A3A_fnc_resourcesFIA",2];
Task Creation: Creates establishment task:
Sqf

Apply
private _taskId = "outpostTask" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_watchpost_deploy_desc", _displayTime],localize "STR_watchpost_deploy_header",_marker],_position,false,0,true,"Move",true] call BIS_fnc_taskCreate;
Spawn Group: Spawns sniper group with transport:
Sqf

Apply
private _typeGroup = A3A_faction_reb get "groupSniper";
private _typeVehX = (A3A_faction_reb get "vehiclesBasic") select 0;
_groupX = [getMarkerPos respawnTeamPlayer, teamPlayer, _typeGroup] call A3A_fnc_spawnGroup;
// ... spawn transport
Wait for Arrival: Similar wait condition:
Sqf

Apply
waitUntil {
	sleep 1;
	(!isNil "cancelEstabTask" && {cancelEstabTask}) || 
	{_units findIf {[_x] call A3A_fnc_canFight} == -1 || 
	{{alive _x && {_x distance _position < 35}} count units _groupX > 0 ||
	{(dateToNumber date > _dateLimitNum)}}}
};
Success Logic: Establish watchpost:
Sqf

Apply
case (_units findIf {[_x] call A3A_fnc_canFight && {_x distance _position < 35}} != -1): {
    // ... add to arrays, set marker
    watchpostsFIA pushBack _marker; 
    publicVariable "watchpostsFIA";
    sidesX setVariable [_marker,teamPlayer,true];
    markersX pushBack _marker;
    publicVariable "markersX";
    spawner setVariable [_marker,2,true];
    ["RebelControlCreated", [_marker, "watchpost"]] call EFUNC(Events,triggerEvent);
};
Cleanup: Same cleanup process.
Where it leads:

Calls same functions as other emplacements
Called by outpost establishment systems
Global variables modified: watchpostsFIA, markersX, sidesX
Network implications: Same as others
Synchronization: Same as others
fn_outpost_createWatchpostDistance.sqf
What it does: Spawns watchpost at existing marker. Places sniper group with campfire and tent, sets stealth behavior.

How it does that:

Spawn Snipers: Spawns sniper group:
Sqf

Apply
private _typeGroup = A3A_faction_reb get "groupSniper";
_groupX = [_positionX, teamPlayer, _typeGroup] call A3A_fnc_spawnGroup;
_groupX setBehaviour "STEALTH";
_groupX setCombatMode "GREEN";
{
	[_x,_markerX] spawn A3A_fnc_FIAinitBases;
} forEach units _groupX;
Create Props: Places campfire and tent:
Sqf

Apply
private _campfire = createVehicle ["Land_Campfire_F", _positionX];
private _tent = ["Land_TentDome_F", getPosWorld _campfire] call BIS_fnc_createSimpleObject;
_tent setDir (random 360);
_tent setPos [(getPos _tent select 0) + 4, (getPos _tent select 1) + 4, (getPos _tent select 2) - 0.2]; 

_props pushBack _campfire;
_props pushBack _tent;
Set Vector Up: Ensures props are flat on terrain:
Sqf

Apply
{
	_x setVectorUp surfaceNormal position _x;
} forEach _props;
Wait for Despawn: Wait for spawner deactivation or loss:
Sqf

Apply
waitUntil {
	sleep 1; 
	((spawner getVariable _markerX == 2)) or 
	({alive _x} count units _groupX == 0) or (!(_markerX in watchpostsFIA))
};

if ({alive _x} count units _groupX == 0) then {
	watchpostsFIA = watchpostsFIA - [_markerX];
	publicVariable "watchpostsFIA";
	markersX = markersX - [_markerX];
	publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", (localize "STR_notifiers_watchpost_lost")]] remoteExec ["BIS_fnc_showNotification", 0];
};
Cleanup: Remove props and group:
Sqf

Apply
{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;

{
	deleteVehicle _x;
} forEach _props;
Where it leads:

Calls BIS_fnc_createSimpleObject for tent
Calls A3A_fnc_spawnGroup for group spawning
Calls A3A_fnc_FIAinitBases for unit initialization
Called by garrison spawning systems
Global variables modified: watchpostsFIA, markersX, sidesX
Network implications: Same as other emplacements
Synchronization: Same as other emplacements
fn_paradrop_getPlayersToParadrop.sqf
What it does: Gets list of players signed up for paradrop who are at base, alive, and can fight.

How it does that:

Check Attendants: Ensures players are signed up:
Sqf

Apply
if (count paradropAttendants == 0) exitWith {
    [
        localize "STR_A3AP_paradrop_header", 
        localize "STR_A3AP_paradrop_no_players"
    ] remoteExec ["SCRT_fnc_misc_deniedHint", theBoss];
    []
};
Get Ready Players: Convert UIDs to unit objects and filter:
Sqf

Apply
private _readyPlayers = paradropAttendants apply {_x call BIS_fnc_getUnitByUID};
_readyPlayers = _readyPlayers select {_x distance2D (getMarkerPos "Synd_HQ") < 50 && {vehicle _x == _x && {[_x] call A3A_fnc_canFight}} };
Validation: Check if any players are ready:
Sqf

Apply
if (isNil "_readyPlayers" || {count _readyPlayers == 0}) then {
    [
        localize "STR_A3AP_paradrop_header", 
        localize "STR_A3AP_paradrop_players_condition"
    ] remoteExec ["SCRT_fnc_misc_deniedHint", theBoss];
    []
};
Return Ready Players:
Sqf

Apply
Info_1("Paradrop players: %1", str _readyPlayers);
_readyPlayers
Where it leads:

Calls BIS_fnc_getUnitByUID to get unit from UID
Calls SCRT_fnc_misc_deniedHint for denial messages
Called by paradrop preparation
Global variables modified: paradropAttendants
Network implications: Denied hint sent to TheBoss
Synchronization: N/A
fn_paradrop_jump.sqf
What it does: Handles player parachute jump with backpack management. Detaches backpack, attaches to holder, attaches to player during jump, reattaches after landing.

How it does that:

Backpack Management: Checks if player has backpack:
Sqf

Apply
private _backpackClass = backpack _jumper;
private _packHolder = nil;
private _backPackitems = nil;
if (_backpackClass != "") then {
    _backPackitems = backpackItems _jumper;
    _packHolder = createVehicle ["GroundWeaponHolder", [0,0,0], [], 0, "CAN_COLLIDE"];
    _packHolder addBackpackCargoGlobal [_backpackClass, 1];
    _packHolder attachTo [_jumper, [-0.12,-0.02,-.74], "pelvis"]; 
	_packHolder setVectorDirAndUp [[0,-1,-0.05],[0,0,-1]];
    removeBackpack _jumper;
};
Add Parachute: Adds parachute:
Sqf

Apply
_jumper addBackpack "b_parachute";
Reattach Holder on Chute: Spawn process to reattach holder after parachute opens:
Sqf

Apply
if (!isNil "_packHolder") then {  
    [_jumper, _packHolder] spawn _fnc_reattachPackHolderOnChute;
};
Wait for Ground: Waits until landing:
Sqf

Apply
waitUntil {isTouchingGround _jumper || {(getPos _jumper select 2) < 1}};
Restore Backpack: After landing, restore original backpack with items:
Sqf

Apply
if (!isNil "_backPackClass" && {!isNil "_backPackitems"}) then {
    _jumper addBackpack _backpackClass;
    clearAllItemsFromBackpack _jumper;
    {_jumper addItemToBackpack _x} forEach _backPackitems;
};
Where it leads:

Uses attachment and vector functions for backpack holder
Called by paradrop jump sequence
Global variables modified: None
Network implications: None (local to jumper)
Synchronization: N/A
fn_paradrop_movePlayerToPlane.sqf
What it does: Moves player to paradrop plane with timeout and validation. Includes cancellation via ESC.

How it does that:

Input Timeout: Setup 5-second window for cancellation:
Sqf

Apply
private _inputTimeout = time + TIME_WINDOW;
while {true} do {
    if (time > _inputTimeout) exitWith {};
    if (isMoveToPlaneCancelled) exitWith {};
    cutText [...,"BLACK",0.0001,true,true];
};
Check Paradrop Plane: Waits for plane existence:
Sqf

Apply
private _waitTimeout = time + 30;
waitUntil {sleep 0.01; !(isNil "paradropPlane") || time > _waitTimeout};

if (isNil "paradropPlane") exitWith {
    cutText ["","BLACK IN", 2];
    2 fadeSound 1;
    [localize "STR_A3AP_paradrop_header", localize "STR_A3AP_paradrop_abort_plane"] call SCRT_fnc_misc_deniedHint;
};
Validate Plane: Checks if plane is operational:
Sqf

Apply
if (!canMove paradropPlane || {!alive paradropPlane || {!alive (driver paradropPlane)}}) exitWith {
    cutText ["","BLACK IN", 2];
    2 fadeSound 1;
    [localize "STR_A3AP_paradrop_header", localize "STR_A3AP_paradrop_abort_plane_noncapable"] call SCRT_fnc_misc_deniedHint;
};
Check Seats: Calculates available cargo seats:
Sqf

Apply
private _totalSeats = [(A3A_faction_reb get "vehiclesPlane") # 0, true] call BIS_fnc_crewCount;
private _occupiedSeats = count (crew paradropPlane);

if ((_totalSeats - _occupiedSeats) < 0) exitWith {
    cutText ["","BLACK IN", 2];
    2 fadeSound 1;
    [localize "STR_A3AP_paradrop_header", localize "STR_A3AP_paradrop_abort_plane_no_free_seats"] call SCRT_fnc_misc_deniedHint;
};
Move to Plane: Attempts to move player multiple times:
Sqf

Apply
player moveInCargo paradropPlane;

private _earlyEscape = false;
private _iterations = 0;

while {true} do {
    if (vehicle player == paradropPlane) exitWith {};
    if (_iterations > 30) exitWith {_earlyEscape = true;};
    if (isNil "paradropPlane" || {!alive paradropPlane || {!([player] call A3A_fnc_canFight)}}) exitWith {
        _earlyEscape = true;
    };

    player moveInCargo paradropPlane;
    _iterations = _iterations + 1;
    sleep 0.05;
};
Jump Preparation: After successful boarding:
Sqf

Apply
sleep 1;
cutText [localize "STR_cut_text_paradrop_notification_3","BLACK IN", 3, true, true];
5 fadeSound 1;
Wait for Jump: Waits until player is not in plane:
Sqf

Apply
waitUntil {sleep 0.001; isNil "paradropPlane" || {vehicle player != paradropPlane}};

if (!([player] call A3A_fnc_canFight) || {isNil "paradropPlane"}) exitWith {};

player call SCRT_fnc_paradrop_jump;
Where it leads:

Calls SCRT_fnc_misc_deniedHint for denial messages
Calls SCRT_fnc_paradrop_jump for actual jump
Called by paradrop system
Global variables modified: isMoveToPlaneCancelled, moveMenu
Network implications: None (local to player)
Synchronization: N/A
fn_paradrop_prepare.sqf
What it does: Prepares paradrop by getting ready players and moving them to plane.

How it does that:

Get Ready Players: Calls function to get validated players:
Sqf

Apply
private _players = [] call SCRT_fnc_paradrop_getPlayersToParadrop;

if (_players isEqualTo []) exitWith {};
Get Plane and Seats: Calculates available seats:
Sqf

Apply
private _plane = (A3A_faction_reb get "vehiclesPlane") # 0;
private _totalSeats = [_plane, true] call BIS_fnc_crewCount;
private _crewSeats = [_plane, false] call BIS_fnc_crewCount;
private _cargoSeats = _totalSeats - _crewSeats;
Limit Players if Needed: Shuffle and limit if not enough seats:
Sqf

Apply
if (_cargoSeats < count _players) then {
    _players = [_players] call BIS_fnc_arrayShuffle;
};
Move Players: Remote execute move function for each player:
Sqf

Apply
{
   [] remoteExec ["SCRT_fnc_paradrop_movePlayerToPlane", _x];
} forEach _players;
Where it leads:

Calls SCRT_fnc_paradrop_getPlayersToParadrop for player list
Calls BIS_fnc_arrayShuffle for randomization
Calls SCRT_fnc_paradrop_movePlayerToPlane for player movement
Called by paradrop initiation
Global variables modified: None
Network implications: Remote execution of move function
Synchronization: N/A
fn_rally_deleteRallyPoint.sqf
What it does: Deletes rally point and cleans up all associated objects and markers.

How it does that:

Update State: Sets rally point as not placed:
Sqf

Apply
isRallyPointPlaced = false;
publicVariable "isRallyPointPlaced";
Delete Props: Removes all prop objects:
Sqf

Apply
{deleteVehicle _x} forEach rallyProps;
rallyProps = nil;
publicVariable "rallyProps";
Delete Root Object: Removes main rally point object:
Sqf

Apply
deleteVehicle rallyPointRoot;
rallyPointRoot = nil;
publicVariable "rallyPointRoot";
Delete Markers: Removes rally marker:
Sqf

Apply
deleteMarker rallyPointMarker;
deleteMarker "RallyPointMarker";
publicVariable "rallyPointMarker";
Notify: Sends message to all players:
Sqf

Apply
[petros, "support", localize "STR_comms_mp_RP_ran_out"] remoteExec ["A3A_fnc_commsMP", 0];
Where it leads:

Calls A3A_fnc_commsMP for notification
Called by rally point expiration or deletion
Global variables modified: isRallyPointPlaced, rallyProps, rallyPointRoot, rallyPointMarker
Network implications: Multiple publicVariable calls, remoteExec for notification
Synchronization: State changes broadcast to all clients
fn_rally_placeRallyPoint.sqf
What it does: Places a rally point with props (backpacks, sleeping bag, ammo box) and marker. Sets up lighting and remaining travels.

How it does that:

Check Spawn Count: Validates rally point spawn count:
Sqf

Apply
if (rallyPointSpawnCount isEqualTo 0) exitWith { ... };
Create Root Object: Creates main rally point object:
Sqf

Apply
private _rallyPointClass = FactionGet(reb,"rallyPoint");
rallyPointRoot = [_rallyPointClass, _posWorld] call BIS_fnc_createSimpleObject;
private _rootPos = position rallyPointRoot;
private _rootHeight = (_rootPos select 2) - 0.185;
_rootPos set [2, _rootHeight];
rallyPointRoot setPos _rootPos;
Create Props: Places decorative props:
Sqf

Apply
// Backpacks
private _backpack1 = ["B_Carryall_oli", _posWorld] call BIS_fnc_createSimpleObject;
// ... position and rotate
private _backpack2 = ["B_Carryall_oli", _posWorld] call BIS_fnc_createSimpleObject;
// ... position and rotate

// Sleeping bag
private _bag = ["Item_Sleeping_bag_folded_01", _posWorld] call BIS_fnc_createSimpleObject;
// ... position

// Ammo box
private _ammobox = ["Land_Ammobox_rounds_F", _posWorld] call BIS_fnc_createSimpleObject;
// ... position and rotate
Add Light: Attach light to rally point:
Sqf

Apply
[rallyPointRoot, [0, 0, -0.5], 0.2] remoteExec ["SCRT_fnc_common_attachLightSource", 0, rallyPointRoot];
Create Marker: Creates rally marker:
Sqf

Apply
rallyPointMarker = createMarker ["RallyPointMarker", _rootPos];
rallyPointMarker setMarkerType "hd_join";
rallyPointMarker setMarkerSize [1, 1];
rallyPointMarker setMarkerText (format [localize "STR_marker_RP", str rallyPointSpawnCount]);
rallyPointMarker setMarkerColor "colorIndependent";
rallyPointMarker setMarkerAlpha 1;
sidesX setVariable [rallyPointMarker,teamPlayer,true];
publicVariable "rallyPointMarker";
Store Props: Adds props to array and publicVariable:
Sqf

Apply
rallyProps append [_backpack1, _backpack2, _bag, _ammobox];
publicVariable "rallyProps";
Set Remaining Travels: Initialize travel count:
Sqf

Apply
rallyPointRoot setVariable ["remainingTravels", rallyPointSpawnCount, true];
publicVariable "rallyPointRoot";
Where it leads:

Calls BIS_fnc_createSimpleObject for props
Calls SCRT_fnc_common_attachLightSource for lighting
Calls A3A_fnc_commsMP for notification
Called by rally point placement systems
Global variables modified: rallyPointRoot, rallyProps, rallyPointMarker
Network implications: remoteExec for light, publicVariable for state
Synchronization: Rally point state synchronized
fn_rally_toggleRallyPoint.sqf
What it does: Toggles rally point placement/removal. If placed, can delete with partial refund. If not placed, creates new rally point.

How it does that:

Check Spawn Count: Validates rally point spawn count:
Sqf

Apply
if (rallyPointSpawnCount isEqualTo 0) exitWith { ... };
If Already Placed: Handle deletion:
Sqf

Apply
if (!isNil "isRallyPointPlaced" && {isRallyPointPlaced}) then {
    private _hqMarkerPos = getMarkerPos "Synd_HQ";
    private _rallyPointMarkerPos = getMarkerPos "RallyPointMarker";

    // Check if at HQ or rally point
    if (player distance2D _hqMarkerPos > 50 && {player distance2D _rallyPointMarkerPos > 50}) exitWith {
        [localize "STR_dialogs_RP_header", localize "STR_dialogs_RP_abolish_fail"] call SCRT_fnc_misc_deniedHint;
    };

    // Calculate refund
    private _cost = [_rallyPointClass] call A3A_fnc_vehiclePrice;
    private _remainingTravels = rallyPointRoot getVariable ["remainingTravels", 0];
    if (_remainingTravels > 0) then {
        private _finalCost = _cost * _remainingTravels;
        if (_finalCost < 100) then {
            _finalCost = 100;
        };
        [0, round (_finalCost/1.3)] remoteExec ["A3A_fnc_resourcesFIA",2];
    };

    // Delete rally point
    isRallyPointPlaced = false;
    publicVariable "isRallyPointPlaced";
    { deleteVehicle _x; } forEach rallyProps;
    rallyProps = nil;
    publicVariable "rallyProps";
    deleteVehicle rallyPointRoot;
    rallyPointRoot = nil;
    publicVariable "rallyPointRoot";
    deleteMarker rallyPointMarker;
    deleteMarker "RallyPointMarker";
    publicVariable "rallyPointMarker";

    [petros, "support", localize "STR_dialogs_RP_abolish_success"] remoteExec ["A3A_fnc_commsMP", 0];
};
If Not Placed: Handle placement:
Sqf

Apply
else {
    private _cost = [_rallyPointClass] call A3A_fnc_vehiclePrice;
    private _finalCost = _cost * rallyPointSpawnCount;
    private _resourcesFIA = server getVariable "resourcesFIA";    

    if (_resourcesFIA < _finalCost) exitWith { ... };
    if ([(position player), 50] call A3A_fnc_enemyNearCheck) exitWith { ... };
    if (player != theBoss) exitWith { ... };
    if (!isNull objectParent player) exitWith { ... };

    // Setup placement
    private _extraMessage = format  [localize "STR_dialogs_RP_select_pos", _cost, A3A_faction_civ get "currencySymbol"];
    private _fnc_placed = {
        params ["_vehicle", "_cost"];
        if (_vehicle isEqualTo objNull) exitWith {};
        
        // Deduct cost
        private _factionMoney = server getVariable "resourcesFIA";
        if (player == theBoss && {_cost <= _factionMoney}) then {
            [0,(-1 * _cost)] remoteExec ["A3A_fnc_resourcesFIA",2];
        }
        else {
            [-1 * _cost] call A3A_fnc_resourcesPlayer;
            _vehicle setVariable ["ownerX",getPlayerUID player,true];
        };

        // Place rally point
        private _posWorld = getPosWorld _vehicle;
        deleteVehicle _vehicle;
        [_posWorld] call SCRT_fnc_rally_placeRallyPoint;

        isRallyPointPlaced = true;
        publicVariable "isRallyPointPlaced";
        petros sideRadio "SentGenBaseUnlockRespawn";
        [petros, "support", localize "STR_dialogs_RP_success"] remoteExec ["A3A_fnc_commsMP", 0];
    };

    // Check function for placement validation
    private _fnc_check = {
        [[(position player), 50] call A3A_fnc_enemyNearCheck, localize "STR_dialogs_RP_enemies_near_placement_fail"];
    };

    // Start placement UI
    ["Land_TentSolar_01_folded_olive_F", _fnc_placed, _fnc_check, [_cost], nil, nil, nil, _extraMessage] call HR_GRG_fnc_confirmPlacement;
};
Where it leads:

Calls SCRT_fnc_misc_deniedHint for denial messages
Calls A3A_fnc_resourcesFIA for resource management
Calls A3A_fnc_resourcesPlayer for personal payment
Calls SCRT_fnc_rally_placeRallyPoint for placement
Calls A3A_fnc_enemyNearCheck for safety check
Calls HR_GRG_fnc_confirmPlacement for placement UI
Called by rally point toggle action
Global variables modified: isRallyPointPlaced, rallyProps, rallyPointRoot, rallyPointMarker
Network implications: remoteExec for resource changes, publicVariable for state
Synchronization: State changes broadcast to all clients
fn_rally_travelToRallyPoint.sqf
What it does: Teleports player group to rally point with travel countdown. Consumes remaining travels, deletes if zero.

How it does that:

Validation: Checks various conditions:
Sqf

Apply
if (isNil "rallyProps" || {rallyProps isEqualTo []}) exitWith { ... };
if (vehicle player != player) exitWith { ... };
if (player getVariable ["incapacitated",false] || {!alive player}) exitWith { ... };
if !((vehicle player getVariable "SA_Tow_Ropes") isEqualTo objNull) exitWith { ... };
if (player != player getVariable ["owner",player]) exitWith { ... };
if (player distance2D (getMarkerPos "Synd_HQ") > 50) exitWith { ... };
Check Remaining Travels: Gets travel count and checks:
Sqf

Apply
private _remainingTravels = rallyPointRoot getVariable ["remainingTravels", 0];
if (_remainingTravels < 1) exitWith {
    [localize "STR_A3AP_rally_header", localize "STR_A3AP_rally_not_enough_points"] call SCRT_fnc_misc_deniedHint;
    remoteExecCall ["SCRT_fnc_rally_deleteRallyPoint",2];
};
Get Rally Position: Gets position of first prop:
Sqf

Apply
private _rallyPoint = rallyProps select 0;
private _rallyPosition = position _rallyPoint;
Check Enemy Proximity: Ensures rally point is safe:
Sqf

Apply
if ([position _rallyPoint, 50] call A3A_fnc_enemyNearCheck) exitWith {
    [localize "STR_A3AP_rally_header", localize "STR_A3AP_rally_enemy_surrounding"] call SCRT_fnc_misc_deniedHint;
};
Calculate Travel Time: Based on distance:
Sqf

Apply
private _positionX = [_rallyPosition, 10, random 360] call BIS_fnc_relPos;
private _distanceX = round (((player distance2D _positionX)/200)/2);
Countdown Timer: Shows countdown on screen:
Sqf

Apply
disableUserInput true; 
cutText [format [localize "STR_cut_RP_FT_timer", _distanceX],"BLACK",1]; 
sleep 1;

private _timePassed = 0;
while {_timePassed < _distanceX} do {
    cutText [format [localize "STR_cut_RP_FT_timer", (_distanceX - _timePassed)],"BLACK",0.0001];
    sleep 1;
    _timePassed = _timePassed + 1;
};
Teleport Group: Move all group members:
Sqf

Apply
{
    _unit = _x;
    if ((!isPlayer _unit) || {_unit == player}) then {
        _unit allowDamage false;
        if (!(_unit getVariable ["incapacitated",false])) then {
            _positionX = _positionX findEmptyPosition [1,25,typeOf _unit];
            _unit setPosATL _positionX;
            if (isPlayer leader _unit) then {_unit setVariable ["rearming",false]};
            _unit doWatch objNull;
            _unit doFollow leader _unit;
        } else {
            _positionX = _positionX findEmptyPosition [1,50,typeOf _unit];
            _unit setPosATL _positionX;
        };
    };
} forEach units _groupX;
Update Travels: Decrement and check for deletion:
Sqf

Apply
private _remainingTravels = _remainingTravels - 1;
rallyPointRoot setVariable ["remainingTravels", _remainingTravels, true];
rallyPointMarker setMarkerText (format [localize "STR_marker_RP", str _remainingTravels]);

if (_remainingTravels < 1) then {
    remoteExecCall ["SCRT_fnc_rally_deleteRallyPoint",2];
};
Re-enable Damage: After delay:
Sqf

Apply
sleep 5;
{_x allowDamage true} forEach units _groupX;
Where it leads:

Calls SCRT_fnc_misc_deniedHint for denial messages
Calls BIS_fnc_relPos for position calculation
Calls SCRT_fnc_rally_deleteRallyPoint for cleanup
Called by rally travel action
Global variables modified: remainingTravels on rallyPointRoot
Network implications: remoteExec for deletion
Synchronization: Travel count synchronized via setVariable

Rivals System Documentation
Constants.inc
File: A3A/addons/scrt/Rivals/Constants.inc Line Count: 17 lines

Constants Defined
These are preprocessor macros defining constants used throughout the Rivals system:

Sqf

Apply
#define RIVALS_CITY_PART 0.3
Description: 30% of all non-frontline cities will initially contain Rivals cells. Used in 
fn_rivals_activate.sqf
 to calculate _rivalsCityCount.

Sqf

Apply
#define RIVALS_CONTROL_PART 0.15
Description: 15% of all eligible control points will initially contain Rivals hideouts. Used in 
fn_rivals_activate.sqf
 to calculate _rivalsControlCount.

Event Type Constants: These define event IDs for different Rivals activity types:

Sqf

Apply
#define CARDEMO 100          // Car bomb/IED event
#define UAVGRENADE 200       // UAV-based grenade attack
#define ROVINGMORTAR 300     // Mortar bombardment
#define HELIRAID 400         // Helicopter assault
#define SKIRMISH_OCCVSRIV 500 // Occ vs Rivals skirmish
#define SKIRMISH_POLICEVSRIV 600 // Police vs Rivals skirmish
Activity Level Constants: These define activity thresholds (inverted - lower number = more active):

Sqf

Apply
#define INSIGNIFICANT_ACTIVITY 5    // Least active
#define MODERATE_ACTIVITY 4         // Moderate
#define CONSPICIOUS_ACTIVITY 3      // Conspicuous
#define INTRUSIVE_ACTIVITY 2        // Intrusive
#define OMNIPRESENT_ACTIVITY 1      // Most active
fn_rivals_activate.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_activate.sqf Line Count: 88 lines

Function: [] remoteExecCall ["SCRT_fnc_rivals_activate", 2];
What it does:
Activates the Rivals faction system, setting up their initial presence by selecting hideouts and cell locations in non-friendly cities and control points. This is the primary initialization function for the Rivals system.

How it does that:
1. Initial Setup and Global Variable Initialization:

Sqf

Apply
#include "..\defines.inc"
FIX_LINE_NUMBERS()

#include "Constants.inc"
Info_1("Activateing %1", A3A_faction_riv get "name");
Includes necessary header files for line number fix and constants
Logs activation message with faction name
2. Enable Rivals Discovery:

Sqf

Apply
areRivalsDiscovered = true;
publicVariable "areRivalsDiscovered";
Sets the global discovery flag to true
Uses publicVariable to sync this to all clients
This triggers other systems that depend on rivals being discovered
3. Initial Activity Handicap:

Sqf

Apply
[85, (100/baseRivalsDecay), true] call SCRT_fnc_rivals_reduceActivity;
[] spawn A3A_fnc_statistics;
Calls fn_rivals_reduceActivity with 85 points of reduction over (100/baseRivalsDecay) minutes
The true parameter means silent update (no visual notification)
Updates statistics for all players
4. Location Selection Logic:

Sqf

Apply
private _nearSites = outposts + milbases + airportsX + resourcesX + factories + citiesX;
private _locations = [];
private _radius = (sqrt 2 / 2 * worldSize) / (3 + 2);
Creates array of all friendly base sites to avoid
Calculates operational radius based on world size
5. Frontline City Selection:

Sqf

Apply
private _frontLineCities = citiesX select {([_x] call A3A_fnc_isFrontline && {sidesX getVariable [_x,sideUnknown] != teamPlayer})};
Filters cities that are frontline and not controlled by rebels
These will ALL get Rivals cells automatically
6. Non-Frontline City Filtering:

Sqf

Apply
private _cities = (citiesX select {!(_x in _frontLineCities) && {sidesX getVariable [_x,sideUnknown] != teamPlayer}}) call BIS_fnc_arrayShuffle;
Selects cities that are NOT frontline AND not controlled by rebels
Shuffles the array for random selection
Used to calculate _rivalsCityCount = round ((count _cities) * RIVALS_CITY_PART)
7. Control Point Filtering:

Sqf

Apply
private _controls = (controlsX select {
    private _control = _x;
    private _controlPos = getMarkerPos _control;
    !(isOnRoad _controlPos) && {!((_controlPos) distance2D (getMarkerPos respawnTeamPlayer) < 1000) && {_nearSites findIf {(getMarkerPos _x) distance2D _controlPos < _radius} != -1}}
}) call BIS_fnc_arrayShuffle;
Filters controls that are:
NOT on roads
NOT within 1000m of HQ (respawnTeamPlayer)
Within operational radius of a friendly site
Shuffles for random selection
Used to calculate _rivalsControlCount = round (count _controls * RIVALS_CONTROL_PART)
8. Location Pool Population:

Sqf

Apply
for "_i" from 1 to _rivalsCityCount do {
    private _cityArray = _cities select {!(_x in _locations)};
    if (count _cityArray == 0) exitWith {
        Error("Location parsing error - no city outside of locations pool left.");
    };
    _locations pushBack (_cityArray#0);
};

for "_i" from 1 to _rivalsControlCount do {
    private _controlArray = _controls select {!(_x in _locations)};
    if (count _controlArray == 0) exitWith {
        Error("Location parsing error - no control point outside of locations pool left.");
    };
    _locations pushBack (_controlArray#0);
};
Iterates through cities/controls, selecting random ones not already in location pool
Error handling if pool runs dry (shouldn't happen with proper selection)
9. Final Location Map Creation:

Sqf

Apply
_locations append _frontLineCities;
rivalsLocationsMap = createHashMapFromArray (_locations apply {[_x, false]});
publicVariable "rivalsLocationsMap";
Adds all frontline cities to location pool
Creates hash map with location as key and false (not discovered) as value
Syncs hash map to all clients
10. Player Notification:

Sqf

Apply
[ 
    format [(localize "STR_antistasi_rivals_hint_header"), A3A_faction_riv get "name"], 
    format [(localize "STR_antistasi_rivals_hint_text"), A3A_faction_riv get "name", ([] call SCRT_fnc_misc_getWorldName)]
] remoteExecCall ["A3A_fnc_customHint", [teamPlayer, civilian]];
Sends notification to all rebel players and civilians
Includes faction name and world name
Where it leads:
Functions Called:

SCRT_fnc_rivals_reduceActivity - Reduces rivals activity by specified amount
A3A_fnc_statistics - Updates player statistics HUD
A3A_fnc_isFrontline - Checks if a location is on the frontline
A3A_fnc_localizar - Gets localized name for markers (in 
fn_rivals_destroyLocation.sqf
)
A3A_fnc_customHint - Shows hint to players
SCRT_fnc_misc_getWorldName - Returns current world name
Global Variables Modified:

areRivalsDiscovered (public)
rivalsLocationsMap (public)
areRivalsDefeated (if called again, but typically not)
Dependencies:

Requires A3A_faction_riv to be initialized with proper keys
Requires baseRivalsDecay to be set
Requires inactivityStackRivals to exist
Requires marker arrays: citiesX, controlsX, outposts, etc.
Synchronization:

Uses publicVariable for areRivalsDiscovered and rivalsLocationsMap
Remote execution on teamPlayer and civilian sides
Creates public hash map that all clients can read
fn_rivals_activityUpdateLoop.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_activityUpdateLoop.sqf Line Count: 46 lines

Function: [] spawn SCRT_fnc_rivals_activityUpdateLoop;
What it does:
Maintains continuous loop that updates rivals activity values every minute by processing the inactivity stack. This is the heartbeat of the rivals activity system.

How it does that:
1. Initial Guard Clauses:

Sqf

Apply
#include "..\defines.inc"
FIX_LINE_NUMBERS()

if (!areRivalsEnabled) exitWith {
    Info("Rivals are not enabled, exiting activity update loop.");
};
Checks if rivals are globally enabled
Exits if disabled (log info message)
2. Main Loop Structure:

Sqf

Apply
while {true} do {
	if (areRivalsDefeated) exitWith {
        Info("Rivals are already defeated, exiting activity update loop.");
	};
Infinite loop until defeated
Exits immediately if rivals already defeated
3. Sleep/Wait Conditions:

Sqf

Apply
//Sleep if no player is online or until rivals will be active
if (!areRivalsDiscovered || {A3A_activePlayerCount == 0}) then { sleep 60; continue };
Sleeps 60 seconds if:
Rivals not discovered yet
No active players (optimization)
Uses continue to skip rest of loop iteration
4. Activity Stack Processing:

Sqf

Apply
waitUntil {!activityIsChanging};
activityIsChanging = true;

//Calculate new values for each element
inactivityStackRivals = inactivityStackRivals apply {[(_x select 0) + (_x select 1), (_x select 1)]};
//Filter out all elements which have passed the 0 value
inactivityStackRivals = inactivityStackRivals select {(_x select 0) * (_x select 1) < 0};

activityIsChanging = false;
[] call SCRT_fnc_rivals_calculateActivity;
Waits for activityIsChanging flag to be false (prevents race conditions)
Sets flag to true to lock modifications
Applies decay to each stack entry: [currentValue, decayRate]
Filters out entries that have crossed zero (completed their decay)
Resets flag and calls calculation function
Sleeps 60 seconds at end of loop
Where it leads:
Functions Called:

SCRT_fnc_rivals_calculateActivity - Calculates new activity level based on stack values
Global Variables Modified:

inactivityStackRivals - Array of [value, decayRate] pairs
activityIsChanging - Boolean flag for synchronization
Dependencies:

Requires areRivalsEnabled (boolean)
Requires areRivalsDefeated (boolean)
Requires areRivalsDiscovered (boolean)
Requires A3A_activePlayerCount (number)
Requires inactivityStackRivals (array)
Synchronization:

Uses activityIsChanging to prevent race conditions between multiple activity-modifying functions
Runs only on server (implied by isServer check in similar functions)
fn_rivals_addProgressToRivalsLocationReveal.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_addProgressToRivalsLocationReveal.sqf Line Count: 42 lines

Function: [60] call SCRT_fnc_rivals_addProgressToRivalsLocationReveal;
What it does:
Adds or reduces progress toward revealing the next unknown Rivals location. When threshold is reached, a new location is revealed to players.

How it does that:
1. Parameter Validation:

Sqf

Apply
params ["_value"];
private _newValue = nextRivalsLocationReveal + _value;
Takes single parameter _value (amount to add, can be positive or negative)
Calculates new value by adding to existing nextRivalsLocationReveal
2. Early Exit Conditions:

Sqf

Apply
if (([] call SCRT_fnc_rivals_getLocations) isEqualTo []) exitWith {};
Exits if no locations exist in the rivals network
Calls fn_rivals_getLocations to check
3. Gate Threshold Logic:

Sqf

Apply
#define GATE 100

if (_newValue > GATE) then {
    Info("Gate value exceeded, revealing new location...");
    nextRivalsLocationReveal = 0;  
    [] call SCRT_fnc_rivals_revealLocation;
} else {
    Info_1("New nextRivalsLocationReveal value: %1", str _newValue);
    nextRivalsLocationReveal = _newValue;
};
Gate constant is 100
If new value exceeds gate:
Reset nextRivalsLocationReveal to 0
Call reveal function
Else:
Update nextRivalsLocationReveal with new value
Log new value
4. Synchronization:

Sqf

Apply
publicVariable "nextRivalsLocationReveal";
Syncs new value to all clients
Where it leads:
Functions Called:

SCRT_fnc_rivals_getLocations - Gets array of all rival locations
SCRT_fnc_rivals_revealLocation - Reveals a new unknown location
Global Variables Modified:

nextRivalsLocationReveal (public) - Current progress value (0-100)
Dependencies:

Requires nextRivalsLocationReveal to be initialized
Requires rivalsLocationsMap to exist
Synchronization:

Uses publicVariable to sync progress value
Changes are visible to all clients
Call Sites:

fn_rivals_selectIntel.sqf
 - Adds 15 progress after finding intel
fn_rivals_imprison.sqf
 - Adds 5-7 progress after imprisonment
Other functions that reward location discovery progress
fn_rivals_calculateActivity.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_calculateActivity.sqf Line Count: 67 lines

Function: [] call SCRT_fnc_rivals_calculateActivity;
What it does:
Calculates current rival activity value and updates activity level based on the inactivity stack. This determines how aggressive/active the Rivals are.

How it does that:
1. Parameter and State Validation:

Sqf

Apply
params [["_silent", false]];
if (!areRivalsEnabled) exitWith {};
if (!areRivalsDiscovered) exitWith {};
if (areRivalsDefeated) exitWith {};
Optional _silent parameter (default false) controls notification visibility
Three guard clauses prevent execution in invalid states
2. Stack Value Calculation:

Sqf

Apply
private _newValue = 0;
{
    _newValue = _newValue + (_x select 0);
} forEach inactivityStackRivals;
Iterates through all entries in inactivityStackRivals
Sums the first element (current value) of each entry
Result is total activity value
3. Clamping:

Sqf

Apply
_newValue = round ((_newValue min 100) max 0);
Clamps value between 0 and 100
Rounds to nearest integer
4. Level Boundary Calculation:

Sqf

Apply
private _levelBounds = [((inactivityLevelRivals - 1) * 20) - 2.5, inactivityLevelRivals * 20 + 2.5];
Calculates current level's bounds with ±2.5 buffer
Example: Level 3 => bounds = [(220)-2.5, 320+2.5] = [37.5, 62.5]
5. Level Change Detection:

Sqf

Apply
if (_newValue < (_levelBounds select 0)) then {
    inactivityLevelRivals = ((ceil (_newValue / 20)) min 5) max 1;
    publicVariable "inactivityLevelRivals";
    _notificationText = format [localize "STR_comms_riv_activity_increased", ...];
    _levelsChanged = true;
} else {
    if(_newValue > (_levelBounds select 1)) then {
        inactivityLevelRivals = ((ceil (_newValue / 20)) min 5) max 1;
        publicVariable "inactivityLevelRivals";
        _notificationText = format [localize "STR_comms_riv_activity_reduced", ...];
        _levelsChanged = true;
    };
};
If below lower bound: Calculate new level (value/20, clamped 1-5)
If above upper bound: Calculate new level
Sets _levelsChanged flag and notification text
6. Notification and Update:

Sqf

Apply
if(_levelsChanged) then {
    [] remoteExec ["A3A_fnc_statistics", [teamPlayer, civilian]];
    if(!_silent) then {
        _notificationText = format [localize "STR_comms_riv_activity_change", _notificationText];
        [petros, "income", _notificationText] remoteExec ["A3A_fnc_commsMP", [teamPlayer, civilian]];
    };
};
Updates all rebel players' statistics HUD
If not silent: Sends notification via Petros
Notification is formatted with "Activity change" header
Where it leads:
Functions Called:

SCRT_fnc_rivals_getActivityLevelString - Converts numeric level to localized string
A3A_fnc_statistics - Updates player HUD
A3A_fnc_commsMP - Sends chat message to players
Global Variables Modified:

inactivityLevelRivals (public) - Current activity level (1-5)
activityIsChanging (indirectly via called functions)
Dependencies:

Requires inactivityStackRivals array
Requires areRivalsEnabled, areRivalsDiscovered, areRivalsDefeated
Requires inactivityLevelRivals to exist initially
Synchronization:

Uses publicVariable for inactivityLevelRivals
Remote execution for statistics and communications
Level changes visible to all clients
fn_rivals_chooseGroupToSpawn.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_chooseGroupToSpawn.sqf Line Count: 118 lines

Function: private _rivalsGroup = [] call SCRT_fnc_rivals_chooseGroupToSpawn;
What it does:
Selects appropriate Rivals group composition and vehicle based on current activity level. Higher activity levels spawn more elite/complex units.

How it does that:
1. Switch Statement on Activity Level:

Sqf

Apply
private _groupAndVehicleToSpawn = switch (inactivityLevelRivals) do {
Uses inactivityLevelRivals (1-5) to determine spawn quality
Level 5 = least active (worst units), Level 1 = most active (best units)
2. Level 5 (INSIGNIFICANT_ACTIVITY):

Sqf

Apply
case 5: {
    [selectRandom (A3A_faction_riv get "groupsSentry"), ""]
};
Always spawns Sentry group
No vehicle
Weakest composition
3. Level 4 (MODERATE_ACTIVITY):

Sqf

Apply
case 4: {
    private _group = if (random 100 < ((100 - 20 * inactivityLevelRivals) max 0)) then {
        selectRandom (A3A_faction_riv get "groupsFireteam");
    } else {
        (selectRandom ((A3A_faction_riv get "groupsSentry") + (A3A_faction_riv get "groupsAA") + (A3A_faction_riv get "groupsAT")));
    };
    [_group, ""]
};
20% chance (100 - 20*4 = 20) for Fireteam
80% chance for mixed group (Sentry/AA/AT)
No vehicle
4. Level 3 (CONSPICIOUS_ACTIVITY):

Sqf

Apply
case 3: {
    private _group = if (random 100 < ((100 - 20 * inactivityLevelRivals) max 0)) then {
        selectRandom (A3A_faction_riv get "groupsSquad");
    } else {
        selectRandom ((A3A_faction_riv get "groupsFireteam") + (A3A_faction_riv get "groupsAA") + (A3A_faction_riv get "groupsAT"));
    };
    
    private _vehicle = if (random 100 < (((100 - 20 * inactivityLevelRivals) - 10) max 0)) then {
        selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed");
    } else {
        ""
    };
    [_group, _vehicle]
};
40% chance (100 - 20*3 = 40) for Squad
60% chance for mixed group
30% chance (40-10=30) for Light Armed vehicle
Vehicle can be empty string
5. Level 2 (INTRUSIVE_ACTIVITY):

Sqf

Apply
case 2: {
    private _group = if (random 100 < ((100 - 20 * inactivityLevelRivals) max 0)) then {
        selectRandom (A3A_faction_riv get "groupsSquad");
    } else {
        selectRandom ((A3A_faction_riv get "groupsFireteam") + (A3A_faction_riv get "groupsAA") + (A3A_faction_riv get "groupsAT"));
    };
    
    private _vehicle = switch (true) do {
        case ((random 100) < 25): {
            selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed");
        };
        case ((random 100) < 15): {
            private _apcs = A3A_faction_riv get "vehiclesRivalsAPCs";
            if (_apcs isEqualTo []) then {
                selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed");
            } else {
                selectRandom _apcs;
            };
        };
        default { "" };
    };
    [_group, _vehicle]
};
60% chance for Squad
Vehicle selection:
25% chance for Light Armed
15% chance for APC (fallback to Light Armed if empty)
60% chance for no vehicle
6. Level 1 (OMNIPRESENT_ACTIVITY):

Sqf

Apply
case 1: {
    private _group = selectRandom (A3A_faction_riv get "groupsSquad");
    private _vehicle = switch (true) do {
        case ((random 100) < 35): {
            selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed");
        };
        case ((random 100) < 25): {
            private _apcs = A3A_faction_riv get "vehiclesRivalsAPCs";
            if (_apcs isEqualTo []) then {
                selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed");
            } else {
                selectRandom _apcs;
            };
        };
        case ((random 100) < 15): {
            private _tanks = A3A_faction_riv get "vehiclesRivalsTanks";
            private _apcs = A3A_faction_riv get "vehiclesRivalsAPCs";
            
            switch (true) do {
                case (_tanks isNotEqualTo []): { selectRandom _tanks };
                case (_apcs isNotEqualTo []): { selectRandom _apcs };
                default { selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed") };
            };
        };
        default { "" };
    };
    [_group, _vehicle]
};
Always spawns Squad group
Vehicle selection with priority:
35% chance for Light Armed
25% chance for APC (fallback to Light Armed)
15% chance for Tank/APC (tank priority, then APC, then Light Armed)
25% chance for no vehicle
7. Error Handling:

Sqf

Apply
default {
    Error("Invalid Rivals Inactivity Level, returning empty array.");
    [ [], "" ]
};
Logs error if activity level is invalid
Returns empty group and no vehicle
8. Return Value:

Sqf

Apply
_groupAndVehicleToSpawn
Returns array: [groupClass, vehicleClass]
Where it leads:
Functions Called:

None directly (uses hash maps for data)
Global Variables Modified:

None
Dependencies:

Requires inactivityLevelRivals (1-5)
Requires A3A_faction_riv hash map with keys:
groupsSentry
groupsFireteam
groupsSquad
groupsAA
groupsAT
vehiclesRivalsLightArmed
vehiclesRivalsAPCs
vehiclesRivalsTanks
Used By:

fn_rivals_trySpawnWanderingGroup.sqf
 - To select units for patrols
fn_rivals_createLaptop.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_createLaptop.sqf Line Count: 26 lines

Function: [unit] call SCRT_fnc_rivals_createLaptop;
What it does:
Creates a laptop object near a unit (typically a killed Rivals member) with actions for Intel collection and auto-despawn logic.

How it does that:
1. Laptop Position Calculation:

Sqf

Apply
params ["_unit"];
private _position = [(position _unit), 1, (random 360)] call SCRT_fnc_misc_extendPosition;
private _laptopPosition = [_position select 0, _position select 1, ((getPosATL _unit) select 2) + 0.5];
Takes unit as parameter
Extends position by 1 meter in random direction using extendPosition
Sets Z-coordinate 0.5m above unit's ground level
2. Laptop Creation:

Sqf

Apply
private _laptop = [
    (selectRandom ["Land_laptop_03_closed_black_F", "Land_laptop_03_closed_sand_F", "Land_laptop_03_closed_olive_F"]),
    _laptopPosition,
    (random 360)
] call SCRT_fnc_misc_createBelonging;
Creates random closed laptop variant
Positions at calculated position with random rotation
Uses createBelonging for proper object creation
3. Action Assignment:

Sqf

Apply
[_laptop, "Intel_Rivals_Laptop"] remoteExec ["A3A_fnc_flagaction", [teamPlayer,civilian], _laptop];
Adds "Intel_Rivals_Laptop" action to laptop
Action visible to teamPlayer and civilian sides
Remote execution ensures all clients get the action
4. Despawn Logic:

Sqf

Apply
_nul = _laptop spawn {
    while {alive _this} do {
        sleep 60;
        
        if (!alive _this) exitWith {};
        if ((call SCRT_fnc_misc_getRebelPlayers) inAreaArray [position _this, distanceSPWN, distanceSPWN] isEqualTo []) exitWith {
            deleteVehicle _this;
        };
    };
    
    terminate _thisScript;
};
Spawns separate thread for lifecycle management
Checks every 60 seconds if laptop is alive
Deletes laptop if no rebel players within distanceSPWN (typically 500m)
Exits if laptop is destroyed
terminate _thisScript stops the script when done
5. Return Value:

Sqf

Apply
_laptop
Returns created laptop object
Where it leads:
Functions Called:

SCRT_fnc_misc_extendPosition - Extends position in random direction
SCRT_fnc_misc_createBelonging - Creates object with proper setup
A3A_fnc_flagaction - Adds interaction action
SCRT_fnc_misc_getRebelPlayers - Gets array of rebel players
Global Variables Modified:

None (laptop is local to spawn)
Dependencies:

Requires distanceSPWN global variable
Requires rebel players array to exist
Used By:

fn_rivals_encounter_carDemo.sqf (indirectly via spawn)
fn_rivals_encounter_uavFlyby.sqf (indirectly)
Any event that drops laptops
fn_rivals_defeat.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_defeat.sqf Line Count: 41 lines

Function: [] remoteExecCall ["SCRT_fnc_rivals_defeat", 2];
What it does:
Defeats the Rivals faction, clearing their activity and triggering victory conditions. This is the terminal state of the Rivals system.

How it does that:
1. Clear Activity Stack:

Sqf

Apply
inactivityStackRivals = [];
[100, (100/baseRivalsDecay), true] call SCRT_fnc_rivals_reduceActivity;
Empties the activity stack
Adds a final 100-point reduction that never decays (silent)
2. Set Defeat Flags:

Sqf

Apply
areRivalsDefeated = true;
publicVariable "areRivalsDefeated";

areRivalsDiscovered = false;
publicVariable "areRivalsDiscovered";
Sets areRivalsDefeated to true and syncs
Resets areRivalsDiscovered to false (effectively hiding them)
Both are public variables for all clients
3. Update Statistics:

Sqf

Apply
[] spawn A3A_fnc_statistics;
Updates all player HUDs
4. Victory Message:

Sqf

Apply
private _text = format [
    localize "STR_rivals_destroyed_finale", 
    A3A_faction_riv get "name",
    ([] call SCRT_fnc_misc_getWorldName),
    A3A_faction_reb get "name"
];
[petros, "announce", _text] remoteExec ["A3A_fnc_commsMP", 0];
Formats victory message with faction names and world
Sends announcement via Petros to all players (side 0)
Where it leads:
Functions Called:

SCRT_fnc_rivals_reduceActivity - Reduces activity by 100 points
A3A_fnc_statistics - Updates player HUD
SCRT_fnc_misc_getWorldName - Gets world name
A3A_fnc_commsMP - Sends announcement
Global Variables Modified:

inactivityStackRivals (array)
areRivalsDefeated (public boolean)
areRivalsDiscovered (public boolean)
Dependencies:

Requires baseRivalsDecay
Requires A3A_faction_riv and A3A_faction_reb hash maps
Requires inactivityStackRivals array
Call Sites:

fn_rivals_destroyLocation.sqf
 - When last location destroyed
Manual admin command or scripted victory condition
fn_rivals_destroyLocation.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_destroyLocation.sqf Line Count: 79 lines

Function: [marker] call SCRT_fnc_rivals_destroyLocation;
What it does:
Destroys a Rivals location (hideout or cell), removing it from the network and triggering appropriate notifications.

How it does that:
1. Parameters:

Sqf

Apply
params ["_location", "_source"];
_location: Marker to destroy
_source: Type of destruction ("CELL", "HIDEOUT", "NOINVADER", etc.)
2. Radius Calculation for Chain Destruction:

Sqf

Apply
private _radius = (sqrt 2 / 2 * worldSize) / (3 + 2);
private _locations = ["UNKNOWN"] call SCRT_fnc_rivals_getLocations;
Calculates same operational radius as activation
Gets all unknown locations for proximity check
3. Find Close Locations:

Sqf

Apply
private _closeLocations = _locations select { (getMarkerPos _x) distance2D (getMarkerPos _location) <= _radius };
(_closeLocations + [_location]) apply {
    rivalsLocationsMap deleteAt _x;
};
publicVariable "rivalsLocationsMap";
Finds locations within operational radius
Deletes all close locations + target location from hash map
Syncs hash map to all clients
4. Victory Check:

Sqf

Apply
if (rivalsLocationsMap isEqualTo createHashMap) exitWith {
    [] remoteExecCall ["SCRT_fnc_rivals_defeat", 2];
};
If hash map is empty (no locations left)
Triggers defeat function
5. Activity Reduction:

Sqf

Apply
[(round (random [50, 60, 75])), (100/baseRivalsDecay)] call SCRT_fnc_rivals_reduceActivity;
Reduces activity by 50-75 points
Decay time based on baseRivalsDecay
6. Notification Generation:

Sqf

Apply
private _name = [_location] call A3A_fnc_localizar;
private _text = "";

switch (_source) do {
    case "CELL": {
        _text = format [
            localize "STR_rivals_destroyed_city", 
            A3A_faction_riv get "name",
            _name
        ];
    };
    // ... other cases
};
Gets localized name of marker
Creates appropriate message based on source type
7. Announcement:

Sqf

Apply
[petros, "announce", _text] remoteExec ["A3A_fnc_commsMP", 0];
Sends announcement to all players
Where it leads:
Functions Called:

SCRT_fnc_rivals_getLocations - Gets unknown locations
SCRT_fnc_rivals_defeat - Triggers victory if no locations left
SCRT_fnc_rivals_reduceActivity - Reduces activity
A3A_fnc_localizar - Gets localized marker name
A3A_fnc_commsMP - Sends announcement
Global Variables Modified:

rivalsLocationsMap (public hash map)
inactivityStackRivals (via reduceActivity)
Dependencies:

Requires rivalsLocationsMap to exist
Requires baseRivalsDecay to be set
Requires A3A_faction_riv hash map
Call Sites:

When rebel players capture/destroy a Rivals location
fn_rivals_eventLoop.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_eventLoop.sqf Line Count: 54 lines

Function: [] spawn SCRT_fnc_rivals_eventLoop;
What it does:
Main loop that checks conditions for triggering random Rivals events every 5 minutes (300 seconds). Manages event cooldown and probability checks.

How it does that:
1. Initial Guard Clauses:

Sqf

Apply
if(!isServer) exitWith {};
if (!areRivalsEnabled) exitWith {};
if (areRivalsDefeated) exitWith {};
Runs only on server
Exits if rivals disabled or defeated
2. Initialization:

Sqf

Apply
isRivalEventInProgress = false;
rivalEventCooldown = 0;
Sets event flags to initial state
3. Main Loop:

Sqf

Apply
while {true} do {
    waitUntil {!isNil "A3A_activePlayerCount"};
    
    sleep 300;
    // ... rest of loop
};
Waits for A3A_activePlayerCount to be defined
Sleeps 300 seconds (5 minutes) between checks
4. Event Condition Checks:

Sqf

Apply
if (areRivalsDefeated) exitWith { ... };
if (!areRivalsDiscovered || {isRivalEventInProgress || {A3A_activePlayerCount == 0 }}) then { 
    sleep 60; 
    continue;
};
Exits if defeated
Skips if:
Not discovered
Event already in progress
No active players
Continues loop after 60-second sleep
5. Cooldown Management:

Sqf

Apply
sleep rivalEventCooldown;
if (rivalEventCooldown > 0) then {
    rivalEventCooldown = 0;
};
Sleeps for rivalEventCooldown (set by previous events)
Resets cooldown after sleeping
6. Probability Check:

Sqf

Apply
if (([] call SCRT_fnc_rivals_rollProbability)) then {
    [] call SCRT_fnc_rivals_selectAndExecuteEvent;
} else {
    Info("Event doesn't rolled - low rivals activity.");
};
Rolls probability based on rivals activity level
If successful: Selects and executes event
If failed: Logs info message
Where it leads:
Functions Called:

SCRT_fnc_rivals_rollProbability - Checks event probability
SCRT_fnc_rivals_selectAndExecuteEvent - Selects and triggers event
Global Variables Modified:

isRivalEventInProgress (boolean)
rivalEventCooldown (number)
A3A_activePlayerCount (read only)
Dependencies:

Requires areRivalsEnabled, areRivalsDefeated, areRivalsDiscovered
Requires A3A_activePlayerCount to exist
Synchronization:

Runs only on server
Event state flags are local to server
Call Sites:

Started by mission initialization or admin command
fn_rivals_excludeLocation.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_excludeLocation.sqf Line Count: 5 lines

Function: [location] call SCRT_fnc_rivals_excludeLocation;
What it does:
Excludes a location from being used as a Rivals base, removing it from the available pool.

How it does that:
Sqf

Apply
params ["_location"];
rivalsExcludedLocations set [_location, nil];
publicVariable "rivalsExcludedLocations";
Takes location marker as parameter
Deletes entry from rivalsExcludedLocations hash map
Actually adds to excluded list (key exists = excluded)
Syncs to all clients
Where it leads:
Functions Called: None

Global Variables Modified:

rivalsExcludedLocations (public hash map)
Dependencies:

Requires rivalsExcludedLocations hash map to exist
Used By:

fn_rivals_selectIntel.sqf
 - When intel triggers location exclusion
fn_rivals_findSuitableEncounterPosition.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_findSuitableEncounterPosition.sqf Line Count: 83 lines

Function: [] call SCRT_fnc_rivals_findSuitableEncounterPosition;
What it does:
Finds a suitable position for Rivals encounters based on current activity level. More active = more aggressive positioning.

How it does that:
1. Player Selection:

Sqf

Apply
private _players = (call SCRT_fnc_misc_getRebelPlayers) select {
    private _playerVeh = vehicle _x;
    alive _x && {!(_playerVeh isKindOf "Helicopter") && {!(_playerVeh isKindOf "Plane")}}
};
if (_players isEqualTo []) exitWith {[]};
Gets rebel players
Filters out those in aircraft (safe from ground encounters)
Exits if no valid players
2. Radius Calculation:

Sqf

Apply
private _radius = call SCRT_fnc_rivals_getOperationRadius;
Gets activity-based operational radius
3. Activity-Based Positioning: Switches based on inactivityLevelRivals:

Level 5 (INSIGNIFICANT_ACTIVITY):

Sqf

Apply
case INSIGNIFICANT_ACTIVITY: {
    _encounterPosition = [];
};
Returns empty array (no encounters)
Level 4 (MODERATE_ACTIVITY):

Sqf

Apply
case MODERATE_ACTIVITY: {
    private _sites = (outposts + airportsX + resourcesX + factories + seaports + milbases + ["Synd_HQ"]) select {sidesX getVariable [_x, sideUnknown] == teamPlayer};
    private _offSitePlayers = _players select {
        private _player = _x; 
        _sites findIf {_player inArea _x} == -1 && {_rivalsLocations findIf {_player distance2D (getMarkerPos _x) < _radius} != -1} 
    };
    if (count _offSitePlayers > 0) then {
        _encounterPosition = position (selectRandom _offSitePlayers);
    };
};
Filters players NOT on friendly sites AND within rivals radius
Returns random off-site player position
Level 3 (CONSPICIOUS_ACTIVITY):

Sqf

Apply
case CONSPICIOUS_ACTIVITY: {
    private _blacklistedSites = (airportsX + milbases + ["Synd_HQ"]) select {sidesX getVariable [_x, sideUnknown] == teamPlayer};
    private _offSitePlayers = _players select {
        private _player = _x; 
        _blacklistedSites findIf {_player inArea _x} == -1 && {_rivalsLocations findIf {_player distance2D (getMarkerPos _x) < _radius} != -1} 
    };
    if (count _offSitePlayers > 0) then {
        _encounterPosition = position (selectRandom _offSitePlayers);
    };
};
Blacklists airports, milbases, HQ
Players not on blacklisted sites AND in rivals radius
Level 2 (INTRUSIVE_ACTIVITY):

Sqf

Apply
case INTRUSIVE_ACTIVITY: {
    private _blacklistedSites = ["Synd_HQ"];
    private _offSitePlayers = _players select {
        private _player = _x; 
        _blacklistedSites findIf {_player inArea _x} == -1 && {_rivalsLocations findIf {_player distance2D (getMarkerPos _x) < _radius} != -1} 
    };
    if (count _offSitePlayers > 0) then {
        _encounterPosition = position (selectRandom _offSitePlayers);
    };
};
Only blacklists HQ
Players not on HQ AND in rivals radius
Level 1 (OMNIPRESENT_ACTIVITY):

Sqf

Apply
case OMNIPRESENT_ACTIVITY: {
    _encounterPosition = position (selectRandom _players);
};
Returns any rebel player position (no restrictions)
Where it leads:
Functions Called:

SCRT_fnc_misc_getRebelPlayers - Gets array of rebel players
SCRT_fnc_rivals_getOperationRadius - Gets current operational radius
SCRT_fnc_rivals_getLocations - Gets rivals locations array
Global Variables Modified: None

Dependencies:

Requires inactivityLevelRivals
Requires rivalsLocationsMap
Requires marker arrays (outposts, airportsX, etc.)
Used By:

fn_rivals_encounter_carDemo.sqf
fn_rivals_encounter_uavFlyby.sqf
fn_rivals_encounter_rovingMortar.sqf
fn_rivals_encounter_heliRaid.sqf
fn_rivals_encounter_OccVsRivalsskirmish.sqf
fn_rivals_encounter_policeVsRivalsskirmish.sqf
fn_rivals_getActivityLevelString.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_getActivityLevelString.sqf Line Count: 31 lines

Function: [level] call SCRT_fnc_rivals_getActivityLevelString;
What it does:
Converts numeric activity level (1-5) to localized string representation.

How it does that:
1. Parameter:

Sqf

Apply
params ["_level"];
Takes numeric level (1-5)
2. Switch Statement:

Sqf

Apply
private _activityLevel = switch (_level) do {
    case OMNIPRESENT_ACTIVITY: {
        localize "STR_info_bar_rivals_activity_1";
    };
    case INTRUSIVE_ACTIVITY: {
        localize "STR_info_bar_rivals_activity_2";
    };
    case CONSPICIOUS_ACTIVITY: {
        localize "STR_info_bar_rivals_activity_3";
    };
    case MODERATE_ACTIVITY: {
        localize "STR_info_bar_rivals_activity_4";
    };
    case INSIGNIFICANT_ACTIVITY: {
        localize "STR_info_bar_rivals_activity_5";
    };
    default {
        Error_1("Bad level recieved, cannot generate string, was %1", _level);
        ""
    };
};
Maps constant to localized string
Note: Inverted (1 = most active string, 5 = least active)
Error logging for invalid levels
3. Return:

Sqf

Apply
_activityLevel
Returns localized string
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires localization strings: STR_info_bar_rivals_activity_1 through 5
Used By:

fn_rivals_calculateActivity.sqf
 - For notification text
fn_rivals_ui_showRivalsActivity - For UI display
fn_rivals_getEventCooldown.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_getEventCooldown.sqf Line Count: 19 lines

Function: [] call SCRT_fnc_rivals_getEventCooldown;
What it does:
Calculates cooldown time (in seconds) between Rivals events based on activity level, player count, and difficulty.

How it does that:
1. Calculation Formula:

Sqf

Apply
1600 - (200 * ((5-inactivityLevelRivals) ^ (0.6 + (rivalsDifficulty/10))) + 1 / 4
Base cooldown: 1600 seconds (~27 minutes)
Reduction factor: 200 * (activity level adjusted)
Activity adjustment: (5 - level) - Higher activity = smaller value = less cooldown
Difficulty adjustment: rivalsDifficulty/10 - Harder difficulty = more power = shorter cooldown
Exponent: 0.6 + (rivalsDifficulty/10) - Increases impact of difficulty
Addition: + 1 / 4 - Small adjustment (0.25)
Example calculations:

Level 5 (least active), difficulty 1: 1600 - (200 * ((5-5) ^ (0.6+0.1))) = 1600 - 0 = 1600s
Level 1 (most active), difficulty 10: 1600 - (200 * ((5-1) ^ (0.6+1.0))) = 1600 - (200 * 4^1.6) ≈ 1600 - (200 * 10.08) ≈ 1600 - 2016 = -416s (clamped by function that uses it)
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires inactivityLevelRivals (1-5)
Requires rivalsDifficulty (0-10)
Used By:

fn_rivals_selectAndExecuteEvent.sqf
 - To set rivalEventCooldown
fn_rivals_getLocations.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_getLocations.sqf Line Count: 60 lines

Function: [] call SCRT_fnc_rivals_getLocations; or ["KNOWN"] call SCRT_fnc_rivals_getLocations;
What it does:
Returns array of Rivals locations based on filter mode: all locations, known locations only, or unknown locations only.

How it does that:
1. Parameter Validation:

Sqf

Apply
params [["_mode", ""]];

if (!(_mode in ["KNOWN", "UNKNOWN", ""])) exitWith {
    Error("Wrong value: %1", _mode);
};
Accepts optional mode parameter: "KNOWN", "UNKNOWN", or ""
Validates mode is one of allowed values
Exits with error if invalid
2. State Validation:

Sqf

Apply
if (areRivalsDefeated || !areRivalsDiscovered || !areRivalsEnabled) exitWith {
    [];
};
Returns empty array if:
Rivals defeated
Rivals not discovered
Rivals not enabled
3. Location Filtering:

Sqf

Apply
private _locations = switch (_mode) do {
    case "KNOWN": {
        (rivalsLocationsMap apply { 
            private _marker = _x;
            private _isKnown = _y;
            [nil,_marker] select _isKnown
        }) select {!isNil "_x"};
    };
    case "UNKNOWN": {
        (rivalsLocationsMap apply { 
            private _marker = _x;
            private _isKnown = _y;
            [nil,_marker] select !(_isKnown)
        }) select {!isNil "_x"};
    };
    default {
        keys rivalsLocationsMap;
    };
};
KNOWN: Returns markers where _isKnown is true
UNKNOWN: Returns markers where _isKnown is false
Default (empty): Returns all location keys
4. Error Handling:

Sqf

Apply
if (isNil "_locations") then {
    _locations = [];
};
Ensures array is never nil
5. Return:

Sqf

Apply
Debug_2("Returning locations %1 with %2 filter",str _locations, _mode);
_locations
Logs debug info and returns array
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires rivalsLocationsMap hash map
Requires areRivalsDefeated, areRivalsDiscovered, areRivalsEnabled
Used By:

fn_rivals_addProgressToRivalsLocationReveal.sqf
fn_rivals_revealLocation.sqf
fn_rivals_destroyLocation.sqf
fn_rivals_trySpawnCarDemo.sqf
fn_rivals_trySpawnWanderingGroup.sqf
fn_rivals_findSuitableEncounterPosition.sqf
fn_rivals_getOperationRadius.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_getOperationRadius.sqf Line Count: 24 lines

Function: [] call SCRT_fnc_rivals_getOperationRadius;
What it does:
Calculates the current operational radius for Rivals activities based on world size and activity level.

How it does that:
1. State Validation:

Sqf

Apply
if (!areRivalsEnabled || {!areRivalsDiscovered || {areRivalsDefeated}}) exitWith {
    0;
};
Returns 0 if rivals are disabled, not discovered, or defeated
2. Radius Calculation:

Sqf

Apply
(sqrt 2 / 2 * worldSize) / (inactivityLevelRivals + 2)
sqrt 2 / 2 * worldSize: Calculates diagonal half of world (maximum distance from corner to center)
inactivityLevelRivals + 2: Divisor based on activity level
Level 5 (least active): 5+2=7 - Smaller radius
Level 1 (most active): 1+2=3 - Larger radius
Example for 10km world:

sqrt(2)/2 * 10000 ≈ 7071m
Level 5: 7071/7 ≈ 1010m
Level 1: 7071/3 ≈ 2357m
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires areRivalsEnabled, areRivalsDiscovered, areRivalsDefeated
Requires inactivityLevelRivals
Used By:

fn_rivals_trySpawnCarDemo.sqf
fn_rivals_trySpawnWanderingGroup.sqf
fn_rivals_findSuitableEncounterPosition.sqf
fn_rivals_imprison.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_imprison.sqf Line Count: 56 lines

Function: [unit, caller, actionId, recruiting] call SCRT_fnc_rivals_imprison; (Attached to unit action)
What it does:
Handles imprisonment of captured Rivals unit with escape chance, animations, and intel rewards.

How it does that:
1. Action Removal:

Sqf

Apply
params ["_unit", "_caller", "_actionId", "_recruiting"];
[_unit,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
Removes imprisonment action from unit
2. Early Exit:

Sqf

Apply
if (!alive _unit) exitWith {};
Exits if unit died
3. Escape Chance Calculation:

Sqf

Apply
private _group = group _unit;
private _chance = if ("cellleader" in (toLowerANSI (_unit getVariable "unitType"))) then {
    (random [30,40,60])
} else {
    (random [10,20,25])
};
Cell leaders: 30-60% escape chance (30% min, 40% mid, 60% max)
Regular units: 10-25% escape chance
4. Player Dialogue:

Sqf

Apply
_caller globalChat (selectRandom [ ... ]);
sleep 2;
Random dialogue from caller
2-second delay
5. Escape Check:

Sqf

Apply
if (random 100 < _chance) exitWith {
    _unit globalChat (selectRandom [ ... ]);
    [_unit, Rivals, true] remoteExec ["A3A_fnc_fleeToSide", _unit];
    
    // Group should be surrender-specific now
    sleep 100;
    deleteVehicle _unit;
    deleteGroup _group;
};
Rolls against escape chance
If successful:
Unit responds
Calls fleeToSide to escape
Deletes unit after 100 seconds
6. Imprisonment Success:

Sqf

Apply
_unit globalChat (selectRandom [ ... ]);
[_unit, "amovpsitmstpsnonwnondnon_ground"] remoteExecCall ["playMoveNow", _unit];
Unit responds positively
Plays sitting animation
7. Wait for Player Distance:

Sqf

Apply
private _timeOut = time + 120;
waitUntil {
    sleep 5; 
    isNil "_unit" || {!alive _unit || {time > _timeOut || {(call BIS_fnc_listPlayers) findIf {([objNull, "VIEW"] checkVisibility [eyePos _x, eyePos _unit]) > 0.3} == -1 || {(call BIS_fnc_listPlayers) findIf {(_x distance2D _unit < distanceSPWN)} == -1}}}}
};
Waits up to 120 seconds
Exits if:
Unit nil/dead
Timeout reached
No players can see unit (line of sight check)
No players within distanceSPWN
8. Reward on Success:

Sqf

Apply
if (alive _unit) then {
    [random [5,6,7], 100/baseRivalsDecay] remoteExec ["SCRT_fnc_rivals_reduceActivity",2];
    [random [5,6,7]] remoteExecCall ["SCRT_fnc_rivals_addProgressToRivalsLocationReveal", 2];
};
If unit alive after wait: Reduces activity and adds reveal progress
5-7 points of both
9. Cleanup:

Sqf

Apply
deleteVehicle _unit;
deleteGroup _group;
Removes unit and group
Where it leads:
Functions Called:

A3A_fnc_flagaction - Removes action
A3A_fnc_fleeToSide - Handles escape
SCRT_fnc_rivals_reduceActivity - Reduces activity
SCRT_fnc_rivals_addProgressToRivalsLocationReveal - Adds reveal progress
Global Variables Modified:

inactivityStackRivals (via reduceActivity)
nextRivalsLocationReveal (via addProgress)
Dependencies:

Requires baseRivalsDecay
Requires unit to have unitType variable
Used By:

Unit action "Imprison Rivals" (flagaction)
fn_rivals_mortarRoutine.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_mortarRoutine.sqf Line Count: 221 lines

Function: [mortar, crewGroup, supportName, sleepTime] spawn SCRT_fnc_rivals_mortarRoutine;
What it does:
Controls Rivals mortar support system - firing rounds at targets with proper coordination, markers, and cleanup.

How it does that:
1. Initial Sleep:

Sqf

Apply
params ["_mortar", "_crewGroup", "_supportName", "_sleepTime"];
Info_1("Sleep time: %1", str _sleepTime);
sleep _sleepTime;
Takes mortar object, crew group, support name, and setup time
Sleeps to simulate setup time
2. Rounds and Time Calculation:

Sqf

Apply
private _numberOfRounds = 4;
private _timeAlive = 900;

switch (inactivityLevelRivals) do {
    case 5: { _numberOfRounds = 2; _timeAlive = 1400; };
    case 4: { _numberOfRounds = round (random [2,2,4]); _timeAlive = 1200; };
    case 3: { _numberOfRounds = round (random [2,3,4]); _timeAlive = 1000; };
    case 2: { _numberOfRounds = round (random [3,4,6]); _timeAlive = 800; };
    case 1: { _numberOfRounds = round (random [4,5,7]); _timeAlive = 600; };
};
Level 5: 2 rounds, 1400s lifetime
Level 4: 2-4 rounds, 1200s lifetime
Level 3: 2-4 rounds, 1000s lifetime
Level 2: 3-6 rounds, 800s lifetime
Level 1: 4-7 rounds, 600s lifetime
3. Fire Event Handler:

Sqf

Apply
_fn_executeMortarFire = {
    params ["_mortar"];
    
    private _targets = _mortar getVariable ["FireOrder", []];
    private _target = _targets deleteAt 0;
    _mortar setVariable ["FireOrder", _targets, true];
    
    _mortar addEventHandler [
        "Fired",
        {
            params ["_mortar"];
            
            private _targets = _mortar getVariable ["FireOrder", []];
            
            if(count _targets == 0) exitWith
            {
                _mortar removeEventHandler ["Fired", _thisEventHandler];
                _mortar setVariable ["CurrentlyFiring", false, true];
                _mortar setVariable ["FireOrder", nil, true];
                
                private _supportName = _mortar getVariable "Callsign";
                [_supportName] spawn
                {
                    private _name = _this select 0;
                    sleep 60;
                    deleteMarker (format ["%1_targetMarker", _name]);
                    deleteMarker (format ["%1_text", _name]);
                };
            };
            
            private _target = _targets deleteAt 0;
            _mortar setVariable ["FireOrder", _targets, true];
            
            [_target, _mortar] spawn
            {
                params ["_target", "_mortar"];
                sleep 0.5;
                _mortar doArtilleryFire [_target, _mortar getVariable "shellType", 1];
            }
        }
    ];
    _mortar doArtilleryFire [_target, _mortar getVariable "shellType", 1];
};
Complex nested function for firing sequence
Manages fire order queue
Handles cleanup of markers when firing complete
Uses doArtilleryFire with shell type
4. Target Selection:

Sqf

Apply
private _targetList = server getVariable [format ["%1_targets", _supportName], []];
if (count _targetList > 0) then {
    private _target = _targetList select 0;
    // ... notify players
};
Gets target list from server variable
Notifies players if target is near them
5. Main Loop:

Sqf

Apply
while {_timeAlive > 0} do {
    if !(_mortar getVariable "CurrentlyFiring") then {
        // Check for new targets
        private _targetList = server getVariable [format ["%1_targets", _supportName], []];
        if (count _targetList > 0) then {
            // Process target
            private _target = _targetList deleteAt 0;
            server setVariable [format ["%1_targets", _supportName], _targetList, true];
            
            // Parse target parameters
            private _targetParams = _target select 0;
            private _reveal = _target select 1;
            private _targetPos = _targetParams select 0;
            private _precision = _targetParams select 1;
            private _distance = random (125 - ((_precision/4) * (_precision/4) * 100));
            
            // Generate sub-targets
            private _subTargets = [];
            for "_i" from 1 to _numberOfRounds do {
                _subTargets pushBack (_targetPos getPos [random _distance, random 360]);
            };
            
            // Create markers
            private _targetMarker = createMarker [format ["%1_targetMarker", _supportName], _targetPos];
            _targetMarker setMarkerShape "ELLIPSE";
            _targetMarker setMarkerBrush "Grid";
            _targetMarker setMarkerSize [_distance + 25, _distance + 25];
            _targetMarker setMarkerColor colorRivals;
            _targetMarker setMarkerAlpha 1;
            
            private _textMarker = createMarker [format ["%1_text", _supportName], _targetPos];
            _textMarker setMarkerShape "ICON";
            _textMarker setMarkerType "mil_dot";
            _textMarker setMarkerText (localize "STR_marker_roving_mortar_target");
            _textMarker setMarkerColor colorRivals;
            _textMarker setMarkerAlpha 1;
            
            // Clear target area
            [Rivals, _targetMarker] spawn A3A_fnc_clearTargetArea;
            
            // Start firing
            _mortar setVariable ["CurrentlyFiring", true, true];
            _mortar setVariable ["FireOrder", _subTargets, true];
            [_mortar] call _fn_executeMortarFire;
            _numberOfRounds = 0;
        };
    };
    
    // Check for mortar destruction
    if (!(alive _mortar) || {{alive _x} count (units _crewGroup) == 0 || {_mortar getVariable ["Stolen", false]}}) exitWith {
        ["TaskSucceeded", ["", format [localize "STR_notifiers_roving_mortar_crew_killed", A3A_faction_riv get "name"]]] remoteExec ["BIS_fnc_showNotification", teamPlayer];
        [10, 60] remoteExec ["SCRT_fnc_rivals_reduceActivity",2];
    };
    
    // Check if no rounds left
    if (!(_mortar getVariable "CurrentlyFiring") && (_numberOfRounds <= 0)) exitWith {
        sleep _sleepTime;
        Info_1("%1 has no more rounds left to fire, aborting routine", _supportName);
    };
    
    sleep 5;
    _timeAlive = _timeAlive - 5;
};
Continuous loop with 5-second ticks
Processes targets when not firing
Creates visual markers for players
Handles mortar/crew destruction
Reduces activity if mortar killed
Exits when time expires or no rounds left
6. Cleanup:

Sqf

Apply
_mortar removeAllEventHandlers "Fired";
_crewGroup setCombatMode "GREEN";
doGetOut (units _crewGroup);
_crewGroup setBehaviour "SAFE";
_mortar setVariable ['isFireMissionEnded', true];

if({alive _x} count (units _crewGroup) != 0) then {
    [_crewGroup] spawn A3A_fnc_groupDespawner;
};

if(alive _mortar && {!(_mortar getVariable ["Stolen", false])}) then {
    [_mortar] spawn A3A_fnc_VEHdespawner;
};

server setVariable [format ["%1_targets", _supportName], nil, true];
deleteMarker (format ["%1_targetMarker", _supportName]);
deleteMarker (format ["%1_text", _supportName]);
Removes event handlers
Makes crew retreat
Spawns despawners for mortar and crew
Deletes target variables and markers
Where it leads:
Functions Called:

A3A_fnc_clearTargetArea - Clears area around target
SCRT_fnc_rivals_reduceActivity - Reduces activity if mortar destroyed
A3A_fnc_groupDespawner - Despawns crew group
A3A_fnc_VEHdespawner - Despawns mortar vehicle
Global Variables Modified:

Mortar-specific variables on object
Server variable for target list
inactivityStackRivals (via reduceActivity)
Dependencies:

Requires inactivityLevelRivals
Requires A3A_faction_riv for name
Requires colorRivals color definition
Requires target list to be set externally
Used By:

fn_rivals_encounter_rovingMortar.sqf - Starts this routine
fn_rivals_plantCarDemoCharge.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_plantCarDemoCharge.sqf Line Count: 137 lines

Function: [vehicle, proximityChance] call SCRT_fnc_rivals_plantCarDemoCharge;
What it does:
Plants a demo charge on a vehicle with two trigger methods: engine start OR proximity detection. Includes disarm action.

How it does that:
1. Parameters:

Sqf

Apply
params [["_vehicleToCharge", objNull], ["_proximityChance", 40]];
Target vehicle (default objNull)
Proximity detection chance percentage (default 40%)
2. Charge Creation:

Sqf

Apply
private _charge = "DemoCharge_F" createVehicle [0,0,0];
_charge setVectorDirAndUp [(vectorDir _vehicleToCharge), [0,0,-1]];
_charge setPosWorld ((getPosWorld _vehicleToCharge) vectorAdd [0,0,-0.8]);
_charge attachTo [_vehicleToCharge, [0,0,-0.8]];
Creates demo charge object
Aligns with vehicle direction
Positions 0.8m below vehicle center
Attaches to vehicle
3. Disarm Action:

Sqf

Apply
[
    _charge,
    (localize "STR_antistasi_actions_car_bomb_disarm"),
    "a3\ui_f\data\igui\cfg\holdactions\holdaction_unbind_ca.paa",
    "a3\ui_f\data\igui\cfg\holdactions\holdaction_unbind_ca.paa",
    "(_this distance _target < 3) and (_this getUnitTrait 'engineer')",
    "_caller distance _target < 3",
    {},
    {},
    { deleteVehicle _target },
    {},
    [],
    12,
    0,
    true,
    false
] remoteExec ["BIS_fnc_holdActionAdd", 0, _charge];
Adds hold action for engineers within 3m
12-second disarm time
Action deletes charge on success
4. Engine Start Trigger:

Sqf

Apply
private _engineEhId = _vehicleToCharge addEventHandler 
[
    "Engine", 
    {
        params ["_vehicleToCharge", "_engineOn"];
        if (_engineOn) then { 
            _this spawn { 
                params ["_vehicleToCharge", "_engineOn"]; 
                private _charge = _vehicleToCharge getVariable ["democharge", _vehicleToCharge]; 
                
                if (isNull _charge || {isNil "_charge"}) then {
                    _charge = _vehicleToCharge;
                };
                
                { 
                    [
                        "RivalsActivityDetected", 
                        [
                            format [localize "STR_rivals_activity_header",  A3A_faction_riv get "name"], 
                            format [localize "STR_rivals_activity_demo_car_description", A3A_faction_riv get "nameLeader"]
                        ]
                    ] remoteExec ["BIS_fnc_showNotification", _x];
                } forEach ((call SCRT_fnc_misc_getRebelPlayers) select {(position _x) distance _vehicleToCharge < 100});
                
                private _timeOut = time + 1;
                waitUntil {_timeOut < time};
                
                playSound3D ["x\A3A\addons\core\Sounds\Misc\BombCountdown.ogg", _charge, false, getPosASL _charge, 2.5, 1, 50]; 
                
                private _timeOut = time + 2;
                waitUntil {_timeOut < time};
                
                private _chargePos = getPosWorld _charge; 
                if (_charge != _vehicleToCharge) then { 
                    deleteVehicle _charge; 
                }; 
                _charge = "DemoCharge_Remote_Ammo_Scripted" createVehicle [0,0,0]; 
                _charge setPosWorld _chargePos; 
                _charge setDamage 1; 
            }; 
            
            _vehicleToCharge removeEventHandler [_thisEvent, _thisEventHandler]; 
        };
    }
];
Adds engine start event handler
When engine starts: Notifies nearby players, plays countdown sound, creates explosive
Handler removes itself after triggering
5. Proximity Detection:

Sqf

Apply
[_vehicleToCharge, _charge, _engineEhId, _proximityChance] spawn {
    params ["_vehicleToCharge", "_charge", "_engineEhId", "_proximityChance"];
    
    waitUntil {
        isNil "_vehicleToCharge" 
        || {!alive _vehicleToCharge
        || {(call SCRT_fnc_misc_getRebelPlayers) findIf { _x distance _vehicleToCharge < 25 } != -1}}
    };
    
    // Despawn handling
    if (isNil "_vehicleToCharge" || {isNull _vehicleToCharge || {!alive _vehicleToCharge}}) exitWith {
        deleteVehicle _charge;
        _vehicleToCharge removeEventHandler ["Engine", _engineEhId];
    };
    
    if ((random 100) > _proximityChance) exitWith {};
    
    // Proximity detonation sequence
    { 
        [
            "RivalsActivityDetected", 
            [
                format [localize "STR_rivals_activity_header",  A3A_faction_riv get "name"], 
                format [localize "STR_rivals_activity_demo_car_description", A3A_faction_riv get "nameLeader"]
            ]
        ] remoteExec ["BIS_fnc_showNotification", _x];
    } forEach ((call SCRT_fnc_misc_getRebelPlayers) select {(position _x) distance _vehicleToCharge < 100});
    
    private _timeOut = time + 1;
    waitUntil {_timeOut < time};
    
    playSound3D ["x\A3A\addons\core\Sounds\Misc\BombCountdown.ogg", _charge, false, getPosASL _charge, 2.5, 1, 50]; 
    
    private _timeOut = time + 1;
    waitUntil {_timeOut < time};
    
    private _chargePos = getPosWorld _charge;
    deleteVehicle _charge;
    _chargeScripted = "DemoCharge_Remote_Ammo_Scripted" createVehicle [0,0,0];
    _chargeScripted setPosWorld _chargePos;
    _chargeScripted setDamage 1;
    
    _vehicleToCharge removeEventHandler ["Engine", _engineEhId];
};
Separate thread for proximity detection
Waits for:
Vehicle destroyed
Player within 25m
Checks proximity chance
Triggers same explosion sequence as engine start
Removes engine handler if triggered
Where it leads:
Functions Called:

A3A_fnc_holdActionAdd - Adds disarm action (via remoteExec)
SCRT_fnc_misc_getRebelPlayers - Gets rebel players for proximity
BIS_fnc_showNotification - Notifies players
Global Variables Modified:

democharge variable on vehicle
Engine event handler ID
Dependencies:

Requires A3A_faction_riv with nameLeader key
Requires democharge variable setup
Used By:

fn_rivals_encounter_carDemo.sqf - Plants charge on spawned vehicle
fn_rivals_prepareQuest.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_prepareQuest.sqf Line Count: 24 lines

Function: [] call SCRT_fnc_rivals_prepareQuest;
What it does:
Prepares and starts a Rivals discovery quest by selecting a suitable city and scheduling the encounter.

How it does that:
1. City Selection:

Sqf

Apply
private _posBase = getMarkerPos respawnTeamPlayer;
private _potentials = [];

private _sites = citiesX select {
    private _markerPos = getMarkerPos _x; 
    sidesX getVariable [_x,sideUnknown] != teamPlayer && {(getMarkerPos _x distance2D getMarkerPos respawnTeamPlayer < distanceMission)}
};

if (count _sites == 0) then {
    _sites = citiesX;
};

private _missionSite = selectRandom _sites;
Gets HQ position
Filters cities:
Not controlled by rebels
Within distanceMission of HQ
Fallback to all cities if none found
Random selection from filtered sites
2. Quest Assignment Flag:

Sqf

Apply
isRivalsDiscoveryQuestAssigned = true;
publicVariable "isRivalsDiscoveryQuestAssigned";
Sets flag to prevent duplicate quests
Syncs to all clients
3. Encounter Scheduling:

Sqf

Apply
[[_missionSite],"A3A_fnc_RIV_ENC_Rivals"] remoteExec ["A3A_fnc_scheduler",2];
Schedules RIV_ENC_Rivals encounter on server 2
Passes selected site as parameter
Where it leads:
Functions Called:

A3A_fnc_scheduler - Schedules encounter execution
Global Variables Modified:

isRivalsDiscoveryQuestAssigned (public boolean)
Dependencies:

Requires citiesX marker array
Requires distanceMission parameter
Requires respawnTeamPlayer marker
Used By:

Mission initialization or trigger conditions
fn_rivals_reduceActivity.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_reduceActivity.sqf Line Count: 58 lines

Function: [activityChange, activityTime, silent] call SCRT_fnc_rivals_reduceActivity;
What it does:
Reduces rivals activity by adding an entry to the inactivity stack with a decay rate, which is processed over time.

How it does that:
1. Parameters:

Sqf

Apply
params
[
    ["_activityChange", 0, [0]],
    ["_activityTime", 0, [0]],
    ["_silent", false, [false]]
];
Amount of activity to reduce (positive number)
Time in minutes over which to decay
Silent flag for notification control
2. State Validation:

Sqf

Apply
if (!areRivalsEnabled) exitWith {};
if (!areRivalsDiscovered) exitWith {};
if (areRivalsDefeated) exitWith {};
Exits if rivals not enabled/discovered or defeated
3. Decay Rate Calculation:

Sqf

Apply
_fn_convertMinutesToDecayRate = {
    params ["_points", "_minutes"];
    if(_minutes == 0) then {
        Warning("Minute parameter is 0, assuming 1");
        _minutes = 1;
    };
    (-1) * (_points / _minutes);
};

if(_activityChange == 0) exitWith {};

//Wait until all other activity change operations are done
waitUntil {!activityIsChanging};
activityIsChanging = true;

private _decayRate = [_activityChange, _activityTime] call _fn_convertMinutesToDecayRate;
Converts minutes to decay rate per minute
Negative rate (decreasing activity)
Waits for activityIsChanging flag
4. Stack Addition:

Sqf

Apply
inactivityStackRivals pushBack [_activityChange, _decayRate];

[_silent] call SCRT_fnc_rivals_calculateActivity;
activityIsChanging = false;
Adds entry: [initialValue, decayPerMinute]
Calls calculation function
Resets changing flag
Where it leads:
Functions Called:

SCRT_fnc_rivals_calculateActivity - Updates activity level
Global Variables Modified:

inactivityStackRivals (array)
activityIsChanging (boolean flag)
Dependencies:

Requires areRivalsEnabled, areRivalsDiscovered, areRivalsDefeated
Requires baseRivalsDecay for time calculation
Used By:

fn_rivals_activate.sqf
 (initial handicap)
fn_rivals_defeat.sqf
 (final reduction)
fn_rivals_destroyLocation.sqf
 (reward)
fn_rivals_imprison.sqf
 (reward)
fn_rivals_mortarRoutine.sqf
 (on destruction)
fn_rivals_selectIntel.sqf
 (intel reward)
fn_rivals_revealLocation.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_revealLocation.sqf Line Count: 40 lines

Function: [] call SCRT_fnc_rivals_revealLocation;
What it does:
Reveals one unknown Rivals location to players, making it a valid attack target.

How it does that:
1. Find Unknown Locations:

Sqf

Apply
private _unknownLocations = ["UNKNOWN"] call SCRT_fnc_rivals_getLocations;
Gets array of undiscovered locations
2. Select Nearest:

Sqf

Apply
private _location = [_unknownLocations, respawnTeamplayer] call BIS_fnc_nearestPosition;
Selects location closest to HQ
Uses respawnTeamplayer as reference
3. Validation:

Sqf

Apply
if (isNil "_location") exitWith {};
if (_location isEqualTo [0,0,0]) exitWith {};
Exits if no location found or invalid position
4. Mark as Known:

Sqf

Apply
rivalsLocationsMap set [_location, true];
publicVariable "rivalsLocationsMap";
Sets hash map value to true (known)
Syncs to all clients
5. Notification:

Sqf

Apply
private _name = [_location] call A3A_fnc_localizar;

private _revealText = [
    format [(localize "STR_antistasi_rivals_reveal_location_hideout_hint_text"), A3A_faction_riv get "name", _name],
    format [(localize "STR_antistasi_rivals_reveal_location_city_hint_text"), A3A_faction_riv get "name", _name]
] select (_location in citiesX);

[petros, "support", _revealText] remoteExec ["A3A_fnc_commsMP", [teamPlayer, civilian]];
Gets localized name
Chooses appropriate message (city vs hideout)
Sends via Petros to rebels/civilians
Where it leads:
Functions Called:

SCRT_fnc_rivals_getLocations - Gets unknown locations
A3A_fnc_localizar - Gets localized name
A3A_fnc_commsMP - Sends notification
Global Variables Modified:

rivalsLocationsMap (public hash map)
Dependencies:

Requires rivalsLocationsMap
Requires respawnTeamplayer marker
Requires citiesX array
Used By:

fn_rivals_addProgressToRivalsLocationReveal.sqf
 (via gate threshold)
fn_rivals_selectIntel.sqf
 (intel reward)
fn_rivals_rollProbability.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_rollProbability.sqf Line Count: 29 lines

Function: [] call SCRT_fnc_rivals_rollProbability;
What it does:
Rolls a probability check based on rivals activity level. Higher activity = higher chance.

How it does that:
1. State Validation:

Sqf

Apply
if (!areRivalsEnabled || {!areRivalsDiscovered || {areRivalsDefeated}}) exitWith {
    false;
};
Returns false if rivals not enabled/discovered or defeated
2. Gate Calculation:

Sqf

Apply
private _gate = (100 - 20 * inactivityLevelRivals) max 0;
Base 100% minus 20% per activity level
Minimum 0%
Level 5: 100 - 100 = 0% chance
Level 4: 100 - 80 = 20% chance
Level 3: 100 - 60 = 40% chance
Level 2: 100 - 40 = 60% chance
Level 1: 100 - 20 = 80% chance
3. Roll:

Sqf

Apply
(random 100) < _gate
Returns true if random number (0-100) is less than gate
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires inactivityLevelRivals
Requires areRivalsEnabled, areRivalsDiscovered, areRivalsDefeated
Used By:

fn_rivals_eventLoop.sqf
 - Event probability
fn_rivals_trySpawnCarDemo.sqf
 - Spawn probability
fn_rivals_trySpawnWanderingGroup.sqf
 - Spawn probability
fn_rivals_selectAndExecuteEvent.sqf
 - Event selection
fn_rivals_searchDataOnLaptop.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_searchDataOnLaptop.sqf Line Count: 100 lines

Function: [laptop, caller, action] call SCRT_fnc_rivals_searchDataOnLaptop; (Attached to laptop action)
What it does:
Handles searching a Rivals laptop for intel, with animations, sound, cancellation option, and rewards.

How it does that:
1. Action Removal:

Sqf

Apply
params ["_laptop", "_caller", "_action"];
[_laptop, _action] remoteExec ["removeAction", [teamPlayer, civilian], _laptop];
Removes search action from laptop
2. Laptop Opening:

Sqf

Apply
if !(_laptop getVariable ["isLaptopOpened", false]) then {
    private _openClosedLaptopMap = ["Land_laptop_03_closed_black_F", "Land_laptop_03_closed_sand_F", "Land_laptop_03_closed_olive_F"] 
        createHashMapFromArray ["Land_Laptop_03_black_F", "Land_Laptop_03_sand_F", "Land_Laptop_03_olive_F"];
    private _openedLaptopClass = _openClosedLaptopMap get (typeOf _laptop);
    
    private _oldLaptopPos = getPosATL _laptop;
    
    private _openedLaptop = createVehicle [_openedLaptopClass, [0,0,0], [], 0 , "CAN_COLLIDE"];
    _openedLaptop setPosATL _oldLaptopPos;
    _openedLaptop setObjectTextureGlobal [1, QPATHTOFOLDER(Pictures\Intel\laptop_scan.paa)];
    _openedLaptop setVariable ["isLaptopOpened", true, true];
    
    deleteVehicle _laptop;
    _laptop = _openedLaptop;
};
Converts closed laptop to open variant
Applies scan texture
Maintains position
Updates variable for future checks
3. Caller Direction:

Sqf

Apply
private _callerDir = [_caller,_laptop] call BIS_fnc_DirTo;
_laptop setDir _callerDir;
Rotates laptop to face caller
4. Animation Setup:

Sqf

Apply
_caller setVariable ["laptopSearchTime", (time + 10)];
_caller setVariable ["laptopSearchAnimsDone",false];
_caller setVariable ["laptopSearchDone", false];
_caller setVariable ["cancelLaptopSearch",false];

_caller playMoveNow selectRandom medicAnims;
Sets 10-second search timer
Plays random medical animation (typing)
5. Cancel Action:

Sqf

Apply
private _cancelAction = player addAction [
    (localize "STR_millaptop_cancel_action"),
    {
        (_this select 1) setVariable ["cancelLaptopSearch",true]
    },
    nil,
    6,
    true,
    true,
    "",
    "(isPlayer _this)"
];
Adds cancel action for player
Sets cancellation flag on click
6. Typing Sound:

Sqf

Apply
private _soundSource = createVehicle ["Land_HelipadEmpty_F", (position _laptop), [], 0 , "CAN_COLLIDE"];
playSound3D ["x\A3A\addons\core\Sounds\Misc\Typing.ogg", _soundSource, false, getPosASL _soundSource, 3, 1, 50];
Creates invisible sound source
Plays typing sound
7. Animation Handler:

Sqf

Apply
_caller addEventHandler
[
    "AnimDone",
    {
        private _caller = _this select 0;
        if (
            ([_caller] call A3A_fnc_canFight) &&                        //Caller is still able to fight
            {(time <= (_caller getVariable ["laptopSearchTime",time])) &&     //Time is not yet finished
            {!(_caller getVariable ["cancelLaptopSearch",false]) &&           //Search hasn't been cancelled
            {(isNull objectParent _caller)}}}                           //Caller has not entered a vehicle
        ) then {
            _caller playMoveNow selectRandom medicAnims;
        }
        else {
            _caller removeEventHandler ["AnimDone", _thisEventHandler];
            _caller setVariable ["laptopSearchAnimsDone",true];
        };
    }
];
Loops animations while conditions met:
Caller can fight
Time not expired
Not cancelled
Not in vehicle
Stops animation when conditions fail
8. Wait for Completion:

Sqf

Apply
waitUntil {_caller getVariable ["laptopSearchAnimsDone", false]};

deleteVehicle _soundSource;

_caller setVariable ["laptopSearchTime",nil];
_caller setVariable ["laptopSearchAnimsDone",nil];
_caller removeAction _cancelAction;

private _wasCancelled = _caller getVariable ["cancelLaptopSearch", false];
_caller setVariable ["cancelLaptopSearch", nil];
Waits for animation completion
Cleans up sound, variables, cancel action
9. Cancellation Handling:

Sqf

Apply
if(_wasCancelled) exitWith {
    [(localize "STR_millaptop_cancel_header"), (localize "STR_millaptop_cancel_description")] call A3A_fnc_customHint;
    _caller setVariable ["laptopSearchDone", nil];
    [_laptop, "Intel_Rivals_Laptop"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_laptop];
};
Shows cancellation message
Re-adds laptop action
10. Success Processing:

Sqf

Apply
_laptop setObjectTextureGlobal [1, QPATHTOFOLDER(Pictures\Intel\laptop_data.paa)];
_caller setVariable ["laptopSearchDone", true];

[] remoteExecCall ["SCRT_fnc_rivals_selectIntel", 2];
Applies data texture
Sets completion flag
Calls intel selection on server 2
11. Cleanup Timer:

Sqf

Apply
private _timeOut = time + 120;

waitUntil {
    sleep 5; 
    time > _timeOut || {(call BIS_fnc_listPlayers) findIf {([objNull, "VIEW"] checkVisibility [eyePos _x, (getPosASL _laptop)]) > 0.3} == -1 || {(call BIS_fnc_listPlayers) findIf {(_x distance2D _laptop < distanceSPWN)} == -1}}
};

if (!isNil "_laptop") then {
    deleteVehicle _laptop;
};
Waits 120 seconds or until no players can see laptop or within spawn distance
Deletes laptop when condition met
Where it leads:
Functions Called:

A3A_fnc_canFight - Checks if unit can fight
A3A_fnc_flagaction - Re-adds action on cancel
A3A_fnc_customHint - Shows cancellation message
SCRT_fnc_rivals_selectIntel - Selects and applies intel reward
BIS_fnc_DirTo - Gets direction to laptop
Global Variables Modified:

laptopSearchTime, laptopSearchAnimsDone, laptopSearchDone, cancelLaptopSearch (caller variables)
isLaptopOpened (laptop variable)
Dependencies:

Requires medicAnims array
Requires distanceSPWN
Requires QPATHTOFOLDER macro for texture path
Used By:

Laptop action "Intel_Rivals_Laptop"
fn_rivals_searchDataOnLaptopTask.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_searchDataOnLaptopTask.sqf Line Count: 92 lines

Function: [laptop, caller, action] call SCRT_fnc_rivals_searchDataOnLaptopTask; (Attached to laptop action)
What it does:
Similar to fn_rivals_searchDataOnLaptop but for quest-specific laptops. Marks laptop for task completion instead of general intel.

Key Differences from searchDataOnLaptop:
Texture: Uses laptop_signal.paa instead of laptop_data.paa
Action: Adds "rivals_quest" flagaction instead of re-adding "Intel_Rivals_Laptop"
Global Variable: Sets rivalsLaptop global variable for task tracking
No Intel Selection: Does NOT call fn_rivals_selectIntel
Implementation:
Mostly identical to searchDataOnLaptop except:

Sqf

Apply
_laptop setObjectTextureGlobal [1, QPATHTOFOLDER(Pictures\Intel\laptop_signal.paa)];
_caller setVariable ["laptopSearchDone", true];

//for garbage clean and other things in RES_Rivals task
rivalsLaptop = _laptop; 
publicVariable "rivalsLaptop";
Applies signal texture
Sets global rivalsLaptop variable (public)
Where it leads:
Functions Called:

A3A_fnc_canFight
A3A_fnc_flagaction (with "rivals_quest")
A3A_fnc_customHint
BIS_fnc_DirTo
Global Variables Modified:

rivalsLaptop (public object reference)
Caller variables same as searchDataOnLaptop
Dependencies: Same as searchDataOnLaptop

Used By:

Quest laptop action "rivals_quest"
fn_rivals_selectAndExecuteEvent.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_selectAndExecuteEvent.sqf Line Count: 56 lines

Function: [excludeId] call SCRT_fnc_rivals_selectAndExecuteEvent;
What it does:
Selects a random Rivals event from available types and executes it via scheduler, with optional event exclusion.

How it does that:
1. Parameters and Initialization:

Sqf

Apply
params [["_excludeId", 0]];
Info("Event condition has procced, selecting event...");
isRivalEventInProgress = true;
Takes optional event ID to exclude (for rerolling)
Sets event-in-progress flag
2. Event List and Exclusion:

Sqf

Apply
private _events = [
    [CARDEMO, UAVGRENADE, ROVINGMORTAR, HELIRAID , SKIRMISH_OCCVSRIV , SKIRMISH_POLICEVSRIV],
    ([CARDEMO, UAVGRENADE, ROVINGMORTAR, HELIRAID ,SKIRMISH_OCCVSRIV , SKIRMISH_POLICEVSRIV] select { _x != _excludeId })
] select (_excludeId isNotEqualTo 0);
Full event list if no exclusion
Exclusion list if excludeId provided
3. UAV Event Check:

Sqf

Apply
if ((A3A_faction_riv get "vehiclesRivalsUavs") isEqualTo []) then {
    _events deleteAt (_events find UAVGRENADE); 
};
Removes UAV event if faction has no UAVs
4. Weighted Selection:

Sqf

Apply
private _weight = 1 / (count _events); 
private _eventsWithWeights = flatten (_events apply { [_x, _weight] });
private _eventType = selectRandomWeighted _eventsWithWeights;
Equal weight for all events
Flattens to single array for selectRandomWeighted
Selects event type
5. Event Execution:

Sqf

Apply
switch (_eventType) do {
    case (CARDEMO): {
        [ [], "SCRT_fnc_rivals_encounter_carDemo" ] call A3A_fnc_scheduler;
    };
    // ... other cases
};
Calls A3A_fnc_scheduler with appropriate encounter function
Each case spawns different encounter
Where it leads:
Functions Called:

A3A_fnc_scheduler - Schedules event execution
Global Variables Modified:

isRivalEventInProgress (boolean)
Dependencies:

Requires A3A_faction_riv with vehiclesRivalsUavs key
Requires event encounter functions to exist
Used By:

fn_rivals_eventLoop.sqf
 - When probability succeeds
fn_rivals_selectIntel.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_selectIntel.sqf Line Count: 83 lines

Function: [excludeId] call SCRT_fnc_rivals_selectIntel;
What it does:
Selects random intel type when searching a laptop, executes the reward, and returns appropriate message.

How it does that:
1. Intel Types:

Sqf

Apply
#define BANK_ACCOUNT    100
#define REDUCE_ACTIVITY 101
#define RIVALS_NETWORK  102
#define RIVALS_EXCLUDE  103
Four types of intel rewards
2. Parameter and State:

Sqf

Apply
params [["_excludeId", 0, [0]]];
if (!areRivalsEnabled) exitWith {};
if (areRivalsDefeated) exitWith {};
Optional exclusion
Exit if rivals not enabled or defeated
3. Intel Selection:

Sqf

Apply
private _events = [
    [BANK_ACCOUNT, REDUCE_ACTIVITY, RIVALS_NETWORK, RIVALS_EXCLUDE],
    ([BANK_ACCOUNT, REDUCE_ACTIVITY, RIVALS_NETWORK, RIVALS_EXCLUDE] select { _x != _excludeId })
] select (_excludeId isNotEqualTo 0);

private _weight = 1 / (count _events); 
private _eventsWithWeights = flatten (_events apply { [_x, _weight] });
private _intelContent = selectRandomWeighted _eventsWithWeights;
Equal weight selection
Allows exclusion for rerolls
4. Intel Processing:

BANK_ACCOUNT:

Sqf

Apply
case (BANK_ACCOUNT): {
    private _money = ((round (random 50)) + (10 * tierWar)) * 100;
    _text = format [(localize "STR_intel_select_rivals_bank_account"), [] call SCRT_fnc_misc_getWorldName];
    
    private _rebels = call SCRT_fnc_misc_getRebelPlayers;
    private _rebelsCount = count _rebels;
    
    if(_rebelsCount > 0) then {
        private _totalSalary = round ((random [400,500,800]) * _rebelsCount);
        private _incomePerPlayer = round(_totalSalary / _rebelsCount);
        {
            [_incomePerPlayer,_x] call A3A_fnc_addMoneyPlayer;
        } forEach _rebels;
    };
};
Calculates money: 50-100 + (10 * tierWar) * 100
Distributes to all rebels: 400-800 per rebel total
REDUCE_ACTIVITY:

Sqf

Apply
case (REDUCE_ACTIVITY): {
    [15, ((100/baseRivalsDecay)/2)] call SCRT_fnc_rivals_reduceActivity;
    _text = format [(localize "STR_intel_select_reduce_activity"), _rivalsName, ([] call SCRT_fnc_misc_getWorldName)];
};
Reduces activity by 15 points over half base decay time
RIVALS_NETWORK:

Sqf

Apply
case (RIVALS_NETWORK): {
    _text = format [(localize "STR_intel_select_rivals_network_hideout"), _rivalsName];
    [] remoteExecCall ["SCRT_fnc_rivals_revealLocation", 2];
};
Reveals a new location
RIVALS_EXCLUDE:

Sqf

Apply
case (RIVALS_EXCLUDE): {
    private _locations = (citiesX + (controlsX select {!(isOnRoad getMarkerPos _x)})) select {!(_x in rivalsLocationsMap) && {!(_x in rivalsExcludedLocations)}};
    
    if (count _locations > 0) then {
        private _location = selectRandom _locations;
        [_location] remoteExecCall ["SCRT_fnc_rivals_excludeLocation", 2];
        _text = format [(localize "STR_intel_select_rivals_exclusion"), _rivalsName, ([_location] call A3A_fnc_localizar)];
    } else {
        _text = [RIVALS_EXCLUDE] call SCRT_fnc_rivals_selectIntel;
    };
};
Excludes random unused location
Recurses if no locations available
5. Progress and Notification:

Sqf

Apply
[15] remoteExecCall ["SCRT_fnc_rivals_addProgressToRivalsLocationReveal", 2];

if (_text isNotEqualTo "") then {
    [_text, true] remoteExec ["A3A_fnc_showIntel", [civilian, teamPlayer]];
};
Adds 15 progress to location reveal
Shows intel notification to rebels and civilians
Where it leads:
Functions Called:

SCRT_fnc_misc_getRebelPlayers - Gets rebel players
A3A_fnc_addMoneyPlayer - Adds money to player
SCRT_fnc_rivals_reduceActivity - Reduces activity
SCRT_fnc_rivals_revealLocation - Reveals location
SCRT_fnc_rivals_excludeLocation - Excludes location
A3A_fnc_localizar - Gets localized name
SCRT_fnc_rivals_addProgressToRivalsLocationReveal - Adds progress
A3A_fnc_showIntel - Shows notification
Global Variables Modified:

inactivityStackRivals (via reduceActivity)
nextRivalsLocationReveal (via addProgress)
rivalsExcludedLocations (via excludeLocation)
rivalsLocationsMap (via revealLocation)
Dependencies:

Requires baseRivalsDecay
Requires tierWar
Requires citiesX, controlsX
Requires rivalsLocationsMap, rivalsExcludedLocations
Used By:

fn_rivals_searchDataOnLaptop.sqf
 - When laptop search succeeds
fn_rivals_trySpawnCarDemo.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_trySpawnCarDemo.sqf Line Count: 40 lines

Function: [marker] call SCRT_fnc_rivals_trySpawnCarDemo;
What it does:
Attempts to spawn a car demo charge event at a Rivals location, subject to probability checks.

How it does that:
1. Parameters and Validation:

Sqf

Apply
params [ ["_site", "", [""] ] ];
if (_site isEqualTo "") exitWith { Error("Unknown marker, aborting.") };
Takes site marker
Validates not empty string
2. State Validation:

Sqf

Apply
if (!areRivalsEnabled) exitWith {};
if (areRivalsDefeated) exitWith {};
if (!areRivalsDiscovered) exitWith {};
if (!(_site in ([] call SCRT_fnc_rivals_getLocations))) exitWith {};
if (!([] call SCRT_fnc_rivals_rollProbability)) exitWith {};
Exits if:
Rivals not enabled/discovered/defeated
Site not in rivals locations
Probability roll fails
3. Spawn:

Sqf

Apply
[getMarkerPos _site] spawn SCRT_fnc_rivals_encounter_carDemo;
Spawns car demo encounter at site position
Where it leads:
Functions Called:

SCRT_fnc_rivals_getLocations - Gets rivals locations
SCRT_fnc_rivals_rollProbability - Rolls probability
SCRT_fnc_rivals_encounter_carDemo - Spawns encounter
Global Variables Modified: None

Dependencies:

Requires areRivalsEnabled, areRivalsDiscovered, areRivalsDefeated
Requires inactivityLevelRivals (for probability)
Used By:

Mission scripts that trigger random car demo events
fn_rivals_trySpawnWanderingGroup.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_trySpawnWanderingGroup.sqf Line Count: 174 lines

Function: [marker] spawn SCRT_fnc_rivals_trySpawnWanderingGroup;
What it does:
Spawns a wandering Rivals group at a location, with vehicle selection based on activity level.

How it does that:
1. Parameters and Validation:

Sqf

Apply
params ["_marker"];
if (areRivalsDefeated) exitWith { Info("Rivals was defeated before, exiting."); };
if (!areRivalsDiscovered) exitWith { Info("Rivals are not yet discovered, exiting."); };
if (!(_marker in ([] call SCRT_fnc_rivals_getLocations))) exitWith { Info("Location is not in the rivals network, exiting."); };
if (!([] call SCRT_fnc_rivals_rollProbability)) exitWith { Info("Low probability, exiting."); };
Validates state and probability
2. Group Selection:

Sqf

Apply
private _rivalsTacUnit = [] call SCRT_fnc_rivals_chooseGroupToSpawn;
if (_rivalsTacUnit isEqualTo []) exitWith { Error("Empty rivals group for some reason, aborting."); };

Info_1("Rivals tactical unit: %1", str _rivalsTacUnit);

private _spawnableGroup = _rivalsTacUnit select 0;
private _spawnableVehicle = _rivalsTacUnit select 1;
Calls chooseGroupToSpawn for composition
Extracts group and vehicle classes
3. Vehicle Spawn (if vehicle needed):

Sqf

Apply
if (_spawnableVehicle != "") then {
    // Find origin position
    private _markerPosition = getMarkerPos _marker;
    private _originPosition = [
            _markerPosition, //center
            0, //minimal distance
            700, //maximumDistance
            0, //object distance
            0, //water mode
            0, //maximum terrain gradient
            0, //shore mode
            [], //blacklist positions
            [_markerPosition, _markerPosition] //default position
        ] call BIS_fnc_findSafePos;
    
    // Find nearby roads
    private _roads = [];
    private _radiusX = 50;
    private _iterations = 0;
    
    while {true} do {
        _roads = _originPosition nearRoads _radiusX;
        if (count _roads > 0 && {_roads findIf {!([position _x] call A3A_fnc_enemyNearCheck)} != -1}) exitWith {};
        if (_iterations > 30) exitWith {};
        _iterations = _iterations + 1;
        _radiusX = _radiusX + 50;
    };
    
    // Determine vehicle spawn position
    private _vehicleSpawnPosition = nil;
    private _dirVeh = random 360;
    if (isNil "_roads"  || _roads isEqualTo []) then {
        _vehicleSpawnPosition = [
            _markerPosition, //center
            0, //minimal distance
            250, //maximumDistance
            7, //object distance
            0, //water mode
            0.45, //maximum terrain gradient
            0, //shore mode
            [], //blacklist positions
            [_originPosition, _originPosition] //default position
        ] call BIS_fnc_findSafePos;
    } else {
        private _road = selectRandom _roads;
        private _roadCon = roadsConnectedto _road;
        _dirVeh = if(count _roadcon > 0) then {[_road, _roadCon select 0] call BIS_fnc_DirTo} else {random 360};
        _vehicleSpawnPosition = getPos _road;
    };
    
    // Find empty position
    private _emptyPos = _vehicleSpawnPosition findEmptyPosition [0, 50, _spawnableVehicle];
    if (_emptyPos isNotEqualTo []) then {
        _vehicleSpawnPosition = _emptyPos;
    };
    
    // Spawn vehicle
    private _vehicleData = [_vehicleSpawnPosition, _dirVeh, _spawnableVehicle, Rivals] call A3A_fnc_RivalsSpawnVehicle;
    private _vehicle = _vehicleData select 0;
    [_vehicle, Rivals] call A3A_fnc_AIVEHinit;
    private _vehicleCrew = _vehicleData select 1;
    private _vehicleGroup = _vehicleData select 2;
    {[_x] call A3A_fnc_NATOinit} forEach _vehicleCrew;
    
    // Spawn group and join vehicle
    private _group = [_vehicleSpawnPosition, Rivals, _spawnableGroup] call A3A_fnc_RivalsSpawnGroup;
    {
        [_x] join _vehicleGroup; 
        [_x] call A3A_fnc_NATOinit;
    } forEach units _group;
    deleteGroup _group;
    
    // Patrol loop
    [_vehicleGroup, "Patrol_Area", 25, 100, 500, true, _markerPosition, false] call A3A_fnc_patrolLoop;
    
    _groups pushBack _vehicleGroup;
    _vehicles pushBack _vehicle;
} else {
    // Infantry-only spawn
    private _markerPosition = getMarkerPos _marker;
    private _originPosition = [
            _markerPosition, //center
            0, //minimal distance
            700, //maximumDistance
            7, //object distance
            0, //water mode
            0.45, //maximum terrain gradient
            0, //shore mode
            [], //blacklist positions
            [_markerPosition, _markerPosition] //default position
        ] call BIS_fnc_findSafePos;
    
    private _iterations = 0;
    
    while {(allUnits select {side _x in [Occupants, teamPlayer]}) findIf {_x distance2D _originPosition < 500} != -1} do {
        _originPosition = [
            _markerPosition, //center
            0, //minimal distance
            700, //maximumDistance
            7, //object distance
            0, //water mode
            0.45, //maximum terrain gradient
            0, //shore mode
            [], //blacklist positions
            [_originPosition, _originPosition]
        ] call BIS_fnc_findSafePos;
        if ((allUnits select {side _x in [Occupants, teamPlayer]}) findIf {_x distance2D _originPosition < 500} == -1) exitWith {};
        if (_iterations > 30) exitWith {};
        _iterations = _iterations + 1;
    };
    
    private _group = [_originPosition, Rivals, _spawnableGroup] call A3A_fnc_RivalsSpawnGroup;
    {
        [_x] call A3A_fnc_NATOinit;
    } forEach units _group;
    
    [_group, "Patrol_Area", 25, 250, 350, true, (getMarkerPos _marker), false] call A3A_fnc_patrolLoop;
    _groups pushBack _group;
};
With vehicle:
Finds road or safe position
Spawns vehicle with crew
Spawns group and joins to vehicle
Sets up patrol loop (500m radius)
Infantry only:
Finds safe position away from enemies
Spawns group
Sets up patrol loop (250-350m radius)
4. Despawn Logic:

Sqf

Apply
waitUntil {sleep 1; (spawner getVariable _marker == 2)};

{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Waits for spawner to indicate despawn (marker area cleared)
Spawns despawners for all units and vehicles
Where it leads:
Functions Called:

SCRT_fnc_rivals_chooseGroupToSpawn - Selects group/vehicle
SCRT_fnc_rivals_getLocations - Gets locations
SCRT_fnc_rivals_rollProbability - Rolls probability
A3A_fnc_RivalsSpawnVehicle - Spawns vehicle
A3A_fnc_AIVEHinit - Initializes vehicle AI
A3A_fnc_NATOinit - Initializes unit AI
A3A_fnc_RivalsSpawnGroup - Spawns group
A3A_fnc_patrolLoop - Sets up patrol
A3A_fnc_vehDespawner - Despawns vehicle
A3A_fnc_groupDespawner - Despawns group
Global Variables Modified:

spawner variable on marker (read only)
Dependencies:

Requires Rivals side
Requires spawner system
Requires areRivalsEnabled, etc.
Used By:

Mission scripts that spawn Rivals patrols

fn_rivals_encounter_carDemo.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_encounter_carDemo.sqf Line Count: 98 lines

Function: [overridePosition, overrideRadius, proximityChance] spawn SCRT_fnc_rivals_encounter_carDemo;
What it does:
Spawns a civilian vehicle with a planted demo charge at a road position near a player. The charge can detonate via engine start or proximity detection.

How it does that:
1. Parameters:

Sqf

Apply
params [["_overridePosition", []], ["_overrideRadius", -1], ["_proximityChance", 40]];
_overridePosition: Optional spawn position override
_overrideRadius: Optional radius override for position finding
_proximityChance: Percentage chance for proximity detonation (default 40%)
2. Initial Setup:

Sqf

Apply
Info("Civ Car Demo Charge Rival Event Init.");

private _vehicles = [];
private _effects = [];

private _allPlayers = call SCRT_fnc_misc_getRebelPlayers;
Initializes arrays for tracking spawned objects
Gets all rebel players for selection
3. Origin Position Selection:

Sqf

Apply
private _originPosition = nil;

if (_overridePosition isEqualTo []) then {
    private _player = selectRandom _allPlayers;
    if (isNil "_player") exitWith {
        Error("No players found, aborting.");
    };

    _originPosition = position _player;
    Info_2("%1 will be used as center of the event at %2 position.", name _player, str _originPosition);
} else {
    _originPosition = _overridePosition;
    Info_1("%1 position will be used as center of the event.", str _originPosition);
};
If no override: Randomly selects a rebel player and uses their position
If override provided: Uses specified position
Logs which player/position will be used
4. Early Exit Handling:

Sqf

Apply
if (isNil "_originPosition") exitWith {
    Info("No suitable position for event, cooldowning...");

    isRivalEventInProgress = false;
    publicVariableServer "isRivalEventInProgress";
    rivalEventCooldown = 300;
    publicVariableServer "rivalEventCooldown";
};
Exits if no position found
Resets event flags and sets 5-minute cooldown
5. Spawn Position Finding:

Sqf

Apply
private _spawnPosition = nil;

if (_overrideRadius != -1) then {
    _spawnPosition = [_originPosition, 100, _overrideRadius, 0, 0] call BIS_fnc_findSafePos;
} else {
    _spawnPosition = [_originPosition, 500, distanceSPWN, 0, 0] call BIS_fnc_findSafePos;
};
If override radius provided: 100m minimum, override radius maximum
Otherwise: 500m minimum, distanceSPWN (500m) maximum
Finds safe position (no water, flat terrain)
6. Road Detection:

Sqf

Apply
private _roads = objNull;
private _radiusX = 5;

while {true} do {
    _roads = _spawnPosition nearRoads _radiusX;
    if (count _roads > 0) exitWith {};
    _radiusX = _radiusX + 5;
};
Starts searching for roads with 5m radius
Expands radius by 5m each iteration
Exits when at least one road found
7. Road Positioning:

Sqf

Apply
private _road = selectRandom _roads;
private _roadcon = roadsConnectedto _road;
private _dirveh = if (count _roadcon != 0) then {[_road, _roadcon select 0] call BIS_fnc_dirTo} else {random 360};
private _roadPosition = getPos _road;
Selects random road from found roads
Gets connected roads for direction calculation
Uses road-to-connected-road direction, or random if no connections
8. Vehicle Selection:

Sqf

Apply
private _vehicleClass = selectRandom arrayCivVeh;

if (_vehicleClass == "" || {_vehicleClass == "not_supported"}) exitWith {
    Error("No vehicle class, aborting event.");
    isRivalEventInProgress = false;
    publicVariableServer "isRivalEventInProgress";
    rivalEventCooldown = 300;
    publicVariableServer "rivalEventCooldown";
};
Selects random civilian vehicle from arrayCivVeh
Exits with error if no valid vehicle found
Resets cooldown on failure
9. Vehicle Creation:

Sqf

Apply
private _chargedVehicle = createVehicle [_vehicleClass, [_roadPosition select 0, _roadPosition select 1, 0.9], [], 0, "CAN_COLLIDE"];
_chargedVehicle setDir _dirveh;

[_chargedVehicle, civilian] call A3A_fnc_AIVEHinit;
[_chargedVehicle, _proximityChance] call SCRT_fnc_rivals_plantCarDemoCharge;
Creates vehicle at road position, elevated 0.9m
Sets direction to match road
Initializes with civilian AI
Plants demo charge with specified proximity chance
10. Position Adjustment:

Sqf

Apply
private _vehiclePosition = position _chargedVehicle;
_chargedVehicle setPos [(_vehiclePosition select 0) - 1, (_vehiclePosition select 1) - 1, _vehiclePosition select 2];
Adjusts vehicle position by -1m in X and Y to create space
11. Debug Markers:

Sqf

Apply
#if __A3_DEBUG__
    private _localMarker = createMarkerLocal [format ["%1exp%2", random 10000, random 10000], (position _chargedVehicle)];
    _localMarker setMarkerSizeLocal [1,1];
    _localMarker setMarkerAlpha 1; 
    _localMarker setMarkerTypeLocal "KIA";
    _localMarker setMarkerColorLocal "ColorEAST";
#endif
In debug mode only: Creates local marker on vehicle
Marker shows as KIA icon in red
12. Cleanup Wait:

Sqf

Apply
private _timeOut = time + 1800;
waitUntil { sleep 5; (time > _timeOut) || isNull _chargedVehicle || {_allPlayers findIf {_x distance2D (position _chargedVehicle) < distanceSPWN} == -1} };
30-minute timeout (1800 seconds)
Checks every 5 seconds if:
Timeout reached
Vehicle destroyed/null
No players within spawn distance (500m)
13. Despawn and Cleanup:

Sqf

Apply
[_chargedVehicle] spawn A3A_fnc_vehDespawner;

isRivalEventInProgress = false;
publicVariableServer "isRivalEventInProgress";

rivalEventCooldown = [] call SCRT_fnc_rivals_getEventCooldown;
publicVariableServer "rivalEventCooldown";
Spawns vehicle despawner
Resets event flag
Calculates and sets cooldown for next event
Where it leads:
Functions Called:

SCRT_fnc_misc_getRebelPlayers - Gets rebel players for selection
A3A_fnc_AIVEHinit - Initializes vehicle AI
SCRT_fnc_rivals_plantCarDemoCharge - Plants explosive charge
A3A_fnc_vehDespawner - Despawns vehicle
SCRT_fnc_rivals_getEventCooldown - Gets cooldown duration
Global Variables Modified:

isRivalEventInProgress (public, server)
rivalEventCooldown (public, server)
distanceSPWN (read)
Dependencies:

Requires arrayCivVeh array
Requires distanceSPWN global
Requires A3A_faction_riv with nameLeader key (indirectly via plantCarDemoCharge)
Used By:

fn_rivals_selectAndExecuteEvent.sqf
 - When CARDEMO event selected
fn_rivals_encounter_heliRaid.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_encounter_heliRaid.sqf Line Count: 198 lines

Function: [overridePosition] spawn SCRT_fnc_rivals_encounter_heliRaid;
What it does:
Spawns a Rivals helicopter that performs a raid: either bombs a fixed position or chases players, then attacks with rockets/guns.

How it does that:
1. Parameter:

Sqf

Apply
params [["_overridePosition", []]];
Optional override position for event
2. Faction Validation:

Sqf

Apply
if ((A3A_faction_riv get "vehiclesRivalsHelis") isEqualTo []) exitWith {
    Info("No helicopters defined, rerolling another event.");
    [HELIRAID] remoteExecCall ["SCRT_fnc_encounter_selectAndExecuteEvent", 2];
};
Checks if Rivals faction has helicopters defined
If not, rerolls to different event type
3. Origin Position Selection:

Sqf

Apply
private _originPosition = nil;

if (_overridePosition isEqualTo []) then {
    _originPosition = [] call SCRT_fnc_rivals_findSuitableEncounterPosition;
} else {
    _originPosition = _overridePosition;
};

if (_originPosition isEqualTo []) exitWith {
    Error("No suitable position for event, cooldowning...");
    isRivalEventInProgress = false;
    publicVariableServer "isRivalEventInProgress";
    rivalEventCooldown = 300;
    publicVariableServer "rivalEventCooldown";
};
If no override: Calls findSuitableEncounterPosition (activity-based positioning)
If override: Uses specified position
Exits with cooldown if no position found
4. Notification Function:

Sqf

Apply
private _fnc_notifyPlayers = {
    params ["_originPosition", "_vehicles", "_timeOut"];

    while {true} do {
        sleep 0.5;
        if (_vehicles findIf {_x getVariable ["isNotified", false]} != -1) exitWith {};
        if ((time > _timeOut) || 
            (_vehicles findIf { canMove _x } == -1) || 
            (_vehicles findIf { alive (driver _x) } == -1)
        ) exitWith {};


        if (_vehicles findIf {canMove _x && {alive _x && {(position _x) distance2D _originPosition < 600}}} != -1) then {
            { 
                [
                    "RivalsActivityDetected", 
                    [
                        format [localize "STR_rivals_activity_header",  A3A_faction_riv get "name"], 
                        format [localize "STR_rivals_activity_heli_raid_description",  A3A_faction_riv get "name"]
                    ]
                ] remoteExec ["BIS_fnc_showNotification", _x];
            } forEach ((call BIS_fnc_listPlayers) select {side _x in [teamPlayer, civilian] && {(position _x) distance2D _originPosition < 125}});
            (selectRandom _vehicles) setVariable ["isNotified", true];
        }
    };
};
Nested function for periodic player notification
Checks every 0.5s if:
Already notified (avoid spam)
Timeout reached
All vehicles destroyed/crew dead
Any helicopter within 600m of origin
Notifies players within 125m
5. Helicopter Setup:

Sqf

Apply
private _finPosition = [_originPosition, 2500, (random 360)] call BIS_fnc_relPos;
private _spawnPosition = [_originPosition, 1200, 1400, 0, 0, 1] call BIS_fnc_findSafePos;
private _height = 150 + (random 75);

_spawnPosition pushBack ((_spawnPosition select 2) + _height);

private _heli = createVehicle [selectRandom (A3A_faction_riv get "vehiclesRivalsHelis"), _spawnPosition, [], 0, "FLY"];
private _angle =  [_spawnPosition,_originPosition] call BIS_fnc_dirTo;
_heli setDir _angle;
Final position: 2500m away in random direction (for exit)
Spawn position: 1200-1400m from origin, above ground
Height: 150-225m altitude
Creates helicopter in flight
Sets direction toward origin
6. Debug Markers:

Sqf

Apply
#if __A3_DEBUG__
    _heli spawn {
        while {alive _this} do {
            sleep 1;
            private _localMarker = createMarkerLocal [format ["%1test%2", random 10000, random 10000], (position _this)];
            // ... marker setup
        };
    };
#endif
Creates local marker tracking helicopter position in debug mode
7. Initial Velocity:

Sqf

Apply
private _velocity = velocity _heli;
private _direction = direction _heli;
private _speed = 50;
_heli setVelocity [
    (_velocity select 0) + (sin _direction * _speed),
    (_velocity select 1) + (cos _direction * _speed),
    (_velocity select 2)
];
Sets initial forward velocity of 50 m/s toward destination
8. Crew Creation:

Sqf

Apply
private _groupHeli = [Rivals, _heli, A3A_faction_riv get "unitRifle"] call A3A_fnc_RivalsCreateVehicleCrew;
{
    [_x] call A3A_fnc_NATOinit;	
} forEach (units _groupHeli);
[_heli, Rivals] call A3A_fnc_AIVEHinit;
Creates Rivals crew for helicopter
Initializes crew AI
Initializes helicopter AI
Adds to tracking arrays
9. Fly In Height:

Sqf

Apply
_heli flyInHeight _height;
Sets flight altitude
10. Player Detection:

Sqf

Apply
private _players = [3000, _originPosition] call SCRT_fnc_common_getNearPlayers;
private _lastPos = [];

if (_players isEqualTo []) then {
    // Bomb fixed position
    private _wp = _groupHeli addWaypoint [_originPosition, 0];
    // ... waypoint setup
    [_originPosition, _vehicles, _timeOut] spawn _fnc_notifyPlayers;
} else {
    // Chase player
    private _player = selectRandom _players;
    private _leave = false;

    private _wp = _groupHeli addWaypoint [(position _player), 0];
    // ... waypoint setup
    
    while {true} do {
        sleep 4;
        
        // Update waypoint to chase player
        deleteWaypoint [_groupHeli, 0];
        wp = _groupHeli addWaypoint [(position _player), 0];
        // ... waypoint setup
        
        if (isNil "_heli") exitWith {};
        if (!alive _heli) exitWith {};
        
        if (_heli distance2D _player < 600) then {
            [(position _player), _vehicles, _timeOut, true] spawn _fnc_notifyPlayers;
        };
        
        if (_heli distance2D _player < 500) exitWith {
            _lastPos = position _player;
            private _bombType = selectRandomWeighted ["HE", 1.5, "CLUSTER", 1.25, "CHEMICAL", 1];
            private _bombParams = [_heli, _bombType, 1, 200];
            _bombParams spawn A3A_fnc_airbomb;
        };
    };
};
Checks for players within 3000m of origin
If no players: Flies to origin, drops bomb at waypoint
If players: Randomly selects player to chase
Updates waypoint every 4 seconds to follow player
Drops bomb when within 500m
Bomb types: HE (1.5 weight), Cluster (1.25 weight), Chemical (1 weight)
11. Secondary Attack (if alive):

Sqf

Apply
if (_lastPos isNotEqualTo [] && {getPylonMagazines _heli isNotEqualTo [] && {canMove _heli && {alive _heli && {([driver _heli] call A3A_fnc_canFight)}}}}) then {
    [_heli, _groupHeli, _lastPos] spawn A3A_fnc_attackHeli;
    
    waitUntil { 
        sleep 5; 
        (time > _timeOut) || 
        !(canMove _heli) ||
        !(alive _heli) ||
        !([driver _heli] call A3A_fnc_canFight)
    };
};
If helicopter survived bombing and has pylons:
Spawns attackHeli function for gunship attack
Waits for termination conditions
12. Exit Waypoint:

Sqf

Apply
private _wp2 = _groupHeli addWaypoint [_finPosition, 1];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointSpeed "FULL";
_wp2 setWaypointTimeout [4, 5, 6];
_wp2 setWaypointStatements [
    "true", 
    "private _heli = vehicle this; private _groupHeli = group (crew _heli select 1); [_heli] spawn A3A_fnc_vehDespawner; [_groupHeli] spawn A3A_fnc_groupDespawner;"
];
Final waypoint to exit area
Waypoint statements despawn helicopter and crew on completion
13. Cleanup Wait:

Sqf

Apply
waitUntil { sleep 5; 
    (time > _timeOut) || 
    (_vehicles findIf { !(canMove _x) } != -1) || 
    (_vehicles findIf { !alive (driver _x) } != -1)
};
Waits for timeout or helicopter destruction
14. Forced Despawn:

Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Despawns all vehicles and groups
15. Event Cleanup:

Sqf

Apply
isRivalEventInProgress = false;
publicVariableServer "isRivalEventInProgress";

rivalEventCooldown = [] call SCRT_fnc_rivals_getEventCooldown;
publicVariableServer "rivalEventCooldown";
Resets event flag and sets cooldown
Where it leads:
Functions Called:

SCRT_fnc_rivals_findSuitableEncounterPosition - Finds event position
SCRT_fnc_common_getNearPlayers - Gets players near position
A3A_fnc_RivalsCreateVehicleCrew - Creates helicopter crew
A3A_fnc_NATOinit - Initializes unit AI
A3A_fnc_AIVEHinit - Initializes vehicle AI
A3A_fnc_airbomb - Spawns bomb effect
A3A_fnc_attackHeli - Handles secondary attack
A3A_fnc_vehDespawner - Despawns helicopter
A3A_fnc_groupDespawner - Despawns crew
SCRT_fnc_rivals_getEventCooldown - Gets cooldown duration
Global Variables Modified:

isRivalEventInProgress (public, server)
rivalEventCooldown (public, server)
Dependencies:

Requires A3A_faction_riv with vehiclesRivalsHelis, unitRifle keys
Requires A3A_faction_riv with name key
Requires inactivityLevelRivals (via findSuitableEncounterPosition)
Used By:

fn_rivals_selectAndExecuteEvent.sqf
 - When HELIRAID event selected
fn_rivals_encounter_OccVsRivalsskirmish.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_encounter_OccVsRivalsskirmish.sqf Line Count: 169 lines

Function: [] spawn SCRT_fnc_rivals_encounter_OccVsRivalsskirmish;
What it does:
Creates a large-scale skirmish between Occupants and Rivals near a frontline outpost. Includes infantry, vehicles, and optional UAVs.

How it does that:
1. Initial Info:

Sqf

Apply
Info("Skirmish occupants vs rivals event Init.");
2. Difficulty Rolls:

Sqf

Apply
private _difficult = random 10 < tierWar; 
private _difficult2 = random 10 < tierWar;
Rolls based on current war tier (0-10)
Higher tier = more likely to spawn elite forces
Separate rolls for Occupants and Rivals
3. Player Selection:

Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);

if (isNil "_player") exitWith {
    Error("No players found, aborting.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};
Selects random rebel player
Exits with error if no players found
Resets isEventInProgress flag
4. Origin Position:

Sqf

Apply
private _originPosition = position _player;
Info_2("%1 will be used as center of the event at %2 position.", name _player, str _originPosition);
Uses player position as origin
Logs which player and position
5. Frontline Outpost Selection:

Sqf

Apply
private _potentialOutposts = (outposts + resourcesX + factories + citiesX) select { sidesX getVariable [_x, sideUnknown] == Occupants && {(getMarkerPos _x) distance2D _player < distanceSPWN*2.5}};
if (_potentialOutposts isEqualTo []) exitWith {
    Info("No outposts in proximity, aborting Skirmish fronline Event.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};
private _FrontlineOutpost = selectRandom _potentialOutposts;
Finds Occupant-controlled outposts/locations within 2.5 * spawn distance
If none found: Exit with error and cooldown
Randomly selects one outpost
6. Faction Setup:

Sqf

Apply
private _side = Occupants; //?
private _side2 = Rivals;
private _faction = Faction(_side);
private _faction2 = Faction(_side2);
private _FrontlineOutpostPosition = getMarkerPos _FrontlineOutpost;

Info_2("Frontline outpost %1 at %2 will be used as center of the event.", _FrontlineOutpost, str _FrontlineOutpostPosition);
Sets up sides and faction objects
Gets outpost position
Logs outpost details
7. Group Type Selection:

Sqf

Apply
private _specOpsArray = if (_difficult) then {
    selectRandom (_faction get "groupSpecOpsRandom")
} else {
    selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)
};

private _specOpsArray2 = if (_difficult2) then {
    selectRandom (A3A_faction_riv get "groupsSquad")
} else {
    selectRandom ((A3A_faction_riv get "groupsFireteam") + (A3A_faction_riv get "groupsSentry") + (A3A_faction_riv get "groupsAA") + (A3A_faction_riv get "groupsAT"))
};
Occupants: If difficult: SpecOps else tiered squads
Rivals: If difficult: Squad else mixed groups (Fireteam/Sentry/AA/AT)
8. Skirmish Position:

Sqf

Apply
private _skirmishposition = [_originPosition, distanceSPWN*0.75, distanceSPWN, 1, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
private _skirmishposition2 = [_skirmishposition, 400, 550, 1, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
First position: 375-500m from player
Second position: 400-550m from first position (for Rivals spawn)
9. Group Spawning Function:

Sqf

Apply
private _fnc_spawngroups = {
    params ["_amount","_amount2", "_vehiclesAmount" , "_vehiclesAmount2" , "_difficult" , "_difficult2"];
    
    for "_i" from 1 to _amount do {
        private _skirmishpositionActuall = [_skirmishposition, 100, 250, 1, 0, 5, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
        private _InfGroup = [_skirmishpositionActuall, _side, _specOpsArray] call A3A_fnc_spawnGroup;
        {[_x] call A3A_fnc_NATOinit} forEach units _InfGroup;
        _InfGroup setBehaviourStrong "AWARE";
        private _wp = _InfGroup addWaypoint [_skirmishposition, 50];
        _wp setWaypointSpeed "NORMAL";
        _wp setWaypointType "SAD";
        _InfGroups pushBack _InfGroup;

        // Vehicle spawn
        private _vehicles = if (_difficult) then {
            selectRandom ((_faction get "vehiclesAirborne") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesTanks") + (_faction get "vehiclesAPCs") + (_faction get "vehiclesIFVs"))
        } else {
            selectRandom ((_faction get "vehiclesLightUnarmed") + (_faction get "vehiclesLightArmed") + (_faction get "vehiclesAirborne") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesMilitiaAPCs") + 
            (_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaCars"))
        };
        
        private _vehicledata = [_skirmishpositionActuall, 0, _vehicles, _side] call A3A_fnc_spawnVehicle;
        private _vehicle = _vehicledata select 0;
        private _vehiclegroup = _vehicledata select 2;
        [_vehicle, Occupants] call A3A_fnc_AIVEHinit;
        _vehiclegroup setBehaviourStrong "AWARE";
        units _vehiclegroup join _InfGroup;
        
        // Optional UAV for difficult
        if (_difficult) then {
            private _UAVtype = selectRandom (_faction get "uavsPortable");
            private _uav = createVehicle [_UAVtype, _skirmishpositionActuall, [], 0, "FLY"];
            [_side, _uav] call A3A_fnc_createVehicleCrew;
            _vehiclesArray pushBack _uav;
            private _groupUAV = group (crew _uav select 1);
            {[_x] joinSilent _InfGroup} forEach units _groupUAV;
        };
        
        [_InfGroup, "Patrol_Attack", 0, 300, 1000, true, _skirmishposition, true] call A3A_fnc_patrolLoop;
        [_vehiclegroup, "Patrol_Area", 0, 300, 1000, true, _skirmishposition, false] call A3A_fnc_patrolLoop;
        _vehiclesArray pushBack _vehicle;
    };
    
    // Rivals spawn (similar structure)
    for "_i" from 1 to _amount2 do {
        private _skirmishpositionActuall2 = [_skirmishposition2, 125, 150, 1, 0, 5, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
        private _Rivalsgroup = [_skirmishpositionActuall2, _side2, _specOpsArray2] call A3A_fnc_RivalsSpawnGroup;
        {[_x] call A3A_fnc_NATOinit} forEach units _Rivalsgroup;
        _Rivalsgroup setBehaviourStrong "AWARE";
        private _wp = _Rivalsgroup addWaypoint [_skirmishposition, 50];
        _wp setWaypointSpeed "NORMAL";
        _wp setWaypointType "SAD";
        _Rivalsgroups pushBack _Rivalsgroup;

        private _vehicles2 = if (_difficult2) then {
            selectRandom ((A3A_faction_riv get "vehiclesRivalsAPCs") + (A3A_faction_riv get "vehiclesRivalsTanks"))
        } else {
            selectRandom ((A3A_faction_riv get "vehiclesRivalsCars") + 
            (A3A_faction_riv get "vehiclesRivalsLightArmed") + (A3A_faction_riv get "vehiclesRivalsTrucks"))
        };
        
        private _vehicledata2 = [_skirmishpositionActuall2, 0,_vehicles2, _side2] call A3A_fnc_RivalsSpawnVehicle;
        private _vehicle2 = _vehicledata2 select 0;
        private _vehiclegroup2 = _vehicledata2 select 2;
        [_vehicle2, Invaders] call A3A_fnc_AIVEHinit;
        _vehiclegroup2 setBehaviourStrong "AWARE";
        units _vehiclegroup2 join _Rivalsgroup;
        [_Rivalsgroup, "Patrol_Attack", 0, 300, 1000, true, _skirmishposition, true] call A3A_fnc_patrolLoop;
        [_vehiclegroup2, "Patrol_Area", 0, 300, 1000, true, _skirmishposition, true] call A3A_fnc_patrolLoop;
        _vehiclesArray2 pushBack _vehicle2;
    };
};
Spawns Occupants groups and vehicles at first position
Spawns Rivals groups and vehicles at second position
All units set to "AWARE" behavior
Groups assigned patrol/attack waypoints toward conflict zone
Vehicles and UAVs joined to infantry groups
Uses Patrol_Attack and Patrol_Area patrol types
10. Spawn Amount Calculation:

Sqf

Apply
private _amount = round random 3;
if (_amount == 0) then {
    _amount = 1;
};
private _amount2 = _amount * 2;
if (_amount2 > 5) then {
    _amount2 = 5;
};
private _vehiclesAmount = round random 3;
private _vehiclesAmount2 = round random 3;
if (_vehiclesAmount2 == 0) then {
    _vehiclesAmount2 = 1;
};
Occupants: 1-3 groups (minimum 1)
Rivals: 2x Occupants, maximum 5 groups
Vehicles: 0-3 per side (minimum 1 for Rivals)
11. Execution:

Sqf

Apply
private _InfGroups = [];
private _Rivalsgroups = [];
private _vehiclesArray = [];
private _vehiclesArray2 = [];

[_amount, _amount2, _vehiclesAmount , _vehiclesAmount2 ,_difficult ,_difficult2] call _fnc_spawngroups;
Initializes tracking arrays
Calls spawning function
12. Mutual Spotting:

Sqf

Apply
private _friends = units _side inAreaArray [_skirmishposition, 1000, 1000];
private _friends2 = units _side2 inAreaArray [_skirmishposition, 1000, 1000];
private _friendGroups = allGroups select {(leader _x in _friends) and {isNull objectParent leader _x} };
private _friendGroups2 = allGroups select {(leader _x in _friends2) and {isNull objectParent leader _x} };

// Choose four random enemies to spot
private _allEnemiesSide1 = (units _side2) inAreaArray [_skirmishposition, 500, 500];
private _allEnemiesSide2 = (units _side) inAreaArray [_skirmishposition, 500, 500];
private _spottedEnemies = [];
private _spottedEnemies2 = [];
for "_i" from 0 to 3 do {
    if (count _allEnemiesSide1 == 0) exitWith {};
    private _index = floor random (count _allEnemiesSide1);
    _spottedEnemies pushBack (_allEnemiesSide1 # _index);
    _allEnemiesSide1 deleteAt _index;
    if (count _allEnemiesSide2 == 0) exitWith {};
    private _index2 = floor random (count _allEnemiesSide2);
    _spottedEnemies2 pushBack (_allEnemiesSide2 # _index2);
    _allEnemiesSide2 deleteAt _index2;
    {
        private _group = _x;
        { [_group, [_x, 2]] remoteExec ["reveal", leader _group] } forEach _spottedEnemies;
    } forEach _InfGroups;
    {
        private _group = _x;
        { [_group, [_x, 2]] remoteExec ["reveal", leader _group] } forEach _spottedEnemies2;
    } forEach _Rivalsgroups;
    sleep 60;
};
Gets all ground units within 1000m
Gets groups of those units
Selects 4 random enemies from each side within 500m
Every 60 seconds, reveals spotted enemies to opposing groups
Ensures groups know about each other immediately
13. Cleanup Wait:

Sqf

Apply
private _timeOut = time + 1800;
waitUntil {time > _timeOut && (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_skirmishposition, distanceSPWN1, distanceSPWN1] isEqualTo []};
30-minute timeout
Also waits for no rebel players within spawn distance (500m)
Uses distanceSPWN1 (likely a typo - should be distanceSPWN)
14. Despawn:

Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _InfGroups;
{[_x] spawn A3A_fnc_groupDespawner} forEach _Rivalsgroups;
Despawns all vehicles and groups
15. Event Cleanup:

Sqf

Apply
isEventInProgress = false;
publicVariableServer "isEventInProgress";
Resets event flag
Where it leads:
Functions Called:

SCRT_fnc_misc_getRebelPlayers - Gets rebel players
Faction - Gets faction object
SCRT_fnc_unit_flattenTier - Flattens tiered group lists
A3A_fnc_spawnGroup - Spawns Occupants groups
A3A_fnc_NATOinit - Initializes unit AI
A3A_fnc_spawnVehicle - Spawns Occupants vehicle
A3A_fnc_AIVEHinit - Initializes vehicle AI
A3A_fnc_createVehicleCrew - Creates UAV crew
A3A_fnc_patrolLoop - Sets up patrols
A3A_fnc_RivalsSpawnGroup - Spawns Rivals groups
A3A_fnc_RivalsSpawnVehicle - Spawns Rivals vehicle
A3A_fnc_vehDespawner - Despawns vehicles
A3A_fnc_groupDespawner - Despawns groups
Global Variables Modified:

isEventInProgress (public, server)
distanceSPWN (read)
tierWar (read)
Dependencies:

Requires outposts, resourcesX, factories, citiesX arrays
Requires sidesX hash map
Requires A3A_faction_riv with various vehicle/group keys
Requires A3A_faction_occ with vehicle/group keys
Requires Faction function
Used By:

fn_rivals_selectAndExecuteEvent.sqf
 - When SKIRMISH_OCCVSRIV event selected
fn_rivals_encounter_policeVsRivalsskirmish.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_encounter_policeVsRivalsskirmish.sqf Line Count: 172 lines

Function: [] spawn SCRT_fnc_rivals_encounter_policeVsRivalsskirmish;
What it does:
Spawns a skirmish between police (Occupants) and Rivals in a neutral city. Includes police vehicles with patrol routes and Rivals vehicles.

How it does that:
1. Initial Setup:

Sqf

Apply
Info("Police vs Invaders Event Init.");

private _vehicles = [];
private _groups = [];
2. Player Selection:

Sqf

Apply
private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);

if (isNil "_player") exitWith {
    Error("No players found, aborting.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};
Selects random rebel player
Exits if no players found
3. City Selection:

Sqf

Apply
private _cities = citiesX select {sidesX getVariable [_x, sideUnknown] != teamPlayer && {spawner getVariable _x != 2} && {!(_x in destroyedSites)}};

if (_cities isEqualTo []) exitWith {
    Info("No neutral cities available, aborting event.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};

private _city = selectRandom _cities;
private _cityPos = getMarkerPos _city;
Filters cities that are:
NOT controlled by rebels
NOT despawned (spawner != 2)
NOT destroyed
Selects random city from filtered list
Gets city position
4. Police Force Spawning Function:

Sqf

Apply
private _fnc_spawnPoliceForces = {
    params ["_side", "_basePos", "_vehicleTypes", "_unitGroupType"];
    
    private _numGroups = selectRandom [1, 2];
    
    for "_i" from 1 to _numGroups do {
        // Find nearby road
        private _road = objNull;
        private _radius = 50;
        private _foundRoad = false;

        while {!_foundRoad && _radius <= 300} do {
            private _nearRoads = _basePos nearRoads _radius;

            if (count _nearRoads > 0) then {
                _road = selectRandom _nearRoads;
                _foundRoad = true;
            } else {
                _radius = _radius + 50;
            };
        };

        // Determine spawn position
        private _spawnPos = if (!isNull _road) then {
            getPosATL _road
        } else {
            _basePos getPos [random 150, random 360]
        };
        
        // Use random position if no roads found
        if (isNull _road) then {
            _road = _basePos getPos [random 150, random 360];
            _road setPosATL [getPosATL _road#0, getPosATL _road#1, 0];
        };
        
        // Spawn vehicle
        private _vehicleType = selectRandom _vehicleTypes;
        private _vehData = [_spawnPos, random 360, _vehicleType, _side] call A3A_fnc_spawnVehicle;
        private _vehicle = _vehData select 0;
        _crewGroup = _vehData select 2;
        [_vehicle, _side] call A3A_fnc_AIVEHinit;
        [_vehicle, ["BeaconsStart", 1]] remoteExecCall ["animate", 0, _vehicle];
        private _typeCargoGroup = [_vehicleType, Occupants] call A3A_fnc_cargoSeats;
        private _cargoGroup = [_spawnPos, Occupants, _typeCargoGroup, true,false] call A3A_fnc_spawnGroup;

        (units _crewGroup) join _cargoGroup;
        _groups pushBack _cargoGroup;

        // Adding patrol points
        private _wp = _cargoGroup addWaypoint [_cityPos, 50];
        _wp setWaypointType "MOVE";
        sleep 5;
        _wp setWaypointType "SAD";
        _wp setWaypointSpeed "FULL";
        _wp setWaypointBehaviour "AWARE";

        _vehicles pushBack _vehicle;
    };
};
Spawns 1-2 police groups
Finds road or random position within 150m
Spawns police vehicle
Turns on police lights (beacons)
Spawns cargo group for vehicle
Joins crew to cargo group
Sets waypoint to city center, then SAD (Seek And Destroy) mode
Tracks vehicles and groups
5. Rivals Force Spawning Function:

Sqf

Apply
private _fnc_spawnForces = {
    params ["_side", "_basePos", "_vehicleTypes", "_unitGroupType"];
    
    private _numGroups = selectRandom [1, 2];
    
    for "_i" from 1 to _numGroups do {
        // Similar road finding logic
        
        // Spawn Rivals vehicle
        private _vehicleType = selectRandom _vehicleTypes;
        private _vehData = [_spawnPos, random 360, _vehicleType, Rivals] call A3A_fnc_RivalsSpawnVehicle;
        private _vehicle = _vehData select 0;
        _crewGroup = _vehData select 2;
        [_vehicle, Rivals] call A3A_fnc_AIVEHinit;
        private _group = [_spawnPos, Rivals, _unitGroupType, true] call A3A_fnc_RivalsSpawnGroup;

        (units _crewGroup) join _group;
        _groups pushBack _group;

        // Adding patrol points
        private _wp = _group addWaypoint [_cityPos, 50];
        _wp setWaypointType "MOVE";
        sleep 5;
        _wp setWaypointType "SAD";
        _wp setWaypointSpeed "FULL";
        _wp setWaypointBehaviour "AWARE";

        _vehicles pushBack _vehicle;
    };
};
Similar structure but uses Rivals spawn functions
Spawns Rivals vehicle and group
Joins crew to group
Sets similar patrol waypoints
6. Spawn Execution:

Sqf

Apply
// Spawn police forces (Occupants)
[Occupants, _cityPos getPos [100, random 360], (A3A_faction_occ get "vehiclesPolice"), (A3A_faction_occ get "groupPolice")] call _fnc_spawnPoliceForces;

// Spawn rival forces
[Rivals, _cityPos getPos [300, random 360 + 180], (A3A_faction_riv get "vehiclesRivalsLightArmed") + (A3A_faction_riv get "vehiclesRivalsCars"), (selectRandom (A3A_faction_riv get "groupsSentry"))] call _fnc_spawnForces;
Police spawn: 100m from city center, random direction
Police vehicles, police group type
Rivals spawn: 300m from city center, opposite direction (180°)
Light armed + cars, Sentry groups
7. Set Mutual Hostility:

Sqf

Apply
{_x setCombatMode "YELLOW"} forEach _groups;
Sets all groups to "YELLOW" combat mode (engage enemies at will)
8. Cleanup Wait:

Sqf

Apply
private _timeOut = time + 1200;
waitUntil {
    sleep 5;
    time > _timeOut || 
    {(call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _cityPos < 1400} == -1}
};
20-minute timeout (1200 seconds)
Also waits for no rebel players within 1400m of city
9. Despawn:

Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Despawns all vehicles and groups
10. Event Cleanup:

Sqf

Apply
isEventInProgress = false;
publicVariableServer "isEventInProgress";
Info("Police vs Rivals Event cleanup complete.");
Resets event flag
Where it leads:
Functions Called:

SCRT_fnc_misc_getRebelPlayers - Gets rebel players
A3A_fnc_spawnVehicle - Spawns police vehicle
A3A_fnc_AIVEHinit - Initializes vehicle AI
A3A_fnc_cargoSeats - Gets cargo group type
A3A_fnc_spawnGroup - Spawns police cargo group
A3A_fnc_RivalsSpawnVehicle - Spawns Rivals vehicle
A3A_fnc_RivalsSpawnGroup - Spawns Rivals group
A3A_fnc_vehDespawner - Despawns vehicles
A3A_fnc_groupDespawner - Despawns groups
Global Variables Modified:

isEventInProgress (public, server)
Dependencies:

Requires citiesX array
Requires sidesX hash map
Requires spawner hash map
Requires destroyedSites array
Requires A3A_faction_occ with vehiclesPolice, groupPolice keys
Requires A3A_faction_riv with vehiclesRivalsLightArmed, vehiclesRivalsCars, groupsSentry keys
Used By:

fn_rivals_selectAndExecuteEvent.sqf
 - When SKIRMISH_POLICEVSRIV event selected
fn_rivals_encounter_rovingMortar.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_encounter_rovingMortar.sqf Line Count: 201 lines

Function: [overridePosition, isInstant] spawn SCRT_fnc_rivals_encounter_rovingMortar;
What it does:
Spawns a Rivals mortar team with support vehicle that provides artillery bombardment. Includes destruction detection and theft detection.

How it does that:
1. Parameters:

Sqf

Apply
params [
    ["_overridePosition", []],
    ["_isInstant", false]
];
Optional override position
Boolean for instant deployment (skip setup time)
2. Origin Position Selection:

Sqf

Apply
private _originPosition = nil;
private _earlyEscape = false;
private _logMessage = nil;
private _logSeverity = -1;

if (_overridePosition isEqualTo []) then {
    _originPosition = [] call SCRT_fnc_rivals_findSuitableEncounterPosition;
} else {
    _originPosition = _overridePosition;
};

if (_originPosition isEqualTo []) exitWith {
    Info("No suitable position for event, cooldowning...");
    isRivalEventInProgress = false;
    publicVariableServer "isRivalEventInProgress";
    rivalEventCooldown = 300;
    publicVariableServer "rivalEventCooldown";
};
Finds suitable position or uses override
Exits with cooldown if no position found
3. Override Position Handling:

Sqf

Apply
if (_overridePosition isNotEqualTo []) then {
    private _players = [1000, _originPosition] call SCRT_fnc_common_getNearPlayers;
    private _player = selectRandom _players; 

    _originPosition = position (selectRandom _players);
};
If override provided: Get players within 1000m
Sets origin to random player's position
Used when called as support for other missions
4. Support Name:

Sqf

Apply
private _supportName = format ["%1rovingmortar%2", random 10000, random 10000];
Unique identifier for this mortar support
5. Precision and Reveal Calculation:

Sqf

Apply
private _precision = 0;
private _revealCall = 0;

switch (inactivityLevelRivals) do {
    case 5: { _precision = 0.5; _revealCall = 0.8; };
    case 4: { _precision = 1; _revealCall = 0.6; };
    case 3: { _precision = 2; _revealCall = 0.4; };
    case 2: { _precision = 3; _revealCall = 0.2; };
    case 1: { _precision = 3.5; _revealCall = 0.1; };
};
Precision: Higher activity = worse accuracy (larger number)
Level 5: 0.5m spread
Level 1: 3.5m spread
Reveal Call: Probability of players being notified
Level 5: 80% chance of notification
Level 1: 10% chance of notification
6. Target List Setup:

Sqf

Apply
server setVariable [format ["%1_targets", _supportName], [[[_originPosition, _precision], _revealCall]], true];
Sets server variable with target info
Format: [[[position, precision], revealProbability]]
7. Spawn Position with Safety Check:

Sqf

Apply
private _spawnPosition = [_originPosition, 1200, 2000, 8, 0, 1] call BIS_fnc_findSafePos;
private _sites = (outposts + airportsX + resourcesX + factories + seaports + milbases) select {sidesX getVariable [_x, sideUnknown] != Rivals};

//if too close to some outposts - reroll if possible
if (count _sites > 0 && {_sites findIf {private _markerPos = getMarkerPos _x; _markerPos distance2D _spawnPosition < 800 } != -1 }) then {
    private _iterations = 0;
    private _radius = 1200;
    while {_iterations < 50} do {
        _spawnPosition = [_originPosition, 1200, _radius, 8, 0, 1] call BIS_fnc_findSafePos;

        private _isClose = _sites findIf { private _markerPos = getMarkerPos _x; _markerPos distance2D _spawnPosition < 1200 } != -1;

        if(!_isClose) exitWith {};
        _radius = _radius + 50;
        _iterations = _iterations + 1;
    };
};
Finds spawn position 1200-2000m from origin
Gets all enemy sites
If spawn position within 800m of any site: Reroll up to 50 times
Increases search radius by 50m each iteration
8. Mortar Creation:

Sqf

Apply
private _mortar = [selectRandom (A3A_faction_riv get "staticMortars"), _spawnPosition, 5, 5, true] call A3A_fnc_safeVehicleSpawn;
[_mortar, Rivals] call A3A_fnc_AIVEHinit;
_vehicles pushBack _mortar;

Info_1("Roving mortar has been created at %1 position.", str _spawnPosition);
Spawns mortar using safe spawn
Initializes mortar AI
Logs mortar position
9. Mortar Crew:

Sqf

Apply
private _mortarGroup = [Rivals, _mortar, A3A_faction_riv get "unitRifle"] call A3A_fnc_RivalsCreateVehicleCrew;
_groups pushBack _mortarGroup;

_mortar setVariable ["shellType", A3A_faction_riv get "mortarMagazineHE", true];
[_mortar] call A3A_fnc_addArtilleryTrailEH;
Creates mortar crew
Sets shell type to HE
Adds artillery trail event handler
10. Patrol Group:

Sqf

Apply
private _patrolPosition = [
    _spawnPosition,
    0,
    50,
    2,
    0,
    1,
    0,
    [],
    [_spawnPosition, _spawnPosition]
] call BIS_fnc_findSafePos;

private _carPos =  [_spawnPosition, (random [4,6,8]), (random 360)] call BIS_fnc_relPos;
private _car = (selectRandom (A3A_faction_riv get "vehiclesRivalsCars")) createVehicle _spawnPosition;
private _dirCar = [_mortar, _car] call BIS_fnc_dirTo;
_car setDir _dirCar + (random 90);
[_car, Rivals] call A3A_fnc_AIVEHinit;
_car engineOn true;

_vehicles pushBack _car;

private _patrolGroup = [_patrolPosition, Rivals, (selectRandom (A3A_faction_riv get "groupsSentry"))] call A3A_fnc_RivalsSpawnGroup;
{
    [_x] call A3A_fnc_NATOinit;
} forEach units _patrolGroup;
[_patrolGroup, _spawnPosition, 150] call bis_fnc_taskPatrol;
_groups pushBack _patrolGroup;
Creates patrol position 50m from mortar
Spawns support car 4-8m away, perpendicular to mortar
Spawns Sentry group for patrols
Sets 150m radius patrol around mortar
11. Mortar Destruction Event Handler:

Sqf

Apply
_mortar addEventHandler
[
    "Killed",
    {
        params ["_mortar"];
        ["TaskSucceeded", ["", format [localize "STR_notifiers_roving_mortar_crew_destroyed", A3A_faction_riv get "name"]]] remoteExec ["BIS_fnc_showNotification", teamPlayer];
        [10, 60] remoteExec ["SCRT_fnc_rivals_reduceActivity",2];
    }
];
On mortar death: Notifies players, reduces activity by 10 over 60s
12. Theft Event Handler:

Sqf

Apply
_mortar addEventHandler
[
    "GetIn",
    {
        params ["_vehicle", "_role", "_unit", "_turret"];
        if(side (group _unit) == teamPlayer) then
        {
            ["TaskSucceeded", ["", format [localize "STR_notifiers_roving_mortar_stolen", A3A_faction_riv get "name"]]] remoteExec ["BIS_fnc_showNotification", teamPlayer];
            [10, 60] remoteExec ["SCRT_fnc_rivals_reduceActivity",2];
            _vehicle setVariable ["Stolen", true, true];
            _vehicle removeAllEventHandlers "GetIn";
        };
    }
];
On player entry: Notifies, reduces activity, sets stolen flag
Removes handler after first trigger
13. Crew Death Event Handler:

Sqf

Apply
{
    _x addEventHandler
    [
        "Killed",
        {
            params ["_unit"];
            private _group = group _unit;
            if({alive _x} count (units _group) == 0) then
            {
                ["TaskSucceeded", ["", format [localize "STR_notifiers_roving_mortar_crew_killed", A3A_faction_riv get "name"]]] remoteExec ["BIS_fnc_showNotification", teamPlayer];
                [10, 60] remoteExec ["SCRT_fnc_rivals_reduceActivity",2];
            };
        }
    ];
} forEach (units _mortarGroup);
Checks if all crew members are dead
Notifies and reduces activity if entire crew killed
14. Setup Time Calculation:

Sqf

Apply
private _setupTime = if (_isInstant) then {10} else {60 - (((5 - inactivityLevelRivals) + 1) * 5)};
private _minSleepTime = (1 - ((5 - inactivityLevelRivals) + 1) * 0.1) * _setupTime;
private _sleepTime = _minSleepTime + random (_setupTime - _minSleepTime);
Instant: 10 seconds minimum
Normal: 60 - ((level difference + 1) * 5)
Level 5: 60 - 5 = 55s
Level 1: 60 - 25 = 35s
Minimum sleep time scales with level
Random variation added
15. Mortar Routine Spawn:

Sqf

Apply
_mortarGroup deleteGroupWhenEmpty true;
sleep 10;
[_mortar, _mortarGroup, _supportName, _sleepTime] spawn SCRT_fnc_rivals_mortarRoutine;
Group deletes when empty
10-second initial sleep
Spawns mortar routine with calculated sleep time
16. Cleanup Wait:

Sqf

Apply
private _timeOut = time + 1800;
waitUntil { sleep 5; (time > _timeOut) || (_mortar getVariable ['isFireMissionEnded', false]) || !alive _mortar};
30-minute timeout
Also exits when mortar completes mission or dies
17. Despawn:

Sqf

Apply
{
    [_x] spawn A3A_fnc_vehDespawner;
} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Despawns all vehicles and groups
18. Event Cleanup:

Sqf

Apply
//usually overriden position means that encounter used as support or task event (yeah,it's dirty)
if (isNil "_overridePosition") then {
    isRivalEventInProgress = false;
    publicVariableServer "isRivalEventInProgress";

    rivalEventCooldown = [] call SCRT_fnc_rivals_getEventCooldown;
    publicVariableServer "rivalEventCooldown";
};
Only resets event flags if NOT used as support (no override)
If used as support, caller manages flags
Where it leads:
Functions Called:

SCRT_fnc_rivals_findSuitableEncounterPosition - Finds event position
SCRT_fnc_common_getNearPlayers - Gets nearby players
A3A_fnc_safeVehicleSpawn - Spawns mortar safely
A3A_fnc_AIVEHinit - Initializes mortar AI
A3A_fnc_RivalsCreateVehicleCrew - Creates mortar crew
A3A_fnc_addArtilleryTrailEH - Adds trail effect
A3A_fnc_RivalsSpawnGroup - Spawns patrol group
A3A_fnc_NATOinit - Initializes patrol AI
SCRT_fnc_rivals_mortarRoutine - Starts mortar bombardment
A3A_fnc_vehDespawner - Despawns vehicles
A3A_fnc_groupDespawner - Despawns groups
SCRT_fnc_rivals_getEventCooldown - Gets cooldown (if not support)
Global Variables Modified:

isRivalEventInProgress (public, server - only if not support)
rivalEventCooldown (public, server - only if not support)
server variables for mortar targets
Dependencies:

Requires A3A_faction_riv with staticMortars, unitRifle, mortarMagazineHE, vehiclesRivalsCars, groupsSentry keys
Requires A3A_faction_riv with name key
Requires inactivityLevelRivals
Requires teamPlayer side
Used By:

fn_rivals_selectAndExecuteEvent.sqf
 - When ROVINGMORTAR event selected
Can also be called as support for other missions
fn_rivals_encounter_uavFlyby.sqf
File: A3A/addons/scrt/Rivals/fn_rivals_encounter_uavFlyby.sqf Line Count: 255 lines

Function: [overridePosition] spawn SCRT_fnc_rivals_encounter_uavFlyby;
What it does:
Spawns Rivals UAVs that fly over an area, dropping grenades or shells on players. UAVs can chase players or fly fixed routes.

How it does that:
1. Parameter:

Sqf

Apply
params [["_overridePosition", []]];
Optional override position for event
2. Faction Validation:

Sqf

Apply
if ((A3A_faction_riv get "vehiclesRivalsUavs") isEqualTo []) exitWith {
    Info("No supported UAVs, rerolling another event.");
    [UAVGRENADE] remoteExecCall ["SCRT_fnc_encounter_selectAndExecuteEvent", 2];
};
Checks if Rivals faction has UAVs defined
If not, rerolls to different event
3. Origin Position Selection:

Sqf

Apply
private _originPosition = nil;

if (_overridePosition isEqualTo []) then {
    _originPosition = [] call SCRT_fnc_rivals_findSuitableEncounterPosition;
} else {
    _originPosition = _overridePosition;
};

if (_originPosition isEqualTo []) exitWith {
    Error("No suitable position for event, cooldowning...");
    isRivalEventInProgress = false;
    publicVariableServer "isRivalEventInProgress";
    rivalEventCooldown = 300;
    publicVariableServer "rivalEventCooldown";
};
Finds suitable position or uses override
Exits with cooldown if no position
4. Notification Function:

Sqf

Apply
private _fnc_notifyPlayers = {
    params ["_originPosition", "_vehicles", "_timeOut"];

    while {true} do {
        sleep 0.5;
        if (_vehicles findIf {_x getVariable ["isNotified", false]} != -1) exitWith {};
        if ((time > _timeOut) || 
            (_vehicles findIf { canMove _x } == -1) || 
            (_vehicles findIf { alive (driver _x) } == -1)
        ) exitWith {};

        if (_vehicles findIf {canMove _x && {alive _x && {(position _x) distance2D _originPosition < 75}}} != -1) then {
            { 
                [
                    "RivalsActivityDetected", 
                    [
                        format [localize "STR_rivals_activity_header",  A3A_faction_riv get "name"], 
                        localize "STR_rivals_activity_drone_strike_description"
                    ]
                ] remoteExec ["BIS_fnc_showNotification", _x];
            } forEach ((call BIS_fnc_listPlayers) select {side _x in [teamPlayer, civilian] && {(position _x) distance2D _originPosition < 125}});
            (selectRandom _vehicles) setVariable ["isNotified", true];
        };
    };
};
Similar to helicopter notification but:
UAV within 75m triggers notification
Players notified within 125m
5. UAV Quantity Calculation:

Sqf

Apply
private _uavQuantity = switch (inactivityLevelRivals) do {
    case 5: { 1 };
    case 4: { round (random [1,2,2]) };
    case 3: { round (random [1,2,3]) };
    case 2: { round (random [2,2,4]) };
    case 1: { round (random [2,3,4]) };
};
Level 5: 1 UAV
Level 4: 1-2 UAVs
Level 3: 1-3 UAVs
Level 2: 2-4 UAVs
Level 1: 2-4 UAVs
6. UAV Spawn Loop:

Sqf

Apply
for "_i" from 0 to _uavQuantity - 1 do {
    private _finPosition = [_originPosition, 2500, (random 360)] call BIS_fnc_relPos;
    private _spawnPosition = [_originPosition, 1200, 1400, 0, 0, 1] call BIS_fnc_findSafePos;
    private _isHeavyShell = [] call SCRT_fnc_rivals_rollProbability;
    private _height = 50 + (random 75);

    if (!_isHeavyShell) then {
        _height = 50 + (random 25);
    };

    _spawnPosition pushBack ((_spawnPosition select 2) + _height);

    private _uav = createVehicle [selectRandom (A3A_faction_riv get "vehiclesRivalsUavs"), _spawnPosition, [], 0, "FLY"];
    private _angle =  [_spawnPosition,_originPosition] call BIS_fnc_dirTo;
    _uav setDir _angle;
Creates exit position 2500m away
Spawn position 1200-1400m from origin
Checks if heavy shell (probability based on activity)
Height: 50-125m for heavy, 50-75m for normal
Creates UAV in flight, pointing toward origin
7. Velocity Setup:

Sqf

Apply
private _velocity = velocity _uav;
private _direction = direction _uav;
private _speed = 50;
_uav setVelocity [
    (_velocity select 0) + (sin _direction * _speed),
    (_velocity select 1) + (cos _direction * _speed),
    (_velocity select 2)
];
Sets initial 50 m/s forward velocity
8. UAV Crew and Event Handler:

Sqf

Apply
[Rivals, _uav] call A3A_fnc_RivalsCreateVehicleCrew;
[_uav, Rivals] call A3A_fnc_AIVEHinit;

_vehicles pushBack _uav;

private _hitEhId = _uav addEventHandler ["Hit", {
    params ["_unit", "_source", "_damage", "_instigator"];
    private _chargePos = getPosWorld _unit; 

    private _charge = "DemoCharge_Remote_Ammo_Scripted" createVehicle [0,0,0]; 
    _charge attachTo [_unit, [0,0,0]];
    _charge setPosWorld _chargePos; 
    _charge setDamage 1; 

    _unit removeEventHandler [_thisEvent, _thisEventHandler]; 
}];
_uav setVariable ["ehId", _hitEhId];
Creates Rivals crew for UAV
Adds "Hit" event handler: On damage, creates explosive at UAV position
Removes handler after first trigger (one-time self-destruct)
9. Group Setup:

Sqf

Apply
private _groupUav = group (crew _uav select 0);
_groups pushBack _groupUav;

_uav flyInHeight _height;
Gets UAV group from crew
Sets flight altitude
10. Player Detection:

Sqf

Apply
private _players = [1000, _originPosition] call SCRT_fnc_common_getNearPlayers;

if (_players isEqualTo []) then {
    // Fly fixed route, drop at waypoint
    private _wp = _groupUav addWaypoint [_originPosition, 0];
    // ... waypoint setup
    
    if (_isHeavyShell) then {
        _wp setWaypointStatements [
            "true", 
            "private _uav = vehicle this; private _uavPos = position _uav; private _shell = (selectRandom (A3A_faction_riv get 'mortarAmmo')) createVehicle [_uavPos select 0, _uavPos select 1, (_uavPos select 2) - 4]; _shell setDir (getDir _uav); _shell setVectorDirAndUp [[0,0,-1],[0.1,0.1,1]]; _shell setVelocity [0,0,-50]; [_uav, _shell] remoteExecCall ['disableCollisionWith', 0, _shell]; _uav removeEventHandler ['Hit', (_uav getVariable ['ehId', 0])];"
        ];
    } else {
        _wp setWaypointStatements [
            "true", 
            "private _uav = vehicle this; private _uavPos = position _uav; private _grenade = (selectRandom (A3A_faction_riv get 'handGrenadeAmmo')) createVehicle [_uavPos select 0, _uavPos select 1, (_uavPos select 2) - 4]; [_uav, _grenade] remoteExecCall ['disableCollisionWith', 0, _grenade]; _uav removeEventHandler ['Hit', (_uav getVariable ['ehId', 0])];"
        ];
    };

    [_originPosition, _vehicles, _timeOut] spawn _fnc_notifyPlayers;
} else {
    // Chase player
    private _player = selectRandom _players;

    [_uav, _player, _isHeavyShell, _timeOut, _vehicles, _fnc_notifyPlayers] spawn {
        params ["_uav", "_player", "_isHeavyShell", "_timeOut", "_vehicles", "_fnc_notifyPlayers"];
        while {true} do {
            sleep 3;

            //UAVs should chase player
            _uav doMove (position _player);

            if (isNil "_uav") exitWith {};
            if (!alive _uav) exitWith {};

            if (_uav distance2D _player < 45) then {
                [(position _player), _vehicles, _timeOut] spawn _fnc_notifyPlayers;
            };

            if (_uav distance2D _player < 25) exitWith {
                if (_isHeavyShell) then {
                    private _uavPos = position _uav; 
                    private _shell = (selectRandom (A3A_faction_riv get "mortarAmmo")) createVehicle [_uavPos select 0, _uavPos select 1, (_uavPos select 2) - 4]; 
                    _shell setDir (getDir _uav); 
                    _shell setVectorDirAndUp [[0,0,-1],[0.1,0.1,1]]; 
                    _shell setVelocity [0,0,-50]; [_uav, _shell] remoteExecCall ['disableCollisionWith', 0, _shell];
                    _uav removeEventHandler ['Hit', (_uav getVariable ['ehId', 0])];
                } else {
                    if ("BombDemine_01_F" in (weapons _uav)) then{
                        [_uav, "BombDemine_01_F"] call BIS_fnc_fire;
                        Info_1("Grenade Ammo Class: %1", "BombDemine_01_F");
                        _uav removeEventHandler ['Hit', (_uav getVariable ['ehId', 0])];
                    } else {
                        if ("Bomb_40mm_HE_lxWS" in (weapons _uav)) then {
                            [_uav, "Bomb_40mm_HE_lxWS"] call BIS_fnc_fire;
                            Info_1("Grenade Ammo Class: %1", "Bomb_40mm_HE_lxWS");
                            _uav removeEventHandler ['Hit', (_uav getVariable ['ehId', 0])];
                        } else {
                            private _uavPos = position _uav; 
                            private _grenadeAmmoClass = selectRandom (A3A_faction_riv get "handGrenadeAmmo");
                            Info_1("Grenade Ammo Class: %1", _grenadeAmmoClass);
                            private _grenade = _grenadeAmmoClass createVehicle [_uavPos select 0, _uavPos select 1, (_uavPos select 2) - 4]; 
                            [_uav, _grenade] remoteExecCall ['disableCollisionWith', 0, _grenade]; 
                            _uav removeEventHandler ['Hit', (_uav getVariable ['ehId', 0])];
                        };
                    };
                };
            };
        };
    };
};
Checks for players within 1000m of origin
If no players: Fixed route with waypoint bomb drop
Heavy shell: Spawns mortar ammo with physics
Normal: Spawns grenade
If players: Chases random player
Updates position every 3s
Drops bomb when within 25m
Tries to use UAV's own weapons first, then grenade
11. Exit Waypoint:

Sqf

Apply
private _wp2 = _groupUav addWaypoint [_finPosition, 1];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointSpeed "FULL";
_wp2 setWaypointTimeout [4, 5, 6];
_wp2 setWaypointStatements [
    "true", 
    "private _uav = vehicle this; private _groupUav = group (crew _uav select 1); [_uav] spawn A3A_fnc_vehDespawner; [_groupUav] spawn A3A_fnc_groupDespawner; _uav removeEventHandler ['Hit', (_uav getVariable ['ehId', 0])];"
];
Final waypoint to exit area
Despawns UAV and crew on completion
Removes hit event handler
12. Cleanup Wait:

Sqf

Apply
waitUntil { sleep 5; 
    (time > _timeOut) || 
    (_vehicles findIf { !(canMove _x) } != -1) || 
    (_vehicles findIf { !alive (driver _x) } != -1)
};
Waits for timeout or UAV destruction
13. Forced Cleanup:

Sqf

Apply
{
    _x removeEventHandler ['Hit', (_x getVariable ['ehId', 0])];
    [_x] spawn A3A_fnc_vehDespawner;
} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Removes hit event handlers from all UAVs
Despawns all vehicles and groups
14. Event Cleanup:

Sqf

Apply
isRivalEventInProgress = false;
publicVariableServer "isRivalEventInProgress";

rivalEventCooldown = [] call SCRT_fnc_rivals_getEventCooldown;
publicVariableServer "rivalEventCooldown";
Resets event flag and sets cooldown
Where it leads:
Functions Called:

SCRT_fnc_rivals_findSuitableEncounterPosition - Finds event position
SCRT_fnc_common_getNearPlayers - Gets nearby players
SCRT_fnc_rivals_rollProbability - Rolls for heavy shell
A3A_fnc_RivalsCreateVehicleCrew - Creates UAV crew
A3A_fnc_AIVEHinit - Initializes UAV AI
BIS_fnc_fire - Fires UAV weapon
A3A_fnc_vehDespawner - Despawns UAVs
A3A_fnc_groupDespawner - Despawns crew
SCRT_fnc_rivals_getEventCooldown - Gets cooldown duration
Global Variables Modified:

isRivalEventInProgress (public, server)
rivalEventCooldown (public, server)
Dependencies:

Requires A3A_faction_riv with vehiclesRivalsUavs, mortarAmmo, handGrenadeAmmo keys
Requires A3A_faction_riv with name key
Requires inactivityLevelRivals (via findSuitableEncounterPosition)
Used By:

fn_rivals_selectAndExecuteEvent.sqf
 - When UAVGRENADE event selected

fn_support_chemicalBomb.sqf
File: A3A/addons/scrt/Support/fn_support_chemicalBomb.sqf Line Count: 39 lines

Function: [position, direction, pitchBank, side] spawn SCRT_fnc_support_chemicalBomb;
What it does:
Spawns a chemical bomb effect with gas cloud visualization, damage application over time, and aggression penalties if fired by rebels.

How it does that:
1. Parameter Validation:

Sqf

Apply
params ["_position", "_direction", "_pitchBank", "_side"];
if (!isServer) exitWith {};
if (isNil "_position") exitWith {};
if (count _position == 0) exitWith {};
Takes bomb position, direction, pitch/bank angles, and side that fired it
Runs only on server
Validates position exists and has coordinates
2. Randomized Deployment Delay:

Sqf

Apply
sleep random [0.8,1.2,1.6];
Sleeps 0.8-1.6 seconds before detonation for realism
3. Sound Selection:

Sqf

Apply
private _chemicalSpreadingSounds = [
    "A3\Sounds_f\weapons\smokeshell\smoke_1.wss",
    "A3\Sounds_f\weapons\smokeshell\smoke_2.wss",
    "A3\Sounds_f\weapons\smokeshell\smoke_3.wss"
];
Array of smoke shell sound files
4. Temporary Object Creation:

Sqf

Apply
private _tempObject = createVehicle ["Land_HelipadEmpty_F", _position, [], 0, "FLY"];
private _angle = random [30,45,60];
private _worldPosition = getPosWorld _tempObject;
Creates invisible object at position to serve as reference
Calculates random vertical angle (30-60°)
Gets world position for precision
5. Shell Creation and Positioning:

Sqf

Apply
private _shell = createSimpleObject ["Bo_Mk82_MI08", _worldPosition, false];
_shell setDir (_direction - 180);
[_shell, (-(_pitchBank select 0)), (_pitchBank select 1)] call BIS_fnc_setPitchBank;
Creates simple shell object (visual only)
Sets direction (inverted from input)
Sets pitch and bank angles using BIS function
6. Effect and Sound:

Sqf

Apply
_tempObject remoteExec ["SCRT_fnc_effect_createGasEffect", 0];
playSound3D [(selectRandom _chemicalSpreadingSounds), _shell];
Triggers gas effect creation on all clients
Plays random chemical spreading sound from shell position
7. Damage Application:

Sqf

Apply
sleep 4;
[_tempObject] spawn SCRT_fnc_common_chemicalDamage;
Waits 4 seconds for gas to spread
Spawns chemical damage function to apply damage over time
8. Cleanup Wait (First Phase):

Sqf

Apply
private _timeOut = time + 140;
waitUntil {sleep 1; time > _timeOut};
deleteVehicle _tempObject;
140-second timeout for damage phase
Deletes temporary object after damage application complete
9. Aggression Penalty (If Fired by Rebels):

Sqf

Apply
if (_side == teamPlayer) then {
    [Occupants, 200, 60] remoteExec ["A3A_fnc_addAggression",2];
    [Invaders, 200, 60] remoteExec ["A3A_fnc_addAggression",2];
};
If rebels fired the bomb: Adds 200 aggression over 60 minutes to Occupants and Invaders
Remote executes on server 2
10. Shell Cleanup (Second Phase):

Sqf

Apply
_timeOut = time + 300;
waitUntil {sleep 1; time > _timeOut};
deleteVehicle _shell;
5-minute timeout for shell visibility
Deletes shell object after 5 minutes
Where it leads:
Functions Called:

SCRT_fnc_effect_createGasEffect - Creates visual gas cloud effect
SCRT_fnc_common_chemicalDamage - Applies damage over time to units in area
A3A_fnc_addAggression - Increases aggression levels
Global Variables Modified:

teamPlayer side check (for aggression penalty)
Dependencies:

Requires teamPlayer side definition
Requires gas effect and chemical damage functions to exist
Used By:

fn_support_planePayloadedRun.sqf
 - When supportType is "CHEMICAL"
fn_support_flareBarrage.sqf
File: A3A/addons/scrt/Support/fn_support_flareBarrage.sqf Line Count: 31 lines

Function: [] spawn SCRT_fnc_support_flareBarrage;
What it does:
Spawns a barrage of illumination flares over a support marker position.

How it does that:
1. Position Retrieval:

Sqf

Apply
private _positionOrigin = getMarkerPos [supportMarkerOrigin, true];
private _flareCount = round random [2,3,5];
Gets origin marker position
Calculates 2-5 flares to spawn
2. Petros Notification:

Sqf

Apply
if(!isNil "petros" && {alive petros}) then {
    petros sideChat (localize "STR_chats_barrage_flare");
};
If Petros exists and alive: Uses side chat to announce
3. Delay:

Sqf

Apply
private _timeOut = time + 30;
waitUntil {sleep 1; time > _timeOut };
30-second delay before flares launch
4. Player Notification:

Sqf

Apply
{
    [petros, "support", localize "STR_comms_mp_flares"] remoteExec ["A3A_fnc_commsMP", _x];
} forEach ([500, _positionOrigin] call SCRT_fnc_common_getNearPlayers);
Notifies players within 500m of origin position
Sends "Flares incoming" message
5. Flare Selection:

Sqf

Apply
private _flareModel = selectRandom (A3A_faction_reb get "flares");
Selects random flare type from rebel faction
6. Flare Creation Loop:

Sqf

Apply
for "_i" from 1 to _flareCount do {
    private _randomizedPosition = [(_positionOrigin select 0) + random 50, (_positionOrigin select 1) + random 50, (_positionOrigin select 2) + random [150,175,200]];

    private _flare = _flareModel createVehicle _randomizedPosition;
    _flare setVelocity [-10 + random 20, -10 + random 20, -5];

    sleep 2;
    
    playSound3D [(selectRandom flareSounds), _flare, false,  getPosASL _flare, 1.5, 1, 450, 0];

    sleep 5;
};
Creates flares with:
Random X/Y offset (±50m)
Random altitude (150-200m)
Random velocity vector (-10 to +10 m/s horizontal, -5 m/s vertical)
Plays random flare sound every flare
Sleeps 2s between flares, 5s after sound
7. Unlock Support Marker:

Sqf

Apply
isSupportMarkerPlacingLocked = false;
publicVariable "isSupportMarkerPlacingLocked";
Unlocks support marker placement
Syncs to all clients
Where it leads:
Functions Called:

SCRT_fnc_common_getNearPlayers - Gets players near origin position
A3A_fnc_commsMP - Sends notification to players
Global Variables Modified:

isSupportMarkerPlacingLocked (public)
Dependencies:

Requires supportMarkerOrigin marker
Requires A3A_faction_reb with flares key
Requires flareSounds array
Requires petros unit reference
Used By:

Support menu when flare barrage is selected
fn_support_lootHeli.sqf
File: A3A/addons/scrt/Support/fn_support_lootHeli.sqf Line Count: 164 lines

Function: [] spawn SCRT_fnc_support_lootHeli;
What it does:
Spawns a helicopter that delivers a loot crate to a specified location, then departs. Includes crate parachute deployment.

How it does that:
1. Position Setup:

Sqf

Apply
private _positionOrigin = getMarkerPos supportMarkerOrigin;
private _positionDestination = getMarkerPos supportMarkerDestination;

private _angle = [_positionOrigin, _positionDestination] call BIS_fnc_dirTo;
private _angleOrigin = _angle - 180;

private _intermediatePosition = [_positionDestination, 200, _angle] call BIS_fnc_relPos;
private _originPosition = [_positionOrigin, 1500, _angleOrigin] call BIS_fnc_relPos;
private _finPosition = [_positionDestination, 1500, _angle] call BIS_fnc_relPos;
Calculates angle from origin to destination
Creates intermediate position 200m before destination
Origin: 1500m behind origin marker
Exit: 1500m past destination marker
2. Helicopter Spawn:

Sqf

Apply
private _heliType = selectRandom (A3A_faction_reb getOrDefault ["vehiclesCivHeli", []]);
private _heliData = [_originPosition, _angle, _heliType, teamPlayer] call A3A_fnc_spawnVehicle;
private _heli = _heliData select 0;
private _heliCrew = _heliData select 1;
private _groupHeli = _heliData select 2;

if (_heliType isEqualTo []) exitWith {
    ["Support", "A helicopter is not available due to template issues. Apologies! You have been refunded."] call A3A_fnc_customHint;
    [0,2000] remoteExec ["A3A_fnc_resourcesFIA",2];
};
Selects random civilian helicopter
Spawns helicopter with crew
Refunds 2000 if no helicopter available
3. Helicopter Configuration:

Sqf

Apply
_heli setPosATL [getPosATL _heli select 0, getPosATL _heli select 1, 300];
_heli disableAI "TARGET";
_heli disableAI "AUTOTARGET";
_heli flyInHeight 120;
Sets altitude to 300m
Disables targeting AI
Sets fly height to 120m
4. Loot Crate Creation:

Sqf

Apply
sleep 2;
private _lootCratePosition = (getPos _heli) vectorAdd [0, 0, -4];
private _lootCrate = createVehicle [A3A_faction_occ get "ammobox", _lootCratePosition, [], 0, "NONE"];
_lootCrate allowDamage false;
clearBackpackCargoGlobal _lootCrate;
clearItemCargoGlobal _lootCrate;
clearWeaponCargoGlobal _lootCrate;
clearMagazineCargoGlobal _lootCrate;
[_lootCrate] call A3A_Logistics_fnc_addLoadAction;
_heli setSlingLoad _lootCrate;
Creates empty ammobox 4m below helicopter
Clears all cargo
Adds load action for logistics
Attaches crate to helicopter via sling load
5. Area Marker:

Sqf

Apply
private _areaMarker = createMarkerLocal ["LootHeliAreaGlobalMarker", _positionDestination];
_areaMarker setMarkerShape "ELLIPSE";
_areaMarker setMarkerSize [250,250];
_areaMarker setMarkerType "hd_warning";
_areaMarker setMarkerColor "colorCivilian";
_areaMarker setMarkerBrush "Grid";
Creates local warning marker showing drop area
250m radius ellipse
6. Initial Flight:

Sqf

Apply
driver _heli sideChat (localize "STR_chats_loot_run");
private _wp1 = group _heli addWaypoint [_positionOrigin, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "NORMAL";
_wp1 setWaypointBehaviour "CARELESS";

_wp2 = group _heli addWaypoint [_intermediatePosition, 1];
_wp2 setWaypointSpeed "LIMITED";
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true", "(vehicle this) flyInHeight 40;"];
Pilot announces mission
First waypoint to origin position
Second to intermediate position, reducing altitude to 40m
7. Approach Detection:

Sqf

Apply
waitUntil {_heli distance2D _positionDestination < 250 || {!alive _heli || !(canMove _heli) || {!([(driver _heli)] call A3A_fnc_canFight)}}};
Waits until helicopter within 250m of destination or destroyed
8. Destination Waypoint:

Sqf

Apply
if (!alive _heli || !(canMove _heli) || {!([(driver _heli)] call A3A_fnc_canFight)}) exitWith {
    deleteMarker _areaMarker;
    deleteMarker "LootHeliAreaGlobalMarker";
    Info_2("Helicopter is unable to loot area. Positions: %1, %2", str _positionOrigin, str _positionDestination);

    if (isSupportMarkerPlacingLocked) then {
        isSupportMarkerPlacingLocked = false;
        publicVariable "isSupportMarkerPlacingLocked";
    };
};

_wp3 = group _heli addWaypoint [_positionDestination, 2];
_wp3 setWaypointSpeed "NORMAL";
_wp3 setWaypointType "MOVE";
_wp3 setWaypointStatements ["true", "isSupportMarkerPlacingLocked=false;publicVariable 'isSupportMarkerPlacingLocked'"];
If helicopter destroyed: Cleanup and unlock marker
Otherwise: Create waypoint to destination, unlock marker on arrival
9. Gathering Time:

Sqf

Apply
private _timeOut = time + 45;
waitUntil {time > _timeOut};

if (!alive _heli || !(canMove _heli) || {!([(driver _heli)] call A3A_fnc_canFight)}) exitWith {
    deleteMarker _areaMarker;
    deleteMarker "LootHeliAreaGlobalMarker";
    Info_2("Helicopter is unable to loot area. Positions: %1, %2", str _positionOrigin, str _positionDestination);

    if (isSupportMarkerPlacingLocked) then {
        isSupportMarkerPlacingLocked = false;
        publicVariable "isSupportMarkerPlacingLocked";
    };
};
Waits 45 seconds for helicopter to loiter
Checks again for helicopter viability
10. Loot Gathering:

Sqf

Apply
[_lootCrate, 300, _positionDestination] remoteExec ["SCRT_fnc_loot_gatherLoot", 2];
_heli setSlingLoad objNull;
_isGatherSuccessful = true;
Triggers loot gathering on server 2
Detaches crate from helicopter
Sets success flag
11. Crate Release and Parachute:

Sqf

Apply
_timeOut = time + 3.5;
waitUntil {time > _timeOut};

deleteMarker _areaMarker;
deleteMarker "LootHeliAreaGlobalMarker";

{
    [petros, "support", format [localize "STR_comms_mp_loot_heli", A3A_faction_reb get "name"]] remoteExec ["A3A_fnc_commsMP", _x];
} forEach ([250, _positionDestination] call SCRT_fnc_common_getNearPlayers);

private _para = createVehicle ["B_parachute_02_F", [0,0,0], [], 0, "NONE"];
_para setDir getDir _lootCrate;
_para setPos getPos _lootCrate;
_lootCrate attachTo [_para, [0, 0, -1.2]];
Waits 3.5s for helicopter to position
Deletes markers
Notifies players within 250m
Creates parachute and attaches crate to it
12. Landing Detection:

Sqf

Apply
[_lootCrate, _para] spawn {
    params ["_obj","_para"];

    private _smokeShellVariants = ["SmokeShellRed", "SmokeShellGreen", "SmokeShellYellow", "SmokeShellPurple", "SmokeShellBlue", "SmokeShellOrange"];
        
    waitUntil {
        sleep 0.01;
        ((position _obj) select 2) < 2 
        || 
        isNull _para 
        || 
        (count (lineIntersectsWith [getPosASL _obj, (getPosASL _obj) vectorAdd [0, 0, -0.5], _obj, _para])) > 0
    };
        
    _para disableCollisionWith _obj;
    _obj setVectorUp [0,0,1];
    _obj setVelocity [0,0,0];
    detach _obj;
    
    //mark landing with smoke
    _smokeShell = (selectRandom _smokeShellVariants) createVehicle (position _obj);

    if(sunOrMoon < 1) then {
        private _chemlightVariants = ["Chemlight_green", "Chemlight_red", "Chemlight_yellow", "Chemlight_blue"];
        _chemLight = (selectRandom _chemlightVariants) createVehicle (position _obj);
    };
        
    if (!isNull _para) then {deleteVehicle _para};
};
Spawns landing detection thread
Waits for:
Altitude < 2m
Parachute destroyed
Ground contact detected
On landing: Detaches crate, places upright, creates smoke marker
Adds chemlight if dark
Deletes parachute
13. Exit Waypoint:

Sqf

Apply
_wp4 = group _heli addWaypoint [_finPosition, 4];
_wp4 setWaypointType "MOVE";
_wp4 setWaypointSpeed "FULL";
_wp4 setWaypointStatements ["true", "(vehicle this) flyInHeight 100;"];
Final waypoint to exit area at high speed
Sets altitude to 100m
14. Cleanup Wait:

Sqf

Apply
private _timeOut = time + 600;
waitUntil { sleep 2; (currentWaypoint group _heli == 5) or (time > _timeOut) or !(canMove _heli)};
10-minute timeout
Waits for waypoint 5 (final exit) or helicopter destruction
15. Final Cleanup:

Sqf

Apply
if (isSupportMarkerPlacingLocked) then {
    isSupportMarkerPlacingLocked = false;
    publicVariable "isSupportMarkerPlacingLocked";
};

if (!_isGatherSuccessful) then {
    deleteVehicle _lootCrate;
};

if !(canMove _heli) then { sleep cleantime };
deleteVehicle _heli;
{deleteVehicle _x} forEach _heliCrew;
deleteGroup _groupHeli;
Ensures marker is unlocked
Deletes crate if gathering failed
Deletes helicopter and crew (after cleanup time if destroyed)
Where it leads:
Functions Called:

A3A_fnc_spawnVehicle - Spawns helicopter
A3A_fnc_customHint - Shows refund message
A3A_fnc_resourcesFIA - Refunds resources
A3A_Logistics_fnc_addLoadAction - Adds load action to crate
A3A_fnc_canFight - Checks if pilot can fight
SCRT_fnc_loot_gatherLoot - Gathers loot into crate
SCRT_fnc_common_getNearPlayers - Gets nearby players
Global Variables Modified:

isSupportMarkerPlacingLocked (public)
teamPlayer side reference
Dependencies:

Requires supportMarkerOrigin and supportMarkerDestination markers
Requires A3A_faction_reb with vehiclesCivHeli key
Requires A3A_faction_occ with ammobox key
Requires cleantime global
Requires A3A_faction_reb with name key
Used By:

Support menu when loot heli support is selected
fn_support_planeParadropRun.sqf
File: A3A/addons/scrt/Support/fn_support_planeParadropRun.sqf Line Count: 56 lines

Function: [] spawn SCRT_fnc_support_planeParadropRun;
What it does:
Spawns a transport plane that paradrops cargo or units at a designated location.

How it does that:
1. Position Setup:

Sqf

Apply
private _positionOrigin = getMarkerPos supportMarkerOrigin;
private _positionDestination = getMarkerPos supportMarkerDestination;

private _angle = [_positionOrigin, _positionDestination] call BIS_fnc_dirTo;
private _angleOrigin = _angle - 180;

private _originPosition = [_positionOrigin, 2000, _angleOrigin] call BIS_fnc_relPos;
private _finPosition = [_positionDestination, 2000, _angle] call BIS_fnc_relPos;
Calculates flight angles
Origin: 2000m behind origin marker
Exit: 2000m past destination marker
2. Plane Spawn:

Sqf

Apply
private _planeType = (A3A_faction_reb get "vehiclesPlane") # 0;
private _planeData = [_originPosition, _angle, _planeType, teamPlayer] call A3A_fnc_spawnVehicle;
paradropPlane = _planeData select 0;
private _planeCrew = _planeData select 1;
private _groupPlane = _planeData select 2;

clearBackpackCargoGlobal paradropPlane;
Selects first plane from rebel faction
Spawns plane with crew
Clears backpack cargo (prevents accidental parachute swap)
3. Plane Configuration:

Sqf

Apply
paradropPlane setPosATL [getPosATL paradropPlane select 0, getPosATL paradropPlane select 1, 950];
paradropPlane disableAI "TARGET";
paradropPlane disableAI "AUTOTARGET";
paradropPlane flyInHeight 800;
private _minAltASL = ATLToASL [_positionDestination select 0, _positionDestination select 1, 0];
paradropPlane flyInHeightASL [(_minAltASL select 2) +100, (_minAltASL select 2) +100, (_minAltASL select 2) +100];
Sets altitude to 950m AGL
Disables targeting AI
Sets fly height to 800m
Calculates ASL altitude for destination (ground + 100m)
4. Flight Waypoints:

Sqf

Apply
driver paradropPlane sideChat (localize "STR_chats_plane_paradrop_run");
private _wp1 = group paradropPlane addWaypoint [_positionOrigin, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "FULL";
_wp1 setWaypointBehaviour "CARELESS";

_wp2 = group paradropPlane addWaypoint [_positionDestination, 1];
_wp2 setWaypointSpeed "LIMITED";
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true", "private _crew = fullCrew [(vehicle this), 'cargo', false]; {private _unit = _x select 0; moveOut _unit;} forEach _crew;isSupportMarkerPlacingLocked=false;publicVariable 'isSupportMarkerPlacingLocked';"];
Pilot announces mission
First waypoint to origin
Second to destination with limited speed
Waypoint statements: Move all cargo units out, unlock marker
5. Exit Waypoint:

Sqf

Apply
_wp3 = group paradropPlane addWaypoint [_finPosition, 2];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "FULL";
Final waypoint to exit area at full speed
6. Public Variable:

Sqf

Apply
publicVariable "paradropPlane";
Makes plane globally accessible
7. Cleanup Wait:

Sqf

Apply
private _timeOut = time + 600;
waitUntil { sleep 2; currentWaypoint group paradropPlane == 4 or {time > _timeOut or {!canMove paradropPlane}} };
10-minute timeout
Waits for waypoint 4 or plane destruction
8. Final Cleanup:

Sqf

Apply
if (isSupportMarkerPlacingLocked) then {
    isSupportMarkerPlacingLocked = false;
    publicVariable "isSupportMarkerPlacingLocked";
};

if !(canMove paradropPlane) then { sleep cleantime };
deleteVehicle paradropPlane;
{deleteVehicle _x} forEach _planeCrew;
deleteGroup _groupPlane;

paradropPlane = nil;
publicVariable "paradropPlane";
Ensures marker unlocked
Deletes plane and crew (after cleanup time if destroyed)
Clears global variable
Where it leads:
Functions Called:

A3A_fnc_spawnVehicle - Spawns plane
A3A_fnc_canFight - Checks if plane can move
Global Variables Modified:

paradropPlane (public object reference)
isSupportMarkerPlacingLocked (public)
Dependencies:

Requires supportMarkerOrigin and supportMarkerDestination markers
Requires A3A_faction_reb with vehiclesPlane key
Requires cleantime global
Used By:

Support menu when paradrop support is selected
fn_support_planePayloadedRun.sqf
File: A3A/addons/scrt/Support/fn_support_planePayloadedRun.sqf Line Count: 103 lines

Function: [] spawn SCRT_fnc_support_planePayloadedRun;
What it does:
Spawns a plane/helicopter with payload (supply, vehicle airdrop, or airstrike) and performs the delivery/attack.

How it does that:
1. Position Setup:

Sqf

Apply
private _positionOrigin = getMarkerPos supportMarkerOrigin;
private _positionDestination = getMarkerPos supportMarkerDestination;
private _angle = [_positionOrigin, _positionDestination] call BIS_fnc_dirTo;
private _angleOrigin = _angle - 180;

private _originPosition = [_positionOrigin, 2500, _angleOrigin] call BIS_fnc_relPos;
private _finPosition = [_positionDestination, 2500, _angle] call BIS_fnc_relPos;
Similar to paradrop but 2500m offset
2. Aircraft Spawn:

Sqf

Apply
private _planeData = [_originPosition, _angle, selectRandom (A3A_faction_reb get "vehiclesPlane"), teamPlayer] call A3A_fnc_spawnVehicle;
private _plane = _planeData select 0;
private _planeCrew = _planeData select 1;
private _groupPlane = _planeData select 2;

private _isHelicopter = _plane isKindOf "helicopter";
Spawns random aircraft from rebel plane list
Checks if it's a helicopter for different altitude handling
3. Aircraft Configuration:

Sqf

Apply
_plane setPosATL [getPosATL _plane select 0, getPosATL _plane select 1, if (_isHelicopter) then {100} else {1000}];
_plane disableAI "TARGET";
_plane disableAI "AUTOTARGET";
_plane flyInHeight 120;
private _minAltASL = ATLToASL [_positionDestination select 0, _positionDestination select 1, 0];
_plane flyInHeightASL [(_minAltASL select 2) +120, (_minAltASL select 2) +120, (_minAltASL select 2) +120];
Helicopter: 100m altitude, Plane: 1000m
Fly height: 120m
ASL altitude: destination ground + 120m
4. First Waypoint:

Sqf

Apply
driver _plane sideChat (localize "STR_chats_plane_run");
private _wp1 = group _plane addWaypoint [_positionOrigin, 0];
_wp1 setWaypointType "MOVE";
if (!_isHelicopter) then { _wp1 setWaypointSpeed "LIMITED" };
_wp1 setWaypointBehaviour "CARELESS";
Pilot announces mission
Speed limited for planes (not helicopters)
Behavior: CARELESS
5. Support Type Handling:

Sqf

Apply
private _text = nil;

switch (supportType) do {
    case ("SUPPLY"): {
        _wp1 setWaypointStatements ["true", format ["if !(local this) exitWith {}; [this, '%1', '%2'] spawn SCRT_fnc_common_supplyDrop", "IG_supplyCrate_F", supportType]];
        _text = localize "STR_comms_mp_supply";
    };
    case ("VEH_AIRDROP"): {
        _wp1 setWaypointStatements ["true", format ["if !(local this) exitWith {}; [this, '%1', '%2'] spawn SCRT_fnc_common_supplyDrop", selectRandom (A3A_faction_reb get "vehiclesBasic"), supportType]];
        _text = localize "STR_comms_mp_light_veh";
    };
    case ("NAPALM");
    case ("HE");
    case ("CLUSTER");
    case ("CHEMICAL"): {
        _text = format [localize "STR_comms_mp_airstrike", supportType];

        private _bombCount = switch (supportType) do {
            case "CHEMICAL": { 1 };
            case "NAPALM";
            case "CLUSTER": { 2 };
            default { 4 };
        };

        private _distance = _positionOrigin distance2D _positionDestination;
        private _bombParams = [_plane, supportType, _bombCount, _distance];

        (driver _plane) setVariable ["bombParams", _bombParams, true];

        [_positionOrigin, driver _plane] spawn {
            params ["_pos", "_pilot"];
            waitUntil {sleep 0.1; ((_pos distance2D _pilot) < 250) || {isNull (objectParent _pilot)}};
            if(isNull (objectParent _pilot)) exitWith {};
            (_pilot getVariable 'bombParams') remoteExec ["A3A_fnc_airbomb", 2];
        };
    };
};
SUPPLY: Drops supply crate (IG_supplyCrate_F)
VEH_AIRDROP: Drops random basic vehicle
Airstrikes: Chemical (1 bomb), Napalm/Cluster (2 bombs), HE (4 bombs)
Sets waypoint statement to call supplyDrop or triggers bomb function when within 250m
6. Destination Waypoint:

Sqf

Apply
_wp2 = group _plane addWaypoint [_positionDestination, 1];
if (!_isHelicopter) then { _wp2 setWaypointSpeed "LIMITED" };
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true", "isSupportMarkerPlacingLocked=false;publicVariable 'isSupportMarkerPlacingLocked';"];
Destination waypoint, speed limited for planes
Unlocks marker on arrival
7. Exit Waypoint:

Sqf

Apply
_wp3 = group _plane addWaypoint [_finPosition, 2];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "FULL";
Exit to final position at full speed
8. Delay and Notification:

Sqf

Apply
sleep 50;

if (canMove _plane && {alive _plane}) then {
    {
        [petros, "support", _text] remoteExec ["A3A_fnc_commsMP", _x];
    } forEach ([1000, _positionDestination] call SCRT_fnc_common_getNearPlayers);
};
Waits 50 seconds
Notifies players within 1000m of destination
Message depends on support type
9. Cleanup Wait:

Sqf

Apply
private _timeOut = time + 600;
waitUntil { sleep 2; (currentWaypoint group _plane == 4) or (time > _timeOut) or !(canMove _plane) };

if (isSupportMarkerPlacingLocked) then {
    isSupportMarkerPlacingLocked = false;
    publicVariable "isSupportMarkerPlacingLocked";
};

if !(canMove _plane) then { sleep cleantime };
deleteVehicle _plane;
{deleteVehicle _x} forEach _planeCrew;
deleteGroup _groupPlane;
10-minute timeout or waypoint 4 or destruction
Ensures marker unlocked
Deletes plane and crew
Where it leads:
Functions Called:

A3A_fnc_spawnVehicle - Spawns aircraft
SCRT_fnc_common_supplyDrop - Drops supply/vehicle
A3A_fnc_airbomb - Triggers airstrike (via remoteExec)
SCRT_fnc_common_getNearPlayers - Gets nearby players
A3A_fnc_commsMP - Sends notification
Global Variables Modified:

isSupportMarkerPlacingLocked (public)
supportType (read)
Dependencies:

Requires supportMarkerOrigin, supportMarkerDestination markers
Requires supportType variable
Requires A3A_faction_reb with vehiclesPlane, vehiclesBasic keys
Requires cleantime global
Requires teamPlayer side reference
Used By:

Support menu for supply, vehicle airdrop, and airstrike supports
fn_support_planeReconRun.sqf
File: A3A/addons/scrt/Support/fn_support_planeReconRun.sqf Line Count: 65 lines

What it does:
Spawns a recon plane that flies over an area, performing reconnaissance and revealing enemy positions.

How it does that:
1. Position Setup:

Sqf

Apply
private _positionOrigin = getMarkerPos supportMarkerOrigin;
private _positionDestination = getMarkerPos supportMarkerDestination;
private _angle = [_positionOrigin, _positionDestination] call BIS_fnc_dirTo;
private _angleOrigin = _angle - 180;

private _originPosition = [_positionOrigin, 2500, _angleOrigin] call BIS_fnc_relPos;
private _finPosition = [_positionDestination, 2500, _angle] call BIS_fnc_relPos;
Standard position calculations
2. Plane Spawn:

Sqf

Apply
private _planeData = [_originPosition, _angle, selectRandom (A3A_faction_reb get "vehiclesPlane"), teamPlayer] call A3A_fnc_spawnVehicle;
private _plane = _planeData select 0;
private _planeCrew = _planeData select 1;
private _groupPlane = _planeData select 2;
Spawns random rebel plane
3. Initial Recon (Optional):

Sqf

Apply
if (hideEnemyMarkers) then {
    private _distance = hideEnemyMarkersReconPlaneDistance;
    [_positionDestination, _distance, _plane] spawn A3U_fnc_revealZonesDistance;
};
If enemy markers hidden: Reveals zones within specified distance using A3U function
4. Plane Configuration:

Sqf

Apply
_plane setPosATL [getPosATL _plane select 0, getPosATL _plane select 1, 1000];
_plane disableAI "TARGET";
_plane disableAI "AUTOTARGET";
_plane flyInHeight 250;
private _minAltASL = ATLToASL [_positionX select 0, _positionX select 1, 0];
_plane flyInHeightASL [(_minAltASL select 2) +100, (_minAltASL select 2) +100, (_minAltASL select 2) +100];
Note: _positionX is undefined - likely bug, should be _positionDestination
Altitude: 1000m AGL, 250m fly height
ASL altitude: destination ground + 100m
5. Flight Waypoints:

Sqf

Apply
driver _plane sideChat (localize "STR_chats_plane_run");
private _wp1 = group _plane addWaypoint [_positionOrigin, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "LIMITED";
_wp1 setWaypointBehaviour "CARELESS";

private _relativePositions = [];

{
    private _relativePosition = [_positionDestination, 300, _x] call BIS_fnc_relPos;
    _relativePositions pushBack _relativePosition;
} forEach [0, 180];

{
    private _index = _forEachIndex + 1;
    private _wp = group _plane addWaypoint [_x, _index];
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointType "MOVE";

    if(_index == 1) then {
        _wp setWaypointStatements ["true", format ["if !(local this) exitWith {}; [%1, %2, %3] spawn SCRT_fnc_common_recon;isSupportMarkerPlacingLocked=false;publicVariable 'isSupportMarkerPlacingLocked';", _positionDestination, 350, 180]];
    };
} forEach _relativePositions;

_wp3 = group _plane addWaypoint [_finPosition, 3];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "FULL";
First waypoint to origin
Creates two positions 300m from destination (0° and 180°)
Creates two waypoints at these positions
First waypoint triggers recon function with destination, 350m radius, 180° scan angle
Unlocks marker after recon
Final waypoint to exit
6. Cleanup Wait:

Sqf

Apply
private _timeOut = time + 600;
waitUntil { sleep 2; (currentWaypoint group _plane == 5) or (time > _timeOut) or !(canMove _plane) };

if (isSupportMarkerPlacingLocked) then {
    isSupportMarkerPlacingLocked = false;
    publicVariable "isSupportMarkerPlacingLocked";
};

if !(canMove _plane) then { sleep cleantime };
deleteVehicle _plane;
{deleteVehicle _x} forEach _planeCrew;
deleteGroup _groupPlane;
10-minute timeout or waypoint 5 or destruction
Deletes plane and crew
Where it leads:
Functions Called:

A3A_fnc_spawnVehicle - Spawns plane
A3U_fnc_revealZonesDistance - Reveals enemy zones (optional)
SCRT_fnc_common_recon - Performs reconnaissance
A3A_fnc_canFight - Checks if plane can move
Global Variables Modified:

isSupportMarkerPlacingLocked (public)
Dependencies:

Requires supportMarkerOrigin, supportMarkerDestination markers
Requires A3A_faction_reb with vehiclesPlane key
Requires hideEnemyMarkers boolean
Requires hideEnemyMarkersReconPlaneDistance number
Requires cleantime global
Note: Bug - uses undefined _positionX variable
Used By:

Support menu when recon support is selected
fn_support_smokeBarrage.sqf
File: A3A/addons/scrt/Support/fn_support_smokeBarrage.sqf Line Count: 30 lines

Function: [] spawn SCRT_fnc_support_smokeBarrage;
What it does:
Spawns a barrage of smoke shells over a support marker position.

How it does that:
1. Position and Count:

Sqf

Apply
private _positionOrigin = getMarkerPos [supportMarkerOrigin, true];
private _smokeCount = round random [3,4,5];
private _soundPool = ["A3\Sounds_f\weapons\smokeshell\smoke_1.wss", "A3\Sounds_f\weapons\smokeshell\smoke_2.wss", "A3\Sounds_f\weapons\smokeshell\smoke_3.wss"];
3-5 smoke shells
Array of smoke shell sounds
2. Petros Notification:

Sqf

Apply
if(!isNil "petros" && {alive petros}) then {
    petros sideChat (localize "STR_chats_barrage_smoke");
};
Petros announces via side chat
3. Delay:

Sqf

Apply
private _timeOut = time + 30;
waitUntil {sleep 1; time > _timeOut };
30-second delay
4. Player Notification:

Sqf

Apply
{
    [petros, "support", localize "STR_comms_mp_smokes"] remoteExec ["A3A_fnc_commsMP", _x];
} forEach ([500, _positionOrigin] call SCRT_fnc_common_getNearPlayers);
Notifies players within 500m
5. Smoke Shell Creation:

Sqf

Apply
for "_i" from 1 to _smokeCount do {
    private _randomizedPosition = [(_positionOrigin select 0) + random 15, (_positionOrigin select 1) + random 15, (_positionOrigin select 2) + random [90,110,125]];

    private _smokeRound = "Smoke_82mm_AMOS_White" createVehicle _randomizedPosition;
    _smokeRound setVelocity [-10 + random 20, -10 + random 20, -5];

    sleep 2;
    
    playSound3D [(selectRandom _soundPool), _smokeRound, false,  getPosASL _smokeRound, 1.5, 1, 450, 0];

    sleep 5;
};
Creates 82mm smoke shells
Random X/Y offset (±15m)
Random altitude (90-125m)
Random velocity vector (-10 to +10 m/s horizontal, -5 m/s vertical)
Plays smoke sound
2s between shells, 5s after sound
6. Unlock Marker:

Sqf

Apply
isSupportMarkerPlacingLocked = false;
publicVariable "isSupportMarkerPlacingLocked";
Unlocks support marker
Where it leads:
Functions Called:

SCRT_fnc_common_getNearPlayers - Gets nearby players
A3A_fnc_commsMP - Sends notification
Global Variables Modified:

isSupportMarkerPlacingLocked (public)
Dependencies:

Requires supportMarkerOrigin marker
Requires petros unit reference
Used By:

Support menu when smoke barrage is selected
fn_trader_addVehicleMarketAction.sqf
File: A3A/addons/scrt/Trader/fn_trader_addVehicleMarketAction.sqf Line Count: 13 lines

Function: [traderX] call SCRT_fnc_trader_addVehicleMarketAction;
What it does:
Adds a "Vehicle Market" action to the trader unit.

How it does that:
1. Action Setup:

Sqf

Apply
params ["_traderX"];

_traderX addAction [
    format ["<img image='\a3\ui_f\data\igui\cfg\actions\getindriver_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", localize "STR_antistasi_actions_common_access_vehicle_marker_text"],
    {createDialog "A3A_BlackMarketDialog"},
    nil,
    5,
    false,
    true,
    "",
    "(isPlayer _this) and (vehicle _this == _this) and (_this == _this getVariable ['owner',objNull])",
    3
];
Takes trader unit as parameter
Adds action with:
Driver icon image
Localized text "Access Vehicle Market"
Opens "A3A_BlackMarketDialog"
Priority 5
Only for players who:
Are on foot
Own the trader (owner variable)
3m distance limit
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires traderX unit reference
Requires owner variable on trader
Requires "A3A_BlackMarketDialog" dialog to exist
Used By:

Called when trader is created to add vehicle market access
fn_trader_createTrader.sqf
File: A3A/addons/scrt/Trader/fn_trader_createTrader.sqf Line Count: 95 lines

Function: [position] call SCRT_fnc_trader_createTrader;
What it does:
Creates a trader at specified position with all props (tent, table, chairs, boxes, etc.) and the trader unit itself.

How it does that:
1. Parameter:

Sqf

Apply
params ["_position"];

if (disableTrader) exitWith {};
Takes position parameter
Exits if trader disabled globally
2. Marker Creation (If Quest Completed):

Sqf

Apply
traderObjects = [];

if (isTraderQuestCompleted) then {
    traderMarker = createMarker ["TraderMarker", _position];
    traderMarker setMarkerType "hd_objective";
    traderMarker setMarkerSize [1, 1];
    traderMarker setMarkerText (localize "STR_marker_arms_dealer");
    traderMarker setMarkerColor "ColorUNKNOWN";
    traderMarker setMarkerAlpha 1;
    sidesX setVariable [traderMarker,teamPlayer,true];
    publicVariable "traderMarker";
};
Creates marker if quest completed
Marker shows as objective icon
Sets as rebel-controlled
Publicizes marker
3. Clear Terrain:

Sqf

Apply
{  
    [_x, true] remoteExec ["hideObject", 0, true];
} forEach nearestTerrainObjects [_position, [], 50, false, true];
Hides all terrain objects within 50m
4. VN Check:

Sqf

Apply
private _isVn = ((A3A_Reb_template splitString "_") select 0) isEqualTo "VN";
Checks if using Vietnam template for different prop selection
5. Tent Creation:

Sqf

Apply
private _traderTent = if (_isVn) then { 
    createVehicle ["Land_MedicalTent_01_wdl_generic_inner_F", _position]; 
} else {
    createVehicle ["Land_MedicalTent_01_wdl_generic_open_F", _position];
};

_traderTent allowDamage false;
_buildingPositions = _traderTent buildingPos -1;
Creates appropriate tent based on template
Makes tent indestructible
Gets interior positions
6. Chair Creation:

Sqf

Apply
private _chair = ["Land_DeskChair_01_black_F", getPosWorld _traderTent] call BIS_fnc_createSimpleObject;
_chair setPos (_buildingPositions select 0);
_chair setPos [getPos _chair select 0, (getPos _chair select 1) + 1, (getPos _chair select 2) + 0.4];
Creates simple chair object
Positions at first interior position
Offsets by 1m Y, 0.4m Z
7. Desk Creation:

Sqf

Apply
private _table = ["Land_PortableDesk_01_black_F", getPosWorld _traderTent] call BIS_fnc_createSimpleObject;
_table setPos (_buildingPositions select 0);
_table setPos [getPos _table select 0, getPos _table select 1, (getPos _table select 2) + 0.7];
Creates desk at same interior position
Offsets by 0.7m Z
8. Laptop and Satellite (Non-VN):

Sqf

Apply
if (!_isVn) then {
    private _laptopArray = [[_table, "TOP"],"Land_Laptop_02_unfolded_F",1,[0,0,0],180] call BIS_fnc_spawnObjects;
    private _laptop = _laptopArray select 0;
    traderObjects pushBack _laptop;

    private _satellite = ["SatelliteAntenna_01_Black_F", getPosWorld _traderTent] call BIS_fnc_createSimpleObject;
    _satellite setPos (_buildingPositions select 0);
    _satellite setPos [(getPos _laptop select 0) + 5.5, getPos _laptop select 1, (getPos _laptop select 2) + 1.75];
    _satellite setDir 45; 
    traderObjects pushBack _satellite;
};
Spawns unfolded laptop on desk
Creates satellite antenna 5.5m away, elevated
Sets direction 45°
9. Ammo Boxes:

Sqf

Apply
private _tableBoxArray = [[_table, "TOP"],"Land_Ammobox_rounds_F",1,[-0.4,(random 0.2),(random 20)-10],(random 180)] call BIS_fnc_spawnObjects;
private _tableBox = _tableBoxArray select 0;

private _ammoBox1 = ["Land_PaperBox_open_full_F", getPosWorld _traderTent] call BIS_fnc_createSimpleObject;
_ammoBox1 setPos [(getPos _ammoBox1 select 0) + 2.6, (getPos _ammoBox1 select 1) + 3, (getPos _ammoBox1 select 2) - 1.4];

private _ammoBox2 = ["Land_PaperBox_open_empty_F", getPosWorld _traderTent] call BIS_fnc_createSimpleObject;
_ammoBox2 setPos [(getPos _ammoBox2 select 0) - 2.6, (getPos _ammoBox2 select 1) + 3, (getPos _ammoBox2 select 2) - 1.4];
Small box on desk with random offsets
Two larger boxes outside tent
Positioned symmetrically
10. Container:

Sqf

Apply
private _container = ["Land_Cargo20_military_green_F", getPosWorld _traderTent] call BIS_fnc_createSimpleObject;
_container setPos (_buildingPositions select 0);
_container setPos [(getPos _container select 0) - 8, (getPos _container select 1) + 3, (getPos _container select 2) + 2.4];
_container setDir 90;
20ft cargo container 8m left, 3m forward, 2.4m up
Rotated 90°
11. Tracking and Publicizing:

Sqf

Apply
traderObjects append [_traderTent, _chair, _table, _tableBox, _ammoBox1, _ammoBox2, _container];
publicVariable "traderObjects";
Adds all objects to tracking array
Publicizes to all clients
12. Lighting:

Sqf

Apply
[_traderTent, [0, 0, 1]] remoteExec ["SCRT_fnc_common_attachLightSource", 0, _traderTent];
Attaches light source to tent on all clients
13. Trader Unit Creation:

Sqf

Apply
private _traderGroup = createGroup civilian;
_traderX = _traderGroup createUnit ["C_Nikos", _position, [], 0, "CAN_COLLIDE"];
_traderX allowDamage false;
_traderX setUnitPos "UP";
_traderX setSpeaker "NoVoice";
{_traderX disableAI _x} forEach ["CHECKVISIBLE", "MOVE", "COVER", "SUPPRESSION", "FSM"];
_traderX setDir -30;
Creates civilian group with "C_Nikos" unit
Makes indestructible
Sets standing position
Disables voice and several AI behaviors
Faces -30°
14. Return Trader:

Sqf

Apply
_traderX
Returns trader unit reference
Where it leads:
Functions Called:

BIS_fnc_createSimpleObject - Creates simple objects
BIS_fnc_spawnObjects - Spawns objects (laptop)
SCRT_fnc_common_attachLightSource - Attaches light to tent
Global Variables Modified:

traderObjects array
traderMarker (if quest completed)
traderX (set by caller)
Dependencies:

Requires disableTrader global
Requires isTraderQuestCompleted global
Requires A3A_Reb_template (VN detection)
Requires sidesX hash map
Requires teamPlayer side
Used By:

Called to spawn trader when quest completed
fn_trader_prepareTraderQuest.sqf
File: A3A/addons/scrt/Trader/fn_trader_prepareTraderQuest.sqf Line Count: 35 lines

Function: [] call SCRT_fnc_trader_prepareTraderQuest;
What it does:
Prepares and assigns the trader quest by selecting a suitable location and scheduling the encounter.

How it does that:
1. State Check:

Sqf

Apply
if (disableTrader) exitWith {};

if (isTraderQuestAssigned || isTraderQuestCompleted) exitWith {
    Warning("Something tries to call for Arms Dealer quest again, aborting...");
};
Exits if trader disabled
Exits if quest already assigned or completed
2. Quest Assignment Flag:

Sqf

Apply
isTraderQuestAssigned = true;
publicVariable "isTraderQuestAssigned";
Sets flag to prevent duplicate quests
Publicizes to all clients
3. Location Selection:

Sqf

Apply
private _posbase = getMarkerPos respawnTeamPlayer;
private _potentials = [];

private _sites = (controlsX select {!(isOnRoad getMarkerPos _x) && {sidesX getVariable [_x,sideUnknown] != teamPlayer}});

if (count _sites > 0) then {
    for "_i" from 0 to ((count _sites) - 1) do {
        private _siteX = _sites select _i;
        private _pos = getMarkerPos _siteX;

       if (_pos distance _posbase < distanceMission * 2) then {
           _potentials pushBack _siteX;
       };
    };
};

if (count _potentials < 1) then {
    //hope there are no maps without controls
    private _defaultSite = controlsX select 0;
    _potentials pushBack _defaultSite;
};
Gets control points that are:
NOT on roads
NOT controlled by rebels
Within 2x mission distance of HQ
If none found: Uses first control point as fallback
4. Encounter Scheduling:

Sqf

Apply
[[(selectRandom _potentials)],"A3A_fnc_ENC_Trader"] remoteExec ["A3A_fnc_scheduler",2];
Selects random suitable location
Schedules ENC_Trader encounter on server 2
Where it leads:
Functions Called:

A3A_fnc_scheduler - Schedules trader encounter
Global Variables Modified:

isTraderQuestAssigned (public boolean)
Dependencies:

Requires disableTrader global
Requires isTraderQuestAssigned, isTraderQuestCompleted globals
Requires controlsX marker array
Requires sidesX hash map
Requires respawnTeamPlayer marker
Requires distanceMission global
Used By:

Called to start trader quest chain
fn_trader_removeUnlockedItemsFromStock.sqf
File: A3A/addons/scrt/Trader/fn_trader_removeUnlockedItemsFromStock.sqf Line Count: 48 lines

Function: [] call SCRT_fnc_trader_removeUnlockedItemsFromStock;
What it does:
Removes items that are already unlocked in the arsenal from the trader's stock to prevent selling duplicate items.

How it does that:
1. Trader Reference:

Sqf

Apply
private _trader = if (!isNil "traderX") then {
    traderX
} else { 
    nil 
};

if (isNil "_trader") exitWith {
    Info("Trader hasn't spawned yet.");
};
Gets reference to trader unit
Exits if trader not spawned
2. Stock Retrieval:

Sqf

Apply
private _stocks = _trader getVariable ["HALs_store_trader_stocks", []];

if (_stocks isEqualTo []) exitWith {
    Info("Trader has empty stock.");
};
Gets trader stock from HALs store variable
Exits if stock is empty
3. Arsenal Reference:

Sqf

Apply
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"
Includes Arsenal UI constants for tab IDs
4. Get Unlocked Items from Arsenal:

Sqf

Apply
private _weapons = ((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_HANDGUN) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON)) select {_x select 1 isEqualTo -1};
private _explosives = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT) select {_x select 1 isEqualTo -1};
private _magazines = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW) select {_x select 1 isEqualTo -1};
private _backpacks = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_BACKPACK) select {_x select 1 isEqualTo -1};
private _items = ((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_GOGGLES) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_MAP) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_GPS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_RADIO) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_COMPASS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_WATCH) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMACC) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMMUZZLE) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMBIPOD) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_BINOCULARS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_UNIFORM)) select {_x select 1 isEqualTo -1};
private _optics = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC) select {_x select 1 isEqualTo -1};
private _nv = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_NVGS) select {_x select 1 isEqualTo -1};
private _helmets = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_HEADGEAR) select {_x select 1 isEqualTo -1};
private _vests = (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_VEST) select {_x select 1 isEqualTo -1};
Gets unlocked items from jna_dataList (JNA - Jey's Arsenal)
Selects items where select 1 equals -1 (unlocked)
Covers all item categories
5. Stock Removal:

Sqf

Apply
{
    private _item = toLowerANSI (_x select 0);
    private _stockIndex = _stocks find _item;

    if (_stockIndex != -1) then {
        _stocks deleteAt _stockIndex; //item
        _stocks deleteAt (_stockIndex + 1); //quantity
    };
} forEach _weapons + _explosives + _magazines + _backpacks + _items + _optics + _nv + _helmets + _vests;
Converts item class to lowercase for comparison
Finds item in stock array
Deletes item and its quantity (stocks are [item, quantity, item, quantity...])
6. Save and Update:

Sqf

Apply
_trader setVariable ["HALs_store_trader_stocks", _stocks, true];
private _players = allPlayers select {(_x getVariable ["HALs_store_trader_current", objNull]) isEqualTo _trader} apply {owner _x};
[] remoteExecCall ["HALs_store_fnc_update", _players, false];
Saves updated stock to trader
Gets players currently viewing this trader
Updates their trader interface
Where it leads:
Functions Called:

HALs_store_fnc_update - Updates trader interface for viewing players
Global Variables Modified:

Trader's HALs_store_trader_stocks variable (public)
Dependencies:

Requires traderX unit reference
Requires jna_dataList global (Jey's Arsenal)
Requires HALs_store_trader_stocks on trader
Requires HALs_store_trader_current on players
Used By:

Called when trader stock is updated to remove unlocked items
fn_trader_rerollTrader.sqf
File: A3A/addons/scrt/Trader/fn_trader_rerollTrader.sqf Line Count: 72 lines

Function: [] spawn SCRT_fnc_trader_rerollTrader;
What it does:
Removes current trader, rolls back all quest variables, and assigns a new find trader task. Costs 1000 resources.

How it does that:
1. Cost and State Check:

Sqf

Apply
if (disableTrader) exitWith {};

#define COST 1000

if (!(isTraderQuestCompleted || (!(isNil 'isTraderQuestAssigned') && {isTraderQuestAssigned}))) exitWith {
    Error("Trader task is not completed yet, aborting.");
};

Info("Arms dealer reroll initiated.");

private _resourcesFIA = server getVariable "resourcesFIA";
if (_resourcesFIA < COST) exitWith {
    [
        localize "STR_notifiers_fail_type",
        localize "STR_notifiers_trader_position_reroll_trader_header",  
        parseText (localize "STR_notifiers_trader_position_reroll_trader_no_money"), 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
Cost: 1000 resources
Only allows reroll if quest completed or assigned
Checks for sufficient resources
Shows failure message if insufficient
2. Close Dialogs:

Sqf

Apply
closeDialog 0;
closeDialog 0;
Closes any open dialogs
3. Deduct Resources:

Sqf

Apply
[0, -COST] remoteExec ["A3A_fnc_resourcesFIA",2];
Deducts 1000 resources on server 2
4. Reset State Variables:

Sqf

Apply
Debug("Cancelling state variables.");

isTraderQuestAssigned = false;
isTraderQuestCompleted = false;
publicVariable "isTraderQuestAssigned";
publicVariable "isTraderQuestCompleted";
Resets quest flags to false
Publicizes to all clients
5. Delete Trader Marker:

Sqf

Apply
Debug("Deleting trader markers.");

deleteMarker "TraderMarker";
traderMarker = nil;
publicVariable "traderMarker";
Deletes trader marker
Clears global variable
Publicizes change
6. Delete Trader Unit:

Sqf

Apply
Debug("Deleting trader.");

deleteVehicle traderX;
publicVariable "traderX";
Deletes trader unit
Clears global variable
Publicizes change
7. Delete Trader Objects:

Sqf

Apply
Debug("Deleting trader objects.");

{
    deleteVehicle _x;
} forEach traderObjects;

sleep 1.5;

traderObjects = nil;
publicVariable "traderObjects";
Deletes all trader objects (props)
1.5s delay for sync
Clears and publicizes array
8. Assign New Quest:

Sqf

Apply
Debug("Assigning new trader task.");

[] remoteExec ["SCRT_fnc_trader_prepareTraderQuest", 2];
Schedules new trader quest on server 2
Where it leads:
Functions Called:

A3A_fnc_resourcesFIA - Deducts resources
SCRT_fnc_ui_showMessage - Shows failure message
SCRT_fnc_trader_prepareTraderQuest - Starts new quest
Global Variables Modified:

isTraderQuestAssigned (public)
isTraderQuestCompleted (public)
traderMarker (public)
traderX (public)
traderObjects (public)
Dependencies:

Requires disableTrader global
Requires isTraderQuestAssigned, isTraderQuestCompleted globals
Requires traderX, traderObjects, traderMarker globals
Requires resourcesFIA server variable
Used By:

Manual admin command or player action to reroll trader location
fn_trader_setStockType.sqf
File: A3A/addons/scrt/Trader/fn_trader_setStockType.sqf Line Count: 150 lines

Function: [traderX] call SCRT_fnc_trader_setStockType;
What it does:
Sets trader stock based on loaded mods and DLC, with special handling for various modsets.

How it does that:
1. Parameter:

Sqf

Apply
params ["_traderX"];
Takes trader unit as parameter
2. Modset Detection Setup:

Sqf

Apply
private _modsets = [];

// DLC to modset mapping
private _modsetToDLC = createHashMapFromArray [
    ["ws", "ws"],
    ["marksmen", "mark"],
    ["lawsofwar", "orange"],
    ["tanks", "tank"],
    ["apex", "expansion"],
    ["contact", "enoch"],
    ["jets", "jets"],
    ["artofwar", "aow"],
    ["kart", "kart"],
    ["globmob", "gm"],
    ["csla", "csla"],
    ["rf", "rf"],
    ["vn", "vn"],
    ["ww2cdlc", "spe"],
    ["ef", "ef"]
];

// Special modsets with class checks
private _specialModsets = [
    ["nickelsteel", "vn", "vnx_b_air_ac119_02_01"],
    ["spex", "spe", "SPEX_M2_60"]
];

// DLC/CDLC that block vanilla
private _modsetDLCs = createHashMapFromArray [
    ["ws", true],
    ["globmob", true],
    ["csla", true],
    ["rf", true],
    ["vn", true],
    ["ww2cdlc", true],
    ["ef", true]
];
Maps modset prefixes to DLC names
Special modsets with class check requirements
Which DLC/CDLC are considered blocking (non-vanilla)
3. Old Config Format (Deprecated):

Sqf

Apply
private _oldCfg = (configFile >> "A3U" >> "traderMods") call BIS_fnc_getCfgSubClasses;
if (_oldCfg isNotEqualTo []) then {
    {
        private _addons = getArray (configFile >> "A3U" >> "traderMods" >> _x >> "addons");
        private _prefix = getText (configFile >> "A3U" >> "traderMods" >> _x >> "prefix");

        // Check if this modset is associated with a DLC
        private _dlc = _modsetToDLC get _prefix;
        if (!isNil "_dlc" && {!(_dlc in A3A_enabledDLC)}) then {
            Verbose_2("Skipped DLC-based modset %1 (DLC %2 not enabled)", _prefix, _dlc);
            continue;
        };

        if ([_addons] call A3U_fnc_hasAddon) then {
            _modsets pushBackUnique _prefix;
            Error_1("Added %1 to _modsets list (old version). It is now deprecated and should be updated ASAP.", _prefix);
        };
    } forEach _oldCfg;
};
Reads old deprecated config format
Checks if DLC is enabled
Adds modset if addons present
4. New Config Format:

Sqf

Apply
private _baseCfg = (configFile >> "A3U" >> "traderAddons");
private _cfg = _baseCfg call BIS_fnc_getCfgSubClasses;
private _ignoreClasses = ["traderWeapons", "traderVehicles"];

{
    if (_x in _ignoreClasses) then {continue};
    private _addons = getArray (_baseCfg >> _x >> "addons");
    if (_addons isEqualTo []) then {continue};
    private _weapons = getText (_baseCfg >> _x >> "weapons");
    if (_weapons isEqualTo "") then {continue};
    private _prefix = getText (_baseCfg >> "traderWeapons" >> _weapons >> "prefix");
    if (isNil "_prefix" || {_prefix isEqualTo ""}) then {continue};

    // Check if this modset is associated with a DLC
    private _dlc = _modsetToDLC get _prefix;
    if (!isNil "_dlc" && {!(_dlc in A3A_enabledDLC)}) then {
        Verbose_2("Skipped DLC-based modset %1 (DLC %2 not enabled)", _prefix, _dlc);
        continue;
    };

    if ([_addons] call A3U_fnc_hasAddon) then {
        _modsets pushBackUnique _prefix;
        Verbose_1("Added %1 to _modsets list.", _prefix);
    };
} forEach _cfg;
Reads new config format with weapon references
Checks DLC enablement
Adds modset if addons present
5. Regular DLC Modsets:

Sqf

Apply
{
    private _modset = _x;
    private _dlc = _y;
    
    if (_dlc in A3A_enabledDLC) then {
        _modsets pushBackUnique _modset;
    };
} forEach _modsetToDLC;
Processes all DLC-based modsets
Adds if DLC is enabled
6. Special Modsets:

Sqf

Apply
{
    _x params ["_modset", "_dlc", "_checkClass"];
    
    if (_dlc in A3A_enabledDLC && {isClass (configFile >> "cfgVehicles" >> _checkClass)}) then {
        _modsets pushBackUnique _modset;
    };
} forEach _specialModsets;
Checks DLC enablement and class existence
Adds special modset if conditions met
7. Blocking Modsets Check:

Sqf

Apply
private _hasBlockingModsets = false;
{
    private _currentModset = _x;
    private _isSpecialModset = false;
    {
        if (_x#0 == _currentModset) exitWith { _isSpecialModset = true; };
    } forEach _specialModsets;
    
    if (_modsetDLCs getOrDefault [_currentModset, false] || 
        (isNil {_modsetToDLC get _currentModset} && !_isSpecialModset)) then {
        _hasBlockingModsets = true;
    };
} forEach _modsets;
Checks if any modset is a blocking CDLC or custom mod
Blocks vanilla if blocking modsets exist
8. Vanilla Modset Handling:

Sqf

Apply
if (!_hasBlockingModsets || {vanillaArmsDealer isEqualTo true}) then {
    _modsets pushBackUnique "vanilla";
};

if ("coldWar" in A3A_factionEquipFlags) then { // 3cbf cold war //why do it this way?
    _modsets pushBack "3cbfcw";
};
Adds vanilla only if no blocking modsets OR vanillaArmsDealer is true
Adds 3CBF Cold War if flag present
9. Trader Stock Assignment:

Sqf

Apply
[_traderX, _modsets] call HALs_store_fnc_addTrader;
Calls HALs function to add trader with determined modsets
10. Remove Unlocked Items:

Sqf

Apply
[] call SCRT_fnc_trader_removeUnlockedItemsFromStock;
Removes already unlocked items from stock
Where it leads:
Functions Called:

A3U_fnc_hasAddon - Checks if addons exist
HALs_store_fnc_addTrader - Adds trader with modsets
SCRT_fnc_trader_removeUnlockedItemsFromStock - Removes unlocked items
Global Variables Modified:

None (modifies stock via HALs function)
Dependencies:

Requires A3A_enabledDLC array
Requires A3A_factionEquipFlags array
Requires vanillaArmsDealer global
Requires config entries for trader addons
Requires traderX unit reference
Used By:

Called when trader stock needs to be set (typically when trader is created or rerolled)
fn_trader_setTraderDiscount.sqf
File: A3A/addons/scrt/Trader/fn_trader_setTraderDiscount.sqf Line Count: 21 lines

Function: [discount] call SCRT_fnc_trader_setTraderDiscount;
What it does:
Sets a discount percentage on the trader's sales.

How it does that:
1. Parameter and Trader Reference:

Sqf

Apply
params ["_discount"];

private _trader = if (!isNil "traderX") then {
    traderX
} else { 
    nil 
};

if (isNil "_trader") exitWith {
    Info("Trader is not spawned yet, aborting.");
};
Takes discount percentage (0-100)
Gets trader reference
Exits if trader not spawned
2. Discount Application:

Sqf

Apply
Info_1("Setting %1 discount.", _discount);

_trader setVariable ["HALs_store_trader_sale", _discount, true];

traderDiscount = _discount;
publicVariable "traderDiscount";
Sets sale percentage on trader
Sets global discount variable
Publicizes to all clients
Where it leads:
Functions Called: None

Global Variables Modified:

traderDiscount (public)
Trader's HALs_store_trader_sale variable (public)
Dependencies:

Requires traderX unit reference
Requires HALs_store_trader_sale variable in HALs store system
Used By:

Manual admin command or script to set trader discount

fn_ui_assignRivalsAttackLocationEventHandler.sqf
File: A3A/addons/scrt/UI/fn_ui_assignRivalsAttackLocationEventHandler.sqf Line Count: 59 lines

Function: [mode] call SCRT_fnc_ui_assignRivalsAttackLocationEventHandler;
What it does:
Adds or removes a map click handler for assigning Rivals attack locations. When active, clicking on the map selects a known Rivals location to attack.

How it does that:
1. Mode Check:

Sqf

Apply
params ["_mode"];

if(_mode == "ADD") then {
    // Add handler
} else {
    // Remove handler
}
Accepts "ADD" or "REMOVE" mode
2. Add Handler:

Sqf

Apply
[
    "assignRivalsAttackLocation",
    "onMapSingleClick",
    {
        playSound "readoutClick";

        private _knownLocations = ["KNOWN"] call SCRT_fnc_rivals_getLocations;

        private _location = [_knownLocations, _pos] call BIS_fnc_nearestPosition;
        if (getMarkerPos _location distance _pos > 50) exitWith {
            [
                localize "STR_notifiers_fail_type",
                localize "STR_antistasi_rivals_destroy_hideoutcell_header",
                parseText (localize "STR_antistasi_rivals_destroy_hideoutcell_click_miss_text"),  
                30
            ] spawn SCRT_fnc_ui_showMessage;
        };

        if ((spawner getVariable [_location, 0]) != 2) exitWith {
            [
                localize "STR_notifiers_fail_type",
                localize "STR_antistasi_rivals_destroy_hideoutcell_header",
                parseText (format [localize "STR_antistasi_rivals_destroy_hideoutcell_no_spawner_text", A3A_faction_riv get "name", str distanceSPWN]),  
                30
            ] spawn SCRT_fnc_ui_showMessage;
        };

        if (_location in citiesX) then {
            [[_location],"A3A_fnc_RIV_ATT_Cell"] remoteExec ["A3A_fnc_scheduler",2];
        } else {
            if !(areInvadersDefeated) then {
                private _roll = round random 100;
                if (_roll >= 55) then {
                    [[_location],"A3A_fnc_RIV_ATT_Transfer"] remoteExec ["A3A_fnc_scheduler",2];	
                } else {
                    [[_location],"A3A_fnc_RIV_ATT_Hideout"] remoteExec ["A3A_fnc_scheduler",2];
                };
            } else {
                Debug("No rival missions are possible, invaders are defeated and location isn't a city.");
                [_location, "NOINVADER"] remoteExecCall ["SCRT_fnc_rivals_destroyLocation",2];
            };
        };

        ["REMOVE"] call SCRT_fnc_ui_assignRivalsAttackLocationEventHandler;
        closeDialog 0;
        closeDialog 0;
        [] call SCRT_fnc_ui_clearRivals;
    },
    []
] call BIS_fnc_addStackedEventHandler;
Registers map click handler named "assignRivalsAttackLocation"
Click Logic:
Gets known Rivals locations
Finds nearest location to click position
Validation 1: Must be within 50m of click
Validation 2: Location must be despawned (spawner == 2)
If City: Schedules cell attack
If Hideout:
If invaders not defeated: 55% chance transfer, 45% hideout attack
If invaders defeated: Directly destroys location
Cleans up handler, closes dialogs, clears Rivals markers
3. Remove Handler:

Sqf

Apply
["assignRivalsAttackLocation", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
Removes the map click handler
Where it leads:
Functions Called:

SCRT_fnc_rivals_getLocations - Gets known locations
SCRT_fnc_ui_showMessage - Shows error messages
A3A_fnc_scheduler - Schedules attack tasks
SCRT_fnc_rivals_destroyLocation - Destroys location
SCRT_fnc_ui_assignRivalsAttackLocationEventHandler - Self (removal)
SCRT_fnc_ui_clearRivals - Clears visual markers
Global Variables Modified:

None (handler is local to client)
Dependencies:

Requires citiesX array
Requires areInvadersDefeated boolean
Requires distanceSPWN global
Requires A3A_faction_riv with name key
Requires spawner hash map
Used By:

fn_ui_setAssignRivalsAttackLocationMode - To activate handler
fn_ui_changeTab.sqf
File: A3A/addons/scrt/UI/fn_ui_changeTab.sqf Line Count: 73 lines

Function: [displayId, direction] spawn SCRT_fnc_ui_changeTab;
What it does:
Handles tab navigation in commander/rebel menus with animated sliding transitions.

How it does that:
1. Parameter and Setup:

Sqf

Apply
#define SUPPORT_TAB 1140

disableSerialization;
params ["_displayId","_direction"];

private _display = findDisplay _displayId;

if (str (_display) == "no display") exitWith {
    Error("Commander Menu Display is not Detected");
};
Defines support tab ID constant
Gets display reference
Error handling if display not found
2. Calculate Target Tab:

Sqf

Apply
_currentMenu = menuSliderArray select menuSliderCurrent;	
_selectedMenu = [];
_menuSliderTarget = 0;
switch (_direction) do {
    case "LEFT": {
        _menuSliderTarget = if (menuSliderCurrent isEqualTo 0) then {((count menuSliderArray) - 1)} else {menuSliderCurrent - 1};
        _selectedMenu = menuSliderArray select _menuSliderTarget;
    };
    case "RIGHT": {
        _menuSliderTarget = if (menuSliderCurrent isEqualTo ((count menuSliderArray) - 1)) then {0} else {menuSliderCurrent + 1};
        _selectedMenu = menuSliderArray select _menuSliderTarget;
    };
};	
Gets current menu controls
Calculates target index based on direction
Wraps around (left from first goes to last, right from last goes to first)
Gets selected menu controls
3. Slide Current Menu Out:

Sqf

Apply
{
    if (_forEachIndex != 0) then {
        _thisCtrl = (_display displayCtrl _x);				
        _thisCtrl ctrlSetPosition [-0.4 * safezoneW + safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
        _thisCtrl ctrlCommit 0.1;
    };
} forEach _currentMenu;
sleep 0.1;
Moves all controls in current menu to left (-40% of screen width)
Excludes first control (likely the title)
Commits animation over 0.1 seconds
Sleeps 0.1s for animation completion
4. Slide New Menu In:

Sqf

Apply
_leftPos = 0 * pixelGridNoUIScale * pixelW;
{
    if (_forEachIndex == 0) then {
        _thisCtrl = (_display displayCtrl 1101);
        _thisCtrl ctrlSetText _x;
    } else {
        _thisCtrl = (_display displayCtrl _x);				
        _thisCtrl ctrlSetPosition [safezoneX, (ctrlPosition _thisCtrl) select 1, (ctrlPosition _thisCtrl) select 2, (ctrlPosition _thisCtrl) select 3];
        _thisCtrl ctrlCommit 0.2;
    };
} forEach _selectedMenu;	
First element: Sets text of control 1101 (title)
Other elements: Moves controls from left to center (safezoneX)
Commits animation over 0.2 seconds
5. Update Slider State:

Sqf

Apply
menuSliderCurrent = _menuSliderTarget;
Updates global slider index
6. Tab-Specific Event Handlers:

Sqf

Apply
if(_displayId == 60000) then {
    private _tabId = _selectedMenu select 1;
    switch (_tabId) do {
        case (SUPPORT_TAB): {
            ["ADD"] call SCRT_fnc_ui_manageSupportTabEventHandler;
        };
        default {
            ["REMOVE"] call SCRT_fnc_ui_manageSupportTabEventHandler;
            ["REMOVE"] call SCRT_fnc_ui_hqTabEventHandler;
            ["REMOVE"] call SCRT_fnc_ui_establishOutpostEventHandler;
            ["REMOVE"] call SCRT_fnc_ui_disbandGarrisonEventHandler;
            ["REMOVE"] call SCRT_fnc_ui_recruitGarrisonEventHandler;
            ["REMOVE"] call SCRT_fnc_ui_minefieldEventHandler;
            ["REMOVE"] call SCRT_fnc_ui_assignRivalsAttackLocationEventHandler;
            [] spawn SCRT_fnc_ui_clearSupport;
            [] call SCRT_fnc_ui_clearOutpost;
            [] call SCRT_fnc_ui_clearRivals;
        };
    };
};
Only runs for commander menu (display 60000)
If entering support tab: Adds support map handler
For any other tab: Removes all map handlers and clears visual markers
Where it leads:
Functions Called:

SCRT_fnc_ui_manageSupportTabEventHandler - Adds/removes support map handler
SCRT_fnc_ui_hqTabEventHandler - Adds/removes HQ map handler
SCRT_fnc_ui_establishOutpostEventHandler - Adds/removes outpost map handler
SCRT_fnc_ui_disbandGarrisonEventHandler - Adds/removes disband map handler
SCRT_fnc_ui_recruitGarrisonEventHandler - Adds/removes recruit map handler
SCRT_fnc_ui_minefieldEventHandler - Adds/removes minefield map handler
SCRT_fnc_ui_assignRivalsAttackLocationEventHandler - Adds/removes Rivals attack handler
SCRT_fnc_ui_clearSupport - Clears support markers
SCRT_fnc_ui_clearOutpost - Clears outpost markers
SCRT_fnc_ui_clearRivals - Clears Rivals markers
Global Variables Modified:

menuSliderCurrent (global)
Various handler flags (indirectly)
Dependencies:

Requires menuSliderArray global with structure: [[title, idc], [title, idc], ...]
Requires menuSliderCurrent global
Used By:

UI button actions for left/right navigation
fn_ui_populateCommanderMenu (initial setup)
fn_ui_clearOutpost.sqf
File: A3A/addons/scrt/UI/fn_ui_clearOutpost.sqf Line Count: 9 lines

Function: [] call SCRT_fnc_ui_clearOutpost;
What it does:
Clears outpost-related map markers.

How it does that:
Sqf

Apply
if (!isNil "outpostOrigin") then {
    deleteMarkerLocal outpostOrigin;
    outpostOrigin = nil;
};

if (!isNil "outpostDirection") then {
    deleteMarkerLocal outpostDirection;
    outpostDirection = nil;
};
Checks for origin marker and deletes it
Checks for direction marker and deletes it
Clears global variables
Where it leads:
Functions Called: None

Global Variables Modified:

outpostOrigin (cleared)
outpostDirection (cleared)
Dependencies:

Requires outpostOrigin and outpostDirection global markers
Used By:

fn_ui_changeTab (when switching away from outpost tab)
fn_ui_dispose (when closing menu)
fn_ui_clearRivals.sqf
File: A3A/addons/scrt/UI/fn_ui_clearRivals.sqf Line Count: 3 lines

Function: [] call SCRT_fnc_ui_clearRivals;
What it does:
Clears Rivals activity visualization markers.

How it does that:
Sqf

Apply
if (!isNil "visibleRivalsMarkers") then {
    {deleteMarkerLocal _x} forEach visibleRivalsMarkers;
};
Deletes all markers in visibleRivalsMarkers array
Does not clear the array itself
Where it leads:
Functions Called: None

Global Variables Modified:

Local markers deleted
visibleRivalsMarkers array remains (but markers are gone)
Dependencies:

Requires visibleRivalsMarkers array
Used By:

fn_ui_changeTab (when switching away from Rivals tab)
fn_ui_dispose (when closing menu)
fn_ui_assignRivalsAttackLocationEventHandler (after selecting location)
fn_ui_clearSupport.sqf
File: A3A/addons/scrt/UI/fn_ui_clearSupport.sqf Line Count: 25 lines

Function: [] spawn SCRT_fnc_ui_clearSupport;
What it does:
Clears all support-related map markers and waits for cooldown to complete.

How it does that:
1. Cooldown Wait:

Sqf

Apply
if(!isNil "supportCooldown" && {supportCooldown}) then {
    waitUntil {supportCooldown isEqualTo false};
};
If support is on cooldown, waits until cooldown expires
2. Marker Cleanup:

Sqf

Apply
if (!isNil "supportMarkerOrigin") then {
    deleteMarkerLocal supportMarkerOrigin;
    supportMarkerOrigin = nil;
};

if (!isNil "supportMarkerDestination") then {
    deleteMarkerLocal supportMarkerDestination;
    supportMarkerDestination = nil;
};
Deletes origin and destination markers
Clears global variables
3. Forced Cleanup:

Sqf

Apply
deleteMarkerLocal "BRStart";
deleteMarkerLocal "BRFin";
Deletes hardcoded marker names (fallback)
4. Forbidden Zones Cleanup:

Sqf

Apply
if (!isNil "forbiddenParadropZones") then {
    {deleteMarkerLocal _x} forEach forbiddenParadropZones;
};
Deletes all forbidden paradrop zone markers
5. Loot Heli Area Cleanup:

Sqf

Apply
if (getMarkerColor "LootHeliAreaMarker" != "") then {
    deleteMarkerLocal "LootHeliAreaMarker";
};
Deletes loot heli area marker if it exists
Where it leads:
Functions Called: None

Global Variables Modified:

supportMarkerOrigin (cleared)
supportMarkerDestination (cleared)
forbiddenParadropZones (markers deleted)
supportCooldown (read only)
Dependencies:

Requires all support marker variables
Requires supportCooldown global
Used By:

fn_ui_changeTab (when switching away from support tab)
fn_ui_dispose (when closing menu)
fn_ui_launchSupport (after support completes)
fn_ui_createConstructionMenu.sqf
File: A3A/addons/scrt/UI/fn_ui_createConstructionMenu.sqf Line Count: 22 lines

Function: [] call SCRT_fnc_ui_createConstructionMenu;
What it does:
Creates construction menu dialog and populates building type combobox.

How it does that:
1. Dialog Creation:

Sqf

Apply
disableSerialization;

createDialog "constructionMenu";

private _display = findDisplay 80000;

if (str (_display) == "no display") exitWith {};
Creates construction menu dialog
Gets display with ID 80000
Exits if dialog creation failed
2. Populate Combobox:

Sqf

Apply
private _comboBox = _display displayCtrl 505;

_comboBox lbAdd localize "STR_antistasi_dialogs_trenches";
_comboBox lbSetData [0, "TRENCH"];
_comboBox lbAdd localize "STR_antistasi_dialogs_veh_obstacles";
_comboBox lbSetData [1, "OBSTACLE"];
_comboBox lbAdd localize "STR_antistasi_dialogs_light_bunkers";
_comboBox lbSetData [2, "LIGHT_BUNKER"];
_comboBox lbAdd localize "STR_antistasi_dialogs_heavy_bunkers";
_comboBox lbSetData [3, "HEAVY_BUNKER"];
_comboBox lbAdd localize "STR_antistasi_dialogs_misc";
_comboBox lbSetData [4, "MISC"];

_comboBox lbSetCurSel 0;
Adds 5 construction types with localized text
Sets data values: "TRENCH", "OBSTACLE", "LIGHT_BUNKER", "HEAVY_BUNKER", "MISC"
Selects first item by default
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires construction menu dialog to exist (config)
Requires control ID 505 to exist in dialog
Used By:

Called from UI to open construction menu
fn_ui_createRebelLoadoutMenu.sqf
File: A3A/addons/scrt/UI/fn_ui_createRebelLoadoutMenu.sqf Line Count: 59 lines

Function: [] call SCRT_fnc_ui_createRebelLoadoutMenu;
What it does:
Creates rebel loadout menu and marks already unlocked loadouts.

How it does that:
1. Dialog Creation:

Sqf

Apply
createDialog 'rebelLoadoutMenu';

private _display = findDisplay 120000;

if (str (_display) != "no display") then {
    // Check and mark unlocked loadouts
};
Creates rebel loadout menu
Gets display with ID 120000
2. Loadout Checking Function:

Sqf

Apply
private _addLoadoutMark = {
    params ["_control"];
    private _oldText = ctrlText _control;
    _control ctrlSetText format ["%1 %2", _oldText, "[x]"];
};
Takes control as parameter
Appends "[x]" to existing control text
3. Loadout Verification:

Sqf

Apply
if ((A3A_faction_reb get "unitRifle") in rebelLoadouts) then {
    [(_display displayCtrl 120001)] call _addLoadoutMark;
};

if ((A3A_faction_reb get "unitMG") in rebelLoadouts) then {
    [(_display displayCtrl 120002)] call _addLoadoutMark;
};

// ... repeated for all 12 loadout types
Checks if each unit type is in rebelLoadouts array
If found: Marks corresponding control (120001-120012) with "[x]"
Covers: Rifleman, MG, Medic, Engineer, GL, Sniper, LAT, Crew, SL, Exp, AT, AA
Where it leads:
Functions Called:

_addLoadoutMark - Marks unlocked loadouts
Global Variables Modified: None

Dependencies:

Requires A3A_faction_reb with unit type keys
Requires rebelLoadouts array
Requires control IDs 120001-120012 in dialog
Used By:

Called from UI to open rebel loadout menu
fn_ui_disbandGarrisonEventHandler.sqf
File: A3A/addons/scrt/UI/fn_ui_disbandGarrisonEventHandler.sqf Line Count: 45 lines

Function: [mode] call SCRT_fnc_ui_disbandGarrisonEventHandler;
What it does:
Adds or removes map click handler for disbanding garrisons.

How it does that:
1. Mode Check:

Sqf

Apply
params ["_mode"];

if(_mode == "ADD") then {
    [
        "disbandGarrison",
        "onMapSingleClick",
        {
            playSound "readoutClick";

            private _site = [markersX, _pos] call BIS_fnc_nearestPosition;
            if (getMarkerPos _site distance _pos > 50) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_notifiers_disband_header",  
                    parseText (localize "STR_notifiers_disband_click"), 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            private _side = sidesX getVariable [_site, sideUnknown];
            if (_side != teamPlayer) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_notifiers_disband_header",  
                    parseText format [localize "STR_notifiers_disband_not_belong", A3A_faction_reb get "name"], 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            if ([_positionX] call A3A_fnc_enemyNearCheck) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_notifiers_disband_header",  
                    parseText (localize "STR_notifiers_disband_enemies_nearby"), 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            ["rem", _site] spawn A3A_fnc_garrisonDialog;
        },
        []
    ] call BIS_fnc_addStackedEventHandler;
} else {
    ["disbandGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
};
Add Handler:
Clicks must be within 50m of marker
Site must be owned by rebels
No enemies nearby
Opens garrison dialog with "rem" mode
Remove Handler: Removes the map click handler
Where it leads:
Functions Called:

SCRT_fnc_ui_showMessage - Shows error messages
A3A_fnc_enemyNearCheck - Checks for nearby enemies
A3A_fnc_garrisonDialog - Opens garrison management dialog
Global Variables Modified:

None (handler is local)
Dependencies:

Requires markersX array
Requires sidesX hash map
Requires teamPlayer side
Requires A3A_faction_reb with name key
Requires garrisonDialog to exist
Used By:

fn_ui_setDisbandMode - Activates handler
fn_ui_dispose.sqf
File: A3A/addons/scrt/UI/fn_ui_dispose.sqf Line Count: 23 lines

Function: [] call SCRT_fnc_ui_dispose;
What it does:
Cleans up all UI-related state when commander/rebel menu is closed.

How it does that:
1. Remove All Event Handlers:

Sqf

Apply
["REMOVE"] call SCRT_fnc_ui_manageSupportTabEventHandler;
["REMOVE"] call SCRT_fnc_ui_hqTabEventHandler;
["REMOVE"] call SCRT_fnc_ui_establishOutpostEventHandler;
["REMOVE"] call SCRT_fnc_ui_disbandGarrisonEventHandler;
["REMOVE"] call SCRT_fnc_ui_recruitGarrisonEventHandler;
["REMOVE"] call SCRT_fnc_ui_minefieldEventHandler;
["REMOVE"] call SCRT_fnc_ui_assignRivalsAttackLocationEventHandler;
Removes all map click handlers
2. Clear Global Variables:

Sqf

Apply
menuSliderArray = nil;
menuSliderCurrent = nil;
outpostType = nil;
supportType = nil;
minefieldType = nil;
outpostCost = nil;
minefieldCost = nil;
Clears all UI state variables
3. Clear Markers:

Sqf

Apply
if (!isNil "forbiddenParadropZones") then {
    {deleteMarkerLocal _x} forEach forbiddenParadropZones;
};

[] spawn SCRT_fnc_ui_clearSupport;
[] call SCRT_fnc_ui_clearOutpost;
[] call SCRT_fnc_ui_clearRivals;
Deletes paradrop zones
Clears support, outpost, and Rivals markers
Where it leads:
Functions Called:

All *_EventHandler functions with "REMOVE"
SCRT_fnc_ui_clearSupport
SCRT_fnc_ui_clearOutpost
SCRT_fnc_ui_clearRivals
Global Variables Modified:

All UI state variables cleared
Dependencies:

Requires all UI handler functions
Requires all marker clearing functions
Used By:

Called when commander/rebel menu is closed
fn_ui_editParamsMenu.sqf
File: A3A/addons/scrt/UI/fn_ui_editParamsMenu.sqf Line Count: 44 lines

Function: [mode] call SCRT_fnc_ui_editParamsMenu;
What it does:
Handles parameter editing menu in multiplayer, allowing admins to change mission parameters.

How it does that:
1. Mode Switch:

Sqf

Apply
params ["_mode"];

switch (_mode) do {
    case ("onLoad"): {
        closeDialog 0;
        createDialog "A3A_SetupDialog_InGame";

        private _display = findDisplay A3A_IDD_SETUPDIALOG;
        private _params = ([missionNamespace, "A3A_saveData", createHashMap] call BIS_fnc_getServerVariable) getOrDefault["params", []];
        _display setVariable ["savedParams", _params];

        ["switchTab", ["params"]] call A3A_fnc_setupDialog;
        private _paramsTable = _display displayCtrl A3A_IDC_SETUP_PARAMSTABLE;
        waitUntil {sleep 0.1; !isNil {_paramsTable getVariable "allTextCtrls"}};
        ["fillParams"] call A3A_fnc_setupParamsTab;
    };
    case ("ResetParams"): {
        ["fillParams"] call A3A_fnc_setupParamsTab;
    };
    case ("SaveParams"): {
        private _params = ['getParams'] call A3A_fnc_setupParamsTab;
        private _savedParamsHM = createHashMapFromArray _params;
        {
            if (getArray (_x/"texts") isEqualTo [""]) then { continue };                // spacer/title
            private _val = _savedParamsHM getOrDefault [configName _x, getNumber (_x/"default")];
            if (getArray (_x/"values") isEqualTo [0,1]) then {
                if (_val isEqualType 0) then { _val = _val != 0 };                      // number -> bool
            } else {
                if (_val isEqualType false) then { _val = [0, 1] select _val };         // bool -> number
            };
            [missionNamespace, configName _x, _val] call BIS_fnc_setServerVariable;
        } forEach ("true" configClasses (configFile/"A3A"/"Params"));

        closeDialog 0;

        private _saveData = [missionNamespace, "A3A_saveData", createHashMap] call BIS_fnc_getServerVariable;
        sleep 1;
        _saveData set ["params", _params];
        [missionNamespace, "A3A_saveData", _saveData] call BIS_fnc_setServerVariable;
    };
};
onLoad: Opens dialog, loads saved params, fills table
ResetParams: Reloads default params
SaveParams:
Gets current values
Converts bool ↔ number
Sets server variables
Closes dialog
Saves to server save data
Where it leads:
Functions Called:

A3A_fnc_setupDialog - Switches tabs
A3A_fnc_setupParamsTab - Fills/gets parameters
BIS_fnc_setServerVariable - Sets server variables
BIS_fnc_getServerVariable - Gets server save data
Global Variables Modified:

A3A_saveData (server variable)
Individual parameter variables (server variables)
Dependencies:

Requires A3A_SetupDialog_InGame dialog
Requires parameter config in configFile/A3A/Params
Requires admin permissions
Used By:

Admin parameter editing interface
fn_ui_establishOutpostEventHandler.sqf
File: A3A/addons/scrt/UI/fn_ui_establishOutpostEventHandler.sqf Line Count: 104 lines

Function: [mode] call SCRT_fnc_ui_establishOutpostEventHandler;
What it does:
Handles map click events for establishing outposts with different types and optional direction markers.

How it does that:
1. Mode Check:

Sqf

Apply
params ["_mode"];

if(_mode == "ADD") then {
    [
        "establishOutpost",
        "onMapSingleClick",
        {
            playSound "readoutClick";
            // ... validation and creation logic
        },
        []
    ] call BIS_fnc_addStackedEventHandler;
} else {
    ["establishOutpost", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
};
2. Click Logic:

Watchpost (One-Click):

Sqf

Apply
if (outpostType == "WATCHPOST" && {isOnRoad _pos}) exitWith {
    // Error: watchpost on road
};

if (outpostType == "WATCHPOST") exitWith {
    [_pos, outpostCost select 0, outpostCost select 1, clientOwner] remoteExec ["SCRT_fnc_outpost_createWatchpost", 2];
    ["REMOVE"] call SCRT_fnc_ui_establishOutpostEventHandler;
    closeDialog 0;
};
Cannot be on road
Directly creates watchpost
Removes handler and closes dialog
Roadblock (One-Click):

Sqf

Apply
if (outpostType == "ROADBLOCK" && {!isOnRoad _pos}) exitWith {
    // Error: roadblock not on road
};

if (outpostType == "ROADBLOCK") exitWith {
    [_pos, outpostCost select 0, outpostCost select 1, clientOwner] remoteExec ["SCRT_fnc_outpost_createRoadblock", 2];
    ["REMOVE"] call SCRT_fnc_ui_establishOutpostEventHandler;
    closeDialog 0;
};
Must be on road
Directly creates roadblock
AA/AT/HMG (Two-Click with Direction):

First Click (Origin):

Sqf

Apply
if (isNil "outpostOrigin") then {
    outpostOrigin = createMarkerLocal ["BRStart", _pos];
    outpostOrigin setMarkerShapeLocal "ICON";
    outpostOrigin setMarkerTypeLocal "hd_end";
    outpostOrigin setMarkerTextLocal format [localize "STR_marker_outpost_position", outpostType];

    [
        localize "STR_notifiers_info_type",
        localize "STR_notifiers_trader_establish_outpost_header",
        parseText (localize "STR_notifiers_trader_establish_outpost_set_direction"), 
        30
    ] spawn SCRT_fnc_ui_showMessage;
};
Creates origin marker (hd_end icon)
Shows instruction for second click
Second Click (Direction):

Sqf

Apply
else {           
    outpostDirection = createMarkerLocal ["BRFin", _pos];
    outpostDirection setMarkerShapeLocal "ICON";
    outpostDirection setMarkerTypeLocal "hd_dot";
    outpostDirection setMarkerTextLocal format [localize "STR_marker_outpost_direction", outpostType];

    private _direction = [(getMarkerPos outpostOrigin), (getMarkerPos outpostDirection)] call BIS_fnc_dirTo;

    switch (outpostType) do {
        case "AA": {
            [(getMarkerPos outpostOrigin), _direction, outpostCost select 0, outpostCost select 1, clientOwner] remoteExec ["SCRT_fnc_outpost_createAa", 2];
        };
        case "AT": {
            [(getMarkerPos outpostOrigin), _direction, outpostCost select 0, outpostCost select 1, clientOwner] remoteExec ["SCRT_fnc_outpost_createAt", 2];
        };
        case "HMG": {
            [(getMarkerPos outpostOrigin), _direction, outpostCost select 0, outpostCost select 1, clientOwner] remoteExec ["SCRT_fnc_outpost_createHmg", 2];
        };
    };

    ["REMOVE"] call SCRT_fnc_ui_establishOutpostEventHandler;
    closeDialog 0;
};
Creates direction marker (hd_dot icon)
Calculates direction between origin and direction markers
Calls appropriate outpost creation function
Removes handler and closes dialog
Where it leads:
Functions Called:

SCRT_fnc_ui_showMessage - Shows instructions
SCRT_fnc_outpost_createWatchpost - Creates watchpost
SCRT_fnc_outpost_createRoadblock - Creates roadblock
SCRT_fnc_outpost_createAa - Creates AA outpost
SCRT_fnc_outpost_createAt - Creates AT outpost
SCRT_fnc_outpost_createHmg - Creates HMG outpost
SCRT_fnc_ui_establishOutpostEventHandler - Self (removal)
Global Variables Modified:

outpostOrigin (local marker)
outpostDirection (local marker)
Dependencies:

Requires outpostType global
Requires outpostCost global
Requires clientOwner
Requires teamPlayer side
Used By:

fn_ui_setEstablishOutpostMode - Activates handler
fn_ui_getSwitchLookup.sqf
File: A3A/addons/scrt/UI/fn_ui_getSwitchLookup.sqf Line Count: 23 lines

Function: [table, idc] call SCRT_fnc_ui_getSwitchLookup;
What it does:
Returns variable name, current value, and possible values for switch buttons.

How it does that:
Sqf

Apply
params ["_table", "_idc"];
_return = [];	
switch (_table) do {
    case "MAIN": {
        switch (_idc) do {
            case 5100: {
                _return pushBack "musicON";
                _return pushBack musicON;
            };
            case 5400: {
                _return pushBack "isPlayerParadropable";
                _return pushBack isPlayerParadropable;
            };
            case 5500: {
                _return pushBack "randomizeRebelLoadoutUniforms";
                _return pushBack randomizeRebelLoadoutUniforms;
            };
        };
        _return pushBack [localize "STR_commander_menu_switch_enabled", localize "STR_commander_menu_switch_disabled"];			
    };
};
_return
Returns array: [variableName, currentValue, [enabledText, disabledText]]
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires musicON, isPlayerParadropable, randomizeRebelLoadoutUniforms globals
Used By:

fn_ui_switchButton - Gets lookup data
fn_ui_hqTabEventHandler.sqf
File: A3A/addons/scrt/UI/fn_ui_hqTabEventHandler.sqf Line Count: 46 lines

Function: [mode] call SCRT_fnc_ui_hqTabEventHandler;
What it does:
Handles map click for rebuilding HQ assets.

How it does that:
1. Mode Check:

Sqf

Apply
params ["_mode"];

if(_mode isEqualTo "ADD") then {
    [
        "hqMap",
        "onMapSingleClick",
        {
            playSound "readoutClick";

            private _site = [markersX, _pos] call BIS_fnc_nearestPosition;
            if (getMarkerPos _site distance _pos > 50) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_notifiers_rebuild_assets_header",  
                    parseText (localize "STR_notifiers_rebuild_assets_friendly_marker"), 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            private _side = sidesX getVariable [_site, sideUnknown];
            if (_side != teamPlayer) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_notifiers_rebuild_assets_header",  
                    parseText format [localize "STR_notifiers_rebuild_assets_not_belong", A3A_faction_reb get "name"], 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };
            
            private _resourcesFIA = server getVariable "resourcesFIA";
            if (_resourcesFIA < 5000) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_notifiers_rebuild_assets_header",  
                    parseText format [localize "STR_notifiers_rebuild_assets_not_enough_money", A3A_faction_civ get "currencySymbol"], 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            [_site, _pos] call A3A_fnc_rebuildAssets;
        },
        []
    ] call BIS_fnc_addStackedEventHandler;
} else {
    ["hqMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
}
Click Logic:

Must be within 50m of marker
Site must be owned by rebels
Must have 5000+ resources
Calls A3A_fnc_rebuildAssets
Where it leads:
Functions Called:

SCRT_fnc_ui_showMessage - Shows error messages
A3A_fnc_rebuildAssets - Rebuilds assets
Global Variables Modified:

None (handler is local)
Dependencies:

Requires markersX array
Requires sidesX hash map
Requires teamPlayer side
Requires A3A_faction_reb with name key
Requires A3A_faction_civ with currencySymbol key
Requires 5000+ resources
Used By:

fn_ui_setRebuildAssetMode - Activates handler
fn_ui_launchSupport.sqf
File: A3A/addons/scrt/UI/fn_ui_launchSupport.sqf Line Count: 212 lines

Function: [] call SCRT_fnc_ui_launchSupport;
What it does:
Launches support after validating all requirements and deducting costs.

How it does that:
1. Cooldown Check:

Sqf

Apply
if(!isNil "supportCooldown" && {supportCooldown}) exitWith {
    // Error: support overwhelmed
};
2. Resource Checks:

Airstrikes:

Sqf

Apply
if (supportType in ["NAPALM", "HE", "CLUSTER", "CHEMICAL"] && bombRuns < 1) exitWith {
    // Error: not enough airstrike runs
};
Other Supports:

Sqf

Apply
if (supportType in ["LOOTHELI","SUPPLY", "SMOKE", "FLARE", "VEH_AIRDROP", "RECON", "PARADROP"] && supportPoints < 1) exitWith {
    // Error: not enough support points
};
3. Airport Check:

Sqf

Apply
private _hasAirports = airportsX findIf { sidesX getVariable [_x, sideUnknown] isEqualTo teamPlayer } isNotEqualTo -1;
if (supportType in ["LOOTHELI","NAPALM", "HE", "CLUSTER", "CHEMICAL", "VEH_AIRDROP", "SUPPLY", "RECON", "PARADROP"] && !_hasAirports) exitWith {
    // Error: need airport
};
4. Money Checks:

Sqf

Apply
if (supportType isEqualTo "PARADROP" && {_resourcesFIA < 500}) exitWith {
    // Error: need 500
};

if (supportType isEqualTo "LOOTHELI" && {_resourcesFIA < 2000}) exitWith {
    // Error: need 2000
};

if (supportType isEqualTo "VEH_AIRDROP" && {_resourcesFIA < 200}) exitWith {
    // Error: need 200
};
5. Radio Check:

Sqf

Apply
if (!([player] call A3A_fnc_hasRadio)) exitWith {
    // Error: need radio
};
6. Marker Checks:

Sqf

Apply
if (isNil "supportMarkerOrigin") exitWith {
    // Error: specify origin
};

if (!(supportType in ["SMOKE", "FLARE"]) && {isNil "supportMarkerDestination"}) exitWith {
    // Error: specify destination
};
7. Paradrop-Specific Checks:

Sqf

Apply
if (supportType isEqualTo "PARADROP") then {
    if ((getMarkerPos "Synd_HQ") distance2D theBoss > 50) exitWith {
        // Error: commander must be at HQ
    };

    if ([(getMarkerPos "Synd_HQ")] call A3A_fnc_enemyNearCheck) exitWith {
        // Error: enemies at HQ
    };

    private _attendants = [missionNamespace, "paradropAttendants", []] call BIS_fnc_getServerVariable;
    if (_attendants isEqualTo []) exitWith {
        // Error: no players ready
    };

    _attendants = _attendants apply {_x call BIS_fnc_getUnitByUID};
    private _readyPlayers = _attendants select {
        _x distance2D (getMarkerPos "Synd_HQ") < 50 
        && vehicle _x isEqualTo _x && {[_x] call A3A_fnc_canFight} 
        && !(!(isNil "HR_GRG_placing") && {HR_GRG_placing})
    };
    if (isNil "_readyPlayers" || {count _readyPlayers == 0}) exitWith {
        // Error: no ready players
    };
};
8. Deduct Resources:

Sqf

Apply
switch (supportType) do {
    case ("SUPPLY");
    case ("SMOKE");
    case ("FLARE");
    case ("RECON"): {
        supportPoints = supportPoints - 1;
        publicVariable "supportPoints";
    };
    case ("VEH_AIRDROP"): {
        supportPoints = supportPoints - 1;
        publicVariable "supportPoints";
        [0,-200] remoteExec ["A3A_fnc_resourcesFIA",2];
    };
    case ("PARADROP"): {
        supportPoints = supportPoints - 1;
        publicVariable "supportPoints";
        [0,-500] remoteExec ["A3A_fnc_resourcesFIA",2];
    };
    case ("LOOTHELI"): {
        supportPoints = supportPoints - 1;
        publicVariable "supportPoints";
        [0,-2000] remoteExec ["A3A_fnc_resourcesFIA",2];
    };
    case ("NAPALM");
    case ("HE");
    case ("CLUSTER");
    case ("CHEMICAL"): {
        bombRuns = bombRuns - 1;
        publicVariable "bombRuns";
    };
};
9. Spawn Support:

Sqf

Apply
switch (true) do {
    case (supportType isEqualTo "SMOKE"): {
        [] spawn SCRT_fnc_support_smokeBarrage;
    };
    case (supportType isEqualTo "FLARE"): {
        [] spawn SCRT_fnc_support_flareBarrage;
    };
    case (supportType isEqualTo "RECON"): {
        [] spawn SCRT_fnc_support_planeReconRun;
    };
    case (supportType isEqualTo "PARADROP"): {
        [] remoteExec  ["SCRT_fnc_paradrop_prepare", 2];
        [] spawn SCRT_fnc_support_planeParadropRun;
    };
    case (supportType isEqualTo "LOOTHELI"): {
        [] spawn SCRT_fnc_support_lootHeli;
    };
    case (supportType isEqualTo "VEH_AIRDROP");
    case (supportType isEqualTo "SUPPLY");
    case (supportType in ["HE", "CLUSTER", "CHEMICAL", "NAPALM"]): {
        [] spawn SCRT_fnc_support_planePayloadedRun;
    };
};
10. Cooldown and Cleanup:

Sqf

Apply
supportCooldown = true;
publicVariable "supportCooldown";
isSupportMarkerPlacingLocked = true;
publicVariable "isSupportMarkerPlacingLocked";

// Show success message

private _timeOut = time + 180;
waitUntil { sleep 1; !isSupportMarkerPlacingLocked || {time > _timeOut} };

supportCooldown = false;
publicVariable "supportCooldown";

[] spawn SCRT_fnc_ui_clearSupport;
Sets cooldown flags
Waits 3 minutes or until support completes
Resets cooldown
Clears support markers
Where it leads:
Functions Called:

A3A_fnc_hasRadio - Checks for radio
A3A_fnc_enemyNearCheck - Checks for enemies
SCRT_fnc_support_smokeBarrage - Smoke support
SCRT_fnc_support_flareBarrage - Flare support
SCRT_fnc_support_planeReconRun - Recon support
SCRT_fnc_paradrop_prepare - Prepares paradrop (server 2)
SCRT_fnc_support_planeParadropRun - Paradrop support
SCRT_fnc_support_lootHeli - Loot heli support
SCRT_fnc_support_planePayloadedRun - Supply/vehicle/airstrike support
A3A_fnc_resourcesFIA - Deducts resources
SCRT_fnc_ui_clearSupport - Clears markers
A3A_fnc_statistics - Updates HUD
SCRT_fnc_ui_updateSupportMenu - Updates support menu
SCRT_fnc_ui_showMessage - Shows notifications
Global Variables Modified:

supportCooldown (public)
isSupportMarkerPlacingLocked (public)
supportPoints (public)
bombRuns (public)
paradropAttendants (server variable)
Dependencies:

Requires all support type variables
Requires all marker variables
Requires teamPlayer, theBoss
Requires airportsX, markersX
Requires A3A_faction_reb, A3A_faction_civ
Used By:

Support menu launch button
fn_ui_manageSupportTabEventHandler.sqf
File: A3A/addons/scrt/UI/fn_ui_manageSupportTabEventHandler.sqf Line Count: 128 lines

Function: [mode] call SCRT_fnc_ui_manageSupportTabEventHandler;
What it does:
Handles map clicks for support marker placement (origin and destination).

How it does that:
1. Mode Check:

Sqf

Apply
params ["_mode"];

if(_mode isEqualTo "ADD") then {
    [
        "supportMap",
        "onMapSingleClick",
        {
            if(!isNil "isSupportMarkerPlacingLocked" && {isSupportMarkerPlacingLocked}) exitWith {};

            playSound "readoutClick";
            // ... marker creation logic
        },
        []
    ] call BIS_fnc_addStackedEventHandler;
} else {
    ["supportMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
};
2. Click Logic:

First Click (Origin):

Sqf

Apply
if (isNil "supportMarkerOrigin") then {
    if (supportType == "PARADROP") then {
        private _nearMarker = [forbiddenParadropZones, _pos] call BIS_fnc_nearestPosition;
        if ((getMarkerPos _nearMarker) distance2D _pos < 500) then {
            // Error: too close to enemy
        } else {
            supportMarkerOrigin = createMarkerLocal ["BRStart", _pos];
            // ... setup marker
        };
    } else {                   
        supportMarkerOrigin = createMarkerLocal ["BRStart", _pos];
        // ... setup marker
    };

    // Color and text based on supportType
    switch (supportType) do {
        case ("SUPPLY"): {
            supportMarkerOrigin setMarkerColorLocal "ColorBlue";
            supportMarkerOrigin setMarkerTextLocal (localize "STR_support_supply_run_init");
        };
        // ... other cases
    };
};
Second Click (Destination):

Sqf

Apply
} else {
    if !(supportType in ["SMOKE", "FLARE"]) then {
        if (supportType == "PARADROP") then {
            private _nearMarker = [forbiddenParadropZones, _pos] call BIS_fnc_nearestPosition;
            if ((getMarkerPos _nearMarker) distance2D _pos < 500) then {
                // Error: too close
            } else {
                supportMarkerDestination = createMarkerLocal ["BRFin", _pos];
                // ... setup marker
            };
        } else {                   
            supportMarkerDestination = createMarkerLocal ["BRFin", _pos];
            // ... setup marker
        };

        // Color and text based on supportType
        switch (supportType) do {
            case ("SUPPLY"): {
                supportMarkerDestination setMarkerColorLocal "ColorBlue";
                supportMarkerDestination setMarkerTextLocal (localize "STR_support_supply_run_exit");
            };
            // ... other cases
            case ("LOOTHELI"): {
                // Also creates area marker
                private _areaMarker = createMarkerLocal ["LootHeliAreaMarker", _pos];
                _areaMarker setMarkerShapeLocal "ELLIPSE";
                _areaMarker setMarkerSizeLocal [250,250];
                _areaMarker setMarkerTypeLocal "hd_warning";
                _areaMarker setMarkerColorLocal "colorCivilian";
                _areaMarker setMarkerBrushLocal "Grid";
            };
        };
    } else {
        deleteMarkerLocal supportMarkerDestination;
    };
};
Where it leads:
Functions Called:

BIS_fnc_nearestPosition - Finds nearest forbidden zone
SCRT_fnc_ui_showMessage - Shows error messages
Global Variables Modified:

supportMarkerOrigin (local marker)
supportMarkerDestination (local marker)
LootHeliAreaMarker (local marker)
Dependencies:

Requires supportType global
Requires forbiddenParadropZones array (for paradrop)
Requires isSupportMarkerPlacingLocked global
Used By:

Support tab in commander menu
fn_ui_minefieldEventHandler.sqf
File: A3A/addons/scrt/UI/fn_ui_minefieldEventHandler.sqf Line Count: 15 lines

Function: [mode] call SCRT_fnc_ui_minefieldEventHandler;
What it does:
Handles map clicks for minefield placement.

How it does that:
Sqf

Apply
params ["_mode"];

if(_mode == "ADD") then {
    [
        "minefieldMap",
        "onMapSingleClick",
        {
            playSound "readoutClick";
            [minefieldType, _pos] spawn A3A_fnc_mineDialog;
        },
        []
    ] call BIS_fnc_addStackedEventHandler;
} else {
    ["minefieldMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
};
Click calls A3A_fnc_mineDialog with minefield type and position
Where it leads:
Functions Called:

A3A_fnc_mineDialog - Opens minefield dialog
Global Variables Modified:

None (handler is local)
Dependencies:

Requires minefieldType global
Used By:

fn_ui_setMinefieldMode - Activates handler
fn_ui_populateBlackMarket.sqf
File: A3A/addons/scrt/UI/fn_ui_populateBlackMarket.sqf Line Count: 91 lines

Function: [_category] call SCRT_fnc_ui_populateBlackMarket;
What it does:
Populates black market vehicle list based on category.

How it does that:
1. Get Stock:

Sqf

Apply
private _stock = A3U_blackMarketStock select {
    private _fnc_isAvailable = _x select 3;
    call _fnc_isAvailable;
};
Filters stock by availability function
2. Extract Classes by Type:

Sqf

Apply
private _fnc_extractMarketClasses = {
    private _type = _this;
    private _vehicleRegisters = _stock select {(_x select 2) isEqualTo _type};
    if (_vehicleRegisters isEqualTo []) exitWith {[]};

    _vehicleRegisters apply {_x select 0};
};
Returns all vehicle classes for given type
3. Category Switch:

Sqf

Apply
switch (_category) do {
    case "artillery": {
        _vehicleClasses = ("ARTILLERY" call _fnc_extractMarketClasses) select {_x isNotEqualTo []};
    };
    // ... other cases
    case "all": {
        if (_stock isEqualTo []) exitWith {_buyableVehiclesList};
        _vehicleClasses = _stock apply {_x select 0};
    };
};
4. Price Calculation:

Sqf

Apply
{
    private _vehiclePrice = [_x] call A3U_fnc_blackMarketVehiclePrice;
    _buyableVehiclesList pushBack [_x, _vehiclePrice, false];
} forEach _vehicleClasses;
5. Return:

Sqf

Apply
_buyableVehiclesList;
Where it leads:
Functions Called:

A3U_fnc_blackMarketVehiclePrice - Calculates price
Global Variables Modified: None

Dependencies:

Requires A3U_blackMarketStock array
Requires vehicle availability functions
Used By:

Black market vehicle dialog
fn_ui_populateCommanderMenu.sqf
File: A3A/addons/scrt/UI/fn_ui_populateCommanderMenu.sqf Line Count: 249 lines

Function: [] call SCRT_fnc_ui_populateCommanderMenu;
What it does:
Sets up commander menu with all tabs, buttons, and UI elements.

How it does that:
1. Tab Definition:

Sqf

Apply
menuSliderArray = [
    [localize "STR_commander_menu_abilities_header_upper", 1140],
    [localize "STR_commander_menu_garrison_header_upper", 2000],
    [format [localize "STR_commander_menu_hq_header_upper", (toUpper (A3A_faction_reb get "name"))], 3000],
    [localize "STR_commander_menu_environment_header_upper", 4000],
    [localize "STR_commander_menu_game_options_header_upper", 5000],
    [localize "STR_commander_menu_game_info_header_upper", 6000]
];

// Add Rivals tab if discovered
if (areRivalsDiscovered) then {
    // Insert rivals tab at position 3
    menuSliderArray = _firstPart + [[format [(localize "STR_antistasi_rivals_tab_header"), (toUpper (A3A_faction_riv get "name"))], 7000]] + _secondPart;
};

menuSliderCurrent = 0;
2. Rivals Tab Content:

Sqf

Apply
if (areRivalsDiscovered && {!areRivalsDefeated}) then {
    private _knownLocationsCount = count (["KNOWN"] call SCRT_fnc_rivals_getLocations);

    (_display displayCtrl 7703) ctrlSetText format [(localize "STR_antistasi_rivals_total_locations_label"), (count rivalsLocationsMap)];
    (_display displayCtrl 7704) ctrlSetText format [(localize "STR_antistasi_rivals_attackable_locations_label"), _knownLocationsCount];
    (_display displayCtrl 7700) ctrlSetText format [(localize "STR_antistasi_rivals_network_header"), A3A_faction_riv get "name"];
    (_display displayCtrl 7701) ctrlSetText format [(localize "STR_antistasi_rivals_network_description"), A3A_faction_riv get "name"];

    (_display displayCtrl 7750) progressSetPosition (nextRivalsLocationReveal / 100);
    (_display displayCtrl 7750) ctrlSetTooltip format [(localize "STR_antistasi_rivals_network_progress_bar_tooltip"), A3A_faction_riv get "name"];

    if (_knownLocationsCount > 0) then {
        (_display displayCtrl 7762) ctrlSetBackgroundColor [(profilenamespace getvariable ['GUI_BCG_RGB_R',0.376]), (profilenamespace getvariable ['GUI_BCG_RGB_G',0.125]), (profilenamespace getvariable ['GUI_BCG_RGB_B',0.043]), 1];
        (_display displayCtrl 7762) ctrlSetText (localize "STR_antistasi_rivals_show_activity_attack_title");
    } else {
        (_display displayCtrl 7762) ctrlSetText format [(localize "STR_antistasi_rivals_show_activity_title"), A3A_faction_riv get "name"];
    };
    (_display displayCtrl 7762) ctrlSetTooltip format [(localize "STR_antistasi_rivals_show_activity_commander_tooltip"), A3A_faction_riv get "name"];
};
3. Support Combobox Population:

Sqf

Apply
supportType = "SMOKE";
lbAdd [1750, localize "STR_commander_menu_smoke_barrage_title"];
lbSetData [1750, 0, "SMOKE"];
lbSetTooltip [1750, 0, localize "STR_commander_menu_smoke_barrage_tooltip"];
// ... repeated for all support types
lbSetCurSel [1750, 0];
4. Outpost Combobox:

Sqf

Apply
outpostType = "WATCHPOST";
lbAdd [2750, localize "STR_commander_menu_watchpost_title"];
lbSetData [2750, 0, "WATCHPOST"];
// ... repeated for all outpost types
lbSetCurSel [2750, 0];
5. Minefield Combobox:

Sqf

Apply
minefieldType = "APERSMine";
lbAdd [2758, localize "STR_commander_menu_apersminefield_title"];
lbSetData [2758, 0, "APERSMine"];
// ... repeated
lbSetCurSel [2758, 0];
6. Weather Controls:

Sqf

Apply
sliderSetRange [4041, 0, 100];
sliderSetPosition [4041, 50];
(_display displayCtrl 4041) ctrlSetText format [localize "STR_commander_menu_fog_title", 50];
fogValue = nil;

sliderSetRange [4061, 0, 100];
sliderSetPosition [4061, 50];
(_display displayCtrl 4061) ctrlSetText format [localize "STR_commander_menu_overcast_title", 50];
overcastValue = nil;
7. Button Visibility:

Sqf

Apply
// Show reroll button if quest completed
if (!isTraderQuestCompleted) then {
    (_display displayCtrl 6014) ctrlShow false;
};

// Show admin button if admin
if (isServer || {(call BIS_fnc_admin) isEqualTo 2}) then {
    ctrlShow [5200, true];
    ctrlEnable [5200, true];
} else {
    ctrlShow [5200, true];
    ctrlEnable [5200, false];
};

// Show HQ rebuild button only at HQ
if (player distance2D (getMarkerPos "Synd_HQ") > 50) then {
    (_display displayCtrl 5300) ctrlShow false;
};
8. Final Setup:

Sqf

Apply
[] call SCRT_fnc_ui_updateSupportMenu;
["ADD"] call SCRT_fnc_ui_manageSupportTabEventHandler;
Where it leads:
Functions Called:

SCRT_fnc_rivals_getLocations - Gets known locations
SCRT_fnc_ui_updateSupportMenu - Updates support counters
SCRT_fnc_ui_manageSupportTabEventHandler - Adds support map handler
Global Variables Modified:

menuSliderArray (global)
menuSliderCurrent (global)
supportType (global)
outpostType (global)
minefieldType (global)
fogValue, overcastValue (global)
Dependencies:

Requires all menu control IDs
Requires areRivalsDiscovered, areRivalsDefeated
Requires nextRivalsLocationReveal
Requires A3A_faction_riv with name key
Requires A3A_faction_reb with name key
Requires traderQuestCompleted
Requires player, theBoss
Requires supportPoints, bombRuns
Used By:

fn_ui_toggleCommanderMenu - When opening commander menu
fn_ui_populateGameOptionsMenu.sqf
File: A3A/addons/scrt/UI/fn_ui_populateGameOptionsMenu.sqf Line Count: 55 lines

Function: [] call SCRT_fnc_ui_populateGameOptionsMenu;
What it does:
Populates game options tab with switch buttons and info.

How it does that:
1. Tab Setup:

Sqf

Apply
menuSliderArray = [
    [localize "STR_commander_menu_game_options_header_upper", 5000],
    [localize "STR_commander_menu_game_info_header_upper", 6000]
];
menuSliderCurrent = 0;
2. Info Display:

Sqf

Apply
private _gameInfoText = format [
    localize "STR_commander_menu_about_text", 
    worldName,
    QUOTE(VERSION_FULL), 
    minWeaps,
    [localize "STR_antistasi_dialogs_generic_button_no_text", localize "STR_antistasi_dialogs_generic_button_yes_text"] select limitedFT,
    [localize "STR_antistasi_dialogs_generic_button_no_text", localize "STR_antistasi_dialogs_generic_button_yes_text"] select areRivalsEnabled,
    [[serverTime-A3A_lastGarbageCleanTime] call A3A_fnc_secondsToTimeSpan,1,0,false,2,false,true] call A3A_fnc_timeSpan_format)
];

(_display displayCtrl 6011) ctrlSetText _gameInfoText;
(_display displayCtrl 6013) ctrlSetText ([] call A3A_fnc_membersList);
3. Skill Info:

Sqf

Apply
private _fiaTrainingText = format [localize "STR_commander_menu_skill_level_title", A3A_faction_reb get "name", skillFIA];
(_display displayCtrl 3102) ctrlSetText _fiaTrainingText;
4. Switch Buttons:

Sqf

Apply
["MAIN", 5100, false] call SCRT_fnc_ui_switchButton;
["MAIN", 5400, false] call SCRT_fnc_ui_switchButton;
5. Show Reroll Button:

Sqf

Apply
if (!isTraderQuestCompleted) then {
    (_display displayCtrl 6014) ctrlShow false;
};
6. Admin Button:

Sqf

Apply
if (isServer || {(call BIS_fnc_admin) isEqualTo 2}) then {
    ctrlShow [5200, true];
    ctrlEnable [5200, true];
    (_display displayCtrl 5200) ctrlSetTooltip (localize "STR_commander_menu_edit_params_button_tooltip");
} else {
    ctrlShow [5200, false];
    ctrlEnable [5200, false];
    (_display displayCtrl 5200) ctrlSetTooltip (localize "STR_generic_admin_only");
};
7. Navigate to Options Tab:

Sqf

Apply
[60000,'LEFT'] spawn SCRT_fnc_ui_changeTab;
sleep 0.1;
[60000,'LEFT'] spawn SCRT_fnc_ui_changeTab;
Switches twice to get to game options tab (position 2)
Where it leads:
Functions Called:

SCRT_fnc_ui_switchButton - Initializes switch buttons
A3A_fnc_secondsToTimeSpan - Formats time
A3A_fnc_membersList - Gets member list
SCRT_fnc_ui_changeTab - Navigates to options tab
Global Variables Modified:

menuSliderArray (global)
menuSliderCurrent (global)
Dependencies:

Requires limitedFT, areRivalsEnabled
Requires A3A_lastGarbageCleanTime
Requires skillFIA
Requires traderQuestCompleted
Requires A3A_faction_reb with name key
Requires admin permissions
Used By:

Called from UI to populate options tab
fn_ui_populateRebelMenu.sqf
File: A3A/addons/scrt/UI/fn_ui_populateRebelMenu.sqf Line Count: 81 lines

Function: [] call SCRT_fnc_ui_populateRebelMenu;
What it does:
Populates rebel menu (simplified commander menu for non-commander players).

How it does that:
1. Tab Setup:

Sqf

Apply
menuSliderArray = [
    [localize "STR_commander_menu_game_options_header_upper", 1140],
    [localize "STR_commander_menu_game_info_header_upper", 2000]
];

if (areRivalsDiscovered) then {
    private _rivTitle = format [(localize "STR_antistasi_rivals_tab_header"), (toUpper (A3A_faction_riv get "name"))];
    menuSliderArray = [
        [_rivTitle, 7000],
        [localize "STR_commander_menu_game_options_header_upper", 1140],
        [localize "STR_commander_menu_game_info_header_upper", 2000]
    ];
    ((findDisplay 70000) displayCtrl 1101) ctrlSetText _rivTitle;
};
2. Rivals Tab Content:

Sqf

Apply
if (areRivalsDiscovered) then {
    private _knownLocationsCount = count (["KNOWN"] call SCRT_fnc_rivals_getLocations);

    ((findDisplay 70000) displayCtrl 7703) ctrlSetText format [(localize "STR_antistasi_rivals_total_locations_label"), (count rivalsLocationsMap)];
    ((findDisplay 70000) displayCtrl 7704) ctrlSetText format [(localize "STR_antistasi_rivals_attackable_locations_label"), _knownLocationsCount];
    // ... rest of rivals UI
};
3. Navigation:

Sqf

Apply
[70000,'RIGHT'] spawn SCRT_fnc_ui_changeTab;
[70000,'RIGHT'] spawn SCRT_fnc_ui_changeTab;
[70000,'RIGHT'] spawn SCRT_fnc_ui_changeTab;
Switches 3 times to get to rivals tab (position 2)
Where it leads:
Functions Called:

SCRT_fnc_rivals_getLocations - Gets known locations
SCRT_fnc_ui_changeTab - Navigates to rivals tab
Global Variables Modified:

menuSliderArray (global)
menuSliderCurrent (global)
Dependencies:

Requires display 70000 (rebel menu)
Requires areRivalsDiscovered
Requires Rivals UI controls (7703, 7704, 7700, 7701, 7750, 7762)
Used By:

fn_ui_toggleCommanderMenu - When opening rebel menu for non-commander
fn_ui_populateVehicleBox.sqf
File: A3A/addons/scrt/UI/fn_ui_populateVehicleBox.sqf Line Count: 220 lines

Function: [_category] call SCRT_fnc_ui_populateVehicleBox;
What it does:
Populates vehicle box list based on category (civilian, military, statics, etc.).

How it does that:
1. Category Switch:

Sqf

Apply
switch (_category) do {
    case "civilian": {
        private _civilianVehicles = 
            (A3A_faction_reb get 'vehiclesCivCar') +
            (A3A_faction_reb get 'vehiclesCivTruck') +
            (A3A_faction_reb get 'vehiclesCivBoat') select {_x isNotEqualTo ""};
        
        private _civAircrafts = (A3A_faction_reb get "vehiclesCivHeli") + (A3A_faction_reb get 'vehiclesCivPlane');
        if (_civAircrafts isNotEqualTo [] && {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0}) then {
            _civilianVehicles append _civAircrafts;
        };

        _isCivilian = true;
        _vehicleClasses = _civilianVehicles;
    };
    case "civcars": {
        private _civilianVehicles = (A3A_faction_reb get 'vehiclesCivCar') select {_x isNotEqualTo ""};
        _isCivilian = true;
        _vehicleClasses = _civilianVehicles;
    };
    // ... many other cases
    case "static": {
        private _statics = [];
        
        if (tierWar > 2) {
            private _availableVehs = (A3A_faction_reb get 'staticMGs') select {_x isNotEqualTo []};
            _statics append _availableVehs;
        };

        if (tierWar > 3) {
            private _availableVehs = 
                (A3A_faction_reb get 'staticAT') +
                (A3A_faction_reb get 'staticAA') select {_x isNotEqualTo []};
            _statics append _availableVehs;
        };

        if (tierWar > 4) {
            private _mortars = A3A_faction_reb get 'staticMortars';
            if (_mortars isNotEqualTo []) then {
                _statics append _mortars;
            };
        };

        _vehicleClasses = _statics;
    };
    // ... many other cases
};
2. Price Calculation:

Sqf

Apply
{
    private _vehiclePrice = [_x] call A3A_fnc_vehiclePrice;
    _buyableVehiclesList pushBack [_x, _vehiclePrice, _isCivilian];
} forEach _vehicleClasses;
3. Return:

Sqf

Apply
_buyableVehiclesList;
Where it leads:
Functions Called:

A3A_fnc_vehiclePrice - Gets vehicle price
Global Variables Modified: None

Dependencies:

Requires A3A_faction_reb with all vehicle arrays
Requires tierWar
Requires airportsX
Requires sidesX
Requires teamPlayer
Used By:

Vehicle box dialog
fn_ui_prepareConstructionBuild.sqf
File: A3A/addons/scrt/UI/fn_ui_prepareConstructionBuild.sqf Line Count: 18 lines

Function: [] call SCRT_fnc_ui_prepareConstructionBuild;
What it does:
Gets construction type and specific construction from dialog, then starts building.

How it does that:
1. Get Selections:

Sqf

Apply
private _display = findDisplay 80000;
private _comboBox = _display displayCtrl 505;
private _index = lbCurSel _comboBox;
private _constructionType = _comboBox lbData _index;

_comboBox = _display displayCtrl 506;
_index = lbCurSel _comboBox;
private _construction = _comboBox lbData _index;
2. Close Dialog and Build:

Sqf

Apply
closeDialog 0;
closeDialog 0;
[_constructionType, _construction] call SCRT_fnc_build_prepareAndStartConstruction;
Where it leads:
Functions Called:

SCRT_fnc_build_prepareAndStartConstruction - Starts construction
Global Variables Modified: None

Dependencies:

Requires display 80000 (construction menu)
Requires controls 505 and 506
Used By:

Construction menu "Build" button
fn_ui_prepareConstructionRemoval.sqf
File: A3A/addons/scrt/UI/fn_ui_prepareConstructionRemoval.sqf Line Count: 55 lines

Function: [] call SCRT_fnc_ui_prepareConstructionRemoval;
What it does:
Handles construction removal with confirmation dialog.

How it does that:
1. Validation:

Sqf

Apply
if (!(player call A3A_fnc_isEngineer)) exitWith {
    [localize "STR_antistasi_dialogs_construction_removal_title", localize "STR_antistasi_dialogs_construction_removal_no_trait"] call SCRT_fnc_misc_deniedHint;
    closeDialog 0;
};

if (count constructionsToSave < 1) exitWith {
    closeDialog 0;
};
2. Find Construction:

Sqf

Apply
private _construction = cursorTarget;
if(isNil "_construction" || {isNull _construction}) then {
    private _constuctions = +constructionsToSave;
    private _closeConstructions = [_constuctions, [], { player distance _x }, "ASCEND"] call BIS_fnc_sortBy;

    if (count _closeConstructions > 0 && {player distance2D (_closeConstructions select 0) < 3}) then {
        _construction = _closeConstructions select 0;
    };
};

if(isNil "_construction" || {isNull _construction}) exitWith {
    closeDialog 0;
};

private _buildingIndex = constructionsToSave find _construction;

if (_buildingIndex == -1) exitWith {
    [localize "STR_antistasi_dialogs_construction_removal_title", localize "STR_antistasi_dialogs_construction_removal_no_valid_construction"] call SCRT_fnc_misc_deniedHint;
    closeDialog 0;
};
3. Confirmation Dialog:

Sqf

Apply
createDialog "constructionRemovalConfirmation";

private _display = findDisplay 123;

if (str (_display) != "no display") then {
    private _childControl = _display displayCtrl 1244;
    private _name = getText (configFile >> "CfgVehicles" >> typeOf _construction >> "displayName");
    _childControl ctrlSetText format ["%1 (%2)?",localize "STR_antistasi_dialogs_remove_construction", _name];
};

waitUntil {(!dialog) || {!isNil "removeConstruction"}};
if ((!dialog) && {isNil "removeConstruction"}) exitWith {
    closeDialog 0;
};

removeConstruction = nil;
4. Execute Removal:

Sqf

Apply
[_construction] remoteExecCall ["SCRT_fnc_build_removeConstruction", 2];

sleep 0.5;

[localize "STR_antistasi_dialogs_construction_removal_title", localize "STR_antistasi_dialogs_construction_removal_success"] call A3A_fnc_customHint;
playSound "A3AP_UiSuccess";
closeDialog 0;
closeDialog 0;
Where it leads:
Functions Called:

A3A_fnc_isEngineer - Checks engineer trait
SCRT_fnc_misc_deniedHint - Shows denial message
BIS_fnc_sortBy - Sorts constructions by distance
SCRT_fnc_build_removeConstruction - Removes construction (server 2)
A3A_fnc_customHint - Shows success message
Global Variables Modified:

removeConstruction (confirmation flag)
Dependencies:

Requires constructionsToSave array
Requires construction removal dialog (123)
Requires control 1244
Requires engineer trait
Used By:

Construction removal button
fn_ui_recruitGarrisonEventHandler.sqf
File: A3A/addons/scrt/UI/fn_ui_recruitGarrisonEventHandler.sqf Line Count: 45 lines

Function: [mode] call SCRT_fnc_ui_recruitGarrisonEventHandler;
What it does:
Handles map clicks for recruiting garrison units.

How it does that:
Sqf

Apply
params ["_mode"];

if(_mode == "ADD") then {
    [
        "recruitGarrison",
        "onMapSingleClick",
        {
            playSound "readoutClick";

            private _site = [markersX, _pos] call BIS_fnc_nearestPosition;
            if (getMarkerPos _site distance _pos > 25) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_antistasi_journal_entry_header_AI_1",  
                    parseText (localize "STR_notifiers_disband_click"), 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            private _side = sidesX getVariable [_site, sideUnknown];
            if (_side != teamPlayer) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_antistasi_journal_entry_header_AI_1",  
                    parseText format [localize "STR_notifiers_disband_not_belong", A3A_faction_reb get "name"], 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            if ([_positionX] call A3A_fnc_enemyNearCheck) exitWith {
                [
                    localize "STR_notifiers_fail_type",
                    localize "STR_antistasi_journal_entry_header_AI_1",  
                    parseText (localize "STR_notifiers_disband_enemies_nearby"), 
                    30
                ] spawn SCRT_fnc_ui_showMessage;
            };

            ["add", _site] spawn A3A_fnc_garrisonDialog;
        },
        []
    ] call BIS_fnc_addStackedEventHandler;
} else {
    ["recruitGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
}
Click must be within 25m of marker
Site must be owned by rebels
No enemies nearby
Opens garrison dialog with "add" mode
Where it leads:
Functions Called:

SCRT_fnc_ui_showMessage - Shows error messages
A3A_fnc_enemyNearCheck - Checks for enemies
A3A_fnc_garrisonDialog - Opens garrison dialog
Global Variables Modified:

None (handler is local)
Dependencies:

Same as disband handler
Used By:

fn_ui_setRecruitMode - Activates handler
fn_ui_setAssignRivalsAttackLocationMode.sqf
File: A3A/addons/scrt/UI/fn_ui_setAssignRivalsAttackLocationMode.sqf Line Count: 55 lines

Function: [] call SCRT_fnc_ui_setAssignRivalsAttackLocationMode;
What it does:
Validates conditions and activates Rivals attack location assignment mode.

How it does that:
1. Task Validation:

Sqf

Apply
if ("RIV_ATT" in A3A_activeTasks) exitWith {
    // Error: already has Rivals attack task
};

if ("DEF_HQ" in A3A_activeTasks) exitWith {
    // Error: HQ defense in progress
};

if ("invaderPunish" in A3A_activeTasks) exitWith {
    // Error: invader punishment in progress
};

if (bigAttackInProgress) exitWith {
    // Error: big attack in progress
};
2. Location Validation:

Sqf

Apply
private _locationsCount = count ([] call SCRT_fnc_rivals_getLocations);
if (_locationsCount == 0) exitWith {
    // Error: no targets available
};
3. Activate Mode:

Sqf

Apply
[] call SCRT_fnc_ui_showRivalsActivity;
["ADD"] call SCRT_fnc_ui_assignRivalsAttackLocationEventHandler;

[
    localize "STR_notifiers_info_type",
    (localize "STR_antistasi_rivals_destroy_hideoutcell_header"),  
    parseText (localize "STR_antistasi_rivals_destroy_hideoutcell_start_text"), 
    60
] spawn SCRT_fnc_ui_showMessage;
Where it leads:
Functions Called:

SCRT_fnc_rivals_getLocations - Gets rival locations
SCRT_fnc_ui_showRivalsActivity - Shows activity visualization
SCRT_fnc_ui_assignRivalsAttackLocationEventHandler - Activates handler
SCRT_fnc_ui_showMessage - Shows instructions
Global Variables Modified:

None
Dependencies:

Requires A3A_activeTasks array
Requires bigAttackInProgress boolean
Requires rivalsLocationsMap
Requires areRivalsDiscovered
Used By:

Commander menu Rivals tab attack button
fn_ui_setAvailableBuildingTypes.sqf
File: A3A/addons/scrt/UI/fn_ui_setAvailableBuildingTypes.sqf Line Count: 56 lines

Function: [] call SCRT_fnc_ui_setAvailableBuildingTypes;
What it does:
Populates construction combobox based on selected construction type.

How it does that:
1. Get Construction Type:

Sqf

Apply
private _display = findDisplay 80000;
private _buildingTypeCombobox = _display displayCtrl 505;
private _index = lbCurSel _buildingTypeCombobox;
private _constructionType = _buildingTypeCombobox lbData _index;
2. Lookup Arrays:

Sqf

Apply
switch(_constructionType) do {
    case("TRENCH"): {
        _shopLookupArray = ["Land_BagFence_Corner_F", "Land_BagFence_End_F", "Land_BagFence_Long_F", "Land_BagFence_Round_F", "Land_BagFence_Short_F", "Land_SandbagBarricade_01_half_F", "Land_SandbagBarricade_01_hole_F", "Land_SandbagBarricade_01_F"];
    };
    case("OBSTACLE"): {
        _shopLookupArray = ["Land_CzechHedgehog_01_new_F", "Land_Razorwire_F"];
    };
    case("LIGHT_BUNKER"): {
        _shopLookupArray = ["Land_BagBunker_Large_F", "Land_BagBunker_Small_F", "Land_GuardBox_01_brown_F"];
    };
    case("HEAVY_BUNKER"): {
        _shopLookupArray = ["Land_Bunker_02_light_double_F"];
    };
    case("MISC"): {
        _shopLookupArray = ["Land_HelipadCircle_F", "Land_HelipadSquare_F", "Land_u_Addon_01_V1_F"];
    };
};
3. Populate Second Combobox:

Sqf

Apply
private _buildingCombobox = _display displayCtrl 506;
lbClear _buildingCombobox;

private _fillCombo = {
    params ["_buildings", "_comboBox"];

    {
        private _name = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
        _comboBox lbAdd _name;
        _comboBox lbSetData [_forEachIndex, _x];
    } forEach _buildings;
};

[_shopLookupArray, _buildingCombobox] call _fillCombo;

_buildingCombobox lbSetCurSel 0;
Where it leads:
Functions Called:

_fillCombo - Populates combobox
Global Variables Modified: None

Dependencies:

Requires display 80000
Requires controls 505 and 506
Used By:

Construction menu type combobox onChange event
fn_ui_setBuildTypeCostText.sqf
File: A3A/addons/scrt/UI/fn_ui_setBuildTypeCostText.sqf Line Count: 33 lines

Function: [] call SCRT_fnc_ui_setBuildTypeCostText;
What it does:
Updates cost display based on selected construction type.

How it does that:
Sqf

Apply
private _costTextBox = _display displayCtrl 510;
private _comboBox = _display displayCtrl 505;
private _index = lbCurSel _comboBox;
private _buildType = _comboBox lbData _index;

switch (_buildType) do {
    case ("TRENCH"): {
        _costTextBox ctrlSetText format ["%1: 100%2", _costLocalized, A3A_faction_civ get "currencySymbol"];
    };
    case ("OBSTACLE"): {
        _costTextBox ctrlSetText format ["%1: 250%2", _costLocalized, A3A_faction_civ get "currencySymbol"];
    };
    case ("LIGHT_BUNKER"): {
        _costTextBox ctrlSetText format ["%1: 1000%2", _costLocalized, A3A_faction_civ get "currencySymbol"];
    };
    case ("HEAVY_BUNKER"): {
        _costTextBox ctrlSetText format ["%1: 2000%2", _costLocalized, A3A_faction_civ get "currencySymbol"];
    };
    case ("MISC"): {
        _costTextBox ctrlSetText format ["%1: 50%2", _costLocalized, A3A_faction_civ get "currencySymbol"];
    };
};
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires display 80000
Requires controls 505 and 510
Requires A3A_faction_civ with currencySymbol key
Used By:

Construction menu type combobox onChange event
fn_ui_setDisbandMode.sqf
File: A3A/addons/scrt/UI/fn_ui_setDisbandMode.sqf Line Count: 12 lines

Function: [] call SCRT_fnc_ui_setDisbandMode;
What it does:
Activates disband garrison mode.

How it does that:
Sqf

Apply
["disbandGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["establishOutpost", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["minefieldMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["recruitGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["ADD"] call SCRT_fnc_ui_disbandGarrisonEventHandler;

[
    localize "STR_notifiers_info_type",
    localize "STR_notifiers_disband_header",  
    parseText (localize "STR_notifiers_disband_tip"), 
    60
] spawn SCRT_fnc_ui_showMessage;
Where it leads:
Functions Called:

All other event handlers (remove)
SCRT_fnc_ui_disbandGarrisonEventHandler (add)
SCRT_fnc_ui_showMessage
Global Variables Modified: None

Dependencies:

All event handler functions
Used By:

Garrison tab disband button
fn_ui_setEstablishOutpostMode.sqf
File: A3A/addons/scrt/UI/fn_ui_setEstablishOutpostMode.sqf Line Count: 63 lines

Function: [] call SCRT_fnc_ui_setEstablishOutpostMode;
What it does:
Validates and activates outpost establishment mode.

How it does that:
1. Cost Validation:

Sqf

Apply
private _moneyCost = outpostCost select 0;
private _hrCost = outpostCost select 1;

private _resourcesFIA = server getVariable "resourcesFIA";
private _hrFIA = server getVariable "hr";

if ((_resourcesFIA < _moneyCost) or {_hrFIA < _hrCost}) exitWith {
    // Error: not enough resources
};
2. Task Validation:

Sqf

Apply
if ("outpostTask" in A3A_activeTasks) exitWith {
    // Error: only one outpost at a time
};
3. Radio Validation:

Sqf

Apply
if (!([player] call A3A_fnc_hasRadio)) exitWith {
    // Error: need radio
};
4. War Level Validation:

Sqf

Apply
if (outpostType in ["ROADBLOCK", "HMG"] && {tierWar < 3}) exitWith {
    // Error: need war level 3
};

if (outpostType in ["AA", "AT"] && {tierWar < 4}) exitWith {
    // Error: need war level 4
};
5. Activate Mode:

Sqf

Apply
["disbandGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["establishOutpost", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["minefieldMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["recruitGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["ADD"] call SCRT_fnc_ui_establishOutpostEventHandler;

[
    localize "STR_notifiers_info_type",
    localize "STR_notifiers_trader_establish_outpost_header",  
    parseText (localize "STR_notifiers_establish_success"), 
    60
] spawn SCRT_fnc_ui_showMessage;
Where it leads:
Functions Called:

A3A_fnc_hasRadio - Checks for radio
All other event handlers (remove)
SCRT_fnc_ui_establishOutpostEventHandler (add)
SCRT_fnc_ui_showMessage
Global Variables Modified: None

Dependencies:

Requires outpostCost, outpostType
Requires resourcesFIA, hr
Requires teamPlayer side
Used By:

Outpost tab establish button
fn_ui_setMinefieldCost.sqf
File: A3A/addons/scrt/UI/fn_ui_setMinefieldCost.sqf Line Count: 41 lines

Function: [] call SCRT_fnc_ui_setMinefieldCost;
What it does:
Calculates and displays minefield cost.

How it does that:
1. Get Minefield Type:

Sqf

Apply
private _costTextBox = _display displayCtrl 2761;
private _comboBox = _display displayCtrl 2758;
private _index = lbCurSel _comboBox;
private _minefieldType = lbData [2758, _index];

minefieldType = _minefieldType;
2. Check Mine Availability:

Sqf

Apply
private _pool = jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT;
private _minePool = [AllMinesAPERS, AllMinesAT] select (_minefieldType isEqualTo "ATMine");

private _availableMinesPool = _pool select { 
    private _className = _x select 0;
    private _quantity = _x select 1;
    _className in _minePool && {_quantity >= 5 || {_quantity isEqualTo -1}};
};

if (count _availableMinesPool < 1) then {
    _quantity = 0;
} else {
    _mine = selectRandom (_availableMinesPool apply {_x select 0});
    private _mineQuantity = (_availableMinesPool select {(_x select 0) == _mine }) apply {_x select 1};
    _quantity = _mineQuantity select 0;
};
3. Calculate Costs:

Sqf

Apply
_costs = (2*(server getVariable (A3A_faction_reb get "unitExp"))) + ([(A3A_faction_reb get "vehiclesTruck") # 0] call A3A_fnc_vehiclePrice);
_hr = 2;
_costTextBox ctrlSetText format [localize "STR_commander_menu_minefield_cost", minefieldType, _hr, _costs, A3A_faction_civ get "currencySymbol"];

minefieldCost = [_costs, _hr, _quantity, _mine];
Where it leads:
Functions Called:

A3A_fnc_vehiclePrice - Gets truck price
Global Variables Modified:

minefieldType (global)
minefieldCost (global array)
Dependencies:

Requires jna_dataList (JNA arsenal)
Requires AllMinesAPERS, AllMinesAT
Requires A3A_faction_reb with unitExp, vehiclesTruck keys
Requires A3A_faction_civ with currencySymbol key
Used By:

Minefield combobox onChange event
fn_ui_setMinefieldMode.sqf
File: A3A/addons/scrt/UI/fn_ui_setMinefieldMode.sqf Line Count: 54 lines

Function: [] call SCRT_fnc_ui_setMinefieldMode;
What it does:
Validates and activates minefield placement mode.

How it does that:
1. Cost Validation:

Sqf

Apply
private _moneyCost = minefieldCost select 0;
private _hrCost = minefieldCost select 1;
private _mineQuantity = minefieldCost select 2;

private _resourcesFIA = server getVariable "resourcesFIA";
private _hrFIA = server getVariable "hr";

if ((_resourcesFIA < _moneyCost) or (_hrFIA < _hrCost)) exitWith {
    // Error: not enough resources
};
2. Task Validation:

Sqf

Apply
if ("Mines" in A3A_activeTasks) exitWith {
    // Error: only one minefield at a time
};
3. Radio Validation:

Sqf

Apply
if (!([player] call A3A_fnc_hasRadio)) exitWith {
    // Error: need radio
};
4. Mine Quantity Validation:

Sqf

Apply
if (_mineQuantity < 5 && {_mineQuantity isNotEqualTo -1}) exitWith {
    // Error: need at least 5 mines
};
5. Activate Mode:

Sqf

Apply
["disbandGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["establishOutpost", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["minefieldMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["recruitGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["ADD"] call SCRT_fnc_ui_minefieldEventHandler;

[
    localize "STR_notifiers_info_type",
    localize "STR_notifiers_minefield_header",
    parseText (localize "STR_notifiers_minefield_click"), 
    60
] spawn SCRT_fnc_ui_showMessage;
Where it leads:
Functions Called:

A3A_fnc_hasRadio - Checks for radio
All other event handlers (remove)
SCRT_fnc_ui_minefieldEventHandler (add)
SCRT_fnc_ui_showMessage
Global Variables Modified: None

Dependencies:

Requires minefieldCost, minefieldType
Requires resourcesFIA, hr
Requires teamPlayer side
Used By:

Minefield tab place button
fn_ui_setRebuildAssetMode.sqf
File: A3A/addons/scrt/UI/fn_ui_setRebuildAssetMode.sqf Line Count: 11 lines

Function: [] call SCRT_fnc_ui_setRebuildAssetMode;
What it does:
Activates HQ asset rebuild mode.

How it does that:
Sqf

Apply
#define COST 5000

["hqMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["ADD"] call SCRT_fnc_ui_hqTabEventHandler;

[
    localize "STR_notifiers_info_type",
    localize "STR_notifiers_rebuild_assets_header",  
    parseText format [(localize "STR_notifiers_rebuild_assets_info"), str COST, A3A_faction_civ get "currencySymbol"], 
    60
] spawn SCRT_fnc_ui_showMessage;
Where it leads:
Functions Called:

SCRT_fnc_ui_hqTabEventHandler (add)
SCRT_fnc_ui_showMessage
Global Variables Modified: None

Dependencies:

Requires 5000 resources
Used By:

HQ tab rebuild button
fn_ui_setRecruitMode.sqf
File: A3A/addons/scrt/UI/fn_ui_setRecruitMode.sqf Line Count: 12 lines

Function: [] call SCRT_fnc_ui_setRecruitMode;
What it does:
Activates garrison recruitment mode.

How it does that:
Sqf

Apply
["disbandGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["establishOutpost", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["minefieldMap", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["recruitGarrison", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;
["ADD"] call SCRT_fnc_ui_recruitGarrisonEventHandler;

[
    localize "STR_notifiers_info_type",
    localize "STR_antistasi_journal_entry_header_AI_1",  
    parseText (localize "STR_notifiers_friendly_outpost_recruit"), 
    60
] spawn SCRT_fnc_ui_showMessage;
Where it leads:
Functions Called:

All other event handlers (remove)
SCRT_fnc_ui_recruitGarrisonEventHandler (add)
SCRT_fnc_ui_showMessage
Global Variables Modified: None

Dependencies:

All event handler functions
Used By:

Garrison tab recruit button
fn_ui_setSupportCostText.sqf
File: A3A/addons/scrt/UI/fn_ui_setSupportCostText.sqf Line Count: 64 lines

Function: [] call SCRT_fnc_ui_setSupportCostText;
What it does:
Updates support cost display and handles paradrop zones.

How it does that:
1. Get Support Type:

Sqf

Apply
private _costTextBox = _display displayCtrl 1751;
private _comboBox = _display displayCtrl 1750;
private _index = lbCurSel _comboBox;
private _supportType =  lbData [1750, _index];

supportType = _supportType;
2. Update Cost Text:

Sqf

Apply
switch (supportType) do {
    case ("SUPPLY");
    case ("SMOKE");
    case ("FLARE");
    case ("RECON"): {
        _costTextBox ctrlSetText format [localize "STR_commander_menu_abilities_cost_support_point", 1];
    };
    case ("VEH_AIRDROP"): {
        _costTextBox ctrlSetText format [localize "STR_commander_menu_abilities_cost_support_point_and_money", 1, 200, A3A_faction_civ get "currencySymbol"];
    };
    // ... other cases
};
3. Paradrop Forbidden Zones:

Sqf

Apply
if (supportType == "PARADROP") then {
    private _markersX = markersX select {sidesX getVariable [_x,sideUnknown] != teamPlayer};
    _markersX = _markersX - controlsX;

    forbiddenParadropZones = [];

    {
        private _localMarker = createMarkerLocal [format ["%1forbiddenzone", count forbiddenParadropZones], getMarkerPos _x];
        _localMarker setMarkerShapeLocal "ELLIPSE";
        _localMarker setMarkerSizeLocal [500,500];
        _localMarker setMarkerTypeLocal "hd_warning";
        _localMarker setMarkerColorLocal "ColorRed";
        _localMarker setMarkerBrushLocal "DiagGrid";
        forbiddenParadropZones pushBack _localMarker;
    } forEach _markersX;
} else { 
    if (!isNil "forbiddenParadropZones") then {
        {deleteMarkerLocal _x} forEach forbiddenParadropZones;
    };
};

if (supportType != "LOOTHELI" && {getMarkerColor "LootHeliAreaMarker" != ""}) then {
    deleteMarkerLocal "LootHeliAreaMarker";
};
Where it leads:
Functions Called: None

Global Variables Modified:

supportType (global)
forbiddenParadropZones (local markers)
LootHeliAreaMarker (deleted if needed)
Dependencies:

Requires display 60000
Requires controls 1750 and 1751
Requires markersX, controlsX, sidesX
Requires teamPlayer
Used By:

Support combobox onChange event
fn_ui_showDynamicTextMessage.sqf
File: A3A/addons/scrt/UI/fn_ui_showDynamicTextMessage.sqf Line Count: 31 lines

Function: [header, text, severity, duration] spawn SCRT_fnc_ui_showDynamicTextMessage;
What it does:
Shows dynamic text message on screen.

How it does that:
1. Format Text:

Sqf

Apply
switch (_severity) do {
    case (localize "STR_notifiers_info_type"): {
        _finalText = format ["<t size='0.6' color='#f0d498'>%1</t><br/><t size='0.5'>%2</t>", _header, _text];
    };
    case (localize "STR_notifiers_warning_type"): {
        playSound "A3AP_UiFailure";
        _finalText = format ["<t size='0.6' color='#f0d498'>%1</t><br/><t size='0.5'>%2</t>", _header, _text];
    };
    case (localize "STR_notifiers_fail_type"): {
        playSound "A3AP_UiFailure";
        _finalText = format ["<t size='0.6' color='#e60000'>%1</t><br/><t size='0.5'>%2</t>", _header, _text];
    };
    case (localize "STR_notifiers_success_type"): {
        playSound "A3AP_UiSuccess";
        _finalText = format ["<t size='0.6' color='#00cc00'>%1</t><br/><t size='0.5'>%2</t>", _header, _text];
    };
};
2. Create/Use Layer:

Sqf

Apply
if (isNil "dynamicTextMessageLayer") then {
    dynamicTextMessageLayer = ["dynamicTextMessage"] call BIS_fnc_rscLayer;
};

[_finalText, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], -0.15, _duration, 0, 0, dynamicTextMessageLayer] spawn bis_fnc_dynamicText;
Where it leads:
Functions Called:

BIS_fnc_rscLayer - Creates layer
bis_fnc_dynamicText - Shows text
Global Variables Modified:

dynamicTextMessageLayer (global)
Dependencies:

None
Used By:

Various UI functions for notifications
fn_ui_showMessage.sqf
File: A3A/addons/scrt/UI/fn_ui_showMessage.sqf Line Count: 42 lines

Function: [_severity, _header, _message, _time, _displayId] spawn SCRT_fnc_ui_showMessage;
What it does:
Shows message in commander menu notification area.

How it does that:
1. Get Display Controls:

Sqf

Apply
private _display = findDisplay _displayId;
private _title = _display displayCtrl 1055;
private _text = _display displayCtrl 1056;
2. Set Color and Sound:

Sqf

Apply
switch (true) do {
    case (_severity isEqualTo (localize "STR_notifiers_info_type")): {
        _title ctrlSetTextColor [0,0,1,1];
    };
    case (_severity isEqualTo (localize "STR_notifiers_fail_type")): {
        playSound "A3AP_UiFailure";
        _title ctrlSetTextColor [0.9,0,0,1];
    };
    case (_severity isEqualTo (localize "STR_notifiers_success_type")): {
        playSound "A3AP_UiSuccess";
        _title ctrlSetTextColor [0,0.8,0,1];
    };
};
3. Set Text:

Sqf

Apply
_title ctrlSetText _header;
_text ctrlSetStructuredText _message; 
4. Fade In:

Sqf

Apply
{
    _x ctrlSetFade 0;
    _x ctrlCommit 0.3;
} forEach [_title, _text];
5. Fade Out:

Sqf

Apply
waitUntil {time > _timeOut};

{
    _x ctrlSetFade 1;
    _x ctrlCommit 10;
} forEach [_title, _text];
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires display with controls 1055 and 1056
Used By:

All UI validation and error messages
fn_ui_showRivalsActivity.sqf
File: A3A/addons/scrt/UI/fn_ui_showRivalsActivity.sqf Line Count: 49 lines

Function: [] call SCRT_fnc_ui_showRivalsActivity;
What it does:
Visualizes Rivals activity zones on the map.

How it does that:
1. Clear Previous:

Sqf

Apply
[] call SCRT_fnc_ui_clearRivals;

visibleRivalsMarkers = [];
2. Known Locations:

Sqf

Apply
private _knownLocations = ["KNOWN"] call SCRT_fnc_rivals_getLocations;
private _radiusOfOperations = call SCRT_fnc_rivals_getOperationRadius;

{
    private _localMarkerArea = createMarkerLocal [format ["%1rivalsradius%2", random 10000, random 10000], getMarkerPos _x]; 
    _localMarkerArea setMarkerShapeLocal "ELLIPSE"; 
    _localMarkerArea setMarkerSizeLocal [_radiusOfOperations,_radiusOfOperations]; 
    _localMarkerArea setMarkerTypeLocal "hd_warning"; 
    _localMarkerArea setMarkerColorLocal colorRivals; 
    _localMarkerArea setMarkerBrushLocal "BDiagonal"; 
    visibleRivalsMarkers pushBack _localMarkerArea; 

    private _localMarker = createMarkerLocal [format ["%1rivalsmarker%2", random 10000, random 10000], getMarkerPos _x];
    _localMarker setMarkerSizeLocal [1,1];
    _localMarker setMarkerAlpha 1; 
    _localMarker setMarkerTypeLocal "hd_flag";
    _localMarker setMarkerColorLocal "ColorRed";
    visibleRivalsMarkers pushBack _localMarker;
} forEach _knownLocations;
3. Questionable Locations:

Sqf

Apply
private _questionableLocations = (citiesX + (controlsX select {!(isOnRoad getMarkerPos _x)})) select {!(_x in _knownLocations) && {!(_x in rivalsExcludedLocations)}};

{
    private _localMarkerArea = createMarkerLocal [format ["%1rivalsunknownradius%2", random 10000, random 10000], getMarkerPos _x]; 
    _localMarkerArea setMarkerShapeLocal "ELLIPSE"; 
    _localMarkerArea setMarkerSizeLocal [_radiusOfOperations,_radiusOfOperations]; 
    _localMarkerArea setMarkerTypeLocal "hd_warning"; 
    _localMarkerArea setMarkerColorLocal colorRivals; 
    _localMarkerArea setMarkerBrushLocal "BDiagonal"; 
    visibleRivalsMarkers pushBack _localMarkerArea; 

    private _localMarker = createMarkerLocal [format ["%1rivalsunknownmarker%2", random 10000, random 10000], getMarkerPos _x];
    _localMarker setMarkerSizeLocal [1,1];
    _localMarker setMarkerAlpha 1; 
    _localMarker setMarkerTypeLocal "hd_unknown";
    _localMarker setMarkerColorLocal colorRivals;
    visibleRivalsMarkers pushBack _localMarker;
} forEach _questionableLocations;
4. Notification:

Sqf

Apply
[
    localize "STR_notifiers_info_type",
    format [(localize "STR_antistasi_rivals_show_activity_title"), A3A_faction_riv get "name"],
    parseText (localize "STR_antistasi_rivals_show_activity_hint"), 
    10
] spawn SCRT_fnc_ui_showMessage;
Where it leads:
Functions Called:

SCRT_fnc_ui_clearRivals - Clears previous markers
SCRT_fnc_rivals_getLocations - Gets known locations
SCRT_fnc_rivals_getOperationRadius - Gets radius
SCRT_fnc_ui_showMessage - Shows notification
Global Variables Modified:

visibleRivalsMarkers (global array of local markers)
Dependencies:

Requires rivalsLocationsMap
Requires rivalsExcludedLocations
Requires citiesX, controlsX
Requires colorRivals color
Requires A3A_faction_riv with name key
Used By:

fn_ui_setAssignRivalsAttackLocationMode - To show locations
Rivals tab "Show Activity" button
fn_ui_switchButton.sqf
File: A3A/addons/scrt/UI/fn_ui_switchButton.sqf Line Count: 53 lines

Function: [table, idc, change, action] call SCRT_fnc_ui_switchButton;
What it does:
Toggles a switch button (on/off) and optionally executes an action.

How it does that:
1. Get Lookup:

Sqf

Apply
params ["_table", "_idc", ["_change", true], ["_action", "NONE"]];	
private _optionData = [_table, _idc] call SCRT_fnc_ui_getSwitchLookup;

private _varStr = (_optionData select 0);
private _currentValue = (_optionData select 1);	
private _allValues = (_optionData select 2);
2. Calculate New Value:

Sqf

Apply
if (_change) then {
    switch (true) do {
        case(_currentValue isEqualType true): {
            _newValue = !_currentValue;
            _representation = if(_newValue) then {_allValues select 0} else {_allValues select 1};
        };  
    };

    missionNamespace setVariable [_varStr, _newValue];
    ctrlSetText [(_idc + 3), _representation];

    // Execute actions
    if (_action isEqualTo "MUSIC") exitWith {call A3A_fnc_music;};
    if (_action isEqualTo "PARADROP") exitWith {
        if (isPlayerParadropable) then {
            // Add to attendants
        } else {
            // Remove from attendants
        };
    };
    if (_action isEqualTo "UNIFORMRANDOMIZE") exitWith {
        publicVariable "randomizeRebelLoadoutUniforms";
    };
} else {
    _representation = if(_currentValue) then {_allValues select 0} else {_allValues select 1};
    ctrlSetText [(_idc + 3), _representation];
};
Where it leads:
Functions Called:

SCRT_fnc_ui_getSwitchLookup - Gets variable info
A3A_fnc_music - If music action
Global Variables Modified:

Variable from lookup (e.g., musicON, isPlayerParadropable, randomizeRebelLoadoutUniforms)
paradropAttendants (via server variable)
Dependencies:

Requires lookup function
Requires control at idc + 3 to exist
Used By:

Switch button click events
fn_ui_toggleCommanderMenu.sqf
File: A3A/addons/scrt/UI/fn_ui_toggleCommanderMenu.sqf Line Count: 29 lines

Function: [] call SCRT_fnc_ui_toggleCommanderMenu;
What it does:
Toggles commander/rebel menu open/close.

How it does that:
1. If Open:

Sqf

Apply
if (isMenuOpen) then {
    closeDialog 0;
    closeDialog 0;
    isMenuOpen = false;
    [] call SCRT_fnc_ui_dispose;
};
2. If Closed:

Sqf

Apply
if(player isEqualTo theBoss) then {
    closeDialog 0;
    closeDialog 0;
    createDialog "commanderMenu";
    [] call SCRT_fnc_ui_populateCommanderMenu;
    isMenuOpen = true;
} else {
    closeDialog 0;
    closeDialog 0;
    createDialog "rebelMenu";
    [] call SCRT_fnc_ui_populateRebelMenu;
    isMenuOpen = true;
};
3. Camera:

Sqf

Apply
if (vehicle player isEqualTo player) then {
    [] spawn SCRT_fnc_misc_orbitingCamera;
} else {
    [] spawn SCRT_fnc_misc_followCamera;
};
Where it leads:
Functions Called:

SCRT_fnc_ui_dispose - Cleans up on close
SCRT_fnc_ui_populateCommanderMenu - Sets up commander menu
SCRT_fnc_ui_populateRebelMenu - Sets up rebel menu
SCRT_fnc_misc_orbitingCamera - Orbiting camera
SCRT_fnc_misc_followCamera - Follow camera
Global Variables Modified:

isMenuOpen (global)
Dependencies:

Requires theBoss variable
Requires dialog definitions
Used By:

Menu toggle hotkey or button
fn_ui_toggleMenuBlur.sqf
File: A3A/addons/scrt/UI/fn_ui_toggleMenuBlur.sqf Line Count: 17 lines

Function: [mode] call SCRT_fnc_ui_toggleMenuBlur;
What it does:
Toggles screen blur effect when menu is open.

How it does that:
Sqf

Apply
params ["_mode"];

switch (_mode) do {
    case ("on"): {
        if (isNil "dialog_blur_gui_blur") then {
            dialog_blur = ppEffectCreate ["DynamicBlur", 999];
            dialog_blur ppEffectEnable true;
        };

        dialog_blur ppEffectAdjust [8];
        dialog_blur ppEffectCommit 0.2;
    };
    case ("off"): {
        dialog_blur ppEffectAdjust [0];
        dialog_blur ppEffectCommit 0.3;
    };
};
Where it leads:
Functions Called: None

Global Variables Modified:

dialog_blur (ppEffect)
Dependencies:

Post-process effects enabled
Used By:

Menu open/close events
fn_ui_updateSupportMenu.sqf
File: A3A/addons/scrt/UI/fn_ui_updateSupportMenu.sqf Line Count: 30 lines

Function: [] call SCRT_fnc_ui_updateSupportMenu;
What it does:
Updates support counters in commander menu.

How it does that:
Sqf

Apply
private _display = findDisplay 60000;

if (str (_display) != "no display") then {
    private _supportControl = _display displayCtrl 1702;
    _supportControl ctrlSetText format [(localize "STR_commander_menu_abilities_available_supports" + " %1" + "/%2"), supportPoints, maxSupportPoints];

    if (supportPoints < 1) {
        _supportControl ctrlSetTextColor [1, 0, 0, 1];
    };

    private _airstrikesControl = _display displayCtrl 1703;
    _airstrikesControl ctrlSetText format [
        (localize "STR_commander_menu_abilities_available_airstrikes" + " %1" + "/%2"), 
        (floor bombRuns), 
        (({sidesX getVariable [_x,sideUnknown] == teamPlayer} count airportsX) * 2)
    ];

    if (bombRuns < 1) {
        _airstrikesControl ctrlSetTextColor [1, 0, 0, 1];
    };

    private _airportsControl = _display displayCtrl 1704;
    private _airports = { sidesX getVariable [_x, sideUnknown] isEqualTo teamPlayer } count airportsX;
    _airportsControl ctrlSetText format [(localize "STR_commander_menu_abilities_captured_airports" + " %1" + "/%2"), _airports, (count airportsX)];

    if (_airports < 1) {
        _airportsControl ctrlSetTextColor [1, 0, 0, 1];
    };
};
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires display 60000
Requires controls 1702, 1703, 1704
Requires supportPoints, maxSupportPoints, bombRuns
Requires airportsX, sidesX, teamPlayer
Used By:

fn_ui_populateCommanderMenu - Initial setup
fn_ui_launchSupport - After support launch
Any function that updates support resources
fn_unit_flattenTier.sqf
File: A3A/addons/scrt/Unit/fn_unit_flattenTier.sqf Line Count: 33 lines

Function: [_faction, _key, _forceTier] call SCRT_fnc_unit_flattenTier;
What it does:
Extracts tiered group array for current war level.

How it does that:
Sqf

Apply
params [
    ["_faction", createHashMap, [createHashMap]], 
    ["_key", "", [""]],
    ["_forceTier", -1, [0]]
];

(_faction get _key) apply {[_x, _forceTier] call SCRT_fnc_unit_getTiered}
Gets tiered array from faction
Applies fn_unit_getTiered to each entry
Where it leads:
Functions Called:

SCRT_fnc_unit_getTiered - Extracts specific tier
Global Variables Modified: None

Dependencies:

Requires faction hash map with tiered arrays
Used By:

Various faction-based spawning functions
fn_unit_getTiered.sqf
File: A3A/addons/scrt/Unit/fn_unit_getTiered.sqf Line Count: 71 lines

Function: [_tieredArray, _forceTier] call SCRT_fnc_unit_getTiered;
What it does:
Extracts unit/group from tiered array based on war level.

How it does that:
1. Forced Tier:

Sqf

Apply
if (_forceTier != -1) exitWith {
    _tieredArray select _forceTier
};
2. Plus Garrison Mode:

Sqf

Apply
if (plusGarrison) exitWith {
    switch (true) do {
        case (tierWar < 5): { _tieredArray select 0 };
        case (tierWar < 8 && {tierWar > 4}): { _tieredArray select 1 };
        case (tierWar > 7): { _tieredArray select 2 };
        default { _tieredArray select 0 };
    };
};
3. Standard Mode:

Sqf

Apply
private _militia = missionNamespace getVariable ["A3U_setting_tierWarMilitia", 3];
private _elite = missionNamespace getVariable ["A3U_setting_tierWarElite", 8];

switch (true) do {
    case (tierWar >= _elite): {
        _tieredArray select 2
    };
    case (tierWar >= (_militia + 1)): {
        _tieredArray select 1
    };
    case (tierWar <= _militia): {
        _tieredArray select 0
    };
    default {
        _tieredArray select 0
    };
};
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires plusGarrison boolean
Requires tierWar
Requires A3U_setting_tierWarMilitia, A3U_setting_tierWarElite
Used By:

fn_unit_flattenTier
Various faction-based unit selection
fn_unit_getUnitMap.sqf
File: A3A/addons/scrt/Unit/fn_unit_getUnitMap.sqf Line Count: 186 lines

Function: [_side] call SCRT_fnc_unit_getUnitMap;
What it does:
Returns a hash map of unit class names for a given side.

How it does that:
Sqf

Apply
private _side = _this;

private _unitClassMap = switch (_side) do {
    case west: { 
        createHashMapFromArray [
            ["militia_SquadLeader", "B_Soldier_SL_F"],
            ["militia_Rifleman", "B_Soldier_F"],
            // ... all unit types for west
        ];
    };
    case east: { 
        createHashMapFromArray [
            ["militia_SquadLeader", "O_Soldier_SL_F"],
            // ... all unit types for east
        ];
    };
    case independent: {
        createHashMapFromArray [
            ["militia_Unarmed", "a3a_unit_reb_unarmed"],
            ["militia_Rifleman", "a3a_unit_reb"],
            // ... all rebel unit types
        ];
    };
    case civilian: {
        createHashMapFromArray [
            ["militia_Worker", "C_man_w_worker_F"],
            // ... civilian types
        ];
    };
};

_unitClassMap
Where it leads:
Functions Called: None

Global Variables Modified: None

Dependencies:

Requires unit class definitions to exist
Used By:

Faction compatibility loading functions
Unit spawning functions