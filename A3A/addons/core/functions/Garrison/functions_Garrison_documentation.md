Function: fn_addGarrison.sqf
What it does: This function integrates a set of newly provided units into an existing garrison, while simultaneously removing them from the list of reinforcements (requested). It's a critical component of the garrison management system, handling the transition of units from a "requested" state to an "active" garrison state. This function is typically called when reinforcements arrive at a marker or when new units are spawned locally at a location.

How it does that:

Parameter Validation: The function first checks for the existence of required inputs. If either _marker or _units is nil, it logs an error and exits immediately.

Sqf

Apply
if (isNil "_marker") exitWith {Error("No marker given!")};
if (isNil "_units") exitWith {Error("No units given!")};
Data Retrieval & Initialization: It retrieves the current garrison (_garrison) and requested list (_requested) for the specified marker. It also initializes _nonReinfUnits, an array intended to hold units that are not replacements for dead units but additions. (Note: In the current implementation, this array is populated but ultimately discarded at the end of the function).

Sqf

Apply
private _garrison = [_marker] call A3A_fnc_getGarrison;
private _requested = [_marker] call A3A_fnc_getRequested;
private _nonReinfUnits = [["", [], []]];
Iterative Processing of Input Units: The function loops through each entry in the _units array. Each entry is formatted as [_vehicle, _crew, _cargo].

Vehicle Handling:
It checks if a vehicle name is provided (_vehicle != "").
It attempts to find a matching vehicle in the _requested array. If found (_index != -1), it replaces the existing vehicle in _garrison with the new one and removes the request from _requested.
If the vehicle is not found in the requested list (meaning it's a new vehicle, not a replacement), it is added to the _nonReinfUnits list. The logic handles appending to the last entry or creating a new entry depending on slot availability.
Crew Handling:
If the unit is not a new vehicle (!_isNew), the function processes the crew.
It iterates through each crew unit. It tries to find a slot in _requested that has crew slots available. If found, it adds the crew to _garrison and removes the corresponding unit from _requested.
If no slot is found in _requested, it searches the _nonReinfUnits list for a vehicle with open crew slots (comparing crew count to vehicle capacity using BIS_fnc_crewCount). If none is found, it creates a new entry.
Cargo Handling:
The function processes cargo units. It distinguishes between crew-type units (checked against FactionGet(occ,"crew") or FactionGet(inv,"crew")) and combat units.
Crew Units: Treated exactly like the crew section above, attempting to fill empty crew slots in _requested or _nonReinfUnits.
Combat Units: Treated as garrison cargo. It attempts to find a slot in _requested that has specific cargo units available. If found, it adds the unit to _garrison and removes it from _requested. If not found, it tries to add it to _nonReinfUnits, finding a slot with less than 8 cargo units. If no slot exists, a new one is created.
Finalization and Cleanup:

Non-Reinforcement Units: The code contains comments indicating that _nonReinfUnits should be appended to _garrison but is currently discarded to avoid "too much units and data junk." The line _garrison append _nonReinfUnits; is commented out.
Storage: The updated _garrison and _requested arrays are saved back to the garrison namespace variable for the specific marker.
State Update: The function calls A3A_fnc_updateReinfState to recalculate the reinforcement status (e.g., whether the marker needs reinforcements, is full, etc.) based on the new garrison composition.
Sqf

Apply
garrison setVariable [format ["%1_garrison", _marker], _garrison];
garrison setVariable [format ["%1_requested", _marker], _requested];
[_marker] call A3A_fnc_updateReinfState;
Where it leads:

Calls:
A3A_fnc_getGarrison: Retrieves the current garrison array.
A3A_fnc_getRequested: Retrieves the list of units needing replacement.
BIS_fnc_crewCount: Used to determine vehicle capacity for crew allocation.
A3A_fnc_updateReinfState: Updates the global reinforcement state for the marker.
Dependents: This function is called by reinforcement delivery systems (e.g., convoy arrival scripts) and potentially by debug/admin commands that manually add units to garrisons.
System Fit: It is the core ingestion mechanism for the garrison system, turning "requested" resources into "active" defensive forces. It handles the complex logic of matching new units to specific slots (vehicle, crew, cargo) defined by the garrison structure.
Global Variables Modified: Modifies garrison namespace variables (%1_garrison and %1_requested for the specific marker).
Network Implications: As a server-side function (managing mission-critical state), it typically runs on the server. Data changes are stored in the server's garrison namespace, which is accessible to clients via publicVariable or setVariable with the public flag if needed for synchronization, though this specific function does not explicitly use the public flag.
Function: fn_addRequested.sqf
What it does: This function adds units to the list of units that need to be reinforced (requested) for a specific marker. It supports two modes: standard mode (adding a single dead unit) and stock-up mode (adding a set of units as a new request). It automatically adjusts the garrison array to match the size of the requested list.

How it does that:

Parameter Handling: It takes _marker, _unit, _unitIndex, and an optional _stockUp boolean. If _stockUp is true, _unit is expected to be an array ["vehicle", [crew], [cargo]]; otherwise, _unit is a string (classname), and _unitIndex defines the position (YYX, where YY is group ID, X is type: 0=vehicle, 1=crew, 2=cargo).

Standard Mode (_stockUp == false):

Index Parsing: Parses _unitIndex to get the group ID and unit type.
Sqf

Apply
_unitType = _unitIndex % 10;
_groupID = floor (_unitIndex / 10);
Data Retrieval: Gets the current _reinforcements (requested) and _garrison arrays.
Array Expansion: Ensures the _reinforcements array is large enough to hold the group ID by pushing back empty ["", [], []] entries if needed.
Unit Insertion:
For vehicles (_unitType == 0): Sets the vehicle slot in _reinforcements and clears the corresponding vehicle slot in _garrison.
For crew/cargo (_unitType != 0): Pushes the unit name into the appropriate sub-array (crew or cargo) in _reinforcements and removes it from the corresponding array in _garrison.
Storage: Updates the garrison namespace variable for the requested list.
Stock-up Mode (_stockUp == true):

Validation: Validates that the input _unit is an array of length 3.
Array Synchronization: Retrieves the current _garrison and _requested arrays. It calculates the size of the garrison and ensures the _requested array is expanded to match (filling new slots with empty ["", [], []] entries) before appending the new full request unit.
Storage: Saves the updated requested list back to the garrison namespace (with publicVariable set to true).
State Update: Regardless of the mode, the function calls A3A_fnc_updateReinfState to recalculate the marker's reinforcement status.

Sqf

Apply
[_marker] call A3A_fnc_updateReinfState;
Where it leads:

Calls:
A3A_fnc_getRequested: Gets the current requested units.
A3A_fnc_getGarrison: Gets the current garrison (in standard mode to remove units from it).
A3A_fnc_updateReinfState: Updates the reinforcement status.
Dependents: Called when units are killed (fn_enemyUnitKilledEH), during garrison initialization (fn_createGarrison), or when the AI decides to upgrade a garrison (stock-up mode).
System Fit: It is the inverse operation of fn_addGarrison. While fn_addGarrison moves units into the garrison, fn_addRequested moves units out (into the request list) or adds new requests. It manages the "damage" or "deficit" side of the garrison system.
Global Variables Modified: Modifies the garrison namespace variable %1_requested for the marker. In stock-up mode, it uses publicVariable to sync the change.
Network Implications: The stock-up mode explicitly sets the third parameter of setVariable to true, broadcasting the change to all clients. The standard mode relies on the function calling updateReinfState, which likely handles its own synchronization.
Function: fn_checkGroupType.sqf
What it does: This function validates whether a specific group of units (_group) is compatible with a given vehicle type (_vehicle) and a preferred group size (_preference). It is used during garrison creation or updates to ensure logical composition (e.g., placing an AT team in a tank, or a squad in a large transport).

How it does that:

Parameter Initialization: Initializes _result to false and retrieves group data for both factions (Occupants and Invaders).

Sqf

Apply
private _occGroupData = FactionGet(occ, "groups");
private _invGroupData = FactionGet(occ, "groups"); // Note: Looks like a copy-paste error in original code, likely meant FactionGet(inv, "groups")
Hard-coded Special Cases:

Tanks: If the vehicle is LAND_TANK, the function immediately exits, returning true only if the group matches the faction's Anti-Tank (AT) group tier.
Sqf

Apply
if(_vehicle == "LAND_TANK") exitWith {
  private _occGroup = [(FactionGet(occ,"groupTierAT"))] call SCRT_fnc_unit_getTiered;
  private _invGroup = [(FactionGet(inv,"groupTierAT"))] call SCRT_fnc_unit_getTiered;
  _group == _occGroup || {_group == _invGroup}
};
AA Vehicles: If the vehicle is LAND_AIR (AA vehicle), it returns true only if the group matches the faction's Anti-Air (AA) group tier.
Preference Validation:

Squad Size: If _preference is "SQUAD", it checks if the group count is exactly 8.
Sqf

Apply
if(_preference == "SQUAD") then { _result = (count _group == 8); };
Group Size: If _preference is "GROUP", it checks if the group count is exactly 4.
Vehicle Capacity Validation:

It calculates the available passenger seats in the vehicle: Total Seats - Crew Seats.
It updates _result to true only if the previous preference check passed and the group size fits within the vehicle's passenger capacity.
Sqf

Apply
_vehicleSeats = ([_vehicle, true] call BIS_fnc_crewCount) - ([_vehicle, false] call BIS_fnc_crewCount);
_result = (_result && (count _group <= _vehicleSeats));
Return Value: Returns the final boolean _result.

Where it leads:

Calls:
FactionGet: Retrieves faction configuration data.
SCRT_fnc_unit_getTiered: Retrieves the specific group array based on tier.
BIS_fnc_crewCount: Calculates vehicle capacity.
Dependents: fn_createGarrisonLine (to validate the selected group), fn_updateGarrison (to check if an existing group is still valid).
System Fit: It is a helper validation function ensuring the integrity of the garrison structure. It prevents logically invalid combinations (e.g., a full squad in a jeep or a rifle team in a tank).
Global Variables Modified: None.
Network Implications: None. Pure calculation.
Function: fn_checkVehicleType.sqf
What it does: This function checks if a specific vehicle type fits into a preferred category (e.g., LAND_LIGHT, HELI_ATTACK). It uses preprocessor macros to define vehicle categories and a switch statement to evaluate the preference.

How it does that:

Preprocessor Definitions: Defines macros for vehicle categories (e.g., lightVeh, apc, tank, drone) using lazy evaluation. These macros check if _vehicle belongs to specific faction arrays (e.g., FactionGet(occ,"vehiclesLightArmed")).

Sqf

Apply
#define lightVeh \
    {_vehicle in FactionGet(occ,"vehiclesLightArmed")} \
    || {_vehicle in FactionGet(occ,"vehiclesLightUnarmed")} \
    ...
Preference Switch: A switch statement handles the _preference parameter.

Empty: Returns true only if _vehicle == "".
Land Categories: Uses the macros to check inclusion.
LAND_START: Allows empty or light vehicles.
LAND_LIGHT: Allows only light vehicles.
LAND_DEFAULT: Allows light vehicles or APCs.
LAND_ATTACK: Allows APCs or Tanks.
LAND_TANK: Allows only Tanks.
LAND_AIR: Checks against AA vehicle arrays.
Heli Categories: Uses patrolHeli, transportHeli, attackHeli macros.
Air Categories: Uses drone and plane macros (which include CAS and AA planes).
Default: If no case matches, it falls through (implicitly returning nil or the last result, but the function structure relies on the switch returning a value).
Return Value: Returns a boolean indicating if the vehicle matches the preference.

Where it leads:

Calls: Uses FactionGet to access vehicle arrays.
Dependents: fn_selectVehicleType (to filter potential vehicles), fn_updateGarrison (to validate existing vehicles).
System Fit: It is a categorization filter used to narrow down vehicle choices during garrison creation and maintenance, ensuring vehicles match the tactical role defined in the preference list.
Global Variables Modified: None.
Network Implications: None.
Function: fn_countGarrison.sqf
What it does: This function counts the total number of units in a garrison array or breaks it down by type (vehicle, crew, cargo).

How it does that:

Parameter Initialization: Takes _garrison (array) and _returnTogether (boolean).

Sqf

Apply
params ["_garrison", "_returnTogether"];
Iterative Counting: Loops through each element (_data) in the _garrison array.

Vehicles: Checks if the vehicle slot (index 0) is not empty (""). If so, increments _vehicleCount.
Crew: Counts the number of elements in the crew array (index 1) and adds to _crewCount.
Cargo: Counts the number of elements in the cargo array (index 2) and adds to _cargoCount.
Sqf

Apply
for "_i" from 0 to (_count - 1) do {
  _data = _garrison select _i;
  if((_data select 0) != "") then { _vehicleCount = _vehicleCount + 1; };
  _crewCount = _crewCount + (count (_data select 1));
  _cargoCount = _cargoCount + (count (_data select 2));
};
Output Formatting:

If _returnTogether is true, it sums all counts and returns the total.
If false, it returns an array [_vehicleCount, _crewCount, _cargoCount].
Where it leads:

Calls: None.
Dependents: fn_getGarrisonRatio (calculates strength), fn_selectReinfUnits (determines how many units to send), fn_shouldReinforce (decides if reinforcement is needed).
System Fit: A utility function used to quantify garrison strength, essential for AI decision-making regarding reinforcement priorities and attack capabilities.
Global Variables Modified: None.
Network Implications: None.

Function Name: A3A_fnc_createGarrison
What it does: This function is responsible for initializing the garrison data for a set of specific markers (e.g., airports, outposts). It determines which units and vehicles are present at a location and which ones are missing and need to be reinforced. It populates global variables (via the garrison namespace) with the initial state of these locations.

How it does that: The function operates in a loop for every marker provided in _markerArray.

Parameter Validation and Initialization:

Code: params ["_markerArray", "_type", ["_lose", [0, 0, 0]]];
Explanation: The function expects an array of marker strings (_markerArray), the type of the markers (_type), and an optional array _lose representing initial losses (land, heli, air).
Variable Setup: It initializes arrays to hold the garrison state (_garrison) and the requested reinforcement state (_requested).
Preference Retrieval:

Code:
Sqf

Apply
private ["_losses", "_preferred", "_garrison", "_requested", "_marker", "_side", "_line", "_start", "_index"];
_preferred = garrison getVariable [format ["%1_preference", _type], objNull];
while {!(_preferred isEqualType [])} do
{
    sleep 1;
    _preferred = garrison getVariable [format ["%1_preference", _type], objNull];
};
Explanation: It fetches the template preference array for the specific _type (e.g., "Airport_preference"). It includes a safety loop that waits (sleeps) until the preferences are properly initialized and are an array, preventing errors if the init runs asynchronously.
Side Determination:

Code:
Sqf

Apply
_side = sidesX getVariable [_marker, sideUnknown];
while {_side == sideUnknown} do
{
    sleep 1;
    _side = sidesX getVariable [_marker, sideUnknown];
};
Explanation: It retrieves the owning side of the marker from the global sidesX namespace. It also includes a wait loop to ensure the side is known before proceeding.
Line Generation Loop:

Code:
Sqf

Apply
for "_i" from 0 to ((count _preferred) - 1) do
{
    _line = [_preferred select _i, _side] call A3A_fnc_createGarrisonLine;
    // ... logic to handle losses ...
};
Explanation: It iterates through every entry in the preference array. For each entry, it calls A3A_fnc_createGarrisonLine to generate the unit composition. It then checks the vehicle type (Land, Heli, Air) to see if it corresponds to a requested loss.
Logic Flow:
It extracts the vehicle start prefix (e.g., "LAN", "HEL", "AIR") from the preference data.
If _losses for that category is > 0, it decrements the loss counter, adds an empty entry to _garrison (representing a destroyed vehicle), and puts the line in _requested (representing the need for replacement).
If no loss is requested, it adds the generated line to _garrison and an empty entry to _requested.
State Finalization:

Code:
Sqf

Apply
garrison setVariable [format ["%1_garrison", _marker], _garrison, true];
garrison setVariable [format ["%1_requested", _marker], _requested, true];
[_marker] call A3A_fnc_updateReinfState;
Explanation: It saves the generated arrays to the garrison namespace, synced to clients (true flag). Finally, it calls A3A_fnc_updateReinfState to update the global reinforcement lists based on the new garrison state.
Where it leads:

Calls:
A3A_fnc_createGarrisonLine: Called for every entry in the preference array to generate unit data.
A3A_fnc_updateReinfState: Called after setting variables to update the reinforcement logic (e.g., adding the marker to the "needs help" list if losses exist).
Dependencies:
Depends on garrison namespace variables set by fn_initPreference.
Depends on sidesX namespace for ownership data.
System Fit:
This is a core initialization function called during mission start or when a location is captured/respawned. It establishes the baseline for garrison management.
Global Variables Modified:
garrison (Namespace): Sets [marker]_garrison and [marker]_requested.
Network Implications:
Uses the true flag in setVariable to broadcast the garrison state to all connected clients, ensuring UI and client-side logic is in sync with the server.
Function Name: A3A_fnc_createGarrisonLine
What it does: Generates a single "line" of garrison data. This is a unit composition array containing a vehicle, its crew, and its cargo passengers, based on a provided template preference.

How it does that:

Parameter Parsing:

Code: params ["_data", "_side"];
Explanation: _data is the preference tuple [VehicleType, IncludeCrew, SquadType]. _side defines the faction.
Vehicle Selection:

Code: _vehicleType = _data select 0; _vehicle = [_vehicleType, _side] call A3A_fnc_selectVehicleType;
Explanation: It extracts the vehicle type string (e.g., "LAND_START") and calls A3A_fnc_selectVehicleType to resolve it into a specific vehicle classname.
Crew Generation:

Code:
Sqf

Apply
_crew = [];
if((_data select 1) != 0) then
{
    _crewMember = Faction(_side) get "unitCrew";
    _crew = [_vehicle, _crewMember] call A3A_fnc_getVehicleCrew;
};
Explanation: Checks the "include crew" flag. If true, it retrieves the crew unit classname for the faction and calls A3A_fnc_getVehicleCrew to generate an array of crew members matching the vehicle's seat count.
Cargo Group Selection:

Code: _cargoGroup = [_vehicle, _data select 2, _side] call A3A_fnc_selectGroupType;
Explanation: It passes the selected vehicle and the preferred squad type (e.g., "SQUAD", "EMPTY") to A3A_fnc_selectGroupType to get an array of unit classnames for the passengers.
Return:

Code: [_vehicle, _crew, _cargoGroup];
Explanation: Returns the formatted line array.
Where it leads:

Calls:
A3A_fnc_selectVehicleType: Converts abstract vehicle types (e.g., "LAND_START") into concrete classnames.
A3A_fnc_getVehicleCrew: Generates crew member classnames based on vehicle seat count.
A3A_fnc_selectGroupType: Selects the appropriate infantry group for the cargo space.
Dependencies:
Relies on Faction(_side) data structures.
System Fit:
A low-level helper used by fn_createGarrison and fn_updateGarrison. It encapsulates the complexity of vehicle and group selection.
Global Variables Modified: None.
Network Implications: None (pure calculation).
Function Name: A3A_fnc_getGarrison
What it does: Retrieves the stored garrison data for a specific marker.

How it does that:

Input Validation:

Code: if(isNil "_marker") exitWith {Error("No marker given!")};
Explanation: Checks if the parameter was passed; if not, logs an error and exits.
Data Retrieval:

Code: result = garrison getVariable [format ["%1_garrison", _marker], [["", [], []]]];
Explanation: Uses the garrison namespace to fetch the array associated with [marker]_garrison. It defaults to a single empty unit entry [[ "", [], [] ]] if the variable doesn't exist (e.g., marker not initialized).
Return:

Code: _result;
Explanation: Returns the garrison array.
Where it leads:

Calls: None.
Dependencies:
garrison namespace variables set by fn_createGarrison.
System Fit:
Standard accessor function used by spawn scripts (e.g., fn_createSDKGarrisons) to know what units to spawn when a marker becomes active.
Global Variables Modified: None (Read-only).
Network Implications: None (Reads local namespace data).
Function Name: A3A_fnc_getGarrisonLimit
What it does: Calculates the maximum number of units (garrison limit) allowed for a specific marker based on its type and the current rebel tier.

How it does that:

Parameter Validation:

Code: params [["", "", [""]]]; if (_marker isEqualTo "") exitWith { Error(...); };
Explanation: Validates that a marker name was provided.
Global Limit Check:

Code: if (A3A_rebelGarrisonLimit == -1) exitWith {-1};
Explanation: Checks a global config variable. If set to -1, garrison limits are disabled (infinite).
Switch Logic (Per-Marker-Type Calculation):

Code:
Sqf

Apply
private _limit = switch (true) do {
    case (_marker in citiesX): { ... };
    case (_marker in airportsX): { ... };
    // ... other cases ...
};
Explanation: It checks which category the marker belongs to (Cities, Airports, Milbases, Factories/Resources, or Default).
Calculations:
Cities: Scales with population size: 2 * round (sqrt ((server getVariable _marker)#0) / 2).
Airports: Multiplier of base limit: round (A3A_rebelGarrisonLimit * 1.5).
Milbases: Multiplier of base limit: round (A3A_rebelGarrisonLimit * 1.25).
Factories/Resources: Multiplier of base limit: round (A3A_rebelGarrisonLimit * 0.5).
Default: Returns A3A_rebelGarrisonLimit.
Return:

Code: _limit
Explanation: Returns the calculated integer limit.
Where it leads:

Calls: None.
Dependencies:
Global arrays: citiesX, airportsX, milbases, factories, resourcesX.
Server variable: server getVariable _marker (population).
Global setting: A3A_rebelGarrisonLimit.
System Fit:
Used by reinforcement logic (e.g., fn_selectReinfUnits) to cap the number of units that can be requested or sent to a location.
Global Variables Modified: None.
Network Implications: None.
Function Name: A3A_fnc_getGarrisonRatio
What it does: Calculates the percentage of active (alive) units compared to the total units (active + requested reinforcements) for a specific marker.

How it does that:

Input Validation:

Code: if(isNil "_marker") exitWith {Error("No marker given!")};
Explanation: Validates input.
Data Gathering:

Code:
Sqf

Apply
_garrison = [_marker] call A3A_fnc_getGarrison;
_neededReinf = [_marker] call A3A_fnc_getRequested;
Explanation: Retrieves the current active garrison and the list of units that need to be reinforced.
Counting Units:

Code:
Sqf

Apply
_garrisonCount = [_garrison, true] call A3A_fnc_countGarrison;
_reinfCount = [_neededReinf, true] call A3A_fnc_countGarrison;
Explanation: Calls fn_countGarrison to count units. The true flag likely indicates counting only alive units for the garrison (not empty slots) and all requested units for reinforcements.
Ratio Calculation:

Code:
Sqf

Apply
_allUnitsCount = _garrisonCount + _reinfCount;
_ratio = 1;
if(_allUnitsCount > 0) then
{
    _ratio = _preferredUnitsCount / _allUnitsCount;
};
Explanation: It sums the active units and the requested units. The ratio is Active / (Active + Requested). If the total is 0 (empty location), ratio defaults to 1.
Return:

Code: _ratio;
Explanation: Returns a float between 0.0 and 1.0.
Where it leads:

Calls:
A3A_fnc_getGarrison
A3A_fnc_getRequested
A3A_fnc_countGarrison
Dependencies:
Data structures populated by fn_createGarrison.
System Fit:
Used by fn_getGarrisonStatus to determine if a location is "Good", "Weakened", or "Decimated".
Used by fn_updateReinfState to determine if a location needs help.
Global Variables Modified: None.
Network Implications: None.
Function Name: A3A_fnc_getGarrisonStatus
What it does: Returns a string representing the combat effectiveness of a marker's garrison ("Good", "Weakened", "Decimated").

How it does that:

Input Validation:

Code: if(isNil "_marker") exitWith {Error("No marker given!")};
Explanation: Validates input.
Ratio Calculation:

Code: _ratio = ["_marker"] call A3A_fnc_getGarrisonRatio;
Explanation: Retrieves the active vs requested ratio.
Threshold Check:

Code:
Sqf

Apply
_result = "Decimated";
if(_ratio > 0.9) then { _result = "Good" }
else { if(_ratio > 0.4) then { _result = "Weakened" }; };
Explanation:
90%: Status "Good".

40% but <= 90%: Status "Weakened".

<= 40%: Status "Decimated".
Return:

Code: _result;
Explanation: Returns the status string.
Where it leads:

Calls: A3A_fnc_getGarrisonRatio.
Dependencies: Relies on the ratio logic defined in fn_getGarrisonRatio.
System Fit:
Used by UI scripts to display garrison status to players.
Used by AI logic to determine aggression or retreat behavior.
Global Variables Modified: None.
Network Implications: None.
Function Name: A3A_fnc_getRequested
What it does: Retrieves the list of units requested (needed) for a specific marker.

How it does that:

Input Validation:

Code: if(isNil "_marker") exitWith {Error("No marker given!")};
Explanation: Validates input.
Data Retrieval:

Code: result = garrison getVariable [format ["%1_requested", _marker], [["", [], []]]];
Explanation: Fetches the [marker]_requested array from the garrison namespace. Defaults to empty if not found.
Return:

Code: _result;
Explanation: Returns the requested units array.
Where it leads:

Calls: None.
Dependencies:
garrison namespace variables set by fn_createGarrison and fn_addRequested.
System Fit:
Used by fn_selectReinfUnits to determine what specific units need to be spawned and sent to the marker.
Global Variables Modified: None (Read-only).
Network Implications: None.
Function Name: A3A_fnc_getVehicleCrew
What it does: Generates an array of crew unit classnames required for a specific vehicle type.

How it does that:

Parameter Validation:

Code: if(_vehicleType == "" || {_vehicleType == "Empty"}) exitWith {[]};
Explanation: If the vehicle is empty or invalid, returns an empty array immediately.
Seat Count Calculation:

Code: _seatCount = [_vehicleType, false] call BIS_fnc_crewCount;
Explanation: Uses the Arma engine command BIS_fnc_crewCount to determine how many seats the vehicle has (excluding cargo).
Array Generation:

Code:
Sqf

Apply
_result = [];
for "_i" from 1 to _seatCount do
{
    _result pushBack _crewType;
};
Explanation: Loops from 1 to the seat count, pushing the _crewType string into the result array for every seat.
Return:

Code: _result;
Explanation: Returns the array of crew classnames.
Where it leads:

Calls:
BIS_fnc_crewCount (Engine function).
Dependencies: None specific to A3A globals.
System Fit:
Helper function used in fn_createGarrisonLine and fn_updateGarrison to ensure crew lists match vehicle capacity.
Global Variables Modified: None.
Network Implications: None.
Function Name: A3A_fnc_initPreference
What it does: Initializes the global "preference" templates for different location types (Airport, Military Base, Outpost, City, Other). These templates define the desired garrison composition.

How it does that:

Airport Preferences:

Code:
Sqf

Apply
private _preference = [ ... ];
garrison setVariable ["Airport_preference", _preference];
garrison setVariable ["Airport_statics", 0.35];
Explanation: Defines an array of tuples [VehicleType, IncludeCrew, SquadType]. Sets the static defense percentage to 35%.
Military Base Preferences:

Code:
Sqf

Apply
_preference = [ ... ];
garrison setVariable ["MilitaryBase_preference", _preference];
garrison setVariable ["MilitaryBase_statics", 0.3];
Explanation: Defines heavier armor (Tanks, APCs) and sets static defense to 30%.
Outpost Preferences:

Code: Similar structure, lighter armor, static defense 20%.
City Preferences:

Code: garrison setVariable ["City_preference", []];
Explanation: Sets an empty preference array, meaning cities start with no garrison until the war tier increases.
Other Preferences:

Code: Defines basic infantry/light vehicle setups for minor objectives.
Where it leads:

Calls: None.
Dependencies: Relies on the garrison global namespace.
System Fit:
Called during mission initialization (preInit or server init). It sets the baseline data that fn_createGarrison reads to build actual garrisons.
Global Variables Modified:
garrison (Namespace): Sets Airport_preference, Airport_statics, MilitaryBase_preference, etc.
Network Implications: None (Run on server, variables are local).
Function Name: A3A_fnc_replenishGarrison
What it does: Selects units to reinforce a specific marker and adds them to the garrison.

How it does that:

Unit Selection:

Code: private _units = [_marker, _marker, false, true] call A3A_fnc_selectReinfUnits;
Explanation: Calls fn_selectReinfUnits to determine which units to send. The parameters indicate the base is the same as the target (self-replenish), and it bypasses restrictions (true).
Adding Garrison:

Code: [_marker, _units] call A3A_fnc_addGarrison;
Explanation: Calls fn_addGarrison (not shown in provided files but implied) to physically add the selected units to the marker's garrison list.
Where it leads:

Calls:
A3A_fnc_selectReinfUnits
A3A_fnc_addGarrison
Dependencies: Relies on unit selection logic.
System Fit:
Used as a helper to refill garrisons, likely triggered by debug commands or specific scripted events.
Global Variables Modified:
Indirectly modifies garrison namespace via fn_addGarrison.
Network Implications: Depends on fn_addGarrison (likely syncs via setVariable).
Function Name: A3A_fnc_selectGroupType
What it does: Selects a specific infantry group (array of classnames) suitable for a vehicle based on seat capacity and type.

How it does that:

Special Cases (Tank/AA):

Code:
Sqf

Apply
if(_vehicle in OccAndInv("vehiclesTanks")) exitWith {[_faction get "groupTierAT"] call SCRT_fnc_unit_getTiered};
if(_vehicle in OccAndInv("vehiclesAA")) exitWith {[_faction get "groupTierAA"] call SCRT_fnc_unit_getTiered};
Explanation: Hardcoded logic: Tanks always get AT teams, AA vehicles get AA teams.
Vehicle Capacity Check:

Code:
Sqf

Apply
_vehicleSeats = ([_vehicle, true] call BIS_fnc_crewCount) - ([_vehicle, false] call BIS_fnc_crewCount);
Explanation: Calculates cargo seats (Total seats - Crew seats).
Selection Logic:

Code:
Sqf

Apply
if(_vehicleSeats >= 8) then { _result = _preference; }
else { if(_vehicleSeats >= 4) then { _result = "GROUP"; } ... };
Explanation:
If cargo >= 8: Use the requested preference (e.g., "SQUAD").
If cargo >= 4: Downgrade to "GROUP".
If cargo < 4: Warns in debug, falls back to preference anyway.
Final Mapping:

Code:
Sqf

Apply
if(_result != "EMPTY") exitWith
{
    if(_result == "SQUAD") then { ... } else { ... };
};
[]];
Explanation: Converts the string "SQUAD" or "GROUP" into an actual array of unit classnames using SCRT_fnc_unit_flattenTier.
Where it leads:

Calls:
BIS_fnc_crewCount
SCRT_fnc_unit_getTiered (External mod/function)
SCRT_fnc_unit_flattenTier (External mod/function)
Dependencies: Faction data (Faction(_side)).
System Fit:
Used by fn_createGarrisonLine to generate passenger lists.
Global Variables Modified: None.
Network Implications: None.
Function Name: A3A_fnc_selectReinfUnits
What it does: Calculates the specific units (vehicles, crew, cargo) to send from a base to a target marker to satisfy reinforcement needs.

How it does that:

Capacity Check:

Code: _maxUnitSend = garrison getVariable [format ["%1_recruit", _base], 0];
Explanation: Checks how many "recruit slots" are available at the base.
Exit Condition: If slots < 3, returns empty array (cannot send just a driver).
Data Preparation:

Code:
Sqf

Apply
_reinf = +([_target] call A3A_fnc_getRequested);
_side = sidesX getVariable [_base, sideUnknown];
_maxRequested = [_reinf, false] call A3A_fnc_countGarrison;
Explanation: Copies the requested list (to modify it safely), gets the side, and counts the needed vehicles/cargo.
Vehicle Selection Loop:

Code:
Sqf

Apply
while {_currentUnitCount < (_maxUnitSend - 2) && {_maxCargoSpaceNeeded+_maxVehiclesNeeded > 0}} do
{ ... }
Explanation: Loops until base capacity is reached or needs are satisfied.
Inner Logic:
Iterates through _reinf to find the best vehicle (most seats) that fits in the remaining capacity.
If no requested vehicle fits, it selects a generic transport vehicle (Helicopter/Truck) based on cargo needs and distance (_isAir flag).
Once a vehicle is selected, it marks it as used in _reinf.
Cargo Loading:

Code:
Sqf

Apply
for "_i" from 0 to ((count _reinf) - 1) do
{ ... while {count _dataCargo > 0} do { ... } }
Explanation: Fills the selected vehicle's cargo space with infantry units from the request list, tracking _currentUnitCount and _openSpace.
Finalization:

Code:
Sqf

Apply
garrison setVariable [format ["%1_recruit", _base], (_maxUnitSend - _currentUnitCount), true];
_unitsSend;
Explanation: Deducts the used slots from the base's recruit pool (synced) and returns the final unit array.
Where it leads:

Calls:
A3A_fnc_getRequested
A3A_fnc_countGarrison
BIS_fnc_crewCount
A3A_fnc_getVehicleCrew
Dependencies: garrison namespace (recruit counts), sidesX namespace.
System Fit:
Core logic for reinforcement convoys. Used when the server decides to send help to a marker.
Global Variables Modified:
garrison: Updates [base]_recruit count.
Network Implications: Updates recruit count with true flag (broadcast).
Function Name: A3A_fnc_selectVehicleType
What it does: Converts an abstract vehicle category string (e.g., "LAND_START") into a specific vehicle classname from the faction's pool.

How it does that:

Direct Mappings:

Code:
Sqf

Apply
if(_preference == "LAND_AIR") exitWith { selectRandom (_faction get "vehiclesAA") };
if(_preference == "LAND_TANK") exitWith { selectRandom (_faction get "vehiclesTanks") };
Explanation: Handles specific, non-ambiguous categories immediately.
Accumulation Lists:

Code:
Sqf

Apply
private _possibleVehicles = [];
if(_preference in ["EMPTY", "LAND_START", ...]) then { _possibleVehicles pushBack ""; };
if(_preference in ["LAND_START", "LAND_LIGHT", ...]) then { _possibleVehicles append (_faction get "vehiclesLightArmed"); };
// ... more appends ...
Explanation: Uses in operator to check membership in a list of categories. For every match, it appends relevant vehicle arrays (e.g., vehiclesLightArmed, vehiclesAPCs) to _possibleVehicles.
Selection:

Code:
Sqf

Apply
if(count _possibleVehicles == 0) exitWith { "Empty"; };
selectRandom _possibleVehicles;
Explanation: If no vehicles matched the category, returns "Empty". Otherwise, returns a random vehicle from the accumulated list.
Where it leads:

Calls: None (uses Faction(_side) data).
Dependencies: Faction config arrays (vehiclesLightArmed, etc.).
System Fit:
Used by fn_createGarrisonLine to spawn vehicles.
Global Variables Modified: None.
Network Implications: None.
Function Name: A3A_fnc_shouldReinforce
What it does: Determines if a base (_base) should send reinforcements to a target marker (_target).

How it does that:

Basic Checks:

Code:
Sqf

Apply
if(_base isEqualTo _target) exitWith {false};
if (spawner getVariable _base != 2 || {_base in forcedSpawn}) exitWith {false};
Explanation: Prevents self-reinforcement. Checks if the base is active (spawned) and not forced to spawn.
Distance/Connectivity Checks:

Code:
Sqf

Apply
if(!_isAirport && {(getMarkerPos _base) distance2D (getMarkerPos _target) > distanceForLandAttack || {!([_base, _target] call A3A_fnc_arePositionsConnected)}}) exitWith {false};
Explanation: For land convoys, checks maximum distance and path connection (roads/bridges).
Killzone Check:

Code: if (_target in (killZones getVariable [_base, []])) exitWith {false};
Explanation: Checks if recent reinforcements/attacks failed at the target, preventing infinite meat grinders.
Capacity Checks:

Code:
Sqf

Apply
_maxSend = garrison getVariable [format ["%1_recruit", _base], 0];
if((_reinfCount < 18) && {_maxSend < (_reinfCount * 2/3)}) exitWith {false};
if((_reinfCount > 8) && {!_isAirport}) exitWith {false};
Explanation: Ensures the base has enough recruits. Ground bases cannot send more than 8 troops at a time (to prevent massive convoys). Airports have fewer restrictions.
Return:

Code: true;
Explanation: If all checks pass, returns true.
Where it leads:

Calls:
A3A_fnc_arePositionsConnected
Dependencies:
spawner, forcedSpawn, killZones namespaces.
garrison namespace (recruit counts).
System Fit:
Called by the reinforcement scheduler (likely fn_scheduler or fn_findBasesForConvoy) to filter valid sources for reinforcements.
Global Variables Modified: None.
Network Implications: None.
Function Name: A3A_fnc_updateGarrison
What it does: Updates an existing garrison's composition (e.g., upgrading vehicle types or adding missing units) based on current preferences and tier.

How it does that:

Data Retrieval:

Code:
Sqf

Apply
_preferred = garrison getVariable (format ["%1_preference", _type]);
_garrison = garrison getVariable (format ["%1_garrison", _marker]);
Explanation: Gets the current preference template and the existing garrison data.
Vehicle Upgrade Loop:

Code:
Sqf

Apply
for "_i" from 0 to (_garCount - 1) do
{
    if(!([_garData select 0, _preData select 0] call A3A_fnc_checkVehicleType)) then
    {
        // Update Vehicle, Crew, and Group
    }
}
Explanation: Compares existing vehicle against preferred type. If they don't match (or are obsolete), it updates:
Vehicle (via fn_selectVehicleType).
Crew (via fn_getVehicleCrew).
Group (via fn_selectGroupType and A3A_checkGroupType).
Size Expansion:

Code:
Sqf

Apply
if(_garCount >= _preCount) exitWith {};
for "_i" from _garCount to (_preCount - 1) do
{
    _line = [_preferred select _i, _side] call A3A_fnc_createGarrisonLine;
    [_marker, _line, -1, true] call A3A_fnc_addRequested;
};
Explanation: If the preference template has grown (new tier), it creates new lines and adds them to the requested list (marked as missing units).
Where it leads:

Calls:
A3A_fnc_checkVehicleType
A3A_fnc_selectVehicleType
A3A_fnc_getVehicleCrew
A3A_checkGroupType
A3A_fnc_selectGroupType
A3A_fnc_createGarrisonLine
A3A_fnc_addRequested
Dependencies: garrison namespace, tierWar.
System Fit:
Used when the war tier increases (fn_updatePreference) or when a marker is re-evaluated. It ensures garrisons evolve with the war.
Global Variables Modified:
Indirectly updates garrison namespace via fn_addRequested.
Network Implications: Depends on fn_addRequested (syncs data).
Function Name: A3A_fnc_updatePreference
What it does: Updates the global preference templates (garrison composition rules) when the war tier increases.

How it does that:

Tier Check:

Code: if(tierPreference >= tierWar) exitWith {Debug("Aborting update of preferences!")};
Explanation: Only runs if the war tier has actually increased since the last preference update.
Loop Through New Tiers:

Code:
Sqf

Apply
for "_i" from (tierPreference + 1) to tierWar do
{ ... }
Explanation: Iterates through every skipped tier to ensure updates are not missed.
Category Updates (Airport, Milbase, etc.):

Code:
Sqf

Apply
if(_i in airportUpdateTiers) then
{
    _preference = garrison getVariable ["Airport_preference", []];
    [_preference] call A3A_fnc_updateVehicles;
    // PushBack new vehicle entries
    garrison setVariable ["Airport_preference", _preference, true];
}
Explanation:
Checks if the current tier triggers an update for a specific category.
Calls fn_updateVehicles to upgrade existing entries in the array (e.g., "LAND_START" -> "LAND_LIGHT").
Appends new vehicle entries (e.g., adding tanks or helicopters) to the array.
Updates the static defense percentage (Airport_statics) based on tier arrays.
Sets the variable with true to broadcast to clients.
Finalization:

Code: tierPreference = tierWar; publicVariable "tierPreference";
Explanation: Updates the global tier tracking and broadcasts it.
Where it leads:

Calls:
A3A_fnc_updateVehicles
Dependencies:
Global arrays: airportUpdateTiers, milbaseUpdateTiers, etc.
Global variables: tierWar, tierPreference.
System Fit:
Called periodically (e.g., in fn_scheduler or on mission time progression). It drives the escalation of the AI's military capabilities.
Global Variables Modified:
garrison: Updates preference variables for all types.
tierPreference: Updates the tracking variable.
Network Implications: Broadcasts garrison variables and tierPreference to all clients.
Function Name: A3A_fnc_updateReinfState
What it does: Updates the reinforcement state for a marker. This determines if the marker appears in the "Needs Reinforcements" list and if it is capable of sending reinforcements to others.

How it does that:

Side Handling:

Code: Handles _sides parameter (optional) if the marker changed ownership, otherwise reads current side from sidesX.
Remove Old Entries:

Code:
Sqf

Apply
if(_loser != teamPlayer) then
{
    // Find and delete marker from reinforceMarkerOccupants/Invaders and canReinforce lists
}
Explanation: If the marker switched sides (or was captured), it cleans up the old side's reinforcement lists.
Calculate Ratio:

Code: private _ratio = [_marker] call A3A_fnc_getGarrisonRatio;
Explanation: Gets the current strength percentage.
Update "Needs Help" List:

Code:
Sqf

Apply
if(_ratio != 1) then
{
    if(!_isAirport) then { ... pushBack [_ratio, _marker] ... }
}
else
{
    if(_index != -1) then { _reinfMarker deleteAt _index; };
}
Explanation:
If ratio < 1 (needs help), adds/updates the marker in reinforceMarkerOccupants/Invaders.
If ratio == 1 (full strength), removes it from the list.
Airports are excluded from receiving reinforcements.
Update "Can Send" List:

Code:
Sqf

Apply
if((_isAirport && _ratio > 0.4) || {_isOutpost && _ratio > 0.8 ...}) then
{
    _canReinf pushBackUnique _marker;
}
else
{
    _canReinf = _canReinf - [_marker];
}
Explanation: Checks if the garrison has enough strength (thresholds vary by type) to spare units for others. If so, adds to canReinforce... list; otherwise removes.
Where it leads:

Calls: A3A_fnc_getGarrisonRatio.
Dependencies:
reinforceMarkerOccupants, reinforceMarkerInvaders arrays.
canReinforceOccupants, canReinforceInvaders arrays.
sidesX namespace.
System Fit:
Called by fn_createGarrison (init), fn_addGarrison (growth), and likely after combat events (despawning).
Global Variables Modified:
reinforceMarkerOccupants/Invaders (Array).
canReinforceOccupants/Invaders (Array).
(Note: These are likely global variables, not namespace, implied by direct array manipulation).
Network Implications: The arrays are likely public global variables, affecting client-side UI and server-side reinforcement scheduling.
Function Name: A3A_fnc_updateVehicles
What it does: In-place modifies a preference array, upgrading vehicle categories and cargo types based on a logical progression.

How it does that:

Loop Through Entries:

Code: for "_i" from 0 to ((count _preference) - 1) do { ... }
Explanation: Iterates over every preference tuple in the array.
Vehicle Upgrade Logic:

Code:
Sqf

Apply
if(!(_vehicle in ["EMPTY", "LAND_TANK", ...])) then
{
    switch (_vehicle) do
    {
        case ("LAND_START") : {_newVehicle = "LAND_LIGHT";};
        // ... more cases ...
    };
};
Explanation: Checks if the vehicle is already at max tier. If not, uses a switch statement to advance the category (e.g., Light -> Default -> APC -> Attack -> Tank).
Cargo Upgrade Logic:

Code:
Sqf

Apply
if(!(_cargo in ["EMPTY", "AA", "AT"])) then
{
    if(_newVehicle in ["LAND_START", ...]) then { _newCargo = "GROUP"; };
    // ... logic for Squads, AT, AA based on vehicle type ...
};
Explanation: Adjusts the passenger group type to match the new vehicle capability (e.g., larger vehicles get "SQUAD" instead of "GROUP").
In-Place Update:

Code: _data set [0, _newVehicle]; _data set [2, _newCargo];
Explanation: Modifies the passed array directly.
Where it leads:

Calls: None.
Dependencies: None (Pure logic).
System Fit:
Used by fn_updatePreference to scale garrison strength with the war tier.
Global Variables Modified: None (Modifies passed reference).
Network Implications: None.