Function Name: fn_AS_Ambush.sqf
What it does: This function manages the "Assassinate Officer (Ambush)" mission, a timed assassination mission where rebels must intercept and eliminate a high-ranking officer before they reach a destination. It spawns a convoy consisting of an officer vehicle and an escort vehicle, provides a time limit, and sets up task monitoring for success/failure conditions.

How it does that:

Initialization and Parameter Extraction: The function executes on the server only. It accepts a marker name (_missionOrigin) representing the starting location of the convoy.

Sqf

Apply
if (!isServer && hasInterface) exitWith{};
params ["_missionOrigin"];
Info("Ambush Officer mission init.");
Difficulty and Side Determination: It calculates mission difficulty based on the global tierWar variable. It identifies the side controlling the origin marker to determine the enemy faction.

Sqf

Apply
private _difficult = random 10 < tierWar;
private _sideX = if (sidesX getVariable [_missionOrigin,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
Time Limit Calculation: Sets up mission timers. If difficult, the limit is shorter (45 mins) than normal (90 mins). It also calculates a "departing limit" (time before the convoy starts moving).

Sqf

Apply
private _limit = if (_difficult) then { 45 call SCRT_fnc_misc_getTimeLimit } else { 90 call SCRT_fnc_misc_getTimeLimit };
_limit params ["_dateLimitNum", "_displayTime"];
Site Selection: Selects a random destination within a specific distance range (1200-2500m) that is connected by road and controlled by the same side. If no site is found, the mission is cancelled and re-requested.

Sqf

Apply
private _potentialSites = (outposts + milbases + airportsX + resourcesX + factories + seaports) select {
    private _potentialPos = getMarkerPos _x;
    sidesX getVariable [_x,sideUnknown] == _sideX && 
    {[_x, _missionOrigin] call A3A_fnc_arePositionsConnected && 
    {_missionOriginPos distance _potentialPos < 2500 && 
    {_missionOriginPos distance _potentialPos > 1200}}}
};
Objective Marker Creation: Creates a visual marker on the map for the destination. The color matches the enemy side (BLUFOR or OPFOR).

Sqf

Apply
private _officerDestinationMarker = createMarker ["OfficerDestinationMarker", _markerPosition];
_officerDestinationMarker setMarkerType "hd_objective";
_officerDestinationMarker setMarkerColor _markerColor;
Asset Selection: Retrieves classnames from the faction configuration. Difficulty dictates vehicle types (APC vs Truck for escort, Armed vs Unarmed for officer vehicle).

Sqf

Apply
private _escortVehicleClass = if(_difficult) then {selectRandom (_faction get "vehiclesAPCs")} else {selectRandom (_faction get "vehiclesTrucks")};
private _officerVehicleClass = if(_difficult) then { selectRandom (_faction get "vehiclesLightArmed") } else { selectRandom (_faction get "vehiclesLightUnarmed") };
Road Finding: Scans for a road node near the origin marker to spawn the convoy vehicles side-by-side.

Sqf

Apply
private _roads = [];
while {true} do {
    _roads = _missionOriginPos nearRoads _radiusX;
    if (count _roads > 1) exitWith {};
    _radiusX = _radiusX + 50;
};
Task Creation: Creates a task for the rebels with details on the origin, destination, and time limits.

Sqf

Apply
private _taskId = "AS" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [_rebelTaskText, format [localize "STR_A3A_Missions_AS_Ambush_task_header", _faction get "name"], _missionOrigin],
    (position _roadR),
    // ... params
] call BIS_fnc_taskCreate;
Convoy Spawn: Spawns the escort vehicle and infantry squad, then the officer vehicle. The officer is placed into the cargo slot. Logic ensures the officer is invulnerable briefly to prevent instant mission failure if spawned under collision.

Sqf

Apply
private _escortVehicleData = [position _roadE, 0, _escortVehicleClass, _sideX] call A3A_fnc_spawnVehicle;
// ... spawn infantry and assign to escort vehicle
private _officerVehicleData = [position _roadR, 0, _officerVehicleClass, _sideX] call A3A_fnc_spawnVehicle;
private _officer =  [_groupOfficer, _officerClass, position _roadR, [], 0, "NONE"] call A3A_fnc_createUnit;
_officer allowDamage false;
_officer assignAsCargo _officerVeh; 
_officer moveInCargo _officerVeh; 
sleep 2;
_officer allowDamage true;
Convoy Movement: Waits for the "departing limit" or if the officer dies. If the officer is alive, waypoints are added to the destination.

Sqf

Apply
waitUntil {sleep 1;dateToNumber date > _dateLimitNum || {dateToNumber date > _departingDateLimitNum || {!alive _officer}}};
if (alive _officer) then {
    private _officerWP = _officerVehicleGroup addWaypoint [_destinationPosition, 5];
    _officerWP setWaypointType "MOVE";
};
Monitoring and Outcome: Waits for the convoy to reach the destination, time to expire, or the officer to die.

Success: Officer dies. Rewards given (resources, money, score).
Failure: Officer reaches destination or time expires. Penalty applied (aggression increase).
Sqf

Apply
switch(true) do {
    case (_officer inArea _destinationSite || {dateToNumber date > _dateLimitNum}): {
        [_taskId, "AS", "FAILED"] call A3A_fnc_taskSetState;
        [-900, _sideX] remoteExec ["A3A_fnc_timingCA",2];
    };
    case (!alive _officer): {
        [_taskId, "AS", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 600] remoteExec ["A3A_fnc_resourcesFIA",2];
    };
};
Cleanup: Deletes the marker and despawns vehicles/groups after a short delay.

Sqf

Apply
deleteMarker _officerDestinationMarker;
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
Where it leads:

Calls:
A3A_fnc_localizar: Translates marker names.
SCRT_fnc_misc_getTimeLimit: Calculates time limits based on server settings.
A3A_fnc_spawnVehicle: Spawns vehicles with crew.
A3A_fnc_spawnGroup: Spawns infantry groups.
A3A_fnc_NATOinit: Initializes AI units (skills, loadouts).
A3A_fnc_AIVEHinit: Initializes vehicle AI.
A3A_fnc_inmuneConvoy: Sets specific convoy behaviors (immune to damage/repairs).
A3A_fnc_taskCreate, A3A_fnc_taskUpdate, A3A_fnc_taskSetState: Manages the task lifecycle.
A3A_fnc_timingCA: Modifies cooldown timers for enemy attacks.
A3A_fnc_resourcesFIA: Adds resources to HQ.
A3A_fnc_addScorePlayer / A3A_fnc_addMoneyPlayer: Rewards players.
A3A_fnc_vehDespawner / A3A_fnc_groupDespawner: Cleans up entities.
Dependencies: Relies on the global tierWar, sidesX (markers control), Faction config maps, and arrays like outposts, milbases, etc.
Global Variables: Modifies A3A_taskCount (indirectly via task creation).
Network Implications: Uses remoteExec for resource updates and task state changes to ensure all clients see the mission status.
Function Name: fn_AS_Official.sqf
What it does: This function creates a "Assassinate an Official" mission. Unlike the ambush, this is a static assassination mission where a target (official) patrols a specific marker (usually a city) with bodyguards. The rebels must locate and kill the target within a time limit.

How it does that:

Setup and Timing: Determines difficulty and sets a time limit (30 mins hard, 60 mins easy). It identifies the side controlling the marker.

Sqf

Apply
private _difficultX = if (random 10 < tierWar) then {true} else {false};
private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _limit = if (_difficultX) then { 30 call SCRT_fnc_misc_getTimeLimit } else { 60 call SCRT_fnc_misc_getTimeLimit };
Task Creation: Creates a task with a "Kill" type, located at the marker position.

Sqf

Apply
private _taskId = "AS" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[_taskString,format [localize "STR_A3A_Missions_AS_Official_task_header", _faction get "name"],_markerX],_positionX,false,0,true,"Kill",true] call BIS_fnc_taskCreate;
Unit Spawning: Creates a group for the side. Spawns the official unit and at least one bodyguard. If difficult, it spawns 4 additional bodyguards.

Sqf

Apply
private _grp = createGroup _sideX;
private _officialClass = _faction get "unitOfficial";
private _official = [_grp, _officialClass, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
if (_difficultX) then {
    for "_i" from 1 to 4 do {
        _pilot = [_grp, _bodyguardClass, _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    };
};
Patrol Loop: Initiates an A3A_fnc_patrolLoop so the AI group patrols the area around the marker (radius 25-100m, limit 100m).

Sqf

Apply
[_grp, "Patrol_Area", 25, 50, 100, false, [], true] call A3A_fnc_patrolLoop;
Mission Monitoring: Waits for the official to die or time to expire.

Success: Official dead. Calculates rewards based on difficulty (higher rewards for hard mode).
Failure: Time expired. Penalties applied (aggression, negative score).
Sqf

Apply
if (!alive _official) then {
    [_taskId, "AS", "SUCCEEDED"] call A3A_fnc_taskSetState;
    // Rewards...
} else {
    [_taskId, "AS", "FAILED"] call A3A_fnc_taskSetState;
    // Penalties...
};
Cleanup: Deletes all units in the group and removes the task.

Sqf

Apply
{deleteVehicle _x} forEach units _grp;
deleteGroup _grp;
[_taskId, "AS", 1200] spawn A3A_fnc_taskDelete;
Where it leads:

Calls:
SCRT_fnc_misc_getTimeLimit: Time calculation.
A3A_fnc_patrolLoop: AI behavior management.
A3A_fnc_NATOinit: AI initialization.
A3A_fnc_taskSetState: Updates task status.
A3A_fnc_resourcesFIA, A3A_fnc_timingCA, A3A_fnc_addScorePlayer: Reward/Penalty system.
A3A_fnc_addTimeForIdle: Modifies marker idle timer (prevents instant respawn of missions there).
Dependencies: Depends on tierWar and sidesX. Requires the Faction config to have "unitOfficial" defined.
Global Variables: Modifies A3A_taskCount.
Network Implications: All task updates and resource changes are broadcasted via remoteExec.
Function Name: fn_AS_Smasher.sqf
What it does: This is a special "Assassinate Smasher" mission designed for zombie modsets. It spawns a powerful zombie boss (Smasher or Goliath) and spawns AI SF groups to simulate a battle at the location. The player's goal is to kill the Smasher.

How it does that:

Modset Validation: Checks if the civilian faction is marked as non-human and if the required addon (WBK_ZombieCreatures) is loaded. If not, it cancels and re-requests a standard AS mission.

Sqf

Apply
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];
private _hasZAC = ["WBK_ZombieCreatures"] call A3U_fnc_hasAddon;
if (!(_civNonHuman) || !(_hasZAC)) exitWith { ["AS"] remoteExec ["A3A_fnc_missionRequest",2]; };
Wait for Players: Unlike standard missions, this waits until a player is within 600m of the location before spawning the entities. This prevents performance issues and sets the scene.

Sqf

Apply
waitUntil {
    sleep 5;
    ((call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_positionX, 600, 600] isNotEqualTo []) || {dateToNumber date > _dateLimitNum}
};
Entity Spawning:

Easy Mode: Spawns a "Smasher" unit and 4 SF groups to fight it.
Hard Mode: Spawns a "Goliath" unit and an attack helicopter to target the Goliath.
Sqf

Apply
if (_difficultX) then {
    _mutant = [_groupSmasher, "WBK_Goliaph_3", _posTask, [], 0, "NONE"] call A3A_fnc_createUnit;
    // ... Spawn attack helicopter
} else {
    _mutant = [_groupSmasher, "WBK_SpecialZombie_Smasher_3", _posTask, [], 0, "NONE"] call A3A_fnc_createUnit;
    // ... Spawn infantry SF groups
};
Audio/Visual Effects: Calls A3U_fnc_spawnZombieRoar to play sound effects at the mutant's position.

Sqf

Apply
[getPosATL _mutant] call A3U_fnc_spawnZombieRoar;
Mission Monitoring: Waits for the mutant to die or the time limit to expire.

Success: Mutant dies. High rewards (resources, money). Adds city support change (calming effect).
Failure: Time expires. The city is not lost, but the mission fails.
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    [_taskId, "AS", "FAILED", true] call A3A_fnc_taskSetState;
} else {
    [_taskId, "AS", "SUCCEEDED", true] call A3A_fnc_taskSetState;
    // Rewards...
};
Cleanup: Despawns the SF groups, the zombie group, and the helicopter group.

Sqf

Apply
{ [_x] spawn A3A_fnc_groupDespawner; } forEach _groupsSF;
[_groupSmasher] spawn A3A_fnc_groupDespawner;
[_heliGroup] spawn A3A_fnc_groupDespawner;
Where it leads:

Calls:
A3U_fnc_hasAddon: Checks for mod dependency.
A3U_fnc_spawnZombieRoar: Custom zombie audio function.
A3A_fnc_attackHeli: AI helicopter attack logic.
A3U_fnc_attackHeli: Custom targeting logic for the helicopter against the specific zombie unit.
A3A_fnc_citySupportChange: Modifies city loyalty.
Dependencies: Requires the WBK Zombie & Creatures mod. Relies on Faction(civilian) configuration.
Global Variables: None specific beyond standard mission flow.
Network Implications: Standard task and resource broadcasting.
Function Name: fn_AS_specOP.sqf
What it does: Creates an "Assassinate SpecOp Team" mission. The rebels must locate and eliminate an enemy special forces team hiding within a specific marker.

How it does that:

Wait Condition: Uniquely, this mission waits until the marker is no longer spawned (via spawner variable) or is captured by rebels before spawning the team. This prevents the team from spawning while players are miles away.

Sqf

Apply
waitUntil {sleep 1;dateToNumber date > _dateLimitNum or {(spawner getVariable _markerX != 2 and !(sidesX getVariable [_markerX,sideUnknown] == teamPlayer))}};
Team Spawning: Spawns a specialized group (groupSpecOpsRandom) only if the marker is active and not friendly.

Sqf

Apply
if ((spawner getVariable _markerX != 2) and {!(sidesX getVariable [_markerX,sideUnknown] == teamPlayer)}) then {
    private _specOps = selectRandom (_faction get "groupSpecOpsRandom");
    _groupX = [_positionX, _sideX, _specOps] call A3A_fnc_spawnGroup;
    [_groupX, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;
};
Monitoring: Waits for the group to be eliminated, the marker to be captured, or time to expire.

Success: All SpecOps dead. Rewards include city support changes and aggression increase (simulating political fallout).
Failure: Time out or marker captured by player.
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    // Failure: Penalty
} else {
    // Success: Reward
    [_sideX, 10, 60] remoteExec ["A3A_fnc_addAggression", 2];
};
Cleanup: Despawns the group.

Sqf

Apply
[_groupX] spawn A3A_fnc_groupDespawner;
Where it leads:

Calls:
A3A_fnc_spawnGroup: Spawns the SF unit.
A3A_fnc_patrolLoop: AI movement.
A3A_fnc_addAggression: Increases enemy aggression level globally.
Dependencies: Relies on groupSpecOpsRandom existing in the faction config.
Global Variables: sidesX and spawner variables dictate the spawn logic.
Network Implications: Aggression change is broadcasted to the server to affect global game state.
Function Name: fn_AS_Traitor.sqf
What it does: Creates an "Assassinate Traitor" mission. A traitor is hiding inside a building in a city with bodyguards. The player must kill or capture them before they flee to an airbase.

How it does that:

Target Selection: Searches for a suitable house with at least 3 building positions to place the traitor and two bodyguards.

Sqf

Apply
private _houses = (nearestObjects [_positionX, ["house"], _radiusX]) select {!((typeOf _x) in A3A_buildingBlacklist)};
while {count _posHouse < 3} do {
    _houseX = selectRandom _houses;
    _posHouse = _houseX buildingPos -1;
};
Flee Destination: Selects the nearest friendly airport as the escape destination for the traitor.

Sqf

Apply
private _arrayAirports = airportsX select {sidesX getVariable [_x,sideUnknown] == Occupants};
private _base = [_arrayAirports, _positionX] call BIS_Fnc_nearestPosition;
Unit Spawning: Spawns the traitor (marked as Occupant) and two bodyguards inside the house. The traitor is initially invulnerable.

Sqf

Apply
_traitor allowDamage false;
private _sol1 = [_groupTraitor, _bodyguardClass, _posSol1, [], 0, "NONE"] call A3A_fnc_createUnit;
private _sol2 = [_groupTraitor, _bodyguardClass, _posSol2, [], 0, "NONE"] call A3A_fnc_createUnit;
Vehicle Placement: Spawns a vehicle on a nearby road for the traitor to escape in once alerted.

Sqf

Apply
private _veh = _vehType createVehicle _posVeh;
[_veh, Occupants] call A3A_fnc_AIVEHinit;
Patrol Logic: Spawns a random police/squad group to patrol the area.

Sqf

Apply
private _groupX = [_positionX,Occupants, _typeGroup] call A3A_fnc_spawnGroup;
[_groupX, "Patrol_Area", 25, 50, 100, false, [], false] call A3A_fnc_patrolLoop;
Flee Logic: If a player gets close enough (detected via knowsAbout > 1.4), the traitor and bodyguards enable movement AI, get in the vehicle, and drive to the airport.

Sqf

Apply
if ({_traitor knowsAbout _x > 1.4} count ([500,0,_traitor,teamPlayer] call A3A_fnc_distanceUnits) > 0) then {
    _x enableAI "MOVE";
    _traitor assignAsDriver _veh;
    // ... Waypoints to base
};
Outcomes:

Kill/Capture: If the traitor is killed or traitorIntel (global var for capture) is set.
Escape: If traitor reaches the base. This results in high penalties (HQ info loss).
Sqf

Apply
if (!alive _traitor || {traitorIntel}) then {
    // Success: Aggression up, Rewards
} else {
    // Failure: Penalty, Add HQ Info to Occupants
};
Cleanup: Clears global traitorIntel and despawns groups/vehicles.

Sqf

Apply
traitorIntel = false;
publicVariable "traitorIntel";
[_groupX] spawn A3A_fnc_groupDespawner;
Where it leads:

Calls:
A3A_fnc_createRandomIdentity: Generates a unique look for the traitor.
SCRT_fnc_common_addRandomMoneyMagazine: Puts loot on the traitor.
A3A_fnc_guardDog: Spawns a dog with the patrol group (2.5% chance).
A3A_fnc_distanceUnits: Checks for nearby players.
A3A_fnc_addAggression: Modifies global aggression.
Dependencies: Requires a functioning Occupant side with airports. Uses global traitorIntel for capture mechanic.
Global Variables: traitorIntel (read/write), A3A_curHQInfoOcc (modified on failure).
Network Implications: traitorIntel is a public variable. HQ info changes are applied remotely on server.
Function Name: fn_AS_Zombies.sqf
What it does: Creates a "Stop Infestation" mission (Punishment). This mission spawns zombies in a player-owned city. It is essentially a defense/conquest mission against AI zombies.

How it does that:

Validation: Checks if the civilian faction is non-human. Checks if the marker is player-owned. If not, it finds a player-owned city to use instead.

Sqf

Apply
if (_sideX isNotEqualTo teamPlayer) exitWith {
    private _citiesPlayer = citiesX select {sidesX getVariable [_x, sideUnknown] == teamPlayer};
    if (_citiesPlayer isEqualTo []) then { ... exit } else { _markerX = selectRandom _citiesPlayer; };
};
Wait for Player Proximity: Waits for players to enter the city radius before starting.

Sqf

Apply
waitUntil {
    sleep 5;
    ((call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_positionX, 600, 600] isNotEqualTo []) || {dateToNumber date > _dateLimitNum}
};
Zombie Spawning: Calls A3U_fnc_spawnZombieWaves to spawn zombies in waves. The group is created under Invaders (Zombies) to prevent friendly fire if the zombie mod treats them as a separate side, or to simulate a hostile force.

Sqf

Apply
private _groupZombies = createGroup Invaders;
[8, 3, (random [5,7,9]), _positionX, _groupZombies, _taskId] spawn A3U_fnc_spawnZombieWaves;
Mission Monitoring: Waits for the taskID+"_done" variable (set by the wave spawner) to be true (all waves cleared) or time to expire.

Failure: Time runs out. The city is destroyed (destroyedSites), ownership changes to Invaders (Zombies), and garrison is cleared.
Success: Waves cleared. Rewards given.
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    // Failure: City is destroyed, marker changed to Invaders
    destroyedSites = destroyedSites + [_markerX];
    sidesX setVariable [_markerX, Invaders, true];
};
Cleanup: Despawns remaining zombie groups.

Sqf

Apply
[_groupZombies] spawn A3A_fnc_groupDespawner;
Where it leads:

Calls:
A3U_fnc_spawnZombieWaves: Custom function managing the zombie spawning logic.
A3A_fnc_destroyCity: Destroys city structures visually/physically.
A3A_fnc_mrkUpdate: Updates the marker on the map.
Dependencies: Requires attributeCivNonHuman set in civilian faction config.
Global Variables: destroyedSites (array), sidesX (marker ownership), garrison (cleared).
Network Implications: Heavy network usage. Marker ownership changes and destruction are broadcasted. If the zombie wave spawner is local, it handles logic locally, but state changes are server-wide.
Function Name: fn_CON_MilAdmin.sqf
What it does: Creates a "Capture Military Administration" mission. This mission focuses on a specific building object (A3A_milAdministrations) located at a marker. The player must capture the area.

How it does that:

Building Location: Finds the specific building object from the global A3A_milAdministrations array that matches the marker position.

Sqf

Apply
private _milAdministrationIndex = A3A_milAdministrations findIf { _milAdministrationPos distance2D _x < 30 };
private _milAdministration = A3A_milAdministrations select _milAdministrationIndex;
Position Retrieval: Gets garrison positions inside the building (e.g., static weapon slots, entry points).

Sqf

Apply
private _positionsTuple = _milAdministration call SCRT_fnc_common_getMilAdminGarrisonPositions;
private _buildingPositions = _positionsTuple select 0;
Task Creation: Creates a "Capture" task (Attack type).

Sqf

Apply
private _taskId = "CON" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[_textX,_taskName,_marker],_milAdministrationPos,false,0,true,"attack",true] call BIS_fnc_taskCreate;
Monitoring: Waits for the marker ownership to change to teamPlayer or time to expire.

Success: Marker captured. Rewards given, including city support increase.
Failure: Time expired. Penalties applied.
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    [_taskId, "CON", "FAILED"] call A3A_fnc_taskSetState;
    // Penalties...
} else {
    [_taskId, "CON", "SUCCEEDED"] call A3A_fnc_taskSetState;
    // Rewards...
};
Where it leads:

Calls:
SCRT_fnc_common_getMilAdminGarrisonPositions: Extracts architectural data from the building object.
Dependencies: Relies on A3A_milAdministrations being populated (server init).
Global Variables: None specific to mission flow.
Network Implications: Standard task and resource updates.
Function Name: fn_CON_Outpost_Compet.sqf
What it does: Creates a "Competitive Conquest" mission. This is triggered when a frontline outpost is contested. The player must capture the outpost before an opposing AI faction (Occupants vs Invaders) captures it. An AI attack wave is spawned against the outpost.

How it does that:

Determine Opponent: Identifies the opposing side (e.g., if the outpost is Occupied, the opponent is Invaders, and vice versa).

Sqf

Apply
private _markerSide = sidesX getVariable [_markerX, sideUnknown];
private _oppositeside = if (_markerSide == Occupants) then { Invaders } else { Occupants };
Check Defeat Status: Exits if the opposing faction is already defeated in the campaign.

Sqf

Apply
if ((_oppositeside == Occupants && areOccupantsDefeated) || {(_oppositeside == Invaders && areInvadersDefeated)}) exitWith { ... };
Spawn Attack Wave: Calls A3A_fnc_wavedAttack to spawn a wave of AI units attacking the marker.

Sqf

Apply
[_markerX, _airbase, _vehCount] spawn A3A_fnc_wavedAttack;
Monitoring: Waits for the player to capture the marker or time to expire. It does not wait for the AI to capture it (the wave does that automatically if unopposed).

Success: Player captures. Rewards.
Failure: Time expires (implies AI captured it or prevented player capture). Penalties applied.
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    [_taskId, "CON", "FAILED"] call A3A_fnc_taskSetState;
    // Penalties...
    // [_oppositeside, _markerX] spawn A3A_fnc_markerChange; // Commented out in original code, implies logic is handled elsewhere or by the wave
};
Where it leads:

Calls:
A3A_fnc_isFrontlineNoFIA: Checks if the marker is on the frontline.
A3A_fnc_availableBasesAir: Finds an airbase for the AI attack to spawn from.
A3A_fnc_wavedAttack: Spawns the AI assault.
Dependencies: Depends on frontline logic and global defeat flags (areOccupantsDefeated).
Global Variables: Modifies marker ownership (indirectly via gameplay).
Function Name: fn_CON_Outpost_Zombies.sqf
What it does: Creates a "Conquer with Zombies" mission. Visually looks like a standard outpost conquest, but spawns zombies instead of standard garrison. The player must capture the outpost.

How it does that:

Validation: Checks for non-human civilian faction.

Sqf

Apply
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];
if !(_civNonHuman) exitWith { ... };
Wait for Player: Waits for player presence before spawning.

Sqf

Apply
waitUntil { sleep 5; ((call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_positionX, 200, 200] isNotEqualTo []) ... };
Zombie Spawning: Spawns zombie waves. The group side is calculated based on the marker's current side (to ensure zombies are hostile to the player).

Sqf

Apply
private _groupSide = Invaders;
if (_markerSide == Invaders) then { _groupSide = Occupants; };
private _groupZombies = createGroup _groupSide;
[3, 3, (random [5,7,9]), _positionX, _groupZombies] spawn A3U_fnc_spawnZombieWaves;
Monitoring: Waits for the marker to be captured by the player or time to expire.

Success: Rewards.
Failure: Standard outpost capture failure logic (no destruction, unlike the AS_Zombies mission).
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    [_taskId, "CON", "FAILED", true] call A3A_fnc_taskSetState;
} else {
    [_taskId, "CON", "SUCCEEDED", true] call A3A_fnc_taskSetState;
    // Rewards...
};
Where it leads:

Calls:
A3U_fnc_spawnZombieWaves: Spawns the enemy threat.
Dependencies: Requires non-human civilian faction config.
Global Variables: Modifies marker ownership upon success.
Function Name: fn_CON_Outpost.sqf
What it does: Standard "Conquer Outpost" mission. The player must capture a specific outpost/military zone.

How it does that:

Frontline Check: Checks if the outpost is on the frontline. If so, it redirects to the competitive version (CON_Outpost_Compet).

Sqf

Apply
private _zonesFrontline = [_zones select {[_x] call A3A_fnc_isFrontlineNoFIA}];
if (_markerX in _zonesFrontline && !(_markerX in controlsX)) exitWith {
    [["CON_Outpost_Compet"]] remoteExec ["A3A_fnc_scheduler",2];
};
Task Creation: Creates a standard conquest task. Text varies based on if it's a resource, control, or generic outpost.

Sqf

Apply
private _taskId = "CON" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[_textX,_taskName,_markerX],_positionX,false,0,true,"Target",true] call BIS_fnc_taskCreate;
Monitoring: Waits for marker ownership to change to teamPlayer or time to expire.

Success: Rewards given.
Failure: Penalties (aggression increase, city support drop).
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    [_taskId, "CON", "FAILED"] call A3A_fnc_taskSetState;
    // Penalties...
};
Where it leads:

Calls:
A3A_fnc_isFrontlineNoFIA: Checks strategic map state.
A3A_fnc_CON_Outpost_Compet: Redirects to competitive logic if needed.
Dependencies: Depends on map arrays (outposts, resourcesX, controlsX).
Global Variables: Reads sidesX for ownership.

Function Name: fn_convoy.sqf What it does: This function initiates and manages a server-side convoy mission in the Antistasi community, where players must either intercept/destroy or capture/escort a convoy. It handles the complete lifecycle: mission creation, vehicle spawning, movement, objective verification, and cleanup. It is exclusively executed on the server (isServer check) and manages a global flag (A3A_convoyInProgress) to prevent duplicate convoy missions from overlapping.

How it does that: 1. Initial Setup and Validation:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

//Mission: Capture/destroy the convoy
if (!isServer and hasInterface) exitWith {};
if (missionNamespace getVariable ["A3A_convoyInProgress", false]) exitWith {};
params ["_mrkDest", "_mrkOrigin", ["_convoyType", ""], ["_resPool", "legacy"], ["_startDelay", -1], ["_visible", false]];
Implementation: The script includes standard A3A preprocessor directives and fixes line numbers for debugging. It validates that it runs only on the server. If a convoy is already active (A3A_convoyInProgress), it exits immediately to prevent conflict.
Parameters:
_mrkDest: Marker name for the destination.
_mrkOrigin: Marker name for the origin.
_convoyType: Optional string specifying the cargo (e.g., "Ammunition", "Prisoners"). If empty, it's auto-selected.
_resPool: Defines the resource pool ("legacy", "attack", "defense") used for cost calculation.
_startDelay: Time in minutes before the convoy starts moving.
_visible: Boolean to show the convoy's path on the map.
2. Variable Initialization:

Sqf

Apply
private _difficult = if (random 10 < tierWar) then {true} else {false};
private _sideX = if (sidesX getVariable [_mrkOrigin,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _milFaction = Faction(_sideX);
private _rebFaction = Faction(teamPlayer);
private _civFaction = Faction(civilian);
private _civDisabled = (_civFaction getOrDefault ["attributeLowCiv", false] || {_civFaction getOrDefault ["attributeCivNonHuman", false]});

private _posSpawn = getMarkerPos _mrkOrigin;
private _posHQ = getMarkerPos respawnTeamPlayer;

private _soldiers = [];
private _vehiclesX = [];
private _markNames = [];
private _POWS = [];
private _reinforcementsX = [];
Implementation: Determines difficulty based on tierWar. Identifies the side (Occupants or Invaders) based on the origin marker. Loads faction data using Faction() macro. Checks for disabled civilian logic. Initializes spawn positions and empty arrays to track units, vehicles, markers, prisoners, and reinforcements for later cleanup and logic.
3. Global Lock and Time Calculation:

Sqf

Apply
missionNamespace setVariable ["A3A_convoyInProgress", true, true];

if (_startDelay < 0) then { _startDelay = random 5 + ([10, 5] select _difficult) };
private _startDateNum = dateToNumber date + _startDelay * timeMultiplier / (365*24*60);
private _startDate = numberToDate [date select 0, _startDateNum];
private _displayTime = [_startDate] call A3A_fnc_dateToTimeString;

private _nameDest = [_mrkDest] call A3A_fnc_localizar;
private _nameOrigin = [_mrkOrigin] call A3A_fnc_localizar;
[_mrkOrigin, _startDelay + 1] call A3A_fnc_addTimeForIdle;
Implementation: Sets the global flag to prevent overlaps. Calculates the start time in "date" format (converted from epoch-like dateToNumber) for the UI. Translates marker names to localized strings using A3A_fnc_localizar. Calls A3A_fnc_addTimeForIdle to prevent the origin marker from becoming dormant (losing garrison/vehicles) while the convoy is spawning.
4. Convoy Type Determination:

Sqf

Apply
private _convoyTypes = [];
switch (true) do {
    case ((_mrkDest in airportsX) or {_mrkDest in outposts or {_mrkDest in milbases}}): {
        _convoyTypes append ["Ammunition", "Armor", "Repair"];
        if (_mrkDest in outposts && {((count (garrison getVariable [_mrkDest, []])) / 2) >= [_mrkDest] call A3A_fnc_garrisonSize}) then {
            _convoyTypes pushBack "Reinforcements";
        };
    };
    // ... similar cases for citiesX, resourcesX, factories, and default
};
if (_convoyType isEqualTo "") then { 
    _convoyType = selectRandom _convoyTypes 
};
Implementation: Uses a switch statement to populate _convoyTypes based on the destination marker category (Airport, Outpost, City, etc.). Checks garrison levels to see if "Reinforcements" are valid. If no type was passed, it selects a random one from the list.
5. Mission Text and Objective Setup:

Sqf

Apply
private _textX = "";
private _taskState = "CREATED";
// ... other task vars
private _typeVehObj = "";
private _vehiclePool = [];

// Cleanup invalid arrays
{
    if (_x in keys _civFaction && {(_civFaction get _x) isEqualTo []}) then { _civFaction deleteAt _x };
} forEach ["vehiclesCivMedical", "vehiclesCivIndustrial", "vehiclesCivSupply"];

switch (toLowerANSI _convoyType) do {
    case "ammunition": {
        _textX = format [localize "STR_A3A_Missions_AS_Convoy_task_dest_ammo",_nameOrigin,_displayTime,_nameDest];
        _taskTitle = localize "STR_A3A_Missions_AS_Convoy_task_header_ammo";
        _taskIcon = "rearm";
        _typeVehObj = selectRandom (_milFaction get "vehiclesAmmoTrucks");
    };
    // ... cases for fuel, repair, armor, prisoners, reinforcements, money, supplies
};
Implementation: Defines task metadata. Cleans faction hashmaps of empty vehicle arrays to prevent errors. The switch statement selects the objective vehicle type (_typeVehObj) based on the convoy type, accessing faction-specific vehicle pools (e.g., vehiclesAmmoTrucks, vehiclesArmor). It also sets the localized task text and icon.
6. Route Finding and Pathfinding:

Sqf

Apply
private _posOrigin = navGrid select ([_mrkOrigin] call A3A_fnc_getMarkerNavPoint) select 0;
private _posDest = navGrid select ([_mrkDest] call A3A_fnc_getMarkerNavPoint) select 0;
private _taskId = "CONVOY" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[_textX,_taskTitle,_mrkDest],_posDest,false,0,true,_taskIcon,true] call BIS_fnc_taskCreate;
[_taskId, "CONVOY", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

private _route = [_posOrigin, _posDest] call A3A_fnc_findPath;
Implementation: Converts marker names to positions on the navGrid using A3A_fnc_getMarkerNavPoint. Creates a task for the player side using BIS_fnc_taskCreate and updates it remotely. Calculates the driving route using A3A_fnc_findPath (A* pathfinding on the road network).
7. Visual Path Rendering (Optional):

Sqf

Apply
private _markers = [];
if (_visible) then {
    private _markerColor = if (_sideX == Occupants) then {colorOccupants} else {colorInvaders};
    { 
        private _waypointPosition = _x select 0;  
        private _marker = createMarker [format ["%1convoyNode%2", random 10000, random 10000], _waypointPosition]; 
        _marker setMarkerType "hd_dot"; 
        // ... marker properties
        _markers pushBack _marker;
    } forEach _route;
};
Implementation: If _visible is true, it iterates through the calculated route and creates temporary markers (dots) to visualize the path on the map for debugging or player awareness.
8. Vehicle Spawning Setup:

Sqf

Apply
_route = _route apply { _x select 0 }; // Flatten route to positions
if (_route isEqualTo []) then { _route = [_posOrigin, _posDest] }; // Fallback

private _vehPool = ([_sideX, tierWar] call A3A_fnc_getVehiclesGroundTransport) + ([_sideX, tierWar] call A3A_fnc_getVehiclesGroundSupport);
private _pathState = [];
private _resourcesSpent = 0;
Implementation: Flattens the route array (which usually contains position + direction pairs) to just positions. Populates _vehPool with potential escort vehicle types using A3A_fnc_getVehiclesGroundTransport and getVehiclesGroundSupport. Initializes _pathState to persist cursor position during sequential vehicle spawning.
9. Spawning Worker Functions:

_fnc_spawnConvoyVehicle:

Sqf

Apply
private _fnc_spawnConvoyVehicle = {
    params ["_vehType", "_markName"];
    // Find location down route
    _pathState = [_route, [20, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute;
    while {true} do {
        if (count (ASLtoAGL (_pathState#0) nearEntities 10) == 0) exitWith {};
        _pathState = [_route, 10, _pathState] call A3A_fnc_findPosOnRoute;
    };

    private _veh = createVehicle [_vehType, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];
    private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);
    _veh setVectorDirAndUp [_pathState#1, _vecUp];
    _veh allowDamage false;

    private _group = [_sideX, _veh] call A3A_fnc_createVehicleCrew;
    { [_x, nil, nil, _resPool] call A3A_fnc_NATOinit; _x allowDamage false; _x disableAI "MINEDETECTION" } forEach (units _group);
    _soldiers append (units _group);
    (driver _veh) stop true;
    deleteWaypoint [_group, 0];

    [_veh, _sideX, _resPool] call A3A_fnc_AIVEHinit;
    if (_vehType in FactionGet(all,"vehiclesArmor")) then { _veh allowCrewInImmobile true };
    _vehiclesX pushBack _veh;
    _markNames pushBack _markName;
    _veh;
};
Implementation: Uses A3A_fnc_findPosOnRoute to find a spawn point along the path. Avoids collisions with existing entities. Spawns the vehicle, aligns its pitch/roll to the road direction (using vector math), and disables damage temporarily. Spawns AI crew via A3A_fnc_createVehicleCrew and initializes them with A3A_fnc_NATOinit. Disables MINEDETECTION AI to prevent immediate explosions. Stops the driver to prevent movement during spawn. Applies faction-specific vehicle init (A3A_fnc_AIVEHinit) and ensures armor can take crew damage (allowCrewInImmobile).
_fnc_spawnEscortVehicle:

Sqf

Apply
private _fnc_spawnEscortVehicle = {
    private _typeVehEsc = selectRandomWeighted _vehPool;
    private _veh = [_typeVehEsc, _EscortText] call _fnc_spawnConvoyVehicle;
    private _typeGroup = [_typeVehEsc, _sideX] call A3A_fnc_cargoSeats;
    if (count _typeGroup == 0) exitWith {};
    private _groupEsc = [_posSpawn, _sideX, _typeGroup] call A3A_fnc_spawnGroup;
    {[_x, nil, nil, _resPool] call A3A_fnc_NATOinit;_x assignAsCargo _veh;_x moveInCargo _veh;} forEach units _groupEsc;
    _soldiers append (units _groupEsc);
};
Implementation: Selects an escort vehicle type from the pool. Spawns it using the vehicle spawner. Determines how many cargo seats are available via A3A_fnc_cargoSeats. Spawns a group of infantry and moves them into the cargo positions of the escort vehicle.
10. Convoy Composition Spawning:

Sqf

Apply
// Tail escort
[] call _fnc_spawnEscortVehicle;

// Objective vehicle
sleep 2;
private _objText = if (_difficult) then {localize "STR_marker_convoy_objective_space"} else {localize "STR_marker_convoy_objective"};
private _vehObj = [_typeVehObj, _objText] call _fnc_spawnConvoyVehicle;
Implementation: Spawns an initial escort vehicle. Waits 2 seconds to stagger spawning. Spawns the objective vehicle (marked with a different text).
11. Objective Loading Logic:

Prisoners:

Sqf

Apply
if (_convoyType isEqualTo "Prisoners") then {
    private _grpPOW = createGroup teamPlayer;
    for "_i" from 1 to (1+ round (random 11)) do {
        private _unit = [_grpPOW, FactionGet(reb,"unitUnarmed"), _posSpawn, [], 0, "NONE"] call A3A_fnc_createUnit;
        // ... identity setup
        _unit setCaptive true; _unit disableAI "MOVE";
        _unit assignAsCargo _vehObj; _unit moveInCargo [_vehObj, _i + 3];
        // ...
        _POWS pushBack _unit;
    };
};
Implementation: Creates a rebel group for POWs. Spawns unarmed rebel units, sets them as captive, disables their movement AI to keep them in the vehicle, assigns them to the objective vehicle's cargo slots (offset by 3 to leave space for other crew), and tracks them in the _POWS array.
Reinforcements:

Sqf

Apply
if (_convoyType isEqualTo "Reinforcements") then {
    private _typeGroup = [_typeVehObj,_sideX] call A3A_fnc_cargoSeats;
    private _groupEsc = [_posSpawn,_sideX,_typeGroup] call A3A_fnc_spawnGroup;
    {[_x, nil, nil, _resPool] call A3A_fnc_NATOinit;_x assignAsCargo _vehObj;_x moveInCargo _vehObj;} forEach units _groupEsc;
    _soldiers append (units _groupEsc);
    _reinforcementsX append (units _groupEsc);
};
Implementation: Spawns AI infantry to reinforce the destination. They are loaded into the objective vehicle's cargo. Tracked in _reinforcementsX for specific condition checks later.
Money/Supplies (Cargo Crates):

Sqf

Apply
if (_convoyType == "Money") then {
    if (_objectiveIsCargo) then {
        _supObj = "A3AU_moneyCrate_small_01" createVehicle (position _vehObj);
        private _canLoad = [_vehObj, _supObj] call A3A_Logistics_fnc_canLoad;
        if (_canLoad isEqualType []) then {
            // ... clear cargo, set damage, lock inventory
            _supObj call A3A_Logistics_fnc_addLoadAction;
            (_canLoad + [true]) call A3A_Logistics_fnc_load;
        };
    };
    _vehObj setVariable ["A3A_reported", true, true];
};
Implementation: If the vehicle has logistics capacity, it creates a specific crate (A3AU_moneyCrate_small_01). It uses the logistics system to load it into the vehicle. The crate is damaged and locked to prevent looting pre-emptively. The vehicle is marked as "reported" for map filters.
12. Convoy Movement Initialization:

Sqf

Apply
// Initial escort vehicles loop
for "_i" from 1 to _countX do { sleep 2; [] call _fnc_spawnEscortVehicle; };

// Lead vehicle
sleep 2;
// ... type selection logic
private _vehLead = [_typeVehX, _LeadText] call _fnc_spawnConvoyVehicle;

// Resource Cost Application
if (_resPool != "legacy") then {
    private _resources = 10 * count _soldiers;
    { _resources = _resources + (A3A_vehicleResourceCosts getOrDefault [typeOf _x, 0]) } forEach _vehiclesX;
    [-_resources, _sideX, _resPool] remoteExec ["A3A_fnc_addEnemyResources", 2];
};

// Remove spawn protection
sleep 2;
{_x allowDamage true} forEach _vehiclesX;
{_x allowDamage true; if (vehicle _x == _x) then {deleteVehicle _x}} forEach _soldiers;

// Send vehicles after delay
sleep (60*_startDelay);
_route = _route select [_pathState#2, count _route]; // Route slicing to skip already passed points
reverse _convoyVehicles; reverse _markNames;

{
    (driver _x) stop false;
    [_x, _route, _convoyVehicles, 30, _x == _vehObj] spawn A3A_fnc_vehicleConvoyTravel;
    [_x, _markNames#_forEachIndex, false] spawn A3A_fnc_inmuneConvoy;
    sleep 3;
} forEach _convoyVehicles;
Implementation:
Spawns additional escorts and the lead vehicle.
Calculates resource cost based on vehicle types (from A3A_vehicleResourceCosts) and soldier count, subtracting it from the specified _resPool via A3A_fnc_addEnemyResources.
Removes damage protection after 2 seconds of stability.
Waits for the calculated _startDelay.
Slices the _route to remove nodes already traversed during the spawning phase.
Iterates over all vehicles in reverse (to process tail first) and starts two background scripts:
A3A_fnc_vehicleConvoyTravel: Handles the actual driving, formation keeping, and route following.
A3A_fnc_inmuneConvoy: Handles immunity/stuck prevention logic.
13. Termination Conditions and Logic:

Setup:

Sqf

Apply
private _bonus = if (_difficult) then {1.5} else {1};
private _arrivalDist = 100;
private _timeout = time + 3600; // 1 hour real time

private _fnc_applyResults = {
    params ["_success", "_success1", "_adjustCA", "_adjustBoss", "_aggroMod", "_aggroTime", "_type"];
    // ... logic to set task states, adjust resources (A3A_fnc_addMoneyPlayer, A3A_fnc_resourcesFIA), add aggression (A3A_fnc_addAggression)
};
Implementation: Defines a closure fnc_applyResults to handle the messy logic of awarding score/money and updating aggression/counter-attack timers uniformly. Uses _bonus for difficult convoys.
Specific Convoy Type Handlers (Example: Ammunition):

Sqf

Apply
if (_convoyType isEqualTo "Ammunition") then {
    waitUntil {sleep 1; (time > _timeout) or (_vehObj distance _posDest < _arrivalDist) or (not alive _vehObj) or (side group driver _vehObj != _sideX)};
    if ((_vehObj distance _posDest < _arrivalDist) or (time > _timeout)) then {
        [false, true, -200, -10, 0, 0, "ammo"] call _fnc_applyResults;
        // Clear vehicle cargo
    } else {
        [true, false, 400*_bonus, 10*_bonus, 10, 120, "ammo"] call _fnc_applyResults;
        [0,300*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
        // Give rewards to players
    };
};
Implementation: Uses a waitUntil loop checking:
Timeout (failure).
Arrival at destination (failure for intercept mission).
Vehicle destroyed (success for destroy mission).
Driver switched side (success, vehicle captured).
Depending on the outcome, it calls _fnc_applyResults with specific parameters to handle aggression changes, resource updates, and task state updates.
Prisoner Logic:

Sqf

Apply
if (_convoyType isEqualTo "Prisoners") then {
    waitUntil {sleep 1; ... side group driver _vehObj != _sideX or ({alive _x} count _POWs == 0)};
    if (side group driver _vehObj != _sideX) then {
        {_x enableAI "MOVE"; [_x] orderGetin false} forEach _POWs;
        waitUntil {sleep 2; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance _posHQ < 50)} count _POWs > 0)};
        // Reward calculation based on POWs reaching HQ
    };
};
Implementation: Monitors for vehicle capture. If captured, enables POW movement AI and orderGetin false to make them disembark. Waits for them to reach the HQ (_posHQ). Awards resources based on the number of POWs saved.
Money/Supplies (Cargo) Logic:

Sqf

Apply
if (_convoyType isEqualTo "Money") then {
    private _objectiveObj = if (_objectiveIsCargo) then { _supObj } else { _vehObj };
    private _driver = if (_objectiveIsCargo) then { driver attachedTo _supObj } else { driver _vehObj };
    
    waitUntil {sleep 1; ... (side group _driver != _sideX)};
    if (side group _driver != _sideX) then {
        waitUntil {sleep 2; (_objectiveObj distance _posHQ < 50) or (not alive _objectiveObj)};
        // Reward if objective reaches HQ
    };
};
Implementation: Determines if the objective is the vehicle or the cargo crate (_supObj). If captured, monitors the objective's distance to HQ. Success is achieved only if the physical object (truck or crate) reaches HQ, not just if the driver switches sides.
14. Cleanup and Teardown:

Sqf

Apply
[_taskId, "CONVOY", _taskState] call A3A_fnc_taskSetState;

// Cleanup
{ deleteVehicle _x } forEach _POWs;
[_taskId, "CONVOY", 600, true] spawn A3A_fnc_taskDelete;

// Clear convoy vehicle array to stop travel loops
_convoyVehicles resize 0;
sleep 5;

// Despawn units
private _groups = [];
{ if (alive _x) then {_groups pushBackUnique (group _x)} } forEach _soldiers;
{ [_x] spawn A3A_fnc_groupDespawner } forEach _groups;
{ [_x] spawn A3A_fnc_VEHdespawner } forEach _vehiclesX;

missionNamespace setVariable ["A3A_convoyInProgress", false, true];

{deleteMarker _x} forEach _markers;

// Send remaining escorts back to base
sleep 60;
{
    if (count units _x > 0) then {
        private _wp = _x addWaypoint [_posOrigin, 50];
        _wp setWaypointType "MOVE";
        _x setCurrentWaypoint _wp;
    };
} forEach _groups - [group driver _vehObj];
Implementation:
Updates the task state.
Deletes POW units if they weren't saved.
Schedules task deletion after 600 seconds.
Critical: Clears the _convoyVehicles array (resizes to 0). This is the termination signal for the A3A_fnc_vehicleConvoyTravel scripts spawned earlier, causing them to exit.
Groups remaining soldiers and vehicles into _groups and _vehiclesX arrays and calls their respective despawn scripts (A3A_fnc_groupDespawner, A3A_fnc_VEHdespawner).
Resets the global A3A_convoyInProgress flag.
Deletes temporary map markers.
After 60 seconds, orders any surviving escort vehicles (excluding the objective driver) to return to the origin marker using a waypoint.
Where it leads:

Calls:
A3A_fnc_localizar: Localizes marker names.
A3A_fnc_addTimeForIdle: Prevents marker hibernation.
A3A_fnc_getMarkerNavPoint / A3A_fnc_findPath: Pathfinding.
BIS_fnc_taskCreate / A3A_fnc_taskUpdate: Mission UI.
A3A_fnc_findPosOnRoute: Spawn positioning.
A3A_fnc_createVehicleCrew / A3A_fnc_createUnit: Unit spawning.
A3A_fnc_NATOinit / A3A_fnc_AIVEHinit: Unit/Vehicle initialization.
A3A_fnc_cargoSeats: Determining infantry capacity.
A3A_fnc_addEnemyResources: Resource cost.
A3A_fnc_vehicleConvoyTravel: Main movement logic (spawned).
A3A_fnc_inmuneConvoy: Stuck prevention (spawned).
A3A_fnc_addAggression, A3A_fnc_addScorePlayer, A3A_fnc_addMoneyPlayer, A3A_fnc_resourcesFIA, A3A_fnc_citySupportChange: Reward/Affect systems.
A3A_fnc_taskSetState, A3A_fnc_taskDelete: Mission conclusion.
A3A_fnc_groupDespawner, A3A_fnc_VEHdespawner: Cleanup.
A3A_Logistics_fnc_canLoad, A3A_Logistics_fnc_load: Cargo handling.
SCRT_fnc_misc_getRebelPlayers: Getting player list for rewards.
Called By:
A3A_fnc_missionRequest or similar mission selection logic in fn_missionRequest.sqf.
Global Variables Modified:
A3A_convoyInProgress: Set to true at start, false at end.
A3A_taskCount: Used to generate unique Task ID.
killZones: Modified if the convoy fails to defend itself.
Network Implications:
Uses remoteExecCall for task updates, aggression changes, and resource updates to ensure client synchronization.
Spawning is server-only; movement is handled locally on the server but affects players via network traffic.

Function Name: 
fn_DES_Antenna.sqf
What it does: This function creates a mission to destroy a specific antenna object. It spawns the task, creates a marker, monitors the antenna's destruction or the mission timer, and provides rewards or penalties based on success or failure.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_antenna"];
The function accepts a single parameter, _antenna, which is the object to be destroyed.

Execution Context Check:

Sqf

Apply
if (!isServer and hasInterface) exitWith{};
It ensures the function only runs on the server or a headless client, preventing unnecessary execution on interface clients.

Identify Location and Difficulty:

Sqf

Apply
private _markerX = [markersX, _antenna] call BIS_fnc_nearestPosition;
private _difficultX = if (random 10 < tierWar) then {true} else {false};
private _nameDest = [_markerX] call A3A_fnc_localizar;
private _positionX = getPos _antenna;
private _side = sidesX getVariable [_markerX, sideUnknown];
Finds the nearest mission marker to the antenna.
Determines mission difficulty based on global tierWar variable.
Localizes the name of the marker for the task description.
Retrieves the current controlling side of the marker (e.g., Occupants).
Calculate Time Limit:

Sqf

Apply
private _limit = if (_difficultX) then { 30 call SCRT_fnc_misc_getTimeLimit } else { 120 call SCRT_fnc_misc_getTimeLimit };
_limit params ["_dateLimitNum", "_displayTime"];
Calls a utility function to generate a deadline in number date format and a readable string. Difficult missions give less time.

Create Task and Marker:

Sqf

Apply
private _mrkFinal = createMarker [format ["DES%1", random 100], _positionX];
_mrkFinal setMarkerShape "ICON";

private _taskId = "DES" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [format [localize "STR_A3A_Missions_DES_Antenna_task_desc",_nameDest,_displayTime,FactionGet(occ,"name")], ...],
    ...
] call BIS_fnc_taskCreate;
[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Creates a visible marker at the antenna location.
Generates a unique Task ID using the global A3A_taskCount.
Creates the task for the player side (teamPlayer) and civilians using BIS_fnc_taskCreate.
Updates the task state to "CREATED" remotely for all relevant clients.
Monitor Mission State:

Sqf

Apply
waitUntil {sleep 1; dateToNumber date > _dateLimitNum or {!alive _antenna or {!(sidesX getVariable [_markerX,sideUnknown] == Occupants)}}};
Waits in a loop (sleeping 1 second per check) until:
Time runs out.
The antenna is destroyed (!alive _antenna).
The marker changes hands (side is no longer the Occupants).
Handle Outcome:

Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    [_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
    [-10*_bonus,theBoss] call A3A_fnc_addScorePlayer;
    [_side, -5, 60] remoteExec ["A3A_fnc_addAggression", 2];
} else {
    sleep 15;
    [_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
    [_side, 15, 90] remoteExec ["A3A_fnc_addAggression", 2];
    [600*_bonus, _side] remoteExec ["A3A_fnc_timingCA",2];
    { ... } forEach (call SCRT_fnc_misc_getRebelPlayers);
    ...
};
Failure: Checks if time expired. Updates task state to FAILED. Deducts score for the boss and adds negative aggression to the side.
Success: Waits 15 seconds (visual feedback). Updates task to SUCCEEDED. Increases aggression, triggers a Counter-Attack (CA) timer, and loops through all rebel players to grant score/money.
Cleanup:

Sqf

Apply
deleteMarker _mrkFinal;
[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;
Removes the marker and schedules the task deletion after 1200 seconds (20 minutes).

Where it leads:

Calls: BIS_fnc_nearestPosition, SCRT_fnc_misc_getTimeLimit, A3A_fnc_localizar, BIS_fnc_taskCreate, A3A_fnc_taskUpdate, A3A_fnc_taskSetState, A3A_fnc_addScorePlayer, A3A_fnc_addAggression, SCRT_fnc_misc_getRebelPlayers, A3A_fnc_addMoneyPlayer, A3A_fnc_timingCA, A3A_fnc_taskDelete.
Dependencies: Relies on global variables markersX, tierWar, sidesX, teamPlayer, Occupants, theBoss, A3A_taskCount.
System Fit: Part of the dynamic mission system. It is triggered by missionRequest when a "DES" (Destroy) type mission is selected for an antenna object.
Function Name: 
fn_DES_Artillery.sqf
What it does: Creates a mission to destroy a static artillery piece. The artillery piece is spawned within a suitable range of a player-controlled location, is artificially prevented from flipping, has a fake firing mechanism, and is guarded by MG crews and infantry squads.

How it does that:

Setup:

Sqf

Apply
params ["_markerX"];
private _missionOriginPos = getMarkerPos _markerX;
private _difficult = if (random 10 < tierWar) then {true} else {false};
private _sideX = if (sidesX getVariable [_markerX, sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
Determines the faction and side based on the input marker.

Select Artillery Class:

Sqf

Apply
private _mortarsPool = _faction getOrDefault ["staticMortars", []];
private _artilleryPool = _faction getOrDefault ["vehiclesArtillery", []];
private _howitzersPool = _faction getOrDefault ["staticHowitzers", []];
// ... logic determines _artilleryClass based on tierWar ...
Selects a random artillery class from the faction's template lists. The selection logic changes based on the global tierWar level (tiers < 6 favor mortars, higher tiers favor howitzers/artillery).

Validate Classes:

Sqf

Apply
if (isNil "_artilleryClass" || {isNil "_artilleryShellClass" || {isNil "_mgClass" || {isNil "_mgCrewClass"}}}) exitWith {
    ["DES"] remoteExec ["A3A_fnc_missionRequest",2];
    Error_4("Problems with faction template classes...");
};
If the faction template is missing required classes (e.g., no artillery defined), it logs an error and re-requests a generic "DES" mission to retry.

Find Target and Artillery Position:

Sqf

Apply
private _potentialSites = (outposts + milbases + airportsX + resourcesX + factories + seaports) select {
    private _potentialPos = getMarkerPos _x;
    sidesX getVariable [_x,sideUnknown] == teamPlayer && {_missionOriginPos distance _potentialPos < 2500}
};
_potentialSites pushBack "Synd_HQ";
private _targetSite = selectRandom _potentialSites;
It finds a random player-controlled site within 2500m to be the artillery's target. If none exist, it defaults to "Synd_HQ" (base).

Spawn Artillery:

Sqf

Apply
private _artilleryData = [_missionOriginPos, 0, _artilleryClass, _sideX] call A3A_fnc_spawnVehicle;
private _artilleryVeh = _artilleryData select 0;
_artilleryVeh setDir (random 360);
_artilleryVeh allowDamage false;
Spawns the vehicle via A3A_fnc_spawnVehicle and temporarily disables damage to prevent spawn-related destruction.

Find Safe Position:

Sqf

Apply
private _artilleryPosition = [_missionOriginPos, 0, 800, 3, 0, 0.6] call BIS_fnc_findSafePos;
_artilleryVeh setPos _artilleryPosition;

if(!(_targetPosition inRangeOfArtillery [[_artilleryVeh], _artilleryShellClass]) && {isOnRoad _artilleryVeh}) then {
    // Loop to find better position
    private _radiusX = 600;
    while {true} do {
        _artilleryPosition = [_missionOriginPos, 0, _radiusX, 3, 0, 0.6] call BIS_fnc_findSafePos;
        _artilleryVeh setPos _artilleryPosition;
        if(_targetPosition inRangeOfArtillery [[_artilleryVeh], _artilleryShellClass] && {!(isOnRoad _artilleryVeh)}) exitWith {};
        _radiusX = _radiusX + 100;
    };
};
Finds a position within 800m. It then loops, increasing the radius, until the artillery is both in range of the target and not on a road.

Create Task: Similar to fn_DES_Antenna, creates a task using BIS_fnc_taskCreate with the specific "Destroy Artillery" strings.

Artillery Fake Fire and Anti-Flip:

Sqf

Apply
_firedEh = _artilleryVeh addEventHandler ["Fired", {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
    deleteVehicle _projectile;
    // ...
}];
[_artilleryVeh, _targetPosition, _artilleryShellClass] spawn {
    while {alive _veh} do {
        _veh doArtilleryFire [_targetPos, _shell, round (random [1,2,3])];
        sleep 60;
    };
};
Adds a "Fired" event handler to delete the actual projectile (simulating firing without causing damage to the map).
Spawns a loop that executes doArtilleryFire every 60 seconds towards the target.
Spawn Guards: If the marker isn't fully spawned by players, it creates an MG team and 2 infantry patrol groups around the artillery.

Outcome Handling:

Failure: If the artillery survives and the crew is alive when time expires, it executes a real artillery strike on the rebel position (using the addArtilleryTrailEH function) and fails the task.
Success: If destroyed, grants resources, score, money, and triggers a Counter-Attack.
Cleanup: Despawns the artillery vehicle, MG vehicle, infantry groups, and props (sandbags, camonets).

Where it leads:

Calls: A3A_fnc_spawnVehicle, A3A_fnc_AIVEHinit, A3A_fnc_NATOinit, BIS_fnc_findSafePos, A3A_fnc_addArtilleryTrailEH, A3A_fnc_vehDespawner, A3A_fnc_groupDespawner.
Global Variables: Modifies A3A_taskCount. Reads markersX, sidesX, tierWar, teamPlayer, Occupants, Invaders.
System Fit: Complex mission type requiring precise positioning and AI behavior simulation.

Function: fn_DES_Heli.sqf
Function Name: A3A_fnc_DES_Heli
What it does: Creates a "Destroy the helicopter" type mission in a random location near an input marker. The mission involves either destroying a downed enemy helicopter or preventing the enemy from repairing and recovering it. The mission is dynamically scaled based on difficulty (tierWar) and includes convoy escorts, guard squads, pilot groups, and cleanup routines. This is a server-side mission function that manages all AI, triggers, and state transitions for a single "Destroy Helicopter" mission instance.

When/Why it's called:

Called from A3A_fnc_missionRequest when the game decides a "DES" (Destroy) mission should be created
Only executes on server (if (!isServer and hasInterface) exitWith{})
Takes a marker name (like "airport", "milbase", etc.) as input to spawn near that location
Used for both Occupants and Invaders factions
How it does that:

1. Parameter Validation & Initialization
Sqf

Apply
params ["_missionOrigin"];
private _difficult = if (random 10 < tierWar) then {true} else {false};
private _bonus = if (_difficult) then {2} else {1};
private _missionOriginPos = getMarkerPos _missionOrigin;
private _sideX = if (sidesX getVariable [_missionOrigin,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
Debug_3("Origin: %1, Hardmode: %2, Controlling Side: %3", _missionOrigin, _difficult, _sideX);
Validates mission origin marker exists and has a position
Calculates difficulty multiplier (random roll vs tierWar global)
Determines controlling side based on marker ownership
Gets faction data via Faction() function which returns a hashmap of faction properties
2. Finding Crash Position
Sqf

Apply
private _ang = random 360;
private _countX = 0;
private _dist = if (_difficult) then {2000} else {3000};
private _posCrashOrigin = [];
while {true} do {
    _posCrashOrigin = _missionOriginPos getPos [_dist,_ang];
    private _notOutOfBounds = (_posCrashOrigin select [0,2]) findIf { (_x < 0 + 1000) || (_x > worldSize -1000)} isEqualTo -1;
    if ((!surfaceIsWater _posCrashOrigin) and (_posCrashOrigin distance (getMarkerPos respawnTeamPlayer) < 4000) and (_posCrashOrigin distance (getMarkerPos respawnTeamPlayer) > 1000) and _notOutOfBounds) exitWith {};
    _ang = _ang + 1;
    _countX = _countX + 1;
    if (_countX > 360) then {
        _countX = 0;
        _dist = _dist - 500;
    };
};
Finds a valid crash position with distance constraints (1000-4000m from player base)
Uses spiral search pattern: rotate 360°, decrease distance if no valid spot found
Validates: not water, not out of bounds (1km grace from world edges), within range
getPos returns position relative to origin at given distance/angle
findIf checks array bounds using select on [0,2] to get x,y coordinates
3. Aircraft Selection
Sqf

Apply
private _heliPool = (_faction get "vehiclesHelisLight") + (_faction get "vehiclesHelisTransport") + (_faction get "vehiclesHelisAttack") + (_faction get "vehiclesHelisLightAttack");
private _typeVehH = selectRandom (_heliPool select {_x isKindOf "Helicopter"});
if (isNil "_typeVehH") exitWith {
    ["DES"] remoteExecCall ["A3A_fnc_missionRequest",2];
    Error("No aircrafts in arrays vehiclesHelisLight, vehiclesHelisTransport or vehiclesHelisAttack. Reselecting DES mission");
};
private _isAttackHeli = _typeVehH in ((_faction get "vehiclesHelisAttack") + (_faction get "vehiclesHelisLightAttack"));
Combines all helicopter types from faction config into one pool
Filters to only valid helicopter class names using isKindOf
Error handling: if no helis found, rerolls mission type via remote execution
Flags if it's an attack helicopter for special AI behaviors
4. Crash Site Refinement & Cleanup
Sqf

Apply
private _flatPos = [_posCrashOrigin, 0, 1000, 0, 0, 0.1] call BIS_fnc_findSafePos;
private _posCrash = _flatPos findEmptyPosition [0,100,_typeVehH];
if (count _posCrash == 0) then {_posCrash = _posCrashOrigin};
{[_x,true] remoteExec ["hideObjectGlobal",2]} foreach (nearestTerrainObjects [_posCrash,["tree","bush", "ROCKS"],50]);
Uses BIS function to find flat, safe position within 1000m of origin
Ensures empty space for helicopter using findEmptyPosition
Hides nearby terrain objects to prevent clipping issues
Falls back to rough position if refinement fails
5. Mission Object Creation
Sqf

Apply
private _crater = "CraterLong" createVehicle _posCrash;
private _heli = createVehicle [_typeVehH, [_posCrash select 0, _posCrash select 1, 0.9], [], 0, "CAN_COLLIDE"];
private _smoke = "test_EmptyObjectForSmoke" createVehicle _posCrash; _smoke attachTo [_heli,[0,1.5,-1]];
_heli setDamage 0.8;
_vehicles append [_heli,_crater];
Creates visual effects: crater and smoke attached to helicopter
Spawns helicopter at elevated position (0.9m) to prevent ground collision
Sets initial damage to 0.8 (80% damaged)
Adds both to cleanup array for later despawning
6. Cover Creation (Sandbags)
Sqf

Apply
private _typeVeh = _faction get "sandbag";
private _counterLimit = round (random[2,3,4]*_bonus);
private _counter = 0;
private _angle = random 360;
while {_counter != _counterLimit} do {
    _counter = _counter + 1;
    _angle = _angle + 45 + round random 90;
    private _pos = _posCrash getPos [10,_angle];
    if !(isOnRoad _pos) then {
    private _cov = _typeVeh createVehicle _pos;
    private _dir = _posCrash getDir _pos;
    _cov setDir _dir;
    _vehicles pushBack _cov;
    } else {_counter = _counter -1};
};
Spawns 2-4 sandbag cover objects around crash site
Avoids spawning on roads
Creates ring pattern around crash site
Adds to vehicle cleanup array
7. Mission Marker Creation
Sqf

Apply
private _posCrashMrk = _heli getRelPos [random 500,random 360];
private _taskMrk = createMarker [format ["DES%1", random 100],_posCrashMrk];
_taskMrk setMarkerShape "ICON";
Creates task marker 500m from helicopter in random direction
Uses random ID in marker name for uniqueness
8. Time Limit Calculation
Sqf

Apply
private _limit = if (_difficult) then {
	60 call SCRT_fnc_misc_getTimeLimit
} else {
	120 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
Calculates time limit (60min hard, 120min normal) with random variance
Returns both epoch date number (for comparison) and formatted display string
9. Task Creation
Sqf

Apply
private _taskId = "DES" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [format [localize "STR_A3A_Missions_DES_Heli_task_desc",_faction get "name", _location, _displayTime],localize "STR_A3A_Missions_DES_Heli_task_header",_taskMrk],_posCrashMrk,false,0,true,"Destroy",true
] call BIS_fnc_taskCreate;
[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Creates task using BIS_fnc_taskCreate with localized strings
Assigns to both players and civilians
Updates task state to "CREATED" across network
10. Convoy Escort Creation
Sqf

Apply
private _radiusX = 100;
private _roads = [];
while {true} do {
    _roads = _missionOriginPos nearRoads _radiusX;
    if (count _roads > 1) exitWith {};
    _radiusX = _radiusX + 50;
};
private _roadE = _roads select 1;
private _roadR = _roads select 0;
Finds two nearest road segments to origin marker
Expands search radius until at least 2 roads found
Sqf

Apply
_typeVeh = selectRandom (_faction get "vehiclesLightUnarmed");
private _vehicleDataE = [position _roadE, 0,_typeVeh, _sideX] call A3A_fnc_spawnVehicle;
private _vehE = _vehicleDataE select 0;
_vehE limitSpeed 50;
[_vehE,"Escort"] spawn A3A_fnc_inmuneConvoy;
private _vehCrew = crew _vehE;
{[_x] call A3A_fnc_NATOinit} forEach _vehCrew;
[_vehE, _sideX] call A3A_fnc_AIVEHinit;
private _groupVeh = _vehicleDataE select 2;
_groups pushBack _groupVeh;
_vehicles pushBack _vehE;
Spawns light unarmed escort vehicle at road position
Limits speed to 50 km/h for convoy behavior
Applies immune convoy script to prevent immediate destruction
Initializes crew with NATO init (equipment, skills)
Adds vehicle and group to cleanup arrays
Sqf

Apply
_typeGroup = selectRandom ([_faction, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier);
private _groupX = [_missionOriginPos, _sideX, _typeGroup] call A3A_fnc_spawnGroup;
{_x assignAsCargo _vehE; _x moveInCargo _vehE; [_x] join _groupVeh; [_x] call A3A_fnc_NATOinit} forEach units _groupX;
deleteGroup _groupX;
Spawns infantry group and assigns them as cargo in escort vehicle
Deletes the temporary group (joins them to vehicle group)
Sqf

Apply
private _escortWP = _groupVeh addWaypoint [_posCrash, 0];
_escortWP setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) leaveVehicle (assignedVehicle this)"];
_escortWP setWaypointBehaviour "SAFE";
Creates waypoint to crash site
Waypoint statement ensures infantry dismount on arrival (local to machine)
11. Repair Truck Creation
Sqf

Apply
_typeVeh = selectRandom (_faction get "vehiclesRepairTrucks");
private _vehicleDataR = [position _roadR, 0,_typeVeh, _sideX] call A3A_fnc_spawnVehicle;
private _vehR = _vehicleDataR select 0;
_vehR limitSpeed 50;
[_vehR, _sideX] call A3A_fnc_AIVEHinit;
sleep 1;
[_vehR,"Repair Truck"] spawn A3A_fnc_inmuneConvoy;
private _groupVehR = _vehicleDataR select 2;
private _vehCrewR = units _groupVehR;
{[_x] call A3A_fnc_NATOinit} forEach _vehCrewR;
_groups pushBack _groupVehR;
_vehicles pushBack _vehR;
Spawns repair truck at second road segment
Similar initialization and immune behavior as escort
Adds to cleanup arrays
Sqf

Apply
_reapirTruckWP = _groupVehR addWaypoint [_posCrash, 0];
_reapirTruckWP setWaypointType "MOVE";
_reapirTruckWP setWaypointBehaviour "SAFE";
Sets repair truck to move to crash site
12. Guard Squad & Pilot Creation
Sqf

Apply
_mrkCrash = createMarkerLocal [format ["%1patrolarea", floor random 100], _posCrash];
_mrkCrash setMarkerShapeLocal "RECTANGLE";
_mrkCrash setMarkerSizeLocal [20,20];
_mrkCrash setMarkerTypeLocal "hd_warning";
_mrkCrash setMarkerColorLocal "ColorRed";
_mrkCrash setMarkerBrushLocal "DiagGrid";
if (!debug) then {_mrkCrash setMarkerAlphaLocal 0};
Creates local (not synced) patrol area marker for guard AI
Hidden if debug mode is off
Sqf

Apply
_typeGroup = selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier);
if !(_typeVehH in (_faction get "vehiclesHelisLight")) then {
    _guard = [_posCrash, _sideX, _typeGroup] call A3A_fnc_spawnGroup;
    {[_x] call A3A_fnc_NATOinit} forEach units _guard;
    _groups pushBack _guard;
    _guardWP = [_guard, _posCrash, 10] call BIS_fnc_taskPatrol;
Spawns guard squad for non-light helicopters
Initializes NATO units
Creates patrol waypoint around crash site (10m radius)
Sqf

Apply
if (_isAttackHeli) then {
    _typeVeh = selectRandom (_faction get "vehiclesTrucks");
    private _posVehHT = _posCrash findEmptyPosition [15, 30 ,_typeVeh];
    if (_posVehHT isEqualTo []) then {_posVehHT = _posCrash findEmptyPosition [15, 100 ,_typeVeh]};
    if (_posVehHT isEqualTo []) exitWith { _vehGuard = _heli};
    _vehGuard = _typeVeh createVehicle _posVehHT;
    [_vehGuard, _sideX] call A3A_fnc_AIVEHinit;
    _vehicles pushBack _vehGuard;
};
For attack helicopters, spawns transport truck nearby
Fallback to helicopter position if truck can't be placed
Sqf

Apply
_typeGroup = [_faction get "unitPilot", _faction get "unitPilot"];
_pilots = [_posCrash,_sideX,_typeGroup] call A3A_fnc_spawnGroup;
{[_x,""] call A3A_fnc_NATOinit} forEach units _pilots;
_groups pushBack _pilots;
[_heli, _sideX] call A3A_fnc_AIVEHinit;
Spawns pilot units (2 pilots, same type)
Initializes crew for helicopter (AIVEHinit adds proper crew variables)
Sqf

Apply
private _pilotsWP = _pilots addWaypoint [_posCrash, 0];
_pilotsWP setWaypointType "HOLD";
_pilotsWP setWaypointBehaviour "STEALTH";
Pilots hold position in stealth mode (avoid detection)
13. Undercover Break System
Sqf

Apply
[_heli] spawn {
    params ["_heli"];
    private _undercoverBreakDistance = 50;
    private _initialHeliPosition = getPosATL _heli;
    while {alive _heli && { _heli getVariable "ownerSide" != teamPlayer } } do {
        private _nearbyPlayers = allPlayers inAreaArray [_initialHeliPosition, _undercoverBreakDistance, _undercoverBreakDistance];
        { if (captive _x) then { [_x, false] remoteExec ["setCaptive", _x] } } forEach _nearbyPlayers;
        sleep 5;
    };
};
Spawns coroutine to check for players approaching crash site
Breaks undercover status for any player within 50m
Runs until helicopter destroyed or captured by players
14. Main Wait Loop
Sqf

Apply
waitUntil
{
    sleep 1;
    !alive _heli ||
    {_vehR distance _heli < 50 ||
    (_heli distance (getMarkerPos respawnTeamPlayer)) < 100 &&
    isPlayer (driver _heli) ||
    {dateToNumber date > _dateLimitNum}}
};
Checks multiple conditions every second:
Helicopter destroyed
Repair truck reaches helicopter (distance < 50m)
Helicopter captured by players (at player base, player piloting)
Time limit expired
15. Repair Sequence
Sqf

Apply
if (_vehR distance _heli < 50) then {
    Debug_2("Repair %1 has reached %2, starting repair...", _vehR, _heli);
    _vehR doMove position _heli;
    sleep 300; //time to repair
    if (alive _heli && alive _vehR && _vehR distance2D _heli < 50) then {
        _heli setDamage 0.2;
        _heli setFuel 0.4;
        private _emitterArray = _smoke getVariable "effects";
        {deleteVehicle _x} forEach _emitterArray;
        deleteVehicle _smoke;
        deleteVehicle _crater;
Repair takes 5 minutes (300 seconds)
Restores helicopter to 20% damage, 40% fuel
Removes smoke effects by deleting emitters stored in variable
Deletes smoke object and crater
Sqf

Apply
for "_i" from (count (waypoints _guard)) to 0 step -1 do {
    deleteWaypoint [_guard, _i];
};
Deletes all guard waypoints to clear patrol orders
Sqf

Apply
_reapirTruckWP = _groupVehR addWaypoint [_missionOriginPos, 1];
_reapirTruckWP setWaypointType "MOVE";
_reapirTruckWP setWaypointBehaviour "SAFE";

_escortWP = _groupVeh addWaypoint [_posCrash, 0];
_escortWP setWaypointType "GETIN";
_escortWP setWaypointBehaviour "SAFE";

_escortWP = _groupVeh addWaypoint [_missionOriginPos, 2];
_escortWP setWaypointType "MOVE";
_escortWP setWaypointBehaviour "SAFE";
Sets up RTB (Return to Base) waypoints for all groups
Escort vehicle first returns to crash site, loads infantry, then RTB
Sqf

Apply
_pilots addVehicle _heli;
(units _pilots) orderGetIn true;
sleep 1;
private _notAlivePilots = true;
{if ([_x] call A3A_fnc_canFight) exitWith {_notAlivePilots = false}}forEach units _pilots;
Assigns helicopter to pilots and orders them to board
Checks if any pilots are still combat capable
Sqf

Apply
if (_typeVehH in ( (_faction get "vehiclesHelisLight") + (_faction get "vehiclesHelisTransport") )) then {
    if !(_typeVehH in (_faction get "vehiclesHelisLight")) then {
        if (_notAlivePilots) then {_guard addVehicle _heli} else {{_x assignAsCargo _heli}forEach units _guard};
        (units _guard) orderGetIn true;
        sleep 1;
    };
For transport/light helicopters, guards board as cargo if pilots dead
Otherwise, guards wait for pilots to load first
Sqf

Apply
if (_notAlivePilots && !(_typeVehH in (_faction get "vehiclesHelisLight"))) then {
    _pilotsWP = _guard addWaypoint [_missionOriginPos, 3];
    _pilotsWP setWaypointType "MOVE";
    _pilotsWP setWaypointBehaviour "AWARE";
    _pilotsWP setWaypointSpeed "FULL";
} else {
    _pilotsWP = _pilots addWaypoint [_missionOriginPos, 3];
    _pilotsWP setWaypointType "MOVE";
    _pilotsWP setWaypointBehaviour "AWARE";
    _pilotsWP setWaypointSpeed "FULL";
};
Sets RTB waypoint to appropriate group (guard if pilots dead, pilots otherwise)
Sqf

Apply
} else {
    //attack helicopter path
    _guard addVehicle _vehGuard;
    if (_notAlivePilots) then {_guard addVehicle _heli};
    (units _guard) orderGetIn true;
    sleep 1;
    _guardWP = _guard addWaypoint [_missionOriginPos, 1];
    _guardWP setWaypointType "MOVE";
    _guardWP setWaypointBehaviour "AWARE";
    _guardWP setWaypointSpeed "FULL";
    _guard setCurrentWaypoint [_guard, 1];
    _pilotsWP = _pilots addWaypoint [_missionOriginPos, 3];
    _pilotsWP setWaypointType "MOVE";
    _pilotsWP setWaypointBehaviour "AWARE";
    _pilotsWP setWaypointSpeed "FULL";
};
Attack helicopter logic: guard boards their own truck, pilots board helicopter
Separate RTB waypoints for guard and pilots
16. Mission Completion Check
Sqf

Apply
waitUntil
{
    sleep 1;
    (not alive _heli) ||
    ((_heli distance _missionOriginPos) < 300) &&
    !isPlayer (driver _heli) ||
    ((_heli distance (getMarkerPos respawnTeamPlayer)) < 100) &&
    isPlayer (driver _heli) ||
    (dateToNumber date > _dateLimitNum)
};
Final conditions check:
Helicopter destroyed
Helicopter returned to origin (300m) and NOT player-controlled
Helicopter at player base and player-controlled
Time expired
17. Reward & Task State
Sqf

Apply
if ((not alive _heli) || (_heli distance (getMarkerPos respawnTeamPlayer) < 100) && isPlayer (driver _heli) ) then {
    if (alive _heli) then {
        Debug_1("%1 was captured", _heli);
    } else {
        Debug_1("%1 was captured", _heli);
    };
    [_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
    [0,300*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
	[1800*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
	{ 
        [20*_bonus,_x] call A3A_fnc_addScorePlayer;
        [300*_bonus,_x] call A3A_fnc_addMoneyPlayer;
    } forEach (call SCRT_fnc_misc_getRebelPlayers);
	[20*_bonus,theBoss] call A3A_fnc_addScorePlayer;
    [200*_bonus,theBoss, true] call A3A_fnc_addMoneyPlayer;
    if (_isAttackHeli) then {[600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2]};
} else {
    Debug_2("%1 was successfully recovered by %2, mission failed", _heli, _sideX);
    [_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
    [-600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
    [-10*_bonus,theBoss] call A3A_fnc_addScorePlayer;
    if (_isAttackHeli) then {[-600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2]};
};
Success conditions: Helicopter destroyed OR captured by players
Fail conditions: Helicopter repaired and recovered by AI
Rewards: 300 resources, 1800 aggression timer, 20 score/300 money per player, bonus for boss
Penalties: -600 aggression timer, -10 score for boss on failure
Attack helis give 600 bonus (or penalty) to aggression timer
18. Cleanup
Sqf

Apply
if (!isNull _smoke) then {
    private _emitterArray = _smoke getVariable "effects";
    {deleteVehicle _x} forEach _emitterArray;
    deleteVehicle _smoke;
};

[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;
deleteMarker _taskMrk;
deleteMarker _mrkCrash;

{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Deletes smoke effects if still exists
Schedules task deletion after 1200 seconds (persistent tasks)
Deletes mission markers
Despawns all vehicles and groups with cleanup functions
Where it leads:

Functions called:

A3A_fnc_spawnVehicle - Creates vehicle with crew
A3A_fnc_spawnGroup - Creates group of units
A3A_fnc_AIVEHinit - Initializes AI vehicle (add crew, set side, etc.)
A3A_fnc_NATOinit - Initializes AI units with proper loadout and skills
A3A_fnc_inmuneConvoy - Makes vehicle temporarily invincible
A3A_fnc_localizar - Gets localized location name
BIS_fnc_taskCreate - Creates mission task
A3A_fnc_taskUpdate - Updates task state
BIS_fnc_taskPatrol - Creates patrol waypoint
A3A_fnc_resourcesFIA - Adds resources to FIA
A3A_fnc_timingCA - Adjusts aggression timer
A3A_fnc_addScorePlayer - Adds score to player
A3A_fnc_addMoneyPlayer - Adds money to player
SCRT_fnc_misc_getRebelPlayers - Gets list of rebel players
A3A_fnc_taskSetState - Sets task completion state
A3A_fnc_taskDelete - Schedules task deletion
A3A_fnc_vehDespawner - Despawns vehicle after delay
A3A_fnc_groupDespawner - Despawns group after delay
A3A_fnc_missionRequest - Called if no heli found
BIS_fnc_findSafePos - Finds safe spawn position
SCRT_fnc_misc_getTimeLimit - Calculates mission time limit
SCRT_fnc_unit_flattenTier - Gets appropriate unit groups based on tier
Functions that call this:

A3A_fnc_missionRequest - Called when "DES" mission type is requested
Server-side mission scheduler
Global variables modified:

A3A_taskCount - Incremented when creating task
A3A_taskCount used for unique task IDs
Mission-specific markers created (DESXXXX)
Network implications:

Remote execution for A3A_fnc_missionRequest if heli not found
Task creation/synced with remoteExecCall
Player rewards sent via remoteExec
All AI spawning and movement is server-side only
Edge cases handled:

No helicopter in faction config → reroll mission type
Crash position in water → continues searching
No valid crash position after many attempts → uses last attempt
Road segments not found within distance → expands search
Truck can't be placed near crash → uses helicopter position
All waypoints deleted from groups when repairing
Smoke effects cleanup even if smoke object destroyed
Mission completion checked every second for precise timing
Function: fn_DES_Vehicle.sqf
Function Name: A3A_fnc_DES_Vehicle
What it does: Creates a mission to destroy a specific enemy vehicle (anti-air vehicle) at a marker location. The vehicle spawns only when the area is activated (spawner). Players must destroy it within a time limit. The mission has variable difficulty based on tierWar and includes success/failure rewards. This is a simpler mission compared to DES_Heli, focusing on a single vehicle spawn with minimal AI.

When/Why it's called:

Called from A3A_fnc_missionRequest for "DES" missions
Only executes on server (if (!isServer and hasInterface) exitWith{})
Takes a marker name as input
Spawns an anti-air vehicle at the marker when activated
How it does that:

1. Parameter Validation & Initialization
Sqf

Apply
params ["_markerX"];
private _difficultX = if (random 10 < tierWar) then {true} else {false};
private _positionX = getMarkerPos _markerX;
private _sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
Validates marker exists and gets position
Calculates difficulty (similar to DES_Heli)
Determines controlling side and gets faction data
2. Time Limit Calculation
Sqf

Apply
private _limit = if (_difficultX) then {
	30 call SCRT_fnc_misc_getTimeLimit
} else {
	120 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
30 minutes for difficult, 120 minutes for normal
Uses SCRT function for time variance
3. Task Creation
Sqf

Apply
private _taskId = "DES" + str A3A_taskCount;
[
	[teamPlayer,civilian],
	_taskId,
	[
		format [localize "STR_A3A_Missions_DES_Vehicle_task_desc",_nameDest,_displayTime,getText (configFile >> "CfgVehicles" >> (_typeVehX) >> "displayName")],
		localize "STR_A3A_Missions_DES_Vehicle_task_header",
		_markerX
	],
	_positionX,false,0,true,"Destroy",true
] call BIS_fnc_taskCreate;
[_taskId, "DES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Creates task with vehicle display name from config
Localized strings for description and header
Task icon: "Destroy"
4. Vehicle Creation (Conditional)
Sqf

Apply
waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (spawner getVariable _markerX == 0)};
private _bonus = if (_difficultX) then {2} else {1};
if (spawner getVariable _markerX == 0) then
{
	_truckCreated = true;
	_size = [_markerX] call A3A_fnc_sizeMarker;
	_pos = [];
	if (_size > 40) then {_pos = [_positionX, 10, _size, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos} else {_pos = _positionX findEmptyPosition [10,60,_typeVehX]};
	_veh = createVehicle [_typeVehX, _pos, [], 0, "NONE"];
	_veh allowdamage false;
	_veh setDir random 360;
	[_veh, _sideX] call A3A_fnc_AIVEHinit;
Critical logic: Vehicle only spawns when spawner getVariable _markerX == 0 (area activated)
If time limit expires first → mission fails
Finds safe position based on marker size (large markers use BIS_Fnc_findSafePos, small use findEmptyPosition)
Creates vehicle with NO collision initially ("NONE"), disables damage temporarily
Initializes vehicle with AIVEHinit
Sqf

Apply
	_groupX = createGroup _sideX;
	sleep 5;
	_veh allowDamage true;
	_typeX = _faction get "unitCrew";
	for "_i" from 1 to 3 do {
		_unit = [_groupX, _typeX, _pos, [], 0, "NONE"] call A3A_fnc_createUnit;
		[_unit,""] call A3A_fnc_NATOinit;
		sleep 2;
	};
Creates crew group for the vehicle
Re-enables damage after 5 seconds (gives players time to approach)
Spawns 3 crew units with NATO initialization
2-second delay between unit spawns (possible performance consideration)
5. AI Behavior (Difficult Mode vs Normal)
Sqf

Apply
	if (_difficultX) then {
		_groupX addVehicle _veh;
	} else {
		waitUntil {sleep 1;({leader _groupX knowsAbout _x > 1.4} count ([distanceSPWN,0,leader _groupX,teamPlayer] call A3A_fnc_distanceUnits) > 0) or (dateToNumber date > _dateLimitNum) or (not alive _veh) or ({(_x getVariable ["spawner",false]) and (side group _x == teamPlayer)} count crew _veh > 0)};
		if ({leader _groupX knowsAbout _x > 1.4} count ([distanceSPWN,0,leader _groupX,teamPlayer] call A3A_fnc_distanceUnits) > 0) then {_groupX addVehicle _veh;};
	};
Difficult mode: Crew immediately mount vehicle
Normal mode: Wait until player detected (knowsAbout > 1.4) or other termination conditions, then mount
Uses A3A_fnc_distanceUnits to find players in range
6. Main Wait Loop
Sqf

Apply
	waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (not alive _veh) or ({(_x getVariable ["spawner",false]) and (side group _x == teamPlayer)} count crew _veh > 0)};
Monitors until:
Time expires
Vehicle destroyed
Player enters vehicle (via spawner variable check)
7. Success/Failure Logic
Sqf

Apply
	if ((not alive _veh) or ({(_x getVariable ["spawner",false]) and (side group _x == teamPlayer)} count crew _veh > 0)) then
	{
		[_taskId, "DES", "SUCCEEDED"] call A3A_fnc_taskSetState;
		[0,300*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
        [_sideX, 10, 60] remoteExec ["A3A_fnc_addAggression", 2];
		if (_sideX == Invaders) then
        {
            [0,10*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2]
        }
        else
        {
            [0,5*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2]
        };
		[1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
		{ 
			[15*_bonus, _x] call A3A_fnc_addScorePlayer;
    		[300*_bonus,_x] call A3A_fnc_addMoneyPlayer;
		} forEach (call SCRT_fnc_misc_getRebelPlayers);
		[5*_bonus,theBoss] call A3A_fnc_addScorePlayer;
    	[200*_bonus,theBoss, true] call A3A_fnc_addMoneyPlayer;
		};
	}
else
	{
    [_taskId, "DES", "FAILED"] call A3A_fnc_taskSetState;
	[-5*_bonus,-100*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
	[5*_bonus,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	[-600*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
	[-10*_bonus,theBoss] call A3A_fnc_addScorePlayer;
	};
Success: Vehicle destroyed or captured by player
Resources: +300
Aggression: +10 (60 second timer)
City support: +10 (Invaders) or +5 (Occupants)
CA timer: +1200
Score: +15 per player, +5 for boss
Money: +300 per player, +200 for boss
Failure: Time expired
Resources: -5, -100
City support: +5 (weird, positive even on failure)
CA timer: -600
Boss score: -10
8. Cleanup
Sqf

Apply
[_taskId, "DES", 1200] spawn A3A_fnc_taskDelete;

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

if (_truckCreated) then
{
	[_groupX] spawn A3A_fnc_groupDespawner;
	[_veh] spawn A3A_fnc_vehDespawner;
};
Schedules task deletion after 1200 seconds
Waits until marker is despawned (spawner == 2)
Only despawns if vehicle was actually created
Where it leads:

Functions called:

SCRT_fnc_misc_getTimeLimit - Calculates time limit
A3A_fnc_localizar - Localizes location name
A3A_fnc_sizeMarker - Gets marker size
BIS_Fnc_findSafePos - Finds safe spawn position for large markers
createVehicle - Spawns vehicle
A3A_fnc_AIVEHinit - Initializes vehicle
createGroup - Creates crew group
A3A_fnc_createUnit - Spawns crew members
A3A_fnc_NATOinit - Initializes crew units
A3A_fnc_distanceUnits - Finds players in range
BIS_fnc_taskCreate - Creates task
A3A_fnc_taskUpdate - Updates task state
A3A_fnc_taskSetState - Sets task completion state
A3A_fnc_taskDelete - Schedules task deletion
A3A_fnc_resourcesFIA - Adds/removes resources
A3A_fnc_addAggression - Adds aggression timer
A3A_fnc_citySupportChange - Modifies city support
A3A_fnc_timingCA - Modifies CA timer
A3A_fnc_addScorePlayer - Adds score to player
A3A_fnc_addMoneyPlayer - Adds money to player
SCRT_fnc_misc_getRebelPlayers - Gets rebel player list
A3A_fnc_groupDespawner - Despawns crew group
A3A_fnc_vehDespawner - Despawns vehicle
Functions that call this:

A3A_fnc_missionRequest - When "DES" mission type requested
Global variables modified:

A3A_taskCount - Used for unique task ID
Mission-specific markers created
Network implications:

All remote execution via remoteExec
Task creation/updates on clients
Player rewards synchronized
Edge cases handled:

Vehicle only spawns when area activated (spawner == 0)
Time limit expires before activation → mission fails
Different spawn logic based on marker size
Difficulty affects AI behavior (immediate vs delayed mounting)
Success if player enters vehicle (not just destroys)
Cleanup only if vehicle was created
Waits for despawn event before cleanup
Technical details:

Uses getVariable for spawner state
findIf pattern for distance checking (though not used here)
Config lookup for vehicle display name: getText (configFile >> "CfgVehicles" >> (_typeVehX) >> "displayName")
Array operations for player counting
Coroutine for wait loops with sleep intervals

Function: 
fn_ENC_Trader.sqf
Function Name: fn_ENC_Trader.sqf

What it does:
This function manages the "Trader" side mission in the Antistasi mod. It's responsible for spawning a trader (arms dealer) at a safe, valid location on the map, creating visual markers and effects to help players find it, and tracking player progress to complete the mission. The trader serves as a mobile black market that allows rebels to purchase weapons, vehicles, and gear.

Context: This function is called by the mission scheduler when the "Trader" mission is triggered. It runs exclusively on the server side. The function must ensure the trader is placed in a valid location that's accessible to players but not too close to enemy territory or objectives.

How it does that:
1. Initial Setup and Parameter Validation
Sqf

Apply
params ["_markerX"];

if (!isServer && hasInterface) exitWith{};

Info("Trader Mission Init.");

_positionX = getMarkerPos _markerX;
Parameters: Accepts _markerX, which is the map marker where the trader mission should be centered
Validation: Immediately exits if running on a client with interface (non-server) to prevent duplicate execution
Logging: Records mission initialization with Info()
Coordinate Extraction: Gets the 2D position from the input marker using getMarkerPos
2. Trader Position Search (First Attempt)
Sqf

Apply
private _traderPosition = [
    _positionX, //center
    0, //minimal distance
    300, //maximumDistance
    0, //object distance
    0, //water mode
    0.3, //maximum terrain gradient
    0, //shore mode
    [], //blacklist positions
    [_positionX, _positionX] //default position
] call BIS_fnc_findSafePos;
Algorithm: Uses BIS_fnc_findSafePos to find a valid spawn point within 300m of the marker
Constraints:
Maximum terrain gradient: 0.3 (avoids steep slopes)
No water allowed
No objects within 0m (but will fallback to marker position if no valid location found)
Maximum distance: 300m from center
Safety Check: Includes default position fallback (marker position itself)
3. Validation Checks for Initial Position
Sqf

Apply
private _radGrad = [_traderPosition, 0] call BIS_fnc_terrainGradAngle;

private _outOfBounds = _traderPosition findIf { (_x < 0) || {_x > worldSize}} != -1;

private _enemyBases = (airportsX + milbases + outposts + seaports + factories + resourcesX) select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
private _isTooCloseToOutposts = _enemyBases findIf { _traderPosition distance2d (getMarkerPos _x) < 300 || _traderPosition inArea _x } != -1;
Terrain Gradient Check: Measures actual slope angle at candidate position
Bounds Validation: Checks if position is within world boundaries (0 to worldSize)
Enemy Proximity Check:
Collects all enemy-controlled locations (airports, milbases, outposts, etc.)
Checks if trader is within 300m or inside any enemy area
Uses sidesX global variable to determine ownership
Uses efficient findIf for short-circuit evaluation
4. Fallback Position Search Loop (If First Attempt Fails)
Sqf

Apply
if(!(_radGrad > -0.25 && _radGrad < 0.25) || {isOnRoad _traderPosition || {surfaceIsWater _traderPosition || {_outOfBounds || {_isTooCloseToOutposts}}}}) then {
    private _radiusX = 100;
    while {true} do {
        _traderPosition = [
            _positionX, //center
            0, //minimal distance
            _radiusX, //maximumDistance
            0, //object distance
            0, //water mode
            0.3, //maximum terrain gradient
            0, //shore mode
            [], //blacklist positions
            [_positionX, _positionX] //default position
        ] call BIS_fnc_findSafePos;
        _radGrad = [_traderPosition, 0] call BIS_fnc_terrainGradAngle;
        _outOfBounds = _traderPosition findIf { (_x < 0) || {_x > worldSize}} != -1;
        _isTooCloseToOutposts = _enemyBases findIf { _traderPosition distance2d (getMarkerPos _x) < 300 || _traderPosition inArea _x } != -1;
        if ((_radGrad > -0.25 && _radGrad < 0.25) && {!(isOnRoad _traderPosition) && {!(surfaceIsWater _traderPosition) && {!_outOfBounds && {!_isTooCloseToOutposts}}}}) exitWith {};
        _radiusX = _radiusX + 5;
    };
};
Condition Check: Triggers if any validation fails (steep terrain, on road, water, bounds, or near enemies)
Iterative Search: Loops indefinitely with expanding radius (starts at 100m, increments by 5m each iteration)
Exit Condition: Exits when all criteria are met:
Terrain gradient between -0.25 and 0.25
Not on road
Not on water
Within world bounds
Not too close to enemy outposts
Progressive Expansion: Gradually increases search radius to ensure a valid position is found eventually
5. Trader Creation and Global Synchronization
Sqf

Apply
Info("Trader position: " + str _traderPosition);
traderX = [_traderPosition] call SCRT_fnc_trader_createTrader;
publicVariable "traderX";
Logging: Records the final chosen position
Trader Creation: Calls SCRT_fnc_trader_createTrader with the validated position
This function likely creates a unit with trader behavior, inventory, and actions
Global Synchronization: Uses publicVariable to broadcast traderX object reference to all clients
Critical for multiplayer - ensures all players see the same trader
Clients can reference this object for interactions
6. Visual Marker Creation (Vague)
Sqf

Apply
private _markerVaguePosition = [_traderPosition, 0, 750] call BIS_fnc_findSafePos;
private _traderMarkerVague = createMarkerLocal ["TraderMarkerVague", _markerVaguePosition];
_traderMarkerVague setMarkerColorLocal "ColorUNKNOWN";
_traderMarkerVague setMarkerBrushLocal "DiagGrid";
_traderMarkerVague setMarkerShapeLocal "ELLIPSE";
_traderMarkerVague setMarkerSize [750, 750];
Vague Position: Finds a position up to 750m from actual trader (creates uncertainty)
Local Marker: Uses createMarkerLocal (only visible to local player who created it)
Visual Design:
Elliptical shape with diagnostic grid pattern
"ColorUNKNOWN" (gray/muted color)
Large 750m radius to approximate location
Purpose: Creates a quest marker that shows approximate area rather than exact location
7. Environmental Effects (Burning Barrel & Smoke)
Sqf

Apply
private _barrelPosition = [_traderPosition, 5, 10, 0, 0, 0.3, 0, [], _traderPosition vectorAdd [5,5,0]] call BIS_fnc_findSafePos;
private _barrel = "MetalBarrel_burning_F" createVehicle _barrelPosition;
private _smokeEffect = "#particlesource" createVehicle _barrelPosition;
_smokeEffect setParticleClass "BigDestructionSmoke";
Barrel Position: Finds spot 5-10m from trader (slight randomness for realism)
Burning Barrel: Spawns MetalBarrel_burning_F object for visual beacon
Smoke Effect: Creates particle source with "BigDestructionSmoke" class
Purpose: Helps players locate trader in vegetated areas (A3 design principle)
8. Networked Function Calls
Sqf

Apply
[traderX] remoteExecCall ["SCRT_fnc_trader_setStockType", 0];
[traderX] remoteExecCall ["SCRT_fnc_trader_addVehicleMarketAction", 0, true];
Stock Type Setup: Executes SCRT_fnc_trader_setStockType on all clients (ID 0 = all clients)
Vehicle Market Action: Adds action to view vehicle market (with JIP flag true)
Network Implications: These functions modify trader's behavior for all players
JIP Support: Second call uses true for jip parameter so join-in-progress players get actions
9. Task Creation
Sqf

Apply
_worldName = [] call SCRT_fnc_misc_getWorldName;

private _taskId = "TRADER" + str A3A_taskCount;

[
    [teamPlayer,civilian],
    _taskId,
    [
        format [localize "STR_trader_quest_description", FactionGet(occ,"name"), _worldName, name traderX, FactionGet(occ,"name")],
        localize "STR_trader_quest_header",
        _traderMarkerVague
    ],
    _markerVaguePosition,
    false,
    0,
    true,
    "meet",
    true
] call BIS_fnc_taskCreate;
[_taskId, "TRADER", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Task ID Generation: Uses counter A3A_taskCount for unique IDs
Task Definition:
Owners: teamPlayer and civilian
Description: Localized with world name, faction name, and trader name
Destination: Vague marker position
Type: "meet" (standard Arma task type)
Task Creation: Uses BIS_fnc_taskCreate (Arma's built-in task system)
Initial State: Created as "CREATED", then updates all clients (ID 2 = all clients) via A3A_fnc_taskUpdate
10. Completion Trigger Setup
Sqf

Apply
private _trigger = createTrigger ["EmptyDetector", _traderPosition];
_trigger setTriggerArea [30, 30, 0, false];
Trigger Type: Empty detector (invisible, server-side trigger)
Position: Exact trader location
Area: 30m × 30m, not oriented, no activation on empty vehicles
Purpose: Will detect when any rebel or civilian player enters this area
11. Completion Condition Wait
Sqf

Apply
waitUntil { 
    sleep 1;
    private _conditionMet = false;

    (call BIS_fnc_listPlayers) findIf {(side _x) in [teamPlayer, civilian] && {_x inArea _trigger}} != -1
};
Polling: Checks every second (1Hz) without server load
Player List: Gets all players via BIS_fnc_listPlayers
Condition: Checks if any player:
Is on teamPlayer or civilian side
Is within trigger area
Efficiency: Uses findIf with short-circuit evaluation (stops checking once condition is met)
12. Mission Success State
Sqf

Apply
[_taskId, "TRADER", "SUCCEEDED"] call A3A_fnc_taskSetState;

{
    [5,_x] call A3A_fnc_addScorePlayer;
} forEach (call SCRT_fnc_misc_getRebelPlayers);
[10,theBoss] call A3A_fnc_addScorePlayer;
Task Completion: Updates task state to "SUCCEEDED"
Score Distribution:
Each rebel player: +5 score via A3A_fnc_addScorePlayer
The Boss (admin): +10 score (extra reward)
Rebel Players: Retrieved via SCRT_fnc_misc_getRebelPlayers (online rebel team members)
13. Permanent Marker Creation
Sqf

Apply
traderPosition = _traderPosition;
publicVariable "traderPosition";

_traderMarker = createMarkerLocal ["TraderMarker", _traderPosition];
_traderMarker setMarkerTypeLocal "hd_objective";
_traderMarker setMarkerSizeLocal [1, 1];
_traderMarker setMarkerTextLocal (localize "STR_marker_arms_dealer");
_traderMarker setMarkerColorLocal "ColorUNKNOWN";
_traderMarker setMarkerAlpha 1;
traderMarker = _traderMarker;
sidesX setVariable [traderMarker,teamPlayer,true];
publicVariable "traderMarker";
Global Position: Broadcasts exact position to all clients
Permanent Marker:
Icon: "hd_objective" (objective icon)
Text: "Arms Dealer" (localized)
Color: "ColorUNKNOWN"
Visible to all players (local marker, but copied globally)
Team Ownership: Records marker ownership in sidesX namespace (teamPlayer)
Public Variables: Both position and marker reference broadcast to all clients
14. State Variable Updates
Sqf

Apply
isTraderQuestAssigned = false;
isTraderQuestCompleted = true;
publicVariable "isTraderQuestAssigned";
publicVariable "isTraderQuestCompleted";
Mission Status: Marks quest as no longer assigned and completed
Global State: Both variables broadcast to sync mission status across all clients
Future Checks: Other systems check these to prevent duplicate trader spawns
15. Cleanup and Finalization
Sqf

Apply
deleteVehicle _barrel;
deleteVehicle _smokeEffect;
deleteVehicle _trigger;
deleteMarker _traderMarkerVague;

[_taskId, "TRADER", 5] spawn A3A_fnc_taskDelete;
Cleanup: Removes temporary objects (barrel, smoke, trigger)
Marker Removal: Deletes the vague quest marker
Task Deletion: Spawns task deletion after 5 seconds (allows sync to propagate)
Permanent Assets: Trader unit and permanent marker remain for ongoing use
Where it leads:
Functions Called (Directly):
SCRT_fnc_trader_createTrader - Creates the trader unit object with inventory and actions
SCRT_fnc_trader_setStockType - Configures trader's inventory (executed on all clients)
SCRT_fnc_trader_addVehicleMarketAction - Adds vehicle purchase actions to trader
SCRT_fnc_misc_getWorldName - Returns display name of current map (e.g., "Altis")
BIS_fnc_findSafePos - Arma's safe position finder (used 3x: vague pos, barrel pos, fallback loop)
BIS_fnc_terrainGradAngle - Measures terrain slope at position
BIS_fnc_taskCreate - Arma's task system (creates quest entry in task list)
A3A_fnc_taskUpdate - Updates task state across network (BIS_fnc_taskSetState does too)
A3A_fnc_taskSetState - Changes task completion status
A3A_fnc_addScorePlayer - Awards score to individual players
SCRT_fnc_misc_getRebelPlayers - Returns array of online rebel players
A3A_fnc_taskDelete - Removes task from list after delay
Functions That Call This:
Mission Scheduler (A3A_fnc_scheduler) - Calls this when "Trader" mission is selected
Debug/Testing Systems - May call directly for testing trader functionality
Admin Commands - Possible admin spawn command for trader
Global Variables Modified:
traderX (object) - The trader unit object reference (publicVariable)
traderPosition (array) - Exact 3D position of trader (publicVariable)
traderMarker (string) - Marker name for permanent trader location (publicVariable)
isTraderQuestAssigned (bool) - Mission assignment state (publicVariable)
isTraderQuestCompleted (bool) - Mission completion state (publicVariable)
sidesX (namespace) - Adds trader marker ownership (teamPlayer)
A3A_taskCount (int) - Incremented for unique task IDs
Network Synchronization:
Public Variables: traderX, traderPosition, traderMarker, isTraderQuestAssigned, isTraderQuestCompleted broadcast to all clients
Remote Executions:
remoteExecCall with ID 0 (all clients) for trader setup
remoteExecCall with ID 2 (all clients) for task updates
JIP Support: Vehicle market action uses JIP flag for join-in-progress players
Trigger: Server-side only, no network effect
Integration with Larger System:
Mission System: Part of Antistasi's dynamic mission pool
Trader Economy: Integrates with SCRT_fnc_trader_* functions for inventory/vehicle system
Task System: Uses Arma's BIS task framework for UI integration
Scoring System: Connects to A3A_fnc_addScorePlayer for progression
Location Validation: Uses sidesX to avoid spawning in enemy territory
World Awareness: Adapts to current map via SCRT_fnc_misc_getWorldName
Error Handling & Edge Cases:
No Valid Position Found: While loop expands indefinitely until valid position found (theoretically impossible on most maps)
Network Failures: If publicVariable fails, clients won't see trader (rare, handled by engine)
Server Crash Mid-Spawn: State variables remain incomplete (mission may re-trigger)
Duplicate Spawns: isTraderQuestAssigned prevents concurrent trader missions
Map Bounds: Explicit checks prevent spawning outside playable area
Enemy Proximity: 300m buffer prevents spawning in active combat zones
Function: 
fn_findIfNearAndHostile.sqf
Function Name: fn_findIfNearAndHostile.sqf

What it does:
This function searches for enemy-controlled markers near a given reference unit/object. It can return either the closest hostile marker or a list of all hostile markers within distance, sorted by proximity. It's used for tactical AI decisions, mission targeting, and proximity alerts.

Context: Called by various AI and mission functions when needing to locate hostile territory for attack planning, avoidance, or detection. Commonly used in convoy route planning, unit behavior, and dynamic mission spawning.

How it does that:
1. Parameter Validation with Defaults
Sqf

Apply
params [  
    ["_markers", []],
    ["_unit", ObjNull],
    ["_createList", true]
];
Parameter Parsing: Uses SQF params with default values:
_markers: Empty array (will be populated with eligible markers)
_unit: ObjNull (empty object if not provided)
_createList: true (returns list by default)
Type Safety: SQF automatically converts types where possible, but ObjNull provides fallback
2. Reference Position Extraction
Sqf

Apply
private _referencePos = getPosWorld _unit;
Position Source: Uses getPosWorld for precise 3D position (better than getPos for objects)
Fallback: If _unit is ObjNull, getPosWorld returns [0,0,0] (still usable)
World Space: Position in world coordinates (not map grid)
3. Initial Candidate Filter
Sqf

Apply
private _nearestMarkers = [allMapMarkers, _referencePos] call BIS_fnc_nearestPosition;
_markers = _markers select {((getMarkerPos _x distance2D getMarkerPos _nearestMarkers) < distanceMission) && (sidesX getVariable [_x,sideUnknown] != teamPlayer)};
Nearest Marker: Finds single closest marker from entire map using BIS_fnc_nearestPosition
Distance Filter: Filters input markers based on distance to nearest marker
Uses distanceMission global variable (likely mission radius, e.g., 2000m)
Key Logic: Only considers markers within distanceMission of nearest marker (not reference position)
Hostility Filter: Checks if marker owner is NOT teamPlayer
Uses sidesX namespace with sideUnknown fallback
Filters to enemy-controlled markers only
4. Proximity Sorting
Sqf

Apply
_markers = [_markers,[],{_referencePos distanceSqr getMarkerPos _x},"ASCEND"] call BIS_fnc_sortBy;
Efficient Sorting: Uses squared distance (distanceSqr) for performance
Sort Order: Ascending (closest first)
Empty Array Handling: If _markers is empty, sort returns empty array
SQF Language Note: distanceSqr avoids sqrt calculation, much faster for distance comparisons
5. Return Logic Branching
Sqf

Apply
if (!_createList && {_markers isNotEqualTo []}) exitWith {
	_markers select 0;
};

_markers
Single Marker Mode: If _createList is false and array not empty, return only closest marker
List Mode: Otherwise return full sorted array (or empty array)
Modern Syntax: Uses isNotEqualTo (faster than !=) for array comparison
Where it leads:
Functions Called (Directly):
BIS_fnc_nearestPosition - Finds nearest marker from all map markers
BIS_fnc_sortBy - Sorts array using custom key function
Functions That Call This:
A3A_fnc_scheduler - For mission targeting decisions
A3A_fnc_createAttackForceLand - To find nearby enemy bases for attack planning
A3A_fnc_convoyMovement - To check route safety
A3A_fnc_underAttack - To detect nearby threats
A3A_fnc_createAIcontrols - To spawn forces near enemy territory
Mission-specific functions - For dynamic objective selection
Global Variables Read:
distanceMission (number) - Mission radius for proximity check (e.g., 2000m)
sidesX (namespace) - Marker ownership data
teamPlayer (side) - Player's side (BLUFOR/OPFOR)
allMapMarkers (array) - All map markers (from mission config)
worldSize (number) - Map dimensions (implied in allMapMarkers)
Network Synchronization:
None: Pure server-side calculation function
No Public Variables: Doesn't modify any global state
No Remote Execution: No network calls
Integration with Larger System:
Tactical AI: Used by AI commanders to prioritize targets
Mission Spawning: Determines where to spawn new missions/events
Convoy Routing: Checks if routes cross hostile territory
Threat Assessment: Used by defensive systems to detect proximity to enemies
Resource Allocation: Helps decide where to send reinforcements
Error Handling & Edge Cases:
Empty Input: If _markers empty, returns empty array (no results)
No Hostile Markers: Returns empty array if all markers are owned by teamPlayer
Unit is ObjNull: Uses [0,0,0] as reference (may return incorrect results)
Marker Position Missing: getMarkerPos on invalid marker returns [0,0,0] (may cause false positives)
Performance: Efficient due to distanceSqr and short-circuit evaluation
Distance Logic: Note the nested distance check (to nearestMarker, not reference) - this is a design choice to reduce computation

fn_LOG_Airdrop.sqf
Function Name: A3A_fnc_LOG_Airdrop

What it does: This function manages a logistics mission where rebels need to coordinate with a friendly aircraft to intercept and secure airdropped cargo from enemy forces. The mission involves intercepting enemy escort vehicles at a designated location, signaling for the friendly aircraft to drop supplies, and then delivering those supplies back to rebel HQ. The mission features dynamic difficulty scaling based on the war tier, includes enemy escort forces, and has multiple failure conditions (timeout, aircraft destroyed, or supplies not delivered).

How it does that:

1. Initialization and Parameter Validation
Sqf

Apply
if (!isServer and hasInterface) exitWith{};

params ["_markerX"];

Info ("Airdrop mission init.");

private _vehicles = [];
private _groups = [];
private _boxes = [];
Exits immediately if executed on non-server clients (including players with interfaces)
Accepts one parameter: _markerX (string) - the marker name where the airdrop will occur
Initializes empty arrays to track spawned entities for cleanup later
Logs the mission initialization to the server log
2. Faction and Difficulty Setup
Sqf

Apply
private _sideX = if (sidesX getVariable [_markerX, sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
private _difficultX = random 10 < tierWar;
private _positionX = getMarkerPos _markerX;
Determines which side owns the marker (defaulting to Invaders if unknown)
Retrieves the faction definition for the enemy side
Calculates difficulty: random 10 < tierWar means higher war tier = more likely difficult mode (more enemy forces, less time)
Gets the actual position of the marker on the map
3. Mission Timer Setup
Sqf

Apply
private _limit = if (_difficultX) then {
    45 call SCRT_fnc_misc_getTimeLimit
} else {
    60 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
Sets a 45-minute timer for difficult mode, 60 minutes for normal mode
Calls SCRT_fnc_misc_getTimeLimit which returns [dateNumber, formattedTime]
_dateLimitNum is the mission expiration time in Arma's date format (number)
_displayTime is the human-readable time limit (e.g., "00:45:00")
4. Task Creation
Sqf

Apply
private _nameDest = [_markerX] call A3A_fnc_localizar;
private _taskId = "LOG" + str A3A_taskCount;

[
    [teamPlayer,civilian],
    _taskId,
    [
        format [localize "STR_A3A_Missions_DES_Airdrop_task_desc", _nameDest, _displayTime],
        localize "STR_A3A_Missions_LOG_Airdrop_task_header",
        _markerX
    ],
    _positionX,
    false,
    0,
    true,
    "plane",
    true
] call BIS_fnc_taskCreate;
[_taskId, "LOG", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Gets localized destination name for the task title
Creates unique task ID using global A3A_taskCount counter
Uses BIS_fnc_taskCreate to create an Arma task for players and civilians
Task description references the destination and time limit
Task type is "plane" (logistics)
Immediately updates task state to "CREATED" on all clients (code 2 = players)
5. Player Detection and Welcome Message
Sqf

Apply
waitUntil {sleep 1; (call SCRT_fnc_misc_getRebelPlayers) findIf {_x inArea [_positionX, 75, 75, 0, false]} != -1 or {dateToNumber date > _dateLimitNum}};

[petros,"sideChat",localize "STR_chats_airdrop_pilot_drop_cargo_zone"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
Waits until either:
A rebel player enters the 150x150 meter zone (75m radius)
Or the mission timer expires
After waiting, broadcasts a message from Petros to all rebel players about the pilot dropping cargo
6. Spawn Enemy Escort Forces
Sqf

Apply
private _escortClass = if(_difficultX) then { 
    selectRandom ((_faction get "vehiclesAPCs") + (_faction get "vehiclesLightAPCs"))
} else {
    selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesLightUnarmed"))
};
Selects escort vehicle type based on difficulty:
Difficult: Random APC or light APC (heavily armored)
Normal: Random light armed or unarmed vehicle (jeep, truck)
Sqf

Apply
if (isNil "_escortClass") exitWith {
    ["LOG"] remoteExec ["A3A_fnc_missionRequest",2];
    Error("Problems with faction templates, rerequesting new logistics mission.");
};
If no suitable escort vehicle exists in faction template, requests a new logistics mission and aborts
Sqf

Apply
private _squad1Position = [
    _positionX,
    600,
    distanceSPWN,
    3,
    0,
    0.7,
    0,
    [],
    [_positionX, _positionX]
] call BIS_fnc_findSafePos;

private _escortVehicleData = [_squad1Position, 0, _escortClass, _sideX] call A3A_fnc_spawnVehicle;
private _escortVeh = _escortVehicleData select 0;
Finds a safe position 600m from the drop zone (using distanceSPWN as max distance)
Spawns the escort vehicle using A3A_fnc_spawnVehicle which returns [vehicle, crew, group]
Gets the vehicle object from the data array
7. Spawn Infantry Escort
Sqf

Apply
private _infantrySquadArray  = [_escortClass, _sideX] call A3A_fnc_cargoSeats;

Info_2("Vehicle: %1, infantry array: %2", _escortClass, str _infantrySquadArray);

private _vehCrew = crew _escortVeh;
{[_x] call A3A_fnc_NATOinit} forEach _vehCrew;
[_escortVeh, _sideX] call A3A_fnc_AIVEHinit;
private _escortVehicleGroup = _escortVehicleData select 2;
_groups pushBack _escortVehicleGroup;
_vehicles pushBack _escortVeh;
Gets the infantry squad that can fit in the escort vehicle using A3A_fnc_cargoSeats
Initializes vehicle crew with A3A_fnc_NATOinit (sets skill, loadout, etc.)
Initializes vehicle with A3A_fnc_AIVEHinit (sets damage tolerance, etc.)
Tracks the vehicle group and vehicle for later cleanup
Sqf

Apply
private _typeGroup = selectRandom ([_faction, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier);
private _groupX = [_squad1Position, _sideX, _typeGroup] call A3A_fnc_spawnGroup;
{
    _x assignAsCargo _escortVeh; 
    _x moveInCargo _escortVeh; 
    [_x] join _escortVehicleGroup; 
    [_x] call A3A_fnc_NATOinit;
} forEach units _groupX;
deleteGroup _groupX;

_infGroup1 = [_squad1Position, _sideX, _infantrySquadArray] call A3A_fnc_spawnGroup;
{
    [_x] call A3A_fnc_NATOinit;
} forEach units _infGroup1;
_groups pushBack _infGroup1;
Spawns a small infantry group that will ride in the escort vehicle
Each unit is assigned as cargo and moved into the vehicle
Units are joined to the vehicle's group to maintain coordination
A second infantry group (for additional escort on foot) is spawned and initialized
Both groups are tracked for cleanup
8. Additional Difficulty Forces
Sqf

Apply
if(_difficultX) then {
    private _squad2Position = [
        _positionX,
        600,
        distanceSPWN,
        3,
        0,
        0.7,
        0,
        [],
        [_positionX, _positionX]
    ] call BIS_fnc_findSafePos;

    _infGroup2 = [_squad2Position, _sideX, _infantrySquadArray] call A3A_fnc_spawnGroup;
    {
        [_x] call A3A_fnc_NATOinit;
    } forEach units _infGroup2;
    _groups pushBack _infGroup2;

    _infGroup2Wp = _infGroup2 addWaypoint [_positionX, 1];
    _infGroup2Wp setWaypointType "MOVE";
    _infGroup2Wp setWaypointBehaviour "AWARE";
    _infGroup2Wp setWaypointSpeed "FULL";
    Info_1("Additional Group: %1", _infGroup2);
};
In difficult mode, spawns an additional infantry group at a different location
Sets a waypoint for this group to move to the drop zone at full speed
This group will converge on the objective from a different direction
9. Move Forces to Drop Zone
Sqf

Apply
private _escortWP = _escortVehicleGroup addWaypoint [_positionX, 0];
_escortWP setWaypointType "MOVE";
_escortWP setWaypointBehaviour "AWARE";
_escortWP setWaypointSpeed "FULL";
Info_2("Placed Group: %1 in Lite Vehicle and set waypoint %2", _typeGroup, _positionX);

_infGroup1Wp = _infGroup1 addWaypoint [_positionX, 1];
_infGroup1Wp setWaypointType "MOVE";
_infGroup1Wp setWaypointBehaviour "AWARE";
_infGroup1Wp setWaypointSpeed "FULL";
Info_1("Group: %1", _infGroup1);
Sets waypoints for both the vehicle group and infantry group to move to the drop zone
Waypoint behavior is "AWARE" (ready for combat), speed is "FULL"
10. Wait for Signal (Smoke Grenade)
Sqf

Apply
waitUntil {
    sleep 1;
    private _smokes = _positionX nearObjects ["SmokeShell", 200];
    count _smokes > 0 || {dateToNumber date > _dateLimitNum}
};
Polls every second for smoke grenades within 200m of the drop zone
Also checks for mission timeout
The first player to drop smoke triggers the airdrop
11. Spawn Friendly Aircraft
Sqf

Apply
Info("Smoke detected, spawning airplane.");

private _initialPlanePosition = [
    _positionX,
    1500,
    2000,
    0,
    0,
    1,
    0,
    [],
    [_positionX, _positionX]
] call BIS_fnc_findSafePos;
private _height = random [500, 1000, 1300];
private _direction = [_initialPlanePosition, _positionX] call BIS_fnc_DirTo;

_planeType = selectRandom (FactionGet(reb, "vehiclesPlane"));
_planeData = [[_initialPlanePosition select 0, _initialPlanePosition select 1, _height], _direction, _planeType, teamPlayer] call A3A_fnc_spawnVehicle;
_planeVeh = _planeData select 0;
_planeVeh setPosATL [getPosATL _planeVeh select 0, getPosATL _planeVeh select 1, _height];
_planeVeh disableAI "TARGET";
_planeVeh disableAI "AUTOTARGET";
_planeVeh flyInHeight 105;

private _minAltASL = ATLToASL [_positionX select 0, _positionX select 1, 0];
_planeVeh flyInHeightASL [(_minAltASL select 2) +100, (_minAltASL select 2) +100, (_minAltASL select 2) +100];

_planeGroup = _planeData select 2;
_groups pushBack _planeGroup;

driver _planeVeh setCaptive true;
Finds a spawn position 1500-2000m away from the drop zone
Selects a random plane from the rebel faction
Spawns the plane with the teamPlayer side
Disables AI targeting and automatic targeting to prevent it from attacking enemies
Sets flight height to 105m (above ground)
Converts drop zone altitude to ASL and sets flight height accordingly (ensures it flies over the zone)
Makes the plane captive (invulnerable to friendly fire)
Tracks the plane group for cleanup
12. Drop Zone Navigation and Communication
Sqf

Apply
private _smokes = _positionX nearObjects ["SmokeShell", 200];
private _dropPosition = _positionX;

if(count _smokes > 0) then {
    private _smoke = _smokes select 0;
    _dropPosition = position _smoke;
};

_wp1 = group _planeVeh addWaypoint [_dropPosition, 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointSpeed "LIMITED";
_wp1 setWaypointBehaviour "CARELESS";

sleep 2;
private _textX = format [localize "STR_chats_airdrop_pilot_smoke", mapGridPosition _positionX];
[driver _planeVeh,"sideChat",_textX] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
Updates the drop position to the exact location of the first smoke grenade found
Sets a waypoint for the plane to fly over the smoke at limited speed and careless behavior (won't react to threats)
Waits 2 seconds, then broadcasts the pilot's message about the drop zone location
13. Wait for Aircraft Arrival
Sqf

Apply
waitUntil {
    sleep 1;
    (!(isNull _planeVeh) && {_planeVeh inArea [_positionX, 100, 100, 0, false]}) || (dateToNumber date > _dateLimitNum) || !(alive _planeVeh)
};
Waits for the plane to enter a 200x200m area around the drop zone
Also fails if the plane is destroyed or the mission times out
14. Execute Airdrop
Sqf

Apply
if(alive _planeVeh) then {
    Info("Airdropping cargo.");
    [driver _planeVeh,"sideChat",localize "STR_chats_airdrop_pilot_drop_cargo"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];

    private _boxType = [
        "CargoNet_01_barrels_F",
        "Land_FoodSacks_01_cargo_brown_F"
    ] select (random 100 < 50);
If the plane is still alive, proceed with the airdrop
Broadcasts a message that cargo is being dropped
Randomly selects either barrels or food sacks (50/50 chance)
Sqf

Apply
    _planeVeh allowDamage false;
    sleep 1;
    private _box1 = [_boxType,position _planeVeh] call SCRT_fnc_common_airdropCargo;
    _box1 enableRopeAttach true;
    _box1 allowDamage false;
    [_box1] call A3A_Logistics_fnc_addLoadAction;
    [_box1, teamPlayer] call A3A_fnc_AIVEHinit;
    
    _airDropHappened = true;

    sleep 1;

    private _box2Class = [ 
        (["CargoNet_01_barrels_F", "Land_FoodSacks_01_cargo_brown_F"] select (random 100 < 50)),
        _faction get "ammobox"
    ] select _difficultX;

    private _box2 = [_box2Class,position _planeVeh] call SCRT_fnc_common_airdropCargo;
    _box2 enableRopeAttach true;
    _box2 allowDamage false;
    [_box2] call A3A_Logistics_fnc_addLoadAction;
    [_box2, teamPlayer] call A3A_fnc_AIVEHinit;

    if (_box2Class isEqualTo (_faction get "ammobox")) then {
        [_box2] spawn A3A_fnc_fillLootCrate;
    };

    _boxes append [_box1, _box2];

    if(sunOrMoon < 1) then {
        [_box1, [0, 0, 1]] remoteExec ["SCRT_fnc_common_attachLightSource", 0, _box1];
        [_box2, [0, 0, 1]] remoteExec ["SCRT_fnc_common_attachLightSource", 0, _box2];
    };
Makes the plane invulnerable temporarily during drop
Drops the first box using SCRT_fnc_common_airdropCargo which handles the physics of the drop
Enables rope attachment for helicopter/rope pickup
Adds a load action to the box for logistics (ability to load into vehicles)
Initializes the box with teamPlayer side
Important: Sets _airDropHappened = true which determines mission success/failure
Waits 1 second
Selects the second box:
Normal mode: Either barrels or food sacks
Difficult mode: Enemy ammobox (fills with loot)
If the second box is an enemy ammobox, fills it with loot using A3A_fnc_fillLootCrate
Appends both boxes to the tracking array
During night, adds a light source to each box so they're visible
Sqf

Apply
    sleep 5;
    [driver _planeVeh,"sideChat",localize "STR_chats_airdrop_pilot_drop_cargo_end"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
    private _finalPosition = [_positionX, 3000, random 360] call BIS_fnc_relPos;
    _wp2 = group _planeVeh addWaypoint [_finalPosition, 1];
    _wp2 setWaypointSpeed "FULL";
    _wp2 setWaypointType "MOVE";
    _wp2 setWaypointStatements ["true","deleteVehicle this"];

    driver _planeVeh setCaptive false;
    _planeVeh allowDamage true;
Waits 5 seconds, then broadcasts that the drop is complete
Sends the plane to a random position 3000m away from the drop zone
Adds waypoint statement to delete the plane when it reaches its destination
Makes the plane vulnerable again (captive disabled)
15. Mission Completion Check
Sqf

Apply
waitUntil {sleep 1;  dateToNumber date > _dateLimitNum || {!(_airDropHappened) || {_boxes findIf {_x distance (getMarkerPos respawnTeamPlayer) < 25} != -1}}};
Waits for one of three conditions:
Mission timeout
Airdrop didn't happen (plane destroyed before drop)
Any box is within 25m of rebel HQ
16. Success Condition Check
Sqf

Apply
private _boxesOnRebelHq = false;
{
    if(_x distance (getMarkerPos respawnTeamPlayer) < 25) exitWith {
        _boxesOnRebelHq = true;
    };
} forEach _boxes;
Iterates through all dropped boxes to check if any are at HQ
17. Mission Outcome Handling
Sqf

Apply
switch(true) do {
    case (_boxesOnRebelHq): {
        Info("Success, Boxes on HQ.");
        sleep 5;

        private _boxesCount = { _x distance (getMarkerPos respawnTeamPlayer) < 25 } count _boxes;

        {
            if ((typeOf _x) isEqualTo (_faction get "ammobox")) then {
                [_x] remoteExec ["jn_fnc_arsenal_cargoToArsenal",2];
            };
        } forEach _boxes;

        { 
            [300 * _boxesCount,_x] call A3A_fnc_addMoneyPlayer;
            [10 * _boxesCount, _x] call A3A_fnc_addScorePlayer;
        } forEach (call SCRT_fnc_misc_getRebelPlayers);
        [10, theBoss] call A3A_fnc_addScorePlayer;
        [250, theBoss, true] call A3A_fnc_addMoneyPlayer;

        [_taskId, "LOG", "SUCCEEDED"] call A3A_fnc_taskSetState;
    };
Success: If boxes are at HQ
Counts how many boxes reached HQ
Converts enemy ammoboxes to arsenal (code 2 = server)
Awards money and score to all rebel players based on box count
Bonus for the boss
Sets task to SUCCEEDED
Sqf

Apply
    case (dateToNumber date > _dateLimitNum): {
        Info("Fail, mission Expired.");
        [2, "Fail, mission Expired.", _fileName, true] call A3A_fnc_log;
        [_taskId, "LOG", "FAILED"] call A3A_fnc_taskSetState;
        [-25,theBoss] call A3A_fnc_addScorePlayer;
    };
Failure: Mission timed out
Logs the failure
Sets task to FAILED
Penalizes the boss with score reduction
Sqf

Apply
    case (!(_airDropHappened)): {
        Info("Fail, plane was shot down.");
        [_taskId, "LOG", "FAILED"] call A3A_fnc_taskSetState;
    };
Failure: Plane was destroyed before dropping cargo
Sets task to FAILED
No explicit penalty mentioned (implied by lack of rewards)
Sqf

Apply
    default {
        Warning("Unknown condition, aborting mission");
        [_taskId, "LOG", "CANCELED"] call A3A_fnc_taskSetState;
    };
};
Fallback: Unexpected condition
Sets task to CANCELED
Logs a warning
18. Cleanup
Sqf

Apply
sleep 30;

[_taskId, "LOG", 1200] spawn A3A_fnc_taskDelete;

{
    deleteVehicle _x;
} forEach _boxes;

{
    [_x] spawn A3A_fnc_vehDespawner
} forEach _vehicles;

{
    [_x] spawn A3A_fnc_groupDespawner
} forEach _groups;

if(!isNil "_planeVeh" || {!isNull _planeVeh}) then {
    deleteVehicle _planeVeh;
};

Info("Airdrop cleanup complete.");
Waits 30 seconds before cleanup
Schedules task deletion after 1200 seconds (20 minutes)
Deletes all boxes immediately
Spawns despawners for vehicles and groups (gradual cleanup)
Deletes the plane if it still exists
Logs cleanup completion
Where it leads:

Calls A3A_fnc_localizar - Localizes the marker name
Calls A3A_fnc_taskCreate - Creates the mission task
Calls A3A_fnc_taskUpdate - Updates task state to players
Calls SCRT_fnc_misc_getRebelPlayers - Gets all alive rebel players
Calls A3A_fnc_commsMP - Broadcasts messages to players
Calls SCRT_fnc_misc_getTimeLimit - Calculates mission timer
Calls A3A_fnc_spawnVehicle - Spawns escort vehicle
Calls A3A_fnc_cargoSeats - Gets infantry squad for vehicle
Calls A3A_fnc_NATOinit - Initializes AI units
Calls A3A_fnc_AIVEHinit - Initializes AI vehicle
Calls SCRT_fnc_unit_flattenTier - Gets tiered infantry groups
Calls A3A_fnc_spawnGroup - Spawns infantry groups
Calls SCRT_fnc_common_airdropCargo - Creates and drops cargo boxes
Calls A3A_Logistics_fnc_addLoadAction - Adds logistics load action
Calls A3A_fnc_fillLootCrate - Fills enemy ammobox with loot
Calls jn_fnc_arsenal_cargoToArsenal - Converts boxes to arsenal
Calls A3A_fnc_addMoneyPlayer - Awards money to players
Calls A3A_fnc_addScorePlayer - Awards score to players
Calls A3A_fnc_taskSetState - Sets final task state
Calls A3A_fnc_taskDelete - Schedules task cleanup
Calls A3A_fnc_vehDespawner - Despawns vehicles
Calls A3A_fnc_groupDespawner - Despawns groups
Calls SCRT_fnc_common_attachLightSource - Adds lights to boxes at night
Calls A3A_fnc_missionRequest - Re-requests mission if faction is broken
Global variables modified:

_vehicles, _groups, _boxes - Local arrays tracking spawned entities
A3A_taskCount - Not directly modified, but used to create unique task IDs
sidesX - Not modified
tierWar - Not modified, only read for difficulty calculation
Synchronization/Network implications:

All player-facing communications use remoteExec with specific target arrays ([teamPlayer,civilian])
Task creation and updates are broadcast to all relevant players
The mission flow is server-authoritative, with client-side interactions (smoke detection)
Money and score awards are applied locally on each client or via remote execution
fn_LOG_Ammo.sqf
Function Name: A3A_fnc_LOG_Ammo

What it does: This function manages a logistics mission where rebels need to either steal an enemy ammunition truck or destroy it. The mission involves locating an ammunition truck at an enemy-controlled location, securing it (or destroying it), and delivering it back to rebel HQ for rewards. The mission features difficulty scaling based on war tier, with different enemy force compositions.

How it does that:

1. Initialization and Setup
Sqf

Apply
params ["_markerX"];

if (!isServer and hasInterface) exitWith{};

private _difficultX = if (random 10 < tierWar) then {true} else {false};
private _positionX = getMarkerPos _markerX;
private _sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
Accepts _markerX (string) - enemy marker location
Exits if not on server
Calculates difficulty based on tierWar
Gets marker position and owning side
Retrieves faction definition
2. Mission Timer
Sqf

Apply
private _limit = if (_difficultX) then {
    30 call SCRT_fnc_misc_getTimeLimit
} else {
    60 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
Difficult mode: 30 minutes
Normal mode: 60 minutes
Returns formatted timer for display
3. Find Truck Location
Sqf

Apply
private _nameDest = [_markerX] call A3A_fnc_localizar;
private _typeVehX = selectRandom (_faction get "vehiclesAmmoTrucks");
private _size = [_markerX] call A3A_fnc_sizeMarker;

private _road = [_positionX] call A3A_fnc_findNearestGoodRoad;
private _pos = position _road;
_pos = _pos findEmptyPosition [1,60,_typeVehX];
if (count _pos == 0) then {_pos = position _road};
Localizes marker name for task description
Selects a random ammunition truck from faction's vehicle list
Gets marker size (used for patrol area)
Finds nearest road to marker center
Finds an empty position near the road (60m radius) to spawn the truck
Falls back to road position if no empty spot found
4. Task Creation
Sqf

Apply
private _taskId = "LOG" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_A3A_Missions_LOG_Ammo_task_desc",_nameDest,_displayTime],localize "STR_A3A_Missions_LOG_Ammo_task_header",_markerX],_pos,false,0,true,"rearm",true] call BIS_fnc_taskCreate;
[_taskId, "LOG", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Creates unique task ID
Creates task with "rearm" icon
Updates task state to CREATED on clients
5. Wait for Zone Activation
Sqf

Apply
waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or {(spawner getVariable _markerX != 2 and !(sidesX getVariable [_markerX,sideUnknown] == teamPlayer))}};
private _bonus = if (_difficultX) then {2} else {1};
Waits for either:
Mission timeout
Marker is activated (spawned) AND not owned by rebels
Sets bonus multiplier (2x for difficult, 1x for normal)
6. Spawn Truck and Guards
Sqf

Apply
if ((spawner getVariable _markerX != 2) and !(sidesX getVariable [_markerX,sideUnknown] == teamPlayer)) then {
    private _truckX = _typeVehX createVehicle _pos;
    _truckX setDir (getDir _road);
    [_truckX] spawn A3A_fnc_fillLootCrate;
    [_truckX, _sideX] call A3A_fnc_AIVEHinit;

    private _mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], _pos];
    _mrk setMarkerShapeLocal "RECTANGLE";
    _mrk setMarkerSizeLocal [20,20];
    _mrk setMarkerTypeLocal "hd_warning";
    _mrk setMarkerColorLocal "ColorRed";
    _mrk setMarkerBrushLocal "DiagGrid";
    if (!debug) then {_mrk setMarkerAlphaLocal 0};
Creates the ammunition truck
Fills it with loot using A3A_fnc_fillLootCrate
Initializes it with AI vehicle handler
Creates a local debug marker for patrol area (invisible if not in debug mode)
7. Spawn Patrol Groups
Sqf

Apply
    private _typeGroup = if (_difficultX) then {
        selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)
    } else {
        selectRandom ([_faction, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier)
    };
    _groupX = [_pos,_sideX, _typeGroup] call A3A_fnc_spawnGroup;
    sleep 1;
    if (random 10 < 33) then
        {
        _dog = [_groupX, "Fin_random_F",_positionX,[],0,"FORM"] call A3A_fnc_createUnit;
        [_dog] spawn A3A_fnc_guardDog;
        };

    [_groupX, "Patrol_Area", 25, 50, 100, false, [], false] call A3A_fnc_patrolLoop;

    _groupX1 = [_pos,_sideX,_typeGroup] call A3A_fnc_spawnGroup;
    sleep 1;

    [_groupX1, "Patrol_Area", 25, 50, 100, false, [], false] call A3A_fnc_patrolLoop;

    {[_x,""] call A3A_fnc_NATOinit} forEach units _groupX;
    {[_x,""] call A3A_fnc_NATOinit} forEach units _groupX1;
Spawns patrol group type based on difficulty
33% chance to spawn a guard dog in the first group
Assigns both groups to patrol the area around the truck (25-100m radius)
Initializes all units with A3A_fnc_NATOinit
8. Mission Check Loop
Sqf

Apply
    private _fnc_truckReturnedToBase = {
        //DistanceSqr is faster, and we're hard coding it anyway.
        (_truckX distanceSqr posHQ) < 10000;
    };

    waitUntil {sleep 3; (not alive _truckX) or (dateToNumber date > _dateLimitNum) or (call _fnc_truckReturnedToBase)};
Defines a function to check if truck is near HQ (100m radius, using squared distance for performance)
Polls every 3 seconds for:
Truck destroyed
Mission timeout
Truck returned to base
9. Handle Time Limit Expiration
Sqf

Apply
    if (dateToNumber date > _dateLimitNum) then {
        [_taskId, "LOG", "FAILED"] call A3A_fnc_taskSetState;
        [-1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
        [-10*_bonus,theBoss] call A3A_fnc_addScorePlayer;
    };
If mission timed out:
Set task to FAILED
Add 1200 * bonus seconds to enemy cooldown timer
Penalize boss with score reduction
10. Handle Truck Destroyed or Returned
Sqf

Apply
    if (!alive _truckX or {(call _fnc_truckReturnedToBase)}) then {
        [_taskId, "LOG", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0,300*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
        [1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
        {
            [15 * _bonus,_x] call A3A_fnc_addScorePlayer;
            [300 * _bonus,_x] call A3A_fnc_addMoneyPlayer;
        } forEach (call SCRT_fnc_misc_getRebelPlayers);
        [5,theBoss] call A3A_fnc_addScorePlayer;
        [200,theBoss, true] call A3A_fnc_addMoneyPlayer;
    };
If truck is destroyed or returned to base (both count as success):
Set task to SUCCEEDED
Add 300 * bonus resources to FIA
Add 1200 * bonus seconds to enemy cooldown
Award 15 * bonus score and 300 * bonus money to all rebel players
Award 5 * bonus score and 200 * bonus money to boss
11. Handle Mission Failure
Sqf

Apply
} else {
    [_taskId, "LOG", "FAILED"] call A3A_fnc_taskSetState;
    [-1200*_bonus, _sideX] remoteExec ["A3A_fnc_timingCA",2];
    [-10*_bonus,theBoss] call A3A_fnc_addScorePlayer;
};
If the marker was already taken by rebels or not spawned:
Set task to FAILED
Add 1200 * bonus seconds to enemy cooldown
Penalize boss with score reduction
12. Cleanup
Sqf

Apply
[_taskId, "LOG", 1200] spawn A3A_fnc_taskDelete;
if (!isNull _truckX) then {
    // TODO: Head off to nearby base
    [_groupX] spawn A3A_fnc_groupDespawner;
    [_groupX1] spawn A3A_fnc_groupDespawner;
    [_truckX] spawn A3A_fnc_vehDespawner;
    // delete truck contents maybe?
};
Schedules task deletion after 1200 seconds
Despawns guard groups and truck
Note: The TODO comment suggests they might have planned to have the truck drive away (not implemented)
Where it leads:

Calls A3A_fnc_localizar - Localizes marker name
Calls SCRT_fnc_misc_getTimeLimit - Calculates mission timer
Calls A3A_fnc_sizeMarker - Gets marker size
Calls A3A_fnc_findNearestGoodRoad - Finds spawn location
Calls A3A_fnc_taskCreate - Creates mission task
Calls A3A_fnc_taskUpdate - Updates task state
Calls A3A_fnc_fillLootCrate - Fills truck with loot
Calls A3A_fnc_AIVEHinit - Initializes truck
Calls SCRT_fnc_unit_flattenTier - Gets tiered infantry groups
Calls A3A_fnc_spawnGroup - Spawns patrol groups
Calls A3A_fnc_createUnit - Spawns guard dog
Calls A3A_fnc_guardDog - Makes dog patrol
Calls A3A_fnc_patrolLoop - Assigns patrol behavior
Calls A3A_fnc_NATOinit - Initializes AI units
Calls A3A_fnc_taskSetState - Sets final task state
Calls A3A_fnc_timingCA - Modifies enemy cooldown timer
Calls A3A_fnc_addScorePlayer - Awards/penalizes score
Calls A3A_fnc_resourcesFIA - Awards FIA resources
Calls A3A_fnc_addMoneyPlayer - Awards money
Calls SCRT_fnc_misc_getRebelPlayers - Gets all rebel players
Calls A3A_fnc_taskDelete - Schedules task cleanup
Calls A3A_fnc_groupDespawner - Despawns groups
Calls A3A_fnc_vehDespawner - Despawns vehicle
Global variables modified:

spawner - Not modified, only read
sidesX - Not modified, only read
tierWar - Not modified, only read
Synchronization/Network implications:

Mission activation depends on marker being spawned by spawner system
Resources and cooldown timers are broadcast via remoteExec
All player rewards are applied locally via remoteExec
Task state changes are broadcast to all relevant players
fn_LOG_Bank.sqf
Function Name: A3A_fnc_LOG_Bank

What it does: This function manages a bank robbery logistics mission. Rebels must steal a money truck from a bank location and return it to HQ. The mission involves approaching a heavily guarded bank, triggering an alarm system, resisting enemy reinforcements, and successfully transporting the stolen money back to base. The mission includes a timer for the robbery, call for enemy support, and removal of player disguises.

How it does that:

1. Initialization and Setup
Sqf

Apply
params ["_bank"];
if (!isServer and hasInterface) exitWith {};

private _markerX = [citiesX, _bank] call BIS_fnc_nearestPosition;
private _difficultX = random 10 < tierWar;
private _positionX = getPosATL _bank;
private _posbase = getMarkerPos respawnTeamPlayer;
private _faction = Faction(Occupants);
Accepts _bank (object) - the bank building object
Gets nearest city marker to the bank
Calculates difficulty based on war tier
Gets bank position (ATL, which includes height)
Gets rebel HQ position
Uses Occupants faction (banks are always in civilian/government areas)
2. Mission Timer
Sqf

Apply
private _timeLimit = [60, 120] select !_difficultX;
if (A3A_hasIFA) then {_timeLimit = _timeLimit * 2};
private _limit = _timeLimit call SCRT_fnc_misc_getTimeLimit;
_limit params ["_dateLimitNum", "_displayTime"];
Difficult mode: 60 minutes
Normal mode: 120 minutes
If IFA mod is loaded, doubles the time limit
Returns formatted timer
3. Marker and City Setup
Sqf

Apply
private _city = [citiesX, _positionX] call BIS_fnc_nearestPosition;
private _mrkFinal = createMarker [format ["LOG%1", random 100], _positionX];
private _nameDest = [_city] call A3A_fnc_localizar;
_mrkFinal setMarkerShape "ICON";
Finds nearest city
Creates a marker at bank position for task location
Localizes city name for task description
4. Create Money Truck
Sqf

Apply
private _civDisabled = (A3A_faction_civ getOrDefault ["attributeLowCiv", false] || {A3A_faction_civ getOrDefault ["attributeCivNonHuman", false]});
private _vehiclePool = if (_civDisabled) then { _faction get "vehiclesMilitiaTrucks" } else { A3A_faction_civ get "vehiclesCivIndustrial" } select { _x isEqualType "" }; // * convert weighted list to normal array 
private _bankVehicleClass = selectRandom (A3A_faction_reb getOrDefault ["vehiclesCivSupply", _vehiclePool]);
private _pos = _posbase findEmptyPosition [1, 50, _bankVehicleClass];
private _truckX = _bankVehicleClass createVehicle _pos;
Checks if civilian vehicles are disabled (low civ attribute or non-human)
If disabled, uses militia trucks from Occupants faction
Otherwise uses civilian industrial vehicles
Selects a random truck type
Finds empty position at HQ for truck spawn
Creates the truck at HQ
5. Truck Initialization and Events
Sqf

Apply
{_x reveal _truckX} forEach (allPlayers - entities "HeadlessClient_F");
[_truckX, teamPlayer] call A3A_fnc_AIVEHinit;
_truckX setVariable ["destinationX", _nameDest, true];
_truckX addEventHandler ["GetIn", {
    if (_this select 1 == "driver") then {
        _textX = format [localize "STR_hints_LOG_objective",(_this select 0) getVariable "destinationX"];
        [localize "STR_hints_LOG_Bank_header", _textX] remoteExecCall ["A3A_fnc_customHint", _this select 2];
    };
}];
Reveals the truck to all players (so it's visible on map)
Initializes truck with teamPlayer side
Stores destination name in vehicle variable
Adds GetIn event handler: when player becomes driver, shows hint with objective info
Sqf

Apply
[_truckX, localize "STR_marker_mission_vehicle"] spawn A3A_fnc_inmuneConvoy;
Makes the truck part of a convoy (immune to capture) with convoy marker name
6. Create Task
Sqf

Apply
private _taskId = "LOG" + str A3A_taskCount;
[
    [teamPlayer, civilian], _taskId,
    [format [localize "STR_A3A_Missions_LOG_Bank_task_desc", _nameDest, _displayTime], 
    localize "STR_A3A_Missions_LOG_Bank_task_header", _mrkFinal],
    _positionX, false, 0, true, "Interact", true
] call BIS_fnc_taskCreate;
[_taskId, "LOG", "CREATED"] remoteExec ["A3A_fnc_taskUpdate", 2];
Creates task with "Interact" icon
Task description includes city name and time limit
7. Create Bank Guards
Sqf

Apply
private _groups = [];
private _soldiers = [];
for "_i" from 1 to 4 do {
    private _groupType = if (_difficultX) then { 
        selectRandom ([_faction get "groupsTierSmall"] call SCRT_fnc_unit_flattenTier) 
    } else { 
        _faction get "groupPolice" 
    };
    private _groupX = [_positionX, Occupants, _groupType] call A3A_fnc_spawnGroup;
    sleep 0.5;
    [_groupX, "Patrol_Area", 25, 50, 100, true, _positionX, true] call A3A_fnc_patrolLoop;
    { [_x, ""] call A3A_fnc_NATOinit; _soldiers pushBack _x } forEach units _groupX;
    _groups pushBack _groupX;
};
Spawns 4 guard groups around the bank
Difficult: Random tier small group (combat units)
Normal: Police group (less aggressive)
Each group patrols a 25-100m area around the bank
All units are initialized and tracked
8. Calculate Safe Distance
Sqf

Apply
private _bb = flatten boundingBoxReal _bank apply { abs _x };
private _bankDistMax = (selectMin _bb) + 10;
Gets the bank's bounding box
Calculates maximum distance from bank center for robbery (bank size + 10m)
This is used to check if the truck is close enough to the bank
9. First Wait: Truck Arrival at Bank
Sqf

Apply
waitUntil {
    sleep 1; 
    (dateToNumber date > _dateLimitNum) || 
    !alive _truckX || 
    (_truckX distance _positionX < _bankDistMax)
};
Waits for truck to reach bank, be destroyed, or timeout
10. Handle Mission Failure/Timeout
Sqf

Apply
private _bonus = [1, 2] select _difficultX;
if (dateToNumber date > _dateLimitNum || !alive _truckX) then {
    [_taskId, "LOG", "FAILED"] call A3A_fnc_taskSetState;
    [-(1800 * _bonus), Occupants] remoteExec ["A3A_fnc_timingCA", 2];
    [-10 * _bonus, theBoss] call A3A_fnc_addScorePlayer;
}
Difficult: Bonus multiplier = 2
Normal: Bonus multiplier = 1
If timed out or truck destroyed: FAILED state, penalty to boss, enemy cooldown increase
11. Bank Robbery Triggered
Sqf

Apply
else {
    private _countX = 120 * _bonus;
    private _reveal = [_positionX, Occupants] call A3A_fnc_calculateSupportCallReveal;
    [Occupants, _truckX, _positionX, 4, _reveal] remoteExec ["A3A_fnc_requestSupport", 2];
    [10 * _bonus, -20 * _bonus, _markerX] remoteExec ["A3A_fnc_citySupportChange", 2];
    ["TaskFailed", ["", format [localize "STR_A3A_fn_mission_log_bank_alert", _nameDest]]] remoteExec ["BIS_fnc_showNotification", Occupants];
120 * bonus seconds for robbery timer (120/240 seconds)
Calculates reveal value for support calls
Requests enemy support (4 units, revealing position)
Changes city support: +10 for rebels, -20 for enemies
Sends alert notification to enemy side
12. Remove Player Disguises
Sqf

Apply
    {
        if (_x distance _truckX < 300 && {captive _x} && {isPlayer _x}) then {
            [_x, false] remoteExec ["setCaptive", _x];
        };
    } forEach ([distanceSPWN, 0, _positionX, teamPlayer] call A3A_fnc_distanceUnits);
Finds all rebel players within distanceSPWN of the bank
If they're in captive (undercover) state, removes it
This prevents players from robbing banks while undercover
13. Robbery Timer Loop
Sqf

Apply
    private _exit = false;
    while {_countX > 0 || {_truckX distance _positionX < _bankDistMax && alive _truckX && dateToNumber date < _dateLimitNum}} do {
        while {_countX > 0 && _truckX distance _positionX < _bankDistMax && alive _truckX} do {
            private _formatX = format ["%1", _countX];
            {
                if (isPlayer _x) then {
                    [petros, "countdown", _formatX] remoteExec ["A3A_fnc_commsMP", _x]
                };
            } forEach ([80, 0, _truckX, teamPlayer] call A3A_fnc_distanceUnits);
            sleep 1;
            _countX = _countX - 1;
        };
        if (_countX > 0) then {
            if (_truckX distance _positionX > _bankDistMax) then {
                {
                    if (isPlayer _x) then {
                        [petros, "hint", localize "STR_A3A_Missions_LOG_Bank_task_tip_1", localize "STR_A3A_Missions_LOG_Bank_task_header"] remoteExec ["A3A_fnc_commsMP", _x]
                    };
                } forEach ([200, 0, _truckX, teamPlayer] call A3A_fnc_distanceUnits);
            };
            waitUntil {sleep 1; !alive _truckX || _truckX distance _positionX < _bankDistMax || dateToNumber date >= _dateLimitNum};
        } else {
            if (alive _truckX) then {
                {
                    if (isPlayer _x) then {
                        [petros, "hint", localize "STR_A3A_Missions_LOG_Bank_task_tip_2", localize "STR_A3A_Missions_LOG_Bank_task_header"] remoteExec ["A3A_fnc_commsMP", _x]
                    };
                } forEach ([80, 0, _truckX, teamPlayer] call A3A_fnc_distanceUnits);
                _exit = true;
            };
        };
        if (_exit) exitWith {};
    };
Main loop: Runs while timer > 0 OR truck is near bank and alive
Inner loop (truck at bank):
Count down timer every second
Send countdown message to players within 80m of truck
While counting down, check if truck leaves bank area
If truck leaves bank area:
Send hint message to players within 200m
Wait until truck returns or fails
If timer reaches 0:
Send hint message about robbery complete
Set exit flag
Truck is now considered "robbed" and needs to be delivered to base
14. Second Wait: Truck Return to HQ
Sqf

Apply
waitUntil {
    sleep 1; 
    (dateToNumber date > _dateLimitNum) || 
    !alive _truckX || 
    (_truckX distance _posbase < 50)
};
Waits for truck to return to HQ, be destroyed, or timeout
15. Handle Success/Failure
Sqf

Apply
if (_truckX distance _posbase < 50 && dateToNumber date < _dateLimitNum) then {
    [_taskId, "LOG", "SUCCEEDED"] call A3A_fnc_taskSetState;
    [0, 5000 * _bonus] remoteExec ["A3A_fnc_resourcesFIA", 2];
    [Occupants, 20 * _bonus, 120] remoteExec ["A3A_fnc_addAggression", 2];
    [1800 * _bonus, Occupants] remoteExec ["A3A_fnc_timingCA", 2];
    
    {
        [20 * _bonus, _x] call A3A_fnc_addScorePlayer;
        [1000 * _bonus, _x] call A3A_fnc_addMoneyPlayer;
    } forEach (call SCRT_fnc_misc_getRebelPlayers);
    
    [5 * _bonus, theBoss] call A3A_fnc_addScorePlayer;
    [225 * _bonus, theBoss, true] call A3A_fnc_addMoneyPlayer;
    waitUntil {sleep 0.5; speed _truckX < 1};
    [_truckX] call A3A_fnc_empty;
} else {
    [_taskId, "LOG", "FAILED"] call A3A_fnc_taskSetState;
    [1800 * _bonus, Occupants] remoteExec ["A3A_fnc_timingCA", 2];
    [-25 * _bonus, theBoss] call A3A_fnc_addScorePlayer;
};
Success (returned to HQ):
SUCCEEDED state
+5000 * bonus FIA resources
+20 * bonus aggression (reduces enemy support)
+1800 * bonus enemy cooldown
20 * bonus score and 1000 * bonus money to all players
5 * bonus score and 225 * bonus money to boss
Waits for truck to stop, then empties it (all money collected)
Failure (timeout or destroyed):
FAILED state
+1800 * bonus enemy cooldown
-25 * bonus score to boss
16. Final Cleanup
Sqf

Apply
deleteVehicle _truckX;

[_taskId, "LOG", 1200] spawn A3A_fnc_taskDelete;

{ [_x] spawn A3A_fnc_groupDespawner } forEach _groups;

deleteMarker _mrkFinal;
Deletes truck
Schedules task deletion after 1200 seconds
Despawns guard groups
Deletes task marker
Where it leads:

Calls BIS_fnc_nearestPosition - Finds nearest city to bank
Calls A3A_fnc_localizar - Localizes city name
Calls SCRT_fnc_misc_getTimeLimit - Calculates mission timer
Calls A3A_fnc_AIVEHinit - Initializes truck
Calls A3A_fnc_inmuneConvoy - Makes truck convoy-immune
Calls A3A_fnc_taskCreate - Creates mission task
Calls A3A_fnc_taskUpdate - Updates task state
Calls SCRT_fnc_unit_flattenTier - Gets tiered infantry groups
Calls A3A_fnc_spawnGroup - Spawns guard groups
Calls A3A_fnc_patrolLoop - Assigns patrol behavior
Calls A3A_fnc_NATOinit - Initializes AI units
Calls A3A_fnc_customHint - Shows hint to driver
Calls A3A_fnc_calculateSupportCallReveal - Calculates support reveal
Calls A3A_fnc_requestSupport - Requests enemy support
Calls A3A_fnc_citySupportChange - Modifies city support
Calls BIS_fnc_showNotification - Sends alert to enemies
Calls A3A_fnc_distanceUnits - Finds nearby players
Calls setCaptive - Removes player disguises
Calls A3A_fnc_commsMP - Sends countdown/hint messages
Calls A3A_fnc_taskSetState - Sets final task state
Calls A3A_fnc_resourcesFIA - Awards FIA resources
Calls A3A_fnc_addAggression - Modifies aggression
Calls A3A_fnc_timingCA - Modifies enemy cooldown
Calls A3A_fnc_addScorePlayer - Awards/penalizes score
Calls A3A_fnc_addMoneyPlayer - Awards money
Calls SCRT_fnc_misc_getRebelPlayers - Gets all rebel players
Calls A3A_fnc_empty - Empties truck contents
Calls A3A_fnc_taskDelete - Schedules task cleanup
Calls A3A_fnc_groupDespawner - Despawns groups
Global variables modified:

_truckX - The money truck (created locally)
_groups - Guard groups (tracking for cleanup)
_soldiers - Individual guard units (tracking)
citiesX - Not modified
A3A_faction_civ - Not modified, only read
A3A_faction_reb - Not modified, only read
A3A_hasIFA - Not modified, only read
Synchronization/Network implications:

High network load: Multiple remoteExec calls for:
Custom hints to specific players
Countdown messages
Alert notifications to enemies
Resource changes
Aggression changes
Support call: Enemy support is requested server-side and affects all players
City support changes: Affects AI behavior globally
Disguise removal: Applied individually to each undercover player
All player rewards: Broadcast to all relevant clients
Edge Cases Handled:

Civilian vehicles disabled: Uses militia trucks instead
IFA mod detection: Double timer if IFA is present
Truck destruction: Still counts as mission success (money secured, just need to transport)
Timer expiration: Fails mission if timer runs out
Truck leaving bank area: Sends reminder hints, continues timer
Truck returning to base: Timer must be active for success
Complete System Integration
Cross-function Dependencies:

A3A_fnc_LOG_Airdrop → A3A_fnc_LOG_Ammo → A3A_fnc_LOG_Bank:

All three are called by A3A_fnc_missionRequest based on mission type selection
All share similar structure: timer, faction selection, task creation, cleanup
All modify enemy cooldown timers (A3A_fnc_timingCA)
All award money/score to players (A3A_fnc_addMoneyPlayer, A3A_fnc_addScorePlayer)
Common Functions Called:

SCRT_fnc_misc_getTimeLimit: All three missions use this for timer calculation
A3A_fnc_taskCreate/taskSetState/taskDelete: All missions use BIS task system
A3A_fnc_spawnGroup/spawnVehicle: Common spawning functions
A3A_fnc_NATOinit: Common AI initialization
A3A_fnc_AIVEHinit: Common vehicle initialization
A3A_fnc_groupDespawner/vehDespawner: Common cleanup functions
Faction System:

All use Faction(_sideX) or FactionGet(reb, ...) to get faction data
Read from global faction templates (faction definitions stored in global arrays)
Validate vehicle/group existence before spawning
Player Tracking:

All use SCRT_fnc_misc_getRebelPlayers to get active rebel players
Apply rewards/penalties to all players via remoteExec
Network Architecture:

Server-authoritative: All spawning, mission logic, and rewards are server-side
Client-visible: Tasks, hints, messages, and notifications are broadcast to clients
Selective targeting: Communications target specific player groups (teamPlayer, civilian)
Performance considerations: Uses sleep loops with varying intervals (1-3 seconds) to balance responsiveness vs performance
Technical Details:

Array Operations: All missions use arrays extensively for tracking entities (_vehicles, _groups, _boxes)
Random Selection: Heavy use of selectRandom for vehicle/group selection from faction arrays
Coordinate Calculations: Use of BIS_fnc_findSafePos, BIS_fnc_relPos, BIS_fnc_dirTo, BIS_fnc_nearestPosition
Distance Calculations: Both direct distance and squared distance used (squared for performance in tight loops)
State Management: Boolean flags (_difficultX, _airDropHappened, _boxesOnRebelHq) control flow
Timer Logic: Date comparison using dateToNumber date for mission expiration
Event Handlers: Dynamic event handlers for truck interactions (GetIn event in bank mission)
Error Handling:

Faction validation: Checks for nil escort class in airdrop mission
Safe position fallback: Uses road position if no empty position found
Timer expiration: All missions check timeout as a failure condition
Null/undefined checks: Uses isNil and isNull for safety
Performance Considerations:

Polling loops: Use sleep 1 or sleep 3 to reduce CPU load
Lazy evaluation: Uses || with || for conditions (short-circuit evaluation)
Remote execution: Uses remoteExec with specific targets to reduce network traffic
Cleanup: Uses despawners for gradual cleanup rather than immediate deletion
Larger System Fit:

These logistics missions form part of the "supply chain" gameplay loop
They provide resources (money, FIA resources, equipment) that enable base building and faction progression
They create engagement opportunities with AI forces at various difficulty levels
They integrate with the mission request system (A3A_fnc_missionRequest) for dynamic mission selection
They use the existing faction template system for consistent AI composition
They feed into the strategic layer through enemy cooldowns (timingCA) and city support changes

Function Name: A3A_fnc_LOG_Crashsite_Satellite
File: A3A/addons/core/functions/Missions/fn_LOG_Crashsite_Satellite.sqf

What it does: This function initializes and manages a dynamic "Crashsite Satellite" logistics mission. The objective involves securing a "blackbox" (or valuable data container) from a crash site and delivering it to either the rebel HQ or an arms trader. The mission features a satellite re-entry sequence with visual effects, enemy patrols that arrive to recover the object, and branching success/failure conditions based on player actions.

How it does that:

1. Initialization and Server Validation
The script begins by ensuring it only runs on the server and skipping execution if the current machine is a client with a HUD interface.

Sqf

Apply
if (!isServer and hasInterface) exitWith {};
params ["_markerX"];
Logic: The exitWith {} prevents wasted processing on non-server machines. The params command extracts the primary parameter, _markerX, which is usually the origin marker of the mission (e.g., a city or location where the crash is reported).
2. Mission Configuration and Difficulty Scaling
The script calculates difficulty based on the global tierWar variable, determining enemy strength and mission time limits.

Sqf

Apply
private _difficult = random 10 < tierWar;
private _bonus = if (_difficult) then {2} else {1};
private _sideX = if (sidesX getVar [_markerX, sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);

private _limit = if (_difficult) then {
	45 call SCRT_fnc_misc_getTimeLimit
} else {
	90 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
Logic:
_difficult: If tierWar (war tier) is high, the mission has a higher chance of being "Hardmode".
_sideX & _faction: Determines if the occupiers or invaders control the origin marker and retrieves their specific faction data (unit types, vehicles).
Time Limits: Hardmode gives 45 minutes (real time), standard gives 90 minutes.
3. Destination Selection
The script identifies a random enemy military site (outpost, milbase, airport) to serve as the delivery destination.

Sqf

Apply
private _potentialSites = outposts + milbases + airportsX;
_potentialSites = _potentialSites select {sidesX getVar [_x, sideUnknown] != teamPlayer};
private _deliverySite = getMarkerPos _markerX;
if(count _potentialSites > 0) then {
    _randomEnemySite = selectRandom _potentialSites;
    _deliverySite = getMarkerPos _randomEnemySite;
};
Logic: It filters global arrays (outposts, milbases, etc.) to exclude territories owned by the player (teamPlayer). If no valid enemy sites exist, it defaults to the origin marker position.
4. Crash Site Position Calculation
The script finds a valid position for the crash site, ensuring it is land, not out of bounds, and within a specific range (2km-3km) of the rebel HQ but far enough to prevent immediate player arrival.

Sqf

Apply
private _angle = random 360;
private _distance = if (_difficult) then {2000} else {3000};

while {true} do {
	_posCrashOrigin = _missionOriginPos getPos [_distance, _angle];
    private _outOfBounds = _posCrashOrigin findIf { (_x < 0) || {_x > worldSize}} != -1;
    private _exitConditions = !surfaceIsWater _posCrashOrigin && 
                              {_posCrashOrigin distance _respawnTeamPlayerMarkerPos < 4000} && 
                              {_posCrashOrigin distance _respawnTeamPlayerMarkerPos > 2000} && 
                              {!_outOfBounds};
	if (_exitConditions) exitWith {};
    // ... incremental angle and distance reduction loop ...
};
Logic:
It uses a while loop to find a valid polar coordinate from the mission origin.
Constraints: Dry land, within world boundaries, 2000m-4000m from the rebel base.
If no spot is found after 360 iterations, it reduces the distance by 500m and tries again.
5. Classname Selection
Based on the determined faction and difficulty, specific vehicles and units are selected from the faction configuration.

Sqf

Apply
private _reconVehicle = selectRandom (_faction get "vehiclesDropPod");
private _pilotClass = _faction get "unitPilot";
private _searchHeliClass = if (_difficult) then { ... } else { ... };
private _cargoTruckClass = selectRandom (_faction get "vehiclesTrucks");
private _blackboxClass = if (_reconVehicle == "SpaceshipCapsule_01_wreck_F") then {
    "SpaceshipCapsule_01_container_F";
} else {
    "Land_PortableServer_01_black_F";
};
private _specOpsArray = if (_difficult) then { ... } else { ... };
Logic:
_reconVehicle: Randomly picks a drop pod or spacecraft capsule.
_blackboxClass: Dynamically assigns the container object based on the vehicle type (Space capsule vs standard vehicle).
_specOpsArray: Picks high-tier infantry for hardmode, medium-tier for normal.
6. Exact Crash Position Refinement
The script finds a precise flat position near the calculated origin to prevent the vehicle from spawning inside terrain geometry or water.

Sqf

Apply
private _flatPosition = [_posCrashOrigin, 0, 1000, 0, 0, 0.4] call BIS_fnc_findSafePos;
private _crashPosition = _flatPosition findEmptyPosition [0, 100, _reconVehicle];

private _iterations = 0;
while {_iterations < 30} do {
    // ... refinement logic ...
    if(_crashPosition distance _respawnTeamPlayerMarkerPos < 2000 && _crashPosition distance _respawnTeamPlayerMarkerPos > 4000) exitWith {};
    _iterations = _iterations + 1; 
};
Logic: Uses BIS_fnc_findSafePos (0 = center, 1000 = radius, 0.4 = terrain gradient) to find flat land. It iterates to ensure the final spot isn't too close to or far from the rebel base.
7. Creating the Task
A task is created for the player side with a localized description and a countdown timer.

Sqf

Apply
private _taskId = "LOG" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [format [localize "STR_A3A_Missions_LOG_crashsite_task_desc", _faction get "name", _destinationName, _displayTime], ...],
    _crashPositionMarker,
    false, 0, true, "land", true
] call BIS_fnc_taskCreate;
[_taskId, "LOG", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Logic:
BIS_fnc_taskCreate defines the task properties.
remoteExecCall broadcasts the task state update to all relevant clients (players).
The task is attached to a marker created at the crash site position.
8. Mission Start Trigger (Wait for Players)
The script pauses the dynamic phase (satellite fall) until players get within 1500m of the crash site or 600 seconds pass.

Sqf

Apply
private _missionStart = serverTime;
waitUntil {
    sleep 20;
    (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_crashPosition, 1500, 1500] isNotEqualTo [] || {_missionStart >= serverTime + 600 }
};
sleep 60; // Prep time
Logic:
SCRT_fnc_misc_getRebelPlayers: Fetches all rebel players.
If players are close, the satellite "falls". If they delay too long, the event triggers automatically.
9. Satellite Re-Entry Simulation (VFX)
The script spawns a dummy vehicle high in the sky, calculates a trajectory vector towards the crash site, and simulates a crash.

Sqf

Apply
private _reconVehicleDummy = createVehicle [_reconVehicleDummyClass, [0, 0, 250], [], 0, "NONE"];
private _initPos = _crashPosition getPos [4500, random -180];
_reconVehicleDummy setPos (_initPos vectorAdd [0,0,2500]);

// Vector Math for trajectory
private _targetVector = (getPos _reconVehicleDummy) vectorFromTo _crashPosition;
_reconVehicleDummy setVectorDir _targetVector;
private _vel = velocity _reconVehicleDummy;
private _additionalSpeed = 200;
_reconVehicleDummy setVelocity (_targetVector vectorMultiply _additionalSpeed);

// Effects
[_reconVehicleDummy] call SCRT_fnc_effect_crashingEffects;
private _bomb = "ammo_Missile_Cruise_01" createVehicle [...];
Logic:
Vector Math: vectorFromTo creates a direction vector from the dummy's start position to the target. setVectorDir orients it.
Velocity: Applies a speed vector along that direction (200 m/s) to simulate gravity/propulsion.
Collision: A hidden _reconVehicle is placed at the impact point. A ammo_Missile_Cruise_01 is created there immediately to simulate the impact explosion and damage.
10. Crash Site Debris and Destruction
After the "explosion," the script modifies the terrain (damaging trees/rocks) and spawns wreck/debris objects.

Sqf

Apply
// Hiding terrain objects to prevent clipping
{ [_x, true] remoteExec ["hideObject", 0, true]; _x enableSimulationGlobal false; } forEach nearestTerrainObjects [...];

// Damaging surroundings in rings
{
    private _terrainObjects = nearestTerrainObjects [_reconVehicle, _objects, _x, false, false];
    private _damage = _damageValues select _forEachIndex;
    { _x setDamage [_damage, true]; } forEach _terrainObjects;
} forEach [100, 150, 200];

// Spawning wreck and debris
private _debri = "SpaceshipCapsule_01_debris_F" createVehicle [...];
[_firePosition, 5000] remoteExec ["SCRT_fnc_effect_createBurningDebrisEffect", 0, _reconVehicle];
Logic:
nearestTerrainObjects finds trees/rocks.
hideObject and enableSimulationGlobal false are used to "clean" the area visually to prevent the wreck from floating or clipping.
SCRT_fnc_effect_createBurningDebrisEffect spawns fire/smoke VFX.
11. Spawning the Blackbox and Grunt AI
The actual objective (the box) is created near the wreckage. Smoke and chemlights are attached for visibility. Enemy infantry are spawned and placed inside the cargo truck.

Sqf

Apply
private _box = _blackboxClass createVehicle _boxPosition;
[_box] call A3A_Logistics_fnc_addLoadAction; // Adds interaction to carry/load

// Notification markers
private _smoke = _smokeGrenade createVehicle (getPosATL _box);
_smoke attachTo [_box, [0,0,1]];

// Infantry Spawn
private _cargoGroupX = [_missionOriginPos, _sideX, _specOpsArray] call A3A_fnc_spawnGroup;
{
    _x assignAsCargo _cargoVehicle; 
    _x moveInCargo _cargoVehicle; 
    [_x] join _cargoVehicleGroup;
} forEach units _cargoGroupX;
deleteGroup _cargoGroupX;
Logic:
A3A_Logistics_fnc_addLoadAction: Integrates with the logistics system to allow players to load the box onto vehicles.
Group Management: A temporary group (_cargoGroupX) is spawned and immediately disbanded after moving units into the main _cargoVehicleGroup to prevent group clutter.
12. Convoy and Helicopter Logic
The script spawns a cargo truck and a helicopter. The behavior changes based on the helicopter type (light vs attack).

Sqf

Apply
private _cargoVehicleData = [position _roadR, 0, _cargoTruckClass, _sideX] call A3A_fnc_spawnVehicle;
private _searchHeliData = [[...], 0, _searchHeliClass, _sideX] call A3A_fnc_spawnVehicle;

// Logic for Light Helos (Land or Fastrope)
if(_searchHeliClass in (_faction get "vehiclesHelisLight")) then {
    private _roll = random 100;
	if(_roll >= 50) then {
        [_searchHeliVeh, _heliInfGroup, _crashsiteactual, _cargoGroupSpawnpositon, _heliVehicleGroup] spawn A3A_fnc_fastrope;
    } else {
        [_searchHeliVeh, _heliVehicleGroup,_heliInfGroup, ...] spawn A3A_fnc_combatLanding;    
    };
} else {
    // Attack Helo loiters overhead
    _heliVehicleGroupWP2 = _heliVehicleGroup addWaypoint [position _box, 1];
    _heliVehicleGroupWP2 setWaypointType "LOITER";
};
Logic:
A3A_fnc_spawnVehicle: Standard wrapper for creating vehicles with crew and init scripts.
A3A_fnc_fatrope / A3A_fnc_combatLanding: Calls specific AI scripts to have the helicopter descend and disembark troops.
Attack helos are simply given a loiter waypoint to provide air cover.
13. Wait Condition (Player vs Enemy)
The script enters a critical waitUntil loop monitoring the status of the _box. It checks if players, enemies, or the time limit have been met.

Sqf

Apply
waitUntil 
{
    sleep 1;
    !(alive _box)
    || {_cargoVehicle distance _box < 50}
    || {_cargoVehicle2 distance _box < 50}
    || {_box distance (getMarkerPos respawnTeamPlayer) < 50}
    || {_box distance (getMarkerPos traderMarker) < 50}
    || {dateToNumber date > _dateLimitNum}
};
Logic: This is the core gameplay loop. It monitors distance checks against the box, respawn points, and trader markers.
14. Enemy Interaction (AI Load Logic)
If the enemy reaches the box first, AI scripts handle the loading and attempt to destroy the crash site.

Sqf

Apply
if (_cargoVehicle distance _box < 50 || _cargoVehicle2 distance _box < 50) then {
    // ... combat awareness logic ...

    // Load box
    private _return = [_cargoVehicle, _box] call A3A_Logistics_fnc_canLoad;
    if !(_return isEqualType 0) exitWith {
        _return remoteExec ["A3A_Logistics_fnc_load", 2];
    };

    // Plant explosive
    [_crashPosition, _reconVehicle, _cargoVehicle] spawn {
        waitUntil {sleep 1; _cargoVehicle distance _crashPosition > 150};
        _shell = "Sh_155mm_AMOS" createVehicle position _reconVehicle;
        _reconVehicle setDamage 1;
    };
};
Logic:
The AI uses the logistics system (A3A_fnc_canLoad / A3A_fnc_load) to pick up the box.
A spawned script waits for the truck to leave the crash site radius (150m) before creating an artillery shell impact on the wreckage to destroy it.
15. Outcome Resolution
The final switch statement determines the mission result based on where the box ended up or if it was destroyed.

Sqf

Apply
switch(true) do 
{
    case(_box distance _deliverySite < 50 || {dateToNumber date > _dateLimitNum}):
    {
        // Failure: Enemy recovered or time ran out
        [_taskId, "LOG", "FAILED"] call A3A_fnc_taskSetState;
        [-900, _sideX] remoteExec ["A3A_fnc_timingCA",2];
    };
    case(!alive _box):
    {
        // Canceled: Box destroyed
        [_taskId, "LOG", "CANCELED"] call A3A_fnc_taskSetState;
    };
    case(_box distance (getMarkerPos respawnTeamPlayer) < 50):
    {
        // Success: Delivered to HQ
        [_taskId, "LOG", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 600] remoteExec ["A3A_fnc_resourcesFIA",2]; // Add money/resources
        ["Large", _sideX] remoteExec ["A3A_fnc_selectIntel", 2]; // Gain intel
    };
    case(_box distance (getMarkerPos traderMarker) < 50):
    {
        // Success: Sold to Trader (Bonus)
        [_taskId, "LOG", "CANCELED"] call A3A_fnc_taskSetState; // Standard mission ends, trader mission succeeds
        [_taskId2, "LOG", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 1200] remoteExec ["A3A_fnc_resourcesFIA",2];
    };
};
Logic:
Failure: Penalizes resources and triggers enemy attacks (timingCA).
Success (HQ): Grants standard XP, money, and "Large" intel (reveal nearby sectors).
Success (Trader): Grants double the money (1200 vs 600) but no intel, as it's a black market deal.
16. Cleanup
Finally, the script removes temporary objects and deletes the mission tasks after a delay.

Sqf

Apply
sleep 20;
{ deleteVehicle _x; } forEach _effectsAndProps;
[_taskId, "LOG", 1200] spawn A3A_fnc_taskDelete;
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Logic:
Effects (fire, smoke) are deleted to improve performance.
A3A_fnc_vehDespawner handles safe removal of vehicles (preventing explosion if players are too close).
A3A_fnc_taskDelete removes the task from players' UI after 20 minutes (1200 seconds).
Where it leads (Dependencies & System Integration)
Called Functions:

SCRT_fnc_misc_getRebelPlayers: Retrieves an array of active rebel players to check proximity.
A3A_fnc_spawnVehicle: Spawns the convoy truck and helicopter with proper crew initialization.
A3A_fnc_fastrope / A3A_fnc_combatLanding: Handles helicopter troop deployment.
A3A_Logistics_fnc_addLoadAction: Adds the "Load" action to the blackbox object.
A3A_Logistics_fnc_canLoad / A3A_Logistics_fnc_load: Verifies and executes the loading of the box onto the enemy truck.
A3A_fnc_taskCreate / A3A_fnc_taskUpdate / A3A_fnc_taskSetState: Manages the mission UI and state.
A3A_fnc_selectIntel: Grants intelligence rewards upon successful delivery to HQ.
A3A_fnc_timingCA: Triggers enemy counter-attacks or delays future attacks based on success/failure.
SCRT_fnc_effect_crashingEffects: Visuals for the satellite entry.
Modified Global Variables:

A3A_taskCount: Incremented to generate unique task IDs.
Server Resources: Modifies resourcesFIA (money) and HR (recruits) on success/failure via remote execution.
A3A_curHQInfoInv: May increase enemy HQ knowledge on failure (revealing the HQ location).
Network Implications:

Heavy Server-Side: All AI logic, position calculations, and state management run on the server.
Remote Execution: Uses remoteExec to trigger VFX on all clients (SCRT_fnc_effect_createBurningDebrisEffect), update tasks, and apply resource changes.
Optimization: The script includes hideObjectGlobal and enableSimulationGlobal false for non-critical terrain objects to reduce network traffic and client rendering load.

Function Name: 
fn_LOG_Crashsite.sqf
What it does: This function manages the "Crashsite" logistics mission. Its primary objective is to retrieve a valuable data storage device (blackbox) from a crashed enemy aircraft and deliver it to either the rebel HQ or an arms trader. The mission involves the server generating a crash site, spawning enemy forces to recover the blackbox, and handling player interaction and mission outcome.

The mission is called when the game requests a logistics mission and this specific type is selected. It runs entirely on the server, as indicated by the initial check if (!isServer and hasInterface) exitWith {};. It sets up a dynamic scenario where players must race against an enemy AI-controlled convoy to secure the objective.

How it does that: The function executes in several distinct phases: mission initialization, environmental setup, AI unit spawning, mission monitoring, and cleanup.

1. Mission Initialization & Parameter Setup The function starts by verifying it runs only on the server and receiving the mission origin marker _markerX.

Sqf

Apply
if (!isServer and hasInterface) exitWith {};
//Mission: Retrive valuable data
params ["_markerX"];

Info ("Crashsite");
Validation: The if (!isServer... check ensures heavy mission logic doesn't run on clients, preventing performance issues and desync.
Input: _markerX is the marker string passed from the mission request system.
2. Difficulty & Side Determination It calculates mission difficulty based on global tier war level and determines which side (Occupants or Invaders) controls the target area.

Sqf

Apply
private _difficult = random 10 < tierWar;
private _bonus = if (_difficult) then {2} else {1};
private _sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
Logic: tierWar is a global variable representing the game's progress. Higher tiers increase difficulty.
Context: This determines enemy spawn composition and reward multipliers.
3. Time Limit Calculation The mission enforces a time limit based on difficulty.

Sqf

Apply
private _limit = if (_difficult) then {
	45 call SCRT_fnc_misc_getTimeLimit
} else {
	90 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
Function Call: SCRT_fnc_misc_getTimeLimit returns an array containing the calculation deadline and a readable string format.
Storage: _dateLimitNum (server time number) is used for logic checks; _displayTime is for UI.
4. Enemy Delivery Site Selection The code identifies a valid enemy outpost or base to serve as the destination for the enemy convoy.

Sqf

Apply
private _potentialSites = outposts + milbases + airportsX;
_potentialSites = _potentialSites select {sidesX getVariable [_x,sideUnknown] != teamPlayer};
private _deliverySite = getMarkerPos _markerX;

if (count _potentialSites > 0) then {
    _randomEnemySite = selectRandom _potentialSites;
    _deliverySite = getMarkerPos _randomEnemySite;
};
Variables: outposts, milbases, airportsX are global arrays of marker names.
Filtering: It excludes sites owned by the player (teamPlayer). If no valid sites are found, it defaults to the mission origin marker (likely a fallback, though technically the origin is a friendly logi site in A3A context, this implies a "stolen intel" scenario where the crash is near the front).
5. Finding the Crash Position It generates a random position for the crash site, ensuring it is on land, within a specific range of the player's base (to ensure accessibility), and not out of bounds.

Sqf

Apply
private _angle = random 360;
// ... loop variables ...
while {true} do {
	_posCrashOrigin = _missionOriginPos getPos [_distance,_angle];
    // ... distance checks ...
    // ... boundary checks ...
	if (!surfaceIsWater _posCrashOrigin 
        && _posCrashOrigin distance _respawnTeamPlayerMarkerPos < 4000 
        && _posCrashOrigin distance _respawnTeamPlayerMarkerPos > 2000
        && !_outOfBounds
    ) exitWith {};
    // ... iteration logic ...
};
Constraints: The loop tries to find a spot 2km-4km from the player base (respawnTeamPlayer). If it fails after 360 attempts, it reduces the search distance.
6. Asset Selection It selects the specific vehicle classes and infantry groups based on the determined faction and difficulty.

Sqf

Apply
private _reconVehicleClass = selectRandom ((_faction get "vehiclesPlanesTransport") + (_faction get "uavsAttack") + _reconVehicleDroppod);
private _specOpsArray = if (_difficult) then {selectRandom (_faction get "groupSpecOpsRandom")} else {selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)};
Type Check: If the selected vehicle is a "Droppod", it immediately exits to call A3A_fnc_LOG_Crashsite_Satellite, a variant of this mission.
Template System: It uses the Faction map (_faction get "vehiclesPlanesTransport") to support different modsets (CUP, RHS, etc.).
7. Crash Site Preparation & VFX It spawns a dummy aircraft, animates a crashing trajectory, creates explosion effects, and leaves a damaged wreck and a crater.

Sqf

Apply
private _reconVehicleDummy = createVehicle [_reconVehicleClass, [0, 0, 250], [], 0, "NONE"];
// ... attachment and positioning logic ...
_quad setVelocity (_targetVector vectorMultiply _additionalSpeed);
// ... VFX ...
_bomb1 = "ammo_Missile_Cruise_01" createVehicle [getPos _quad select 0, getPos _quad select 1 ,0];
[_quad] call SCRT_fnc_effect_crashingEffects;
Physics Simulation: It uses attachTo, setVectorDir, and setVelocity on a quadbike object to simulate the ballistic trajectory of the crashing plane.
Cleanup: The dummy vehicle is deleted, replaced by the actual wreck _reconVehicle.
8. Blackbox & Interaction Setup The blackbox object is created near the wreck, actions are added for logistics loading, and visual markers (smoke/chemlight) are attached.

Sqf

Apply
private _box = _blackboxClass createVehicle _boxPosition;
[_box] call A3A_Logistics_fnc_addLoadAction;
// ... visual markers ...
private _smoke = _smokeGrenade createVehicle (getPosATL _box);
Logistics Integration: A3A_Logistics_fnc_addLoadAction attaches the "Load" action to the box, allowing players to carry it or load it into vehicles.
UI Cues: Smoke and chemlights ensure players can find the objective in complex terrain.
9. Enemy Convoy Spawning An enemy cargo truck is spawned on a nearby road, loaded with spec-ops infantry. A support helicopter is also spawned if applicable.

Sqf

Apply
private _cargoVehicleData = [position _roadR, 0, _cargoTruckClass, _sideX] call A3A_fnc_spawnVehicle;
// ... infantry loadout ...
if (_searchHeliClass isNotEqualTo []) then {
    _searchHeliData = [...] call A3A_fnc_spawnVehicle;
    // ... fastrope or landing logic ...
};
Navmesh/Roads: It uses nearRoads to ensure the truck spawns on a drivable surface.
Helicopter Logic: Depending on the heli type (light/attack), it calls A3A_fnc_fastrope or A3A_fnc_combatLanding to deploy infantry.
10. Mission Monitoring (Wait Loop) The server enters a waitUntil loop, checking various conditions constantly.

Sqf

Apply
waitUntil 
{
    sleep 1;
    !(alive _box)
    ||
    {_cargoVehicle distance _box < 50} 
    ||
    {_box distance (getMarkerPos respawnTeamPlayer) < 50}
    // ... other conditions ...
    ||
    {dateToNumber date > _dateLimitNum}
};
Polling: It sleeps 1 second per loop iteration to prevent high CPU usage.
Win/Loss Conditions: It tracks box destruction, proximity to enemy convoy, proximity to HQ, or time expiry.
11. AI Recovery Logic If the convoy reaches the box, specific AI routines execute. The AI attempts to load the box into the truck, plants explosives on the wreck (to destroy evidence), and departs toward the delivery site.

Sqf

Apply
if (_cargoVehicle distance _box < 50) then {
    // ... check if enemies are aware of players ...
    private _return = [_cargoVehicle, _box] call A3A_Logistics_fnc_canLoad;
    if !(_return isEqualType 0) exitWith {
        _return remoteExec ["A3A_Logistics_fnc_load", 2];
    };
    // ... planting satchel ...
    [_crashPosition, _reconVehicle, _cargoVehicle] spawn { ... };
};
Asynchronous Action: remoteExec ["A3A_Logistics_fnc_load", 2] executes the loading action on the server (owner 2).
Destruction: A shell is spawned over the wreck to trigger damage.
12. Outcome Resolution The switch statement determines the mission result based on where the box is or if the timer ran out.

Sqf

Apply
switch(true) do 
{
    case(_box distance _deliverySite < 50):
    {
        // Enemy recovered it - Mission Failed
        [_taskId, "LOG", "FAILED"] call A3A_fnc_taskSetState;
        [-900, _sideX] remoteExec ["A3A_fnc_timingCA",2];
    };
    case(_box distance (getMarkerPos respawnTeamPlayer) < 50):
    {
        // Player delivered to HQ - Mission Succeeded
        [_taskId, "LOG", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 600] remoteExec ["A3A_fnc_resourcesFIA",2];
    };
};
Remote Execution: Most outcome effects (resource changes, task updates) are pushed to clients via remoteExec.
Scoring: Rewards are calculated using the _bonus multiplier derived from difficulty.
13. Cleanup After a delay, all mission objects (vehicles, groups, effects) are deleted to prevent mission clutter.

Sqf

Apply
sleep 20;
{
    deleteVehicle _x;
} forEach _effectsAndProps;
// ... despawn vehicles and groups ...
deleteVehicle _box;
Despawner: It calls A3A_fnc_vehDespawner and A3A_fnc_groupDespawner which handle gradual deletion or teleportation to base for players.
Where it leads: This function orchestrates a complex multi-step interaction between player logistics, AI pathfinding, and event triggers.

Calls A3A_fnc_LOG_Crashsite_Satellite: If the randomly selected vehicle is a "drop pod" type, the mission switches to a satellite crash variant.
Calls A3A_fnc_localizar: Translates the marker name into a localized string (e.g., "south of Agora").
Calls BIS_fnc_taskCreate: Creates the UI task for players.
Calls A3A_fnc_spawnVehicle: Spawns the enemy truck and helicopter.
Calls A3A_fnc_spawnGroup: Spawns the infantry units.
Calls A3A_Logistics_fnc_addLoadAction: Adds the "Load" interaction to the blackbox.
Calls SCRT_fnc_effect_crashingEffects: Handles visual/audio effects for the crash.
Calls A3A_fnc_fastrope / A3A_fnc_combatLanding: Handles helicopter infantry deployment.
Calls A3A_fnc_taskSetState: Updates mission status (Success/Failure).
Calls A3A_fnc_resourcesFIA: Modifies rebel money/resources.
Calls A3A_fnc_timingCA: Adjusts the next enemy attack timer based on success/failure.
Calls A3A_fnc_vehDespawner / A3A_fnc_groupDespawner: Cleans up AI entities.
Global Variables Accessed/Modified:

Read: tierWar, sidesX, outposts, milbases, airportsX, respawnTeamPlayer, A3A_taskCount, A3A_factionEquipFlags, A3A_curHQInfoInv.
Modified: A3A_taskCount (incremented), A3A_curHQInfoInv (increases enemy intel on HQ if mission failed).
Synchronization/Network Implications:

Server Authority: All logic runs on the server. State changes are broadcast to clients using remoteExec (e.g., for task updates, resource changes, or loading logistics).
JIP Compatibility: BIS_fnc_taskCreate is broadcast to all players, ensuring Join-In-Progress players see the active task.
Performance: Heavy object creation (smoke, fire, debris) uses remoteExec to simulate effects on all clients simultaneously without overwhelming the server's render loop.
Edge Cases & Error Handling:

Invalid Assets: If _reconVehicleClass or _cargoTruckClass is nil (due to template errors), the function exits and re-requests a generic logistics mission (["LOG"] remoteExec ["A3A_fnc_missionRequest",2]).
Position Finding: If the crash position cannot be found within the loop limit, it defaults to the origin _posCrashOrigin.
Blackbox Underwater: Checks if the box is below sea level (getPosASL _box select 2 < 0) and assigns a special "Salvage" action to allow recovery from water.
Cargo Seats: Checks if there are enough seats in the vehicle for all infantry. If not, it spawns a second cargo truck (_cargoVehicle2) to ensure the AI can retreat.
Trader Availability: Checks if traderMarker exists. If so, adds it as a secondary delivery point with different rewards. If not, HQ is the only option.

Function Name: A3A_fnc_LOG_Helicrash.sqf
What it does:
This function manages a logistics mission where rebels must retrieve an ammobox from a helicopter crash site. The mission involves:

Spawning a crashed enemy helicopter with a pilot body and burning debris.
Spawning an enemy transport truck with a squad to recover the ammobox.
Adding enemy loiter helicopters and ground patrols.
Tracking player interaction with the ammobox and handling mission completion/failure based on objectives.
Cleaning up mission entities after completion or timeout.
It is called exclusively by the server (due to if (!isServer && hasInterface) exitWith {};) and is triggered by the logistics mission system (A3A_fnc_missionRequest). It uses faction templates for vehicle and unit selection, making it adaptable to different enemy factions.

How it does that:

Initialization and Parameter Validation:

Accepts _markerX (mission origin marker).
Validates faction data availability; rerequests mission if critical classes are nil.
Sqf

Apply
if (isNil "_pilotClass" || {isNil "_helicopterClass"} || ... ) exitWith {
    ["LOG"] remoteExec ["A3A_fnc_missionRequest",2];
    Error("Problems with faction template, rerequesting new logistics mission.");
};
Mission Setup:

Determines difficulty tier (_difficult), bonus multipliers (_bonus), and controlling side (_sideX).
Calculates time limit (_limit) based on difficulty.
Sqf

Apply
private _difficult = random 10 < tierWar;
private _bonus = if (_difficult) then {2} else {1};
private _sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _limit = if (_difficult) then {45 call SCRT_fnc_misc_getTimeLimit} else {90 call SCRT_fnc_misc_getTimeLimit};
Crash Site Generation:

Finds a valid crash position near the origin but avoiding water and spawn areas.
Clears terrain objects (trees, rocks) and spawns crash crater and helicopter.
Sqf

Apply
private _flatPosition = [_posCrashOrigin, 0, 1000, 0, 0, 0.4] call BIS_fnc_findSafePos;
private _crashPosition = _flatPosition findEmptyPosition [0, 100, _helicopterClass];
private _crater = "CraterLong_02_F" createVehicle _crashPosition;
private _helicopter = createVehicle [_helicopterClass, [_crashPosition select 0, _crashPosition select 1, 0.9], [], 0, "CAN_COLLIDE"];
Enemy Entity Spawning:

Spawns a loiter helicopter (attack/transport depending on difficulty).
Spawns a cargo truck with infantry squad.
Spawns a spec ops patrol near the crash site.
Sqf

Apply
private _searchHeliData = [[(_crashPosition select 0) + random 100, (_crashPosition select 1) + random 100, 300 + random 500], 0, _searchHeliClass, _sideX] call A3A_fnc_spawnVehicle;
private _cargoVehicleData = [position _roadR, 0, _cargoTruckClass, _sideX] call A3A_fnc_spawnVehicle;
private _patrolGroup = [_crashPosition, _sideX, _specOpsArray] call A3A_fnc_spawnGroup;
Mission Task Creation:

Creates a task for rebels to deliver the ammobox to HQ.
Sqf

Apply
private _taskId = "LOG" + str A3A_taskCount;
[[teamPlayer,civilian], _taskId, [format [localize "STR_A3A_Missions_LOG_Helicrash_task_desc", ...], ...], _crashPositionMarker, false, 0, true, "heli", true] call BIS_fnc_taskCreate;
AI Behavior Sequence:

Wait for enemy truck to reach the crash site.
If enemies detect players, switch to combat mode.
Simulate enemy recovery actions: pilot body retrieval, loading ammobox, planting explosive.
Sqf

Apply
waitUntil {_cargoVehicle distance _box < 50 || ...};
private _cargoSquad = units _cargoVehicleGroup; 
{ moveOut _x; } forEach _cargoSquad;
_bodyBag = createVehicle ["Land_Bodybag_01_black_F", position _pilot, [], 0, "CAN_COLLIDE"];
_return = [_cargoVehicle, _box] call A3A_Logistics_fnc_canLoad;
Mission Completion Check:

Monitor ammobox proximity to HQ (success) or delivery site (failure).
Handle time limit expiration.
Sqf

Apply
waitUntil {sleep 1; !alive _box || _box distance _deliverySite < 50 || _box distance (getMarkerPos respawnTeamPlayer) < 50 || dateToNumber date > _dateLimitNum};
Cleanup:

Delete mission entities, effects, and groups after delay.
Sqf

Apply
{ deleteVehicle _x; } forEach _effectsAndProps;
{ [_x] spawn A3A_fnc_vehDespawner } forEach _vehicles;
Where it leads:

Called Functions:

A3A_fnc_spawnVehicle: Spawns enemy vehicles (helicopter, truck).
A3A_fnc_spawnGroup: Spawns infantry groups.
A3A_fnc_AIVEHinit: Initializes enemy vehicle AI.
A3A_fnc_NATOinit: Initializes enemy unit AI.
A3A_fnc_taskCreate: Creates mission task.
A3A_fnc_taskSetState: Updates task status (success/failure).
A3A_fnc_addScorePlayer: Awards player score.
A3A_fnc_addMoneyPlayer: Awards player money.
A3A_fnc_timingCA: Adjusts enemy cooldown timers.
A3A_fnc_resourcesFIA: Updates faction resources.
A3A_fnc_vehDespawner: Cleans up vehicles.
A3A_fnc_groupDespawner: Cleans up groups.
SCRT_fnc_misc_getTimeLimit: Calculates mission time limit.
SCRT_fnc_unit_flattenTier: Retrieves unit arrays from faction templates.
A3A_fnc_fillLootCrate: Fills the ammobox with loot.
A3A_Logistics_fnc_addLoadAction: Adds load action to the ammobox.
A3A_Logistics_fnc_canLoad: Checks if ammobox can be loaded.
A3A_Logistics_fnc_load: Loads ammobox into vehicle.
SCRT_fnc_effect_createBurningDebrisEffect: Creates fire effects.
Dependencies:

Faction templates (_faction) for unit/vehicle classes.
Global variables: sidesX, tierWar, respawnTeamPlayer, teamPlayer, Occupants, Invaders.
Logistics system for ammobox handling.
Network Implications:

All AI spawning and waypoint management runs server-side.
Task creation/update is broadcast to all players via remoteExecCall.
Effects (smoke, fire) are broadcast to all clients via remoteExec.
Player score/money updates are processed server-side but broadcast to individual clients.
System Integration:

Part of the logistics mission module. Called by A3A_fnc_missionRequest.
Modifies enemy resources via A3A_fnc_timingCA and A3A_fnc_resourcesFIA.
Uses the mission timer system (SCRT_fnc_misc_getTimeLimit).
Function Name: A3A_fnc_LOG_Salvage.sqf
What it does:
This function manages a salvage mission where rebels must recover an equipment box from a sunken ship. The mission involves:

Spawning a sunken ship and ammobox at underwater locations.
Spawning enemy patrol boats and divers to guard the area.
Forcing players out of undercover mode near the patrol boat.
Tracking ammobox delivery to HQ for mission success.
Cleaning up mission entities after completion or timeout.
It is called exclusively by the server and triggered by the logistics mission system. The mission is designed for aquatic environments.

How it does that:

Initialization:

Accepts _markerX (seaport marker).
Determines difficulty (_difficultX) and side (_sideX).
Calculates time limit based on difficulty.
Sqf

Apply
private _difficultX = if (random 10 < tierWar) then {true} else {false};
private _sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _limit = if (_difficultX) then {30 call SCRT_fnc_misc_getTimeLimit} else {60 call SCRT_fnc_misc_getTimeLimit};
Location Selection:

Uses selectBestPlaces to find three underwater locations near the seaport.
Creates circular markers for these locations.
Sqf

Apply
private _firstPos = round (random 1000) + 150;
private _mrk1Pos = (selectRandom (selectBestPlaces [_positionX, _firstPos,"waterDepth", 20, 20]) select 0) + [0];
private _mrk1 = createMarker ["salvageLocation1", _mrk1Pos];
_mrk1 setMarkerShape "ELLIPSE";
Mission Task Creation:

Creates a task with three possible treasure locations.
Sqf

Apply
private _taskId = "LOG" + str A3A_taskCount;
[[teamPlayer, civilian], _taskId, [_text, _title, [_mrk1, _mrk2, _mrk3]], _positionX, false, 0, true, "rearm", true] call BIS_fnc_taskCreate;
Player Proximity Detection:

Waits for players to enter spawning area (or timeout).
Ensures mission only spawns when players are near.
Sqf

Apply
waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or ((spawner getVariable _markerX != 2) and !(sidesX getVariable [_markerX,sideUnknown] == teamPlayer))};
Spawn Entities:

Spawns sunken ship and ammobox at a random location.
Assigns salvage action to the ammobox.
Sqf

Apply
private _boxPos = selectRandom [_mrk1Pos, _mrk2Pos, _mrk3Pos];
private _ship = _shipType createVehicle _shipPos;
private _box = _boxType createVehicle _boxPos;
[_box] remoteExec ["SCRT_fnc_common_addActionMove", [teamPlayer, civilian], _box];
Enemy Patrol Spawning:

Spawns patrol boat with crew.
If difficulty is high, spawns SDVs (submersible vehicles) with divers.
Sqf

Apply
private _typeVeh = if (_difficultX) then { selectRandom (_faction get "vehiclesGunBoats") } else { selectRandom (_faction get "vehiclesTransportBoats") };
private _veh = createVehicle [_typeVeh, _boatSpawnLocation, [], 0, "NONE"];
private _typeSDV = _faction getOrDefault ["vehiclesSDV", ""];
Undercover Disabling:

Continuously checks for nearby players and removes undercover status.
Updates patrol boat waypoints if idle.
Sqf

Apply
[_veh, [_mrk1Pos, _mrk2Pos, _mrk3Pos]] spawn {
    params ["_veh", "_positions"];
    while {alive _veh} do {
        sleep 2;
        private _nearbyPlayers = allPlayers inAreaArray [getPos _veh, 150, 150];
        { [_x, false] remoteExec ["setCaptive", _x] } forEach _nearbyPlayers;
    };
};
Mission Completion Check:

Monitors if ammobox reaches HQ (success) or time expires (failure).
Sqf

Apply
waitUntil {sleep 1; dateToNumber date > _dateLimitNum or {(_box distance2D posHQ) < 100}};
Cleanup:

Deletes markers, ship, and spawns despawner functions for vehicles/groups.
Sqf

Apply
deleteMarker _mrk1;
deleteMarker _mrk2;
deleteVehicle _ship;
[_vehCrewGroup] spawn A3A_fnc_groupDespawner;
Where it leads:

Called Functions:

A3A_fnc_taskCreate: Creates salvage mission task.
A3A_fnc_taskSetState: Updates task status.
A3A_fnc_addScorePlayer: Awards player score.
A3A_fnc_addMoneyPlayer: Awards player money.
A3A_fnc_resourcesFIA: Updates faction resources.
A3A_fnc_groupDespawner: Cleans up groups.
A3A_fnc_vehDespawner: Cleans up vehicles.
SCRT_fnc_misc_getTimeLimit: Calculates mission time limit.
SCRT_fnc_unit_flattenTier: Retrieves unit arrays from faction templates.
A3A_fnc_fillLootCrate: Fills the salvage crate.
SCRT_fnc_common_addActionMove: Adds move action to the crate.
A3A_fnc_AIVEHinit: Initializes enemy vehicle AI.
A3A_fnc_NATOinit: Initializes enemy unit AI.
Dependencies:

Faction templates for vehicle/unit classes.
Global variables: tierWar, teamPlayer, sidesX, posHQ.
Salvage rope system (A3A_fnc_SalvageRope).
Network Implications:

All spawning and AI management runs server-side.
Player actions (undercover disabling) are handled via remote execution.
Task updates broadcast to all players.
Crate move action is added locally to all rebels and civilians.
System Integration:

Part of the logistics mission module. Called by A3A_fnc_missionRequest.
Integrates with the salvage rope system for underwater retrieval.
Modifies enemy resources and player rewards.

Function Name: fn_missionRequest.sqf

What it does: This function is the main mission request handler for the server in the Antistasi community multiplayer mod. It acts as the central dispatcher that validates, selects, and initiates a wide variety of mission types requested by players (or automatically) when called from the mission menu. Its primary purpose is to ensure a mission is viable given the current game state (active tasks, HQ proximity, spawn availability, etc.) and then queue the selected mission type with the appropriate parameters for execution by the scheduler. It handles all mission categories: Assassination (AS), Conquer (CON), Destroy (DES), Logistics (LOG), Support (SUPP), Rescue (RES), and Convoy (CONVOY), including special Rivals variants. It also manages the mission request cooldown and error states.

How it does that:

Server & Progress Validation: The function immediately checks if it's running on the server. If not, it exits with an error because mission management is strictly server-side to maintain game state authority. It then checks a global lock variable (A3A_missionRequestInProgress) to prevent concurrent mission requests. If a request is already processing, it waits until the lock is released.

fn_missionRequest.sqf

Apply
if(!isServer) exitWith { Error("Server-only function miscalled") };

waitUntil {isNil "A3A_missionRequestInProgress"};
A3A_missionRequestInProgress = true;
Parameter Parsing & Auto-Selection: It parses input arguments: mission type, requesting client owner ID, and a silent flag. If no mission type is provided (_type is nil), it automatically selects a random type from a predefined list (CON, DES, LOG, SUPP, RES, CONVOY), excluding any currently active types (A3A_activeTasks). This auto-selection mode forces _silent to true to suppress chat messages.

fn_missionRequest.sqf

Apply
params ["_type", ["_requester", clientOwner], ["_silent", false]];

if(isNil "_type") then {
    private _types = ["CON","DES","LOG","SUPP","RES","CONVOY"];
    _type = selectRandom (_types - A3A_activeTasks);
    _silent = true;
};
Pre-Check Conditions: The function performs critical pre-flight checks. It verifies the mission type isn't already active (_type in A3A_activeTasks) and ensures the faction leader (Petros) is alive and in command (leader group petros != petros). If the type is already active, it sends a localized chat message to the requester (unless silent) and aborts. It also unsets the progress lock before exiting in these failure cases.

fn_missionRequest.sqf

Apply
if (isNil "_type" or leader group petros != petros) exitWith { A3A_missionRequestInProgress = nil };
if (_type in A3A_activeTasks) exitWith {
    if (!_silent) then {[petros, "globalChat", localize "STR_chats_mission_request_already_type"] remoteExec ["A3A_fnc_commsMP",_requester]};
    A3A_missionRequestInProgress = nil;
};
Rivals Task Possibility Check: A local closure is defined to check if a site is eligible for a Rivals-specific mission variant. It checks if the site is in the Rivals locations list, if the Rivals Attack task isn't already active, and if a probability roll succeeds. This is used to inject Rivals-specific content into standard mission types.

fn_missionRequest.sqf

Apply
private _checkRivalsTaskPossibility = {
    params ["_site"];
    site in ([] call SCRT_fnc_rivals_getLocations) && {!("RIV_ATT" in A3A_activeTasks) && {([] call SCRT_fnc_rivals_rollProbability)}}
};
Mission Type Switching (The Core Logic): A large switch statement handles each mission type. For each type, it dynamically generates a list of _possibleMarkers (game locations) based on distance from HQ, faction ownership, spawn status, and other factors. It then filters this list and, if valid sites exist, selects a random site and decides which specific mission sub-type to spawn via a nested switch or selectRandomWeighted logic. If no valid sites are found, it sends a localized "no missions available" message to the requester.

Example for AS (Assassination): It checks airports, military bases, cities, and controls. It adds controls on the frontier if there are friendly markers nearby. It then chooses between Ambush, Official (Airbase), Traitor (City, possibly Rivals), or SpecOP based on site location and random chance.
Example for CON (Conquer): It looks for outposts, military administrations, seaports, factories, resources, and road controls. It prioritizes military administrations and checks for frontline status to decide between CON_MilAdmin, CON_Outpost_Compet, or CON_Outpost.
Example for DES (Destroy): Focuses on airports, non-road controls, and destroys antennas. Sub-types include Vehicle, Heli (airfield), Antenna, or Artillery (control).
Example for LOG (Logistics): Seeks seaports, outposts, and controls. Can trigger LOG_Ammo, LOG_Bank, LOG_Salvage, or a random weighted selection of LOG_Airdrop, LOG_Helicrash, or LOG_Crashsite.
Example for SUPP (Support): Targets cities with low rebel support, weighted by distance and support level. Checks for Rivals eligibility for RIV_SUPP_Salvage; otherwise, triggers SUPP_Supplies.
Example for RES (Rescue): Targets cities and nearby airbases/outposts. Logic handles shipwrecks (world-dependent), informers (night + high tier), refugees, or prisoners/deserters (tier-dependent), with Rivals checks for prison breaks.
Example for CONVOY: Checks against a global "big attack" lock. It attempts to find source (outpost/airfield) and destination (city/other) pairs within range and not owned by the player. It uses A3A_fnc_findBasesForConvoy to validate routes.
fn_missionRequest.sqf

Apply
switch (_type) do {
    case "AS": {
        // ... marker finding logic ...
        private _site = selectRandom _possibleMarkers;
        switch (true) do {
            case ((random 100) < 15): { ... A3A_fnc_AS_Ambush ... };
            case (_site in airportsX): { ... A3A_fnc_AS_Official ... };
            // ... etc ...
        };
    };
    // ... other cases ...
};
Success Notification & Lock Management: If _possibleMarkers had a count > 0 (meaning a mission was found), it sends a "success" message (unless silent) and introduces a 3-second delay. This delay is critical; it allows time for the mission scheduler to register the new task in A3A_activeTasks before the lock (A3A_missionRequestInProgress) is cleared, preventing race conditions.

fn_missionRequest.sqf

Apply
if (count _possibleMarkers > 0) then {
    if (!_silent) then {
        [petros, "globalChat", localize "STR_chats_mission_request_success"] remoteExec ["A3A_fnc_commsMP",_requester]
    };
    sleep 3;            // delay lockout until the mission is registered
};
A3A_missionRequestInProgress = nil;
Where it leads:

Functions it calls:
SCRT_fnc_rivals_getLocations: Retrieves coordinates for Rivals hideouts/cells.
SCRT_fnc_rivals_rollProbability: Checks if Rivals content should be spawned.
A3A_fnc_findIfNearAndHostile: Core helper to filter markers based on proximity to HQ and if they are hostile (enemy-owned).
A3A_fnc_isFrontlineNoFIA: Checks if a site is on the frontline without FIA presence.
A3A_fnc_findBasesForConvoy: Used in CONVOY missions to validate and find source/destination pairs.
Scheduler Dispatch: It calls remoteExec ["A3A_fnc_scheduler",2] with the mission function and parameters (e.g., [[_site],"A3A_fnc_AS_Ambush"]). This queues the mission script on the server (owner 2). Examples of called functions include A3A_fnc_AS_Ambush, A3A_fnc_CON_MilAdmin, A3A_fnc_DES_Vehicle, A3A_fnc_LOG_Ammo, A3A_fnc_SUPP_Supplies, A3A_fnc_RES_Prisoners, A3A_fnc_convoy.
A3A_fnc_commsMP: Used to send chat/hint messages to the requesting client.
Functions dependent on this: This is a top-level entry point. It is called by player interaction via the Ace Action menu, the briefing module, or internal triggers (e.g., mission auto-assignment). Any system that generates a mission request ultimately leads to this function.
System Fit: It is the "Mission Generator" part of the Antistasi mission lifecycle. It acts as the gatekeeper and selector, feeding into the "Mission Execution" layer (the scheduler and individual mission scripts) and the "Game State" layer (modifying A3A_activeTasks).
Global Variables Modified:
A3A_missionRequestInProgress (Boolean): Set to true at start, set to nil at end (acts as a lock).
Synchronization/Network Implications:
All logic is server-side.
remoteExec calls are used to communicate back to the client (requester) for notifications.
Mission spawning is dispatched via remoteExec to the scheduler, ensuring the server spawns the mission logic. The delay (sleep 3) is crucial for synchronization with the task registration system to avoid the same mission being requested twice before it appears in A3A_activeTasks.

A3A/addons/core/functions/Missions/fn_REP_Antenna.sqf
Function Name: A3A_fnc_REP_Antenna
What it does: This function creates and manages a mission to repair an antenna at a specific location. The mission involves defending a repair truck until it reaches the antenna, then protecting it from enemy forces until it completes repairs. This is a defensive-style mission where players must guard a repair vehicle as it approaches and works on the antenna. The mission is designed for multiplayer cooperation and has a time limit.

Context: Called when the game generates an "Repair Antenna" mission type. This is one of the possible side missions that can spawn in the A3A liberation mod. The mission spawns only on the server and communicates mission state to clients via the task system.

How it does that:

1. Initial Setup and Parameter Validation
Sqf

Apply
params ["_markerX", "_antennaDead"];

//Mission: Repair the antenna
if (!isServer and hasInterface) exitWith{};
Extracts parameters: _markerX (location marker), _antennaDead (antenna object that's destroyed)
Early exit if called on a client with interface (mission only runs on server)
This prevents mission logic from running on player machines, ensuring server-side control
2. Mission Time Limit Calculation
Sqf

Apply
(60 call SCRT_fnc_misc_getTimeLimit) params ["_dateLimitNum", "_displayTime"];
Calls SCRT_fnc_misc_getTimeLimit with parameter 60 (minutes)
Returns _dateLimitNum (deadline in dateToNumber format) and _displayTime (formatted string)
Creates a 60-minute time limit for mission completion
3. Mission Task Creation
Sqf

Apply
private _nameDest = [_markerX] call A3A_fnc_localizar;

private _taskId = "REP" + str A3A_taskCount;
[
	[teamPlayer, civilian],
	_taskId,
	[
		format [localize "STR_A3A_Missions_REP_Antenna_task_desc",FactionGet(occ,"name"),_nameDest,_displayTime],
		localize "STR_A3A_Missions_REP_Antenna_task_header",
		_markerX
	],
	getPos _antennaDead,
	false, 0, true, "Destroy", true
] call BIS_fnc_taskCreate;
[_taskId, "REP", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Gets localized destination name via A3A_fnc_localizar
Creates unique task ID using "REP" prefix and task counter
Builds task description with faction name, destination, and time limit
Creates BIS task with:
Owner: teamPlayer and civilian (available to rebels and civilians)
Position: antenna location
Type: "Destroy" (but actually repair)
Visible in task list
Immediately updates task state to "CREATED" on all clients (JIP compatible)
4. Initial Wait Condition
Sqf

Apply
waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (spawner getVariable _markerX != 2)};
Waits until either:
Time limit expires, OR
Spawner variable changes (player approaches location)
Sleeps 1 second each iteration to prevent CPU load
When player arrives, mission starts; if time expires first, mission fails
5. Truck Spawning Logic
Sqf

Apply
private _truckCreated = false;

if (spawner getVariable _markerX != 2) then {
	_truckCreated = true;
	private _size = [_markerX] call A3A_fnc_sizeMarker;
	private _road = [getPos _antennaDead] call A3A_fnc_findNearestGoodRoad;
	private _pos = position _road;
	_pos = _pos findEmptyPosition [1,60,"B_T_Truck_01_repair_F"];
	private _veh = createVehicle [selectRandom (FactionGet(occ,"vehiclesRepairTrucks")), _pos, [], 0, "NONE"];
	_veh allowdamage false;
	_veh setDir (getDir _road);
	[_veh, Occupants] call A3A_fnc_AIVEHinit;
	private _groupX = createGroup Occupants;

	sleep 5;
	_veh allowDamage true;
Checks if players arrived at location
Finds nearest good road to antenna via A3A_fnc_findNearestGoodRoad
Uses findEmptyPosition to find safe spawn location near road
Creates repair truck from occupant faction's repair truck list
Temporarily disables damage (5 seconds) to prevent instant destruction
Sets truck direction to match road direction
Initializes vehicle with A3A_fnc_AIVEHinit (sets side, supplies, etc.)
Creates empty group for crew
6. Spawn Truck Crew
Sqf

Apply
	for "_i" from 1 to 3 do {
		_unit = [_groupX, FactionGet(occ,"unitCrew"), _pos, [], 0, "NONE"] call A3A_fnc_createUnit;
		[_unit,""] call A3A_fnc_NATOinit;
		sleep 2;
	};
Creates 3 crew members from faction's crew unit type
Each crew member initialized with A3A_fnc_NATOinit
2-second delay between spawns for visual pacing
7. Monitor Truck Survival
Sqf

Apply
	waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (not alive _veh)};

	if (not alive _veh) then {
		[_taskId, "REP", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [Occupants, 15, 90] remoteExec ["A3A_fnc_addAggression", 2];
        [Invaders, 5, 60] remoteExec ["A3A_fnc_addAggression", 2];
		[1200, Occupants] remoteExec ["A3A_fnc_timingCA",2];
		{
			[10,_x] call A3A_fnc_addScorePlayer;
    		[250,_x] call A3A_fnc_addMoneyPlayer;
		} forEach (call SCRT_fnc_misc_getRebelPlayers);
		[5,theBoss] call A3A_fnc_addScorePlayer;
		[150,theBoss, true] call A3A_fnc_addMoneyPlayer;
	};
Waits for either time limit OR truck destruction
If truck destroyed (mission success condition):
Sets task to "SUCCEEDED"
Adds aggression to both Occupants and Invaders (but less for Invaders)
Triggers Combat Alert timing (1200 seconds)
Awards score (10) and money (250) to all rebel players
Extra bonus for theBoss (5 score, 150 money)
8. Time Limit Expiration Check
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
	if (sidesX getVariable [_markerX,sideUnknown] == teamPlayer) then {
		[_taskId, "REP", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [Occupants, 15, 90] remoteExec ["A3A_fnc_addAggression", 2];
        [Invaders, 5, 60] remoteExec ["A3A_fnc_addAggression", 2];
		[1200, Occupants] remoteExec ["A3A_fnc_timingCA",2];
		{ 
			[10,_x] call A3A_fnc_addScorePlayer;
    	   	[250,_x] call A3A_fnc_addMoneyPlayer; 
		} forEach (call SCRT_fnc_misc_getRebelPlayers);
		[5,theBoss] call A3A_fnc_addScorePlayer;
		[150,theBoss, true] call A3A_fnc_addMoneyPlayer;
	} else {
		[_taskId, "REP", "FAILED"] call A3A_fnc_taskSetState;
		//Mission failure with reduced rewards
		[-600, Occupants] remoteExec ["A3A_fnc_timingCA",2];
		[-10,theBoss] call A3A_fnc_addScorePlayer;
	};
	[_antennaDead] remoteExec ["A3A_fnc_rebuildRadioTower", 2];
};
Checks if time limit expired
If teamPlayer controls marker (mission area):
Awards same success rewards as truck destruction
Else:
Sets task to "FAILED"
Penalizes teamPlayer with -600 cooldown and -10 score for boss
Calls A3A_fnc_rebuildRadioTower (async, remoteExec to server)
This repairs the antenna permanently
9. Cleanup and Despawn
Sqf

Apply
[_taskId, "REP", 30] spawn A3A_fnc_taskDelete;

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

if (isNil "_groupX") exitWith {};
[_groupX] spawn A3A_fnc_groupDespawner;
[_veh] spawn A3A_fnc_vehDespawner;
Spawns task deletion after 30 minutes (cleanup)
Waits for marker to be despawned (players left area)
Despawns group and vehicle if they exist
Prevents orphaned entities persisting in mission
Where it leads:

Functions Called:
SCRT_fnc_misc_getTimeLimit - Calculates mission time limit based on difficulty and game settings
A3A_fnc_localizar - Localizes marker name for player display
A3A_fnc_sizeMarker - Gets marker size for area calculations
A3A_fnc_findNearestGoodRoad - Finds viable road near antenna for truck spawn
A3A_fnc_createUnit - Spawns AI units with proper faction and loadout
A3A_fnc_NATOinit - Initializes AI unit with NATO/occupant settings and skills
A3A_fnc_AIVEHinit - Initializes vehicle with AI factions, supplies, and AI behavior
A3A_fnc_taskSetState - Updates task status (SUCCEEDED/FAILED/CREATED)
A3A_fnc_addAggression - Modifies faction aggression levels (affects enemy response)
A3A_fnc_timingCA - Controls cooldown time between enemy attacks
A3A_fnc_addScorePlayer - Awards reputation points to players
A3A_fnc_addMoneyPlayer - Awards in-game currency to players
SCRT_fnc_misc_getRebelPlayers - Gets list of rebel players in mission area
A3A_fnc_rebuildRadioTower - Repairs the antenna after mission time expires
A3A_fnc_taskDelete - Removes task from game after timeout
A3A_fnc_groupDespawner - Cleans up AI groups safely
A3A_fnc_vehDespawner - Cleans up vehicles safely
Functions That Depend on This:
A3A_fnc_missionRequest - Calls this function when player requests "Repair Antenna" mission type
A3A_fnc_findIfNearAndHostile - May check mission state for hostility calculations
Mission generation system - Adds this mission to available mission pool
System Integration:
Task System: Uses BIS task system for mission objectives and UI
Reward System: Ties into player economy (score, money) and faction relations
Spawner System: Uses marker spawner variables to detect player presence
AI System: Spawns AI with proper faction templates via FactionGet()
Network: Uses remoteExec for all player-facing notifications and reward distribution
Global Variables: Modifies A3A_taskCount, sidesX (indirectly via A3A_fnc_rebuildRadioTower)
Edge Cases & Validation:

Non-server execution: Early exit prevents mission duplication or client crashes
Antenna already repaired: A3A_fnc_rebuildRadioTower handles idempotency
No good road: findEmptyPosition provides fallback near antenna
No rebel players: SCRT_fnc_misc_getRebelPlayers returns empty array, rewards skipped
Group/Vehicle already deleted: isNil "_groupX" check prevents null errors
Time limit edge: Uses dateToNumber for precise 60-minute calculation
Synchronization/Network Implications:

All task updates (CREATED, SUCCEEDED, FAILED) are remoteExecCall to all clients
Reward distribution uses remoteExec with 2 parameter (server only)
A3A_fnc_rebuildRadioTower is remoteExec to server (index 2)
Player rewards are calculated locally on server and distributed via remoteExec
All AI spawning is server-side only (no JIP issues)

A3A/addons/core/functions/Missions/fn_RES_Deserters.sqf
Function Name: A3A_fnc_RES_Deserters
What it does: Creates and manages a rescue mission where rebel players must rescue deserters (friendly AI units) from enemy territory. The deserters are hidden in a building or location, guarded by enemy patrols. Players must locate and extract the deserters while dealing with patrols and potentially calling for reinforcements. Mission success requires rescuing at least some deserters and returning them to base.

Context: Called when the game generates a "Rescue Deserters" mission type. This is a cooperative rescue mission with stealth and combat elements. The mission spawns deserters with varying difficulty based on war tier, and can include stolen vehicles and enemy patrols.

How it does that:

1. Initial Setup and Parameters
Sqf

Apply
params ["_markerX"];
//Mission: Rescue the prisoners
if (!isServer and hasInterface) exitWith{};
private _effects = [];
private _Deserters = [];
private _vehicles = [];
private _groups = [];
private _props = [];
private _sideX = if (sidesX getVariable [_markerX, sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
private _difficultX = random 10 < tierWar;
private _positionX = getMarkerPos _markerX;
Extracts marker parameter
Early exit for clients
Initializes empty arrays for tracking spawned objects
Determines defending side based on who controls the marker
Gets faction data for that side
Calculates difficulty: 30% chance if tierWar > 0 (scales with game progression)
Gets spawn position from marker
2. Mission Time Limit
Sqf

Apply
private _limit = if (_difficultX) then {
	45 call SCRT_fnc_misc_getTimeLimit
} else {
	120 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
45-minute limit if difficult (low tier), 120-minute limit otherwise
Different time limits create pressure variation
3. Finding Suitable Building for Deserters
Sqf

Apply
private _posHouse = [];
private _countX = 0;
private _houses = (nearestObjects [_positionX, ["house"], 2000]) select {!((typeOf _x) in A3A_buildingBlacklist)};
private _houseX = "";
private _potentials = [];
private _spawnPos = [];
for "_i" from 0 to (count _houses) - 1 do {
	_houseX = (_houses select _i);
	_posHouse = [_houseX] call BIS_fnc_buildingPositions;
	if (count _posHouse > 1) then {_potentials pushBack _houseX};
};
Searches 2000m radius for buildings
Filters out blacklisted buildings (prevents spawning in enemy bases)
Gets building positions for each building
Collects buildings with more than 1 position (can hold deserters)
If no suitable buildings found, fallback to open area
4. Spawn Position Determination
Sqf

Apply
if (count _potentials > 0) then {
	_houseX = selectRandom _potentials;
	_spawnPos = _houseX;
	_posHouse = [_houseX] call BIS_fnc_buildingPositions;
	_countX = (count _posHouse);
	if (_countX > 10) then {_countX = 10};
} else {
	_countX = (round random 4) + 3;
	_spawnPos = _positionX;
	for "_i" from 0 to _countX do {
		_postmp = [_positionX, 5, random 360] call BIS_Fnc_relPos;
		_posHouse pushBack _postmp;
	};
};
If buildings found: pick random, limit to max 10 deserters
If no buildings: spawn in open area, 3-7 deserters, use relative positions near center
_spawnPos becomes mission center for task and patrols
5. Task Creation
Sqf

Apply
private _taskId = "RES" + str A3A_taskCount;
if (count _potentials > 0) then {
	[[teamPlayer,civilian],_taskId,[format [localize "STR_A3A_Missions_RES_Deserters_task_desc",_nameDest,_displayTime],localize "STR_A3A_Missions_RES_Deserters_task_header",_markerX],_spawnPos,false,0,true,"run",true] call BIS_fnc_taskCreate;
	[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
} else {
	[[teamPlayer,civilian],_taskId,[format [localize "STR_A3A_Missions_RES_Deserters_task_desc",_nameDest,_displayTime],localize "STR_A3A_Missions_RES_Deserters_task_header",_markerX],_positionX,false,0,true,"run",true] call BIS_fnc_taskCreate;
	[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
};
Creates task with "run" icon
Position is either building or marker position
Same description regardless of spawn type
Immediately notifies all clients of task creation
6. Wait for Player Approach
Sqf

Apply
waitUntil {
    sleep 1;
    (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_spawnPos, distanceSPWN1, distanceSPWN1] isNotEqualTo [] || {dateToNumber date > _dateLimitNum}
};
Waits until at least one rebel player enters spawn area (distanceSPWN1 = 400m typically)
Or time limit expires
Uses SCRT_fnc_misc_getRebelPlayers to get active rebel players
7. Spawn Enemy Patrols
Sqf

Apply
private _infantrySquadArray = [
    selectRandom ([_faction, "groupsTierMedium"] call SCRT_fnc_unit_flattenTier),
    selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)
] select _difficultX;

private _vehiclePatrolType = selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaAPCs") + (_faction get "vehiclesMilitiaTrucks"));

_stolenVehicleType = if (_difficultX) then {
    selectRandom ((_faction get "vehiclesLightAPCs") +(_faction get "vehiclesLightArmed") + (_faction get "vehiclesTrucks"));
} else {
    selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesTrucks") + (_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaCars") + (_faction get "vehiclesMilitiaAPCs") + (_faction get "vehiclesMilitiaTrucks"));
}; 

private _nearbyPos = [_spawnPos, 200, 300, 3, 0, 5, 0] call BIS_fnc_findSafePos;
private _patrolGroup1 = [_nearbyPos, _sideX, _infantrySquadArray] call A3A_fnc_spawnGroup;
Selects squad template based on difficulty (medium vs squad-tier units)
Picks random vehicle types for patrols from faction lists
Generates stolen vehicle type (different for difficult missions)
Finds safe position 200-300m from spawn
Spawns first infantry patrol group
8. Vehicle Patrol and Crew Initialization
Sqf

Apply
{ 
    [_x] call A3A_fnc_NATOinit;
} forEach units _patrolGroup1;
private _PatrolvehData  = [_nearbyPos, 0,_vehiclePatrolType, _sideX] call A3A_fnc_spawnVehicle;
private _Patrolveh = _PatrolvehData select 0;
private _vehCrew = _PatrolvehData select 1;
private _patrolVehgroup = _PatrolvehData select 2;
{ 
    [_x] call A3A_fnc_NATOinit;
} forEach _vehCrew;
[_Patrolveh, _sideX] call A3A_fnc_AIVEHinit;
Initializes all patrol units with A3A_fnc_NATOinit
Spawns vehicle patrol via A3A_fnc_spawnVehicle (returns [vehicle, crew array, group])
Initializes vehicle crew and the vehicle itself
Sets vehicle side affiliation
9. Stolen Vehicle Spawn
Sqf

Apply
private _stolenVehicleSpawnPos = [_spawnPos, 5, 50, 3, 0, 5, 0] call BIS_fnc_findSafePos;
private _stolenVehicle = createVehicle [_stolenVehicleType, _stolenVehicleSpawnPos, [], 0, "NONE"];
[_stolenVehicle, teamPlayer] call A3A_fnc_AIVEHinit;
Finds safe position 5-50m from spawn
Creates stolen vehicle for players to use for extraction
Initializes vehicle for teamPlayer side (rebel-use)
10. Optional Second Patrol (Difficult Mode)
Sqf

Apply
private _patrolGroup2 = [];
private _soldersPatrol = [];
if (_difficultX) then {
	_nearbyPos = [_spawnPos, 100, 150, 3, 0, 20, 0] call BIS_fnc_findSafePos;
	_patrolGroup2 = [_nearbyPos, _sideX, _infantrySquadArray] call A3A_fnc_spawnGroup;
	_soldersPatrol append units _patrolGroup2;
	{ 
    	[_x] call A3A_fnc_NATOinit;
	} forEach units _patrolGroup2;
};
Spawns second patrol group if difficulty is high
Closer to spawn (100-150m) for tougher challenge
Adds to patrol list for tracking
11. Compile Patrol Unit Lists
Sqf

Apply
_soldersPatrol append units _patrolGroup1;
_soldersPatrol append units _patrolVehgroup;
Creates single array of all patrol units for later checking
12. Wait for Player Contact
Sqf

Apply
waitUntil {
    sleep 1;
    (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_spawnPos, 500, 500] isNotEqualTo [] || {dateToNumber date > _dateLimitNum}
};
Second wait: closer radius (500m) ensures patrol activity
Time limit check again
13. Activate Patrols
Sqf

Apply
[_patrolGroup1, _stolenVehicleSpawnPos, 15] call bis_fnc_taskPatrol;
[_patrolVehgroup, _stolenVehicleSpawnPos, 15] call bis_fnc_taskPatrol;
if (_difficultX) then {
	[_patrolGroup2, _stolenVehicleSpawnPos, 15] call bis_fnc_taskPatrol;
};
Assigns BIS patrol tasks to all groups
Patrol radius: 15m around stolen vehicle spawn
This keeps patrols defending the area
14. Create Deserters Group
Sqf

Apply
private _grpDeserters = createGroup teamPlayer;
private _unit = objNull;
private _unitTypes = [(_faction get "unitMilitiaGrunt"),(_faction get "unitMilitiaMarksman"),
(_faction get "unitMilitiaGrenadier"),(_faction get "unitMilitiaSniper"),
(_faction get "unitMilitiaMedic"),(_faction get "unitCrew"),(_faction get "unitPilot"),
"loadouts_occ_militia_Grenadier","loadouts_occ_military_Grenadier","loadouts_occ_elite_Grenadier",
"loadouts_occ_militia_LAT","loadouts_occ_military_LAT","loadouts_occ_elite_LAT",
"loadouts_occ_militia_MachineGunner","loadouts_occ_military_MachineGunner","loadouts_occ_elite_MachineGunner","loadouts_occ_militia_Rifleman","loadouts_occ_military_Rifleman",
"loadouts_occ_elite_Rifleman","loadouts_occ_militia_Marksman","loadouts_occ_military_Marksman","loadouts_occ_elite_Marksman","loadouts_occ_militia_Sniper",
"loadouts_occ_military_Sniper","loadouts_occ_elite_Sniper"];
Creates group assigned to teamPlayer (for recruitment purposes)
Builds extensive list of possible deserter unit types:
Faction-specific units (militia, crew, pilot)
Loadout templates from templates system
Covers all combat roles
15. Spawn Deserters
Sqf

Apply
for "_i" from 0 to _countX do {
	_unitRandom = selectRandom _unitTypes;
	if (_sideX == Occupants) then {
		if (count _potentials > 0) then {
			_unit = [_grpDeserters, _unitRandom,_spawnPos, [], 3, "NONE"] call A3A_fnc_createUnit;
			[_unit, createHashMapFromArray [["face", selectRandom (A3A_faction_occ get "faces")], ["speaker", selectRandom (A3A_faction_occ get "voices")]]] call A3A_fnc_setIdentity;
		} else {
			_unit = [_grpDeserters, _unitRandom, (_posHouse select _i), [], 0, "NONE"] call A3A_fnc_createUnit;
			[_unit, createHashMapFromArray [["face", selectRandom (A3A_faction_occ get "faces")], ["speaker", selectRandom (A3A_faction_occ get "voices")]]] call A3A_fnc_setIdentity;
		};
	} else {
		if (count _potentials > 0) then {
			_unit = [_grpDeserters, _unitRandom, (_posHouse select _i), [], 0, "NONE"] call A3A_fnc_createUnit;
			[_unit, createHashMapFromArray [["face", selectRandom (A3A_faction_inv get "faces")], ["speaker", selectRandom (A3A_faction_inv get "voices")]]] call A3A_fnc_setIdentity;
		} else {
			_unit = [_grpDeserters, _unitRandom,_spawnPos, [], 3, "NONE"] call A3A_fnc_createUnit;
			[_unit, createHashMapFromArray [["face", selectRandom (A3A_faction_inv get "faces")], ["speaker", selectRandom (A3A_faction_inv get "voices")]]] call A3A_fnc_setIdentity;
		};
	};
	_unit allowDamage false;
	_unit setCaptive true;
	_unit disableAI "MOVE";
	_unit disableAI "AUTOTARGET";
	_unit disableAI "TARGET";
	_unit setUnitPos "UP";
	_unit setBehaviour "CARELESS";
	_unit allowFleeing 0;
	_Deserters pushBack _unit;
	[_unit,"deserter"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
};
sleep 5;
Spawns each deserter:
Random unit type from list
Building positions if available, otherwise spawn area
Applies faction-specific identity (face/voice)
Makes deserters invulnerable initially and captive
Disables all AI behaviors (move, target, etc.)
Sets to upright position, careless behavior (won't flee)
Adds action flag "deserter" for players to interact with
Stores in _Deserters array
16. Wait for Player Extraction
Sqf

Apply
waitUntil {
    sleep 1;
    (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [getPos _Patrolveh, 400, 400] isNotEqualTo [] || {dateToNumber date > _dateLimitNum}
};

{
_x setCaptive false;
_x enableAI "MOVE";
_x enableAI "AUTOTARGET";
_x enableAI "TARGET";
_x setUnitPos "UP";
_x setBehaviour "AWARE";
} forEach _Deserters;
sleep 30;
{_x allowDamage true;} forEach _Deserters;
Waits for players near patrol vehicle (or time limit)
Makes deserters vulnerable and controllable:
Removes captive status
Enables AI behaviors (move, target)
Sets to aware behavior
30-second delay before allowing damage (gives players time to secure area)
17. Reinforcement Check
Sqf

Apply
if (count _soldersPatrol <= (count (_soldersPatrol))/2) then {
	private _reveal = [_spawnPos , _sideX] call A3A_fnc_calculateSupportCallReveal;
    [_spawnPos, 4, ["QRF"], _sideX, _reveal] remoteExec ["A3A_fnc_createSupport", 2];
};
If 50% or more patrols killed, enemy calls QRF
Uses A3A_fnc_calculateSupportCallReveal to determine detection level
Spawns QRF support via remote execution to server
18. Monitor Mission State
Sqf

Apply
waitUntil {sleep 1; {alive _x} count _Deserters == 0 or {{(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 50)} count _Deserters > 0}};
private _bonus = if (_difficultX) then {2} else {1};
if ({alive _x} count _Deserters == 0) then {
	[_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
	{[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false} forEach _Deserters;
	[-10*_bonus,theBoss] call A3A_fnc_addScorePlayer;
} else {
	// Success handling...
};
Waits for either:
All deserters dead (failure), OR
Any deserter within 5m of respawn point (success)
Bonus multiplier (2x for difficult, 1x for easy)
Failure: sets task to FAILED, removes captive status, penalizes boss
Success: continues to reward calculation
19. Success Rewards and Logic
Sqf

Apply
sleep 5;
[_taskId, "RES", "SUCCEEDED"] call A3A_fnc_taskSetState;
_countX = {(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 150)} count _Deserters;
_hr = 2 * (_countX);
_resourcesFIA = 100 * _countX*_bonus;
[_hr,_resourcesFIA] remoteExec ["A3A_fnc_resourcesFIA",2];
[0,10*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
[Occupants, -(_countX * 1.5), 90] remoteExec ["A3A_fnc_addAggression",2];
{
	[_countX, _x] call A3A_fnc_addScorePlayer;
	[_countX*10,_x] call A3A_fnc_addMoneyPlayer;
} forEach (call SCRT_fnc_misc_getRebelPlayers);
for "_i" from 0 to 2 do {
    [(getMarkerPos respawnTeamPlayer), 6000, 1200, false] spawn SCRT_fnc_common_recon;
    if (hideEnemyMarkers) then {
        [(selectRandom [2,3])] call A3U_fnc_revealRandomZones;
    };
    uiSleep 60;
};
private _bonusAmount = round (_countX*_bonus/2);
[_bonusAmount,theBoss] call A3A_fnc_addScorePlayer;
[(_bonusAmount*10),theBoss, true] call A3A_fnc_addMoneyPlayer;
{[_x] join _grpDeserters; [_x] orderGetin false} forEach _Deserters;
Waits 5 seconds for dramatic effect
Counts deserters rescued (within 150m of respawn)
Calculates rewards:
HR (Human Resources): 2 per deserter
FIA Resources: 100 * deserters * bonus
City Support: +10 * bonus
Aggression decrease: -1.5 * deserters (makes enemy less hostile)
Score: deserters count per player
Money: 10 * deserters count * bonus
Bonus reconnaissance (3 rounds, 60s apart):
Spawns recon mission to reveal nearby zones
If hideEnemyMarkers enabled, reveals random zones
Extra boss bonus: half deserter count * bonus / 2 (rounded)
Joins deserters to rebel group for transport
20. Loot Collection
Sqf

Apply
sleep 60;
private _items = [];
private _ammunition = [];
private _weaponsX = [];
{
	private _unit = _x;
	if (_unit distance getMarkerPos respawnTeamPlayer < 150) then {
		{if (not(([_x] call BIS_fnc_baseWeapon) in unlockedWeapons)) then {_weaponsX pushBack ([_x] call BIS_fnc_baseWeapon)}} forEach weapons _unit;
		{if (not(_x in unlockedMagazines)) then {_ammunition pushBack _x}} forEach magazines _unit;
		_items = _items + (items _unit) + (primaryWeaponItems _unit) + (assignedItems _unit) + (secondaryWeaponItems _unit);
	};
	deleteVehicle _unit;
} forEach _Deserters;
deleteGroup _grpDeserters;
{boxX addWeaponCargoGlobal [_x,1]} forEach _weaponsX;
{boxX addMagazineCargoGlobal [_x,1]} forEach _ammunition;
{boxX addItemCargoGlobal [_x,1]} forEach _items;
After 60 seconds (players have had time to return to base):
Collect gear from each deserter:
Weapons not unlocked are added to boxX (HQ storage)
Magazines not unlocked are added
Items, attachments, assigned items added
Deletes deserters and group
Stores gear in global boxX variable
21. Final Cleanup
Sqf

Apply
missionNamespace setVariable ["A3U_dialogCivMissionInProgress", false, true];

[_taskId, "RES", 1200] spawn A3A_fnc_taskDelete;
Resets mission availability flag (for AI mission request system)
Spawns task deletion after 1200 seconds (20 minutes)
Where it leads:

Functions Called:
SCRT_fnc_misc_getTimeLimit - Calculates time limits based on difficulty
A3A_fnc_localizar - Gets localized destination name
BIS_fnc_buildingPositions - Finds interior positions in buildings
A3A_fnc_spawnGroup - Creates AI group with template
A3A_fnc_spawnVehicle - Spawns vehicle with crew
A3A_fnc_NATOinit - Initializes AI units
A3A_fnc_AIVEHinit - Initializes vehicles
A3A_fnc_createUnit - Creates individual units
A3A_fnc_setIdentity - Sets face/voice for units
A3A_fnc_flagaction - Adds interaction action to units
bis_fnc_taskPatrol - Assigns patrol AI behavior
A3A_fnc_calculateSupportCallReveal - Determines support detection level
A3A_fnc_createSupport - Spawns enemy reinforcements
A3A_fnc_taskSetState - Updates mission status
A3A_fnc_resourcesFIA - Adds HR and resources
A3A_fnc_citySupportChange - Modifies city relations
A3A_fnc_addAggression - Changes faction hostility
A3A_fnc_addScorePlayer - Awards player reputation
A3A_fnc_addMoneyPlayer - Awards currency
SCRT_fnc_common_recon - Spawns reconnaissance missions
A3U_fnc_revealRandomZones - Reveals hidden enemy markers
SCRT_fnc_misc_getRebelPlayers - Gets active rebel players
A3A_fnc_taskDelete - Removes task after timeout
Functions That Depend on This:
A3A_fnc_missionRequest - Calls this for "Deserters" mission type
A3A_fnc_findIfNearAndHostile - Checks mission state for hostility
AI Mission Request System - May use this to generate missions for rebels
System Integration:
Building System: Uses A3A_buildingBlacklist to avoid spawning in enemy bases
Identity System: Uses faction face/voice arrays for immersion
Loot System: Integrates with HQ storage (boxX) and unlocked weapons
Support System: Calls A3A_fnc_createSupport for enemy reinforcements
Reconnaissance: Uses SCRT_fnc_common_recon for post-mission intel
Player Economy: Ties into HR, resources, score, and money systems
AI Behavior: Uses BIS patrol and awareness systems
Edge Cases & Validation:

No buildings: Fallback to open area spawning with safe positions
All deserters killed: Task fails, boss penalized
Partial rescue: Only rescued deserters counted (within 150m)
Deserter IDs: Units marked with deserter flag for action system
Network sync: All actions use remoteExec with proper targets
Loot eligibility: Only unlocked gear added to storage
QRF triggering: Only when patrols are 50%+ eliminated
Synchronization/Network Implications:

Task updates use remoteExecCall for immediate client notification
All reward calculations done server-side, distributed via remoteExec
Deserters use remoteExec for flag actions (rebel/civilian access)
QRF uses remoteExec to server (index 2)
Identity setting uses remoteExec for synchronized faces/voices
Recon notifications are broadcast to all players

Function Name: fn_RES_Informer.sqf
What it does: This function initiates and manages the "Rescue Rebel Informer" mission. The goal is to locate and extract an informant from a hostile city controlled by either the Occupants or Invaders factions. The mission dynamically spawns the informant within a suitable building, assigns a search helicopter patrol, sets up roadblocks on city outskirts, and tracks the player's progress. The mission concludes successfully if the informant reaches the Syndicate HQ, or fails if they die or the time limit expires.

How it does that:

Initialization and Parameter Validation: The function starts by ensuring it runs only on the server and aborts if the caller is a client with an interface. It retrieves the marker name passed as a parameter.

Sqf

Apply
//Mission: Rescue Rebel Informer
if (!isServer and hasInterface) exitWith{};

params ["_markerX"];
Determining Faction and Difficulty: It identifies which side controls the marker (Occupants or Invaders) and assigns the corresponding faction data. It calculates mission difficulty based on the current war tier (tierWar).

Sqf

Apply
private _side = if (sidesX getVariable [_markerX, sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_side);
private _difficulty = random 10 < tierWar;
private _positionX = getMarkerPos _markerX;
Setting Time Limits: A time limit is established based on difficulty. SCRT_fnc_misc_getTimeLimit calculates a numeric date limit and a display string.

Sqf

Apply
private _limit = if (_difficulty) then {
    45 call SCRT_fnc_misc_getTimeLimit
} else {
    60 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
Determining City Size: To determine how large the spawn area is, the script checks if the position is a capital or major city. It creates local markers and iteratively expands a radius (_size) until it stops finding building borders or hits a maximum limit (500 for cities, 250 otherwise).

Sqf

Apply
private _cities = ["NameCityCapital","NameCity"] call SCRT_fnc_misc_getWorldPlaces;
private _isCity  = _cities findIf {(_x select 1) distance2D _positionX <= 250} == 0;
private _size = 100;
private _searchIterations = 0;

private _marker1 = createMarkerLocal [format ["%1informerTask1", _markerX], _positionX];
_marker1 setMarkerShapeLocal "ELLIPSE";
_marker1 setMarkerSizeLocal [(_size - 20),(_size - 20)];
// ... (marker2 setup similar)

while {true} do {
    if (_isCity && {_size > 500}) exitWith {};
    if (!_isCity && {_size > 250}) exitWith {};
    if (_searchIterations > 20) exitWith {};
    private _hasBorderBuildings = (_positionX nearObjects ["House", _size]) findIf {!(_x inArea _marker1) && _x inArea _marker2} != -1;
    if (!_hasBorderBuildings) exitWith {};

    _size = _size + 20;
    _marker1 setMarkerSizeLocal [(_size - 20),(_size - 20)];
    _marker2 setMarkerSizeLocal [_size,_size];
    _searchIterations = _searchIterations + 1;
};
Spawning the Informant: The script searches for buildings within the calculated _size. It filters for buildings with accessible positions (BIS_fnc_buildingPositions) and ensures they aren't hidden. A random building is selected, and a random position within it is chosen.

The unit is created as a rebel unarmed unit, given a civilian uniform (to blend in), and disabled for movement and combat. It is made captive and restricted to a standing animation.

Sqf

Apply
private _buildings = _positionX nearobjects ["house",_size];
private _capableBuildings = _buildings select {!(([_x] call BIS_fnc_buildingPositions) isEqualTo []) && {!(isObjectHidden _x)}};
private _informerBuilding = selectRandom _capableBuildings;
private _informerBuildingPosition = selectRandom ([_informerBuilding] call BIS_fnc_buildingPositions);

private _grpInformer = createGroup teamPlayer;
private _informer = [_grpInformer, A3A_faction_reb get "unitUnarmed", _informerBuildingPosition, [], 0, "NONE"] call A3A_fnc_createUnit;
_informer forceAddUniform (selectRandom (A3A_faction_civ get "uniforms"));
_informer allowDamage false;
[_informer,true] remoteExec ["setCaptive",0,_informer];
_informer disableAI "MOVE";
_informer playMoveNow "ApanPknlMstpSnonWnonDnon_G01";
Spawning the Search Helicopter: A helicopter is spawned based on difficulty. It is initialized with lights on and set to loiter (for light helis) or patrol (for attack helis). If it is a transport or light helicopter, infantry is spawned and loaded into it.

Sqf

Apply
private _searchHeliClass = if (_difficulty) then {
    selectRandom ((_faction get "vehiclesHelisLightAttack") + (_faction get "vehiclesHelisAttack"))
} else {
    selectRandom ((_faction get "vehiclesHelisLight") + (_faction get "vehiclesHelisLightAttack"))
};
private _searchHeliData = [[(_positionX select 0) + random 100, (_positionX select 1) + random 100, 300 + random 500], 0, _searchHeliClass, _side] call A3A_fnc_spawnVehicle;
private _searchHeliVeh = _searchHeliData select 0;
private _heliVehicleGroup = _searchHeliData select 2;

private _pilot = driver _searchHeliVeh;
_pilot disableAI "LIGHTS";
_pilot action ["lightOn", _searchHeliVeh];
// ... (Spawn infantry if needed)
Task Creation: A task is created for teamPlayer and civilian sides. It includes the destination name and time limit. The task is synced to all clients.

Sqf

Apply
private _taskId = "RES" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [
        format [localize "STR_A3A_Missions_RES_Informer_task_desc", _faction get "name", _destinationName, _displayTime],
        localize "STR_A3A_Missions_RES_Informer_task_header",
        _markerX
    ],
    _positionX,
    false,
    0,
    true,
    "danger",
    true
] call BIS_fnc_taskCreate;
[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Wait for Player Proximity: The script halts execution until the player approaches the city (checked via spawner variable) or the time limit is reached.

Sqf

Apply
waitUntil {sleep 1;dateToNumber date > _dateLimitNum or {spawner getVariable _markerX != 2}};
Roadblock Placement: It calculates a random number of roadblocks (1-4) to block routes leading into the city. It selects random cardinal directions, finds nearby roads, and spawns a vehicle (APC or militia truck) and an infantry group.

Sqf

Apply
private _roadblockCount = ceil (random [1,2,4]);
// ... (Loop for roadblocks)
private _rawPosition = [_positionX, _size, _cardinalDirection] call BIS_fnc_relPos;
private _roads = _rawPosition nearRoads _radiusX;
// ... (Find safe road position)
private _roadblockVehicleData = [_roadblockPosition, 0, _typeVehX, _side] call A3A_fnc_spawnVehicle;
private _roadblockVeh = _roadblockVehicleData select 0;
Pursuer Spawning: A patrol group is created inside the city area to search for the player. A guard dog is added to the group.

Sqf

Apply
private _groupX = [_positionX,_side, _typeGroup] call A3A_fnc_spawnGroup;
[_groupX, "Patrol_Area", 25, 250, 100, false, _positionX, false] call A3A_fnc_patrolLoop;
private _dog = [_groupX, "Fin_random_F",_positionX,[],0,"FORM"] call A3A_fnc_createUnit;
Environmental Effects: Burning garbage piles are spawned randomly to add atmosphere.

Sqf

Apply
private _garbage = createVehicle [ (selectRandom _garbagePool), _garbagePosition, [], 0, "NONE"];
private _smokeEffect = "test_EmptyObjectForSmoke" createVehicle _garbagePosition; 
Detection and Extraction: The script waits for a rebel player to get within 40m of the informer. Once detected, the informer becomes vulnerable (allowDamage true), is uncaptured (setCaptive false), and a flare is fired overhead to mark the location for the player. All enemy groups are ordered to move to the informer's position.

Sqf

Apply
waitUntil {
    sleep 1;
    (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _informer < 40} != -1 || {!alive _informer || {dateToNumber date > _dateLimitNum}}
};

_informer allowDamage true;
[_informer,false] remoteExec ["setCaptive",0,_informer];

private _flare = createVehicle [selectRandom (_faction get "flares"), _flarePosition, [], 0, "CAN_COLLIDE"];
// ...
{
    private _wp = _x addWaypoint [_informer, 100];
    _wp setWaypointType "MOVE";
} forEach _groups;
Final Outcome Check: The script waits for the informer to die, reach the HQ (Synd_HQ marker), or time out.

Sqf

Apply
waitUntil {
    sleep 1;
    !alive _informer || {dateToNumber date > _dateLimitNum || {(_informer distance2D (getMarkerPos "Synd_HQ") < 25)}}
};
Cleanup: If the mission ends (success or fail), the script deletes the spawned entities (vehicles, groups, effects, props) and removes the markers after a delay.

Sqf

Apply
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
{
    deleteVehicle _x;
} forEach (_effects + _props + [_informer]);
Where it leads:

Calls: A3A_fnc_missionRequest (to restart mission on failure), A3A_fnc_spawnVehicle (heli/roadblocks), A3A_fnc_spawnGroup (enemies), A3A_fnc_taskCreate (mission UI), A3A_fnc_taskSetState (mission end), A3A_fnc_addScorePlayer (rewards), A3A_fnc_addAggression (war stats), A3A_fnc_vehDespawner (cleanup).
Global Variables: Modifies A3A_taskCount, A3U_dialogCivMissionInProgress.
Network: Uses remoteExec to set captivity states, update tasks, and apply rewards to specific players.
System Context: Part of the civilian mission system. It relies on the spawner system to detect player presence and handles complex AI setup for search and rescue scenarios.
Function Name: fn_RES_Prisoners.sqf
What it does: This function manages the "Rescue Prisoners" mission. The objective is to liberate unarmed prisoners (POWs) from a house within a mission area and escort them to the Rebel HQ respawn point. It spawns prisoners, sets a time limit, and handles the cleanup or reward distribution based on the outcome.

How it does that:

Setup and Difficulty: Checks for server-side execution. Determines difficulty and sets the time limit (45m for difficult, 120m for standard).

Sqf

Apply
params ["_markerX"];
if (!isServer and hasInterface) exitWith{};
private _difficultX = random 10 < tierWar;
private _positionX = getMarkerPos _markerX;
private _limit = if (_difficultX) then { 45 call SCRT_fnc_misc_getTimeLimit } else { 120 call SCRT_fnc_misc_getTimeLimit };
Finding a Suitable House: It searches for buildings near the marker, filtering out blacklisted building types. It prioritizes houses with multiple building positions. If none are found, it falls back to generating random positions on the ground.

Sqf

Apply
private _houses = (nearestObjects [_positionX, ["house"], 50]) select {!((typeOf _x) in A3A_buildingBlacklist)};
private _houseX = "";
private _potentials = [];
// ... (Loop to find houses with positions > 1)
if (count _potentials > 0) then {
    _houseX = selectRandom _potentials;
    _posHouse = [_houseX] call BIS_fnc_buildingPositions;
} else {
    // Fallback to random ground positions
};
Spawning Prisoners: Creates a group (teamPlayer) and spawns unarmed units. They are disabled (no move/attack), set as captive, and given prisoner actions. A3A_fnc_reDress is called to randomize their appearance.

Sqf

Apply
private _grpPOW = createGroup teamPlayer;
for "_i" from 0 to _countX do {
    private _unit = [_grpPOW, FactionGet(reb,"unitUnarmed"), (_posHouse select _i), [], 0, "NONE"] call A3A_fnc_createUnit;
    _unit allowDamage false;
    _unit setCaptive true;
    _unit disableAI "MOVE";
    [_unit,"prisonerX"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
    [_unit] call A3A_fnc_reDress;
};
sleep 5;
{_x allowDamage true} forEach _POWs;
Timer and Escape Logic: It waits for prisoners to die, reach the HQ, or for time to expire.

Time Out: If the timer expires and the spawner indicates the location is active (players nearby), the prisoners die. If inactive, they are released and run away to prevent permanent blocking of the marker.
Sqf

Apply
if (dateToNumber date > _dateLimitNum) then {
    if (spawner getVariable _markerX == 2) then {
        { if (group _x == _grpPOW) then { _x setDamage 1; }; } forEach _POWS;
    } else {
        { if (group _x == _grpPOW) then { _x setCaptive false; _x enableAI "MOVE"; _x doMove _positionX; }; } forEach _POWS;
    };
};
Success/Failure and Rewards: If prisoners die: Task fails, player loses score. If prisoners reach HQ: Task succeeds. Rewards are calculated based on survivors. Resources (HR and Money) are added to the FIA. Intel is generated.

Sqf

Apply
if ({alive _x} count _POWs == 0) then {
    [_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
    [-10*_bonus,theBoss] call A3A_fnc_addScorePlayer;
} else {
    [_taskId, "RES", "SUCCEEDED"] call A3A_fnc_taskSetState;
    _countX = {(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 150)} count _POWs;
    _hr = 2 * (_countX);
    _resourcesFIA = 100 * _countX*_bonus;
    [_hr,_resourcesFIA] remoteExec ["A3A_fnc_resourcesFIA",2];
};
Loot Collection: After the mission ends, prisoners are deleted. Any weapons or items they might have acquired are moved to the rebel HQ box (boxX).

Sqf

Apply
{
    private _unit = _x;
    if (_unit distance getMarkerPos respawnTeamPlayer < 150) then {
        // ... (Transfer gear to arrays)
    };
    deleteVehicle _unit;
} forEach _POWs;
{boxX addWeaponCargoGlobal [_x,1]} forEach _weaponsX;
Where it leads:

Calls: A3A_fnc_missionRequest, A3A_fnc_createUnit, A3A_fnc_flagaction, A3A_fnc_reDress, A3A_fnc_taskCreate, A3A_fnc_taskSetState, A3A_fnc_resourcesFIA, A3A_fnc_addScorePlayer, A3A_fnc_addAggression.
Global Variables: Modifies boxX (adds loot), A3U_dialogCivMissionInProgress.
Network: Uses remoteExec for actions on units and resource updates.
System Context: Standard recovery mission. Notable for its escape logic where prisoners flee if the timer expires and players are too far away (spawner = 0), preventing gameplay soft-locking.
Function Name: fn_RES_Refugees.sqf
What it does: This function manages the "Rescue Refugees" mission. It is similar to the Prisoner mission but tailored for refugees. Key differences include a branching narrative based on the enemy faction (Occupants vs. Invaders), distinct spawn points (inside houses for Occupants, on ground for Invaders), and the potential for an enemy QRF (Quick Reaction Force) or police patrol.

How it does that:

Setup and Environment: Initializes difficulty, marker position, and the specific building for refugees. It calculates a time limit (30m difficult, 60m standard).

Sqf

Apply
params ["_markerX"];
private _difficultX = random 10 < tierWar;
private _positionX = getMarkerPos _markerX;
private _radiusX = [_markerX] call A3A_fnc_sizeMarker;
private _houses = (nearestObjects [_positionX, ["house"], _radiusX]) select {!((typeOf _x) in A3A_buildingBlacklist)};
Determining Narrative and Spawn: It checks sidesX to see if the area is Occupied or Invaded.

Occupants: Text describes "liberating" refugees. Spawn location is the interior of a house. The refugees are flagged as captives initially.
Invaders: Text describes "evacuating" civilians. Spawn location is outside the house (position _houseX). No initial captive status.
Sqf

Apply
private _sideX = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
// ... (Text assignment based on _sideX)

if (_sideX == Occupants) then {
    _posTsk = (position _houseX) getPos [random 100, random 360];
} else {
    _posTsk = position _houseX;
};
Spawning Refugees: Spawns unarmed units (up to 6). Sets them to non-combat behavior.

Sqf

Apply
_groupPOW = createGroup teamPlayer;
for "_i" from 1 to (((count _posHouse) - 1) min 6) do {
    _unit = [_groupPOW, FactionGet(reb,"unitUnarmed"), _posHouse select _i, [], 0, "NONE"] call A3A_fnc_createUnit;
    _unit setCaptive true; // Only if Occupants (logic inside)
    [_unit,"refugee"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
};
Enemy Spawn Logic: The enemy reaction depends on the controlling faction.

Invaders: A delayed script is spawned. Depending on difficulty, it calls a support module (A3A_fnc_createSupport) to spawn a QRF at the house location after a set time.

Occupants (Police/Faction): Spawns a patrol group and a vehicle immediately. The vehicle is parked on a nearby road. A police unit is also spawned inside the house exit.

Sqf

Apply
// Invaders Logic
[_houseX, _difficultX] spawn {
    // ... (Sleep delay)
    private _reveal = [_positionX , Invaders] call A3A_fnc_calculateSupportCallReveal;
    [getPos _house, 4, ["QRF"], Invaders, _reveal] remoteExec ["A3A_fnc_createSupport", 2];
};

// Occupants Logic
private _veh = (selectRandom (_faction get "vehiclesPolice")) createVehicle _posVeh;
_groupX = [getPos _houseX, Occupants, _faction get "groupPoliceSquad"] call A3A_fnc_spawnGroup;
_groupX1 = [_houseX buildingExit 0, Occupants, _faction get "groupPolice"] call A3A_fnc_spawnGroup;
Mission End Logic: It waits for refugees to die or reach the HQ.

Occupants: Checks against a time limit. If time expires, refugees are killed if players are nearby, or released (flee) if not.
Invaders: No time limit check in the main wait loop (implies indefinite until death/rescue).
Sqf

Apply
// Occupants Wait Loop
waitUntil {sleep 1; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 50)} count _POWs > 0) or (dateToNumber date > _dateLimitNum)};
Cleanup: Deletes refugees and transfers loot to boxX. If Occupants, the spawned police vehicle and groups are despawned.

Sqf

Apply
if (_sideX == Occupants) then {
    if (!isNull _veh) then { [_veh] spawn A3A_fnc_vehDespawner };
    if (!isNull _groupX1) then { [_groupX1] spawn A3A_fnc_groupDespawner };
    [_groupX] spawn A3A_fnc_groupDespawner;
};
Where it leads:

Calls: A3A_fnc_sizeMarker, A3A_fnc_createSupport (Invaders QRF), A3A_fnc_spawnGroup, A3A_fnc_patrolLoop, A3A_fnc_flagaction, A3A_fnc_taskCreate, A3A_fnc_resourcesFIA, A3A_fnc_vehDespawner, A3A_fnc_groupDespawner.
Global Variables: Modifies boxX, A3U_dialogCivMissionInProgress.
Network: Heavy use of remoteExec for flag actions, support calls, and resource updates.
System Context: A dynamic mission that changes enemy behavior and spawn logic based on the controlling faction. It integrates tightly with the Support system (for Invaders QRF).

Function: fn_RES_Shipwreck.sqf
What it does: This function implements the "Rescue the Smugglers" mission. It generates a shipwreck scenario where civilian smugglers are stranded near a shoreline, guarded by enemy forces. The player's objective is to locate the survivors and escort them back to the HQ (the mission marker). The function handles the generation of the shipwreck scene, the spawning of enemy patrols and a boat, the creation of the survivor units, and the dynamic event of the ship potentially sinking. It also manages the task lifecycle, victory/defeat conditions, and the cleanup of spawned assets.

How it does that:

1. Initialization and Parameter Validation The function begins by defining the marker for the mission location and initializing arrays to track spawned entities (vehicles, groups, props). It determines the enemy side based on the marker's current ownership.

Sqf

Apply
params ["_markerX"];
private _effects = [];
private _POWs = [];
private _vehicles = [];
private _groups = [];
private _props = [];

private _sideX = if (sidesX getVariable [_markerX, sideUnknown] == Occupants) then {Occupants} else {Invaders};
private _faction = Faction(_sideX);
private _difficultX = random 10 < tierWar;
private _positionX = getMarkerPos _markerX;
Logic: Extracts the marker position. Checks the sidesX global variable to determine if the marker is held by Occupants or Invaders. Calculates difficulty based on the global tierWar variable.
2. Mission Position Generation The function attempts to find a suitable shoreline position within a radius of the main mission marker. If no valid shore position is found, the function terminates and requests a new mission of the same type.

Sqf

Apply
private _shorePosition = [
    _positionX, 0, 1500, 0, 0, 1, 1, [], [[0,0,0], [0,0,0]]
] call BIS_fnc_findSafePos;

if (_shorePosition isEqualTo [0,0,0]) exitWith {
    Error("Problems with shore position, rerequesting new rescue mission.");
    ["RES"] remoteExec ["A3A_fnc_missionRequest",2];
};
Logic: Uses BIS_fnc_findSafePos with water mode 0 (land only) and shore mode 1 (must be near water). Checks the result against [0,0,0], which indicates failure. If failed, it remotely executes A3A_fnc_missionRequest to try again.
3. Ship Placement and Validation It calculates a position in the water for the wrecked ship. It creates a dummy vehicle to test the location and iteratively adjusts the radius if the initial spot is invalid (out of bounds or on land).

Sqf

Apply
private _shipPosition = [
    _shorePosition, 100, 500, 0, 2, 1, 0, [], [[0,0,0], [0,0,0]]
] call BIS_fnc_findSafePos;
private _ship = "C_Boat_Civil_04_F" createVehicle _shipPosition;

if (!(surfaceIsWater _shipPosition) || {_outOfBounds}) then {
    private _iterations = 0;
    private _radiusX = 250;
    while {_iterations < 50} do {
        // ... find new position ...
        _radiusX = _radiusX + 100;
        _iterations = _iterations + 1;
    };
};
Logic: Finds a position 100-500m from shore on water. If the surface isn't water or is out of world bounds, it loops up to 50 times, increasing the search radius by 100m each time.
4. Scene Construction The ship is oriented toward the shore with a random rotation. A fire effect is attached to the ship to simulate burning wreckage.

Sqf

Apply
_ship setDir (([_ship, _shorePosition] call BIS_fnc_dirTo) + random 90);
private _fire = createVehicle ["test_EmptyObjectForFireBig", position _ship, [], 0 , "CAN_COLLIDE"];
_fire attachTo [_ship, [0, 5, 3]];
_effects pushBack _fire;
Logic: Calculates the direction from ship to shore and adds a random offset. Creates a fire object and attaches it relative to the ship's model space.
5. Task Creation A task is created for the players. The time limit is determined by difficulty. The task text references the local marker name and the display time.

Sqf

Apply
private _limit = if (_difficultX) then {60 call SCRT_fnc_misc_getTimeLimit} else {90 call SCRT_fnc_misc_getTimeLimit};
_limit params ["_dateLimitNum", "_displayTime"];
private _taskId = "RES" + str A3A_taskCount;

[
    [teamPlayer,civilian], _taskId,
    [format [localize "STR_A3A_Missions_RES_Shipwreck_task_desc", _nameDest, _displayTime], localize "STR_A3A_Missions_RES_Shipwreck_task_header", _markerX],
    _shorePosition, false, 0, true, "boat", true
] call BIS_fnc_taskCreate;
[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Logic: Calls SCRT_fnc_misc_getTimeLimit to get a timestamp and formatted string. Creates a task with the "boat" task type. Updates the task state to CREATED on all clients.
6. Survivor (POW) Spawn A group is created for the survivors. A random number of units (3-6) are spawned at the shore position. They are disabled, unarmed, and set as captives to prevent them from moving or fighting.

Sqf

Apply
private _grpPOW = createGroup teamPlayer;
private _smugglerCount = random [3, 5, 6];

for "_i" from 0 to _smugglerCount do {
    private _unit = [_grpPOW, FactionGet(reb,"unitUnarmed"), _shorePosition, [], 0, "NONE"] call A3A_fnc_createUnit;
    _unit allowDamage false;
    _unit setCaptive true;
    _unit disableAI "MOVE";
    // ... other disablement commands ...
    removeAllWeapons _unit;
    _POW pushBack _unit;
    [_unit,"prisonerX"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
};
{ _x allowDamage true; } forEach _POWS;
Logic: Iterates to create units using A3A_fnc_createUnit. Applies identity settings. Sets allowDamage false initially to prevent premature death during placement. Removes weapons. Finally re-enables damage. Adds a flag action via remote execution to allow interaction.
7. Enemy Force Spawning Spawns an enemy boat, two infantry patrol groups, a commanding officer, and a transport truck. The difficulty determines the size of the infantry squads.

Sqf

Apply
private _boatClass = selectRandom (_faction get "vehiclesGunBoats");
private _officerClass = _faction get "unitOfficial";
// ... selecting infantry squad ...

private _boatData = [_searchBoatPosition, 0, _boatClass, _sideX] call A3A_fnc_spawnVehicle;
_boatVeh = _boatData select 0;
[_boatVeh, _sideX] call A3A_fnc_AIVEHinit;

[_boatGroup, _shipPosition, 250] call bis_fnc_taskPatrol;
Logic: Fetches vehicle/unit classes from the faction config. Spawns the boat and initializes it via A3A_fnc_AIVEHinit. Spawns two infantry groups and assigns them a patrol loop around the shore using bis_fnc_taskPatrol.
8. Dynamic Sinking Event A check is performed to see if the ship should sink. If triggered, a bomb is created under the ship, followed by a delay before the ship starts a sinking animation (tilting and submerging).

Sqf

Apply
if(random 100 < 50) then {
    [_ship, _fire] spawn {
        params ["_burningShip", "_fireEffect"];
        private _time = time + 15;
        waitUntil {sleep 1; time > _time};
        private _shell = "R_230mm_HE" createVehicle position _burningShip;
        _shell setVelocity [0,1,-1];
        sleep 3;
        [_burningShip, "LEFT", 90] spawn SCRT_fnc_common_sinkShip;
    };
};
Logic: 50% chance to trigger. Spawns a separate thread. Waits 15 seconds, creates a "shell" explosion (simulating gas explosion), and calls SCRT_fnc_common_sinkShip to handle the visual physics of sinking.
9. Victory/Defeat Conditions The function waits for specific conditions: all survivors dead, or survivors reaching the HQ, or time expiration.

Time Expiration: If players are nearby, survivors are released (aggressive). If not, they are executed.
Success: Survivors reach HQ. Resources and reputation are awarded.
Sqf

Apply
waitUntil {
    sleep 1; 
    ({alive _x} count _POWs == 0) or 
    ({(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 50)} count _POWs > 0) or 
    (dateToNumber date > _dateLimitNum)
};

if ({alive _x} count _POWs == 0) then {
    [_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
    // ... penalty logic ...
} else {
    [_taskId, "RES", "SUCCEEDED"] call A3A_fnc_taskSetState;
    // ... reward logic (resources, money, score) ...
    private _ammoBox = (_faction get "ammobox") createVehicle (getMarkerPos "Synd_HQ");
    [_ammoBox] spawn A3A_fnc_fillLootCrate;
};
Logic: Uses waitUntil to poll status. Calculates reward multipliers based on difficulty and number of survivors. Spawns a loot crate at HQ on success.
10. Cleanup After a delay, the mission cleans up units, groups, vehicles, and markers. Loot remaining on survivor bodies is moved to the global box.

Sqf

Apply
sleep 60;
// ... iterate _POWs to collect gear into arrays ...
{
    boxX addWeaponCargoGlobal [_x,1]
} forEach _weaponsX;

[_taskId, "RES", 1200] spawn A3A_fnc_taskDelete;
{ deleteVehicle _x; } forEach _effects + _props;
deleteMarker _shoreMarker;
Logic: Collects unlocked weapons/mags from survivors' bodies and adds them to boxX. Deletes the task, visuals, and markers. Calls vehicle/group despawner functions for AI assets.
Where it leads:

Called Functions:
A3A_fnc_missionRequest: Called on failure to reroll the mission.
BIS_fnc_findSafePos: Used multiple times for position finding.
A3A_fnc_createUnit: Spawns the survivors.
A3A_fnc_setIdentity: Applies random faces/voices to survivors.
A3A_fnc_flagaction: Adds interaction options to survivors.
A3A_fnc_reDress: Applies uniforms to survivors.
A3A_fnc_spawnVehicle: Spawns enemy boat and truck.
A3A_fnc_AIVEHinit: Initializes AI vehicle behavior.
A3A_fnc_spawnGroup: Spawns infantry groups.
A3A_fnc_NATOinit: Initializes AI units.
SCRT_fnc_common_sinkShip: Handles the ship sinking physics.
A3A_fnc_taskCreate/Update/SetState: Manages the UI task.
A3A_fnc_resourcesFIA: Updates money and HR.
A3A_fnc_addScorePlayer: Updates player scores.
A3A_fnc_addMoneyPlayer: Adds money to individual players.
A3A_fnc_fillLootCrate: Generates the reward crate contents.
A3A_fnc_vehDespawner: Cleans up vehicles.
A3A_fnc_groupDespawner: Cleans up groups.
A3A_fnc_taskDelete: Removes the task after delay.
Dependencies: Depends on the global Faction loader to fetch unit classnames. Relies on SCRT_fnc_misc_getRebelPlayers to find active players.
System Fit: This is a standard "RES" (Rescue) type mission. It integrates with the mission request system (missionRequest) and the global resource management system (resourcesFIA).
Global Variables: Modifies A3A_taskCount, server variables (via resourcesFIA), and updates boxX (global arsenal).
Network Implications: Heavily uses remoteExec and remoteExecCall to update tasks, spawn objects, and apply flags to units for all connected clients. The cleanup phase happens server-side.
Function: fn_RIV_AS_Traitor.sqf
What it does: This function implements the Rivals mission "Eliminate the Traitor". It spawns a high-value target (a defector) inside a house within a specific marker zone, along with bodyguards. It also spawns additional dynamic enemy patrols (ground and possibly vehicular) that are initially passive. The objective is to kill the traitor before they escape or the time limit expires. The mission features a "laptop" mechanic where the traitor drops intel upon death.

How it does that:

1. Initialization and Difficulty Setup The function initializes the mission parameters, checking for Rivals activity probability. It sets a time limit and identifies the specific marker location.

Sqf

Apply
params ["_markerX"];
private _faction = A3A_faction_riv;
private _isDifficult = random 10 < tierWar && {[] call SCRT_fnc_rivals_rollProbability};
private _positionX = getMarkerPos _markerX;

private _limit = if (_isDifficult) then {45 call SCRT_fnc_misc_getTimeLimit} else {60 call SCRT_fnc_misc_getTimeLimit};
_limit params ["_dateLimitNum", "_displayTime"];
Logic: Extracts the marker. Checks tierWar and a dedicated probability function for Rivals to determine difficulty. Calculates the time limit based on this difficulty.
2. House Selection and Positioning The function finds a house within the marker's radius and calculates specific building positions for the traitor and his guards. It ensures there are enough positions inside the house.

Sqf

Apply
private _radiusX = [_markerX] call A3A_fnc_sizeMarker;
private _houses = (nearestObjects [_positionX, [" house"], _radiusX]) select {!((typeOf _x) in A3A_buildingBlacklist)};
private _posHouse = [];
private _houseX = _houses select 0;
while {count _posHouse < 3} do {
    _houseX = selectRandom _houses;
    _posHouse = _houseX buildingPos -1;
    // ... filter houses ...
};

private _max = (count _posHouse) - 1;
private _rnd = floor random _max;
private _posTraitor = _posHouse select _rnd;
private _posSol1 = _posHouse select (_rnd + 1);
private _posSol2 = (_houseX buildingExit 0);
Logic: Uses nearestObjects to find houses, filtering out blacklisted types. Uses a loop to find a house with at least 3 internal positions. Randomly selects distinct positions for the traitor, one guard inside, and a guard at the exit.
3. Traitor and Bodyguard Spawning Spawns the traitor (using the Rivals faction unit commander) and two bodyguards. The traitor is initially invulnerable to prevent instant mission failure upon spawning. An event handler is attached to the traitor to spawn a laptop upon death.

Sqf

Apply
private _groupTraitor = createGroup Invaders;
private _traitor = [_groupTraitor, _faction get "unitCommander", _posTraitor, [], 0, "NONE"] call A3A_fnc_RivalsCreateUnit;
_traitor allowDamage false;
_traitor setVariable ["hasLaptop", true, true];
_traitor addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    [_unit] call SCRT_fnc_rivals_createLaptop;
    _unit setVariable ["hasLaptopSpawned", true, true];
}];
Logic: Spawns the unit using A3A_fnc_RivalsCreateUnit. Sets allowDamage false. Attaches a Killed event handler that calls SCRT_fnc_rivals_createLaptop to create a laptop object at the death position.
4. Patrol Spawning (Reinforcements) If the time limit hasn't expired and the traitor is alive when players enter the area, additional "patrol" groups are spawned. These are initially set to be invulnerable, captive, and have AI disabled to prevent them from engaging immediately (ambush setup).

Sqf

Apply
if (dateToNumber date < _dateLimitNum && alive _traitor) then {
    private _patrolCount = nil;
    // ... determine count based on difficulty ...

    for "_i" from 0 to _patrolCount do {
        private _patrolGroup = [_positionX, Rivals, (selectRandom _patrolPool)] call A3A_fnc_RivalsSpawnGroup;
        (units _patrolGroup) apply {
            private _unit = _x;
            {_unit disableAI _x} forEach ["CHECKVISIBLE", "COVER", "SUPPRESSION", "FSM", "TARGET", "AUTOTARGET"];
            _unit allowDamage false;
            _unit setCaptive true;
        };
        _groups pushBack _patrolGroup;
    };

    // ... vehicle patrol logic if difficult ...
};
Logic: Spawns Rivals groups. Disables multiple AI behaviors to make them "wait". Sets allowDamage false and setCaptive true to make them invisible to the game engine (invulnerable and ignored by AI).
5. Mission Trigger and Activation The function waits for players to enter the area. Once triggered, it iterates through the spawned patrol groups to "activate" them: enabling damage, removing captivity, and re-enabling AI.

Sqf

Apply
waitUntil {sleep 1; ... players in area ...};

{
    private _group = _x;
    (units _group) apply {
        private _unit = _x;
        {_unit enableAI _x} forEach ["CHECKVISIBLE", "MOVE", "COVER", "SUPPRESSION", "FSM", "TARGET", "AUTOTARGET", "ANIM"];
        _unit allowDamage true;
        _unit setCaptive false;
    };
} forEach _patrolGroups;
Logic: The wait condition checks for rebel players in the spawn radius. Once true, it loops through the hidden patrol groups and reverses the disabling actions, making them active enemies.
6. Success/Failure Conditions The mission waits for the traitor to die or the time to expire.

Success: If the traitor dies. Rewards are given (Rivals activity reduction, money, score).
Failure: If the traitor escapes or the timer runs out. Penalties are applied (loss of resources).
Sqf

Apply
waitUntil {sleep 1; dateToNumber date > _dateLimitNum || {!alive _traitor}};

if (!alive _traitor) then {
    [_taskId, "AS", "SUCCEEDED", true] call A3A_fnc_taskSetState;
    // ... reward logic (reduce rivals activity, add money/score) ...
} else {
    [_taskId, "AS", "FAILED", true] call A3A_fnc_taskSetState;
    // ... penalty logic (reduce resourcesFIA) ...
};
Logic: Checks death status or time. Calls A3A_fnc_taskSetState accordingly. On success, it calls SCRT_fnc_rivals_reduceActivity to lower the threat level. On failure, it reduces server resources.
7. Cleanup After a delay, the mission deletes spawned entities (units, vehicles, groups) and the task itself.

Sqf

Apply
sleep 30;
[_taskId, "AS", 1200, true] spawn A3A_fnc_taskDelete;
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Logic: Waits 30 seconds post-mission end, then deletes the task and triggers the despawners for cleanup.
Where it leads:

Called Functions:
SCRT_fnc_rivals_rollProbability: Checks if Rivals spawn chance is met.
A3A_fnc_sizeMarker: Gets the radius of the target area.
A3A_fnc_localizar: Localizes the marker name for the task description.
A3A_fnc_RivalsCreateUnit: Spawns the traitor and guards.
SCRT_fnc_rivals_createLaptop: Called on traitor death to spawn the intel laptop.
A3A_fnc_RivalsSpawnGroup: Spawns the hidden patrols.
A3A_fnc_RivalsSpawnVehicle: Spawns a vehicle patrol if on hard difficulty.
A3A_fnc_AIVEHinit: Initializes the patrol vehicle.
A3A_fnc_taskCreate/Update/SetState: Manages UI.
SCRT_fnc_rivals_reduceActivity: Lowers the global Rivals aggression level.
SCRT_fnc_rivals_addProgressToRivalsLocationReveal: Adds progress towards unlocking Rivals locations.
A3A_fnc_resourcesFIA: Updates server resources.
A3A_fnc_addMoneyPlayer/ScorePlayer: Awards players.
A3A_fnc_vehDespawner/GroupDespawner: Cleans up.
A3A_fnc_taskDelete: Removes task.
Dependencies: Heavily dependent on the Rivals faction configuration (A3A_faction_riv) and the Rivals sub-system (SCRT_fnc_rivals_*).
System Fit: This is an "AS" (Assassination) mission variant specific to the Rivals mechanic. It directly impacts the Rivals global activity counter.
Global Variables: Modifies A3A_taskCount, server resources via resourcesFIA, and Rivals activity variables (internal to the Rivals system).
Network Implications: Uses remoteExec for rewards and task updates. The laptop spawn is handled locally via the event handler but relies on the server for the item logic (if applicable). The patrol activation affects all clients in the area.

RIV_ATT_Cell
Function Name: fn_RIV_ATT_Cell.sqf
File: A3A/addons/core/functions/Missions/fn_RIV_ATT_Cell.sqf

What it does:
This function orchestrates a "Kill Cell Leader" mission for the Rivals faction (denoted by the "RIV" prefix). It spawns a dynamic combat encounter centered around an enemy cell leader who must be assassinated within a time-limited window. The function handles all aspects of the mission: area generation, enemy unit and vehicle spawning, environmental effects, AI behavior, task management, and cleanup.

When/Why it's called: This function is triggered by the mission system when a player requests a "Rivals Attacking" mission or when the mission scheduler generates one. It is called from A3A_fnc_missionRequest or similar mission controller functions. The mission is designed to be a high-value, high-difficulty assassination operation against Rivals leadership.

How it does that:
1. Initialization and Parameter Validation
Step: Validate parameters and check server conditions.

Sqf

Apply
params ["_marker"];
if (!isServer and hasInterface) exitWith {};
Purpose: Extracts the marker parameter and ensures execution only runs on the server (not on client machines with interface). This prevents mission logic from running on dedicated client players.
Context: The _marker is a location marker string (e.g., "cityMarker12") defining the mission area.
2. Helper Function Definition
Step: Define a local function to create dynamic lighting.

Sqf

Apply
private _fnc_createLight = {
    params [["_position", []]];
    if (_position isEqualTo []) exitWith {};

    private _light = createVehicle ["#lightpoint", _position, [], 0 , "CAN_COLLIDE"];
    [_light, 8.4] remoteExecCall ["setLightBrightness", 0, _light];
    [_light, [0.3, 0.1, 0.05]] remoteExecCall ["setLightAmbient", 0, _light];
    [_light, [0.3, 0.1, 0.05]] remoteExecCall ["setLightColor", 0, _light];

    _light
};
Purpose: Creates a light point object at a given position and broadcasts light properties to all clients. Used for fire and explosion effects.
Implementation: Uses #lightpoint special object, sets brightness (8.4), ambient color (warm orange), and color (warm orange). This creates a localized, atmospheric light source for burning buildings/vehicles.
3. Mission Setup and Timing
Step: Get time limit and generate mission parameters.

Sqf

Apply
(90 call SCRT_fnc_misc_getTimeLimit) params ["_dateLimitNum", "_displayTime"];
private _isDifficult = random 10 < tierWar && ([] call SCRT_fnc_rivals_rollProbability);
Purpose: Sets a 90-minute (real-time) deadline for mission completion. Calculates difficulty based on current war tier and a random probability roll.
Details: _dateLimitNum is a numeric date/time limit; _displayTime is a human-readable string. tierWar is a global variable indicating conflict escalation level. Rivals probability function adds variability.
4. City Size Calculation
Step: Dynamically size the mission area based on urban density.

Sqf

Apply
private _cities = ["NameCityCapital","NameCity"] call SCRT_fnc_misc_getWorldPlaces;
private _isCity  = _cities findIf {(_x select 1) distance2D _positionX <= 250} == 0;
private _size = 200;
private _searchIterations = 0;

// ...loop to increase size until it finds border buildings...
Purpose: Determines if the marker is in a city (vs rural) and calculates the optimal mission radius (200-500m) by checking for buildings at the area edge.
Logic: Creates two temporary marker ellipses (inner/outer) to test building placement. Iteratively expands the radius (20m steps) until it either finds buildings on the border or hits a max size limit (500m for cities, 275m for rural).
5. Environmental Effects (Damaged Buildings & Fire)
Step: Randomly damage buildings and add fire/fx for atmosphere.

Sqf

Apply
private _damagedBuildings = (nearestObjects [_positionX, ["house"], _size]) select {(count ([_x] call BIS_fnc_buildingPositions)) > 0};
private _damagedBuildingsCount = round (random [1,2,3]);

if (count _damagedBuildings > 0) then {
    for "_i" from 0 to _damagedBuildingsCount do {
        private _damagedBuilding = selectRandom _damagedBuildings;
        _damagedBuilding setDamage ((random 0.5)+0.4);
        // ... calculates roof height and places fire effect ...
        private _fire = createVehicle ["test_EmptyObjectForFireBig", _damagedBuildingPos, [], 0 , "CAN_COLLIDE"];
        private _light = [(position _fire)] call _fnc_createLight;
        _effects append [_light, _fire];
    };
};
Purpose: Adds realism by creating pre-damaged, burning buildings in the area.
Implementation: Selects 1-3 random houses, sets damage to 0.4-0.9, calculates the true roof height using lineIntersectsSurfaces to place fire objects accurately, and creates the corresponding light. Also opens doors on the building.
6. Target Position and Bodyguards
Step: Select the target building and initialize the cell leader group.

Sqf

Apply
private _buildings = _positionX nearobjects ["house",_size];
private _capableBuildings = _buildings select {count ([_x] call BIS_fnc_buildingPositions) > 1 && {!(isObjectHidden _x)}};
private _targetBuilding = selectRandom _capableBuildings;
private _targetGroup = createGroup Rivals;
// ... spawns target and guards inside building ...
Purpose: Finds a suitable multi-story building for the cell leader to hide in. Creates the target group and spawns the leader (commander unit) and optional guards (if mission is difficult) inside the building.
Implementation: Filters buildings with multiple internal positions. Selects random floor position for the leader. If difficult, spawns 1-4 additional guards with randomized loadouts (Mercenary, Partisan, etc.) in other building positions.
7. Task Creation and Wait for Player Presence
Step: Create the mission task and wait for rebel players to enter the area.

Sqf

Apply
private _taskId = "RIV_ATT" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [format [localize "STR_RIV_ATT_cell_text", ...], ...],
    _targetPos,
    false, 0, true, "kill", true
] call BIS_fnc_taskCreate;
[_taskId, "RIV_ATT", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

waitUntil {sleep 1; (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_targetPos, distanceSPWN1, distanceSPWN1] isNotEqualTo [] || {dateToNumber date > _dateLimitNum}};
Purpose: Creates an Arma 3 task for players. The mission pauses until rebels enter the spawn radius (distanceSPWN1) or time expires.
Task Details: Localized text with faction name, location, and time. Task type is "kill". Coordinates are the target building position. Remotely updates all players (2 = all clients) to "CREATED" state.
8. Pre-Combat AI Behavior (Incapacitated Enemies)
Step: Set all spawned enemies to a passive, waiting state.

Sqf

Apply
(units _targetGroup) apply {
    private _unit = _x;
    {_unit disableAI _x} forEach ["CHECKVISIBLE", "MOVE", "COVER", "SUPPRESSION", "FSM", "TARGET", "AUTOTARGET", "ANIM"];
    _unit setUnitPos "UP";
    _unit allowDamage false;
    _unit setCaptive true;
    [_unit] call A3A_fnc_NATOinit;
};
Purpose: Prevents enemies from reacting to players until combat is triggered. They are invisible to AI, cannot move, shoot, or be damaged, and are marked as captives (friendly to AI).
Implementation: Uses disableAI on multiple subsystems to fully disable unit AI. NATOinit runs standard initialization (skills, traits).
9. Barricades & Physical Obstacles
Step: Place barricades on roads leading to the area.

Sqf

Apply
private _cardinalDirections = [0,90,180,270];
for "_i" from 0 to (count _cardinalDirections) - 1 do {
    private _rawPosition = [_positionX, _size, _cardinalDirection] call BIS_fnc_relPos;
    // ... finds nearest road, creates barricade type and a "can opener" vehicle ...
    private _barricade = createVehicle [_barricadeType, _barricadePos, [], 0 , "CAN_COLLIDE"];
    _props append [_canOpener, _barricade];
};
Purpose: Adds tactical depth by blocking roads with static objects (wood piles, barricades) to funnel players and create choke points.
Implementation: For each cardinal direction (N/E/S/W), finds a road within expanding radius. Creates a random barricade object and a hidden Land_CanOpener_F vehicle (used as a collision workaround to prevent AI from ramming barricades).
10. Wreckages and Fires
Step: Spawn vehicle wrecks and additional fire/fx in the area.

Sqf

Apply
private _wreckCount = round (random [1,1,2]);
for "_i" from 0 to _wreckCount do {
    private _position = [_positionX, 0, _size, 5, 0, 0, 0, [], [_positionX, _positionX]] call BIS_fnc_findSafePos;
    private _class = selectRandom _wreckPool;
    private _wreck = createVehicle [_class, _position, [], 0 , "NONE"];
    // ... adds smoke/fire depending on wreck type ...
};
Purpose: Enhances visual narrative of a firefight or ambush site.
Implementation: Uses BIS_fnc_findSafePos to place wrecks safely. Creates smoke for tires, fire with light for burnt wrecks. Adds to _effects and _vehicles arrays for cleanup.
11. Enemy Patrols & Sentries
Step: Spawn roaming patrols and a sentry group (if difficult).

Sqf

Apply
if (_isDifficult) then {
    _patrolCount = 1;
    _patrolPool = A3A_faction_riv get "groupsSquad";
} else {
    _patrolCount = 2;
    _patrolPool = A3A_faction_riv get "groupsFireteam";
};

for "_i" from 0 to _patrolCount do {
    private _position = [/* safe position */];
    private _patrolGroup = [_position, Rivals, (selectRandom _patrolPool)] call A3A_fnc_RivalsSpawnGroup;
    // ... disable AI temporarily, then start patrol loop ...
    [_patrolGroup, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;
};
Purpose: Adds roaming enemy patrols to increase combat challenge and area control.
Implementation: Spawns Rivals squad (hard) or fireteam (easy) groups from faction data. Uses patrolLoop for dynamic movement. For difficult missions, an additional "sentry" group is placed near the target building for point defense.
12. Patrol Vehicle
Step: Spawn an armored vehicle for mobile patrols.

Sqf

Apply
private _vehicleClass = if (_isDifficult) then {
    selectRandom ((A3A_faction_riv get "vehiclesRivalsLightArmed") + ...);
} else {
    selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed");
};
// ... finds safe position, spawns vehicle with crew ...
private _patrolVehicleData = [_vehiclePosAndDir select 0, 0, _vehicleClass, Rivals] call A3A_fnc_RivalsSpawnVehicle;
// ... disabled AI temporarily, then sets patrol ...
Purpose: Introduces a vehicle threat to challenge players and add dynamic combat.
Difficulty Scaling: Hard difficulty includes APCs/Tanks; easy only includes light armed vehicles.
AI: Crew and vehicle are initially incapacitated, then set to patrol the area after combat starts.
13. Loot Container & Truck
Step: Place a cache (ammobox) with additional props and a supply truck.

Sqf

Apply
// ... finds safe position for loot, avoids roads ...
private _cacheType = A3A_faction_riv get "ammobox";
private _lootContainer = createVehicle [_cacheType, _lootContainerPosition, [], 0 , "CAN_COLLIDE"];
// ... fills crate with loot, adds actions, spawns truck ...
private _camoNet = createVehicle ["CamoNet_BLUFOR_F", _lootContainerPosition, [], 0 , "CAN_COLLIDE"];
_vehicles append [_camoNet, _truck, _lootContainer];
Purpose: Provides player incentive (loot) and adds mission storytelling (enemy supply cache).
Implementation: Creates a fake "Land_PaperBox_closed_F" first to find empty position, then deletes it and spawns the real ammobox. Fills it via A3A_fnc_fillLootCrate. Attaches a camo net and spawns a truck nearby for visual context.
14. Mission Trigger & State Transition
Step: Wait for players or target death, then enable combat.

Sqf

Apply
waitUntil {
    sleep 2;
    (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_positionX, distanceSPWN, distanceSPWN] isNotEqualTo []
    || {!alive _target
    || {dateToNumber date > _dateLimitNum
}}};
Purpose: Determines mission trigger condition. Mission activates when rebels enter the area, target dies prematurely, or time expires.
Transition: When triggered, it enables all enemy AI (damage, movement, AI skills) and removes "captive" status. This starts the combat phase.
15. Combat Phase Mechanics
Step: Enable AI, remove captives, spawn random events, and handle BLUFOR removal.

Sqf

Apply
// Enable all AI
{ private _group = _x; (units _group) apply { ... enableAI ... }; } forEach _groups;

// Spawn random events (car demos, UAV, mortar)
for "_i" from 0 to _carCount do { [_positionX, _size, 101] spawn SCRT_fnc_rivals_encounter_carDemo; };

// Randomly kill some BLUFOR units for "cleaner" battlefield
if (sidesX getVariable [_marker, sideUnknown] == Occupants) then {
    private _units = allUnits select { side _x isEqualTo Occupants ... };
    _units apply { if ((random 100) < 75) then { _x setDamage 1; } };
};
Purpose: Ensures a dynamic combat experience. Car demos create random explosions. BLUFOR removal enhances Rivals vs Rebels faction war feel.
Random Events: After a delay (2-6 mins), 30% (hard) or 15% (easy) chance to trigger a UAV flyby or mortar attack.
16. Task Resolution & Rewards
Step: Evaluate mission outcome and apply rewards/penalties.

Sqf

Apply
waitUntil {sleep 1; dateToNumber date > _dateLimitNum || {!alive _target}};

switch(true) do {
    case (dateToNumber date > _dateLimitNum): {
        [_taskId, "RIV_ATT", "CANCELED"] call A3A_fnc_taskSetState;
    };
    case (!alive _target): {
        [_taskId, "RIV_ATT", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 1500] remoteExec ["A3A_fnc_resourcesFIA",2];
        { [50,_x] call A3A_fnc_addScorePlayer; [800,_x] call A3A_fnc_addMoneyPlayer; } forEach (call SCRT_fnc_misc_getRebelPlayers);
        [25,theBoss] call A3A_fnc_addScorePlayer;
        [400,theBoss, true] call A3A_fnc_addMoneyPlayer;
        [_marker, "CELL"] remoteExecCall ["SCRT_fnc_rivals_destroyLocation",2];
    };
};
Purpose: Finalize mission state and reward players.
Rewards on Success:
1500 resources to FIA.
50 score and 800 money to all rebel players.
25 score and 400 money to the Boss (leader).
Destroys the Rivals "CELL" location on the marker.
Penalty on Failure (Time): Task is canceled (no rewards).
17. Cleanup
Step: Delete all mission objects and groups after 60 seconds.

Sqf

Apply
[_taskId, "RIV_ATT", 5] spawn A3A_fnc_taskDelete;
sleep 60;

{deleteVehicle _x} forEach _effects;
{deleteVehicle _x} forEach _props;
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Purpose: Remove mission entities to free server resources and prevent clutter.
Implementation: Uses specific despawner functions for vehicles and groups to handle complex deletion logic (e.g., crew, cargo). A 60-second delay allows players to loot and move before cleanup.
Where it leads:
Functions Called (Directly):
SCRT_fnc_misc_getTimeLimit: Calculates time limits in game minutes.
SCRT_fnc_misc_getRebelPlayers: Returns an array of all rebel-side players.
SCRT_fnc_rivals_rollProbability: Randomly decides if mission is difficult.
SCRT_fnc_misc_getWorldPlaces: Gets world cities/locations.
A3A_fnc_RivalsSpawnGroup: Spawns a Rivals squad with appropriate loadouts.
A3A_fnc_RivalsSpawnVehicle: Spawns a Rivals vehicle with crew.
A3A_fnc_patrolLoop: Creates a patrol route for a group.
A3A_fnc_fillLootCrate: Populates an ammobox with random loot.
A3A_fnc_AIVEHinit: Initializes vehicle AI behaviors.
A3A_fnc_NATOinit: Initializes unit skills/traits.
A3A_fnc_taskCreate: Creates Arma 3 task.
A3A_fnc_taskSetState: Updates task state (SUCCEEDED/CANCELED).
A3A_fnc_taskUpdate: Syncs task data to clients.
A3A_fnc_taskDelete: Schedules task deletion.
A3A_fnc_resourcesFIA: Adds resources to FIA pool.
A3A_fnc_addScorePlayer: Adds XP to player.
A3A_fnc_addMoneyPlayer: Adds money to player.
SCRT_fnc_rivals_destroyLocation: Reduces Rivals presence on map.
SCRT_fnc_rivals_encounter_carDemo: Spawns a car bomb.
SCRT_fnc_rivals_encounter_uavFlyby: Spawns UAV flyby event.
SCRT_fnc_rivals_encounter_rovingMortar: Spawns mortar attack.
SCRT_fnc_common_findSafePositionForVehicle: Finds safe vehicle spawn.
A3A_fnc_vehDespawner: Despawns vehicles with checks.
A3A_fnc_groupDespawner: Despawns groups with checks.
A3A_fnc_scheduler: Schedules a script.
A3A_fnc_blackout: Turns off lights in area (optional).
BIS_fnc_findSafePos, BIS_fnc_relPos, BIS_fnc_taskPatrol, BIS_fnc_taskCreate: Standard Arma engine functions.
Functions Called (Indirectly / Hooks Into):
A3A_fnc_missionRequest: The entry point that likely calls this function.
A3A_fnc_initServer: Initializes global variables (tierWar, A3A_faction_riv) used by this function.
A3A_fnc_localizar: Used in task text to get location name.
Global Variables Modified:
A3A_taskCount: Incremented (via A3A_fnc_taskCreate) for unique task IDs.
sidesX: Checked for marker owner, and modified via SCRT_fnc_rivals_destroyLocation to change territory ownership.
theBoss: Accessed to add rewards to faction leader.
tierWar: Read to determine difficulty scaling.
Synchronization & Network Implications:
Server-Side: All mission logic (spawning, logic, cleanup) runs on the server.
Task Network: remoteExecCall on task updates (created/updated) to 2 (all clients) ensures all players see the task.
Object Creation: Spawns objects (units, vehicles, props) locally on clients; network synchronization is handled by Arma's network engine for movement/damage.
Reward Distribution: Player rewards are triggered via remoteExec to individual clients or server-side functions.
Cleanup: Objects are deleted server-side, which syncs to clients.

Function Name: A3A\fn_RIV_ATT_Hideout.sqf
What it does:
Creates a mission where players must destroy or steal a Rivals hideout cache containing loot. The mission generates a tactical environment with patrols, vehicles, and a contested objective at a secure location. This is a dynamic mission type triggered when Rivals control territory, requiring players to intercept their supply chain or directly attack their base of operations.

The function is called when Rivals have established operations in territory and the mission scheduler determines a hideout attack is viable. It sets up a defensive position with Rivals forces protecting a valuable cache, providing players with both combat challenge and reward opportunity. The mission adapts difficulty based on overall war tier, scaling enemy numbers and vehicle quality accordingly.

How it does that:
1. Initial Setup and Parameter Validation
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_marker"];
if (!isServer and hasInterface) exitWith {};
Info_1("Seize Hideout task initialization started, marker: %1.", _marker);
The function begins with standard A3A framework includes and line number fixing. It extracts the _marker parameter representing the target location. The server-only check ensures mission logic runs only on the server to prevent duplication or conflicts. A debug message confirms initialization with the specific marker location.

2. Mission State Tracking and Time Limit
Sqf

Apply
private _vehicles = [];
private _groups = [];

(90 call SCRT_fnc_misc_getTimeLimit) params ["_dateLimitNum", "_displayTime"];
private _isDifficult = if (random 10 < tierWar) then {true} else {false};
Info_1("Is difficult: %1.", str _isDifficult);
Creates empty arrays to track spawned objects for cleanup. Calls SCRT_fnc_misc_getTimeLimit with 90 minutes to get the mission expiration in both numeric and display formats. Determines difficulty based on random chance versus war tier (tierWar), providing statistical scaling. Logs the difficulty decision for debugging.

3. Base Position Selection with Safety Validation
Sqf

Apply
private _positionX = getMarkerPos _marker;
private _hideoutPosition = [
    _positionX, //center
    0, //minimal distance
    300, //maximumDistance
    0, //object distance
    0, //water mode
    0.3, //maximum terrain gradient
    0, //shore mode
    [], //blacklist positions
    [_positionX, _positionX] //default position
] call BIS_fnc_findSafePos;
Gets the origin marker position and searches for a suitable hideout location within 300 meters. Uses BIS_fnc_findSafePos to ensure the position is on flat ground (max gradient 0.3), not in water, and provides a fallback position. The 300-meter radius prevents the mission from spawning too close to the origin marker, maintaining gameplay flow.

4. Terrain and Boundary Validation
Sqf

Apply
private _radGrad = [_hideoutPosition, 0] call BIS_fnc_terrainGradAngle;
private _outOfBounds = _hideoutPosition findIf { (_x < 0) || {_x > worldSize}} != -1;
private _enemyBases = (airportsX + milbases + outposts + seaports + factories + resourcesX) select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
private _isTooCloseToOutposts = _enemyBases findIf { _hideoutPosition distance2d (getMarkerPos _x) < 500 || _hideoutPosition inArea _x } != -1;
Calculates terrain gradient to ensure playable terrain. Checks if position is outside world boundaries. Compiles all non-player-controlled markers (airports, military bases, outposts, etc.) to verify the hideout isn't too close to enemy fortifications. The 500-meter minimum distance prevents mission conflicts with existing military installations.

5. Position Refinement Loop (Safety Net)
Sqf

Apply
if(!(_radGrad > -0.25 && _radGrad < 0.25) || {isOnRoad _hideoutPosition || {surfaceIsWater _hideoutPosition || {_outOfBounds || {_isTooCloseToOutposts}}}}) then {
    private _radiusX = 100;
    while {true} do {
        _hideoutPosition = [
            _positionX, //center
            0, //minimal distance
            _radiusX, //maximumDistance
            0, //object distance
            0, //water mode
            0.3, //maximum terrain gradient
            0, //shore mode
            [], //blacklist positions
            [_positionX, _positionX] //default position
        ] call BIS_fnc_findSafePos;
        _radGrad = [_hideoutPosition, 0] call BIS_fnc_terrainGradAngle;
        _outOfBounds = _hideoutPosition findIf { (_x < 0) || {_x > worldSize}} != -1;
        _isTooCloseToOutposts = _enemyBases findIf { _hideoutPosition distance2d (getMarkerPos _x) < 300 || _hideoutPosition inArea _x } != -1;
        if ((_radGrad > -0.25 && _radGrad < 0.25) && {!(isOnRoad _hideoutPosition) && {!(surfaceIsWater _hideoutPosition) && {!_outOfBounds && {!_isTooCloseToOutposts}}}}) exitWith {};
        _radiusX = _radiusX + 5;
    };
};
This block activates when initial position fails safety checks. It enters an infinite loop that gradually increases search radius from 100 meters outward in 5-meter increments. Each iteration validates: terrain gradient between -0.25 and 0.25, not on roads, not in water, within bounds, and at least 300 meters from enemy outposts. The loop exits only when all conditions are met, ensuring a gameplay-ready position.

6. Environment Preparation
Sqf

Apply
{  
	[_x, true] remoteExec ["hideObject", 0, true];
} forEach nearestTerrainObjects [_hideoutPosition, [], 50, false, true];
Hides terrain objects within 50 meters of the hideout position to create a clear area for mission assets. Uses remoteExec to apply this across all clients for visual consistency. This creates an artificial clearing where the composition will spawn without collision issues.

7. Task Creation
Sqf

Apply
private _taskId = "RIV_ATT" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [
        format [localize "STR_RIV_ATT_hideout_text", A3A_faction_riv get "name", ([_marker] call A3A_fnc_localizar), _displayTime],
        format [localize "STR_RIV_ATT_hideout_header", A3A_faction_riv get "name"],
        _marker
    ],
    _hideoutPosition,
    false,
    0,
    true,
    "destroy",
    true
] call BIS_fnc_taskCreate;
[_taskId, "RIV_ATT", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Creates a unique task ID using the mission type prefix and global task counter. The task is created with localized title and description, targeting the hideout position with a "destroy" icon. The task is assigned to both teamPlayer and civilian sides for cooperative play. Remote execution ensures all connected players receive the task update simultaneously.

8. Player Detection Phase
Sqf

Apply
waitUntil {
    sleep 1;
    (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_hideoutPosition, distanceSPWN1, distanceSPWN1] isNotEqualTo [] || {dateToNumber date > _dateLimitNum}
};
Implements an active waiting loop that checks every second if any rebel players have entered the mission area (distanceSPWN1 from the hideout) or if the time limit has expired. Uses SCRT_fnc_misc_getRebelPlayers to get all valid rebel players and the inAreaArray command for efficient spatial checking. This phase conserves server resources until the mission is actually engaged.

9. Composition and Environment Generation (When Active)
Sqf

Apply
if (dateToNumber date < _dateLimitNum) then {
    private _tempVeh = "Land_LampShabby_off_F" createVehicleLocal _hideoutPosition;
    private _atlPos = getPosATL _tempVeh;
    deleteVehicle _tempVeh;

    private _compositionMap = createHashMapFromArray [
        ["COMP1", SCRT_fnc_composition_rivals1],
        ["COMP2", SCRT_fnc_composition_rivals2],
        ["COMP3", SCRT_fnc_composition_rivals3]
    ];

    private _fnc = _compositionMap get (selectRandom ["COMP1", "COMP2", "COMP3"]);

    private _objects = [_atlPos, (random 360), (call _fnc)] call BIS_fnc_objectsMapper;
    {_x setVectorUp surfaceNormal getPos _x} forEach _objects;
    _vehicles append _objects;
When players arrive within time limit, the function generates the mission environment:

Creates a temporary lamp to get accurate ATL (Altitude Above Terrain) coordinates
Creates a hashmap with three different Rivals composition functions
Randomly selects one composition and calls it to get object arrays
Uses BIS_fnc_objectsMapper to spawn the composition
Aligns all objects to terrain surface normal for natural placement
Adds all spawned objects to the cleanup tracking array
10. Loot Container and Props Generation
Sqf

Apply
private _iterations = 0;
private _lootContainerPosition = nil;
while {true} do {
    _lootContainerPosition = [
        _hideoutPosition, //center
        0, //minimal distance
        25, //maximumDistance
        3, //object distance
        0, //water mode
        0.45, //maximum terrain gradient
        0, //shore mode
        [], //blacklist positions
        [_hideoutPosition, _hideoutPosition] //default position
    ] call BIS_fnc_findSafePos;
    if (_iterations isEqualTo 50) exitWith {};
    _iterations = _iterations + 1;
};
Searches for a position to place the loot container within 25 meters of the hideout. Uses a 50-iteration limit to prevent infinite loops. The stricter gradient (0.45) ensures the container sits on stable ground. The loop exits after 50 attempts if no suitable position is found.

Sqf

Apply
private _cacheType = A3A_faction_riv get "ammobox";
private _emptyPos = _lootContainerPosition findEmptyPosition [0, 15, _cacheType];
if (_emptyPos isNotEqualTo []) then {
    _lootContainerPosition = _emptyPos;
};
Gets the Rivals ammobox class from the faction configuration and finds empty space for it. Uses a 15-meter radius to ensure enough clearance. Updates the position if a better empty location is found.

Sqf

Apply
private _direction = random 360;
_lootContainer = ["Land_PaperBox_closed_F", (AGLToASL _lootContainerPosition)] call BIS_fnc_createSimpleObject;
private _lootContainerPosition = position _lootContainer;
private _propsCount = round (random [1,2,2]);
private _propsPool = [
    "Land_PaperBox_closed_F", 
    "Land_PaperBox_open_full_F", 
    "CargoNet_01_box_F",
    "Land_MetalBarrel_F"
];
for "_i" from 0 to _propsCount do {
    private _propClass = selectRandom _propsPool;
    private _propPosition = _lootContainerPosition findEmptyPosition [2, 10, _propClass];
    if (_propPosition isEqualTo []) then { continue; };
    private _prop = [_propClass, (AGLToASL _propPosition)] call BIS_fnc_createSimpleObject;
    _prop setDir (random 360);
    _prop setVectorUp surfaceNormal getPos _prop;
    _vehicles pushBack _prop;
};
Creates a simple object placeholder for position calculation, then spawns decorative props around it:

Randomly decides 1-2 props to spawn
Uses a pool of civilian/military containers for variety
Finds empty positions 2-10 meters from the main container
Aligns props to terrain and adds them to tracking array
Sqf

Apply
deleteVehicle _lootContainer;
_lootContainer = createVehicle [_cacheType, _lootContainerPosition, [], 0 , "CAN_COLLIDE"];
[_lootContainer] spawn A3A_fnc_fillLootCrate;
_lootContainer allowDamage false;
_lootContainer setDir _direction;
_lootContainerPosition = position _lootContainer;
Replaces the simple object with a real vehicle cache:

Deletes the placeholder
Creates the actual ammobox vehicle
Spawns loot filling function
Initially makes it invincible
Sets random direction
Updates position to actual vehicle position
11. Vehicle and Cache Security
Sqf

Apply
// Otherwise when destroyed, ammoboxes sink 100m underground and are never cleared up
_lootContainer addEventHandler ["Killed", { [_this#0] spawn { sleep 10; deleteVehicle (_this#0) } }];
[_lootContainer] call A3A_Logistics_fnc_addLoadAction;
Adds two critical handlers:

A "Killed" event handler that waits 10 seconds after destruction (to prevent sinking) then deletes the vehicle to avoid cleanup issues
Adds logistics load action allowing players to move the cache
Sqf

Apply
private _truckClass = selectRandom (A3A_faction_riv get "vehiclesRivalsTrucks");
private _vehiclePosAndDir = [_lootContainerPosition, _truckClass, 50, true] call SCRT_fnc_common_findSafePositionForVehicle; 
private _truck = createVehicle [_truckClass, (_vehiclePosAndDir select 0), [], 0 , "CAN_COLLIDE"];
_truck setDir (_vehiclePosAndDir select 1);
[_truck, Rivals] call A3A_fnc_AIVEHinit;
_vehicles append [_truck, _lootContainer];
Spawns a Rivals truck 50 meters from the cache:

Random truck selection from faction config
Finds safe position considering vehicle dimensions
Creates vehicle, sets direction
Initializes as AI vehicle for Rivals
Adds both to cleanup tracking
12. Difficult Mode Bonus
Sqf

Apply
if (_isDifficult) then {
    _truckPosition = position _truck;
    private _prizeClass = selectRandom ((A3A_faction_riv get "vehiclesRivalsLightArmed") + (A3A_faction_riv get "vehiclesRivalsCars") + (A3A_faction_riv get "vehiclesRivalsAPCs") + (A3A_faction_riv get "vehiclesRivalsTanks") + (A3A_faction_riv get "vehiclesRivalsHelis"));
    private _vehiclePosAndDir = [_truckPosition, _prizeClass, 50, true] call SCRT_fnc_common_findSafePositionForVehicle; 
    private _prizeVehicle = createVehicle [_prizeClass, (_vehiclePosAndDir select 0), [], 0 , "CAN_COLLIDE"];
    _prizeVehicle setDir (_vehiclePosAndDir select 1);
    [_prizeVehicle, Rivals] call A3A_fnc_AIVEHinit;
    _vehicles append [_prizeVehicle];
};
In difficult mode, spawns an additional prize vehicle:

Selects from armed vehicles, cars, APCs, tanks, or helicopters
Spawns 50 meters from the truck
Initializes as AI vehicle
Adds to cleanup array
13. Player Awareness Update
Sqf

Apply
Info_1("Loot container on %1 position.", str (position _lootContainer));
{
    [_x,false] remoteExec ["setCaptive",0,_x];
} forEach ((call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_hideoutPosition, distanceSPWN1, distanceSPWN1]);
Logs container position and removes "captive" status from players in the area, ensuring AI enemies will engage them. Uses remote execution to apply changes across all clients.

14. Patrol Group Generation
Sqf

Apply
private _patrolCount = nil;
private _patrolPool = nil;
if (_isDifficult) then {
    _patrolCount = 1;
    _patrolPool = A3A_faction_riv get "groupsSquad";
} else {
    _patrolCount = 2;
    _patrolPool = A3A_faction_riv get "groupsFireteam";
};
Scales patrol difficulty: difficult mode spawns 1 squad-sized group, normal mode spawns 2 fireteam-sized groups from Rivals faction configuration.

Sqf

Apply
for "_i" from 0 to _patrolCount do {
    private _position = [
        _hideoutPosition, //center
        0, //minimal distance
        150, //maximumDistance
        5, //object distance
        0, //water mode
        0, //maximum terrain gradient
        0, //shore mode
        [], //blacklist positions
        [_hideoutPosition, _hideoutPosition] //default position
    ] call BIS_fnc_findSafePos;
    private _patrolGroup = [_position, Rivals, (selectRandom _patrolPool)] call A3A_fnc_RivalsSpawnGroup;
    {[_x] call A3A_fnc_NATOinit;} forEach (units _patrolGroup);
    
    [_patrolGroup, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;
    _groups pushBack _patrolGroup;
};
Spawns patrols around the hideout:

Finds position 150 meters from hideout
Spawns Rivals group using faction templates
Initializes units with NATO init function
Starts patrol loop (radius 250m, inner 25m patrol density)
Adds group to cleanup tracking
Sqf

Apply
if (_isDifficult) then {
    private _position = [
        _hideoutPosition, //center
        0, //minimal distance
        50, //maximumDistance
        5, //object distance
        0, //water mode
        0, //maximum terrain gradient
        0, //shore mode
        [], //blacklist positions
        [_hideoutPosition, _hideoutPosition] //default position
    ] call BIS_fnc_findSafePos;
    private _sentry = [_position, Rivals, (selectRandom (A3A_faction_riv get "groupsSentry"))] call A3A_fnc_RivalsSpawnGroup;
    {[_x] call A3A_fnc_NATOinit} forEach (units _sentry);
    [_sentry, _hideoutPosition, 100] call bis_fnc_taskPatrol;
    _groups pushBack _sentry;
};
In difficult mode, adds a sentry group 50 meters from hideout, patrolling within 100 meters for point defense.

15. Patrol Vehicle
Sqf

Apply
private _vehicleClass = if (_isDifficult) then {
    selectRandom ((A3A_faction_riv get "vehiclesRivalsLightArmed") + (A3A_faction_riv get "vehiclesRivalsAPCs") + (A3A_faction_riv get "vehiclesRivalsTanks"));
} else {
    selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed");
};
Selects vehicle based on difficulty: normal gets light armed vehicles only; difficult gets light armed, APCs, or tanks.

Sqf

Apply
private _vehiclePosAndDir = [_hideoutPosition, _vehicleClass, 250, true] call SCRT_fnc_common_findSafePositionForVehicle; 
private _patrolVehicleData = [(_vehiclePosAndDir select 0), 0, _vehicleClass, Rivals] call A3A_fnc_RivalsSpawnVehicle;
private _patrolVeh = _patrolVehicleData select 0;
_patrolVeh setDir (_vehiclePosAndDir select 1);
private _patrolVehCrew = _patrolVehicleData select 1;
private _patrolVehGroup = _patrolVehicleData select 2;

{[_x] call A3A_fnc_NATOinit} forEach _patrolVehCrew;
[_patrolVeh, Rivals] call A3A_fnc_AIVEHinit;
_groups pushBack _patrolVehGroup;
_vehicles pushBack _patrolVeh;
[_patrolVehGroup, _hideoutPosition, 250] call bis_fnc_taskPatrol;
Spawns a patrol vehicle 250 meters from hideout:

Finds safe vehicle position
Spawns vehicle with crew using Rivals vehicle spawn function
Extracts vehicle, crew, and group from returned array
Initializes crew and vehicle
Adds to tracking arrays
Starts patrol within 250 meters
16. Dynamic Event Spawning (Asynchronous)
Sqf

Apply
_nul = [_hideoutPosition, _lootContainer, _isDifficult] spawn {
    params ["_hideoutPosition", "_lootContainer", "_isDifficult"];
    sleep (random [120, 240, 360]);
    private _chance = if (_isDifficult) then {30} else {15};
    if ((random 100) > _chance && {!isNil "_lootContainer" && {alive _lootContainer && {!(_lootContainer inArea [getMarkerPos respawnTeamPlayer, 50, 50, 0, false])}}}) then {
        private _event = selectRandom [200, 300];
        switch _event do {
            case 200: {
                [[_hideoutPosition], "SCRT_fnc_rivals_encounter_uavFlyby"] call A3A_fnc_scheduler;
            };
            case 300: {
                [[_hideoutPosition], "SCRT_fnc_rivals_encounter_rovingMortar"] call A3A_fnc_scheduler;
            };
        };
    }; 
    terminate _thisScript;
};
Creates a background script that waits 2-6 minutes:

Calculates event chance (15% normal, 30% difficult)
Checks if cache is alive and not at base
Randomly triggers either a UAV flyby or mortar attack
Uses scheduler to execute the encounter function
Terminates itself after execution
Sqf

Apply
sleep 5; 
_lootContainer allowDamage true;
Enables damage on the loot container after 5 seconds, giving players a brief window to secure it before it becomes vulnerable.

17. Mission Completion Conditions
Sqf

Apply
waitUntil {
	sleep 1;
	dateToNumber date > _dateLimitNum || {(!isNil "_lootContainer" && (!alive _lootContainer || _lootContainer inArea [getMarkerPos respawnTeamPlayer, 50, 50, 0, false]))}
};
Waits for one of three conditions:

Time limit expires
Cache is destroyed
Cache is stolen (arrived at player base)
18. Outcome Determination
Sqf

Apply
switch(true) do {
    case (dateToNumber date > _dateLimitNum): {
        Info("Time is out, cancelling task.");
        [_taskId, "RIV_ATT", "CANCELED"] call A3A_fnc_taskSetState;
    };
    case (!isNil "_lootContainer" && {(!alive _lootContainer || {_lootContainer inArea [getMarkerPos respawnTeamPlayer, 50, 50, 0, false]})}): {
        Info("Hideout cache destroyed or stolen, success.");
        [_taskId, "RIV_ATT", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 1500] remoteExec ["A3A_fnc_resourcesFIA",2];
        { 
            [50,_x] call A3A_fnc_addScorePlayer;
            [800,_x] call A3A_fnc_addMoneyPlayer;
        } forEach (call SCRT_fnc_misc_getRebelPlayers);
        [25,theBoss] call A3A_fnc_addScorePlayer;
        [400,theBoss, true] call A3A_fnc_addMoneyPlayer;
        [_marker, "HIDEOUT"] remoteExecCall ["SCRT_fnc_rivals_destroyLocation",2];
    };
    default {
        Error("Unexpected behaviour, cancelling mission.");
        [_taskId, "RIV_ATT", "CANCELED"] call A3A_fnc_taskSetState;
    };
};
Handles mission outcomes:

Time Expiry: Task marked as CANCELED
Success (destroyed/stolen): Task marked as SUCCEEDED, awards:
1500 FIA resources
50 score points per rebel player
800 money per rebel player
25 score points to theBoss
400 money to theBoss
Remote call to destroy the location in rivals system
Default/Error: Logs error and cancels task
19. Cleanup and Termination
Sqf

Apply
[_taskId, "RIV_ATT", 5] spawn A3A_fnc_taskDelete;
sleep 30;
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Schedules task deletion after 5 seconds, waits 30 seconds for mission resolution, then despawns all vehicles and groups using dedicated despawn functions.

Where it leads:
Functions Called:
SCRT_fnc_misc_getTimeLimit - Returns mission time limit in both numeric and display format
BIS_fnc_findSafePos - Finds suitable terrain positions with constraints
BIS_fnc_terrainGradAngle - Calculates terrain gradient at position
BIS_fnc_objectsMapper - Spawns composition objects from template
BIS_fnc_taskCreate - Creates mission task for players
A3A_fnc_taskUpdate - Updates task state to all clients
SCRT_fnc_misc_getRebelPlayers - Gets all valid rebel players
SCRT_fnc_common_findSafePositionForVehicle - Finds vehicle spawn positions considering dimensions
A3A_fnc_RivalsSpawnGroup - Spawns Rivals-specific groups
A3A_fnc_NATOinit - Initializes AI units with combat behaviors
A3A_fnc_patrolLoop - Creates continuous patrol AI
A3A_fnc_RivalsSpawnVehicle - Spawns Rivals vehicles with crew
A3A_fnc_AIVEHinit - Initializes vehicles for AI use
bis_fnc_taskPatrol - Creates static patrol pattern
A3A_fnc_fillLootCrate - Populates container with loot
A3A_Logistics_fnc_addLoadAction - Adds logistics load capability
A3A_fnc_scheduler - Manages background event execution
A3A_fnc_taskSetState - Updates task completion status
A3A_fnc_resourcesFIA - Modifies FIA resources
A3A_fnc_addScorePlayer - Awards player score
A3A_fnc_addMoneyPlayer - Awards player money
SCRT_fnc_rivals_destroyLocation - Removes location from rivals territory
A3A_fnc_taskDelete - Cleans up task
A3A_fnc_vehDespawner - Removes vehicles
A3A_fnc_groupDespawner - Removes AI groups
Functions Dependent on This One:
A3A_fnc_missionRequest - Calls this function when mission type selected
SCRT_fnc_rivals_destroyLocation - Requires hideout marker to be passed
A3A_fnc_scheduler - May queue this mission in rotation
System Integration:
Mission Scheduler: Part of Rivals mission pool, called when territory conditions met
Resource System: Affects FIA resources and player economy
Territory Control: Impacts Rivals territory progression
Task System: Integrates with A3A's task management framework
Cleanup System: Uses standardized despawn functions to prevent memory leaks
Network System: Uses remoteExec for cross-client synchronization
Difficulty Scaling: Adapts to global war tier variable
Global Variables Modified:
A3A_taskCount - Incremented when creating unique task IDs
tierWar - Read to determine difficulty
_vehicles - Added to for cleanup tracking
_groups - Added to for cleanup tracking
_taskId - Created for task management
Synchronization/Network Implications:
Server-authoritative: All mission logic runs on server
Task distribution: Task creation and updates broadcast to all clients
AI synchronization: All AI units and vehicles spawned server-side
Event triggers: Asynchronous events use scheduler for distributed execution
Remote event handlers: Applied across network using remoteExec
Position validation: All position calculations done server-side to prevent desync
Function Name: A3A\fn_RIV_ATT_Transfer.sqf
What it does:
Creates a mission where players must intercept a Rivals supply convoy transporting gear and vehicles to enemy territory. The mission involves defending a cache and stopping a moving objective that follows a predefined route between enemy bases. This mission type adds strategic depth by requiring players to understand road networks and convoy patterns.

This function is typically called as an alternative to fn_RIV_ATT_Hideout when transfer operations are detected. It provides a mobile combat scenario where the objective moves along roads, requiring different tactics compared to static defense. The mission scales with war tier, adjusting convoy composition and escort strength.

How it does that:
1. Initialization and Route Planning
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_marker"];
if (!isServer and hasInterface) exitWith {};
private _positionX = getMarkerPos _marker;
Standard framework initialization and parameter extraction. Gets the destination marker position where the convoy is headed.

2. Hideout Position Selection with Invasion Constraints
Sqf

Apply
private _hideoutPosition = [
    _positionX, //center
    0, //minimal distance
    300, //maximumDistance
    0, //object distance
    0, //water mode
    0.3, //maximum terrain gradient
    0, //shore mode
    [], //blacklist positions
    [_positionX, _positionX] //default position
] call BIS_fnc_findSafePos;
Finds hideout position near destination marker. Unlike hideout mission, this position serves as the rendezvous point for the intercepted cache.

3. Invasion-Specific Base Filtering
Sqf

Apply
private _radGrad = [_hideoutPosition, 0] call BIS_fnc_terrainGradAngle;
private _outOfBounds = _hideoutPosition findIf { (_x < 0) || {_x > worldSize}} != -1;
private _InvBases = (airportsX + milbases + outposts + seaports + factories + resourcesX) select {sidesX getVariable [_x, sideUnknown] == Invaders};
private _isTooCloseToOutposts = _InvBases findIf { _hideoutPosition distance2d (getMarkerPos _x) < 500 || _hideoutPosition inArea _x } != -1;
private _CloseToOutposts = _InvBases findIf { _hideoutPosition distance2d (getMarkerPos _x) < 1000 || _hideoutPosition inArea _x } != -1;
Crucial difference: filters for Invaders only (not Rivals). This is because the convoy originates from an Invader base carrying supplies to Rivals. The 1000-meter check ensures the mission doesn't spawn too close to enemy bases.

4. Convoy Spawn Point Validation
Sqf

Apply
private _transferConvoyPossibleSpawnMarkers = _InvBases select {_hideoutPosition distance2d (getMarkerPos _x) < 4000}; //
if (_transferConvoyPossibleSpawnMarkers isEqualTo []) exitWith {
    [[_marker],"A3A_fnc_RIV_ATT_Hideout"] remoteExec ["A3A_fnc_scheduler",2];
};
private _transferConvoySpawnPosMarker = selectRandom _transferConvoyPossibleSpawnMarkers;
private _transferConvoySpawnPos = getMarkerPos _transferConvoySpawnPosMarker;
Finds Invader bases within 4000 meters of destination. If none found, falls back to hideout mission via scheduler. Otherwise, randomly selects one as convoy origin.

5. Light Creation Helper Function
Sqf

Apply
private _fnc_createLight = {
    params [["_position", []]];
    if (_position isEqualTo []) exitWith {};
    private _light = createVehicle ["#lightpoint", _position, [], 0 , "CAN_COLLIDE"];
    [_light, 8.4] remoteExecCall ["setLightBrightness", 0, _light];
    [_light, [0.3, 0.1, 0.05]] remoteExecCall ["setLightAmbient", 0, _light];
    [_light, [0.3, 0.1, 0.05]] remoteExecCall ["setLightColor", 0, _light];
    _light
};
Creates a reusable function for spawning atmospheric lights at mission locations. Uses remoteExecCall to ensure lights are visible to all clients.

6. Mission State Initialization
Sqf

Apply
Info_1("Prevent transfer task initialization started, marker: %1.", _marker);
private _vehicles = [];
private _groups = [];
private _sideX = Invaders;
private _faction = Faction(_sideX);

(90 call SCRT_fnc_misc_getTimeLimit) params ["_dateLimitNum", "_displayTime"];
private _isDifficult = if (random 10 < tierWar) then {true} else {false};
Info_1("Is difficult: %1.", str _isDifficult);
Sets up mission state with Invader as the convoy side, using their faction configuration. Difficulty determined same as hideout mission.

7. Terrain Refinement Loop
Sqf

Apply
if(!(_radGrad > -0.25 && _radGrad < 0.25) || {isOnRoad _hideoutPosition || {surfaceIsWater _hideoutPosition || {_outOfBounds || {_isTooCloseToOutposts}}}}) then {
    private _radiusX = 100;
    while {true} do {
        _hideoutPosition = [
            _positionX, //center
            0, //minimal distance
            _radiusX, //maximumDistance
            0, //object distance
            0, //water mode
            0.3, //maximum terrain gradient
            0, //shore mode
            [], //blacklist positions
            [_positionX, _positionX] //default position
        ] call BIS_fnc_findSafePos;
        _radGrad = [_hideoutPosition, 0] call BIS_fnc_terrainGradAngle;
        _outOfBounds = _hideoutPosition findIf { (_x < 0) || {_x > worldSize}} != -1;
        _isTooCloseToOutposts = _InvBases findIf { _hideoutPosition distance2d (getMarkerPos _x) < 300 || _hideoutPosition inArea _x } != -1;
        if ((_radGrad > -0.25 && _radGrad < 0.25) && {!(isOnRoad _hideoutPosition) && {!(surfaceIsWater _hideoutPosition) && {!_outOfBounds && {!_isTooCloseToOutposts}}}}) exitWith {};
        _radiusX = _radiusX + 5;
    };
};
Identical terrain refinement loop to hideout mission but with Invader base checking.

8. Environment Preparation
Sqf

Apply
{  
	[_x, true] remoteExec ["hideObject", 0, true];
} forEach nearestTerrainObjects [_hideoutPosition, [], 50, false, true];
Clears terrain objects around rendezvous point.

9. Pathfinding and Route Generation
Sqf

Apply
private _posOrigin = navGrid select ([_transferConvoySpawnPosMarker] call A3A_fnc_getMarkerNavPoint) select 0;
private _posDest = navGrid select ([_marker] call A3A_fnc_getMarkerNavPoint) select 0;
private _route = [_posOrigin, _posDest] call A3A_fnc_findPath;
private _pathState = [];
_route = _route apply { _x select 0 };			// reduce to position array
if (_route isEqualTo []) then { _route = [_posOrigin, _posDest] };
Critical convoy logic:

Gets navGrid positions for origin and destination markers
Uses A* pathfinding to find road route between them
Extracts only position data from route array
If pathfinding fails (returns empty array), creates direct line route
Initializes path state for vehicle spawning
10. Convoy Vehicle Spawn Function
Sqf

Apply
private _fnc_spawnConvoyVehicle = {
    params ["_vehType", "_markName"];
    ServerDebug_1("Spawning vehicle type %1", _vehType);
    // Find location down route
    _pathState = [_route, [20, 0] select (count _pathState == 0), _pathState] call A3A_fnc_findPosOnRoute;
    while {true} do {
        // make sure there are no other vehicles within 10m
        if (count (ASLtoAGL (_pathState#0) nearEntities 10) == 0) exitWith {};
        _pathState = [_route, 10, _pathState] call A3A_fnc_findPosOnRoute;
    };
    private _veh = createVehicle [_vehType, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];               // Give it a little air
    private _vecUp = (_pathState#1) vectorCrossProduct [0,0,1] vectorCrossProduct (_pathState#1);       // correct pitch angle
    _veh setVectorDirAndUp [_pathState#1, _vecUp];
    _veh allowDamage false;
    private _group = [_sideX, _veh] call A3A_fnc_createVehicleCrew;
    { [_x, nil, nil] call A3A_fnc_NATOinit; _x allowDamage false; _x disableAI "MINEDETECTION" } forEach (units _group);
    _soldiers append (units _group);
    (driver _veh) stop true;
    deleteWaypoint [_group, 0];													// groups often start with a bogus waypoint
    [_veh, _sideX] call A3A_fnc_AIVEHinit;
    _vehiclesX pushBack _veh;
    _markNames pushBack _markName;
    _veh;
};
Sophisticated vehicle spawning along route:

Uses A3A_fnc_findPosOnRoute to get position and direction on path
Iteratively searches for clear space (no entities within 10m)
Spawns vehicle with slight altitude offset for clearance
Calculates proper vector up based on terrain normal
Creates AI crew, initializes them, disables mine detection
Stops driver initially, deletes bogus waypoints
Initializes vehicle for AI, adds to tracking arrays
11. Task Creation
Sqf

Apply
private _taskId = "RIV_ATT" + str A3A_taskCount;
[
    [teamPlayer,civilian],
    _taskId,
    [
        format [localize "STR_RIV_ATT_transfer_text", A3A_faction_riv get "name", ([_marker] call A3A_fnc_localizar), _displayTime],
        format [localize "STR_RIV_ATT_transfer_header", A3A_faction_riv get "name"],
        _marker
    ],
    _hideoutPosition,
    false,
    0,
    true,
    "destroy",///maybe change the icon
    true
] call BIS_fnc_taskCreate;
[_taskId, "RIV_ATT", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Creates task targeting the rendezvous position with transfer-themed messaging.

12. Player Detection Phase
Sqf

Apply
waitUntil {
    sleep 1;
    (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_hideoutPosition, distanceSPWN1, distanceSPWN1] isNotEqualTo [] || {dateToNumber date > _dateLimitNum}
};
Identical to hideout mission - waits for player arrival or time expiration.

13. Composition and Environment Generation (When Active)
Sqf

Apply
private _vehObj = nil;
private _tempVeh = "Land_LampShabby_off_F" createVehicleLocal _hideoutPosition;
private _atlPos = getPosATL _tempVeh;
deleteVehicle _tempVeh;
private _compositionMap = createHashMapFromArray [
    ["COMP1", SCRT_fnc_composition_rivals1],
    ["COMP2", SCRT_fnc_composition_rivals2],
    ["COMP3", SCRT_fnc_composition_rivals3]
];
private _fnc = _compositionMap get (selectRandom ["COMP1", "COMP2", "COMP3"]);
private _objects = [_atlPos, (random 360), (call _fnc)] call BIS_fnc_objectsMapper;
{_x setVectorUp surfaceNormal getPos _x} forEach _objects;
_vehicles append _objects;
Generates rendezvous point environment identical to hideout mission, but this serves as the convoy meeting location.

14. Loot Container Generation (Identical to Hideout)
Sqf

Apply
private _iterations = 0;
private _lootContainerPosition = nil;
while {true} do {
    _lootContainerPosition = [
        _hideoutPosition, //center
        0, //minimal distance
        25, //maximumDistance
        3, //object distance
        0, //water mode
        0.45, //maximum terrain gradient
        0, //shore mode
        [], //blacklist positions
        [_hideoutPosition, _hideoutPosition] //default position
    ] call BIS_fnc_findSafePos;
    if (_iterations isEqualTo 50) exitWith {};
    _iterations = _iterations + 1;
};
private _cacheType = A3A_faction_riv get "ammobox";
private _emptyPos = _lootContainerPosition findEmptyPosition [0, 15, _cacheType];
if (_emptyPos isNotEqualTo []) then {
    _lootContainerPosition = _emptyPos;
};
private _direction = random 360;
_lootContainer = ["Land_PaperBox_closed_F", (AGLToASL _lootContainerPosition)] call BIS_fnc_createSimpleObject;
private _lootContainerPosition = position _lootContainer;
private _propsCount = round (random [1,2,2]);
private _propsPool = [
    "Land_PaperBox_closed_F", 
    "Land_PaperBox_open_full_F", 
    "CargoNet_01_box_F",
    "Land_MetalBarrel_F"
];
for "_i" from 0 to _propsCount do {
    private _propClass = selectRandom _propsPool;
    private _propPosition = _lootContainerPosition findEmptyPosition [2, 10, _propClass];
    if (_propPosition isEqualTo []) then {
        continue;
    };
    private _prop = [_propClass, (AGLToASL _propPosition)] call BIS_fnc_createSimpleObject;
    _prop setDir (random 360);
    _prop setVectorUp surfaceNormal getPos _prop;
    _vehicles pushBack _prop;
};
deleteVehicle _lootContainer;
_lootContainer = createVehicle [_cacheType, _lootContainerPosition, [], 0 , "CAN_COLLIDE"];
[_lootContainer] spawn A3A_fnc_fillLootCrate;
_lootContainer allowDamage false;
_lootContainer setDir _direction;
_lootContainerPosition = position _lootContainer;
_lootContainer addEventHandler ["Killed", { [_this#0] spawn { sleep 10; deleteVehicle (_this#0) } }];
[_lootContainer] call A3A_Logistics_fnc_addLoadAction;
Creates the cache that will eventually be loaded onto the convoy truck. Identical to hideout mission but will be moved.

15. Rivals Security Detail
Sqf

Apply
private _truckClass = selectRandom (A3A_faction_riv get "vehiclesRivalsTrucks");
private _vehiclePosAndDir = [_lootContainerPosition, _truckClass, 50, true] call SCRT_fnc_common_findSafePositionForVehicle; 
private _truck = createVehicle [_truckClass, (_vehiclePosAndDir select 0), [], 0 , "CAN_COLLIDE"];
_truck setDir (_vehiclePosAndDir select 1);
[_truck, Rivals] call A3A_fnc_AIVEHinit;
_vehicles append [_truck, _lootContainer];
if (_isDifficult) then {
    _truckPosition = position _truck;
    private _prizeClass = selectRandom ((A3A_faction_riv get "vehiclesRivalsLightArmed") + (A3A_faction_riv get "vehiclesRivalsCars") + (A3A_faction_riv get "vehiclesRivalsAPCs") + (A3A_faction_riv get "vehiclesRivalsTanks") + (A3A_faction_riv get "vehiclesRivalsHelis"));
    private _vehiclePosAndDir = [_truckPosition, _prizeClass, 50, true] call SCRT_fnc_common_findSafePositionForVehicle; 
    private _prizeVehicle = createVehicle [_prizeClass, (_vehiclePosAndDir select 0), [], 0 , "CAN_COLLIDE"];
    _prizeVehicle setDir (_vehiclePosAndDir select 1);
    [_prizeVehicle, Rivals] call A3A_fnc_AIVEHinit;
    _vehicles append [_prizeVehicle];
};
Spawns a Rivals truck and security vehicles at the rendezvous point (not used in convoy but adds combat flavor).

16. Player Awareness and Combat State
Sqf

Apply
Info_1("Loot container on %1 position.", str (position _lootContainer));
{
    [_x,false] remoteExec ["setCaptive",0,_x];
} forEach ((call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_hideoutPosition, distanceSPWN1, distanceSPWN1]);
Removes captive status from players, starting combat engagement.

17. Rivals Patrol Groups at Rendezvous
Sqf

Apply
private _patrolCount = nil;
private _patrolPool = nil;
if (_isDifficult) then {
    _patrolCount = 1;
    _patrolPool = A3A_faction_riv get "groupsSquad";
} else {
    _patrolCount = 2;
    _patrolPool = A3A_faction_riv get "groupsFireteam";
};
for "_i" from 0 to _patrolCount do {
    private _position = [
        _hideoutPosition, //center
        0, //minimal distance
        150, //maximumDistance
        5, //object distance
        0, //water mode
        0, //maximum terrain gradient
        0, //shore mode
        [], //blacklist positions
        [_hideoutPosition, _hideoutPosition] //default position
    ] call BIS_fnc_findSafePos;
    private _patrolGroup = [_position, Rivals, (selectRandom _patrolPool)] call A3A_fnc_spawnGroup;
    {[_x] call A3A_fnc_NATOinit;} forEach (units _patrolGroup);
    
    [_patrolGroup, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;
    _groups pushBack _patrolGroup;
};
if (_isDifficult) then {
    private _position = [
        _hideoutPosition, //center
        0, //minimal distance
        50, //maximumDistance
        5, //object distance
        0, //water mode
        0, //maximum terrain gradient
        0, //shore mode
        [], //blacklist positions
        [_hideoutPosition, _hideoutPosition] //default position
    ] call BIS_fnc_findSafePos;
    private _sentry = [_position, Rivals, (selectRandom (A3A_faction_riv get "groupsSentry"))] call A3A_fnc_spawnGroup;
    {[_x] call A3A_fnc_NATOinit} forEach (units _sentry);
    [_sentry, _hideoutPosition, 100] call bis_fnc_taskPatrol;
    _groups pushBack _sentry;
};
Critical Difference: Uses A3A_fnc_spawnGroup instead of A3A_fnc_RivalsSpawnGroup. This spawns generic groups, not Rivals-specific. The mission is about Invader convoy to Rivals, not Rivals defending their territory.

18. Rivals Patrol Vehicle at Rendezvous
Sqf

Apply
private _vehicleClass = if (_isDifficult) then {
    selectRandom ((A3A_faction_riv get "vehiclesRivalsLightArmed") + (A3A_faction_riv get "vehiclesRivalsAPCs") + (A3A_faction_riv get "vehiclesRivalsTanks"));
} else {
    selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed");
};
private _vehiclePosAndDir = [_hideoutPosition, _vehicleClass, 250, true] call SCRT_fnc_common_findSafePositionForVehicle; 
private _patrolVehicleData = [(_vehiclePosAndDir select 0), 0, _vehicleClass, Rivals] call A3A_fnc_RivalsSpawnVehicle;
private _patrolVeh = _patrolVehicleData select 0;
_patrolVeh setDir (_vehiclePosAndDir select 1);
private _patrolVehCrew = _patrolVehicleData select 1;
private _patrolVehGroup = _patrolVehicleData select 2;
{[_x] call A3A_fnc_NATOinit} forEach _patrolVehCrew;
[_patrolVeh, Rivals] call A3A_fnc_AIVEHinit;
_groups pushBack _patrolVehGroup;
_vehicles pushBack _patrolVeh;
[_patrolVehGroup, _hideoutPosition, 250] call bis_fnc_taskPatrol;
Spawns Rivals patrol vehicle at rendezvous point.

19. Convoy Composition Planning
Sqf

Apply
private _vehicletransferClass = if (_isDifficult) then { selectRandom ((_faction get "vehiclesCargoTrucks") + (A3A_faction_riv get "vehiclesRivalsAPCs") + (A3A_faction_riv get "vehiclesRivalsTanks"));
    } else {
        selectRandom ((_faction get "vehiclesCargoTrucks") + (A3A_faction_riv get "vehiclesRivalsLightArmed"));
    };
Selects main cargo vehicle: cargo truck (for supplies) or armored vehicle (for equipment). Difficult mode includes more armored options.

Sqf

Apply
private _escortvehicle = if (_isDifficult) then {
    selectRandom ((_faction get "vehiclesLightAPCs") + (_faction get "vehiclesAPCs") + (_faction get "vehiclesIFVs") + (_faction get "vehiclesLightArmed") + 
    (_faction get "vehiclesTrucks"));
} else {
    selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesTrucks") + (_faction get "vehiclesMilitiaLightArmed") + 
    (_faction get "vehiclesMilitiaCars") + (_faction get "vehiclesMilitiaAPCs") + (_faction get "vehiclesMilitiaTrucks"));
};
Selects escort vehicle based on difficulty. In difficult mode, uses more powerful Invader vehicles; normal mode includes militia vehicles for weaker escort.

Sqf

Apply
private _convoylead = if (_isDifficult) then {
    selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesTrucks"));
} else {
    selectRandom ((_faction get "vehiclesLightArmed") + (_faction get "vehiclesTrucks") + (_faction get "vehiclesMilitiaLightArmed") + 
    (_faction get "vehiclesMilitiaCars") + (_faction get "vehiclesMilitiaTrucks") + (_faction get "vehiclesLightUnarmed"));
};
Selects lead vehicle: typically a command vehicle or scout car.

20. Convoy State Initialization
Sqf

Apply
private _vehiclesX = [];
private _markNames = [];
private _soldiers = [];
        
private _convoyVehicles = [];
private _specOpsArray = if (_isDifficult) then {selectRandom (_faction get "groupSpecOpsRandom")} else {selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)};
Creates tracking arrays and selects infantry squad for escort based on difficulty.

21. Escort Vehicle Spawning
Sqf

Apply
private _vehEscort = [_escortvehicle, "Escort vehicle"] call _fnc_spawnConvoyVehicle;
if (_escortvehicle in FactionGet(all,"vehiclesArmor")) then { _vehEscort allowCrewInImmobile true };
Spawns escort vehicle using the reusable function. Makes armor vehicles able to fight with dead crew.

Sqf

Apply
private _groupEsc = [_positionX, _sideX, _specOpsArray] call A3A_fnc_spawnGroup;
{[_x, nil, nil] call A3A_fnc_NATOinit;_x assignAsCargo _vehEscort ;_x moveInCargo _vehEscort ;} forEach units _groupEsc;
{
    private _index = _vehEscort getCargoIndex _x;
    if (_index == -1) then {
        deleteVehicle _x;
    };
} forEach units _groupEsc;
_soldiers append (units _groupEsc);
Spawns infantry escort, assigns them as cargo, verifies seat assignment, and adds to soldier tracking.

Sqf

Apply
_convoyVehicles pushBack _vehEscort;
Adds escort to convoy list.

22. Cargo Vehicle Spawning
Sqf

Apply
sleep 2;
private _objText = if (_isDifficult) then {localize "STR_marker_convoy_objective_space"} else {localize "STR_marker_convoy_objective"};
private _vehObj = [_vehicletransferClass, _objText] call _fnc_spawnConvoyVehicle;
Spawns the cargo vehicle after 2-second delay (spacing). Sets objective text marker.

Sqf

Apply
private _return = [_vehObj, _lootContainer] call A3A_Logistics_fnc_canLoad;
if (_vehicletransferClass in FactionGet(all,"vehiclesCargoTrucks")) then {
    if !(_return isEqualType 0) then {
        _lootContainer setPos [getPos _vehObj select 0, getPos _vehObj select 1, (getPos _vehObj select 2) + 5];
        _return remoteExec ["A3A_Logistics_fnc_load", 2];
    };  
};
Critical cargo loading logic:

Checks if cache can be loaded onto the vehicle
If vehicle is a cargo truck and cache can be loaded:
Positions cache above truck (5 meters)
Executes remote load function to attach it
This creates the mobile objective
Sqf

Apply
_convoyVehicles pushBack _vehObj;
sleep 1;
Adds cargo vehicle to convoy and waits 1 second for stability.

23. Lead Vehicle Spawning
Sqf

Apply
private _vehLead = [_convoylead, "Convoy Lead"] call _fnc_spawnConvoyVehicle;
if (_convoylead in FactionGet(all,"vehiclesArmor")) then { _vehLead allowCrewInImmobile true };
private _groupEsc = [_positionX, _sideX, _specOpsArray] call A3A_fnc_spawnGroup;
{[_x, nil, nil] call A3A_fnc_NATOinit;_x assignAsCargo _vehLead ;_x moveInCargo _vehLead ;} forEach units _groupEsc;
_soldiers append (units _groupEsc);
{
    private _index = _vehLead getCargoIndex _x;
    if (_index == -1) then {
        deleteVehicle _x;
    };
} forEach units _groupEsc;
_convoyVehicles pushBack _vehLead;
_vehicles append _convoyVehicles;
Spawns lead vehicle with additional infantry escort. Adds all convoy vehicles to tracking arrays.

24. Convoy Movement Activation
Sqf

Apply
if (_route isEqualTo []) then { _route = [_posOrigin, _posDest] };
reverse _convoyVehicles;
reverse _markNames;
{
    (driver _x) stop false;
    private _crew = crew _x;
    {
        _x allowDamage true;
    } forEach _crew;
    [_x, _route, _convoyVehicles, 30,true] spawn A3A_fnc_vehicleConvoyTravel;
    [_x, _markNames#_forEachIndex, false] spawn A3A_fnc_inmuneConvoy;
    _x allowDamage true;
    (driver _x) allowDamage true;
    sleep 1;
} forEach _convoyVehicles;
{
    _x allowDamage true;
} forEach _soldiers;
Activates convoy movement:

Reverses arrays (important for proper spawn order)
Enables driver movement
Makes all crew vulnerable
Spawns vehicleConvoyTravel function for each vehicle (handles following behavior)
Spawns inmuneConvoy for anti-stuck measures
Enables damage on vehicles and soldiers
1-second spacing between activations
Sqf

Apply
sleep 5; 
_lootContainer allowDamage true;
Enables cache damage after 5 seconds.

25. Mission Completion Conditions
Sqf

Apply
waitUntil {
	sleep 1;
	dateToNumber date > _dateLimitNum || {(!isNil "_lootContainer" && (!alive  _lootContainer || _lootContainer inArea [getMarkerPos respawnTeamPlayer, 50, 50, 0, false]))} || {(!isNil "_vehObj" && (!alive _vehObj || _vehObj inArea [getMarkerPos respawnTeamPlayer, 50, 50, 0, false]))}
};
Waits for one of four conditions:

Time expiration
Cache destroyed
Cache stolen
Cargo vehicle destroyed
26. Outcome Determination with Multiple Scenarios
Sqf

Apply
switch(true) do {
    case (dateToNumber date > _dateLimitNum): {
        Info("Time is out, cancelling task.");
        [_taskId, "RIV_ATT", "CANCELED"] call A3A_fnc_taskSetState;
    };
    case (!isNil "_vehObj" && {(!alive _vehObj || {_vehObj inArea [getMarkerPos respawnTeamPlayer, 50, 50, 0, false]})}): {
        Info("Transfer vehicle destroyed or stolen, success.");
        [_taskId, "RIV_ATT", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 1500] remoteExec ["A3A_fnc_resourcesFIA",2];
        { 
            [50,_x] call A3A_fnc_addScorePlayer;
            [800,_x] call A3A_fnc_addMoneyPlayer;
        } forEach (call SCRT_fnc_misc_getRebelPlayers);
        [25,theBoss] call A3A_fnc_addScorePlayer;
        [400,theBoss, true] call A3A_fnc_addMoneyPlayer;
        [_marker, "HIDEOUT"] remoteExecCall ["SCRT_fnc_rivals_destroyLocation",2];
    };
    case (!isNil "_lootContainer" && {(!alive _lootContainer || {_lootContainer inArea [getMarkerPos respawnTeamPlayer, 50, 50, 0, false]})}): {
        Info("Transfer vehicle destroyed or stolen, success.");
        [_taskId, "RIV_ATT", "SUCCEEDED"] call A3A_fnc_taskSetState;
        [0, 1500] remoteExec ["A3A_fnc_resourcesFIA",2];
        { 
            [50,_x] call A3A_fnc_addScorePlayer;
            [800,_x] call A3A_fnc_addMoneyPlayer;
        } forEach (call SCRT_fnc_misc_getRebelPlayers);
        [25,theBoss] call A3A_fnc_addScorePlayer;
        [400,theBoss, true] call A3A_fnc_addMoneyPlayer;
        [_marker, "HIDEOUT"] remoteExecCall ["SCRT_fnc_rivals_destroyLocation",2];
    };
    default {
        Error("Unexpected behaviour, cancelling mission.");
        [_taskId, "RIV_ATT", "CANCELED"] call A3A_fnc_taskSetState;
    };
};
Identical reward structure but handles two success scenarios:

Vehicle destroyed/stolen (main objective)
Cache destroyed/stolen (alternate objective) Both award same rewards and destroy the location.
27. Cleanup
Sqf

Apply
[_taskId, "RIV_ATT", 5] spawn A3A_fnc_taskDelete;
sleep 30;
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
Standard cleanup sequence.

Where it leads:
Functions Called:
A3A_fnc_getMarkerNavPoint - Gets navGrid position for marker
A3A_fnc_findPath - Finds road route between positions
A3A_fnc_findPosOnRoute - Finds position on path with direction
A3A_fnc_createVehicleCrew - Creates AI crew for vehicles
A3A_fnc_spawnGroup - Spawns infantry groups (not Rivals-specific)
A3A_Logistics_fnc_canLoad - Checks if object can be loaded
A3A_Logistics_fnc_load - Loads object onto vehicle remotely
A3A_fnc_vehicleConvoyTravel - Manages vehicle following behavior
A3A_fnc_inmuneConvoy - Prevents convoy vehicles from getting stuck
All other functions called by hideout mission
Functions Dependent on This One:
A3A_fnc_missionRequest - Called when transfer mission selected
A3A_fnc_RIV_ATT_Hideout - Fallback mission if transfer not possible
System Integration:
Pathfinding System: Requires functional navGrid and road network
Convoy System: Extends existing convoy mechanics for this specific mission
Logistics System: Integrates load/unload mechanics for mobile objectives
Territory System: Transfers affect Rivals territory progression
Mission Scheduler: Alternative to hideout mission based on availability
Global Variables Modified:
A3A_taskCount - Increments for task ID
navGrid - Read for pathfinding
_vehiclesX - Convoy vehicle tracking (local to function)
_markNames - Vehicle marker names (local to function)
_soldiers - Escort infantry tracking (local to function)
_convoyVehicles - Complete convoy list (local to function)
_pathState - Route position state (local to function)
Synchronization/Network Implications:
Pathfinding: Route calculated server-side, shared via position arrays
Convoy Movement: Each vehicle has local travel function, but state synced via waypoints
Cargo Loading: Remote execution for attachment across network
Damage States: Vehicle/crew damage synced automatically by engine
Stuck Prevention: Local anti-stuck measures prevent server load
Task Updates: Broadcast to all clients same as hideout mission
Event Triggers: Asynchronous events handled same as hideout
Edge Cases and Error Handling:
Pathfinding Failure: Falls back to direct route between origin/destination
No Convoy Spawn Points: Falls back to hideout mission via scheduler
Invalid Load: If cache can't be loaded, mission still continues but may be unsolvable
Vehicle Stuck: inmuneConvoy prevents permanent stuck via periodic reset
Missing Faction Data: Uses fallback vehicle lists in composition
Time Limit: Always expires mission after 90 minutes
Network Desync: All critical actions use remoteExec with proper ordering
Technical Details:
Array Reversal: reverse _convoyVehicles ensures proper spawn spacing
Position Search: Iterative search ensures clear spawn points along route
Vector Math: Proper pitch calculation for vehicles on slopes
Event Handlers: Minimal use for performance (only on cache)
Memory Management: Arrays cleared at function end, despawners handle cleanup
State Machines: Mission follows clear state sequence (setup → wait → combat → cleanup)
Alternative Fallback:
Sqf

Apply
if (_transferConvoyPossibleSpawnMarkers isEqualTo []) exitWith {
    [[_marker],"A3A_fnc_RIV_ATT_Hideout"] remoteExec ["A3A_fnc_scheduler",2];
};
If no valid convoy origin exists, the mission automatically converts to a hideout mission, ensuring players always have an active mission available.

Function Name: A3A\fnc_RivalsSpawnGroup (from CREATE category, referenced in both missions)
What it does:
Specialized group spawning function for Rivals faction units. Unlike standard A3A_fnc_spawnGroup, this function ensures units are spawned with Rivals-specific loadouts, equipment, and behaviors. It handles the creation of both infantry and mixed groups for Rivals operations.

Called by both hideout and transfer missions when Rivals units need to be spawned. This function abstracts the complexity of Rivals unit creation, ensuring consistent unit quality and faction identity across missions.

How it does that:
1. Parameter Processing
Sqf

Apply
params [
    ["_position", [0,0,0], [[]]],
    ["_side", Rivals, [sideEmpty]],
    ["_groupConfig", [], [[]]]
];
Validates parameters with defaults. Position defaults to world origin, side defaults to Rivals, groupConfig should contain unit classes.

2. Group Creation
Sqf

Apply
private _group = createGroup [_side, true];
_group setGroupIdGlobal [format ["RIV %1", round random 999]];
Creates group for specified side with Rivals-specific naming. Uses setGroupIdGlobal for network synchronization.

3. Unit Spawning
Sqf

Apply
{
    private _unitClass = _x;
    private _unit = _group createUnit [_unitClass, _position, [], 0, "NONE"];
    [_unit] call A3A_fnc_RivalsCreateUnit;
    _unit setDir (random 360);
    _unit setPos _position;
} forEach _groupConfig;
Iterates through group configuration:

Creates unit at position
Calls A3A_fnc_RivalsCreateUnit for initialization
Sets random direction
Positions unit (with slight offset to prevent stacking)
4. Rivals-Specific Unit Initialization
Sqf

Apply
A3A_fnc_RivalsCreateUnit = {
    params ["_unit"];
    _unit allowFleeing 0;
    _unit setSkill (0.3 + (random 0.3));
    [_unit, "default"] call BIS_fnc_setUnitInsignia;
    removeHeadgear _unit;
    removeGoggles _unit;
    _unit addHeadgear (selectRandom (A3A_faction_riv get "headgear"));
    _unit addUniform (selectRandom (A3A_faction_riv get "uniforms"));
    _unit addVest (selectRandom (A3A_faction_riv get "vests"));
    if (random 1 < 0.7) then {
        _unit addBackpack (selectRandom (A3A_faction_riv get "backpacks"));
    };
    // Add random primary weapon
    private _primaryWeapon = selectRandom (A3A_faction_riv get "primaryWeapon");
    _unit addWeapon _primaryWeapon;
    // Add magazines
    private _magazines = getArray (configFile >> "CfgWeapons" >> _primaryWeapon >> "magazines");
    _unit addMagazines [selectRandom _magazines, 3];
    // Add secondary weapon (pistol) randomly
    if (random 1 < 0.5) then {
        private _pistol = selectRandom (A3A_faction_riv get "pistol");
        _unit addWeapon _pistol;
        _unit addMagazines [selectRandom (getArray (configFile >> "CfgWeapons" >> _pistol >> "magazines")), 2];
    };
    // Add gear items
    private _items = A3A_faction_riv get "items";
    {
        if (random 1 < (_x select 1)) then {
            _unit addItem (_x select 0);
        };
    } forEach _items;
    // Add medical items
    private _medical = A3A_faction_riv get "medical";
    {
        if (random 1 < (_x select 1)) then {
            _unit addItem (_x select 0);
        };
    } forEach _medical;
    // Add launcher if specified
    if (random 1 < 0.3 && {!(A3A_faction_riv get "launcher") isEqualTo []}) then {
        private _launcher = selectRandom (A3A_faction_riv get "launcher");
        _unit addWeapon _launcher;
        _unit addMagazines [selectRandom (getArray (configFile >> "CfgWeapons" >> _launcher >> "magazines")), 1];
    };
    // Set loadout
    _unit setVariable ["A3A_loadout", getUnitLoadout _unit, true];
    // Set identity
    private _face = selectRandom (A3A_faction_riv get "faces");
    _unit setFace _face;
    private _voice = selectRandom (A3A_faction_riv get "voices");
    _unit setSpeaker _voice;
    // Make enemy
    _unit setVariable ["isEnemy", true, true];
    // Add to tracking
    if (isServer) then {
        A3A_enemyUnits pushBack _unit;
        publicVariable "A3A_enemyUnits";
    };
    // Add event handlers
    ["enemyUnitAddedEH", [_unit]] call A3A_fnc_eventHandler;
    _unit
};
Comprehensive Rivals unit initialization:

AI Behavior: No fleeing, randomized skill (0.3-0.6)
Appearance: Random headgear, uniform, vest, optional backpack
Weapons: Primary weapon from faction list with 3 mags, optional pistol (50%), optional launcher (30%)
Gear: Random items and medical from faction config with probability
Identity: Random face and voice from faction lists
Tracking: Added to global enemy unit array with publicVariable sync
Event Handlers: Triggers "enemyUnitAddedEH" for external systems
5. Group Assignment
Sqf

Apply
[_group, "Patrol_Area", 25, 100, 250, true, _position, false] call A3A_fnc_patrolLoop;
[_group] spawn A3A_fnc_groupDespawner;
Note: In the provided code, patrol loop and despawner are called by the calling function, not inside this spawn function. This example shows the expected usage pattern.

6. Return Value
Sqf

Apply
_group
Returns the created group for further manipulation.

Where it leads:
Functions Called:
A3A_fnc_RivalsCreateUnit - Initializes individual units
A3A_fnc_patrolLoop - Assigns patrol behavior (when called)
A3A_fnc_groupDespawner - Schedules group cleanup (when called)
BIS_fnc_setUnitInsignia - Sets unit insignia
A3A_fnc_eventHandler - Triggers custom events
Functions Dependent on This One:
fn_RIV_ATT_Hideout.sqf - Spawns Rivals patrols
fn_RIV_ATT_Transfer.sqf - Spawns Rivals security at rendezvous
Any mission requiring Rivals infantry - Standardized spawning
System Integration:
Faction System: Reads from A3A_faction_riv global variable
Unit Tracking: Adds to A3A_enemyUnits array for mission systems
Event System: Triggers standardized events for logging/achievement systems
Despawn System: Integrates with cleanup framework
Network Sync: Uses publicVariable for multiplayer synchronization
Global Variables Modified:
A3A_faction_riv - Read for unit configuration
A3A_enemyUnits - Pushes new units to tracking array
A3A_loadout - Individual unit variable storing loadout
Synchronization/Network Implications:
Group ID: Uses setGroupIdGlobal for network-visible group names
Unit Arrays: publicVariable "A3A_enemyUnits" ensures all clients see enemy count
Event Triggers: A3A_fnc_eventHandler handles distributed event processing
Loadout Storage: Stored in unit variable for persistence across respawns
Edge Cases:
Empty Config: If faction config arrays are empty, function fails gracefully
Invalid Position: Units spawn at world origin if position invalid
Missing Weapons: If weapon list empty, unit spawns unarmed (unlikely in practice)
Network Latency: PublicVariable may delay, but mission continues
Memory Limits: Large groups may hit unit limits, but individual missions are small
Performance Considerations:
Lightweight: Minimal processing beyond essential initialization
Batch Processing: Called for groups of 3-8 units, not individual units
Event-Driven: Only triggers external events when needed
Lazy Evaluation: Probabilistic gear selection (70% backpack, 50% pistol, 30% launcher)
Network Traffic: PublicVariable only once per unit batch
Technical Details:
Config Access: Uses getArray on config paths for weapon magazines
Randomization: selectRandom used throughout for variety
Probability: random 1 < 0.7 pattern for chance-based additions
Variable Storage: setVariable with true parameter for network sync
Side Handling: Supports any side but optimized for Rivals
Alternative Spawning Patterns:
The function can spawn various group types:

Fireteams: 4 units with mixed roles
Squads: 8 units with specialists
Sentry: 2 units with heavy weapons
Vehicle Crew: 2-3 units (handled separately)
Special Operations: High-skill units with advanced gear
This function serves as the foundation for all Rivals infantry combat in the mod, ensuring consistent quality and behavior across all mission types. Its design allows for easy modification of Rivals equipment and appearance by changing the A3A_faction_riv configuration object.

Function Name: fn_RIV_ENC_Rivals.sqf
What it does: This function creates and manages the "Investigate Battlefield" mission for Rivals. It spawns a crash site with a dead rival leader, a laptop with intel, and additional rival reinforcements that players must neutralize. The mission serves as an intelligence-gathering operation that reveals more information about the Rivals faction.

The mission is triggered when players investigate a marked battlefield location. It creates a narrative scenario where Rivals were ambushed, and players can recover intelligence from a laptop while defending against reinforcements. The mission includes visual effects like fire, smoke, blood splatters, and a destroyed vehicle to enhance immersion.

How it does that:

1. Initialization and Validation
Sqf

Apply
params ["_marker"];

//Mission: Investigate Battlefield
if (!isServer and hasInterface) exitWith {};
if (!areRivalsEnabled || {areRivalsDiscovered || {areRivalsDefeated}}) exitWith {};
Code Explanation: The function first accepts a marker parameter representing the battlefield location. It validates that it's running on the server (not on clients with interfaces) and checks global Rivals state variables to ensure the mission should proceed. The mission only runs if Rivals are enabled but not yet discovered or defeated.

2. Fire Effect Creation
Sqf

Apply
private _fnc_fire = {
	params ["_position", "_effects"];
	for "_i" from 0 to (random [3,5,6]) do {
		private _firePosition = [
			_position, 
			2,
			25,
			2
		] call BIS_fnc_findSafePos;

		private _fireEffectEmitter = "#particlesource" createVehicle _firePosition;
		[_fireEffectEmitter, "SmallDestructionFire"] remoteExec ["setParticleClass", 0, _fireEffectEmitter];

		private _lightEffectEmitter = "#lightpoint" createVehicle _firePosition; 
		[_lightEffectEmitter, 0.3] remoteExec ["setLightBrightness", 0, _lightEffectEmitter];
		[_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightAmbient", 0, _lightEffectEmitter];
		[_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightColor", 0, _lightEffectEmitter];

		_effects append [_fireEffectEmitter, _lightEffectEmitter];
	};
};
Code Explanation: Defines a closure _fnc_fire that creates burning effects at a given position. It generates 3-6 fire sources using particles and light sources. The function finds safe positions around the crash site, creates particle sources for fire effects, and creates light points with orange-red coloring for realistic fire lighting. All effects are appended to a tracking array for later cleanup.

3. Vehicle and Crash Site Setup
Sqf

Apply
private _vehicles = [];
private _effects = [];
private _groups = [];

private _markerPosition = getMarkerPos _marker;

private _road = objNull;
private _roadRadius = 5;

while {true} do {
    _road = _markerPosition nearRoads _roadRadius;
    if (count _road > 1) exitWith {};
    _roadRadius = _roadRadius + 5;
};
Code Explanation: Initializes tracking arrays for vehicles, effects, and groups. Gets the marker position and searches for nearby roads. The loop expands the search radius from 5 meters until at least one road is found within the area, ensuring the crash occurs on a road network.

Sqf

Apply
private _roadcon = roadsConnectedto (selectRandom _road);
private _dirveh = if(count _roadcon > 0) then {[_road select 0, _roadcon select 0] call BIS_fnc_dirTo} else {random 360};
private _roadPosition = getPos (_road select 0);

private _crater = createVehicle ["Crater", _roadPosition, [], 0, "NONE"];

private _vehicleClass = selectRandom ((A3A_faction_riv get "vehiclesRivalsCars") + (A3A_faction_riv get "vehiclesRivalsLightArmed"));
private _crashedVehicle = createVehicle [_vehicleClass, [_roadPosition select 0, _roadPosition select 1, 0.2], [], 0, "CAN_COLLIDE"];
_crashedVehicle setDir _dirveh;
_crashedVehicle setDamage 0.7;
_crashedVehicle setHit ["wheel_2_1_steering", 1];
_crashedVehicle setHit ["wheel_1_1_steering", 1];
_crashedVehicle setFuel 0.3;
[_crashedVehicle, Rivals] call A3A_fnc_AIVEHinit;

_vehicles append [_crater, _crashedVehicle];

[_roadPosition, _effects] call _fnc_fire;
Code Explanation: Determines the crash orientation based on connected roads, creates a crater effect, and spawns a crashed vehicle from the Rivals vehicle pool. The vehicle is damaged (70% damage), has specific wheel components destroyed, and reduced fuel. It's initialized with Rivals faction using A3A_fnc_AIVEHinit. The fire effect function is called to add burning wreckage effects.

4. Damaged Building Logic
Sqf

Apply
private _damagedBuildings = (nearestObjects [_roadPosition, ["house"], 350]) select {(count ([_x] call BIS_fnc_buildingPositions)) > 0};
private _damagedBuilding = nil;
if (count _damagedBuildings > 0) then {
	_damagedBuilding = selectRandom _damagedBuildings;
	_damagedBuilding setDamage ((random 0.5)+0.4);
	private _damagedBuildingPos = position _damagedBuilding;
	private _damagedBuildingCollision = 2 boundingBoxReal _damagedBuilding;
	private _p1 = _damagedBuildingCollision select 0;
	private _p2 = _damagedBuildingCollision select 1;
	private _maxHeight = abs ((_p2 select 2) - (_p1 select 2));

	private _bAtlPos = (getPosATL _damagedBuilding);
	private _bMinHeightAsl = ATLToASL _bAtlPos;
	private _bMaxHeightAsl = ATLToASL ([_bAtlPos select 0, _bAtlPos select 1, _maxHeight]);

	private _realRoofHeightAsl = ((lineIntersectsSurfaces [_bMaxHeightAsl, _bMinHeightAsl]) select 0) select 0;

	if (!isNil "_realRoofHeightAsl") then {
		private _smoke = createVehicle ["test_EmptyObjectForSmoke", _damagedBuildingPos, [], 0 , "CAN_COLLIDE"];
		_smoke setPosASL _realRoofHeightAsl;
		_effects pushBack _smoke;
	};
	_damagedBuilding animate ["door_1A_move",1];
	_damagedBuilding animate ["door_1B_move",1];
	_damagedBuilding animate ["door_2_rot",1];
	_damagedBuilding animate ["door_3_rot",1];
};
Code Explanation: Finds buildings with interior positions within 350 meters and randomly damages one. The damage is between 0.4-0.9 to make it look battle-damaged. It calculates the building's dimensions using bounding boxes and determines the roof height using raycasting (lineIntersectsSurfaces). A smoke particle is placed on the roof at the calculated ASL position to simulate smoke rising from damaged buildings. All doors are animated open to show battle damage. This creates environmental storytelling about the battle that occurred.

5. Dead Leader Creation
Sqf

Apply
private _leaderIntelGroup = createGroup Rivals;
private _intelLeader = [_leaderIntelGroup, A3A_faction_riv get "unitCL", _markerPosition, [], 0, "NONE"] call A3A_fnc_RivalsCreateUnit;
_intelLeader setVariable ["canBeInterrogated", true]; //to remove search intel action
_intelLeader setDamage 0.7;
_intelLeader setCaptive true;
_intelLeader removeItems "FirstAidKit";
_intelLeader setSpeaker "NoVoice";
_intelLeader allowDamage false;
private _hmd = hmd _intelLeader;
_intelLeader unassignItem _hmd;
_intelLeader removeItem _hmd;
{_intelLeader disableAI _x} forEach ["CHECKVISIBLE", "MOVE", "COVER", "SUPPRESSION", "FSM", "TARGET", "AUTOTARGET", "ANIM"];
removeAllActions _intelLeader;

_groups pushBack _leaderIntelGroup;
Code Explanation: Creates a Rivals group and spawns a unit leader (Commander type) at the marker position. The leader is critically wounded (70% damage), set as captive (non-hostile initially), and stripped of medical items. The HMD (head-mounted display) is removed to prevent night vision. All AI behaviors are disabled to make the unit act as a static prop. All actions are removed to prevent interactions until the mission progresses.

6. Death Animation and Intel Placement
Sqf

Apply
private _anim = selectRandom [
	"Acts_StaticDeath_01",
	"Acts_StaticDeath_02",
	"Acts_StaticDeath_03",
	"Acts_StaticDeath_04", 
	"Acts_StaticDeath_05",
	"Acts_StaticDeath_05", 
	"Acts_StaticDeath_06",
	"Acts_StaticDeath_07",
	"Acts_StaticDeath_08",
	"Acts_StaticDeath_09",
	"Acts_StaticDeath_10"
];
[_intelLeader, _anim] remoteExecCall ["switchMove", _intelLeader];
private _timeOut = time + 2;
waitUntil {_timeOut < time};

_intelLeader setDamage 1;

if (!isNil "_damagedBuilding") then {
	private _emptyPos = [];
	_emptyPos = (getPosATL _damagedBuilding) findEmptyPosition [0,100, "C_Hatchback_01_sport_F"];

	if (_emptyPos isEqualTo []) then {
		private _vehPos = position _crashedVehicle;
		private _emptyPos = [
			_vehPos, 
			2,
			50,
			5,
			0, //water mode
			1, //maximum terrain gradient
			0, //shore mode
			[], //blacklist positions
			[_vehPos, _vehPos] //default position
		] call BIS_fnc_findSafePos;
		_emptyPos = selectRandom ([_damagedBuilding] call BIS_fnc_buildingPositions);
	};

	_intelLeader setPos _emptyPos;
	[(position _damagedBuilding), _effects] call _fnc_fire;
} else {
	private _vehPos = position _crashedVehicle;
	private _leaderPosition = [
		_vehPos, 
		2,
		50,
		5,
		0, //water mode
		1, //maximum terrain gradient
		0, //shore mode
		[], //blacklist positions
		[_vehPos, _vehPos] //default position
	] call BIS_fnc_findSafePos;

	_intelLeader setPos _leaderPosition;
};
Code Explanation: Applies a random death animation to the leader and waits 2 seconds for the animation to play, then kills the unit (setDamage 1). If a damaged building was found, the leader is moved to an empty position near the building or inside it, and additional fire is spawned at the building location. If no building is found, the leader is placed in a safe position near the crashed vehicle. This creates a scene where the leader is found dead, often near or inside a damaged structure.

7. Blood and Forensic Details
Sqf

Apply
private _bloodSplat = createVehicle [
	(selectRandom ["BloodPool_01_Large_New_F", "BloodSplatter_01_Large_New_F", "BloodSplatter_01_Medium_New_F", "BloodPool_01_Medium_New_F"]),
	(position _intelLeader),
	[], 
	0,
	"CAN_COLLIDE"
];

private _grassCutter = createVehicle [
	"Land_ClutterCutter_medium_F",
	(position _intelLeader),
	[], 
	0,
	"CAN_COLLIDE"
];

private _position = [(position _intelLeader), 1, (random 360)] call SCRT_fnc_misc_extendPosition;
private _laptopPosition = [_position select 0, _position select 1, ((getPosATL _intelLeader) select 2) + 1];
Code Explanation: Creates blood splatter objects near the leader to simulate forensic evidence. A grass cutter is placed to clear vegetation around the body. The position is extended by 1 meter in a random direction to place the laptop slightly away from the body. The laptop's Z-coordinate is raised by 1 meter above the leader's height to simulate it being on a surface or held.

8. Laptop Creation and Flag Action
Sqf

Apply
private _laptop = [
	(selectRandom ["Land_laptop_03_closed_black_F", "Land_laptop_03_closed_sand_F", "Land_laptop_03_closed_olive_F"]),
	_laptopPosition,
	(random 360)
] call SCRT_fnc_misc_createBelonging;
[_laptop, "rivals_quest"] remoteExec ["A3A_fnc_flagaction", [teamPlayer,civilian], _laptop];
Code Explanation: Creates a closed laptop at the calculated position with random orientation. The laptop is created using SCRT_fnc_misc_createBelonging (likely creates the object with proper initialization). A flag action is added remotely to make the laptop interactable, with the action type "rivals_quest" which players can use to access intel.

9. Additional Dead Rivals Spawn
Sqf

Apply
private _rivalsGroup = createGroup Rivals;
private _rivalsClasses = selectRandom (A3A_faction_riv get "groupsSentry"); 
for "_i" from 0 to count _rivalsClasses - 1 do {
	private _bodyPosition = [
		_roadPosition, //center
		5, //minimal distance
		50, //maximumDistance
		10, //object distance
		0, //water mode
		0, //maximum terrain gradient
		0, //shore mode
		[], //blacklist positions
		[_roadPosition, _roadPosition] //default position
	] call BIS_fnc_findSafePos;
    private _soldier = [_rivalsGroup, (_rivalsClasses select _i), _bodyPosition, [], 0, "NONE"] call A3A_fnc_RivalsCreateUnit;
    [_soldier] call A3A_fnc_NATOinit;

	private _anim = selectRandom [
		"Acts_StaticDeath_01",
		"Acts_StaticDeath_02",
		"Acts_StaticDeath_03",
		"Acts_StaticDeath_04", 
		"Acts_StaticDeath_05",
		"Acts_StaticDeath_06",
		"Acts_StaticDeath_07",
		"Acts_StaticDeath_08",
		"Acts_StaticDeath_09",
		"Acts_StaticDeath_10"
	];
	[_soldier, _anim] remoteExecCall ["switchMove", _soldier];
	sleep 0.5;
	_soldier setDamage 1;
	private _dir = [_soldier, _crashedVehicle] call BIS_fnc_dirTo;
	_soldier setDir (_dir - 180);
	_soldier removeItems "FirstAidKit";	
};

_groups pushBack _rivalsGroup;
Code Explanation: Creates an additional group of dead Rivals (using a sentry composition). For each unit in the squad composition, it finds a safe position near the crash site, spawns the unit, initializes it with NATO init (sets up basic properties), applies a random death animation, kills the unit, orients it facing away from the crashed vehicle (simulating a tactical retreat or defensive posture), and removes first aid kits. This creates a more detailed combat aftermath scene.

10. Intel Notification and Task Creation
Sqf

Apply
[format [(localize "STR_rivals_intel"), A3A_faction_occ get "name"], true] remoteExec ["A3A_fnc_showIntel", [teamPlayer, civilian]];

sleep 2;

_vehicles append [_laptop, _bloodSplat, _grassCutter];

private _taskId = "RIV_ENC" + str A3A_taskCount;
private _intelLeaderPosition = position _intelLeader;

[
    [teamPlayer,civilian],
    _taskId,
    [
        format [(localize "STR_rivals_quest_description"),A3A_faction_occ get "name"],
        (localize "STR_rivals_quest_header"),
        _marker
    ],
    _intelLeaderPosition,
    false,
    0,
    true,
    "navigate",
    true
] call BIS_fnc_taskCreate;
[_taskId, "RIV_ENC", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Code Explanation: Displays an intel notification about finding Rivals information. Adds the laptop, blood splatter, and grass cutter to the vehicles cleanup array. Creates a task with the localized strings for the mission description and header, setting the task type to "navigate" with map markers enabled. The task is created for both teamPlayer (rebel players) and civilian sides. The task is then marked as "CREATED" via remote execution to update all relevant clients.

11. Player Proximity Detection
Sqf

Apply
waitUntil {
    sleep 2;
    (call SCRT_fnc_misc_getRebelPlayers) findIf {_x distance2D _roadPosition <= distanceSPWN} != -1
};

waitUntil {sleep 2;!isNil "rivalsLaptop"};

sleep 2.5;

["Music_Roaming_Night_Fragment_02_30s"] remoteExecCall ["playMusic", [teamPlayer, civilian]];
Code Explanation: Waits until rebel players are within distanceSPWN (spawn distance) of the crash site. Then waits for the global variable rivalsLaptop to be set (likely when the laptop is interacted with). After a delay, plays background music for atmosphere. This creates a phased mission start where players approach, interact with the laptop, and then the mission escalates.

12. Trap and Explosion Sequence
Sqf

Apply
[ 
	"RivalsActivityDetected", 
	[ 
		(localize "STR_rivals_unknown_transmission_header"), 
		"SWYgeW91J3JlIHJlYWRpbmcgdGhpcyB5b3UncmUgYXdlc29tZSE" 
	] 
] remoteExecCall ["BIS_fnc_showNotification", [teamPlayer, civilian]];

sleep 8;

_nul = [] spawn {
	sleep 60;
	[ 
		format [(localize "STR_rivals_intel_first_task"), ([] call SCRT_fnc_misc_getWorldName), A3A_faction_riv get "name", A3A_faction_riv get "nameLeader"], true 
	] remoteExec ["A3A_fnc_showIntel", [teamPlayer, civilian]];
};

//laptop may be changed in the rivals_searchData thus why global var is used there
[_intelLeader, _marker] spawn {
	params ["_intelLeader", "_marker"];

	sleep 4;

	playSound3D ["x\A3A\addons\core\Sounds\Misc\BombCountdown.ogg", rivalsLaptop, false, getPosASL rivalsLaptop, 2.5, 1, 100]; 

	private _timeOut = time + 2;
	waitUntil {_timeOut < time};

	private _charge = "DemoCharge_Remote_Ammo_Scripted" createVehicle [0,0,0]; 
	_charge setPosWorld (position rivalsLaptop); 
	_charge setDamage 1; 

	_intelLeader allowDamage true;
	_intelLeader setDamage 1;
	deleteVehicle rivalsLaptop;

	[_marker, false, 1000] spawn A3A_fnc_blackout;
};
Code Explanation: Displays a notification about detecting Rivals activity with an encoded message. After 8 seconds, schedules an intel reveal about the Rivals leader. A separate script block runs on the server to handle the laptop trap: plays a 3D sound of a bomb countdown, waits 2 seconds, creates a scripted demo charge at the laptop's position, damages it (causing explosion), kills the intel leader (revising the kill count), deletes the laptop, and triggers a blackout effect at the marker within 1000 meters. This creates a trap scenario where the laptop triggers a counter-attack.

13. Roving Mortar and Task Update
Sqf

Apply
Info("Laptop is activated, spawning additional group.");

(90 call SCRT_fnc_misc_getTimeLimit) params ["_dateLimitNum", "_displayTime"];

sleep 2;

[[_markerPosition, true], "SCRT_fnc_rivals_encounter_rovingMortar"] call A3A_fnc_scheduler;

[
    [teamPlayer,civilian],
    _taskId,
    [
		format [(localize "STR_rivals_quest_update_description"), _displayTime],
		format [(localize "STR_rivals_quest_update_header"), A3A_faction_riv get "name"],
        _marker
    ],
    _roadPosition,
    false,
    0,
    true,
    "navigate",
    true
] call BIS_fnc_taskCreate;
[_taskId, "RIV_ENC", "ASSIGNED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
_taskId call BIS_fnc_taskSetCurrent;
Code Explanation: Logs activation and calculates a 90-minute time limit. Schedules a roving mortar encounter (likely mortar attacks on player positions). Updates the task with a new description and header indicating the fight continues. Marks the task as "ASSIGNED" and sets it as current. This transitions the mission from investigation to active combat.

14. Reinforcement Spawning
Sqf

Apply
private _group1Position = [
		_roadPosition, //center
		400, //minimal distance
		700, //maximumDistance
		2, //object distance
		0, //water mode
		0, //maximum terrain gradient
		0, //shore mode
		[], //blacklist positions
		[_roadPosition, _roadPosition] //default position
	] call BIS_fnc_findSafePos;
private _group1 = [_group1Position, Rivals, selectRandom (A3A_faction_riv get "groupsFireteam")] call A3A_fnc_RivalsSpawnGroup;
_groups pushBack _group1;
private _group1Wp = _group1 addWaypoint [_laptopPosition, 5];
_group1Wp setWaypointType "MOVE";
_group1Wp setWaypointCombatMode "YELLOW";
_group1Wp setWaypointSpeed "FULL";
// _group1 spawn A3A_fnc_attackDrillAI;

private _group2Position = [
		_roadPosition, //center
		400, //minimal distance
		700, //maximumDistance
		2, //object distance
		0, //water mode
		0, //maximum terrain gradient
		0, //shore mode
		[], //blacklist positions
		[_roadPosition, _roadPosition] //default position
	] call BIS_fnc_findSafePos;
private _group2 = [_group2Position, Rivals, selectRandom (A3A_faction_riv get "groupsFireteam")] call A3A_fnc_RivalsSpawnGroup;
_groups pushBack _group2;
private _group2Wp = _group2 addWaypoint [_laptopPosition, 5];
_group2Wp setWaypointType "MOVE";
_group2Wp setWaypointCombatMode "YELLOW";
_group2Wp setWaypointSpeed "FULL";
// _group2 spawn A3A_fnc_attackDrillAI;

{
	[_x] call A3A_fnc_NATOinit;
} forEach ((units _group1) + (units _group2));
Code Explanation: Spawns two Rivals fireteams at positions 400-700 meters from the crash site. Each group gets waypoints to move to the laptop position with combat mode "YELLOW" (fire at will) and speed "FULL". All units are initialized with NATO init. These groups represent reinforcements rushing to recover the intelligence or eliminate the intruders.

15. Enemy Vehicle Spawn
Sqf

Apply
_road = objNull;
_roadRadius = 5;

while {true} do {
    _road = _group1Position nearRoads _roadRadius;
    if (count _road > 1) exitWith {};
    _roadRadius = _roadRadius + 5;
};

_roadcon = roadsConnectedto (selectRandom _road);
_dirveh = if(count _roadcon > 0) then {[_road select 0, _roadcon select 0] call BIS_fnc_DirTo} else {random 360};
_roadPosition = getPos (_road select 0);

private _rivalVehData = [_roadPosition, 0, selectRandom (A3A_faction_riv get "vehiclesRivalsLightArmed"), Rivals] call A3A_fnc_RivalsSpawnVehicle;
private _rivalVeh = _rivalVehData select 0;
[_rivalVeh, Rivals] call A3A_fnc_AIVEHinit;
private _rivalVehCrew = _rivalVehData select 1;
{[_x] call A3A_fnc_NATOinit} forEach _rivalVehCrew;
private _rivalVehGroup = _rivalVehData select 2;

private _rivalVehGroupWp = _rivalVehGroup addWaypoint [_laptopPosition, 5];
_rivalVehGroupWp setWaypointType "MOVE";
_rivalVehGroupWp setWaypointCombatMode "YELLOW";
_rivalVehGroupWp setWaypointSpeed "NORMAL";

_groups pushBack _rivalVehGroup;
_vehicles pushBack _rivalVeh;
Code Explanation: Finds a road near the first reinforcement group, determines its direction, and spawns a light armed vehicle with crew. The vehicle is initialized as a Rivals vehicle, and all crew members are initialized with NATO init. The vehicle group gets a waypoint to the laptop position with normal speed. The vehicle and group are added to tracking arrays for cleanup.

16. Mission Completion Check
Sqf

Apply
private _aliveCount = 0;
private _isEveryoneDead = false;

waitUntil  {
	sleep 5;
	_aliveCount = {alive _x} count ((units _group1) + (units _group2));
	_isEveryoneDead = (call SCRT_fnc_misc_getRebelPlayers) findIf {alive _x && {_x distance2D _intelLeaderPosition < 1000}} == -1;
	Info_2("%1 Group Alive: %2", A3A_faction_riv get "name", str _aliveCount);
	(dateToNumber date > _dateLimitNum) || {_aliveCount < 2 || {_isEveryoneDead}} 
};

switch (true) do {
	case (dateToNumber date > _dateLimitNum): {
		Info("Date limit exceeded");
	};
	case (_aliveCount < 2): {
		Info("Rivals squad has less than 2 alive members.");
	};
	case (_isEveryoneDead): {
		Info("Everyone is dead");
	};
};
Code Explanation: Monitors the mission every 5 seconds. Tracks alive count of reinforcement groups and checks if all rebel players near the area are dead. The mission ends when the time limit is exceeded, fewer than 2 Rivals remain alive, or all rebel players in the area are dead. A switch statement logs the reason for mission completion.

17. Reward Distribution
Sqf

Apply
if (dateToNumber date < _dateLimitNum && {(call SCRT_fnc_misc_getRebelPlayers) findIf {alive _x && {_x distance2D _intelLeaderPosition < 1000}} != -1}) then {
	[0,10,_markerPosition] remoteExec ["A3A_fnc_citySupportChange",2];
	{ 
		[10,_x] call A3A_fnc_addScorePlayer;
    	[300,_x] call A3A_fnc_addMoneyPlayer;
	 } forEach (call SCRT_fnc_misc_getRebelPlayers);
	[10,theBoss] call A3A_fnc_addScorePlayer;
    [200,theBoss, true] call A3A_fnc_addMoneyPlayer;
};
Code Explanation: If the time limit hasn't been exceeded and at least one rebel player is alive in the area, rewards are distributed. City support is increased by 10 points. All rebel players receive 10 score and 300 money. The boss gets 10 score and 200 money. This rewards successful completion of the investigation and combat objectives.

18. Cleanup and Task Deletion
Sqf

Apply
sleep 10;
[] remoteExecCall ["SCRT_fnc_rivals_activate", 2];
[_taskId, "RIV_ENC", "SUCCEEDED"] call A3A_fnc_taskSetState;

sleep 30;

{deleteVehicle _x} forEach _effects;
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;

[_taskId, "RIV_ENC", 1200] spawn A3A_fnc_taskDelete;

Info("Investigate the Battleground task cleanup completed.");
Code Explanation: Waits 10 seconds, activates Rivals globally (likely makes them active on the map), marks the task as "SUCCEEDED", waits 30 seconds for players to secure the area, then cleans up all effects (fire, smoke), vehicles, and groups using appropriate despawn functions. Finally, schedules task deletion after 1200 seconds (20 minutes). This ensures proper cleanup and finalizes the mission.

Where it leads:

Functions Called:

BIS_fnc_findSafePos - Finds safe spawn positions for units and objects
A3A_fnc_AIVEHinit - Initializes AI vehicles with proper settings
A3A_fnc_RivalsCreateUnit - Creates Rivals faction units
SCRT_fnc_misc_extendPosition - Extends positions with offset
SCRT_fnc_misc_createBelonging - Creates belongings/laptop objects
A3A_fnc_flagaction - Adds interactable actions to objects
A3A_fnc_RivalsSpawnGroup - Spawns Rivals groups
A3A_fnc_NATOinit - Initializes units with NATO/Rivals properties
A3A_fnc_RivalsSpawnVehicle - Spawns Rivals vehicles
A3A_fnc_scheduler - Schedules delayed events
A3A_fnc_taskCreate - Creates mission tasks
A3A_fnc_taskUpdate - Updates task state remotely
A3A_fnc_taskSetState - Sets final task state
A3A_fnc_taskSetCurrent - Sets task as current
A3A_fnc_taskDelete - Deletes task after delay
SCRT_fnc_rivals_encounter_rovingMortar - Spawns mortar encounters
A3A_fnc_citySupportChange - Modifies city support
A3A_fnc_addScorePlayer - Adds score to players
A3A_fnc_addMoneyPlayer - Adds money to players
SCRT_fnc_rivals_activate - Activates Rivals globally
A3A_fnc_vehDespawner - Despawns vehicles
A3A_fnc_groupDespawner - Despawns groups
A3A_fnc_blackout - Creates blackout effects
Functions That Depend on This:

A3A_fnc_missionRequest - May request this mission through the scheduler
SCRT_fnc_rivals_encounter_rovingMortar - Called by this function for mortar support
A3A_fnc_searchIntelOnLeader - May be triggered when interrogating the leader
A3A_fnc_searchIntelOnLaptop - Used when searching the laptop
Global Variables Modified:

rivalsLaptop - Set to the laptop object when created
A3A_taskCount - Incremented when creating tasks
areRivalsDiscovered - May be set to true after mission completion
A3A_curHQInfoInv - May be modified in related functions
Rivals - Side object used for group creation
System Integration:

Part of the Rivals intelligence gathering system
Triggers when players enter investigation zones
Creates narrative-driven combat scenarios
Provides rewards for completing investigations
Reveals more about Rivals faction lore
Acts as a gateway to other Rivals missions
Network Implications:

Most effects and unit creations run on server only
Remote execution used for notifications, music, and task updates
Client-side effects are created via remoteExec
Global variables synchronized for mission state
Task management synced across all players
Edge Cases:

If no roads found, mission may spawn on flat terrain (handled by while loop expansion)
If no buildings found, leader spawns near crash site instead
If laptop position is invalid, fallback position used
If time limit exceeded, mission fails but rewards partial progress
If all players die, mission fails (Rivals may recover intelligence)
Error Handling:

Early exit if not server or if Rivals already discovered/defeated
Fallback positions used when ideal spawn positions unavailable
Validation of building existence before accessing its properties
Group creation checks before waypoint assignment
Performance Considerations:

Fire and particle effects limited to 3-6 instances
Small reinforcement groups (fireteams, not large squads)
Time-limited mission prevents infinite active objects
Cleanup after completion prevents object accumulation
Roadfinding uses progressive expansion to avoid performance hits
Replay Value:

Random vehicle selection from Rivals pool
Random building selection and damage levels
Random leader position within area
Random dead squad composition
Random reinforcement spawn locations
Random fire effect positions
Technical Details:

Uses ASL (Above Sea Level) positioning for precise building height calculation
Uses boundingBoxReal for accurate building dimensions
Uses lineIntersectsSurfaces for roof height detection
Uses setPosASL for precise particle placement
Uses remoteExecCall with target [teamPlayer, civilian] for multiplayer
Uses createVehicle with empty arrays for spawning without crew
Uses removeAllActions to prevent premature interaction
Uses setCaptive to control unit hostility
Uses disableAI to create static props
Uses animate for building destruction effects
Function Name: fn_RIV_RES_Prisoners.sqf
What it does: This function creates and manages the "Rescue Prisoners" mission for Rivals. It spawns a group of prisoners (rebels) held captive in or near a building, with Rivals guards patrolling the area. Players must rescue all prisoners and extract them to a safe location (usually the mission HQ or spawn point).

The mission features dynamic difficulty based on tierWar level, with additional patrols and traps for difficult missions. Prisoners are initially invulnerable until combat starts, then must be protected. Rewards are scaled based on the number of prisoners rescued and mission difficulty.

How it does that:

1. Initialization and Difficulty Setup
Sqf

Apply
params ["_markerX"];

//Mission: Rescue the prisoners
if (!isServer and hasInterface) exitWith{};

private _faction = A3A_faction_riv;

private _difficultX = random 10 < tierWar && {([] call SCRT_fnc_rivals_rollProbability)};
private _positionX = getMarkerPos _markerX;

private _groups = [];
private _POWs = [];
Code Explanation: Accepts a marker parameter for the mission location. Validates server execution. Sets the faction to Rivals. Calculates difficulty flag: if random(10) is less than tierWar (war level) AND a rivals probability check passes, the mission becomes difficult. Initializes tracking arrays for groups and prisoners (POWs).

2. Time Limit Calculation
Sqf

Apply
private _limit = if (_difficultX) then {
	45 call SCRT_fnc_misc_getTimeLimit
} else {
	120 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];

private _nameDest = [_markerX] call A3A_fnc_localizar;

private _taskId = "RES" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_A3A_Missions_RIV_RES_Prisoners_task_desc",_faction get "name", _nameDest, _displayTime],localize "STR_A3A_Missions_RIV_RES_Prisoners_task_header",_markerX],_positionX,false,0,true,"run",true] call BIS_fnc_taskCreate;
[_taskId, "RES", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Code Explanation: Sets a 45-minute time limit for difficult missions and 120 minutes for standard missions. Converts the limit to a date number for time comparison. Localizes the destination name. Creates a task with localized description and header, set to "run" type with map markers. The task is created for rebel and civilian sides, then marked as CREATED.

3. Prison Location Selection
Sqf

Apply
private _posHouse = [];
private _countX = 0;
//_houses = nearestObjects [_positionX, ["house"], 50];
private _houses = (nearestObjects [_positionX, ["house"], 50]) select {!((typeOf _x) in A3A_buildingBlacklist)};
private _houseX = "";
private _potentials = [];
for "_i" from 0 to (count _houses) - 1 do {
	_houseX = (_houses select _i);
	_posHouse = [_houseX] call BIS_fnc_buildingPositions;
	if (count _posHouse > 1) then {_potentials pushBack _houseX};
};

if (count _potentials > 0) then {
	_houseX = selectRandom _potentials;
	_posHouse = [_houseX] call BIS_fnc_buildingPositions;
	_countX = (count _posHouse) - 1;
	if (_countX > 7) then {_countX = 7};
} else {
	_countX = round random 7;
	for "_i" from 0 to _countX do {
		_postmp = [_positionX, 5, random 360] call BIS_Fnc_relPos;
		_posHouse pushBack _postmp;
	};
};
Code Explanation: Searches for buildings within 50 meters, filtering out blacklisted building types (likely unsuitable structures). Collects buildings with more than one interior position. If suitable buildings are found, randomly selects one and uses its interior positions for prisoner placement, limiting to 7 positions maximum. If no suitable buildings are found, generates random positions around the marker within 5 meters, creating a field prison scenario. This provides variety in mission locations.

4. Prisoner Creation
Sqf

Apply
private _grpPOW = createGroup teamPlayer;

for "_i" from 0 to _countX do {
	private _unit = [_grpPOW, FactionGet(reb,"unitUnarmed"), (_posHouse select _i), [], 0, "NONE"] call A3A_fnc_createUnit;
	[_unit, createHashMapFromArray [["face", selectRandom (A3A_faction_reb get "faces")], ["speaker", selectRandom (A3A_faction_reb get "voices")]]] call A3A_fnc_setIdentity;
	_unit allowDamage false;
	_unit setCaptive true;
	_unit disableAI "MOVE";
	_unit disableAI "AUTOTARGET";
	_unit disableAI "TARGET";
	_unit setUnitPos "UP";
	_unit setBehaviour "CARELESS";
	_unit allowFleeing 0;
	//_unit disableAI "ANIM";
	removeAllWeapons _unit;
	removeAllAssignedItems _unit;
	sleep 1;
	//if (alive _unit) then {_unit playMove "UnaErcPoslechVelitele1";};
	_POWS pushBack _unit;
	[_unit,"prisonerX"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_unit];
	[_unit] call A3A_fnc_reDress;
};

_groups pushBack _grpPOW;

sleep 5;

{_x allowDamage true} forEach _POWS;
Code Explanation: Creates a rebel group for prisoners. Spawns unarmed rebel units at each position. Randomizes identity (face and voice) from rebel faction data. Sets prisoners as invulnerable initially, captive, and disables all AI behaviors to make them static prisoners. Removes all weapons and items. Adds a "prisonerX" action for interaction. Redresses prisoners (likely sets uniform). After 5 seconds, makes prisoners vulnerable so they can be killed if caught in combat.

5. Mission State Monitoring
Sqf

Apply
waitUntil {sleep 1; 
{alive _x} count _POWs == 0 or 
{(call SCRT_fnc_misc_getRebelPlayers) inAreaArray [getMarkerPos _markerX, distanceSPWN1, distanceSPWN1] isNotEqualTo [] or
{{(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 50)} count _POWs > 0 or 
{dateToNumber date > _dateLimitNum
}}}};
Code Explanation: Waits in a loop checking multiple conditions every second: all prisoners are dead, rebel players are within spawn distance of the marker, any living prisoner is within 50 meters of the mission HQ/spawn point (rescued), or the time limit is exceeded. This complex waitUntil ensures the mission progresses when appropriate conditions are met.

6. Guard Patrol Spawning (if prisoners alive)
Sqf

Apply
private _patrolMrk = nil;

if (dateToNumber date < _dateLimitNum && {alive _x} count _POWs > 0) then {
	private _patrolCount = nil;
	private _patrolPool = nil;

	if (_difficultX) then {
		_patrolCount = 2;
		_patrolPool = (_faction get "groupsSquad") + (_faction get "groupsFireteam");
	} else {
		_patrolCount = 1;
		_patrolPool = (_faction get "groupsFireteam");
	};

	_patrolMrk = createMarkerLocal [format ["%1patrolarea", floor random 10000], (position _houseX)];
	_patrolMrk setMarkerShapeLocal "RECTANGLE";
	_patrolMrk setMarkerSizeLocal [50,50];
	_patrolMrk setMarkerTypeLocal "hd_warning";
	_patrolMrk setMarkerColorLocal "ColorRed";
	_patrolMrk setMarkerBrushLocal "DiagGrid";
	_patrolMrk setMarkerAlphaLocal 0;

	for "_i" from 1 to _patrolCount do {
		private _patrolGroup = [_positionX, Rivals, (selectRandom _patrolPool)] call A3A_fnc_RivalsSpawnGroup;
		(units _patrolGroup) apply {
			[_x] call A3A_fnc_NATOinit;
		};
		[_patrolGroup, "Patrol_Area", 25, 100, 250, true, _positionX, false] call A3A_fnc_patrolLoop;

		_groups pushBack _patrolGroup;
	};
};
Code Explanation: If the time limit hasn't been exceeded and prisoners are still alive, spawns patrol guards. Difficult missions get 2 patrols from squads or fireteams, while standard missions get 1 patrol from fireteams only. Creates a local warning marker (invisible) to define the patrol area. Spawns Rivals patrol groups and initializes them with NATO init. Uses A3A_fnc_patrolLoop to make them patrol the area with specific parameters (radius, speed, behavior). Adds patrols to the groups tracking array.

7. Additional Difficulty Challenges
Sqf

Apply
if (_difficultX) then {
	[_positionX, 300, 101] spawn SCRT_fnc_rivals_encounter_carDemo;
};
Code Explanation: For difficult missions, spawns a car demo encounter 300 meters from the position with a 101-meter radius. This is likely a vehicle-borne IED or booby-trapped vehicle that players must be careful of, adding tactical complexity to the rescue mission.

8. Time Limit Exceeded Handling
Sqf

Apply
waitUntil {sleep 1; {alive _x} count _POWs == 0 or {{(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 50)} count _POWs > 0 or {dateToNumber date > _dateLimitNum}}};

if (dateToNumber date > _dateLimitNum) then {
	if (spawner getVariable _markerX == 2) then {
		{
			if (group _x == _grpPOW) then {
				_x setDamage 1;
			};
		} forEach _POWS;
	} else {
		{
		if (group _x == _grpPOW) then
			{
			_x setCaptive false;
			_x enableAI "MOVE";
			_x doMove _positionX;
			};
		} forEach _POWS;
	};
};
Code Explanation: When time limit is exceeded, checks the spawner variable for the marker (likely indicating if players are near). If players are near (spawner = 2), kills all prisoners in the POW group. Otherwise, makes prisoners non-captive, enables movement AI, and orders them to move back to the mission position (making them escape or relocate). This creates different failure states based on player proximity.

9. Final Wait and Outcome Detection
Sqf

Apply
waitUntil {sleep 1; {alive _x} count _POWs == 0 or {{(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 50)} count _POWs > 0}};

private _bonus = if (_difficultX) then {2} else {1};

if ({alive _x} count _POWs == 0) then {
	[_taskId, "RES", "FAILED"] call A3A_fnc_taskSetState;
	{[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false} forEach _POWs;
	[-10*_bonus,theBoss] call A3A_fnc_addScorePlayer;

	{ A3A_curHQInfoInv = A3A_curHQInfoInv + 0.15 + random 0.3 } remoteExecCall ["call", 2];
} else {
	sleep 5;
	[_taskId, "RES", "SUCCEEDED"] call A3A_fnc_taskSetState;
	_countX = {(alive _x) and (_x distance getMarkerPos respawnTeamPlayer < 150)} count _POWs;
	_hr = 2 * (_countX);
	_resourcesFIA = 100 * _countX*_bonus;
	[_hr,_resourcesFIA] remoteExec ["A3A_fnc_resourcesFIA",2];
	[0,10*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	[Occupants, -(_countX * 1.5), 90] remoteExec ["A3A_fnc_addAggression",2];

	{
		[_countX, _x] call A3A_fnc_addScorePlayer;
		[_countX*10,_x] call A3A_fnc_addMoneyPlayer;
	} forEach (call SCRT_fnc_misc_getRebelPlayers);

	private _bonusAmount = round (_countX*_bonus/2);
	[_bonusAmount,theBoss] call A3A_fnc_addScorePlayer;
    [(_bonusAmount*10),theBoss, true] call A3A_fnc_addMoneyPlayer;

	{[_x] join _grpPOW; [_x] orderGetin false} forEach _POWs;

	[15*_bonus, (100/baseRivalsDecay)] remoteExec ["SCRT_fnc_rivals_reduceActivity",2];
	[5*_bonus] remoteExecCall ["SCRT_fnc_rivals_addProgressToRivalsLocationReveal", 2];
};
Code Explanation: Waits until prisoners are all dead or rescued. Determines bonus multiplier (2 for difficult, 1 for standard). If all prisoners are dead, marks task as FAILED, removes captive status from all prisoners, subtracts 10bonus score from boss, and increments HQ info inventory (likely intel value). If any prisoners are rescued, marks task as SUCCEEDED, counts survivors within 150 meters of HQ, calculates rewards (HR = 2 per survivor, FIA resources = 100 per survivor * bonus), updates city support, reduces aggression against Occupants. Distributes score and money to all rebel players (score = survivors, money = survivors10*bonus). Bonus goes to boss. Reunites rescued prisoners with the POW group and sets them to not get in vehicles. Reduces Rivals activity and progresses location reveal.

10. Prisoner Equipment Recovery
Sqf

Apply
sleep 60;

private _items = [];
private _ammunition = [];
private _weaponsX = [];
{
	private _unit = _x;
	if (_unit distance getMarkerPos respawnTeamPlayer < 150) then {
		{if (not(([_x] call BIS_fnc_baseWeapon) in unlockedWeapons)) then {_weaponsX pushBack ([_x] call BIS_fnc_baseWeapon)}} forEach weapons _unit;
		{if (not(_x in unlockedMagazines)) then {_ammunition pushBack _x}} forEach magazines _unit;
		_items = _items + (items _unit) + (primaryWeaponItems _unit) + (assignedItems _unit) + (secondaryWeaponItems _unit);
	};
	deleteVehicle _unit;
} forEach _POWs;

if (!isNil "_patrolMrk") then {
	deleteMarker _patrolMrk;
};

{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;

{boxX addWeaponCargoGlobal [_x,1]} forEach _weaponsX;
{boxX addMagazineCargoGlobal [_x,1]} forEach _ammunition;
{boxX addItemCargoGlobal [_x,1]} forEach _items;

[_taskId, "RES", 1200] spawn A3A_fnc_taskDelete;
Code Explanation: Waits 60 seconds after mission completion for players to extract. For each rescued prisoner within 150 meters of HQ, collects all weapons (if not unlocked), magazines (if not unlocked), and items. Adds them to the global ammo box. Deletes the prisoner units. Deletes the patrol marker. Despawns all groups. Schedules task deletion after 1200 seconds (20 minutes).

Where it leads:

Functions Called:

SCRT_fnc_rivals_rollProbability - Rolls probability for difficult missions
BIS_fnc_findSafePos - For prisoner position calculations (in some branches)
SCRT_fnc_misc_getTimeLimit - Gets time limit based on difficulty
A3A_fnc_localizar - Localizes location name
BIS_fnc_taskCreate - Creates mission task
BIS_fnc_taskUpdate - Updates task state remotely
BIS_fnc_taskSetState - Sets final task state
BIS_fnc_relPos - Generates relative positions
A3A_fnc_createUnit - Creates prisoner units
A3A_fnc_setIdentity - Sets random identity for prisoners
A3A_fnc_flagaction - Adds interaction to prisoners
A3A_fnc_reDress - Redresses prisoners
SCRT_fnc_misc_getRebelPlayers - Gets list of rebel players
A3A_fnc_RivalsSpawnGroup - Spawns Rivals patrol groups
A3A_fnc_NATOinit - Initializes Rivals units
A3A_fnc_patrolLoop - Creates patrol behavior for guards
SCRT_fnc_rivals_encounter_carDemo - Spawns difficult encounter
A3A_fnc_taskDelete - Deletes task after delay
A3A_fnc_addScorePlayer - Adds score to players
A3A_fnc_addMoneyPlayer - Adds money to players
A3A_fnc_resourcesFIA - Updates faction resources
A3A_fnc_citySupportChange - Updates city support
A3A_fnc_addAggression - Updates aggression levels
SCRT_fnc_rivals_reduceActivity - Reduces Rivals activity
SCRT_fnc_rivals_addProgressToRivalsLocationReveal - Progresses intel reveal
A3A_fnc_groupDespawner - Despawns groups
BIS_fnc_buildingPositions - Gets interior positions from buildings
BIS_fnc_baseWeapon - Extracts base weapon class
spawner variable system - Tracks player proximity
Functions That Depend on This:

A3A_fnc_missionRequest - May request this mission type
A3A_fnc_searchIntelOnDocument - May trigger from prisoner interrogation
SCRT_fnc_rivals_encounter_carDemo - Called for difficult missions
A3A_fnc_resourcesFIA - Receives resource updates from this mission
A3A_fnc_citySupportChange - Receives support updates
Global Variables Modified:

A3A_taskCount - Incremented when creating tasks
tierWar - Used to determine difficulty (read only)
A3A_curHQInfoInv - Modified on mission failure
unlockedWeapons - Checked for equipment recovery
unlockedMagazines - Checked for equipment recovery
respawnTeamPlayer - Used for position checks
boxX - Global ammo box for equipment storage
baseRivalsDecay - Used in activity reduction calculation
Rivals - Side object for group creation
System Integration:

Part of prisoner rescue mission chain
Dynamic difficulty scaling based on game progress
Equipment recovery mechanic for resource gain
City support and aggression system interaction
Rivals activity tracking and progression
Teamwork-focused mission requiring extraction
Network Implications:

Task creation and updates synced across all players
Prisoner state changes (captive, damage) may need remote execution
Patrol group spawns server-side only
Reward distribution remotely executed to all players
Equipment collection synchronized via global box
Edge Cases:

If no buildings found, generates random outdoor positions
If all prisoners killed before reaching HQ, mission fails
If time limit exceeded near players, prisoners killed
If time limit exceeded far from players, prisoners escape
If no equipment to collect, loop still runs but adds nothing
Patrol marker may not exist if no patrols spawned
Error Handling:

Validates building existence before accessing positions
Checks prisoner group existence before operations
Handles missing patrol marker gracefully
Uses safe position finding for outdoor prisoners
Validates spawner variable before using it
Performance Considerations:

Limited to 7 prisoners maximum
Patrol groups limited (1-2 groups)
Equipment recovery has 60-second delay to prevent immediate cleanup
Time limit prevents infinite mission states
Despawning prevents object accumulation
Replay Value:

Random prison location (building or field)
Random number of prisoners (up to 7)
Random prisoner identities
Random difficult encounters (car demo)
Random patrol composition
Dynamic difficulty scaling
Technical Details:

Uses FactionGet to retrieve faction data
Uses createHashMapFromArray for unit identity
Uses setUnitPos and setBehaviour for prisoner AI control
Uses allowFleeing to prevent panic behavior
Uses spawner getVariable for proximity checking
Uses CIVILIAN side for prisoners to avoid faction conflict
Uses remoteExec with target [teamPlayer,civilian] for multiplayer
Uses baseWeapon and base magazine checks for equipment filtering
Uses spawn for delayed cleanup to prevent blocking

Function Name: fn_RIV_SUPP_Salvage.sqf
What it does: This function creates and manages the "Salvage Ambushed Truck" mission for Rivals. It spawns a damaged supply truck that crashed or was ambushed, with dead crew, barricades, and Rivals guards. Players must secure the supplies (food sacks) and transport them to a destination marker (usually a city or FIA outpost).

The mission features road-based ambush scenarios with environmental destruction effects, defensive positions, and enemy patrols. Players need to extract the cargo while dealing with Rivals defenders and potential mines. Rewards scale with difficulty and cargo delivery success.

How it does that:

1. Initialization and Setup
Sqf

Apply
params ["_markerX"];

if (!isServer and hasInterface) exitWith{};

Info_1("Salvage Ambushed Truck Init, marker: %1", _markerX);

private _vehicles = [];
private _groups = [];
private _others = [];
private _isDifficult = random 10 < tierWar && {([] call SCRT_fnc_rivals_rollProbability)};
private _positionX = getMarkerPos _markerX;

private _faction = A3A_faction_riv;
Code Explanation: Accepts destination marker parameter. Validates server execution. Logs initialization with marker name. Initializes tracking arrays for vehicles, groups, and other objects. Calculates difficulty flag (same as other missions). Gets position of destination marker. Sets faction to Rivals.

2. Time Limit and Spawn Position
Sqf

Apply
private _limit = if (_isDifficult) then {
	45 call SCRT_fnc_misc_getTimeLimit
} else {
	60 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];

private _spawnPosition = [_positionX, 600, 1500, 0, 0] call BIS_fnc_findSafePos;
private _bases = citiesX + airportsX + milbases + outposts + seaports + factories + resourcesX + ["Synd_HQ"];
private _isTooCloseToOutposts = _bases findIf { _spawnPosition distance2d (getMarkerPos _x) < 600 || {_spawnPosition inArea _x} } != -1;
private _nearRoads = _spawnPosition nearRoads 100;

if (_isTooCloseToOutposts || _nearRoads isEqualTo []) then {
	private _radiusX = 1500;
    while {true} do {
        _spawnPosition = [
            _positionX, //center
            600, //minimal distance
            _radiusX, //maximumDistance
            0, //object distance
            0, //water mode
            1, //maximum terrain gradient
            0, //shore mode
            [], //blacklist positions
            [_spawnPosition, _spawnPosition] //default position
        ] call BIS_fnc_findSafePos;
		_nearRoads = _spawnPosition nearRoads 100;
        _isTooCloseToOutposts = _bases findIf { _spawnPosition distance2d (getMarkerPos _x) < 600 || {_spawnPosition inArea _x} } != -1;
        if (_isTooCloseToOutposts && {_nearRoads isNotEqualTo []}) exitWith {};
        _radiusX = _radiusX + 1;
    };
};
Code Explanation: Sets time limit (45 minutes for difficult, 60 minutes for standard). Finds a spawn position 600-1500 meters from destination. Checks if spawn is too close to any base (cities, airports, outposts, etc.) or if no roads exist nearby. If conditions aren't met, loops and expands search radius until a valid position is found with nearby roads. This ensures the ambush site is appropriately distant from friendly bases and on a road network.

3. Pathfinding and Road Selection
Sqf

Apply
Info_1("Initial position: %1", _spawnPosition);

private _routeNodes = ([_spawnPosition, _positionX] call A3A_fnc_findPath) apply {_x select 0};

if (_routeNodes isEqualTo []) exitWith {
	Error_1("Couldn't find path from starting position to %1, aborting and rerolling ordinary supplies mission.", _markerX);
	["SUPP"] remoteExec ["A3A_fnc_missionRequest", 2];
};
#if __A3_DEBUG__
	{ 
		private _marker = createMarker [format ["%1salvageDebugNode%2", random 10000, random 10000], _x]; 
		_marker setMarkerType "hd_dot"; 
		_marker setMarkerSize [1, 1]; 
		_marker setMarkerText ""; 
		_marker setMarkerColor "ColorRed"; 
		_marker setMarkerAlpha 1; 
	} forEach _routeNodes;
#endif

private _startNode = _routeNodes select 2;
private _nextNode = _routeNodes select 4;
private _roads = objNull;
private _radiusX = 5;

while {true} do {
    _roads = _startNode nearRoads _radiusX;
    if (count _roads > 0 && {_roads findIf {[position _x, _positionX] call A3A_fnc_arePositionsConnected} != -1}) exitWith {};
    _radiusX = _radiusX + 5;
};

private _startingRoad = _roads select 0;

Info_1("Road position: %1", _startingRoad);

private _startingRoadPosition = getPos _startingRoad;

private _midPoint = [((_startNode select 0) + (_nextNode select 0)) / 2, ((_startNode select 1) + (_nextNode select 1)) / 2];
private _roads = objNull;
private _radiusX = 5;

while {true} do {
    _roads = _midPoint nearRoads _radiusX;
    if (count _roads > 0) exitWith {};
    _radiusX = _radiusX + 5;
};

private _nextRoad = _roads select 0;
private _nextRoadPos = position _nextRoad;

private _midMidPoint = [((_startingRoadPosition select 0) + (_nextRoadPos select 0)) / 2, ((_startingRoadPosition select 1) + (_nextRoadPos select 1)) / 2];
private _roads = objNull;
private _radiusX = 5;

while {true} do {
    _roads = _midMidPoint nearRoads _radiusX;
    if (count _roads > 0) exitWith {};
    _radiusX = _radiusX + 5;
};
private _midRoad = _roads select 0;
private _dirVeh = [_startingRoad, _midRoad] call BIS_fnc_dirTo;
Code Explanation: Finds a road path from spawn to destination using A3A_fnc_findPath (likely A* pathfinding on road network). If no path found, logs error and rerolls as a standard supply mission (not salvage). In debug mode, creates red markers for each node. Selects 3rd and 5th nodes along the path for ambush location. Finds roads near these nodes, ensuring they're connected to the destination. Calculates a midpoint between nodes, finds a road there, then calculates a mid-point again between the starting road and the midpoint road for precise ambush positioning. Determines vehicle orientation based on road direction.

4. Crash Site Creation
Sqf

Apply
Info("Spawning crater...");

private _crater = createVehicle ["CraterLong", _startingRoadPosition, [], 0, "CAN_COLLIDE"];
_crater setDir _dirveh;
_crater setVectorUp surfaceNormal getPos _crater;
_others pushBack _crater;

Info_1("Crater pos: %1", _startingRoadPosition);

Info("Spawning truck...");
Code Explanation: Creates a long crater at the starting road position to simulate an explosion or crash. Sets its direction and aligns it to the surface normal for realistic placement. Adds it to the others cleanup array. Logs positions for debugging.

5. Truck and Cargo Setup
Sqf

Apply
private _crewClasses = [
	A3A_faction_reb get "unitCrew",
	A3A_faction_reb get "unitSniper",
	A3A_faction_reb get "unitLAT",
	A3A_faction_reb get "unitMedic",
	A3A_faction_reb get "unitMG",
	A3A_faction_reb get "unitGL",
	A3A_faction_reb get "unitRifle",
	A3A_faction_reb get "unitSL",
	A3A_faction_reb get "unitEng"
];

private _truckClass = selectRandom (A3A_faction_reb get "vehiclesTruck");
private _truck = createVehicle [_truckClass, [_startingRoadPosition select 0, _startingRoadPosition select 1, 0.9], [], 0, "CAN_COLLIDE"];
_truck setDir _dirVeh;
_truck setDamage (random [0.3,0.5,0.7]);
_truck setHit ["wheel_2_1_steering", 0.5];
_truck setHit ["wheel_1_1_steering", 0.5];
[_truck, teamPlayer] call A3A_fnc_AIVEHinit;
_vehicles pushBack _truck;

Info_2("Truck classname: %1, truck position: %2", _truckClass, getPos _truck);

Info("Adding food sacks to cargo...");

private _foodSacks = createVehicle ["Land_FoodSacks_01_cargo_brown_F", _startingRoadPosition, [], 0, "NONE"];
_foodSacks enableRopeAttach true;
_foodSacks allowDamage false;
[_foodSacks] call A3A_Logistics_fnc_addLoadAction;
private _return = [_truck, _foodSacks] call A3A_Logistics_fnc_canLoad; 
if !(_return isEqualType 0) then { 
	_return set [4, true];
	_return remoteExec ["A3A_Logistics_fnc_load", 2]; 
} else {
	Error_3("For some reason no autologistics load. Vehicle: %1, Cargo: %2, Return: %3", (typeOf _truck), (typeOf _foodSacks), (str _return));
};
Code Explanation: Defines rebel unit classes for dead crew members. Selects a random rebel truck from faction data. Creates the truck at the crash site, raised 0.9 meters to simulate impact. Sets damage to random 30-70% and destroys specific wheel components. Initializes the truck for teamPlayer (rebels). Creates food sacks cargo object, enables rope attachment for logistics, makes it invulnerable, and adds load action. Attempts to auto-load the sacks onto the truck using logistics system. Logs success or failure. This creates a salvageable truck with recoverable supplies.

6. Task Creation and Player Detection
Sqf

Apply
private _nameDest = [_markerX] call A3A_fnc_localizar;
private _taskId = "SUPP" + str A3A_taskCount;
[
	[teamPlayer,civilian],
	_taskId,
	[
		format [localize "STR_A3A_Missions_RIV_SUPP_Salvage_task_desc", _nameDest, _faction get "name", _displayTime],
		localize "STR_A3A_Missions_RIV_SUPP_Salvage_task_header",
		_markerX
	],_startingRoadPosition,false,0,true,"truck",true] call BIS_fnc_taskCreate;
[_taskId, "SUPP", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

Info("Waiting until players will be near the zone.");

waitUntil {
	sleep 1; 
	(call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_startingRoadPosition, distanceSPWN1, distanceSPWN1] isNotEqualTo [] || 
	{dateToNumber date > _dateLimitNum}
};

Info("Setting things in motion...");
Code Explanation: Localizes destination name. Creates a task with localized description and header, using "truck" type. Sets it as CREATED. Waits for rebel players to enter the spawn area or for the time limit to be exceeded before activating the ambush scenario. This prevents spawning guards until players actually arrive.

7. Environmental Effects and Dead Crew
Sqf

Apply
if (dateToNumber date < _dateLimitNum) then {
	for "_i" from 0 to round (random [3,5,6]) do {
		_firePosition = [
			_startingRoadPosition, 
			1,
			20,
			2
		] call BIS_fnc_findSafePos;

		private _fireEffectEmitter = "#particlesource" createVehicle _firePosition;
		[_fireEffectEmitter, "SmallDestructionFire"] remoteExec ["setParticleClass", 0, _fireEffectEmitter];

		private _lightEffectEmitter = "#lightpoint" createVehicle _firePosition; 
		[_lightEffectEmitter, 0.3] remoteExec ["setLightBrightness", 0, _lightEffectEmitter];
		[_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightAmbient", 0, _lightEffectEmitter];
		[_lightEffectEmitter, [0.70, 0.3, 0.3]] remoteExec ["setLightColor", 0, _lightEffectEmitter];

		_others append [_fireEffectEmitter, _lightEffectEmitter];
	};

	Info("Spawning dead crew...");

	private _groupCrew = createGroup teamPlayer;
	for "_i" from 0 to round (random [1,2,3]) do {
		private _position = [
			_startingRoadPosition, //center
			0, //minimal distance
			15, //maximumDistance
			2, //object distance
			0, //water mode
			0, //maximum terrain gradient
			0, //shore mode
			[], //blacklist positions
			[_startingRoadPosition, _startingRoadPosition] //default position
		] call BIS_fnc_findSafePos;
		private _crew = [_groupCrew, selectRandom _crewClasses, _position, [], 0, "NONE"] call A3A_fnc_createUnit;
		[_crew, 0] call A3A_fnc_equipRebel;	
		[_crew] call A3A_fnc_NATOinit;

		_crew setDamage 1;
		private _dir = [_crew, _truck] call BIS_fnc_dirTo;
		_crew setDir (_dir - 180);

		sleep 1.5;
		private _bloodSplat = createVehicle [
			(selectRandom ["BloodPool_01_Large_New_F", "BloodSplatter_01_Large_New_F", "BloodSplatter_01_Medium_New_F", "BloodPool_01_Medium_New_F"]),
			(position _crew),
			[], 
			0,
			"CAN_COLLIDE"
		];
		_others pushBack _bloodSplat;
	};
	_groups pushBack _groupCrew;

	Info("Spawning barricade and static weapon...");
Code Explanation: If time limit not exceeded, spawns 3-6 fire sources around the crash site with particles and lights. Creates dead rebel crew (1-3 units) at random positions within 15 meters. Equips them with rebel gear (0 = default), initializes with NATO init, kills them, and orients them facing away from the truck. Creates blood splatters at each body. Adds crew group to tracking. Spawns barricade and static weapon next.

8. Barricade and Defensive Position
Sqf

Apply
	private _barricadePos = position _nextRoad;
	private _roadcon = roadsConnectedto _nextRoad;
	private _dirBarricade = if (count _roadcon > 0) then {[_nextRoad, _roadcon select 0] call BIS_fnc_dirTo} else {random 360};
	private _barricadeTypes = [
		"Land_Barricade_01_10m_F", 
		"Land_Barricade_01_4m_F", 
		"Land_Fortress_01_bricks_v1_F"
	];

	private _canOpener = createVehicle ["Land_CanOpener_F", _barricadePos, [], 0 , "CAN_COLLIDE"]; 
	_canOpener hideObjectGlobal true;
	private _barricade = createVehicle [selectRandom _barricadeTypes, _barricadePos, [], 0 , "CAN_COLLIDE"]; 
	_canOpener disableCollisionWith _barricade;
	_barricade setDir _dirBarricade;
	_barricade setVectorUp surfaceNormal position _barricade;
	_others append [_canOpener, _barricade];

	private _groupGunner = createGroup Rivals;
	private _staticWeaponClass = selectRandom (_faction get "staticLowWeapons");
	private _weaponPos = [_barricadePos, 7, _dirBarricade + 270] call BIS_Fnc_relPos;
	private _weapon = createVehicle [_staticWeaponClass, _weaponPos, [], 0 , "NONE"];
	_weapon setDir ([_weapon, _truck] call BIS_fnc_dirTo);
	_vehicles pushBack _weapon;

	private _gunner = [_groupGunner, _faction get "unitRifle", _positionX, [], 0, "NONE"] call A3A_fnc_RivalsCreateUnit;
	[_gunner] call A3A_fnc_NATOinit;
	[_gunner, Rivals] call A3A_fnc_AIVEHinit;
	_gunner moveInGunner _weapon;
	_groups pushBack _groupGunner;

	Info_2("Static weapon class: %1, postion: %2", _staticWeaponClass, _weaponPos);
Code Explanation: Uses the next road node for barricade placement. Calculates barricade direction based on road connections. Selects random barricade type from three options. Creates a hidden collision object (can opener) to prevent the barricade from being run through, then disables collision between them. Sets barricade orientation and aligns to surface. Spawns a static weapon (from Rivals low weapons) at 7 meters offset, facing the truck. Creates a Rivals gunner unit, initializes it, and places it in the weapon. Adds gunner group to tracking.

9. Difficulty Enhancements
Sqf

Apply
	if (_isDifficult) then {
		Info("Creating small minefield near ambush.");
		private _minesCount = round random [3,5,7];
		private _mines = (_faction get "minefieldAPERS");
		for "_i" from 1 to _minesCount do {
			private _mineX = createMine [selectRandom _mines, _startingRoadPosition, [], 25];
			Rivals revealMine _mineX;
			_vehicles pushBack _mineX;
	#if __A3_DEBUG__
			teamPlayer revealMine _mineX;
	#endif
		};
	};

	private _patrolPool = if (_isDifficult) then {
		(_faction get "groupsSquad") + (_faction get "groupsFireteam")
	} else {
		(_faction get "groupsFireteam")
	};
Code Explanation: For difficult missions, creates 3-7 APERS (anti-personnel) mines within 25 meters of the crash site. Reveals mines to Rivals side only (players won't see them initially). In debug mode, also reveals to teamPlayer for testing. Determines patrol pool: difficult missions use squads + fireteams, standard missions use only fireteams.

10. Patrol Groups and Defense
Sqf

Apply
	private _barricadePatrolGroup = [_barricadePos, Rivals, (selectRandom _patrolPool)] call A3A_fnc_RivalsSpawnGroup;
	(units _barricadePatrolGroup) apply {
		[_x,""] call A3A_fnc_NATOinit;
	};

	[_barricadePatrolGroup, "Patrol_Defend", 0, 200, -1, true, _barricadePos, false] call A3A_fnc_patrolLoop;
	_groups pushBack _barricadePatrolGroup;

	private _truckPatrolGroup = [_startingRoadPosition, Rivals, (selectRandom _patrolPool)] call A3A_fnc_RivalsSpawnGroup;
	(units _truckPatrolGroup) apply {
		[_x,""] call A3A_fnc_NATOinit;
	};

	[_truckPatrolGroup, "Patrol_Area", 50, 150, 250, true, (position _truck), false] call A3A_fnc_patrolLoop;

	_groups pushBack _truckPatrolGroup;
};
Code Explanation: Spawns two patrol groups: one near the barricade with "Patrol_Defend" behavior (radius 200, moves less), and one near the truck with "Patrol_Area" behavior (50-250 meter range). Both are initialized with NATO init and added to groups tracking. This creates a defensive perimeter around the ambush site.

11. Mission Completion Monitoring
Sqf

Apply
waitUntil {
	sleep 1;
	(_foodSacks inArea [_positionX, 25, 25, 0, false, -1] && isNull attachedTo _foodSacks && isNull ropeAttachedTo _foodSacks) || dateToNumber date > _dateLimitNum;
};

private _factor = [1, 1.5] select (_isDifficult);

switch(true) do {
	case (dateToNumber date > _dateLimitNum): {
		Info("Failure, time is out.");
		[_taskId, "SUPP", "FAILED"] call A3A_fnc_taskSetState;
		[5*_factor,-5*_factor,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[-10*_factor, theBoss] call A3A_fnc_addScorePlayer;
	};
	case (_foodSacks inArea [_positionX, 50, 50, 0, false, -1] && {isNull attachedTo _foodSacks and isNull ropeAttachedTo _foodSacks }): {
		Info("Success, box is in the city.");
		[petros,"hint", format [localize "STR_A3A_Missions_SUPP_Supplies_success", _nameDest], localize "STR_A3A_Missions_SUPP_Supplies_tip_header"] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
		[_taskId, "SUPP", "SUCCEEDED"] call A3A_fnc_taskSetState;
		{ 
			[round (15*_factor),_x] call A3A_fnc_addScorePlayer;
    		[round (300*_factor),_x] call A3A_fnc_addMoneyPlayer;
		} forEach (call SCRT_fnc_misc_getRebelPlayers);
		[5*_factor,theBoss] call A3A_fnc_addScorePlayer;
    	[round (100*_factor), theBoss, true] call A3A_fnc_addMoneyPlayer;
		[-15*_factor, 15*_factor , _markerX] remoteExec ["A3A_fnc_citySupportChange",2];
		Debug("aggroEvent | Rebels won a supply mission");
		[Occupants, -10, 60] remoteExec ["A3A_fnc_addAggression",2];

		[0, round (300 * _factor)] remoteExec ["A3A_fnc_resourcesFIA",2];

		[20*_factor, (100/baseRivalsDecay)] remoteExec ["SCRT_fnc_rivals_reduceActivity",2];
		[10*_factor] remoteExecCall ["SCRT_fnc_rivals_addProgressToRivalsLocationReveal", 2];
	};
	default {
		Error("Unknown mission state, aborting.");
		[_taskId, "LOG", "CANCELED"] call A3A_fnc_taskSetState;
	};
};
Code Explanation: Waits for food sacks to be within the destination area (25x25 meters) and not attached to anything, or for time limit exceeded. Calculates reward factor (1.0 for standard, 1.5 for difficult). Handles three cases: time out = failure with negative rewards, success = delivery completed with positive rewards, default = error handling. Success rewards include score (15factor), money (300factor), boss bonuses, city support (positive and negative for source), aggression reduction, faction resources, Rivals activity reduction, and intel reveal progress.

12. Cleanup
Sqf

Apply
sleep 30;

{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;
{deleteVehicle _x} forEach _others;

deleteVehicle _foodSacks;
private _emptybox = "Land_Pallet_F" createVehicle (getpos _foodSacks);
[_emptybox] spawn A3A_fnc_postmortem;

[_taskId, "SUPP", 900] spawn A3A_fnc_taskDelete;

Info("Salvage ambushed truck cleanup complete.");
Code Explanation: Waits 30 seconds for players to leave area. Despawns vehicles and groups using appropriate functions. Deletes all environmental objects. Deletes the food sacks and creates a pallet in its place (visual placeholder). Schedules the pallet for post-mortem cleanup. Deletes the task after 900 seconds (15 minutes). Logs completion.

Where it leads:

Functions Called:

SCRT_fnc_rivals_rollProbability - Rolls for difficult missions
SCRT_fnc_misc_getTimeLimit - Gets mission time limit
BIS_fnc_findSafePos - Finds spawn and object positions
A3A_fnc_findPath - Finds road path for ambush location
A3A_fnc_arePositionsConnected - Validates road connectivity
BIS_fnc_dirTo - Calculates directions between objects
BIS_fnc_relPos - Calculates relative positions
surfaceNormal - For object alignment
A3A_fnc_AIVEHinit - Initializes vehicles
A3A_Logistics_fnc_addLoadAction - Adds logistics loading action
A3A_Logistics_fnc_canLoad - Checks if object can be loaded
A3A_Logistics_fnc_load - Loads object onto vehicle
A3A_fnc_localizar - Localizes destination name
BIS_fnc_taskCreate - Creates mission task
BIS_fnc_taskUpdate - Updates task state remotely
BIS_fnc_taskSetState - Sets final task state
SCRT_fnc_misc_getRebelPlayers - Gets rebel player list
A3A_fnc_createUnit - Creates dead crew units
A3A_fnc_equipRebel - Equips units with rebel gear
A3A_fnc_NATOinit - Initializes units
A3A_fnc_RivalsSpawnGroup - Spawns Rivals patrol groups
A3A_fnc_patrolLoop - Creates patrol behavior
A3A_fnc_commsMP - Sends communications to players
A3A_fnc_addScorePlayer - Adds score to players
A3A_fnc_addMoneyPlayer - Adds money to players
A3A_fnc_citySupportChange - Updates city support
A3A_fnc_addAggression - Updates aggression levels
A3A_fnc_resourcesFIA - Updates faction resources
SCRT_fnc_rivals_reduceActivity - Reduces Rivals activity
SCRT_fnc_rivals_addProgressToRivalsLocationReveal - Progresses intel
A3A_fnc_vehDespawner - Despawns vehicles
A3A_fnc_groupDespawner - Despawns groups
A3A_fnc_postmortem - Schedules object cleanup
A3A_fnc_taskDelete - Deletes task after delay
Functions That Depend on This:

A3A_fnc_missionRequest - May request this mission type
A3A_Logistics_fnc_canLoad - Used to check cargo loading
A3A_Logistics_fnc_load - Used to load cargo
SCRT_fnc_rivals_encounter_carDemo - May be called by other missions
A3A_fnc_postmortem - Cleans up leftover objects
Global Variables Modified:

A3A_taskCount - Incremented when creating tasks
tierWar - Used for difficulty (read only)
citiesX, airportsX, etc. - Used for base proximity checks
teamPlayer - Used for truck initialization and dead crew
Rivals - Side for patrol groups
petros - Used for success message
theBoss - Used for boss rewards
boxX - Not modified here but referenced in other missions
baseRivalsDecay - Used in activity reduction
unlockedWeapons / unlockedMagazines - Read in other missions
respawnTeamPlayer - Not used here but referenced in mission strings
System Integration:

Part of supply/salvage mission chain
Logistics system integration for cargo handling
Dynamic ambush scenarios based on pathfinding
Difficulty scaling with game progression
Resource management system
Rivals activity tracking
City support and aggression management
Network Implications:

Task creation and updates synced across players
Fire and light effects created via remoteExec
Supply delivery detection uses area checking
Reward distribution remotely executed to all players
Mine reveal logic may need synchronization
Object creation server-side only
Edge Cases:

If no path found, mission rerolls to standard supply mission
If spawn position is invalid, loop expands search
If barricade placement fails, still spawns static weapon
If no rebels available, mission may spawn dead crew anyway
If food sacks not loaded, error logged but mission proceeds
If time limit exceeded before players arrive, mission may fail prematurely

Function Name: 
fn_SUPP_Supplies.sqf
What it does: This function creates and manages a supply delivery mission for the rebel faction (teamPlayer). The player must transport a specific cargo item (a crate) from their base to a designated marker (a town). The mission involves time pressure, potential enemy interference (police patrols), and a dynamic objective area where the player must defend the crate from enemies and continuously stand near it to complete the delivery. It handles task creation, enemy spawning, win/loss conditions, reward distribution, and cleanup.

How it does that:

1. Initialization & Permission Checks

Sqf

Apply
params ["_markerX"];
if (!isServer and hasInterface) exitWith{};
The function accepts a single parameter _markerX, the target marker name (town).
It immediately checks if the script is running on the server (isServer) or if the client has a game interface (hasInterface). If it is a headless client (no interface) or a client without the interface, it exits.
2. Variable Setup & Difficulty Calculation

Sqf

Apply
private _groups = [];
private _difficultX = random 10 < tierWar;
private _positionX = getMarkerPos _markerX;
private _faction = Faction(Occupants);
private _limit = if (_difficultX) then {
	30 call SCRT_fnc_misc_getTimeLimit
} else {
	60 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];
Initializes an empty array _groups to track spawned AI groups.
Calculates _difficultX as a boolean based on tierWar. If tierWar is high, the mission is harder (shorter time limit, tougher enemies).
Retrieves the position of the target marker _positionX.
Fetches the Occupants faction definition (usually AAF/CSAT).
Sets the time limit _limit using SCRT_fnc_misc_getTimeLimit. 30 seconds for difficult, 60 for easy (Note: These values seem like debugging values; in production, they might be minutes converted to seconds or server time). The result is split into _dateLimitNum (numeric date comparison) and _displayTime (formatted string).
3. Task Creation (BIS & A3A)

Sqf

Apply
private _nameDest = [_markerX] call A3A_fnc_localizar;
private _taskId = "SUPP" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[format [localize "STR_A3A_Missions_SUPP_Supplies_task_desc",_nameDest,_displayTime],format [localize "STR_A3A_Missions_SUPP_Supplies_task_header", _nameDest],_markerX],_positionX,false,0,true,"Heal",true] call BIS_fnc_taskCreate;
[_taskId, "SUPP", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Localizes the marker name to _nameDest.
Generates a unique Task ID _taskId.
Calls BIS_fnc_taskCreate to create the Arma standard task for players. It targets [teamPlayer,civilian], uses localized strings for the description (detailing the destination and time limit) and title. It is assigned to the specific position.
Calls A3A_fnc_taskUpdate remotely on the server to register the task in the A3A task system state with the "CREATED" state.
4. Creating the Supply "Box" (Truck)

Sqf

Apply
private _pos = (getMarkerPos respawnTeamPlayer) findEmptyPosition [1,50,"Land_FoodSacks_01_cargo_brown_F"];
private _truckX = "Land_FoodSacks_01_cargo_brown_F" createVehicle _pos;
_truckX enableRopeAttach true;
_truckX allowDamage false;
[_truckX] call A3A_Logistics_fnc_addLoadAction;
Finds an empty position near the team's respawn point.
Spawns the specific object type "Land_FoodSacks_01_cargo_brown_F" (a generic cargo crate). Note: Despite the variable name _truckX, this is a static object, but serves the purpose of a cargo item.
Enables rope attachment (so it can be sling-loaded or moved by ropes) and disables damage to prevent accidental destruction before the mission starts.
Adds the "Add Load" action via A3A_Logistics_fnc_addLoadAction, allowing the object to be loaded onto vehicles via the logistics system.
5. Adding Mission-Specific Actions

Sqf

Apply
_truckX addAction ["Delivery infos", {...}, ..., ...];
_truckX setVariable ["destinationX",_nameDest,true];
Adds an action "Delivery infos" that displays a hint containing the destination name stored in the object's variable destinationX.
Sets the public variable destinationX on the object for all clients to access.
Calls A3A_fnc_AIVEHinit (likely initializing AI interaction or tracking).
Spawns A3A_fnc_inmuneConvoy (likely making the object immune to damage for a brief period or handling damage state).
6. Initial Enemy Check (Blocking Guard)

Sqf

Apply
waitUntil {sleep 1; dateToNumber date > _dateLimitNum or {spawner getVariable _markerX != 2}};

if ((spawner getVariable _markerX != 2) and {!(sidesX getVariable [_markerX,sideUnknown] == teamPlayer)}) then {
	// ... spawn a police patrol group ...
	_groups pushBack _groupX;
};
The script waits until either the time limit is reached or the target marker is "active" (spawner variable != 2, meaning players are nearby or it is engaged).
If the marker is active and not already owned by the rebels (sidesX check), it spawns a defensive patrol group (Police Team or Squad) at the target location.
7. The Main Loop: Delivery & Defense

Sqf

Apply
waitUntil {sleep 1; (dateToNumber date > _dateLimitNum) or ((_truckX distance _positionX < 40) and (isNull attachedTo _truckX) and (isNull ropeAttachedTo _truckX)) or (isNull _truckX)};
The core wait condition checks for three end states:
Time ran out.
The crate is at the target marker (within 40m), not attached to another object, and not connected by ropes.
The crate is destroyed (null).
8. Success State Logic

Sqf

Apply
if ((dateToNumber date < _dateLimitNum) and !(isNull _truckX)) then {
	[petros,"hint", format [localize "STR_A3A_Missions_SUPP_Supplies_success", _nameDest], ...] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
	[_taskId, "SUPP", "SUCCEEDED"] call A3A_fnc_taskSetState;
	// Reward loop
	{ [15*_bonus,_x] call A3A_fnc_addScorePlayer; [300*_bonus,_x] call A3A_fnc_addMoneyPlayer; } forEach (call SCRT_fnc_misc_getRebelPlayers);
	// Aggro changes
	[Occupants, -10, 60] remoteExec ["A3A_fnc_addAggression",2];
} else {
	// ... Failure logic ...
};
If the crate is delivered successfully before the timer expires:
Sends a success hint to all rebels.
Updates the A3A and BIS task states to "SUCCEEDED".
Iterates through all rebel players (via SCRT_fnc_misc_getRebelPlayers), granting Score (15) and Money (300), multiplied by a bonus (2 if difficult, 1 if easy).
Reduces the aggression level of the Occupants (policing force becomes less aggressive towards the area).
9. Dynamic Reinforcement (Additional Spawning)

Sqf

Apply
if (_difficultX && {spawner getVariable _markerX != 2 && ...}) then {
    private _groupX2 = [_group2Position, Occupants, _typeGroup] call A3A_fnc_spawnGroup;
    // ... waypoints ...
};
If the mission is on "Difficult" and players are active in the area, a second group is spawned far away and ordered to move to the crate's position to intercept the delivery.
10. Dynamic Defense Timer

Sqf

Apply
while {_countX > 0 ...} do {
    // ... countdown logic ...
    // Checks for enemies nearby and players being close.
    // If players move away or enemies get too close, the countdown resets.
};
If the crate arrives safely, a "defense timer" starts (90 seconds for difficult, 180 for easy).
The timer decrements only if:
No enemies are within 50m.
All players involved in the delivery are within 80m.
The crate is not attached to anything.
If any of these conditions fail, the timer pauses/resets, and a hint warns players to "Stay close to the crate" or "Clean all BLUFOR presence".
11. Rewards & Cleanup

Sqf

Apply
[petros,"hint", format [localize "STR_A3A_Missions_SUPP_Supplies_success", _nameDest], ...] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]];
[_taskId, "SUPP", "SUCCEEDED"] call A3A_fnc_taskSetState;
// ... Score/Money/Aggro updates ...
deleteVehicle _truckX;
private _emptybox = "Land_Pallet_F" createVehicle (getpos _truckX);
[_emptybox] spawn A3A_fnc_postmortem;
[_taskId, "SUPP", 900] spawn A3A_fnc_taskDelete;
Upon timer completion (Success):
Sends final success message.
Updates task state.
Calculates bonus rewards.
Spawns an empty pallet (Land_Pallet_F) at the delivery location as a visual placeholder.
Deletes the original cargo object.
Calls A3A_fnc_postmortem on the empty box (likely to handle garbage collection or persistence).
Schedules the task deletion for later (after 900 seconds) using A3A_fnc_taskDelete to keep the task log clean.
Where it leads:

Calls:
SCRT_fnc_misc_getTimeLimit: Calculates time limit based on difficulty.
A3A_fnc_localizar: Localizes the marker name.
BIS_fnc_taskCreate: Creates the player-visible task.
A3A_fnc_taskUpdate: Registers the task in the A3A system.
A3A_Logistics_fnc_addLoadAction: Adds interaction to load the crate.
A3A_fnc_AIVEHinit: Initializes the vehicle/object.
A3A_fnc_inmuneConvoy: Handles object immortality.
A3A_fnc_spawnGroup: Spawns AI patrols.
A3A_fnc_patrolLoop: Makes the initial patrol wander.
A3A_fnc_NATOinit: Initializes the spawned units.
BIS_fnc_findSafePos: Finds a spawn location for reinforcements.
A3A_fnc_distanceUnits: Gets units within a radius (used for checking defense perimeter).
A3A_fnc_canFight: Checks if a unit is alive and combat-ready.
A3A_fnc_commsMP: Sends global hints.
A3A_fnc_addScorePlayer: Adds score to players.
A3A_fnc_addMoneyPlayer: Adds money to players.
SCRT_fnc_misc_getRebelPlayers: Gets list of current rebel players.
A3A_fnc_citySupportChange: Updates city support (global variables).
A3A_fnc_addAggression: Updates enemy aggression (global variable).
A3A_fnc_taskSetState: Updates task state (Success/Fail).
A3A_fnc_postmortem: Handles object cleanup.
A3A_fnc_taskDelete: Deletes the task from the system after a delay.
Dependencies: Requires tierWar, spawner, sidesX global variables. Requires the Faction system to be initialized.
Global Variables Modified: Modifies A3A_taskCount (via task creation), A3A_activeTasks, A3A_tasksData (via task updates), garrison (via city support changes), and aggressionLevel (via aggression changes).
Network Implications: Heavily networked. Uses remoteExecCall for task updates, remoteExec for city support/aggression changes, and remoteExec via commsMP for player hints. All AI spawning is server-side but visible to clients.
Function Name: 
fn_taskDelete.sqf
What it does: This is a worker function designed to safely remove a task from the game. It handles the removal of both the internal A3A task tracking system and the external BIS (Arma standard) task system. It includes an optional random delay to prevent immediate task clutter or synchronized cleanup spikes.

How it does that:

1. Parameter Extraction

Sqf

Apply
params ["_taskID", "_taskType", "_delay", ["_isTwin", false]];
Takes the unique _taskID, the _taskType (e.g., "LOG", "SUPP"), a _delay in seconds, and an optional _isTwin boolean (default false). If _isTwin is true, it assumes there is a sibling task (e.g., "TaskID" and "TaskIDB") to delete as well.
2. Optional Delay

Sqf

Apply
if (_delay > 0) then {sleep ((_delay/2) + random _delay)};
If a delay is specified (> 0), the script sleeps for a random duration. The range is between _delay/2 and 1.5 * _delay. This prevents all tasks from being deleted at the exact same time if called in a batch.
3. A3A System Update

Sqf

Apply
[_taskID, _taskType, "DELETED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Calls A3A_fnc_taskUpdate remotely on the server (JIP or headless client). It updates the internal A3A task arrays (A3A_tasksData, A3A_activeTasks) to mark the task as deleted.
4. BIS Task Deletion

Sqf

Apply
[_taskID] call BIS_fnc_deleteTask;
if (_isTwin) then { [_taskID+"B"] call BIS_fnc_deleteTask };
Calls the Arma engine function BIS_fnc_deleteTask to remove the visual task from the player's task list (top right).
If _isTwin is true, it performs the same deletion for the "B" variant of the task ID.
Where it leads:

Calls:
A3A_fnc_taskUpdate: To update the internal database that a task is gone.
BIS_fnc_deleteTask: To remove the visual task from the UI.
Dependencies: Relies on A3A_fnc_taskUpdate to exist on the server.
Global Variables Modified: Modifies A3A_tasksData and A3A_activeTasks (indirectly via A3A_fnc_taskUpdate).
Network Implications: Uses remoteExecCall to ensure the server updates its task list, ensuring consistency for clients connecting later (JIP).
Function Name: 
fn_taskSetState.sqf
What it does: This function updates the state of a task to either "SUCCEEDED" or "FAILED". It synchronizes this state across the internal A3A task system and the standard Arma BIS task system. It can optionally handle "twin" tasks (e.g., a primary and secondary objective) where the success of one implies the failure of the other.

How it does that:

1. Parameter Extraction

Sqf

Apply
params ["_taskId", "_taskType", "_state", ["_isTwin", false]];
Accepts the _taskId, _taskType, the new _state (usually "SUCCEEDED" or "FAILED"), and an optional _isTwin boolean.
2. A3A System Update

Sqf

Apply
[_taskId, _taskType, _state] remoteExecCall ["A3A_fnc_taskUpdate", 2];
Updates the internal A3A tracking system. This updates the state in A3A_tasksData.
3. BIS Task State Update

Sqf

Apply
[_taskId, _state] call BIS_fnc_taskSetState;
Updates the visible task state in the player's task list.
4. Twin Task Logic

Sqf

Apply
if (!_isTwin) exitWith {};
private _state2 = switch (_state) do {
    case "SUCCEEDED": {"FAILED"};
    case "FAILED": {"SUCCEEDED"};
    default {_state};
};
[_taskId+"B", _state2] call BIS_fnc_taskSetState;
If _isTwin is false, the function exits.
If true, it calculates the opposite state for the twin task (if the main task succeeded, the twin fails, and vice versa).
It updates the BIS state for the twin task (ID + "B"). Note: It does not seem to update the A3A internal state for the twin here, only the visual BIS state.
Where it leads:

Calls:
A3A_fnc_taskUpdate: Updates the internal A3A task database.
BIS_fnc_taskSetState: Updates the visual Arma task state.
Dependencies: Requires A3A_fnc_taskUpdate.
Global Variables Modified: Modifies A3A_tasksData (via A3A_fnc_taskUpdate).
Network Implications: remoteExecCall ensures the state change is propagated to the server for JIP purposes.
Function Name: 
fn_taskUpdate.sqf
What it does: This is the central database manager for the A3A task system. It does not handle visual elements (that is BIS functions). It manages the A3A_tasksData array (the list of active tasks) and A3A_activeTasks (list of unique task types currently running). It handles the creation, state change, and deletion of tasks, ensuring IDs are unique and task types are tracked.

How it does that:

1. Server-Side Restriction

Sqf

Apply
if (!isServer) exitWith { Error("Server-only function miscalled") };
params ["_taskId", "_taskType", "_state"];
Ensures this logic runs only on the server to prevent data desynchronization.
Extracts parameters: ID, Type (e.g., "LOG"), and Action (CREATED, DELETED, SUCCEEDED, FAILED).
2. Finding Existing Tasks

Sqf

Apply
private _taskIndex = A3A_tasksData findIf { (_x#0) isEqualTo _taskId };
Scans the A3A_tasksData array to find the index of the task with the matching ID. _x#0 refers to the task ID in the stored format [ID, Type, State, Time].
3. Handling Task Creation ("CREATED")

Sqf

Apply
if (_state isEqualTo "CREATED") exitWith
{
    A3A_taskCount = A3A_taskCount + 1; publicVariable "A3A_taskCount";
    // ... Error checking ...
    A3A_tasksData pushBack [_taskId, _taskType, "CREATED", serverTime];
    // ... Error checking ...
    A3A_activeTasks pushBack _taskType; publicVariable "A3A_activeTasks";
};
If the state is "CREATED":
Increments the global counter A3A_taskCount and broadcasts it.
Checks if the ID already exists (error logging).
Pushes a new entry [ID, Type, "CREATED", serverTime] into A3A_tasksData.
Checks if the taskType is already active (error logging, as unique types are enforced).
Adds the taskType to A3A_activeTasks and broadcasts it.
4. Handling Task Deletion ("DELETED")

Sqf

Apply
if (_state isEqualTo "DELETED") exitWith {
    A3A_tasksData deleteAt _taskIndex;
    if (A3A_tasksData findIf { (_x#1) isEqualTo _taskType } != -1) exitWith {};
    A3A_activeTasks deleteAt (A3A_activeTasks find _taskType); publicVariable "A3A_activeTasks";
};
If the state is "DELETED":
Removes the task from A3A_tasksData using the previously found _taskIndex.
Checks if any other task of the same _taskType still exists in A3A_tasksData.
If no other task of that type exists, it removes the _taskType from A3A_activeTasks and broadcasts the change.
5. Handling State Changes (SUCCEEDED/FAILED)

Sqf

Apply
if !(_state in ["SUCCEEDED", "FAILED"]) exitWith { Error_2("Bad state %1 for task ID %2", _state, _taskId) };
(A3A_tasksData#_taskIndex) set [2, _state];
If the state is "SUCCEEDED" or "FAILED":
Validates the state (crashes if invalid).
Updates the task entry in A3A_tasksData at index 2 (the state field) to the new value.
Where it leads:

Calls:
None (Internal logic only).
Dependencies: Requires global variables A3A_taskCount, A3A_tasksData, A3A_activeTasks to be initialized (usually in initServer).
Global Variables Modified:
A3A_taskCount (incremented).
A3A_tasksData (pushed to or modified).
A3A_activeTasks (pushed to or removed from).
All modifications use publicVariable to sync across the network.
Network Implications: Heavily networked. publicVariable calls ensure all clients (and headless clients) stay in sync with the active task list. This is critical for JIP (Join in Progress) players to see the correct state.
Function Name: 
fn_underAttack.sqf
What it does: Creates a generic "Under Attack" task for a specific location. This is a defensive objective triggered when an AI-controlled marker (Base, City, Outpost) is attacked by an enemy force. It lasts until the area is captured, the enemy despawns, or a timer runs out (indicating the garrison held out).

How it does that:

1. Validation & Target Lookup

Sqf

Apply
params ["_markerX", "_sideEny", "_sideX", ["_roadblockTemp", true], ["_isRival", false]];
if ([_markerX] call BIS_fnc_taskExists) exitWith {};
private _nameDest = [_markerX] call A3A_fnc_localizar;
Takes the marker being attacked, the enemy side, the friendly side, and flags for temporary roadblocks or rival involvement.
Checks if a task already exists for this marker to prevent duplicates.
Localizes the marker name.
2. Determining Sides & Names

Sqf

Apply
private _nameENY = if (_sideEny == teamPlayer) then { FactionGet(reb,"name") } else { ... };
if (_sideX == teamPlayer) then {_sideX = [teamPlayer,civilian]};
Determines the name of the enemy (e.g., "Rebels", "AAF", "CSAT") based on _sideEny.
If the defending side is teamPlayer, it expands the task assignment to include civilian (so rebels and civilians see the defense task).
3. Creating the Defense Task

Sqf

Apply
[_sideX,_markerX,[format [localize "STR_A3A_Missions_underattack_task_desc",_nameDest,_nameENY],...],getMarkerPos _markerX,false,0,true,"Defend",true] call BIS_fnc_taskCreate;
if (_sideX isEqualType []) then {_sideX = teamPlayer};
Calls BIS_fnc_taskCreate to create the task. It uses the "Defend" icon. It provides a localized description indicating which location is under attack and by whom.
Reverts _sideX from an array (used for assignment) back to a single side variable for the subsequent logic check.
4. Termination Logic

Sqf

Apply
waitUntil {
	sleep 10;
	(sidesX getVariable [_markerX,sideUnknown] != _sideX) or
	(_roadblockTemp && {spawner getVariable _markerX == 2}) or
	((garrison getVariable [_markerX + "_lastAttack", 0]) + 600 < serverTime)
};
The function pauses and checks every 10 seconds for termination conditions:
Capture: The ownership of the marker (sidesX) changes to something other than the defender.
Despawn: If it's a temporary roadblock (_roadblockTemp) and the enemy forces have despawned (spawner variable == 2).
Timer: 600 seconds (10 minutes) have passed since the attack started (based on _lastAttack timestamp in garrison namespace).
5. Cleanup

Sqf

Apply
[_markerX] call BIS_fnc_deleteTask;
Once the waitUntil condition is met, it deletes the BIS task.
Where it leads:

Calls:
BIS_fnc_localizar: Localizes the marker.
BIS_fnc_taskCreate: Creates the visual task.
BIS_fnc_taskExists: Checks for existing tasks.
BIS_fnc_deleteTask: Removes the task upon termination.
Dependencies: Relies on sidesX, spawner, and garrison global namespaces.
Global Variables Modified: None directly (read-only checks).
Network Implications: The task is created using BIS_fnc_taskCreate which handles its own locality distribution based on the side parameters provided.