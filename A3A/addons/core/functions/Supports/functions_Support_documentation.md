fn_addSupportTarget.sqf
Function Name: A3A_fnc_addSupportTarget

What it does: This function adds a specific target (both an object and its position) to an active, multi-target support asset, allowing that single support to strike multiple targets. It is primarily used when an active support (like artillery or a gunship) already exists in an area and the commander wishes to assign a new target to it rather than creating a completely new support. It also triggers the creation of a strike record in A3A_supportStrikes to prevent overlapping strikes against the same target type.

How it does that:

Parameter Handling: The function accepts three arguments: the support identifier (either a string name or the active support array), the target object, and the target position. It first determines if the input support is a string (name) or an array (data).

Sqf

Apply
params ["_activeSupport", "_target", "_targPos"];

if (_activeSupport isEqualType "") then { 
    private _index = A3A_activeSupports findIf { _activeSupport == _suppName };
    if (_index != -1) then { _activeSupport = A3A_activeSupports select _index };
};
If the support name is provided but not found in the active list, the function logs an error and exits, returning false.

Sqf

Apply
if (_activeSupport isEqualType "") exitWith { Error_1("Support name %1 not in active list", _activeSupport); false; };
Target Validation: It unpacks the support array (_suppName, _suppSide, _suppType, _center, _radius, _suppTarget) and checks if the support has remaining capacity. Specifically, it verifies that the radius is not 0 (indicating the support is still active) and that the target list (_suppTarget) is currently empty (ready for a new target).

Sqf

Apply
_activeSupport params ["_suppName", "_suppSide", "_suppType", "_center", "_radius", "_suppTarget"];

if (_radius == 0 or _suppTarget isNotEqualTo []) exitWith { 
    Error_2("No remaining targets for support %1", _suppName); 
};
Appending Target: It appends the target object and its position to the _suppTarget array within the active support array. Because SQF arrays are passed by reference, this modifies the actual array in A3A_activeSupports.

Sqf

Apply
_suppTarget append [_target, _targPos];
Info_3("Added target %1 (position %2) to support %3", _target, _targPos, _suppName);
Strike Record Creation: It retrieves the support type's base category (TARGET, AREA, etc.) from the faction support hashmaps. It then determines the strike target (object if base type is "TARGET", position otherwise) and pushes a new record to the global A3A_supportStrikes array. This records persists for 20 minutes with a specific power rating (200).

Sqf

Apply
private _suppTypeHM = [A3A_supportTypesOcc, A3A_supportTypesInv] select (_side == Invaders);
(_suppTypeHM get _suppType) params ["_baseType", "", "", "_strikePower"];
private _strikeTarg = if (_baseType == "TARGET") then { _target } else { _targPos };
A3A_supportStrikes pushBack [_suppSide, _baseType, _strikeTarg, time + 20*60, 20*60, _strikePower];
Output: Returns true to indicate success.

Where it leads:

Called Functions:
Error_1 / Error_2: Logging functions for errors.
Info_3: Logging function for info.
Dependent Functions: A3A_fnc_requestSupport and A3A_fnc_requestArtillery call this when they detect an existing support in the requested area.
System Integration: Modifies A3A_activeSupports (global array on server) and A3A_supportStrikes (global array on server).
Network Implications: None directly; these are server-side arrays. The changes are propagated to clients via the support routines that read these arrays (e.g., the suppRoutine scripts check A3A_supportStrikes to determine if a target is already being engaged).
fn_calculateSupportCallReveal.sqf
Function Name: A3A_fnc_calculateSupportCallReveal

What it does: Calculates a "reveal value" (0.0 to 1.0) representing how much information rebels should receive about an incoming support. This value is influenced by the proximity of the support target to rebel-controlled assets (HQ, airports, antennas) and the distance to the nearest friendly assets.

How it does that:

Initialization: Accepts a position array. Initializes _result to 0. Sets up _hardValue (guaranteed reveal) and _softValue (random chance pool), both starting at 0 and 20 respectively.

Sqf

Apply
params [["_position", [0,0,0], [[]]]];
private _result = 0;
private _hardValue = 0;
private _softValue = 20;
HQ Proximity Checks: Checks the distance from the target position to the Syndicate HQ (Synd_HQ).

Very Close (< 1000m): Adds 20 to _hardValue and 20 to _softValue.
Close (< 2500m): Adds 20 to _softValue.
Sqf

Apply
if(_position distance2D (getMarkerPos "Synd_HQ") < 1000) then { ... };
if(_position distance2D (getMarkerPos "Synd_HQ") < 2500) then { ... };
Airport Checks: Finds the nearest airport marker. If the rebels own it, adds 20 to _softValue. If the airport is also within 1500m, adds 10 to _hardValue and 10 to _softValue.

Sqf

Apply
private _nearestAirport = [airportsX, _position] call BIS_fnc_nearestPosition;
if(sidesX getVariable [_nearestAirport, sideUnknown] == teamPlayer) then { ... };
Antenna Checks: Finds the nearest antenna and its associated marker (outpost/airport/milbase). If the rebels own the marker, adds 10 to _hardValue and 20 to _softValue. If the marker is within 2000m, adds another 20 to _hardValue and 10 to _softValue.

Sqf

Apply
private _nearestAntenna = [antennas, _position] call BIS_fnc_nearestPosition;
private _antennaMarker = [outposts + airportsX + milbases, _position] call BIS_fnc_nearestPosition;
if(sidesX getVariable [_antennaMarker, sideUnknown] == teamPlayer) then { ... };
Result Calculation: Calculates _result as _hardValue plus a random integer from 0 to _softValue. The total is divided by 100 and clamped to a maximum of 1.0.

Sqf

Apply
_result = _hardValue + (round (random _softValue));
_result = (_result / 100) min 1;
_result;
Where it leads:

Called Functions: BIS_fnc_nearestPosition.
Dependent Functions: Called by A3A_fnc_requestSupport and A3A_fnc_requestArtillery to determine the initial reveal value before spending a radio key.
System Integration: Relies on global variables airportsX, milbases, sidesX, teamPlayer, antennas, outposts.
Network Implications: None; runs entirely on the server.
fn_clearTargetArea.sqf
Function Name: A3A_fnc_clearTargetArea

What it does: Forces AI units belonging to a specific side (and optionally civilians) to flee from a designated marker area. This is used to clear the area of friendly forces or civilians before a support strike to minimize friendly fire or collateral damage.

How it does that:

Parameter Validation: Accepts a side (default sideUnknown) and a marker string (default ""). Validates inputs.

Sqf

Apply
params [["_side", sideUnknown, [sideUnknown]], ["_targetArea", "", [""]]];
Area Calculation: Determines the center position (_targetPoint) and size (_targetSize) of the marker. The size is the maximum of the x and y dimensions.

Sqf

Apply
private _targetPoint = getMarkerPos _targetArea;
private _targetSize = getMarkerSize _targetArea;
_targetSize = (_targetSize select 0) max (_targetSize select 1);
Side Definition: Creates a list of sides that should flee (_fleeingSides). If the input side is Occupants, civilian is added to the list (since Occupants defend civilians).

Sqf

Apply
private _fleeingSides = [_side];
if(_side == Occupants) then { _fleeingSides pushBack civilian; };
Unit Iteration: Iterates through allUnits. For each unit, it checks:

Does the unit's group side belong to _fleeingSides?
Is the unit inside _targetArea?
Sqf

Apply
{
    if(((side (group _x)) in _fleeingSides) && {_x inArea _targetArea}) then { ... };
} forEach allUnits;
Fleeing Logic: Calculates a direction away from the center of the target area (_dir) and a position far enough outside the area (plus a random offset). The unit is commanded to move (doMove) to this safe position.

Sqf

Apply
private _dir = _targetPoint getDir (getPos _x);
private _pos = _x getPos [_dir, (_targetSize + 10 + random 25)];
_x doMove _pos;
Where it leads:

Called Functions: None (standard commands used).
Dependent Functions: Called by A3A_fnc_SUP_mortarRoutine (commented out in code, but intended), A3A_fnc_SUP_airstrikeRoutine, and potentially other support routines before an impact.
System Integration: Interacts with the entity system (allUnits) and mission global variables (Occupants).
Network Implications: doMove is a local command. If run on the server, it affects the unit's AI locally. For clients to see the effect, the command should be executed on the machine where the unit is local (usually the server for AI).
fn_createSupport.sqf
Function Name: A3A_fnc_createSupport

What it does: This is the central factory function for the support system. It handles resource costing, type validation, active support re-use (for multi-target supports), and finally instantiates the specific support routine (e.g., airstrike, artillery) via the appropriate creation function.

How it does that:

Input Processing: Extracts parameters including type, side, resource pool, max spend, target, position, reveal, and delay. Determines the resource pool (defence or attack).

Sqf

Apply
params ["_type", "_side", "_caller", "_maxSpend", "_target", "_targPos", "_reveal", ["_delay", -1]];
private _resPool = ["defence", _caller] select (_caller isEqualType "");
Type Validation: Checks if the requested support type exists in the faction's support hashmaps (A3A_supportTypesOcc or A3A_supportTypesInv). If not, returns an empty string.

Sqf

Apply
private _suppTypeHM = [A3A_supportTypesOcc, A3A_supportTypesInv] select (_side == Invaders);
if !(_type in _suppTypeHM) exitWith { "" };
Concurrency Lock: Waits for the global A3A_supportCallInProgress flag to clear to prevent race conditions during support creation.

Sqf

Apply
waitUntil { isNil "A3A_supportCallInProgress" };
A3A_supportCallInProgress = true;
Active Support Re-use Logic: Scans A3A_activeSupports for an existing support of the same type and side that is within range of the new target and currently has no active target (_suppTarg isEqualTo []). If found, it calls A3A_fnc_addSupportTarget and returns the existing support name.

Sqf

Apply
private _supportIndex = A3A_activeSupports findIf { ... check logic ... };
if (_target isEqualType objNull and _supportIndex != -1) exitWith {
    private _activeSupport = A3A_activeSupports # _supportIndex;
    [_activeSupport, _target, _targPos] call A3A_fnc_addSupportTarget;
    ... return support name ...
};
New Support Creation:

Name: Generates a unique support name using A3A_supportCount.
Radio Key: Calls A3A_fnc_useRadioKey to boost reveal value if a radio key is available.
Cost Calculation: Retrieves the specific creation function (A3A_fnc_SUP_<type>) from the mission namespace. It calls this function to calculate the resource cost. The function is wrapped in a try/catch block for error handling.
Resource Deduction: If successful (cost >= 0), it calls A3A_fnc_addEnemyResources to deduct the cost from the appropriate pool.
Spend Tracking: If the caller is a position array (defence response), it adds an entry to A3A_supportSpends to track resource usage over time.
Sqf

Apply
// Example: Cost calculation and deduction
private _resourceCost = [_supportName, _side, _resPool, _maxSpend, _target, _targPos, _reveal, _delay] call _createFunc;
[-_resourceCost, _side, _resPool] call A3A_fnc_addEnemyResources;
Cleanup: Releases the concurrency lock and returns the generated support name (or empty string on failure).

Where it leads:

Called Functions: A3A_fnc_addSupportTarget, A3A_fnc_useRadioKey, A3A_fnc_addEnemyResources, and dynamic calls to A3A_fnc_SUP_<type> (e.g., A3A_fnc_SUP_airstrike).
Dependent Functions: A3A_fnc_requestSupport and A3A_fnc_requestArtillery are the primary entry points that lead here.
System Integration: Modifies A3A_supportSpends and A3A_supportCount. Reads from A3A_activeSupports.
Network Implications: Server-side only. The A3A_supportCallInProgress flag is local to the script execution context (server), so no network sync is needed there, but it ensures sequential processing on the server.
fn_getArtilleryRanges.sqf
Function Name: A3A_fnc_getArtilleryRanges

What it does: Calculates the minimum and maximum effective firing ranges for a specific artillery vehicle and magazine combination. It uses a ballistic formula and config parsing to determine these values.

How it does that:

Caching: Checks a global hashmap A3A_artyRangeHM to see if the range for this specific vehicle/magazine combo has already been calculated. If so, returns the cached value immediately.

Sqf

Apply
private _hmkey = _vehType + "_" + _shellType;
if (isNil "A3A_artyRangeHM") then { A3A_artyRangeHM = createHashMap };
if (_hmkey in A3A_artyRangeHM) exitWith { A3A_artyRangeHM get _hmkey };
Turret Config Parsing: Searches the vehicle config (CfgVehicles >> _vehType >> Turrets) for a turret with elevationMode != 0. If none is found, it defaults to "MainTurret".

Sqf

Apply
private _turretCfg = call {
    private _allTurrets = configProperties [configFile >> "CfgVehicles" >> _vehType >> "Turrets"];
    private _idx = _allTurrets findIf { getNumber (_x >> "elevationMode") != 0 };
    ... return turret config ...
};
Weapon Identification: Extracts the weapon classname associated with the magazine (via pylonWeapon or the turret's weapon array).

Sqf

Apply
private _weapon = getText (configfile >> "CfgMagazines" >> _shellType >> "pylonWeapon");
if (_weapon == "") then { _weapon = getArray (_turretCfg >> "Weapons") # 0 };
Charge Extraction: Iterates through the weapon's firing modes to find artilleryCharge values. Determines the minimum (_minCharge) and maximum (_maxCharge) charges available.

Sqf

Apply
{
    private _modeCfg = if (_x == "this") then { _weaponCfg } else { _weaponCfg >> _x };
    private _charge = getNumber (_modeCfg >> "artilleryCharge");
    ... update min/max ...
} forEach getArray (_weaponCfg >> "modes");
Elevation Calculation: Spawns a local vehicle object to inspect the gunBeg and gunEnd selections relative to the world. Calculates the base elevation angle (_baseElev) relative to the horizon. Adds minElev and maxElev from the config to determine the firing angles.

Sqf

Apply
private _veh = createVehicleLocal [_vehType, [0,0,-1000], [], 0, "NONE"];
... vector math ...
_baseElev = asin (_gunDir#2) - getNumber (_turretCfg >> "initElev");
... delete vehicle ...
Ballistic Calculation: Uses the projectile's initSpeed, the calculated charges, and the elevation angles in a standard physics formula to compute range: $Range = \frac{Velocity^2 \times \sin(2 \times \theta)}{9.807}$ It adjusts for minimum elevation (long range) and maximum elevation (short range) to get realistic min/max bounds.

Sqf

Apply
private _maxRange = (_initSpeed * _maxCharge)^2 * sin (2*_longElev) / 9.807;
private _minRange = (_initSpeed * _minCharge)^2 * sin (2*_maxElev) / 9.807;
Result & Caching: Returns an array [_minRange, _maxRange] (with safety offsets applied) and saves it to the cache hashmap.

Where it leads:

Called Functions: None (uses core SQF config commands).
Dependent Functions: A3A_fnc_SUP_artillery, A3A_fnc_SUP_mortar, A3A_fnc_SUP_howitzer.
System Integration: Relies on A3A_artyRangeHM for caching. Accesses ConfigFile.
Network Implications: None. Runs locally on the machine calling it (usually server).
fn_initSupports.sqf
Function Name: A3A_fnc_initSupports

What it does: Initializes the global support system variables and data structures required for support management. It generates support availability hashmaps for Occupants and Invaders based on faction data, and builds a database of strategic markers with defense multipliers and radio tower associations.

How it does that:

Global Variable Initialization: Initializes counters (A3A_supportCount, A3A_supportMarkerCount) and arrays for tracking support usage (A3A_supportSpends, A3A_supportStrikes, A3A_activeSupports).

Sqf

Apply
A3A_supportCount = 0;
A3A_supportMarkerCount = 0;
A3A_supportSpends = [];
...
Support Type Definition: Defines the _initData array containing definitions for every support type: type name, base type (TARGET/AREA), weight, lowAir weight, effective radius, strike power, flags (unfair/futuristic), and required vehicle class.

Sqf

Apply
private _initData = [
    ["AIRSTRIKE", "AREA", 0.5, ...],
    ...
];
Hashmap Generation: Defines a local function _fnc_buildSupportHM that filters _initData based on the faction's available vehicles (e.g., vehiclesArtillery) and game settings (allowUnfairSupports). It creates a hashmap where the key is the support type and the value is an array [baseType, weight, radius, power]. This is executed for both Occupants and Invaders.

Sqf

Apply
private _fnc_buildSupportHM = { ... };
A3A_supportTypesOcc = A3A_faction_occ call _fnc_buildSupportHM;
A3A_supportTypesInv = A3A_faction_inv call _fnc_buildSupportHM;
Strategic Marker Database Construction: Clears and rebuilds A3A_supportMarkerTypes and A3A_supportMarkersXYI.

It iterates through different marker categories (airports, milbases, etc.) and assigns them a "defense multiplier" based on importance (e.g., Airport = 1.0, Town = 0.3).
It also tracks if a marker has an associated antenna (radio tower).
Sqf

Apply
{ A3A_supportMarkerTypes pushBack [_x, "Airport", false, 1.0] } forEach airportsX;
...
{
    _x pushBack (0.5 + random 0.5); // Time-based randomness
    ... add to A3A_supportMarkersXYI ...
} forEach A3A_supportMarkerTypes;
Radio Tower Association: Iterates through antennas (active and dead) to find the nearest marker within 500m. If found, it marks that marker in the database as having a radio tower and increases its defense multiplier by RADIO_TOWER_BONUS (0.15).

Where it leads:

Called Functions: None (helper function logic is internal).
Dependent Functions: This is an initialization function. It is called during mission initialization (server pre-init). It is a prerequisite for almost all other support functions.
System Integration: Populates global variables A3A_supportTypesOcc, A3A_supportTypesInv, A3A_supportMarkerTypes, A3A_supportMarkersXYI.
Network Implications: None directly; these are server-side tables used for AI decision making. The data is not synced to clients.
fn_maxDefenceSpend.sqf
Function Name: A3A_fnc_maxDefenceSpend

What it does: Calculates the maximum amount of resources (in points) an AI side can spend on a defensive support for a specific target and location. It considers global resource pools, target type (air vs. ground), marker importance, threat balance, and recent resource expenditure in the area.

How it does that:

Target & Side Identification: Determines the target's side (_targetSide) and selects the correct global resource pool (A3A_resourcesDefenceInv or A3A_resourcesDefenceOcc).

Sqf

Apply
private _curResources = [A3A_resourcesDefenceInv, A3A_resourcesDefenceOcc] select (_side == Occupants);
Max Pool Calculation: Calculates the theoretical maximum resources based on A3A_balanceResourceRate and game mode (campaign vs. skirmish). Applies a modifier for Invader balance.

Sqf

Apply
private _maxResources = A3A_balanceResourceRate * 10 * ...;
if (gameMode == 1) then { ... adjust based on aggression ... };
Air Target Handling: If the target is an aircraft, it uses a specific logic branch:

Calculates target threat based on vehicle costs and previous kills (A3A_airKills).
Sums up recent AA spend from A3A_supportStrikes to avoid over-killing a single plane.
Calculates current AA spend from A3A_supportSpends.
Caps the max spend at 30% of global resources minus current AA spend.
Sqf

Apply
if (_target isEqualType objNull and {_target isKindOf "Air"}) exitWith {
    ... complex AA logic ...
    _curResources min _maxSpendTarg min (_maxAASpend - _curAASpend);
};
Ground Target Handling (Location Logic):

If CallPos is a Marker: Uses the marker's pre-calculated defense multiplier from A3A_supportMarkerTypes.
If CallPos is a Position: Calculates a defense multiplier based on friendly markers near the caller and a defense penalty based on enemy markers near the target.
Sqf

Apply
private _maxSpendLoc = _maxResources;
if (_callPos isEqualType "") then {
    ... marker lookup ...
} else {
    ... distance checks to markers ...
    _maxSpendLoc = _maxSpendLoc * (_defMul - _defSub);
};
Threat Balance: Calculates a _threatBalance factor (0 to 1) based on:

Recent damage taken in the area (from A3A_fnc_getRecentDamage).
Enemy strength (infantry and vehicles nearby).
Friendly strength (infantry nearby).
Sqf

Apply
_threatBalance = (2*_recentDamage + _enemyStr) / (_friendStr max 1);
_threatBalance = 1 min (_threatBalance - 1);
Expenditure History: Iterates through A3A_supportSpends to sum up resources spent in the area recently. Uses linearConversion to apply a time-based falloff (older spends count less).

Sqf

Apply
{
    _x params ["_spSide", "_spCallPos", ...];
    ... distance checks and time falloff ...
} forEach A3A_supportSpends;
Final Calculation: Calculates final max spend: (_threatBalance * _maxSpendLoc) - (callPosSpend max targPosSpend). Applies a minimum threshold based on vehicle costs; if the result is too low, returns 0 (preventing "penny-pinching" supports).

Where it leads:

Called Functions: A3A_fnc_getRecentDamage.
Dependent Functions: A3A_fnc_requestSupport uses this to determine the _maxSpend parameter passed to A3A_fnc_createSupport.
System Integration: Reads global arrays A3A_supportMarkerTypes, A3A_supportSpends, A3A_supportStrikes, A3A_resourcesDefence....
Network Implications: None.
fn_requestArtillery.sqf
Function Name: A3A_fnc_requestArtillery

What it does: Selects and creates an area-effect support (Artillery, Mortar, Howitzer, Airstrike, Carpet Bombs) against a specific target position. It filters support types based on the target's nature and available active supports.

How it does that:

Target Precision: Calculates a _deprecisionRange based on the input _precision value (0-4). The higher the precision, the smaller the deviation. The final _targPos is the target's current position offset by this range.

Sqf

Apply
private _deprecisionRange = random (150 - ((_precision/4) * (_precision/4) * 125));
private _targPos = _target getPos [_deprecisionRange, random 360];
Target Object Resolution: If the target is a unit in a vehicle, it switches the target object to the vehicle (parent object). If the input was a position, target becomes objNull.

Sqf

Apply
if (_target isEqualType objNull) then {
    if (_target isKindOf "Man" and !(isNull objectParent _target)) then { _target = objectParent _target };
} else {
    _target = objNull;
};
Active Support Filtering: Scans A3A_activeSupports for supports that:

Match the requested side.
Are of type "AREA" (artillery/airstrike).
Are within range of the target position.
Have an empty target list (ready for a new target). Populates a hashmap _actSuppHM with these found supports, keyed by type.
Sqf

Apply
private _actSuppHM = createHashMap;
{
    _x params [...];
    if (_suppSide != _side or _suppType in _actSuppHM) then { continue };
    ... range checks ...
    _actSuppHM set [_suppType, _x];
} forEach A3A_activeSupports;
Support Type Weighting: Iterates through the faction's available support types (_supportTypesHM). Skips types that are not "AREA" class.

Calls the specific availability function (e.g., A3A_fnc_SUP_artilleryAvailable) to get a target weight.
Multiplies the base type weight by the target weight.
Applies a x3 weight bonus if the support type was found in _actSuppHM (encourages re-use).
Stores weights in _weightedSupports array.
Sqf

Apply
private _weightedSupports = [];
{
    _y params ["_class", "_typeWeight"];
    if (_class != "AREA") then { continue };
    ... call availability ...
    private _finalWeight = _typeWeight * _targWeight;
    if (_x in _actSuppHM) then { _finalWeight = _finalWeight * 3 };
    _weightedSupports append [_x, _finalWeight];
} forEach _supportTypesHM;
Random Selection & Creation: Loops while no support has been created and weighted list is not empty. Selects a support type randomly weighted by _weightedSupports. Attempts to create it using A3A_fnc_createSupport. If creation fails (returns empty string), it removes that type from the list and tries again.

Where it leads:

Called Functions: A3A_fnc_SUP_<type>Available (dynamic), A3A_fnc_createSupport.
Dependent Functions: Typically called by mission scripts or triggers requesting specific area denial.
System Integration: Reads A3A_activeSupports. Modifies nothing directly (delegates to createSupport).
Network Implications: None (Server-side logic).
fn_requestSupport.sqf
Function Name: A3A_fnc_requestSupport

What it does: The main entry point for requesting AI support against a specific target object. It determines resource limits, calculates support type weights (balancing between Area, Target, and Troop supports), checks for friendly fire hazards, and delegates to A3A_fnc_createSupport.

How it does that:

Cleanup & Locking: Waits for the support lock to clear. Cleans up old entries in A3A_supportSpends, A3A_supportStrikes, and A3A_activeSupports (based on time or radius = 0).

Sqf

Apply
A3A_supportSpends = A3A_supportSpends select { _x#4 + 3600 > time };
A3A_supportStrikes = A3A_supportStrikes select { _x#3 > time };
A3A_activeSupports = A3A_activeSupports select { _x#4 > 0 };
HQ Intelligence Update: Calculates distance to HQ and updates A3A_curHQInfoOcc or A3A_curHQInfoInv based on proximity, aggro, and whether the HQ is in a bunker.

Target Preparation: Resolves target object (switching to vehicle if unit is inside one) and calculates a de-precision range based on _precision. Determines _targPos.

Resource Calculation: Calls A3A_fnc_maxDefenceSpend to get the _maxSpend limit.

Support Type Weights (Class Weights): Calculates base weights for AREA, TARGET, and TROOPS classes based on global aggression and existing A3A_supportStrikes.

Area: Heavily penalized if recent area strikes overlap the target area.
Troops: Penalized if recent troop deployments are nearby.
Target: Blocked (weight 0) if the specific target is already being engaged.
Sqf

Apply
private _classWeightsHM = call {
    ... logic to calculate _weightArea, _weightTroops, _weightTarget ...
    createHashMapFromArray [["AREA", _weightArea], ...];
};
Safety Checks (Friendly Fire): Scans for friendly units and civilian houses within the effective radius of potential supports.

Counts _nearfriendlies and _nearHouses.
Defines strict limits (_maxFriendlies, _maxHouses) based on side (Invaders are less restrained).
If these limits are exceeded for a specific class (e.g., Area strikes hit too many friendlies), that class weight becomes 0.
Sqf

Apply
private _nearfriendlies = units _side inAreaArray [_targPos, 200, 200];
... count logic ...
if (_effRadius > 0) then {
    ... check counts against limits ...
    if (_friendlyCount > _maxFriendlies) then { continue };
};
Active Support Lookup & Weighting: Scans A3A_activeSupports for reusable supports (same as requestArtillery but for all types). Builds _weightedSupports array by multiplying:

Class Weight (proximity/usage)
Type Weight (faction preference)
Target Weight (specific availability function result)
Bonus (x3) if re-using an active support.
Creation: Randomly selects a support type from the weighted list and calls A3A_fnc_createSupport. Loops if creation fails.

Where it leads:

Called Functions: A3A_fnc_maxDefenceSpend, A3A_fnc_calculateSupportCallReveal, A3A_fnc_useRadioKey, A3A_fnc_SUP_<type>Available, A3A_fnc_createSupport.
Dependent Functions: Called by AI commanders (e.g., A3A_fnc_enemyKilled or patrol scripts) when they need assistance.
System Integration: Reads/Writes A3A_supportSpends, A3A_supportStrikes, A3A_activeSupports, A3A_curHQInfo....
Network Implications: None (Server-side).
fn_showInterceptedSetupCall.sqf
Function Name: A3A_fnc_showInterceptedSetupCall

What it does: Displays a "Radio Intercepted" notification to players near the target position, informing them that a support is being set up. The level of detail in the notification depends on the reveal value (0-1).

How it does that:

Reveal Check: If reveal is ≤ 0.2, no notification is shown.

Sqf

Apply
if(_reveal <= 0.2) exitWith {};
Text Generation (Based on Reveal):

Low Reveal (0.2 - 0.5): Only reveals the side calling the support (e.g., "NATO").
High Reveal (> 0.5): Switches on _supportType to select a localized string describing the specific support (e.g., "Airstrike", "Artillery", "QRF").
Sqf

Apply
switch (toUpperANSI _supportType) do {
    case ("AIRSTRIKE"): { ... };
    ...
};
Time Modification: Randomizes the displayed setup time based on the reveal value (higher reveal = more accurate time).

Sqf

Apply
_setupTime = _setupTime * (_reveal + random (2 - 2*_reveal));
Appending Time to Text: If reveal is very high (≥ 0.8), appends the estimated arrival time to the message text.

Network Broadcast: Finds all players within 2000m of the target position and executes BIS_fnc_showNotification remotely on their machines.

Sqf

Apply
private _nearbyPlayers = allPlayers select {(_x distance2D _position) <= 2000};
["RadioIntercepted", [_text]] remoteExec ["BIS_fnc_showNotification", _nearbyPlayers];
Where it leads:

Called Functions: BIS_fnc_showNotification.
Dependent Functions: Called by A3A_fnc_createSupport (indirectly via the specific support creation function, e.g., SUP_airstrike) or A3A_fnc_SUP_mortarRoutine.
System Integration: Relies on Faction(_side) for side names and localized strings.
Network Implications: Sends notifications to clients. Requires the "RadioIntercepted" notification class to be defined in CfgNotifications.
fn_showInterceptedSupportCall.sqf
Function Name: A3A_fnc_showInterceptedSupportCall

What it does: Displays a "Radio Intercepted" notification regarding an active support execution (e.g., "Airstrike inbound") and optionally creates a map marker showing the target area or object.

How it does that:

Reveal Check: Exits if reveal is ≤ 0.2.

Text & Marker Generation (Based on Reveal):

Low Reveal (0.2 - 0.5): Generic message ("Enemy support activity detected").
High Reveal (> 0.5): Specific message based on _supportType (e.g., "Airstrike inbound").
Marker Text: Determined by the support type (e.g., "Target" for CAS, "QRF" for infantry).
Map Marker Creation (High Reveal ≥ 0.8): If the reveal is high enough, it creates a local map marker.

If _markerType is a Number (Radius): Creates an ellipse marker at _position with the given radius. Also creates a text icon marker.
If _markerType is an Object (Target): Creates a single icon marker that tracks the object's position.
Sqf

Apply
if (_markerType isEqualType 0) then {
    createMarkerLocal [_targetMarker, _position];
    _targetMarker setMarkerShapeLocal "ELLIPSE";
    ...
} else {
    createMarkerLocal [_textMarker, _position];
    _textMarker setMarkerTypeLocal "mil_objective";
    ...
    [_textMarker, _markerType, time + _markerLifeTime] spawn { ... track object ... };
};
Marker Cleanup: Spawns a script to delete the markers after _markerLifeTime seconds (or when the tracked object dies/timeout expires).

Network Broadcast: Sends the notification text to players within 2000m of the position.

Where it leads:

Called Functions: BIS_fnc_showNotification, createMarkerLocal.
Dependent Functions: Called by support routine scripts (e.g., A3A_fnc_SUP_airstrikeRoutine, A3A_fnc_SUP_SAMRoutine) when the support starts its attack run.
System Interaction: Modifies local map markers (client-side only).
Network Implications: Notification is networked; markers are local to each client.
fn_SUP_airstrike.sqf
Function Name: A3A_fnc_SUP_airstrike

What it does: Prepares and launches a standard airstrike support. It selects an aircraft, calculates bomb type probabilities based on aggression, sets up the strike record, and spawns the execution routine.

How it does that:

Base Selection: Finds an available airbase (A3A_fnc_availableBasesAir) for the side.

Sqf

Apply
private _airport = [_side, _targPos] call A3A_fnc_availableBasesAir;
if(isNil "_airport") exitWith { ... -1 ... };
Loadout Selection: Calculates weights for bomb types (HE, Cluster, Napalm, Chemical) based on aggression and tier. Selects one randomly.

Sqf

Apply
private _weightHE = if (_side == Occupants) then {2} else {1};
private _weightCluster = 0 max ((tierWar - 5) / 10 + _aggroValue / 200);
private _bombType = selectRandomWeighted ["HE", _weightHE, "CLUSTER", _weightCluster, ...];
Aircraft Selection: Selects a random plane from the faction's CAS lists.

Sqf

Apply
private _planeType = selectRandom ((_faction get "vehiclesPlanesCAS") + (_faction get "vehiclesPlanesLargeCAS"));
Delay Calculation: Calculates setup time based on war tier and aggression if not provided.

Sqf

Apply
if (_delay < 0) then { _delay = (0.5 + random 1) * (300 - 15*tierWar - 1*_aggroValue) };
Strike Record: Adds an entry to A3A_supportStrikes with base type "AREA", duration 20 minutes, and power 200.

Spawning Routine: Spawns A3A_fnc_SUP_airstrikeRoutine with the calculated parameters (delay, airport, plane type, bomb type).

Sqf

Apply
[_supportName, _side, _delay, _targPos, _airport, _resPool, _planeType, _bombType, _reveal] spawn A3A_fnc_SUP_airstrikeRoutine;
Cost Return: Returns the resource cost of the selected aircraft from A3A_vehicleResourceCosts.

Where it leads:

Called Functions: A3A_fnc_availableBasesAir, A3A_fnc_SUP_airstrikeRoutine, A3A_fnc_showInterceptedSetupCall.
Dependent Functions: Called by A3A_fnc_createSupport when type is "AIRSTRIKE".
System Integration: Writes to A3A_supportStrikes.
Network Implications: None (Server-side).
fn_SUP_airstrikeRoutine.sqf
Function Name: A3A_fnc_SUP_airstrikeRoutine

What it does: The executable logic for an airstrike. Spawns the aircraft, flies it to the target area, drops bombs (handling ballistics via events), and cleans up.

How it does that:

Sleep & Spawn: Sleeps for the calculated delay time. Spawns the aircraft at the airport marker + altitude (500m for planes, 150m for helicopters).

Sqf

Apply
sleep _sleepTime;
private _spawnPos = (getMarkerPos _airport) vectorAdd [0, 0, if (_isHelicopter) then {150} else {500}];
private _plane = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
Crew & AI Setup: Creates crew, initializes them (A3A_fnc_NATOinit), and disables their AI targeting to force manual execution by the script.

Sqf

Apply
private _group = [_side, _plane] call A3A_fnc_createVehicleCrew;
{ _x disableAI "TARGET"; _x disableAI "AUTOTARGET"; } forEach units _group;
Waypoints: Calculates start and end bomb run positions relative to the target. Adds MOVE waypoints for the approach, the run, and the return to base.

Sqf

Apply
private _startBombPosition = _targetPos getPos [100, _targDir + 180];
private _endBombPosition = _targetPos getPos [100, _targDir];
Bombing Logic: Spawns a separate script block that waits for the plane to reach _startBombPosition. It then calls A3A_fnc_airbomb to handle the actual bomb dropping physics.

Cleanup: Waits for the plane to reach the final waypoint (returning to base). If it succeeds, it deletes the crew and plane. If it times out (e.g., destroyed), it uses groupDespawner and vehDespawner.

Where it leads:

Called Functions: A3A_fnc_AIVEHInit, A3A_fnc_createVehicleCrew, A3A_fnc_NATOinit, A3A_fnc_airbomb, A3A_fnc_showInterceptedSupportCall, A3A_fnc_groupDespawner, A3A_fnc_vehDespawner.
Dependent Functions: Called by A3A_fnc_SUP_airstrike.
System Integration: Modifies unit/group behavior. Spawns local entities.
Network Implications: Entities are synchronized over the network (visible to all players). remoteExec is used for notifications.
fn_SUP_artillery.sqf
Function Name: A3A_fnc_SUP_artillery

What it does: Prepares an artillery support. Finds a suitable base, spawns the artillery vehicle and crew, calculates ranges, and sets up the A3A_activeSupports entry to allow for multi-shot functionality.

How it does that:

Asset Selection: Selects a random artillery vehicle and compatible magazine from faction config.

Sqf

Apply
private _vehType = selectRandom (_faction get "vehiclesArtillery");
private _magPool = (_faction get "magazines") get _vehType;
private _shellType = selectRandom _magPool;
Range Calculation: Calls A3A_fnc_getArtilleryRanges to determine min/max effective distances.

Sqf

Apply
([_vehType, _shellType] call A3A_fnc_getArtilleryRanges) params ["_minRange", "_maxRange"];
Base Selection: Scans airportsX and milbases for bases owned by the side that are within range but not too close (min range).

Sqf

Apply
private _possibleBases = (airportsX + milbases) select { ... distance and side checks ... };
Spawning: Uses A3A_fnc_safeVehicleSpawn to place the vehicle and A3A_fnc_createVehicleCrew for personnel.

Sqf

Apply
private _vehicle = [_vehType, markerPos _base, 50, 5, true] call A3A_fnc_safeVehicleSpawn;
private _group = [_side, _vehicle] call A3A_fnc_createVehicleCrew;
Active Support Entry: Pushes a new entry to A3A_activeSupports. Crucially, it sets the radius to _maxRange and the target list [].

Sqf

Apply
private _suppData = [_supportName, _side, "ARTILLERY", markerPos _base, _maxRange, _targArray, _minRange];
A3A_activeSupports pushBack _suppData;
Routine Execution: Spawns A3A_fnc_SUP_mortarRoutine (which is shared by mortars, howitzers, and artillery) to handle the firing logic.

Where it leads:

Called Functions: A3A_fnc_getArtilleryRanges, A3A_fnc_safeVehicleSpawn, A3A_fnc_createVehicleCrew, A3A_fnc_AIVehInit, A3A_fnc_NATOinit, A3A_fnc_SUP_mortarRoutine.
Dependent Functions: Called by A3A_fnc_createSupport when type is "ARTILLERY".
System Integration: Writes to A3A_activeSupports.
Network Implications: None.

Function Name: 
fn_SUP_artillery.sqf
 What it does: This function sets up an artillery support request for the server. It finds a suitable artillery piece within range of the target, spawns it and its crew at a base, and launches the support routine. It validates that a base exists with a clear line of fire and within the specific weapon range of the chosen artillery shell. How it does that:

Parameter Validation: The function begins by extracting named arguments from the _this array.

Sqf

Apply
params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Weapon and Range Selection: It retrieves the faction data to select a random artillery vehicle and a compatible shell type. It then calculates the minimum and maximum ranges for that specific combination.

Sqf

Apply
private _faction = Faction(_side);
private _vehType = selectRandom (_faction get "vehiclesArtillery");
private _magPool = (_faction get "magazines") get _vehType;
private _shellType = selectRandom _magPool;
([_vehType, _shellType] call A3A_fnc_getArtilleryRanges) params ["_minRange", "_maxRange"];
Base Selection: It scans airportsX and milbases to find a base belonging to the _side where the distance to the target is between the _minRange and _maxRange. It checks if the base is spawned (value 2).

Sqf

Apply
private _possibleBases = (airportsX + milbases) select
{
    (sidesX getVariable [_x, sideUnknown] == _side) &&
    {(markerPos _x distance2D _targPos <= _maxRange) &&
    {(markerPos _X distance2D _targPos > _minRange) &&
    {spawner getVariable _x == 2}}}
};
if(count _possibleBases == 0) exitWith { Debug("Couldn't find a suitable base for artillery"); -1 };
private _base = selectRandom _possibleBases;
Spawning and Initialization: The artillery vehicle is spawned safely near the base. It is assigned a variable _shellType and initialized via A3A_fnc_AIVehInit. The crew is created separately and initialized with A3A_fnc_NATOinit.

Sqf

Apply
private _vehicle = [_vehType, markerPos _base, 50, 5, true] call A3A_fnc_safeVehicleSpawn;
_vehicle setVariable ["shellType", _shellType];
[_vehicle, _side, _resPool] call A3A_fnc_AIVehInit;

private _group = [_side, _vehicle] call A3A_fnc_createVehicleCrew;
{ [_x, nil, false, _resPool] call A3A_fnc_NATOinit } forEach units _group;
_group deleteGroupWhenEmpty true;
Delay Calculation: If a negative delay is passed, it calculates a dynamic delay based on war tier and aggression levels.

Sqf

Apply
private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (300 - 15*tierWar - 1*_aggro) };
Support Data Registration: It creates a support data array containing the target info and adds it to A3A_activeSupports. It also logs the strike area to A3A_supportStrikes if the target is a specific object.

Sqf

Apply
private _targArray = [];
if (_target isEqualType objNull) then {
    A3A_supportStrikes pushBack [_side, "AREA", _targPos, time + 20*60, 20*60, 200];
    _targArray = [_target, _targPos];
};

private _suppData = [_supportName, _side, "ARTILLERY", markerPos _base, _maxRange, _targArray, _minRange];
A3A_activeSupports pushBack _suppData;
Routine Execution: It spawns the support routine A3A_fnc_SUP_mortarRoutine (reused for artillery) and the visual/audio cue function.

Sqf

Apply
[_suppData, _vehicle, _group, _delay, _reveal, true] spawn A3A_fnc_SUP_mortarRoutine;
[_reveal, _side, "ARTILLERY", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;
Return Value: Returns the calculated resource cost of the support.

Sqf

Apply
(A3A_vehicleResourceCosts get _vehType) + (10 * count units _group) + 200;
Where it leads:

Called Functions:
Faction(_side): Retrieves faction configuration data.
A3A_fnc_getArtilleryRanges: Calculates min/max range for the specific weapon/ammunition combo.
A3A_fnc_safeVehicleSpawn: Spawns the artillery unit safely.
A3A_fnc_AIVehInit: Initializes vehicle AI and resources.
A3A_fnc_createVehicleCrew: Spawns crew members for the artillery.
A3A_fnc_NATOinit: Initializes AI unit skills and behavior.
A3A_fnc_SUP_mortarRoutine: The core logic loop that handles firing patterns (spawns immediately).
A3A_fnc_showInterceptedSetupCall: Handles UI/interception feedback for the player.
Dependencies:
Relies on global arrays airportsX and milbases.
Relies on A3A_activeSupports and A3A_supportStrikes to track active support instances and map markers.
Depends on spawner and sidesX variables for base state validation.
Global Variables:
Modified: A3A_activeSupports, A3A_supportStrikes.
Read: tierWar, aggressionOccupants, aggressionInvaders.
Network/Exec: Runs entirely on the Server. Spawns scheduled scripts (spawn).
Edge Cases:
Returns -1 if no valid base is found within range parameters.
If _delay is negative, it performs a calculation; otherwise, it uses the provided value.
Function Name: 
fn_SUP_artilleryAvailable.sqf
 What it does: Calculates the probability weight for an artillery support option against a specific target. It enforces a "tech tier" lock, preventing artillery from being available in early game stages, and filters out air targets. How it does that:

Parameter Extraction:

Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Target Filtering: Immediately returns 0 (unavailable) if the target is airborne, as artillery cannot track or hit air units effectively.

Sqf

Apply
if (_target isKindOf "Air") exitWith { 0 };
Tier Restriction: Checks the global tierWar variable. If the war tier is less than 5, artillery is unavailable (weight 0).

Sqf

Apply
if(tierWar < 5) exitWith { 0 };
Weight Calculation: Calculates a linear weight based on the current war tier. The weight increases as the war progresses.

Sqf

Apply
(tierWar - 4) / 12;
Where it leads:

Called Functions: None directly.
Dependencies: None.
Global Variables:
Read: tierWar (global int).
Network/Exec: Runs on the machine calling the support selection logic (Server or Headless Client).
Edge Cases:
Returns 0 if _target is "Air".
Returns 0 if tierWar is less than 5.
Function Name: 
fn_SUP_ASF.sqf
 What it does: Sets up an Air Superiority Fighter (ASF) support. It selects a fighter jet from the faction, finds an airbase, calculates a delay, and registers the support. It does not spawn the aircraft immediately; that is handled by the routine spawned at the end. How it does that:

Parameter Extraction:

Sqf

Apply
params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Airbase Selection: Calls A3A_fnc_availableBasesAir to find a suitable airport for the side.

Sqf

Apply
private _airport = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airport") exitWith { Debug_1("No airport found for %1 support", _supportName); -1; };
Aircraft Selection: Selects a random aircraft from the faction's vehiclesPlanesAA or vehiclesPlanesLargeAA lists.

Sqf

Apply
private _faction = Faction(_side);
private _vehType = selectRandom ((_faction get "vehiclesPlanesAA") + (_faction get "vehiclesPlanesLargeAA"));
Delay Calculation: Calculates delay based on aggression and the A3A_enemyResponseTime setting.

Sqf

Apply
private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (100 - _aggro + 18*A3A_enemyResponseTime) };
Target Handling: Prepares the target array. If a specific target object is provided, it logs the strike to A3A_supportStrikes (for "Target Killed" notifications).

Sqf

Apply
private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "TARGET", _target, time + 1200, 1200, 200];
    _targArray = [_target, _targPos];
};
Support Registration: Creates the active support data entry.

Sqf

Apply
private _suppData = [_supportName, _side, "ASF", _targPos, 10000, _targArray];
A3A_activeSupports pushBack _suppData;
Routine Spawning: Spawns the A3A_fnc_SUP_ASFRoutine which handles the actual flight mechanics and attack logic.

Sqf

Apply
[_suppData, _resPool, _airport, _vehType, _delay, _reveal] spawn A3A_fnc_SUP_ASFRoutine;
[_reveal, _side, "ASF", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;
Return Cost: Returns the resource cost.

Sqf

Apply
(A3A_vehicleResourceCosts get _vehType) + 0;
Where it leads:

Called Functions:
A3A_fnc_availableBasesAir: Finds an airport.
Faction(_side): Retrieves faction data.
A3A_fnc_SUP_ASFRoutine: The logic loop for the fighter jet (spawns immediately).
A3A_fnc_showInterceptedSetupCall: UI notification.
Dependencies:
Relies on A3A_supportStrikes for mission tracking.
Global Variables:
Modified: A3A_supportStrikes, A3A_activeSupports.
Read: aggressionOccupants, aggressionInvaders, A3A_enemyResponseTime.
Network/Exec: Server-side script that spawns scheduled code.
Edge Cases:
Returns -1 if no airbase is available.
Function Name: 
fn_SUP_ASFAvailable.sqf
 What it does: Determines the weight for the ASF support option. It is strictly limited to targets that are themselves aircraft. How it does that:

Target Kind Check: Checks if the target is of kind "Air". If not, the weight is 0 (ASFs are anti-air, not ground attack).

Sqf

Apply
if !(_target isKindOf "Air") exitWith { 0 };
Return Weight: Returns a fixed weight of 1 if the target is an aircraft.

Sqf

Apply
1;
Where it leads:

Called Functions: None.
Dependencies: None.
Global Variables: None.
Network/Exec: Logic check on the calling machine.
Edge Cases:
Returns 0 for ground or sea targets.
Function Name: 
fn_SUP_ASFRoutine.sqf
 What it does: Manages the lifecycle of an Air Superiority Fighter. It spawns the plane, creates a loiter waypoint, and cycles through a target list. When a valid enemy air target is acquired, it switches to a "Destroy" waypoint to engage. It handles cleanup and return to base. How it does that:

Preparation Delay: Sleeps for the calculated _sleepTime to simulate flight preparation/rally time.

Sqf

Apply
sleep _sleepTime;
Aircraft Spawning: Spawns the plane at the airport marker. It sets the direction, altitude (1000m), and initial velocity to prevent stalling.

Sqf

Apply
private _spawnPos = (markerPos _airport);
private _plane = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
_plane setDir (_spawnPos getDir _suppCenter);
_plane setPosATL (_spawnPos vectorAdd [0, 0, 1000]);
_plane setVelocityModelSpace [0, 150, 0];
_plane flyInHeight 1000;
[_plane, _side, _resPool] call A3A_fnc_AIVehInit;
Crew and Loadout: Creates the crew, initializes them, and sets the plane loadout to "AA" (Anti-Air).

Sqf

Apply
private _group = [_side, _plane] call A3A_fnc_createVehicleCrew;
{ [_x, nil, false, _resPool] call A3A_fnc_NATOinit } forEach units _group;
[_plane, "AA"] call A3A_fnc_setPlaneLoadout;
Loiter Waypoint: Clears existing waypoints and adds a "Loiter" waypoint at the target center (_suppCenter) with a 2000m radius.

Sqf

Apply
private _loiterWP = _group addWaypoint [_suppCenter, 0];
_loiterWP setWaypointType "Loiter";
_loiterWP setWaypointLoiterRadius 2000;
Engagement Loop: The main while loop checks conditions:

Target Acquisition: If not attacking and _remTargets > 0, it checks A3A_supportStrikes or the initial target array.
Attack Waypoint: Adds a DESTROY waypoint for the acquired target object.
State Management: Switches group behaviour to COMBAT and RED mode.
Target Monitoring: Checks if the target is destroyed or has moved out of the patrol radius. If so, it resets to loiter and decrements _remTargets.
Cleanup: Sets the active support radius to 0 (signaling completion) and triggers despawners.
Sqf

Apply
// ... Logic loop handling waypoints and state ...
_suppData set [4, 0];
[_group] spawn A3A_fnc_groupDespawner;
[_plane] spawn A3A_fnc_vehDespawner;
Return to Base: If the plane is still functional, it clears waypoints and creates a move waypoint back to the spawn position. Once close, the crew and plane are deleted.

Sqf

Apply
private _wpBase = _group addWaypoint [_spawnPos, 0];
waitUntil { sleep 2; (currentWaypoint _group != 0) or (time > _timeout) };
{ deleteVehicle _x } forEach (units _group);
deleteVehicle _plane;
Where it leads:

Called Functions:
A3A_fnc_AIVehInit: Initializes vehicle.
A3A_fnc_createVehicleCrew: Spawns pilot/gunner.
A3A_fnc_NATOinit: AI setup.
A3A_fnc_setPlaneLoadout: Configures pylons.
A3A_fnc_showInterceptedSupportCall: Notifies players of engagement.
A3A_fnc_groupDespawner / A3A_fnc_vehDespawner: Cleanup.
Dependencies:
Reads A3A_supportStrikes to find dynamic targets.
Global Variables:
Modified: A3A_activeSupports (index 4 set to 0).
Read: None specific to globals.
Network/Exec: Server-side, scheduled.
Edge Cases:
Handles plane destruction via canFire check.
Handles timeout (900 seconds) to prevent planes lingering indefinitely.
Function Name: 
fn_SUP_carpetBombs.sqf
 What it does: Sets up a carpet bombing support event. This is a visual and area-of-effect event triggered from a carrier or designated location. It does not spawn a physical aircraft entity but simulates the drop zone. How it does that:

Parameter Extraction:

Sqf

Apply
params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Delay Calculation: Calculates delay based on war tier and aggression.

Sqf

Apply
private _aggroValue = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (350 - 15*tierWar - 1*_aggroValue) };
Strike Area Logging: Adds the strike area to A3A_supportStrikes to prevent friendly spawns in that zone and track the event.

Sqf

Apply
A3A_supportStrikes pushBack [_side, "AREA", _targPos, time + 1200, 1200, 300];
Routine Spawning: Spawns the SUP_carpetBombsRoutine which handles the actual bomb drops and visuals.

Sqf

Apply
[_supportName, _side, _delay, _targPos, _reveal] spawn A3A_fnc_SUP_carpetBombsRoutine;
[_reveal, _side, "CARPETBOMBS", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;
Return Cost: Returns a fixed cost of 200.

Sqf

Apply
200;
Where it leads:

Called Functions:
A3A_fnc_SUP_carpetBombsRoutine: The actual implementation.
A3A_fnc_showInterceptedSetupCall: UI feedback.
Dependencies:
A3A_supportStrikes for area denial.
Global Variables:
Modified: A3A_supportStrikes.
Read: tierWar, aggressionOccupants, aggressionInvaders.
Network/Exec: Server-side, spawns scheduled script.
Function Name: 
fn_SUP_carpetBombsRoutine.sqf
 What it does: Executes the carpet bombing visual effect. It calculates a drop vector based on the carrier marker, creates a formation of falling bombs, and detonates them over the target area. How it does that:

Delay and Visualization: Sleeps for the delay, then triggers the intercepted call visualization.

Sqf

Apply
sleep _delay;
[_reveal, _targPos, _side, "CarpetBombs", 200, 120] spawn A3A_fnc_showInterceptedSupportCall;
Vector Calculation: Determines the direction from the target to the carrier marker (NATO_carrier or CSAT_carrier).

Sqf

Apply
private _carrierMarker = if (_side == Occupants) then {"NATO_carrier"} else {"CSAT_carrier"};
private _dir = _targPos getDir markerPos _carrierMarker;
private _vectorDir = [[1,0], _dir] call BIS_fnc_rotateVector2D;
private _vectorRight = [[1,0], _dir + 90] call BIS_fnc_rotateVector2D;
Bomb Loop: Runs a loop from 0 to 20. For each iteration, it calculates a position offset based on _vectorDir (along the flight path) and _vectorRight (side-to-side spread).

It spawns a Bo_Mk82 bomb object.
Sets vector direction straight down.
Sets a downward velocity.
Sleeps 0.35 seconds between drops.
Sqf

Apply
for "_counter" from 0 to 20 do
{
    private _dropPos = _targPos vectorAdd (_vectorDir vectorMultiply (...));
    _dropPos set [2, 1000];
    private _bomb = createVehicle ["Bo_Mk82", _dropPos, [], 0 , "CAN_COLLIDE"];
    _bomb setVectorDirAndUp [[0,0,-1], [1,0,0]];
    _bomb setVelocity [0, 0, -75];
    sleep 0.35;
};
Where it leads:

Called Functions:
BIS_fnc_rotateVector2D: Math helper.
A3A_fnc_showInterceptedSupportCall: UI effect.
Dependencies:
Marker NATO_carrier or CSAT_carrier must exist.
Global Variables: None.
Network/Exec: Server-side, scheduled. Creates objects (bombs) which handle their own destruction on impact.
Edge Cases:
Relies on the carrier marker existing in the map configuration.
Function Name: 
fn_SUP_CAS.sqf
 What it does: Sets up a standard Close Air Support (CAS) mission using planes or UAVs. It selects an aircraft (including UAVs based on chance), finds an airbase, calculates delay, and registers the support. How it does that:

Airbase Selection: Finds a suitable airport for the side.

Sqf

Apply
private _airport = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airport") exitWith { ... -1; };
Vehicle Selection: Selects a plane from vehiclesPlanesCAS or vehiclesPlanesLargeCAS. If A3A_UAVSpawnChance is high enough, it includes UAV attack vehicles.

Sqf

Apply
private _vehType = "";
if (A3A_UAVSpawnChance < 0.2) then {
    _vehType = selectRandom ((_faction get "vehiclesPlanesCAS") + (_faction get "vehiclesPlanesLargeCAS"));
} else {
    _vehType = selectRandom ((_faction get "vehiclesPlanesCAS") + (_faction get "vehiclesPlanesLargeCAS") + (_faction get "uavsAttack"));
};
Delay and Target Prep: Calculates delay and prepares target array for A3A_supportStrikes.

Sqf

Apply
private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "TARGET", _target, time + 1200, 1200, 200];
    _targArray = [_target, _targPos];
};
Registration and Routine: Registers support and spawns A3A_fnc_SUP_CASRoutine.

Sqf

Apply
private _suppData = [_supportName, _side, "CAS", _targPos, 3000, _targArray];
A3A_activeSupports pushBack _suppData;
[_suppData, _resPool, _airport, _vehType, _delay, _reveal] spawn A3A_fnc_SUP_CASRoutine;
Cost Calculation: Returns vehicle cost + 100.

Sqf

Apply
(A3A_vehicleResourceCosts get _vehType) + 100;
Where it leads:

Called Functions:
A3A_fnc_availableBasesAir.
Faction(_side).
A3A_fnc_SUP_CASRoutine (spawns immediately).
A3A_fnc_showInterceptedSetupCall.
Dependencies:
A3A_UAVSpawnChance (global setting).
Global Variables:
Modified: A3A_supportStrikes, A3A_activeSupports.
Read: tierWar, aggressionOccupants, aggressionInvaders, A3A_enemyResponseTime.
Network/Exec: Server-side, spawns scheduled script.
Edge Cases:
Returns -1 if no airbase is found.
Function Name: 
fn_SUP_CASAvailable.sqf
 What it does: Calculates weight for CAS support. It penalizes infantry targets (unless the plane is just re-arming) and weights the support based on the threat level of the target vehicle. How it does that:

Target Filtering: Returns 0 for Air targets. Returns a very low weight (0.001) for Men.

Sqf

Apply
if (_target isKindOf "Air") exitWith { 0 };
if (_target isKindOf "Man") exitWith { 0.001 };
Threat Weighting: Retrieves the threat level of the ground vehicle from A3A_groundVehicleThreat and adds it to a base weight.

Sqf

Apply
private _threat = A3A_groundVehicleThreat getOrDefault [typeOf _target, 0];
0.001 + _threat / 80;
Where it leads:

Called Functions: None.
Dependencies:
A3A_groundVehicleThreat (HashMap).
Global Variables: None.
Network/Exec: Logic check.
Edge Cases:
Returns 0.001 for Infantry (to allow reuse of active support).
Function Name: 
fn_SUP_CASApproach.sqf
 What it does: The primary flight logic for standard CAS (strafing/rocket runs). It manages the aircraft's state machine (Loiter -> Approach -> Attack -> Reposition), handles target acquisition, and applies ballistic corrections to unguided munitions. How it does that:

Ammo and Loadout Analysis: Analyzes the aircraft's loadout to determine available ammo counts for main guns, rockets, and missiles, storing them in a HashMap.

Sqf

Apply
private _ammoHM = createHashMap;
private _loadout = _plane getVariable "loadout";
// ... loops through weapons and magazines to populate _ammoHM ...
_plane setVariable ["ammoCount", _ammoHM];
Ballistic Correction Event Handler: Adds a Fired event handler to the plane. When a projectile is fired:

Decrements the ammo count in the HashMap.
For Main Gun: Calculates a correction vector to steer the bullet toward the target (simulating accurate fire).
For Rockets: Waits for thrust to finish, then corrects the trajectory.
For Missiles: No correction (guided).
Triggering Bursts: The EH triggers subsequent shots if a burst count > 1 was set.
Sqf

Apply
private _firedEH = _plane addEventHandler ["Fired", {
    // ... complex ballistic math ...
    // _fnc_ballisticCorrection calculates lead and gravity
    // forceWeaponFire is used to manually trigger subsequent shots
}];
Waypoint Setup: Clears waypoints and sets a "Loiter" waypoint at _suppCenter (ALT 700m) as a base state.

Sqf

Apply
private _loiterWP = _group addWaypoint [_suppCenter, 0];
_loiterWP setWaypointType "Loiter";
State Machine (While Loop):

STATE_PICK_TARGET: Looks for targets in A3A_supportStrikes. Validates target is alive (canFight).
STATE_APPROACH: Moves the plane towards the target. Calculates line-of-sight (terrain/lineIntersect). Uses a probability check (_baseSpotChance) to "acquire" the target visually.
Attack Run: Once acquired and in range (< 2000m), it spawns A3A_fnc_SUP_CASRun to execute a fly-by attack. Waits for the run to finish.
STATE_REPOSITION: If the plane passes the target or is too close, it sets a waypoint on a 45-degree offset circle to set up another attack pass.
Ammo/Timeout Check: Exits loop if ammo is depleted or time limit reached.
Cleanup: Removes the Fired EH and sets radar off.

Sqf

Apply
_plane setVehicleRadar 0;
_plane removeEventHandler ["Fired", _firedEH];
Where it leads:

Called Functions:
A3A_fnc_SUP_CASRun (spawns to handle the actual gun/rocket firing sequence).
BIS_fnc_rotateVector2D (for repositioning logic).
A3A_fnc_canFight (target validation).
Dependencies:
Relies on A3A_supportStrikes for target priority.
Global Variables:
Read: aggressionOccupants, aggressionInvaders.
Network/Exec: Server-side, scheduled.
Edge Cases:
Terrain/Line-of-sight blocking: If target is blocked, the approach is aborted.
Ammo exhaustion: Triggers return to base logic.
Function Name: 
fn_SUP_CASRun.sqf
 What it does: Executes a single attack pass on a target. It uses setVelocityTransformation to create a smooth, straight flight path for the plane, and handles the firing logic via the EachFrame event handler. How it does that:

Fire Matrix Setup: Retreives the fire parameters (number of shots, weapon types) stored by CASApproach.

Sqf

Apply
private _fireParams = +(_plane getVariable "fireParams");
_plane setVariable ["currentTarget", _target];
Trajectory Calculation: Calculates the entry and exit positions for the attack run based on the plane's current velocity.

Sqf

Apply
private _enterRunPos = getPosASL _plane;
private _exitRunPos = _targetPos vectorAdd [0,0,20];
private _forwardSpeed = (velocityModelSpace _plane) select 1;
EachFrame Handler (Transformation): Adds an EachFrame event handler that interpolates the plane's position and velocity from _enterRunPos to _exitRunPos over the calculated time (_timeForRun).

Sqf

Apply
addMissionEventHandler ["EachFrame",
{
    _interval = (time - _startTime) / _timeForRun;
    _transform set [8, _interval];
    _plane setVelocityTransformation _transform;
    // ... trigger firing when interval > threshold ...
}];
Firing Logic: Checks the current interval. If the plane has passed specific distance markers (fire intervals), it calls the internal _fnc_executeWeaponFire function (defined in CASApproach context but passed here) to fire the weapons.

Sqf

Apply
if (_interval > _fireIntervals#0) then {
    if (_fireParams#0#0) then { [_plane, _fireParams#0] spawn _fireFnc };
    _fireParams deleteAt 0;
    _fireIntervals deleteAt 0;
};
Completion: Waits for the transformation to complete (_transform#8 >= 1), then releases controls and deploys flares.

Sqf

Apply
waitUntil { sleep 1; _transform#8 >= 1 };
for '_i' from 1 to 3 do { [_plane, "CMFlareLauncher"] call BIS_fnc_fire; ... };
Where it leads:

Called Functions:
BIS_fnc_fire (for flares).
Dependencies:
Uses variables set by CASApproach (fireParams, currentTarget, ammoCount).
Global Variables: None.
Network/Exec: Server-side, heavy on CPU (EachFrame loop).
Edge Cases:
Target dies mid-run: Exits early.
Plane takes damage: Exits early.
Function Name: 
fn_SUP_CASDiveRoutine.sqf
 What it does: Sets up a specific CAS variant intended for dive-bombing. It spawns the aircraft, initializes crew, and delegates the actual dive logic to CASDiveBomb if the plane has bomb racks, or CASApproach if it has guns (though the latter path seems unreachable in this specific file snippet). How it does that:

Spawn and Init: Similar to CASRoutine, spawns the plane at the airport.

Sqf

Apply
private _plane = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
// ... set position/velocity ...
[_plane, _side, _resPool] call A3A_fnc_AIVehInit;
[_plane, "CASDIVE"] call A3A_fnc_setPlaneLoadout;
Routine Delegation: Checks if the plane has bombRacks variable set (via loadout). If yes, calls A3A_fnc_SUP_CASDiveBomb. If no (commented out), it would call A3A_fnc_SUP_CASApproach.

Sqf

Apply
if (!isNil {_plane getVariable "bombRacks"}) then {
    [_suppData, _plane, _group, _reveal] call A3A_fnc_SUP_CASDiveBomb;
};
Cleanup and Return: Handles the post-mission phase, sending the plane back to base and despawning.

Sqf

Apply
_suppData set [4, 0];
[_group] spawn A3A_fnc_groupDespawner;
[_plane] spawn A3A_fnc_vehDespawner;
// ... Fly back logic ...
Where it leads:

Called Functions:
A3A_fnc_AIVehInit.
A3A_fnc_setPlaneLoadout.
A3A_fnc_SUP_CASDiveBomb (primary path).
A3A_fnc_groupDespawner / A3A_fnc_vehDespawner.
Dependencies:
Plane config must define bombRacks variable for the dive logic to trigger.
Global Variables: None.
Network/Exec: Server-side, scheduled.
Edge Cases:
If bombRacks is nil, the routine ends immediately (logic flaw in the provided snippet, as the commented code is disabled).
Function Name: 
fn_SUP_CASDiveBomb.sqf
 What it does: Manages the high-level logic for a dive-bombing run. It transitions the aircraft from a loiter state to an approach state, handles visual acquisition of the target, and then calls the specific dive run function. How it does that:

Waypoint Setup: Sets up a loiter waypoint at high altitude (_startAlt).

Sqf

Apply
private _loiterWP = _group addWaypoint [_suppCenter, 0];
_loiterWP setWaypointType "Loiter";
_loiterWP setWaypointLoiterAltitude _startAlt;
State Machine:

STATE_PICK_TARGET: Waits for a target in _suppTarget.
STATE_APPROACH: Moves the plane towards the target. Checks for visual acquisition (line of sight). If acquired and altitude is high enough, it triggers the dive run.
STATE_REPOSITION: If the approach fails (overshoot or no LOS), it moves to a reposition point.
Dive Execution: When ready, it calls A3A_fnc_SUP_CASDiveBombRun.

Sqf

Apply
private _rval = [_plane, _targetObj, _supportName, _setupWP] call A3A_fnc_SUP_CASDiveBombRun;
Post-Dive: If the run returns success (bombs dropped), it exits the loop. If failure, it switches to reposition to try again.

Sqf

Apply
if (_rval) then {
    Info_1("%1 dive bomb run completed", _supportName);
    break;
};
Where it leads:

Called Functions:
A3A_fnc_SUP_CASDiveBombRun (spawns the actual dive).
A3A_fnc_showInterceptedSupportCall.
Dependencies:
Relies on _suppTarget array being populated externally.
Global Variables: None.
Network/Exec: Server-side, scheduled.
Edge Cases:
Handles overshooting the target by resetting state.
Function Name: 
fn_SUP_CASDiveBombRun.sqf
 What it does: This is the intensive flight physics function for dive-bombing. It manually controls the aircraft's position, velocity, and vector to perform a realistic dive towards the target, releasing bombs at a specific altitude. How it does that:

Pre-Positioning Loop: Calculates the "dive distance" (horizontal distance required to descend from start altitude to release altitude at the dive angle). It steers the plane towards a point 1000m past the target to align the dive path.

Sqf

Apply
private _diveDist = (getPosATL _plane#2) / tan _diveAngle;
// ... Logic to check if plane is close to the dive entry point ...
Dive Phase (EachFrame Handler): Once positioned, an EachFrame handler takes over:

Calculates the target position with lead (moving target).
Vector Rotation: Applies rotation towards the target using Rodrigues' rotation formula (smooth turning).
Position Update: Manually updates the plane's position (setPosASL) and velocity based on the calculated vector and dive speed.
Dive Angle: Maintains the steep dive angle.
Sqf

Apply
// ... Rodrigues' formula for rotation ...
private _nextPos = (_plane getVariable "A3A_diveLastPos") vectorAdd (_dir vectorMultiply _diveSpeed*diag_deltaTime);
_plane setPosASL _nextPos;
_plane setVelocity (_dir vectorMultiply _diveSpeed);
Bomb Release: Checks altitude. When getPosASL _plane#2 - getPosASL _target#2 < _endAlt, it executes the bomb drop.

It iterates through _plane getVariable "bombRacks".
Uses forceWeaponFire on driver/gunner/commander to release all bombs in the rack.
Sqf

Apply
{
    private _bombMags = getArray (configFile >> "CfgWeapons" >> _x >> "magazines");
    // ... Count ammo ...
    for "_i" from 1 to _ammoCount do {
        driver _plane forceWeaponFire [_weaponState#1, _weaponState#2];
        // ... repeat for gunner/commander ...
    };
} forEach (_plane getVariable "bombRacks");
Cleanup: Removes the EachFrame handler and the Fired EH (previously added).

Sqf

Apply
removeMissionEventHandler ["EachFrame", _ehID];
_plane removeEventHandler ["Fired", _firedEH];
Where it leads:

Called Functions:
BIS_fnc_fire (possibly in EH).
Dependencies:
Plane must have bombRacks variable set.
Plane must have diveParams variable set (array of dive physics constants).
Global Variables: None.
Network/Exec: Server-side, very CPU intensive (EachFrame loop with vector math).
Edge Cases:
Target destroyed during dive: Exits handler.
Overshoot: Returns false.
Bad heading at release: Drops no bombs.

Function: 
fn_SUP_CASDiveRoutine.sqf
Function Name: A3A_fnc_SUP_CASDiveRoutine
File: A3A/addons/core/functions/Supports/fn_SUP_CASDiveRoutine.sqf

What it does:
This function creates and manages a Close Air Support (CAS) aircraft tasked with conducting a dive-bombing attack run. It is specifically designed for "CASDIVE" missions, where the aircraft performs a low-level diving attack on a designated target, dropping bombs, and then returning to its home base if it survives. It is intended to be spawned on the server in a scheduled environment.

How it does that:
Parameter Extraction: The function starts by unpacking the arguments and extracting relevant data from the support structure.

Sqf

Apply
params ["_suppData", "_resPool", "_airport", "_planeType", "_sleepTime", "_reveal"];
_suppData params ["_supportName", "_side", "_suppType", "_suppCenter", "_suppRadius", "_suppTarget"];
Preparation Delay: It simulates preparation time by sleeping for _sleepTime seconds.

Sqf

Apply
sleep _sleepTime;
Aircraft Spawning: It locates the spawn point at the specified airport and creates the aircraft object in the sky with forward velocity to prevent it from falling.

Sqf

Apply
private _spawnPos = (markerPos _airport);
private _plane = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
_plane setDir (_spawnPos getDir _suppCenter);
_plane setPosATL (_spawnPos vectorAdd [0, 0, 500]);
_plane setVelocityModelSpace [0, 150, 0];
_plane flyInHeight 500;
Initialization: The vehicle is initialized using A3A_fnc_AIVehInit (setting up event handlers and crew simulation) and assigned a specific loadout for CASDIVE missions via A3A_fnc_setPlaneLoadout.

Sqf

Apply
[_plane, _side, _resPool] call A3A_fnc_AIVehInit;
[_plane, "CASDIVE"] call A3A_fnc_setPlaneLoadout;
Crew Creation: A crew group is created for the aircraft. The crew members are initialized (calling A3A_fnc_NATOinit), and the pilot is given "Manual Fire" capability to bypass standard AI limitations. The group is set to "CARELESS" behavior to ignore threats.

Sqf

Apply
private _group = [_side, _plane] call A3A_fnc_createVehicleCrew;
{ [_x, nil, false, _resPool] call A3A_fnc_NATOinit } forEach units _group;
(driver _plane) action ["ManualFire", _plane];
_group deleteGroupWhenEmpty true;
_group setBehaviourStrong "CARELESS";
Killed Event Handler: An event handler is attached to the aircraft to notify players if the CAS asset is destroyed.

Sqf

Apply
_plane addEventHandler ["Killed", {
    params ["_plane"];
    ["TaskSucceeded", ["", localize "STR_notifiers_cas_killed"]] remoteExec ["BIS_fnc_showNotification", teamPlayer];
}];
Bombing Execution: It checks if the plane has variable bombRacks defined (implying it has bombs loaded). If true, it calls A3A_fnc_SUP_CASDiveBomb to initiate the diving attack run.

Sqf

Apply
if (!isNil {_plane getVariable "bombRacks"}) then {
    [_suppData, _plane, _group, _reveal] call A3A_fnc_SUP_CASDiveBomb;
};
Cleanup Signaling: The function sets the active support radius to 0 in the support data array. This is a flag used by the global cleanup system to identify the support as completed.

Sqf

Apply
_suppData set [4, 0];
Despawning Setup: It schedules the group and vehicle for despawning (cleanup) via A3A_fnc_groupDespawner and A3A_fnc_vehDespawner. Note that this cleanup is delayed until the vehicle is returned or destroyed.

Sqf

Apply
[_group] spawn A3A_fnc_groupDespawner;
[_plane] spawn A3A_fnc_vehDespawner;
Return to Base Logic: If the aircraft is still moving and the pilot is alive/able to fight, the function calculates a path back to the spawn airport. It deletes existing waypoints, adds a move waypoint to the airport, and sets a timeout based on distance.

If the plane reaches the airport (or close enough), it deletes the vehicle and crew.
If the timeout is reached, the routine exits without immediate deletion (leaving it for the despawner).
Sqf

Apply
if (canMove _plane && {driver _plane call A3A_fnc_canFight}) then {
    while {count waypoints _group > 0} do { deleteWaypoint [_group, 0] };
    private _wpBase = _group addWaypoint [_spawnPos, 0];
    _wpBase setWaypointSpeed "NORMAL";
    _wpBase setWaypointBehaviour "CARELESS";
    _group setCurrentWaypoint _wpBase;

    private _timeout = time + (getPos _plane distance2d _spawnPos) / 20;
    waitUntil { sleep 2; (currentWaypoint _group != 0) or (time > _timeout) };
    if (time > _timeout) exitWith {};
    { deleteVehicle _x } forEach (units _group);
    deleteVehicle _plane;
};
Where it leads:
Directly Calls:

A3A_fnc_AIVehInit: Initializes the vehicle.
A3A_fnc_setPlaneLoadout: Configures the weapon pylons.
A3A_fnc_createVehicleCrew: Spawns pilot/gunner.
A3A_fnc_NATOinit: Initializes crew AI.
A3A_fnc_SUP_CASDiveBomb: Handles the actual attack run logic.
A3A_fnc_groupDespawner: Schedules group deletion.
A3A_fnc_vehDespawner: Schedules vehicle deletion.
A3A_fnc_canFight: Checks pilot status (likely defined in AI\fn_canFight.sqf).
Dependencies:

Relies on A3A_activeSupports (global variable, usually via _suppData) for context.
Relies on A3A_faction_all (via A3A_fnc_setPlaneLoadout) for loadout definitions.
Global Variable Modification:

Modifies _suppData (index 4) to signal completion to the cleanup system.
Modifies teamPlayer notifications.
Network Implications:

Remote executes BIS_fnc_showNotification to teamPlayer on death.
Function: 
fn_SUP_CASDiveRun.sqf
Function Name: A3A_fnc_SUP_CASDiveRun
File: A3A/addons/core/functions/Supports/fn_SUP_CASDiveRun.sqf

What it does:
This function controls the specific "gun run" or attack pass of a CAS aircraft. It calculates a 3D flight path (a "transform") to guide the plane over the target at a specific speed and dive angle, while triggering weapon fire at calculated intervals along the path.

How it does that:
Parameter Extraction & Setup: Extracts the aircraft, target, and support name. It enables the aircraft's radar and retrieves the pre-defined firing parameters (fireParams) from the plane's variables.

Sqf

Apply
params ["_plane", "_target", "_supportName"];
_plane setVehicleRadar 1;
private _fireParams = +(_plane getVariable "fireParams");
_plane setVariable ["currentTarget", _target];
Flight Path Calculation:

Calculates the start point (_enterRunPos) and target eye position (_targetPos).
Checks for terrain intersection between the plane and the target. If blocked, it exits immediately.
Calculates the exit point, forward speed, and time required for the run.
Constructs a transformation array (_transform) using vector math (position, velocity vector, forward direction vector, up vector) to define the plane's movement for setVelocityTransformation.
Sqf

Apply
private _enterRunPos = getPosASL _plane;
private _targetPos = eyePos _target;
if(terrainIntersectASL [_enterRunPos, _targetPos]) exitWith { ... };

private _exitRunPos = _targetPos vectorAdd [0,0,20];
private _forwardSpeed = (velocityModelSpace _plane) select 1;
private _timeForRun = (_enterRunPos vectorDistance _exitRunPos) / _forwardSpeed;
private _forward = _enterRunPos vectorFromTo _exitRunPos;
private _speedVector = _forward vectorMultiply _forwardSpeed;
private _upVector = _forward vectorCrossProduct (vectorUp _plane) vectorCrossProduct _forward;
private _transform = [_enterRunPos, _exitRunPos, _speedVector, _speedVector, _forward, _forward, _upVector, _upVector, 0];
Fire Interval Setup: It calculates relative distance points (0.0 to 1.0) where the plane should fire based on distance to the target (700m, 1000m, 1500m). It syncs the number of fire parameters with these intervals.

Sqf

Apply
private _fireIntervals = [];
private _runDist = _plane distance2d _target;
{ if (_runDist > _x) then { _fireIntervals pushBack (1 - _x / _runDist) } } forEach [700, 1000, 1500];
reverse _fireIntervals;
while { count _fireParams > count _fireIntervals } do { _fireParams deleteAt 0 };
EachFrame Event Handler: An EachFrame event handler is added to handle the real-time flight and firing.

Calculates the progress _interval (0.0 to 1.0).
Checks for termination conditions: target dead, plane too close, timeout, or pilot loss. If met, it sets the transform progress to 1.0 and removes the event handler.
Updates the plane's position using setVelocityTransformation.
Checks if the current progress passes a fire interval. If so, it spawns the _fnc_executeWeaponFire function and removes the used interval/parameter.
Sqf

Apply
addMissionEventHandler ["EachFrame", {
    _thisArgs params ["_plane", "_target", "_startTime", "_timeForRun", "_transform", "_fireParams", "_fireFnc", "_fireIntervals"];
    _interval = (time - _startTime) / _timeForRun;

    if (!alive _target or (_plane distance2d _target) < 300 or _interval > 0.95 or !canMove _plane or isNull driver _plane) exitWith {
        _transform set [8, 1];
        removeMissionEventHandler ["EachFrame", _thisEventHandler];
    };

    _transform set [8, _interval];
    _plane setVelocityTransformation _transform;

    if (_interval > _fireIntervals#0) then {
        if (_fireParams#0#0) then { [_plane, _fireParams#0] spawn _fireFnc };
        _fireParams deleteAt 0;
        _fireIntervals deleteAt 0;
    };
}, [...]];
Execution Function (_fnc_executeWeaponFire): This local function handles the actual weapon firing logic:

Missiles: Selects the weapon with the most ammo, locks on to the target, and fires.
Rockets: Selects a rocket weapon, calculates the appropriate fire mode and reload time, and forces the weapon fire.
Main Gun: Selects the main gun, determines the mode (e.g., "close"), and forces fire.
It uses forceWeaponFire to bypass AI firing restrictions.
Completion and Cleanup: The waitUntil loop pauses execution until the transform is complete (_transform#8 >= 1). Upon completion:

Disables radar.
Fires countermeasures (flares) in a loop to simulate evasive maneuvers.
The event handler is automatically removed during the exit condition.
Sqf

Apply
waitUntil { sleep 1; _transform#8 >= 1 };
_plane setVehicleRadar 0;
for '_i' from 1 to 3 do {
    [_plane, "CMFlareLauncher"] call BIS_fnc_fire;
    [_plane, "CMFlareLauncher_Triples"] call BIS_fnc_fire;
    [_plane, "CMFlareLauncher_Singles"] call BIS_fnc_fire;
    sleep 1;
};
Where it leads:
Directly Calls:

BIS_fnc_fire: Fires countermeasures.
Internal execution _fnc_executeWeaponFire (spawns):
forceWeaponFire: Internal ArmA command for AI.
fireAtTarget: Internal ArmA command for missiles.
Dependencies:

Requires _plane to have variables fireParams, missileLauncher, rocketLauncher, mainGun, and ammoCount set (usually by A3A_fnc_setPlaneLoadout).
Global Variable Modification:

None directly, modifies local scope variables and plane local variables.
Network Implications:

None (server-side only).
Function: 
fn_SUP_CASRoutine.sqf
Function Name: A3A_fnc_SUP_CASRoutine
File: A3A/addons/core/functions/Supports/fn_SUP_CASRoutine.sqf

What it does:
Creates and maintains a standard Close Air Support (CAS) aircraft. Unlike the dive routine, this one is designed for a more general attack pattern, likely involving an approach run and potentially a gun run (if implemented in the commented-out section). It handles spawning, crew creation, attack execution, and returning to base.

How it does that:
Parameter Extraction: Unpacks support data, resource pool, airport, plane type, delay, and reveal level.

Sqf

Apply
params ["_suppData", "_resPool", "_airport", "_planeType", "_sleepTime", "_reveal"];
_suppData params ["_supportName", "_side", "_suppType", "_suppCenter", "_suppRadius", "_suppTarget"];
Preparation: Sleeps for the defined delay to simulate setup time.

Sqf

Apply
sleep _sleepTime;
Aircraft Spawning: Spawns the plane at the airport marker, sets direction towards the target, and places it at altitude with forward velocity.

Sqf

Apply
private _spawnPos = (markerPos _airport);
private _plane = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
_plane setDir (_spawnPos getDir _suppCenter);
_plane setPosATL (_spawnPos vectorAdd [0, 0, 500]);
_plane setVelocityModelSpace [0, 150, 0];
_plane flyInHeight 500;
Initialization & Loadout: Initializes the vehicle (A3A_fnc_AIVehInit) and sets the loadout to "CAS" (standard CAS, not necessarily dive).

Sqf

Apply
[_plane, _side, _resPool] call A3A_fnc_AIVehInit;
[_plane, "CAS"] call A3A_fnc_setPlaneLoadout;
Crew Creation: Creates the vehicle crew, initializes them with A3A_fnc_NATOinit, deletes the group when empty, and sets behavior to "CARELESS".

Note: It also deducts enemy resources for the crew spawn.
Sqf

Apply
private _group = [_side, _plane] call A3A_fnc_createVehicleCrew;
{ [_x, nil, false, _resPool] call A3A_fnc_NATOinit } forEach units _group;
_group deleteGroupWhenEmpty true;
_group setBehaviourStrong "CARELESS";
[-10 * count units _group, _side, _resPool] call A3A_fnc_addEnemyResources;
Radar & Death Handling: Enables the plane's radar (unlike the dive routine which enables it inside the run) and adds a "Killed" notification event handler.

Sqf

Apply
_plane setVehicleRadar 1;
_plane addEventHandler ["Killed", { ... }];
Attack Execution:

Bombing: If the plane has bombRacks, it calls A3A_fnc_SUP_CASDiveBomb (reusing the dive bomb logic for the standard CAS routine).
Approach (Commented/Optional): There is a commented-out check (and an active check in this version) for canFire and canMove. If true, it calls A3A_fnc_SUP_CASApproach (likely a gun run or strafing pass).
Sqf

Apply
if (!isNil {_plane getVariable "bombRacks"}) then {
    [_suppData, _plane, _group, _reveal] call A3A_fnc_SUP_CASDiveBomb;
};

if (canFire _plane && canMove _plane && side _plane == _side) then {
    [_suppData, _plane, _group, _reveal] call A3A_fnc_SUP_CASApproach;
};
Cleanup Signaling: Sets the support radius to 0 to indicate the active mission phase is over.

Sqf

Apply
_suppData set [4, 0];
Despawning: Schedules the group and vehicle for despawning via the despawner functions.

Sqf

Apply
[_group] spawn A3A_fnc_groupDespawner;
[_plane] spawn A3A_fnc_vehDespawner;
Return to Base: Similar to the dive routine, if the plane is alive and moving, it routes back to the spawn airport. It deletes existing waypoints, adds a new move waypoint, and waits for arrival or timeout. Upon arrival, it deletes the crew and vehicle.

Sqf

Apply
if (canMove _plane && {driver _plane call A3A_fnc_canFight}) then {
    while {count waypoints _group > 0} do { deleteWaypoint [_group, 0] };
    private _wpBase = _group addWaypoint [_spawnPos, 0];
    _wpBase setWaypointSpeed "NORMAL";
    _wpBase setWaypointBehaviour "CARELESS";
    _group setCurrentWaypoint _wpBase;

    private _timeout = time + (getPos _plane distance2d _spawnPos) / 20;
    waitUntil { sleep 2; (currentWaypoint _group != 0) or (time > _timeout) };
    if (time > _timeout) exitWith {};
    { deleteVehicle _x } forEach (units _group);
    deleteVehicle _plane;
};
Where it leads:
Directly Calls:

A3A_fnc_AIVehInit: Vehicle initialization.
A3A_fnc_setPlaneLoadout: Loadout configuration.
A3A_fnc_createVehicleCrew: Crew creation.
A3A_fnc_NATOinit: Crew initialization.
A3A_fnc_addEnemyResources: Deducts resources.
A3A_fnc_SUP_CASDiveBomb: Handles bombing phase.
A3A_fnc_SUP_CASApproach: Handles gun run/strafe phase.
A3A_fnc_groupDespawner: Group cleanup.
A3A_fnc_vehDespawner: Vehicle cleanup.
A3A_fnc_canFight: Pilot status check.
Dependencies:

Relies on A3A_activeSupports for data.
Relies on global resource variables (via A3A_fnc_addEnemyResources).
Global Variable Modification:

Modifies _suppData (index 4).
Modifies enemy resource pool via remote execution.
Network Implications:

Remote executes BIS_fnc_showNotification on death.
Remote executes A3A_fnc_addEnemyResources to deduct costs.
Function: 
fn_SUP_CASRun.sqf
Function Name: A3A_fnc_SUP_CASRun
File: A3A/addons/core/functions/Supports/fn_SUP_CASRun.sqf

What it does:
Performs a low-level attack run (gun run) for a CAS aircraft. It is functionally identical to 
fn_SUP_CASDiveRun.sqf
 but is used by the standard CAS routine. It manages the flight path transformation and weapon firing events.

How it does that:
The implementation is nearly identical to 
fn_SUP_CASDiveRun.sqf
, with the primary difference being the function name context and potential minor variations in weapon handling logic (e.g., firing from multiple crew positions).

Parameter & Initialization: Extracts parameters, enables radar, and clones the fireParams from the plane's variables.

Sqf

Apply
params ["_plane", "_target", "_supportName"];
_plane setVehicleRadar 1;
private _fireParams = +(_plane getVariable "fireParams");
_plane setVariable ["currentTarget", _target];
Path Calculation: Calculates the enter/exit positions and constructs the _transform array for setVelocityTransformation.

Sqf

Apply
private _enterRunPos = getPosASL _plane;
private _targetPos = eyePos _target;
if(terrainIntersectASL [_enterRunPos, _targetPos]) exitWith { ... };
private _exitRunPos = _targetPos vectorAdd [0,0,20];
// ... Vector math for _transform ...
Fire Intervals: Calculates when to fire based on distance (700m, 1000m, 1500m) and aligns the fire parameters.

Sqf

Apply
private _fireIntervals = [];
private _runDist = _plane distance2d _target;
{ if (_runDist > _x) then { _fireIntervals pushBack (1 - _x / _runDist) } } forEach [700, 1000, 1500];
reverse _fireIntervals;
while { count _fireParams > count _fireIntervals } do { _fireParams deleteAt 0 };
EachFrame Handler: Updates the plane's position and triggers weapon fire.

Difference: In _fnc_executeWeaponFire, it attempts to fire from driver, gunner, and commander turrets (whereas DiveRun might only use driver/gunner).
Sqf

Apply
addMissionEventHandler ["EachFrame", {
    // ... Logic identical to DiveRun ...
    if (_interval > _fireIntervals#0) then {
        if (_fireParams#0#0) then { [_plane, _fireParams#0] spawn _fireFnc };
        _fireParams deleteAt 0;
        _fireIntervals deleteAt 0;
    };
}, [...]];
Weapon Execution: The _fnc_executeWeaponFire function handles missile, rocket, and main gun firing.

Rocket/Main Gun: Explicitly calls forceWeaponFire for Driver, Gunner, and Commander.
Sqf

Apply
(driver _plane) forceWeaponFire [_selectedWeapon, configName _modeCfg];
(gunner _plane) forceWeaponFire [_selectedWeapon, configName _modeCfg];
(commander _plane) forceWeaponFire [_selectedWeapon, configName _modeCfg];
Completion: Waits for the transform to finish, disables radar, and fires countermeasures.

Sqf

Apply
waitUntil { sleep 1; _transform#8 >= 1 };
_plane setVehicleRadar 0;
for '_i' from 1 to 3 do {
    [_plane, "CMFlareLauncher"] call BIS_fnc_fire;
    // ...
};
Where it leads:
Directly Calls:

BIS_fnc_fire: Countermeasures.
forceWeaponFire: Weapon triggering.
fireAtTarget: Missile launching.
Dependencies:

Plane variables set by A3A_fnc_setPlaneLoadout.
Global Variable Modification:

None.
Network Implications:

None (Server-side).
Function: 
fn_SUP_cruiseMissile.sqf
Function Name: A3A_fnc_SUP_cruiseMissile
File: A3A/addons/core/functions/Supports/fn_SUP_cruiseMissile.sqf

What it does:
Prepares and initiates a cruise missile support. It selects a suitable airport (naval or air base), spawns a naval launcher (VLS), sets up the support data, and launches the routine to fire the missile.

How it does that:
Parameter Extraction: Extracts support name, side, resource pool, target object, target position, reveal level, and delay.

Sqf

Apply
params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Airport Selection: Iterates through airportsX and milbases. It filters for:

Correct side.
Spawner status (must be active/spawned).
Distance constraints (> 8000m is skipped in the code, though commented as "dumb").
Terrain checks to ensure line of sight if the target is an object.
Assigns weights based on distance (closer is preferred).
Sqf

Apply
private _airports = [];
private _weights = [];
{
    private _pos = markerPos _x;
    private _dist = _pos distance2D _targPos;
    if (_dist > 8000) then {continue};
    if (sidesX getVariable [_x,sideUnknown] != _side) then {continue};
    if (spawner getVariable _x == 0) then {continue};
    
    if (_target isEqualType objNull and {!isNull _target}) then {
        private _targDir = _pos getDir _targPos;
        private _intersectPoint = (ATLtoASL _pos) getPos [250, _targDir] vectorAdd [0,0,300];
        if (terrainIntersectASL [_intersectPoint, getPosASL _target]) then {continue};
    };

    _airports pushBack _x;
    _weights pushBack (1 / _dist^2);
} forEach (airportsX + milbases);
Launcher Spawning: Selects a launcher type based on side (NATO vs CSAT). Spawns it safely near the airport using A3A_fnc_safeVehicleSpawn.

Sqf

Apply
private _airport = _airports selectRandomWeighted _weights;
private _launcherType =["B_Ship_MRLS_01_F", "B_Ship_MRLS_01_F"] select (_side == Invaders);
private _launcher = [_launcherType, markerPos _airport, 200, 10, true] call A3A_fnc_safeVehicleSpawn;
Crew Creation & Initialization: Creates a crew group, initializes the vehicle, and initializes NATO crew AI.

Sqf

Apply
private _group = [_side, _launcher] call A3A_fnc_createVehicleCrew;
[_launcher, _side] call A3A_fnc_AIVEHInit;
_group deleteGroupWhenEmpty true;
{ [_x, nil, false] call A3A_fnc_NATOinit } forEach units _group;
Delay Calculation: Calculates the delay if not provided, based on war tier and aggression.

Sqf

Apply
private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (600 - 15*tierWar - 1*_aggro) };
Target Setup: If a target object exists, it adds an entry to A3A_supportStrikes (global tracking) and creates a target array.

Sqf

Apply
private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "TARGET", _target, time + 1200, 1200, 400];
    _targArray = [_target, _targPos];
};
Support Data & Routine Launch: Creates the _suppData array and pushes it to A3A_activeSupports. It then spawns A3A_fnc_SUP_cruiseMissileRoutine with the necessary arguments.

Sqf

Apply
private _suppData = [_supportName, _side, "CRUISEMISSILE", _targPos, 8000, _targArray];
A3A_activeSupports pushBack _suppData;
[_suppData, _launcher, _group, _delay, _reveal] spawn A3A_fnc_SUP_cruiseMissileRoutine;
Notification and Cost: Spawns the intercepted setup call notification and returns the resource cost (200).

Sqf

Apply
[_reveal, _side, "CRUISEMISSILE", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;
200;
Where it leads:
Directly Calls:

A3A_fnc_safeVehicleSpawn: Spawns the launcher.
A3A_fnc_createVehicleCrew: Creates crew.
A3A_fnc_AIVEHInit: Initializes vehicle.
A3A_fnc_NATOinit: Initializes crew.
A3A_fnc_SUP_cruiseMissileRoutine: Main logic for firing.
A3A_fnc_showInterceptedSetupCall: Notification.
Dependencies:

Relies on global arrays: airportsX, milbases, sidesX, spawner, A3A_supportStrikes, A3A_activeSupports.
Relies on configuration: A3A_faction_all (via spawn routine).
Global Variable Modification:

A3A_supportStrikes: Adds a tracking entry.
A3A_activeSupports: Adds the active support entry.
Network Implications:

Spawns a remote execution for notification.
Function: 
fn_SUP_cruiseMissileAvailable.sqf
Function Name: A3A_fnc_SUP_cruiseMissileAvailable
File: A3A/addons/core/functions/Supports/fn_SUP_cruiseMissileAvailable.sqf

What it does:
Determines if the cruise missile support is available for selection against a specific target. It checks game progression (Tier), faction template, equipment flags, and target type.

How it does that:
Parameter Extraction: Extracts the target, side, max spend, and available types.

Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Progression Checks: Checks if the war tier is at least 6. If not, returns -1 (unavailable).

Sqf

Apply
if(tierWar < 6) exitWith {-1};
Template Checks: Loads the faction template for the given side. It checks if the template is "VN" (Vietnam mod) or if the "lowTech" flag is present in equipment flags. If either is true, it returns -1.

Sqf

Apply
private _loadedTemplate = if (_side isEqualTo Occupants) then {A3A_Occ_template} else {A3A_Inv_template};
if (toLower _loadedTemplate isEqualTo "VN") exitWith {-1};
if ("lowTech" in A3A_factionEquipFlags) exitWith {-1};
Target Type Check: Checks if the target is an "Air" vehicle. Cruise missiles are generally ineffective against air targets, so this returns 0 (weight 0).

Sqf

Apply
if (_target isKindOf "Air") exitWith { 0 };
Availability: If all checks pass, it returns 1 (available with standard weight).

Sqf

Apply
1;
Where it leads:
Directly Calls:

None.
Dependencies:

tierWar: Global variable for war progression.
A3A_Occ_template / A3A_Inv_template: Global variables for faction templates.
A3A_factionEquipFlags: Global variable for equipment limitations.
Global Variable Modification:

None.
Network Implications:

None.
Function: 
fn_SUP_cruiseMissileRoutine.sqf
Function Name: A3A_fnc_SUP_cruiseMissileRoutine
File: A3A/addons/core/functions/Supports/fn_SUP_cruiseMissileRoutine.sqf

What it does:
Manages the lifecycle of a cruise missile launcher. It waits for a delay, then enters a loop where it acquires targets and fires missiles. It handles laser designation, missile flight simulation (via event handlers), and cleanup.

How it does that:
Parameter & Delay: Extracts parameters and sleeps for the preparation delay.

Sqf

Apply
params ["_suppData", "_launcher", "_group", "_delay", "_reveal"];
sleep _delay;
Fired Event Handler: Attaches an event handler to the launcher to capture the projectile object when a missile is fired. This allows tracking the missile's status.

Sqf

Apply
_launcher addEventHandler ["Fired", {
    params ["_launcher", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
    _launcher setVariable ["A3A_currentMissile", _projectile];
}];
Main Loop: Enters a while {true} loop to manage operations.

Integrity Check: Verifies the launcher and gunner are alive/can fire.
Timeout/Missile Check: Checks if the support duration has expired or missiles are depleted.
Target Acquisition: If no current target, it looks at _suppTarget. If a target exists, it validates it (alive check) and sets a timeout for engagement.
Sqf

Apply
while {true} do {
    if !(canFire _launcher and gunner _launcher call A3A_fnc_canFight) exitWith { ... };
    if (time > _timeout or _missiles <= 0) exitWith { ... };

    if (isNull _targetObj) then {
        if (_suppTarget isEqualTo []) then { sleep 5; continue };
        _targetObj = _suppTarget select 0;
        if !(alive _targetObj) exitWith { ... };
        _targTimeout = (time + 120);
        _acquisition = 0;
    };
Target Validation: Checks if the target has moved out of range or died. If so, it resets the target and goes idle.

Sqf

Apply
if (!canMove _targetObj or time > _targTimeout) then {
    _suppTarget resize 0;
    _targetObj = objNull;
    _launcher doWatch objNull;
    continue;
};
Laser Designation & Firing:

Wait: Waits for any previous missile to impact.
Create Laser: Spawns a Land_Battery_F (invisible helper) attached to the target, and a LaserTargetE attached to the battery.
Lock: Uses reportRemoteTarget and confirmSensorTarget to lock the side onto the laser.
Fire: Fires at the laser using fireAtTarget.
Sqf

Apply
if (alive (_launcher getVariable ["A3A_currentMissile", objNull])) then { sleep 1; continue };

_attachObj = createVehicle ["Land_Battery_F", (getPos _targetObj), [], 0, "CAN_COLLIDE"];
_laser = createVehicle ["LaserTargetE", (getPos _targetObj), [], 0, "CAN_COLLIDE"];
_attachObj attachTo [_targetObj, [0,0,0]];
_laser attachTo [_attachObj, [0,0,0]];

_side reportRemoteTarget [_laser, 300];
_laser confirmSensorTarget [_side, true];
_launcher fireAtTarget [_laser, "weapon_vls_01"];
Magazine Manipulation: The code manually removes and re-adds the magazine/weapon to reset the reload time, allowing for rapid firing (simulated rapid fire or switching missile types).

Sqf

Apply
_launcher removeMagazinesTurret ["magazine_Missiles_Cruise_01_x18",[0]]; 
_launcher removeWeaponTurret ["weapon_VLS_01",[0]]; 
_launcher addMagazineTurret ["magazine_Missiles_Cruise_01_Cluster_x18",[0]]; 
_launcher addWeaponTurret ["weapon_VLS_01",[0]];
Cleanup: After the loop exits (timeout or destruction), it signals completion by setting radius to 0, waits 180 seconds, and then despawns the launcher and group. It also deletes the created laser and battery objects.

Sqf

Apply
_suppData set [4, 0];
sleep 180;
[_launcher] spawn A3A_fnc_vehDespawner;
[_group] spawn A3A_fnc_groupDespawner;
deleteVehicle _laser;
deleteVehicle _attachObj;
Where it leads:
Directly Calls:

A3A_fnc_canFight: Pilot status.
A3A_fnc_showInterceptedSupportCall: Notification.
A3A_fnc_vehDespawner: Vehicle cleanup.
A3A_fnc_groupDespawner: Group cleanup.
Dependencies:

_suppData: Active support data array.
A3A_currentMissile: Plane/local variable.
Global Variable Modification:

Modifies _suppData (index 4).
Network Implications:

Spawns a remote notification execution.
Function: 
fn_SUP_gunship.sqf
Function Name: A3A_fnc_SUP_gunship
File: A3A/addons/core/functions/Supports/fn_SUP_gunship.sqf

What it does:
Sets up a Gunship support (AC-130, HMP, Pelican, etc.). It determines the specific gunship type from the faction, identifies an available air base, calculates the delay, and spawns the appropriate routine function based on the vehicle class (e.g., fn_SUP_gunshipRoutineUSAF).

How it does that:
Parameter Extraction: Extracts support name, side, resource pool, target, target position, reveal, and delay.

Sqf

Apply
params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Airport Selection: Calls A3A_fnc_availableBasesAir to find a suitable base for the specific side and target position.

Sqf

Apply
private _airport = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airport") exitWith { ... };
Delay Calculation: Calculates the delay based on war tier and aggression if not provided.

Sqf

Apply
private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (450 - 15*tierWar - 1*_aggro) };
Vehicle Selection: Retrieves the faction definition and selects a random gunship from vehiclesPlanesGunship.

Sqf

Apply
private _faction = Faction(_side);
private _oppositeSide = ...; // Determines enemy side
private _vehType = selectRandom (_faction get "vehiclesPlanesGunship");
Target Setup: Adds the target to A3A_supportStrikes if a valid object is provided and creates a target array.

Sqf

Apply
private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "AREA", _target, time + 1200, 1200, 200];
    _targArray = [_target, _targPos];
};
Vehicle Type Routing (Switch Case): This is the core logic. It creates a test vehicle instance of _vehType to determine its class inheritance.

Based on the result (e.g., VTOL_01_armed_base_F, USAF_AC130U_base, ls_hmp_base), it spawns the corresponding specific routine function (e.g., fn_SUP_gunshipRoutineV44, fn_SUP_gunshipRoutineUSAF).
It passes the _suppData, sides, faction, vehicle type, and other params to the routine.
Sqf

Apply
private _planeTest = createVehicle [_vehType, [0,0,0], [], 0, "FLY"];
switch (true) do {
    case (_planeTest isKindOf "VTOL_01_armed_base_F"): { ... spawn V44; ...};
    case (_planeTest isKindOf "USAF_AC130U_base"): { ... spawn USAF; ...};
    // ... other cases
    default { ... spawn Default; ...};
};
deleteVehicle _planeTest;
Notification & Cost: Spawns the setup notification and returns the cost (Vehicle Cost + 100).

Sqf

Apply
[_reveal, _side, "GUNSHIP", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;
(A3A_vehicleResourceCosts get _vehType) + 100;
Where it leads:
Directly Calls:

A3A_fnc_availableBasesAir: Finds spawn base.
Faction: Function to get faction data.
Various Gunship Routines (spawns):
A3A_fnc_SUP_gunshipRoutineV44
A3A_fnc_SUP_gunshipRoutineUSAF
A3A_fnc_SUP_gunshipRoutineNickelSteel
A3A_fnc_SUP_gunshipRoutinePelican
A3A_fnc_SUP_gunshipRoutineStarWarsHMP
A3A_fnc_SUP_gunshipRoutineStarWarsLAAT
A3A_fnc_SUP_gunshipRoutine3CBAC47
A3A_fnc_SUP_gunshipRoutineDefault
A3A_fnc_showInterceptedSetupCall: Notification.
Dependencies:

A3A_vehicleResourceCosts: For cost calculation.
A3A_supportStrikes: For tracking.
tierWar, aggressionOccupants/Invaders: For delay.
Global Variable Modification:

Adds to A3A_supportStrikes.
Network Implications:

Remote notification execution.
Function: 
fn_SUP_gunshipAvailable.sqf
Function Name: A3A_fnc_SUP_gunshipAvailable
File: A3A/addons/core/functions/Supports/fn_SUP_gunshipAvailable.sqf

What it does:
Calculates the weight (probability) of the Gunship support being available against a specific target. It prevents gunships from targeting air units and scales availability based on war tier.

How it does that:
Parameter Extraction: Extracts target, side, max spend, and available types.

Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Air Target Check: Returns 0 if the target is an air vehicle, as gunships are generally poor at engaging fast-moving aircraft.

Sqf

Apply
if (_target isKindOf "Air") exitWith { 0 };
Tier Check: Checks if tierWar is less than 5. If so, returns 0 (unavailable).

Sqf

Apply
if (tierWar < 5) exitWith { 0 };
Weight Calculation: Returns a linear scaling weight based on the tier. 10% chance at Tier 5, scaling up to 50% at Tier 10.

Sqf

Apply
(tierWar - 4) / 10;
Where it leads:
Directly Calls:

None.
Dependencies:

tierWar: Global variable.
Global Variable Modification:

None.
Network Implications:

None.
Function: 
fn_SUP_gunshipRoutineDefault.sqf
Function Name: A3A_fnc_SUP_gunshipRoutineDefault
File: A3A/addons/core/functions/Supports/fn_SUP_gunshipRoutineDefault.sqf

What it does:
Manages a generic gunship (not matching specific mod types). It spawns the gunship, initializes crew, enters an attack loop to find and engage targets with a specific weapon set (likely 40mm cannon and 105mm howitzer logic), and returns to base.

How it does that:
Spawning & Setup: Calls A3A_fnc_SUP_gunshipSpawn to create the vehicle and group. Spawns a single main gunner unit and moves it into the gunship.

Sqf

Apply
private _gunshipData = [_side, _airport, ...] call A3A_fnc_SUP_gunshipSpawn;
_gunshipData params ["_gunship", "_strikeGroup"];
private _mainGunner = [_strikeGroup, _faction get "unitPilot", getPos _gunship] call A3A_fnc_createUnit;
_mainGunner moveInAny _gunship;
Fired Event Handler (Physics): Adds an EH to the gunship. When a projectile is fired, it calculates a ballistic trajectory to guide the projectile towards the target (currentTarget), overriding the default flight path for better accuracy.

It calculates the direction vector from the projectile to the target and updates the projectile's velocity.
Sqf

Apply
_gunship addEventHandler ["Fired", {
    // ... params ...
    if (_target isEqualType objNull) then { _target = getPosASL _target; };
    
    [_projectile, _target] spawn {
        params ["_projectile", "_target"];
        sleep 0.1;
        _target = (_target vectorAdd [0,0,7.5]) apply {_x + (random 6) - 8};
        private _speed = (speed _projectile)/3.6;
        private _dir = vectorNormalized (_target vectorDiff (getPosASL _projectile));
        _projectile setVelocity (_dir vectorMultiply _speed);
        _projectile setVectorDir _dir;
        // ... loop to adjust flight ...
    };
}];
Attack Loop Thread: Spawns a separate thread (_mainGunnerList) to handle fire orders.

Defines _fnc_executeFireOrder which manages ammo consumption (HE/AP ammo counts) and weapon firing (forceWeaponFire).
It checks a priority target list (server variable) first, then a local list.
It validates targets (alive, can fight) and executes fire orders based on target type (Infantry vs Vehicle).
Sqf

Apply
[_gunship, _mainGunnerList, _mainGunner, _supportName] spawn {
    // ... function definition ...
    private _fnc_executeFireOrder = {
        // ... Ammo calculation ...
        // ... forceWeaponFire [_selectedWeapon, configName _modeCfg] ...
    };
    // ... Loop checks target lists ...
};
Main Life Loop: Runs for _lifeTime (400 seconds). It scans for enemies in the area (_suppCenter nearEntities).

Filters enemies by side (teamPlayer or opposite side).
Categorizes targets (Helicopter, Tank, APC, Infantry).
Pushes target data into _mainGunnerList with specific fire parameters (shots, belt type, rockets).
Sqf

Apply
private _targets = _suppCenter nearEntities [["Man", "LandVehicle", "Helicopter", "Plane", "Ship"], 400];
// ... filtering ...
{
    private _target = _x;
    if(_target isKindOf "Tank") then {
        _mainGunnerList pushBack [_target, 24, _antiTankBelt, 0];
    } else { ... };
} forEach _targets;
Exit Conditions: Breaks loop if Out of Ammo, Retreating, or Destroyed.

Return to Base: If alive, it adds a waypoint to the airport, sets statements to delete on arrival, and flies home. If it reaches the area (< 100m), it triggers the despawner.

Sqf

Apply
private _wpBase = _strikeGroup addWaypoint [(getMarkerPos _airport) vectorAdd [0, 0, 1000], 0];
_wpBase setWaypointStatements ["true", "if !(local this) exitWith {}; deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
// ... waitUntil ...
if(alive _gunship) then { [_gunship] spawn A3A_fnc_vehDespawner; };
Where it leads:
Directly Calls:

A3A_fnc_SUP_gunshipSpawn: Spawns the airframe.
A3A_fnc_createUnit: Spawns crew.
A3A_fnc_canFight: Checks target status.
A3A_fnc_vehDespawner: Cleanup.
Internal: forceWeaponFire, BIS_fnc_fire (implicit via weapon usage).
Dependencies:

Relies on server namespace for target lists (server getVariable [format ["%1_targets", _supportName], []]).
Relies on _suppCenter for scanning area.
Global Variable Modification:

Modifies server namespace variables (target lists).
Modifies gunship variables (AP_Ammo, HE_Ammo, Rockets, OutOfAmmo, etc.).
Network Implications:

None (Server-side logic).
Function: 
fn_SUP_gunshipSpawn.sqf
Function Name: A3A_fnc_SUP_gunshipSpawn
File: A3A/addons/core/functions/Supports/fn_SUP_gunshipSpawn.sqf

What it does:
A helper function that actually spawns the gunship vehicle, creates the pilot, sets up flight paths (entry and loiter), and attaches event handlers for damage and missile detection.

How it does that:
Spawning: Creates the vehicle at the airport marker, initializes it (A3A_fnc_AIVEHInit), sets direction, and positions it at 800m altitude with forward velocity.

Sqf

Apply
private _spawnPos = (getMarkerPos _airport);
private _strikePlane = createVehicle [_plane, _spawnPos, [], 0, "FLY"];
[_strikePlane, _side] call A3A_fnc_AIVEHInit;
private _startDir = _spawnPos getDir _supportPos;
_strikePlane setDir _startDir;
_strikePlane setPosATL (_spawnPos vectorAdd [0, 0, 800]);
_strikePlane setVelocityModelSpace [0, 150, 0];
Debug Markers: If __A3_DEBUG__ is defined, it spawns a loop to draw local red dots on the map tracking the gunship's position.

Crew & Group: Creates a group for the side and a pilot unit. Moves the pilot into the driver seat. Disables AI autotarget and sets combat mode to "BLUE" (hold fire) initially.

Sqf

Apply
private _strikeGroup = createGroup _side;
private _pilot = [_strikeGroup, _pilotType, getPos _strikePlane] call A3A_fnc_createUnit;
_pilot moveInDriver _strikePlane;
_strikePlane disableAI "AUTOTARGET";
_strikeGroup setCombatMode "BLUE";
Event Handlers:

Killed: Notifies players of a gunship kill and runs post-mortem.
IncomingMissile: If a vehicle fires a missile at the gunship, it checks if it's a vehicle. If so, it calls for support (ASF/SAM) against the attacker and sets the Retreat variable.
HandleDamage: Monitors damage sources. If hit by bullets from a vehicle, it adds the vehicle to the target list (if in range) or calls for support. If damage exceeds 0.5, it sets Retreat.
Sqf

Apply
_strikePlane addEventHandler ["Killed", { ... }];
_strikePlane addEventHandler ["IncomingMissile", { ... }];
_strikePlane addEventHandler ["HandleDamage", { ... }];
Waypoint Calculation: Calculates an entry point based on distance and angle to the target, ensuring the plane approaches from a distance before entering the loiter circle.

Height & Loiter Configuration: Sets flyInHeight and waypointLoiterRadius based on the specific plane class (VTOL, AC130, etc.) using a switch statement.

Sqf

Apply
switch (true) do {
    case (_strikePlane isKindOf "VTOL_01_armed_base_F"): {_strikePlane flyInHeight 600;};
    // ... others ...
};
Waypoint Creation:

Entry Point: A "MOVE" waypoint at the calculated entry position. The waypoint statement sets the InArea variable to true once reached.
Loiter Point: A "LOITER" waypoint at the target position (_supportPos), set to circle.
Sqf

Apply
private _entryPoint = _strikeGroup addWaypoint [_entryPos, 0, 1];
_entryPoint setWaypointType "MOVE";
_entryPoint setWaypointStatements ["true", "(vehicle this) setVariable ['InArea', true];"];
private _loiterWP = _strikeGroup addWaypoint [_supportPos, 0, 2];
_loiterWP setWaypointType "LOITER";
Return: Returns an array [_strikePlane, _strikeGroup] to the calling function.

Where it leads:
Directly Calls:

A3A_fnc_AIVEHInit: Vehicle initialization.
A3A_fnc_createUnit: Pilot creation.
A3A_fnc_callForSupport: If attacked (via EH).
A3A_fnc_addSupportTarget: If attacked (via EH).
A3A_fnc_postMortem: On death.
Dependencies:

A3A_vehicleResourceCosts (implicit via A3A_fnc_AIVEHInit).
Global Variable Modification:

Sets InArea on the vehicle.
Sets Retreat on the vehicle.
Calls external support functions (modifies global support arrays).
Network Implications:

None (Server-side).
Function: 
fn_SUP_howitzer.sqf
Function Name: A3A_fnc_SUP_howitzer
File: A3A/addons/core/functions/Supports/fn_SUP_howitzer.sqf

What it does:
Sets up a static Howitzer artillery support. It finds a base within range, spawns the howitzer and crew, calculates delay, and launches the mortar/artillery routine (reusing fn_SUP_mortarRoutine).

How it does that:
Parameter Extraction: Extracts arguments.

Configuration: Selects a random howitzer and shell type from the faction. Gets min/max artillery ranges using A3A_fnc_getArtilleryRanges.

Sqf

Apply
private _faction = Faction(_side);
private _vehType = selectRandom (_faction get "staticHowitzers");
private _shellType = _faction get "howitzerMagazineHE";
([_vehType, _shellType] call A3A_fnc_getArtilleryRanges) params ["_minRange", "_maxRange"];
Base Selection: Filters airportsX and milbases for:

Correct side.
Distance between min and max ranges.
Spawner status (must be 2/spawned).
Sqf

Apply
private _possibleBases = (airportsX + milbases) select {
    (sidesX getVariable [_x, sideUnknown] == _side) &&
    {(markerPos _x distance2D _targPos <= _maxRange) &&
    {(markerPos _X distance2D _targPos > _minRange) &&
    {spawner getVariable _x == 2}}}
};
Spawning: Uses A3A_fnc_safeVehicleSpawn to spawn the howitzer near the selected base. Sets the shellType variable on the vehicle. Creates crew and initializes them.

Sqf

Apply
private _vehicle = [_vehType, markerPos _base, 50, 5, true] call A3A_fnc_safeVehicleSpawn;
_vehicle setVariable ["shellType", _shellType];
// ... create crew ...
Delay Calculation: Calculates delay based on tier and aggression.

Support Data & Routine: Creates _suppData (including min range for the routine). Pushes to A3A_activeSupports. Spawns A3A_fnc_SUP_mortarRoutine with _isHeavyArty set to true.

Sqf

Apply
private _suppData = [_supportName, _side, "HOWITZER", markerPos _base, _maxRange, _targArray, _minRange];
A3A_activeSupports pushBack _suppData;
[_suppData, _vehicle, _group, _delay, _reveal, true] spawn A3A_fnc_SUP_mortarRoutine;
Notification & Cost: Spawns notification and returns cost (Vehicle Cost + 125).

Where it leads:
Directly Calls:

A3A_fnc_getArtilleryRanges: Config lookup.
A3A_fnc_safeVehicleSpawn: Spawns howitzer.
A3A_fnc_createVehicleCrew: Spawns crew.
A3A_fnc_AIVehInit: Initializes vehicle.
A3A_fnc_NATOinit: Initializes crew.
A3A_fnc_SUP_mortarRoutine: Main artillery logic.
A3A_fnc_showInterceptedSetupCall: Notification.
Dependencies:

airportsX, milbases, sidesX, spawner (global arrays).
A3A_activeSupports (global array).
Global Variable Modification:

A3A_activeSupports: Adds entry.
Network Implications:

Remote notification.
Function: 
fn_SUP_howitzerAvailable.sqf
Function Name: A3A_fnc_SUP_howitzerAvailable
File: A3A/addons/core/functions/Supports/fn_SUP_howitzerAvailable.sqf

What it does:
Calculates availability weight for Howitzer support. Checks for air targets, presence of big outposts (airports/milbases), war tier, and competition with standard artillery.

How it does that:
Air Target Check: Returns 0 if target is air.

Outpost Check: Counts how many airports/milbases belong to the side. If 0, returns 0 (no place to spawn).

Sqf

Apply
if ({sidesX getVariable [_x, sideUnknown] == _side} count (airportsX + milbases) == 0) exitWith { 0 };
Tier & Availability:

Tier < 4: Unavailable (0).
Tier < 5 AND "ARTILLERY" not in available types: Returns 1 (Standard weight).
Otherwise: Calculates a decreasing weight as tier increases (87.5% at Tier 5 to 25% at Tier 10), reducing likelihood as more advanced artillery becomes available.
Sqf

Apply
if (tierWar < 4) exitWith { 0 };
if (tierWar < 5 or !("ARTILLERY" in _availTypes)) exitWith { 1 };
1 - (tierWar - 4) / 8;
Where it leads:
Directly Calls:

None.
Dependencies:

tierWar, airportsX, milbases, sidesX.
Global Variable Modification:

None.
Network Implications:

None.
Function: 
fn_SUP_mortar.sqf
Function Name: A3A_fnc_SUP_mortar
File: A3A/addons/core/functions/Supports/fn_SUP_mortar.sqf

What it does:
Sets up a Mortar support. It finds a suitable base (outpost, airport, or milbase), finds a specific mortar spawn position if available, spawns the mortar and crew, and launches the mortar routine.

How it does that:
Parameter Extraction & Configuration: Gets mortar type and shell type from faction. Calculates ranges.

Base Selection: Filters outposts, airportsX, and milbases for side, range, and spawner status.

Sqf

Apply
private _possibleBases = (outposts + airportsX + milbases) select { ... };
Spawn Position Search: Iterates through possible bases to find a specific "Mortar" spawn position using A3A_fnc_findSpawnPosition. If found, it uses that. If not, it defaults to the base flag position with a 10m radius.

Sqf

Apply
{
    _spawnParams = [_x, "Mortar"] call A3A_fnc_findSpawnPosition;
    if (_spawnParams isEqualType []) exitWith {};
} forEach _possibleBases;
Spawning: Spawns the mortar vehicle at the determined position. Sets spawnPlace and shellType variables. Creates and initializes crew.

Sqf

Apply
private _vehicle = [_vehType, _spawnParams#0, _spawnRadius, 5, true] call A3A_fnc_safeVehicleSpawn;
_vehicle setVariable ["spawnPlace", _spawnParams#2];
_vehicle setVariable ["shellType", _shellType];
Delay Calculation: Based on tier and aggression.

Support Data & Routine: Creates _suppData (including min range). Pushes to A3A_activeSupports. Spawns A3A_fnc_SUP_mortarRoutine with _isHeavyArty set to false.

Sqf

Apply
private _suppData = [_supportName, _side, "MORTAR", _spawnParams#0, _maxRange, _targArray, _minRange];
A3A_activeSupports pushBack _suppData;
[_suppData, _vehicle, _group, _delay, _reveal, false] spawn A3A_fnc_SUP_mortarRoutine;
Notification & Cost: Spawns notification and returns cost (Vehicle Cost + (10 * Crew Count) + 100).

Where it leads:
Directly Calls:

A3A_fnc_getArtilleryRanges.
A3A_fnc_findSpawnPosition.
A3A_fnc_safeVehicleSpawn.
A3A_fnc_createVehicleCrew.
A3A_fnc_AIVehInit.
A3A_fnc_NATOinit.
A3A_fnc_SUP_mortarRoutine.
A3A_fnc_showInterceptedSetupCall.
Dependencies:

outposts, airportsX, milbases, sidesX, spawner.
A3A_activeSupports.
Global Variable Modification:

A3A_activeSupports: Adds entry.
Network Implications:

Remote notification.
Function: 
fn_SUP_mortarAvailable.sqf
Function Name: A3A_fnc_SUP_mortarAvailable
File: A3A/addons/core/functions/Supports/fn_SUP_mortarAvailable.sqf

What it does:
Calculates weight for Mortar support. Checks for air targets, war tier, and availability of artillery.

How it does that:
Air Target Check: Returns 0 if target is air.

Tier Logic:

Tier < 2: Unavailable (0).
Tier < 5 OR "ARTILLERY" not available: Returns 1 (High weight).
Otherwise: Returns a decreasing weight (91.7% at Tier 5 to 50% at Tier 10).
Sqf

Apply
if (tierWar < 2) exitWith { 0 };
if (tierWar < 5 or !("ARTILLERY" in _availTypes)) exitWith { 1 };
1 - (tierWar - 4) / 12;
Where it leads:
Directly Calls:

None.
Dependencies:

tierWar.
Global Variable Modification:

None.
Network Implications:

None.
Function: 
fn_SUP_mortarRoutine.sqf
Function Name: A3A_fnc_SUP_mortarRoutine
File: A3A/addons/core/functions/Supports/fn_SUP_mortarRoutine.sqf

What it does:
Manages a mortar or howitzer firing cycle. It rotates the weapon to face the target, calculates firing solutions (ranging shots + effect shots), and executes the fire order using an event handler to chain shots together.

How it does that:
Parameter & Initialization: Extracts parameters. Sets _timeAlive, _shotsForEffect, _maxVolleys, _reloadTime, and _spreadOffset based on whether it's heavy artillery or a mortar.

Rotation Function (_fn_rotateToTarget): Calculates the angle difference between the current dir and target dir. Uses an EachFrame event handler to slowly rotate the vehicle to face the target.

Sqf

Apply
private _change = (_mortar getDir _targPos) - getDir _mortar;
// ... logic ...
addMissionEventHandler ["EachFrame", {
    // ... Interpolate direction ...
    _mortar setDir  _newDir;
}, [...]];
Fired Event Handler (_fn_executeMortarFire): Adds a Fired event handler to the mortar.

It retrieves a queue of shots (FireOrder) from the mortar's variables.
When fired, it pops the first shot position and delay.
It spawns a sleep for the delay, then orders the mortar to fire again at the calculated position.
This creates a chain of shots without blocking the main loop.
Sqf

Apply
_mortar addEventHandler ["Fired", {
    params ["_mortar"];
    private _subTargets = _mortar getVariable ["FireOrder", []];
    if (_subTargets isEqualTo []) exitWith { ... remove EH ... };
    (_subTargets deleteAt 0) params ["_shotPos", "_delayTime"];
    [_shotPos, _delayTime, _mortar] spawn {
        sleep _delayTime;
        _mortar doArtilleryFire [_shotPos, _mortar getVariable "shellType", 1];
    }
}];
Main Loop: Runs until timeout, destroyed, or out of ammo.

Checks if mortar is intact.
Waits for a target in _target (passed from A3A_fnc_addSupportTarget).
Ballistic Calculation:
Calculates _flightTime.
Builds a list of _subTargets:
Ranging shot (offset based on distance).
Effect shots (line of fire over the target area).
Sets the FireOrder variable on the mortar.
Spawns the rotation function.
Spawns the execution function.
Decrements _maxVolleys.
Sqf

Apply
private _flightTime = _mortar getArtilleryETA [_targetPos, _mortar getVariable "shellType"];
// ... build _subTargets array ...
_mortar setVariable ["FireOrder", _subTargets];
[_mortar, _targetPos] spawn _fn_rotateToTarget;
[_mortar] spawn _fn_executeMortarFire;
Cleanup: Removes the event handler, sets support radius to 0, unassigns crew, and schedules despawn.

Sqf

Apply
_mortar removeAllEventHandlers "Fired";
_suppData set [4, 0];
{ unassignVehicle _x } forEach units _crewGroup;
[_crewGroup] spawn A3A_fnc_groupDespawner;
[_mortar] spawn A3A_fnc_VEHdespawner;
Where it leads:
Directly Calls:

A3A_fnc_canFight.
A3A_fnc_showInterceptedSupportCall.
A3A_fnc_groupDespawner.
A3A_fnc_VEHdespawner.
Internal: doArtilleryFire, getArtilleryETA.
Dependencies:

_suppData for target data.
Mortar variables (FireOrder, shellType).
Global Variable Modification:

Modifies _suppData (index 4).
Network Implications:

Spawns remote notifications.
Function: 
fn_SUP_orbitalStrike.sqf
Function Name: A3A_fnc_SUP_orbitalStrike
File: A3A/addons/core/functions/Supports/fn_SUP_orbitalStrike.sqf

What it does:
Sets up an Orbital Strike support. It calculates a delay, registers the strike in A3A_supportStrikes, and spawns the orbital strike routine.

How it does that:
Parameter Extraction: Extracts support name, side, target position, reveal, and delay.

Delay Calculation: Calculates delay based on aggression and war tier.

Sqf

Apply
private _aggroValue = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (350 - 15*tierWar - 1*_aggroValue) };
Support Strike Registration: Adds an entry to A3A_supportStrikes defining the area, end time, duration, and power.

Sqf

Apply
A3A_supportStrikes pushBack [_side, "AREA", _targPos, time + 1200, 1200, 500];
Routine Launch: Spawns A3A_fnc_SUP_orbitalStrikeRoutine with the converted target position (ASL) and reveal level.

Sqf

Apply
[_supportName, _side, _delay, ATLtoASL _targPos, _reveal] spawn A3A_fnc_SUP_orbitalStrikeRoutine;
Notification & Cost: Spawns setup notification and returns cost (500).

Where it leads:
Directly Calls:

A3A_fnc_SUP_orbitalStrikeRoutine: Main logic.
A3A_fnc_showInterceptedSetupCall: Notification.
Dependencies:

A3A_supportStrikes.
tierWar, aggressionOccupants/Invaders.
Global Variable Modification:

A3A_supportStrikes: Adds entry.
Network Implications:

Remote notification.
Function: 
fn_SUP_orbitalStrikeAvailable.sqf
Function Name: A3A_fnc_SUP_orbitalStrikeAvailable
File: A3A/addons/core/functions/Supports/fn_SUP_orbitalStrikeAvailable.sqf

What it does:
Checks availability for Orbital Strike. Requires high war tier and high resource spend.

How it does that:
Checks:

Target is Air: 0.
Max Spend < 300: 0.
Tier < 8: 0.
Sqf

Apply
if (_maxSpend < 300) exitWith { 0 };
if (tierWar < 8) exitWith { 0 };
Return: Returns 1 if available.

Where it leads:
Directly Calls:

None.
Dependencies:

tierWar.
Global Variable Modification:

None.
Network Implications:

None.
Function: 
fn_SUP_orbitalStrikeRoutine.sqf
Function Name: A3A_fnc_SUP_orbitalStrikeRoutine
File: A3A/addons/core/functions/Supports/fn_SUP_orbitalStrikeRoutine.sqf

What it does:
Executes the visual and physical effects of the orbital strike. It spawns a projectile from high altitude, plays sound/visual effects, applies physics to nearby objects (physics impulse), and destroys terrain/buildings.

How it does that:
Delay & Notification: Sleeps for delay, then spawns the intercepted strike notification.

Beam Object Spawning: Creates a "Land_Battery_F" object high above the target (_startPos) and sets its velocity downward to simulate an orbital projectile.

Sqf

Apply
private _startPos = +_impactPosition;
_startPos set [2, (_startPos select 2) + 1000];
private _strikeObject = "Land_Battery_F" createVehicle _startPos;
_strikeObject setVelocity [0,0,-200];
Beam Effects (Remote): Calculates players within 3000m and remotely executes A3A_fnc_SUP_orbitalStrikeBeamEffects on them. This creates the local particle beam and sound.

Sqf

Apply
private _players = allPlayers select {(_x distance2D _impactPosition) < 3000};
[_strikeObject] remoteExec ["A3A_fnc_SUP_orbitalStrikeBeamEffects", _players];
Impact Detection: Waits until the strike object descends below 10m altitude. Disables simulation to stop it.

Impact Effects (Remote): Remotely executes A3A_fnc_SUP_orbitalStrikeImpactEffects on players. This handles screen shake, blur, sound, and light effects.

Sqf

Apply
[_strikeObject, _impactPosition] remoteExec ["A3A_fnc_SUP_orbitalStrikeImpactEffects", _players];
Physical Damage:

Scans for objects (Static, Man, AllVehicles, Terrain objects) within 150-250m.
Physics: Applies a velocity impulse to vehicles and men based on distance (flinging them away).
Damage: Sets damage to 1 (destroyed) for vehicles and surrounding terrain objects.
Performance: Uses a counter (_destroyCounter) to batch the destruction and sleep slightly to prevent lag spikes.
Sqf

Apply
private _nearObjects = (ASLtoAGL _impactPosition) nearObjects ["Static", 200];
// ... append others ...
{
    if(_x isKindOf "Man" || _x isKindOf "AllVehicles") then {
        // ... Vector math for impulse ...
        _x setVelocity _dirVector;
        // ... Damage calculation ...
    } else {
        _x setDamage [1, false];
    };
} forEach _nearObjects;
City Destruction: Checks for cities within 200m. If found, it marks them as destroyed, updates global variables (destroyedSites, sidesX, garrison), and notifies players.

Sqf

Apply
private _citiesInRange = (citiesX - destroyedSites) select {((getMarkerPos _x) distance2D _impactPosition) < 200};
{
    ["TaskFailed", ...] remoteExec ["BIS_fnc_showNotification",teamPlayer];
    destroyedSites = destroyedSites + [_x];
    publicVariable "destroyedSites";
    sidesX setVariable [_x, Invaders, true];
    // ...
} forEach _citiesInRange;
Cleanup: Deletes the strike object and light source.

Where it leads:
Directly Calls:

A3A_fnc_showInterceptedSupportCall.
A3A_fnc_SUP_orbitalStrikeBeamEffects (Remote).
A3A_fnc_SUP_orbitalStrikeImpactEffects (Remote).
A3A_fnc_localizar (for city name).
A3A_fnc_mrkUpdate.
Dependencies:

destroyedSites, sidesX, garrison, citiesX (global arrays/variables).
beamImpactDone (global variable for synchronization).
Global Variable Modification:

destroyedSites: Adds destroyed city.
sidesX: Changes side of city.
garrison: Clears garrison.
beamImpactDone: Sets to true and broadcasts.
Network Implications:

Heavy network usage: Remote execution of visual effects to multiple clients.
Public variable updates for city destruction.
Function: 
fn_SUP_QRFAir.sqf
Function Name: A3A_fnc_SUP_QRFAir
File: A3A/addons/core/functions/Supports/fn_SUP_QRFAir.sqf

What it does:
Sets up an Air Quick Reaction Force (QRF). It selects an air base, determines the number of vehicles based on max spend, and schedules the QRF routine.

How it does that:
Parameter Extraction & Base Selection: Finds an available air base using A3A_fnc_availableBasesAir.

Force Composition: Calculates _vehCount (min 3, scaled by spend). Calculates _attackCount (number of attack vehicles, random based on vehicle count).

Calculates estimated resources (1.5x multiplier for air).
Sqf

Apply
private _vehCount = 3 min ceil (_maxSpend / A3A_balanceVehicleCost);
private _attackCount = round random ([0, 0, 0.8, 1.5] select _vehCount);
private _estResources = 1.5 * _vehCount * A3A_balanceVehicleCost;
Tracking & Delay: Adds entry to A3A_supportStrikes. Calculates delay (negative values trigger calculation based on tier/aggression).

Scheduling: Schedules A3A_fnc_SUP_QRFRoutine using A3A_fnc_scheduler. Passes the specific type "AIR".

Sqf

Apply
[[_suppName, _side, _resPool, _delay, _targPos, _airbase, "AIR", _vehCount, _attackCount, _estResources], "A3A_fnc_SUP_QRFRoutine"] call A3A_fnc_scheduler;
Notification & Cost: Estimates travel time for notification, spawns it, and returns estimated resources.

Where it leads:
Directly Calls:

A3A_fnc_availableBasesAir.
A3A_fnc_scheduler: Queues the routine.
A3A_fnc_showInterceptedSetupCall.
Dependencies:

A3A_supportStrikes.
A3A_balanceVehicleCost.
Global Variable Modification:

A3A_supportStrikes: Adds entry.
Network Implications:

Remote notification.

Function: 
fn_SUP_QRFAirAvailable.sqf
Function Name: A3A_fnc_SUP_QRFAirAvailable
File: A3A/addons/core/functions/Supports/fn_SUP_QRFAirAvailable.sqf

What it does:
Calculates weight for Air QRF. Prevents usage against AA targets or fixed-wing aircraft (unless air).

How it does that:
Target Filtering:

Checks if target is in _allAA list (AA vehicles/planes). If so, returns 0.
If target is Air: Returns 0.2 (Low chance).
If target is Vehicle (not air): Returns 0.5 (Medium chance).
If target is Man: Returns 1 (High chance).
Logic: Air QRFs are best against infantry and ground vehicles, poor against AA and other aircraft.

Where it leads:
Directly Calls:

None.
Dependencies:

A3A_faction_all: To get AA vehicle lists.
Global Variable Modification:

None.
Network Implications:

None.
Function: 
fn_SUP_QRFLand.sqf
Function Name: A3A_fnc_SUP_QRFLand
File: A3A/addons/core/functions/Supports/fn_SUP_QRFLand.sqf

What it does:
Sets up a Land QRF. Selects a land base, calculates force size, and schedules the routine.

How it does that:
Base Selection: Uses A3A_fnc_availableBasesLand.

Idle Time: Calls A3A_fnc_addTimeForIdle on the base to prevent immediate re-spawning on top of itself.

Force Composition: Calculates _vehCount and _attackCount. No 1.5x multiplier for ground forces (unlike air).

Scheduling: Schedules A3A_fnc_SUP_QRFRoutine with type "LAND". Delay is 0 (ground forces are slow enough).

Sqf

Apply
if (_delay < 0) then { _delay = 0 };
[[...], "A3A_fnc_SUP_QRFRoutine"] call A3A_fnc_scheduler;
Notification & Cost: Estimates slower travel time, spawns notification, returns resources.

Where it leads:
Directly Calls:

A3A_fnc_availableBasesLand.
A3A_fnc_addTimeForIdle.
A3A_fnc_scheduler.
A3A_fnc_showInterceptedSetupCall.
Dependencies:

A3A_supportStrikes.
A3A_balanceVehicleCost.
Global Variable Modification:

A3A_supportStrikes: Adds entry.
Network Implications:

Remote notification.
Function: 
fn_SUP_QRFLandAvailable.sqf
Function Name: A3A_fnc_SUP_QRFLandAvailable
File: A3A/addons/core/functions/Supports/fn_SUP_QRFLandAvailable.sqf

What it does:
Checks availability for Land QRF. Prevents usage against fixed-wing aircraft.

How it does that:
Target Check: If target is in A3A_faction_all "vehiclesFixedWing", returns 0. Otherwise returns 1.
Where it leads:
Directly Calls:

None.
Dependencies:

A3A_faction_all.
Global Variable Modification:

None.
Network Implications:

None.
Function: 
fn_SUP_QRFRoutine.sqf
Function Name: A3A_fnc_SUP_QRFRoutine
File: A3A/addons/core/functions/Supports/fn_SUP_QRFRoutine.sqf

What it does:
Spawns and manages a QRF force. It calls the appropriate creation function (createAttackForceLand, createAttackForceAir, etc.), monitors the force state, and controls their behavior (travelling vs. attacking).

How it does that:
Force Creation: Based on _qrfType, it calls the corresponding A3A_fnc_createAttackForce....

LAND: createAttackForceLand
AIR: createAttackForceAir
ORBITAL: createAttackForceOrbital
Returns _resources, _vehicles, _crewGroups, _cargoGroups.
Sqf

Apply
private _data = switch (_qrfType) do {
    case "LAND": { [_side, _base, ...] call A3A_fnc_createAttackForceLand; };
    case "AIR": { ... };
};
Resource Update: Adjusts the global enemy resources to reflect the actual cost vs. estimated cost.

Sqf

Apply
[_estResources - _resources, _side, _resPool] remoteExec ["A3A_fnc_addEnemyResources", 2];
Monitoring Loop: Runs for up to 30 minutes (_timeOut).

Victory Condition: If 75% of soldiers are dead (_curSoldiers <= count * 0.25), the QRF is defeated and retreats.
Travel State: Checks if the group has entered the target area (radius 300m). If so, switches to _travelling = false.
Search State: Once in the area, it checks for nearby enemies every 10 minutes. If none are found, it breaks the loop to return.
Sqf

Apply
if (_travelling and {-1 != _cargoGroups findif { leader _x distance2d _targPos < 300 }}) then {
    _travelling = false;
    _searchTime = time + 600;
};
Cleanup/Return: If the loop breaks (defeat, timeout, or no targets):

Despawns vehicles (VEHDespawner).
Crew groups are told to return to base (enemyReturnToBase).
Cargo groups either return to base or are assigned to the nearest marker (if captured) to act as garrison.
Sqf

Apply
{ [_x] spawn A3A_fnc_VEHDespawner } forEach _vehicles;
{ [_x] spawn A3A_fnc_enemyReturnToBase } forEach _crewGroups;
{
    if (isNil "_nearMrk") then { [_x] spawn A3A_fnc_enemyReturnToBase; continue };
    [_x, _nearMrk] spawn A3A_fnc_enemyReturnToBase;
} forEach _cargoGroups;
Where it leads:
Directly Calls:

A3A_fnc_createAttackForceLand
A3A_fnc_createAttackForceAir
A3A_fnc_createAttackForceOrbital
A3A_fnc_addEnemyResources
A3A_fnc_zoneCheck
A3A_fnc_VEHDespawner
A3A_fnc_enemyReturnToBase
Dependencies:

Global arrays for vehicle/crew creation.
sidesX for zone checking.
Global Variable Modification:

Modifies enemy resources (via remote exec).
Potentially modifies sidesX via zoneCheck.
Network Implications:

Remote execution for resource updates and zone checks.
Function: 
fn_SUP_tank.sqf
Function Name: A3A_fnc_SUP_tank
File: A3A/addons/core/functions/Supports/fn_SUP_tank.sqf

What it does:
Sets up a Tank QRF (Armored support). Selects a land base, determines vehicle count (min 2), and launches the tank routine.

How it does that:
Base Selection: Uses A3A_fnc_availableBasesLand.

Idle Time: Prevents immediate overlap with A3A_fnc_addTimeForIdle.

Force Composition: Calculates _vehCount (min 2). Est resources = _vehCount * 200.

Support Data & Routine: Creates _suppData with type "TANK". Pushes to A3A_activeSupports. Spawns A3A_fnc_SUP_tankRoutine.

Sqf

Apply
private _suppData = [_supportName, _side, "TANK", _targPos, 1000, _targArray];
A3A_activeSupports pushBack _suppData;
[_suppData, _resPool, _base, _vehCount, _delay, _estResources] spawn A3A_fnc_SUP_tankRoutine;
Notification & Cost: Spawns notification, returns estimated resources.

Where it leads:
Directly Calls:

A3A_fnc_availableBasesLand.
A3A_fnc_addTimeForIdle.
A3A_fnc_SUP_tankRoutine.
A3A_fnc_showInterceptedSetupCall.
Dependencies:

A3A_activeSupports.
A3A_supportStrikes.
Global Variable Modification:

Adds to A3A_supportStrikes and A3A_activeSupports.
Network Implications:

Remote notification.
Function: 
fn_SUP_tankRoutine.sqf
Function Name: A3A_fnc_SUP_tankRoutine
File: A3A/addons/core/functions/Supports/fn_SUP_tankRoutine.sqf

What it does:
Manages a group of tanks. Spawns the force, monitors state (Travel, Acquire, Attack), and handles cleanup.

How it does that:
Spawning: Calls A3A_fnc_createAttackForceLand specifically requesting tanks (type 2) and transport (0).

State Machine: Uses a switch statement with three states:

STATE_TRAVEL: Waits for vehicles to enter the _suppCenter radius. Once inside, switches to STATE_ACQUIRE.
STATE_ACQUIRE: Checks _suppTarget for a new target. If found, it reveals the target to the crew, deletes existing waypoints, and creates "DESTROY" and "SAD" (Search and Destroy) waypoints. Sets combat behavior. Switches to STATE_ATTACK. Increments timeout.
STATE_ATTACK: Monitors if the target is alive and within the support radius. If the target dies or leaves, it decrements _remTargets, clears the target, and switches back to STATE_ACQUIRE (unless out of targets).
Exit Conditions: Loop breaks if:

All vehicles are destroyed (_remVehicles empty).
Timeout reached.
_remTargets reaches 0.
Cleanup: Sets support radius to 0. Despawns vehicles and returns crew to base.

Sqf

Apply
if (alive _targetObj and {_targetObj distance2D _suppCenter < _suppRadius}) exitWith { sleep 5 };
Where it leads:
Directly Calls:

A3A_fnc_createAttackForceLand.
A3A_fnc_addEnemyResources.
A3A_fnc_VEHDespawner.
A3A_fnc_enemyReturnToBase.
Dependencies:

_suppData for target/center data.
Global Variable Modification:

Modifies _suppData (index 4).
Network Implications:

None (Server-side).

fn_SUP_orbitalStrikeBeamEffects.sqf
Function Name: fn_SUP_orbitalStrikeBeamEffects.sqf

What it does: Creates visual particle effects for an orbital strike beam. This function handles the visual representation of a descending energy beam from space, including a main beam particle effect and a lightning-like particle effect. It's designed for client-side execution only and attaches to an object that's falling from the sky.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_strikeObject"];
The function accepts one parameter: _strikeObject - an object that's leading the beam (typically falling from space).

Play Sound:
Sqf

Apply
playSound "StrikeThunder";
Immediately plays a thunder sound effect to accompany the visual beam.

Main Beam Particle Creation:
Sqf

Apply
private _mainBeamParticle = "#particlesource" createVehicleLocal (getpos _strikeObject);
Creates a local particle source at the position of the strike object.

Configure Main Beam Particle:
Sqf

Apply
_mainBeamParticle setParticleCircle [0, [0, 0, -3]];
_mainBeamParticle setParticleRandom [0, [0.25, 0.25, 0], [0.175, 0.175, 0], 0, 0.25, [0, 0, 0, 0.1], 0, 0];
_mainBeamParticle setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 8, [0, 0, 0], [0, 0, 0], 150, 1, 0, 0, [15,11,7,3], [[1, 1, 1, 1],[1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1]], [0.08], 1, 0, "", "", _strikeObject];
_mainBeamParticle setDropInterval 0.002;
Configures the particle with:

Billboard orientation
8-second lifetime
Size progression: 15 → 11 → 7 → 3 meters
White color throughout
Attach particle to _strikeObject
Fast drop interval (0.002 seconds) for dense beam appearance
Main Beam Cleanup:
Sqf

Apply
[_mainBeamParticle, _strikeObject] spawn
{
	waitUntil {sleep 0.25; (getPosATL (_this select 1)) select 2 < 10};
	deleteVehicle (_this select 0);
};
Spawns a script that waits until the strike object is less than 10 meters above ground, then deletes the particle source.

Lightning Particle Creation:
Sqf

Apply
private _beamLightningParticle = "#particlesource" createVehicleLocal (getpos _strikeObject);
Creates a second particle source for lightning effect.

Configure Lightning Particle:
Sqf

Apply
_beamLightningParticle setParticleCircle [0, [0, 0, -3]];
_beamLightningParticle setParticleRandom [0, [0.25, 0.25, 0], [0.175, 0.175, 0], 0, 0.25, [0, 0, 0, 0.1], 0, 0];
_beamLightningParticle setParticleParams [["\A3\data_f\VolumeLight", 1, 0, 1], "", "SpaceObject", 1, 8, [0, 0, 0], [0, 0, 0], 150, 1, 0, 0, [6,4,2,1], [[1, 1, 1, 1],[1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1]], [0.08], 1, 0, "", "", _strikeObject];
_beamLightningParticle setDropInterval 0.002;
Configures lightning particle with:

SpaceObject orientation
Smaller size progression: 6 → 4 → 2 → 1 meters
Also attached to _strikeObject
Lightning Particle Cleanup:
Sqf

Apply
_beamLightningParticle spawn
{
	waitUntil {sleep 0.25; beamImpactDone};
	sleep 4;
	deleteVehicle _this;
};
Spawns a script that waits for the beamImpactDone global variable to be set to true, waits 4 more seconds, then deletes the particle.

Where it leads:

Called by: A3A_fnc_SUP_orbitalStrikeRoutine (remoteExec'd to players near impact)
Depends on: Global variable beamImpactDone set by fn_SUP_orbitalStrikeRoutine
Calls: None directly (particle system is handled by Arma engine)
Part of: Orbital strike support system
Global variables modified: None (only reads beamImpactDone)
Network implications: Executed locally on client machines via remoteExec from server. No network synchronization needed as all effects are client-side only.
Execution context: Client-side only, must be spawned or called from server remoteExec.
fn_SUP_orbitalStrikeImpactEffects.sqf
Function Name: fn_SUP_orbitalStrikeImpactEffects.sqf

What it does: Creates visual, audio, and physical effects when an orbital strike impacts the ground. This includes shockwave particles, sound effects, camera shake, screen effects, and earthquake simulations based on distance from impact.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_strikeObject", "_impactPosition"];
Accepts two parameters:

_strikeObject: The object leading the beam
_impactPosition: Position in format posASL (above sea level)
Shockwave Particle Creation:
Sqf

Apply
private _shockWaveParticle = "#particlesource" createVehicleLocal getPos _strikeObject;
Creates a particle source at the strike object's position.

Configure Shockwave Particle:
Sqf

Apply
_shockWaveParticle setParticleParams [["A3\Data_F\ParticleEffects\Universal\universal.p3d", 16, 7, 48], "", "Billboard", 1, 7, [0, 0, 0], [0, 0, 0], 0, 500, 1, 0, [50, 100], [[0.1, 0.1, 0.1, 0.5], [0.5, 0.5, 0.5, 0.5], [1, 1, 1, 0.3], [1, 1, 1, 0]], [1,0.5], 0.1, 1, "", "", _strikeObject];
_shockWaveParticle setParticleRandom [2, [20, 20, 20], [5, 5, 0], 0, 0, [0, 0, 0, 0.1], 0, 0];
_shockWaveParticle setParticleCircle [50, [-80, -80, 2.5]];
_shockWaveParticle setDropInterval 0.0005;
Configures shockwave with:

Long lifetime (500 seconds)
Large size: 50 → 100 meters
Dark to white color progression
Attached to strike object
Very fast drop interval for dense effect
Shockwave Cleanup:
Sqf

Apply
_shockWaveParticle spawn
{
	waitUntil {sleep 0.25; beamImpactDone};
	deleteVehicle _this;
};
Deletes particle when beamImpactDone is set to true.

Earthquake Sound Function Definition:
Sqf

Apply
_fn_playSoundTillDead =
{
	params ["_sound", "_strikeObject", "_earthquakeStrength"];
	while {!(isNull _strikeObject)} do
	{
		playSound _sound;
		addCamShake [_earthquakeStrength, 20, 5];
		sleep 7;
	};
};
Defines a local function that continuously plays sound and shakes camera while the strike object exists.

Distance-Based Earthquake Selection:
Sqf

Apply
private _distance = player distance _impactPosition;
if(_distance > 2000) exitWith {};
if(_distance < 1000) then
{
	if(_distance < 500) then
	{
		["EarthquakeHeavy", _strikeObject, 15] spawn _fn_playSoundTillDead;
	}
	else
	{
		["EarthquakeMore", _strikeObject, 10] spawn _fn_playSoundTillDead;
	};
}
else
{
	if(_distance < 1500) then
	{
		["EarthquakeLess", _strikeObject, 5] spawn _fn_playSoundTillDead;
	}
	else
	{
		["EarthquakeLight", _strikeObject, 3] spawn _fn_playSoundTillDead;
	};
};
Selects earthquake sound based on distance:

< 500m: Heavy earthquake (strength 15)
500-1000m: More earthquake (strength 10)
1000-1500m: Less earthquake (strength 5)
1500-2000m: Light earthquake (strength 3)
2000m: No effects

Impact Sound Effects:
Sqf

Apply
[] spawn
{
	playSound "StrikeImpact";
	sleep 1;
	playSound "StrikeSound";
};
Spawns a script that plays impact sound followed by strike sound after 1 second.

Screen Effects (White Out/In and Blur):
Sqf

Apply
[_distance] spawn
{
	private _distance = _this select 0;
	cutText ["", "WHITE OUT", 1];
	titleCut ["", "WHITE IN", 1];
	private _value = 0;
	if(_distance < 1250) then
	{
		_value = 50 * (1 - (_distance/1250));
	};
	"dynamicBlur" ppEffectEnable true;
	"dynamicBlur" ppEffectAdjust [_value];
	"dynamicBlur" ppEffectCommit 0;
	"dynamicBlur" ppEffectAdjust [0.0];
	"dynamicBlur" ppEffectCommit 5;
	sleep 6;
	"dynamicBlur" ppEffectEnable false;
};
Creates visual effects:

White out/in screen transition (1 second each)
Dynamic blur effect intensity based on distance (max 50 at < 1250m)
Blur fades out over 5 seconds
Effect disabled after 6 seconds total
Camera Shake (Close Range):
Sqf

Apply
if(_distance < 750) then
{
	sleep (_distance/120);
	addCamShake [30 * (1 - (_distance/1000)), 6, 60];
};
Adds additional camera shake for close impacts (< 750m):

Delay before shake increases with distance
Shake intensity: 30 * (1 - distance/1000), max 30
Duration: 6 seconds, power: 60
Where it leads:

Called by: A3A_fnc_SUP_orbitalStrikeRoutine (remoteExec'd to players)
Depends on: Global variable beamImpactDone set by fn_SUP_orbitalStrikeRoutine
Calls:
_fn_playSoundTillDead (local function)
playSound (Arma engine)
addCamShake (Arma engine)
cutText/titleCut (Arma UI functions)
ppEffect* functions (post-processing effects)
Part of: Orbital strike support system
Global variables modified: None (only reads beamImpactDone)
Network implications: Executed locally on client machines. Effects are client-side only. Sound and camera shake affect only the local player.
Execution context: Client-side only, must be spawned or called from server remoteExec.
fn_SUP_orbitalStrikeRoutine.sqf
Function Name: fn_SUP_orbitalStrikeRoutine.sqf

What it does: Manages the complete orbital strike sequence on the server. This includes spawning a falling object, triggering visual/audio effects on clients, handling physics-based destruction of nearby objects, updating game state (destroyed cities), and cleaning up all created objects.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_supportName", "_side", "_delay", "_impactPosition", "_reveal"];
Accepts five parameters:

_supportName: Unique name for logging
_side: Side sending the support (Occupants/Invaders)
_delay: Delay time in seconds before strike
_impactPosition: Target position in posASL format
_reveal: Amount of info to reveal to rebels (0-1)
Initial Delay:
Sqf

Apply
sleep _delay;
Waits for the specified delay before starting the strike.

Show Intercepted Support Call:
Sqf

Apply
[_reveal, _impactPosition, _side, "ORBITALSTRIKE", 300, 120] spawn A3A_fnc_showInterceptedSupportCall;
Notifies players about the incoming support with reveal parameter.

Strike Object Creation:
Sqf

Apply
private _startPos = +_impactPosition;
_startPos set [2, (_startPos select 2) + 1000];

private _strikeObject = "Land_Battery_F" createVehicle _startPos;
_strikeObject setPosASL _startPos;
_strikeObject setVelocity [0,0,-200];
Creates a battery object 1000 meters above target with downward velocity of 200 m/s.

Beam Impact State Initialization:
Sqf

Apply
beamImpactDone = false;
publicVariable "beamImpactDone";
Initializes and broadcasts global variable to sync clients.

Visual Effects on Clients:
Sqf

Apply
private _players = allPlayers select {(_x distance2D _impactPosition) < 3000};
[_strikeObject] remoteExec ["A3A_fnc_SUP_orbitalStrikeBeamEffects", _players];
Identifies players within 3000m of impact and triggers beam visual effects.

Beam Light Creation:
Sqf

Apply
private _beamLight = "#lightpoint" createVehicle (getpos _strikeObject);
_beamLight setLightBrightness 150;
_beamLight setLightAmbient[0,0.5,0.8];
_beamLight setLightColor[0,0.5,0.8];
_beamLight lightAttachObject [_strikeObject, [0,0,0]];
Creates a bright blue light point attached to the falling object.

Wait for Impact:
Sqf

Apply
waitUntil {sleep 0.1; (getPosATL _strikeObject) select 2 < 10};
_strikeObject enableSimulation false;
Waits until object is 10m above ground, then disables its physics.

Impact Effects on Clients:
Sqf

Apply
[_strikeObject, _impactPosition] remoteExec ["A3A_fnc_SUP_orbitalStrikeImpactEffects", _players];
Triggers impact visual/audio effects on nearby clients.

Destruction of Nearby Objects:
Sqf

Apply
private _nearObjects = (ASLtoAGL _impactPosition) nearObjects ["Static", 200];
_nearObjects append ((ASLtoAGL _impactPosition) nearEntities [["Man", "AllVehicles"], 250]);
_nearObjects append ( nearestTerrainObjects [ASLtoAGL _impactPosition, ["BUSH", "TREE", "WALL", "FENCE", "POWER LINES", "FUELSTATION"], 150, true]);
Info_1("Found %1 objects to destroy", count _nearObjects);
Collects objects within 200-250m for destruction:

Static objects (200m)
Men and vehicles (250m)
Terrain objects (150m)
Object Destruction Loop:
Sqf

Apply
private _destroyCounter = 0;
{
    if(_x isKindOf "Man" || _x isKindOf "AllVehicles") then
    {
        private _dirVector = (getPosASL _x) vectorDiff _impactPosition;

        private _upForce = exp (- (0.0035 * (_dirVector select 2)) - (0.006 * (_x distance2D _impactPosition)));

        _dirVector set [2, 0];
        _dirVector = vectorNormalized _dirVector;

        _dirVector = _dirVector vectorMultiply 20;
        _dirVector set [2, 175 * _upForce];

        _x setVelocity _dirVector;

        if(_x isKindOf "Man") then
        {
            _x setDamage (1 - (((_x distance2D _impactPosition) - 100)/200));
        }
        else
        {
            _x setDamage 1;
        };
    }
    else
    {
        if !(_x in [mapX,flagX,vehicleBox,boxX]) then
        {
            if !(_x isKindOf "FlagCarrierCore") then
            {
                _x setDamage [1, false];
            };
        };
    };
    _destroyCounter = _destroyCounter + 1;
    if(_destroyCounter > 25) then
    {
        sleep 0.1;
        _destroyCounter = 0;
    };
} forEach _nearObjects;
For each object:

Vehicles/Units: Apply physics impulse and damage
Direction vector from impact to object
Upward force calculated based on height and distance
Horizontal velocity: 20 m/s
Vertical velocity: 175 * upForce m/s
Damage: linear scale (1 at impact, 0 at 200m for units)
Static Objects: Set damage to 1 (destroy)
Skips mission-critical objects (mapX, flagX, etc.)
Performance Throttling: Sleep 0.1s every 25 objects
Mark Impact Complete:
Sqf

Apply
beamImpactDone = true;
publicVariable "beamImpactDone";
Sets global variable to signal clients to clean up effects.

Light Fade-Out:
Sqf

Apply
[_beamLight] spawn
{
    private _light = _this select 0;
    private _lightCounter = 0;

    while {_lightCounter < 150} do
    {
        _light setLightBrightness (150 - _lightCounter);
        sleep (6/150);
        _lightCounter = _lightCounter + 1;
    };
};
Fades beam light over 6 seconds (150 steps).

Cleanup:
Sqf

Apply
sleep 8;
deleteVehicle _beamLight;
deleteVehicle _strikeObject;
Wait 8 seconds, then delete light and strike object.

City Destruction:
Sqf

Apply
private _citiesInRange = (citiesX - destroyedSites) select {((getMarkerPos _x) distance2D _impactPosition) < 200};
{
    ["TaskFailed", ["", format [localize "STR_notifiers_orbitalStrike_destruct", [_x] call A3A_fnc_localizar]]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
    destroyedSites = destroyedSites + [_x];
	publicVariable "destroyedSites";
    sidesX setVariable [_x, Invaders, true];
    garrison setVariable [_x, [], true];
    [_x] call A3A_fnc_mrkUpdate;
    sleep 10;
} forEach _citiesInRange;
For cities within 200m:

Show notification to players
Add to destroyedSites (global array)
Set side to Invaders
Clear garrison
Update marker
Wait 10s between cities
Where it leads:

Called by: A3A_fnc_createAttackForceOrbital or similar orbital strike spawning function
Depends on:
A3A_fnc_showInterceptedSupportCall
A3A_fnc_localizar
A3A_fnc_mrkUpdate
Global variables: beamImpactDone, destroyedSites, sidesX, garrison, citiesX
Calls:
A3A_fnc_showInterceptedSupportCall
A3A_fnc_localizar
A3A_fnc_mrkUpdate
remoteExec (to clients)
publicVariable
Arma engine functions: createVehicle, setVelocity, setDamage, setLight*, deleteVehicle
Part of: Orbital strike support system
Global variables modified:
beamImpactDone (server and clients)
destroyedSites (global array)
sidesX (namespace, sets destroyed cities to Invaders)
garrison (namespace, clears garrisons)
Network implications:
Executes on server
Broadcasts beamImpactDone to all clients
RemoteExecs effects to specific players
Updates global game state variables
Execution context: Server-side only, must be spawned (scheduled).

fn_SUP_QRFOrbital.sqf
Function Name: fn_SUP_QRFOrbital.sqf

What it does: Sets up an orbital Quick Reaction Force (QRF) support. This is a simplified version of orbital strike used as QRF support, spawning vehicles via orbital deployment.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_suppName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Accepts 8 parameters for QRF setup.

Airbase Selection:
Sqf

Apply
private _airbase = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airbase") exitWith { Info("QRF cancelled because no airbases available (how?)"); -1 };
Finds an available airbase for the side. Exits if none available.

Vehicle Count Calculation:
Sqf

Apply
private _vehCount = 3 min ceil (_maxSpend / A3A_balanceVehicleCost);
Calculates max 3 vehicles based on resource budget.

Attack Count Calculation:
Sqf

Apply
private _attackCount = round random ([0, 0, 0.8, 1.5] select _vehCount);
Random attack count based on vehicle count.

Resource Tracking:
Sqf

Apply
private _estResources = 1.5 * _vehCount * A3A_balanceVehicleCost;
A3A_supportStrikes pushBack [_side, "TROOPS", _targPos, time + 45*60, 45*60, _estResources];
Calculates estimated resources and adds to support strikes array.

Delay Calculation:
Sqf

Apply
private _aggro = [aggressionOccupants, aggressionInvaders] select (_side == Invaders);
if (_delay < 0) then { _delay = (0.5 + random 1) * (300 - 15*tierWar - 1*_aggro) };
Calculates delay based on war tier and aggression if not specified.

Schedule QRF Routine:
Sqf

Apply
[[_suppName, _side, _resPool, _delay, _targPos, _airbase, "ORBITAL", _vehCount, _attackCount, _estResources], "A3A_fnc_SUP_QRFRoutine"] call A3A_fnc_scheduler;
Schedules the main QRF routine execution.

Estimated Time and Interception Call:
Sqf

Apply
private _approxTime = _delay + (markerPos _airbase distance2D _targPos) / (200 / 3.6);
[_reveal, _side, "ORBITAL", _targPos, _approxTime] spawn A3A_fnc_showInterceptedSetupCall;
Calculates travel time and shows intercepted setup call.

Return Resource Cost:
Sqf

Apply
_estResources;
Returns estimated resource cost.

Where it leads:

Called by: Support request system (likely A3A_fnc_requestSupport)
Depends on:
A3A_fnc_availableBasesAir
A3A_fnc_SUP_QRFRoutine
A3A_fnc_scheduler
A3A_fnc_showInterceptedSetupCall
Global variables: A3A_balanceVehicleCost, aggressionOccupants, aggressionInvaders, tierWar, A3A_supportStrikes
Calls:
A3A_fnc_availableBasesAir
A3A_fnc_scheduler
A3A_fnc_showInterceptedSetupCall
Info (logging function)
Part of: QRF support system
Global variables modified:
A3A_supportStrikes (adds entry)
Network implications: Executes on server, schedules background task, creates interception call.
Execution context: Server-side, scheduled.
fn_SUP_QRFOrbitalAvailable.sqf
Function Name: fn_SUP_QRFOrbitalAvailable.sqf

What it does: Calculates the weight/availability of orbital QRF support against a specific target. Determines if orbital QRF is suitable and assigns a priority score.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Accepts target object, side, max spend, and available types.

Air Target Check:
Sqf

Apply
private _allAA = (A3A_faction_all get "vehiclesPlanesAA");
if (typeOf _target in _allAA) exitWith { 0 };
Exits with weight 0 if target is an anti-air vehicle (orbital strike shouldn't target AA).

Air Vehicle Check:
Sqf

Apply
if (_target isKindOf "Air") exitWith { 0.2 };
Returns low weight (0.2) for air targets.

Infantry Target Check:
Sqf

Apply
if !(_target isKindOf "Man") exitWith { 0.5 };
Returns medium weight (0.5) for non-infantry targets.

Default for Infantry:
Sqf

Apply
1;
Returns weight 1 for infantry targets.

Where it leads:

Called by: Support selection system when evaluating available support types
Depends on: Global variable A3A_faction_all (faction configuration)
Calls: None
Part of: Support availability evaluation system
Global variables modified: None (read-only access to A3A_faction_all)
Network implications: None
Execution context: Server-side, unscheduled.
fn_SUP_QRFVehAirdrop.sqf
Function Name: fn_SUP_QRFVehAirdrop.sqf

What it does: Sets up a vehicle airdrop QRF support. Spawns a vehicle via airdrop (likely parachute drop) as a QRF.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_suppName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Accepts 8 parameters for QRF setup.

Airbase Selection:
Sqf

Apply
private _airbase = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airbase") exitWith { Info("QRF cancelled because no airbases available (how?)"); -1 };
Finds an available airbase.

Vehicle Count:
Sqf

Apply
private _vehCount = 1;
Always spawns 1 vehicle for airdrop QRF.

Attack Count Calculation:
Sqf

Apply
private _attackCount = round random ([0, 0, 0.8, 1.5] select _vehCount);
Random attack count (0, 0.8, or 1.5 based on vehicle count).

Resource Tracking:
Sqf

Apply
private _estResources = 1.5 * _vehCount * A3A_balanceVehicleCost;
A3A_supportStrikes pushBack [_side, "TROOPS", _targPos, time + 45*60, 45*60, _estResources];
Calculates resources and adds to support strikes.

Delay Calculation:
Sqf

Apply
private _aggro = [aggressionOccupants, aggressionInvaders] select (_side == Invaders);
if (_delay < 0) then { _delay = (0.5 + random 1) * (300 - 15*tierWar - 1*_aggro) };
Calculates delay based on war tier and aggression.

Schedule QRF Routine:
Sqf

Apply
[[_suppName, _side, _resPool, _delay, _targPos, _airbase, "VEHAIRDROP", _vehCount, _attackCount, _estResources], "A3A_fnc_SUP_QRFRoutine"] call A3A_fnc_scheduler;
Schedules QRF routine with "VEHAIRDROP" type.

Estimated Time and Interception Call:
Sqf

Apply
private _approxTime = _delay + (markerPos _airbase distance2D _targPos) / (200 / 3.6);
[_reveal, _side, "QRFAIR", _targPos, _approxTime] spawn A3A_fnc_showInterceptedSetupCall;
Calculates travel time and shows interception call.

Return Resource Cost:
Sqf

Apply
_estResources;
Returns estimated cost.

Where it leads:

Called by: Support request system
Depends on:
A3A_fnc_availableBasesAir
A3A_fnc_SUP_QRFRoutine
A3A_fnc_scheduler
A3A_fnc_showInterceptedSetupCall
Global variables: A3A_balanceVehicleCost, aggressionOccupants, aggressionInvaders, tierWar, A3A_supportStrikes
Calls:
A3A_fnc_availableBasesAir
A3A_fnc_scheduler
A3A_fnc_showInterceptedSetupCall
Info
Part of: QRF support system
Global variables modified: A3A_supportStrikes (adds entry)
Network implications: Executes on server, schedules background task.
Execution context: Server-side, scheduled.
fn_SUP_QRFVehAirdropAvailable.sqf
Function Name: fn_SUP_QRFVehAirdropAvailable.sqf

What it does: Calculates the weight/availability of vehicle airdrop QRF support against a specific target.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Accepts target object, side, max spend, and available types.

War Tier Check:
Sqf

Apply
if(tierWar < 2) exitWith {-1};
Exits with weight -1 (unavailable) if war tier is less than 2.

Anti-Air Target Check:
Sqf

Apply
private _allAA = (A3A_faction_all get "vehiclesPlanesAA") + (A3A_faction_all get "vehiclesAA") + (A3A_faction_all get "staticAA");
if (typeOf _target in _allAA) exitWith { 0 };
Returns weight 0 if target is an anti-air vehicle or static AA.

Tank Target Check:
Sqf

Apply
if (_target isKindOf "Tank") exitWith { 0.3 };
Returns low weight (0.3) for tank targets (airborne vehicles usually have light weapons).

Default Weight Calculation:
Sqf

Apply
(tierWar - 5) / 8;
Calculates weight based on war tier: linear scale from tier 5 to tier 13.

Where it leads:

Called by: Support selection system
Depends on:
Global variable A3A_faction_all
Global variable tierWar
Calls: None
Part of: Support availability evaluation system
Global variables modified: None (read-only)
Network implications: None
Execution context: Server-side, unscheduled.
fn_SUP_SAM.sqf
Function Name: fn_SUP_SAM.sqf

What it does: Sets up a Surface-to-Air Missile (SAM) support. Spawns a SAM launcher vehicle with crew to engage air targets.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Accepts 8 parameters for SAM support setup.

Airport/Carrier Selection:
Sqf

Apply
private _airports = [];
private _weights = [];
{
    private _pos = markerPos _x;
    private _dist = _pos distance2D _targPos;
    if (_dist > 8000 or _dist < 1500) then {continue};
    if (sidesX getVariable [_x,sideUnknown] != _side) then {continue};
    if (spawner getVariable _x == 0) then {continue};
    if (garrison getVariable [_x + "_samDestroyedCD", 0] != 0) then {continue};
    
    if (_target isEqualType objNull and {!isNull _target}) then {
        private _targDir = _pos getDir _targPos;
        private _intersectPoint = (ATLtoASL _pos) getPos [250, _targDir] vectorAdd [0,0,300];
        if (terrainIntersectASL [_intersectPoint, getPosASL _target]) then {continue};
    };

    _airports pushBack _x;
    _weights pushBack (1 / _dist^2);
} forEach (airportsX + milbases);
Iterates through airports and milbases:

Distance check: 1500-8000m from target
Side ownership check
Spawn availability check
SAM destroyed cooldown check
Terrain visibility check (for initial target)
Adds to arrays with inverse square distance weighting
Airport Selection:
Sqf

Apply
if (_airports isEqualTo []) exitWith {
    Error_1("No suitable airport found for %1", _supportName); -1;
};

private _airport = _airports selectRandomWeighted _weights;
Exits if no suitable airports found, otherwise selects weighted random.

SAM Launcher Creation:
Sqf

Apply
private _launcherType = ["B_SAM_System_03_F", "O_SAM_System_04_F"] select (_side == Invaders);
private _launcher = [_launcherType, markerPos _airport, 50, 5, true] call A3A_fnc_safeVehicleSpawn;
Creates appropriate SAM launcher (NATO or CSAT) near airport.

Crew Creation:
Sqf

Apply
private _group = [_side, _launcher] call A3A_fnc_createVehicleCrew;
[_launcher, _side, _resPool] call A3A_fnc_AIVEHInit;
_group deleteGroupWhenEmpty true;
{ [_x, nil, false, _resPool] call A3A_fnc_NATOinit } forEach units _group;
Creates crew, initializes vehicle, sets group to delete when empty, and initializes crew units.

Delay Calculation:
Sqf

Apply
private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (100 - _aggro + 22*A3A_enemyResponseTime) };
Calculates delay based on aggression and enemy response time.

Target Tracking:
Sqf

Apply
private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "TARGET", _target, time + 1200, 1200, 200];
    _targArray = [_target, _targPos];
};
Tracks target in support strikes if specified.

Active Support Registration:
Sqf

Apply
private _suppData = [_supportName, _side, "SAM", _targPos, 8000, _targArray];
A3A_activeSupports pushBack _suppData;
[_suppData, _launcher, _group, _delay, _reveal] spawn A3A_fnc_SUP_SAMRoutine;
Registers support and spawns routine.

Interception Call:
Sqf

Apply
[_reveal, _side, "SAM", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;
Shows intercepted setup call.

Return Cost:
Sqf

Apply
200;
Returns fixed resource cost.

Where it leads:

Called by: Support request system
Depends on:
A3A_fnc_safeVehicleSpawn
A3A_fnc_createVehicleCrew
A3A_fnc_AIVEHInit
A3A_fnc_NATOinit
A3A_fnc_SUP_SAMRoutine
A3A_fnc_showInterceptedSetupCall
Global variables: sidesX, spawner, garrison, aggressionOccupants, aggressionInvaders, A3A_enemyResponseTime, A3A_supportStrikes, A3A_activeSupports
Calls:
A3A_fnc_safeVehicleSpawn
A3A_fnc_createVehicleCrew
A3A_fnc_AIVEHInit
A3A_fnc_NATOinit
A3A_fnc_SUP_SAMRoutine
A3A_fnc_showInterceptedSetupCall
Part of: SAM support system
Global variables modified:
A3A_supportStrikes (adds entry)
A3A_activeSupports (adds entry)
Network implications: Executes on server, spawns background routine.
Execution context: Server-side, scheduled.
fn_SUP_SAMAvailable.sqf
Function Name: fn_SUP_SAMAvailable.sqf

What it does: Calculates the weight/availability of SAM support against a specific air target.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Accepts target object, side, max spend, and available types.

Air Target Check:
Sqf

Apply
if !(_target isKindOf "Air") exitWith { 0 };
Exits with weight 0 if target is not an air vehicle (SAM only targets air).

Target Threat Calculation:
Sqf

Apply
private _targThreat = A3A_vehicleResourceCosts getOrDefault [typeOf _target, 0];
_targThreat = _targThreat + (_target getVariable ["A3A_airKills", 0]);
Calculates threat based on vehicle resource cost and air kill count.

Low Air Adjustment:
Sqf

Apply
private _lowAir = Faction(_side) getOrDefault ["attributeLowAir", false];
if (!_lowAir) then { _targThreat = _targThreat - 150 };
Reduces threat for factions with low air capability.

Weight Calculation:
Sqf

Apply
_targThreat / 500;
Returns threat divided by 500 as weight.

Where it leads:

Called by: Support selection system
Depends on:
Global variable A3A_vehicleResourceCosts
Faction(_side) function
Calls:
Faction (faction lookup function)
Part of: Support availability evaluation system
Global variables modified: None (read-only)
Network implications: None
Execution context: Server-side, unscheduled.
fn_SUP_SAMRoutine.sqf
Function Name: fn_SUP_SAMRoutine.sqf

What it does: Maintains and controls a SAM launcher support. Manages target acquisition, missile firing, and cleanup.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_suppData", "_launcher", "_group", "_delay", "_reveal"];
_suppData params ["_supportName", "_side", "_suppType", "_center", "_radius", "_suppTarget"];
Accepts support data, launcher object, crew group, delay, and reveal.

Initial Delay:
Sqf

Apply
sleep _delay;
Waits for specified delay before starting.

Missile Tracking Event Handler:
Sqf

Apply
_launcher addEventHandler ["Fired", {
    params ["_launcher", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
    _launcher setVariable ["A3A_currentMissile", _projectile];
}];
Tracks fired missiles to prevent firing until previous missile impacts.

Main Loop Variables:
Sqf

Apply
private _targetObj = objNull;
private _timeout = time + 900;
private _targTimeout = 0;
private _acquisition = 0;
private _missiles = 4;
Initialize loop variables: timeout (15 minutes), target timeout, acquisition progress, missile count.

Main Control Loop:
Sqf

Apply
while {true} do
{
    // check if launcher/crew are intact
    if !(canFire _launcher and gunner _launcher call A3A_fnc_canFight) exitWith {
        Info_1("%1 has been destroyed or disabled, aborting routine", _supportName);
    };

    // check if we're past the active time/missiles
    if (time > _timeout or _missiles <= 0) exitWith {
        Info_1("%1 has timed out or run out of missiles, aborting routine", _supportName);
    };
Checks launcher status and timeout/missile count.

Target Acquisition:
Sqf

Apply
if (isNull _targetObj) then
{
    if (_suppTarget isEqualTo []) then { sleep 5; continue };
        
    _targetObj = _suppTarget select 0;
    if !(alive _targetObj) exitWith {
        _suppTarget resize 0;
        Debug_1("%1 skips target, as it is already dead", _supportName);
        continue;
    };
    Debug_2("Next target for %2 is %1", _suppTarget, _supportName);

    [_reveal, getPosATL _targetObj, _side, "SAM", _targetObj, 60] spawn A3A_fnc_showInterceptedSupportCall;
    
    _targTimeout = (time + 120);
    _acquisition = 0;
};
Acquires new target from suppTarget array, checks if alive, shows interception call.

Target Validation:
Sqf

Apply
if (!canMove _targetObj or time > _targTimeout) then {
    Debug_1("%1 target lost or destroyed, returning to idle", _supportName);
    _suppTarget resize 0;
    _targetObj = objNull;
    _launcher doWatch objNull;
    continue;
};
Resets target if invalid or timed out.

Acquisition Progress:
Sqf

Apply
private _dir = _launcher getDir _targetObj;
private _intercept = (getPosASL _launcher) getPos [250, _dir] vectorAdd [0,0,300];
private _isBlocked = terrainIntersectASL [_intercept, getPosASL _targetObj];
_acquisition = _acquisition + ([0.1, -0.1] select _isBlocked);
_acquisition = 1 min _acquisition max 0;
_launcher doWatch _intercept;
if (_acquisition < 1) then { sleep 1; continue };
Calculates interception point, checks terrain blocking, updates acquisition (0.1 if clear, -0.1 if blocked), clamps to 0-1.

Missile Firing:
Sqf

Apply
if (alive (_launcher getVariable ["A3A_currentMissile", objNull])) then { sleep 1; continue };

 Debug("Firing at target");
 _launcher reveal [_targetObj, 4];
 _targetObj confirmSensorTarget [_side, true];
 _side reportRemoteTarget [_targetObj, 300];
 _launcher fireAtTarget [_targetObj];
 [_reveal, getPosATL _targetObj, _side, "SAM", _targetObj, 60] spawn A3A_fnc_showInterceptedSupportCall;
 _missiles = _missiles - 1;
 _targTimeout = (time + 120);
 sleep 1;
Waits for previous missile, fires at target, updates missile count and target timeout.

Cleanup:
Sqf

Apply
_suppData set [4, 0];       // zero radius to signal termination

[_launcher] spawn A3A_fnc_vehDespawner;
[_group] spawn A3A_fnc_groupDespawner;
Sets radius to 0 (signals termination), despawns vehicle and group.

Where it leads:

Called by: A3A_fnc_SUP_SAM (spawned)
Depends on:
A3A_fnc_canFight
A3A_fnc_showInterceptedSupportCall
A3A_fnc_vehDespawner
A3A_fnc_groupDespawner
Calls:
A3A_fnc_canFight
A3A_fnc_showInterceptedSupportCall
A3A_fnc_vehDespawner
A3A_fnc_groupDespawner
Arma engine: canFire, getDir, terrainIntersectASL, doWatch, fireAtTarget, reveal, confirmSensorTarget, reportRemoteTarget
Part of: SAM support system
Global variables modified: None
Network implications: Executes on server, may affect sensor targets and reveal.
Execution context: Server-side, spawned (scheduled).
fn_SUP_tankAvailable.sqf
Function Name: fn_SUP_tankAvailable.sqf

What it does: Calculates the weight/availability of tank support against a specific ground target.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Accepts target object, side, max spend, and available types.

Air Target Check:
Sqf

Apply
if (_target isKindOf "Air") exitWith { 0 };
Exits with weight 0 if target is air (tanks can't hit air).

Infantry Target Check:
Sqf

Apply
if (_target isKindOf "Man") exitWith { 0.001 };
Returns very low weight (0.001) for infantry targets (tanks re-use active supports rather than spawn new).

Threat-Based Weight:
Sqf

Apply
private _threat = A3A_groundVehicleThreat getOrDefault [typeOf _target, 0];
0.001 + _threat / 80;
Calculates threat from ground vehicle threat database, adds small base weight.

Where it leads:

Called by: Support selection system
Depends on: Global variable A3A_groundVehicleThreat
Calls: None
Part of: Support availability evaluation system
Global variables modified: None (read-only)
Network implications: None
Execution context: Server-side, unscheduled.
fn_SUP_UAV.sqf
Function Name: fn_SUP_UAV.sqf

What it does: Sets up a surveillance UAV support. Spawns an unarmed UAV for reconnaissance (not attack).

How it does that:

Parameter Validation:
Sqf

Apply
params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Accepts 8 parameters.

Airbase Selection:
Sqf

Apply
private _airport = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airport") exitWith { Debug_1("No airport found for %1 support", _supportName); -1; };
Finds available airbase.

UAV Type Selection:
Sqf

Apply
private _planeType = selectRandom (Faction(_side) get "uavsAttack");
Selects random attack UAV from faction configuration.

Delay Calculation:
Sqf

Apply
private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (300 - 15*tierWar - 1*_aggro) };
Calculates delay based on war tier and aggression.

Target Tracking:
Sqf

Apply
private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "TARGET", _target, time + 1200, 1200, 200];
    _targArray = [_target, _targPos];
};
Tracks target if specified.

Active Support Registration:
Sqf

Apply
private _suppData = [_supportName, _side, "UAV", _targPos, 1000, [objNull, _targPos]];
A3A_activeSupports pushBack _suppData;
[_suppData, _resPool, _airport, _planeType, _delay, _reveal] spawn A3A_fnc_SUP_UAVRoutine;
Registers support and spawns routine.

Interception Call:
Sqf

Apply
[_reveal, _side, "UAV", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;
Shows intercepted setup call.

Return Cost:
Sqf

Apply
(A3A_vehicleResourceCosts get _planeType) + 100;
Returns vehicle cost plus 100.

Where it leads:

Called by: Support request system
Depends on:
A3A_fnc_availableBasesAir
A3A_fnc_SUP_UAVRoutine
A3A_fnc_showInterceptedSetupCall
Global variables: Faction, aggressionOccupants, aggressionInvaders, tierWar, A3A_supportStrikes, A3A_activeSupports, A3A_vehicleResourceCosts
Calls:
A3A_fnc_availableBasesAir
A3A_fnc_SUP_UAVRoutine
A3A_fnc_showInterceptedSetupCall
Part of: UAV support system
Global variables modified:
A3A_supportStrikes (adds entry)
A3A_activeSupports (adds entry)
Network implications: Executes on server, spawns background routine.
Execution context: Server-side, scheduled.
fn_SUP_UAVAttack.sqf
Function Name: fn_SUP_UAVAttack.sqf

What it does: Sets up an armed UAV attack support. Spawns an armed UAV for attacking targets.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];
Accepts 8 parameters.

Airbase Selection:
Sqf

Apply
private _airport = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airport") exitWith { Debug_1("No airport found for %1 support", _supportName); -1; };
Finds available airbase.

UAV Type Selection:
Sqf

Apply
private _planeType = selectRandom (Faction(_side) get "uavsAttack");
Selects random attack UAV from faction configuration.

Delay Calculation:
Sqf

Apply
private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (300 - 15*tierWar - 1*_aggro) };
Calculates delay based on war tier and aggression.

Target Tracking:
Sqf

Apply
private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "TARGET", _target, time + 1200, 1200, 200];
    _targArray = [_target, _targPos];
};
Tracks target if specified.

Active Support Registration:
Sqf

Apply
private _suppData = [_supportName, _side, "UAVAttack", _targPos, 1000, [objNull, _targPos]];
A3A_activeSupports pushBack _suppData;
[_suppData, _resPool, _airport, _planeType, _delay, _reveal] spawn A3A_fnc_SUP_UAVRoutine;
Registers support with "UAVAttack" type and spawns routine.

Interception Call:
Sqf

Apply
[_reveal, _side, "UAVAttack", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;
Shows intercepted setup call with "UAVAttack" type.

Return Cost:
Sqf

Apply
(A3A_vehicleResourceCosts get _planeType) + 100;
Returns vehicle cost plus 100.

Where it leads:

Called by: Support request system
Depends on:
A3A_fnc_availableBasesAir
A3A_fnc_SUP_UAVRoutine
A3A_fnc_showInterceptedSetupCall
Global variables: Faction, aggressionOccupants, aggressionInvaders, tierWar, A3A_supportStrikes, A3A_activeSupports, A3A_vehicleResourceCosts
Calls:
A3A_fnc_availableBasesAir
A3A_fnc_SUP_UAVRoutine
A3A_fnc_showInterceptedSetupCall
Part of: UAV support system
Global variables modified:
A3A_supportStrikes (adds entry)
A3A_activeSupports (adds entry)
Network implications: Executes on server, spawns background routine.
Execution context: Server-side, scheduled.
fn_SUP_UAVAttackAvailable.sqf
Function Name: fn_SUP_UAVAttackAvailable.sqf

What it does: Calculates the weight/availability of armed UAV attack support against a specific target.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Accepts target object, side, max spend, and available types.

Air Target Check:
Sqf

Apply
if (_target isKindOf "Air") exitWith { 0 };
Exits with weight 0 if target is air (UAVs can't hit air effectively).

War Tier Check:
Sqf

Apply
if (tierWar < 3) exitWith { 0 };
Exits with weight 0 if war tier is less than 3.

Tier-Based Weight Calculation:
Sqf

Apply
-0.025 * tierWar + 0.75;
Calculates linear weight: 60% at tier 6 to 50% at tier 10.

Where it leads:

Called by: Support selection system
Depends on: Global variable tierWar
Calls: None
Part of: Support availability evaluation system
Global variables modified: None (read-only)
Network implications: None
Execution context: Server-side, unscheduled.
fn_SUP_UAVAttackRoutine.sqf
Function Name: fn_SUP_UAVAttackRoutine.sqf

What it does: Maintains and controls an armed UAV attack support. Manages target selection, laser designation, missile firing, and UAV flight pattern.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_suppData", "_resPool", "_airport", "_planeType", "_sleepTime", "_reveal"];
_suppData params ["_supportName", "_side", "_suppType", "_suppCenter", "_suppRadius", "_suppTarget"];
Accepts support data, resource pool, airport, plane type, delay, and reveal.

Initial Delay:
Sqf

Apply
sleep _sleepTime;
Waits for specified delay.

UAV Creation:
Sqf

Apply
private _spawnPos = markerPos _airport vectorAdd [0,0,300];
private _uav = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
[_side, _uav] call A3A_fnc_createVehicleCrew;
_groupVeh = group driver _uav;
{ [_x, nil, false, _resPool] call A3A_fnc_NATOinit } forEach (crew _uav);
[-10 * count units _groupVeh, _side, _resPool] call A3A_fnc_addEnemyResources;
[_uav, _side, _resPool] call A3A_fnc_AIVEHinit;
private _gunner = gunner _uav;
Creates UAV at airport, spawns crew, initializes crew and vehicle.

Missile Tracking Event Handler:
Sqf

Apply
_uav addEventHandler ["Fired", {
    params ["_uav", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
    _uav setVariable ["A3A_currentMissile", _projectile];
}];
Tracks fired missiles for collision detection.

Debug Markers (Conditional):
Sqf

Apply
#if __A3_DEBUG__
    _uav spawn {
        // Creates visual markers for debugging
    };
#endif
Creates local markers for debugging when enabled.

Waypoint Setup:
Sqf

Apply
_wp = _groupVeh addWayPoint [_suppCenter, 0];
_wp setWaypointBehaviour "AWARE";
_wp setWaypointType "LOITER";
_wp setWaypointLoiterType "CIRCLE_L";
_wp setWaypointSpeed "NORMAL";
_wp setWaypointLoiterRadius 600;
_groupVeh setCurrentWaypoint _wp;
_uav flyInHeight 350;
_groupVeh lockWP true;
Creates loiter waypoint around target area, locks waypoint to prevent deviation.

Missile Trajectory Correction:
Sqf

Apply
_uav addEventHandler
[
    "Fired",
    {
        params ["_uav", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
        private _target = _uav getVariable ["currentTarget", objNull];
        if(_target isEqualTo objNull) exitWith {};
        if(_target isEqualType objNull) then
        {
            _target = getPosASL _target;
        };
        [_projectile, _target] spawn
        {
            params ["_projectile", "_target"];
            sleep 0.25;
            private _speed = (speed _projectile)/3.6;
            while {!(isNull _projectile) && {alive _projectile}} do
            {   
                if ((getPos _projectile) select 2 < 10) exitwith {};
                sleep 0.1;
                private _dir = vectorNormalized (_target vectorDiff (getPosASL _projectile));
                _projectile setVelocity (_dir vectorMultiply _speed);
                _projectile setVectorDir _dir;
            };
        };
    }
];
Guides missile toward target using vector math, adjusts velocity and direction every 0.1s until impact.

Main Loop Variables:
Sqf

Apply
private _timeout = time + 900;
private _enemySide = [Occupants, Invaders] select (_side == Invaders);
Initialize timeout (15 minutes) and enemy side.

Main Control Loop:
Sqf

Apply
while {time < _timeout && canMove _uav} do
{
    waitUntil { sleep 5; _uav distance2d _suppCenter < 1200 || !alive _uav};
    if !(canFire _uav and gunner _uav call A3A_fnc_canFight || alive _uav) exitWith {
        Info_1("%1 has been destroyed or disabled, aborting routine", _supportName);
    };
Wait for UAV to reach target area, check if operational.

Friendly Spotting:
Sqf

Apply
private _friends = units _side inAreaArray [_suppCenter, 1000, 1000];
private _friendGroups = allGroups select {(leader _x in _friends) and {isNull objectParent leader _x} };
Find friendly ground units in area.

Enemy Selection:
Sqf

Apply
private _allEnemies = (units teamPlayer + units _enemySide) inAreaArray [_suppCenter, 500, 500];
private _spottedEnemies = [];
for "_i" from 0 to 3 do {
    if (count _allEnemies == 0) exitWith {};
    private _index = floor random (count _allEnemies);
    _spottedEnemies pushBack (_allEnemies # _index);
    _allEnemies deleteAt _index;
};
Select 4 random enemies from area.

Reveal to Friendlies:
Sqf

Apply
{
    private _group = _x;
    { [_group, [_x, 2]] remoteExec ["reveal", leader _group] } forEach _spottedEnemies;
} forEach _friendGroups;
Reveal enemies to friendly groups.

Timeout Check:
Sqf

Apply
if (time > _timeout) exitWith {
    Info_1("%1 has timed out, aborting routine", _supportName);
};
sleep 10;
Check timeout, sleep if not timed out.

Target Acquisition:
Sqf

Apply
if (isNull _currentTarget) then
{
    private _currentTarget = selectRandom _spottedEnemies;
    _laser = createVehicle ["LaserTargetE", (getPos _currentTarget), [], 0, "CAN_COLLIDE"];
    Info_1("Trying to attack laser to %1", _currentTarget);
    _uav setVariable ["currentTarget", _currentTarget];
    _laser attachTo [_currentTarget, [0,0,0]];
    _uav doWatch _laser;

    _side reportRemoteTarget [_laser, 600];
    _laser confirmSensorTarget [_side, true];
    _uav reveal [_laser, 4];
    [_uav, (weapons _uav) select 1] call BIS_fnc_fire;
    if !(alive _currentTarget) exitWith {
        _uav doTarget objNull;
        _uav doWatch objNull;
        _uav setVariable ["currentTarget", nil];
        _suppTarget resize 0;
        deleteVehicle _laser;
        Debug_1("%1 skips target, as it is already dead", _supportName);
        continue;
    };
};
Creates laser target on enemy, attaches to it, reports to side, fires weapon.

Wait for Previous Missile:
Sqf

Apply
if (alive (_uav getVariable ["A3A_currentMissile", objNull])) then { sleep 1; continue };
deleteVehicle _laser;
sleep 10;
Wait for missile to impact, delete laser.

Cleanup:
Sqf

Apply
_suppData set [4, 0];  // Set activesupport radius to zero, prevents adding further targets
[_groupVeh] spawn A3A_fnc_groupDespawner;
[_uav] spawn A3A_fnc_vehDespawner;
Terminate support, despawn group and vehicle.

Return to Base (Optional):
Sqf

Apply
if (canMove _uav) then
{
    while {count waypoints _groupVeh > 0} do { deleteWaypoint [_groupVeh, 0] };
    private _wpBase = _groupVeh addWaypoint [markerPos _airport, 0];
    _wpBase setWaypointSpeed "NORMAL";
    _wpBase setWaypointBehaviour "CARELESS";
    _groupVeh setCurrentWaypoint _wpBase;

    private _timeout = time + (_uav distance2d _spawnPos) / 20;
    waitUntil { sleep 2; (currentWaypoint _groupVeh != 0) or (time > _timeout) };
    if (time > _timeout) exitWith {};
    { deleteVehicle _x } forEach (units _groupVeh);
    deleteVehicle _uav;
};
If UAV survives, return to base, then delete if at base or timeout.

Where it leads:

Called by: A3A_fnc_SUP_UAVAttack (spawned)
Depends on:
A3A_fnc_createVehicleCrew
A3A_fnc_NATOinit
A3A_fnc_addEnemyResources
A3A_fnc_AIVEHinit
A3A_fnc_canFight
A3A_fnc_groupDespawner
A3A_fnc_vehDespawner
BIS_fnc_fire
Calls:
A3A_fnc_createVehicleCrew
A3A_fnc_NATOinit
A3A_fnc_addEnemyResources
A3A_fnc_AIVEHinit
A3A_fnc_canFight
A3A_fnc_groupDespawner
A3A_fnc_vehDespawner
BIS_fnc_fire
Arma engine: createVehicle, setVariable, attachTo, doWatch, reportRemoteTarget, confirmSensorTarget, reveal, setVelocity, setVectorDir, fireAtTarget
Part of: UAV attack support system
Global variables modified: None (uses local variables and support data)
Network implications: Executes on server, may affect sensor targets and reveal.
Execution context: Server-side, spawned (scheduled).
fn_SUP_UAVAvailable.sqf
Function Name: fn_SUP_UAVAvailable.sqf

What it does: Calculates the weight/availability of surveillance UAV support against a specific target.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_target", "_side", "_maxSpend", "_availTypes"];
Accepts target object, side, max spend, and available types.

Air Target Check:
Sqf

Apply
if (_target isKindOf "Air") exitWith { 0 };
Exits with weight 0 if target is air.

War Tier Check:
Sqf

Apply
if (tierWar < 3) exitWith { 0 };
Exits with weight 0 if war tier is less than 3.

Tier-Based Weight Calculation:
Sqf

Apply
-0.025 * tierWar + 0.75;
Calculates linear weight: 60% at tier 6 to 50% at tier 10.

Where it leads:

Called by: Support selection system
Depends on: Global variable tierWar
Calls: None
Part of: Support availability evaluation system
Global variables modified: None (read-only)
Network implications: None
Execution context: Server-side, unscheduled.
fn_SUP_UAVRoutine.sqf
Function Name: fn_SUP_UAVRoutine.sqf

What it does: Maintains and controls a surveillance UAV support. Manages flight pattern and enemy spotting for friendly units.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_suppData", "_resPool", "_airport", "_planeType", "_sleepTime", "_reveal"];
_suppData params ["_supportName", "_side", "_suppType", "_suppCenter", "_suppRadius", "_suppTarget"];
Accepts support data, resource pool, airport, plane type, delay, and reveal.

Initial Delay:
Sqf

Apply
sleep _sleepTime;
Waits for specified delay.

UAV Creation:
Sqf

Apply
private _spawnPos = markerPos _airport vectorAdd [0,0,300];
private _uav = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
[_side, _uav] call A3A_fnc_createVehicleCrew;
_groupVeh = group driver _uav;
{ [_x, nil, false, _resPool] call A3A_fnc_NATOinit } forEach (crew _uav);
[-10 * count units _groupVeh, _side, _resPool] call A3A_fnc_addEnemyResources;
[_uav, _side, _resPool] call A3A_fnc_AIVEHinit;
Creates UAV at airport, spawns crew, initializes crew and vehicle.

Debug Markers (Conditional):
Sqf

Apply
#if __A3_DEBUG__
    _uav spawn {
        // Creates visual markers for debugging
    };
#endif
Creates local markers for debugging when enabled.

Waypoint Setup:
Sqf

Apply
_wp = _groupVeh addWayPoint [_suppCenter, 0];
_wp setWaypointBehaviour "AWARE";
/* _wp setWaypointType "SAD"; */
_wp setWaypointType "LOITER";
_wp setWaypointLoiterType "CIRCLE_L";
_wp setWaypointSpeed "NORMAL";
_wp setWaypointLoiterRadius 600;
_groupVeh setCurrentWaypoint _wp;
_uav flyInHeight 400;
_groupVeh lockWP true;
Creates loiter waypoint around target area, locks waypoint.

Main Loop Variables:
Sqf

Apply
private _timeout = time + 1200;
private _enemySide = [Occupants, Invaders] select (_side == Invaders);
Initialize timeout (20 minutes) and enemy side.

Main Control Loop:
Sqf

Apply
while {time < _timeout && canMove _uav} do
{
    waitUntil { sleep 5; _uav distance2d _suppCenter < 1200 || !alive _uav};
    if !(canFire _uav and gunner _uav call A3A_fnc_canFight || alive _uav) exitWith {
        Info_1("%1 has been destroyed or disabled, aborting routine", _supportName);
    };
Wait for UAV to reach target area, check if operational.

Friendly Spotting:
Sqf

Apply
private _friends = units _side inAreaArray [_suppCenter, 1000, 1000];
private _friendGroups = allGroups select {(leader _x in _friends) and {isNull objectParent leader _x} };
Find friendly ground units in area.

Enemy Selection:
Sqf

Apply
private _allEnemies = (units teamPlayer + units _enemySide) inAreaArray [_suppCenter, 500, 500];
private _spottedEnemies = [];
for "_i" from 0 to 3 do {
    if (count _allEnemies == 0) exitWith {};
    private _index = floor random (count _allEnemies);
    _spottedEnemies pushBack (_allEnemies # _index);
    _allEnemies deleteAt _index;
};
Select 4 random enemies from area.

Reveal to Friendlies:
Sqf

Apply
{
    private _group = _x;
    { [_group, [_x, 2]] remoteExec ["reveal", leader _group] } forEach _spottedEnemies;
} forEach _friendGroups;
Reveal enemies to friendly groups.

Timeout Check:
Sqf

Apply
if (time > _timeout) exitWith {
    Info_1("%1 has timed out, aborting routine", _supportName);
};
sleep 10;
Check timeout, sleep if not timed out.

Cleanup:
Sqf

Apply
_suppData set [4, 0];           // Set activesupport radius to zero, prevents adding further targets
[_groupVeh] spawn A3A_fnc_groupDespawner;
[_uav] spawn A3A_fnc_vehDespawner;
Terminate support, despawn group and vehicle.

Return to Base (Optional):
Sqf

Apply
if (canMove _uav) then
{
    while {count waypoints _groupVeh > 0} do { deleteWaypoint [_groupVeh, 0] };
    private _wpBase = _groupVeh addWaypoint [markerPos _airport, 0];
    _wpBase setWaypointSpeed "NORMAL";
    _wpBase setWaypointBehaviour "CARELESS";
    _groupVeh setCurrentWaypoint _wpBase;

    private _timeout = time + (_uav distance2d _spawnPos) / 20;
    waitUntil { sleep 2; (currentWaypoint _groupVeh != 0) or (time > _timeout) };
    if (time > _timeout) exitWith {};
    { deleteVehicle _x } forEach (units _groupVeh);
    deleteVehicle _uav;
};
If UAV survives, return to base, then delete if at base or timeout.

Where it leads:

Called by: A3A_fnc_SUP_UAV (spawned)
Depends on:
A3A_fnc_createVehicleCrew
A3A_fnc_NATOinit
A3A_fnc_addEnemyResources
A3A_fnc_AIVEHinit
A3A_fnc_canFight
A3A_fnc_groupDespawner
A3A_fnc_vehDespawner
Calls:
A3A_fnc_createVehicleCrew
A3A_fnc_NATOinit
A3A_fnc_addEnemyResources
A3A_fnc_AIVEHinit
A3A_fnc_canFight
A3A_fnc_groupDespawner
A3A_fnc_vehDespawner
Arma engine: createVehicle, setVariable, reveal
Part of: UAV support system
Global variables modified: None (uses local variables and support data)
Network implications: Executes on server, affects sensor targets and reveal.
Execution context: Server-side, spawned (scheduled).
fn_useRadioKey.sqf
Function Name: fn_useRadioKey.sqf

What it does: Spends a radio key to boost reveal value to maximum (1.0) if within distance to HQ and the side has available keys.

How it does that:

Parameter Validation:
Sqf

Apply
params ["_side", "_position", "_reveal"];
Accepts side, position, and current reveal value.

Max Reveal Check:
Sqf

Apply
if (_reveal >= 0.8) exitWith { _reveal };
Exits early if reveal is already high (≥0.8).

Distance Check and Key Usage:
Sqf

Apply
if(_position distance2D markerPos "Synd_HQ" < distanceMission) then
{
    if(_side == Occupants && occupantsRadioKeys > 0) then {
        occupantsRadioKeys = occupantsRadioKeys - 1;
        _reveal = 1;
    };
    if(_side == Invaders && invaderRadioKeys > 0) then {
        invaderRadioKeys = invaderRadioKeys - 1;
        _reveal = 1;
    };
};
If within mission distance:

For Occupants: check occupantsRadioKeys, decrement if available, set reveal to 1
For Invaders: check invaderRadioKeys, decrement if available, set reveal to 1
Return Modified Reveal:
Sqf

Apply
_reveal;
Returns potentially modified reveal value.

Where it leads:

Called by: Support request system before calling support
Depends on: Global variables: occupantsRadioKeys, invaderRadioKeys, distanceMission
Calls: None
Part of: Support call system
Global variables modified:
occupantsRadioKeys (decremented if used)
invaderRadioKeys (decremented if used)
Network implications: Executes on server, modifies global resource variables.
Execution context: Server-side, unscheduled.