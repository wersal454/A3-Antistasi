A3A_fnc_canGoUndercover
Function Name: A3A/addons/core/functions/Undercover/fn_canGoUndercover.sqf
What it does:
Checks if the player is currently able to transition into undercover status. This function acts as a gatekeeper, verifying various conditions related to player equipment, vehicle state, proximity to enemy territory, and current combat status. It's designed to be called immediately before activating undercover to prevent illegal state transitions.

When/Why it's called:

Called by A3A_fnc_goUndercover to validate undercover eligibility
Called by other systems (via mission scripts or UI actions) when player requests to go undercover
Returns a boolean result and a string reason that explains why undercover is unavailable
How it does that:
1. Initialization and Early Validation
Sqf

Apply
private _reasons = [];

if (player != player getVariable["owner", player]) exitWith
{
    ["Undercover", localize "STR_A3A_fn_undercover_canGoUn_no_ai"] call A3A_fnc_customHint;
    [false, "No Undercover while controlling AI"];
};

if (captive player) exitWith
{
    ["Undercover", localize "STR_A3A_fn_undercover_canGoUn_already"] call A3A_fnc_customHint;
    [false, "Already undercover"];
};
Purpose: Prevent invalid states before continuing
Logic Flow:
Checks if player is controlling an AI unit (owner variable)
Checks if player is already captive (undercover status)
Exit Early: Both conditions immediately return [false, reason]
Technical Details:
Uses player getVariable["owner", player] to detect AI control
captive player returns the player's current captive status
A3A_fnc_customHint displays a localized UI hint
2. Faction Attribute Checks
Sqf

Apply
private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];

private _roadblocks = controlsX select {isOnRoad(getMarkerPos _x)};

if (_lowCiv || {_civNonHuman}) exitWith {
    [localize "STR_A3A_goUndercover_title", localize "STR_A3A_fn_undercover_canGoUn_no_lowciv"] call A3A_fnc_customHint;
    [false, "Undercover not allowed in current civ template."];
};
Purpose: Check civilian faction configuration
Logic Flow:
Retrieves attributeLowCiv and attributeCivNonHuman from civilian faction hashmap
Filters controlsX markers that are on roads to get roadblocks
If either attribute is true, prevents undercover
Technical Details:
Faction(civilian) returns the civilian faction hashmap
getOrDefault safely retrieves boolean attributes
isOnRoad checks if marker position is on a road
Edge Case: Returns early if civilian faction is configured as "low civ" or non-human
3. Secure Base Calculation
Sqf

Apply
private _secureBases = airportsX + milbases + outposts + seaports + (controlsX select {isOnRoad(getMarkerPos _x)});
Purpose: Create array of all enemy-controlled bases and secure areas
Technical Details:
Combines: airports, military bases, outposts, seaports, and roadblocks
Uses controlsX (global array of all control markers)
Important: This array is used for proximity checks later in the function
4. Vehicle-Based Checks
Sqf

Apply
if !(isNull (objectParent player)) then
{
    if (!(typeOf(objectParent player) in undercoverVehicles)) exitWith
    {
        ["Undercover", localize "STR_A3A_fn_undercover_canGoUn_no_nociv"] call A3A_fnc_customHint;
        _result = [false, "In non civilian vehicle"];
    };
    if ((objectParent player) getVariable ["A3A_reported", false]) exitWith
    {
        ["Undercover", localize "STR_A3A_fn_undercover_canGoUn_no_reported1"] call A3A_fnc_customHint;
        _result = [false, "In reported vehicle"];
    };
    if ((objectParent player) getVariable ["SA_Tow_Ropes", []] isNotEqualTo []) exitWith
    {
        ["Undercover", localize "STR_A3A_fn_undercover_canGoUn_no_towrope"] call A3A_fnc_customHint;
        _result = [false, "In vehicle with tow ropes attached"];
    };
}
Purpose: Validate vehicle state if player is inside one
Logic Flow:
Check if player is in a vehicle (objectParent player not null)
Verify vehicle type is in undercoverVehicles global array
Check if vehicle is already reported (A3A_reported variable)
Check if vehicle has tow ropes attached (SA_Tow_Ropes variable)
Technical Details:
typeOf(objectParent player) gets vehicle class name
undercoverVehicles is a global array of allowed civilian vehicle classes
Vehicle uses namespace variables: A3A_reported and SA_Tow_Ropes
isNotEqualTo [] checks for non-empty array (tow ropes present)
Exit on Failure: Each condition sets _result and exits the block
5. On-Foot Equipment Checks
Sqf

Apply
else
{
    if (dateToNumber date < (player getVariable ["compromised", 0])) exitWith
    {
        ["Undercover", localize "STR_A3A_fn_undercover_canGoUn_no_reported2"] call A3A_fnc_customHint;
        _result = [false, "Recently reported"];
    };

    private _text = localize "STR_A3A_fn_undercover_canGoUn_no_while";
    _result = [true];
    if (primaryWeapon player != "" || secondaryWeapon player != "" || handgunWeapon player != "") then
    {
        _text = format [localize "STR_A3A_fn_undercover_canGoUn_no_reason_weapon", _text];
        _result set [0, false];
        _result pushBack "Weapon visible";
    };
    // ... additional checks for vest, helmet, NVG, uniform, no clothes, tow ropes
}
Purpose: Validate on-foot player state when not in vehicle
Logic Flow:
Check if player is still "compromised" from previous incident
Initialize _result as success [true]
Sequentially check equipment:
Weapons: Primary, secondary, or handgun equipped
Vest: Any vest equipped
Helmet: If helmet is in allArmoredHeadgear global array
NVG: If any HMD equipped
Uniform: If uniform not in civilian faction's uniform list
No Clothes: If uniform slot is empty
Tow Ropes: If player is holding tow ropes
Technical Details:
dateToNumber date converts game date to a comparable number
compromised variable stores timestamp when player was compromised
Each check adds failure reason to _result array: [false, "Reason1", "Reason2", ...]
Dynamic Hint: Accumulates failures into a formatted text message
Array Manipulation: _result set [0, false] changes first element to false
PushBack: Adds failure reason string to the array
6. Result Processing and Early Exit
Sqf

Apply
if (count _result != 0 && !(_result select 0)) exitWith
{
    _result;
};
Purpose: Exit function if vehicle or on-foot checks failed
Logic:
Only if _result is populated AND first element is false
Returns the result array immediately
Skips remaining proximity and awareness checks
7. Proximity to Enemy Territory
Sqf

Apply
private _base = [_secureBases, player] call BIS_fnc_nearestPosition;
private _size = [_base] call A3A_fnc_sizeMarker;
if ((player distance2D getMarkerPos _base < _size * 2) && (sidesX getVariable [_base, sideUnknown] != teamPlayer)) exitWith
{
    ["Undercover", localize "STR_A3A_fn_undercover_canGoUn_no_close"] call A3A_fnc_customHint;
    [false, "Near enemy territory"];
};
Purpose: Prevent undercover near enemy bases
Logic Flow:
Find nearest secure base to player position
Get marker size using A3A_fnc_sizeMarker
Calculate distance threshold: size * 2
Check if:
Player is within threshold distance
Base is not controlled by player's team (teamPlayer)
Technical Details:
BIS_fnc_nearestPosition finds closest marker in _secureBases array
sidesX is a namespace storing marker control ownership
teamPlayer is the player's side (rebel)
Exit on Failure: Returns [false, "Near enemy territory"]
8. Enemy Awareness Check
Sqf

Apply
if
(
    {
        ((side _x == Invaders) || (side _x == Occupants)) &&
        {(_x knowsAbout player > 1.4) &&
        {_x distance player < 500}}}
    count allUnits > 0
) exitWith
{
    ["Undercover", localize "STR_A3A_fn_undercover_canGoUn_no_spotted"] call A3A_fnc_customHint;
    [false, "Spotted by enemies"];
};
Purpose: Prevent undercover if spotted by enemy units
Logic Flow:
Iterate through all units (allUnits)
Filter for enemies (Invaders or Occupants side)
Check if any enemy has:
Knowledge of player > 1.4 (threshold for positive identification)
Distance < 500 meters
If count > 0, exit with failure
Technical Details:
knowsAbout returns enemy awareness level (0-4)
> 1.4 indicates >35% detection (not exact, but used as threshold)
count allUnits > 0 ensures at least one match exists
Performance: This is a unit-counting operation that runs every call
9. Success Case
Sqf

Apply
[true, ""];
Purpose: Return success if all checks pass
Returns: [true, ""] indicating player can go undercover
Where it leads:
Functions Called by fn_canGoUndercover:
A3A_fnc_customHint (Multiple calls)

Location: A3A/addons/core/functions/UI/fn_customHint.sqf
Purpose: Displays UI hints to the player with localized text
Called with: Undercover-specific localized strings and hint titles
BIS_fnc_nearestPosition

Location: BIS Framework function
Purpose: Finds closest marker to player from _secureBases array
Input: Array of markers, player object
A3A_fnc_sizeMarker

Location: A3A/addons/core/functions/Base/fn_sizeMarker.sqf
Purpose: Returns the radius of a circular or size area of a rectangular marker
Input: Marker name string
Faction(civilian) (Helper function)

Location: Template system (implicit call to faction loading)
Purpose: Retrieves civilian faction configuration hashmap
Returns: HashMap with faction attributes
Functions That Call fn_canGoUndercover:
A3A_fnc_goUndercover

Location: A3A/addons/core/functions/Undercover/fn_goUndercover.sqf
Role: Primary caller - uses this to validate before activating undercover
Usage: private _result = [] call A3A_fnc_canGoUndercover;
Other Mission Scripts

Potential callers: Mission-specific triggers, action menus, or UI buttons that initiate undercover
Global Variables Modified/Accessed:
Read-Only Access:
player - The local player object
controlsX - Array of all control markers (global)
airportsX, milbases, outposts, seaports - Base marker arrays (global)
undercoverVehicles - Allowed vehicle class array (global)
allArmoredHeadgear - Helmet blacklist array (global)
sidesX - Namespace for marker ownership (global)
teamPlayer, Invaders, Occupants - Side constants (global)
A3A_faction_civ - Civilian faction hashmap (global)
A3A_hasACE - ACE mod detection boolean (global)
Namespace Variables (Player):
owner - AI control variable
compromised - Timestamp of last compromise
SA_Tow_Ropes_Vehicle - Tow rope state
SA_Tow_Ropes - Tow rope attachment list
A3A_reported - Vehicle reported status
Synchronization/Network Implications:
Local Execution: Runs entirely on client (player machine)
No Network Calls: Pure local calculation, no remote execution
State Dependencies: Relies on global variables that are typically synchronized by the server
Timing: Called before any network operations in fn_goUndercover
Fits into Larger System:
Undercover System: Entry point for player's stealth gameplay
Game State Flow: Part of transition: Player → Vehicle/Equipment Check → Territory Check → Awareness Check → (Success) → fn_goUndercover → Undercover Active
Combat Status: Integrates with "compromised" state and vehicle reporting system
Template System: Validates against civilian faction configuration
Error Handling: Provides detailed reasons for failure, enabling user feedback
Edge Cases Handled:
AI Control: Prevents AI-controlled units from going undercover
Already Undercover: Prevents duplicate state changes
Low Civ/Non-Human Templates: Disables undercover for incompatible factions
Non-Civilian Vehicle: Blocks entry into armed/security vehicles
Reported Vehicle: Vehicles previously spotted cannot be used
Tow Ropes: Vehicles with tow ropes are considered suspicious
Compromised State: Recent exposure prevents immediate re-entry
Combat Equipment: Comprehensive list of banned gear
No Clothes: Player must be wearing something
Enemy Proximity: Prevents undercover near active threats
Enemy Awareness: Stops undercover if already detected
Roadblocks: Treated as enemy territory when checking proximity
Performance Considerations:
allUnits Scan: Only performed on foot (not in vehicle)
Array Filtering: Uses SQF's efficient selection/filter operations
Early Exits: Most checks exit early on failure
Minimal Calculation: Distance checks use simple arithmetic
A3A_fnc_goUndercover
Function Name: A3A/addons/core/functions/Undercover/fn_goUndercover.sqf
What it does:
Activates undercover status for the player when conditions are met, monitors the player's state continuously until undercover is broken, and handles all transition effects including visual indicators, AI companion logic, and system state updates. It's the state manager for the undercover gameplay loop.

When/Why it's called:

Called after A3A_fnc_canGoUndercover returns [true, ""]
Triggered by player action, UI button, or command that initiates undercover
Runs until either: player cancels, conditions break, or mission ends
How it does that:
1. Pre-Activation Validation
Sqf

Apply
private _result = [] call A3A_fnc_canGoUndercover;

if(!(_result select 0)) exitWith
{
    if((_result select 1) == "Spotted by enemies") then
    {
        if !(isNull (objectParent player)) then
        {
            (objectParent player) setVariable ["A3A_reported", true, true];
            {
                if ((isPlayer _x) && (captive _x)) then
                {
                    [_x, false] remoteExec["setCaptive", _x];
                };
            } forEach ((crew(objectParent player)) + (assignedCargo(objectParent player)) - [player]);
        };
    };
};

if (_result select 0 isEqualTo false) exitWith {["Undercover", _result select 1] call A3A_fnc_customHint};
Purpose: Validate using fn_canGoUndercover and handle special "spotted" case
Logic Flow:
Call validation function
If fail AND reason is "Spotted by enemies":
Mark vehicle as reported
Remove captive status from all passengers (remote execution)
If fail for any other reason: Show hint and exit
Technical Details:
Remote Execution: [_x, false] remoteExec["setCaptive", _x] runs setCaptive on each passenger's machine
Complex Array: (crew(objectParent player)) + (assignedCargo(objectParent player)) - [player] gets all passengers except player
Variable Setting: setVariable with true in third parameter makes it global/synchronized
2. Visual Feedback Layer
Sqf

Apply
private _layer = ["A3A_infoCenter"] call BIS_fnc_rscLayer;
[(localize "STR_antistasi_dialogs_radio_comm_undercover"), 0, 0, 4, 0, 0, _layer] spawn bis_fnc_dynamicText;
Purpose: Display "Undercover" text on screen
Technical Details:
BIS_fnc_rscLayer gets/creates display layer for text
bis_fnc_dynamicText spawns the text with timing: 0 second delay, 4 second duration
Layer: "A3A_infoCenter" is a defined display layer in UI system
3. Core Undercover Activation
Sqf

Apply
player setCaptive true;
[] spawn A3A_fnc_statistics;
if (player == leader group player) then
{
    {
        if ((!isplayer _x) && (local _x) && (_x getVariable["owner", _x] == player)) then
        {
            [_x] spawn A3A_fnc_undercoverAI;
        }
    } forEach units group player;
};
Purpose: Set player captive, update stats, manage AI companions
Logic Flow:
Player State: Set captive to true (game engine hides player from enemy AI)
Statistics: Spawn stats update to refresh UI
AI Management: For each group member:
Check if: Not player, local to client, controlled by player
Spawn undercover AI function
Technical Details:
setCaptive true is the core engine mechanic for "invisible to AI"
spawn A3A_fnc_statistics runs asynchronously
isplayer _x checks if unit is human-controlled
local _x checks if unit runs on this client (for AI commands)
getVariable["owner", _x] == player checks if AI is player-controlled
spawn A3A_fnc_undercoverAI starts companion AI logic loop
4. Secure Base Definition
Sqf

Apply
private _secureBases = (
    (airportsX + outposts + seaports + milbases + (controlsX select {isOnRoad(getMarkerPos _x)})) select {sidesX getVariable [_x, sideUnknown] != teamPlayer}
) + (milAdministrationsX select {sidesX getVariable [_x,sideUnknown] == Occupants});
Purpose: Create array of all enemy-controlled secure bases for detection
Logic:
Combine all base types (airports, outposts, seaports, milbases, roadblocks)
Filter to include only those NOT controlled by player's team
Add military administrations controlled by Occupants
Technical Details:
sidesX namespace stores marker ownership
sideUnknown is fallback default
milAdministrationsX - specific military admin zones
Purpose: This defines where player can be detected while undercover
5. Main Monitoring Loop
Sqf

Apply
private _lastBaseInside = "";
private _reason = "";
["Undercover", [""]] call EFUNC(Events,triggerEvent);

while {_reason == ""} do
{
    private _healingTarget = objNull;
    if !(isNil {player getVariable "ace_medical_treatment_endInAnim"}) then
    {
        _healingTarget = currentAceTarget;
    };

    sleep 1;

    if (!captive player) exitWith
    {
        _reason = "Reported";
    };

    // ... additional checks
};
Purpose: Continuous monitoring loop (runs every second)
Structure:
Initialize tracking variables
Trigger event for "Undercover started"
Loop with sleep 1 (1 second intervals)
Check various conditions each iteration
Technical Details:
_lastBaseInside tracks which base was last checked to avoid repeated detection
EFUNC(Events,triggerEvent) triggers mod events (CBA extended functions)
ACE Integration: Checks if player is in healing animation and gets target
6. Vehicle State Monitoring
Sqf

Apply
private _veh = objectParent player;
if !(isNull _veh) then
{
    private _vehType = typeOf _veh;
    if (!(_vehType in undercoverVehicles)) exitWith
    {
        _reason = "VNoCivil"
    };

    if (_veh getVariable ["A3A_reported", false]) exitWith
    {
        _reason = "VCompromised"
    };

    if (_veh getVariable ["SA_Tow_Ropes", []] isNotEqualTo []) exitWith
    {
        _reason = "VTowRopes"
    };

    // ... more vehicle checks
};
Purpose: Check vehicle integrity every second
Checks Performed:
Vehicle Type: Must remain in undercoverVehicles
Reported Status: Must not be flagged as reported
Tow Ropes: Must not have tow ropes attached
Explosives (ACE): Checks for nearby demo charges/satchels detected by enemies
No-Fly Zone: Checks if vehicle entered restricted airspace
Highway Off-road: Checks if ground vehicle is far from road while enemies nearby
Technical Details:
Uses early exitWith for each failure condition
mineDetectedBy checks if explosives are detected by specific side
nearObjects filters for explosive types within 5m
NoFlyZoneDetected is set by airspace control system
7. On-Foot State Monitoring
Sqf

Apply
else
{
    if (_healingTarget != objNull && {side _healingTarget != civilian && {_healingTarget isKindOf "Man"}}) exitWith
    {
        if ({((side _x == Invaders) or(side _x == Occupants)) and((_x knowsAbout player > 1.4) or(_x distance player < 350))} count allUnits > 0) then
        {
            _reason = "BadMedic2";
        }
        else
        {
            _reason = "BadMedic";
        };
    };
    if ((primaryWeapon player != "") || (secondaryWeapon player != "") || (handgunWeapon player != "") || (vest player != "") || (getNumber(configfile >> "CfgWeapons" >> headgear player >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Head" >> "armor") > 2) || (hmd player != "") || (!(uniform player in (A3A_faction_civ get "uniforms")))) exitWith
    {
        if ({((side _x == Invaders) or (side _x == Occupants)) and ((_x knowsAbout player > 1.4) or (_x distance player < 350))} count allUnits > 0) then
        {
            _reason = "clothes2"
        }
        else
        {
            _reason = "clothes"
        };
    };
    // ... more checks
};
Purpose: Check on-foot player state every second
Checks Performed:
Healing Enemy: If healing a non-civilian, break undercover
Equipment Violation: Any weapon, vest, armored helmet, NVG, or non-civilian uniform
Compromised State: Check timestamp against current game time
Tow Ropes: Holding tow ropes breaks undercover
Technical Details:
ACE Healing: Uses currentAceTarget from event handlers
Helmet Armor Check: Retrieves config value for helmet armor protection
Uniform Check: Validates against A3A_faction_civ uniform list
Context-Aware Breaking: Different reason codes based on enemy proximity
Code:
"clothes" - Equipment violation without enemies nearby
"clothes2" - Equipment violation with enemies nearby (sets compromised)
"BadMedic" - Healing enemy without enemies nearby
"BadMedic2" - Healing enemy with enemies nearby (sets compromised)
8. Territory/Proximity Monitoring
Sqf

Apply
// Don't do location checks on air vehicles. AirspaceControl handles that.
if (!isNull _veh and { _veh isKindOf "Air" }) then { continue };

private _base = [_secureBases, player] call BIS_fnc_nearestPosition;
private _onDetectionMarker = detectionAreas findIf {player inArea _x && (_base in airportsX) && {((getMarkerPos _x) distance2D (getMarkerPos _base)) <= 700}} != -1;
private _onBaseMarker = player inArea _base;
private _baseSide = sidesX getVariable [_base, sideUnknown];
if ((_onBaseMarker || _onDetectionMarker) && (_baseSide != teamPlayer) && (_base != _lastBaseInside)) then
{
    // ... reason assignment based on base type
};
Purpose: Detect entry into enemy territory
Logic Flow:
Skip airspace checks (handled separately)
Find nearest secure base
Check if player is on detection marker (airfield radar area)
Check if player is inside base marker area
Only trigger if base is enemy-controlled AND not recently checked
Technical Details:
detectionAreas - Special markers for airfield radar zones
findIf - Efficient search for matching detection area
continue - Loops to next iteration if in air vehicle
Base Types: Different reasons for airports, outposts, seaports, milbases, roadblocks
Aggression Calculation: For roadblocks, uses aggression + tier war level for random chance
9. Reason Processing and Exit
Sqf

Apply
if (captive player) then
{
    player setCaptive false;
};

if !(isNull (objectParent player)) then
{
    {
        if (isPlayer _x) then
        {
            [_x, false] remoteExec["setCaptive", _x];
        }
    } forEach((assignedCargo(vehicle player)) + (crew(vehicle player)) - [player]);
};

private _layer = ["A3A_infoCenter"] call BIS_fnc_rscLayer;
[localize "STR_A3A_fn_undercover_goUn_off", 0, 0, 4, 0, 0, _layer] spawn bis_fnc_dynamicText;
[] spawn A3A_fnc_statistics;
Purpose: Clean up undercover state and update UI
Logic:
Clear captive status from player
Clear captive status from all passengers
Display "Undercover Off" text
Update statistics
Technical Details:
setCaptive false - Core engine mechanic removal
remoteExec - Synchronizes passenger states across network
10. Reason-Specific Handling
Sqf

Apply
switch (_reason) do
{
    case "Reported":
    {
        ["Undercover", localize "STR_A3A_fn_undercover_goUn_reported"] call A3A_fnc_customHint;
        if (vehicle player != player) then
        {
            (objectParent player) setVariable ["A3A_reported", true, true];
        }
        else
        {
            player setVariable["compromised", (dateToNumber[date select 0, date select 1, date select 2, date select 3, (date select 4) + 30])];
        };
    };
    // ... more cases
};
Purpose: Provide context-specific feedback and set appropriate game state

Reason Codes and Actions:

Reported: Vehicle marked as compromised or player gets 30-minute lockout
VNoCivil: Shows hint about non-civilian vehicle
VCompromised: Shows hint about reported vehicle
VTowRopes/VTowRopes: Tow rope violations
SpotBombTruck: Explosives detected - vehicle marked as reported
Highway: Off-road in enemy area - vehicle marked as reported
clothes: Equipment violation without enemy proximity
clothes2: Equipment violation with enemy proximity - sets compromised
BadMedic/BadMedic2: Healing enemy violation
Compromised: Left vehicle while compromised
Airport/Outpost/Milbase/Seaport/Roadblock: Base trespassing - marks compromised
NoFly: Airspace violation - marks vehicle reported
Technical Details:

Switch Statement: Efficient multi-case handling
Timestamp Calculation: dateToNumber[year, month, day, hour, (minute + 30)] creates 30-minute future timestamp
Variable Setting: setVariable with true makes changes global/synchronized
11. Event Triggering
Sqf

Apply
["Undercover", [_reason]] call EFUNC(Events,triggerEvent);
Purpose: Notify other systems of undercover status change
Technical Details:
Uses CBA Events system for modularity
Reason code allows other systems to react specifically
Where it leads:
Functions Called by fn_goUndercover:
A3A_fnc_canGoUndercover

Location: A3A/addons/core/functions/Undercover/fn_canGoUndercover.sqf
Purpose: Validates eligibility before activation
Called: private _result = [] call A3A_fnc_canGoUndercover;
A3A_fnc_customHint (Multiple calls)

Location: A3A/addons/core/functions/UI/fn_customHint.sqf
Purpose: Displays UI feedback for all state transitions
BIS_fnc_rscLayer

Location: BIS Framework function
Purpose: Gets display layer for dynamic text
bis_fnc_dynamicText

Location: BIS Framework function
Purpose: Spawns on-screen text messages
A3A_fnc_statistics

Location: A3A/addons/core/functions/Base/fn_statistics.sqf
Purpose: Updates UI stat display
Called with: spawn for asynchronous execution
A3A_fnc_undercoverAI

Location: A3A/addons/core/functions/AI/fn_undercoverAI.sqf
Purpose: Manages AI companion logic for player-controlled units
Called for: Each non-player, local, player-controlled AI in group
EFUNC(Events,triggerEvent)

Location: CBA Events system
Purpose: Triggers mod events for system integration
Called with: Event name and optional payload
BIS_fnc_nearestPosition

Location: BIS Framework function
Purpose: Finds nearest enemy base for detection
Called with: _secureBases array and player
dateToNumber

Location: Built-in SQF function (or custom implementation)
Purpose: Converts game date to comparable number
Functions That Call fn_goUndercover:
UI Actions/Mission Scripts

Not explicitly shown in provided code
Likely called by: Player action menu, command bar button, or scripted trigger
Possible Indirect Callers:

Vehicle-based undercover activation
Equipment-based undercover activation
Map marker interactions
Global Variables Modified/Accessed:
Read/Write Access:
player - Local player object (state changes)
objectParent player - Current vehicle (variable modifications)
Modified Namespace Variables:
A3A_reported - Vehicle reported status (if set)
compromised - Player compromise timestamp (if set)
NoFlyZoneDetected - Airspace violation marker (if cleared)
SA_Tow_Ropes - Tow rope state (read only)
SA_Tow_Ropes_Vehicle - Tow rope association (read only)
captive - Player's captive state (engine-owned)
Read-Only Global:
undercoverVehicles - Allowed vehicle list
airportsX, milbases, etc. - Base markers
sidesX - Marker ownership
teamPlayer, Invaders, Occupants - Side constants
detectionAreas - Radar zones
milAdministrationsX - Admin zones
A3A_faction_civ - Civilian uniforms list
allUnits - AI units array
currentAceTarget - ACE healing target
A3A_hasACE - ACE mod flag
Synchronization/Network Implications:
Network Calls:
remoteExec["setCaptive", _x] - Synchronizes captive state to other players
setVariable with true - Makes variable changes global across network
Client-Side Loops:
Main monitoring loop runs locally on client
Only network synchronization is for passenger states
State Consistency:
Vehicle reporting and compromised status are globally synchronized
Local loop checks server-synced values
Fits into Larger System:
Undercover State Machine: Central state manager for stealth gameplay
Game Flow Integration:
Player Request → Validation → Activation → Monitoring → Termination → Cleanup
Combat System Integration:
Ties into "reported" vehicle system
Links with "compromised" player status
Integrates with ACE medical if present
AI Command System: Manages AI companion behavior during undercover
Event System: Triggers events for mod integration and mission scripting
UI Feedback: Provides comprehensive feedback through hints and text
Edge Cases Handled:
Mid-Loop State Changes: Checks conditions every second
Player Death/Respawn: Loop exits when captive is cleared by other systems
Vehicle Changes: Continuously validates vehicle type and status
Network Disconnections: Local loop continues but may not sync properly
ACE Integration: Special handling for ACE medical interactions
Multiple Violations: Reason code determines which violation was first
Air Vehicles: Skips ground detection for aircraft
Repeated Base Entries: _lastBaseInside prevents spam detection
Aggression-Based Detection: Roadblock checks use dynamic aggression values
Airspace Violations: Special handling for no-fly zone system
Performance Considerations:
1-Second Loop: Balanced between responsiveness and performance
Unit Counting: Only performed on foot, not in vehicle
Array Operations: Efficient SQF filtering and selection
Early Exits: Loop exits immediately when reason found
Local-Only: Minimal network traffic
Code Complexity Notes:
Nested Conditions: Complex boolean logic for equipment checks
State Tracking: Multiple variables track different aspects (base, reason, etc.)
Context-Aware Reasons: Different codes for same violation based on enemy proximity
Mod Integration: ACE-specific checks that are skipped if mod not present
A3A_fnc_initUndercover
Function Name: A3A/addons/core/functions/Undercover/fn_initUndercover.sqf
What it does:
Initializes the ACE medical target tracking system for undercover compatibility. Sets up event handlers to track the current interaction target during ACE medical interactions, which is needed for the undercover system to detect when a player is healing enemy units.

When/Why it's called:

Called during mission initialization (preInit or postInit)
Required for undercover system to work with ACE medical mod
Sets up persistent event handlers that run throughout the mission
How it does that:
1. ACE Mod Detection
Sqf

Apply
if (A3A_hasACE) then {
Purpose: Only initialize if ACE medical is present
Technical Details:
A3A_hasACE is a global boolean set during mod detection
Prevents initialization errors if ACE isn't loaded
2. Variable Initialization
Sqf

Apply
currentAceTarget = objNull;
Purpose: Create global variable for tracking healing target
Technical Details:
objNull is the default value (no target)
Variable is used by undercover loop to detect enemy healing
3. Interaction Menu Handler
Sqf

Apply
["ace_interactMenuOpened", {
    //player setVariable ["lastMenuOpened", "INTERACT"];
    currentAceTarget = ace_interact_menu_selectedTarget;
}] call CBA_fnc_addEventHandler;
Purpose: Track target when ACE interaction menu opens
Logic Flow:
Event handler registered for ace_interactMenuOpened
When event fires, extract selectedTarget from ACE interaction menu
Store in currentAceTarget
Technical Details:
CBA_fnc_addEventHandler registers the event handler
ace_interact_menu_selectedTarget is an ACE global variable containing the interaction target
Commented-out line shows historical tracking of menu type
4. Medical Menu Handler
Sqf

Apply
["ace_medicalMenuOpened", {
    //player setVariable ["lastMenuOpened", "MEDICAL"];
    currentAceTarget = param [1];
}] call CBA_fnc_addEventHandler;
Purpose: Track target when ACE medical menu opens
Logic Flow:
Event handler registered for ace_medicalMenuOpened
When event fires, extract second parameter (medical target)
Store in currentAceTarget
Technical Details:
param [1] extracts the second parameter from the event
Medical menu event passes patient as second parameter
Commented-out line shows historical tracking of menu type
Where it leads:
Functions Called by fn_initUndercover:
CBA_fnc_addEventHandler
Location: CBA (Community Base Addons) mod
Purpose: Registers event handlers for mod events
Called Twice: For ace_interactMenuOpened and ace_medicalMenuOpened
Functions That Call fn_initUndercover:
Mission Initialization System

Location: A3A/addons/core/functions/init/fn_initClient.sqf (likely)
Purpose: Part of client-side initialization sequence
Called: During mission startup, after CBA and ACE are loaded
Other Init Functions

May be called by A3A_fnc_initClient or similar initialization script
Global Variables Modified/Accessed:
Read/Write Access:
currentAceTarget - Global variable for healing target tracking
Read-Only:
A3A_hasACE - ACE mod detection flag
ace_interact_menu_selectedTarget - ACE interaction target (read from ACE)
Synchronization/Network Implications:
Local-Only System:
Event handlers run locally on each client
currentAceTarget is local to client (not synchronized)
Undercover loop uses local currentAceTarget value
No Network Traffic:
Pure client-side event handling
No remote execution or synchronization needed
Fits into Larger System:
ACE Medical Integration: Bridge between ACE medical system and A3A undercover system
Event-Driven Architecture: Uses CBA events for loose coupling
Initialization Chain: Part of client-side mod initialization
Undercover System Dependency: Required for the undercover loop to detect enemy healing
Edge Cases Handled:
Non-ACE Environments: Initialization skipped if ACE not present
Event Registration: Uses CBA event system for reliability
Variable Persistence: currentAceTarget persists throughout mission
Code Simplicity:
Minimal Logic: Only sets up tracking, no processing
Event-Based: Reactive design, only triggers when menus open
Fail-Safe: Uses objNull default, safe for nil-checks