Function Name: 
fn_addArtilleryTrailEH.sqf
What it does: This function attaches an event handler to an artillery vehicle. When the vehicle fires a projectile, it creates a persistent smoke trail attached to the projectile to make its trajectory visible. This is primarily used to provide visual feedback to players about incoming artillery fire.

Implementation Details:

Parameter Validation:
Sqf

Apply
params [["_artillery", objNull, [objNull]]];
Validates that _artillery is an object (objNull is the default).
If no parameter is provided or an invalid object is passed, it defaults to objNull.
Event Handler Attachment:
Sqf

Apply
_artillery addEventHandler ["Fired", {...}];
Adds a "Fired" event handler to the artillery vehicle. The handler executes whenever the vehicle fires any weapon.
Event Handler Code Block:
Sqf

Apply
params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
_projectile spawn {
    sleep 0.05;
    private _smoke = "SmokeShell_Infinite" createVehicle (getPos _this);
    _smoke attachTo [_this, [0, -1, 0]];
    waitUntil {sleep 0.1; !(alive _this)};
    deleteVehicle _smoke;
};
Parameter Extraction: The event handler receives standard firing parameters. Only _projectile is used.
Spawned Subroutine: The projectile is passed to a new scheduled environment (spawn).
Initial Delay: sleep 0.05 gives the projectile time to leave the muzzle and establish its trajectory.
Smoke Creation: Creates a "SmokeShell_Infinite" at the projectile's current position. This smoke object will emit smoke indefinitely.
Attachment: The smoke object is attached to the projectile with an offset [0, -1, 0] (1 meter behind the projectile).
Cleanup Loop: The script enters a loop that checks every 0.1 seconds if the projectile is still alive (alive _this). Once the projectile is destroyed (e.g., impacts), the loop exits.
Cleanup: The attached smoke object is deleted to prevent garbage accumulation.
Where it Leads:

Calls to Functions: None. The function directly creates objects and uses built-in SQF commands.
Dependent Functions: No other functions depend on this one directly. It's a standalone effect add-on.
Global System Integration:
Part of the "EventHandler" module in the A3A framework.
Used to enhance gameplay feedback for artillery units.
Global Variables Modified: None.
Synchronization/Network Implications: This is entirely a client-side visual effect. The event handler is added locally where the artillery is local. No network calls are made. The smoke trail is visible to all players near the projectile, but its creation and management are local to the machine where the artillery fired.
Function Name: 
fn_enemyUnitDeletedEH.sqf
What it does: This function handles the cleanup and resource management when an enemy unit is deleted (via the Deleted event handler). It refunds or depletes resource pools based on the unit's purchase status (prepaid vs. legacy) and updates garrison counts if the unit belongs to one.

Implementation Details:

Includes and Setup:
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Includes standard A3A headers for debug and consistency. FIX_LINE_NUMBERS() ensures correct error reporting.
Parameter Handling:
Sqf

Apply
params ["_unit"];
Extracts the unit object from the event parameters.
Early Exit Conditions:
Sqf

Apply
if (!alive _unit) exitWith {};
if ((_unit getVariable ["isRival", false])) exitWith {};
Exits if the unit is already dead (already handled by kill events).
Exits immediately if the unit is a Rival (managed by a separate system).
Resource Pool and Side Validation:
Sqf

Apply
private _pool = _unit getVariable ["A3A_resPool", "legacy"];
private _side = _unit getVariable ["originalSide", sideUnknown];
if (_side != Occupants and _side != Invaders) then {
    Error_2("Wrong unit had delete handler, side %1, type %2, pool %3", _side, _unit getVariable "UnitType", _pool);
};
Retrieves the resource pool the unit was spawned from (attack, defence, legacy). Defaults to legacy.
Retrieves the unit's original side (originalSide variable).
Error Check: Validates the side is either Occupants or Invaders. Logs a critical error if not, indicating a logic error elsewhere.
Resource Refund Logic:
Sqf

Apply
if (_unit call A3A_fnc_canFight) then {
    if (_pool == "attack" or _pool == "defence") then {
        [10, _side, _pool] remoteExecCall ["A3A_fnc_addEnemyResources", 2];
    };
}
else {
    if (_pool == "legacy") then {
        [-10, _side, _pool] remoteExecCall ["A3A_fnc_addEnemyResources", 2];
    };
};
CanFight Check: Uses A3A_fnc_canFight to determine if the unit was a combat-capable entity.
Prepaid Logic (Attack/Defence Pool): If the unit was spawned from a prepaid pool (e.g., as part of a QRF or defense wave), and the unit was alive and combat-capable upon deletion, it refunds 10 resources to that specific pool.
Legacy Logic: If the unit was spawned from the "legacy" pool (default non-prepaid spawns), and the unit is not combat-capable (e.g., deleted during pathfinding, group creation failures), it depletes the legacy pool by 10 resources.
Garrison Update:
Sqf

Apply
private _marker = _victim getVariable "markerX";
if (isNil "_marker" or { sidesX getVariable [_marker, sideUnknown] != _side }) exitWith {};
[_victim getVariable "unitType", _side, _marker,-1] remoteExec ["A3A_fnc_garrisonUpdate", 2];
Bug Note: Uses _victim instead of _unit (parameter name). This is a variable scoping error in the original code; _victim is undefined here.
Checks if the unit had a markerX variable (indicating it belongs to a garrison).
Validates that the marker's current side matches the unit's original side.
Calls A3A_fnc_garrisonUpdate with -1 to decrement the garrison count for that unit type on the server.
Where it Leads:

Calls to Functions:
A3A_fnc_canFight: Checks if a unit can still engage in combat.
A3A_fnc_addEnemyResources: Called on server (machine 2) to update faction resource pools.
A3A_fnc_garrisonUpdate: Called on server to update garrison counts.
Dependent Functions: Used by the unit spawner system. Any function that deletes an enemy unit and has this event handler attached will trigger this logic.
Global System Integration:
Part of the resource management and garrison system.
Essential for maintaining accurate economy (resources) and garrison strengths.
Global Variables Modified:
Indirectly modifies A3A_factionResources or similar global resources via addEnemyResources.
Indirectly modifies sidesX and garrison arrays via garrisonUpdate.
Synchronization/Network Implications: Heavy use of remoteExecCall to the server (machine 2). This ensures resource and garrison changes are synchronized for all clients and the server. The function itself likely runs on the server or HC where the unit locality is managed.
Function Name: 
fn_enemyUnitKilledEH.sqf
What it does: This function handles the complex consequences when an enemy unit is killed. It manages resource depletion, aggression, city support changes, garrison updates, score awards, and captive status removal.

Implementation Details:

Includes and Parameters:
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_victim", "_killer"];
Standard headers and parameter extraction.
Stop Spawning:
Sqf

Apply
if (_victim getVariable ["spawner",false]) then {
    _victim setVariable ["spawner",nil,true]
};
Sets a flag to prevent the dead unit from triggering any further spawning routines (if applicable).
Information Gathering and Post-Mortem:
Sqf

Apply
private _victimGroup = group _victim;
private _victimSide = side (group _victim);
private _isRival = _victim getVariable ["isRival", false];
[_victim] spawn A3A_fnc_postmortem;
Gathers group and side information.
Spawns A3A_fnc_postmortem in a separate thread to handle gear storage and delayed cleanup without blocking the main flow.
Resource Depletion (Legacy):
Sqf

Apply
private _pool = _victim getVariable ["A3A_resPool", "legacy"];
if (_pool == "legacy" && {!_isRival}) then {
    [-10, _victimSide, "legacy"] remoteExecCall ["A3A_fnc_addEnemyResources", 2];
};
Checks if the unit is from the legacy pool and is not a rival.
Depletes the legacy resource pool by 10 units on the server.
ACE Medical Handler Adjustment:
Sqf

Apply
if (A3A_hasACE) then {
    if ((isNull _killer) || (_killer == _victim)) then {
        _killer = _victim getVariable ["ace_medical_lastDamageSource", _killer];
    };
};
If ACE medical is active, attempts to identify the real killer (e.g., from fall damage or self-inflicted) using an ACE variable.
AI Reaction (For Enemy Deaths):
Sqf

Apply
if (_victimSide in [Occupants, Invaders]) then {
    [_victim, _victimGroup, _killer] spawn A3A_fnc_AIreactOnKill;
};
Spawns AIreactOnKill to handle squad reactions (panic, targeting the killer) if the victim was part of the enemy forces.
Killer Evaluation:
Player or Faction Kills:
Sqf

Apply
if (side (group _killer) == teamPlayer) then {
    // ... player reward logic ...
}
else {
    // ... enemy-on-enemy logic ...
};
Distinguishes between kills by rebels (teamPlayer) and kills by other factions (enemy or civilians).
Player Reward Logic:
Sqf

Apply
if (isPlayer _killer) then {
    [2,_killer] call A3A_fnc_addScorePlayer;
    if (captive _killer) then {
        if (_killer distance _victim < distanceSPWN) then {
            [_killer,false] remoteExec ["setCaptive",_killer];
        };
    };
    _killer addRating 1000;
};
if (vehicle _killer isKindOf "StaticMortar") then {
    {
        if ((_x distance _victim < 300) and (captive _x)) then {
            [_x,false] remoteExec ["setCaptive",_killer];
        };
    } forEach (call A3A_fnc_playableUnits);
};
Score: Awards 2 points if the killer is a player.
Captive Status: If the killer was a captive, removes that status if within spawn distance.
Rating: Increases the killer's rating by 1000.
Mortar Popper: If the killing vehicle is a static mortar, removes captive status from any player within 300m of the victim (mortar crews can't hide).
Aggression and Support Logic (Rebel Kills):
Sqf

Apply
if (count weapons _victim < 1 && {!(_victim getVariable ["isAnimal", false])}) {
    // ... surrendered unit logic ...
} else {
    // ... normal combat kill logic ...
};
Surrendered/Disarmed: If the victim had no weapons (surrendered) and isn't an animal:
Decreases city support (Occupants are angered).
Increases aggression if not a rival.
Combat Kill: If the victim had weapons:
Small city support change.
Small aggression increase if not a rival.
Rival Kills: If the victim was a rival, triggers SCRT_fnc_rivals_reduceActivity.
Enemy-on-Enemy Logic:
Sqf

Apply
else { // (side (group _killer) != teamPlayer)
    if (_victimSide == Occupants) then {
        [-0.25,0,getPos _victim] remoteExec ["A3A_fnc_citySupportChange",2];
    } else {
        if (!_isRival) then { ... } else { ... };
    };
};
Checks if the victim was Occupants or Invaders.
Adjusts city support (tiny negative change for Occupants).
Handles rival vs. non-rival logic for Invader victims.
Garrison and Zone Update:
Sqf

Apply
private _victimLocation = _victim getVariable ["markerX", ""];
if (_victimLocation != "") then {
    if (sidesX getVariable [_victimLocation,sideUnknown] == _victimSide) then {
        [_victim getVariable "unitType",_victimSide,_victimLocation,-1] remoteExec ["A3A_fnc_garrisonUpdate",2];
        [_victimLocation,_victimSide] remoteExec ["A3A_fnc_zoneCheck",2]
    };
};
Checks if the unit was part of a garrison (has markerX).
Validates the garrison's current side matches the victim's side.
Decrements the garrison count for that unit type on the server.
Triggers A3A_fnc_zoneCheck on the server to re-evaluate zone control or frontline status.
Where it Leads:

Calls to Functions:
A3A_fnc_postmortem: Handles gear storage and delayed deletion.
A3A_fnc_addEnemyResources: Updates faction resources.
A3A_fnc_AIreactOnKill: Manages AI squad reactions.
A3A_fnc_addScorePlayer: Awards score to player killers.
A3A_fnc_playableUnits: Lists all player units.
A3A_fnc_citySupportChange: Modifies city support levels.
A3A_fnc_addAggression: Adjusts global aggression.
SCRT_fnc_rivals_reduceActivity: Manages rival activity reduction.
A3A_fnc_garrisonUpdate: Updates garrison counts.
A3A_fnc_zoneCheck: Updates zone control.
Dependent Functions: Attached to EnemyUnitKilledEH event for all enemy units via spawners (e.g., A3A_fnc_createUnit).
Global System Integration:
Core to the economy, AI, and garrison systems.
Drives the dynamic enemy response and resource management.
Global Variables Modified:
A3A_score (via addScorePlayer).
A3A_aggression (via addAggression).
city and supportX arrays (via citySupportChange).
sidesX and garrison arrays (via garrisonUpdate and zoneCheck).
Player rating.
Synchronization/Network Implications: Extensive use of remoteExec and remoteExecCall to synchronize data with the server and all clients (e.g., score, aggression, support changes). The logic to determine which calls to make is local to where the kill occurred, ensuring responsiveness.
Function Name: 
fn_vehicleDeletedEH.sqf
What it does: Handles cleanup and resource management when a vehicle is deleted. It cleans up associated objects (landing pads, spawn places) and calculates a resource refund or penalty based on vehicle damage and ownership side.

Implementation Details:

Includes and Parameters:
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_veh"];
Cleanup of Associated Objects:
Sqf

Apply
private _landingPad = _veh getVariable "LandingPad";
if (!isNil "_landingPad") then { deleteVehicle _landingPad };

private _spawnPlace = _veh getVariable "spawnPlace";
if (!isNil "_spawnPlace") then { [_spawnPlace] call A3A_fnc_freeSpawnPositions };
Landing Pad: If the vehicle had a dedicated landing pad (e.g., for helo bases), it's deleted.
Spawn Place: If the vehicle reserved a spawn position, it's freed up using A3A_fnc_freeSpawnPositions.
Resource and Ownership Check:
Sqf

Apply
private _side = _veh getVariable ["ownerSide", teamPlayer];
private _vehCost = A3A_vehicleResourceCosts getOrDefault [typeof _veh, 0];
if (!alive _veh || {(_side != Occupants && _side != Invaders) || {_vehCost == 0 || {_veh in (A3A_faction_all get "vehiclesRivals")}}}) exitWith {};
Retrieves the owning side (ownerSide), defaulting to teamPlayer (player-owned).
Looks up the vehicle's resource cost from the global A3A_vehicleResourceCosts hashmap. Defaults to 0 if not found.
Exits Early If: The vehicle is not dead, is not owned by an AI faction, has a cost of 0, or is a rival vehicle. This function only processes AI-faction-owned vehicles with a cost.
Damage Calculation:
Sqf

Apply
Debug_1("Calculating damage for vehicle type %1", typeof _veh);
private _vehDamage = damage _veh;
if (getAllHitPointsDamage _veh isNotEqualTo []) then {
    private _allHP = getAllHitPointsDamage _veh select 2;
    private _total = 0; { _total = _total + _x } forEach _allHP;
    _vehDamage = _vehDamage max (_total / count _allHP);
};
Basic Damage: Uses damage _veh (overall health, 0 = full health, 1 = destroyed).
Hitpoint Damage: Checks for detailed hitpoint damage. If available, calculates the average of all hitpoint damage values. This gives a more accurate picture of vehicle health (e.g., tracks destroyed but engine intact).
Worst-Case: Takes the maximum of the two damage values. If the engine is at 100% damage, the vehicle is considered destroyed, even if the hull is intact.
Resource Logic (Legacy vs. Prepaid):
Sqf

Apply
private _pool = _veh getVariable ["A3A_resPool", "legacy"];
Debug_5("Vehicle type %1 deleted with side %2, pool %3, cost %4, damage %5", typeof _veh, _side, _pool, _vehCost, _vehDamage);

if (_pool == "legacy") then {
    if (_vehDamage < 0.1) exitWith {};
    [-_vehDamage*_vehCost, _side, "legacy"] remoteExecCall ["A3A_fnc_addEnemyResources", 2];
} else {
    [(1-_vehDamage)*_vehCost*2/3, _side, _pool] remoteExecCall ["A3A_fnc_addEnemyResources", 2];
};
Legacy Pool (Non-Prepaid):
If damage is less than 10%, no penalty is applied (e.g., mild damage, small target).
Otherwise, penalties the resource pool. The penalty is proportional to damage and vehicle cost (-damage * cost).
Prepaid Pool (Attack/Defence):
Refunds resources. The refund is proportional to remaining health (1 - damage), scaled by cost, and limited to 2/3 of the total cost. This represents salvaging a partially damaged asset.
Where it Leads:

Calls to Functions:
A3A_fnc_freeSpawnPositions: Releases a reserved spawn location.
A3A_fnc_addEnemyResources: Updates the enemy resource pool on the server.
Dependent Functions: Attached to the Deleted event of enemy vehicles (and possibly player vehicles, though early exit excludes them). Triggered by the vehicle spawner system or manual deletion.
Global System Integration:
Part of the resource economy and vehicle management system.
Ensures the resource pool reflects the state of the enemy vehicle fleet.
Global Variables Modified:
Indirectly modifies A3A_factionResources or similar via addEnemyResources.
The spawn position system is modified via freeSpawnPositions.
Synchronization/Network Implications: The remoteExecCall to addEnemyResources on machine 2 synchronizes the resource change with the server. All other operations (cleanup) are local and don't require network sync.