Function Name: fn_addBuildingActions.sqf
What it does:
Client-side function that adds interactive actions to a plank construction object, enabling players to either "Build" or "Cancel" the construction of a building. The "Build" action is a hold action that requires engineer qualification and proximity, while the "Cancel" action is a simple action for immediate cancellation.

When/Why it's called: Called via remote execution from 
fn_placeBuilderObjects.sqf
 when a new construction plank is created on the server, broadcasting to all clients to add the interactive actions to the plank object.

How it does that:
Step 1: Parameter validation and initialization

Sqf

Apply
params ["_plankObject", "_holdTime"];
Takes two parameters: _plankObject (the plank object to add actions to) and _holdTime (calculated based on object price)
No explicit validation shown; assumes proper types are passed from caller
Step 2: Add "Build" hold action

Sqf

Apply
[
    _plankObject,
    "Build",
    "a3\ui_f\data\igui\cfg\actions\repair_ca.paa",
    "a3\ui_f\data\igui\cfg\actions\repair_ca.paa",
    "isNull objectParent player && {player call A3A_fnc_isEngineer && {(player distance _target < 8)}}",
    "[player] call A3A_fnc_canFight and (player distance _target < 10)",
    {},
    {},
    {
        [_this#0, true] remoteExecCall ["A3A_fnc_buildingComplete", 2];
    },
    {},
    [],
    _holdTime
] call BIS_fnc_holdActionAdd;
Uses BIS_fnc_holdActionAdd to create a hold action with these specifications:
Target object: _plankObject
Title: "Build"
Icon (idle/hover): Repair icon
Condition to show: Must be dismounted (isNull objectParent player), player is engineer (player call A3A_fnc_isEngineer), and within 8 meters of the target
Condition for success: Must be able to fight ([player] call A3A_fnc_canFight) and within 10 meters
Start/completion code: Empty code blocks (no-op)
Code on completion: [_this#0, true] remoteExecCall ["A3A_fnc_buildingComplete", 2] - calls server function with true for completed
Code on interrupt: Empty
Arguments: Empty array
Hold time: _holdTime (calculated externally, varies by object price)
Step 3: Add "Cancel" action

Sqf

Apply
_plankObject addAction ["Cancel",
    {
        [_this#0, false] remoteExecCall ["A3A_fnc_buildingComplete", 2];
    },
    nil,
    1.5,
    true,
    true,
    "",
    "player call A3A_fnc_isEngineer",
    8
];
Uses addAction for instant cancellation:
Title: "Cancel"
Code: Calls A3A_fnc_buildingComplete with false for cancellation
Priority: 1.5
Show window: true
Hide on use: true
Condition: Empty (always shown)
Condition for activation: Must be engineer (player call A3A_fnc_isEngineer)
Radius: 8 meters
Where it leads:
Functions called:

A3A_fnc_isEngineer - Checks if player has engineer trait
A3A_fnc_canFight - Checks if player can fight (not incapacitated)
A3A_fnc_buildingComplete (remote) - Server function to complete/cancel construction
Functions that call this:

fn_placeBuilderObjects.sqf
 - Calls via remote execution for each construction plank
Potentially 
fn_lockBuilderBox.sqf
 for repair scenarios
Global variables:

Modifies: None directly
Reads: None directly
Network implications: remoteExecCall to server (JIP compatible due to object attachment)
System integration:

Part of the construction system flow: Player place object → Server creates plank → Client gets actions → Player performs action → Server completes/cancels
Uses client-side validation for eligibility checks
No data persistence beyond action lifetime
Function Name: fn_buildingComplete.sqf
What it does:
Server-side function that processes construction completion or cancellation. Either refunds resources (if cancelled), repairs a ruined building (if repair scenario), or spawns the actual building (if completed). Cleans up the temporary plank object and updates global building tracking arrays.

When/Why it's called: Called remotely by 
fn_addBuildingActions.sqf
 when a player finishes the hold action or clicks cancel. Also called from repair scenarios in the building placer.

How it does that:
Step 1: Parameter validation

Sqf

Apply
params ["_target", ["_finished", true]];
_target: The plank object to process
_finished: Boolean, true for complete, false for cancel (defaults to true)
Step 2: Remove from unbuilt objects list

Sqf

Apply
A3A_unbuiltObjects deleteAt (A3A_unbuiltObjects find _target);
publicVariable "A3A_unbuiltObjects";
Searches for _target in global A3A_unbuiltObjects array
Uses find to get index, then deleteAt to remove
Important: Uses find which is position-dependent - if same object appears twice, only first occurrence removed
Publishes updated array to all clients via publicVariable
Step 3: Extract build data from plank object

Sqf

Apply
private _buildClass = _target getVariable "A3A_build_class";
private _buildDir = _target getVariable "A3A_build_dir";
private _buildPos = _target getVariable "A3A_build_pos";
private _buildPrice = _target getVariable["A3A_build_price", 10];
private _repairObj = _target getVariable["A3A_build_repairObj", objNull];
Retrieves metadata set by 
fn_placeBuilderObjects.sqf
:
_buildClass: Classname of building to spawn
_buildDir: Direction array [vectorDir, vectorUp]
_buildPos: World position
_buildPrice: Refund amount (defaults to 10)
_repairObj: If repairing, the ruined building object
Step 4: Delete the plank object

Sqf

Apply
deleteVehicle _target;
Immediate deletion of temporary construction plank
No cleanup of associated variables (they're on the plank)
Step 5: Define callback runner

Sqf

Apply
private _runCallback = {
    params[["_object", objNull, [objNull]], ["_callbackName", "", [""]], ["_params", [], [[]]]];

    if !assert(!isNull _object) exitWith {};

    if isText(configOf _object >> _callbackName) then {
        ([_object] + _params) call compile getText(configOf _object >> _callbackName);
    };

    nil;
};
Purpose: Executes callback function defined in object's config
Checks:
Assert object is not null (exits if null)
Check if config has callback: isText(configOf _object >> _callbackName)
If exists, compile and execute: ([_object] + _params) call compile getText(...)
Returns: nil (no effect on flow)
Step 6: Handle cancellation

Sqf

Apply
if (!_finished) exitWith {
    if (_buildPrice > 0) then {
        [0, _buildPrice] spawn A3A_fnc_resourcesFIA;
    };
};
If cancelled (_finished is false):
Check if price is positive
Spawn A3A_fnc_resourcesFIA to refund resources
Function receives [0, _buildPrice] - zero for resources, price for money
Note: Uses spawn which runs scheduled (suspends execution temporarily)
Step 7: Handle repair scenario

Sqf

Apply
if (!isNull _repairObj) exitWith {
    _repairObj call A3A_fnc_repairRuinedBuilding;
    [_repairObj, QGVAR(onBuildingRepaired)] call _runCallback;
};
If _repairObj is not null (repair scenario):
Call A3A_fnc_repairRuinedBuilding with the ruined building object
Run callback onBuildingRepaired on the repaired building
Exits after handling repair
Step 8: Handle normal construction

Sqf

Apply
private _building = createVehicle [_buildClass, [0,0,0], [], 0, "CAN_COLLIDE"];
_building setPosWorld _buildPos;
_building setVectorDirAndUp _buildDir;
_building setVariable ["A3A_building", true, true];
Creates building at world origin (temporary)
Sets world position from stored coordinates
Sets direction from stored vector data
Marks as A3A building with A3A_building variable (set public, JIP compatible)
Step 9: Add to save array and publish

Sqf

Apply
A3A_buildingsToSave pushBack _building;
publicVariable "A3A_buildingsToSave";
Adds to global A3A_buildingsToSave array for mission saving
Publishes to all clients (important for multiplayer persistence)
Step 10: Handle flagpole construction

Sqf

Apply
if (_className isEqualTo (A3A_faction_reb get "flag")) then {
    _building setFlagTexture (A3A_faction_reb get "flagTexture");
};
Bug note: Uses _className instead of _buildClass (typo, variable doesn't exist)
Would set flag texture if building is flagpole class
A3A_faction_reb is a global hash map from faction configuration
Step 11: Execute completion callback

Sqf

Apply
[_building, QGVAR(onBuildingCompleted)] call _runCallback;
Runs onBuildingCompleted callback from building's config if present
Step 12: Final return

Sqf

Apply
nil;
Returns nothing
Where it leads:
Functions called:

A3A_fnc_resourcesFIA - Refunds resources when construction cancelled
A3A_fnc_repairRuinedBuilding - Repairs destroyed building
runCallback - Executes config-defined callbacks
Functions that call this:

fn_addBuildingActions.sqf
 (remote) - Via hold action completion
fn_placeBuilderObjects.sqf
 - For repair scenarios
Potentially admin/debug functions
Global variables modified:

A3A_unbuiltObjects - Removed plank object
A3A_buildingsToSave - Added new building
A3A_faction_reb - Read for flag handling
Public network: Both arrays synced via publicVariable
Synchronization implications:

Critical path: Multiple publicVariable calls ensure all clients see state changes
Network traffic: Sends entire arrays (could be large for many objects)
Race conditions: Potential if multiple builders complete simultaneously (array modifications not atomic)
JIP compatibility: publicVariable ensures new clients get current state
Edge cases handled:

Cancellation refund (positive price only)
Repair scenario detection
Flag texture setting (if typo fixed)
Null object safety in callback runner
Known issues:

Bug: _className used instead of _buildClass on line 58
find for array index is position-sensitive
No validation that _target actually exists in A3A_unbuiltObjects
Function Name: fn_buildingPlacer.sqf
What it does:
Main client-side RTS-style building placer. Creates a camera, visual aids, and GUI for placing, rotating, and managing building objects. Handles real-time collision detection, surface snapping, and context-sensitive hints. Provides tools for construction, repair, and deletion.

When/Why it's called: Called from 
fn_buildingPlacerStart.sqf
 after acquiring builder box ownership. Runs in unscheduled environment but spawns the placer loop which runs scheduled.

How it does that:
Step 1: Parameter validation and early exit

Sqf

Apply
params [
    ["_centerObject", player, [objNull]],
    ["_buildingRadius", 20, [0]],
    ["_teamLeaderBox", objNull, [objNull]]
];

// Already in the placer
if(!isNil "A3A_building_EHDB") exitwith {};
Takes center object (default: player), radius (default: 20), and optional builder box
Checks if placer already active (A3A_building_EHDB exists) - exits if true
Prevents duplicate placer instances
Step 2: Initialize database

Sqf

Apply
[_centerObject, _buildingRadius, _teamLeaderBox] call A3A_fnc_initPlacerDB;
Calls fn_initPlacerDB to create A3A_building_EHDB - a large array database
Database holds all placer state (see initPlacerDB.sqf for details)
Step 3: Display UI hints layer

Sqf

Apply
("A3A_PlacerHint" call BIS_fnc_rscLayer) cutRsc ["A3A_PlacerHints", "PLAIN", -1, false];
Creates/clears hint display layer using BIS layer system
Shows UI for controls help
Step 4: Create camera

Sqf

Apply
A3A_cam = "camcurator" camCreate (position _centerObject vectorAdd [0,0,5]);
A3A_cam cameraEffect ["Internal", "top"];
player enableSimulation false;
Creates curator-type camera 5m above center object
Sets camera effect to internal (player sees from camera)
Disables player simulation (makes player stand still)
Step 5: Create bounding circle visualization

Sqf

Apply
A3A_boundingCircle = [];
for "_i" from 1 to 36 do {
    private _posStart = [_buildingRadius * (cos(10*_i)), _buildingRadius * (sin(10*_i)),0] vectorAdd getPos _centerObject;
    private _piece = "Sign_Sphere100cm_F" createVehicleLocal _posStart;
    _piece enableSimulation false;
    A3A_boundingCircle pushBack _piece;
};
Creates 36 sphere objects in circle to visualize build radius
Each sphere is local (not network-synced)
Added to A3A_boundingCircle for cleanup later
Step 6: Create UI display

Sqf

Apply
private _emptyDisplay = findDisplay 46 createDisplay "A3A_teamLeaderBuilder";
A3A_building_EHDB set [BUILD_DISPLAY, _emptyDisplay];
call (A3A_building_EHDB # UPDATE_BB);
Creates GUI display from 46 (mission display)
Stores display handle in database
Calls UPDATE_BB function (from initPlacerDB) to update building collision ray array
Step 7: Define user action event handlers

Sqf

Apply
private _userActions = [ ... ];
Array of 14 action definitions (see code for full list)
Each entry: ["actionName", "eventType", callbackCode]
Action types:
buildingPlacerAbort: Deactivate - ends placer
buildingPlacerAlign: Align object to cursor
buildingPlacerDelete: Delete selected object
buildingPlacerPlace: Place object (permanent)
buildingPlacerRepair: Repair ruined building
buildingPlacerRotateCCW/CW: Rotation mode toggle
buildingPlacerRotateStepDecrease/Increase: Change rotation step
buildingPlacerSnapToSurface: Toggle surface snapping
buildingPlacerUnsafeMode: Toggle unsafe placement
Example: Place action callback

Sqf

Apply
[
    QGVAR(buildingPlacerPlace),
    EVENT_TYPE_DEACTIVATE,
    {
        if (count (A3A_buildingsToSave) >= A3A_builderLimit) exitWith {
            ["Build Placer", format["There are too many builds. %1/%2", (count A3A_buildingsToSave), A3A_builderLimit]] call A3A_fnc_customHint;
        };

        private _tempObject = (A3A_building_EHDB # BUILD_OBJECT_TEMP_OBJECT);
        if (isObjectHidden _tempObject) exitWith {};
        if ((A3A_building_EHDB # BUILD_OBJECT_SELECTED_STRING) isEqualTo "Land_Can_V2_F") exitWith {};

        if (_tempObject distance (A3A_building_EHDB # BUILD_RADIUS_OBJECT_CENTER) > (A3A_building_EHDB # BUILD_RADIUS)) exitWith {};

        private _price = (A3A_building_EHDB # OBJECT_PRICE);
        private _supply = (A3A_building_EHDB # AVAILABLE_MONEY);

        if (_price > _supply) exitWith {};

        A3A_building_EHDB set [AVAILABLE_MONEY, _supply - _price];
        ["updateMoney"] call A3A_fnc_teamLeaderRTSPlacerDialog;

        private _position = getPosWorld _tempObject;
        private _dirAndUp = [vectorDir _tempObject, vectorUp _tempObject];

        private _vehicle = typeof _tempObject createVehicleLocal [0,0,0];
        _vehicle setPosWorld _position;
        _vehicle setVectorDirAndUp _dirAndUp;

        (A3A_building_EHDB # BUILD_OBJECT_TEMP_OBJECT_ARRAY) pushBack _vehicle;
        (A3A_building_EHDB # BUILD_OBJECTS_ARRAY) pushBack [typeof _vehicle, objNull, _position, _dirAndUp, _price];

        _tempObject hideObject true;
    }
]
Validation checks:
Build limit not exceeded
Temp object exists and not hidden
Not in placeholder mode (Land_Can_V2_F)
Within build radius
Have sufficient money
Process:
Deduct cost from available money
Update UI dialog
Capture position/direction
Create local visual copy
Add to temporary arrays (for preview and later placement)
Hide original temp object
Step 8: Register user action handlers

Sqf

Apply
A3A_building_EHDB set[USER_ACTION_EHS, _userActions apply {
    _x params["_actionName", "_eventType", "_callback"];

    [_actionName, _eventType, addUserActionEventHandler[_actionName, _eventType, _callback]];
}];
For each action, creates event handler and stores [actionName, eventType, handlerID]
addUserActionEventHandler returns ID for later removal
Stores in USER_ACTION_EHS array for cleanup
Step 9: Create main EachFrame event handler

Sqf

Apply
private _eventHanderEachFrame = addMissionEventHandler ["EachFrame", { ... }];
A3A_building_EHDB set [EACH_FRAME_EH, _eventHanderEachFrame];
Main render loop running every frame
Responsibilities:
Update object position based on mouse
Detect cursor object for context hints
Handle rotation
Apply surface snapping
Camera clamping
Collision detection
Hide/show object based on validity
Detailed breakdown of EachFrame handler:

Position/state change detection:

Sqf

Apply
private _stateChange = false;
private _object = (A3A_building_EHDB # BUILD_OBJECT_TEMP_OBJECT);
private _vehiclePos = screenToWorld getMousePosition;

if (_object distance2d _vehiclePos > 0.1) then {
    _stateChange = true;
};
Gets current mouse position in world
Checks if object moved >0.1m
Sets flag if changed
Cursor object detection:

Sqf

Apply
private _intersects = lineIntersectsSurfaces [getPosASL A3A_cam, AGLtoASL _vehiclePos, _object, A3A_cam];
private _intersectObj = if (count _intersects > 0) then { _intersects#0#3 } else { objNull };
A3A_building_EHDB set [CURSOR_OBJECT, _intersectObj];
["setContextKey", [""]] call A3A_fnc_setupPlacerHints;
Raycast from camera to mouse position
Gets first intersected object (index 3 in result)
Updates cursor object in database
Resets context hints
Ruin detection and rebuild hint:

Sqf

Apply
if (_intersectObj isKindOf "Ruins") then {
    private _ruin = _intersectObj;
    private _building = _ruin getVariable "building";
    if (isNil "_building") exitWith {};
    if (_building in antennasDead) exitWith {};
    if (-1 != (A3A_building_EHDB # BUILD_OBJECTS_ARRAY) findIf { _x#1 == _building }) exitWith {};

    private _bbsize = (boundingBoxReal _building # 1) vectorDiff (boundingBoxReal _building # 0);
    private _price = 6 * sqrt((_bbsize#0) * (_bbsize#1) * (_bbsize#2));
    _price = 10 * round (_price / 10);
    ["setContextKey", ["rebuild", _price]] call A3A_fnc_setupPlacerHints;
};
If pointing at ruin:
Get linked building (from building variable)
Skip if not rebuildable or antenna
Skip if already in build array (already rebuilding)
Calculate repair cost from bounding box volume
Round to nearest 10
Show rebuild hint with cost
Cancel hint for placed objects:

Sqf

Apply
if (_intersectObj in (A3A_building_EHDB # BUILD_OBJECT_TEMP_OBJECT_ARRAY)) then {
    ["setContextKey", ["cancel", getText (configof _intersectObj >> "displayName")]] call A3A_fnc_setupPlacerHints;
};
If cursor on temporary placed object
Show cancel hint with object name
Rotation handling:

Sqf

Apply
if ((A3A_building_EHDB # ROTATION_MODE_CW) || { A3A_building_EHDB # ROTATION_MODE_CCW }) then {
    private _multiplier = [-1, 1] select (A3A_building_EHDB # ROTATION_MODE_CW);
    private _delta = if ((A3A_building_EHDB # ROTATION_STEP) isEqualType false) then {
        diag_deltaTime * 120
    } else {
        A3A_building_EHDB set[ROTATION_MODE_CCW, false];
        A3A_building_EHDB set[ROTATION_MODE_CW, false];
        (A3A_building_EHDB # ROTATION_STEP)
    };

    private _direction = (A3A_building_EHDB # BUILD_OBJECT_TEMP_DIR) + _multiplier * _delta;
    A3A_building_EHDB set [BUILD_OBJECT_TEMP_DIR, _direction];
    _object setDir _direction;
    _stateChange = true;
};
Rotation modes:
Continuous: diag_deltaTime * 120 degrees/second
Stepped: Fixed increment (7.5, 15, 30, 45, 60, 90 degrees)
After step rotation, disables mode to prevent continuous rotation
Updates direction in database and object
Surface snapping:

Sqf

Apply
if (A3A_building_EHDB # SNAP_SURFACE_MODE) then {
    private _posASL = AGLtoASL _vehiclePos;
    private _intersects = lineIntersectsSurfaces [_posASL vectorAdd [0,0,100], _posASL vectorAdd [0,0,-100], _object];
    if (count _intersects > 0) then {
        _vehiclePos = ASLtoAGL (_intersects select 0 select 0);
    };
    _stateChange = true;
};
Raycasts up and down from mouse position
Finds surface intersection point
Adjusts placement position to surface
Camera clamping to build radius:

Sqf

Apply
private _centerPos = getPosATL (A3A_building_EHDB # BUILD_RADIUS_OBJECT_CENTER);
private _cameraPos = getPosATL A3A_cam;
private _buildRad = A3A_building_EHDB # BUILD_RADIUS;

private _camClampPos = [0,0,0];
_camClampPos set [0, _cameraPos#0 max (_centerPos#0 - _buildRad) min (_centerPos#0 + _buildRad)];
_camClampPos set [1, _cameraPos#1 max (_centerPos#1 - _buildRad) min (_centerPos#1 + _buildRad)];
_camClampPos set [2, _cameraPos#2 max (_centerPos#2 + 5) min (_centerPos#2 + _buildRad)];
A3A_cam setPosATL _camClampPos;
Constrains camera to spherical area around build center
X/Y clamped to ±radius from center
Z clamped between 5m above center and radius height
Object position and surface alignment update:

Sqf

Apply
_object setPosATL _vehiclePos;
_object setDir (A3A_building_EHDB # BUILD_OBJECT_TEMP_DIR);

private _normTotal = surfaceNormal _vehiclePos;
{
    _normTotal = _normTotal vectorAdd (surfaceNormal (_vehiclePos vectorAdd _x));
} forEach [[-2,0], [2,0], [0,-2], [0,2]];
_object setVectorUp vectorNormalized _normTotal;
Sets object position and direction
Calculates surface normal at position + 4 offset points
Averages normals and normalizes
Aligns object up vector to terrain normal
Collision detection and visibility:

Sqf

Apply
private _hide = call {
    if (_object distance (A3A_building_EHDB # BUILD_RADIUS_OBJECT_CENTER) > (A3A_building_EHDB # BUILD_RADIUS)) exitWith {true};
    if (surfaceIsWater _vehiclePos) exitWith {true};
    if (A3A_building_EHDB # UNSAFE_MODE) exitWith {false};
    if (A3A_building_EHDB # SNAP_SURFACE_MODE) exitWith {false};

    if (isNil "A3A_buildingRays") then { call (A3A_building_EHDB # UPDATE_BB) };

    -1 != A3A_buildingRays findIf {
        _x params ["_start", "_end"];
        lineIntersects [_object modelToWorldVisualWorld _start, _object modelToWorldVisualWorld _end, _object];
    };
};
_object hideObject _hide;
Hide conditions:
Outside build radius
On water
Unsafe mode disabled
Collision check: Uses 42 ray segments from A3A_buildingRays
If collision detected, hide object (red/outline visible but can't place)
Where it leads:
Functions called:

A3A_fnc_initPlacerDB - Initialize database
A3A_fnc_setupPlacerHints - Update UI hints
A3A_fnc_teamLeaderRTSPlacerDialog - Update money display
A3A_fnc_customHint - Show error messages
A3A_fnc_buildingPlacerStart - Entry point
Functions that call this:

fn_buildingPlacerStart.sqf
 - Main entry after box ownership
Potential direct calls for debug
Global variables modified:

A3A_building_EHDB - Main database
A3A_cam - Camera object
A3A_boundingCircle - Visual spheres
A3A_buildingRays - Collision rays (updated via callback)
A3A_buildingsToSave - Read for limit check
A3A_builderLimit - Read for placement limit
Synchronization/network implications:

Client-only: All operations local, no network calls
Data preparation: Only sends final array via fn_placeBuilderObjects on completion
State persistence: No network sync during placement
Potential issues: Camera/objects remain if function exits unexpectedly (need cleanup)
Edge cases handled:

Already in placer check
Water placement prevention
Rotation mode toggling
Surface normal averaging
Collision detection with 42-ray system
Camera boundary enforcement
Known issues:

Complex rotation handling could be optimized
42-ray collision is expensive (called every frame)
No recovery from crashed state (requires manual mission restart)
Function Name: fn_buildingPlacerStart.sqf
What it does:
Entry point for building placer. Validates player eligibility, checks for enemy proximity, attempts to acquire builder box ownership, and hands off to fn_buildingPlacer after successful lock acquisition.

When/Why it's called: Called from mission triggers, actions, or scripts when player wants to start building. Typically triggered by builder box interaction or team leader action.

How it does that:
Step 1: Parameter extraction

Sqf

Apply
params [
    ["_centerObject", player, [objNull]],
    ["_radius", 20, [0]],
    ["_builderBox", objNull, [objNull]]
];
private _hintTitle = localize "STR_A3A_builder_title";
Takes center object, radius, and builder box
Gets localized title for hints
Step 2: Prevent duplicate placer

Sqf

Apply
if(!isNil "A3A_building_EHDB") exitwith {};
Checks if placer already running
Exits immediately if so
Step 3: Check enemy proximity

Sqf

Apply
if ([getPosATL _centerObject] call A3A_fnc_enemyNearCheck) exitWith {
    [_hintTitle, "You can not use the placer while there are enemies nearby."] call A3A_fnc_customHint;
};
Calls A3A_fnc_enemyNearCheck to detect nearby enemies
Exits with hint if enemies present
Prevents building under fire
Step 4: Check player eligibility

Sqf

Apply
private _eligibleTL = (A3A_builderPermissions % 2 >= 0) and (typeOf player == "I_G_Soldier_TL_F");
private _eligibleEng = (A3A_builderPermissions % 4 >= 2) and (player call A3A_fnc_isEngineer);
if (!_eligibleTL and !_eligibleEng and player != theBoss) exitWith {
    [_hintTitle, "You are not eligible to use the building placer."] call A3A_fnc_customHint;
};
Permission system: A3A_builderPermissions uses modulo for flags
Bit 0 (1): Team leaders allowed
Bit 1 (2): Engineers allowed
Bit 2 (4): Both allowed
Eligibility:
TL: Permission bit 0 set AND player is team leader
Engineer: Permission bit 1 set AND player has engineer trait
Boss: Always eligible
Exits with hint if not eligible
Step 5: Acquire builder box ownership

Sqf

Apply
[_builderBox, player, true] remoteExecCall ["A3A_fnc_lockBuilderBox", 2];
Calls server function to lock box to player
true = take ownership
Server handles ownership logic and updates box variables
Step 6: Wait for ownership confirmation

Sqf

Apply
private _timeout = time + 5;
private _owner = objNull;
waitUntil {
    sleep 0.1;
    _owner = _builderBox getVariable ["A3A_build_owner", objNull];
    time > _timeout or alive _owner
};
Polls every 0.1s for 5 seconds
Checks if box now has owner and owner is alive
Race condition mitigation: Multiple players may try to lock same box
Timeout: Server might be busy, give up after 5s
Step 7: Validate ownership and start placer

Sqf

Apply
isNil {
    if (time > _timeout) exitWith {
        [_hintTitle, "Server failed to respond to building placer request."] call A3A_fnc_customHint;
    };
    if (alive _owner and _owner != player) exitWith {
        [_hintTitle, format ["Builder box is already being used by %1", name _curOwner]] call A3A_fnc_customHint;
    };

    // Have box ownership so start the placer
    _this call A3A_fnc_buildingPlacer;
};
isNil block for atomic execution
Failure cases:
Timeout: Server didn't respond
Wrong owner: Another player grabbed box faster
Success: Calls fn_buildingPlacer with original parameters
Where it leads:
Functions called:

A3A_fnc_enemyNearCheck - Detect enemies
A3A_fnc_isEngineer - Check engineer trait
A3A_fnc_lockBuilderBox (remote) - Acquire box ownership
A3A_fnc_customHint - Show messages
A3A_fnc_buildingPlacer - Main placer function
Functions that call this:

Mission triggers/actions (builder box interaction)
Direct script calls
Possibly admin commands
Global variables read:

A3A_building_EHDB - Check if placer active
A3A_builderPermissions - Check permissions
theBoss - Check boss eligibility
A3A_buildingsToSave - Not directly, but through placer
Synchronization/network implications:

Remote call: remoteExecCall to server for box lock
Race condition: Window between lock request and confirmation where another player could grab box
No direct sync: Player state changes (eligibility) are local
Edge cases handled:

Duplicate placer prevention
Enemy proximity check
Permission system with mod 2/4 logic
Timeout handling
Ownership validation
Known issues:

No feedback during 5s wait (could be improved)
If server is laggy, timeout might occur falsely
Box might be locked but A3A_build_owner not yet updated (timing)
Function Name: fn_handlerTerrainManipulator.sqf
What it does:
Post-init handler for terrain manipulator base builder objects. Processes action properties from config and executes appropriate terrain functions (cleaning, smoothing, hiding) for the object.

When/Why it's called: Called during mission initialization for objects with A3U_HelipadTerrainSmoothing enabled, or during base build completion for terrain manipulator objects.

How it does that:
Step 1: Parameter validation

Sqf

Apply
params[ ["_object", objNull, [objNull]] ];
if !assert(!isNull _object) exitWith {};
Takes single object parameter
Asserts object is not null, exits if null
Step 2: Read configuration

Sqf

Apply
private _properties = configOf _object >> QGVAR(Properties);
private _actions = getArray(_properties >> "actions");
Gets object's config path
Reads actions array from properties (e.g., ["terrainCleaner", "terrainSmoother", "hideObject"])
QGVAR(Properties) is macro for A3U_Properties
Step 3: Conditional experimental smoothing

Sqf

Apply
if (A3U_HelipadTerrainSmoothing && { "terrainSmootherExperimental" in _actions }) then {
    _actions pushBack "terrainSmoother";
};
If experimental smoothing is enabled globally AND object requests experimental
Add regular terrainSmoother to actions list
Purpose: Compatibility for experimental terrain smoothing
Step 4: Process terrain cleaning

Sqf

Apply
if ("terrainCleaner" in _actions) then {
    [_object, getNumber(_properties >> "cleanRadius"), getArray(_properties >> "cleanTerrainTypes")] call A3A_fnc_terrainCleaner;
};
If terrainCleaner in actions:
Get cleanRadius (number)
Get cleanTerrainTypes (array of terrain types)
Call fn_terrainCleaner with object, radius, types
Step 5: Process terrain smoothing

Sqf

Apply
if ("terrainSmoother" in _actions) then {
    getArray(_properties >> "smoothRadius") params[
        ["_mainZoneRadius", 0, [0]],
        ["_smoothingZoneRadius", 0, [0]]
    ];
    [_object, _mainZoneRadius, _smoothingZoneRadius] call A3A_fnc_terrainSmoother;
};
If terrainSmoother in actions:
Get smoothRadius array [mainZone, smoothingZone]
Extract with default 0
Call fn_terrainSmoother with both radii
Step 6: Process object hiding

Sqf

Apply
if ("hideObject" in _actions) then {
    _object hideObjectGlobal true;
    _object enableSimulationGlobal false;
};
If hideObject in actions:
Hide object globally (visible to all clients)
Disable simulation globally
Note: Uses Global variants for multiplayer sync
Where it leads:
Functions called:

A3A_fnc_terrainCleaner - Hides terrain objects
A3A_fnc_terrainSmoother - Modifies terrain height
Functions that call this:

Mission initialization scripts
Base builder completion handlers
Possibly fn_lockBuilderBox or fn_placeBuilderObjects for terrain manipulators
Global variables read:

A3U_HelipadTerrainSmoothing - Global flag for experimental smoothing
Synchronization/network implications:

Global operations: hideObjectGlobal and enableSimulationGlobal sync to all clients
Terrain changes: Smoothing uses setTerrainHeight which is server-authoritative and synced
Edge cases handled:

Null object check
Missing config values (defaults to 0/empty array)
Experimental smoothing toggle
Known issues:

Dependent on A3U_HelipadTerrainSmoothing global (not in provided code)
Config structure must be precise
Function Name: fn_handlerTerrainObjectHiderPostInitClient.sqf
What it does:
Client-side post-init handler for terrain object hider base buildable objects. Creates visual preview shapes (ellipses/rectangles) for terrain hiders during building placement, using attached sphere objects.

When/Why it's called: Called during mission init for terrain hider objects, or during building placer when such objects are placed.

How it does that:
Step 1: Parameter validation and client check

Sqf

Apply
params[ ["_object", objNull, [objNull]] ];
if !assert(!isNull _object) exitWith {};
if !(local _object) exitWith {};
Takes object parameter
Exits if null
Important: Only runs if object is local to this client (not synced across network)
Step 2: Check if in placer preview

Sqf

Apply
if (isNil "A3A_building_EHDB") exitWith {};
Exits if A3A_building_EHDB doesn't exist
Purpose: Only create preview if in building placer mode
Step 3: Check if temporary object

Sqf

Apply
if (_object getVariable[QGVAR(isTempObject), false]) exitWith {};
Exits if object has isTempObject variable set to true
Only creates preview for permanent objects
Step 4: Wait for object creation, then create preview

Sqf

Apply
[{
    params[["_object", objNull, [objNull]]];

    if (_object getVariable[QGVAR(isTempObject), false]) exitWith {};

    private _config = configOf _object >> QGVAR(Properties);
    private _shape = getText(_config >> "previewShape");
    private _balls = switch (_shape) do {
        case "ellipse": {
            private _radiusX = getNumber(_config >> "previewWidth");
            private _radiusY = getNumber(_config >> "previewHeight");
            private _points = [];

            for "_angle" from 0 to 360 step 20 do {
                _points pushBack[_radiusX * cos (_angle), _radiusY * sin (_angle), 0];
            };

            _points;
        };

        case "rectangle": {
            private _width = getNumber(_config >> "previewWidth");
            private _height = getNumber(_config >> "previewHeight");
            [
                [-_width / 2, -_height / 2, 0],
                [0, -_height / 2, 0],
                [_width / 2, -_height / 2, 0],
                [_width / 2, 0, 0],
                [_width / 2, _height / 2, 0],
                [0, _height / 2, 0],
                [-_width / 2, _height / 2, 0],
                [-_width / 2, 0, 0]
            ];
        };

        default {
            Error_2("Unknown shape %1 for map object hider %2",_shape,typeOf _object);
            [];
        };
    };

    if !assert(_balls isNotEqualTo []) exitWith {};

    _balls apply {
        private _offset = _x;
        private _ball = "Sign_Sphere10cm_F" createVehicleLocal[0,0,0];
        _ball attachTo[_object, _offset vectorAdd[0,0,1]];
        A3A_boundingCircle pushBack _ball;
    };
}, _this, 0.5] call CBA_fnc_waitAndExecute;
Delayed execution: Uses CBA wait-and-execute for 0.5s delay
Purpose: Ensures object is fully created before attaching preview
Shape generation:
Ellipse: 18 points around circumference (20° steps)
Rectangle: 8 corner points
Error handling: Logs unknown shapes
Sphere creation:
Creates Sign_Sphere10cm_F for each point
Attaches to object with 1m vertical offset
Adds to A3A_boundingCircle for cleanup
Where it leads:
Functions called:

CBA_fnc_waitAndExecute - Delayed execution
Functions that call this:

Mission initialization for terrain hider objects
Building placer when objects are created
Global variables:

A3A_boundingCircle - Pushes preview spheres for later cleanup
A3A_building_EHDB - Checked for existence
Synchronization/network implications:

Client-only: All operations local
No network calls: Preview is local visualization
Cleanup: Spheres added to bounding circle for deletion when placer ends
Edge cases handled:

Null object check
Local object check
Temporary object skip
Delayed execution for object stability
Shape validation
Known issues:

Depends on CBA mod for wait-and-execute
If object deleted before 0.5s, spheres will still spawn at origin
No error recovery if config missing
Function Name: fn_initBuildableObjects.sqf
What it does:
Client-side function that initializes the list of buildable objects from map-specific configuration. Populates global A3A_buildableObjects array for use by building placer.

When/Why it's called: Called during mission initialization, typically by fn_buildingPlacer or directly by builders when they open the placer.

How it does that:
Step 1: Locate map configuration

Sqf

Apply
private _mapInfo = missionConfigFile/"A3A"/"mapInfo"/toLower worldName;
if (!isClass _mapInfo) then {_mapInfo = configFile/"A3A"/"mapInfo"/toLower worldName};
First checks mission config: missionConfigFile/A3A/mapInfo/[worldName]
If not found, checks global config: configFile/A3A/mapInfo/[worldName]
Converts world name to lowercase for consistency
Step 2: Read buildable objects array

Sqf

Apply
A3A_buildableObjects = getArray (_mapInfo/"buildObjects");
Reads buildObjects array from config
Stores in global variable
Expected format: Array of classnames or object data
Where it leads:
Functions called:

None
Functions that call this:

Mission initialization
fn_buildingPlacer (indirectly via direct call)
Builder UI scripts
Global variables:

A3A_buildableObjects - Populated with array
worldName - Read for config lookup
Synchronization/network implications:

Client-only: Each client runs independently
No network: Config read is local
Consistency: All clients read same config if mission/config is consistent
Edge cases handled:

Missing mission config falls back to global config
Case-insensitive world name handling
Known issues:

No validation of array contents
No default if config missing entirely
No cache mechanism (re-reads every time called)
Function Name: fn_initBuilderMonitors.sqf
What it does:
Client-side spawned function that sets up continuous monitoring for builders. Adds 3D icons for under-construction objects and continuously monitors cursor object to add deconstruction actions to built structures.

When/Why it's called: Spawned during client initialization, runs indefinitely. Only active for engineers.

How it does that:
Step 1: Delay and eligibility check

Sqf

Apply
Info("initBuilderMonitors started");
uiSleep 10;
if !(player call A3A_fnc_isEngineer) exitWith { Info("initBuilderMonitors: Player is not an engineer, exiting"); };
Info("initBuilderMonitors starting handlers");
Waits 10 seconds for player traits to initialize
Checks if player is engineer
Exits if not (non-engineers don't need monitors)
Logs progress
Step 2: Add 3D draw icon event handler

Sqf

Apply
A3A_buildDrawIconsEH = addMissionEventHandler ["Draw3D", {
    {
        private _normalizedDistance = 1 - ((_x distance player) / 100);
        _normalizedDistance = 0 max _normalizedDistance;
        _normalizedDistance = 1 min _normalizedDistance;
        drawIcon3D [
            "\A3\ui_f\data\map\markers\handdrawn\objective_CA.paa",
            [1,0,0,_normalizedDistance],
            getPosATLVisual _x vectorAdd [0,0,2],
            1,1,0,
            _x getVariable "A3A_build_name",
            2,0.06,"RobotoCondensedLight"
        ];
    } forEach (A3A_unbuiltObjects inAreaArray [getPosATL player, 150, 150]);
}];
3D icon loop: Runs every frame
Filter: Finds unbuilt objects within 150m radius of player
Icon details:
Red color (RGBA)
Transparency based on distance (0=opaque at 0m, invisible at 100m+)
Positioned 2m above object
Shows object name (A3A_build_name variable)
Uses RobotoCondensedLight font
Stores handler ID: A3A_buildDrawIconsEH
Step 3: Continuous cursor object monitor loop

Sqf

Apply
while { true } do {
    if (isNil { cursorObject getVariable "A3A_building" }) then { sleep 1; continue };
    if (!isNil { cursorObject getVariable "A3A_build_removeAction" }) then { sleep 1; continue };

    Debug_1("Adding remove action for item %1", cursorObject);
    cursorObject setVariable ["A3A_build_removeAction", true];
    [
        cursorObject,
        "Destroy",
        "a3\ui_f\data\igui\cfg\actions\repair_ca.paa",
        "a3\ui_f\data\igui\cfg\actions\repair_ca.paa",
        "isNull objectParent player",
        "[player] call A3A_fnc_canFight",
        {},
        {},
        {
            // refund? Nah
            deleteVehicle (_this#0);
        },
        {},
        [],
        10,
        -100
    ] call BIS_fnc_holdActionAdd;
};
Infinite loop (spawned, so won't block)
Checks every 1 second when no cursor object
Conditions to add action:
Cursor object has A3A_building variable (is A3A building)
Cursor object doesn't already have A3A_build_removeAction flag
Action specification:
Title: "Destroy"
Condition: Dismounted (isNull objectParent player)
Success condition: Able to fight ([player] call A3A_fnc_canFight)
On completion: Deletes vehicle (no refund)
Hold time: 10 seconds
Priority: -100 (very low priority)
Marks action added: Sets A3A_build_removeAction to prevent duplicates
Where it leads:
Functions called:

A3A_fnc_isEngineer - Check eligibility
A3A_fnc_canFight - Action success condition
BIS_fnc_holdActionAdd - Creates destroy action
Functions that call this:

Client initialization scripts
Potentially engineer trait change handlers
Global variables read:

A3A_unbuiltObjects - Read for 3D icons
cursorObject - Built-in engine variable
Synchronization/network implications:

Local only: All operations client-side
No network calls: Draw3D is local rendering
Action execution: DeleteVehicle is local (object is local to builder, but deleting is synced)
Edge cases handled:

Non-engineer check (exits early)
150m radius limit for icons
Action deduplication flag
Sleep in loop to prevent CPU overuse
Known issues:

while {true} loop runs indefinitely (can't be stopped)
No cleanup of A3A_buildDrawIconsEH on death/disconnect
3D icons may stack if multiple builders on same mission
No visibility distance culling (all within 150m show)
Function Name: fn_initPlacerDB.sqf
What it does:
Database constructor for the RTS placer. Creates and populates the A3A_building_EHDB array with all state variables, callback functions, and configuration for the building placer system.

When/Why it's called: Called from fn_buildingPlacer to initialize the placer state before creating UI and camera.

How it does that:
Step 1: Parameter extraction

Sqf

Apply
params [
    ["_buildCenter", player, [objNull]],
    ["_buildRadius", 20,[0]],
    ["_teamLeaderBox", objNull, [objNull]]
];
Takes center object, radius, and builder box
Defaults: player center, 20m radius, no box
Step 2: Create database array

Sqf

Apply
A3A_building_EHDB = [ ... ];
Large array with ~30 elements
Each element accessed by index or named constants (from placerDefines.hpp)
Database structure (indices):

0: ROTATION_STEP

Sqf

Apply
false,
false = continuous rotation (uses diag_deltaTime)
number = step rotation (7.5, 15, 30, 45, 60, 90 degrees)
1: ROTATION_MODE_CW

Sqf

Apply
false,
Boolean: clockwise rotation active
2: ROTATION_MODE_CCW

Sqf

Apply
false,
Boolean: counter-clockwise rotation active
3: GUI_BUTTON_PRESSED

Sqf

Apply
false,
Boolean: tracks UI button presses for state update
4: UNSAFE_MODE

Sqf

Apply
false,
Boolean: allows building anywhere (no collision checks)
5: BUILD_OBJECTS_ARRAY

Sqf

Apply
[],
Array of placed objects data: [classname, repairObj, position, direction, price]
6: BUILD_OBJECT_SELECTED_STRING

Sqf

Apply
"Land_Can_V2_F",
Currently selected buildable object classname
Default placeholder "Land_Can_V2_F" means nothing selected
7: BUILD_OBJECT_TEMP_OBJECT

Sqf

Apply
"Land_Can_V2_F" createVehicleLocal [0,0,0],
Live preview object (follows mouse)
Initially placeholder, replaced when selection changes
8: BUILD_OBJECT_TEMP_OBJECT_ARRAY

Sqf

Apply
[],
Array of temporary placed objects (preview only, not saved)
For objects placed during current session
9: END_BUILD_FUNC

Sqf

Apply
{
    private _remMoney = (A3A_building_EHDB # AVAILABLE_MONEY);
    [A3A_building_EHDB # TEAMLEADER_BOX, player, false, _remMoney] remoteExecCall ["A3A_fnc_lockBuilderBox", 2];
    {deleteVehicle _x} forEach A3A_boundingCircle;
    {deleteVehicle _x} forEach (A3A_building_EHDB # BUILD_OBJECT_TEMP_OBJECT_ARRAY);
    {
        _x params["_actionName", "_eventType", "_ehID"];
        removeUserActionEventHandler[_actionName, _eventType, _ehID];
    } forEach (A3A_building_EHDB # USER_ACTION_EHS);
    removeMissionEventHandler ["EachFrame", (A3A_building_EHDB # EACH_FRAME_EH)];
    (A3A_building_EHDB # BUILD_DISPLAY) closeDisplay 1;
    A3A_cam cameraEffect ["terminate", "back"];
    camDestroy A3A_cam;
    deleteVehicle (A3A_building_EHDB # BUILD_OBJECT_TEMP_OBJECT);
    ("A3A_PlacerHint" call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
    private _params = (A3A_building_EHDB # BUILD_OBJECTS_ARRAY);
    A3A_buildingRays = nil;
    A3A_building_EHDB = nil;
    player enableSimulation true;
    [_params] remoteExecCall ["A3A_fnc_placeBuilderObjects", 2];
},
Cleanup function: Called when placer ends (abort or complete)
Steps:
Release builder box ownership (remote call)
Delete bounding circle spheres
Delete temporary objects
Remove user action event handlers
Remove eachFrame handler
Close GUI display
Destroy camera and terminate effect
Delete preview object
Clear hint layer
Save placed objects array to variable
Clean up globals
Restore player simulation
Remote call to server to create objects
10: BUILD_DISPLAY

Sqf

Apply
-1,
Display handle (filled later in fn_buildingPlacer)
11: USER_ACTION_EHS

Sqf

Apply
[],
Array of [actionName, eventType, handlerID] for cleanup
12: ROTATION_STEP_FUNC

Sqf

Apply
{
    params[["_direction", 1, [0]]];

    private _steps = [7.5, 15, 30, 45, 60, 90];
    private _stepping = A3A_building_EHDB # ROTATION_STEP;
    private _newIndex = if (_stepping isEqualType false) then {
        [0, count(_steps) - 1] select (_direction < 0);
    } else {
        private _index = (_steps find _stepping) + _direction;
        [_index, false] select (_index < 0 || { _index >= count _steps });
    };

    if (_newIndex isEqualType false) exitWith {
        A3A_building_EHDB set [ROTATION_STEP, false];
        systemChat "Rotation stepping disabled";
    };

    A3A_building_EHDB set [ROTATION_STEP, _steps#_newIndex];
    systemChat format["Rotation step set to %1°", _steps#_newIndex];
},
Rotation step controller:
_direction: 1 for increase, -1 for decrease
Cycles through step values: 7.5° to 90°
If at max, toggles to false (continuous)
If at min with negative direction, toggles to false
Shows systemChat messages
13: EACH_FRAME_EH

Sqf

Apply
-1,
EachFrame handler ID (filled later)
14: UPDATE_BB

Sqf

Apply
{
    private _bb = (0 boundingBoxReal (A3A_building_EHDB # BUILD_OBJECT_TEMP_OBJECT));
    private _back = (_bb#0#1);
    private _front = (_bb#1#1);
    private _top = (_bb#1#2);
    private _left = (_bb#0#0);
    private _right = (_bb#1#0);
    private _bottom = (_bb#0#2) + 0.2;
    private _knee = _bottom + 0.5;
    A3A_buildingRays = [
    // ... 42 ray segments ...
    ];
},
Update collision rays: Called when preview object changes or first time
Calculates bounding box of preview object
Creates 42 ray segments for collision detection:
8 outer box edges
8 inner lines
8 knee-level checks
8 center checks
Stored in: A3A_buildingRays global
15: BUILD_RADIUS_OBJECT_CENTER

Sqf

Apply
_buildCenter,
Object to center placement around
16: BUILD_RADIUS

Sqf

Apply
_buildRadius,
Maximum placement distance from center
17: HOLD_TIME

Sqf

Apply
15,
Unused default hold time
18: OBJECT_PRICE

Sqf

Apply
0,
Current object's price (updated when selection changes)
19: BUILD_OBJECT_TEMP_DIR

Sqf

Apply
0,
Current rotation of preview object
20: TEAMLEADER_BOX

Sqf

Apply
_teamLeaderBox,
Builder box object reference
21: ELEVATION_MODE_UP

Sqf

Apply
false,
Unused elevation mode
22: ELEVATION_MODE_DOWN

Sqf

Apply
false,
Unused elevation mode
23: SNAP_SURFACE_MODE

Sqf

Apply
false,
Surface snapping mode toggle
24: AVAILABLE_MONEY

Sqf

Apply
_teamLeaderBox getVariable ["A3A_build_money", 0],
Money available for building (from box variable)
25: CURSOR_OBJECT

Sqf

Apply
objNull
Currently cursor-hovered object (for context hints)
Where it leads:
Functions called:

None (pure data creation)
Functions that call this:

fn_buildingPlacer - Main entry point
fn_buildingPlacerStart (indirectly)
Global variables:

A3A_building_EHDB - Main database created
A3A_buildingRays - Updated by UPDATE_BB
Synchronization/network implications:

Client-only: Database is client-local
No network: All state local to placer session
Data persistence: Only finalized via placeBuilderObjects remote call
Edge cases handled:

Default values for all parameters
Null object handling (via createVehicleLocal of placeholder)
Known issues:

HOLD_TIME, ELEVATION_MODE_* are unused (dead code)
TEAMLEADER_BOX might be null if no box used
Database is large (~30 elements) but manageable
Function Name: fn_lockBuilderBox.sqf
What it does:
Server-side function to take or release ownership of a builder box. Manages box state, publishes ruin-building links for nearby destroyed buildings, and handles money transfer. Deletes box if money reaches zero on release.

When/Why it's called: Called by fn_buildingPlacerStart (remote) to lock box before starting placer, and by fn_buildingPlacer (via END_BUILD_FUNC) to release box when done.

How it does that:
Step 1: Parameter extraction

Sqf

Apply
params ["_box", "_player", "_take", "_money"];
_box: Builder box object
_player: Player unit to own/release
_take: Boolean - true = take ownership, false = release
_money: Money remaining (only used on release)
Step 2: Get current owner

Sqf

Apply
private _curOwner = _box getVariable "A3A_build_owner";
Retrieves current owner from box variable
Step 3: Take ownership

Sqf

Apply
if (_take) then {
    if (!isNil "_curOwner" and { alive _curOwner }) exitWith {
        Debug("Builder box already has a valid owner");
    };

    // Publish ruin->building link for nearby buildings
    private _nearBuildings = destroyedBuildings inAreaArray [getPosATL _box, 100, 100];
    {
        private _ruin = _x getVariable ["ruins", objNull];
        if (isNull _ruin) then { _ruin = _x getVariable ["BIS_fnc_createRuin_ruin", objNull] };
        if (isNull _ruin) then { continue };
        _ruin setVariable ["building", _x, owner player];
    } forEach _nearBuildings;

    private _money = _box getVariable ["A3A_itemPrice", 0];
    _box setVariable ["A3A_itemPrice", 0, true];
    _box setVariable ["A3A_build_money", _money, true];
    _box setVariable ["A3A_build_owner", _player, true];
Check for existing owner: If owner exists and is alive, exit with debug
Ruin linking:
Find destroyed buildings within 100m of box
For each, get ruin object from two possible variable names
If ruin exists, set building variable on ruin (public)
Purpose: Allows repair system to know which ruin belongs to which building
Money transfer:
Get A3A_itemPrice from box (price paid for box)
Set A3A_itemPrice to 0 (box now owned)
Set A3A_build_money to original price (available for building)
Public: All variables set public (synced to clients)
Step 4: Release ownership

Sqf

Apply
} else {
    if (isNil "_curOwner" or { _player != _curOwner }) exitWith {
        Error("Attempted to release builder box by player who wasn't controlling it");
    };
    if (_money <= 0) exitWith { deleteVehicle _box };

    _box setVariable ["A3A_itemPrice", _money, true];
    _box setVariable ["A3A_build_owner", nil, true];
};
Validate: Player must be current owner
Empty box: If money ≤ 0, delete the box entirely
Refund money: Store remaining money in A3A_itemPrice
Release ownership: Clear A3A_build_owner (set to nil)
Public: All variables synced
Where it leads:
Functions called:

None (direct variable manipulation)
Functions that call this:

fn_buildingPlacerStart (remote) - Take ownership
fn_buildingPlacer (via END_BUILD_FUNC) - Release ownership
Global variables:

destroyedBuildings - Read for nearby ruins
Box variables: A3A_build_owner, A3A_build_money, A3A_itemPrice
Synchronization/network implications:

Server-only execution: Must run on server for owner player and global vars
Public variables: All box variables are public (synced to all clients)
Ruin linking: ruin setVariable ["building", _x, owner player] ensures ruin is owned by player's client (important for local-only effects)
Deletion: deleteVehicle is server-authoritative and synced
Edge cases handled:

Existing owner check
Owner validation on release
Empty box deletion
Ruin variable name fallback (ruins vs BIS_fnc_createRuin_ruin)
Known issues:

Race condition possible: Two players could lock same box if server lags
No timeout on ownership (box locked indefinitely)
destroyedBuildings might be empty if not maintained
Function Name: fn_placeBuilderObjects.sqf
What it does:
Server-side function that creates construction planks from the builder's placement array. Each plank is a temporary object that players can interact with to complete construction. Planks are added to global A3A_unbuiltObjects for tracking and timeout cleanup.

When/Why it's called: Called from fn_buildingPlacer when placer ends (abort/complete). Receives the array of objects placed during session.

How it does that:
Step 1: Parameter extraction

Sqf

Apply
params [["_objects",[],[[]]]];
Takes array of objects to place
Each object is [classname, repairObj, position, direction, price]
Step 2: Define plank price thresholds

Sqf

Apply
private _constructionObjects = [
    ["Land_WoodenBox_F", 50],
    ["Land_WoodenBox_02_F", 100],
    ["Land_WoodenCrate_01_stack_x5_F", 250],
    ["Land_PaperBox_closed_F", 400],
    ["Land_WoodenCrate_01_F", 999999]
];
Plank object mapping: Price determines which plank to use
≤50: Single wooden box
≤100: Double box
≤250: Stacked crates
≤400: Paper box
400: Large crate

999999 is effectively unlimited (no object >400 cost)
Step 3: Process each object

Sqf

Apply
{
    _x params ["_className", "_repairObj", "_position", "_direction", "_price"];

    private _plankIndex = _constructionObjects findIf { _price <= _x#1 };
    private _plankClass = _constructionObjects # _plankIndex # 0;
    private _planks = createVehicle [_plankClass, [0,0,0], [], 0, "CAN_COLLIDE"];
    _planks setVariable ["A3A_build_timeout", time + 1200];
    _planks setVariable ["A3A_build_price", _price];
Find plank type: Uses findIf to locate first plank with price ≥ object price
Create plank: Spawns at origin, collides
Set timeout: 1200 seconds = 20 minutes
Store price: For refund on cancellation
Step 4: Construction vs repair logic

Sqf

Apply
private _buildName = getText (configFile / "CfgVehicles" / _className / "displayName");
if (isNull _repairObj) then
{
    // Construction, create planks on spot
    private _emptyPosition = ([_position#0, _position#1, 0] findEmptyPosition [0, 50, _plankClass]);
    if(_emptyPosition isNotEqualTo []) then { _planks setPos _emptyPosition; } else { _planks setPos _position; };
    _planks setDir random 360;

    _planks setVariable ["A3A_build_pos", _position];
    _planks setVariable ["A3A_build_dir", _direction];
    _planks setVariable ["A3A_build_class", _className];
    _buildName = "Build " + _buildName;
}
else
{
    // Repair, create planks nearby
    _position = getPosATL _repairObj findEmptyPosition [0, 50, _plankClass];
    if (_position isEqualTo []) then { _position = _repairObj getPos [10, random 360] };
    _planks setPosATL _position;

    _planks setVariable ["A3A_build_repairObj", _repairObj];
    _buildName = "Repair " + _buildName;
};
Construction:
Find empty position near target (50m search)
Fall back to exact position if none found
Random direction (not aligned)
Store position, direction, class
Prefix name with "Build"
Repair:
Find empty position near ruined building
Fall back to 10m random offset
Store repair object reference
Prefix name with "Repair"
Step 5: Set visual name and add to unbuilt list

Sqf

Apply
_planks setVariable ["A3A_build_name", _buildName, true];
A3A_unbuiltObjects pushBack _planks;
Set public variable for 3D icons
Add to global A3A_unbuiltObjects array
Step 6: Add client actions

Sqf

Apply
private _holdTime = (A3A_builderBuildTime / 10) * sqrt _price;
[_planks, _holdTime] remoteExecCall ["A3A_fnc_addBuildingActions", 0, _planks];
Hold time calculation: (builder time / 10) * sqrt(price)
Example: If A3A_builderBuildTime = 30, price = 100 → 30/10 * 10 = 30s hold
sqrt reduces time for expensive objects
Remote execution: Calls fn_addBuildingActions on all clients (JIP-compatible via object attachment)
Step 7: Publish unbuilt objects

Sqf

Apply
publicVariable "A3A_unbuiltObjects";
Syncs array to all clients for 3D icons and timeout checks
Where it leads:
Functions called:

A3A_fnc_addBuildingActions (remote) - Adds actions to planks
A3A_fnc_resourcesFIA (indirect via timeout) - Refund on timeout
Functions that call this:

fn_buildingPlacer (via END_BUILD_FUNC) - Main entry point
Global variables read:

A3A_unbuiltObjects - Modified (pushBack)
A3A_builderBuildTime - Used for hold time calculation
destroyedBuildings - Not used directly
Synchronization/network implications:

Server execution: Creates objects on server
Public variable: A3A_unbuiltObjects synced to all clients
Remote execution: Actions added to all clients with JIP support
Network load: One publicVariable per placement session (batched)
Edge cases handled:

Empty position search with fallback
Random direction for construction
Repair position near ruined building
Hold time calculation with sqrt
Timeout variable set
Known issues:

findEmptyPosition could fail in dense areas (fallback to exact position)
Random direction might not be ideal (could align to terrain)
No validation of _className existence
Plank type mapping is arbitrary (price-based, not semantic)
Function Name: fn_processBuildingTimeouts.sqf
What it does:
Server-side function that cleans up unbuilt construction planks that have exceeded their timeout period (20 minutes). Refunds resources for timed-out constructions and removes them from tracking arrays.

When/Why it's called: Called periodically by the mission resource check loop (e.g., resourceCheckSkipTime or similar timer).

How it does that:
Step 1: Atomic execution with isNil

Sqf

Apply
isNil {
    private _unbuiltObjectsChanged = false;
Uses isNil block to ensure atomic execution
Prevents race conditions with fn_buildingComplete (which also modifies A3A_unbuiltObjects)
Tracks if any objects were removed to decide on publicVariable
Step 2: Iterate through unbuilt objects

Sqf

Apply
{
    private _object = _x;
    if (time <= _object getVariable ["A3A_build_timeout", 0]) then { continue };

    // refund? Arguable
    private _price = _object getVariable ["A3A_build_price", 0];
    if (_price >= 0) then { [0, _price] spawn A3A_fnc_resourcesFIA; };

    // remove the object from the list
    A3A_unbuiltObjects deleteAt _forEachIndex;
    _unbuiltObjectsChanged = true;
    deleteVehicle _object;

} forEachReversed A3A_unbuiltObjects;
Checks timeout: If current time > timeout time
Refund resources: Spawns A3A_fnc_resourcesFIA with [0, _price]
Note: Uses spawn which runs scheduled
Remove from array: Uses forEachReversed to avoid index shift issues during deletion
Mark changed: Sets flag if any deletions occurred
Delete object: Remove plank from game
Step 3: Publish if changed

Sqf

Apply
if (_unbuiltObjectsChanged) then { publicVariable "A3A_unbuiltObjects" };
Syncs updated array to all clients
Only publishes if there were changes (optimization)
Where it leads:
Functions called:

A3A_fnc_resourcesFIA (spawned) - Refund resources
Functions that call this:

Mission resource check loop (e.g., resourceCheckSkipTime)
Possibly admin/debug commands
Global variables:

A3A_unbuiltObjects - Read and modified
time - Built-in mission time
Synchronization/network implications:

Server execution: Runs on server
Public variable: publicVariable if changes occur
Resource refund: Spawns scheduled function (async)
Race condition: Protected by isNil block
Edge cases handled:

forEachReversed prevents index shifting during deletion
Timeout default 0 if variable missing
Negative price check before refund
Only publish if changes occurred
Known issues:

Refund uses spawn which is non-deterministic timing
No cleanup of plank if object already deleted (try/catch not present)
Could be called frequently, creating many spawn threads
Function Name: fn_terrainCleaner.sqf
What it does:
Server-side function that hides and disables simulation for terrain objects (trees, rocks, etc.) within a radius around an object. Used to "clean" terrain for building placement.

When/Why it's called: Called from fn_handlerTerrainManipulator when terrainCleaner action is present in object config.

How it does that:
Step 1: Parameter extraction

Sqf

Apply
params [
  ["_object", objNull, [objNull]],
  ["_radius", 0, [0]],
  ["_terrainTypes", [], [[]]]
];
Takes object, radius, and array of terrain object types to hide
Step 2: Find and process terrain objects

Sqf

Apply
{
    [_x, true] remoteExec ["hideObject", 0, true];
    _x enableSimulationGlobal false;
} forEach nearestTerrainObjects [getPos _object, _terrainTypes, _radius, false, true];
Find objects: nearestTerrainObjects with:
Center: getPos _object
Types: _terrainTypes (e.g., ["TREE", "BUSH", "ROCK"])
Radius: _radius
false: Don't exclude objects behind walls
true: Sort by distance
Hide object: hideObject remote executed to all clients (0 = all, true = JIP)
Disable simulation: enableSimulationGlobal to all clients
Note: forEach executes for each found terrain object
Where it leads:
Functions called:

None (direct engine commands)
Functions that call this:

fn_handlerTerrainManipulator - When action present
Global variables:

None modified
Synchronization/network implications:

Server execution: Must run on server for global commands
Network traffic: One remoteExec per terrain object
Global effects: All clients see hidden objects
Performance: Could be expensive with many objects in radius
Edge cases handled:

Null object check (in caller)
Empty terrain types array (no objects found)
Radius 0 (only immediate area)
Known issues:

remoteExec per object is inefficient (could batch)
No error handling if terrain object doesn't exist
Hiding is permanent for mission duration
Function Name: fn_terrainSmoother.sqf
What it does:
Server-side function that modifies terrain height to create flat areas for building. Uses two zones: main zone (completely flattened) and smoothing zone (gradual transition).

When/Why it's called: Called from fn_handlerTerrainManipulator when terrainSmoother action is present in object config.

How it does that:
Step 1: Parameter extraction

Sqf

Apply
params [
    ["_object", objNull, [objNull]],
    ["_radius", 0, [0]],
    ["_smoothingRadius", 0, [0]]
];
Takes object, main flatten radius, and smoothing radius (must be > main radius)
Step 2: Calculate terrain parameters

Sqf

Apply
private _center = getPos _object;
private _targetHeight = getTerrainHeightASL _center;
private _gridSize = getTerrainInfo #2;
Get object's position
Target height is current terrain height at center (ASL)
Grid size from terrain info (resolution)
Step 3: Optimization - pre-calculate coordinates

Sqf

Apply
private _centerX = _center select 0;
private _centerY = _center select 1;
Extract X/Y once for performance
Step 4: Define chunking function

Sqf

Apply
private _fnc_processTerrain = {
    params ["_positions"];
    private _chunkSize = 10000;
    
    for "_i" from 0 to (count _positions) step _chunkSize do {
        private _chunk = _positions select [_i, _chunkSize];
        if (count _chunk > 0) then {
            setTerrainHeight [_chunk, true];
        };
    };
};
Chunking: Processes 10,000 points at a time to avoid engine limits
setTerrainHeight with true flag (uncommented? needs verification)
Step 5: Create main zone points

Sqf

Apply
private _radiusSqr = _radius * _radius;
private _mainZonePoints = [];
for "_dx" from -_radius to _radius step _gridSize do {
    for "_dy" from -_radius to _radius step _gridSize do {
        if ((_dx*_dx + _dy*_dy) <= _radiusSqr) then {
            _mainZonePoints pushBack [
                _centerX + _dx,
                _centerY + _dy,
                _targetHeight
            ];
        }
    };
};
[_mainZonePoints] call _fnc_processTerrain;
Generate points: Grid of points within radius (circular via distance squared check)
Each point: [x, y, targetHeight]
Process in chunks
Step 6: Create smoothing zone points

Sqf

Apply
private _smoothingRadiusSqr = _smoothingRadius * _smoothingRadius;
private _smoothingPoints = [];
private _smoothingFactorBase = _smoothingRadius - _radius;

for "_dx" from -_smoothingRadius to _smoothingRadius step _gridSize do {
    for "_dy" from -_smoothingRadius to _smoothingRadius step _gridSize do {
        private _distSqr = _dx*_dx + _dy*_dy;
        if (_distSqr > _radiusSqr && _distSqr <= _smoothingRadiusSqr) then {
            private _xPos = _centerX + _dx;
            private _yPos = _centerY + _dy;
            private _currentHeight = getTerrainHeightASL [_xPos, _yPos];
            private _distance = sqrt(_distSqr);
            
            // Optimization: pre-calculate coefficients
            private _smoothingFactor = (_distance - _radius) / _smoothingFactorBase;
            private _heightDiff = _targetHeight - _currentHeight;
            
            _smoothingPoints pushBack [
                _xPos,
                _yPos,
                _currentHeight + _heightDiff * (1 - _smoothingFactor)
            ];
        }
    };
};
[_smoothingPoints] call _fnc_processTerrain;
Generate points in annulus: Between _radius and _smoothingRadius
Height interpolation: For each point:
Calculate normalized distance from inner radius: (_distance - _radius) / _smoothingFactorBase
Calculate height difference from target
Blend: currentHeight + heightDiff * (1 - smoothingFactor)
At inner radius: smoothingFactor = 0 → full interpolation
At outer radius: smoothingFactor = 1 → no interpolation
Where it leads:
Functions called:

getTerrainHeightASL - Read current height
setTerrainHeight - Modify terrain
Functions that call this:

fn_handlerTerrainManipulator - When action present
Global variables:

None modified (terrain changes are global but not in variables)
Synchronization/network implications:

Server execution: Must run on server
Global terrain: setTerrainHeight affects all clients
Performance: Could be very expensive for large radii
Chunking: Prevents engine limits on point count
Edge cases handled:

Null object check (in caller)
Empty smoothing zone (if radii equal)
Grid size alignment
Known issues:

setTerrainHeight true flag behavior unclear (might need false)
Could cause performance spikes for large areas
No revert mechanism (permanent for mission)
Uses diag_deltaTime in original? Not in provided code