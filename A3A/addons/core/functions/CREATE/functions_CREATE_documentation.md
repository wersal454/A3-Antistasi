fn_AAFroadPatrol.sqf
What it does: Creates and manages AI-controlled road patrols for the AAF (Altis Armed Forces) faction. This function spawns a military vehicle (land, sea, or air) with appropriate crew and cargo from an enemy-held base, creates waypoints for it to patrol between enemy-controlled markers, and manages its lifecycle until it's destroyed, despawned, or returns to base. The function handles different patrol types (land, sea, air) with appropriate vehicle selection based on the base type and faction capabilities.

How it does that:

1. Player and Base Validation

Sqf

Apply
private _players = allPlayers - entities "HeadlessClient_F";
private _bases = (seaports + airportsX + outposts + milbases) select {
    call {
        if (_players inAreaArray [markerPos _x, 2000, 2000] isEqualTo []) exitWith {false};
        private _side = sidesX getVariable [_x, sideUnknown];
        if (_side == teamPlayer) exitWith {false};
        if (_x in seaports and Faction(_side) get "vehiclesGunBoats" isEqualTo []) exitWith {false};
        if (_x call A3A_fnc_getMarkerNavPoint == -1) exitWith {false};
        true;
    };
};
Filters out Headless Clients from the player list
Iterates through all potential base markers (seaports, airports, outposts, milbases)
Validation checks: At least one player within 2000m, base not rebel-owned, seaports have gunboats available, base has a valid navpoint for pathfinding
If no valid bases found, function exits early
2. Base Selection

Sqf

Apply
if (_bases isEqualTo []) exitWith {};
Debug_1("Possible patrol bases %1", _bases);
private _base = selectRandom _bases;
Randomly selects one base from the validated list
Creates debug output showing available bases
3. Faction and Vehicle Type Determination

Sqf

Apply
private _sideX = sidesX getVariable [_base,sideUnknown];
private _faction = Faction(_sideX);
private _typeCar = "";
private _typePatrol = "LAND";

switch (true) do {
    case (_base in seaports): {
        _typeCar = selectRandom (_faction get "vehiclesGunBoats");
        _typePatrol = "SEA";
    };
    case (_base in milbases): {
        if (random 10 < tierWar + aggressionOccupants/10) then {
            _typeCar = selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesAPCs") + (_faction get "vehiclesIFVs") + (_faction get "vehiclesLightTanks"));
        } else {
            _typeCar = selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesLightAPCs") + (_faction get "vehiclesMilitiaAPCs"));
        };
    };
    case (_base in airportsX && {!(_faction getOrDefault ["attributeLowAir", false])}): {
        if (_sideX isEqualTo Invaders || {random 10 < tierWar + aggressionOccupants/10}) then {
            _typeCar = selectRandom (_faction get "vehiclesHelisLight");
            if(count (_faction get "vehiclesAirPatrol") > 0) then {
                _typeCar = selectRandom (_faction get "vehiclesAirPatrol");
            };
            _typePatrol = "AIR";
        } else {
            _typeCar = selectRandom ((_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaCars"));
        };
    };
    default {
        if (_sideX isEqualTo Invaders || {random 10 < tierWar + aggressionOccupants/10}) then {
            _typeCar = selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesLightUnarmed"));
        } else {
            _typeCar = selectRandom ((_faction get "vehiclesPolice") + (_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaCars") + (_faction get "vehiclesBasic"));
        };
    };
};
Determines the side of the selected base and gets the appropriate faction definition
Uses a switch statement to select vehicle type based on base category:
Seaports: Gunboats (sea patrol)
Milbases: Light armored vehicles, APCs, IFVs, or light tanks (chance increases with tierWar and aggression)
Airports: Helicopters (air patrol) or light vehicles (if faction has "attributeLowAir" or low tier)
Default (Outposts): Light armed/unarmed vehicles, police vehicles, or militia cars
Sets _typePatrol to "SEA", "AIR", or "LAND"
4. Destination and Pathfinding Setup

Sqf

Apply
Info_3("Sending patrol of type %1 vehicle %2 from %3", _typePatrol, _typeCar, _base);

private _posbase = getMarkerPos _base;
private _arrayDestinations = [];
private _distanceX = 0;

switch (_typePatrol) do {
    case "AIR": {
        _arrayDestinations = markersX select {sidesX getVariable [_x,sideUnknown] == _sideX};
        _distanceX = 200;
    };
    case "SEA": {
        _arrayDestinations = seaMarkers select {(getMarkerPos _x) distance _posbase < 2500};
        _distanceX = 100;
    };
    default {
        _arrayDestinations = markersX select {sidesX getVariable [_x,sideUnknown] == _sideX};
        _arrayDestinations = [_arrayDestinations,_posBase] call A3A_fnc_patrolDestinations;
        _distanceX = 50;
    };
};

if (count _arrayDestinations < 4) exitWith {};
Retrieves base position coordinates
Builds destination array based on patrol type:
Air: All markers owned by the same side
Sea: Sea markers within 2500m of the base
Land: Same-side markers filtered through patrolDestinations (road pathfinding)
Sets completion radius (_distanceX) and validates at least 4 destinations exist
5. Patrol Counter and Spawn Position Adjustment

Sqf

Apply
AAFpatrols = AAFpatrols + 1;

switch (true) do {
    case (_typePatrol isEqualTo "SEA"): {
        _posbase = [_posbase,50,150,10,2,0,0] call BIS_Fnc_findSafePos;
    };
    case (_typePatrol isNotEqualTo "AIR"): {
        private _indexX = airportsX find _base;
        if (_indexX != -1) then {
            private _spawnPoint = server getVariable (format ["spawn_%1", _base]);
            _posBase = getMarkerPos _spawnPoint;
        } else {
            _posbase = position ([_posbase] call A3A_fnc_findNearestGoodRoad);
        };
    };
};
Increments global patrol counter for performance tracking
Adjusts spawn position:
Sea: Finds safe water position 50-150m from base
Land (airports): Uses server-stored spawn point marker
Land (other): Spawns on nearest good road to base
6. Vehicle and Crew Spawning

Sqf

Apply
private _vehicle = [_posBase, 0,_typeCar, _sideX] call A3A_fnc_spawnVehicle;
private _veh = _vehicle select 0;

[_veh, _sideX] call A3A_fnc_AIVEHinit;
[_veh,"Patrol"] spawn A3A_fnc_inmuneConvoy;

private _vehCrew = _vehicle select 1;

{[_x,"",false] call A3A_fnc_NATOinit} forEach _vehCrew;

private _groupVeh = _vehicle select 2;
_soldiers append _vehCrew;
_groups pushBack _groupVeh;
_vehiclesX pushBack _veh;
Spawns vehicle using spawnVehicle (returns [vehicle, crew array, group])
Initializes vehicle with AI behavior using AIVEHinit
Spawns immune convoy effect (temporary invincibility)
Initializes each crew member with NATOinit (forced non-spawner for performance)
References and stores: vehicle, crew, and group for later management
7. Infantry Passenger Assignment

Sqf

Apply
switch (true) do {
    case (_typeCar in (_faction get "vehiclesLightUnarmed")): {
        sleep 1;
        private _groupX = [_posbase, _sideX, (selectRandom ([_faction, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier))] call A3A_fnc_spawnGroup;
        {_x assignAsCargo _veh;_x moveInCargo _veh; _soldiers pushBack _x; [_x] joinSilent _groupVeh; [_x,"",false] call A3A_fnc_NATOinit} forEach units _groupX;
        deleteGroup _groupX;
    };
    // Similar cases for APCs and IFVs with different group sizes
};
Checks vehicle type and spawns appropriate infantry group
Light Unarmed: Small tier group (4 units)
Light APCs: Medium tier group
APCs/IFVs: Squad tier group
Assigns infantry to cargo, joins to vehicle's group, initializes as non-spawner
Deletes temporary spawning group
8. Main Patrol Loop

Sqf

Apply
while {alive _veh} do {
    if (count _arrayDestinations < 2) exitWith {};
    private _destinationX = selectRandom _arrayDestinations;
    private _posDestination = getMarkerPos _destinationX;
    if (_typePatrol == "LAND") then {
        private _road = [_posDestination] call A3A_fnc_findNearestGoodRoad;
        _posDestination = position _road;
    };
    private _Vwp0 = _groupVeh addWaypoint [_posDestination, 0];
    _Vwp0 setWaypointType "MOVE";
    _Vwp0 setWaypointBehaviour "SAFE";
    _Vwp0 setWaypointSpeed "LIMITED";
    _veh setFuel 1;

    private _timeout = time + (_veh distance2d _posDestination) / 6 + 300;
    waitUntil {sleep 60; _veh distance _posDestination < _distanceX or {time > _timeout or {{[_x] call A3A_fnc_canFight} count _soldiers == 0 or {!canMove _veh}}}};
    if !(_veh distance _posDestination < _distanceX) exitWith {};

    switch (_typePatrol) do {
        case "AIR": {
            _arrayDestinations = markersX select {sidesX getVariable [_x,sideUnknown] == _sideX};
        };
        case "SEA": {
            _arrayDestinations = seaMarkers select {(getMarkerPos _x) distance position _veh < 2500};
        };
        default {
            _arrayDestinations = markersX select {sidesX getVariable [_x,sideUnknown] == _sideX};
            _arrayDestinations = [_arrayDestinations,position _veh] call A3A_fnc_patrolDestinations;
        };
    };
};
Continues while vehicle is alive
Selects random destination from current list
Land patrols: Adjusts destination to nearest road
Creates waypoint with SAFE behavior, LIMITED speed
Refuels vehicle before each leg
Calculates timeout (travel time + 5 minutes buffer)
Waits until: vehicle reaches destination, timeout, no soldiers can fight, or vehicle cannot move
If destination reached, updates destination list:
Air: Refreshes all same-side markers
Sea: Refreshes markers within 2500m of current position
Land: Re-routes through patrolDestinations (pathfinding)
9. Cleanup and Patrol Counter Decrement

Sqf

Apply
{ [_x] spawn A3A_fnc_VEHDespawner } forEach _vehiclesX;
{ [_x] spawn A3A_fnc_enemyReturnToBase } forEach _groups;

AAFpatrols = AAFpatrols - 1;
Spawns despawner for all vehicles (checks distance to players)
Spawns return-to-base for all groups
Decrements global patrol counter
Where it leads:

Functions called:

A3A_fnc_spawnVehicle - Spawns vehicle and crew at position
A3A_fnc_AIVEHinit - Initializes vehicle with AI behaviors and event handlers
A3A_fnc_inmuneConvoy - Applies temporary invincibility effect
A3A_fnc_NATOinit - Initializes AI units with skills, equipment, event handlers
A3A_fnc_spawnGroup - Spawns infantry groups
A3A_fnc_cargoSeats - Determines infantry group composition
A3A_fnc_patrolDestinations - Generates road-based pathfinding destinations
A3A_fnc_findNearestGoodRoad - Finds nearest drivable road
A3A_fnc_VEHDespawner - Manages vehicle cleanup when no players nearby
A3A_fnc_enemyReturnToBase - Sends groups back to base
A3A_fnc_canFight - Checks if unit is combat capable
SCRT_fnc_unit_flattenTier - Flattens tiered unit lists for selection
Functions that call this:

A3A_fnc_reinforcementsAI (periodic reinforcement system)
Manual execution via debug/menu commands
Global variables modified:

AAFpatrols - Global counter for active patrols (performance management)
soldiers, vehiclesX, groups - Local arrays for tracking spawned objects
Synchronization/Network:

Runs entirely server-side (isServer check in calling code)
Uses remoteExec for unit initialization to ensure proper networking
Global patrol counter may be used by other server-side systems for performance limits
Edge cases:

Empty destination list: Function exits if less than 4 valid destinations
No safe spawn position: Vehicle spawn may fail or use fallback positions
Vehicle destroyed mid-leg: Cleanup triggers immediately
All crew killed: Patrol ends via _soldiers == 0 check
Low fuel/tier: Vehicle may be less equipped (handled by vehicle selection)
fn_airportCanAttack.sqf
What it does: Determines if an airport (or outpost/milbase) can currently launch an attack. This is a validation function used by attack systems to ensure the base meets minimum requirements for launching offensive operations.

How it does that:

1. Date/Time Validation

Sqf

Apply
params ["_markerX"];

if !(dateToNumber date > server getVariable [_markerX,0]) exitWith {false};
Checks if current date (converted to number) is greater than the marker's "idle date"
Uses server getVariable [_markerX,0] which stores when the base was last attacked
Prevents rapid repeated attacks on the same base
2. Carrier Special Case

Sqf

Apply
if (_markerX == "CSAT_Carrier" or {_markerX == "NATO_Carrier"}) exitWith {true};
Carriers can always attack regardless of other conditions
Returns true immediately for carrier markers
3. Spawn State Validation

Sqf

Apply
if ((spawner getVariable _markerX) == 0) exitWith {false};
Checks if base spawn state is 0 (means it's currently despawned/inactive)
Only bases in "spawned" state (1 or 2) can attack
4. Marker Type Validation

Sqf

Apply
if (!(_markerX in airportsX) and {!(_markerX in outposts) and {!(_markerX in milbases)}}) exitWith {false};
Validates marker is an airport, outpost, or milbase
Exits if marker is another type (seaport, resource, factory, etc.)
5. Garrison Strength Validation

Sqf

Apply
if (count (garrison getVariable [_markerX,[]]) < 16) exitWith {false};
Checks if base has at least 16 garrison units
Uses garrison namespace variable
Ensures sufficient troops available to support attack
6. Forced Spawn Check

Sqf

Apply
if (_markerX in forcedSpawn) exitWith {false};
Exits if marker is in forcedSpawn array (currently under attack or special mission)
Prevents multiple simultaneous attacks on same base
7. Success

Sqf

Apply
true
All checks passed, base can attack
Where it leads:

Functions called:

None directly (uses global arrays and variables)
Functions that call this:

A3A_fnc_chooseAttack - Main attack selection system
A3A_fnc_singleAttack - Direct attack launcher
A3A_fnc_wavedAttack - Wave-based attack system
Global variables/modifications:

dateToNumber - Date conversion function
server - Server namespace containing marker idle dates
spawner - Spawn state management
garrison - Garrison unit counts
forcedSpawn - Active mission markers
airportsX, outposts, milbases - Marker arrays
Synchronization/Network:

Pure server-side function (no networking)
All data retrieved from server namespaces or global arrays
Edge cases:

Carrier attack: Always allowed regardless of garrison or spawn state
Recently attacked: Delay based on idle date
Low garrison: Requires minimum 16 units
Currently spawning: Cannot attack if despawned
fn_AIVEHinit.sqf
What it does: Comprehensive vehicle initialization function that installs all necessary damage, AI, capture, and interaction logic for enemy vehicles. Handles different vehicle types (ground, air, static weapons), adds event handlers for various scenarios (damage, death, capture, artillery), and sets up faction-specific behaviors.

How it does that:

1. Initial Validation and Type Detection

Sqf

Apply
params ["_veh", "_side", "_resPool", ["_excludeTrails", false]];

if (isNil "_veh") exitWith {};

// Not a crewed vehicle, nothing to do here
if (fullCrew [_veh, "", true] isEqualTo []) exitWith {
    if (typeof _veh in A3A_utilityItemHM) then { _veh call A3A_fnc_initObject };
};
Validates vehicle exists
Checks if vehicle has crew positions (skip utility items like crates)
If utility item, calls object initialization instead
2. Vehicle Capabilities Setup

Sqf

Apply
_veh setVehicleRadar ([0, 1] select (getNumber(configOf _veh >> "radarType") in [2, 4]));
_veh setVehicleReceiveRemoteTargets true;
_veh setVehicleReportRemoteTargets true;
_veh setVehicleReportOwnPosition true;
Enables radar if vehicle config has radar type 2 or 4
Enables remote target reporting (for shared targeting)
Enables position reporting
3. Side Initialization Check

Sqf

Apply
if (isNil { _veh getVariable "ownerSide" }) exitWith {
    [_veh, _side, true] call A3A_fnc_vehKilledOrCaptured;
};
If vehicle already has ownerSide variable, calls vehKilledOrCaptured to swap side
Prevents double initialization
4. Variable Setup

Sqf

Apply
_veh setVariable ["originalSide", _side, true];
_veh setVariable ["ownerSide", _side, true];

if (isNil "_resPool") then { _resPool = "legacy" };
_veh setVariable ["A3A_resPool", _resPool, true];
Sets original and owner side (for capture logic)
Sets resource pool for cost tracking (legacy, attack, defence, etc.)
5. Cargo Clearance

Sqf

Apply
if (_side == teamPlayer) then {
    clearMagazineCargoGlobal _veh;
    clearWeaponCargoGlobal _veh;
    clearItemCargoGlobal _veh;
    clearBackpackCargoGlobal _veh;
} else {
    clearWeaponCargoGlobal _veh;
};
Clears all cargo for rebel vehicles
Clears only weapons for enemy vehicles (keep magazines/items for AI)
6. Texture Synchronization

Sqf

Apply
_veh call A3A_fnc_vehicleTextureSync;
Applies faction-appropriate textures/variants
7. Ground Vehicle Event Handlers

Sqf

Apply
if (_veh isKindOf "Car" or{ _veh isKindOf "Tank"}) then {
    if (_side == teamPlayer or _side == civilian) exitWith {};

    if (_typeX in FactionGet(all,"vehiclesArmor")) then { _veh call A3A_fnc_addActionBreachVehicle };

    switch (true) do {
        case (_veh isKindOf "Car"): {
            _veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != teamPlayer)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
            if ({"SmokeLauncher" in (_veh weaponsTurret _x)} count (allTurrets _veh) > 0) then {
                _veh setVariable ["within",true];
                _veh addEventHandler ["GetOut", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}];
                _veh addEventHandler ["GetIn", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
            };
        };

        case (_typeX in FactionGet(all,"vehiclesAPCs") + FactionGet(all,"vehiclesIFVs") + FactionGet(all,"vehiclesLightAPCs")): {
            _veh addEventHandler ["HandleDamage",{private _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto; _veh removeEventHandler ["HandleDamage",_thisEventHandler]};if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_veh))) then {0;} else {(_this select 2);}}];
            _veh setVariable ["within",true];
            _veh addEventHandler ["GetOut", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false];[_veh] call A3A_fnc_smokeCoverAuto}}}];
            _veh addEventHandler ["GetIn", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
        };

        default {
            _veh addEventHandler ["HandleDamage",{private _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto; _veh removeEventHandler ["HandleDamage",_thisEventHandler]}; _this select 2}];
        };
    };
};
All ground vehicles (not teamPlayer/civilian):
Armor vehicles: Add breach action
Cars:
Wheel damage immunity if not player driver and not rebel attacker
Auto-smoke if equipped with smoke launchers (GetOut/GetIn to track "within" status)
APCs/IFVs:
HandleDamage to trigger smoke when vehicle cannot fire
Wheel damage immunity as above
Smoke launcher functionality
Tanks/AA:
HandleDamage to trigger smoke when cannot fire
8. Air Vehicle Event Handlers

Sqf

Apply
} else {
    switch (true) do {
        case (unitIsUAV _veh && {_side isEqualTo teamPlayer}): {
            if (crew _veh isNotEqualTo []) then { deleteVehicleCrew _veh };
            [_side, _veh] call A3A_fnc_createVehicleCrew;
        };
        case (_typeX in (FactionGet(all,"vehiclesFixedWing") + FactionGet(all,"vehiclesHelis"))): {
            _veh addEventHandler ["GetIn", {
                if (_this select 1 != "driver") exitWith {};
                _unit = _this select 2;
                if (!isPlayer _unit and {_unit getVariable ["spawner",false] and {side group _unit == teamPlayer}}) then {
                    moveOut _unit;
                    [localize "STR_A3A_Create_AIVEHINIT_header", localize "STR_A3A_Create_AIVEHINIT_only_humans"] call A3A_fnc_customHint;
                };
            }];

            if (_veh isKindOf "Helicopter" && {_typeX in FactionGet(all,"vehiclesTransportAir")}) then {
                _veh setVariable ["within",true];
                _veh addEventHandler ["GetOut", {private _veh = _this select 0; if ((isTouchingGround _veh) and (isEngineOn _veh)) then {if (side (_this select 2) != teamPlayer) then {if (_veh getVariable "within") then {_veh setVariable ["within",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}}];
                _veh addEventHandler ["GetIn", {private _veh = _this select 0; if (side (_this select 2) != teamPlayer) then {_veh setVariable ["within",true]}}];
            };
            _veh addEventHandler ["RopeAttach", {
                params ["_object1", "_rope", "_object2"];
                {
                    [_x, false] remoteExec ["setCaptive", _x];
                } forEach crew _object1;
            }];
        };
    };
};
UAVs (teamPlayer only): Delete existing crew and create proper vehicle crew
Fixed-wing/Helicopters:
Prevents AI spawners from entering pilot seat (only players can fly)
Transport helicopters: Smoke launcher on GetOut when grounded with engine on
Rope attachment: Removes captive status from crew when ropes are attached
9. Static Weapons and Ground Vehicles

Sqf

Apply
if ((_veh isKindOf  "LandVehicle") || (_veh isKindOf  "Ship")) then {
    private _markers = markersX select { _veh inArea _x && {sidesX getVariable [_x, sideUnknown] == teamPlayer} };
    if (_markers isEqualTo []) exitWith {};
    if (_side isNotEqualTo teamPlayer) exitWith {};
    
    private _staticVehInit = {
        waitUntil { sleep 0.1; !isNil "serverInitDone" };
        params ["_veh", "_flagAction"];
        
        [_veh, _flagAction] remoteExec ["A3A_fnc_flagAction", [teamPlayer, civilian], _veh];
        
        if !(locked _veh < 2) exitWith {};
        private _saved = _veh in staticsToSave;
        private _flipped = _veh in staticsToFlip;
        _veh call ([A3A_fnc_lockStatic, A3A_fnc_unlockStatic] select (_saved && {XOR(A3A_enableVehiclesForAI, _flipped)}));

        // add *all* rebel vehicles to staticsToSave
        if (_saved) exitWith {};
        staticsToSave pushBack _veh;
        publicVariable "staticsToSave";
    };

    if (_veh isKindOf "StaticWeapon") then {
        _veh setCenterOfMass [(getCenterOfMass _veh) vectorAdd [0, 0, -1], 0];
        [_veh, "static"] spawn _staticVehInit;
    } else {
        [_veh, "vehiclestatic"] spawn _staticVehInit;
    };
};
Checks if ground vehicle/ship is near rebel marker
Only for teamPlayer side (rebel static weapons)
Static Weapons: Adjust center of mass to prevent tipping
Static Vehicles: Enable flag action and save system
Uses staticsToSave array for persistence
10. Civilian Vehicle Handlers

Sqf

Apply
if (_side == civilian) then {
    _veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_this select 0))) then {0;} else {(_this select 2);};}];
    
    if ((_veh isKindOf "Air")) exitWith {};

    _veh addEventHandler ["HandleDamage", {
        private _veh = _this select 0;
        if (side(_this select 3) == teamPlayer) then {
            _driverX = driver _veh;
            if (side group _driverX == civilian) then {_driverX leaveVehicle _veh};
            _veh removeEventHandler ["HandleDamage", _thisEventHandler];
        };
    }];
};
Wheel damage immunity for AI civilian drivers
If attacked by rebel: Civilian driver exits vehicle
Air vehicles excluded (handled separately)
11. Enemy Response to Damage

Sqf

Apply
if (_side == Invaders || _side == Occupants) then {
    _veh addEventHandler ["HandleDamage", {
        params ["_veh", "_part", "_damage", "_source"];
        if (_damage < 0.5) exitWith { nil };            // rough as hell, but whatever
        if (isNil "_source" or {isNull _source or side _source == side _veh}) exitWith { nil };

        _veh removeEventHandler ["HandleDamage", _thisEventHandler];
        if (_veh getVariable "ownerSide" != _veh getVariable "originalSide") exitWith { nil };

        // Add 1/3 cost to recent casualties list on server
        private _vehCost = A3A_vehicleResourceCosts getOrDefault [typeof _veh, 0];
        [_veh getVariable "ownerSide", getPos _veh, _vehCost/3, _source] remoteExec ["A3A_fnc_addRecentDamage", 2];

        // Attempt to call for support if there's a crew. Assume local, should be true
        if !(isNull group _veh) then { [group _veh, _source] spawn A3A_fnc_callForSupport };
        nil;
    }];

    // Event handler to (usually) get the crew out after crippling damage
    if (_veh isKindOf "Helicopter") then {
        _veh addEventHandler ["Dammaged", {
            params ["_veh"];
            if (canMove _veh) exitWith {};
            Debug("Downed heli handler triggered");
            group _veh leaveVehicle _veh;
            _veh removeEventHandler ["Dammaged", _thisEventHandler];
        }];
    };

    _veh addEventHandler ["IncomingMissile", {
        params ["_veh", "_ammo", "_source", "_instigator"];
        private _group = group _veh;
        if (isNull _group or { side _group == teamPlayer }) exitWith { _veh removeEventHandler ["IncomingMissile", _thisEventHandler] };
        private _isRival = (units _group) findIf {_unit getVariable ["isRival", false]} != -1;
        if (_isRival) exitWith { _veh removeEventHandler ["IncomingMissile", _thisEventHandler] };

        if (random 10 < tierWar + aggressionOccupants/10) then {
            [_group, _source] spawn A3A_fnc_callForSupport;
        }; 
    }];
};
HandleDamage (enemy vehicles):
Triggers at 0.5+ damage
Records 1/3 vehicle cost to recent damage system
Calls for support from nearby units
Removes itself after first trigger
Helicopter Dammaged: Dumps crew when vehicle cannot move
IncomingMissile: Chance-based support call (higher tier/aggression = more likely)
12. Artillery Detection

Sqf

Apply
if(isNumber (configFile >> "CfgVehicles" >> _typeX >> "artilleryScanner") && {(getNumber (configFile >> "CfgVehicles" >> _typeX >> "artilleryScanner") isEqualTo 1)}) then {
    _veh addEventHandler ["Fired", SCRT_fnc_common_triggerArtilleryResponseEH];
    if (!_excludeTrails) then {
        [_veh] call A3A_fnc_addArtilleryTrailEH;
    };
};
Checks config for artilleryScanner = 1
Adds fired event handler for AI artillery response
Optionally adds trail detection for player visibility
13. Capture Logic (GetIn Event)

Sqf

Apply
if (_side != teamPlayer) then
{
    _veh addEventHandler ["GetIn", {
        params ["_veh", "_role", "_unit"];
        if (side group _unit != teamPlayer) exitWith {};
        private _oldside = _veh getVariable ["ownerSide", teamPlayer];
        if (_oldside != teamPlayer) then
        {
            ServerDebug_2("%1 switching side from %2 to rebels", typeof _veh, _oldside);
            [_veh, teamPlayer, true] call A3A_fnc_vehKilledOrCaptured;
        };
        _veh removeEventHandler ["GetIn", _thisEventHandler];
    }];
};
Enemy vehicles: First rebel entry triggers capture
Calls vehKilledOrCaptured to switch sides and update resources
Removes itself after first capture
14. Airspace Control (Air Vehicles)

Sqf

Apply
if(_veh isKindOf "Air") then
{
    _veh addEventHandler ["GetIn", {
        params ["_veh", "_role", "_unit"];
        if((side (group _unit) == teamPlayer) && {isPlayer _unit}) then
        {
            [_veh] spawn A3A_fnc_airspaceControl;
        };
    }];
};
When player enters air vehicle: Starts airspace control script
Manages anti-air warnings and interception
15. Cargo Kill on Destruction

Sqf

Apply
if(([_veh] call A3A_Logistics_fnc_getVehCapacity) > 1) then {
    _veh addEventHandler ["Killed", {
        params ["_vehicle", "_killer", "_instigator", "_useEffects"];
        private _cargo = _vehicle call A3A_Logistics_fnc_getCargo;
        if (_cargo isEqualTo []) exitWith {};
        _cargo = _cargo select {typeOf _x isEqualTo FactionGet(reb, "lootCrate")};
        {
            _cargoItem setDamage 1; 
            [_x] spawn {
                params["_cargoItem"];
                sleep 4;
                deleteVehicle _cargoItem;
            };
        } forEach _cargo;
    }];
};
If vehicle can carry cargo: Destroy loot crates on vehicle death
Applies damage and delays deletion for visual effect
16. Vehicle Deletion Refund

Sqf

Apply
if (A3A_vehicleResourceCosts getOrDefault [typeof _veh, 0] > 0) then {
    _veh addEventHandler ["Deleted", A3A_fnc_vehicleDeletedEH];
};
If vehicle has resource cost: Refund when deleted
Tracks resource usage for game economy
17. Logistics Loading

Sqf

Apply
if([typeOf _veh] call A3A_Logistics_fnc_isLoadable) then {[_veh] call A3A_Logistics_fnc_addLoadAction;};
Adds load action to loadable vehicles
18. Cleanser and Initialization

Sqf

Apply
[_veh] spawn A3A_fnc_cleanserVeh;

if (_side != teamPlayer) then {
    [_veh, _side] call SCRT_fnc_misc_tryInitVehicle;
};

if (!isNull _veh) then {
    ["AIVehInit", [_veh, _side]] call EFUNC(Events,triggerEvent);
};
Spawns cleanser to delete destroyed-on-spawn vehicles
Applies faction-specific visual variants
Fires custom event for external systems
Where it leads:

Functions called:

A3A_fnc_vehKilledOrCaptured - Handles side switching and resource updates
A3A_fnc_smokeCoverAuto - Deploys smoke screen
A3A_fnc_addActionBreachVehicle - Adds breach action to armor
A3A_fnc_createVehicleCrew - Creates crew for UAVs
A3A_fnc_customHint - Shows UI messages
A3A_fnc_flagAction - Adds flag actions to statics
A3A_fnc_lockStatic / A3A_fnc_unlockStatic - Controls static weapon access
A3A_fnc_addRecentDamage - Records damage for AI response
A3A_fnc_callForSupport - Requests reinforcements
A3A_fnc_addArtilleryTrailEH - Adds artillery detection
A3A_fnc_airspaceControl - Manages air vehicle restrictions
A3A_fnc_vehicleDeletedEH - Handles resource refunds
A3A_fnc_cleanserVeh - Deletes vehicles destroyed on spawn
SCRT_fnc_misc_tryInitVehicle - Applies faction variants
A3A_fnc_initObject - Initializes utility items
A3A_fnc_vehicleTextureSync - Applies textures
A3A_Logistics_fnc_getVehCapacity / A3A_Logistics_fnc_getCargo - Cargo management
A3A_Logistics_fnc_isLoadable / A3A_Logistics_fnc_addLoadAction - Logistics support
Functions that call this:

A3A_fnc_spawnVehicle - Main vehicle spawner
A3A_fnc_createAttackVehicle - Attack force vehicle creation
A3A_fnc_patrolReinf - Reinforcement vehicles
Various mission spawning functions
Global variables modified:

staticsToSave - Array of static weapons to persist
staticsToFlip - Array of flipped vehicles
A3A_enableVehiclesForAI - Configuration flag
Synchronization/Network:

Uses remoteExec for flag actions and damage reporting
All event handlers are local to vehicle creation
Damage/kill events reported to server for resource tracking
Edge cases:

Multiple initialization: Protected by ownerSide check
UAV crew: Delete and recreate for proper AI behavior
Air vehicle restrictions: Prevents AI from hijacking player aircraft
Cargo destruction: Only affects loot crates, not all cargo
Resource refund: Only for vehicles with defined costs

Function: fn_attackHQ.sqf
What it does:
This function manages the special forces air attack against the player's HQ (Petros). It is a server-only function that creates a task, spawns an attacking force (mixing air and ground units), triggers artillery support, and monitors the engagement to determine success or failure based on Petros's status and the attacker's casualty count.

Context:

Scope: Server.
Environment: Scheduled (must be spawned).
Trigger: Usually called by the game system when enemy aggression levels trigger a major attack on the HQ.
How it does that:
The function follows a strict sequence of initialization, force generation, and lifecycle monitoring.

1. Parameter Validation & Initialization
First, the function validates execution context and parses arguments.

Sqf

Apply
if (!isServer) exitWith { Error("Server-only function miscalled") };

params ["_side", "_airbase", "_delay"];
private _targPos = markerPos "Synd_HQ";
private _faction = Faction(_side);
Logic: Ensures the function only runs on the server to prevent desync. It captures the attacker's side, the airbase used for the attack, and an optional delay.
Variable Setup: Synd_HQ is the hardcoded target. Faction(_side) retrieves the specific faction data (loadouts, vehicle types) for the attacker (Occupants or Invaders).
2. Forced Spawn & Task Creation
The HQ marker is forced to persist, and a defense task is created for players.

Sqf

Apply
forcedSpawn pushBack "Synd_HQ"; publicVariable "forcedSpawn";

private _taskId = "DEF_HQ" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [localize "STR_tasks_attackHq_desc", localize "STR_tasks_attackHq_header", respawnTeamPlayer],
    _targPos,
    true,
    10,
    true,
    "Defend",
    true
] call BIS_fnc_taskCreate;

[_taskId, "DEF_HQ", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Forced Spawn: Prevents the HQ from despawning if players move away, ensuring the attack is always visible.
Task Creation: Uses BIS_fnc_taskCreate to define the objective. It is localized (multi-language support). The task is initially set to "CREATED" status and updated remotely to all clients.
3. UAV Support Calculation
A UAV is spawned as a support asset. The availability of UAVs affects the number of ground vehicles spawned.

Sqf

Apply
private _uavSupp = ["UAV", _side, "attack", 500, objNull, _targPos, 0, 0] call A3A_fnc_createSupport;
private _vehCount = round (1 + random 1 + 2 * A3A_balancePlayerScale + ([0, 0.5] select (_uavSupp == "")));
Support Call: A3A_fnc_createSupport is called to spawn a UAV. If the string _uavSupp returns empty, it indicates failure to spawn.
Vehicle Count: The number of vehicles is calculated dynamically. The A3A_balancePlayerScale variable ensures more vehicles spawn against larger player groups. The ternary operator [0, 0.5] adds a bonus vehicle if a UAV failed to spawn (fallback mechanism).
4. Dynamic Delay Calculation
If no delay was provided, it calculates one based on player scale to give players a fair reaction time.

Sqf

Apply
if (isNil "_delay") then { _delay = 300 / A3A_balancePlayerScale };
Logic: Base delay is 300 seconds (5 minutes). This is divided by the player scale factor. More players = shorter delay (attack hits faster).
5. Attacking Force Generation
Creates a mixed air/ground force using A3A_fnc_createAttackForceMixed.

Sqf

Apply
private _data = [_side, _airbase, _targPos, "attack", _vehCount, _delay, ["airboost", "specops"]] call A3A_fnc_createAttackForceMixed;
_data params ["_resources", "_vehicles", "_crewGroups", "_cargoGroups"];
Parameters: Side, source base, target position, resource pool ("attack"), vehicle count, calculated delay, and modifiers (airboost adds air units, specops adds elite infantry).
Output: _data is an array containing resources spent, spawned vehicles, crew groups, and cargo (infantry) groups.
6. Support Strike Registration
Registers the attack as a support strike in the system so it can be tracked and counteracted.

Sqf

Apply
A3A_supportStrikes pushBack [_side, "TROOPS", _targPos, time + 1800, 1800, _resources];
Global Variable: Modifies A3A_supportStrikes, a public array used to track active enemy offensives. It adds an entry with a timestamp expiration (1800 seconds / 30 minutes).
7. Artillery Support
The function triggers a randomized artillery barrage targeting the HQ vicinity.

Sqf

Apply
call {
    private _target = _targPos getPos [random 100, random 360];
    private _vehicles = vehicles inAreaArray [_targPos, 100, 100];
    _vehicles = _vehicles select { canFire _x and _x isKindOf "StaticWeapon" };
    if !(_vehicles isEqualTo []) then { _target = selectRandom _vehicles };

    [_side, _target, "attack", 2, 0, 0] call A3A_fnc_requestArtillery;
};
Targeting: Logic seeks out static weapons (HMGs/AT) near the HQ to prioritize. If none exist, it fires at a random position near the HQ.
Request: Calls A3A_fnc_requestArtillery to execute the actual fire mission.
8. Engagement Loop (The "Watchdog")
A loop monitors the battle state. It checks every 30 seconds to see if the attack should end.

Sqf

Apply
private _timeout = time + 900;
private _soldiers = [];
{ _soldiers append units _x } forEach _cargoGroups;
private _origPetros = petros;

while {true} do
{
    private _curSoldiers = { !fleeing _x and _x call A3A_fnc_canFight } count _soldiers;
    if (_curSoldiers < count _soldiers * 0.33) exitWith { ... }; // Defeat
    if (time > _timeout) exitWith { ... }; // Timeout
    if (!alive _origPetros) exitWith { ... }; // Victory
    sleep 30;
};
State Tracking: It tracks the original Petros unit (_origPetros) and a flat list of all attacking infantry (_soldiers).
Exit Conditions:
Defeat: If less than 33% of soldiers remain able to fight.
Timeout: If 900 seconds (15 mins) pass without a resolution.
Success: If Petros is dead.
9. Cleanup & Despawn
When the loop exits, the function cleans up remaining units and vehicles.

Sqf

Apply
{ [_x] spawn A3A_fnc_VEHDespawner } forEach _vehicles;
{ [_x] spawn A3A_fnc_enemyReturnToBase } forEach (_crewGroups + _cargoGroups);
Vehicles: Passed to VEHDespawner to be deleted if they remain unused.
Units: Passed to enemyReturnToBase to simulate retreating behavior (they head back to their base and eventually despawn).
10. Task Resolution & Rewards
Determines the task state and awards score/money to players.

Sqf

Apply
if (!alive _origPetros) then {
    [_taskId, "DEF_HQ", "FAILED"] call A3A_fnc_taskSetState;
} else {
    [_taskId, "DEF_HQ", "SUCCEEDED"] call A3A_fnc_taskSetState;
    // ... Award loop ...
};
Logic: Compares Petros's status against the stored _origPetros handle.
Rewards: Iterates through SCRT_fnc_misc_getRebelPlayers to award tierWar scaled score and money.
11. Final State Reset
Resets global mission variables and cleans up the forced spawn.

Sqf

Apply
bigAttackInProgress = false; publicVariable "bigAttackInProgress";
forcedSpawn = forcedSpawn - ["Synd_HQ"]; publicVariable "forcedSpawn";
[_taskId, "DEF_HQ", 1200] spawn A3A_fnc_taskDelete;
Global Cleanup: Unsets the "big attack" flag so other attacks can start. Removes the HQ from forced spawns.
Task Deletion: Schedules the task to be deleted from the players' task list after 1200 seconds (20 minutes).
Where it leads:
Called Functions:
A3A_fnc_createSupport: Spawns the UAV.
A3A_fnc_taskCreate: Initializes the mission.
BIS_fnc_taskCreate: (Internal) Arma engine task creation.
A3A_fnc_createAttackForceMixed: Core function to spawn the mixed air/ground force.
A3A_fnc_requestArtillery: Calls in the artillery barrage.
A3A_fnc_canFight: Checks if a unit is combat capable.
A3A_fnc_VEHDespawner: Cleans up vehicles.
A3A_fnc_enemyReturnToBase: Manages retreating infantry.
A3A_fnc_taskSetState: Updates mission status (Success/Fail).
A3A_fnc_addAggression: Modifies global aggression levels if players are nearby.
A3A_fnc_addScorePlayer / A3A_fnc_addMoneyPlayer: Awards resources.
A3A_fnc_taskDelete: Removes the task.
Dependent Functions:
Called indirectly by mission controllers or reinforcementsAI when aggression thresholds are met.
System Integration:
Integrates with the A3A_taskCount system to generate unique IDs.
Modifies A3A_supportStrikes for the global support tracking system.
Interacts with forcedSpawn to ensure persistence.
Global Variables Modified:
forcedSpawn: Added/Removed "Synd_HQ".
A3A_supportStrikes: Pushes a new entry.
bigAttackInProgress: Boolean flag toggled.
publicVariable: Used to sync forcedSpawn and bigAttackInProgress across the network.
Synchronization/Network:
Uses remoteExecCall for task updates to ensure all clients receive the correct task state.
Uses publicVariable to ensure the server state (attack in progress) is reflected on all clients and heads.
Calculates delays based on A3A_balancePlayerScale, a server-side variable that estimates player "weight."

1. fn_availableBasesAir.sqf
Function Name: 
fn_availableBasesAir.sqf

What it does: This function selects from a distance-weighted list of available enemy air bases or returns the complete list. It's designed to provide intelligent spawning locations for air units by checking multiple criteria: idle status, spawn readiness, distance, and garrison strength. The carrier is always available as a fallback option, ensuring the function always returns something.

When/Why it's called:

Called when enemy air reinforcements need to spawn (quick reaction forces)
Used by air support or air attack mission generators
Invoked when determining spawn locations for air patrol units
Typically called from mission generation scripts or enemy reinforcement logic
How it does that:

Step 1: Parameter Validation and Initialization

Sqf

Apply
params ["_side", "_targPos", ["_returnAll", false]];

private _freeAirports = [];
private _weights = [];
Extracts three parameters: enemy side (_side), target position (_targPos), and optional flag (_returnAll)
Initializes empty arrays for storing valid airports and their associated weights
Uses SQF's params command with optional parameter handling (default false for _returnAll)
Step 2: Main Airbase Selection Loop

Sqf

Apply
{
    if (sidesX getVariable [_x,sideUnknown] != _side) then {continue};
    if (dateToNumber date < server getVariable [_x, 0]) then {continue};
    if (spawner getVariable _x == 0) then {continue};
    if (count (garrison getVariable [_x,[]]) < 16) then {continue};

    _freeAirports pushBack _x;
    private _effDist = abs ((markerPos _x distance2D _targPos) - 5000);
    _weights pushBack (1 / _effDist^2);
} forEach airportsX;
Iterates through all airports in airportsX array (global variable containing all airport markers)
Validation 1: Checks if airport belongs to the enemy side using sidesX namespace
Validation 2: Checks if airport is idle (not recently used) using server namespace timestamp
Validation 3: Checks if spawner is ready (value != 0) using spawner namespace
Validation 4: Checks if garrison has at least 16 units
Weight Calculation: Uses distance from target to calculate weight, favoring mid-distance spawns (5000m preference)
Weight formula: 1 / (distance - 5000)^2 creates stronger preference for distances near 5000m
Pushes valid airport markers and calculated weights to respective arrays
Step 3: Carrier Fallback Addition

Sqf

Apply
private _carrier = ["CSAT_carrier", "NATO_carrier"] select (_side == Occupants);
_freeAirports pushBack _carrier;
_weights pushBack (1 / (markerPos _carrier distance2D _targPos)^2);
Selects appropriate carrier marker based on side (CSAT for CSAT, NATO for NATO)
Always adds carrier to available options regardless of other checks
Calculates weight based on carrier distance to target
Ensures at least one option is always available
Step 4: Return Logic

Sqf

Apply
if (_returnAll) exitWith { [_freeAirports, _weights] };
_freeAirports selectRandomWeighted _weights;
If _returnAll is true, returns both arrays for external processing
Otherwise, selects and returns one random airport based on calculated weights
Uses SQF's selectRandomWeighted for probability-based selection
Where it leads:

Functions Called:

markerPos - Returns position of a marker (Built-in Arma function)
sidesX getVariable - Retrieves side ownership from global namespace
dateToNumber - Converts date to number for timestamp comparison (Built-in Arma function)
server getVariable - Retrieves idle timestamp from server namespace
spawner getVariable - Checks spawner state from spawner namespace
garrison getVariable - Retrieves garrison units from garrison namespace
count - Counts array elements (Built-in Arma function)
abs - Absolute value calculation (Built-in Arma function)
distance2D - 2D distance calculation (Built-in Arma function)
selectRandomWeighted - Weighted random selection (Built-in SQF function)
Functions That Depend On This:

createAttackForceAir.sqf - Uses for air attack force spawning
createAttackForceMixed.sqf - Uses for mixed force spawning
SUP_QRFAir.sqf - Uses for quick reaction force air support
SUP_airstrike.sqf - May use for airstrike base selection
Enemy reinforcement mission generators
Global Variables Modified:

None - This is a pure query function, doesn't modify any global state
System Fit: Part of the enemy reinforcement system. Works alongside spawn placement validation and mission generation. Integrates with the spawn management system (spawner namespace) and garrison system. Ensures enemy air units spawn from appropriately defended bases.

Network/Synchronization:

Queries server-side namespaces (server, spawner, garrison, sidesX)
Should be called server-side or on client with server context
No network traffic beyond namespace queries (already synchronized)
No side effects, safe to call frequently
Edge Cases:

Returns nil if no airports satisfy conditions (but carrier ensures this doesn't happen)
If all airports are invalid except carrier, carrier will be selected
If _returnAll is true, arrays may be empty if no airports satisfy conditions
2. fn_availableBasesLand.sqf
Function Name: 
fn_availableBasesLand.sqf

What it does: Selects from a distance-weighted list of available enemy land bases or returns the complete list. Checks idle status, spawn readiness, garrison strength, spawn position availability, and pathfinding connectivity. Uses a pre-filtered list of land support markers based on target position.

When/Why it's called:

When enemy ground reinforcements need to spawn
For land attack mission generation
Vehicle convoy spawning
Quick reaction force deployment
Any mission requiring ground unit deployment
How it does that:

Step 1: Import and Setup

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_side", "_target", ["_returnAll", false]];
Includes script component header for debugging/error handling
Fixes line numbers for error reporting
Extracts parameters: enemy side, target (position or marker name), and return flag
Step 2: Target Analysis and Filtering

Sqf

Apply
private _lowAir = Faction(_side) getOrDefault ["attributeLowAir", false];
private _nearMarkers = [_target, _lowAir] call A3A_fnc_findLandSupportMarkers;
Retrieves faction attribute for low air capability
Calls findLandSupportMarkers to get pre-filtered list of land-based markers
This pre-filtering reduces processing time and ensures relevance
Step 3: Threat Detection

Sqf

Apply
private _rebelSpawners = units teamPlayer select { _x getVariable ["spawner", false] };
Collects all player units flagged as spawners (active spawn points)
Used to avoid spawning near active rebel operations
Step 4: Main Land Base Selection Loop

Sqf

Apply
private _freeBases = [];
private _weights = [];
{
    _x params ["_marker", "_navDist"];
    if (sidesX getVariable [_marker, sideUnknown] != _side) then {continue};
    if (dateToNumber date < server getVariable [_marker, 0]) then {continue};
    if ([_marker, "Vehicle"] call A3A_fnc_countFreeSpawnPositions == 0) then {continue};
    if (count (garrison getVariable [_marker,[]]) < 16) then {continue};
    if (_rebelSpawners inAreaArray [markerPos _marker, 700, 700] isNotEqualTo []) then {continue};

    _freeBases pushBack _marker;
    _weights pushBack (1 / _navDist^2);
} forEach _nearMarkers;
Iterates through pre-filtered land support markers with navigation distances
Validation 1: Side ownership check
Validation 2: Idle timestamp check
Validation 3: Vehicle spawn position availability (count > 0)
Validation 4: Minimum garrison size (16 units)
Validation 5: No rebel spawners within 700m radius
Weight Calculation: Uses pre-calculated navigation distance, favoring closer bases
Weight formula: 1 / navDist^2 - stronger preference for closer bases
Pushes valid bases and weights
Step 5: Return Logic

Sqf

Apply
if (_returnAll) exitWith { [_freeBases, _weights] };
_freeBases selectRandomWeighted _weights;
Returns all bases/weights if requested
Otherwise performs weighted random selection
Where it leads:

Functions Called:

A3A_fnc_findLandSupportMarkers - Returns filtered list of land support markers
Faction - Faction helper function
sidesX getVariable - Side ownership check
dateToNumber - Date to timestamp conversion
server getVariable - Idle timestamp retrieval
A3A_fnc_countFreeSpawnPositions - Counts available spawn positions
garrison getVariable - Garrison unit retrieval
units teamPlayer - Gets player units
markerPos - Marker position retrieval
inAreaArray - Spatial query for units in area
Functions That Depend On This:

createAttackForceLand.sqf - Land attack force generation
createAttackForceMixed.sqf - Mixed force generation
SUP_QRFLand.sqf - Land quick reaction forces
Enemy convoy spawning systems
Reinforcement mission generators
Global Variables Modified:

None - Pure query function, no state modification
System Fit: Integrates with the pathfinding system (findNavDistance, findLandSupportMarkers), garrison management, and spawn placement systems. Part of the comprehensive enemy ground reinforcement framework.

Network/Synchronization:

Queries multiple synchronized namespaces
All data sources are server-authoritative
No network traffic beyond namespace reads
Safe for client-side calls with proper context
Edge Cases:

Returns nil if no land bases satisfy conditions
May return empty arrays if _returnAll is true and no valid bases
Navigation distance used for weight calculation requires valid pathfinding data
Commented Unused Code: The function contains an extensive commented-out section showing an older implementation that:

Used direct distance checks instead of navigation distance
Required spawner state to be 2 (dangerous)
Included pathfinding connectivity checks
Processed all outposts, airports, and milbases directly
This provides historical context but is not active in current implementation
3. fn_calculateMarkerArea.sqf
Function Name: 
fn_calculateMarkerArea.sqf

What it does: Calculates the surface area of an Arma marker based on its shape and size. Supports both ellipse and rectangle markers. Returns 0 for unrecognized shapes.

When/Why it's called:

Mission area calculations for spawning/despawning logic
Determining coverage area for patrols or alerts
Calculating garrison requirements based on base size
Vehicle placement spacing calculations
Visual feedback for area effects
How it does that:

Step 1: Parameter Extraction and Initialization

Sqf

Apply
params ["_marker"];

private _result = 0;
private _size = getMarkerSize _marker;
Extracts single parameter: marker name
Initializes result to 0 (default for invalid shapes)
Gets marker dimensions (width, height) from engine
Step 2: Shape Detection and Calculation

Sqf

Apply
switch (markerShape _marker) do {
    case "ELLIPSE": {
      _result = PI * (_size select 0) * (_size select 1);
    };
    case "RECTANGLE": {
      _result = (_size select 0) * (_size select 1) * 4;
    };
};
Uses markerShape to determine geometry type
ELLIPSE: Calculates area using π × width × height (engine returns width/height as diameters)
RECTANGLE: Calculates area as width × height (engine returns width/height as half-dimensions, multiplied by 4)
Note: In the original code, there are two "ELLIPSE" cases (likely a bug). The second should be "RECTANGLE".
Step 3: Return Result

Sqf

Apply
_result;
Returns calculated area or 0 for unsupported shapes
Where it leads:

Functions Called:

markerShape - Returns marker geometry type (Built-in Arma function)
getMarkerSize - Returns marker dimensions [width, height] (Built-in Arma function)
PI - Mathematical constant π (Built-in SQF constant)
Functions That Depend On This:

A3A_fnc_sizeMarker (likely) - Wrapper for marker sizing
garrisonSize.sqf - Determines required garrison based on area
spawnVehicleAtMarker.sqf - May use for spawn placement spacing
Mission generation for area-based calculations
Global Variables Modified:

None - Pure mathematical calculation
System Fit: Utility function for spatial calculations. Used by larger systems to make decisions based on marker geometry. Part of the mission/ambient management infrastructure.

Network/Synchronization:

Local calculation only
No network traffic
Deterministic (same input produces same output)
Edge Cases:

Bug Alert: The function has duplicate "ELLIPSE" cases. The second should be "RECTANGLE" to correctly handle rectangle markers
Returns 0 for unknown shapes (e.g., "ICON" markers with 0 area)
Marker sizes might be negative if marker is flipped, but area remains positive
Marker rotation doesn't affect area calculation
Technical Details:

Uses basic geometry formulas
Assumes marker sizes are in engine units (meters)
For ellipses, engine returns full width/height, so π×w×h is correct
For rectangles, engine returns half-widths, so w×h×4 = (2w)×(2h) = full area
4. fn_cargoSeats.sqf
Function Name: 
fn_cargoSeats.sqf

What it does: Determines appropriate unit composition for vehicle cargo based on available cargo seats and vehicle/faction type. Returns squad/loadout configurations for militia, police, rival, and standard faction vehicles.

When/Why it's called:

When spawning vehicles with AI crews
Vehicle crew assignment logic
Garrison vehicle configuration
Reinforcement squad assignment
Mission-specific vehicle loading
How it does that:

Step 1: Imports and Parameter Extraction

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
private _filename = "fn_cargoSeats";
params ["_veh", "_sideX"];
Sets up error handling and debugging context
Stores filename for error reporting
Extracts vehicle and side parameters
Step 2: Faction and Vehicle Type Identification

Sqf

Apply
private _faction = Faction(_sideX);
private _isMilitia = _veh in ((_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaTrucks") + (_faction get "vehiclesMilitiaCars") + (_faction get "vehiclesMilitiaAPCs"));
Retrieves faction data for the given side
Determines if vehicle is militia-type by checking against faction vehicle arrays
Uses associative array (hashmap) for fast lookups
Step 3: Seat Counting

Sqf

Apply
private _totalSeats = [_veh, true] call BIS_fnc_crewCount;
private _crewSeats = [_veh, false] call BIS_fnc_crewCount;
private _cargoSeats = _totalSeats - _crewSeats;
if (_veh in (_faction get "vehiclesPolice")) then { _cargoSeats = 6 min _cargoSeats };
Calculates total seats including crew, passengers, and FFV positions
Calculates crew-only seats
Derives cargo seats by subtraction
Special handling for police vehicles: caps at 6 cargo seats
Step 4: Low-Capacity Vehicle Handling

Sqf

Apply
if (_cargoSeats < 2) exitwith { [] };
Returns empty array for vehicles with fewer than 2 cargo seats
Step 5: Small Capacity (2-3 seats)

Sqf

Apply
if (_cargoSeats < 4) exitWith
{
	if (_isMilitia) exitWith { selectRandom ([_faction, "groupsTierSmall", 0] call SCRT_fnc_unit_flattenTier) };
	if (_veh in (_faction get "vehiclesPolice")) exitWith { _faction get "groupPolice" };
	selectRandom ([_faction, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier);
};
For vehicles with 2-3 cargo seats:
Militia: Random small-tier militia group
Police: Static police group
Standard: Random small-tier faction group
Step 6: Medium Capacity (4-5 seats or 6 seats randomly)

Sqf

Apply
if (_cargoSeats < 6 or { _cargoSeats == 6 and random 3 < 1}) exitWith
{
	if (_isMilitia) exitWith { selectRandom ([_faction, "groupsTierMedium", 0] call SCRT_fnc_unit_flattenTier) };
	if (_veh in (_faction get "vehiclesPolice")) exitWith { (_faction get "groupPolice") + [_faction get "unitPoliceGrunt", _faction get "unitPoliceGrunt"] };
	selectRandom ([_faction, "groupsTierMedium"] call SCRT_fnc_unit_flattenTier);
};
For 4-5 seats OR 6 seats with 1/3 probability:
Militia: Random medium-tier militia group
Police: Base police group plus 2 extra grunts
Standard: Random medium-tier faction group
Step 7: Large Capacity (6+ seats)

Sqf

Apply
private _squad = call {
	if (_isMilitia) exitWith { selectRandom ([_faction, "groupsTierSquads", 0] call SCRT_fnc_unit_flattenTier) };
	if (_veh in (_faction get "vehiclesPolice")) exitWith { (_faction get "groupPolice") + [_faction get "unitPoliceGrunt", _faction get "unitPoliceGrunt"] + [_faction get "unitPoliceGrunt", _faction get "unitPoliceGrunt"]};
    selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier);
};
For large capacity vehicles:
Militia: Random squad-tier militia group
Police: Base police group plus 4 extra grunts
Standard: Random squad-tier faction group
Step 8: Squad Size Adjustment

Sqf

Apply
while { count _squad > _cargoSeats } do {
	_squad deleteAt (1 + floor random (count _squad - 1));
};
_squad;
Reduces squad size if it exceeds cargo capacity
Randomly removes non-leaders (keeps squad leader at index 0)
Returns final squad configuration
Where it leads:

Functions Called:

Faction - Faction data retrieval
BIS_fnc_crewCount - Arma's crew counting function
SCRT_fnc_unit_flattenTier - Flattens tiered group configurations
selectRandom - Random selection (Built-in SQF)
count - Array size (Built-in SQF)
deleteAt - Array element removal (Built-in SQF)
floor - Math function (Built-in SQF)
random - Random number generation (Built-in SQF)
Functions That Depend On This:

spawnVehicle.sqf - Vehicle crew assignment
createVehicleCrew.sqf - Crew creation for spawned vehicles
createAttackVehicle.sqf - Attack vehicle configuration
reinforcementsAI.sqf - Reinforcement vehicle loading
garrisonUpdate.sqf - Garrison vehicle assignment
Global Variables Modified:

None - Pure calculation function
System Fit: Core component of the spawn/loadout system. Works with faction templates and unit tiering. Ensures appropriate unit composition for different vehicle types and factions.

Network/Synchronization:

Local calculation only
Uses faction data (synchronized server-side)
Deterministic except for random selection
No network traffic
Edge Cases:

Police vehicles have 6-seat cap for balance
Militia vehicles get specific militia groups
6-seat vehicles have random chance of using medium or large group
Squad leader never removed during size adjustment
Empty squads possible for low-capacity vehicles
Technical Details:

Uses faction data structure (hashmap-like arrays)
Unit tiering system provides scalable difficulty
Squad flattening converts tiered groups to flat arrays
Random seat allocation for medium vehicles adds variety
5. fn_civVEHinit.sqf
Function Name: 
fn_civVEHinit.sqf

What it does: Initializes civilian vehicles with appropriate event handlers and simulation management. Adds damage handling for wheels, sets up cleanup systems, and manages simulation enable/disable for performance optimization.

When/Why it's called:

When civilian vehicles spawn in the world
During ambient civilian traffic generation
When mission spawns civilian vehicles
As part of civilian vehicle creation pipeline
How it does that:

Step 1: Parameter Extraction and Setup

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

private _veh = _this select 0;
private _vehCrew = crew _veh;
Sets up debugging context
Extracts vehicle from passed arguments
Gets current crew members
Step 2: Vehicle-Type Specific Damage Handling

Sqf

Apply
if (_veh isKindOf "Car") then {
	_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)};}];
};
Only applies to cars (not boats, planes, etc.)
HandleDamage Event Handler: Prevents non-player drivers from taking wheel damage from non-explosive sources
Logic: If damage is to wheel, from no source (environment), and not player-driven → return 0 damage
Otherwise returns original damage value
Improves vehicle survival and reduces realistic-but-frustrating failures
Step 3: Cleanup System Setup

Sqf

Apply
[_veh] spawn A3A_fnc_cleanserVeh;
Spawns asynchronous cleanup process
Checks vehicle health after 5 seconds
Deletes vehicle if destroyed on spawn (prevents ghost wrecks)
Step 4: Death Handler

Sqf

Apply
_veh addEventHandler ["Killed",{[_this select 0] spawn A3A_fnc_postmortem}];
Adds killed event handler
Spawns postmortem function for loot creation/score calculation
Handles aftermath of vehicle destruction
Step 5: Empty Vehicle Simulation Management

Sqf

Apply
if (count _vehCrew == 0) then {
	sleep 10;
	[_veh,false] remoteExec ["enableSimulationGlobal",2];
	_veh addEventHandler ["GetIn", {
		_veh = _this select 0;
		if (!simulationEnabled _veh) then {[_veh,true] remoteExec ["enableSimulationGlobal",2]};
		[_veh] spawn A3A_fnc_VEHdespawner;
	}];
	_veh addEventHandler ["HandleDamage", {
		_veh = _this select 0;
		if (!simulationEnabled _veh) then {[_veh,true] remoteExec ["enableSimulationGlobal",2]};
	}];
};
Only for empty vehicles:
Waits 10 seconds for initial physics settlement
Disables simulation globally for performance (server optimization)
GetIn Handler: Re-enables simulation when entered
HandleDamage Handler: Re-enables simulation when damaged (ensures physics work)
Both handlers then spawn VEHdespawner for eventual cleanup
Step 6: Event Trigger

Sqf

Apply
["civVehInit", [_veh]] call EFUNC(Events,triggerEvent);
Triggers custom event system for mod compatibility
Allows other systems to respond to civilian vehicle initialization
Where it leads:

Functions Called:

A3A_fnc_cleanserVeh - Cleanup handler for spawn issues
A3A_fnc_postmortem - Post-death processing (loot/score)
enableSimulationGlobal - Global simulation control (Built-in Arma)
A3A_fnc_VEHdespawner - Vehicle despawning system
EFUNC(Events,triggerEvent) - Custom event system
Functions That Depend On This:

spawnCivilianVehicles (ambient system)
Mission scripts spawning civilian vehicles
City/road system for civilian traffic
Global Variables Modified:

Simulation state of specific vehicle (via remote execution)
Event listeners may respond to "civVehInit" event
System Fit: Part of ambient civilian system. Balances performance (simulation disabling) with functionality (reactivation when needed). Integrates with cleanup and death handling systems.

Network/Synchronization:

Uses remoteExec to enable/disable simulation globally
Event triggers are synchronous on server, may propagate to clients
Event handlers are local to vehicle (run where vehicle exists)
Edge Cases:

Only applies to empty vehicles initially
Wheel damage prevention may conflict with realism mods
10-second sleep before disabling simulation allows physics to settle
Simulation reactivation occurs on damage or entry (may miss rare events)
Performance Considerations:

Simulation disabling reduces server load for distant/unused vehicles
Re-enabling ensures vehicles work when interacted with
Balance between performance and gameplay experience
6. fn_cleanserVeh.sqf
Function Name: 
fn_cleanserVeh.sqf

What it does: Performs post-spawn cleanup for vehicles. Waits 5 seconds, then checks if the vehicle is null or destroyed, and deletes it if needed. Provides debug logging for spawn issues.

When/Why it's called:

Immediately after vehicle spawning
As part of vehicle creation pipeline
When vehicles spawn destroyed (bug prevention)
To clean up spawn artifacts
How it does that:

Step 1: Delay and Null Check

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_veh"];

sleep 5;

if (isNull _veh) exitWith {
    Debug_1("%1 is null on spawn", typeof _veh);
};
Sets up debugging context
Extracts vehicle parameter
Waits 5 seconds for spawn completion and physics
Checks if vehicle is null (failed spawn)
Logs debug message with vehicle type
Step 2: Destruction Check

Sqf

Apply
if (!alive _veh) then
{
    private _nearestMarker  = [markersX, getPosATL _veh] call BIS_fnc_nearestPosition;
    Debug_3("%1 destroyed on spawn at %2, near %3", typeof _veh, getPosATL _veh, _nearestMarker);
	deleteVehicle _veh;
};
Checks if vehicle is destroyed immediately after spawn
Note: This logic is flawed - if vehicle dies during the 5-second wait, this executes
Finds nearest marker for debug context
Logs detailed debug information (type, position, nearby marker)
Deletes the dead vehicle to prevent ghost wrecks
Where it leads:

Functions Called:

Debug_1, Debug_3 - Debug logging functions
typeof - Vehicle class name (Built-in Arma)
alive - Vehicle alive check (Built-in Arma)
getPosATL - Position relative to terrain (Built-in Arma)
BIS_fnc_nearestPosition - Find closest marker (Built-in Arma)
deleteVehicle - Remove vehicle (Built-in Arma)
Functions That Depend On This:

fn_civVEHinit.sqf
 - Called for civilian vehicles
spawnCivilianVehicles - Ambient civilian system
Vehicle spawning functions needing cleanup
Global Variables Modified:

None - Deletes specific vehicle instance
System Fit: Part of vehicle spawning cleanup system. Prevents invalid/dead vehicles from remaining in world. Supports debug logging for spawn issues.

Network/Synchronization:

Runs locally on machine where vehicle spawned
Uses debug logging (likely global or logged)
deleteVehicle is network-aware
Edge Cases:

Bug Potential: 5-second wait may miss vehicles that despawn naturally
Logic Flaw: The !alive check executes after 5 seconds - if vehicle dies during wait, it gets deleted
Debug messages assume debug system exists globally
markersX must be defined globally
Performance:

Async spawn process doesn't block spawning
Minimal overhead (5-second delay, single check)
Debug logging only when issues occur
7. fn_countFreeSpawnPositions.sqf
Function Name: 
fn_countFreeSpawnPositions.sqf

What it does: Counts empty spawn positions on a marker of a specific type (vehicle, mortar, helicopter, or plane). Returns the number of available positions.

When/Why it's called:

Before spawning vehicles to find available space
During base/garrison management
When validating spawn locations
For spawn placement optimization
How it does that:

Step 1: Parameter Extraction

Sqf

Apply
params ["_marker", "_type"];
Extracts marker name and spawn position type
Step 2: Variable Name Construction

Sqf

Apply
private _varName = format ["%1_%2_used", _marker, tolower _type];
Creates unique variable name for the marker/type combination
Uses lowercase for consistency
Format: markerName_typeUsed (e.g., base1_vehicle_used)
Step 3: Used Positions Retrieval

Sqf

Apply
private _used = spawner getVariable [_varName, []];
Gets array of "used" spawn positions from spawner namespace
Default to empty array if not found
Each position likely has a boolean flag (true=occupied, false=free)
Step 4: Count Free Positions

Sqf

Apply
{ !_x } count _used;
Uses SQF's count with condition to count elements where value is false
Returns count of free (false) positions
Efficient single-pass counting
Where it leads:

Functions Called:

format - String formatting (Built-in SQF)
tolower - Case conversion (Built-in SQF)
spawner getVariable - Spawner namespace retrieval
count with condition - Conditional counting (Built-in SQF)
Functions That Depend On This:

fn_availableBasesLand.sqf
 - Validates spawn positions available
spawnVehicleAtMarker.sqf - Finds available slot for spawning
freeSpawnPositions.sqf - Likely similar functionality
Vehicle placement systems
Global Variables Modified:

None - Pure query function
System Fit: Core part of spawn position management system. Works with spatial positioning to ensure vehicles don't overlap. Used by reinforcement and mission systems.

Network/Synchronization:

Queries spawner namespace (server-synchronized)
No network traffic beyond namespace read
Should be called server-side or with proper context
Edge Cases:

If variable doesn't exist, returns 0 (empty array has 0 false elements)
Type must match exactly (case-sensitive except for conversion)
Marker must be registered in spawner system
Technical Details:

Uses SQF's efficient conditional counting
Array of booleans indicates occupancy
Assumes spawner namespace is properly maintained
Type normalization prevents typos
8. fn_calculateMarkerArea.sqf (Bug Fix Implementation)
What it does (Corrected): Calculates the surface area of an Arma marker. Supports ellipses (area = π × width × height) and rectangles (area = width × height). Returns 0 for unknown shapes.

Corrected Implementation:

Sqf

Apply
params ["_marker"];

private _result = 0;
private _size = getMarkerSize _marker;

switch (markerShape _marker) do {
    case "ELLIPSE": {
      _result = PI * (_size select 0) * (_size select 1);
    };
    case "RECTANGLE": {
      _result = (_size select 0) * (_size select 1) * 4;
    };
};

_result;
Bug Explanation: The original code had two "ELLIPSE" cases in the switch statement. The second should be "RECTANGLE" to correctly handle rectangle markers. Without this fix, rectangle markers would return 0 area (or be handled by the first ELLIPSE case, producing incorrect results).

fn_createAIAirplane.sqf
Function Name: createAIAirplane.sqf
What it does: This function spawns all AI (AI vs. players) airbase facilities, including SAM sites, static defenses, aircraft (CAS, AA, transport, etc.), patrol vehicles, and garrison units. It's the main spawner for airbase locations. The function runs on the server only and handles dynamic spawning, despawning, and persistent state management for airbase objects. It's called when an airbase marker needs to be populated with AI forces.

How it does that:

Input Validation and Setup:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer and hasInterface) exitWith{};
params ["_markerX"];

//Not sure if that ever happens, but it reduces redundance
if(spawner getVariable _markerX == 2) exitWith {};
The function first includes necessary script components and line number fixes.
It exits immediately if not running on the server or if running on a client with interface (player).
It takes the marker name _markerX as parameter.
It checks the spawner variable to avoid duplicate spawning (value 2 indicates already spawned).
Initialization of Arrays and Variables:

Sqf

Apply
ServerInfo_1("Spawning Airbase %1", _markerX);

private _vehiclesX = [];
private _groups = [];
private _soldiers = [];
private _props = [];
private _dogs = [];
private _spawnsUsed = [];

_positionX = getMarkerPos (_markerX);
private _patrolSize = [_markerX] call A3A_fnc_sizeMarker;

private _size = [_markerX] call A3A_fnc_sizeMarker;

private _frontierX = [_markerX] call A3A_fnc_isFrontline;
private _busy = false;      //if (dateToNumber date > server getVariable _markerX) then {false} else {true};
private _nVeh = round (_size/60);

private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _faction = Faction(_sideX);
Logs the spawning event with server info.
Initializes empty arrays for tracking vehicles, groups, soldiers, props (sandbags), and dogs.
Gets the marker position and size.
Determines if it's a frontier marker.
Sets a _busy flag (currently always false, comment suggests it was used for time-based spawning).
Calculates expected number of vehicles based on marker size.
Gets the side (Occupants/Invaders) and faction for the marker.
SAM Site Spawning:

Sqf

Apply
private _radarType = _faction getOrDefault ["vehicleRadar", ""];
private _samType = _faction getOrDefault ["vehicleSam", ""];

if (_radarType isEqualType [] && {_radarType isNotEqualTo []}) then {_radarType = selectRandom _radarType};
if (_samType isEqualType [] && {_samType isNotEqualTo []}) then {_samType = selectRandom _radarType};
Retrieves SAM vehicle types from faction configuration.
Handles array types by selecting random variant.
Sqf

Apply
if (garrison getVariable [_markerX + "_samDestroyedCD", 0] == 0) then 
{
  if (_radarType != "" && {_samType != ""}) then 
  {
    private _spawnParameter = [_markerX, "Sam"] call A3A_fnc_findSpawnPosition;
    if !(_spawnParameter isEqualType []) exitWith {};
    _spawnsUsed pushBack _spawnParameter#2;
    
    {
      private _aaVehicle = nil;
      isNil {
        _aaVehicle = [_x, _spawnParameter select 0, 25, 10, true] call A3A_fnc_safeVehicleSpawn;
        _aaVehicle setDir (_spawnParameter select 1);
      };
      
      private _aaGroup = [_sideX, _aaVehicle] call A3A_fnc_createVehicleCrew;
      [_aaVehicle, _sideX] call A3A_fnc_AIVEHinit;
      
      _soldiers append (units _aaGroup);
      _groups pushBack _aaGroup;
      _vehiclesX pushBack _aaVehicle;
      
      if(_x isEqualTo _radarType) then {
        _aaVehicle spawn {
          while {alive _this} do {
            {
              _this lookAt (_this getRelPos [100, _x]);
              sleep 2.45;
            } forEach [120, 240, 0];
          };
        };
        _aaVehicle setVehicleRadar 1;
        _aaVehicle setVehicleReportRemoteTargets true;
      };
      
      _aaVehicle setVariable ["A3A_samMarker", _markerX];
      _aaVehicle addEventHandler ["Killed", { 
        private _marker = _this#0 getVariable ["A3A_samMarker",""];
        if (_marker isNotEqualTo "") then {
          private _varName = _marker + "_samDestroyedCD";
          private _previousValue = garrison getVariable [_varName, 0];
          garrison setVariable [_varName, (_previousValue + 1800), true];
        };
      }];
    } forEach [_radarType, _samType];
  };
};
Checks if SAM site cooldown has ended.
Finds spawn position for SAM site using "Sam" type.
Spawns radar and SAM vehicle with safeVehicleSpawn (prevents spawning inside objects).
Creates vehicle crew for each vehicle.
Initializes vehicle with AI logic.
For radar: spawns a rotation script that continuously rotates the radar to scan different directions.
Sets radar properties (enable radar, report targets).
Adds event handler to set cooldown when SAM is destroyed (1800 seconds = 30 minutes).
Tracks vehicles, groups, soldiers, and spawn positions.
Frontier Static Defense:

Sqf

Apply
if (_frontierX) then {
  _roads = _positionX nearRoads _size;
  if (count _roads != 0) then {
    private _groupX = createGroup _sideX;
    _groups pushBack _groupX;
    private _typeVehX = selectRandom (_faction get "staticAT");
    
    if (_faction getOrDefault ["noSandbag", false]) then {        
      private _veh = _typeVehX createVehicle _positionX;
      _vehiclesX pushBack _veh;
      _veh setPos _pos;
      _veh setDir _dirVeh + 180;
      private _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
      private _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
      _unit moveInGunner _veh;
      [_unit,_markerX] call A3A_fnc_NATOinit;
      [_veh, _sideX] call A3A_fnc_AIVEHinit;
      _soldiers pushBack _unit;
    } else {
      private _bunker = (_faction get "sandbag") createVehicle _pos;
      _vehiclesX pushBack _bunker;
      _bunker setDir _dirveh;
      _pos = getPosATL _bunker;
      private _veh = _typeVehX createVehicle _positionX;
      _vehiclesX pushBack _veh;
      _veh setPos _pos;
      _veh setDir _dirVeh + 180;
      private _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
      private _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
      _unit moveInGunner _veh;
      [_unit,_markerX] call A3A_fnc_NATOinit;
      [_veh, _sideX] call A3A_fnc_AIVEHinit;
      _soldiers pushBack _unit;
    };
  };
};
For frontier airbases, spawns static AT guns on roads.
Creates a group for the crew.
Handles both sandbag (with bunker) and no-sandbag factions.
Creates AT vehicle and crew.
Initializes both unit and vehicle with NATO/AI init functions.
Patrol Area Marker:

Sqf

Apply
private _mrk = createMarkerLocal [format ["%1patrolarea", random 100], _positionX];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [(distanceSPWN/2),(distanceSPWN/2)];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_mrk setMarkerDirLocal (markerDir _markerX);
if (!debug) then {_mrk setMarkerAlphaLocal 0};
Creates a local patrol area marker for visualization and logic.
Sets shape, size, type, color, and brush.
Hides marker if debug mode is off.
Additional Garrison Spawning:

Sqf

Apply
private _additionalGarrison = [_sideX, _markerX] call SCRT_fnc_garrison_rollOversizeGarrison;
if (_additionalGarrison isNotEqualTo []) then {
  for "_i" from 0 to (count _additionalGarrison) - 1 do {
    private _groupTypes = _additionalGarrison select _i;
    private _group = [_positionX, _sideX, _groupTypes, false, true] call A3A_fnc_spawnGroup;
    if !(isNull _group) then {
      sleep 1;
      [_group, "Patrol_Area", 25, 150, 300, false, [], false] call A3A_fnc_patrolLoop;
      _groups pushBack _group;
      {[_x] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
    };
  };
};
Rolls for additional garrison units (reinforcements).
Spawns groups with specific types.
Puts them in patrol loops with area patrols.
Initializes soldiers and tracks them.
Garrison Processing and Patrol Decision:

Sqf

Apply
private _garrison = garrison getVariable [_markerX,[]];
_garrison = _garrison call A3A_fnc_garrisonReorg;

private _radiusX = count _garrison;
private _patrol = true;

if (_radiusX < ([_markerX] call A3A_fnc_garrisonSize)) then {
  _patrol = false;
} else {
  _patrol = ((markersX findIf {(getMarkerPos _x inArea _mrk) && {sidesX getVariable [_x, sideUnknown] != _sideX}}) == -1);
};

if (_patrol) then {
  [_markerX, _positionX, _sideX, _faction, 6] call SCRT_fnc_location_createPatrols;
};
Gets current garrison, reorganizes it.
Decides whether to spawn patrols based on:
Garrison size vs required size
Enemy markers in patrol area (if any, no patrols spawn)
If conditions met, spawns location-specific patrols.
Mortar Spawning:

Sqf

Apply
private _countX = 0;
private _groupX = createGroup _sideX;
_groups pushBack _groupX;
private _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
while {true} do {
  private _spawnParameter = [_markerX, "Mortar"] call A3A_fnc_findSpawnPosition;
  if (_spawnParameter isEqualType false) exitWith {};
  
  _spawnsUsed pushBack _spawnParameter#2;
  _typeVehX = selectRandom (_faction get "staticMortars");
  _veh = _typeVehX createVehicle (_spawnParameter select 0);
  _veh setDir (_spawnParameter select 1);
  _unit = [_groupX, _typeUnit, _positionX, [], 0, "CAN_COLLIDE"] call A3A_fnc_createUnit;
  _unit moveInGunner _veh;
  [_unit,_markerX] call A3A_fnc_NATOinit;
  [_veh, _sideX] call A3A_fnc_AIVEHinit;
  [_groupX] call A3A_fnc_artilleryAdd;
  _soldiers pushBack _unit;
  _vehiclesX pushBack _veh;
  sleep 1;
  
  private _mortarPos = _spawnParameter select 0;
  {
    private _relativePosition = [_mortarPos, 4, _x] call BIS_fnc_relPos;
    private _sandbag = createVehicle [_faction get "sandbagRound", _relativePosition, [], 0, "CAN_COLLIDE"];
    _sandbag setDir ([_sandbag, _mortarPos] call BIS_fnc_dirTo);
    _sandbag setVectorUp surfaceNormal position _sandbag;
    _props pushBack _sandbag;
  } forEach [0, 90, 180, 270];
};
Creates mortar group.
Spawns as many mortars as possible (until no more spawn positions).
For each mortar: creates vehicle, crew, adds artillery capability, creates sandbag ring.
Tracks all objects for cleanup.
Military Buildings:

Sqf

Apply
private _ret = [_markerX,_size,_sideX,_frontierX] call A3A_fnc_milBuildings;
_groups pushBack (_ret select 0);
_vehiclesX append (_ret select 1);
_soldiers append (_ret select 2);
_spawnsUsed append (_ret select 3);
{[_x, _sideX] call A3A_fnc_AIVEHinit} forEach (_ret select 1);
Calls milBuildings to spawn additional military structures and vehicles.
Adds returned objects to tracking arrays.
Initializes vehicles with AI logic.
Intel Placement:

Sqf

Apply
if(random 100 < (50 + tierWar * 3)) then {
  _large = (random 100 < (40 + tierWar * 2));
  [_markerX, _large] spawn A3A_fnc_placeIntel;
};
Randomly decides to place intel at airbase.
Spawns intel placement function based on tierWar (war tier).
Aircraft Spawning:

Sqf

Apply
if (!_busy) then {
  private _pos = nil;
  private _ang = nil;
  private _runwaySpawnLocation = [_markerX] call A3A_fnc_getRunwayTakeoffForAirportMarker;
  if !(_runwaySpawnLocation isEqualTo []) then
  {
    _pos = _runwaySpawnLocation select 0;
    _ang = _runwaySpawnLocation select 1;
  };
  private _groupX = createGroup _sideX;
  _groups pushBack _groupX;
  _countX = 0;
  private _vehCount = round (random [2, 4, 5]);
  while {_countX < _vehCount} do {
    private _veh = objNull;
    private _hangar = objNull;
    private _spawnParameter = [_markerX, "Plane"] call A3A_fnc_findSpawnPosition;
    if(_spawnParameter isEqualType []) then {
      private _vehiclesPlanesCAS = _faction get "vehiclesPlanesCAS";
      private _vehiclesPlanesAA = _faction get "vehiclesPlanesAA";
      private _uavsAttack = _faction getOrDefault ["uavsAttack", []];
      
      private _vehPool = [];
      {
          _vehPool pushBack _x;
          _vehPool pushBack 1;
      } forEach _vehiclesPlanesCAS;
      
      {
          _vehPool pushBack _x;
          _vehPool pushBack 1;
      } forEach _vehiclesPlanesAA;
      
      {
          _vehPool pushBack _x;
          _vehPool pushBack A3A_UAVSpawnChance;
      } forEach _uavsAttack;
      _spawnsUsed pushBack _spawnParameter#2;
      _typeVehX = selectRandomWeighted _vehPool;
      _veh = createVehicle [_typeVehX, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
      _veh setDir (_spawnParameter select 1);
      sleep 0.5;
      if !(alive _veh) then {
          _hangar = (nearestObjects [_veh, ["Static"], 20]) select 0;
          deleteVehicle _hangar;
          deleteVehicle _veh;
          _veh = createVehicle [_typeVehX, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
          _veh setDir (_spawnParameter select 1);
          _veh allowDamage false;
          _veh enableSimulation false;
          sleep 0.5;
          _veh enableSimulation true;
          _veh allowDamage true;
      };
      _vehiclesX pushBack _veh;
      [_veh, _sideX] call A3A_fnc_AIVEHinit;
    } else {
      if !(_runwaySpawnLocation isEqualTo []) then {
        private _vehiclesPlanesCAS = _faction get "vehiclesPlanesCAS";
        private _vehiclesPlanesAA = _faction get "vehiclesPlanesAA";
        private _vehiclesPlanesLargeCAS = _faction get "vehiclesPlanesLargeCAS";
        private _vehiclesPlanesLargeAA = _faction get "vehiclesPlanesLargeAA";
        private _vehiclesPlanesTransport = _faction get "vehiclesPlanesTransport";
        private _vehiclesPlanesGunship = _faction getOrDefault ["vehiclesPlanesGunship", []];
        private _uavsAttack = _faction getOrDefault ["uavsAttack", []];
        private _vehPool = [];
        {
            _vehPool pushBack _x;
            _vehPool pushBack 0.7;
        } forEach _vehiclesPlanesCAS;
        {
            _vehPool pushBack _x;
            _vehPool pushBack 0.7;
        } forEach _vehiclesPlanesAA;
        {
            _vehPool pushBack _x;
            _vehPool pushBack 1;
        } forEach _vehiclesPlanesLargeCAS;
        {
            _vehPool pushBack _x;
            _vehPool pushBack 1;
        } forEach _vehiclesPlanesLargeAA;
        {
            _vehPool pushBack _x;
            _vehPool pushBack 1;
        } forEach _vehiclesPlanesTransport;
        {
            _vehPool pushBack _x;
            _vehPool pushBack 0.5;
        } forEach _vehiclesPlanesGunship;
        {
            _vehPool pushBack _x;
            _vehPool pushBack ((A3A_UAVSpawnChance - 0.1) max 0);
        } forEach _uavsAttack;
        _typeVehX = selectRandomWeighted _vehPool;
        if (!isNil "_typeVehX") then {
          _veh = createVehicle [_typeVehX, _pos, [],50, "NONE"];
          _veh setDir (_ang);
          _pos = [_pos, 50,_ang] call BIS_fnc_relPos;
          _vehiclesX pushBack _veh;
          [_veh, _sideX] call A3A_fnc_AIVEHinit;
        };
      } else {
        _countX = _vehCount;
      };
    };
    _countX = _countX + 1;
  };
};
Gets runway takeoff position for airport.
Creates aircraft group.
Spawns aircraft in hangars first (using Plane spawn type).
For each aircraft: builds weighted vehicle pool from faction arrays, spawns with safe placement, handles hangar collision issues.
If no hangar space, spawns on runway if available.
Initializes each aircraft with AI logic.
Flag Creation:

Sqf

Apply
private _typeVehX = _faction get "flag";
private _flagX = createVehicle [_typeVehX, _positionX, [],0, "NONE"];
_flagX allowDamage false;
[_flagX,"take"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_flagX];
_vehiclesX pushBack _flagX;
if (flagTexture _flagX != (_faction get "flagTexture")) then {[_flagX,(_faction get "flagTexture")] remoteExec ["setFlagTexture",_flagX]};
Creates faction flag at marker position.
Makes it undamageable.
Adds remote exec flag action for capturing.
Sets appropriate flag texture if different from default.
Ammo Box Spawning:

Sqf

Apply
private _ammoBox = if (garrison getVariable [_markerX + "_lootCD", 0] == 0) then
{
  private _ammoBoxType = _faction get "ammobox";
  private _ammoBox = [_ammoBoxType, _positionX, 15, 5, true] call A3A_fnc_safeVehicleSpawn;
  _ammoBox addEventHandler ["Killed", { [_this#0] spawn { sleep 10; deleteVehicle (_this#0) } }];
  [_ammoBox] spawn A3A_fnc_fillLootCrate;
  [_ammoBox, nil, true] call A3A_Logistics_fnc_addLoadAction;
  
  [_ammoBox] spawn {
    sleep 1;
    {
      _this#0 addItemCargoGlobal [_x, round random [5,15,15]];
    } forEach (A3A_faction_reb get "flyGear");
  };
  _ammoBox;
};
Checks loot cooldown.
Spawns ammo box with safeVehicleSpawn.
Adds cleanup event handler (deleted 10 seconds after destruction).
Fills with loot using fillLootCrate.
Adds logistics load action for players.
Adds rebel gear items to crate.
Patrol Vehicle Spawning:

Sqf

Apply
if (!_busy) then
{
  private _vehPool = [];
  private _vehTypes = [
    "vehiclesLightAPCs",
    "vehiclesAPCs",
    "vehiclesIFVs",
    "vehiclesLightTanks",
    "vehiclesTanks",
    "vehiclesAirborne"
    ];
  private _typeWeight = [
    12 - (tierWar), 
    12 - (tierWar * 0.5),
    5 + (tierWar), 
    12 - (tierWar * 0.25),
    5 + (tierWar),
    5 + (tierWar)
    ];
  
  {
    private _vehs = _faction get _x;
    if (_vehs isEqualTo []) then {continue};
    private _weight = (_typeWeight select _forEachIndex) / count _vehs;
    {
      _vehPool append [_x, _weight];
    } forEach _vehs;
  } forEach _vehTypes;
  for "_i" from 1 to (round (random 2)) do
  {
    _spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
    if (_spawnParameter isEqualType []) then
    {
      private _veh = nil;
      _spawnsUsed pushBack _spawnParameter#2;
      isNil {
        _veh = createVehicle [selectRandomWeighted _vehPool, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
        _veh setDir (_spawnParameter select 1);
      };
      _vehiclesX pushBack _veh;
      [_veh, _sideX] call A3A_fnc_AIVEHinit;
      _nVeh = _nVeh -1;
      sleep 1;
    };
  };
};
Builds weighted vehicle pool based on tierWar.
Spawns 1-2 patrol vehicles (random).
Uses weighted selection for vehicle type diversity.
Tracks spawned vehicles.
Ground Vehicle Spawning:

Sqf

Apply
private _groundPool = [];

private _vehTypes = [
  "vehiclesLightArmed",
  "vehiclesLightUnarmed",
  "vehiclesTrucks",
  "vehiclesCargoTrucks",
  "vehiclesAmmoTrucks",
  "vehiclesRepairTrucks",
  "vehiclesFuelTrucks",
  "vehiclesMedical"
];

private _vehTypeWeights = [
  7, 
  4, 
  2, 
  2,
  1 + (tierWar * 0.05), 
  1 + (tierWar * 0.05), 
  1 + (tierWar * 0.2), 
  2
];

{
  private _vehs = _faction get _x;
  if (_vehs isEqualTo []) then {continue};
  private _weight = (_vehTypeWeights select _forEachIndex) / count _vehs;
  {
    _groundPool append [_x, _weight];
  } forEach _vehs;
} forEach _vehTypes;

_countX = 0;
while {_countX < _nVeh && {_countX < 3}} do {
  private _typeVehX = selectRandomWeighted _groundPool;
  private _spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
  if(_spawnParameter isEqualType []) then
  {
    _spawnsUsed pushBack _spawnParameter#2;
    private _veh = nil;
    isNil {
      _veh = createVehicle [_typeVehX, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
      _veh setDir (_spawnParameter select 1);
    };
    _vehiclesX pushBack _veh;
    [_veh, _sideX] call A3A_fnc_AIVEHinit;
    sleep 1;
    _countX = _countX + 1;
  }
  else
  {
    _countX = _nVeh;
  };
};
Builds ground vehicle pool with different weights for each type.
Spawns ground vehicles (up to 3) based on calculated _nVeh.
Tracks each spawn to avoid overpopulation.
Garrison Unit Spawning:

Sqf

Apply
private _array = [];
private _subArray = [];
_countX = 0;
_radiusX = _radiusX -1;
while {_countX <= _radiusX} do {
  _array pushBack (_garrison select [_countX,7]);
  _countX = _countX + 8;
};
for "_i" from 0 to (count _array - 1) do {
  private _groupX = if (_i == 0) then {
    [_positionX, _sideX, (_array select _i), true, false] call A3A_fnc_spawnGroup;
  } else {
    private _spawnPosition = [_positionX, 50, 100, 5, 0, -1, 0] call A3A_fnc_getSafePos;
    [_spawnPosition, _sideX, (_array select _i), false, true] call A3A_fnc_spawnGroup;
  };
  _groups pushBack _groupX;
  {
    [_x, _markerX] call A3A_fnc_NATOinit; 
    _soldiers pushBack _x;
  } forEach units _groupX;
  if (_i == 0) then {
    private _additionalGroups = [_groupX, getMarkerPos _markerX, _size] call A3A_fnc_patrolGroupGarrison;
    _groups append _additionalGroups;
  } else {
    [_groupX, "Patrol_Defend", 0, 200, -1, true, _positionX, false] call A3A_fnc_patrolLoop;
  };
};
Splits garrison array into groups of 7 (with 1-unit overlap).
First group spawns at exact marker position (defensive).
Other groups spawn nearby with safe position.
First group gets additional defense groups if needed.
Other groups patrol defensively.
All units initialized and tracked.
Self-Propelled AA:

Sqf

Apply
private _max = if (_frontierX) then {2} else {1};
for "_i" from 1 to _max do {
  private _spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
  
  if !(_spawnParameter isEqualType []) exitWith {};
  _spawnsUsed pushBack _spawnParameter#2;
  
  private _veh = nil;
  isNil {
    _veh = createVehicle [selectRandom (_faction get "vehiclesAA"), (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
    _veh setDir (_spawnParameter select 1);
  };
  
  _groupVeh = [_sideX, _veh] call A3A_fnc_createVehicleCrew;
  {[_x,_markerX] call A3A_fnc_NATOinit} forEach units _groupVeh;
  [_veh, _sideX] call A3A_fnc_AIVEHinit;
  _soldiers append units _groupVeh;
  _groups pushBack _groupVeh;
  [_groupVeh, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;
  _vehiclesX pushBack _veh;
  
  sleep 1;
  [(gunner _veh), 300] spawn SCRT_fnc_common_scanHorizon;
  
  _veh setVariable ["originalPos", getPosATL _veh];
};
Spawns 1-2 SPAA vehicles based on frontier status.
Creates crew and patrols in area.
Spawns horizon scanning for gunner.
Stores original position for despawn logic.
Vehicle Locking:

Sqf

Apply
{
  if (_x isKindOf "Static" || _x isKindOf "StaticWeapon") then {continue};
  [_x, true] call A3U_fnc_setLock;
} forEach _vehiclesX;
Locks all non-static vehicles to prevent player use (unless captured).
Boat Spawning:

Sqf

Apply
private _boatType = selectRandom (_faction get "vehiclesGunBoats");
private _mrkMar = seaSpawn select {getMarkerPos _x inArea _markerX};
if (count _mrkMar > 0) then {
  private _pos = (getMarkerPos (_mrkMar select 0)) findEmptyPosition [0,20,_typeVehX];
  private _vehicle=[_pos, 0,_boatType, _sideX] call A3A_fnc_spawnVehicle;
  private _veh = _vehicle select 0;
  [_veh, _sideX] call A3A_fnc_AIVEHinit;
  private _vehCrew = _vehicle select 1;
  {[_x,_markerX] call A3A_fnc_NATOinit} forEach _vehCrew;
  private _groupVeh = _vehicle select 2;
  _soldiers append _vehCrew;
  [_groupVeh, "Patrol_Water", 25, 200, -1, true, _pos] call A3A_fnc_patrolLoop;
  _groups pushBack _groupVeh;
  _vehiclesX pushBack _veh;
  sleep 1;
  
  _veh setVariable ["originalPos", getPosATL _veh];
};
Finds nearest sea spawn marker in airbase area.
Spawns gunboat with crew.
Water patrol pattern.
Tracks for cleanup.
Heavy Patrol Vehicle:

Sqf

Apply
if (random 100 < (20 + tierWar * 3)) then {
  private _road = [_positionX] call A3A_fnc_findNearestGoodRoad;
  if (_road distance2D _positionX > 800) exitWith {};
  
  private _heavyVehPool =  (_faction get "vehiclesTanks") + (_faction get "vehiclesAPCs") + (_faction get "vehiclesLightAPCs") + (_faction get "vehiclesIFVs") + (_faction get "vehiclesLightTanks");
  private _type = selectRandom _heavyVehPool;
  
  private _heavyVehicle = [_type, (position _road), 15, 10] call A3A_fnc_safeVehicleSpawn;
  if (isNull _heavyVehicle) exitWith {};
  
  private _crewType = [_sideX, _heavyVehicle] call A3A_fnc_crewTypeForVehicle;
  private _group = createGroup _sideX;
  
  _group = [_group, _heavyVehicle, _crewType] call A3A_fnc_createVehicleCrew;
  
  [_heavyVehicle, _sideX] call A3A_fnc_AIVEHinit;
  {[_x,_markerX] call A3A_fnc_NATOinit} forEach (units _group);
  
  if (_type in ((_faction get "vehiclesAPCs") + (_faction get "vehiclesIFVs") + (_faction get "vehiclesLightAPCs"))) then {
    sleep 1;
    private _troopGroup = [(position _road), _sideX, (selectRandom ([_faction, "groupsTierMedium"] call SCRT_fnc_unit_flattenTier))] call A3A_fnc_spawnGroup;
    {_x assignAsCargo _heavyVehicle;_x moveInCargo _heavyVehicle; _soldiers pushBack _x; [_x] joinSilent _group; [_x,"",false] call A3A_fnc_NATOinit} forEach units _troopGroup;
    deleteGroup _troopGroup;
  };
  
  [_group, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;
  
  _heavyVehicle setVariable ["originalPos", getPosATL _heavyVehicle];
  
  _soldiers append (units _group);
  _groups pushBack _group;
  _vehiclesX pushBack _heavyVehicle;
  
  _heavyVehicle setVariable ["originalPos", getPosATL _heavyVehicle];
};
Random chance based on tierWar.
Finds nearest good road.
Spawns heavy vehicle (tank, APC, IFV).
For APC/IFV: adds troops in cargo.
Patrols area.
Set Original Positions and Event:

Sqf

Apply
{ _x setVariable ["originalPos", getPosATL _x] } forEach _vehiclesX;

["locationSpawned", [_markerX, "Airport", true]] call EFUNC(Events,triggerEvent);
Sets original position for all vehicles for despawn logic.
Triggers event for other systems.
Despawn Logic:

Sqf

Apply
waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

{
  if (_x getVariable ["ownerSide", _sideX] == _sideX) then {
    if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
    else { if !(_x isKindOf "StaticWeapon") then { [_x] spawn A3A_fnc_VEHdespawner } };
  };
} forEach _vehiclesX;

deleteMarker _mrk;
{ if (alive _x) then { deleteVehicle _x } } forEach _soldiers;
{ deleteVehicle _x } forEach _dogs;
{ deleteGroup _x } forEach _groups;
{ deleteVehicle _x } forEach _props;

_spawnsUsed call A3A_fnc_freeSpawnPositions;
Waits for despawn signal (spawner variable = 2).
Deletes vehicles unless owned by non-owning side (captured).
Sends captured vehicles to despawner.
Deletes all spawned objects and groups.
Frees spawn positions.
Loot Crate Cooldown:

Sqf

Apply
if (!isNil "_ammoBox") then {
  if ((alive _ammoBox) and (_ammoBox distance2d _positionX < 100)) exitWith { deleteVehicle _ammoBox };
  if (alive _ammoBox) then { [_ammoBox] spawn A3A_fnc_VEHdespawner };
  private _lootCD = 120*16 / ([_markerX] call A3A_fnc_garrisonSize);
  garrison setVariable [_markerX + "_lootCD", _lootCD, true];
};
["locationSpawned", [_markerX, "Airport", false]] call EFUNC(Events,triggerEvent);
If ammo box wasn't stolen (still at marker), deletes it.
If stolen, sends to despawner and sets cooldown.
Cooldown based on garrison size.
Triggers spawn complete event.
Where it leads:

Calls:

A3A_fnc_sizeMarker - Gets marker size
A3A_fnc_isFrontline - Determines if frontier
A3A_fnc_findSpawnPosition - Finds valid spawn locations
A3A_fnc_safeVehicleSpawn - Spawns vehicles safely
A3A_fnc_createVehicleCrew - Creates vehicle crew
A3A_fnc_AIVEHinit - Initializes AI vehicle
A3A_fnc_patrolLoop - Creates patrol patterns
SCRT_fnc_location_createPatrols - Location-specific patrols
A3A_fnc_milBuildings - Spawns military structures
A3A_fnc_placeIntel - Places intel
A3A_fnc_getRunwayTakeoffForAirportMarker - Gets runway positions
A3A_fnc_fillLootCrate - Fills ammo crate
A3A_fnc_spawnGroup - Creates groups
A3A_fnc_patrolGroupGarrison - Garrison patrol logic
A3A_fnc_spawnVehicle - Spawns vehicles
A3A_fnc_safeVehicleSpawn - Safe vehicle spawning
A3A_fnc_crewTypeForVehicle - Gets crew type
A3A_fnc_createVehicleCrew - Creates crew
A3A_fnc_VEHdespawner - Despawns vehicles
A3A_fnc_freeSpawnPositions - Frees spawn slots
SCRT_fnc_common_scanHorizon - Horizon scanning
SCRT_fnc_garrison_rollOversizeGarrison - Additional garrison
Depended on by:

spawnPatrol - Base patrol spawning system
reinforcementsAI - Uses for airbase defense
cycleSpawn - Main spawner loop
createAIcontrols - Airbase creation logic
Global Variables Modified:

garrison - Set SAM destroyed cooldown, loot cooldown
spawner - Variable checked for spawning/despawning
ServerInfo - Logging system
Synchronization/Network Implications:

Uses remoteExec for flag actions (player capture).
Uses setFlagTexture remoteExec for flag texture sync.
Event system calls with EFUNC macro for multiplayer sync.
All server-side object creation, no client sync needed for spawning.
Despawn logic runs on server only.
Function Name: createAICities.sqf
What it does: This function spawns AI patrol units in city/civilian areas. It handles spawning of infantry patrols with dogs (for AAF), garrisons, and ensures proper cleanup when the area needs to despawn. It's called for city markers where AI forces need to be present. It adjusts spawn amount based on prestige and frontline status.

How it does that:

Input Validation and Setup:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer and hasInterface) exitWith{};

params ["_markerX"];

private _groups = [];
private _soldiers = [];
private _dogs = [];

private _positionX = getMarkerPos _markerX;

private _num = [_markerX] call A3A_fnc_sizeMarker;
private _patrolSize = _num;

private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _faction = Faction(_sideX);
Validates server-only execution.
Takes marker name as parameter.
Initializes tracking arrays.
Gets position and size.
Determines side and faction.
Enemy Check and City Calculation:

Sqf

Apply
if ((markersX - controlsX - milAdministrationsX) findIf {(getMarkerPos _x inArea _markerX) and (sidesX getVariable [_x,sideUnknown] != _sideX)} != -1) exitWith {};
_num = round (_num / 100);
Checks if any enemy markers are in the area (exit if true).
Calculates number of patrols based on marker size.
Prestige and Frontline Logic:

Sqf

Apply
ServerInfo_1("Spawning City Patrol in %1", _markerX);

private _dataX = server getVariable _markerX;
private _prestigeOPFOR = _dataX select 2;
private _prestigeBLUFOR = _dataX select 3;

private _isAAF = true;
private _params = nil;
if (_markerX in destroyedSites) then {
  _isAAF = false;
  _params = [_positionX,Invaders, selectRandom (_faction get "groupSpecOpsRandom")];
} else {
  _num = round (_num * (_prestigeOPFOR + _prestigeBLUFOR)/100);
  private _frontierX = [_markerX] call A3A_fnc_isFrontline;
  if (_frontierX) then {
    _num = _num * 2;
    _params = [_positionX, Occupants, (selectRandom ([_faction, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier))];
  } else {
    _params = [_positionX, Occupants, _faction get "groupPolice"];
  };
};
if (_num < 1) then {_num = 1};
Gets city data (prestige values).
Determines if AAF (Occupants) or Invaders (destroyed sites).
For destroyed sites: spawns spec ops groups.
For cities: adjusts spawn count by prestige, doubles for frontier.
Uses police groups for peaceful cities, tiered groups for frontier.
Ensures minimum 1 patrol.
Civilian Non-Human Check (Zombies):

Sqf

Apply
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];

if (_civNonHuman && {(selectRandom [1,2,3]) isEqualTo 2}) exitWith {
  ["locationSpawned", [_markerX, "City", true]] call EFUNC(Events,triggerEvent);
  
  waitUntil {sleep 1;(spawner getVariable _markerX == 2)};
  
  ["locationSpawned", [_markerX, "City", false]] call EFUNC(Events,triggerEvent);
};
Checks for zombie/non-human civilians.
1/3 chance to skip spawning (just trigger events).
Used for zombie missions where zombies replace patrols.
Patrol Spawning Loop:

Sqf

Apply
while {(spawner getVariable _markerX != 2) and (_countX < _num)} do {
  private _spawnPosition = [];
  
  if (count _roadPositions >= 1) then {
    _spawnPosition = selectRandom _roadPositions;
    _roadPositions deleteAt (_roadPositions find _spawnPosition);
  } else {
    _spawnPosition = _positionX;
  };
  
  _groupX = [_spawnPosition, (_params # 1), (_params # 2)] call A3A_fnc_spawnGroup;
  
  // Forced non-spawner for performance and consistency with other garrison patrols
  {
    [_x, "", false] call A3A_fnc_NATOinit; 
    _soldiers pushBack _x;
  } forEach units _groupX;
  
  sleep 1;
  
  // Only spawn dog units with Occupant forces.
  if (_isAAF) then {
    if (random 10 < 2.5) then {
      private _dog = [_groupX, "Fin_random_F", _spawnPosition, [], 0, "FORM"] call A3A_fnc_createUnit;
      _dogs pushBack _dog;
      [_dog] spawn A3A_fnc_guardDog;
    };
  };
  [_groupX, "Patrol_Area", 25, 150, 150, false, _positionX, true] call A3A_fnc_patrolLoop;
  _groups pushBack _groupX;
  _countX = _countX + 1;
};
Spawns groups until despawn signal or count reached.
Prefers road positions, then falls back to marker center.
Creates group with appropriate side and type.
Initializes soldiers with NATO init.
Randomly spawns guard dogs for AAF (25% chance).
Starts patrol loop for each group.
Despawn Logic:

Sqf

Apply
["locationSpawned", [_markerX, "City", true]] call EFUNC(Events,triggerEvent);

waitUntil {sleep 1;(spawner getVariable _markerX == 2)};

{if (alive _x) then {deleteVehicle _x}} forEach _soldiers;
{deleteVehicle _x} forEach _dogs;
{ deleteGroup _x } forEach _groups;

["locationSpawned", [_markerX, "City", false]] call EFUNC(Events,triggerEvent);
Triggers spawn complete event.
Waits for despawn signal.
Deletes all soldiers, dogs, and groups.
Triggers despawn event.
Where it leads:

Calls:

A3A_fnc_sizeMarker - Gets marker size
A3A_fnc_isFrontline - Checks if frontier
SCRT_fnc_unit_flattenTier - Flattens tiered unit lists
A3A_fnc_spawnGroup - Creates infantry groups
A3A_fnc_NATOinit - Initializes units
A3A_fnc_createUnit - Creates guard dogs
A3A_fnc_guardDog - Dog AI behavior
A3A_fnc_patrolLoop - Patrol patterns
Depended on by:

spawnPatrol - Base patrol spawning system
createAIcontrols - City creation logic
cycleSpawn - Main spawner loop
Global Variables Modified:

spawner - Variable checked for spawning/despawning
destroyedSites - Checked for destroyed city status
ServerInfo - Logging system
Synchronization/Network Implications:

Event system calls with EFUNC macro for multiplayer sync.
All server-side object creation, no client sync needed.
Despawn logic runs on server only.
CfgFunctions.hpp
What it does: This file defines all functions in the A3A addon, organized by category. It specifies function names, file paths, and special attributes (like preInit/postInit). This is a configuration file, not a runtime function. It's used by the game engine to load and reference functions.

How it does that:

Defines class hierarchy: A3A > Category > Function
Maps function names to file paths using QPATHTOFOLDER macro
Specifies execution context (preInit, postInit)
Organizes 100+ functions into logical categories (AI, Ammunition, Base, etc.)
Used by call command and event handlers to locate functions
Where it leads:

Functions are called via: [params] call A3A_fnc_functionName
PreInit functions run on mission start
PostInit functions run after mission initialization
Functions listed in this file must exist in the specified paths
This file is the "entry point" for all A3A functionality

Function Name: A3A\fn_createAIcontrols.sqf
What it does: This function manages the spawning and lifecycle of a "Control" point (usually a roadblock) in the Antistasi mission. It handles the creation of static defenses, parked vehicles, AI squads, minefields, and UAVs based on the location type (road or off-road) and the controlling side. It also manages the interaction with the spawner system for performance optimization and tracks the location's conquest status, updating global game state (sidesX) upon capture or loss. It is called by the server-side scheduler (e.g., A3A_fnc_scheduler or A3A_fnc_cycleSpawn) when a marker needs active AI.

How it does that: The function executes in a sequence: parameter retrieval, initial validation, determining the location type (Roadblock vs. Field Position), generating specific assets for that type, managing the AI simulation state based on player proximity, and finally cleaning up or updating state upon completion.

1. Initialization and Parameter Validation

Sqf

Apply
_markerX = _this select 0;
_positionX = getMarkerPos _markerX;
_sideX = sidesX getVariable [_markerX,sideUnknown];
private _faction = Faction(_sideX);

ServerInfo_1("Spawning Control Point %1", _markerX);

if ((_sideX == teamPlayer) or (_sideX == sideUnknown)) exitWith {};
if ({if ((sidesX getVariable [_x,sideUnknown] != _sideX) and (_positionX inArea _x)) exitWith {1}} count markersX >1) exitWith {};
Explanation: Retrieves the marker name from the passed array. Gets the 2D position and the owning side from the sidesX global variable.
Validation: Checks if the side is already the player side or unknown; if so, it exits immediately. It also checks if the marker is currently overlapping with any other hostile marker (which shouldn't happen in a valid map setup) and exits if true.
2. Variable Setup and IFA Detection

Sqf

Apply
_vehiclesX = [];
_soldiers = [];
private _dogs = [];
private _groups = [];
_pilots = [];
_conquered = false;
_groupX = grpNull;
_isFIA = false;
_leave = false;
A3A_hasIFA = false;

//IFA Detection
if (isClass (configfile >> "CfgPatches" >> "LIB_core")) then {
    A3A_hasIFA = true;
    [2,"Iront Front Detected.",_fnc_scriptName] call A3A_fnc_log;
};
Explanation: Initializes empty arrays to track spawned entities. Sets default flags. Detects the mod "IFA: Iron Front" by checking for the LIB_core config class, setting a global flag A3A_hasIFA used later to branch spawning logic (e.g., different bunker models).
3. Roadblock Logic (isOnRoad)

Sqf

Apply
_isControl = if (isOnRoad _positionX) then {true} else {false};

if (_isControl) then
{
    if (_sideX == Occupants) then
    {
        if ((random 10 > (tierWar + difficultyCoef)) and (!([_markerX] call A3A_fnc_isFrontline))) then
        {
            _isFIA = true;
        }
    };
Explanation: Determines if the control point is on a road. If it is an Occupants (NATO/Argentine) roadblock and the difficulty (tierWar) is low and it's not the frontline, the AI is designated as a weaker "FIA-style" militia unit.
Road Finding Algorithm:
Sqf

Apply
_radiusX = 20;
while {_radiusX < 100} do
{
    _roads = _positionX nearRoads _radiusX;
    _roads = _roads select { count (roadsConnectedTo _x) == 2 };
    if (count _roads > 0) exitWith {};
    _radiusX = _radiusX + 10;
};
Logic: It searches for a road segment with exactly two connections (an intersection or turn) starting from a 20m radius and expanding to 100m. This ensures the roadblock blocks the main road but isn't on a dead-end or fork where it might look out of place.
4. Spawning Static Defenses (Roadblock)

Sqf

Apply
if (!_isFIA) then
{
    _groupE = grpNull;
    if !(A3A_hasIFA) then
    {
        _pos = [getPos (_roads select 0), 7, _dirveh + 270] call BIS_Fnc_relPos;
        _bunker = "Land_BagBunker_01_Small_green_F" createVehicle _pos;
        _bunker setDir _dirveh;
        _pos = getPosATL _bunker;
        _vehiclesX pushBack _bunker;

        _typeVehX = selectRandom (_faction get "staticMGs");
        _veh = _typeVehX createVehicle _positionX;
        _veh setPosATL _pos;
        _veh setDir _dirVeh;
        _groupE = createGroup _sideX;
        private _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
        _unit = [_groupE, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
        _unit moveInGunner _veh;
        _soldiers pushBack _unit;
    };
    ```
    *   **Explanation:** Spawns a defensive "nest" 7 meters to the left and a rearward direction relative to the road. It creates a static machine gun (from the faction's `staticMGs` list) and a crew unit (tiered by war level) to man it. This is repeated on the other side.
    *   **Flag & Beacon:**
        ```sqf
        _pos = [getPos _bunker, 6, getDir _bunker] call BIS_fnc_relPos;
        _typeVehX = _faction get "flag";
        _veh = createVehicle [_typeVehX, _pos, [],0, "NONE"];
        ```
    *   **Explanation:** A flag pole is spawned near the bunker. The texture is set remotely to ensure network sync, matching the faction's flag.

**5. Spawning FIA/Militia (Roadblock Alternative)**
```sqf
else
{
    private _vehicleGet = "";
    switch (true) do 
    {
        case (tierWar >= 9): { _vehicleGet = _tier9Vehicle; };
        case (tierWar >= 6): { _vehicleGet = "vehiclesAPCs"; };
        // ... etc ...
    };
    _typeVehX = selectRandom (_faction get _vehicleGet);
    _veh = _typeVehX createVehicle getPos (_roads select 0);
    _veh setDir _dirveh + 90;
    [_veh, _sideX] call A3A_fnc_AIVEHinit;
    _vehiclesX pushBack _veh;

    _typeGroup = selectRandom (_faction get "groupsMilitiaMedium");
    _groupX = [_positionX, _sideX, _typeGroup, true] call A3A_fnc_spawnGroup;
    _unit = [_groupX, _faction get "unitMilitiaGrunt", _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    _unit moveInGunner _veh;
};
Explanation: If _isFIA is true (weaker militia), it selects a vehicle based on the current Tier (War 9 = Light Tanks, War 6 = APCs, etc.). It spawns the vehicle on the road, angles it 90 degrees to the road direction (blocking it). A gunner is placed in the vehicle and a squad of infantry is spawned nearby.
6. Off-Road Logic (Field Position / OP)

Sqf

Apply
else
{
    _markersX = markersX select {(getMarkerPos _x distance _positionX < distanceSPWN) and ...};
    _frontierX = if (count _markersX > 0) then {true} else {false};
    if (_frontierX) then
    {
        // Minefield Generation
        if ({if (_x inArea _markerX) exitWith {1}} count allMines == 0) then
        {
            private _mines = (_faction get "minefieldAPERS");
            for "_i" from 1 to 45 do {
                _mineX = createMine [ selectRandom _mines ,_positionX,[],_size];
                _sideX revealMine _mineX;
            };
        };
        // SpecOps / Patrol
        _cfg = selectRandom (_faction get "groupSpecOpsRandom");
        _groupX = [_positionX,_sideX, _cfg] call A3A_fnc_spawnGroup;
        [_groupX, "Patrol_Area", 25, 150, 300, false, [], false] call A3A_fnc_patrolLoop;
    }
    else
    {
        // Sniper / Random Patrol
        // ...
    };
};
Explanation: If the location is not on a road (e.g., an outpost in a field):
It checks if the location is on the "frontier" (near enemy territory). If so, it spawns a minefield (APERS mines) if none exist.
It spawns a SpecOps group that patrols a tight area around the marker.
If not on the frontier (deep in territory), it spawns a sniper pair or a random patrol group. A check ((random 100) > ((tierWar * 3) + (_aggro / 5))) determines if the location is "quiet" enough to skip spawning (_leave = true).
7. Simulation Management Loop

Sqf

Apply
_spawnStatus = 0;
while {(spawner getVariable _markerX != 2) and ...} do
{
    if ((spawner getVariable _markerX == 1) and (_spawnStatus != spawner getVariable _markerX)) then
    {
        _spawnStatus = 1;
        { if (vehicle _x == _x) then {[_x,false] remoteExec ["enableSimulationGlobal",2] } } forEach _soldiers;
    }
    else
    {
        if ((spawner getVariable _markerX == 0) and (_spawnStatus != spawner getVariable _markerX)) then
        {
            _spawnStatus = 0;
            { if (vehicle _x == _x) then {[_x,true] remoteExec ["enableSimulationGlobal",2] } } forEach _soldiers;
        }
    };
    sleep 3;
};
Explanation: This is the core performance loop.
Spawner Variable: 0 = Active/Spawned, 1 = Empty/Timed out (Sim enabled), 2 = Delete/Despawn.
It checks the state every 3 seconds. If the area is empty (State 1), it disables simulation for all units (freezes them, stops physics). If players return (State 0), it re-enables simulation. This reduces server load drastically.
8. Conquest Detection and State Update

Sqf

Apply
waitUntil {sleep 1;((spawner getVariable _markerX == 2)) or ...};

if (spawner getVariable _markerX != 2) then
{
    _conquered = true;
    _allUnits = allUnits select {(side _x != civilian) and (side _x != _sideX) and (alive _x) and (!captive _x)};
    _closest = [_allUnits,_positionX] call BIS_fnc_nearestPosition;
    _winner = side _closest;

    if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then
    {
        if (_winner == Invaders) then
        {
            _nul = [-5,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
            sidesX setVariable [_markerX,Invaders,true];
        }
        else
        {
            sidesX setVariable [_markerX,teamPlayer,true];
        };
    };
};
Explanation: Waits for the location to be despawned (Player left) OR for all AI soldiers to die.
If the loop broke because soldiers died (and spawn status isn't 2), it calculates the winner by finding the nearest alive non-civilian unit to the marker.
It updates sidesX (the global side ownership variable) accordingly. If the original owner was Occupants and Invaders won, it updates to Invaders; otherwise, it usually updates to teamPlayer (Rebels).
It triggers notifications (TaskSucceeded/TaskFailed) and city support changes.
9. Post-Capture Trigger

Sqf

Apply
if (_conquered) then
{
    _indexX = controlsX find _markerX;
    if (_indexX > defaultControlIndex) then
    {
        _timeLimit = 120;
        waitUntil {sleep 60;(dateToNumber date > _dateLimitNum)};
        _base = [(markersX - controlsX),_positionX] call BIS_fnc_nearestPosition;
        // Reinforcement logic...
    };
};
Explanation: If the control point was conquered, and it is not a "default" control point (meaning it's a custom one added by the mission), a timer starts (2 hours). After the timer, the location is automatically retaken by the nearest base (Airport or Main Base), simulating enemy reinforcements pushing back the line.
Where it leads:

Called by: A3A_fnc_cycleSpawn (or similar server scheduler).
Calls:
Faction(_sideX): Retrieves unit/vehicle pools.
A3A_fnc_isFrontline: Checks if marker is on the frontline.
BIS_fnc_DirTo: Calculates road direction.
A3A_fnc_createUnit: Spawns infantry.
A3A_fnc_spawnGroup: Spawns squad groups.
A3A_fnc_patrolLoop: Assigns AI movement orders.
A3A_fnc_AIVEHinit: Initializes vehicles (texture, lock state).
A3A_fnc_NATOinit: Adds killed event handlers and skill adjustments.
A3A_fnc_citySupportChange: Updates city loyalty.
Global Variables Modified:
sidesX: Updates side ownership of the marker.
A3A_hasIFA: Global flag for IFA mod detection (set once).
spawner: Local variable (per marker) used for simulation management.
Network Implications: Heavy use of remoteExec for enableSimulationGlobal, setFlagTexture, and notifications. Requires server-client synchronization for vehicle ownership and side changes.
Function Name: A3A\fn_createAIMilAdmin.sqf
What it does: This function handles the dynamic spawning of a "Military Administration" location. Unlike a standard spawn, this location relies on a pre-placed building object (A3A_milAdministrations). The function spawns garrison troops, a patrol team, an officer, parked vehicles, supply crates, and dynamically placed POWs. It monitors the building's integrity and the officer's status to trigger capture or destruction events.

How it does that: The function locates the specific building object associated with the marker, validates it, and then sequentially spawns different AI types into specific building positions obtained via SCRT_fnc_common_getMilAdminGarrisonPositions.

1. Object Association and Validation

Sqf

Apply
params["_marker"];

private _milAdministrationPos = getMarkerPos _marker;
private _milAdministrationIndex = A3A_milAdministrations findIf { _milAdministrationPos distance2D _x < 30 };
if (_milAdministrationIndex isEqualTo -1) exitWith { Error_1(...) };

private _milAdministration = A3A_milAdministrations select _milAdministrationIndex;
if (_milAdministration isEqualTo objNull) exitWith { Error_1(...) };
if (!alive _milAdministration) exitWith { Warning_1(...) };
Explanation: The function accepts a marker. It looks up the actual in-game building object from the global array A3A_milAdministrations by finding the closest object within 30 meters. It validates that the object exists and is alive before proceeding. This links the abstract map marker to the physical 3D object.
2. Difficulty and Faction Setup

Sqf

Apply
private _isDifficult = [_marker] call A3A_fnc_isFrontline || {random 10 < tierWar + aggressionOccupants/10};
private _faction = Faction(_side);

if (_isDifficult) then {
    _leader = FactionGet(occ,"unitMilitiaGrunt");
    _unitPool = [ (_faction get "unitMilitiaGrunt"), ... ];
    _carPool = _faction get "vehiclesMilitiaCars";
} else {
    _leader = (_faction get "unitPoliceOfficer");
    _unitPool = [ (_faction get "unitPoliceGrunt") ];
    _carPool = _faction get "vehiclesPolice";
};
Explanation: Determines if the admin is near the frontline or has high aggression (high tierWar). If difficult, it uses military units and cars. If not difficult, it uses police units and police cars. This creates a visual difference between frontline bases (militarized) and rear-area bases (police stations).
3. Patrol Group Spawning

Sqf

Apply
private _patrolGroupRoster = [_leader, selectRandom _unitPool];
private _patrolPosition = [
    _milAdministrationPos, 0, 200, 3, 0, 1, 0, [], [_milAdministrationPos, _milAdministrationPos]
] call BIS_fnc_findSafePos;

private _patrolGroup = [_patrolPosition, _side, _patrolGroupRoster] call A3A_fnc_spawnGroup;
[_patrolGroup, _milAdministrationPos, 250] call bis_fnc_taskPatrol;
Explanation: Finds a safe position (land, 200m radius, no water) to spawn a small patrol group. This group is given a taskPatrol radius of 250m around the administration building to simulate outer security.
4. Garrison Spawning (Building Interiors)

Sqf

Apply
private _positionsTuple = _milAdministration call SCRT_fnc_common_getMilAdminGarrisonPositions;
private _buildingPositions = _positionsTuple select 0;
private _soldierPositions = _positionsTuple select 1;
// ...
private _soilderCount = if (_isDifficult) then {round (random [4, 6, 8])} else {round (random [3, 5, 7])};
private _garrisonGroup = createGroup _side;

for "_i" from 0 to _soilderCount do {
    private _buildingPosIndex = selectRandom _soldierPositions;
    private _buildingPosition = _buildingPositions select _buildingPosIndex;
    private _soldier = [_garrisonGroup, (selectRandom _unitPool), _buildingPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
    _soldier allowDamage false;
    _soldier setunitpos "UP";
    _soldier disableAI "PATH";
    sleep 0.5;
    _soldier allowDamage true;
    _soldiers pushBack _soldier;
};
Explanation: Calls a helper function to get valid positions inside the building (floors, rooms).
It loops to spawn soldiers. Crucially, it disables damage and pathfinding (disableAI "PATH") while placing the unit to prevent them from falling through the floor or getting stuck during the placement process. It re-enables damage after a small delay.
5. POW Spawning

Sqf

Apply
private _powCd = garrison getVariable [_marker + "_powCD", 0];
if (_powCd == 0) then {
    _grpPOW = createGroup teamPlayer;
    private _powCount = random [1, 3, 5];
    for "_i" from 0 to _powCount do {
        private _buildingPosIndex = selectRandom _powPositions;
        private _buildingPosition = _buildingPositions select _buildingPosIndex;
        _unit = [_grpPOW, FactionGet(reb,"unitUnarmed"), _buildingPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
        // ... make captive, disable AI, remove weapons ...
        [_unit,"prisonerFlee"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
    };
} else {
    // Update cooldown logic...
};
Explanation: Checks a cooldown variable (_marker + "_powCD") stored in the garrison namespace. If 0, it spawns unarmed prisoners in specific "pow" positions.
It sets them as captive (invulnerable to AI), disables all AI behavior so they don't run, and adds a flag action (interaction) for players to free them.
6. Parked Vehicle and Equipment Crate

Sqf

Apply
// Vehicle
private _road = objNull;
private _radiusX = 5;
while {true} do {
    _road = _milAdministrationPos nearRoads _radiusX;
    if (count _road > 0) exitWith {};
    _radiusX = _radiusX + 5;
};
private _parkedVehicle = createVehicle [_vehClass, _spawnPos, [], 0, "NONE"];

// Crate
if (garrison getVariable [_marker + "_lootCD", 0] == 0) then {
    private _ammoBox = createVehicle [_ammoBoxType, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _ammoBox addEventHandler ["Killed", { [_this#0] spawn { sleep 10; deleteVehicle (_this#0) } }];
    _crateContents call A3A_fnc_fillLootCrate;
};
Explanation: Finds the nearest road to spawn a parked vehicle (aligned to the road).
Spawns an equipment crate (if cooldown is 0). Adds a Killed event handler to automatically delete the wreck after 10 seconds to prevent script lag. Fills it with loot using A3A_fnc_fillLootCrate.
7. Conquest Monitoring

Sqf

Apply
waitUntil {sleep 1; spawner getVariable _marker == 2 or {!alive _milAdministration or {!alive _collaborant}}};

switch (true) do {
    case (!alive _collaborant): {
        [_milAdministration, "CAPTURE"] call SCRT_fnc_location_removeMilAdmin;
    };
    case (!alive _milAdministration): {
        [_milAdministration, "DESTROY"] call SCRT_fnc_location_removeMilAdmin;
    };
};
Explanation: Waits for the location to be despawned (player leaves), OR the building dies, OR the officer dies.
If the officer dies, it triggers a "Capture" event (e.g., liberation of the location).
If the building is destroyed, it triggers a "Destroy" event.
Where it leads:

Called by: A3A_fnc_cycleSpawn or A3A_fnc_scheduler.
Calls:
SCRT_fnc_common_getMilAdminGarrisonPositions: Fetches coordinate arrays for building placement.
A3A_fnc_spawnGroup: Spawns patrol, garrison, and POW groups.
A3A_fnc_createUnit: Spawns individual units.
A3A_fnc_fillLootCrate: Populates supply crate.
SCRT_fnc_location_removeMilAdmin: Handles the logic for removing the location from the active map and awarding resources.
bis_fnc_taskPatrol: Assigns AI patrol waypoints.
Global Variables Modified:
A3A_milAdministrations: Read-only access to find the building object.
garrison: Writes powCD and lootCD (cooldown timers) to the namespace.
spawner: Monitors state.
Synchronization: Uses remoteExec for prisoner flag actions so all players see the interaction option. Loot crate spawning and filling is server-side. Event triggers (SCRT_fnc_location_removeMilAdmin) handle multiplayer synchronization.

fn_createAIMilAdmin.sqf
Function Name: fn_createAIMilAdmin.sqf
What it does: This function spawns and manages a Military Administration (mil-admin) location for the AI side in the A3A Antistasi mission. It handles the creation of enemy personnel, vehicles, and static objects at a military administration building, including patrol groups, garrison units, prisoner of war (POW) NPCs, parked vehicles, and an officer NPC. It also manages loot crates and the despawning of all created entities when the mission ends or the location is neutralized. The function is designed to run on the server only, exiting early if the client has an interface or is not the server.

How it does that:

1. Initial Setup and Validation
The function begins by receiving the marker name as input and validating the environment and the associated military administration building.

Sqf

Apply
params["_marker"];

if (!isServer and hasInterface) exitWith {};

private _milAdministrationPos = getMarkerPos _marker;
private _milAdministrationIndex = A3A_milAdministrations findIf { _milAdministrationPos distance2D _x < 30 };
if (_milAdministrationIndex isEqualTo -1) exitWith {
	Error_1("For some reason %1 mil administration has no corresponding building, aborting.", _marker);
};

private _milAdministration = A3A_milAdministrations select _milAdministrationIndex;

if (_milAdministration isEqualTo objNull) exitWith {
	Error_1("For some reason mil administration %1 object is null, aborting.", _marker);
};
if (!alive _milAdministration) exitWith {
	Warning_1("Mil Admin building %1 was destroyed before (should not spawn at all, suspicious), aborting.", _marker);
};

private _side = sidesX getVariable [_marker, sideUnknown];

if (_side isEqualTo sideUnknown) exitWith {
	Error_1("For some reason mil administration %1 side is %2, aborting.", _marker, str _side);
};

Info_2("Spawning military administration personel for %1 marker on %2 position.", _marker, str _milAdministrationPos);
Explanation:

params["_marker"];: Captures the marker name passed to the function.
if (!isServer and hasInterface) exitWith {};: Ensures the function only runs on the server (not on clients with a UI), preventing duplicated or conflicting executions.
private _milAdministrationPos = getMarkerPos _marker;: Gets the 2D position of the marker.
The findIf loop checks A3A_milAdministrations (a global array of military administration building objects) to find a building within 30 meters of the marker position. If not found, it logs an error and exits.
It retrieves the building object and validates it's not null and is alive (not destroyed). If either check fails, it logs a warning/error and exits.
It retrieves the owning side of the marker from the sidesX namespace. If the side is sideUnknown, it errors out and exits.
An informational message is logged to the server console.
2. Variable Initialization and Difficulty Calculation
Next, it initializes containers for spawned entities and determines if the location should be difficult based on frontline status and war tier.

Sqf

Apply
private _vehicles = [];
private _groups = [];
private _soldiers = [];
private _POWs = [];

private _isDifficult = [_marker] call A3A_fnc_isFrontline || {random 10 < tierWar + aggressionOccupants/10};
private _faction = Faction(_side);

private _leader = "";
private _unitPool = [];
private _carPool = [];

if (_isDifficult) then {
	_leader = FactionGet(occ,"unitMilitiaGrunt");
	_unitPool = [
		(_faction get "unitMilitiaGrunt"),
		(_faction get "unitMilitiaMarksman"),
		(_faction get "unitMilitiaGrenadier"),
		(_faction get "unitMilitiaSniper"),
		(_faction get "unitMilitiaMedic")
	];
	_carPool = _faction get "vehiclesMilitiaCars";
} else {
	_leader = (_faction get "unitPoliceOfficer");
	_unitPool = [(_faction get "unitPoliceGrunt")];
	_carPool = _faction get "vehiclesPolice";
};
Explanation:

Arrays _vehicles, _groups, _soldiers, and _POWs are created to track all spawned entities for later cleanup.
_isDifficult: Boolean calculated using A3A_fnc_isFrontline (checks if the marker is on the frontline) or a random chance based on tierWar (global variable representing the current war level) and aggressionOccupants (AI side aggression level). If true, the location will have a stronger garrison.
_faction: Retrieves the faction configuration for the calculated _side using the Faction macro.
Based on _isDifficult, it selects unit types and vehicle pools. If difficult, it uses militiamen and militia cars. If not difficult, it uses police units and police cars.
3. Patrol Group Spawning
A patrol group is created and assigned a patrol task around the military administration.

Sqf

Apply
private _patrolGroupRoster = [_leader, selectRandom _unitPool];
private _patrolPosition = [
	_milAdministrationPos,
	0,
	200,
	3,
	0,
	1,
	0,
	[],
	[_milAdministrationPos, _milAdministrationPos]
] call BIS_fnc_findSafePos;

private _patrolGroup = [_patrolPosition, _side, _patrolGroupRoster] call A3A_fnc_spawnGroup;
{
	[_x] call A3A_fnc_NATOinit;
	_soldiers pushBack _x;
} forEach units _patrolGroup;
[_patrolGroup, _milAdministrationPos, 250] call bis_fnc_taskPatrol;
_groups pushBack _patrolGroup;
Explanation:

_patrolGroupRoster: Defines the composition of the patrol group (1 leader + 1 random unit from the pool).
BIS_fnc_findSafePos: Finds a position within 200 meters of the mil-admin, trying to avoid water and attempting 3 tries per radius step. It starts at 0m radius and expands to 200m if needed.
A3A_fnc_spawnGroup: Spawns the group at the found position with the defined side and roster.
The loop iterates over each unit in the new group, initializes it using A3A_fnc_NATOinit (sets skill, loadout, etc.), and adds it to the _soldiers array for tracking.
bis_fnc_taskPatrol: Assigns a patrol task to the group, circling within 250 meters of the mil-admin center.
The group reference is pushed to the _groups array for later deletion.
4. Garrison Spawning
The function determines valid positions inside the military administration building and spawns garrison units there.

Sqf

Apply
private _positionsTuple = _milAdministration call SCRT_fnc_common_getMilAdminGarrisonPositions;
private _buildingPositions = _positionsTuple select 0;
private _soldierPositions = _positionsTuple select 1;
private _cratePositions = _positionsTuple select 2;
private _leaderPositions = _positionsTuple select 3;
private _powPositions = _positionsTuple select 4;

private _soilderCount = if (_isDifficult) then {round (random [4, 6, 8])} else {round (random [3, 5, 7])};
private _garrisonGroup = createGroup _side;
private _pickedIndexes = [];
for "_i" from 0 to _soilderCount do {
	private _buildingPosIndex = selectRandom _soldierPositions;
	private _findIndex = _pickedIndexes find _buildingPosIndex;
	while {_findIndex != -1} do {
		_buildingPosIndex = selectRandom _soldierPositions;
		_findIndex = _pickedIndexes find _buildingPosIndex;
	};
	_pickedIndexes pushBack _buildingPosIndex;

	private _buildingPosition = _buildingPositions select _buildingPosIndex;
	if (isNil "_buildingPosition") then {
		continue;
	};
	private _soldier = [_garrisonGroup, (selectRandom _unitPool), _buildingPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
	_soldier allowDamage false;
	_soldier setunitpos "UP";
	_soldier disableAI "PATH";
	[_soldier] call A3A_fnc_NATOinit;
	sleep 0.5;
	_soldier allowDamage true;
	_soldiers pushBack _soldier;
};
_groups pushBack _garrisonGroup;
Explanation:

SCRT_fnc_common_getMilAdminGarrisonPositions: A helper function that returns a tuple of position arrays for the specific building model (indices for building positions, soldier spots, crate spots, leader spots, and POW spots).
_soilderCount: Determines how many garrison soldiers to spawn based on difficulty (random between min/average/max values).
createGroup _side: Creates an empty group for the garrison units.
for loop: Spawns soldiers one by one.
It selects a random index from _soldierPositions (positions where soldiers can stand). It checks _pickedIndexes to ensure no duplicate positions are selected.
It retrieves the actual 3D position from _buildingPositions using the index.
A3A_fnc_createUnit: Spawns a unit at the specific building position.
Pre-spawn protection: The unit is temporarily invulnerable (allowDamage false), set to stand (setunitpos "UP"), and disabled from moving (disableAI "PATH").
The unit is initialized with A3A_fnc_NATOinit, then after a 0.5 second sleep (to prevent physics glitches), damage is re-enabled. The unit is added to _soldiers.
Finally, the garrison group is added to _groups.
5. Prisoner of War (POW) Spawning
The function checks a cooldown timer for POWs and spawns them if available.

Sqf

Apply
private _grpPOW = nil;

private _powCd = garrison getVariable [_marker + "_powCD", 0];
if (_powCd == 0) then {
	_grpPOW = createGroup teamPlayer;
	private _powCount = random [1, 3, 5];

	for "_i" from 0 to _powCount do {
		private _buildingPosIndex = selectRandom _powPositions;
		private _buildingPosition = _buildingPositions select _buildingPosIndex;

		_unit = [_grpPOW, FactionGet(reb,"unitUnarmed"), _buildingPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
		_unit allowDamage false;
		[_unit,true] remoteExec ["setCaptive",0,_unit];
		_unit setCaptive true;
		_unit disableAI "MOVE";
		_unit disableAI "AUTOTARGET";
		_unit disableAI "TARGET";
		_unit setUnitPos "UP";
		_unit setBehaviour "CARELESS";
		_unit allowFleeing 0;
		removeAllWeapons _unit;
		removeAllAssignedItems _unit;
		_POWS pushBack _unit;
		[_unit,"prisonerFlee"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
		[_unit] call A3A_fnc_reDress;
	};

	{
		_x allowDamage true;
	} forEach _POWS;
} else {
	private _newValue = _powCd - time;
	if (_newValue < 0) then {_newValue = 0};
	garrison setVariable [_marker + "_powCD", _newValue];
};
Explanation:

_powCd: Checks the garrison namespace for a cooldown variable named marker_powCD. If 0, POWs can spawn.
If spawning is allowed:
Creates a group belonging to teamPlayer (independent rebels), as POWs are friendly to players.
Calculates a random count of POWs.
Selects a position from the pre-calculated _powPositions.
Spawns an unarmed rebel unit (unitUnarmed) at that position.
Set up as POW: Disables damage temporarily, makes the unit captive (captures them), disables movement and combat AI, sets behavior to CARELESS, and removes all gear.
Adds the unit to the _POWS array.
Adds the "prisonerFlee" flag action to the unit remotely for players.
Calls A3A_fnc_reDress to potentially apply a prisoner-specific uniform/appearance.
After setup, enables damage on all spawned POWs.
If cooldown is active, it decrements the cooldown time stored in the garrison namespace (using time, which is mission time).
6. Parked Vehicle Spawning
A static vehicle is spawned on a nearby road.

Sqf

Apply
private _road = objNull;
private _radiusX = 5;

while {true} do {
	_road = _milAdministrationPos nearRoads _radiusX;
	if (count _road > 0) exitWith {};
	_radiusX = _radiusX + 5;
};

private _roadcon = roadsConnectedto (_road select 0);
private _dirveh = if(count _roadcon > 0) then {[_road select 0, _roadcon select 0] call BIS_fnc_DirTo} else {random 360};
private _roadPosition = getPos (_road select 0);

private _vehClass = selectRandom _carPool;
private _spawnPos = (getPos (_road select 0)) findEmptyPosition [0, 10, _vehClass];
if (isNil "_spawnPos") then {
	_spawnPos = getPos (_road select 0);
};

private _parkedVehicle = createVehicle [_vehClass, _spawnPos, [], 0, "NONE"];
_parkedVehicle setDir _dirveh + 45;
[_parkedVehicle, _side] call A3A_fnc_AIVEHinit;

if (!_isDifficult) then {
	[_parkedVehicle, ["BeaconsStart", 1]] remoteExecCall ["animate", 0, _parkedVehicle];
};

_vehicles pushBack _parkedVehicle;
{ _x setVariable ["originalPos", getPos _x] } forEach _vehicles;
Explanation:

A loop expands the search radius (starting at 5m) until a road object is found near the mil-admin.
roadsConnectedto: Finds connected roads to determine the road's direction.
BIS_fnc_DirTo: Calculates the direction between the road and its connection. If no connection, uses a random direction.
Selects a vehicle class from the car pool.
Finds an empty position on the road for the vehicle. If none found, defaults to the road position.
Spawns the vehicle, adds 45 degrees to the calculated direction (often to angle it along the road).
Initializes the vehicle using A3A_fnc_AIVEHinit (sets side, locks it, etc.).
If not difficult (police), it animates the vehicle's beacons on (remote execution for all clients).
Adds the vehicle to _vehicles and stores its original position in a variable for later tracking (to see if it was moved/stolen).
7. Officer (Collaborant) Spawning
Spawns a high-value NPC (the collaborant) inside the building.

Sqf

Apply
private _groupCollaborant = createGroup _side;
private _buildingPosIndex = selectRandom _leaderPositions;
private _buildingPosition = _buildingPositions select _buildingPosIndex;

private _collaborant = [_groupCollaborant, (_faction get "unitOfficial"), _buildingPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
_collaborant setPosATL _buildingPosition;
_collaborant setunitpos "UP";
_collaborant disableAI "PATH";
[_collaborant] call A3A_fnc_NATOinit;

_soldiers pushBack _collaborant;
_groups pushBack _groupCollaborant;
Explanation:

Creates a new group for the officer.
Selects a specific position from _leaderPositions (spots designated for leaders inside the building).
Spawns a unit of type unitOfficial (an officer) at that position.
Fixes the position (setPosATL), sets stance, disables movement, and initializes the unit.
Adds the officer to tracking arrays. This officer is a critical target; killing/capturing him completes the location capture.
8. Equipment (Ammo) Box Spawning
Spawns a loot crate if the cooldown has expired.

Sqf

Apply
private _ammoBox = if (garrison getVariable [_marker + "_lootCD", 0] == 0) then {
	private _ammoBoxPosition = _buildingPositions select (selectRandom _cratePositions);
	_ammoBoxPosition = _ammoBoxPosition vectorAdd [0,0,1];
	private _ammoBoxType = _faction get "equipmentBox";
	private _ammoBox = createVehicle [_ammoBoxType, [0, 0, 0], [], 0, "CAN_COLLIDE"];
	_ammoBox allowDamage false;
	_ammoBox setPosATL _ammoBoxPosition;
	_ammoBox setDir (getDir _milAdministration);

	// Otherwise when destroyed, ammoboxes sink 100m underground and are never cleared up
	_ammoBox addEventHandler ["Killed", { [_this#0] spawn { sleep 10; deleteVehicle (_this#0) } }];

	private _playerCount = count (allPlayers - entities "HeadlessClient_F");
	private _crateContents = selectRandom [
		[_ammoBox, 2, _playerCount, 0, 0, 1, (round random [6,8,9]), 0, 0, 0, 0, 0, 0, 0, 0, 1, _playerCount, 0, 0],
		[_ammoBox, 3, _playerCount, 0, 0, 1, (round random [4,5,7]), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[_ammoBox, 4, _playerCount, 0, 0, 1, (round random [6,8,9]), 1, 1, 0, 0, 0, 0, 1, 0, 0, _playerCount, 0, 0]
	];

	_crateContents call A3A_fnc_fillLootCrate;
	[_ammoBox, nil, true] call A3A_Logistics_fnc_addLoadAction;
	[_ammoBox] remoteExec ["SCRT_fnc_common_addActionMove", [teamPlayer, civilian], _ammoBox];

	sleep 2;
	_ammoBox allowDamage true;

	_ammoBox;
};
Explanation:

Checks loot cooldown in the garrison namespace. If 0, proceeds.
Selects a random crate position from the pre-calculated list and offsets it slightly upward (Z+1) to prevent floating issues.
Spawns the equipment box class defined in the faction.
Adds a Killed event handler that deletes the wreck after 10 seconds to prevent physics issues (sinking into ground).
Calculates playerCount to scale loot quantity.
Selects a random loot configuration array (different ammo/weapon counts) and calls A3A_fnc_fillLootCrate to populate it.
Adds logistics actions (load into vehicle) and a "Move" action for the correct side remotely.
Sleeps 2 seconds to allow object creation to settle, then enables damage so players can blow it up.
9. Waits and Logic for Location Capture
The function enters a waiting state until the location is captured, destroyed, or despawned.

Sqf

Apply
waitUntil {sleep 1; spawner getVariable _marker == 2 or {!alive _milAdministration or {!alive _collaborant}}};

switch (true) do {
	case (!alive _collaborant): {
		Info_1("Military Administration %1 was captured - collaborant has been killed.", _marker);
		[_milAdministration, "CAPTURE"] call SCRT_fnc_location_removeMilAdmin;
	};
	case (!alive _milAdministration): {
		Info_1("Military Administration %1 was destroyed.", _marker);
		[_milAdministration, "DESTROY"] call SCRT_fnc_location_removeMilAdmin;
	};
};
Explanation:

waitUntil: Pauses execution. It continues when:
spawner getVariable _marker == 2: The marker is flagged for despawning (player left the area).
OR the mil-admin building is dead.
OR the collaborant officer is dead.
switch statement: Checks conditions to determine why the wait ended.
If the collaborant is dead, it logs capture and calls SCRT_fnc_location_removeMilAdmin with the "CAPTURE" reason. This likely updates global state and triggers rewards.
If the building is dead (destroyed), it logs destruction and calls the same function with the "DESTROY" reason.
10. Despawn Cleanup
Once the wait is over (regardless of cause), it waits a final moment for the spawner status, then cleans up entities.

Sqf

Apply
waitUntil {sleep 1; (spawner getVariable _marker == 2)};

{deleteVehicle _x} forEach (_soldiers select {alive _x});
{deleteGroup _x} forEach _groups;

{
	// delete all vehicles that haven't been stolen
	if (_x getVariable ["ownerSide", _side] == _side) then {
		if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
		else { if !(_x isKindOf "StaticWeapon") then { [_x] spawn A3A_fnc_VEHdespawner } };
	};
} forEach _vehicles;

// If loot crate was stolen, set the cooldown
if (!isNil "_ammoBox") then {
	if ((alive _ammoBox) and (_ammoBox distance2d _milAdministrationPos < 100)) exitWith { deleteVehicle _ammoBox };
	if (alive _ammoBox) then { [_ammoBox] spawn A3A_fnc_VEHdespawner };
	private _lootCD = 120*16 / ([_marker] call A3A_fnc_garrisonSize);
	garrison setVariable [_marker + "_lootCD", _lootCD, true];
};

if (count (units _grpPOW) != count _POWs) then {
	private _powCD = 120*16 / ([_marker] call A3A_fnc_garrisonSize);
	garrison setVariable [_marker + "_powCD", time + 3600, true];
};

// {deleteVehicle _x} forEach _POWs;
// deleteGroup _grpPOW;
if (!isNil "_grpPOW") then {
	[_grpPOW] spawn A3A_fnc_groupDespawner;
};

["locationSpawned", [_marker, "MilAdmin", false]] call EFUNC(Events,triggerEvent);
Explanation:

Final Wait: Ensures the marker is fully set to despawn state (2).
Soldier Cleanup: Deletes any alive soldiers and their groups.
Vehicle Cleanup: Iterates through vehicles. If the vehicle still belongs to the original side and is within 100m of its spawn point, it's deleted. If it's far away (stolen), it's despawned using A3A_fnc_VEHdespawner (async cleanup).
Loot Crate Logic:
If the crate exists and is alive and near the mil-admin, it's deleted (returned to base).
If it's alive but far away (stolen), it's despawned, and a loot cooldown is set in the garrison namespace. The cooldown duration scales inversely with the garrison size of the marker.
POW Cleanup Logic:
If the number of units in the POW group doesn't match the original count (meaning some escaped or were rescued), a POW cooldown is set.
The POW group is despawned using A3A_fnc_groupDespawner.
Event Trigger: Fires a "locationSpawned" event with false status, signaling the location is no longer active.
Function Name: fn_createAIMilbase.sqf
What it does: This function spawns and manages a Military Base location for the AI side. It is significantly more complex than the mil-admin function, responsible for spawning static defenses (SAM sites, mortars), AI patrols, vehicle crews, garrison units, parked vehicles, heavy patrol vehicles, boats, and managing loot crates. It handles logic for frontline status, spawn position validation, and cleanup. It also calculates spawn counts based on the marker's size and war tier.

How it does that:

1. Initial Setup and Pre-checks
Initializes variables and performs early exit checks.

Sqf

Apply
if (!isServer and hasInterface) exitWith{};

params ["_markerX"];

//Not sure if that ever happens, but it reduces redundance
if(spawner getVariable _markerX == 2) exitWith {};

ServerInfo_1("Spawning Military Base %1", _markerX);

private _vehiclesX = [];
private _groups = [];
private _soldiers = [];
private _props = [];
private _dogs = []; //dogs are used in fn_location_createPatrols, removing this variable will break spawn
private _spawnsUsed = [];

private _positionX = getMarkerPos (_markerX);

private _size = [_markerX] call A3A_fnc_sizeMarker;

private _frontierX = [_markerX] call A3A_fnc_isFrontline;
private _busy = false;	//if (dateToNumber date > server getVariable _markerX) then {false} else {true};
private _nVeh = round (_size/60);

private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _faction = Faction(_sideX);
Explanation:

Server check and early exit if spawner variable is 2 (despawned).
_size: Calculates the marker's area size using A3A_fnc_sizeMarker. This influences the number of spawned units.
_frontierX: Checks if the marker is on the frontline.
_nVeh: Calculates a rough number of vehicles to spawn based on marker size (1 vehicle per ~60 sqm).
Retrieves side and faction information.
2. SAM Site Spawning
Checks for cooldown and spawns a radar and SAM vehicle if available.

Sqf

Apply
private _radarType = _faction getOrDefault ["vehicleRadar", ""];
private _samType = _faction getOrDefault ["vehicleSam", ""];

// In case of array
if (_radarType isEqualType [] && {_radarType isNotEqualTo []}) then {_radarType = selectRandom _radarType};
if (_samType isEqualType [] && {_samType isNotEqualTo []}) then {_samType = selectRandom _samType};

// In case of empty array
if (_samType isEqualType [] && {_samType isEqualTo []}) then {_samType = ""};
if (_radarType isEqualType [] && {_radarType isEqualTo []}) then {_radarType = ""};

if (garrison getVariable [_markerX + "_samDestroyedCD", 0] == 0) then 
{
	if (_radarType != "" && {_samType != ""}) then 
	{
		private _spawnParameter = [_markerX, "Sam"] call A3A_fnc_findSpawnPosition;
		if !(_spawnParameter isEqualType []) exitWith {};
		_spawnsUsed pushBack _spawnParameter#2;

		{
			private _aaVehicle = nil;
			isNil {
				_aaVehicle = [_x, _spawnParameter select 0, 25, 10, true] call A3A_fnc_safeVehicleSpawn;
				_aaVehicle setDir (_spawnParameter select 1);
			};

			private _aaGroup = [_sideX, _aaVehicle] call A3A_fnc_createVehicleCrew;
			[_aaVehicle, _sideX] call A3A_fnc_AIVEHinit;

			_soldiers append (units _aaGroup); //not sure if needed
			_groups pushBack _aaGroup;
			_vehiclesX pushBack _aaVehicle;

			//radar rotation
			if(_x isEqualTo _radarType) then {
				_aaVehicle spawn {
					while {alive _this} do {
						{
							_this lookAt (_this getRelPos [100, _x]);
							sleep 2.45;
						} forEach [120, 240, 0];
					};
				};
				_aaVehicle setVehicleRadar 1;
				_aaVehicle setVehicleReportRemoteTargets true;
			};

			_aaVehicle setVariable ["A3A_samMarker", _markerX];
			_aaVehicle addEventHandler ["Killed", { 
				private _marker = _this#0 getVariable ["A3A_samMarker", ""];
				if (_marker isNotEqualTo "") then {
					private _varName = _marker + "_samDestroyedCD";
					private _previousValue = garrison getVariable [_varName, 0];
					garrison setVariable [_varName, (_previousValue + 900), true];
				};
			}];
		} forEach [_radarType, _samType];
	};
};
Explanation:

Fetches radar and SAM types from faction config. Handles cases where they are arrays (random selection).
Checks the SAM cooldown in the garrison namespace. If 0, proceeds.
Finds a valid spawn position for "Sam" type using A3A_fnc_findSpawnPosition.
Iterates over radar and SAM types (if valid).
Spawns the vehicle using A3A_fnc_safeVehicleSpawn (which handles empty position finding).
Creates a crew for the vehicle using A3A_fnc_createVehicleCrew.
Initializes the vehicle.
Radar Specific Logic: If the vehicle is a radar, it starts a spawn loop to rotate the vehicle's look direction every 2.45 seconds (simulating scanning). It enables the vehicle radar and remote target reporting.
Adds a Killed event handler to the vehicle. When killed, it updates the SAM cooldown variable in the garrison namespace by adding 900 seconds (15 minutes).
3. Static AT on Frontline
If on the frontline, spawns a static AT gun.

Sqf

Apply
if (_frontierX) then {
	private _roads = _positionX nearRoads _size;
	if (count _roads != 0) then {
		private _groupX = createGroup _sideX;
		_groups pushBack _groupX;
		private _typeVehX = selectRandom (_faction get "staticAT");

		if (_faction getOrDefault ["noSandbag", false]) then {		
			private _veh = _typeVehX createVehicle _positionX;
			_vehiclesX pushBack _veh;
			_veh setPos _pos;
			_veh setDir _dirVeh + 180;
			private _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
			private _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
			_unit moveInGunner _veh;
			[_unit,_markerX] call A3A_fnc_NATOinit;
			[_veh, _sideX] call A3A_fnc_AIVEHinit;
			_soldiers pushBack _unit;
		} else {
			private _bunker = (_faction get "sandbag") createVehicle _pos;
			_vehiclesX pushBack _bunker;
			_bunker setDir _dirveh;
			_pos = getPosATL _bunker;
			private _veh = _typeVehX createVehicle _positionX;
			_vehiclesX pushBack _veh;
			_veh setPos _pos;
			_veh setDir _dirVeh + 180;
			private _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
			private _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
			_unit moveInGunner _veh;
			[_unit,_markerX] call A3A_fnc_NATOinit;
			[_veh, _sideX] call A3A_fnc_AIVEHinit;
			_soldiers pushBack _unit;
		};
	};
};
Explanation:

Checks if _frontierX is true.
Finds nearby roads. If roads exist:
Creates a group.
Selects a static AT vehicle class.
Checks if the faction requires sandbags (noSandbag flag).
If no sandbags: Spawns the AT gun directly.
If sandbags: Spawns a sandbag object first, then spawns the AT gun on top of it.
Gets the tiered crew unit type, spawns the unit, and moves them into the gunner position.
Initializes both unit and vehicle.
Adds them to tracking arrays.
4. Patrol Area Creation and Additional Garrison
Creates a debug marker and spawns additional garrison units if the base is reinforced.

Sqf

Apply
private _mrk = createMarkerLocal [format ["%1patrolarea", random 100], _positionX];
// ... marker settings (rectangle, size, color) ...
if (!debug) then {_mrk setMarkerAlphaLocal 0};

private _additionalGarrison = [_sideX, _markerX] call SCRT_fnc_garrison_rollOversizeGarrison;
if (_additionalGarrison isNotEqualTo []) then {
	for "_i" from 0 to (count _additionalGarrison) - 1 do {
		private _groupTypes = _additionalGarrison select _i;
		private _group = [_positionX, _sideX, _groupTypes, false, true] call A3A_fnc_spawnGroup;
		if !(isNull _group) then {
			sleep 1;
			[_group, "Patrol_Defend", 0, 200, -1, true, _positionX, false] call A3A_fnc_patrolLoop;
			_groups pushBack _group;
			{[_x] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
		};
	};
};
Explanation:

Creates a local rectangular marker _mrk centered on the base, sized by distanceSPWN (global spawn distance). This is used for patrol logic.
Calls SCRT_fnc_garrison_rollOversizeGarrison to see if the base has received reinforcement units recently.
If there are additional units, it iterates through them, spawns groups, and assigns them a "Patrol_Defend" task using A3A_fnc_patrolLoop within the base area.
5. Patrol Logic and Mortar Spawning
Decides if a patrol should run and spawns mortars with protective sandbags.

Sqf

Apply
private _garrison = garrison getVariable [_markerX,[]];
_garrison = _garrison call A3A_fnc_garrisonReorg;

private _radiusX = count _garrison;
private _patrol = true;

if (_radiusX < ([_markerX] call A3A_fnc_garrisonSize)) then {
	_patrol = false;
} else {
	_patrol = ((markersX findIf {(getMarkerPos _x inArea _mrk) && {sidesX getVariable [_x, sideUnknown] != _sideX}}) == -1);
};

if (_patrol) then {
	[_markerX, _positionX, _sideX, _faction, 5] call SCRT_fnc_location_createPatrols;
};

// Mortar spawning
private _groupX = createGroup _sideX;
_groups pushBack _groupX;
private _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
while {true} do {
	private _spawnParameter = [_markerX, "Mortar"] call A3A_fnc_findSpawnPosition;
	if (_spawnParameter isEqualType false) exitWith {};

	_spawnsUsed pushBack _spawnParameter#2;

	_typeVehX = selectRandom (_faction get "staticMortars");
	_veh = _typeVehX createVehicle (_spawnParameter select 0);
	_veh setDir (_spawnParameter select 1);
	_unit = [_groupX, _typeUnit, _positionX, [], 0, "CAN_COLLIDE"] call A3A_fnc_createUnit;
	_unit moveInGunner _veh;
	[_unit,_markerX] call A3A_fnc_NATOinit;
	[_veh, _sideX] call A3A_fnc_AIVEHinit;
	[_groupX] call A3A_fnc_artilleryAdd;
	_soldiers pushBack _unit;
	_vehiclesX pushBack _veh;
	sleep 1;

	private _mortarPos = _spawnParameter select 0;
	{
		private _relativePosition = [_mortarPos, 4, _x] call BIS_fnc_relPos;
		private _sandbag = createVehicle [_faction get "sandbagRound", _relativePosition, [], 0, "CAN_COLLIDE"];
		_sandbag setDir ([_sandbag, _mortarPos] call BIS_fnc_dirTo);
		_sandbag setVectorUp surfaceNormal position _sandbag;
		_props pushBack _sandbag;
	} forEach [0, 90, 180, 270];
};
Explanation:

Retrieves the current garrison from the garrison namespace and reorganizes it.
Checks patrol conditions:
If the garrison count is lower than the standard garrison size, patrol is disabled.
Otherwise, it checks if any enemy marker is inside the patrol area. If yes, patrol is disabled.
If patrol is enabled, calls SCRT_fnc_location_createPatrols to generate roaming groups.
Mortar Loop: Enters an infinite loop to spawn mortars.
Finds a "Mortar" spawn position.
Spawns the mortar vehicle.
Spawns a crew unit and moves them into it.
Initializes both.
Adds artillery capability to the group (A3A_fnc_artilleryAdd).
Sandbag Creation: Spawns 4 sandbag segments in a circle (0, 90, 180, 270 degrees) around the mortar position, 4 meters out, to provide protection.
6. Military Building Spawning
Calls a helper function to spawn barracks, towers, and other structures.

Sqf

Apply
private _ret = [_markerX,_size,_sideX,_frontierX] call A3A_fnc_milBuildings;

_groups pushBack (_ret select 0);
_vehiclesX append (_ret select 1);
_soldiers append (_ret select 2);
_spawnsUsed append (_ret select 3);

{[_x, _sideX] call A3A_fnc_AIVEHinit} forEach (_ret select 1);
Explanation:

Calls A3A_fnc_milBuildings with marker info. This function handles the complex logic of placing concrete structures, bunkers, and maybe walls around the base area.
It returns a tuple of groups, vehicles, soldiers, and spawn position indices used.
The function appends these returned arrays to the local tracking arrays and initializes the returned vehicles.
7. Intel and Flag Placement
Spawns a flag and potentially an intelligence item.

Sqf

Apply
if(random 100 < (50 + tierWar * 3)) then {
	_large = (random 100 < (40 + tierWar * 2));
	[_markerX, _large] spawn A3A_fnc_placeIntel;
};

private _typeVehX = _faction get "flag";
private _flagX = createVehicle [_typeVehX, _positionX, [],0, "NONE"];

_flagX allowDamage false;
[_flagX,"take"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_flagX];

_vehiclesX pushBack _flagX;
if (flagTexture _flagX != (_faction get "flagTexture")) then {[_flagX,(_faction get "flagTexture")] remoteExec ["setFlagTexture",_flagX]};
Explanation:

Intel: Based on war tier, there's a chance to spawn intel (laptop/document). The size of the intel loot is randomized.
Flag: Creates the faction's flag vehicle object. Makes it invulnerable, adds a "Take" action for players (so they can capture the base).
Pushes the flag to the vehicles array and updates the flag texture remotely to match the faction.
8. Ammunition Box Creation
Defines a function to create loot crates and spawns them if allowed.

Sqf

Apply
private _fnc_createAmmobox = {
	private _ammoBoxType = _faction get "ammobox";
	private _ammoBox = [_ammoBoxType, _positionX, 15, 5, true] call A3A_fnc_safeVehicleSpawn;
	// Otherwise when destroyed, ammoboxes sink 100m underground and are never cleared up
	_ammoBox addEventHandler ["Killed", { [_this#0] spawn { sleep 10; deleteVehicle (_this#0) } }];
	[_ammoBox] spawn A3A_fnc_fillLootCrate;
	[_ammoBox, nil, true] call A3A_Logistics_fnc_addLoadAction;

	_ammoBox;
};

private _ammobox1 = nil;
private _ammobox2 = nil;

// Only create ammoBox if it's been recharged (see reinforcementsAI)
if (garrison getVariable [_markerX + "_lootCD", 0] == 0) then {
	_ammobox1 = call _fnc_createAmmobox;
	_ammobox2 = call _fnc_createAmmobox;
};
Explanation:

Defines a local closure _fnc_createAmmobox that spawns a crate, adds the wreck deletion handler, fills it with loot via A3A_fnc_fillLootCrate, and adds a logistics load action.
Checks the loot cooldown in the garrison namespace. If 0, it calls the function twice to spawn two crates.
9. Heavy Vehicle Spawning (Optional)
Spawns armored vehicles based on base size and war tier.

Sqf

Apply
if (!_busy) then
{
	private _vehPool = [];
	// ... definitions for vehTypes and typeWeight arrays ...
	{
		private _vehs = _faction get _x;
		if (_vehs isEqualTo []) then {continue};
		private _weight = (_typeWeight select _forEachIndex) / count _vehs;
		{
			_vehPool append [_x, _weight];
		} forEach _vehs;
	} forEach _vehTypes;
	for "_i" from 1 to (round (random 2)) do
	{
		_spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
		if (_spawnParameter isEqualType []) then
		{
			private _veh = nil;
			_spawnsUsed pushBack _spawnParameter#2;
			isNil {
				_veh = createVehicle [selectRandomWeighted _vehPool, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
				_veh setDir (_spawnParameter select 1);
			};
			_vehiclesX pushBack _veh;
			[_veh, _sideX] call A3A_fnc_AIVEHinit;
			_nVeh = _nVeh -1;
			sleep 1;
		};
	};
};
Explanation:

Defines pools for APCs, Tanks, etc., with weights inversely proportional to their count in the faction.
Uses selectRandomWeighted to pick a vehicle type based on these weights.
Spawns 1 or 2 vehicles in valid "Vehicle" spawn positions.
Initializes them and updates the vehicle counter.
10. Ground Vehicle Loop
Spawns utility and transport vehicles.

Sqf

Apply
private _groundPool = [];
// ... definitions for vehTypes and vehTypeWeights ...

while {_countX < _nVeh && {_countX < 3}} do {
	private _typeVehX = selectRandomWeighted _groundPool;
	private _spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
	if(_spawnParameter isEqualType [])
	{
		_spawnsUsed pushBack _spawnParameter#2;
		private _veh = nil;
		isNil {
			_veh = createVehicle [_typeVehX, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
			_veh setDir (_spawnParameter select 1);
		};
		_vehiclesX pushBack _veh;
		[_veh, _sideX] call A3A_fnc_AIVEHinit;
		sleep 1;
		_countX = _countX + 1;
	}
	else
	{
		//No further spaces to spawn vehicle
		_countX = _nVeh;
	};
};
Explanation:

Builds a weighted pool of ground vehicles (trucks, light armed, repair, etc.).
Loops to fill the vehicle quota (_nVeh, capped at 3).
Spawns and initializes vehicles. If no spawn position is found, it forces the loop to end.
11. Garrison Unit Loop
Spawns the main infantry garrison units.

Sqf

Apply
{ _x setVariable ["originalPos", getPosATL _x] } forEach _vehiclesX;

private _array = [];
private _subArray = [];
_countX = 0;
_radiusX = _radiusX -1;
while {_countX <= _radiusX} do {
	_array pushBack (_garrison select [_countX,7]);
	_countX = _countX + 8;
};
for "_i" from 0 to (count _array - 1) do {
	private _groupX = if (_i == 0) then {
		[_positionX, _sideX, (_array select _i), true, false] call A3A_fnc_spawnGroup;
	} else {
		private _spawnPosition = [_positionX, 50, 100, 5, 0, -1, 0] call A3A_fnc_getSafePos;
		[_spawnPosition, _sideX, (_array select _i), false, true] call A3A_fnc_spawnGroup;
	};
	_groups pushBack _groupX;
	{
		[_x, _markerX] call A3A_fnc_NATOinit; 
		_soldiers pushBack _x;
	} forEach units _groupX;
	if (_i == 0) then {
		// Sets first loop as garrison, returns additional defense groups if not enough positions found.
		private _additionalGroups = [_groupX, getMarkerPos _markerX, _size] call A3A_fnc_patrolGroupGarrison;
		_groups append _additionalGroups;
	} else {
		[_groupX, "Patrol_Defend", 0, 200, -1, true, _positionX, false] call A3A_fnc_patrolLoop;
	};
};
Explanation:

Splits the garrison array into chunks of 7 units (a squad).
Iterates through chunks.
First chunk: Spawns directly at the base center (_positionX) and calls A3A_fnc_patrolGroupGarrison. This function tries to assign units to building positions (garrison) and returns any excess units as additional groups if building space is limited.
Other chunks: Spawns at a safe position (50-100m away) and assigns a "Patrol_Defend" task to circle the base.
All units are initialized with A3A_fnc_NATOinit.
12. Self-Propelled AA
Spawns mobile AA vehicles based on chance.

Sqf

Apply
if (random 10 < (tierWar + difficultyCoef)) then {
	private _max = if (_frontierX) then {2} else {1};
	for "_i" from 1 to _max do {
		private _spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
		// ... spawn logic ...
		[_groupVeh, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;
		// ... initialization ...
		[(gunner _veh), 300] spawn SCRT_fnc_common_scanHorizon;
		// ...
	};
};
Explanation:

Chance check based on war tier and difficulty coefficient.
Spawns 1 or 2 AA vehicles (more on frontier).
Creates crew, initializes, and assigns an area patrol (radius 250m).
Calls SCRT_fnc_common_scanHorizon on the gunner to simulate scanning for aircraft.
13. Locking and Naval Patrol
Locks vehicles and spawns boats if water is present.

Sqf

Apply
{
  if (_x isKindOf "Static" || _x isKindOf "StaticWeapon") then {continue};
  [_x, true] call A3U_fnc_setLock;
} forEach _vehiclesX;

private _boatType = selectRandom (_faction get "vehiclesGunBoats");
private _mrkMar = seaSpawn select {getMarkerPos _x inArea _markerX};
if (count _mrkMar > 0) then {
	// ... Boat spawn logic ...
	[_groupVeh, "Patrol_Water", 25, 200, -1, true, _pos] call A3A_fnc_patrolLoop;
	// ...
};
Explanation:

Iterates through spawned vehicles and locks them (except statics) using a utility function (A3U_fnc_setLock).
Checks seaSpawn markers (water spawn points) to see if any overlap with the base area.
If water is present, spawns a gunboat, creates crew, and assigns a "Patrol_Water" task.
14. Heavy Patrol Vehicle
Spawns a heavy armored vehicle (tank or APC) patrolling nearby roads.

Sqf

Apply
if (random 100 < (30 + tierWar * 6)) then {
	private _heavyVehPool =  (_faction get "vehiclesTanks") + (_faction get "vehiclesAPCs") + (_faction get "vehiclesLightAPCs") + (_faction get "vehiclesIFVs") + (_faction get "vehiclesLightTanks");
	private _type = selectRandom _heavyVehPool;

	private _road = [_positionX] call A3A_fnc_findNearestGoodRoad;
	if (_road distance2D _positionX > 800) exitWith {};

	private _heavyVehicle = [_type, (position _road), 15, 10] call A3A_fnc_safeVehicleSpawn;
	// ... create crew ...
	[_group, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;
	// ...
};
Explanation:

Chance check.
Finds the nearest good road to the base (must be within 800m).
Spawns a heavy vehicle at the road.
If it's an APC/IFV, it spawns a passenger squad and loads them into the vehicle.
Assigns an area patrol task.
15. Despawn Cleanup
Wait for despawn signal and clean up all entities.

Sqf

Apply
["locationSpawned", [_markerX, "Milbase", true]] call EFUNC(Events,triggerEvent);

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

_spawnsUsed call A3A_fnc_freeSpawnPositions;

{
	// delete all vehicles that haven't been stolen
	if (_x getVariable ["ownerSide", _sideX] == _sideX) then {
		if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
		else { if !(_x isKindOf "StaticWeapon") then { [_x] spawn A3A_fnc_VEHdespawner } };
	};
} forEach _vehiclesX;

deleteMarker _mrk;
{ if (alive _x) then { deleteVehicle _x } } forEach _soldiers;
{ deleteVehicle _x } forEach _dogs;
{ deleteGroup _x } forEach _groups;
{ deleteVehicle _x } forEach _props;

_spawnsUsed call A3A_fnc_freeSpawnPositions;

// If loot crate was stolen, set the cooldown
if (!isNil "_ammoBox1") then {
	if ((alive _ammoBox1) and (_ammoBox1 distance2d _positionX < 100)) exitWith { deleteVehicle _ammoBox1 };
	if (alive _ammoBox1) then { [_ammoBox1] spawn A3A_fnc_VEHdespawner };
	private _lootCD = 120*16 / ([_markerX] call A3A_fnc_garrisonSize);
	garrison setVariable [_markerX + "_lootCD", _lootCD, true];
};
if (!isNil "_ammoBox2") then {
	// ... same logic as above ...
};

["locationSpawned", [_markerX, "Milbase", false]] call EFUNC(Events,triggerEvent);
Explanation:

Fires a "spawned" event.
Waits for despawn variable (spawner).
Free Spawn Positions: Calls A3A_fnc_freeSpawnPositions to mark used indices as available again for future spawns.
Vehicle Cleanup: Same logic as mil-admin (delete if near original pos, despawn if stolen).
Deletes the patrol marker, all alive soldiers, dogs, groups, and static props (sandbags).
Loot Crate Cleanup: Checks both ammo boxes. If alive and near base, delete. If stolen (alive and far), despawn and set loot cooldown in garrison namespace.
Fires a "spawned" event with false status.
Where it leads:
Functions Called by 
fn_createAIMilAdmin.sqf
:
A3A_fnc_isFrontline: Checks if the marker is on the frontline.
Faction(_side) / FactionGet: Retrieves faction configuration data (unit types, vehicle classes).
SCRT_fnc_common_getMilAdminGarrisonPositions: Critical helper. Calculates valid building positions based on the specific model of the military administration building.
A3A_fnc_spawnGroup: Spawns a group of units at a position.
A3A_fnc_createUnit: Spawns a single unit.
A3A_fnc_NATOinit: Initializes a unit (skill, loadout, side affiliation).
bis_fnc_taskPatrol: Assigns a patrol task to a group (Engine function).
A3A_fnc_AIVEHinit: Initializes a vehicle for the AI side (locking, crew, side).
A3A_fnc_reDress: Applies specific uniforms/gear (used for POWs).
SCRT_fnc_location_removeMilAdmin: Handles the logic for capturing/destroying the location (rewards, state change).
A3A_fnc_VEHdespawner: Asynchronously despawns vehicles that have been moved.
A3A_fnc_groupDespawner: Asynchronously despawns groups.
A3A_fnc_garrisonSize: Calculates the intended garrison size for cooldown scaling.
A3A_fnc_fillLootCrate: Populates a crate with random loot.
A3A_Logistics_fnc_addLoadAction: Adds "Load into vehicle" action to the crate.
SCRT_fnc_common_addActionMove: Adds "Move" action to the crate.
EFUNC(Events,triggerEvent): Triggers an event for the mission system.
Functions Called by 
fn_createAIMilbase.sqf
:
A3A_fnc_sizeMarker: Calculates marker area size.
A3A_fnc_isFrontline: Checks frontline status.
Faction(_sideX): Retrieves faction data.
A3A_fnc_findSpawnPosition: Core function. Finds valid spawn locations for specific types (Sam, Mortar, Vehicle) within the marker area, avoiding water, buildings, and using a pool of pre-calculated points.
A3A_fnc_safeVehicleSpawn: Spawns a vehicle at a position, ensuring it's empty and valid.
A3A_fnc_createVehicleCrew: Spawns AI crew for a vehicle.
A3A_fnc_AIVEHinit: Initializes AI vehicle.
SCRT_fnc_unit_getTiered: Gets unit type based on war tier.
A3A_fnc_milBuildings: Critical helper. Spawns concrete structures (barracks, towers, walls) for the military base.
A3A_fnc_patrolGroupGarrison: Tries to assign units to building positions; returns excess groups.
A3A_fnc_patrolLoop: Manages AI patrol behaviors (Patrol_Area, Patrol_Defend, etc.).
SCRT_fnc_location_createPatrols: Generates external patrols for the location.
A3A_fnc_artilleryAdd: Adds artillery support capability to a group.
A3A_fnc_findNearestGoodRoad: Finds a road node.
A3A_fnc_spawnVehicle: Spawns a vehicle with crew (used for boats).
SCRT_fnc_common_scanHorizon: Forces AI to look around.
A3A_fnc_fillLootCrate: Fills ammo boxes.
A3A_Logistics_fnc_addLoadAction: Adds load action to crates.
A3A_fnc_freeSpawnPositions: Returns used spawn indices to the pool.
A3A_fnc_VEHdespawner: Async vehicle cleanup.
A3A_fnc_groupDespawner: Async group cleanup.
A3A_fnc_garrisonSize: Calculates garrison size.
EFUNC(Events,triggerEvent): Triggers events.
Dependencies and System Fit:
A3A_milAdministrations: Global array populated during mission init, containing the building objects.
sidesX: Global namespace storing ownership of markers.
garrison: Global namespace storing cooldowns and garrison data for markers. Both functions read/write to this.
spawner: Global namespace used for despawn signaling.
tierWar & aggressionOccupants: Global variables influencing difficulty and spawn counts.
A3A_milAdministrations / A3A_fnc_milBuildings: These functions rely on pre-placed building positions or generated positions. The system uses a "spawn once" model per session, managed by the spawner variable.
Global Variables Modified:
garrison namespace:
markerName_powCD: Cooldown timer for POW spawns (if escaped/rescued).
markerName_lootCD: Cooldown timer for loot crate spawns (if stolen).
markerName_samDestroyedCD: Cooldown timer for SAM sites (if destroyed).
A3A_milAdministrations: (Indirectly, as objects are deleted, but the array persists).
Synchronization/Network Implications:
Most spawning is server-side only (due to !isServer check). Entities are created on the server.
Remote Executions:
remoteExec ["setCaptive", 0, _unit]: Ensures POWs are captive on all clients.
remoteExec ["A3A_fnc_flagaction", [teamPlayer, civilian], _flagX]: Adds actions to flags and crates for players.
remoteExecCall ["animate", 0, _parkedVehicle]: Syncs police car beacon animation.
Event System: Uses EFUNC(Events,triggerEvent) which likely broadcasts events to all clients (or handles JIP).
Cleanup: Despawning is mostly local to the server, which deletes objects, causing them to vanish on clients. Exceptions are vehicles moved by players (A3A_fnc_VEHdespawner handles transition).

Function Name: fn_createAIOutposts.sqf

What it does: This function spawns an AI-controlled outpost (military installation) within the Antistasi mission. It handles the complete creation of an enemy location, including vehicle and soldier placement, garrisoning buildings, setting up patrols, and managing the lifecycle of the spawned AI assets. It is executed on the server side and is designed to create a persistent AI presence that players can attack or defend against.

How it does that: The function follows a strict sequence: validation, environment setup, specialized unit placement (patrols, mortars, flags), garrison population, cleanup, and lifecycle management.

1. Initialization and Parameter Validation The function begins by including the necessary script component and fixing line numbers for debugging. It checks if the code is running on the server; if not, it exits immediately as AI spawning is a server-only responsibility. It then validates the input marker (_markerX).

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!isServer and hasInterface) exitWith{};

params ["_markerX"];

//Not sure if that ever happens, but it reduces redundance
if(spawner getVariable _markerX == 2) exitWith {};
Context: spawner is a location variable controlling lifecycle. 2 represents the "despawned" or "cleaned" state. This check prevents redundant spawning.
2. Variable Initialization and State Tracking It initializes arrays to track spawned entities (vehicles, groups, soldiers, dogs) and lists of used spawn positions (to avoid object collisions). It retrieves the marker's world position and size (radius).

Sqf

Apply
private _vehiclesX = [];
private _groups = [];
private _soldiers = [];
private _dogs = [];
private _spawnsUsed = [];

private _positionX = getMarkerPos (_markerX);
private _pos = [];

ServerInfo_1("Spawning Outpost %1", _markerX);

private _size = [_markerX] call A3A_fnc_sizeMarker;
private _frontierX = [_markerX] call A3A_fnc_isFrontline;
Context: _frontierX determines if the location is near a frontline, influencing defense type (e.g., static mortars). _size determines how far out entities can spawn.
3. Faction and Side Determination It retrieves the controlling side and faction configuration using the global sidesX and Faction helper.

Sqf

Apply
private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _faction = Faction(_sideX);
Context: Faction returns a structured array of classnames (e.g., _faction get "staticMortars").
4. Specialized Outpost Logic (Antenna & IsFIA Check) It checks if the outpost is an enemy location with a communication tower. If a tower exists, it is assigned to _antenna for later garrisoning. It also calculates _isFIA (simulating a weak FIA presence in the rear).

Sqf

Apply
if (_sideX == Occupants && {_markerX in outposts}) then {
    private _buildings = nearestObjects [_positionX,["Land_TTowerBig_1_F","Land_TTowerBig_2_F","Land_Communication_F"], _size];
    if (count _buildings > 0) then {
        _antenna = _buildings select 0;
    };
};
5. Patrol Area Marker Creation A local rectangular marker (_mrk) is created to define the patrol area radius. This is used later to detect if patrols overlap with enemy sites.

Sqf

Apply
private _mrk = createMarkerLocal [format ["%1patrolarea", random 100], _positionX];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [(distanceSPWN/2),(distanceSPWN/2)];
// ... marker styling ...
if (!debug) then {_mrk setMarkerAlphaLocal 0};
6. Garrison Reinforcement and Oversized Vehicles It calls SCRT_fnc_garrison_rollOversizeVehicle and SCRT_fnc_garrison_rollOversizeGarrison (from external mod/extension) to spawn extra heavy assets or extra squads based on game difficulty or garrison size. These are patrolled immediately.

Sqf

Apply
private _patrolVehicleData = [_sideX, _positionX, _size] call SCRT_fnc_garrison_rollOversizeVehicle;
if (_patrolVehicleData isNotEqualTo []) then {
    private _patrolVeh = _patrolVehicleData select 0;
    private _patrolVehCrew = crew _patrolVeh;
    private _patrolVehicleGroup = _patrolVehicleData select 2;
    {[_x] call A3A_fnc_NATOinit} forEach _patrolVehCrew;
    [_patrolVeh, _sideX] call A3A_fnc_AIVEHinit;
    // ... logic to track and patrol ...
};
Called Functions:
A3A_fnc_NATOinit: Initializes an AI unit (gear, skills, name).
A3A_fnc_AIVEHinit: Initializes an AI vehicle (locking, specific settings).
bis_fnc_taskPatrol: BIS function to make a group patrol an area.
7. Dynamic Patrol Assignment It retrieves the persistent garrison data for the marker, reorganizes it, and determines if patrols should be active. Patrols are disabled if the garrison is understrength or if the patrol area overlaps with an enemy site.

Sqf

Apply
private _garrison = garrison getVariable [_markerX,[]];
_garrison = _garrison call A3A_fnc_garrisonReorg;
private _radiusX = count _garrison;
// ... logic to check patrol validity ...
if (_patrol) then {
    [_markerX, _positionX, _sideX, _faction] call SCRT_fnc_location_createPatrols;
};
Called Functions:
A3A_fnc_garrisonReorg: Sorts garrison units.
SCRT_fnc_location_createPatrols: Spawns foot patrols in the area.
8. Frontier Mortar Placement If the outpost is on the frontier, it spawns a static mortar unit crewed by AI.

Sqf

Apply
if (_frontierX and {_markerX in outposts}) then {
    _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
    _typeVehX = selectRandom (_faction get "staticMortars");
    _spawnParameter = [_markerX, "Mortar"] call A3A_fnc_findSpawnPosition;
    if (_spawnParameter isEqualType []) then {
        // ... create mortar, create crew, move crew in ...
    };
};
Called Functions:
SCRT_fnc_unit_getTiered: Returns unit class based on tier (advanced/rival).
A3A_fnc_findSpawnPosition: Finds a valid position for a specific object type (e.g., "Mortar", "Vehicle").
A3A_fnc_createUnit: Spawns a soldier unit.
9. Military Buildings (Fortifications) Calls A3A_fnc_milBuildings to spawn specific structures (like sandbag bunkers) at the location.

Sqf

Apply
private _ret = [_markerX,_size,_sideX,_frontierX] call A3A_fnc_milBuildings;
_groups pushBack (_ret select 0);
_vehiclesX append (_ret select 1);
_soldiers append (_ret select 2);
_spawnsUsed append (_ret select 3);
{ [_x, _sideX] call A3A_fnc_AIVEHinit } forEach _vehiclesX;
Called Functions:
A3A_fnc_milBuildings: Spawns fortifications and static weapons at the marker.
10. Intel and Flag Placement There is a probability based on tier to spawn intel (documents/laptops) at the location. It then creates the faction's flag (indestructible and capturable).

Sqf

Apply
if(random 100 < (40 + tierWar * 3)) then {
    _large = (random 100 < (30 + tierWar * 2));
    [_markerX, _large] spawn A3A_fnc_placeIntel;
};

private _typeVehX = _faction get "flag";
private _flagX = createVehicle [_typeVehX, _positionX, [],0, "NONE"];
_flagX allowDamage false;
[_flagX,"take"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_flagX];
Called Functions:
A3A_fnc_placeIntel: Script to spawn intel items at a location.
A3A_fnc_flagaction: Remote execution to allow players to interact with the flag.
11. Loot Crate Logic It checks a cooldown variable (_markerX + "_lootCD"). If 0, it spawns an ammo box, fills it with loot, and adds a logistics action to lift it. If the location is a seaport, it adds dive gear to the crate.

Sqf

Apply
private _ammoBox = if (garrison getVariable [_markerX + "_lootCD", 0] == 0) then
{
    private _ammoBoxType = _faction get "ammobox";
    private _ammoBox = [_ammoBoxType, _positionX, 15, 5, true] call A3A_fnc_safeVehicleSpawn;
    // ... event handlers and loot filling ...
    _ammoBox;
};
Called Functions:
A3A_fnc_safeVehicleSpawn: Spawns a vehicle ensuring it doesn't clip into objects.
A3A_fnc_fillLootCrate: Populates the crate with random gear.
A3A_Logistics_fnc_addLoadAction: Adds the "Lift" action for logistics.
12. Water Patrols (Seaports) If the marker is a seaport, it finds a water spawn marker and spawns a gunboat patrol.

Sqf

Apply
if (_markerX in seaports) then {
    _typeVehX = selectRandom (_faction get "vehiclesGunBoats");
    private _mrkMar = seaSpawn select {getMarkerPos _x inArea _markerX};
    if(count _mrkMar > 0) then {
        // ... spawn boat, crew, patrol water ...
    };
};
Called Functions:
A3A_fnc_spawnVehicle: Spawns a vehicle and creates a crew group for it.
A3A_fnc_patrolLoop: Custom infinite patrol loop for groups.
13. Frontier Static AT Placement If on the frontier and near roads, it spawns a static anti-tank gun. It calculates the direction relative to the road for natural placement.

Sqf

Apply
if (_frontierX && {count _roads != 0}) then {
    // ... complex road direction calculation ...
    private _dirveh = [_roadcon, _road] call BIS_fnc_DirTo;
    // ... spawn bunker (sandbag) or directly static weapon ...
    private _typeVehX = selectRandom (_faction get "staticAT");
    // ... spawn crew and assign to gun ...
};
Called Functions:
BIS_fnc_DirTo: Calculates direction between two objects.
BIS_fnc_relPos: Calculates position relative to a center (used for offsetting the bunker).
14. Vehicle Pool Selection and Spawning It calls A3A_fnc_findSpawnPosition for a vehicle. The vehicle type is selected dynamically based on faction, if it's an FIA simulation, and availability of civilian vehicles.

Sqf

Apply
_spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
private _veh = nil;
if (_spawnParameter isEqualType []) then {
    // ... logic to select vehicle type (truck, repair, fuel, etc) ...
    _veh = createVehicle [_typeVehX, (_spawnParameter select 0), [], 0, "CAN_COLLIDE"];
    _veh setDir (_spawnParameter select 1);
    [_veh, _sideX] call A3A_fnc_AIVEHinit;
};
15. Antenna Garrisoning If an antenna was identified in step 4, a unit is spawned at the very top of the tower to act as a sniper/guard.

Sqf

Apply
if (!isNull _antenna) then {
    // ... calculate position at top of tower ...
    private _unit = [_groupX, _typeUnit, _positionX, [], _dir, "NONE"] call A3A_fnc_createUnit;
    _unit setPosATL _posF;
    _unit forceSpeed 0;
    // ... init unit ...
};
16. Main Garrison Spawning It iterates through the _garrison array (loaded from the garrison global variable). It creates groups based on the tier. The first group is garrisoned into buildings; subsequent groups patrol the area.

Sqf

Apply
for "_i" from 0 to (count _array - 1) do {
    // ... select group type based on tier and garrison data ...
    private _groupX = if (_i == 0) then {
        [_positionX, _sideX, _array, true, false] call A3A_fnc_spawnGroup;
    } else {
        // ... spawn at safe pos ...
    };

    if (_i == 0) then {
        private _garrisonGroup = [_groupX, getMarkerPos _markerX, _size] call A3A_fnc_patrolGroupGarrison;
        // ... building garrisoning logic ...
    } else {
        [_groupX, "Patrol_Defend", 0, 100, -1, true, _positionX, false] call A3A_fnc_patrolLoop;
    };
};
Called Functions:
A3A_fnc_patrolGroupGarrison: Logic to place units inside building positions.
17. Event Trigger and Cleanup Setup It triggers an event indicating the location has spawned and waits for the spawner variable to change to 2 (Despawn/Hide).

Sqf

Apply
["locationSpawned", [_markerX, "Outpost", true]] call EFUNC(Events,triggerEvent);
waitUntil {sleep 1; (spawner getVariable _markerX == 2)};
18. Despawn Logic Upon the waitUntil condition being met, it deletes local markers, soldiers, groups, and dogs. Vehicles are handled differently: if captured (ownerSide changed to teamPlayer), they are kept. If not captured, they are deleted or moved to a despawner queue.

Sqf

Apply
{ if (alive _x) then { deleteVehicle _x } } forEach _soldiers;
// ... group deletion ...

{
    // delete all vehicles that haven't been stolen
    if (_x getVariable ["ownerSide", _sideX] == _sideX) then {
        if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
        else { if !(_x isKindOf "StaticWeapon") then { [_x] spawn A3A_fnc_VEHdespawner } };
    };
} forEach _vehiclesX;
Called Functions:
A3A_fnc_VEHdespawner: Script to slowly delete a vehicle or move it to a garage.
19. Loot Cooldown Update If the ammo box was stolen (moved away from center) or destroyed, a cooldown variable is set on the garrison namespace to prevent instant respawning of loot.

Sqf

Apply
if (!isNil "_ammoBox") then {
    if ((alive _ammoBox) and (_ammoBox distance2d _positionX < 100)) exitWith { deleteVehicle _ammoBox };
    if (alive _ammoBox) then { [_ammoBox] spawn A3A_fnc_VEHdespawner };
    private _lootCD = 120*16 / ([_markerX] call A3A_fnc_garrisonSize);
    garrison setVariable [_markerX + "_lootCD", _lootCD, true];
};
["locationSpawned", [_markerX, "Outpost", false]] call EFUNC(Events,triggerEvent);
Where it leads:

Calls:
A3A_fnc_sizeMarker: Gets radius of marker.
A3A_fnc_isFrontline: Determines defense needs.
A3A_fnc_NATOinit: Initializes AI skills/loadout.
A3A_fnc_AIVEHinit: Initializes vehicles.
A3A_fnc_patrolLoop: Handles movement logic.
SCRT_fnc_location_createPatrols: Spawns additional infantry patrols.
A3A_fnc_milBuildings: Spawns fortifications.
A3A_fnc_findSpawnPosition: Finds valid spots for objects.
A3A_fnc_createUnit: Spawns individual AI.
A3A_fnc_spawnGroup: Spawns groups of AI.
A3A_fnc_patrolGroupGarrison: Moves AI into buildings.
A3A_fnc_spawnVehicle: Spawns vehicles with crew.
A3A_fnc_VEHdespawner: Handles vehicle cleanup.
A3A_fnc_garrisonReorg: Organizes defensive units.
Global Variables Modified:
garrison: Updates loot cooldown variable (_markerX + "_lootCD").
spawner: Read continuously; controls lifecycle.
sidesX: Read to get side info.
Dependencies: Relies heavily on the garrison array (persistent data) and Faction arrays (configuration). Called by server-side location controllers.
Function Name: fn_createAIResources.sqf

What it does: This function spawns an AI-controlled resource location (typically a factory or power plant). It shares similarities with fn_createAIOutposts but lacks the militaristic fortifications (like static mortars or sandbags) and instead focuses on garrisoning, vehicle placement, and civilian interaction. It creates an enemy presence that players must attack to capture resources.

How it does that:

1. Initialization and Validation Checks server status, validates the input marker, and checks if the location is already despawned.

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer and hasInterface) exitWith{};

params ["_markerX"];
if(spawner getVariable _markerX == 2) exitWith {};
2. Variable Setup Initializes tracking arrays and retrieves marker data.

Sqf

Apply
private _civs = [];
private _soldiers = [];
private _dogs = [];
private _groups = [];
private _vehiclesX = [];
private _spawnsUsed = [];

private _positionX = getMarkerPos _markerX;
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _frontierX = [_markerX] call A3A_fnc_isFrontline;
private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _faction = Faction(_sideX);
3. Frontier Static AT Placement Unlike the outpost function, this block runs unconditionally for frontier resources. It finds a road and places a static AT gun on the road.

Sqf

Apply
if (_frontierX) then {
    _roads = _positionX nearRoads _size;
    if (count _roads != 0) then {
        // ... math to find road direction and connection ...
        private _typeVehX = selectRandom (_faction get "staticAT");
        private _veh = _typeVehX createVehicle _positionX;
        // ... place on road, spawn crew ...
    };
};
Called Functions: BIS_fnc_DirTo, BIS_fnc_relPos, A3A_fnc_createUnit.
4. Patrol Area Marker Creates a local patrol area marker identical to the outpost function for logic consistency.

Sqf

Apply
private _mrk = createMarkerLocal [format ["%1patrolarea", random 100], _positionX];
// ... marker setup ...
5. Garrison Reinforcements (SCRT) Calls the external system to roll for extra garrison units if conditions are met.

Sqf

Apply
private _additionalGarrison = [_sideX, _markerX] call SCRT_fnc_garrison_rollOversizeGarrison;
if (_additionalGarrison isNotEqualTo []) then {
    // ... spawn extra groups and patrol ...
};
Called Functions: A3A_fnc_spawnGroup, A3A_fnc_patrolLoop.
6. Garrison Patrol Logic Loads the persistent garrison, reorganizes it, and decides whether to spawn patrols. It passes an additional parameter (4) to SCRT_fnc_location_createPatrols, possibly indicating a different difficulty or type compared to outposts.

Sqf

Apply
private _garrison = garrison getVariable [_markerX,[]];
_garrison = _garrison call A3A_fnc_garrisonReorg;
// ... logic to set _patrol flag ...
if (_patrol) then {
    [_markerX, _positionX, _sideX, _faction, 4] call SCRT_fnc_location_createPatrols;
};
7. Flag Placement Creates the faction flag.

Sqf

Apply
private _typeVehX = _faction get "flag";
private _flagX = createVehicle [_typeVehX, _positionX, [],0, "NONE"];
// ... flag interaction and texture ...
8. Civilian Population It checks a faction attribute (attributeLowCiv or attributeCivNonHuman). If the resource is considered "normal," it calls A3A_fnc_createResourceCiv to spawn civilian units roaming the location.

Sqf

Apply
private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];

if (_lowCiv isEqualTo false) then {
    private _spawnedCivilians = [_markerX, 4] call A3A_fnc_createResourceCiv;
    if !(isNil "_spawnedCivilians") then {
        _groups pushBack (_spawnedCivilians # 0);
        _civs append (_spawnedCivilians # 1);
    };
};
Called Functions: A3A_fnc_createResourceCiv (spawns civilians with idle animations/tasks).
9. Vehicle Spawning Spawns a resource-related vehicle (truck, repair, fuel). It filters types to ensure they are cargo trucks if possible.

Sqf

Apply
_spawnParameter = [_markerX, "Vehicle"] call A3A_fnc_findSpawnPosition;
if (_spawnParameter isEqualType []) then {
    // ... select type (repair/fuel/truck) based on randomness ...
    private _types = if (!_isFIA) then {
        (_faction get "vehiclesTrucks") + (_faction get "vehiclesCargoTrucks")
    } else {
        _faction get "vehiclesMilitiaTrucks"
    };
    _types = _types select { _x in FactionGet(all,"vehiclesCargoTrucks") };
    // ... spawn vehicle ...
};
Called Functions: A3A_fnc_findSpawnPosition, A3A_fnc_AIVEHinit.
10. Garrison Population (Main Body) Iterates through the persistent garrison array. Spawns groups and places them. The first group is garrisoned into buildings; others patrol.

Sqf

Apply
for "_i" from 0 to (count _array - 1) do {
    _groupX = if (_i == 0) then {
        [_positionX,_sideX, (_array select _i),true, false] call A3A_fnc_spawnGroup;
    } else {
        private _spawnPosition = [_positionX, 10, 50, 5, 0, -1, 0] call A3A_fnc_getSafePos;
        [_spawnPosition, _sideX, (_array select _i), false, true] call A3A_fnc_spawnGroup
    };
    // ... logic to garrison first group or patrol others ...
};
Called Functions: A3A_fnc_getSafePos, A3A_fnc_spawnGroup, A3A_fnc_patrolGroupGarrison, A3A_fnc_patrolLoop.
11. Event Trigger and Wait Triggers spawn event and waits for the despawn signal.

Sqf

Apply
["locationSpawned", [_markerX, "Resource", true]] call EFUNC(Events,triggerEvent);
waitUntil {sleep 1; (spawner getVariable _markerX == 2)};
12. Despawn and Cleanup Deletes entities. Handles vehicle capture logic similarly to the outpost function but specifically targets "Resource" type.

Sqf

Apply
{ if (alive _x) then { deleteVehicle _x } } forEach _soldiers;
{ deleteVehicle _x } forEach _civs;
// ... vehicle cleanup logic ...
Called Functions: A3A_fnc_VEHdespawner.
Where it leads:

Calls:
A3A_fnc_sizeMarker
A3A_fnc_isFrontline
A3A_fnc_getSafePos
SCRT_fnc_location_createPatrols (with param 4)
A3A_fnc_createResourceCiv
A3A_fnc_spawnGroup
A3A_fnc_patrolGroupGarrison
A3A_fnc_patrolLoop
A3A_fnc_VEHdespawner
Global Variables Modified:
garrison (Read only for spawn, but lifecycle affects it).
spawner (Read).
Dependencies: Relies on the same Faction and garrison systems as fn_createAIOutposts. Called by server-side location controllers for Resource markers.

Function: fn_createAttackForceAir.sqf
What it does:
Creates an aerial attack force composed of aircraft and/or helicopters, including support vehicles (e.g., CAS), transports, and cargo units. It handles spawn logic, resource management, and crew/cargo creation for air vehicles. This function is typically called during enemy attack operations, missions, or QRF events where air superiority is required.

How it does that:
Parameter Validation & Initialization:

Sqf

Apply
params ["_side", "_base", "_target", "_resPool", "_vehCount", "_vehAttackCount", ["_tierMod", 0], ["_troopType", "Normal"], ["_isGuaranteedAirdrop", false]];
private _targpos = if (_target isEqualType []) then { _target } else { markerPos _target };
Extracts 9 parameters with defaults for _tierMod, _troopType, and _isGuaranteedAirdrop.
Converts _target to a position array: if it's already an array, use it directly; otherwise, fetch the marker position using markerPos.
Defines _targPos (target position) for the attack.
Transport Ratio Calculation:

Sqf

Apply
private _transportRatio = 1 - _vehAttackCount / _vehCount;
Calculates the proportion of transport vehicles to total vehicles. If _vehAttackCount equals _vehCount, the ratio is 0 (no transports). If _vehAttackCount is 0, ratio is 1 (all transports).
Resource Tracking Arrays:

Sqf

Apply
private _resourcesSpent = 0;
private _vehicles = [];
private _crewGroups = [];
private _cargoGroups = [];
Initializes counters for total resources spent and arrays to store spawned vehicle objects, crew groups, and cargo groups.
Faction Data & Vehicle Pools:

Sqf

Apply
private _faction = Faction(_side);
private _transportPlanes = _faction get "vehiclesPlanesTransport";
private _transportHelis = _faction get "vehiclesHelisTransport";
private _lightHelis = _faction get "vehiclesHelisLight";
private _lhFactor = 0 max (1 - (tierWar+_tierMod) / 10);
Retrieves faction data using the Faction function (a macro defined in script_component.hpp).
Gets arrays of transport planes, transport helicopters, and light helicopters from the faction config.
Calculates a light helicopter factor that scales down usage at higher war tiers: _lhFactor is 0 when (tierWar + _tierMod) / 10 >= 1, otherwise it's a positive scaling factor.
Transport Pool Construction (Weighted):

Sqf

Apply
private _transportPool = [];
if (_transportPlanes isNotEqualTo [] && {(_faction get "vehiclesAirborne") isNotEqualTo []}) then {
    _transportPool append ["VEHAIRDROP", 0.45 / count _transportPlanes];
};
{ _transportPool append [_x, 2 / count _transportHelis] } forEach _transportHelis;
{ _transportPool append [_x, 2 * _lhFactor / count _lightHelis] } forEach _lightHelis;
{ _transportPool append [_x, 0.75 / count _transportPlanes] } forEach _transportPlanes;
Creates a weighted pool for transport vehicle selection:
Adds "VEHAIRDROP" (a special type) with weight 0.45 / count of transport planes, but only if both transport planes and airborne vehicles exist in the faction.
For each transport helicopter, appends the vehicle type with weight 2 / count of transport helicopters.
For each light helicopter, appends with weight 2 * _lhFactor / count of light helicopters (light helicopters phase out at high tiers).
For each transport plane, appends with weight 0.75 / count of transport planes.
The pool is a flat array: [type1, weight1, type2, weight2, ...] suitable for selectRandomWeighted.
Support Pool & Initial Transport Flag:

Sqf

Apply
private _supportPool = [_side, tierWar+_tierMod] call A3A_fnc_getVehiclesAirSupport;
private _numTransports = 0;
private _isTransport = _vehAttackCount < _vehCount;
Calls A3A_fnc_getVehiclesAirSupport to get a weighted list of support vehicles (e.g., CAS, gunships) for the given side and war tier.
Initializes counter for number of transports spawned so far.
Sets initial _isTransport flag: true if the number of attack vehicles requested is less than the total vehicles, meaning the first vehicle should be a transport (since transports usually lead air formations).
Main Spawning Loop:

Sqf

Apply
for "_i" from 1 to _vehCount do {
    private _vehType = selectRandomWeighted ([_supportPool, _transportPool] select _isTransport);
Iterates once per vehicle to spawn (from 1 to _vehCount).
Selects a vehicle type using selectRandomWeighted on either the support pool or transport pool based on _isTransport.
Uses the ternary ([_supportPool, _transportPool] select _isTransport) to choose the appropriate pool.
Vehicle Type Switch Logic: The switch statement handles three cases:

Case 1: Airdrop or Guaranteed Airdrop:

Sqf

Apply
case (_isGuaranteedAirdrop || {_vehType == "VEHAIRDROP"}): {
    private _transportPlaneType = selectRandom _transportPlanes;
    private _vehData = [_transportPlaneType, _troopType, _resPool, [], _side, _base, _targPos, true] call A3A_fnc_createAttackVehicle;
    if !(_vehData isEqualType []) exitWith {};

    _vehicles pushBack (_vehData#0);
    _crewGroups pushBack (_vehData#1);
    if !(isNull (_vehData#2)) then { _cargoGroups pushBack (_vehData#2) };
    _landPosBlacklist = (_vehData#3);

    private _vehCost = A3A_vehicleResourceCosts getOrDefault [_transportPlaneType, 0];
    private _crewCost = 10 * (count units (_vehData#1) + count units (_vehData#2));
    _resourcesSpent = _resourcesSpent + _vehCost + _crewCost;
    sleep 5;
};
Selects a random transport plane type from the faction's vehiclesPlanesTransport.
Calls A3A_fnc_createAttackVehicle to spawn the vehicle with airdrop enabled (true). The function returns an array: [vehicle, crewGroup, cargoGroup, landPosBlacklist].
If the call fails (returns a non-array), skip this iteration.
Otherwise, add the spawned vehicle, crew group, and cargo group (if not null) to their respective arrays.
Updates _landPosBlacklist from the returned data.
Calculates costs: vehicle cost from A3A_vehicleResourceCosts hashmap, crew cost as 10 * (crew count + cargo count).
Adds to _resourcesSpent.
Sleeps 5 seconds to stagger spawns.
Case 2: CAS or CASDIVE:

Sqf

Apply
case (_vehType == "CASDIVE");
case (_vehType == "CAS"): {
    [_vehType, _side, _resPool, 500, false, _targPos, 0, 60] remoteExec ["A3A_fnc_createSupport", 2];
};
Handles air support calls: no vehicle object is created; instead, a support event is spawned remotely on the server (machanism 2).
Calls A3A_fnc_createSupport with parameters: support type, side, resource pool, reveal distance (500m), no immediate reveal, target position, 0 delay, and 60-second support duration.
Note: This branch doesn't affect _vehicles, _crewGroups, or _resourcesSpent directly; resources are handled separately via support system.
Case 3: Default (Other Transport/Attack Vehicles):

Sqf

Apply
default {
    private _vehData = [_vehType, _troopType, _resPool, [], _side, _base, _targPos] call A3A_fnc_createAttackVehicle;
    if !(_vehData isEqualType []) exitWith {};

    _vehicles pushBack (_vehData#0);
    _crewGroups pushBack (_vehData#1);
    if !(isNull (_vehData#2)) then { _cargoGroups pushBack (_vehData#2) };
    _landPosBlacklist = (_vehData#3);

    private _vehCost = A3A_vehicleResourceCosts getOrDefault [_vehType, 0];
    private _crewCost = 10 * (count units (_vehData#1) + count units (_vehData#2));
    _resourcesSpent = _resourcesSpent + _vehCost + _crewCost;
    sleep 5;
};
Handles all other vehicles (e.g., attack helicopters, transports) via the standard attack vehicle creation function.
Calls A3A_fnc_createAttackVehicle without airdrop flag (defaults to false).
Similar processing as Case 1: add vehicles/crew/cargo, update blacklist, calculate costs, sleep 5 seconds.
Post-Loop Logic (Transport Flag & Loop Update):

Sqf

Apply
    if (_isTransport) then { _numTransports = _numTransports + 1 };
    _isTransport = _vehAttackCount == 0 or (_numTransports / _i) < _transportRatio;
};
If the current vehicle was a transport, increment _numTransports.
Recalculate _isTransport for the next iteration: true if no attack vehicles are requested (_vehAttackCount == 0), or if the current transport ratio (_numTransports / i) is less than the target transport ratio. This ensures a balanced mix of transports and attack vehicles.
Return:

Sqf

Apply
[_resourcesSpent, _vehicles, _crewGroups, _cargoGroups];
Returns an array with total resources spent, and arrays of spawned vehicles, crew groups, and cargo groups.
Where it leads:
Functions Called:

Faction(_side) - Returns faction configuration data (macro wrapper).
A3A_fnc_getVehiclesAirSupport(_side, tierWar+_tierMod) - Returns a weighted list of air support vehicle types for the given side and war tier.
A3A_fnc_createAttackVehicle(_vehicleType, _troopType, _resPool, _landPosBlacklist, _side, _markerOrigin, _posDestination, _isAirdrop) - Core function that spawns a vehicle, creates crew and cargo groups, and returns their data.
remoteExec ["A3A_fnc_createSupport", 2] - Remotely executes a support creation function on the server (mechanism 2) for CAS events.
Functions That Call This:

A3A_fnc_createAttackForceMixed - Used to spawn the aerial component of a mixed air/land attack force.
Possibly other mission or QRF functions (not shown in attached files, but based on typical usage patterns).
Global Variables Modified:

None directly; but A3A_fnc_createAttackVehicle may modify global variables related to spawn positions or resource pools.
Synchronization/Network Implications:

Spawning happens locally (on HC or server) with sleep commands, so it's scheduled and doesn't block the main thread.
remoteExec for CAS support ensures server-side execution of support effects.
The function is meant for server or HC (headless client) use; running on client may cause issues.
No direct synchronization of vehicle arrays; these are returned to the caller for further handling (e.g., cleanup, tracking).
Edge Cases & Error Handling:

If selectRandomWeighted returns nil (e.g., empty pool), the switch defaults to a null vehicle type; however, the code doesn't handle this explicitly except via exitWith in cases.
If A3A_fnc_createAttackVehicle fails (returns non-array), the iteration skips silently.
Light helicopters phase out entirely at high tiers (via _lhFactor).
"VEHAIRDROP" is a special token used only when airborne vehicles exist; otherwise, standard air transports are used.
Integration with Larger System:

Part of the AI enemy attack logic, balancing transport and attack roles based on war tier and attack composition.
Uses resource pools (e.g., "attack", "defence") to track and deduct resources for spawning.
Supports airdrops and orbital drops (via similar functions) for variety in attack types.
Works with the crew and cargo creation system (A3A_fnc_createVehicleCrew, A3A_fnc_NATOinit) to populate vehicles with AI units.
Function: fn_createAttackForceLand.sqf
What it does:
Creates a ground-based attack force composed of vehicles, including transports and attack/support vehicles. It handles spawn logic for land vehicles, crew and cargo creation, resource tracking, and manages spawn position blacklisting to avoid crowding. This is used for ground assaults, QRF land components, or mission-based attacks.

How it does that:
Parameter Validation & Initialization:

Sqf

Apply
params ["_side", "_base", "_target", "_resPool", "_vehCount", "_vehAttackCount", ["_tierMod", 0], ["_troopType", "Normal"], ["_tanksOnly", false]];
private _targpos = if (_target isEqualType []) then { _target } else { markerPos _target };
Extracts 9 parameters with defaults for _tierMod, _troopType, and _tanksOnly.
Converts _target to a position array if it's a marker name.
Transport Ratio & Tier Mod Adjustment:

Sqf

Apply
private _transportRatio = 1 - _vehAttackCount / _vehCount;
if (_tierMod isEqualTo 0) then {_tierMod = 1};
Calculates transport ratio similarly to air version.
Sets _tierMod to 1 if it's 0, a bandaid to avoid issues with pool selection functions (as noted in comments).
Resource Tracking Arrays:

Sqf

Apply
private _resourcesSpent = 0;
private _vehicles = [];
private _crewGroups = [];
private _cargoGroups = [];
Initializes arrays for tracking spawned entities and costs.
Vehicle Pool Selection:

Sqf

Apply
private _transportPool = [];
private _supportPool = [];

if (_tanksOnly) then {
    _transportPool = [_side, 6] call A3A_fnc_getVehiclesGroundTransport; 
    _supportPool = [_side, 6, true] call A3A_fnc_getVehiclesGroundSupport;    
} else {
    _transportPool = [_side, tierWar+_tierMod] call A3A_fnc_getVehiclesGroundTransport; 
    _supportPool = [_side, tierWar+_tierMod, true] call A3A_fnc_getVehiclesGroundSupport;
};
Two scenarios:
If _tanksOnly is true, sets a fixed tier (6) for transport and support pools, with an extra parameter for support (indicating tanks or heavy vehicles).
Otherwise, uses the dynamic war tier (tierWar + _tierMod) for pool selection.
Calls A3A_fnc_getVehiclesGroundTransport and A3A_fnc_getVehiclesGroundSupport to get weighted vehicle pools for ground attacks.
Loop Variables:

Sqf

Apply
private _numTransports = 0;
private _isTransport = _vehAttackCount < _vehCount;
private _landPosBlacklist = [];
Initializes counters and a blacklist for spawn positions to avoid overlaps.
Main Spawning Loop:

Sqf

Apply
for "_i" from 1 to _vehCount do {
    private _vehType = ObjNull;

    _vehType = selectRandomWeighted ([_supportPool, _transportPool] select _isTransport);
    if (isNil "_vehType") then {
        Error_1("Failed to grab land vehicle, attempting to grab a transport vehicle.", _base);
        _vehType = selectRandomWeighted _transportPool;
    };
Iterates for each vehicle to spawn.
Selects a vehicle type from the appropriate pool (support or transport) based on _isTransport.
If selection fails (nil, e.g., empty pool), logs an error and falls back to the transport pool.
Error_1 is a logging macro.
Spawning & Processing:

Sqf

Apply
    private _vehData = [_vehType, _troopType, _resPool, _landPosBlacklist, _side, _base, _targPos] call A3A_fnc_createAttackVehicle;
    if !(_vehData isEqualType []) exitWith {
        Error_1("Failed to spawn land vehicle at marker %1", _base);
    };

    _vehicles pushBack (_vehData#0);
    if (!isNull (_vehData#1)) then { _crewGroups pushBack (_vehData#1) };
    if (!isNull (_vehData#2)) then { _cargoGroups pushBack (_vehData#2) };
    _landPosBlacklist = (_vehData#3);

    private _vehCost = A3A_vehicleResourceCosts getOrDefault [_vehType, 0];
    private _crewCost = 10 * (count units (_vehData#1) + count units (_vehData#2));
    _resourcesSpent = _resourcesSpent + _vehCost + _crewCost;
Calls A3A_fnc_createAttackVehicle to spawn the land vehicle with crew and cargo.
If spawning fails (returns non-array), logs error and exits the loop (preventing further spawns from this base).
Otherwise, adds vehicle, crew, and cargo (if not null) to arrays.
Updates blacklist from returned data.
Calculates costs similar to air version (vehicle cost + crew cost).
Adds to total resources spent.
Loop Update & Sleep:

Sqf

Apply
    if (_isTransport) then { _numTransports = _numTransports + 1 };
    _isTransport = _vehAttackCount == 0 or (_numTransports / _i) < _transportRatio;

    sleep 10;
};
Updates transport counter and flag for next iteration (same logic as air version).
Sleeps 10 seconds between spawns for ground vehicles.
Post-Spawn Cleanup (Delayed):

Sqf

Apply
_vehicles spawn {
    sleep 60;
    private _vehicles = _this select { !isNull _x };
    private _spawnPlaces = _vehicles apply { _x getVariable "spawnPlace" };
    _spawnPlaces call A3A_fnc_freeSpawnPositions;
    { _x setVariable ["spawnPlace", nil] } forEach _vehicles;
};
Spawns a separate coroutine that waits 60 seconds, then:
Filters out null vehicles.
Retrieves spawnPlace variable from each vehicle.
Calls A3A_fnc_freeSpawnPositions to mark spawn positions as free (e.g., in a base).
Clears the spawnPlace variable from vehicles.
Return:

Sqf

Apply
[_resourcesSpent, _vehicles, _crewGroups, _cargoGroups];
Returns the same structure as the air version.
Where it leads:
Functions Called:

Faction(_side) - Implicitly via macro in called functions (not directly called here).
A3A_fnc_getVehiclesGroundTransport(_side, tier) - Returns weighted ground transport vehicle types.
A3A_fnc_getVehiclesGroundSupport(_side, tier, true) - Returns weighted ground support (attack) vehicle types.
A3A_fnc_createAttackVehicle(_vehicleType, _troopType, _resPool, _landPosBlacklist, _side, _markerOrigin, _posDestination) - Spawns land vehicle, crew, and cargo.
A3A_fnc_freeSpawnPositions(_spawnPlaces) - Frees up spawn positions at bases.
Error_1 - Logging macro for errors.
Functions That Call This:

A3A_fnc_createAttackForceMixed - Spawns the ground component of a mixed attack force.
Possibly other land-based QRF or attack functions.
Global Variables Modified:

Vehicle spawnPlace variables are cleared after cleanup.
Spawn positions are freed globally via A3A_fnc_freeSpawnPositions.
Synchronization/Network Implications:

Spawning is scheduled with sleeps, running locally on HC/server.
The cleanup coroutine runs asynchronously after 60 seconds, freeing resources without blocking.
No direct network calls; all operations are local.
Edge Cases & Error Handling:

Handles empty _vehType by falling back to transport pool and logging error.
Exits loop if vehicle spawn fails (e.g., due to insufficient space).
_tanksOnly mode uses a fixed tier (6) to ensure tank availability.
Blacklist ensures no overlapping spawns; returned by createAttackVehicle for sequential positioning.
Integration with Larger System:

Part of ground attack AI, using the same resource pools as air attacks.
Works with base management: spawn positions are tracked and freed.
Crew and cargo are initialized with NATO init functions for proper AI behavior.
Supports troop types ("Normal", "SpecOps") for varied infantry composition.
Function: fn_createAttackForceMixed.sqf
What it does:
Creates a combined air and land attack force, coordinating arrival times and balancing composition based on modifiers and war tier. It delegates to specialized functions for ground and air components, handles resource adjustment, and optionally shows intercepted attack warnings. This is a high-level orchestrator for mixed attacks (e.g., HQ assaults, combined arms invasions).

How it does that:
Parameter Validation & Initialization:

Sqf

Apply
params ["_side", "_airbase", "_target", "_resPool", "_vehCount", "_delay", "_modifiers", "_attackType", "_reveal"];
private _targPos = if (_target isEqualType []) then { _target } else { markerPos _target };
Extracts 9 parameters: side, air base marker, target (position or marker), resource pool, total vehicle count, minimum arrival delay, modifiers array, attack type (string), and reveal value.
Converts _target to position array.
Modifier Parsing & Tier Calculation:

Sqf

Apply
// _modifiers ["tierboost", "specops", "airboost", "noairsupport"]
private _lowAir = Faction(_side) getOrDefault ["attributeLowAir", false];
private _tier = [tierWar, tierWar+2] select ("tierboost" in _modifiers);
Checks for tierboost in modifiers to set war tier: if present, use tierWar + 2; otherwise, just tierWar.
Retrieves attributeLowAir from faction to adjust air availability.
Resource Tracking & Composition Calculation:

Sqf

Apply
private _resourcesSpent = 0;
private _vehicles = [];
private _crewGroups = [];
private _cargoGroups = [];

private _landRatio = if ("airboost" in _modifiers) then {
    if (_lowAir) exitWith { 0.5 + random 0.5 };
    random 0.4;
} else {
    if ("noairsupport" in _modifiers) then {
        if (_lowAir) exitWith { 0.8 + random 0.2 };
        0.5 + random 0.4;
    } else {
        if (_lowAir) exitWith { 0.7 + random 0.3 };
        0.4 + random 0.4;
    };
};
Calculates land vehicle ratio based on modifiers:
airboost: Punishment/HQ attack; higher land ratio (0.5-1.0 if low air, 0-0.4 otherwise).
noairsupport: Waved attack; moderate land ratio (0.8-1.0 if low air, 0.5-0.9 otherwise).
Default (counter-attack): Lower land ratio (0.7-1.0 if low air, 0.4-0.8 otherwise).
Uses randomization for variability.
Ground Force Spawn:

Sqf

Apply
private _landCount = round (_landRatio * _vehCount);

if (_landCount > 0) then
{
    private _landBase = [_side, _targPos] call A3A_fnc_availableBasesLand;
    if (_delay >= 0 and !isNil "_landBase") then {
        private _navIndex = _landBase call A3A_fnc_getMarkerNavPoint;
        private _landTime = ([_targPos, _navIndex] call A3A_fnc_findNavDistance) / 15;
        ServerDebug_2("Minimum delay %1 and land travel time %2", _delay, _landTime);
        if (_landTime < _delay) then { sleep (_delay - _landTime) };
        _delay = _landTime;
    };
Calculates number of land vehicles based on ratio.
Finds nearest available land base using A3A_fnc_availableBasesLand.
If delay is specified, calculates travel time from base to target using pathfinding (A3A_fnc_getMarkerNavPoint and A3A_fnc_findNavDistance); sleeps if needed to meet delay, updating _delay to travel time.
Loop to Spawn Land Vehicles (With Base Reuse):

Sqf

Apply
    while { !isNil "_landBase" } do
    {
        [_landBase, 1] call A3A_fnc_addTimeForIdle;
        private _attackCount = round (_landCount * (0.25 + random 0.2));
        private _troops = ["Normal", "SpecOps"] select ("specops" in _modifiers and random 1 > 0.5);
        ServerDebug_3("Attempting to spawn %1 land vehicles including %2 attack from %3", _landCount, _attackCount, _landBase);

        private _data = [_side, _landBase, _targPos, _resPool, _landCount, _attackCount, _tier, _troops] call A3A_fnc_createAttackForceLand;
        if (_data#1 isEqualTo []) exitWith { Error_1("Land base %1 passed checks but failed vehicle spawning", _landBase) };
        _resourcesSpent = _resourcesSpent + _data#0;
        _vehicles append _data#1;
        _crewGroups append _data#2;
        _cargoGroups append _data#3;

        [-(_data#0), _side, _resPool] remoteExec ["A3A_fnc_addEnemyResources", 2];

        ServerInfo_2("Spawn performed: Ground vehicles %1 from %2", _data#1 apply {typeOf _x}, _landBase);

        _landCount = _landCount - count (_data#1);
        if (_landCount <= 0) exitWith {};    
        _landBase = [_side, _targPos] call A3A_fnc_availableBasesLand;
    };
While a land base is available:
Marks base as active with A3A_fnc_addTimeForIdle.
Determines attack vehicle count (25-45% of land count).
Chooses troops: "Normal" or "SpecOps" (50% chance if specops modifier).
Calls A3A_fnc_createAttackForceLand to spawn vehicles.
If no vehicles spawned, log error and exit loop.
Otherwise, accumulate resources, vehicles, crew, cargo.
Remotely adjusts enemy resources (negative amount) via A3A_fnc_addEnemyResources on server.
Logs spawn details.
Reduces _landCount by spawned vehicles; if none left, exit loop.
Find new land base for remaining vehicles.
Show Intercepted Setup:

Sqf

Apply
if (!isNil "_attackType") then {
    [_reveal, _side, _attackType, _targPos, _delay] remoteExec ["A3A_fnc_showInterceptedSetupCall", 2];
};
If attack type is provided, remotely calls A3A_fnc_showInterceptedSetupCall on server to display an intercepted attack warning to players (e.g., "Enemy attack imminent").
Delay Synchronization for Air Force:

Sqf

Apply
if (_delay > 0) then {
    private _airTime = (markerPos _airbase distance2d _targPos) / 70;
    ServerDebug_2("Remaining delay %1 and air travel time %2", _delay, _airTime);
    sleep (0 max (_delay - _airTime));
};
If there's a remaining delay, calculates air travel time (distance / 70, assuming speed ~70 m/s).
Sleeps the difference to synchronize air arrival with ground (if air is slower, it sleeps less; if faster, it may not sleep).
Air Force Spawn:

Sqf

Apply
if (_airBase != "") then            // uh, is that a thing
{
    private _airCount = _vehCount - count (_vehicles);
    if (_airCount <= 0) exitWith {};

    private _attackCount = if ("noairsupport" in _modifiers) then { 0 } else {
        private _AHratio = 0.02 * (6 + tierWar) + random 0.1;
        _AHratio = _AHratio + 0.2 * count (_vehicles) / _vehCount;
        round (random 0.3 + _airCount * _AHratio);
    };
    private _troops = ["Normal", "SpecOps"] select ("specops" in _modifiers);
    ServerDebug_3("Attempting to spawn %1 air vehicles including %2 attack from %3", _airCount, _attackCount, _airbase);
    private _roll = round (random 100);
    if (allowFuturisticUnfairSupports && _roll <= 25 && {(Faction(_side) get "vehiclesDropPod") isNotEqualTo []}) then {
        private _data = [_side, _airBase, _targPos, _resPool, _airCount, _attackCount, _tier, _troops] call A3A_fnc_createAttackForceOrbital;
        // ... accumulate and log ...
    } else {
        private _data = [_side, _airBase, _targPos, _resPool, _airCount, _attackCount, _tier, _troops] call A3A_fnc_createAttackForceAir;
        // ... accumulate and log ...
    };
};
Calculates air count as remaining vehicles.
If no air vehicles, exit.
Attack count calculation:
If no air support modifier, 0.
Otherwise, base ratio from war tier (0.02 * (6 + tierWar) + random 0.1) plus extra based on ground vehicles present (20% of ground/total ratio).
Randomized within 0.3 + ratio * air count.
Troops: "Normal" or "SpecOps" if specops modifier.
Roll for orbital attack (25% chance if allowed and orbital vehicles exist).
Calls A3A_fnc_createAttackForceOrbital or A3A_fnc_createAttackForceAir.
Accumulates resources, vehicles, crew, cargo.
Remotely adjusts enemy resources.
Logs spawn.
Return:

Sqf

Apply
[_resourcesSpent, _vehicles, _crewGroups, _cargoGroups];
Returns combined data.
Where it leads:
Functions Called:

Faction(_side) - Retrieves faction attributes (e.g., attributeLowAir).
A3A_fnc_availableBasesLand(_side, _targPos) - Finds nearest available land base.
A3A_fnc_getMarkerNavPoint(_base) - Returns navigation point for pathfinding.
A3A_fnc_findNavDistance(_targPos, _navIndex) - Calculates travel distance.
A3A_fnc_addTimeForIdle(_base, 1) - Marks base as active.
A3A_fnc_createAttackForceLand(_side, _base, _target, _resPool, _vehCount, _vehAttackCount, _tier, _troops) - Spawns ground force.
A3A_fnc_addEnemyResources(-cost, _side, _resPool) - Adjusts resources remotely.
A3A_fnc_showInterceptedSetupCall(_reveal, _side, _attackType, _targPos, _delay) - Shows warning.
A3A_fnc_createAttackForceOrbital or A3A_fnc_createAttackForceAir - Spawns air force.
Functions That Call This:

Mission systems (e.g., A3A_fnc_attackHQ, A3A_fnc_wavedAttack) or QRF functions (not shown but implied by usage).
Global Variables Modified:

allowFuturisticUnfairSupports (global setting) affects orbital roll.
Enemy resources via remote call.
Synchronization/Network Implications:

All vehicle spawning is local (scheduled), but resource updates and interception warnings are remote calls to the server.
Travel time calculation ensures synchronized arrival; sleeps may block this function locally.
The function runs on server or HC; remote calls ensure central resource management.
Edge Cases & Error Handling:

Handles no land base (loop doesn't run if isNil "_landBase").
If land spawn fails (no vehicles), logs error and continues to air.
Air force may be empty if no airbase.
Modifiers determine composition; defaults handle missing modifiers.
Integration with Larger System:

Central orchestrator for mixed attacks, balancing air/ground based on faction traits (lowAir) and mission parameters.
Integrates with resource management (adding/subtracting enemy resources).
Works with pathfinding for realistic travel times.
Supports diverse modifiers for different attack scenarios (punishment, waves, counter-attacks).
Function: fn_createAttackForceOrbital.sqf
What it does:
Creates an orbital/drop pod attack force, similar to the air force but using drop pods and orbital elements. It's a variant of the air force function for futuristic or special factions, handling vehicle selection, airdrops, and support calls with orbital themes.

How it does that:
Parameter Validation & Initialization:

Sqf

Apply
params ["_side", "_base", "_target", "_resPool", "_vehCount", "_vehAttackCount", ["_tierMod", 0], ["_troopType", "Specops"], ["_isGuaranteedAirdrop", false]];
private _targpos = if (_target isEqualType []) then { _target } else { markerPos _target };
Similar to fn_createAttackForceAir, with _troopType defaulting to "Specops".
Resource Tracking:

Sqf

Apply
private _resourcesSpent = 0;
private _vehicles = [];
private _crewGroups = [];
private _cargoGroups = [];
Standard initialization.
Faction Data & Transport Pool:

Sqf

Apply
private _faction = Faction(_side);
private _transportPlanes = _faction get "vehiclesDropPod";
private _lhFactor = 0 max (1 - (tierWar+_tierMod) / 10);
private _transportPool = [];

if (_transportPlanes isNotEqualTo [] && {(_faction get "vehiclesAirborne") isNotEqualTo []}) then {
    _transportPool append ["VEHAIRDROP", 0.45 / count _transportPlanes];
};
Retrieves vehiclesDropPod instead of transport planes.
Light helicopter factor (though not used directly, kept for consistency).
Adds "VEHAIRDROP" to transport pool if drop pods and airborne vehicles exist.
Support Pool & Transport Logic:

Sqf

Apply
private _supportPool = [_side, tierWar+_tierMod] call A3A_fnc_getVehiclesAirSupport;

private _numTransports = 0;
private _isTransport = _vehAttackCount < _vehCount;

for "_i" from 1 to _vehCount do {
    private _vehType = selectRandomWeighted ([_supportPool, _transportPool] select _isTransport);

    if (isNil "_vehType") then {continue};
Gets air support pool (same as air function).
Loop similar to air, but skips iteration if _vehType is nil (using continue).
Vehicle Type Switch:

Sqf

Apply
switch (true) do {   
    case (_isGuaranteedAirdrop || {_vehType == "VEHAIRDROP"}): {
        private _transportPlaneType = selectRandom _transportPlanes;
        private _vehData = [_transportPlaneType, _troopType, _resPool, [], _side, _base, _targPos, true] call A3A_fnc_createAttackVehicleOrbital;
        // ... identical to air version, but calls orbital function ...
    };
    case (_vehType == "CASDIVE");
    case (_vehType == "CAS"): {
        [_vehType, _side, _resPool, 500, false, _targPos, 0, 60] remoteExec ["A3A_fnc_createSupport", 2];
    };
    default {
        private _vehData = [_vehType, _troopType, _resPool, [], _side, _base, _targPos] call A3A_fnc_createAttackVehicleOrbital;
        // ... similar to air default ...
    };
};
Switch logic mirrors fn_createAttackForceAir:
Airdrop case: selects from vehiclesDropPod, calls A3A_fnc_createAttackVehicleOrbital.
CAS cases: same remote support call.
Default: calls orbital vehicle creation function.
Uses _vehData for vehicles, crews, costs, and sleeps.
Loop Update:

Sqf

Apply
    if (_isTransport) then { _numTransports = _numTransports + 1 };
    _isTransport = ((_vehAttackCount == 0) || (_numTransports / _i) < _transportRatio)
};
Updates transport flag with same ratio logic (parentheses adjusted for clarity).
Return:

Sqf

Apply
[_resourcesSpent, _vehicles, _crewGroups, _cargoGroups];
Returns standard array.
Where it leads:
Functions Called:

Faction(_side) - Retrieves faction vehicles.
A3A_fnc_getVehiclesAirSupport(_side, tierWar+_tierMod) - Air support pool.
A3A_fnc_createAttackVehicleOrbital(_vehicleType, _troopType, _resPool, [], _side, _base, _targPos, _isAirdrop) - Spawns orbital vehicle (drop pod or orbital element).
A3A_fnc_createSupport - For CAS calls.
A3A_fnc_createAttackForceAir is similar but for orbital variants.
Functions That Call This:

A3A_fnc_createAttackForceMixed (when orbital roll succeeds).
Possibly special missions with drop pod attacks.
Global Variables Modified:

Same as air function; vehicle resource costs.
Synchronization/Network Implications:

Local scheduling with sleeps; remote support calls for CAS.
Designed for server/HC; may require faction with vehiclesDropPod.
Edge Cases & Error Handling:

Skips if no vehicle type (nil).
Drop pods only if faction has vehiclesDropPod and airborne vehicles.
continue in loop skips iteration gracefully.
Integration with Larger System:

Specialized for futuristic factions (e.g., with orbital assets).
Integrates with orbital landing AI (A3A_fnc_orbitalLanding).
Uses same crew/cargo system but with orbital vehicle templates.
Function: fn_createAttackVehicle.sqf
What it does:
Spawns a vehicle (air/land), creates crew and cargo groups, initializes them, and sets up QRF behavior (e.g., move to target). Returns vehicle, crew, cargo, and updated blacklist. Core function used by attack force creators.

How it does that:
Parameter Validation:

Sqf

Apply
params ["_vehicleType", "_troopType", "_resPool", "_landPosBlacklist", "_side", "_markerOrigin", "_posDestination", ["_isAirdrop", false]];
8 parameters, _isAirdrop optional default false.
Vehicle Spawn:

Sqf

Apply
private _faction = Faction(_side);
private _vehicle = [_markerOrigin, _vehicleType] call A3A_fnc_spawnVehicleAtMarker;

if(isNull _vehicle) exitWith {objNull};
Retrieves faction.
Calls A3A_fnc_spawnVehicleAtMarker to spawn vehicle at base marker; exits if null.
Crew Creation:

Sqf

Apply
private _isAttackHeli = _vehicleType in FactionGet(all, "vehiclesHelisAttack") + FactionGet(all, "vehiclesHelisLightAttack");
private _crewGroup = [_side, _vehicle, nil, _isAttackHeli] call A3A_fnc_createVehicleCrew;
{
    [_x, nil, nil, _resPool] call A3A_fnc_NATOinit
} forEach (units _crewGroup);
[_vehicle, _side, _resPool] call A3A_fnc_AIVEHinit;
Checks if vehicle is an attack helicopter (for filling turrets).
Creates crew group via A3A_fnc_createVehicleCrew (handles turrets for attack helis).
Initializes each crew member with A3A_fnc_NATOinit (sets side, skill, etc.).
Initializes vehicle with A3A_fnc_AIVEHinit (AI behaviors, etc.).
Cargo Creation:

Sqf

Apply
private _cargoGroup = grpNull;
private _expectedCargo = ([_vehicleType, true] call BIS_fnc_crewCount) - ([_vehicleType, false] call BIS_fnc_crewCount);
if (_expectedCargo >= 2) then
{
    //Vehicle is able to transport units
    private _groupType = call {
        if (_isAirdrop) exitWith { selectRandom ([_faction get "groupsTierAirborne"] call SCRT_fnc_unit_getTiered) };
        if (_troopType == "Normal") exitWith { [_vehicleType, _side] call A3A_fnc_cargoSeats };
        if (_troopType == "Specops") exitWith { selectRandom (_faction get "groupSpecOpsRandom") };
        if (_troopType == "Air") exitWith { [_faction get "groupTierAA"] call SCRT_fnc_unit_getTiered };
        if (_troopType == "Tank") exitWith { [_faction get "groupTierAT"] call SCRT_fnc_unit_getTiered };
    };
Calculates expected cargo seats (total seats minus crew seats).
If enough cargo (>=2), determine troop group type based on _troopType and _isAirdrop:
Airdrop: random airborne tiered group.
Normal: cargo seats group from vehicle/side.
Specops: random spec ops group.
Air/AT: specialized AA or AT groups.
Uses SCRT_fnc_unit_getTiered to filter by tier if needed.
Finding Cargo Turrets (Cargo Assignment Logic):

Sqf

Apply
    private _fnc_addCargoTurrets = {
        params ["_config", ["_path", []]];
        {
            private _turretPath = _path + [_forEachIndex];
            [_x, _turretPath] call _fnc_addCargoTurrets;
            if (getNumber (_x >> "showAsCargo") != 0) then { _cargoTurrets pushBack _turretPath };
        } forEach ("true" configClasses (_config >> "Turrets"));
    };
    private _cargoTurrets = [];
    if !(_vehicleType in ["LIB_C47_Skytrain", "LIB_C47_RAF", "LIB_Li2", "A3U_LIB_C47_German", "JK_B_C47_F", "sab_fl_ju52", "SPEX_C47_Skytrain", "SPEX_CW_C47_Dakota"]) then {
        [configFile >> "CfgVehicles" >> _vehicleType] call _fnc_addCargoTurrets;
    };
Defines a recursive function _fnc_addCargoTurrets to find all turret paths where showAsCargo != 0 (cargo seats in turrets).
For most vehicles (excluding specific transport planes), it builds _cargoTurrets array.
These turrets are used for assigning cargo units to turrets instead of regular cargo.
Cargo Spawn & Assignment:

Sqf

Apply
    if (_expectedCargo < count _groupType) then { _groupType resize _expectedCargo };
    _cargoGroup = [getMarkerPos _markerOrigin, _side, _groupType, true, false] call A3A_fnc_spawnGroup;
    {
        if (_cargoTurrets isNotEqualTo []) then {
            private _turretPath = _cargoTurrets deleteAt 0;
            _x assignAsTurret [_vehicle, _turretPath];
            _x moveInTurret [_vehicle, _turretPath];
        } else {
            _x assignAsCargo _vehicle;
            _x moveInCargo _vehicle;
        };
        [_x, nil, nil, _resPool] call A3A_fnc_NATOinit;
    } forEach units _cargoGroup;
    {
        private _index = _cargoIndex _x;
        if (_index == -1) then {
            deleteVehicle _x;
        };
    } forEach units _cargoGroup;
Resizes group type if needed (to match available seats).
Spawns cargo group via A3A_fnc_spawnGroup (force spawn, pre-checked).
Assigns each unit to turret (if available) or regular cargo.
Initializes each with A3A_fnc_NATOinit.
Cleanup: deletes units that couldn't board (index -1).
QRF Behavior Setup:

Sqf

Apply
_landPosBlacklist = [_vehicle, _crewGroup, _cargoGroup, _posDestination, _markerOrigin, _landPosBlacklist, _isAirdrop, _resPool] call A3A_fnc_createVehicleQRFBehaviour;
Calls A3A_fnc_createVehicleQRFBehaviour to set up AI behaviors (e.g., move to target, land for airdrops).
Updates _landPosBlacklist with new positions to avoid.
Logging & Return:

Sqf

Apply
ServerDebug_5("Spawn Performed: Created vehicle %1 with %2 crew (%3) and %4 cargo (%5)", typeof _vehicle, count units _crewGroup, _crewGroup, count units _cargoGroup, _cargoGroup);

[_vehicle, _crewGroup, _cargoGroup, _landPosBlacklist];
Logs details.
Returns array: vehicle, crew group, cargo group, updated blacklist.
Where it leads:
Functions Called:

Faction(_side) - For faction data.
A3A_fnc_spawnVehicleAtMarker(_markerOrigin, _vehicleType) - Spawns vehicle object.
A3A_fnc_createVehicleCrew(_side, _vehicle, nil, _isAttackHeli) - Creates crew group.
A3A_fnc_NATOinit(_unit, nil, nil, _resPool) - Initializes unit (NATO-like AI).
A3A_fnc_AIVEHinit(_vehicle, _side, _resPool) - Initializes vehicle AI.
A3A_fnc_cargoSeats(_vehicleType, _side) - For normal troops group.
SCRT_fnc_unit_getTiered(_groupsArray) - Filters groups by war tier.
A3A_fnc_spawnGroup(_position, _side, _groupType, true, false) - Spawns cargo group.
A3A_fnc_createVehicleQRFBehaviour(_vehicle, _crewGroup, _cargoGroup, _posDestination, _markerOrigin, _landPosBlacklist, _isAirdrop, _resPool) - Sets up behaviors.
Functions That Call This:

A3A_fnc_createAttackForceAir
A3A_fnc_createAttackForceLand
A3A_fnc_createAttackForceOrbital
Global Variables Modified:

Possibly spawn position tracking via spawnPlace in QRF behavior.
Synchronization/Network Implications:

All operations local; spawns and AI setup are server-side or HC.
No network calls; returns data to caller.
Edge Cases & Error Handling:

Exits if vehicle null.
Handles insufficient cargo seats (resizes group, deletes extras).
Excludes specific vehicle types from turret search (historical transports).
Cargo turret assignment fails silently (if no turrets, regular cargo).
Integration with Larger System:

Core of vehicle spawning: used by all attack force functions.
Integrates with infantry spawning (cargo groups).
QRF behavior ensures vehicles engage targets post-landing.
Works with all sides and troop types.
Function: fn_createAttackVehicleOrbital.sqf
What it does:
Variant of fn_createAttackVehicle for orbital drop pods or futuristic vehicles. Simplified cargo handling (always spec ops) and uses orbital-specific initialization. Creates crew, cargo, and sets up orbital landing behavior.

How it does that:
Parameter Validation (Same as Above):

Sqf

Apply
params ["_vehicleType", "_troopType", "_resPool", "_landPosBlacklist", "_side", "_markerOrigin", "_posDestination", ["_isAirdrop", false]];
Identical parameters.
Vehicle Spawn & Crew (Same as Above):

Sqf

Apply
private _faction = Faction(_side);
private _vehicle = [_markerOrigin, _vehicleType] call A3A_fnc_spawnVehicleAtMarker;

if(isNull _vehicle) exitWith {objNull};

private _isAttackHeli = _vehicleType in FactionGet(all, "vehiclesHelisAttack") + FactionGet(all, "vehiclesHelisLightAttack");
private _crewGroup = [_side, _vehicle, nil, _isAttackHeli] call A3A_fnc_createVehicleCrew;
{
    [_x, nil, nil, _resPool] call A3A_fnc_NATOinit
} forEach (units _crewGroup);
[_vehicle, _side, _resPool] call A3A_fnc_AIVEHinit;
Same as standard version: spawn vehicle, create and initialize crew.
Simplified Cargo Creation:

Sqf

Apply
private _cargoGroup = grpNull;
//private _expectedCargo = ([_vehicleType, true] call BIS_fnc_crewCount) - ([_vehicleType, false] call BIS_fnc_crewCount);
/* if (_expectedCargo >= 2 and !_isAttackHeli) then
{ */
    //Vehicle is able to transport units
/*     private _groupType = call {
        if (_troopType == "Normal") exitWith { [_vehicleType, _side] call A3A_fnc_cargoSeats };
        if (_troopType == "Specops") exitWith { selectRandom (_faction get "groupSpecOpsRandom") };
        if (_troopType == "Air") exitWith { [_faction get "groupTierAA"] call SCRT_fnc_unit_getTiered };
        if (_troopType == "Tank") exitWith { [_faction get "groupTierAT"] call SCRT_fnc_unit_getTiered };
    }; */
    ///if (_expectedCargo < count _groupType) then { _groupType resize _expectedCargo };           // trim to cargo seat count
    private _groupType = selectRandom (_faction get "groupSpecOpsRandom");
    _cargoGroup = [getMarkerPos _markerOrigin, _side, _groupType, true, false] call A3A_fnc_spawnGroup;
    /* if (_cargoGroup == grpNull) then {
        _cargoGroup = selectRandom (_faction get "groupSpecOpsRandom");
    }; */
    {
        [_x, nil, nil, _resPool] call A3A_fnc_NATOinit;
    } forEach units _cargoGroup;
Comments out cargo seat calculation and group type selection based on _troopType.
Always sets _groupType to a random spec ops group from faction (groupSpecOpsRandom), ignoring _troopType.
Spawns cargo group; if null, retries spec ops (commented but functional).
Initializes each unit with A3A_fnc_NATOinit.
Note: Doesn't assign to vehicle; assumed orbital vehicles handle cargo differently (e.g., drop pod troops deploy on landing).
QRF Behavior Setup:

Sqf

Apply
_landPosBlacklist = [_vehicle, _crewGroup, _cargoGroup, _posDestination, _markerOrigin, _landPosBlacklist, _isAirdrop, _resPool] call A3A_fnc_createVehicleQRFBehaviour;
ServerDebug_5("Spawn Performed: Created vehicle %1 with %2 crew (%3) and %4 cargo (%5)", typeof _vehicle, count units _crewGroup, _crewGroup, count units _cargoGroup, _cargoGroup);

[_vehicle, _crewGroup, _cargoGroup, _landPosBlacklist];
Calls QRF behavior (likely orbital-specific, e.g., A3A_fnc_orbitalLanding).
Logs and returns same as standard.
Where it leads:
Functions Called:

Faction(_side) - For faction data.
A3A_fnc_spawnVehicleAtMarker - Spawns orbital vehicle.
A3A_fnc_createVehicleCrew - Creates crew.
A3A_fnc_NATOinit - Initializes units.
A3A_fnc_AIVEHinit - Initializes vehicle.
A3A_fnc_spawnGroup - Spawns cargo group (spec ops only).
A3A_fnc_createVehicleQRFBehaviour - Sets up orbital behaviors.
Functions That Call This:

A3A_fnc_createAttackForceOrbital
Global Variables Modified:

Similar to standard; no cargo assignment to vehicle.
Synchronization/Network Implications:

Local spawning; QRF behavior may involve remote events for orbital effects.
Edge Cases & Error Handling:

Cargo group spawn fallback (retries spec ops if null).
Simplified logic assumes orbital vehicles handle troop deployment separately.
Integration with Larger System:

For futuristic/drop pod attacks; cargo troops deploy after landing.
Integrates with orbital-specific AI (e.g., fast rope or parachute landing).

Function Name: fn_createSDKgarrisons.sqf
What it does: This function creates and spawns rebel garrison units at a specified marker position. It handles the complete lifecycle of garrison units: creation, placement into static weapons (mortars, MGs, etc.), assignment to patrol/defend behavior, and cleanup when the marker is despawned. It manages both infantry units and static assets (like mortars) that have been purchased or assigned to the location. The function is called when a rebel-held marker (like an outpost or resource area) becomes active and needs to provide defense.

How it does that:

Initial Setup and Sanity Checks: The function first ensures it only runs on the server and for players with the interface (avoiding issues on headless clients or pure servers). It then gathers necessary environment data: the marker's position and its size (radius) to define the spawn area.

fn_createSDKgarrisons.sqf

Apply
if (!isServer and hasInterface) exitWith{};
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_markerX"];

private ["_vehiclesX","_groups","_soldiers","_positionX","_staticsX","_garrison"];

private _vehiclesX = [];
private _groups = [];
private _soldiers = [];
private _civs = [];
_positionX = getMarkerPos (_markerX);

private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];

if (_markerX != "Synd_HQ" && {!(_markerX in milAdministrationsX)}) then {  ///maaaaaaybe we should save vehicles near ANY friendly marker?
    if (!(_markerX in citiesX)) then {
        private _veh = createVehicle [FactionGet(reb,"flag"), _positionX, [],0, "NONE"];
        _veh setFlagTexture FactionGet(reb,"flagTexture");
        _veh allowDamage false;
        _vehiclesX pushBack _veh;
        [_veh,"SDKFlag"] remoteExec ["A3A_fnc_flagaction",0,_veh];

        if (_markerX in seaports) then {
            [_veh,"seaport"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_veh];
        };
    };

    if ((_markerX in resourcesX) or (_markerX in factories)) then {
        private _spawnedCivilians = [_markerX, 4] call A3A_fnc_createResourceCiv;
        if !(isNil "_spawnedCivilians") then {
            _groups pushBack (_spawnedCivilians # 0);
            _civs append (_spawnedCivilians # 1);
        };
    };
};
Explanation: The function initializes arrays to track vehicles, groups, soldiers, and civilians spawned. It calculates the spawn position and checks if the marker is a special location (HQ, military admin). If it's a standard rebel location (not a city), it places a rebel flag. For resource points and factories, it spawns civilian workers (using A3A_fnc_createResourceCiv).
Garrison Data Retrieval and Calculation: It fetches the list of static weapons already placed in the area and the current garrison composition (unit types) stored in a global variable. The garrison is then filtered to separate special unit types (like crew for mortars) for special handling.

fn_createSDKgarrisons.sqf

Apply
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _staticsX = staticsToSave select {_x distance2D _positionX < _size};

private _garrison = [];
_garrison = _garrison + (garrison getVariable [_markerX,[]]);

// Don't create these unless required
private _groupStatics = grpNull;
private _groupMortars = grpNull;
Explanation: A3A_fnc_sizeMarker determines the search radius. staticsToSave is a global array of persistent static weapons (like HMGs). The garrison is retrieved from the garrison namespace using _markerX as the key. Two group variables are initialized to manage units assigned to static weapons.
Special Unit Handling - Mortar Crew: The function checks for specific unit types in the garrison that require special vehicle assignment. In this case, mortar crew (UnitCrew) are handled first, as they require specific placement logic.

fn_createSDKgarrisons.sqf

Apply
private _typeCrew = FactionGet(reb,"unitCrew");
if (_typeCrew in _garrison) then {
    _groupMortars = createGroup teamPlayer;
    {
        private _unit = [_groupMortars, _typeCrew, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
        private _pos = [_positionX] call A3A_fnc_mortarPos;
        private _veh = (FactionGet(reb,"staticMortars")) # 0 createVehicle _pos;
        _vehiclesX pushBack _veh;

        [_groupMortars] call A3A_fnc_artilleryAdd;

        _unit assignAsGunner _veh;
        _unit moveInGunner _veh;
        [_veh, teamPlayer] call A3A_fnc_AIVEHinit;
        _soldiers pushBack _unit;
    } forEach (_garrison select {_x == _typeCrew});
    _garrison deleteAt (_garrison find _typeCrew);
};
Explanation: It creates a dedicated group for mortars. For each crew member in the garrison, it creates a unit, calculates a safe mortar position using A3A_fnc_mortarPos, spawns the mortar, adds it to artillery logic (A3A_fnc_artilleryAdd), assigns the unit as gunner, and initializes the vehicle (A3A_fnc_AIVEHinit). The crew member is removed from the general garrison list to prevent double assignment.
Assigning Units to Existing Static Weapons: The function iterates over existing static weapons in the area. For each static, it finds available crew positions (gunner, commander, turrets) and attempts to assign a rifleman from the remaining garrison to fill them.

fn_createSDKgarrisons.sqf

Apply
{
    private _veh = _x; // Rename to avoid variable shadowing
    if !(isNil {_veh getVariable "lockedForAI"}) then { continue };
    if (!(isNull attachedTo _veh) && {_veh in (attachedTo _veh getVariable ["ace_cargo_loaded", []])}) then { continue };

    // Get all available crew positions
    private _crewPositions = [];
    
    // Check gunner position
    if (isNull gunner _veh) then {
        _crewPositions pushBack ["Gunner", []];
    };
    
    // Check commander position
    if ((_veh emptyPositions "Commander") > 0 && isNull commander _veh) then {
        _crewPositions pushBack ["Commander", []];
    };
    
    // Check turret positions - FIXED TURRET UNIT CHECK
    private _emptyTurrets = allTurrets [_veh, false] select { isNull (_veh turretUnit _x) };
    { _crewPositions pushBack ["Turret", _x] } forEach _emptyTurrets;

    // Process each position
    {
        if (count _garrison == 0) exitWith {};
        _x params ["_role", "_turretPath"];
        
        // Find rifleman in garrison
        private _index = _garrison findIf { _x == FactionGet(reb,"unitRifle") };
        if (_index == -1) exitWith {};
        
        // Create unit - FIXED TYPEOF CHECK
        private _unitGroup = if (typeOf _veh in FactionGet(all,"staticMortars")) then {
            if (isNull _groupMortars) then { _groupMortars = createGroup teamPlayer };
            _groupMortars
        } else {
            if (isNull _groupStatics) then { _groupStatics = createGroup teamPlayer };
            _groupStatics
        };
        
        private _unit = [_unitGroup, _garrison select _index, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
        
        // Assign position
        switch (_role) do {
            case "Gunner": { 
                _unit moveInGunner _veh;
                if (_unitGroup == _groupMortars) then {
                    [_unitGroup] call A3A_fnc_artilleryAdd;
                };
            };
            case "Commander": { _unit moveInCommander _veh };
            case "Turret": { _unit moveInTurret [_veh, _turretPath] };
        };
        
        // Initialize and track unit
        [_unit,_markerX] call A3A_fnc_FIAinitBases;
        _soldiers pushBack _unit;
        _garrison deleteAt _index;
        
    } forEach _crewPositions;
    
} forEach _staticsX;
Explanation: It checks for ACE cargo compatibility and "locked" status. It identifies empty positions (gunner, commander, turrets). For each empty slot, it finds a "Rifleman" unit type in the garrison. It determines the correct group (mortars or statics). The unit is created, assigned to the position, initialized (A3A_fnc_FIAinitBases), and removed from the garrison list.
Creating Infantry Groups: The remaining garrison units (those not assigned to statics) are organized into groups of size A3A_rebelGarrisonGroupSize and spawned as infantry units.

fn_createSDKgarrisons.sqf

Apply
_garrison = _garrison call A3A_fnc_garrisonReorg;

private _totalUnits = count _garrison;
private _countUnits = 0;
private _countGroup = A3A_rebelGarrisonGroupSize;
private _groupX = grpNull;

while {(spawner getVariable _markerX != 2) and (_countUnits < _totalUnits)} do {
    if (_countGroup == A3A_rebelGarrisonGroupSize) then {
        _groupX = createGroup teamPlayer;
        _groups pushBack _groupX;
        _countGroup = 0;
    };
    private _typeX = _garrison select _countUnits;
    private _unit = [_groupX, _typeX, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    if (_typeX isEqualTo FactionGet(reb,"unitSL")) then {_groupX selectLeader _unit};
    [_unit,_markerX] call A3A_fnc_FIAinitBases;
    _soldiers pushBack _unit;
    _countUnits = _countUnits + 1;
    _countGroup = _countGroup + 1;
    _groupX setBehaviour "AWARE";
    sleep 0.5;
};
Explanation: A3A_fnc_garrisonReorg optimizes the unit array. The loop runs until the marker is set to despawn (spawner variable == 2) or all units are created. New groups are formed as needed. Squad leaders are promoted. Units are initialized and tracked. A slight sleep prevents performance spikes.
Patrol Logic Assignment: The newly created groups are assigned patrol behaviors. The first group gets a specific garrison patrol routine (A3A_fnc_patrolGroupGarrison), while subsequent groups act as defenders (A3A_fnc_patrolLoop).

fn_createSDKgarrisons.sqf

Apply
for "_i" from 0 to (count _groups) - 1 do {
    _groupX = _groups select _i;
    if (_i == 0) then {
        private _garrisonGroup = [_groupX, getMarkerPos _markerX, _size] call A3A_fnc_patrolGroupGarrison;
        if (count _garrisonGroup > 0) then {
            _groups append _garrisonGroup;
        };
    } else {
        [_groupX, "Patrol_Defend", 0, 150, -1, true, _positionX, false] call A3A_fnc_patrolLoop;
    };
};
Explanation: The first group patrols the area statically. Other groups patrol defensively around the position. This creates a layered defense.
Despawn and Cleanup Logic: The function waits until the marker is set to despawn. Upon despawn, it cleans up all spawned entities (units, groups, vehicles, civilians) and updates the global event system.

fn_createSDKgarrisons.sqf

Apply
["locationSpawned", [_markerX, "RebelOutpost", true]] call EFUNC(Events,triggerEvent);

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

{ if (alive _x) then { deleteVehicle _x }; } forEach _soldiers;
{ deleteVehicle _x } forEach _civs;
{ deleteGroup _x } forEach _groups;

deleteGroup _groupStatics;
deleteGroup _groupMortars;

{if (!(_x in staticsToSave)) then {deleteVehicle _x}} forEach _vehiclesX;
["locationSpawned", [_markerX, "RebelOutpost", false]] call EFUNC(Events,triggerEvent);
Explanation: It triggers a "spawned" event. The waitUntil pauses execution until the marker is flagged for despawn. It then deletes all units (if alive), civilians, and groups. Static groups (null) are deleted. Vehicles are deleted unless they are in the staticsToSave array (persistent assets). Finally, a "despawned" event is triggered.
Where it leads:

Calls:
A3A_fnc_sizeMarker: Gets marker radius.
A3A_fnc_createResourceCiv: Spawns civilians at resources/factories.
A3A_fnc_mortarPos: Finds safe position for mortar.
A3A_fnc_createUnit: Spawns individual units.
A3A_fnc_artilleryAdd: Registers mortar group for artillery support.
A3A_fnc_AIVEHinit: Initializes vehicle AI.
A3A_fnc_FIAinitBases: Initializes unit for rebel behavior.
A3A_fnc_garrisonReorg: Optimizes garrison array.
A3A_fnc_patrolGroupGarrison: Assigns static patrol.
A3A_fnc_patrolLoop: Assigns defensive patrol.
EFUNC(Events,triggerEvent): Dispatches game events.
Depends On: Relies on garrison global variable for unit composition, staticsToSave for persistent vehicles, spawner namespace for despawn control, and faction configuration (FactionGet).
System Fit: Part of the persistent garrison system. It ensures rebel outposts have defense when active and persist across save/load cycles (via the garrison variable and staticsToSave).
Global Variables Modified:
Local: _vehiclesX, _groups, _soldiers, _civs (tracking lists for cleanup).
Global: None directly modified, but it relies on garrison, staticsToSave, and spawner.
Network Implications: Creates units and vehicles locally on the server. Uses remoteExec for flag actions to all players or specific sides. Events are triggered server-side and broadcast.
A3A/addons/core/functions/CREATE/fn_createSDKgarrisonsTemp.sqf
Function Name: fn_createSDKgarrisonsTemp.sqf
What it does: This function creates a single temporary rebel unit at a marker, intended for dynamic reinforcement (e.g., recruiting a unit at an outpost). It attempts to spawn the unit into an existing group at the marker if one is available and has space; otherwise, it creates a new group. It handles special logic for mortar crew (creates a mortar and assigns them as gunner).

How it does that:

Input Validation and Setup: It validates parameters and calculates the spawn position.

fn_createSDKgarrisonsTemp.sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_markerX", "_typeX"];

private _positionX = getMarkerPos _markerX;
if (_typeX isEqualType "") then {
Explanation: It receives the marker and unit type string. It confirms _typeX is a string (class name) before proceeding.
Group Selection Logic: It searches for existing rebel groups at the marker to avoid fragmenting squads.

fn_createSDKgarrisonsTemp.sqf

Apply
    // Select a suitable group from the current garrison for this unit
    private _groups = if (_typeX == FactionGet(reb,"unitCrew")) then {[]} else {
        allGroups select {
            (leader _x getVariable ["markerX",""] == _markerX)
            and (count units _x < 8) and (vehicle (leader _x) == leader _x)
            and (side _x == teamPlayer)                // can happen with surrendered enemy garrison
        };
    };

    private _groupX = if (_groups isEqualTo []) then {
        createGroup teamPlayer
    } else {
        _groups select 0;
    };
Explanation: If the unit is a crew member, it uses an empty list (forces new group creation). Otherwise, it searches allGroups for groups where the leader's marker variable matches _markerX, the group size is less than 8 (max squad size), the leader is not in a vehicle, and the side is teamPlayer. If no group fits, a new group is created.
Unit Creation and Assignment: It creates the unit and handles special "Crew" type assignment (mortar handling).

fn_createSDKgarrisonsTemp.sqf

Apply
    private _unit = [_groupX, _typeX, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    [_unit,_markerX] call A3A_fnc_FIAinitBases;
    if (_typeX isEqualTo FactionGet(reb,"unitRifle")) then { [_markerX] remoteExec ["A3A_fnc_updateRebelStatics", 2] };

    if (_typeX == FactionGet(reb,"unitCrew")) then {
        private _veh = (FactionGet(reb,"staticMortars")) # 0 createVehicle _positionX;
        [_veh] call A3A_fnc_artilleryAdd;

        _unit assignAsGunner _veh;
        _unit moveInGunner _veh;
        [_veh, teamPlayer] call A3A_fnc_AIVEHinit;
    };
Explanation: The unit is created via A3A_fnc_createUnit and initialized. If the unit is a rifleman, it triggers an update to static weapons (likely to refresh garrison counts). If it is a crew member, it spawns a mortar, adds it to artillery, and assigns the unit to it.
Patrol Assignment and Cleanup Logic: If a new group was created, it assigns patrol behavior. A cleanup script is spawned to delete the unit when the marker despawns.

fn_createSDKgarrisonsTemp.sqf

Apply
    if (_groups isEqualTo []) then {
        [_groupX, "Patrol_Defend", 10, 150, -1, true, _positionX, true] call A3A_fnc_patrolLoop;
    };

    [_unit,_markerX] spawn {
        private _unit = _this select 0;
        private _markerX = _this select 1;
        waitUntil {sleep 1; (spawner getVariable _markerX == 2)};
        if (alive _unit) then {
            private _groupX = group _unit;
            if ((_unit getVariable "unitType") isEqualTo FactionGet(reb,"unitCrew")) then {deleteVehicle (vehicle _unit)};
            deleteVehicle _unit;
            if (count units _groupX == 0) then {deleteGroup _groupX};
        };
    };
Explanation: New groups are assigned a defense patrol. A separate script runs in the background. It waits for the marker to despawn (spawner == 2). Upon despawn, it deletes the unit. If the unit was crew, it deletes their vehicle (mortar) first. If the unit's group is now empty, the group is deleted.
Where it leads:

Calls:
A3A_fnc_createUnit: Spawns the unit.
A3A_fnc_FIAinitBases: Initializes unit.
A3A_fnc_updateRebelStatics: Updates static weapon counts (remote exec).
A3A_fnc_artilleryAdd: Registers mortar.
A3A_fnc_AIVEHinit: Initializes mortar.
A3A_fnc_patrolLoop: Assigns patrol if new group.
Depends On: FactionGet for unit classes, spawner namespace for despawn control.
System Fit: Provides dynamic reinforcement capability for rebel garrisons. Used when a player recruits a unit at a base.
Global Variables Modified:
Local: _groups, _groupX (tracking).
Global: None directly modified.
Network Implications: Uses remoteExec to update statics for the server.
A3A/addons/core/functions/CREATE/fn_createUnit.sqf
Function Name: fn_createUnit.sqf
What it does: A wrapper around the native createUnit command that adds extensive functionality. It supports creating units from classnames or custom loadout arrays. It handles custom unit types defined in the A3A_customUnitTypes hashmap (like specialized skeletons or loadouts), applies random identities, handles traits, and manages unit properties (like "isRival" or "unitPrefix").

How it does that:

Parameter Parsing: Extracts parameters with defaults for optional arguments.

fn_createUnit.sqf

Apply
params ["_group", "_type", "_position", ["_markers", []], ["_placement", 0], ["_special", "NONE"], "_identity"];

private _unitDefinition = A3A_customUnitTypes getVariable [_type, []];
Explanation: It defines all parameters, setting markers, placement, and special to defaults. It immediately checks if _type corresponds to a custom unit definition stored in the A3A_customUnitTypes namespace.
Custom Unit Type Handling: If the unit type is custom, it processes the definition array to extract loadouts, traits, properties, and the base class.

fn_createUnit.sqf

Apply
if !(_unitDefinition isEqualTo []) exitWith {
    _unitDefinition params ["_loadouts", "_traits",  "_unitProperties", "_unitClass"];
    private _canSkip = false;

    {
        if (_x select 0 isEqualTo "baseClass") then
        {
            _unitClass = _x select 1; // grab the classname
            if (_unitClass isEqualType []) then
            {
                if ((_unitClass select 0) isEqualType []) exitWith
                {
                    private _weights = ((_x select 1) select 1);
                    private _units = ((_x select 1) select 0);
                    _unitClass = _units selectRandomWeighted _weights; // grab a random classname, weighted
                };
                _unitClass = selectRandom (_x select 1); // grab a random classname
            };
        };
        if (_x select 2 isEqualTo true) then
        {
            _canSkip = true;
        };
    } forEach _traits; // grab all data from base class trait

    private _unit = _group createUnit [_unitClass, _position, _markers, _placement, _special];
    [_unit] joinSilent _group; // normally, this command is literally pointless. But when we're mixing base classes (e.g opfor) but spawning them as blufor (swap enemy sides selection), it'll make them fight each other unless we do this

    if (_canSkip isEqualTo false) then {
        _unit setUnitLoadout selectRandom _loadouts;
    };
    _unit setVariable ["unitType", _type, true];

    private _identity = if (isNil "_identity") then {
        [Faction(side _unit), _type] call A3A_fnc_createRandomIdentity;
    } else {
        _identity;
    };
    [_unit, _identity] call A3A_fnc_setIdentity;

    //it's very fragile and non-extensible (adding second bool or string value into template will break this)
    {
        switch (true) do {
            case (_x isEqualType true): {
                _unit setVariable ["isRival", _x, true];
            };
            case (_x isEqualType ""): {
                _unit setVariable ["unitPrefix", _x, true];
            };
        };
    } forEach _unitProperties;

    {
        if (_x select 0 isNotEqualTo "baseClass") then {
            _unit setUnitTrait _x;
        };
    } forEach _traits;
    _unit
};
Explanation:
It iterates through _traits to find "baseClass" definitions (supporting arrays of classes, weighted selection, or single classes) and to check if loadouts should be skipped (_canSkip).
It creates the unit using the determined base class.
joinSilent is used to ensure side consistency (crucial for side-swapped scenarios).
If loadouts aren't skipped, it applies a random loadout from the definition list.
It sets the unitType variable.
It generates or applies a specific identity (face, voice, name) via A3A_fnc_createRandomIdentity and A3A_fnc_setIdentity.
It processes _unitProperties (booleans and strings) into unit variables (isRival, unitPrefix).
It applies traits (excluding the "baseClass" descriptor trait).
Standard Unit Type Handling: If the type is not a custom definition, it falls back to standard createUnit.

fn_createUnit.sqf

Apply
private _unit = _group createUnit [_type, _position, _markers, _placement, _special];
_unit setVariable ["unitType", _type, true];
_unit
Explanation: Creates a standard unit, sets the unitType variable, and returns it.
Where it leads:

Calls:
A3A_fnc_createRandomIdentity: Generates identity data.
A3A_fnc_setIdentity: Applies identity to the unit.
Depends On: A3A_customUnitTypes global namespace.
System Fit: The core unit spawning tool for the entire addon. It allows for extensive customization of rebel, enemy, and civilian units via faction templates.
Global Variables Modified:
Local: _unit (created object).
Global: None.
Network Implications: Identity and variable setting are local to the unit creation machine (usually server).
A3A/addons/core/functions/CREATE/fn_createVehicleCrew.sqf

Function Name: fn_createVehicleCrew.sqf
What it does: This function creates and assigns a crew to a specific vehicle. It handles drivers, gunners, commanders, and all turret positions based on the vehicle's configuration. It intelligently skips positions that don't require AI (like "donCreateAI" turrets or "showAsCargo" turrets on non-heli vehicles) and handles special cases like UAVs. It can either join existing groups or create a new one.

How it does that:

Parameter Parsing and Group Creation: Handles the input group or side parameter and initializes UAV logic.

fn_createVehicleCrew.sqf

Apply
params ["_group", "_vehicle", "_unitType"];

private _isHeli = _vehicle isKindOf "Helicopter";

private _newGroup = false;
if (_group isEqualType sideUnknown) then {
    _group = createGroup _group;
    _newGroup = true;
};

// Hack. Moving UAV AIs into gunner/turret manually does not work for some reason
if (unitIsUAV _vehicle) then {
    createVehicleCrew _vehicle;
    crew _vehicle joinSilent _group;
};
Explanation: Checks if _group is a side (e.g., west) and creates a group if so. For UAVs, it uses the native createVehicleCrew command because manual assignment is buggy, then moves the crew to the target group.
Driver Creation: Checks for a driver seat and creates a unit if empty.

fn_createVehicleCrew.sqf

Apply
if (isNil "_unitType") then {
    _unitType = [side _group, _vehicle] call A3A_fnc_crewTypeForVehicle;
};

private _type = typeOf _vehicle;
private _config = configFile >> "CfgVehicles" >> _type;
if (getNumber (_config >> "hasDriver") > 0 && isNull driver _vehicle) then {
    private _driver = [_group, _unitType, getPos _vehicle, [], 10] call A3A_fnc_createUnit;
    _driver assignAsDriver _vehicle;
    _driver moveInDriver _vehicle;
};
Explanation: If no unit type is provided, it determines the appropriate crew class (e.g., generic "crew" or specific "pilot") using A3A_fnc_crewTypeForVehicle. It checks the vehicle config for a driver seat. If present and empty, it creates a unit, assigns it as driver, and moves it in.
Turret Crew Creation (Recursive): Defines and calls a recursive function to handle all turret positions, including nested ones (like commander views inside gunner turrets).

fn_createVehicleCrew.sqf

Apply
private _fnc_addCrewToTurrets = {
    params ["_config", ["_path", []]];
    private _turrets = "true" configClasses (_config >> "Turrets");
    {
        private _turretConfig = _x;
        private _turretPath = _path + [_forEachIndex];
        //Handle nested turrets
        [_turretConfig, _turretPath] call _fnc_addCrewToTurrets;

        if (getNumber (_turretConfig >> "hasGunner") == 0 || getNumber (_turretConfig >> "dontCreateAI") != 0) then { continue };
        if (!_isHeli && {getNumber (_turretConfig >> "showAsCargo") > 0}) then { continue };
        if (isNull (_vehicle turretUnit _turretPath)) then {
            private _gunner = [_group, _unitType, getPos _vehicle, [], 10] call A3A_fnc_createUnit;
            _gunner assignAsTurret [_vehicle, _turretPath];
            _gunner moveInTurret [_vehicle, _turretPath];
        };
    } forEach _turrets;
};

[_config] call _fnc_addCrewToTurrets;
Explanation:
It iterates through all turrets in the vehicle config.
It calls itself recursively for nested turrets.
It checks hasGunner, dontCreateAI, and showAsCargo flags to determine if a crew member should be spawned.
If the position is empty, it creates a unit, assigns it to the specific turret path, and moves it in.
Finalization: Assigns leadership and links the vehicle to the group.

fn_createVehicleCrew.sqf

Apply
if (_newGroup) then {
    _group selectLeader (effectiveCommander _vehicle);
};

_group addVehicle _vehicle;
_group
Explanation: If a new group was created, it selects the effective commander (highest command rank in the vehicle) as leader. It then adds the vehicle to the group's vehicle array and returns the group.
Where it leads:

Calls:
A3A_fnc_crewTypeForVehicle: Determines unit class for the crew.
A3A_fnc_createUnit: Spawns the crew members.
Depends On: Faction configuration for crew types.
System Fit: Used whenever a vehicle needs crew, such as in convoy missions, QRFs, or transport missions.
Global Variables Modified:
Local: _group, _unit (created).
Global: None.
Network Implications: Spawns units locally (server).

What it does: This function dictates the tactical behavior and maneuvering of a vehicle QRF (Quick Reaction Force) squad. It determines how a specific vehicle type (aircraft, helicopter, or ground vehicle) should engage its target. This includes calculating landing zones for air units, setting up dismount and attack waypoints for ground units, and selecting appropriate AI behaviors (e.g., combat landing, paradrop, assault).

It is typically executed on the server or Headless Client (HC) when a QRF is triggered to reinforce or attack a location.

How it does that:

1. Parameter Initialization and Vehicle Configuration The function begins by unpacking arguments and configuring the vehicle's detection and targeting properties to ensure it interacts correctly with the mission's friendly forces.

Parameters: Receives the vehicle object, crew group, cargo group, target position, origin marker, and a blacklist of occupied landing positions.
Radar & Targeting: Sets remote target reporting and receiving to true so the vehicle can act as part of a networked battle.
Sizing: Calculates minimum object distance and clearance based on the vehicle's bounding box size to avoid collisions.
Sqf

Apply
// ... existing code ...
params ["_vehicle", "_crewGroup", "_cargoGroup", "_posDestination", "_markerOrigin", "_landPosBlacklist", ["_isAirdrop", false], "_resPool"];

_vehicle setVehicleRadar 0;
_vehicle setVehicleReceiveRemoteTargets true;
_vehicle setVehicleReportRemoteTargets true;
_vehicle setVehicleReportOwnPosition true;

private _vehType = typeOf _vehicle;
private _minObjectDistance = 10 max ((sizeOf _vehType) / 2);
private _minClearance = 10 max (sizeOf _vehType);
// ... existing code ...
2. Air Vehicle Handling (Helicopters, VTOLs, Dropships) If the vehicle is airborne, the function branches based on specific faction type lists (Transport, Attack, Dropship).

VTOL Identification: Checks the config for vtol > 0 and membership in transport lists to handle large transport aircraft.
Transport Logic (Helicopters/VTOLs):
Landing Zone Search: Uses BIS_fnc_findSafePos to find a location near the target. It adjusts search radius based on whether it's a VTOL (needs more space).
Blacklist Check: Verifies the found position isn't already occupied by other units to prevent stacking.
Action Selection: Uses selectRandomWeighted to choose between combatLanding, fastrope, or paradrop. The weights (e.g., 90 vs 10) prioritize combat landing for helicopters but allow for paradrops if a landing zone is unavailable.
Attack Helicopter Logic: Handles attack choppers (AH-64, KA-52). If they carry cargo, they attempt to land; if not, they engage directly via A3A_fnc_attackHeli.
Dropship Logic: Handles specific transport aircraft capable of vehicle airdrops.
Sqf

Apply
// ... existing code ...
if (_vehicle isKindOf "Air" || _vehType in FactionGet(all,"vehiclesDropPod")) then
{
    if (_vehType in FactionGet(all,"vehiclesHelisTransport") + ...) exitWith
    {
        // Transport logic
        _landPos = [_posDestination, [200, 300] select (_vtol), ...] call BIS_fnc_findSafePos;
        // ... blacklist check ...
        if !(_landPos isEqualTo [0,0,0]) then {
            if (_vtol) then {
                call selectRandomWeighted [
                    {[_vehicle, _crewGroup, _cargoGroup, _posDestination, _posOrigin, _landPos] spawn A3A_fnc_combatLanding}, 10,
                    // ... other options ...
                ];
            };
        };
    };
    if (_vehType in FactionGet(all,"vehiclesHelisAttack") + ...) exitWith 
    {   
        // Attack helicopter logic
        if (count units _cargoGroup > 3) then {
            // Attempt landing if heavily loaded
        } else {
            [_vehicle, _crewGroup, _posDestination] spawn A3A_fnc_attackHeli;
        };
    };
// ... existing code ...
3. Ground Vehicle Handling If the vehicle is not airborne, it handles ground transport (Trucks, APCs, Tanks).

Type Identification: Maps the vehicle class to a localized string (e.g., "Tank", "MRAP") for UI purposes.
Branching Logic:
No Cargo: If isNull _cargoGroup, the vehicle acts as a tank destroyer. It disables mine detection (AI optimization) and adds a "SAD" (Search and Destroy) waypoint directly to the target.
No Gunner & Small Cargo: If the vehicle lacks firepower (no gunner) and has few passengers, the crew joins the cargo group. They drive to a safe unload position and then attack on foot.
Single Crew (Driver only) + Large Cargo: The vehicle drives to an unload point, disembarks the cargo, and the vehicle returns to base (RTB) via enemyReturnToBase.
Standard Weaponized Vehicle: The standard case. The vehicle drives to an unload point, drops cargo using TR UNLOAD and synchronized waypoints, and the vehicle crew attacks the target separately using SAD waypoints.
Sqf

Apply
// ... existing code ...
else            // ground vehicle
{
    // ... Type identification (_typeName) ...

    if (isNull _cargoGroup) exitWith
    {
        // No passengers -> Combat vehicle
        {_x disableAI "MINEDETECTION"} forEach (units _crewGroup);
        _vehicle allowCrewInImmobile true;
        [getPosATL _vehicle, _posDestination, _crewGroup] call A3A_fnc_WPCreate;
        // ... set SAD waypoint ...
    };

    if (isNull gunner _vehicle and count units _cargoGroup < 4) exitWith
    {
        // Weak vehicle -> Merge groups, drive, dismount, walk
        (units _crewGroup) joinSilent _cargoGroup;
        // ... find unload pos ...
        private _dismountWP = [_cargoGroup, count waypoints _cargoGroup - 1];
        _dismountWP setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) leaveVehicle (assignedVehicle this); (group this) spawn A3A_fnc_attackDrillAI"];
    };

    if (true) exitWith
    {
        // Standard Transport Logic
        // ... Find safe road to unload ...
        private _vehWP0 = [_crewGroup, count waypoints _crewGroup - 1];
        _vehWP0 setWaypointType "TR UNLOAD";
        _vehWP0 setWaypointStatements ["true", "if !(local this) exitWith {}; [vehicle this] call A3A_fnc_smokeCoverAuto"];
        // ... Vehicle proceeds to attack after unloading ...
    };
};
// ... existing code ...
4. Return Value Updates and returns the _landPosBlacklist array to ensure subsequent QRF waves do not try to land in the same spot.

Where it leads:

Called Functions:
A3A_fnc_combatLanding: Executes tactical landing for air units.
A3A_fnc_fastrope / A3A_fnc_fastropeVTOL: Handles rope descent.
A3A_fnc_paradrop / SCRT_fnc_common_paradropVehicle: Handles parachute drops.
A3A_fnc_OrbitalLanding: Handles drop pods.
A3A_fnc_attackHeli: Logic for attack helicopter engagement.
A3A_fnc_WPCreate: Generates movement waypoints for ground vehicles.
A3A_fnc_findSafeRoadToUnload: Locates a parking spot for ground vehicles.
A3A_fnc_inmuneConvoy: Applies immunity flags to the convoy.
A3A_fnc_attackDrillAI: Script run by AI after dismounting.
Dependencies: Depends on FactionGet arrays to classify vehicles. The spawner system handles the physical creation.
Global State: Modifies _landPosBlacklist (passed by reference). Modifies vehicle waypoints and AI behavior state.
Function Name: fn_crewTypeForVehicle.sqf
What it does: This is a lookup utility that determines the appropriate crew unit class name for a specific vehicle side and type. It utilizes a pre-compiled hashmap (A3A_vehClassToCrew) to efficiently retrieve the correct crew type (e.g., NATO Crew for NATO Tank).

How it does that:

1. Parameter and Side Mapping Converts the SIDE argument into an array index (_sideIndex) to allow array-based selection.

Mapping: west -> 0, east -> 1, independent -> 2, civilian -> 3.
2. Hashmap Lookup Retrieves an array of crew types for the specific vehicle class from the global A3A_vehClassToCrew hashmap.

Fallback: If the vehicle type is not found in the hashmap, it falls back to a default array containing standard rifleman units for each side.
Selection: It selects the specific crew type string using the _sideIndex.
Sqf

Apply
// ... existing code ...
params ["_side", "_vehicle"];

private _sideIndex = [west, east, independent, civilian] find _side;

private _typeX = typeOf _vehicle;

// Returns an array [WestType, EastType, IndepType, CivType]
A3A_vehClassToCrew getOrDefault [_typeX,
    [
        FactionGetTiered(occ,"unitRifle"), 
        FactionGetTiered(inv,"unitRifle"), 
        FactionGet(reb,"unitCrew"), 
        FactionGet(civ,"unitMan")
    ]
] select _sideIndex; // Selects based on calculated index
// ... existing code ...
Where it leads:

Called Functions: None directly in this snippet, but relies on FactionGet (pre-runtime). It is strictly a lookup.
Dependencies: Requires A3A_vehClassToCrew to be initialized (done in fn_initVehClassToCrew.sqf).
Usage: Called by createVehicleCrew and similar spawning logic to determine what units to create inside a vehicle.
Function Name: fn_cycleSpawn.sqf
What it does: This function manages the dynamic spawning of units for a specific garrison marker (e.g., an outpost or city). It reads the garrison data structure, creates vehicles and units, assigns them to groups, and initiates patrol loops (defensive and roaming). It handles the distinction between "stay" groups (defending the base) and "patrol" groups (roaming the area).

How it does that:

1. Initialization and Data Retrieval Sets up variables and retrieves the garrison composition for the given marker.

Garrison Data: Retrieves a nested array representing the unit lines: [VehicleType, CrewArray, CargoArray].
Metrics: Calculates total garrison count and patrol area size (_patrolSize).
2. Looping Through Garrison Lines Iterates over each line in the garrison data. For each line:

Vehicle Handling:
Checks if a vehicle is present (line 0 is not empty string).
Determines spawn type (Car, Heli, Plane) to select the correct spawn position generator.
Calls A3A_fnc_findSpawnPosition to get a valid location.
Creates the vehicle, sets allowDamage false initially (spawn protection), adds a "Killed" event handler to request a replacement via A3A_fnc_addRequested, and assigns it to the group.
Crew Handling:
Spawns units defined in _crewArray into _groupX. Adds Killed event handlers for garrison tracking.
Cargo Handling & Group Splitting:
Garrison Logic: Calls A3A_fnc_patrolGroupGarrison to determine if units should stay inside buildings (if supported).
Patrol Logic: Determines if the cargo should be split into a separate patrol group based on force density (_forcePatrol). It creates new groups (_groupSoldier) for cargo units to allow for splitting movement (some stay, some patrol).
Creation: Spawns cargo units, distributing them into groups to keep squad sizes manageable (approx 2-5 units per group).
Sqf

Apply
// ... existing code ...
{
  _vehicleType = _x select 0;
  _crewArray = _x select 1;
  _cargoArray = _x select 2;
  _groupX = createGroup _side;

  if (_vehicleType != "") then
  {
    // Vehicle logic
    private _spawnParameter = [];
    if(_vehicleType isKindOf "Car") then { ... };
    // ... find spawn position ...
    _vehicle = createVehicle [_vehicleType, _spawnParameter select 0, [], 0 , "CAN_COLLIDE"];
    // ... setup, EH, add to group ...
  };

  // Crew logic
  {
    _unitX = [_groupX, _x, ...] call A3A_fnc_createUnit;
    // ... EH ...
  } forEach _crewArray;

  // Cargo Logic
  private _forcePatrol = ...;
  _groupSoldier = createGroup _side;
  {
    _unitX = [_groupSoldier, _x, ...] call A3A_fnc_createUnit;
    // ... Splitting logic based on counter ...
    if((_counter >= 2) && {_forcePatrol || ...}) then {
        _groupSoldier = createGroup _side; // New group
        // ...
    };
  } forEach _cargoArray;
} forEach _garrison;
// ... existing code ...
3. Patrol Initialization After all units are spawned, it calculates patrol area sizes relative to unit count.

Area Resizing: If the area is too large for the unit count, the _patrolMarker size is reduced to keep units active in a reasonable zone.
Loop Calls:
stayGroups: Calls patrolLoop with mode "Patrol_Defend". These groups defend the spawn marker area.
patrolGroups: Calls patrolLoop with mode "Patrol_Area". These groups roam a larger radius.
Where it leads:

Called Functions:
A3A_fnc_getGarrison: Retrieves garrison data structure.
A3A_fnc_findSpawnPosition: Finds specific slot for vehicle.
A3A_fnc_createUnit: Spawns individual unit.
A3A_fnc_patrolGroupGarrison: Checks for building garrisoning.
A3A_fnc_addRequested: Flags vehicle destruction for replacement.
A3A_fnc_patrolLoop: Initiates the AI movement behavior.
Dependencies: Relies on spawner variables for spawn position tracking. Depends on A3A_fnc_cycleSpawn being triggered by the spawner scheduler system.
Global State: Modifies spawner variables via findSpawnPosition. Adds units to the global unit pool.
Function Name: fn_FIAinitBASES.sqf
What it does: Initializes a specific FIA (Friendly Independence Army/Rebel) unit when they are spawned at a base or garrison. It sets their skill levels, equips them, applies event handlers for death/aggression tracking, and enables special awareness (e.g., spotting air units).

How it does that:

1. Validation and Setup Checks if the unit is valid and retrieves context (marker).

Marker Association: If a marker is passed in arguments, it links the unit to that specific base marker via setVariable.
Simulation Control: If the base marker's spawner state indicates the area is not fully active, it disables simulation globally to save performance.
2. Skill and Traits Configuration Calculates skill based on global multipliers and specific unit roles.

Base Skill: 0.1 + 0.1*A3A_rebelSkillMul + 0.015 * skillFIA.
Role Bonuses: Squad leaders get boosts to courage/commanding; Snipers get boosts to accuracy/shake.
Fleeing: _unit allowFleeing 0 ensures FIA units do not rout easily.
3. Equipment and Weapon Selection Equips the unit using the rebel gear system and ensures they have a weapon ready.

Sqf

Apply
// ... existing code ...
[_unit, 2] call A3A_fnc_equipRebel;			// 2 = garrison unit
_unit selectWeapon (primaryWeapon _unit);
// ... existing code ...
4. Event Handlers (Killed) Attaches a critical event handler to track unit death.

Postmortem: Calls A3A_fnc_postmortem to handle loot/XP calculations.
Aggression: Calls A3A_fnc_addAggression (side -1) which impacts the global war level.
City Support: If killed by Occupants, reduces local city support (A3A_fnc_citySupportChange).
Garrison Update: Removes the unit from the garrison tracking on the specific marker via A3A_fnc_garrisonUpdate.
5. Air Awareness Logic If the unit is a gunner (in a vehicle) or carries a launcher, they gain awareness of air units.

Reveal: Iterates through nearby air vehicles and reveals them to the unit with a high confidence value (1.5).
Where it leads:

Called Functions:
A3A_fnc_initRevive: Applies medical/revive capability.
A3A_fnc_equipRebel: Generates loadout.
A3A_fnc_postmortem: Handles death logic (XP/Loot).
A3A_fnc_addAggression: Updates global aggression.
A3A_fnc_citySupportChange: Updates local politics.
A3A_fnc_garrisonUpdate: Syncs garrison state to server.
Dependencies: Called immediately after a unit is created (e.g., by createUnit or cycleSpawn).
Network Implications: The event handler runs locally when the unit dies, then executes remote commands (to server) to update global variables. The "Air Awareness" logic runs locally on the machine executing the script (usually server/HC).

Function Name: findSpawnPosition.sqf
File Location: A3A/addons/core/functions/CREATE/fn_findSpawnPosition.sqf

What it does:
This function retrieves an empty spawn position from a predefined marker of a specific type (vehicle, mortar, heli, or plane). It maintains a tracking system to prevent multiple spawns from using the same position simultaneously, implementing a lockout mechanism for spawn positions.

Context/Usage:

Called when the game needs to spawn a new unit or vehicle at a specific marker location
Used by various mission spawning systems to ensure no collisions between spawned objects
Part of the spawn management system that tracks available positions for different entity types
Coordinates with freeSpawnPositions to recycle positions after despawn
How it does that:
Step 1: Parameter Validation
Sqf

Apply
params ["_marker", "_type"];
Parameters:
_marker: String - The marker name to search for spawn positions
_type: String - The type of spawn place ("vehicle", "mortar", "heli", "plane")
Validation: No explicit validation, assumes correct input format
Processing: No transformation of parameters
Step 2: Variable Name Construction
Sqf

Apply
private _varName = format ["%1_%2", _marker, tolower _type];
private _varNameUsed = _varName + "_used";
Logic: Constructs unique variable names by combining marker name and lowercase type
Example: For marker "base1" and type "vehicle" → _varName = "base1_vehicle", _varNameUsed = "base1_vehicle_used"
Purpose: Creates deterministic, unique identifiers for each spawn position set
Step 3: Check Available Positions
Sqf

Apply
private _used = spawner getVariable [_varNameUsed, []];
private _index = _used find false;
Step 3a: Get used positions array from spawner namespace
Uses spawner namespace (global object manager)
Retrieves array tracking which positions are marked as used (true) or available (false)
Defaults to empty array if variable doesn't exist
Step 3b: Find first available position
Searches for false value in used array
Returns index of first available position, or -1 if none found
Global Variable: spawner (namespace object containing all spawn tracking data)
Step 4: Handle No Available Positions
Sqf

Apply
if (_index == -1) exitWith {
    Info_1("%1 has no remaining spawn positions of type %2", _marker, _type);
    false;
};
Condition: No available positions found
Action:
Logs informational message using Info_1 macro (logs to RPT with context)
Returns false to indicate failure
Edge Case: First time called for this marker/type (no positions set up yet)
Edge Case: All positions are currently in use (high spawn rate/desync)
Step 5: Mark Position as Used
Sqf

Apply
_used set [_index, true];
spawner setVariable [_varNameUsed, _used, true];
Step 5a: Update local array
Sets the position at _index to true (marked as used)
Modifies the array in place
Step 5b: Update global state
Saves updated array back to spawner namespace
Third parameter true: Syncs to all clients and JIP (JIP = Just In Player)
Network implication: This is a networked operation; will propagate to all connected players
Race condition risk: If multiple clients call simultaneously, could have collisions (mitigated by server-side only execution typically)
Step 6: Retrieve Position Data
Sqf

Apply
private _return = spawner getVariable (_varName + "_places") select _index;
Logic: Gets the actual spawn position data from another variable
Variable name: _varName + "_places" (e.g., "base1_vehicle_places")
Data structure: Array of spawn place data, each containing:
Central position (POSAGL - position format with height)
Direction (NUMBER - orientation)
Any additional placement data
Retrieval: Uses select _index to get specific position at the same index
Step 7: Add Cleanup Data
Sqf

Apply
_return pushBack [_varNameUsed, _index];
Action: Appends tracking data to the position data
Structure added: Array [_varNameUsed, _index]
_varNameUsed: Variable name to track usage (e.g., "base1_vehicle_used")
_index: Index of this position in the used array
Purpose: Creates closure data that can be passed to freeSpawnPositions to mark position as free again
Data returned: [position, direction, [varNameUsed, index]]
Step 8: Debug Logging
Sqf

Apply
Debug_2("Used place with varname %1 and index %2", _varName, _index);
Logging: Only executes if debug mode is enabled
Information: Logs which position was allocated
Debug macro: Uses Debug_2 format string with two parameters
Step 9: Return Result
Sqf

Apply
_return;
Return Value: Array containing:
Position data (POSAGL - x,y,z coordinates)
Direction (NUMBER - degrees)
Cleanup data (ARRAY - [varNameUsed, index])
Failure case: Returns false (see Step 4)
Where it leads:
Functions this calls:
Info_1 - Logging macro for informational messages
Debug_2 - Debug logging macro (conditional)
spawner getVariable - Retrieves data from spawn namespace
spawner setVariable - Saves data to spawn namespace (network synced)
Functions that depend on this one:
freeSpawnPositions - The complementary function that marks positions as free
spawnVehicle - Likely calls this to get spawn positions for vehicles
spawnVehicleAtMarker - Spawning functions that need specific positions
createAttackForce* - Attack force creation functions
createAI* - AI spawning functions
spawnGroup - Group spawning functions
Global Variables Modified:
spawner namespace - Specifically spawner namespace variables
[marker]_[type]_used - Boolean array tracking used positions
JIP synchronized (third parameter true)
System Integration:
Spawn Management System: Core part of A3A's dynamic spawning system
Marker-Based Spawning: Tied to predefined markers on map
Position Recycling: Enables reuse of spawn positions after despawn
Multi-Player Sync: Network synchronized to prevent collisions in multiplayer
Performance Optimization: Tracks positions to prevent overlapping spawns
Technical Details:
Array Operations: Uses find (O(n) search) for locating false values
In-Place Modification: Modifies array directly with set
Variable Naming Convention: Deterministic naming scheme enables dynamic lookup
JIP Handling: Third parameter true ensures new players see correct state
Edge Cases:
First Call: No positions exist yet → Returns false
All Positions Used: High concurrency → Returns false
Race Conditions: Multiple clients calling simultaneously → Could cause duplicates (server should handle)
Marker Non-Existent: Returns false if variable doesn't exist
Type Invalid: Returns false (unhandled type)
Network Implications:
Server Authority: Typically called server-side
Broadcast: setVariable with true broadcasts to all clients
JIP Compatible: New players get correct state
Desync Risk: Moderate - if clients call directly, could cause conflicts
Recommended: Always execute server-side only
Function Name: freeSpawnPositions.sqf
File Location: A3A/addons/core/functions/CREATE/fn_freeSpawnPositions.sqf

What it does:
This function marks spawn positions as available again after they're no longer needed. It accepts cleanup data returned by findSpawnPosition and updates the global tracking system to allow the position to be reused.

Context/Usage:

Called when a spawned unit/vehicle is despawned or destroyed
Called by cleanup functions, unit death handlers, or mission completion scripts
Maintains the availability pool for spawn positions
Must be called with data returned by findSpawnPosition
How it does that:
Step 1: Parameter Acceptance
Sqf

Apply
{
    // ... processing loop
} forEach _this;
Input: this context (implicit parameter)
Expected format: Array of cleanup data (each element is [varNameUsed, index])
Loop Structure: Uses forEach to process each cleanup entry
Flexibility: Can accept multiple position data in single call
Step 2: Type Validation
Sqf

Apply
if !(_x isEqualTypeArray ["", 0]) then {
    Error_1("Invalid data provided: %1", _x);
    continue;
};
Validation Check: Verifies each element is an array containing [STRING, NUMBER]
isEqualTypeArray: Ensures exact type match (not just similar)
Error Handling: Logs error and continues processing next element
Error Macro: Error_1 for logging validation failures
Edge Case: Malformed cleanup data doesn't crash entire function
Step 3: Extract Cleanup Data
Sqf

Apply
_x params ["_varName", "_index"];
Destructuring: Splits array into:
_varName: String - The usage tracking variable name (e.g., "base1_vehicle_used")
_index: Number - The index in the used array
Validation: Implicitly validates array has exactly 2 elements
Step 4: Retrieve Usage Array
Sqf

Apply
private _used = spawner getVariable [_varName, []];
Retrieval: Gets the boolean array from spawner namespace
Default: Empty array if variable doesn't exist
Variable Name: Uses _varName directly (already has _used suffix from findSpawnPosition)
Step 5: Index Validation
Sqf

Apply
if (count _used <= _index) then {
    Error_3("Invalid index %3 provided for varname %1", _varName, _index);
    continue;
};
Bounds Check: Verifies index is within array bounds
Logic: count <= index catches out-of-bounds indices
Error Logging: Error_3 with varName and index for debugging
Safety: Prevents array modification errors
Edge Cases:
Index too high (array shrunk by cleanup)
Index negative
Array was cleared/changed externally
Step 6: Mark Position as Free
Sqf

Apply
_used set [_index, false];
Action: Sets the boolean at _index to false (available)
In-Place Modification: Modifies the array directly
Result: Position marked as reusable
Step 7: Update Global State
Sqf

Apply
spawner setVariable [_varName, _used, true];
Saving: Updates the global namespace with modified array
Third Parameter true: Syncs to all clients and JIP
Network: Broadcasts availability change to all players
Impact: Other clients can now use this position
Step 8: Debug Logging
Sqf

Apply
Debug_2("Freed place with varname %1 and index %2", _varName, _index);
Conditional Logging: Only in debug mode
Information: Confirms which position was freed
Debug_2: Two parameter debug macro
Where it leads:
Functions this calls:
Error_1 - Error logging for validation failures
Error_3 - Error logging for index validation failures
Debug_2 - Debug logging for successful freeing
spawner getVariable - Reads from spawn namespace
spawner setVariable - Writes to spawn namespace (network synced)
Functions that depend on this one:
findSpawnPosition - The complementary function that allocates positions
VEHdespawner - Vehicle despawning function
groupDespawner - Group despawning function
cycleSpawn - Spawning cycle that cleans up old entities
Cleanup handlers in various spawn functions
Death handlers for AI units and vehicles
Mission completion scripts
Global Variables Modified:
spawner namespace - Specifically [marker]_[type]_used arrays
Each element set from true (used) to false (free)
JIP synchronized (third parameter true)
System Integration:
Position Recycling: Enables reuse of limited spawn positions
Spawn Pool Management: Maintains availability pool for dynamic spawning
Multi-Player Sync: All clients aware of position availability
Memory Management: Prevents indefinite position locking
Dynamic Spawning: Allows wave spawning without position exhaustion
Technical Details:
Array Processing: Processes multiple entries in single call
Error Resilience: Continues processing on error (doesn't abort)
Type Safety: Validates input structure before processing
In-Place Modification: Modifies arrays directly for efficiency
Edge Cases:
Empty Input: _this empty → nothing happens
Invalid Data Type: Non-array elements → logged and skipped
Wrong Array Size: Array not [string, number] → logged and skipped
Variable Missing: spawner variable doesn't exist → creates empty array
Out of Bounds Index: Index too high → logged and skipped
Double Free: Freeing already freed position → false set to false (idempotent)
Race Conditions: Multiple frees on same position → safe (idempotent)
Network Implications:
Server Authority: Typically called server-side
Broadcast: setVariable with true broadcasts to all clients
JIP Compatible: New players see correct availability state
Desync Risk: Low if server-managed
Concurrency: Multiple simultaneous calls safe (idempotent)

fn_garrisonReorg.sqf
Function Name: A3A/addons/core/functions/CREATE/fn_garrisonReorg.sqf

What it does: This function reorganizes a garrison unit array into organized squads with proper leadership and medical support. It takes an array of unit classnames (from a garrison) and redistributes them into squads with squad leaders and medics when possible. It's designed to maintain proper military structure within AI garrisons by ensuring each squad has leadership and medical support.

When/Why it's called: This is called when garrisons need to be restructured, typically when spawning or updating AI garrison units to ensure proper squad composition. It's used in garrison creation and reinforcement systems to maintain balanced and functional AI unit groups.

How it does that:

fn_garrisonReorg.sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (count _this <= A3A_rebelGarrisonGroupSize) exitWith {_this};
Explanation:

Includes the script component header for error handling and line number fixes
Checks if the input array (_this) has fewer or equal elements than the configured garrison group size (A3A_rebelGarrisonGroupSize)
If true, exits immediately returning the original array, as no reorganization is needed for small groups
fn_garrisonReorg.sqf

Apply
private _SLcount = {_x in FactionGet(all,"SquadLeaders")} count _this;
private _medCount = {_x in FactionGet(all,"Medics")} count _this;
if ((_SLcount == 0) and (_medCount == 0)) exitWith {_this};
Explanation:

Counts squad leaders in the input array using FactionGet(all,"SquadLeaders") to get valid squad leader classnames
Counts medics in the input array using FactionGet(all,"Medics") to get valid medic classnames
If no squad leaders AND no medics exist, exits returning the original array (no reorganization possible without leadership/medical units)
fn_garrisonReorg.sqf

Apply
private _pool = +_this;
private _slClass = "";
if (_slCount > 0) then
	{
	_slClass = _this select (_this findIf {_x in FactionGet(all,"SquadLeaders")});
	_pool = _pool - [_slClass];
	};
private _medClass = "";
if (_medCount > 0) then
	{
	_medClass = _this select (_this findIf {_x in FactionGet(all,"Medics")});
	_pool = _pool - [_medClass];
	};
if (_pool isEqualTo []) exitWith {_this};
Explanation:

Creates a working copy _pool of the input array
If squad leaders exist (_slCount > 0):
Finds the first squad leader class in the original array using findIf
Stores it as _slClass
Removes it from the working pool
If medics exist (_medCount > 0):
Finds the first medic class in the original array
Stores it as _medClass
Removes it from the working pool
If the pool is empty after removing leaders and medics, exits returning the original array (no regular units to distribute)
fn_garrisonReorg.sqf

Apply
private _result = [];
while {!(_pool isEqualTo [])} do
	{
	_squad = [];
	_countX = A3A_rebelGarrisonGroupSize;
	if (_slCount > 0) then
		{
		_squad pushBack _slClass;
		_slCount = _slCount - 1;
		_countX = _countX - 1;
		};
Explanation:

Initializes empty _result array to store reorganized squads
Enters a loop while there are still units in the pool
Creates an empty _squad array for the current squad
Sets _countX to the maximum squad size from config
If there are still squad leaders available:
Adds the squad leader class to the squad
Decrements the squad leader counter
Decrements the unit count for this squad (since leader occupies one slot)
fn_garrisonReorg.sqf

Apply
	if (_medCount > 0) then
		{
		_countX = _countX - 1;
		if (_countX > (count _pool)) then {_countX = count _pool};
		for "_i" from 1 to _countX do
			{
			_squad pushBack (_pool select 0);
			_pool deleteAt 0;
			};
		_squad pushBack _medClass;
		_medCount = _medCount - 1;
		}
	else
		{
		if (_countX > (count _pool)) then {_countX = count _pool};
		for "_i" from 1 to _countX do
			{
			_squad pushBack (_pool select 0);
			_pool deleteAt 0;
			};
		};
	_result append _squad;
	};
Explanation:

If medics are still available:
Decrements _countX for the medic slot
Adjusts _countX if remaining pool is smaller than planned squad size
Iterates to add regular units from pool to squad (removing them from pool)
Adds the medic to the squad
Decrements the medic counter
If no medics available:
Adjusts _countX if remaining pool is smaller than planned squad size
Iterates to add regular units from pool to squad
Appends the completed squad to the result array
Loop continues with remaining units
fn_garrisonReorg.sqf

Apply
if (_slCount > 0) then
	{
	for "_i" from 1 to _slCount do
		{
		_result pushBack _slClass;
		};
	};
if (_medCount > 0) then
	{
	for "_i" from 1 to _slCount do
		{
		_result pushBack _medClass;
		};
	};
_result
Explanation:

After the main loop, if there are remaining squad leaders (_slCount > 0):
Adds them individually to the result array
If there are remaining medics (_medCount > 0):
Adds them individually to the result array
Note: There's a bug here - it uses _slCount instead of _medCount in the loop condition
Returns the final reorganized array
Where it leads:

Functions it calls:

FactionGet(all,"SquadLeaders") - Retrieves squad leader classnames from faction definitions
FactionGet(all,"Medics") - Retrieves medic classnames from faction definitions
Functions that call this:

Not directly documented, but likely called by:
fn_createSDKgarrisons - When creating rebel garrisons
fn_createAIOutposts - When creating AI outpost garrisons
fn_createAIMilbase - When creating military base garrisons
fn_garrisonUpdate - When updating garrison compositions
Global variables it modifies:

None directly (doesn't modify global state)
Network implications:

Purely local computation with no network calls
Operates on array data passed as parameter
Edge cases handled:

Small arrays (≤ group size) - exits early
No leadership/medical units - exits early
Empty pool after removing leaders/medics - exits early
Running out of units during squad distribution - handles via pool size check
Technical details:

Uses array operations: findIf, pushBack, deleteAt, append
Works with classnames as strings
Maintains counts for leaders/medics to distribute them across squads
Creates copy of input array using +_this to avoid modifying original
fn_garrisonSize.sqf
Function Name: A3A/addons/core/functions/CREATE/fn_garrisonSize.sqf

What it does: Calculates the recommended number of garrison groups (squad-equivalents) for a given map marker based on the marker type (airfield, outpost, military base, or other), its size, and whether it's on the frontline. This determines how many AI units should defend or occupy a location.

When/Why it's called: This is called during garrison creation, reinforcement calculations, and when determining garrison capacity for locations. It's used by AI commanders and mission systems to decide how many units to spawn or maintain at strategic locations.

How it does that:

fn_garrisonSize.sqf

Apply
params ["_markerX", ["_ignoreFrontier", false]];

if ("carrier" in _markerX) exitWith { 0 };
Explanation:

Uses params to extract parameters with default value for _ignoreFrontier
If the marker contains "carrier" (aircraft carrier), returns 0 (carriers have no ground garrison)
Marker name should contain "carrier" string for this condition to trigger
fn_garrisonSize.sqf

Apply
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _frontierX = if (_ignoreFrontier) then { false } else { [_markerX] call A3A_fnc_isFrontline };
Explanation:

Calls A3A_fnc_sizeMarker to get the physical size (radius) of the marker
Determines if marker is on frontline:
If _ignoreFrontier is true, considers it not frontline
Otherwise, calls A3A_fnc_isFrontline to check
fn_garrisonSize.sqf

Apply
private _groups = 0;

switch (true) do {
    case (_markerX in airportsX): {
        _groups = 2 + round (_size/30);
        _groups = _groups min 11;
        if (_frontierX) then {_groups = _groups + 3};
    };
Explanation:

Initializes _groups counter
For airfield markers (in airportsX array):
Base groups: 2 + size/30 (round to integer)
Caps at maximum 11 groups
If on frontline: adds 3 extra groups
fn_garrisonSize.sqf

Apply
    case (_markerX in outposts): {
        _groups = 1 + round (_size/30);
        _buildings = nearestObjects [getMarkerPos _markerX,(["Land_TTowerBig_1_F","Land_TTowerBig_2_F","Land_Communication_F"]) + A3A_milBuildingWhitelist, _size];
        if (count _buildings > 0) then {_groups = _groups + 2};
        _groups = _groups min 7;
        if (_frontierX) then {_groups = _groups + 2};
    };
Explanation:

For outpost markers (in outposts array):
Base groups: 1 + size/30
Checks for communication towers/military buildings within range
If buildings found: adds 2 groups (more defensible)
Caps at 7 groups
If on frontline: adds 2 extra groups
fn_garrisonSize.sqf

Apply
    case (_markerX in milbases): {
        _groups = 1 + round (_size/30);
        _buildings = nearestObjects [getMarkerPos _markerX,(["Land_TTowerBig_1_F","Land_TTowerBig_2_F","Land_Communication_F"]) + A3A_milBuildingWhitelist, _size];
        if (count _buildings > 0) then {_groups = _groups + 2};
        _groups = _groups min 9;
        if (_frontierX) then {_groups = _groups + 2};
    };
Explanation:

For military base markers (in milbases array):
Similar to outposts but with different caps
Base groups: 1 + size/30
Checks for buildings, adds 2 if found
Caps at 9 groups
If on frontline: adds 2 extra groups
fn_garrisonSize.sqf

Apply
    default {
        _groups = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {1 + round (_size/45)} else {1 + round (_size/30)};
        _groups = _groups min 5;
        if (_frontierX) then {_groups = _groups + 1};
    };
};
Explanation:

Default case (towns, resources, etc.):
Checks who owns the marker via sidesX variable
If Occupants: 1 + size/45 (smaller garrisons)
Otherwise (Invaders/Rebels): 1 + size/30 (larger garrisons)
Caps at 5 groups
If on frontline: adds 1 extra group
fn_garrisonSize.sqf

Apply
4 * (_groups max 2);
Explanation:

Final calculation: 4 × (groups × 2 minimum)
Returns the total number of individual units (4 per group)
Ensures minimum of 2 groups (8 units) regardless of input
Where it leads:

Functions it calls:

A3A_fnc_sizeMarker - Gets physical size of marker
A3A_fnc_isFrontline - Checks if marker is on frontline
Functions that call this:

fn_createSDKgarrisons - Determines rebel garrison size
fn_createAIOutposts - Determines AI outpost garrison size
fn_createAIMilbase - Determines military base garrison size
fn_createAIAirports - Determines airfield garrison size
fn_garrisonUpdate - When calculating new garrison capacity
fn_replenishGarrison - When determining reinforcement needs
Global variables it references:

airportsX - Array of airfield markers
outposts - Array of outpost markers
milbases - Array of military base markers
A3A_milBuildingWhitelist - Whitelist of military building types
sidesX - Global side ownership variable
Occupants - Constant for occupant side
Invaders - Constant for invader side
Network implications:

Purely local calculation with no network calls
References global variables that should be synchronized
Edge cases handled:

Carrier markers (returns 0)
Markers with no building support
Different owner types affecting group counts
Frontline vs non-frontline variations
Size-based scaling with minimum/maximum caps
Technical details:

Uses switch statement for cleaner marker type handling
nearestObjects for building detection (with distance parameter)
min function for capping values
round for integer division results
References faction-specific building whitelist
fn_garrisonUpdate.sqf
Function Name: A3A/addons/core/functions/CREATE/fn_garrisonUpdate.sqf

What it does: Modifies garrison data for a specific marker and side, handling addition or removal of units. It's the core function for managing persistent garrison strength across the map, supporting single-unit additions, unit arrays, and removals with proper validation and synchronization.

When/Why it's called: This is called whenever garrisons need to be updated - when units are added through reinforcement, when units are removed through casualties, when capturing/losing locations, or when manually adjusting garrison strength. It ensures garrison data remains consistent and synchronized across the mission.

How it does that:

fn_garrisonUpdate.sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer) exitWith {};
Explanation:

Includes script component header for error handling
Server-only execution - exits on clients
Ensures garrison data is only modified by the server for consistency
fn_garrisonUpdate.sqf

Apply
//ModeX: -1 to remove 1 unbit (killed EHs etc). 1 add 1 single classname / object. 2 adds a hole array and admits classnames or objects
params ["_typeX", "_sideX", "_markerX", "_modeX"];
Explanation:

Documents parameter meaning in comment:
-1: Remove 1 unit (specified in _typeX)
1: Add 1 single unit/classname
2: Add multiple units (array in _typeX)
Uses params to extract all four required parameters
fn_garrisonUpdate.sqf

Apply
if (isNil "_typeX") exitWith {};
if (_typeX isEqualType []) then {
	if ((_typeX select 0) isEqualType objNull) then {
		private _subType = [];
		{
		    _subType pushBack (_x getVariable "unitType");
		} forEach _typeX;
		_typeX = _subType;
	};
} else {
	if (_typeX isEqualType objNull) then {_typeX = _typeX getVariable "unitType"};
};
Explanation:

Checks if _typeX is nil and exits if so
If _typeX is an array:
If first element is an object (objNull comparison):
Creates empty _subType array
Iterates through objects, extracting "unitType" variable from each
Replaces _typeX with the array of classnames
Else if _typeX is a single object:
Extracts "unitType" variable to get classname
fn_garrisonUpdate.sqf

Apply
if !(_markerX isEqualType "") exitWith {
	Error_1("Failed to update Garrison at Position:%1", _this);
};
Explanation:

Validates _markerX is a string
If not, logs error and exits
Ensures marker name is properly formatted for global variable storage
fn_garrisonUpdate.sqf

Apply
_exit = false;
{
    if (isNil _x) exitWith {_exit = true}
} forEach ["_typeX","_sideX","_markerX","_modeX"];
if (_exit) exitWith {
    Error_1("Failed to update Garrison with params:%1",_this);
};
Explanation:

Checks if any parameter is nil using isNil
Sets _exit flag if any parameter is missing
Exits with error message if validation fails
fn_garrisonUpdate.sqf

Apply
waitUntil {!garrisonIsChanging};
garrisonIsChanging = true;
Explanation:

Uses waitUntil to ensure no concurrent garrison modifications
Sets global flag garrisonIsChanging to prevent race conditions
Critical for thread safety when multiple systems update garrisons simultaneously
fn_garrisonUpdate.sqf

Apply
if ((_sideX == Occupants) and (!(sidesX getVariable [_markerX,sideUnknown] == Occupants))) exitWith {garrisonIsChanging = false};
if ((_sideX == Invaders) and (!(sidesX getVariable [_markerX,sideUnknown] == Invaders))) exitWith {garrisonIsChanging = false};
if ((_sideX == teamPlayer) and (!(sidesX getVariable [_markerX,sideUnknown] == teamPlayer))) exitWith {garrisonIsChanging = false};
Explanation:

Validates that the side matches the marker's current ownership
Uses sidesX global variable to check marker ownership
Exits early (releasing lock) if side mismatch prevents update
Prevents updating garrisons for sides that don't own the location
fn_garrisonUpdate.sqf

Apply
private _garrison = [];
_garrison = _garrison + (garrison getVariable [_markerX,[]]);
if (_modeX == -1) then {
	for "_i" from 0 to (count _garrison -1) do {
		if (_typeX == (_garrison select _i)) exitWith {_garrison deleteAt _i};
	};
} else {
	if (_modeX == 1) then {_garrison pushBack _typeX} else {_garrison append _typeX};
};
Explanation:

Gets current garrison array for marker (empty array if none exists)
Mode -1 (Remove): Searches for matching unit and removes first occurrence
Mode 1 (Add single): Appends single unit/classname
Mode 2 (Add array): Appends entire array of units/classnames
fn_garrisonUpdate.sqf

Apply
if (isNil "_garrison") exitWith {garrisonIsChanging = false};
garrison setVariable [_markerX,_garrison,true];
if (_sideX == teamPlayer) then {[_markerX] call A3A_fnc_mrkUpdate};
garrisonIsChanging = false;
Explanation:

Final safety check if garrison became nil
Stores updated garrison in garrison namespace (JIP-synchronized via true parameter)
If side is rebel (teamPlayer), updates marker visuals via A3A_fnc_mrkUpdate
Releases lock by setting garrisonIsChanging = false
Where it leads:

Functions it calls:

A3A_fnc_mrkUpdate - Updates marker visuals for rebel-held locations
Functions that call this:

fn_addGarrison - Adds garrison units
fn_replenishGarrison - Refills garrison after casualties
fn_createSDKgarrisons - Initializes rebel garrisons
fn_createAIOutposts - Initializes AI garrisons
fn_enemyUnitKilledEH - Removes killed units from garrison
fn_vehicleDeletedEH - Removes destroyed vehicles from garrison
fn_convoyArrival - Updates garrisons after convoy delivery
fn_garrisonAdd - Reinforcement system
Global variables it modifies:

garrison - Namespace storing marker → unit array mappings
garrisonIsChanging - Lock flag for concurrency control
sidesX - Read only (checked for ownership)
Network implications:

Server-only, prevents client desync
JIP-synchronized storage (true parameter in setVariable)
When side is rebel, triggers A3A_fnc_mrkUpdate which may update networked markers
Creates race condition protection via garrisonIsChanging flag
Edge cases handled:

Nil parameter validation
Type conversion (object → classname)
Marker ownership verification
Concurrent modification prevention
Empty garrison initialization
Single vs array input handling
Technical details:

Uses global garrison namespace for persistence
Array modification via pushBack, append, deleteAt
String comparison for unit removal
Synchronized via publicVariable equivalent in setVariable
Critical section implementation via flag-based locking
fn_groupDespawner.sqf
Function Name: A3A/addons/core/functions/CREATE/fn_groupDespawner.sqf

What it does: Manages the despawning of AI groups when they are no longer needed, typically when far from players or after combat ends. It monitors group state and cleans up units, vehicles, and groups when conditions are met, preventing performance issues from lingering AI.

When/Why it's called: This is called when an AI group is created, adding a despawner handle to monitor it. It runs continuously until conditions are met for despawning, then cleans up. Used by spawn systems to manage AI lifecycle and prevent performance degradation from abandoned units.

How it does that:

fn_groupDespawner.sqf

Apply
params ["_group", ["_checkNonRebel", false]];

if (!isNil { _group getVariable "A3A_despawnerHandle" }) exitWith {};
_group setVariable ["A3A_despawnerHandle", _thisScript];			// only meaningful locally
Explanation:

Extracts group parameter and optional _checkNonRebel flag
Checks if group already has a despawner handle (to avoid duplicate handles)
If already handled, exits immediately
Otherwise, sets despawner handle variable to current script instance
Note: setVariable without public parameter is local-only (not networked)
fn_groupDespawner.sqf

Apply
if (count units _group == 0) exitWith { deleteGroup _group };
Explanation:

If group has no units remaining, immediately deletes the empty group
Early exit to avoid unnecessary monitoring
fn_groupDespawner.sqf

Apply
// Strip spawner status. If the group is waiting to despawn then it's no longer active
{
	if (_x getVariable ["spawner", false]) then { _x setVariable ["spawner", nil, true] };
} forEach units _group;
Explanation:

Iterates through all units in the group
For units with "spawner" variable set to true:
Removes the "spawner" variable (sets to nil)
Publicly synchronizes the change (true parameter)
This marks units as no longer active for spawning systems
fn_groupDespawner.sqf

Apply
private _eny1 = Occupants;
private _eny2 = Invaders;
private _side = side _group;
if (_side == Occupants) then {_eny1 = teamPlayer} else {if (_side == Invaders) then {_eny2 = teamPlayer}};
Explanation:

Sets up enemy side constants based on group side
For Occupant groups: enemy is teamPlayer (rebels)
For Invader groups: enemy is teamPlayer (rebels)
For other groups (rebels): enemy1 and enemy2 remain as Occupants/Invaders
fn_groupDespawner.sqf

Apply
private _fnc_distCheckEnemy = {
	params ["_unit"];
	if !([distanceSPWN,1,_unit,_eny1] call A3A_fnc_distanceUnits) exitWith { true };
	if !([distanceSPWN,1,_unit,_eny2] call A3A_fnc_distanceUnits) exitWith { true };
	false;
};

private _fnc_distCheckRebel = {
	params ["_unit"];
	if !([distanceSPWN,1,_unit,teamPlayer] call A3A_fnc_distanceUnits) exitWith { true };
	false;
};

_fnc_distCheck = if (_checkNonRebel) then {_fnc_distCheckEnemy} else {_fnc_distCheckRebel};
Explanation:

Defines _fnc_distCheckEnemy: Checks distance to both enemy sides (if checking non-rebel groups)
Defines _fnc_distCheckRebel: Checks distance to rebel side only
Selects appropriate distance check function based on _checkNonRebel flag
Uses A3A_fnc_distanceUnits to check if units are within distanceSPWN range
fn_groupDespawner.sqf

Apply
while {count units _group > 0} do
{
	private _leader = objNull;
	waitUntil {
		sleep 10;
		_leader = leader _group;
		isNull _leader || {[_leader] call _fnc_distCheck};
	};
	if !(isNull _leader) then
	{
		private _pos = position _leader;
		{
			if (_x distance2d _pos < 100) then {
				if (vehicle _x != _x) then { deleteVehicle (vehicle _x) };
				deleteVehicle _x;
			};
		} forEach units _group;
	};
};
Explanation:

Main monitoring loop (runs while group has units)
Wait condition:
Sleeps 10 seconds between checks
Waits until leader is null OR distance check returns true
Distance check true means: not within detection range of enemies
Despawning logic:
If leader exists (not null):
Gets leader position
Iterates through all units in group
Deletes units within 100m of leader position
If unit is in a vehicle, deletes the vehicle too
Only deletes nearby units (not necessarily the entire group at once)
fn_groupDespawner.sqf

Apply
deleteGroup _group;
Explanation:

After loop exits (all units deleted), deletes the group itself
Final cleanup step
Where it leads:

Functions it calls:

A3A_fnc_distanceUnits - Checks if units are within detection range
Functions that call this:

fn_createAttackVehicle - Spawns and monitors attack vehicles
fn_spawnGroup - Spawns AI groups with despawner
fn_spawnVehicle - Spawns vehicles with crew despawning
fn_createAIOutposts - Monitors AI outpost garrisons
fn_createAIMilbase - Monitors military base garrisons
fn_createAIAirports - Monitors airfield garrisons
fn_invaderPunish - Despawns invader punishment units
Global variables it references:

distanceSPWN - Spawn/despawn distance threshold
Occupants - Constant for occupant side
Invaders - Constant for invader side
teamPlayer - Constant for rebel side
Global variables it modifies:

None (removes spawner variable from units, but that's a unit-local change)
Network implications:

Publicly synchronizes "spawner" variable removal
Despawning logic is local to where script runs (typically server)
Group deletion affects all clients (group is global)
Edge cases handled:

Duplicate despawner handles (prevents multiple monitors)
Empty groups (immediate deletion)
Leader becoming null during monitoring
Units in vehicles (deletes vehicle with unit)
Distance-based despawning with configurable threshold
Technical details:

Uses waitUntil with sleep for periodic checking
Distance checks via A3A_fnc_distanceUnits
Deletes vehicles if unit is inside one
Local-only script execution (runs where called)
Cleans up spawner status to prevent re-spawning
fn_invaderPunish.sqf
Function Name: A3A/addons/core/functions/CREATE/fn_invaderPunish.sqf

What it does: Creates a large-scale invader (CSAT) punishment attack against a city. This is a major AI-driven assault that spawns attacking forces, artillery support, civilian defenders, and handles the attack lifecycle including win/loss conditions, rewards, and city destruction logic. It's a scripted event that significantly impacts gameplay and city state.

When/Why it's called: Called when the game decides to punish rebels for aggressive actions against the faction. Typically triggered by AI decision logic, timing systems, or specific game conditions. It's a major event that spawns significant forces and requires player defense.

How it does that:

fn_invaderPunish.sqf

Apply
/*
Maintainer: John Jordan
    Create invader city punishment attack

Scope: Server, although written to work on HCs
Environment: Scheduled, should be spawned

Arguments:
    <STRING> Destination marker (should be town)
    <STRING> Origin marker (should be airbase)
    <SCALAR> Optional, delay in seconds before sending vehicles (Default: Auto-calculated)
*/
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Explanation:

Includes documentation header
Includes script component and line number fixes
Documents that function is server/HC scope and should be spawned (scheduled)
fn_invaderPunish.sqf

Apply
private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];

if (_lowCiv) exitWith {};
// if (_civNonHuman) exitWith {};
Explanation:

Checks if civilian faction has "attributeLowCiv" flag (reduced civilian population)
Checks if civilian faction is non-human (zombies, etc.)
Exits if low civilian population (punishment wouldn't make sense)
Non-human check is commented out but could be used to prevent punishment vs non-human factions
fn_invaderPunish.sqf

Apply
if (!isServer) exitWith { Error("Server-only function miscalled") };
Explanation:

Ensures function only runs on server
Logs error if called elsewhere
fn_invaderPunish.sqf

Create file
if (areInvadersDefeated) exitWith {
    Info("Invaders had been defeated earlier, aborting punishment.");
};
Explanation:

Checks global areInvadersDefeated flag
Exits if invaders have already been defeated (no punishment possible)
fn_invaderPunish.sqf

Apply
params ["_mrkDest", "_mrkOrigin", "_delay"];

ServerInfo_2("Launching CSAT Punishment Against %1 from %2", _mrkDest, _mrkOrigin);
Explanation:

Extracts parameters: destination marker, origin marker, optional delay
Logs start of punishment attack with server info message
fn_invaderPunish.sqf

Apply
forcedSpawn pushBack _mrkDest; publicVariable "forcedSpawn";
Explanation:

Adds destination marker to forcedSpawn array
Publicly synchronizes to all clients
Prevents fast travel to/from the destination during attack
fn_invaderPunish.sqf

Apply
private _posDest = getMarkerPos _mrkDest;
private _posOrigin = getMarkerPos _mrkOrigin;
private _size = [_mrkDest] call A3A_fnc_sizeMarker;
Explanation:

Gets position of destination and origin markers
Calculates size of destination marker for scaling
fn_invaderPunish.sqf

Apply
private _nameDest = [_mrkDest] call A3A_fnc_localizar;
private _taskId = "invaderPunish" + str A3A_taskCount;
[[teamPlayer,civilian,Occupants],_taskId,[format [localize "STR_invaderPunish_desc",_nameDest,FactionGet(inv,"name")],format [localize "STR_invaderPunish_task",FactionGet(inv,"name")],_mrkDest],_posDest,false,0,true,"Defend",true] call BIS_fnc_taskCreate;
[_taskId, "invaderPunish", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Explanation:

Gets localized name of destination city
Creates unique task ID using global counter
Creates defensive task using BIS function for all relevant sides
Updates task state to "CREATED" via remote execution to clients (parameter 2 = server-to-clients)
fn_invaderPunish.sqf

Apply
if (isNil "_delay") then {
    _delay = 300 + 60 * (markerPos "Synd_HQ" distance2d _posDest) / 2000;            // +1 min per 2km
};
Explanation:

If no delay specified, auto-calculates based on distance from HQ
Base delay of 300 seconds (5 minutes)
Adds 60 seconds per 2km distance from HQ
This scales attack timing based on distance
fn_invaderPunish.sqf

Apply
private _vehCount = round (2 + random 1 + A3A_balancePlayerScale);
Explanation:

Calculates vehicle count for attack force
Base: 2-3 vehicles (2 + random 1)
Scaled by A3A_balancePlayerScale (player count adjustment)
fn_invaderPunish.sqf

Apply
private _data = [Invaders, _mrkOrigin, _mrkDest, "attack", _vehCount, _delay, ["airboost", "specops"]] call A3A_fnc_createAttackForceMixed;
_data params ["_resources", "_vehicles", "_crewGroups", "_cargoGroups"];
Explanation:

Calls A3A_fnc_createAttackForceMixed to create attacking force
Parameters: side, origin, destination, attack type, vehicle count, delay, modifiers
Receives data about created resources, vehicles, crew groups, and cargo groups
Uses "airboost" and "specops" modifiers for enhanced air support and special ops
fn_invaderPunish.sqf

Apply
A3A_supportStrikes pushBack [Invaders, "TROOPS", markerPos _mrkDest, time + 1800, 1800, _resources];
Explanation:

Adds this attack to A3A_supportStrikes array for tracking
Includes: side, type, position, expiration time, duration, resources
Uses 1800 seconds (30 minutes) duration
fn_invaderPunish.sqf

Apply
private _artyTargPos = _posDest getPos [_size/3, random 360];
["artillery", "_side", "_target", "_resPool", "_precision", "_reveal", "_delay"];
[Invaders, _artyTargPos, "attack", 0, 0, 0] call A3A_fnc_requestArtillery;
Explanation:

Calculates artillery target position (60% of marker radius from center, random direction)
Calls A3A_fnc_requestArtillery with invader side
Precision 0, reveal 0, delay 0 (immediate artillery support)
fn_invaderPunish.sqf

Apply
private _numCiv = (server getVariable _mrkDest) select 0;
_numCiv = 4 + round sqrt (_numCiv);
if (_numCiv > 30) then {_numCiv = 30};
Explanation:

Gets city population from server variable (first element of array)
Calculates civilian defenders: 4 + sqrt(population) (prevents excessive scaling)
Caps at maximum 30 civilians
fn_invaderPunish.sqf

Apply
private _civilians = [];
private _civGroups = [];
private _civWeapons = unlockedsniperrifles + unlockedmachineguns + unlockedshotguns + unlockedrifles + unlockedsmgs + unlockedhandguns;
Explanation:

Initializes arrays for civilian units and groups
Creates weapon pool by concatenating all unlocked weapon arrays
This gives civilians access to any unlocked rebel weapons
fn_invaderPunish.sqf

Create file
while {count _civilians < _numCiv} do
{
    private _groupCivil = createGroup teamPlayer;
    _civGroups pushBack _groupCivil;
    private _pos = while {true} do {
        private _pos = _posDest getPos [random _size / 2,random 360];
        if (!surfaceIsWater _pos) exitWith { _pos };
    };
    for "_i" from 1 to (4 min (_numCiv - count _civilians)) do
    {
        private _identity = [A3A_faction_civ, FactionGet(reb, "unitUnarmed")] call A3A_fnc_createRandomIdentity;
        private _civ = [_groupCivil, FactionGet(reb, "unitUnarmed"), _pos, [], 0, "NONE", _identity] call A3A_fnc_createUnit;
        [_civ, createHashMapFromArray [["face", selectRandom (A3A_faction_civ get "faces")], ["speaker", "NoVoice"]]] call A3A_fnc_setIdentity;
        _civ forceAddUniform selectRandom (A3A_faction_civ get "uniforms");
        _civ addHeadgear selectRandom (A3A_faction_civ get "headgear");
        [_civ, selectRandom _civWeapons, 5, 0] call BIS_fnc_addWeapon;
        _civ setSkill 0.5;
        _civilians pushBack _civ;
    };
    [_groupCivil, "Patrol_Defend", 0, 100, -1, true, _pos, false] call A3A_fnc_patrolLoop;
};
Explanation:

Creates groups: Creates teamPlayer (rebel) groups for civilians
Position finding: Finds dry land position within marker radius
Unit creation loop: Creates up to 4 units per group (prevents large groups)
Identity: Creates random identity for each civilian
Custom identity: Sets face (random from faction) and no voice
Equipment: Forces civilian uniform, adds headgear, adds random unlocked weapon
Skills: Sets skill level to 0.5
Patrol: Sets group to patrol/defend around spawn position
fn_invaderPunish.sqf

Apply
private _missionExpireTime = time + 2400;
private _missionMinTime = time + 600;
private _soldiers = [];
{ _soldiers append units _x } forEach _cargoGroups;
Explanation:

Sets expiration time (2400s = 40 minutes)
Sets minimum mission time (600s = 10 minutes)
Collects all soldiers from cargo groups into single array
fn_invaderPunish.sqf

Apply
waitUntil {
    sleep 10;
//    Debug_4("Soldiers %1 initial, %2 active. Civs %3 initial, %4 active", count _soldiers, {_x call A3A_fnc_canFight} count _soldiers, count _civilians, {alive _x} count _civilians);
    ({_x call A3A_fnc_canFight} count _soldiers < count _soldiers / 3)
    or (time > _missionMinTime and ({alive _x} count _civilians < count _civilians / 4))
    or (time > _missionExpireTime)
};
Explanation:

Waits for termination conditions with 10-second sleep
Termination conditions:
Less than 1/3 of soldiers can fight (decimated)
OR: Minimum time passed AND less than 1/4 civilians alive (if rebels fail to protect)
OR: Mission expired (time limit reached)
fn_invaderPunish.sqf

Create file
private _fnc_adjustNearCities = {
    params ["_position", "_maxSupport", "_maxDist"];
    {
        private _dist = getMarkerPos _x distance2d _position;
        if (_dist > _maxDist) then { continue };
        private _suppChange = linearConversion [0, _maxDist, _dist, _maxSupport, 0, true];
        [0,_suppChange,_x,false] spawn A3A_fnc_citySupportChange;		// don't scale this by pop
    } forEach citiesX;
};
Explanation:

Defines closure function for adjusting nearby city support
For each city in citiesX:
Calculates distance from attack position
Skips if beyond max distance
Calculates support change using linear conversion (more effect closer to target)
Spawns A3A_fnc_citySupportChange to modify city support (non-population scaled)
fn_invaderPunish.sqf

Apply
if (({_x call A3A_fnc_canFight} count _soldiers < count _soldiers / 3) or (time > _missionExpireTime)) then {
    Info_1("Rebels defeated a punishment attack against %1", _mrkDest);
    [_taskId, "invaderPunish", "SUCCEEDED"] call A3A_fnc_taskSetState;
    [_posDest, 30, 3000] call _fnc_adjustNearCities;

    [Occupants, -10, 90] remoteExec ["A3A_fnc_addAggression",2];
    {
        [round (7*tierWar), _x] call A3A_fnc_addScorePlayer;
        [round (75*tierWar), _x] call A3A_fnc_addMoneyPlayer;
    } forEach (call SCRT_fnc_misc_getRebelPlayers);

    [10,theBoss] call A3A_fnc_addScorePlayer;
    [round (100*((tierWar/3) max 1)), theBoss, true] call A3A_fnc_addMoneyPlayer;
} else {
Explanation:

If rebels won (soldiers decimated OR time expired):
Logs victory
Sets task state to SUCCEEDED
Increases support for nearby cities (+30 max at center)
Reduces aggressor aggression (-10 for 90 seconds)
Gives all rebel players score (7war tier) and money (75war tier)
Gives extra rewards to "theBoss" (faction leader)
fn_invaderPunish.sqf

Create file
    Info_1("Rebels lost a punishment attack against %1", _mrkDest);
    [_taskId, "invaderPunish", "FAILED"] call A3A_fnc_taskSetState;
    [_posDest, -30, 3000] call _fnc_adjustNearCities;

    // Invaders pay extra to destroy a city
    private _citypop = (server getVariable _mrkDest) select 0;
    [-4 * _citypop * A3A_balancePlayerScale, Invaders, "attack"] remoteExec ["A3A_fnc_addEnemyResources", 2];

    destroyedSites = destroyedSites + [_mrkDest];
    publicVariable "destroyedSites";
    private _mineTypes = A3A_faction_inv get "minefieldAPERS";
    for "_i" from 1 to 60 do {
        private _mineX = createMine [selectRandom _mineTypes,_posDest,[],_size];
        Invaders revealMine _mineX;
    };
    [_mrkDest] call A3A_fnc_destroyCity;
    // Putting this stuff here is a bit gross, but currently there's no cityFlip function. Usually done by resourceCheck.
    sidesX setVariable [_mrkDest, Invaders, true];
    garrison setVariable [_mrkDest, [], true];
    [_mrkDest] call A3A_fnc_mrkUpdate;
};
Explanation:

If rebels lost:
Logs defeat
Sets task state to FAILED
Decreases support for nearby cities (-30 max at center)
Invaders pay penalty for city destruction (scaled by population and player count)
Adds city to destroyed sites array and publicly synchronizes
Creates 60 anti-personnel mines (revealed to invaders)
Calls A3A_fnc_destroyCity to handle city destruction
Updates side ownership to Invaders
Clears garrison for the city
Updates marker visuals
fn_invaderPunish.sqf

Apply
sleep 60;
[_taskId, "invaderPunish", 0] spawn A3A_fnc_taskDelete;
Explanation:

Waits 60 seconds
Deletes the task after grace period
fn_invaderPunish.sqf

Apply
bigAttackInProgress = false; publicVariable "bigAttackInProgress";
forcedSpawn = forcedSpawn - [_mrkDest]; publicVariable "forcedSpawn";
Explanation:

Resets bigAttackInProgress flag and publicly synchronizes
Removes destination from forcedSpawn array and publicly synchronizes
Re-enables fast travel to/from destination
fn_invaderPunish.sqf

Apply
{ [_x] spawn A3A_fnc_VEHDespawner } forEach _vehicles;
{ [_x] spawn A3A_fnc_enemyReturnToBase } forEach _crewGroups + _cargoGroups;
Explanation:

Spawns despawner for attack vehicles
Returns enemy groups to base via A3A_fnc_enemyReturnToBase
fn_invaderPunish.sqf

Create file
waitUntil {sleep 5; (spawner getVariable _mrkDest == 2)};
{deleteVehicle _x} forEach _civilians;
{deleteGroup _x} forEach _civGroups;
Explanation:

Waits until marker is despawned (spawner variable = 2)
Deletes all civilian units and groups after despawn
Cleans up civilian defenders when no longer needed
Where it leads:

Functions it calls:

A3A_fnc_sizeMarker - Gets marker size
A3A_fnc_localizar - Localizes marker name
BIS_fnc_taskCreate - Creates mission task
A3A_fnc_taskUpdate - Updates task state
A3A_fnc_createAttackForceMixed - Creates attacking force
A3A_fnc_requestArtillery - Requests artillery support
A3A_fnc_createRandomIdentity - Creates civilian identities
A3A_fnc_createUnit - Creates civilian units
A3A_fnc_setIdentity - Sets civilian appearance
A3A_fnc_patrolLoop - Sets civilian patrol behavior
A3A_fnc_canFight - Checks soldier combat status
A3A_fnc_citySupportChange - Modifies city support
A3A_fnc_addAggression - Modifies aggression
A3A_fnc_addScorePlayer - Awards player score
A3A_fnc_addMoneyPlayer - Awards player money
SCRT_fnc_misc_getRebelPlayers - Gets list of rebel players
A3A_fnc_destroyCity - Destroys city
A3A_fnc_mrkUpdate - Updates marker visuals
A3A_fnc_VEHDespawner - Despawns vehicles
A3A_fnc_enemyReturnToBase - Returns enemies to base
Functions that call this:

Not directly documented in provided files, but likely called by:
AI decision systems for punishment
Mission scripting events
Timing-based triggers for faction responses
Global variables it modifies:

forcedSpawn - Prevents fast travel (added/removed)
A3A_supportStrikes - Tracks support strikes
bigAttackInProgress - Prevents multiple major attacks
destroyedSites - Tracks destroyed cities
sidesX - Updates city ownership
garrison - Clears city garrison
spawner - Monitors despawn state
Network implications:

Heavy network usage: tasks, spawns, resource updates, public variables
Synchronizes across all clients via remoteExec calls
Uses publicVariable for global state changes
Spawns tasks and updates for all players
Makes economic adjustments for all players
Edge cases handled:

Low civilian population (exits early)
Invaders already defeated (exits early)
No delay specified (auto-calculates)
City already destroyed (prevents double destruction)
Fast travel prevention during attack
Minimum mission time enforcement
Mission expiration
Civilian unit cap (max 30)
Distance-based effect scaling
Technical details:

Uses getOrDefault for optional faction attributes
Scheduled execution (spawned)
Heavy use of array concatenation for weapon pools
Modular function design with closure for city support adjustment
Linear conversion for distance-based effects
Multiple publicVariable calls for synchronization
Cleaner design with attack force creation separated
Uses spawn for non-blocking mission cleanup

Function: fn_milBuildings.sqf
Function Name: A3A\addons\core\functions\CREATE\fn_milBuildings.sqf

What it does: This function is responsible for spawning a garrison at a given military marker (_markerX). It identifies compatible military buildings within a specified radius (_size), spawns static weapons (MGs, AT, AA) and units at predefined positions within those buildings, and also spawns attack helicopters for airbases and milbases. It returns the created group, spawned vehicles, soldiers, and used spawn positions.

When/Why it's called: It is called during the mission spawning process when a military marker (like a milbase, outpost, or airport) needs to be populated with AI units. It is typically called by A3A_fnc_createAIMilbase or similar functions that manage the initial setup of enemy AI locations.

How it does that:

1. Parameter Extraction and Initial Validation: The function starts by extracting the marker, position, size, side, and frontier status from the arguments. It then finds military buildings in the area and checks if any were found.

fn_milBuildings.sqf (1-19)

Apply
_markerX = _this select 0;
_positionX = getMarkerPos _markerX;
_size = _this select 1;
_buildings = nearestObjects [_positionX, A3A_milBuildingWhitelist, _size, true];
_buildings = _buildings inAreaArray _markerX;

if (count _buildings == 0) exitWith {[grpNull,[],[]]};

_sideX = _this select 2;
private _faction = Faction(_sideX);
_frontierX = _this select 3;
Extraction: Reads input parameters: marker name (_markerX), spawn radius (_size), side (_sideX), and frontier flag (_frontierX).
Building Search: Uses nearestObjects with a whitelist A3A_milBuildingWhitelist to find relevant military structures. The second filter (_buildings inAreaArray _markerX) ensures only buildings strictly inside the marker area are used.
Error Handling: If no buildings are found, it returns grpNull and empty arrays, terminating early.
2. Helicopter Spawning: A new system is implemented to spawn attack helicopters on airbases and milbases. It populates a list of eligible helicopter types based on the marker type.

fn_milBuildings.sqf (31-60)

Apply
private _groupX = createGroup _sideX;
private _typeUnit = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;

//New system to place helis, does not care about heli types currently
private _helicopterTypes = [];
switch (true) do {
    case (_markerX in milbases): {
        _helicopterTypes append (_faction get "vehiclesHelisTransport");
        _helicopterTypes append (_faction get "vehiclesHelisLight");
        _helicopterTypes append (_faction get "vehiclesHelisLightAttack");
    };
    case (_markerX in airportsX): {
        _helicopterTypes append (_faction get "vehiclesHelisTransport");
        _helicopterTypes append (_faction get "vehiclesHelisLight");
        _helicopterTypes append (_faction get "vehiclesHelisLightAttack");
        _helicopterTypes append (_faction get "vehiclesHelisAttack");
    };
    default {
        _helicopterTypes append (_faction get "vehiclesHelisLight");
    };
};
private _count = 1 + round (random 3);
while {_count > 0} do
{
    if (_helicopterTypes isEqualTo []) exitWith {};
    _typeVehX = selectRandom _helicopterTypes;
    private _spawnParameter = [_markerX, "Heli"] call A3A_fnc_findSpawnPosition;
    if !(_spawnParameter isEqualType []) exitWith {};       // out of spawn places
    _spawnsUsed pushBack _spawnParameter#2;
    _veh = createVehicle [_typeVehX, (_spawnParameter select 0), [],0, "CAN_COLLIDE"];
    _veh setDir (_spawnParameter select 1);
    _vehiclesX pushBack _veh;
    _count = _count - 1;
};
Group Creation: Creates a new group _groupX for the side.
Helicopter Selection:
Checks global arrays milbases and airportX (from core\init\initVarCommon.sqf) to determine the marker type.
Appends transport, light, and attack helicopters from the faction's defined lists to _helicopterTypes.
Spawning Loop:
Spawns between 1 and 4 helicopters.
Calls A3A_fnc_findSpawnPosition to get a valid position and direction for a helicopter.
_spawnsUsed is updated to prevent future overlaps.
Creates the vehicle and adds it to _vehiclesX.
3. Static Weapon Spawning Logic: Two helper functions are defined to handle the creation of static weapons and their crew (_fnc_spawnStatic) and static riflemen (_fnc_spawnStaticUnit).

fn_milBuildings.sqf (62-90)

Apply
private _fnc_spawnStatic = {
    params ["_type", "_pos", "_dir"];
    private _veh = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
    if (!isNil "_dir") then { _veh setDir _dir };
    private _unit = [_groupX, _typeUnit, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    _unit moveInGunner _veh;
    [_unit,_markerX] call A3A_fnc_NATOinit;
    _soldiers pushBack _unit;
    _vehiclesX pushBack _veh;
    _veh;
};

private _fnc_spawnStaticUnit = {
    params ["_type", "_pos", "_dir"];
	private _unit = [_groupX, _type, _pos, [], 0, "NONE"] call A3A_fnc_createUnit;
    if (!isNil "_dir") then { _unit setDir _dir };
    _unit disableAI "PATH"; //block moving
    _unit setUnitPos "UP"; //force standing
    [_unit,_markerX] call A3A_fnc_NATOinit;
    _unit setPosATL _pos;
    _soldiers pushBack _unit;
    _unit;
};
_fnc_spawnStatic: Creates a vehicle, then a unit (using the faction's static crew unit type), moves the unit into the gunner seat, initializes the unit via A3A_fnc_NATOinit, and updates tracking arrays.
_fnc_spawnStaticUnit: Similar but for units that stand alone (e.g., marksmen, guards). It disables their pathfinding AI and forces them to stand.
4. Building Iteration and Static Placement: The code iterates over every found building. For each, it checks the building type and spawns the appropriate static weapon based on hardcoded positions.

Key Examples of Building Handling:

Cargo Patrol Towers (MG):

fn_milBuildings.sqf (112-124)

Apply
if 	((_typeB == "Land_Cargo_Patrol_V1_F") or ...) exitWith
{
    private _type = selectRandom (_faction get "staticMGs");
    private _dir = (getDir _building) - 180;
    private _zpos = AGLToASL (_building buildingPos 1);
    private _pos = _zpos getPos [1.5, _dir];
    _pos = ASLToATL ([_pos select 0, _pos select 1, _zpos select 2]);
    [_type, _pos, _dir] call _fnc_spawnStatic;
};
Uses buildingPos 1 (a coordinate within the model).
Adjusts height and direction relative to the building.
Calls the helper function to spawn MG and crew.
Cargo Tower (Multiple MGs):

fn_milBuildings.sqf (167-193)

Apply
if 	((_typeB == "Land_Cargo_Tower_V1_F") ... ) exitWith
{
    // ... spawn logic for 3 MGs ...
    [_type, _pos, _Tdir] call _fnc_spawnStatic;
    sleep 0.5;
    // ... second MG ...
    sleep 0.5;
    // ... third MG ...
};
Spawns 3 static MGs at different buildingPos indices (11, 13, 16).
Uses sleep 0.5 to stagger spawn times (likely to avoid physics collisions or engine issues).
Bunkers and Fortifications:

fn_milBuildings.sqf (248-258)

Apply
if (_typeB in ["Land_BagBunker_Large_F", ...]) exitWith {
    private _type = selectRandom (_faction get "staticMGs");
    private _dir = (getDir _building) - 180;
    private _zpos = AGLToASL (_building buildingPos 4);
    private _pos = _zpos getPos [2, _dir];
    _pos = ASLToATL ([_pos select 0, _pos select 1, _zpos select 2]);
    private _static = [_type, _pos, _dir] call _fnc_spawnStatic;
    _static setPos _pos;
};
Handles various addon bunker models.
Uses modelToWorld for specific positioning (e.g., Land_SPE_Sandbag_Nest).
AA Statics: Similar blocks exist for Land_Cargo_HQ and Land_Radar types, spawning staticAA weapons.

5. Marksmen and Guard Spawning: After static weapons, the script iterates again to spawn specific unit types (Marksmen in sniper trees, Guards in towers).

fn_milBuildings.sqf (372-470)

Apply
//Spawning Marksmen
for "_i" from 0 to (count _buildings) - 1 do { ... }

//Spawning Riflemen
for "_i" from 0 to (count _buildings) - 1 do {
    if (spawner getVariable _markerX == 2) exitWith {};
    private _building = _buildings select _i;
    private _typeB = typeOf _building;
    
    call {
        if (isObjectHidden _building) exitWith {};
        if (_typeB isEqualTo "Land_GuardTower_01_F") exitWith {
            private _type = selectRandom ([_faction, "unitTierTower"] call SCRT_fnc_unit_flattenTier);
            // ... position calculation ...
            private _unit = [_type, _pos, _dir] call _fnc_spawnStaticUnit;
        };
        // ... more tower types ...
    };
};
Marksmen: Checks for Land_vn_o_snipertree types. Spawns the unit type defined in _faction get "unitMarksman".
Riflemen: Checks for guard tower types (Land_GuardTower_01_F, etc.). Fetches unit tier using SCRT_fnc_unit_flattenTier to determine appropriate guard unit type.
Exit Conditions: spawner getVariable _markerX == 2 checks if the marker has been despawned during execution.
6. Return Value: Returns an array containing the group, array of vehicles, array of soldiers, and array of used spawn positions.

fn_milBuildings.sqf (471)

Apply
[_groupX,_vehiclesX,_soldiers,_spawnsUsed]
Where it leads:

Functions Called:

A3A_fnc_findSpawnPosition: Finds a safe spawn location for helicopters.
A3A_fnc_createUnit: Spawns individual units.
A3A_fnc_NATOinit: Initializes the unit (skills, stance, radio, etc.).
SCRT_fnc_unit_getTiered: Retrieves the static crew unit class based on tier.
SCRT_fnc_unit_flattenTier: Retrieves infantry unit classes (guards/marksmen) based on tier.
Dependencies:

Called by: A3A_fnc_createAIMilbase, A3A_fnc_createAIOutposts, A3A_fnc_createAIResources.
Relies on: Global arrays A3A_milBuildingWhitelist, milbases, airportX. Faction definitions from Faction(_sideX).
Global Variables Modified:
_groupX, _vehiclesX, _soldiers, _spawnsUsed (local but returned).
Modifies spawner namespace variable (spawner getVariable) to check for despawn state.
Network Implications: All spawns are local to the server executing the script (headless client or server). Units and vehicles are created locally and do not require network synchronization for creation, but they will be network-synced objects for all clients.

Function: fn_minefieldAAF.sqf
Function Name: A3A\addons\core\functions\CREATE\fn_minefieldAAF.sqf

What it does: This function generates a random minefield near a specific base (_base) but ensuring it is placed at a safe distance from other markers (to prevent minefields overlapping with outposts or spawn points). It validates the location, spawns a mix of AT and APERS mines, and returns success status.

When/Why it's called: Called during mission initialization or dynamic resource generation when the AI faction (AAF or CSAT) is configured to lay minefields. It is likely triggered by A3A_fnc_createAIMilbase or a similar map initialization script.

How it does that:

1. Parameter Validation and Initialization: Checks if it's running on a server or a client with the interface (Headless Client or Server only).

fn_minefieldAAF.sqf (1-9)

Apply
if (!isServer and hasInterface) exitWith {false};
private ["_markerX","_base","_posbase","_posMarker","_angOrig","_ang","_attempts","_distanceX","_pos","_failure",""_mineX"];

_markerX = _this select 0;
_base = _this select 1;

_sideX = sidesX getVariable [_base,sideUnknown];
private _faction = Faction(_sideX);

if (spawner getVariable _base != 2) exitWith {false};
Side Check: Runs only on non-client machines (server/HC).
Spawner Check: spawner getVariable _base != 2 checks if the base is currently active/spawned. If not, it exits.
Side Retrieval: Gets the side of the base from global variable sidesX (e.g., Independence, West, East).
Faction Lookup: Faction(_sideX) retrieves the configuration for that side.
2. Location Calculation: Calculates a random position in a cone direction between the base and the target marker (_markerX).

fn_minefieldAAF.sqf (10-17)

Apply
_posbase = getMarkerPos _base;
_posMarker = getMarkerPos _markerX;
_angOrig = [_posbase,_posMarker] call BIS_fnc_dirTo;
_angOrig = _angOrig - 45;
_ang = _angOrig + random 90;
_attempts = 1;
_distanceX = 500;
Direction: Calculates the direction from base to marker. Adds a random +/- 45 degree deviation to scatter mines.
Distance: Fixed search radius of 500 meters.
3. Position Validation (Collision Avoidance): Loops up to 37 times to find a valid spot. A spot is valid if:

Not on water.
Not near an active marker (radius + 100m).
Not near a road (to avoid wasting mines on roads).
Not within 200m of existing mines.
fn_minefieldAAF.sqf (18-39)

Apply
_pos = [];
_failure = true;
while {_attempts < 37} do
    {
    _pos = [_posbase, _distanceX, _ang] call BIS_Fnc_relPos;
    if (!surfaceIsWater _pos) then
        {
        _nearX = [markersX,_pos] call BIS_fnc_nearestPosition;
        if (spawner getVariable _nearX == 2) then
            {
            _size = [_nearX] call A3A_fnc_sizeMarker;
            if ((_pos distance (getMarkerPos _nearX)) > (_size + 100)) then
                {
                _road = [_pos,101] call BIS_fnc_nearestRoad;
                if (isNull _road) then
                    {
                    if ({_x distance _pos < 200} count allMines == 0) then
                        {
                        _failure = false;
                        };
                    };
                };
            };
        };
    if (!_failure) exitWith {};
    _attempts = _attempts + 1;
    _ang = _ang - 10;
    };
Loop: Uses BIS_Fnc_relPos to find positions. If a position fails, it subtracts 10 degrees from _ang and tries again.
allMines: Checks against the global array of all mines on the map to prevent density issues.
4. Mine Spawning: If a position is found, it spawns 30 mines in a 50m radius around that point.

fn_minefieldAAF.sqf (41-57)

Apply
if (_failure) exitWith {
    Info_1("could not create a Minefield at %1", _base);
    false;
};

Debug_1("Creating a Minefield at %1", _base);

private _mines = (_faction get "minefieldAT") + (_faction get "minefieldAPERS");

for "_i" from 1 to 30 do {
	_mineX = createMine [ selectRandom _mines ,_pos,[],50];
	_sideX revealMine _mineX;
};

//[-4000] remoteExec ["resourcesAAF",2];
true
Mine Selection: Combines AT (Anti-Tank) and APERS (Anti-Personnel) mine lists from the faction config.
Creation: createMine places the mine. The _sideX reveals it to its own side (so they don't run over their own mines). The loop adds a small random offset (the [] parameter) within 50m.
Resource Deduction (Commented): [-4000] remoteExec ["resourcesAAF",2]; is commented out, suggesting cost calculation might be handled elsewhere or disabled for this specific spawn.
Where it leads:

Functions Called:

BIS_fnc_dirTo: Math function for angle calculation.
BIS_Fnc_relPos: Math function for relative positioning.
BIS_fnc_nearestRoad: Checks for road proximity.
A3A_fnc_sizeMarker: Retrieves the radius of the nearest marker.
Faction(_sideX): Retrieves faction data.
Dependencies:

Called by: A3A_fnc_createAIMilbase or base initialization logic.
Relies on: Global variables sidesX, markersX, allMines, spawner. Faction data for minefieldAT and minefieldAPERS.
Global Variables Modified: allMines is implicitly modified by createMine (though not reassigned in code, the command updates the global array).
Network Implications: createMine is a server-authoritative command. The minefield is created on the server and synchronized to all clients. The revealMine command is likely local to the side but should be run on the server for consistency.

Function: fn_mortarPos.sqf
Function Name: A3A\addons\core\functions\CREATE\fn_mortarPos.sqf

What it does: This is a utility function that finds a suitable position to spawn a mortar. It ensures the position is not on a building roof and is generally clear of obstacles. It uses a random search algorithm to find a valid spot near the requested position.

When/Why it's called: Called whenever a mortar needs to be spawned, such as by A3A_fnc_sup (Supports) or during base defense/garrison generation. It ensures mortars don't spawn inside buildings or on roofs.

How it does that:

1. Initial Placement Check: Starts by finding an empty position near the input _pos using findEmptyPosition.

fn_mortarPos.sqf (1-5)

Apply
params ["_pos"];

_pos = _pos findEmptyPosition [1,30,"I_G_Mortar_01_F"];
if (count _pos == 0) then {_pos = _this select 0};
findEmptyPosition: Searches for a clear spot between 1 and 30 meters from _pos suitable for the "I_G_Mortar_01_F" object type.
Fallback: If no empty position is found, it reverts to the original input position.
2. Distance Search Loop: The function then enters a loop to check if the chosen position is actually a "building position" (defined in another function). If it is (or if the spot is invalid), it moves the position randomly outward in 31-meter increments.

fn_mortarPos.sqf (7-13)

Apply
private _countX = 300;
while {_countX > 0} do {
	if !([_pos] call A3A_fnc_isBuildingPosition) then {_exit = true};
	_pos = _pos getPos [31,random 360];
	_countX = _countX - 1;
};
Loop Logic: It runs 300 times maximum.
A3A_fnc_isBuildingPosition: This checks if the position is on a building. If it returns false (meaning it's not on a building), _exit is set to true, which should break the loop. Note: The variable _exit is not initialized in this snippet, which might be a bug or dependent on scope. The logic seems intended to stop moving once a clear ground spot is found.
Movement: _pos getPos [31,random 360] moves the position 31 meters in a random direction.
3. Final Validation and Return: After the loop (or if it breaks early), it performs one final empty position check. If the result is invalid, it returns the original input position.

fn_mortarPos.sqf (14-17)

Apply
if (_countX == 0) then {_pos = (_this select 0) findEmptyPosition [1,30,"I_G_Mortar_01_F"]};
if (count _pos == 0) then {_pos = _this select 0};

_pos
Loop Exit Check: If _countX reached 0 (loop finished without finding a clear spot), it tries one last time to find an empty position near the original requested location.
Empty Check: If the _pos array is empty (no position found), it defaults to the original requested position (_this select 0).
Return: Returns the determined position array.
Where it leads:

Functions Called:

A3A_fnc_isBuildingPosition: Checks if a position is considered a building position (likely checks for roof/nesting).
findEmptyPosition: BIS function to find clear space.
Dependencies:

Called by: A3A_fnc_sup_mortar, A3A_fnc_spawnVehiclePrecise, or any script requiring a mortar placement.
Relies on: A3A_fnc_isBuildingPosition logic (defined elsewhere, likely checks for buildingPos availability).
Global Variables Modified: None.
Network Implications: Purely calculation logic. No network traffic. This function is likely run locally on the machine requesting the spawn (Server or HC).

Function Name: 
fn_NATOinit.sqf
What it does: Initializes an AI unit with side-specific data, faction-specific visual/audio identity, skill scaling, event handlers, and equipment adjustments based on environmental conditions and unit role. It determines whether the unit should be a spawner (managed by the spawn system) or a persistent garrison unit.

How it does that:

Parameter Validation and Setup: The function begins by validating inputs. It checks if the unit exists and is not NULL. If validation fails, it logs an error and exits.

Sqf

Apply
// Input validation
if ((isNil "_unit") || (isNull _unit)) exitWith
{
    Error_1("Bad init parameter: %1", _this);
};
Variable Initialization: Retrieves the unit's type, side group, faction, and specific flags (like isRival). It assigns default values if missing.

Sqf

Apply
private _type = _unit getVariable "unitType";
private _side = side (group _unit);
private _isRival = _unit getVariable ["isRival", false];
private _unitPrefix = _unit getVariable ["unitPrefix", ""];
private _faction = Faction(_side);
It also sets an internal variable originalSide used for deletion handling.

Spawner Logic: Determines if the unit is a "spawner" (simulated/garbage collected when outside spawn range) or a persistent unit.

If _isSpawner is explicitly provided, it sets the spawner variable.
If not provided, it calculates the status based on context:
Garrison units: If the unit has a marker, it is a persistent garrison unit (not a spawner).
Cargo units: Units assigned as cargo in a vehicle are not initially spawners; they inherit spawner status upon GetOutMan.
Fixed-wing aircraft: Are excluded from being spawners to prevent spawn spam.
Rivals: Are excluded from being spawners (insurgency units).
Default: All other units are spawners.
Sqf

Apply
// Simplified logic for spawner determination
if (isNil "_isSpawner") then {
    if (_marker != "") exitWith {
        // Persistent garrison unit
        _unit setVariable ["markerX", _marker, true];
    };
    if (_unit in (assignedCargo _veh)) exitWith {
        // Cargo unit, waits for dismount
        _unit setVariable ["spawner", false];
        // Add GetOutMan event handler to set spawner later
    };
    if (_isRival) exitWith {};
    // Default: Spawner
    _unit setVariable ["spawner",true,true];
};
Event Handler Installation: Installs core AI logic event handlers for damage calculation (A3A_fnc_handleDamageAAF), resource tracking upon death (A3A_fnc_enemyUnitKilledEH), and cleanup on deletion (A3A_fnc_enemyUnitDeletedEH).

Sqf

Apply
_unit addEventHandler ["HandleDamage", A3A_fnc_handleDamageAAF];
_unit addEventHandler ["Killed", A3A_fnc_enemyUnitKilledEH];
_unit addEventHandler ["Deleted", A3A_fnc_enemyUnitDeletedEH];
Skill Calculation: Calculates a base skill value using global variables (A3A_enemySkillMul, A3A_activePlayerCount) and mission state (tierWar).

Sqf

Apply
private _skill = (0.1 * A3A_enemySkillMul) + (0.07 * (1 max A3A_activePlayerCount^0.5)) + (0.01 * tierWar);
Identity and Equipment Selection: Uses a switch statement to determine visual/audio assets and apply skill modifiers based on unitPrefix (e.g., "militia", "police", "SF").

Selects faces, voices, and insignia from faction data.
Adjusts skill multiplier (e.g., x0.7 for militia, x1.2 for SF).
Sqf

Apply
switch (true) do {
    case (_isRival): { _skill = _skill * 0.9; ... };
    case (_unitPrefix isEqualTo "militia"): { _skill = _skill * 0.7; ... };
    // ... other cases
};
It applies the identity using A3A_fnc_setIdentity and sets the unit's skill attribute.

Leader Specific Logic: Checks if the unit is a Squad Leader. If so, increases specific sub-skills (courage, commanding) and adds specialized loot/intel.

Sqf

Apply
if (_type in FactionGet(all,"SquadLeaders")) then {
    _unit setskill ["courage", _skill + 0.2];
    // Add money magazine and intel
};
AI Accuracy Cap: Enforces a hard cap on aimingAccuracy defined by aiAccuracyCeiling to prevent impossible sniper units.

Sqf

Apply
if((_unit skill "aimingAccuracy") > _decimalAccurancyCap) then {
    _unit setSkill ["aimingAccuracy", _decimalAccurancyCap];
    // ... set other aim skills
};
Night Equipment Management: Modifies NVG and flashlight assignments based on sunOrMoon.

Night: Removes NVGs for non-SF/Leaders based on tierWar. Removes laser attachments if no NVGs are present; adds flashlights if needed. Reduces spotting skills.
Day: Removes NVGs from non-SF units.
Sqf

Apply
if (sunOrMoon < 1) then {
    if (_unitPrefix isNotEqualTo "SF" && {_unit != leader (group _unit)}) then {
        // Remove NVGs based on tier
    };
    // Handle weapon attachments for night vision
};
Reveals Air Targets: If the unit is a gunner or AA carrier, it reveals nearby air entities to the AI squad.

Sqf

Apply
if (_unit == gunner objectParent _unit or {(secondaryWeapon _unit) in allAA}) then {
    {
        if (!isNull driver _x) then { _unit reveal [_x, 1.5] };
    } forEach (_unit nearEntities ["Air", distanceSPWN*1]);
};
Event Trigger: Finally, triggers a global AIInit event for logging or external systems.

Sqf

Apply
["AIInit", [_unit, _side, _marker, _unit getVariable "spawner"]] call EFUNC(Events,triggerEvent);
Where it leads:

Called Functions:
A3A_fnc_handleDamageAAF: Handles damage calculations and survivability logic.
A3A_fnc_enemyUnitKilledEH: Handles loot drops, aggression changes, and resource updates when the unit dies.
A3A_fnc_enemyUnitDeletedEH: Handles cleanup of group variables and data structures.
A3A_fnc_setIdentity: Applies visual/audio identity to the unit.
SCRT_fnc_common_addRandomMoneyMagazine: Adds money to unit inventory (leader specific).
SCRT_fnc_common_selectAndApplyLeaderIntel: Adds intel items to leader inventory.
EFUNC(Events,triggerEvent): Fires a public event.
Called by:
fn_patrolReinf.sqf
 (for cargo units and crew).
fn_AIVEHinit.sqf (indirectly, as vehicles spawn crew).
fn_createUnit.sqf (implied, as unit creation logic).
fn_garrisonUpdate.sqf (when spawning persistent garrison units).
System Fit: This is the central initialization point for all enemy AI (AAF, CSAT, Rivals). It bridges the gap between raw unit creation and active AI simulation.
Global Variables Modified:
Unit local variables: unitType, originalSide, A3A_resPool, spawner, markerX, isRival.
Global event state: Triggers AIInit event.
Network Implications: Some variable setting uses setVariable [..., true] (global sync), ensuring all clients know the unit's state (especially spawner and markerX).
Function Name: 
fn_patrolReinf.sqf
What it does: Spawns a reinforcement group consisting of a transport vehicle and infantry. It determines if the transport travels by land or air, spawns the crew and cargo, creates waypoints for delivery, and cleans up the vehicle and crew once the reinforcement is delivered or timed out.

How it does that:

Parameter Setup: Accepts destination marker, origin marker, troop count, and side. Loads the specific faction data.

Sqf

Apply
params ["_mrkDest", "_mrkOrigin", "_numTroops", "_side"];
private _faction = Faction(_side);
Vehicle Type Selection: Determines if the route must be land-based (due to attributeLowAir faction flag or map support markers).

Sqf

Apply
private _isLand = if (_lowAir) then { true } else {
    private _targNavIndex = _mrkDest call A3A_fnc_getMarkerNavPoint;
    private _suppMarkers = [_targNavIndex, _lowAir] call A3A_fnc_findLandSupportMarkers apply { _x#0 };
    _mrkOrigin in _suppMarkers;
};
Selects the vehicle type based on _isLand:

Land: vehiclesTrucks.
Air: Weighted random selection between vehiclesPlanesTransport and vehiclesHelisTransport.
Vehicle and Crew Spawning: Spawns the transport vehicle at the origin marker.

Sqf

Apply
private _vehicle = [_mrkOrigin, _vehicleType] call A3A_fnc_spawnVehicleAtMarker;
Creates the crew group for the vehicle using A3A_fnc_createVehicleCrew.

Sqf

Apply
private _crewGroup = [_side, _vehicle] call A3A_fnc_createVehicleCrew;
{ [_x, nil, false, "legacy"] call A3A_fnc_NATOinit } forEach (units _crewGroup);
[_vehicle, _side, "legacy"] call A3A_fnc_AIVEHinit;
Cargo Group Spawning: Calculates available cargo space. Trims the requested troop list if necessary.

Sqf

Apply
private _expectedCargo = ([_vehicleType, true] call BIS_fnc_crewCount) - ([_vehicleType, false] call BIS_fnc_crewCount);
if (_expectedCargo < count _groupType) then { _groupType resize _expectedCargo };
Spawns the cargo group and moves them into the vehicle. Uses moveInCargo or moveInAny (for specific unsupported vehicles like uns_an2_transport).

Sqf

Apply
private _cargoGroup = [_posOrigin, _side, _groupType, true, false] call A3A_fnc_spawnGroup;
{
    _x assignAsCargo _vehicle;
    if (_vehicleType == "uns_an2_transport") then { _x moveInAny _vehicle} else { _x moveInCargo _vehicle };
    [_x, nil, false, "defence"] call A3A_fnc_NATOinit;
} forEach units _cargoGroup;
Deducts resources for the spawned units immediately.

Sqf

Apply
[-10*count units _cargoGroup, _side, "defence"] remoteExec ["A3A_fnc_addEnemyResources", 2];
Waypoint Creation (Land): For land transport, finds a safe road to unload and creates waypoints for the driver to the unload point, then back to base.

Sqf

Apply
private _landPos = [_posDest, getPosATL _vehicle, true, []] call A3A_fnc_findSafeRoadToUnload;
[getPosATL _vehicle, _landPos, _crewGroup] call A3A_fnc_WPCreate;
// Add TR UNLOAD waypoint
// Add Return waypoint
It also adds a waypoint for the cargo group to move to the destination after disembarking.

Waypoint Creation (Air): For air transport, attempts to find a safe landing spot (for helicopters) or uses specific actions (VTOL/Fastrope).

Landing: Creates a hidden helipad, sets a TR UNLOAD waypoint that executes a landing script (land 'GET OUT').
Fastrope/Paradrop: If landing is impossible or the vehicle is a fast-rope type, calls A3A_fnc_fastrope or A3A_fnc_paradrop.
Sqf

Apply
if (count _landPos > 0) then {
    // Create helipad and landing waypoints
    _landWP setWaypointStatements ["true", "if !(local this) exitWith {}; (vehicle this) land 'GET OUT'"];
} else {
    if (_vehicleType in vehFastRope) then {
        [_vehicle, _cargoGroup, _posDest, _posOrigin, _crewGroup, [], true] spawn A3A_fnc_fastrope;
    };
};
Timeout and Termination Logic: Sets a timeout based on distance. Waits for the cargo group to be near the destination OR all units to die OR timeout.

Sqf

Apply
private _timeout = if (_isLand) then { time + ([_mrkDest, _mrkOrigin] call A3A_fnc_findNavDistance) / 6 + 300 } else { ... };
waituntil {
    sleep 10;
    private _leader = leader _cargoGroup;
    { alive _x } count (units _cargoGroup) == 0 || time > _timeout || { _leader == vehicle _leader && { _leader distance _posDest < 200 } }
};
Cleanup: Deletes the temporary helipad (if created). Sends the vehicle and crew back to base using A3A_fnc_VEHdespawner and A3A_fnc_enemyReturnToBase.

Sqf

Apply
if !(isNull _landpad) then { deleteVehicle _landpad };
[_vehicle] spawn A3A_fnc_VEHdespawner;
[_crewGroup] spawn A3A_fnc_enemyReturnToBase;
Result Handling:

Failure: If the team is wiped, timed out, or the destination changed ownership, the group is sent back to base. A "killzone" is added to the origin marker to prevent repeating failed routes.
Success: The remaining units are added to the destination's garrison using A3A_fnc_enemyGarrison.
Sqf

Apply
if (count _units == 0 || time > _timeout || _side != (sidesX getVariable _mrkDest)) exitWith {
    // Failure logic
};
[_cargoGroup, _mrkDest] call A3A_fnc_enemyGarrison;
Where it leads:

Called Functions:
A3A_fnc_getMarkerNavPoint: For pathfinding.
A3A_fnc_findLandSupportMarkers: For route validation.
A3A_fnc_spawnVehicleAtMarker: Spawns the transport.
A3A_fnc_createVehicleCrew: Generates driver/pilot crew.
A3A_fnc_AIVEHinit: Initializes transport vehicle.
A3A_fnc_spawnGroup: Spawns infantry cargo.
A3A_fnc_findSafeRoadToUnload: Finds disembarkation point.
A3A_fnc_WPCreate: Creates movement waypoints.
A3A_fnc_fastrope / A3A_fnc_paradrop: Handles aerial insertion.
A3A_fnc_VEHdespawner: Cleans up vehicle.
A3A_fnc_enemyReturnToBase: Sends crew home.
A3A_fnc_enemyGarrison: Adds survivors to garrison.
Called by:
fn_reinforcementsAI.sqf
 (when the AI decides to send a physical reinforcement).
System Fit: Executes the physical delivery of AI units requested by the high-level AI command (reinforcementsAI). It handles the complex logistics of transport and insertion.
Global Variables Modified:
killZones: Updates killzone lists on failure (to avoid repeat failures).
garrison: Modifies when units are successfully added via enemyGarrison.
Unit variables: spawnPlace (set by spawn functions, used for cleanup).
Network Implications: Spawning and waypoint setting are server-side. Cleanup uses spawn to run asynchronously. Resource deduction is executed remotely on the server.
Function Name: 
fn_registerUnitType.sqf
What it does: Registers a custom unit definition into a global variable (A3A_customUnitTypes) so it can be accessed later by spawn functions. This is a utility for template management.

How it does that:

Execution Guard: Ensures the function only runs on the server to prevent data inconsistency.

Sqf

Apply
if (!isServer) exitWith {};
Parameter Extraction: Takes a unit type name (string) and a definition array (containing loadouts, classnames, etc.).

Sqf

Apply
params [["_unitTypeName", nil, [""]], ["_unitDefinition", nil, [[]]]];
Data Storage: Stores the definition in the global namespace variable A3A_customUnitTypes.

Sqf

Apply
A3A_customUnitTypes setVariable [_unitTypeName, _unitDefinition, true];
Debug Logging: Logs the registration details for debugging.

Sqf

Apply
Debug_3("Registering unit %1 with class %2 and %3 loadouts", _unitTypeName, _unitDefinition#2, count (_unitDefinition#0));
Where it leads:

Called Functions: None (pure storage).
Called by:
Template initialization scripts (likely init.sqf or template loading functions like fn_loadFaction).
SCRT\Unit\fn_compileGroups.sqf (implied, as this is used to build unit groups).
System Fit: Part of the custom unit framework. It allows dynamic definition of units without hardcoding classes, essential for mod compatibility and mission customization.
Global Variables Modified:
A3A_customUnitTypes: The central registry for custom unit data.
Network Implications: The true flag ensures the variable is broadcast globally, allowing all clients (especially Headless Clients) to access the definition.
Function Name: 
fn_reinforcementsAI.sqf
What it does: The high-level AI decision-making loop for garrison reinforcement. It calculates required troops based on resource availability and garrison deficits, selects appropriate sources and targets, and triggers either fn_patrolReinf (physical units) or direct garrison updates (abstract units).

How it does that:

Killzone Cleanup: Manages the killZones variable. It calculates a removal rate based on aggression. If the accumulator hits >1, it removes random killzone entries to prevent the AI from permanently avoiding certain routes.

Sqf

Apply
private _kzAggroMult = 0.2 + 0.4 * (aggressionOccupants + aggressionInvaders) / 100;
killZoneRemove = killZoneRemove + _kzAggroMult * (0.5 + 0.1 * count _allKillzones);
// ... loop to remove entries
Side Iteration: Loops through Occupants and Invaders (skipping Invaders in specific gamemodes).

Sqf

Apply
{
    private _side = _x;
    // ...
} forEach [Occupants, Invaders];
Resource Calculation: Calculates total troops available for reinforcement based on defense resources (A3A_resourcesDefenceOcc / Inv).

Sqf

Apply
private _totalReinf = 4 * round (0.1 * _defRes / 40);
Target Selection: Builds a list of valid targets (owned markers) that need troops and are not currently under heavy attack (checked via A3A_fnc_getRecentDamage).

Sqf

Apply
{
    private _site = _x;
    if (sidesX getVariable _site != _side) then { continue };
    // ...
    private _troopsNeeded = _maxTroops - count (garrison getVariable [_site, []]);
    if (_troopsNeeded <= 0) then { continue };
    _reinfTargets pushBack [_troopsNeeded/_maxTroops, _troopsNeeded, _site];
} forEach (airportsX + outposts + seaports + resourcesX + factories + milbases);
Targets are sorted by the proportion of troops needed (highest first).

Logistics and Dispatching Loop: While resources remain, it attempts to dispatch reinforcements.

Land Route (_lowAir): Finds a land source base using A3A_fnc_availableBasesLand. Uses killzones to avoid blocked paths.
Air Route: Selects a random airfield source. Checks distance and killzones.
Spawn Decision:
Self-Reinforce: If source == target, simply adds troops directly to the garrison variable via A3A_fnc_garrisonUpdate (remote exec).
Physical Reinforce: If players are near the target (A3A_fnc_distanceUnits), spawns a physical group via A3A_fnc_patrolReinf.
Abstract Reinforce: If no players are near, adds troops directly to the garrison (abstract spawn).
Sqf

Apply
if (_source == _target) then {
    [[_numTroops, _faction] call _fnc_pickSquadType, _side, _target, 0] remoteExec ["A3A_fnc_garrisonUpdate",2];
} else {
    if ([distanceSPWN1, 1, getMarkerPos _target, teamPlayer] call A3A_fnc_distanceUnits) then {
        [[_target, _source, _numTroops, _side], "A3A_fnc_patrolReinf"] call A3A_fnc_scheduler;
    } else {
        [[_numTroops, _faction] call _fnc_pickSquadType, _side, _target, 2] remoteExec ["A3A_fnc_garrisonUpdate", 2];
    };
};
Road Patrol Generation: If the number of active road patrols (AAFpatrols) is low, it triggers A3A_fnc_AAFroadPatrol.

Sqf

Apply
if (AAFpatrols < round (3 * A3A_balancePlayerScale) and (random 2 < A3A_balancePlayerScale)) then {
    [] spawn A3A_fnc_AAFroadPatrol;
};
Cooldown Management: Reduces loot crate and SAM destruction cooldowns for fully garrisoned bases.

Sqf

Apply
if (_realSize / _maxSize < 0.75) exitWith {};
garrison setVariable [_x + "_lootCD", 0 max (_lootCD - 10), true];
Where it leads:

Called Functions:
A3A_fnc_availableBasesLand: Finds valid land sources.
A3A_fnc_getRecentDamage: Checks for active combat.
A3A_fnc_garrisonUpdate: Updates garrison counts (remote executed).
A3A_fnc_patrolReinf: Spawns physical reinforcements (via scheduler).
A3A_fnc_AAFroadPatrol: Spawns AI road patrols.
A3A_fnc_findNavDistance (implied in patrolReinf).
Called by:
Server loop or scheduler (often called periodically or by a trigger).
System Fit: This is the "Brain" of the AI defense. It balances resources, detects threats, and deploys forces accordingly. It acts as the bridge between economy (A3A_resourcesDefence) and simulation (fn_patrolReinf).
Global Variables Modified:
killZones: Updated to clear old blockades.
killZoneRemove: Internal accumulator for cleanup.
garrison: Modified indirectly via remote exec of garrisonUpdate.
AAFpatrols: Reads current patrol count.
Network Implications: Heavily uses remoteExec to distribute updates to the server (resource management) and potentially Headless Clients (spawning).
Function Name: 
fn_remoteBattle.sqf
What it does: Manages abstracted combat between AI groups when players are not present. It simulates the outcome of a firefight by applying damage to units based on relative numbers, reducing the need for CPU-intensive simulation of distant battles.

How it does that:

Parameter Setup: Accepts an array of soldier objects (_this).

Sqf

Apply
private _soldiers = _this;
Initial Readiness Check: Waits for all units in the group to exit vehicles and be "canFight" (A3A_fnc_canFight).

Sqf

Apply
waitUntil {sleep 10;{([_x] call A3A_fnc_canFight) and {vehicle _x == _x}} count _soldiers == {[_x] call A3A_fnc_canFight} count _soldiers};
Enemy Identification: Determines the side of the group and identifies potential enemy sides (TeamPlayer, Occupants, Invaders).

Sqf

Apply
private _sideX = side (group (_soldiers select 0));
private _eny = [teamPlayer];
if (_sideX == Occupants) then {_eny pushBack Invaders} else {_eny pushBack Occupants};
Simulation Loop: Runs continuously in 10-second intervals.

Filtering: Removes dead units from the _soldiers list.
Proximity Scan: Checks for nearby players. If a player is within distanceSPWN, the simulation aborts immediately (_exit = true), as the real battle should take over.
Enemy Scan: Scans for enemies within distanceSPWN/2. Only checks units that are alive, on the correct side, and on foot.
Sqf

Apply
{
    if ((_x distance _soldierX < (2*distanceSPWN)) and (isPlayer _x)) then { _exit = true };
    if ((_x distance _soldierX < (distanceSPWN/2)) and {[_x] call A3A_fnc_canFight} and {side group _x in _eny} and {vehicle _x == _x}) then {
        _enemiesX pushBackUnique _x;
    };
} forEach (allUnits - _soldiers);
Damage Application: If enemies are found and no players are nearby, it calculates a "kill chance" based on the ratio of friends-to-enemies (_chanceToKill = 50 * (count _soldiers / count _enemiesX)).

If random roll succeeds, an enemy unit is killed (setDamage 1).
If random roll fails, a friendly unit is killed (setDamage 1).
Sqf

Apply
_chanceToKill = 50 * ((count _soldiers) / (count _enemiesX));
if (random 100 <= _chanceToKill) then {
    (selectRandom _enemiesX) setDamage 1;
} else {
    (selectRandom _soldiers) setDamage 1;
};
Where it leads:

Called Functions:
A3A_fnc_canFight: Checks unit status (alive, conscious).
Called by:
A3A_fnc_enemyGarrison (when groups engage at a distance).
A3A_fnc_invaderPunish (implied context for distant combat).
System Fit: Part of the "Low Detail" simulation layer. It ensures the game world state updates correctly (units die, garrisons deplete) without rendering or physics overhead for distant interactions.
Global Variables Modified:
Individual unit damage states (local to unit, synced by engine).
Network Implications: setDamage 1 is engine-handled replication. The loop is local to the server (or the machine running it).

Function: fn_RivalsCargoSeats.sqf
What it does: Calculates the number of available cargo/passenger seats in a vehicle for Rivals, returning an appropriate infantry group composition based on seat availability. It is used when spawning Rivals units in vehicles to ensure the group size matches the vehicle's capacity.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_veh", "_sideX"];
The function accepts two parameters: the vehicle object (_veh) and its side (_sideX). There is no explicit type checking; it assumes valid inputs.

Faction and Seat Calculation:

Sqf

Apply
private _faction = Faction(_sideX);
private _totalSeats = [_veh, true] call BIS_fnc_crewCount;
private _crewSeats = [_veh, false] call BIS_fnc_crewCount;
private _cargoSeats = _totalSeats - _crewSeats;
It retrieves the side's faction data, then uses BIS_fnc_crewCount with boolean flags to distinguish between total seats (including crew) and crew-only seats. The difference gives the available cargo/passenger seats.

Police Vehicle Adjustment:

Sqf

Apply
if (_veh in (_faction get "vehiclesPolice")) then { _cargoSeats = 6 min _cargoSeats };
For police-specific vehicles, the cargo seat count is capped at a maximum of 6.

Minimum Seat Check:

Sqf

Apply
if (_cargoSeats < 2) exitwith { [] };
If there are fewer than 2 cargo seats, the function exits with an empty array, indicating no group should be spawned.

Group Composition Selection: The function uses a series of conditional blocks to select a group template based on seat count:

2-3 seats: Returns a random group from groupsSentry.
4-5 seats (or 6 seats with 1/3 probability): Returns a random group from groupsFireteam.
6+ seats: Attempts to select a squad from groupsSquad, but only if a flag _isRivals is true (though this flag is not defined in the provided snippet, suggesting it may be set externally or the snippet is incomplete).
Sqf

Apply
if (_cargoSeats < 4) exitWith { selectRandom (A3A_faction_riv get "groupsSentry"); };
if (_cargoSeats < 6 or { _cargoSeats == 6 and random 3 < 1}) exitWith { selectRandom (A3A_faction_riv get "groupsFireteam"); };
private _squad = call {
    if (_isRivals) exitWith { selectRandom (A3A_faction_riv get "groupsSquad") };
};
Note: The _isRivals variable is referenced but not defined in this function's scope. This appears to be a bug or an oversight; the function likely relies on a global variable or a previous context.

Squad Size Trimming:

Sqf

Apply
while { count _squad > _cargoSeats } do {
    _squad deleteAt (1 + floor random (count _squad - 1));
};
If a squad larger than the available seats is selected, it iteratively removes random units (excluding index 0, the squad leader) until the squad size matches the seat count.

Output:

Sqf

Apply
_squad;
Returns the final selected group composition array.

Where it leads:

Called by: This function is likely called by higher-level mission spawning functions (e.g., RivalsSpawnVehicle or mission-specific scripts) when configuring a group to be spawned into a vehicle.
Calls: BIS_fnc_crewCount.
Depends on: Global variable A3A_faction_riv (a hashmap containing faction data, specifically vehiclesPolice, groupsSentry, groupsFireteam, groupsSquad).
Modifies: No global variables are modified directly. It returns a localized array.
System Role: Part of the Rivals faction spawning system, ensuring units spawned into vehicles match the vehicle's cargo capacity. This prevents over-spawning units and maintains balanced gameplay.
Edge Cases:
If _cargoSeats is 0 or 1, returns [].
If _cargoSeats is 6, there's a 2/3 probability to use a fireteam and a 1/3 probability to use a squad (if _isRivals is true).
The _isRivals variable's undefined state is a critical flaw that may cause the function to return nil if it reaches the final block and the condition is not met.
Network/Serialization: None. This is a server-side logic function for deterministic group composition.
Function: fn_RivalsCreateUnit.sqf
What it does: Creates a unit for the Rivals faction, handling custom unit types, loadouts, traits, and properties. It acts as a wrapper around the standard createUnit command, providing extended functionality for faction-specific unit definitions.

How it does that:

Parameter Initialization:

Sqf

Apply
params ["_group", "_type", "_position", ["_markers", []], ["_placement", 0], ["_special", "NONE"]];
private _unitDefinition = A3A_customUnitTypes getVariable [_type, []];
It unpacks parameters, with defaults for optional ones. It then looks up _type in the global namespace A3A_customUnitTypes, which holds definitions for custom units (loadouts, traits, etc.).

Custom Unit Type Handling:

Sqf

Apply
if !(_unitDefinition isEqualTo []) exitWith {
    _unitDefinition params ["_loadouts", "_traits", "_unitProperties", "_unitClass"];
    private _canSkip = false;
    // ... parsing traits and properties ...
    private _unit = _group createUnit [_unitClass, _position, _markers, _placement, _special];
    [_unit] joinSilent _group;
    if (_canSkip isEqualTo false) then {
        _unit setUnitLoadout selectRandom _loadouts;
    };
    // ... setting variables and traits ...
    _unit
};
If a custom definition exists:

It unpacks the definition into loadouts, traits, unit properties, and a base unit class.
It iterates through _traits to find a "baseClass" entry, which can override _unitClass. This supports random selection from a weighted list of classes.
It checks for a boolean trait (the second element in each trait array) to set _canSkip, determining if loadouts should be skipped (useful for pre-equipped units).
It creates the unit using the determined class.
It forces the unit to join the group (joinSilent), which is a hack to ensure side allegiance in custom mode setups.
If loadouts aren't skipped, a random one is applied.
It sets the unit's type variable and processes _unitProperties to set flags like "isRival" or "unitPrefix".
Finally, it applies all relevant traits (skipping the "baseClass" trait).
Standard Unit Creation:

Sqf

Apply
private _unit = _group createUnit [_type, _position, _markers, _placement, _special];
_unit setVariable ["unitType", _type, true];
_unit
If no custom definition exists (_unitDefinition is empty), it falls back to the standard createUnit command using _type as the classname, sets the unit type variable, and returns the unit.

Where it leads:

Called by: fn_RivalsCreateVehicleCrew (to create driver/gunners), fn_RivalsSpawnGroup (to create infantry), and potentially any script that needs to spawn a Rivals unit.
Calls: A3A_customUnitTypes getVariable (global namespace lookup), createUnit, joinSilent, setUnitLoadout, setUnitTrait.
Depends on:
Global namespace A3A_customUnitTypes (managed elsewhere).
The createUnit function in A3A_fnc_createUnit (likely the vanilla/standard one, but this version might override it or be specific to Rivals).
Modifies:
Creates a unit object (local to the machine running the script).
Sets the unitType, isRival, and unitPrefix variables on the unit object.
System Role: Core unit spawning abstraction for the Rivals faction. It decouples unit creation logic from the specific game engine command, allowing for complex, data-driven unit configurations.
Edge Cases:
If _type is an array (loadout array) instead of a string, it's not handled here; this function expects a string key for lookup.
Weighted random class selection: if the baseClass entry contains a nested array of classes and weights, it uses selectRandomWeighted.
The joinSilent hack is crucial for side-swapped units to function correctly, preventing AI conflicts.
Network/Serialization: Creates a unit object locally. The unit's data (variables, loadout) is synchronized by the game engine.
Function: fn_RivalsCreateVehicleCrew.sqf
What it does: Creates and assigns crew members to a Rivals vehicle, handling drivers, gunners (including turrets), and UAVs. It automatically determines crew types based on the vehicle.

How it does that:

Parameter and State Initialization:

Sqf

Apply
params ["_group", "_vehicle", "_unitType"];
private _isHeli = _vehicle isKindOf "Helicopter";
private _newGroup = false;
Unpacks parameters. Determines if the vehicle is a helicopter, which affects turret handling later. Tracks if a new group was created.

Group Creation:

Sqf

Apply
if (_group isEqualType sideUnknown) then {
    _group = createGroup Rivals;
    _newGroup = true;
};
If the input is a side, it creates a new group on that side (Rivals).

UAV Handling:

Sqf

Apply
if (unitIsUAV _vehicle) then {
    createVehicleCrew _vehicle;
    crew _vehicle joinSilent _group;
};
For UAVs, it uses the engine's createVehicleCrew and then forcibly joins the crew to the specified group.

Crew Type Determination:

Sqf

Apply
if (isNil "_unitType") then {
    _unitType = [Rivals, _vehicle] call A3A_fnc_RivalsCrewTypeForVehicle;
};
If no explicit crew type is provided, it calls fn_RivalsCrewTypeForVehicle to guess the correct unit type based on vehicle class.

Driver Assignment:

Sqf

Apply
private _type = typeOf _vehicle;
private _config = configFile >> "CfgVehicles" >> _type;
if (getNumber (_config >> "hasDriver") > 0 && isNull driver _vehicle) then {
    private _driver = [_group, _unitType, getPos _vehicle, [], 10] call A3A_fnc_RivalsCreateUnit;
    _driver assignAsDriver _vehicle;
    _driver moveInDriver _vehicle;
};
Checks the vehicle's config for a driver seat. If it exists and is empty, it calls fn_RivalsCreateUnit to spawn a driver and assigns them to the vehicle.

Turret Assignment (Recursive Function):

Sqf

Apply
private _fnc_addCrewToTurrets = {
    params ["_config", ["_path", []]];
    private _turrets = "true" configClasses (_config >> "Turrets");
    {
        private _turretConfig = _x;
        private _turretPath = _path + [_forEachIndex];
        [_turretConfig, _turretPath] call _fnc_addCrewToTurrets; // Handle nested turrets
        if (getNumber (_turretConfig >> "hasGunner") == 0 || getNumber (_turretConfig >> "dontCreateAI") != 0) then { continue };
        if (!_isHeli && {getNumber (_turretConfig >> "showAsCargo") > 0}) then { continue };
        if (isNull (_vehicle turretUnit _turretPath)) then {
            private _gunner = [_group, _unitType, getPos _vehicle, [], 10] call A3A_fnc_RivalsCreateUnit;
            _gunner assignAsTurret [_vehicle, _turretPath];
            _gunner moveInTurret [_vehicle, _turretPath];
        };
    } forEach _turrets;
};
[_config] call _fnc_addCrewToTurrets;
Defines a recursive function to traverse the vehicle's turret hierarchy. For each turret:

It checks if the turret is valid (has a gunner, not disabled for AI creation).
Crucial Condition: For non-helicopters, it skips turrets flagged as showAsCargo (e.g., copilot turrets that function as cargo). Helicopters do not skip these.
If the turret is empty, it creates a gunner unit and assigns them to the specific turret path.
Finalization:

Sqf

Apply
if (_newGroup) then {
    _group selectLeader (effectiveCommander _vehicle);
};
_group addVehicle _vehicle;
_group
If a new group was created, it selects the vehicle's commander as the group leader. Adds the vehicle to the group's assets and returns the group.

Where it leads:

Called by: fn_RivalsSpawnVehicle (the primary caller), and any script that needs to spawn a crewed Rivals vehicle.
Calls: createGroup, createVehicleCrew (for UAVs), A3A_fnc_RivalsCrewTypeForVehicle, A3A_fnc_RivalsCreateUnit (x2 for driver and potentially many for turrets), assignAsDriver, moveInDriver, assignAsTurret, moveInTurret, selectLeader, addVehicle.
Depends on: fn_RivalsCreateUnit for unit instantiation. Relies on game engine configs for vehicle properties (hasDriver, hasGunner, dontCreateAI, showAsCargo).
Modifies:
Creates a new group if input was a side.
Spawns multiple unit objects (driver, gunners).
Modifies the _vehicle object by assigning crew to it.
Modifies the _group by adding units and the vehicle.
System Role: Core crew generation for the Rivals faction. It abstracts the complexity of parsing vehicle configs and assigning crew to specific positions, ensuring vehicles are fully manned by appropriate AI.
Edge Cases:
UAVs: Handled separately via the game's built-in crew creation.
Nested Turrets: The recursive function handles complex turret structures (e.g., a gunner's seat inside a commander's turret).
Helicopter Turrets: The showAsCargo check is skipped for helicopters, ensuring that helicopter copilot/gunner positions are filled.
No Driver: If a vehicle has no driver seat, the driver creation block is skipped.
Network/Serialization: Crew members are spawned and assigned on the server (or the machine running the script). Their positions and states are synchronized by the game engine.
Function: fn_RivalsCrewTypeForVehicle.sqf
What it does: Returns the appropriate unit type string for the crew of a given Rivals vehicle. It uses a lookup table to map vehicle classnames to crew types.

How it does that:

Parameter Validation and Input Prep:

Sqf

Apply
params ["_side", "_vehicle"];
private _sideIndex = [opfor] find _side;
private _typeX = typeOf _vehicle;
Unpacks the side and vehicle. Finds the index of the given side within a hardcoded array [opfor]. This is suspicious—it suggests the system is designed for a single side, likely a bug or oversimplification. It then gets the vehicle's classname.

Lookup and Selection:

Sqf

Apply
A3A_RivalsVehClassToCrew getOrDefault [_typeX,[FactionGet(riv,"unitCrew")]] select _sideIndex;
Lookup: It queries the global hashmap A3A_RivalsVehClassToCrew with the vehicle's class. If the vehicle is not found, it defaults to an array containing the value FactionGet(riv,"unitCrew") (the default crew type for Rivals).
Selection: It selects the entry at _sideIndex. Given the hardcoded [opfor] array, _sideIndex will be 0. So, it always returns the first element of the looked-up array, or the default if not found.
Where it leads:

Called by: fn_RivalsCreateVehicleCrew (to determine _unitType), fn_RivalsSpawnVehicle (to pass to fn_RivalsCreateVehicleCrew).
Calls: FactionGet (macro/function for faction data lookup).
Depends on:
Global hashmap A3A_RivalsVehClassToCrew (must be populated elsewhere, e.g., in initRivalsVehClassToCrew).
Global faction data (via FactionGet).
Modifies: None.
System Role: A simple lookup utility for the Rivals faction's crew type configuration. It allows mapping specific vehicle classes to specific crew types (e.g., special operators for APCs).
Edge Cases:
Undefined Vehicle Class: Returns the default crew type from the Rivals faction.
Single-Side Design: The hardcoded [opfor] array and select _sideIndex logic is fragile. If called for any side other than opfor, it would return nil (since [opfor] find on a different side returns -1, which is an invalid array index). This indicates the function may only be intended for opfor side, or the [opfor] array is a placeholder bug.
Network/Serialization: Pure lookup, no network implications.
Function: fn_RivalsSpawnGroup.sqf
What it does: Spawns a group of Rivals units at a given position, with a predefined unit type composition and appropriate military ranks.

How it does that:

Parameter and Group Initialization:

Sqf

Apply
params ["_positionX","_sideX","_typesX"];
private _groupX = createGroup _sideX;
Unpacks the position, side, and an array of unit types (_typesX) to spawn. Creates a new group on the specified side.

Rank Assignment Logic:

Sqf

Apply
private _ranks = ["LIEUTENANT","SERGEANT","CORPORAL"];
private _countX = count _typesX;
if (_countX < 4) then {
    _ranks = _ranks - ["LIEUTENANT","SERGEANT"];
} else {
    if (_countX < 8) then {
        _ranks = _ranks - ["LIEUTENANT"]
    };
};
private _countRanks = (count _ranks - 1);
Defines a default rank progression (Officer, Sergeant, Corporal). Adjusts the ranks based on group size:

Small groups (<4): Only Corporals.
Medium groups (4-7): Sergeants and Corporals.
Large groups (>=8): All three ranks.
Unit Creation and Assignment Loop:

Sqf

Apply
for "_i" from 0 to (_countX - 1) do {
    _unit = [_groupX, (_typesX select _i), _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    _unit allowDamage false;
    if (_i <= _countRanks) then { 
        _unit setRank (_ranks select _i) 
    };
    if ((_typesX select _i) in FactionGet(all,"SquadLeaders")) then {
        _groupX selectLeader _unit
    };
    sleep 0.25;
};
Iterates through each unit type in _typesX:

Creates the unit using A3A_fnc_createUnit (this is a crucial call—it's the generic unit creation function, not the Rivals-specific one, indicating _typesX likely contains classnames or standardized loadout types).
Temporarily disables damage during spawn to prevent premature death.
Assigns a rank if there are ranks left in the progression.
Checks if the unit is a squad leader (based on a faction-defined list) and, if so, sets them as the group leader.
Includes a 0.25-second delay to prevent performance issues.
Finalization:

Sqf

Apply
{ _x allowDamage true } forEach units _groupX;
_groupX
Re-enables damage for all group members after spawning is complete and returns the group.

Where it leads:

Called by: Mission scripts that generate Rivals infantry groups, such as RivalsSpawnVehicle (for cargo groups) or specific mission types (e.g., RIV_ATT_Cell).
Calls: createGroup, A3A_fnc_createUnit (the generic one), selectLeader.
Depends on: FactionGet(all,"SquadLeaders") (to identify leader units).
Modifies:
Creates a new group object.
Creates multiple unit objects and adds them to the group.
Sets unit ranks and group leadership.
Modifies unit damage state temporarily.
System Role: The standard infantry group spawning function for Rivals. It ensures groups have a logical command structure (ranks) and a designated leader.
Edge Cases:
If _typesX is empty, the loop does not run, and an empty group is returned.
If no unit matches the squad leader list, the group will not have an explicit leader until the game assigns one.
The allowDamage toggle is a common technique to prevent spawning issues (e.g., units dying from splash damage or physics glitches during spawn).
Network/Serialization: Group and units are created on the server. Their states are synchronized.
Function: fn_RivalsSpawnVehicle.sqf
What it does: Spawns a Rivals vehicle with appropriate crew, handling precise positioning, aircraft physics, and side-specific crew type determination.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_pos", "_azi", "_type", "_group", ["_precise", false], "_unitType"];
if (
    isNil "_pos"
    || {isNil "_azi"}
    || {isNil "_type"}
    || {isNil "_group"}
) exitWith { Error_4(...) };
Unpacks parameters and validates that essential ones are not nil. Exits with an error message if validation fails.

Side and Simulation Determination:

Sqf

Apply
private _side = if (_group isEqualType sideUnknown) then { _group } else { Rivals };
private _sim = getText(configFile >> "CfgVehicles" >> _type >> "simulation");
Determines the side for the group (if input is a side, use it; otherwise, assume Rivals). Gets the vehicle's simulation type (e.g., "airplane", "helicopter", "car").

Vehicle Creation and Initial Setup: A switch statement on _sim handles different vehicle types:

Air Vehicles (airplane, helicopter):
Sqf

Apply
_velocity = getNumber(configFile >> "CfgVehicles" >> _type >> "stallSpeed") / 3.6 * 1.1;
_veh = createVehicle [_type, _pos, [], 0, "FLY"];
if (count _pos == 3 && (_pos#2) > 100) then { _veh setPos _pos; };
Sets an initial velocity (110% of stall speed in m/s) for realism. Spawns the vehicle in the air (FLY). If a high altitude is specified, sets the position explicitly.
Ground/Water Vehicles:
Sqf

Apply
_veh = createVehicle [_type, _pos, [], 0, "NONE"];
Spawns the vehicle on the ground/water.
All vehicles then have their direction set: _veh setDir _azi;
Precise Positioning and Velocity Application:

Sqf

Apply
if (_precise) then { _veh setPos _pos; };
_veh setVelocityModelSpace [0, _velocity, 0];
If _precise is true, it overrides the initial spawn position (useful for airports). Applies the calculated velocity in the forward model direction.

Crew Type and Creation:

Sqf

Apply
if (isNil "_unitType") then {
    _unitType = [_side, _veh] call A3A_fnc_RivalsCrewTypeForVehicle;
};
_group = [_group, _veh, _unitType] call A3A_fnc_RivalsCreateVehicleCrew;
If no crew type is provided, it calls fn_RivalsCrewTypeForVehicle to determine the correct unit type. Then, it calls fn_RivalsCreateVehicleCrew to actually create and assign the crew.

Output:

Sqf

Apply
[_veh, crew _veh, _group];
Returns an array containing the vehicle object, the crew array, and the group object.

Where it leads:

Called by: Mission generation scripts (e.g., RIV_ATT_Cell, RIV_ATT_Hideout, RIV_AS_Traitor), and potentially mission frameworks that spawn Rivals vehicles.
Calls:
A3A_fnc_RivalsCrewTypeForVehicle (if _unitType is nil).
A3A_fnc_RivalsCreateVehicleCrew (always).
Depends on:
Vehicle configuration data (simulation type, stall speed).
fn_RivalsCreateVehicleCrew and fn_RivalsCrewTypeForVehicle for crew spawning.
Global side variable Rivals (likely defined as opfor).
Modifies:
Creates a vehicle object and a group object (if input was a side).
Modifies the vehicle's position, direction, and velocity.
Spawns crew members via fn_RivalsCreateVehicleCrew.
System Role: The high-level wrapper for spawning any Rivals vehicle, from ground transport to air assets. It handles all pre- and post-creation logic, making it the standard tool for vehicle generation.
Edge Cases:
High-Altitude Air Vehicles: The logic to set position after creation for altitudes >100m is critical to prevent spawning at default altitude and falling.
Ground Vehicle Spawning: Spawns at the exact position unless _precise is false, in which case the engine will find a safe position (handled by createVehicle with NONE).
Input Validation: The function is robust against nil inputs for critical parameters.
Network/Serialization: Vehicle and crew are spawned on the server. Their initial state (position, velocity) is synchronized. Subsequent movement is controlled by AI.

fn_safeVehicleSpawn.sqf
What it does: This function spawns a vehicle in a safe location, attempting to find a position free of collisions. It is designed to handle both land and air vehicles, utilizing a custom collision detection function. The function iterates through multiple attempts to find a suitable spawn point. If no collision-free position is found after the specified attempts, and the _force parameter is true, it will spawn the vehicle at the closest available position without further collision checks.

How it does that:

1. Parameter Validation and Initial Setup The function accepts the vehicle type, center position, search radius, number of attempts, and a force flag.

Sqf

Apply
params ["_vehicleType", "_pos", ["_radius", 0], ["_attempts", 3], ["_force", false]];

private _spawnPosition = [];
private _willCollide = true;
It initializes _spawnPosition as an empty array and _willCollide as true, assuming a collision until proven otherwise.

2. Vehicle Creation and Initial Positioning A temporary vehicle object is created to act as a reference for collision detection. Depending on whether it is an air vehicle, it is created with the "FLY" or "CAN_COLLIDE" mode. Air vehicles are placed at height 100, and the target position _pos is adjusted accordingly.

Sqf

Apply
private _vehicle = objNull;
if(_vehicleType isKindOf "Air") then
{
    _vehicle = createVehicle [_vehicleType, [0,0,100], [], 0, "FLY"];
    _pos = _pos vectorAdd [0, 0, 100];
}
else
{
    _vehicle = createVehicle [_vehicleType, [0,0,100], [], 0, "CAN_COLLIDE"];
};
Simulation is immediately disabled to save performance and prevent physics interactions during the search process.

Sqf

Apply
_vehicle enableSimulation false;
3. Search Loop for Safe Position The function iterates up to _attempts times to find a valid spawn position.

Sqf

Apply
private _finished = false;
for "_i" from 1 to _attempts do {
Inside the loop, a random offset is applied to the target position to vary the search area, preventing findEmptyPosition from returning the same spot repeatedly.

Sqf

Apply
	_spawnPosition = _pos vectorAdd [random (_radius*2) - _radius, random (_radius*2) - _radius, 0];
If the vehicle is not an air vehicle, findEmptyPosition is called. Note that this command searches strictly on the ground regardless of input height.

Sqf

Apply
	if !(_vehicleType isKindOf "Air") then {
		_spawnPosition = _spawnPosition findEmptyPosition [0, (_radius / 2), _vehicleType];
	};
If a position is found (_spawnPosition is not an empty array), the custom A3A_fnc_vehicleWillCollideAtPosition function is called to check for collisions using the temporary vehicle object. If no collision is detected (_willCollide is false), the loop terminates.

Sqf

Apply
	if !(_spawnPosition isEqualTo []) then {
		_willCollide = [_vehicle, _spawnPosition] call A3A_fnc_vehicleWillCollideAtPosition;
		_finished = !_willCollide;
	};

	if (_finished) exitWith {};
};
4. Force Spawn Logic If the loop completes without finding a collision-free position (_willCollide is still true) and the _force parameter is true, the function resets _spawnPosition to the original _pos (if _spawnPosition is empty) and sets _willCollide to false, overriding the collision warning.

Sqf

Apply
if (_willCollide && _force) then {
	_spawnPosition = [_spawnPosition, _pos] select (_spawnPosition isEqualTo []);
	_willCollide = false;
};
5. Final Output If _willCollide is false, the temporary vehicle is moved to the validated _spawnPosition, simulation is re-enabled, and the vehicle object is returned.

Sqf

Apply
if !(_willCollide) exitWith {
	_vehicle setPos _spawnPosition;
	_vehicle enableSimulation true;
	_vehicle;
};
If the vehicle is deemed to collide and force is false, the temporary vehicle is deleted, and objNull is returned.

Sqf

Apply
deleteVehicle _vehicle;
objNull;
Where it leads:

Calls:
A3A_fnc_vehicleWillCollideAtPosition: Uses a temporary vehicle object and a target position to determine if the vehicle will physically intersect with terrain or other objects.
Dependencies:
This function is a low-level utility used by functions like fn_spawnVehicleAtMarker and likely called during mission generation or dynamic spawning where precise placement is required.
System Fit:
It acts as a robust wrapper around the engine's findEmptyPosition and custom collision logic, essential for preventing vehicle spawn bugs (clipping) in the mod.
Global Variables:
None modified directly.
Network/Scope:
Local execution. The vehicle creation and position checks happen entirely on the calling machine (Server or HC).
fn_singleAttack.sqf
What it does: This function orchestrates a small, single-wave attack force against a specific map marker. It spawns a mixed group of vehicles and infantry, monitors the combat progress, and manages the cleanup (despawn) of units after the objective is either captured, defeated, or times out.

How it does that:

1. Validation and Setup It checks if the attacking faction (Occupants or Invaders) has been defeated in the current campaign. If so, it aborts immediately.

Sqf

Apply
if ((_side == Occupants && areOccupantsDefeated) || {(_side == Invaders && areInvadersDefeated)}) exitWith {
    ServerInfo_1("%1 faction was defeated earlier, aborting single attack.", str _side);
};
It retrieves the target position and logs the start of the attack.

Sqf

Apply
private _targPos = markerPos _mrkDest;
ServerInfo_1("Starting attack with parameters %1", _this);
2. Attack Force Creation The function determines the nearest available airbase for the attacking side.

Sqf

Apply
private _airbase = [_side, markerPos _mrkDest] call A3A_fnc_availableBasesAir;
It calls A3A_fnc_createAttackForceMixed to generate the vehicles and groups. The parameters define it as a defense-oriented force (transport/logistics), with the attack type labeled "CounterAttack".

Sqf

Apply
private _data = [_side, _airbase, _mrkDest, "defence", _vehCount, 0, [], "CounterAttack", _reveal] call A3A_fnc_createAttackForceMixed;
_data params ["", "_vehicles", "_crewGroups", "_cargoGroups"];
3. Combat Monitoring Loop The function sets up a despawn timer (2700 seconds / 45 minutes) and collects all soldiers from the cargo groups into a single array for tracking.

Sqf

Apply
private _endTime = time + 2700;
private _victory = false;
private _soldiers = [];
{ _soldiers append units _x } forEach _cargoGroups;
It enters a loop that checks the status every 30 seconds:

Victory: Checks if the marker side has changed to the attacker's side.
Defeat: Checks if the number of fighting soldiers drops below 25% of the original count.
Timeout: Checks if the current time exceeds _endTime.
Sqf

Apply
while {true} do
{
    private _markerSide = sidesX getVariable _mrkDest;
    if(_markerSide == _side) exitWith { ... };

    private _curSoldiers = { !fleeing _x and _x call A3A_fnc_canFight } count _soldiers;
    if (_curSoldiers < count _soldiers * 0.25) exitWith { ... };
    if(_endTime < time) exitWith { ... };

    // Attempt to flip marker
    [_mrkDest, _markerSide] remoteExec ["A3A_fnc_zoneCheck", 2];
    sleep 30;
};
4. Despawn and Cleanup Once the loop exits (regardless of reason), the function triggers despawn routines for all spawned entities.

Vehicles are sent to A3A_fnc_VEHDespawner.
Crew groups are sent back to their base via A3A_fnc_enemyReturnToBase.
Cargo groups are returned to base or (if victory was achieved) the target marker position.
Sqf

Apply
{ [_x] spawn A3A_fnc_VEHDespawner } forEach _vehicles;
{ [_x] spawn A3A_fnc_enemyReturnToBase } forEach _crewGroups;
{
    [_x, [nil, _mrkDest] select _victory] spawn A3A_fnc_enemyReturnToBase;
    sleep 10;
} forEach _cargoGroups;
Where it leads:

Calls:
A3A_fnc_availableBasesAir: Finds a suitable airbase to spawn from.
A3A_fnc_createAttackForceMixed: Spawns the actual vehicles and units.
A3A_fnc_canFight: Checks if a unit is combat effective.
A3A_fnc_zoneCheck: Updates zone status on the server.
A3A_fnc_VEHdespawner: Handles vehicle cleanup if abandoned.
A3A_fnc_enemyReturnToBase: Sends AI units back to their spawn point.
Dependencies:
Relies on sidesX global variable for marker ownership.
Used by the mission system to defend against rebel attacks.
System Fit:
Part of the dynamic response system. It is a lighter version of fn_wavedAttack, used for smaller skirmishes or specific event triggers.
Global Variables:
Reads sidesX (Global) and areOccupantsDefeated/areInvadersDefeated (Global).
Modifies none directly.
Network/Scope:
Executed on Server or HC.
Uses remoteExec to trigger A3A_fnc_zoneCheck on Server (ID 2) to update marker ownership.
fn_spawnGroup.sqf
What it does: This function creates a group on a specific side and populates it with units of defined types. It assigns ranks to the first few units based on the group size and automatically designates a Squad Leader if the unit type is defined as such in the faction configuration.

How it does that:

1. Group Creation and Rank Configuration The function creates a new group for the given side.

Sqf

Apply
private _groupX = createGroup _sideX;
It determines the rank structure based on the number of units in the group. Smaller groups lack Lieutenants and Sergeants; medium groups lack Lieutenants.

Sqf

Apply
private _ranks = ["LIEUTENANT","SERGEANT","CORPORAL"];
private _countX = count _typesX;

if (_countX < 4) then {
	_ranks = _ranks - ["LIEUTENANT","SERGEANT"];
} else {
	if (_countX < 8) then {
		_ranks = _ranks - ["LIEUTENANT"]
	};
};
private _countRanks = (count _ranks - 1);
2. Unit Spawning Loop The function iterates through the provided _typesX array.

Sqf

Apply
for "_i" from 0 to (_countX - 1) do {
For each entry, it calls A3A_fnc_createUnit to spawn the unit. Damage is initially disabled to prevent death during spawn animations or placement.

Sqf

Apply
	_unit = [_groupX, (_typesX select _i), _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
	_unit allowDamage false;
It assigns ranks to the first units in the group based on the previously calculated rank list.

Sqf

Apply
	if (_i <= _countRanks) then { 
		_unit setRank (_ranks select _i) 
	};
It checks if the current unit type is defined as a Squad Leader in the faction data (using FactionGet). If so, it sets this unit as the group leader.

Sqf

Apply
	if ((_typesX select _i) in FactionGet(all,"SquadLeaders")) then {
		_groupX selectLeader _unit
	};
A small delay is added to prevent server overload during mass spawning.

Sqf

Apply
	sleep 0.25;
};
3. Finalization Once all units are spawned, damage is re-enabled for all units in the group, and the group object is returned.

Sqf

Apply
{_x allowDamage true} forEach units _groupX;
_groupX
Where it leads:

Calls:
A3A_fnc_createUnit: The core unit spawning function.
FactionGet: Accesses global faction configuration data.
Dependencies:
Used by A3A_fnc_createAttackForceLand, A3A_fnc_createSDKGarrisons, and other functions that need to spawn infantry squads.
System Fit:
A fundamental building block for AI squad generation. It handles the boilerplate of rank assignment and leader selection.
Global Variables:
Reads FactionGet data (Global/Localized).
Network/Scope:
Local execution.
fn_spawnVehicle.sqf
What it does: This function spawns a vehicle with template crew and handles specific initialization logic for different vehicle types (e.g., setting correct velocity for aircraft). It acts as a wrapper around createVehicle and A3A_fnc_createVehicleCrew.

How it does that:

1. Parameter Validation It checks if essential parameters (_pos, _azi, _type, _group) are provided. If any are nil, it logs an error and exits.

Sqf

Apply
if (
    isNil "_pos"
    || {isNil "_azi"}
    || {isNil "_type"}
    || {isNil "_group"}
) exitWith { Error_4("Invalid arguments passed ...") };
It determines the side for the crew, either from the input group or side parameter.

Sqf

Apply
private _side = if (_group isEqualType sideUnknown) then { _group } else { side _group };
2. Vehicle Type Detection and Creation It reads the vehicle's simulation type from the config.

Sqf

Apply
private _sim = getText(configFile >> "CfgVehicles" >> _type >> "simulation");
Using a switch statement, it handles Air vehicles (Airplane, Helicopter) differently from Ground vehicles:

Air Vehicles: Calculates a velocity based on stall speed (110%) and creates the vehicle with "FLY" mode. If the provided position has a height greater than 100m, it forces the vehicle to that specific 3D position immediately.
Ground Vehicles: Created with "NONE" or "CAN_COLLIDE" modes (implied by context, though "NONE" is standard for non-colliding creation).
Sqf

Apply
switch (toLowerANSI _sim) do {
    case "airplane";
    case "airplanex";
    case "helicopterrtd";
    case "helicopterx": {
        _velocity = getNumber(configFile >> "CfgVehicles" >> _type >> "stallSpeed") / 3.6 * 1.1;
        _veh = createVehicle [_type, _pos, [], 0, "FLY"];
        if (count _pos == 3 && (_pos#2) > 100) then {
            _veh setPos _pos;
        };
    };
    default {
        _veh = createVehicle [_type, _pos, [], 0, "NONE"];
    };
};
3. Orientation and Positioning The vehicle's direction is set. If the _precise flag is true, the position is explicitly set again to ensure it matches the input exactly (overriding engine placement).

Sqf

Apply
_veh setDir _azi;
if (_precise) then {
    _veh setPos _pos;
};
4. Velocity and Crew Setup For air vehicles, the calculated velocity is applied to the model space to ensure it is moving forward immediately upon spawn.

Sqf

Apply
_veh setVelocityModelSpace [0, _velocity, 0];
It determines the unit type for the crew (e.g., pilot or driver type) using A3A_fnc_crewTypeForVehicle.

Sqf

Apply
if (isNil "_unitType") then {
    _unitType = [_side, _veh] call A3A_fnc_crewTypeForVehicle;
};
It spawns the crew and groups them.

Sqf

Apply
_group = [_group, _veh, _unitType] call A3A_fnc_createVehicleCrew;
Finally, it returns an array containing the vehicle, crew, and group.

Sqf

Apply
[_veh, crew _veh, _group];
Where it leads:

Calls:
A3A_fnc_crewTypeForVehicle: Determines correct crew class (e.g., specific pilot types).
A3A_fnc_createVehicleCrew: Handles the actual crew spawning and group assignment.
Dependencies:
Used by A3A_fnc_spawnAttackVehicle, A3A_fnc_createAttackForceAir, and mission scripts that need complete vehicle setup.
System Fit:
High-level vehicle spawning utility. It standardizes the process of getting a functional vehicle unit (with crew) into the mission.
Global Variables:
None modified directly.
Network/Scope:
Local execution.
fn_spawnVehicleAtMarker.sqf
What it does: This function spawns a specific vehicle type at a predefined marker. It leverages the marker's spawn point definitions for precise placement on the ground or uses the safe spawn logic for air vehicles.

How it does that:

1. Input Validation It checks if the marker and vehicle strings are non-empty.

Sqf

Apply
if(_vehicle == "" || _marker == "") exitWith
{
    Error_1("Function called with bad input, was %1", _this);
    objNull;
};
2. Air Vehicle Handling If the vehicle type is a subclass of "Air", it calls A3A_fnc_safeVehicleSpawn. It provides a search radius of 100m and 5 attempts, forcing the spawn if necessary. Note that _vehicle is passed as the type string, and getMarkerPos _marker as the position.

Sqf

Apply
if(_vehicle isKindOf "Air") exitWith
{
    _vehicleObj = [_vehicle, getMarkerPos _marker, 100, 5, true] call A3A_fnc_safeVehicleSpawn;
    _vehicleObj;
};
3. Ground Vehicle Handling For ground vehicles, it retrieves the specific spawn parameters for the marker using A3A_fnc_findSpawnPosition. This function returns an array containing the position, direction, and specific spawn place ID.

Sqf

Apply
private _spawnParams = [_marker, "Vehicle"] call A3A_fnc_findSpawnPosition;
If a valid spawn position array is returned, it creates the vehicle inside a isNil block (likely for thread safety or locality reasons). It uses "CAN_COLLIDE" mode but relies on the predefined position being clear.

Sqf

Apply
if(_spawnParams isEqualType []) then
{
    isNil {
        _vehicleObj = createVehicle [_vehicle, (_spawnParams select 0), [], 0, "CAN_COLLIDE"];
        _vehicleObj setDir (_spawnParams select 1);
    };
    _vehicleObj setVariable ["spawnPlace", _spawnParams select 2];
};
It returns the created vehicle object (or objNull if creation failed).

Sqf

Apply
_vehicleObj;
Where it leads:

Calls:
A3A_fnc_safeVehicleSpawn: For air vehicle collision checking.
A3A_fnc_findSpawnPosition: Retrieves predefined spawn locations for markers.
Dependencies:
Relies on spawnPlaces logic defined in the mission initialization.
Used by logistics, vehicle shops, or garrison spawning scripts to place vehicles at specific map locations.
System Fit:
Connects map markers to vehicle instantiation. It is essential for the static vehicle placement system.
Global Variables:
None modified directly.
Network/Scope:
Executed on Server or HC.
fn_spawnVehiclePrecise.sqf
What it does: This function provides a highly configurable method to spawn a vehicle with precise control over position (including coordinate system like AGLS, WORLD), direction (VectorDir or VectorDirAndUp), and aircraft physics (height, velocity). It also supports an empty position search radius and a fallback mechanism for invalid vehicle classnames.

How it does that:

1. Parameter Initialization It sets defaults for all parameters, ensuring the function is robust against missing arguments. It flattens the position array to handle nested inputs.

Sqf

Apply
params [
    ["_className","",[ "" ]],
    ["_position",[0,0,0],[ [] ], [2,3,4]],
    // ... other params with defaults
];
private _position = flatten _position;
2. Aircraft Physics Configuration It checks if _aircraftPhysics is provided. If so, it verifies the vehicle is an air type (Airplane or Helicopter) and enables physics.

Sqf

Apply
if !(isNil {_aircraftPhysics}) then {
    if !((toLower getText(configFile >> "CfgVehicles" >> _className >> "simulation")) in ["airplanex","helicopterrtd","helicopterx"]) exitWith {};
    _addAircraftPhysics = true;
    _createVehicleSpecial = "FLY"; // Air vehicles spawn with "FLY" mode
    
    // Unpack physics parameters: Min Height and Velocity
    _aircraftPhysics params [ ... ];
    _aircraftMinHeight = _aircraftMinHeightIN;
    _velocity = _velocityIN;
};
3. Vehicle Creation with Error Handling The core creation logic is wrapped in isNil to ensure atomic execution. It attempts to create the vehicle at the 2D projection of the input position.

Sqf

Apply
if (isNil {
    _vehicle = createVehicle [_className, _position select [0,2], [], 0, _createVehicleSpecial];
It handles invalid classnames gracefully. If creation fails (returns objNull), it logs an error and attempts to spawn a placeholder vehicle (C_Offroad_01_F). It sets a variable InvalidObjectClassName on the vehicle to allow external systems to detect the fallback.

Sqf

Apply
    if (isNull _vehicle) then {
        Error("InvalidObjectClassName | """+_className+""" does not exist or failed creation.");
        _vehicle = createVehicle ["C_Offroad_01_F", _position select [0,2], [], 0, _createVehicleSpecial];
        _vehicle setVariable ["InvalidObjectClassName",true,true];
    };
It configures randomization and applies the requested direction (handling scalar, VectorDir, or VectorDirAndUp).

Sqf

Apply
    _vehicle setVariable ["BIS_enableRandomization", _enableRandomization];
    switch (true) do {
        case (!(_direction isEqualType [])): {_vehicle setDir _direction};
        case (count _direction isEqualTo 3): {_vehicle setVectorDir _direction};
        default {_vehicle setVectorDirAndUp _direction};
    };
    _vehicle setVelocityModelSpace [0, _velocity, 0];
4. Position Refinement It handles the optional empty position search. If _emptyPositionRadius is greater than 0, it finds an empty position near the initial spot.

Sqf

Apply
    if (_emptyPositionRadius > 0) then {
        [_vehicle,_position] call A3A_fnc_setPos; // Set initial pos to get ground level
        _safePosition = getPos _vehicle findEmptyPosition [0, _emptyPositionRadius, _className];
        if (_safePosition isEqualTo []) then { ... } else {
            _position = _safePosition + ["AGLS"];   // Switch coordinate system to Above Ground Level
        };
    };
It applies the final position using A3A_fnc_setPos (which handles coordinate system logic like AGLS, WORLD, etc.).

Sqf

Apply
    [_vehicle,_position] call A3A_fnc_setPos;
If physics are active, it enforces the minimum height above the ground surface.

Sqf

Apply
    if (_addAircraftPhysics && getPosVisual _vehicle #2 < _aircraftMinHeight) then {
        [_vehicle,[_position#0,_position#1,_aircraftMinHeight],"AGLS"] call A3A_fnc_setPos;
    };
}) exitWith {_vehicle};
5. Return Returns the spawned vehicle object.

Sqf

Apply
_vehicle;
Where it leads:

Calls:
A3A_fnc_setPos: Handles complex coordinate system conversions (AGLS, WORLD, etc.).
Dependencies:
Used for mission-specific vehicle placement, zeus modules, or script-heavy scenarios requiring precise positioning (e.g., vehicles on building roofs, aircraft carriers).
System Fit:
The most flexible spawning function in the library. It bridges the gap between standard engine spawning and complex modding requirements (coordinate systems, precise physics).
Global Variables:
None modified directly.
Network/Scope:
Local execution.
fn_VEHdespawner.sqf
What it does: This function monitors a vehicle and automatically deletes it if it meets specific conditions: it is abandoned (no crew), not attached to anything, and no players (or enemies, depending on the flag) are nearby. It ensures rebel-owned vehicles are ignored.

How it does that:

1. Initial Checks and Locking It first checks if the vehicle belongs to the player side (teamPlayer). If so, it exits immediately.

Sqf

Apply
if (_veh getVariable ["ownerSide", teamPlayer] == teamPlayer) exitWith {};
It checks if a despawner is already running for this vehicle (using the inDespawner variable) to prevent duplicate loops. If not, it locks the vehicle by setting the variable and storing a handle to the running script.

Sqf

Apply
if (!isNil {_veh getVariable "inDespawner"}) exitWith {};
_veh setVariable ["inDespawner", true, true];
_veh setVariable ["A3A_despawnerHandle", _thisScript];
2. Monitoring Loop It runs in a while loop as long as the vehicle is alive.

Sqf

Apply
while {alive _veh} do
{
	sleep 60; // Check every minute
	if !(alive _veh) exitWith {};
3. Despawn Condition Evaluation Inside the loop, it calculates a boolean _despawn using a switch-like call block. The vehicle will NOT despawn if:

Crew is present.
The vehicle is attached to another object.
Any rebel player (teamPlayer) is within distanceSPWN.
If _checkNonRebel is true: It also checks if any Occupant or Invader unit is within distanceSPWN.
Sqf

Apply
	private _despawn = call {
		if ({ alive _x } count crew _veh > 0) exitWith {false};
		if !(isNull attachedTo _veh) exitWith {false};
		if ([distanceSPWN,1,_veh,teamPlayer] call A3A_fnc_distanceUnits) exitWith {false};
		if !(_checkNonRebel) exitWith {true};
		if ([distanceSPWN,1,_veh,Occupants] call A3A_fnc_distanceUnits) exitWith {false};
		if ([distanceSPWN,1,_veh,Invaders] call A3A_fnc_distanceUnits) exitWith {false};
		true;
	};
4. Execution If _despawn evaluates to true, the vehicle is deleted and the loop terminates.

Sqf

Apply
	if (_despawn) exitWith { deleteVehicle _veh };
};
Where it leads:

Calls:
A3A_fnc_distanceUnits: Checks for unit presence within a radius.
Dependencies:
Triggered by A3A_fnc_singleAttack, A3A_fnc_wavedAttack, or vehicle creation scripts to clean up lost assets.
System Fit:
Part of the garbage collection system. It prevents mission bloat by removing unused AI assets.
Global Variables:
Uses distanceSPWN (Global) for the radius check.
Network/Scope:
Local execution on the machine that spawned the vehicle (usually Server or HC).
fn_vehKilledOrCaptured.sqf
What it does: This function handles the logic when a vehicle is destroyed or captured. It updates resource pools, aggression, city support, and triggers side-specific events (e.g., kicking units out of destroyed vehicles, punishing civilian car thieves). It also manages the transition of the vehicle's ownership side.

How it does that:

1. Initialization and Ownership Check It retrieves the vehicle's type and current owner side (defaulting to teamPlayer for Zeus-spawned vehicles). If the vehicle is captured by its current owner, it exits.

Sqf

Apply
params ["_veh", "_sideEnemy", ["_captured", false], ["_killer", objNull]];
private _type = typeof _veh;
private _side = _veh getVariable ["ownerSide", teamPlayer];
if (_captured && (_side == _sideEnemy)) exitWith {};
2. Ejection from Destroyed Vehicles If the vehicle is destroyed (not captured) and has crew, it spawns a separate thread to eject the crew. It waits until the vehicle touches the ground or 30 seconds pass, then forcibly moves units out.

Sqf

Apply
if (!_captured and count crew _veh > 0) then {
	_veh spawn {
		private _timeout = time + 30;
		waitUntil { sleep 2; time > _timeout or isTouchingGround _this };
		while {count crew _this > 0} do {
			moveOut (crew _this # 0);
			sleep 0.5;
		};
	};
};
3. Resource and Aggression Updates (Enemy Vehicles) If the destroyed/captured vehicle belongs to Enemies (Occupants/Invaders) and has a resource cost:

It depletes the enemy resource pool (if not pre-resourced).
It updates "recent damage" stats for the killer.
If the killer was the player team, it increases aggression and adjusts city support.
Sqf

Apply
if ((_side == Occupants || _side == Invaders) && {_vehCost > 0 && {!(_type in (A3A_faction_riv get "vehiclesRivals"))}}) then
{
	// ... resource depletion ...
	[_side, getPos _veh, 2*_vehCost/3, _killer] remoteExec ["A3A_fnc_addRecentDamage", 2];

	if (_sideEnemy != teamPlayer) exitWith {};

    [_side, round (_vehCost / 50), 45] remoteExec ["A3A_fnc_addAggression", 2];
	if (_side == Occupants) then {
		[-_vehCost / 100, _vehCost / 100, position _veh] remoteExec ["A3A_fnc_citySupportChange", 2];
	};
};
4. Civilian Vehicle Logic If the vehicle is civilian and captured by the player team:

It reduces city support (punishment for theft).
It reveals the thieves to nearby AI if the city has government support.
Sqf

Apply
if (_side == civilian) then
{
	if (_sideEnemy != teamPlayer) exitWith {};
	[0, -1, _pos] remoteExec ["A3A_fnc_citySupportChange", 2];
	// ... reveal logic ...
};
5. Side Switch (Capture) If the vehicle was captured, it updates the ownerSide variable globally.

Sqf

Apply
if (_captured) then
{
	if (_sideEnemy == teamPlayer) then {
		// Disable despawner if it was running
		private _despawnerHandle = _veh getVariable "A3A_despawnerHandle";
		if (!isNil "_despawnerHandle") then { terminate _despawnerHandle; _veh setVariable ["A3A_despawnerHandle", nil]; };
	};
	// Do the actual side-switch
	_veh setVariable ["ownerSide", _sideEnemy, true];
};
Where it leads:

Calls:
A3A_fnc_addEnemyResources: Modifies enemy resource pool.
A3A_fnc_addRecentDamage: Logs damage for retaliation.
A3A_fnc_addAggression: Updates global aggression level.
A3A_fnc_citySupportChange: Updates local city loyalty.
Dependencies:
Connected to the Killed and Captured event handlers on vehicles.
System Fit:
Core economy and conflict simulation script. It translates physical actions (destroying a tank) into numerical changes in the campaign layers (resources, aggression, support).
Global Variables:
Modifies ownerSide on the vehicle object.
Triggers remote execution to modify global campaign stats.
Network/Scope:
Executes locally where the event happened, but uses remoteExec to update global state on the Server (ID 2).
fn_wavedAttack.sqf
What it does: This function manages a large-scale, multi-wave attack against a target marker. It spawns land, air, and support units, manages wave timers, monitors combat status, and handles cleanup. It is significantly more complex than fn_singleAttack, handling logistics, air support coordination, and artillery requests.

How it does that:

1. Initialization and Task Creation It sets up the attack environment and creates a task for rebels (or a notification for enemy-vs-enemy attacks). It calculates a "reveal" value for radio intercepts.

Sqf

Apply
forcedSpawn pushBack _mrkDest; publicVariable "forcedSpawn";
// ... task creation logic ...
private _reveal = call { ... };
2. Wave Loop Setup It initializes arrays to track all spawned entities (_allCargoGroups, _allVehicles, etc.) and sets up the main loop _wave.

Sqf

Apply
private _allCargoGroups = [];
private _allCrewGroups = [];
private _allVehicles = [];
private _attackHelis = [];
private _wave = 1;
while {_wave <= _maxWaves and !_victory} do { ... }
3. Wave Composition Calculation Inside the loop, it calculates the number of vehicles for the current wave, scaling with player count and tier.

Sqf

Apply
private _vehCount = round (2 + random 1 + 3*A3A_balancePlayerScale);
if (_targside != teamPlayer) then { _vehCount = 5 + round (random 2) };
if (_wave == 1) then { _vehCount = _vehCount + 2 };
It checks A3A_activeSupports to determine how many air assets are already available and calculates how many new supports (UAV, CAS, AH) are needed.

Sqf

Apply
private _countNewSupport = 0;
call {
    // ... check active supports and attack helis ...
    private _remSupports = (count _airSupports + count _attackHelis);
    private _reqSupports = round (_vehCount * (0.1 + random 0.1 + (5 + tierWar) * 0.025) * ([1, 0.4] select _lowAir));
    _countNewSupport = 1 max (_reqSupports - _remSupports);
};
_vehCount = _vehCount - _countNewSupport;
4. Spawning Land and Air Units It calls A3A_fnc_createAttackForceMixed to spawn the ground convoy and transports.

Sqf

Apply
private _data = [_side, _mrkOrigin, _mrkDest, "attack", _vehCount, _minDelay, ["noairsupport"], "MajorAttack", _reveal] call A3A_fnc_createAttackForceMixed;
_data params ["", "_newVehicles", "_crewGroups", "_cargoGroups"];
It then spawns additional air supports (Attack Helis) by calling A3A_fnc_createAttackForceAir.

Sqf

Apply
if (_newAttackHelis > 0) then {
    private _data = [_side, _mrkOrigin, _mrkDest, "attack", _newAttackHelis, _newAttackHelis, 2] call A3A_fnc_createAttackForceAir;
    // ... append to tracking arrays ...
};
It also requests artillery support via A3A_fnc_requestArtillery.

Sqf

Apply
[_side, _target, "attack", _wave min 4, 0, 0] call A3A_fnc_requestArtillery;
5. Wave Monitoring It tracks the total number of soldiers in the wave and monitors the battle. The loop terminates if:

The marker is captured (_victory = true).
Soldier count drops below 25%.
A 15-minute timeout is reached.
Sqf

Apply
while {true} do {
    private _markerSide = sidesX getVariable _mrkDest;
    if(_markerSide == _side) exitWith { _victory = true; };
    private _curSoldiers = { !fleeing _x and _x call A3A_fnc_canFight } count _soldiers;
    if (_curSoldiers < count _soldiers * 0.25) exitWith { ... };
    if(_timeout < time) exitWith { ... };
    // ... zone check ...
    sleep 10;
};
6. Conclusion and Cleanup If victory is achieved, it updates task status and awards score/money to rebels. If defeated, it calls A3A_fnc_minefieldAAF (likely to mine the area around the objective). It then triggers the despawn routines for all tracked vehicles and groups.

Sqf

Apply
{ [_x] spawn A3A_fnc_VEHDespawner } forEach _allVehicles;
{ [_x] spawn A3A_fnc_enemyReturnToBase } forEach _allCrewGroups;
{
    [_x, [nil, _mrkDest] select _victory] spawn A3A_fnc_enemyReturnToBase;
    sleep 10;
} forEach _allCargoGroups;
Finally, it resets global flags (bigAttackInProgress, forcedSpawn).

Sqf

Apply
bigAttackInProgress = false; publicVariable "bigAttackInProgress";
forcedSpawn = forcedSpawn - [_mrkDest]; publicVariable "forcedSpawn";
Where it leads:

Calls:
A3A_fnc_calculateSupportCallReveal: Determines radio interception chance.
A3A_fnc_createAttackForceMixed: Spawns ground/transport units.
A3A_fnc_createSupport: Creates UAV/CAS/ASF support requests.
A3A_fnc_createAttackForceAir: Spawns attack helicopters.
A3A_fnc_requestArtillery: Calls in artillery strikes.
A3A_fnc_minefieldAAF: Lays mines after defeat.
A3A_fnc_VEHdespawner: Cleans up vehicles.
A3A_fnc_enemyReturnToBase: Sends survivors home.
Dependencies:
Used for major campaign attacks against strongholds.
System Fit:
The "Boss" of the attack system. It integrates support systems, garrison spawning, and economy costs into a single cohesive event.
Global Variables:
Modifies forcedSpawn, bigAttackInProgress, A3A_supportStrikes, A3A_activeSupports.
Network/Scope:
Server/HC. Uses publicVariable to update global state for all clients.
fn_WPCreate.sqf
What it does: This function creates a path of waypoints for a group from an origin to a destination. It utilizes a pathfinding algorithm to find a route over roads or terrain, then simplifies the path to reduce the number of waypoints for performance.

How it does that:

1. Parameter Handling It accepts either marker names or position arrays for origin and destination, converting them to positions if necessary.

Sqf

Apply
private _posOrigin = if(_origin isEqualType "") then {getMarkerPos _origin} else {_origin};
private _posDestination = if(_destination isEqualType "") then {getMarkerPos _destination} else {_destination};
2. Pathfinding It calls A3A_fnc_findPath to calculate the route. It then trims the path using A3A_fnc_trimPath (removing unnecessary nodes).

Sqf

Apply
private _path = [_posOrigin, _posDestination] call A3A_fnc_findPath;
_path = [_path] call A3A_fnc_trimPath;
If the pathfinding fails (less than 2 points), it creates a single waypoint at the destination.

Sqf

Apply
if(count _path < 2) exitWith {
    private _wp = _group addWaypoint [_posDestination, 0];
    _wp setWaypointBehaviour "SAFE";
    _group setCurrentWaypoint _wp;
};
3. Path Simplification (Culling) To optimize the path, it removes the starting point (to avoid backtracking) and performs distance-based culling. It iterates through the path, adding a point only if the accumulated distance from the previous point exceeds 400 meters.

Sqf

Apply
_path deleteAt 0;
reverse _path;
private _prevPos = _path deleteAt 0;
private _culledPath = [_prevPos];
private _distToPrev = 0;
{
    _distToPrev = _distToPrev + (_prevPos distance2d _x);
    if (_distToPrev >= 400) then {
        _culledPath pushBack _x;
        _distToPrev = 0;
    };
    _prevPos = _x;
} forEach _path;
_path = _culledPath;
reverse _path;
4. Waypoint Creation It converts the final path array into actual waypoints for the group. It sets the behavior to "SAFE" and speed to "FULL".

Sqf

Apply
private _waypoints = _path apply {_group addWaypoint [ATLtoASL _x, -1]};
{_x setWaypointBehaviour "SAFE"} forEach _waypoints;
{_x setWaypointSpeed "FULL"} forEach _waypoints;
_group setCurrentWaypoint (_waypoints select 0);
Where it leads:

Calls:
A3A_fnc_findPath: Calculates the optimal route using the navigation grid.
A3A_fnc_trimPath: Cleans up the raw path data.
Dependencies:
Used by A3A_fnc_vehicleConvoyTravel and AI movement scripts to guide units.
System Fit:
Part of the pathfinding and navigation system. It abstracts the complexity of the A* algorithm into simple group orders.
Global Variables:
None modified directly.
Network/Scope:
Local execution. Waypoints are local to the group and the machine controlling it.