Function: fn_addBlackMarketVeh.sqf
Function Name: 
fn_addBlackMarketVeh.sqf

What it does:
This function manages the purchase of vehicles from the Black Market (trader) interface. It handles resource validation (checking player/faction money), distance checks, and initiates the vehicle placement process (either directly adding to the garage or triggering a placement confirmation dialog). It is designed to handle both standard player purchases and commander (theBoss) purchases using faction funds.

How it does that:
Parameter Validation & Initial Checks:

Validates inputs and checks for active placement states or AI control.
Checks proximity to the trader and enemy presence.
Code Snippet:

Apply
params [
    ["_typeVehX", "", [""]],
    ["_addToGarage", false]
];

if (_typeVehX isEqualTo "") exitWith {[localize "STR_A3A_addFiaVeh_header", localize "STR_A3AP_error_empty_generic"] call A3A_fnc_customHint;};
if (!(isNil "HR_GRG_placing") && {HR_GRG_placing}) exitWith {[localize "STR_A3A_addFiaVeh_header", localize "STR_A3AP_error_already_placing_generic"] call A3A_fnc_customHint;};
if (player != player getVariable ["owner",player]) exitWith {[localize "STR_A3A_addFiaVeh_header", localize "STR_A3AP_error_aicontrol_generic"] call A3A_fnc_customHint;};
if ([getPosATL player] call A3A_fnc_enemyNearCheck) exitWith {[localize "STR_A3A_addFiaVeh_header", localize "STR_A3AP_error_enemynear_generic"] call A3A_fnc_customHint;};
Cost Calculation & Resource Check:

Retrieves the vehicle cost via A3U_fnc_blackMarketVehiclePrice.
Determines available funds based on whether the player is the commander (theBoss). If the commander, it prioritizes using faction funds (resourcesFIA) if sufficient; otherwise, uses personal funds.
Code Snippet:

Apply
private _cost = [_typeVehX] call A3U_fnc_blackMarketVehiclePrice;
private _resourcesFIA = 0;

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

if (_resourcesFIA < _cost) exitWith {
    [localize "STR_A3A_addFiaVeh_header", format [localize "STR_A3AP_error_veh_not_enough_money_generic", _cost, A3A_faction_civ get "currencySymbol"]] call A3A_fnc_customHint;
};
Placement Logic:

If adding directly to garage (_addToGarage true), it calls _fnc_buyVehicle to deduct resources and HR_GRG_fnc_addVehiclesByClass to store the vehicle.
If placing in-world, it sets up callbacks (_fnc_placed, _fnc_check) and calls HR_GRG_fnc_confirmPlacement to initiate the ghost preview system.
Code Snippet (Garage):

Apply
if (_addToGarage) then {
    [_typeVehX, _cost] call _fnc_buyVehicle;
    [[_typeVehX], ""] remoteExecCall ["HR_GRG_fnc_addVehiclesByClass", 2];
} else {
    [_typeVehX, _fnc_placed, _fnc_check, [_cost, _fnc_buyVehicle], nil, nil, nil, _extraMessage] call HR_GRG_fnc_confirmPlacement;
};
Code Snippet (Buy Logic):

Apply
private _fnc_buyVehicle = {
    params ["_vehicle", "_cost"];
    private _factionMoney = server getVariable "resourcesFIA";
    if (player == theBoss && {_cost <= _factionMoney}) then {
        [0,(-1 * _cost)] remoteExec ["A3A_fnc_resourcesFIA",2];
    } else {
        [-1 * _cost] call A3A_fnc_resourcesPlayer;
        if !(_vehicle isEqualType "") then { _vehicle setVariable ["ownerX",getPlayerUID player,true] };
        playSound "A3AP_UiSuccess";
    };
};
Where it leads:
Called Functions:
A3A_fnc_customHint: Displays errors/success messages.
A3A_fnc_enemyNearCheck: Validates safety.
A3U_fnc_blackMarketVehiclePrice: Gets the cost of the specific vehicle class.
A3A_fnc_resourcesFIA: Remote Exec (Server). Deducts money from the faction pool if the commander bought it.
A3A_fnc_resourcesPlayer: Deducts money from the local player's wallet.
HR_GRG_fnc_confirmPlacement: Starts the vehicle placement UI/ghost object logic.
HR_GRG_fnc_addVehiclesByClass: Remote Exec (Server). Adds the vehicle class to the HR Garage persistence system.
HR_GRG_fnc_vehInit: Initialized the placed vehicle (fuel, damage, etc.).
Dependencies: Relies on HR_GRG (High Command Respawn/Garage) system for placement and storage.
Global Variables: Modifies ownerX on the created vehicle. Network sync via remoteExec updates server-side money variables.
System Fit: Part of the economy/persistence system. It bridges the UI (Black Market menu) with the backend resource management and the HR Garage placement engine.
Function: fn_addBombRun.sqf
Function Name: 
fn_addBombRun.sqf

What it does:
Converts a specific type of aircraft into "Bomb Run" credits. The player looks at an aircraft, and if it meets criteria (not owned by another, is a valid enemy type, not a player vehicle), it is deleted and converted into a point value. These points are added to the global bombRuns counter, allowing the commander to call in airstrikes later.

How it does that:
Target Validation:

Checks if the cursor target is valid, alive, and an aircraft (Air kind).
Ensures the player is not near enemies.
Code Snippet:

Apply
_veh = cursortarget;
if (isNull _veh) exitWith { ... };
if (!alive _veh) exitWith { ... };
if ([getPosATL player] call A3A_fnc_enemyNearCheck) exitWith { ... };
if (!(_veh isKindOf "Air")) exitWith { ... };
Ownership & Type Logic:

Verifies the player is near a friendly HQ/Airport.
Checks if the aircraft is a rebel type (in which case, it's rejected).
Checks if the aircraft is currently crewed by players.
Validates the owner variable to prevent stealing enemy vehicles (unless they are abandoned/wreck).
Code Snippet:

Apply
private _rebAircraftTypes = FactionGet(reb,"vehiclesPlane") + ...;
if (typeOf _veh in _rebAircraftTypes) exitWith { ... };
if ({isPlayer _x} count crew _veh > 0) exitWith { ... };

private _owner = _veh getVariable "ownerX";
if (!isNil "_owner" && {_owner isEqualType "" && {_getPlayerUID player != _owner}}) then {
    _exit = true;
};
Calculation & Conversion:

Determines the "point value" based on vehicle class (Helos = 5, Jets = 10).
Deletes the vehicle.
Updates the global bombRuns variable (capped at a limit based on airports owned).
Code Snippet:

Apply
private _pointsX = 1;
if (_typeX in (FactionGet(all,"vehiclesHelisAttack") ...)) then {_pointsX = 5};
if (_typeX in (OccAndInv("vehiclesPlanesCAS") ...)) then {_pointsX = 10};

deleteVehicle _veh;
private _newBombRuns = bombRuns + _pointsX;
if (_newBombRuns > _maxQuantity) then { _newBombRuns = _maxQuantity; };
bombRuns = _newBombRuns;
publicVariable "bombRuns";
[] remoteExec ["A3A_fnc_statistics", theBoss];
Where it leads:
Called Functions:
A3A_fnc_enemyNearCheck: Safety validation.
SCRT_fnc_misc_deniedHint: UI feedback for invalid targets.
A3A_fnc_customHint: Success notification.
A3A_fnc_statistics: Remote Exec. Updates the commander's dashboard to reflect the new bomb run count.
Global Variables:
bombRuns: Modified locally and broadcast via publicVariable.
ownerX: Read from the vehicle object.
System Fit: Part of the High Command/Air Support system. It allows recycling captured or enemy aircraft into a strategic resource (bomb runs) rather than just selling them or using them directly.
Function: fn_addFIAsquadHC.sqf
Function Name: 
fn_addFIAsquadHC.sqf

What it does:
Spawns a High Command (HC) squad or vehicle squad. It handles costs (HR and Money), tier restrictions (war level), and placement (ghost placement or automatic spawn at HQ). It supports infantry groups, vehicle-mounted groups, and static weapon teams.

How it does that:
Prerequisites & Restrictions:

Checks if the player is the commander (theBoss).
Checks for radio availability, HQ safety, and HC group limit.
Checks tier/war level restrictions for specific unit types (e.g., AT squads unavailable until Tier 3).
Code Snippet:

Apply
if (player != theBoss) exitWith { ... };
if (markerAlpha respawnTeamPlayer == 0) exitWith { ... };
if (!([player] call A3A_fnc_hasRadio)) exitWith { ... };
if (tierWar < 3 && {_typeGroup isEqualTo (FactionGet(reb,"groupAT"))}) exitWith { ... };
Cost Calculation:

Handles two input types: Arrays (Infantry groups) or Strings (Vehicle classnames).
Calculates manpower cost (_costHR) and monetary cost (_costs) by looking up server variables.
Code Snippet:

Apply
if (_typeGroup isEqualType []) then {
    { _costs = _costs + (server getVariable _x); _costHR = _costHR +1 } forEach _typeGroup;
} else {
    private _typeCrew = FactionGet(reb,"unitCrew");
    _costs = 2*(server getVariable _typeCrew) + ([_typeGroup] call A3A_fnc_vehiclePrice);
    _costHR = 2;
};
Placement & Spawning:

Determines the vehicle type (_vehType) for non-infantry groups.
If the player is far from HQ, it uses HR_GRG_fnc_confirmPlacement for ghost placement.
If close to HQ, it uses a custom auto-spawn block that handles logistics (mounting static weapons on trucks) and calls A3A_fnc_spawnHCGroup.
For infantry requiring a vehicle, it opens a dialog (vehQuery) to let the player choose between buying a truck or going "barefoot".
Code Snippet (Auto-Spawn with Statics):

Apply
private _vehiclePlacementMethod = if (getMarkerPos respawnTeamPlayer distance player > 50) then {
    { ... HR_GRG_fnc_confirmPlacement ... }
} else {
    {
        private _searchCenter = getMarkerPos respawnTeamPlayer getPos [20 + random 30, random 360];
        private _spawnPos = _searchCenter findEmptyPosition [0, 30, _vehType];
        private _vehicle = _vehType createVehicle _spawnPos;
        if (_mounts isNotEqualTo []) then { ... }; // Handles loading static AA onto truck
        [_formatX, _idFormat, _special, _vehicle] spawn A3A_fnc_spawnHCGroup;
    }
};
Where it leads:
Called Functions:
A3A_fnc_hasRadio: Checks equipment.
A3A_fnc_vehiclePrice: Calculates vehicle cost.
HR_GRG_fnc_confirmPlacement: UI for placing vehicle ghost.
A3A_fnc_spawnHCGroup: Core Spawner. Actually creates the group, units, and assigns them to High Command.
A3A_fnc_resourcesFIA: Remote Exec. Deducts money/HR.
A3A_Logistics_fnc_canLoad/fnc_load: Handles attaching static weapons to trucks.
Global Variables:
vehQuery: Set to nil to signal user choice in the dialog.
bombRuns, staticsToSave (indirectly via spawn).
System Fit: Primary interface for the Commander to reinforce HC groups. It abstracts the complexity of unit creation, cost management, and logistics into a single menu.
Function: fn_addFIAveh.sqf
Function Name: 
fn_addFIAveh.sqf

What it does:
Purchases a standard faction vehicle (from the FIA/HQ menu) and places it. Similar to the Black Market function but uses standard vehicle pricing logic and handles specific FIA mechanics like fuel levels and static weapon saving.

How it does that:
Validation:

Checks for empty input, active placement, AI control, and enemy proximity.
Code Snippet:

Apply
params [["_typeVehX", "", [""]]];
if (_typeVehX isEqualTo "") exitWith { ... };
if (!(isNil "HR_GRG_placing") && {HR_GRG_placing}) exitWith { ... };
// ... enemy checks
Cost & Resource Logic:

Uses A3A_fnc_vehiclePrice (includes diminishing returns based on seaports/resources).
Same logic as Black Market for determining funding source (Player vs Faction).
Code Snippet:

Apply
private _cost = [_typeVehX] call A3A_fnc_vehiclePrice;
private _resourcesFIA = 0;
// ... Commander/Player fund split logic ...
if (_resourcesFIA < _cost) exitWith { ... };
Placement & Callbacks:

Uses HR_GRG_fnc_confirmPlacement to spawn the vehicle ghost.
Defines _fnc_placed which deducts money, reveals the vehicle to the player, and plays a sound.
Special logic: If the vehicle is a StaticWeapon, it is added to staticsToSave (global array for persistence).
Code Snippet:

Apply
private _fnc_placed = {
    params ["_vehicle", "_cost"];
    // ... deduction logic ...
    player reveal _vehicle;
    petros directSay "SentGenBaseUnlockVehicle";
    if (!HR_GRG_hasFuelSource) then { _vehicle setFuel random [0.10, 0.25, 0.35]; };
    [_vehicle, teamPlayer] call A3A_fnc_AIVehInit;
    if (_vehicle isKindOf "StaticWeapon") then {
        staticsToSave pushBack _vehicle; 
        publicVariable "staticsToSave";
    };
};
[_typeVehX, _fnc_placed, {false}, [_cost], nil, nil, nil, _extraMessage] call HR_GRG_fnc_confirmPlacement;
Where it leads:
Called Functions:
A3A_fnc_vehiclePrice: Calculates price with economy modifiers.
A3A_fnc_resourcesFIA/ResourcesPlayer: Deducts funds.
HR_GRG_fnc_confirmPlacement: Handles the ghost placement UI.
A3A_fnc_AIVehInit: Initializes vehicle AI/attributes.
Global Variables:
staticsToSave: Added to if the vehicle is a static weapon.
publicVariable "staticsToSave": Syncs the static list to all clients/server.
System Fit: Handles the standard logistics of acquiring ground assets for the rebel faction.
Function: fn_addSquadVeh.sqf
Function Name: 
fn_addSquadVeh.sqf

What it does:
Assigns a vehicle (cursor target) to a selected High Command group. It validates cargo capacity, vehicle status, and transfers vehicle ownership from the player or the environment to the specific AI group.

How it does that:
Selection & Target Validation:

Requires exactly one HC group selected.
Checks if the cursor target is a valid vehicle (alive, can move, not a static weapon, empty of units).
Code Snippet:

Apply
if (count hcSelected player != 1) exitWith { ... };
_groupX = (hcSelected player select 0);
_veh = cursortarget;
if ((!alive _veh) or (!canMove _veh)) exitWith { ... };
if ({(alive _x) and (_x in _veh)} count allUnits > 0) exitWith { ... };
Capacity Check:

Calculates _maxCargo based on transportSoldier config and turrets.
Compares against the number of alive units in the group.
Code Snippet:

Apply
_maxCargo = (getNumber (configFile >> "CfgVehicles" >> (_typeX) >> "transportSoldier")) + (count allTurrets [_veh, true]) + 1;
if ({alive _x} count units _groupX > _maxCargo) exitWith { ... };
Assignment & Boarding:

If the vehicle had a previous owner, unassigns those units.
Enables allowCrewInImmobile if the vehicle has turrets (prevents crew abandoning combat).
Adds the vehicle to the group (_groupX addVehicle _veh).
Assigns group members to specific roles (Driver, Gunner, Cargo) and orders them to get in.
Code Snippet:

Apply
_groupX addVehicle _veh;
_veh setVariable ["owner",_groupX,true];
leader _groupX assignAsDriver _veh;
{[_x] orderGetIn true; [_x] allowGetIn true} forEach units _groupX;
Where it leads:
Called Functions:
A3A_fnc_customHint: UI feedback.
Global Variables:
owner variable on the vehicle object is updated.
System Fit: Operational command tool. Allows the player to dynamically organize the battlefield by assigning captured or existing vehicles to AI groups.
Function: fn_addToGarrison.sqf
Function Name: 
fn_addToGarrison.sqf

What it does:
Adds selected units (or a group) to a specific zone's garrison. It validates the target zone (must be friendly, not a watchpost), checks garrison limits, and handles the unit transfer logic (deleting them from the map if they are far, or moving them there if close).

How it does that:
Zone Selection:

Opens the map for the player to click a position.
Finds the nearest marker (_nearX) and validates it is within 50m and is owned by teamPlayer.
Code Snippet:

Apply
if (!visibleMap) then {openMap true};
positionTel = [];
onMapSingleClick "positionTel = _pos; true";
waitUntil {sleep 0.5; positionTel isNotEqualTo [] or {!visiblemap}};
// ... validation of _nearX distance and side ...
Unit Validation:

Checks if units are already in a garrison.
Bans specific unit types (Civilians, unarmed, Petros).
Checks for dead or player-led units.
Code Snippet:

Apply
private _bannedTypes = FactionGet(civ, "unitMan") + ...;
{
    private _unitType = _x getVariable "unitType";
    if (_unitType in _bannedTypes) exitWith {_earlyEscape = true};
} forEach _unitsX;
Limit Handling:

Calls A3A_fnc_getGarrisonLimit.
If adding units exceeds the limit, it refunds the excess cost and deletes the excess units.
Code Snippet:

Apply
if (_limit != -1 && {_newGarrisonCount >= _limit}) then {
    private _unitsToRefundCount = _newGarrisonCount - _limit;
    // ... refund money and delete excess units ...
    [count _unitsToRefund,_refundMoney] remoteExec ["A3A_fnc_resourcesFIA",2];
};
Persistence & Spawning:

Calls A3A_fnc_garrisonUpdate on the server to update the persistent garrison array.
If the zone is not currently spawned (spawner getVariable _nearX != 2), it calls A3A_fnc_createSDKGarrisonsTemp to physically spawn the units immediately.
If the zone is spawned, it creates a local waypoint for the units to move to the marker, then deletes them once they arrive (replaced by the persistent garrison system).
Code Snippet:

Apply
[_unitTypes,teamPlayer,_nearX,0] remoteExec ["A3A_fnc_garrisonUpdate",2];
if (spawner getVariable _nearX != 2) then {
    [_markerX,_unitType] remoteExec ["A3A_fnc_createSDKGarrisonsTemp",2];
};
Where it leads:
Called Functions:
A3A_fnc_getGarrisonLimit: Retrieves capacity for the specific marker type.
A3A_fnc_garrisonUpdate: Remote Exec (Server). Updates the server-side garrison database.
A3A_fnc_createSDKGarrisonsTemp: Remote Exec (Server). Spawns the units physically if the zone is active.
Global Variables:
positionTel: Input from map click.
garrison (Namespace): Updated server-side.
System Fit: Core defensive mechanic. It converts mobile combat units into static defenders, managing the economy of manpower and zone control.
Function: fn_buildCreateVehicleCallback.sqf
Function Name: 
fn_buildCreateVehicleCallback.sqf

What it does:
Handles the logic for a specific "Build" action (likely a construction project or engine). It manages the engineer's movement to a target location, a timer, an animation loop, and finally remote execution to spawn the structure on the server.

How it does that:
Setup & Movement:

Determines if the player is the engineer or if an AI is assigned.
Sets a 30-second timeout (_timeOut).
If AI, commands them to move to _positionX. If Player, halves the build time and adds a 3D icon at the target location.
Code Snippet:

Apply
private _isPlayer = if (player == construction_selectedEngineer) then {true} else {false};
if (!_isPlayer) then { construction_selectedEngineer doMove _positionX };
addMissionEventHandler ["Draw3D", { ... drawIcon3D ... }];
waitUntil {sleep 1;(time > _timeOut) or (construction_selectedEngineer distance _positionX < 3)};
Construction Loop:

Deducts cost.
Disables AI features (Move, Target) for AI engineers.
Plays a construction animation (medicAnims) repeatedly using an AnimDone event handler.
Waits for the construction_buildTime to elapse or for interruption (unit downed, moved away).
Code Snippet:

Apply
waitUntil  {
    sleep 5; 
    isNil "construction_selectedEngineer" or 
    {!([construction_selectedEngineer] call A3A_fnc_canFight) or ... }
};
construction_selectedEngineer setVariable ["constructing",false];
if (!_isPlayer) then {{construction_selectedEngineer enableAI _x} forEach ["ANIM","AUTOTARGET","FSM","MOVE","TARGET"]};
Finalization:

If the timer completed successfully, it calls SCRT_fnc_build_addConstruction on the server.
Clears global construction variables.
Code Snippet:

Apply
if (time > _timeOut) exitWith { ... cancel ... };
[_structureType, _positionX, _dir] remoteExecCall ["SCRT_fnc_build_addConstruction", 2];
construction_nearestFriendlyMarker = nil;
construction_selectedEngineer = nil;
Where it leads:
Called Functions:
A3A_fnc_canFight: Checks unit status.
SCRT_fnc_build_addConstruction: Remote Exec (Server). Handles the actual object creation and persistence on the server.
A3A_fnc_resourcesPlayer: Deducts cost.
Global Variables:
construction_selectedEngineer: The unit performing the build.
build_cancelBuild, build_atBuildLocation: State flags.
System Fit: Part of the construction/building system. It bridges the gap between the client-side UI/interaction and the server-side object persistence.
Function: fn_buildMinefield.sqf
Function Name: 
fn_buildMinefield.sqf

What it does:
Spawns a task to deploy a minefield. It creates a group with an engineer and a truck, sends them to the target location, and if they arrive safely, spawns the mines and cleans up the group.

How it does that:
Setup & Cost:

Deducts cost for 1 Engineer and 1 Truck.
Removes specific mines from the player's arsenal.
Creates a visual marker for the minefield location and a task.
Code Snippet:

Apply
private _costs = 2*(server getVariable _typeExp) + ([_typeTruck] call A3A_fnc_vehiclePrice);
[-2,(-1*_costs)] remoteExec ["A3A_fnc_resourcesFIA",2];
private _mrk = createMarker [format ["Minefield%1", random 1000], _positionTel];
[[teamPlayer,civilian],_taskId,[format [localize "...",_quantity],"Minefield Deploy",_mrk],_positionTel,false,0,true,"map",true] call BIS_fnc_taskCreate;
Group Spawning & Movement:

Creates an engineer group and a truck at HQ.
Assigns the group to High Command (theBoss hcSetGroup).
Waits for the truck to reach the target location (or be destroyed).
Code Snippet:

Apply
private _groupX = createGroup teamPlayer;
[_groupX, _typeExp, (getMarkerPos respawnTeamPlayer), [], 0, "NONE"] call A3A_fnc_createUnit;
private _truckX = _typeTruck createVehicle _pos;
_groupX addVehicle _truckX;
waitUntil {sleep 1; (!alive _truckX) or ((_truckX distance _positionTel < 50) and ({alive _x} count units _groupX > 0))};
Execution & Cleanup:

If successful, it deletes the engineer group and truck.
Spawns mines using createMine.
Updates the task state to SUCCEEDED and refunds a portion of the cost (2 units refunded, minus the cost of the mines used).
Code Snippet:

Apply
if ((_truckX distance _positionTel < 50) ... ) then {
    {deleteVehicle _x} forEach units _groupX;
    deleteGroup _groupX;
    deleteVehicle _truckX;
    for "_i" from 1 to _quantity do {
        private _mineX = createMine [_typeX,_positionTel,[],100];
        teamPlayer revealMine _mineX;
    };
    [_taskId, "Mines", "SUCCEEDED"] call A3A_fnc_taskSetState;
    [2,_costs] remoteExec ["A3A_fnc_resourcesFIA",2];
};
Where it leads:
Called Functions:
A3A_fnc_resourcesFIA: Remote Exec. Manages economy.
A3A_fnc_createUnit: Spawns the engineer.
A3A_fnc_patrolLoop: (Called if successful) Makes the engineer guard the field briefly.
A3A_fnc_taskSetState: Updates the task UI.
createMine: Native Arma function to place mines.
Global Variables:
staticsToSave: Mines might be added here if they are static objects (depending on config).
System Fit: High-level strategic gameplay. It automates the tedious process of manual mine laying and abstracts it into a logistical task with an AI response.
Function: fn_controlHCsquad.sqf
Function Name: 
fn_controlHCsquad.sqf

What it does:
Allows the commander (theBoss) to take direct control of an AI High Command group. It handles the "soul transfer" logic, allowing the player to play as the AI leader for a set duration (aiControlTime), with automatic return to the original body or on damage.

How it does that:
Validation:

Checks if the player is the commander and not undercover or jailed.
Ensures the selected group leader is alive (A3A_fnc_canFight).
Code Snippet:

Apply
if (player != theBoss) exitWith { ... };
if (captive player) exitWith { ... };
if (!isNil "A3A_FFPun_Jailed" && {(getPlayerUID player) in A3A_FFPun_Jailed}) exitWith { ... };
if !([_unit] call A3A_fnc_canFight) exitWith { ... };
Transfer Logic:

Clears existing waypoints of the group.
Adds event handlers (HandleDamage) to both the player's original body and the target AI unit.
If the AI takes damage, the player returns to their original body.
If the original body takes damage, the player transfers to the AI (starting the control sequence).
Executes selectPlayer _unit to swap control.
Code Snippet:

Apply
_eh1 = player addEventHandler ["HandleDamage", {
    // Damage on original body -> return to AI or Cancel
    selectPlayer _unit;
    // ... notification ...
}];
_eh2 = _unit addEventHandler ["HandleDamage", {
    // Damage on AI -> return to original body
    selectPlayer (_unit getVariable "owner");
}];
selectPlayer _unit;
Timed Loop & Cleanup:

Starts a countdown (_timeX).
Provides an action to return control manually.
Waits for time to run out or for the player to die/return.
Cleans up event handlers and restores the group ownership to theBoss.
Code Snippet:

Apply
waitUntil {sleep 1; _timeX < 0 or {isPlayer theBoss}};
removeAllActions _unit;
selectPlayer (_unit getVariable ["owner",_unit]);
_unit removeEventHandler ["HandleDamage",_eh2];
player removeEventHandler ["HandleDamage",_eh1];
Where it leads:
Called Functions:
A3A_fnc_canFight: Validates target status.
A3A_fnc_customHint: Updates timer in HUD.
Global Variables:
owner: Variable set on the AI unit to remember where to return.
System Fit: Advanced command mechanic. It bridges the gap between RTS (High Command) and FPS gameplay, allowing precise micro-management of key units.
Function: fn_controlunit.sqf
Function Name: 
fn_controlunit.sqf

What it does:
Similar to controlHCsquad but for standard squad members (not HC groups). Allows the squad leader to take control of a specific AI unit in their own group (e.g., to use their AT launcher or medic abilities).

How it does that:
Validation:

Checks if the player is the squad leader (not the commander).
Validates the target unit is alive, not a player, not Petros, and is a rebel.
Code Snippet:

Apply
if (player != leader group player) exitWith { ... };
if (isPlayer _unit) exitWith { ... };
if (!(alive _unit) or (_unit getVariable ["incapacitated",false]))  exitWith { ... };
Transfer & Identity Preservation:

Saves the AI unit's face and voice (identity).
Sets up HandleDamage events similar to controlHCsquad.
Disables fatigue/stamina if configured in mission settings.
Adjusts weapon sway (setCustomAimCoef).
Code Snippet:

Apply
private _face = face _unit;
private _speaker = speaker _unit;
// ... Event handlers ...
selectPlayer _unit;
[_unit, createHashMapFromArray [["face", _face], ["speaker", _speaker]]] call A3A_fnc_setIdentity;
if (fatigueEnabled isEqualTo false) then { _unit enableFatigue false; };
Restoration:

Waits for timeout or death.
Executes selectPlayer (_unit getVariable ["owner",_unit]).
Removes event handlers and restores identity.
Code Snippet:

Apply
waitUntil {sleep 1; (_timeX == -1) or (isPlayer (leader group player))};
selectPlayer (_unit getVariable ["owner",_unit]);
(units group player) joinsilent group player;
group player selectLeader player;
Where it leads:
Called Functions:
A3A_fnc_setIdentity: Preserves AI appearance.
A3A_fnc_customHint: Timer display.
Global Variables:
owner: Set on the unit.
swayEnabled, fatigueEnabled: Read from mission parameters.
System Fit: Squad-level mechanic for enhanced player control over AI teammates without switching to full High Command.
Function: fn_dismissPlayerGroup.sqf
Function Name: 
fn_dismissPlayerGroup.sqf

What it does:
Disbands the player's current squad (excluding the player and Petros). It orders them to return to HQ, waits for them to arrive, and then refunds the resources and scraps their gear.

How it does that:
Selection & Orders:

Filters the group for non-player, non-Petros units.
Creates a new temporary group for them.
Orders them to move to respawnTeamPlayer (HQ).
Code Snippet:

Apply
private _newGroup = createGroup teamPlayer;
{ [_x] join _newGroup; } forEach _units;
{_x domove getMarkerPos respawnTeamPlayer} forEach units _newGroup;
Wait & Refund:

Waits up to 120 seconds for the units to reach HQ.
Iterates through arriving units.
Calculates refund based on unit cost (minus 50% for items? Actually looks like 100% refund for unit cost, but items are scrapped to box).
Deletes the units.
Code Snippet:

Apply
waitUntil {sleep 1; time > _timeX or {{(_x distance getMarkerPos respawnTeamPlayer < 50) and (alive _x)} count units _newGroup == {alive _x} count units _newGroup}};
{
    if ([_unit] call A3A_fnc_canFight) then {
        _resourcesFIA = _resourcesFIA + (server getVariable (_unit getVariable "unitType"));
        _hr = _hr +1;
        // ... Item handling ...
    };
    deleteVehicle _x;
} forEach units _newGroup;
[_hr,0] remoteExec ["A3A_fnc_resourcesFIA",2]; 
[_resourcesFIA] call A3A_fnc_resourcesPlayer;
Where it leads:
Called Functions:
A3A_fnc_canFight: Checks if unit is combat effective (refund only if alive).
A3A_fnc_resourcesFIA: Remote Exec. Returns HR and Money.
A3A_fnc_resourcesPlayer: Returns money to player.
Global Variables:
recruitCooldown: Increased to prevent abuse.
boxX: Gear is added here.
System Fit: Economy management. Allows players to clean up their squad roster and recoup investments.
Function: fn_dismissSquad.sqf
Function Name: 
fn_dismissSquad.sqf

What it does:
Disbands High Command groups selected by the commander. It sends them back to HQ, waits, then deletes them and refunds a portion of their resources.

How it does that:
Validation & Ordering:

Checks selected groups for special types (MineF, Watch, etc.) which cannot be dismissed.
Orders the groups to move to HQ.
Code Snippet:

Apply
if ((groupID _x) in ["MineF", "Watch", "Post", "Road"] ... ) exitWith { _leave = true; };
_wp = _x addWaypoint [_pos, 0];
_wp setWaypointType "MOVE";
Refund Calculation & Cleanup:

Waits 100 seconds for movement.
Iterates through group members and vehicles.
Refunds 50% of unit costs (server getVariable [...] / 2).
Handles backpack assembly logic (static weapons) for partial refund.
Deletes vehicles and groups.
Code Snippet:

Apply
sleep 100;
{
    _groupX = _x;
    {
        if (alive _x) then {
            _hr = _hr + 1;
            _resourcesFIA = _resourcesFIA + (server getVariable [_x getVariable "unitType",0]) / 2;
            // ... Backpack assembly check ...
        };
        deleteVehicle _x;
    } forEach units _groupX;
    deleteGroup _groupX;
} forEach _groups;
_nul = [_hr,_resourcesFIA] remoteExec ["A3A_fnc_resourcesFIA",2];
Where it leads:
Called Functions:
A3A_fnc_resourcesFIA: Remote Exec. Refunds economy.
System Fit: High Command economy management. Cleans up the battlefield and recycles manpower resources.
Function: fn_enemyNearCheck.sqf
Function Name: 
fn_enemyNearCheck.sqf

What it does:
A utility function that checks if any enemy units (Occupants or Invaders) are in combat behavior within a specified radius of a position.

How it does that:
Search:
Uses inAreaArray to filter units of sides Occupants and Invaders within the distance.
Filters further by checking if the unit behavior is "COMBAT" and if the unit is capable of fighting.
Code Snippet:

Apply
private _nearEnemies = ((units Occupants + units Invaders) inAreaArray [
    _unitPos, _distance, _distance]) select { behaviour _x isEqualTo "COMBAT" && {_x call A3A_fnc_canFight} };
(_nearEnemies isNotEqualTo [])
Where it leads:
Called Functions:
A3A_fnc_canFight: Checks unit state.
System Fit: Shared utility used by almost all interaction functions to prevent actions while in combat.
Function: fn_equipRebel.sqf
Function Name: 
fn_equipRebel.sqf

What it does:
Equips a unit with a randomized loadout based on the unit type (Rifleman, Medic, AT, etc.) and the unlocked gear pool (A3A_rebelGear). It handles weapon selection, magazines, uniforms, vests, backpacks, and medical supplies.

How it does that:
Fetch Gear & Determine Type:

Calls A3A_fnc_fetchRebelGear to ensure the gear hashmap is up to date.
Parses the unit type to extract the "tag" (e.g., "AT", "Medic").
Code Snippet:

Apply
call A3A_fnc_fetchRebelGear;
private _unitType = if (_forceClass != "") then {_forceClass} else {_unit getVariable "unitType"};
private _typeTag = _unitType splitString "_" select 3;
Loadout Application (Two Paths):

Custom Loadout: If a specific loadout exists in rebelLoadouts hashmap, it applies it and fills in missing slots with random gear.
Random Loadout: If no custom loadout, it sequentially calls helper functions to build the loadout:
_fnc_addUniform: Adds uniform and medical/misc items.
_fnc_addHeadgear/_fnc_addVest/_fnc_addBackpack: Selects items from A3A_rebelGear hashmaps (e.g., "ArmoredVests").
_fnc_addPrimary/_fnc_addSecondary/_fnc_addHandgun: Calls A3A_fnc_randomWeapon to select weapons based on unit role.
_fnc_addClassEquip: Adds role-specific items (Medic supplies, Engineer toolkits, Explosives).
Code Snippet:

Apply
if (!isNil "_customLoadout") then {
    // ... Apply custom, then override empty slots ...
} else {
    _unit call _fnc_addUniform;
    _unit call _fnc_addHeadgear;
    // ... etc ...
};
Post-Processing:

Removes empty backpacks.
Stores the initial loadout in orgLoadout variable if it's a player-spawned unit (for refunding later).
Code Snippet:

Apply
if (backpackItems _unit isEqualTo []) then { removeBackpack _unit };
if (_recruitType isEqualTo 0) then { _unit setVariable ["orgLoadout", getUnitLoadout _unit, true] };
Where it leads:
Called Functions:
A3A_fnc_fetchRebelGear: Syncs gear database.
A3A_fnc_randomWeapon: Selects specific weapons/mags.
A3A_fnc_itemset_medicalSupplies: Gets medical items.
Global Variables:
A3A_rebelGear: Hashmap containing all available gear classes.
rebelLoadouts: Hashmap of specific unit loadouts.
System Fit: Core character customization. Ensures visual and functional variety for rebel forces based on unlocked equipment.
Function: fn_FIAinit.sqf
Function Name: 
fn_FIAinit.sqf

What it does:
Initializes a rebel unit after creation. It sets skill, traits, identity, equipment, and attaches event handlers for death and AI management (returning to squad if lost).

How it does that:
Base Attributes:

Initializes revive system.
Sets skill based on global skillFIA and A3A_rebelSkillMul.
Sets traits (camouflage, audible).
Code Snippet:

Apply
[_unit] call A3A_fnc_initRevive;
private _skill = (0.1 + 0.1*A3A_rebelSkillMul + 0.015 * skillFIA);
_unit setSkill _skill;
_unit setUnitTrait ["camouflageCoef",0.8];
Identity & Equipment:

Assigns random face/speaker if not preserving identity.
Calls A3A_fnc_equipRebel unless the unit is unarmed (refugee).
Code Snippet:

Apply
if (!_preserveIdentity) then {
    [_unit, createHashMapFromArray [...]] call A3A_fnc_setIdentity;
};
if !(_typeX isEqualTo FactionGet(reb,"unitUnarmed")) then {
    [_unit, [0,1] select (leader _unit != player)] call A3A_fnc_equipRebel;
};
Event Handlers & AI Logic:

Player Squad: Adds a Killed event handler that handles aggression changes and postmortem. Adds a loop to check if the unit is lost (out of range/no radio) and orders them back to the player or HQ.
HC/Non-Player Squad: Adds a simpler Killed event handler for logging and aggression.
Code Snippet (Lost Unit Logic):

Apply
while {alive _unit} do {
    sleep 10;
    if ((unitReady _unit) && ...) then {
        ["", format ["%1 has lost contact", name _unit]] call A3A_fnc_customHint;
        [_unit] join stragglers;
        _unit doMove position player;
        // ... wait for return ...
    };
};
Where it leads:
Called Functions:
A3A_fnc_initRevive: Sets up medical.
A3A_fnc_setIdentity: Assigns face/voice.
A3A_fnc_equipRebel: Gears the unit.
A3A_fnc_postmortem: Handles cleanup on death.
A3A_fnc_undercoverAI: If player is undercover, unit is too.
Global Variables:
stragglers: A group for lost units.
skillFIA: Global skill level.
System Fit: Unit lifecycle management. Ensures all rebel units behave consistently regarding skill, death, and team coordination.
Function: fn_FIAskillAdd.sqf
Function Name: 
fn_FIAskillAdd.sqf

What it does:
Allows the commander to spend faction resources to permanently increase the global skill level of the rebel faction (skillFIA).

How it does that:
Validation:

Checks if player is theBoss.
Checks if skillFIA has reached the cap (40).
Calculates cost: 1000 + (1.5*(skillFIA *750)) (increasing cost per level).
Code Snippet:

Apply
if (player != theBoss) exitWith { ... };
if (skillFIA >= SKILL_CAP) exitWith { ... };
private _costs = 1000 + (1.5*(skillFIA *750));
Execution:

Asks for confirmation via BIS_fnc_guiMessage.
Deducts resources from resourcesFIA.
Increments skillFIA and updates unit costs on the server (scaling prices based on new skill level).
Updates the UI if the Commander menu is open.
Code Snippet:

Apply
skillFIA = skillFIA + 1;
publicVariable "skillFIA";
server setVariable ["resourcesFIA",_resourcesFIA,true];
{
    _costs = server getVariable _x;
    _costs = round (_costs + (_costs * (skillFIA/840)));
    server setVariable [_x,_costs,true];
} forEach FactionGet(reb,"unitsSoldiers");
Where it leads:
Called Functions:
BIS_fnc_guiMessage: Confirmation dialog.
SCRT_fnc_ui_showMessage: Notification.
A3A_fnc_statistics: Updates display.
Global Variables:
skillFIA: Incremented.
resourcesFIA: Decremented server-side.
System Fit: Long-term progression system. It creates a sink for excess resources and scales faction difficulty/efficiency.
Function: fn_garrisonAdd.sqf
Function Name: 
fn_garrisonAdd.sqf

What it does:
Adds a specific unit type to the currently selected garrison zone (via positionXGarr). It is simpler than addToGarrison as it doesn't handle map clicks; it assumes a zone is already selected in the UI.

How it does that:
Validation:

Checks HR and Money.
Checks if the zone is valid (not water, not enemy near).
Checks garrison limit.
Code Snippet:

Apply
private _hr = server getVariable "hr";
if (_hr < 1) exitWith { ... };
private _markerX = positionXGarr;
if ([_positionX] call A3A_fnc_enemyNearCheck) exitWith { ... };
Update & Spawn:

Deducts resources.
Calls A3A_fnc_garrisonUpdate on the server.
If the marker is not currently spawned, it calls A3A_fnc_createSDKGarrisonsTemp to spawn the unit immediately.
Code Snippet:

Apply
[-1,-_costs] remoteExec ["A3A_fnc_resourcesFIA",2];
[_unitType,teamPlayer,_markerX,1] remoteExec ["A3A_fnc_garrisonUpdate",2];
if (spawner getVariable _markerX != 2) then {
    [_markerX,_unitType] remoteExec ["A3A_fnc_createSDKGarrisonsTemp",2];
};
Where it leads:
Called Functions:
A3A_fnc_enemyNearCheck: Safety.
A3A_fnc_garrisonUpdate: Remote Exec. Updates DB.
A3A_fnc_createSDKGarrisonsTemp: Remote Exec. Spawns unit.
Global Variables:
positionXGarr: The currently active zone in the UI.
System Fit: The specific UI action for garrison management.
Function: fn_garrisonDialog.sqf
Function Name: 
fn_garrisonDialog.sqf

What it does:
Manages the garrison UI. It handles the "Remove" (Disband) logic and the "Recruit" logic (opening the recruit dialog or triggering specific watchpost/roadblock setups).

How it does that:
Remove Logic:

Detects if the zone is a specific type (Watchpost, Roadblock, AA/AT Post).
Calculates refund value based on the specific template used to create the outpost.
Deletes the marker and garrison data from global arrays (watchpostsFIA, etc.) and server namespace.
Code Snippet:

Apply
if (_typeX == "rem") then {
    switch (true) do {
        case (_watchpostFIA): {
            _costs = 50; ... // Calculate specific cost
            garrison setVariable [_site,nil,true];
            watchpostsFIA = watchpostsFIA - [_site];
            // ... publicVariable ...
        };
    };
};
Recruit Logic:

Sets the global positionXGarr variable.
Opens the garrisonRecruit dialog.
Updates dialog controls with tooltips showing costs for different unit types.
Code Snippet:

Apply
} else {
    positionXGarr = _site;
    createDialog "garrisonRecruit";
    sleep 1;
    disableSerialization;
    _display = findDisplay 100;
    // ... set tooltips ...
};
Where it leads:
Called Functions:
A3A_fnc_resourcesFIA: Remote Exec. Refunds money.
Global Variables:
positionXGarr: Set for the recruit dialog to know where to add units.
garrison: Namespace modified.
watchpostsFIA, roadblocksFIA, etc.: Arrays modified.
System Fit: The UI backend for garrison management.
Function: fn_postmortem.sqf
Function Name: 
fn_postmortem.sqf

What it does:
Handles the cleanup of dead units. It waits a set amount of time (cleantime) before deleting the unit body and its group to preserve performance.

How it does that:
Initial Handling:

Checks if the unit is in staticsToSave. If so, removes it from the list (as it's destroyed/dead).
Code Snippet:

Apply
if (_victim in staticsToSave) then {
    staticsToSave = staticsToSave - [_victim];
    publicVariable "staticsToSave";
};
Wait & Delete:

Sleeps for cleantime.
Checks stopPostmortem variable (allows cancellation for persistent units).
Deletes the unit and the group.
Code Snippet:

Apply
sleep cleantime;
if (_victim getVariable ["stopPostmortem", false]) exitWith {};
if !(isnull _victim) then {
    if (_victim isKindOf "CAManBase" and !(isNull (objectParent _victim))) then {
        [objectParent _victim, _victim] remoteExec ["deleteVehicleCrew", _victim];
    } else {
        deleteVehicle _victim;
    };
};
if !(isnull _group) then { deleteGroup _group; };
Where it leads:
Called Functions:
deleteVehicleCrew: Remote Exec. Ensures vehicle seats are cleared properly.
Global Variables:
staticsToSave: Modified on death.
System Fit: Performance optimization (garbage collection) and persistence management (removing dead units from save lists).
Function: fn_reDress.sqf & fn_reDressFaction.sqf
Function Name: 
fn_reDress.sqf
 / 
fn_reDressFaction.sqf

What it does:
Simple utility to force a unit into a faction uniform and add a First Aid Kit. Used for prisoners/deserters to give them a visual identity and basic functionality.

How it does that:
Selects a random uniform from the faction's uniform array (A3A_faction_reb or A3A_faction_inv/occ).
Adds the item to the uniform.
Code Snippet:

Apply
_unit forceAddUniform (selectRandom (A3A_faction_reb get "uniforms"));
_unit addItemToUniform "FirstAidKit";
Where it leads:
System Fit: Cosmetic/Utility function for mission scripts (rescues, pow mechanics).
Function: fn_reinfPlayer.sqf
Function Name: 
fn_reinfPlayer.sqf

What it does:
Allows a standard (non-commander) player to recruit a single unit into their personal squad, paying with personal money.

How it does that:
Validation:

Checks if player is a member, cooldown, not AI controlled, no enemies nearby, is squad leader, and has HR/Money.
Checks squad size limit (max 9 + stragglers).
Code Snippet:

Apply
if !(player call A3A_fnc_isMember) exitWith { ... };
if (recruitCooldown > time) exitWith { ... };
if ((count units group player) + (count units stragglers) > 9) exitWith { ... };
Spawning:

Calls A3A_fnc_createUnit at the player's position.
Deducts money and HR.
Initializes the unit (A3A_fnc_FIAinit) and disables AUTOCOMBAT to prevent immediate aggression.
Code Snippet:

Apply
private _unit = [group player, _typeUnit, position player, [], 0, "NONE"] call A3A_fnc_createUnit;
[- _costs] call A3A_fnc_resourcesPlayer;
[_unit] spawn A3A_fnc_FIAinit;
_unit disableAI "AUTOCOMBAT";
Where it leads:
Called Functions:
A3A_fnc_isMember: Membership check.
A3A_fnc_createUnit: Spawns the unit.
A3A_fnc_resourcesFIA/ResourcesPlayer: Deducts cost.
A3A_fnc_FIAinit: Initializes unit.
System Fit: Squad management for standard players.
Function: fn_spawnHCGroup.sqf
Function Name: 
fn_spawnHCGroup.sqf

What it does:
The core spawner for High Command units. It takes a list of unit types, creates them, sets IDs, handles special cases (MG, Mortar, Vehicle integration), and assigns them to the commander.

How it does that:
Spawn & Init:

Calculates cost.
Spawns group at HQ using A3A_fnc_spawnGroup.
Sets group ID (e.g., "SqMG-10").
Initializes all units with A3A_fnc_FIAinit.
Assigns to HC via theBoss hcSetGroup.
Code Snippet:

Apply
private _group = [_pos, teamPlayer, _unitTypes, true] call A3A_fnc_spawnGroup;
_group setGroupIdGlobal [_idFormat + str ({side (leader _x) == teamPlayer} count allGroups)];
{[_x] call A3A_fnc_FIAinit} forEach _units;
theBoss hcSetGroup [_group];
Special Logic (Switch):

staticAutoT: Spawns a static weapon and calls A3A_fnc_MortyAI (AI mortar logic).
BuildAA: Attaches a static AA gun to the vehicle.
MG/Mortar: Adds backpack disassembly items to specific units.
Code Snippet:

Apply
switch _special do {
    case "staticAutoT": {
        private _staticType = ...;
        [_group, _staticType] spawn A3A_fnc_MortyAI;
    };
    case "MG": {
        private _backpacks = getArray (...);
        (_units # (_countUnits - 1)) addBackpackGlobal (_backpacks#1);
    };
};
Deduction:

Calls A3A_fnc_resourcesFIA to deduct costs (HR and Money).
Code Snippet:

Apply
[- _costHR, - _cost] remoteExec ["A3A_fnc_resourcesFIA", 2];
Where it leads:
Called Functions:
A3A_fnc_spawnGroup: Creates the group.
A3A_fnc_FIAinit: Initializes units.
A3A_fnc_MortyAI: Remote Exec. Starts AI logic for static weapons.
A3A_fnc_resourcesFIA: Remote Exec. Deducts cost.
System Fit: The final step in the recruitment chain. It materializes the abstract "Unit Type" into physical game objects.
Function: fn_vehiclePrice.sqf
Function Name: 
fn_vehiclePrice.sqf

What it does:
Calculates the final price of a vehicle based on the base price, economy state (seaports/resources owned), and comparison with Black Market prices.

How it does that:
Base Calculation:

Retrieves base price from server variable.
Calculates diminishing returns: 1 / (1 + (ports * 0.1) + (resources * 0.02)).
Code Snippet:

Apply
private _multiplierSeaport = {sidesX getVariable [_x,sideUnknown] == teamPlayer} count seaports;
private _diminishingFactor = 1 / (1 + (_multiplierSeaport * _reductionFactorSeaport) + ...);
round (_costs * _diminishingFactor);
BM Comparison:

Gets Black Market price via A3U_fnc_blackMarketVehiclePrice.
Takes the minimum of the calculated price and the Black Market price (to prevent arbitrage exploits).
Code Snippet:

Apply
private _costsBM = [_typeX] call A3U_fnc_blackMarketVehiclePrice;
if (_costs isNotEqualTo 0 && {_costsBM isNotEqualTo 0}) then {
    _costs = _costs min _costsBM;
};
Where it leads:
Called Functions:
A3U_fnc_blackMarketVehiclePrice: Gets competitor price.
Global Variables:
seaports, resourcesX: Read for economy modifiers.
System Fit: Economic engine. Balances the cost of goods based on player progress.
Function: fn_vehStats.sqf
Function Name: 
fn_vehStats.sqf

What it does:
Displays status information for a selected HC group or manages vehicle mounting/dismounting for the group.

How it does that:
Mount/Dismount Logic:

If argument is "mount", it iterates through selected groups.
Checks if the group has an assigned vehicle.
If in the vehicle, orders orderGetIn false (dismount).
If out, orders orderGetIn true (mount).
Sets A3A_forceDismount variable to persist the state.
Code Snippet:

Apply
if (_this select 0 == "mount") exitWith {
    if (leader _groupX in _veh) then {
        {[_x] orderGetIn false; [_x] allowGetIn false} forEach units _groupX;
        _groupX setVariable ["A3A_forceDismount", true];
    } else { ... };
};
Status Display:

Compiles a text string with group ID, health status, task, medic presence, AT/AA presence, mortar status, and vehicle info (damage, ammo).
Displays via A3A_fnc_customHint.
Code Snippet:

Apply
_textX = format [localize "...",groupID _groupX,{alive _x} count _unitsX,{[_x] call A3A_fnc_canFight} count _unitsX,_groupX getVariable ["taskX","Patrol"]];
[localize "STR_A3A_reinf_vehStat_header", format ["%1",_textX]] call A3A_fnc_customHint;
Where it leads:
Called Functions:
A3A_fnc_isMedic: Checks unit role.
A3A_fnc_typeOfSoldier: Checks unit speciality (AT, AA).
A3A_fnc_customHint: UI output.