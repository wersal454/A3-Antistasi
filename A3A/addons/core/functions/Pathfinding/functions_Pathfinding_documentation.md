A3A_fnc_addNodesNearMarkers
Function Name: A3A/addons/core/functions/Pathfinding/fn_addNodesNearMarkers.sqf

What it does: This function attempts to improve the navigation mesh (NavGrid) by inserting new nodes near critical mission markers (airports, outposts, etc.) if the existing nodes are too far away to provide a valid connection. It specifically looks for road intersections near markers and links them into the grid, ensuring that convoy and pathfinding logic can reach these locations via roads. It is designed to run on the Server or Headless Client in an unscheduled environment.

How it does that:

1. Initialization and Marker Iteration
The function iterates through a hardcoded list of marker arrays (airportsX, milbases, resourcesX, factories, outposts, seaports, citiesX).

Sqf

Apply
_straddlePoints = [];
{
    private _spawnPoint = server getVariable ["spawn_"+_x, _x];
    private _mpos = markerPos _spawnPoint;
Logic: It retrieves the actual spawn position of the marker. If a specific spawn_ variable exists for the marker (common for airfields with distinct spawn areas), it uses that; otherwise, it defaults to the marker position itself.
2. Cell-Based Node Lookup
To optimize performance, the function determines which 1km x 1km navigation cell the marker falls into and retrieves all nodes within that cell.

Sqf

Apply
    private _navCell = format ["%1/%2", floor ((_mpos#0)/1000), floor ((_mpos#1)/1000)];
    private _navPoints =  A3A_navCellHM getOrDefault [_navCell, []];
    private _navPoints = _navPoints inAreaArray [_mpos, 300, 300];
Logic: It calculates the cell key (e.g., "0/0"). It fetches the list of [x, y, index] arrays stored in the global A3A_navCellHM hashmap. It then filters this list using inAreaArray to find nodes within a 300m radius of the marker.
3. Validation and Filtering
The function applies several checks to determine if a new node is necessary.

Sqf

Apply
    if (_navPoints isEqualTo []) then { Trace_1("%1 has no navpoints within 300m", _x); continue };
    if (_navPoints inAreaArray [_mpos, 50, 50] isNotEqualTo []) then { Trace_1("%1 already has nearby navpoints", _x); continue };
Logic:
No Nodes: If no nodes exist within 300m, the marker is likely isolated. The function logs this and skips to the next marker.
Close Enough: If a node exists within 50m, the marker is already adequately connected.
4. Finding the Optimal Road Segment (The "Straddle" Case)
This is the core geometric logic. It searches for two existing nodes that form a road segment passing near the marker but neither node is close enough.

Sqf

Apply
    {
        private _index = _x#2;
        private _node = NavGrid#_index;
        private _pos1 = _node#0;
        private _relpos1 = _mpos vectorDiff _pos1;
        {
            private _pos2 = NavGrid#(_x#0)#0;
            private _dir = _pos1 vectorFromTo _pos2;
            private _relpos2 = _mpos vectorDiff _pos2;
            if (_relpos1 vectorDotProduct _dir <= 0) then { continue };     // check that it's actually a straddle case
            if (_relpos2 vectorDotProduct _dir >= 0) then { continue };     // wouldn't need both of these if we sorted by distance first

            private _dist = vectorMagnitude (_relpos1 vectorCrossProduct _dir);
            if (_dist < _nearDist) then {
                private _nearPos = _dir vectorMultiply (_relpos1 vectorDotProduct _dir) vectorAdd _pos1;
                _nearDist = _dist;
                _nearData = [_index, _x#0, _nearPos];
            };
        } forEach _node#3;      // connected nodes [index, type, roaddist]
    } forEach _navPoints;
Logic:
It iterates through every node found in the 300m radius.
For each node, it iterates through its connected neighbors (stored in _node#3).
Straddle Check: It calculates the dot product of the vector from Node 1 to the Marker (_relpos1) and the vector from Node 1 to Node 2 (_dir). If the result is <= 0, the marker is behind Node 1. It then checks the dot product for Node 2. If the result is >= 0, the marker is ahead of Node 2. If both checks fail, the marker lies between the nodes (the "straddle" case).
Distance Calculation: It calculates the perpendicular distance from the marker to the road segment using the vector cross product.
Selection: It keeps track of the segment with the shortest perpendicular distance (_nearDist).
5. Road Verification and Node Creation
Once a geometric intersection is found, the function verifies that there is an actual drivable road at that location and creates the new node.

Sqf

Apply
    private _nearRoad = objNull;
    {
        private _dist = _nearData#2 distance2d _x;
        if (_dist < _nearDist) then { _nearDist = _dist; _nearRoad = _x };
    } forEach (_nearData#2 nearRoads 50);
    
    private _newPos = getPosATL _nearRoad;
    private _newNode = [_newPos, _node1#1, false, []];
Logic: It searches for physical road objects within 50m of the calculated intersection point. If none are found, it errors out (as the nav grid implies a road, but physical objects might be missing). The new node is initialized with the road's position, the same island ID (_node1#1), and an empty connection list.
6. Relinking the Graph
This is the critical step where the new node is inserted into the existing navigation graph.

Sqf

Apply
    // relink node 1
    private _n1dist = _node1#0 distance2d _newPos;
    _node1#3 apply { if (_x#0 == _nearData#1) then { _x set [0, _newIndex]; _x set [2, _n1dist]; _roadType = _x#1 } };
    _newNode#3 pushBack [_nearData#0, _roadType, _n1dist];

    // relink node 2
    private _n2dist = _node2#0 distance2d _newPos;
    _node2#3 apply { if (_x#0 == _nearData#0) then { _x set [0, _newIndex]; _x set [2, _n2dist] } };
    _newNode#3 pushBack [_nearData#1, _roadType, _n2dist];
Logic:
Node 1: Finds the connection entry pointing to Node 2 and updates its index to the _newIndex. Updates the distance.
Node 2: Finds the connection entry pointing to Node 1 and updates its index to the _newIndex. Updates the distance.
New Node: Adds connections back to Node 1 and Node 2.
Preservation: This maintains the integrity of the graph while splitting the road segment.
7. Finalization
Sqf

Apply
    NavGrid pushBack _newNode;
    _newIndex call A3A_fnc_addToNavCells;
} forEach (airportsX + milbases + ...);
Logic: The new node is appended to the global NavGrid array, and A3A_fnc_addToNavCells is called to register the node in the spatial hashmap (A3A_navCellHM) for fast future lookups.
Where it leads:

Calls: A3A_fnc_addToNavCells (To register the new node in the spatial grid).
Dependents: This function is typically called during mission initialization (preInit or postInit) by A3A_fnc_initServer or similar setup scripts. It runs once to set up the static navgrid.
Global Variables Modified:
NavGrid: The core navigation graph array is modified (nodes appended, connections updated).
A3A_navCellHM: The spatial hashmap is modified via addToNavCells.
System Fit: This acts as a patcher for the static navgrid data. It ensures that pre-calculated navgrid files (which might not include every single tiny intersection near bases) are enhanced with mission-critical connections.
Network Implications: None. This runs only on Server/HC during initialization.
A3A_fnc_addToNavCells
Function Name: A3A/addons/core/functions/Pathfinding/fn_addToNavCells.sqf

What it does: This function registers a single navigation node into the spatial partitioning system (A3A_navCellHM). It calculates which 1km x 1km cells the node occupies (nodes near borders may occupy multiple cells) and appends the node's index and coordinates to the relevant lists. This enables fast spatial lookups instead of iterating the entire NavGrid.

How it does that:

1. Parameter Extraction
Sqf

Apply
params ["_index"];
NavGrid#_index#0 params ["_xpos", "_ypos"];
Logic: Takes the integer index of the node and extracts its X and Y coordinates from the global NavGrid array.
2. Cell Range Calculation
Sqf

Apply
#define OFFSET 300
private _left = floor ((_xpos - OFFSET) / 1000);
private _right = floor ((_xpos + OFFSET) / 1000);
private _low = floor ((_ypos - OFFSET) / 1000);
private _high = floor ((_ypos + OFFSET) / 1000);
Logic: A node at the edge of a cell might physically be within range of a search centered in the neighboring cell. The OFFSET (300m) ensures that any search within a cell's 300m radius search area (used in getNearestNavPoint) will find the node even if it's technically in an adjacent cell. It calculates the minimum and maximum cell coordinates the node spans.
3. Determining Affected Cells
Sqf

Apply
private _navCells = [format ["%1/%2", _left, _low]];
if (_left != _right) then {
    _navCells pushBack format ["%1/%2", _right, _low];
    if (_low != _high) then {
        _navCells pushBack format ["%1/%2", _left, _high];
        _navCells pushBack format ["%1/%2", _right, _high];
    };
} else {
    if (_low != _high) then {
        _navCells pushBack format ["%1/%2", _left, _high];
    };
};
Logic: It constructs the cell keys (e.g., "12/-5").
If left != right, the node spans the vertical cell border.
If low != high, the node spans the horizontal cell border.
It adds all unique cell keys the node occupies to the _navCells array.
4. Hashmap Insertion
Sqf

Apply
private _navXYI = [_xpos, _ypos, _index];
{
    private _navPoints = A3A_navCellHM getOrDefault [_x, [], true];
    _navPoints pushBack _navXYI;
} forEach _navCells;
Logic:
Creates a compact data array [x, y, index].
Iterates over the calculated cell keys.
getOrDefault retrieves the existing array for that cell or initializes a new empty array.
Pushes the node data into the list.
Where it leads:

Calls: None.
Dependents:
A3A_fnc_loadNavGrid: Called for every node when the grid is initially loaded.
A3A_fnc_addNodesNearMarkers: Called when new nodes are dynamically added during initialization.
A3A_fnc_getNearestNavPoint: Depends on this data structure to find nodes quickly.
Global Variables Modified:
A3A_navCellHM: The global hashmap mapping cell keys to lists of nodes.
System Fit: This is a low-level utility that maintains the spatial index. Without it, pathfinding queries would have to scan the entire NavGrid (thousands of nodes) to find the nearest one, which would be prohibitively slow.
A3A_fnc_areNodesConnected
Function Name: A3A/addons/core/functions/Pathfinding/fn_areNodesConnected.sqf

What it does: Determines if two navigation nodes share the same "island ID" (hash). In the A3A navgrid system, disconnected land masses (islands) are assigned a unique hash. If two nodes have different hashes, no road path exists between them, regardless of distance.

How it does that:

1. Input Normalization
Sqf

Apply
params [ ["_firstNode", -1, [0, []]], ["_secondNode", -1, [0, []]] ];
Logic: Accepts either an integer index or a direct node array.
2. Index Resolution
Sqf

Apply
if(_firstNode isEqualType 0) then {
    if(_firstNode == -1) exitWith { _isConnected = false; };
    _firstNode = navGrid select _firstNode;
};
Logic: If the input is an integer, it retrieves the node data from navGrid. If the index is -1, it fails immediately.
3. Comparison
Sqf

Apply
_isConnected = (_secondNode select 1) == (_firstNode select 1);
Logic: Compares the element at index 1 of both node arrays (the Island Hash). Returns true if they are identical.
Where it leads:

Calls: None.
Dependents:
A3A_fnc_findPathPrecheck: Used to immediately abort pathfinding attempts between islands.
A3A_fnc_findNavDistance: Used to validate if a path is possible.
Global Variables Modified: None.
System Fit: A fundamental validation step used before executing expensive A* pathfinding algorithms.
A3A_fnc_calculateH
Function Name: A3A/addons/core/functions/Pathfinding/fn_calculateH.sqf

What it does: Calculates the heuristic (H) cost for A* pathfinding. This represents the estimated straight-line distance from a current position to the target position, multiplied by an overhead factor.

How it does that:

1. Parameter Extraction
Sqf

Apply
params [ ["_pos", [0,0,0], [[]]], ["_target", [0,0,0], [[]]] ];
Logic: Accepts start and end positions.
2. Calculation
Sqf

Apply
#define OVERHEAD 1.2
private _distance = _pos distance _target;
_distance = _distance * OVERHEAD;
Logic: Calculates Euclidean distance and applies a multiplier.
Why 1.2? A value > 1.0 makes the heuristic slightly more pessimistic (estimated distance is longer than actual). This biases the search toward finding the actual shortest path rather than taking risks on potentially shorter but unverified routes.
Where it leads:

Calls: None.
Dependents:
A3A_fnc_findPath: Used in every step of the A* algorithm to prioritize nodes.
A3A_fnc_findNavDistance: Used in distance calculations.
Global Variables Modified: None.
System Fit: A core component of the A* pathfinding algorithm.
A3A_fnc_convoyTest
Function Name: A3A/addons/core/functions/Pathfinding/fn_convoyTest.sqf

What it does: A debug/utility function that allows a server admin to visually test convoy pathfinding. It prompts the user to click two points on the map, calculates the path, draws it, and spawns a test convoy.

How it does that:

1. Execution Context Validation
Sqf

Apply
if(!canSuspend) exitWith { [] spawn A3A_fnc_convoyDebug; };
if(isDedicated) exitWith {};
if(!isServer && {!(call BIS_fnc_admin > 0)}) exitWith { ["Convoy Test", "Only server admins can execute the convoy test!"] call A3A_fnc_customHint; };
Logic: Ensures it runs in a scheduled environment (to allow waitUntil), is not running on the dedicated server headless (no input), and is restricted to admins.
2. User Input Handling
Sqf

Apply
onMapSingleClick "markedPos = _pos;";
waitUntil {sleep 1; (count markedPos > 0) or (!visibleMap)};
onMapSingleClick "";
Logic: Sets a global variable markedPos when the user clicks. Waits for a click or map closure. This is a synchronous blocking operation.
3. Pathfinding and Visualization
Sqf

Apply
private _path = [_startPos, _endPos] call A3A_fnc_findPath;
[_path, 600] call A3A_fnc_drawPath;
Logic: Calls the main pathfinding function to get the route array, then calls drawPath to render markers and lines for 600 seconds.
4. Convoy Spawning
Sqf

Apply
[69420, _vehicles, _startPos, _endPos, [], "ATTACK", WEST] spawn A3A_fnc_createConvoy;
Logic: Spawns a hardcoded convoy configuration (MRAP + APC) using A3A_fnc_createConvoy.
Where it leads:

Calls:
A3A_fnc_customHint: UI feedback.
A3A_fnc_findPath: The core pathfinding logic.
A3A_fnc_drawPath: Visualization.
A3A_fnc_createConvoy: Actual entity spawning.
Global Variables Modified: markedPos (used for input capture).
System Fit: Debug tool for developers.
A3A_fnc_drawGrid
Function Name: A3A/addons/core/functions/Pathfinding/fn_drawGrid.sqf

What it does: Visualizes the entire navigation grid on the map. It draws a marker for every node and lines for every connection, color-coded by road type and node degree.

How it does that:

1. Node Rendering
Sqf

Apply
{
    private _roadMarker = createMarker [format ["Marker%1", _forEachIndex], (_x select 0)];
    _roadMarker setMarkerShape "ICON";
    // ... color and type logic ...
Logic: Iterates NavGrid. Creates a marker at the node position.
Green: Traversable road.
Grey: Trail.
Text: Number of connections.
Type: Box (Junction), Triangle (Dead end), Dot (Standard).
2. Connection Rendering
Sqf

Apply
    {
        private _conIndex = (_x select 0);
        if(_conIndex > _thisIndex) then {
            private _conPos = navGrid select _conIndex select 0;
            // ... switch on road type ...
            [_thisPos, _conPos, "ColorOrange", _time] call A3A_fnc_drawLine;
        };
    } forEach (_x select 3);
Logic: Iterates connections. The check _conIndex > _thisIndex ensures every line is drawn only once (since connections are bidirectional). It calls A3A_fnc_drawLine with appropriate colors (Yellow=Trail, Orange=Road, Red=Autobahn).
Where it leads:

Calls:
A3A_fnc_drawLine: Renders the lines.
Global Variables Modified: Creates local markers (only visible to the caller).
System Fit: Debug/Visualization tool.
A3A_fnc_drawLine
Function Name: A3A/addons/core/functions/Pathfinding/fn_drawLine.sqf

What it does: Renders a rectangular marker between two points to simulate a line.

How it does that:

1. Geometry Calculation
Sqf

Apply
private _distance = _startPos distance2D _endPos;
private _angle = _startPos getDir _endPos;
private _mid = (_startPos vectorAdd _endPos) vectorMultiply 0.5;
Logic: Calculates length, direction, and midpoint.
2. Marker Creation
Sqf

Apply
private _lineMarker = createMarker [format ["%1line%2", str _startPos, str _endPos], _mid];
_lineMarker setMarkerShape "RECTANGLE";
_lineMarker setMarkerSize [3, _distance/2];
_lineMarker setMarkerDir _angle;
Logic: A rectangle of width 3 and length equal to half the distance (full distance in Arma markers) is created at the midpoint and rotated to align with the points.
Where it leads:

Calls: None.
Dependents: A3A_fnc_drawGrid, A3A_fnc_drawPath.
Global Variables Modified: Creates a local marker.
A3A_fnc_drawPath
Function Name: A3A/addons/core/functions/Pathfinding/fn_drawPath.sqf

What it does: Visualizes a calculated path array (as returned by findPath).

How it does that:

1. Path Iteration
Sqf

Apply
{
    private _nodeData = _x;
    private _nodePos = _x;
    if(count _nodeData == 2) then { _nodePos = _nodeData select 0; };
Logic: Handles both simple position arrays and complex path arrays (which may include junction flags).
2. Line Drawing
Sqf

Apply
if(_forEachIndex < (_pathLength - 1)) then {
    private _nextPos = _path select (_forEachIndex + 1);
    [_nodePos, _nextPos, "ColorRed", _time] call A3A_fnc_drawLine;
};
Logic: Draws a red line between the current step and the next step of the path.
Where it leads:

Calls: A3A_fnc_drawLine.
Dependents: A3A_fnc_convoyTest, A3A_fnc_findPath (internal debugging).
Global Variables Modified: Creates local markers.
A3A_fnc_findLandSupportMarkers
Function Name: A3A/addons/core/functions/Pathfinding/fn_findLandSupportMarkers.sqf

What it does: Finds all outposts, airports, and milbases within "land support distance" (reachable by land vehicles) of a specific nav index or position. It caches results.

How it does that:

1. Caching System
Sqf

Apply
if (isNil "A3A_landSupportMarkers") then {
    A3A_landSupportMarkers = createHashMap;
    // Populate A3A_outpostAirportXYI array...
};
private _key = (["s", "l"] select _lowAir) + str _navIndex;
private _val = A3A_landSupportMarkers get _key;
if (!isNil "_val") exitWith { _val };
Logic: Initializes a persistent hashmap if missing. Generates a unique key based on the nav index and type (LowAir vs Standard). Checks cache; if found, returns immediately.
2. Broad Phase Filter
Sqf

Apply
private _maxLandDist = distanceForLandAttack + ([1000, 2000] select _lowAir);
private _nearLand = A3A_outpostAirportXYI inAreaArray [NavGrid#_navIndex#0, _maxLandDist, _maxLandDist];
Logic: Uses a fast inAreaArray check on a pre-built array of [x, y, markerIndex] to find candidates within a rough distance.
3. Fine Phase Filter (Nav Distance)
Sqf

Apply
{
    private _suppMrk = markersX#(_x#2);
    private _suppNavIndex = _suppMrk call A3A_fnc_getMarkerNavPoint;
    private _navDist = [_navIndex, _suppNavIndex, _maxLandDist+500] call A3A_fnc_findNavDistance;
    if (_navDist < 0) then { continue };
    _supportMrk pushBack [_suppMrk, _navDist];
} forEach _nearLand;
Logic: For each candidate, it calculates the exact road distance using A3A_fnc_findNavDistance. If a path exists within limits, it's added to the result.
Where it leads:

Calls:
A3A_fnc_getMarkerNavPoint: Gets nav index for markers.
A3A_fnc_findNavDistance: Calculates road distance (A*).
Dependents: Mission scripts requesting support (e.g., QRF spawning).
Global Variables Modified: A3A_landSupportMarkers (cache), A3A_outpostAirportXYI (lookup table).
A3A_fnc_findNavDistance
Function Name: A3A/addons/core/functions/Pathfinding/fn_findNavDistance.sqf

What it does: Finds the shortest road distance between two points or nodes using A*. Returns the distance as a number (or -1 if unreachable/max dist exceeded).

How it does that:

1. Initialization
Sqf

Apply
private _startIndex = ...;
private _endIndex = ...;
if (NavGrid#_startIndex#1 != NavGrid#_endIndex#1) exitWith { -1 };
Logic: Resolves inputs to indices. Immediately checks if nodes are on the same island.
2. A* Loop
Sqf

Apply
private _curEntry = [0, _startIndex, 0, -1];
private _open = [];
private _touched = createHashMapFromArray [[_startIndex, true]];
Logic: Sets up the A* open list and a touched hashmap to prevent reprocessing nodes.
Entry Format: [currentGH, index, currentG, parentIndex]. Note: _curEntry here only holds index/g, not the full node data, optimized for memory.
3. Expansion and Termination
Sqf

Apply
while {!isNil "_curEntry"} do {
    _curEntry params ["", "_curIndex", "_curG"];
    {
        _newIndex = _x#0;
        if (_newIndex == _endIndex) exitWith { (_curG + _x#2) breakOut "main" };
        // ... calculate G and GH ...
        if (_newGH < _maxDist) then { _open pushBack [_newGH, _newIndex, _newG, _curIndex] };
    } forEach (NavGrid#_curIndex#3);
    _open sort true;
    _curEntry = _open deleteAt 0;
};
Logic:
Pops the best node from _open.
Iterates connections.
Success: If neighbor is _endIndex, calculates total distance and breaks out.
Expansion: Calculates new G (cost) and GH (heuristic). If under max distance, adds to open list.
Sorting: _open sort true uses Arma's built-in sort (lowest first), leveraging the GH value at index 0.
Where it leads:

Calls: A3A_fnc_getNearestNavPoint (if inputs are positions).
Dependents: A3A_fnc_findLandSupportMarkers, A3A_fnc_arePositionsConnected.
Global Variables Modified: None (local scope).
System Fit: Optimized distance calculator, distinct from findPath which returns a route array.
A3A_fnc_findNodesInDistance
Function Name: A3A/addons/core/functions/Pathfinding/fn_findNodesInDistance.sqf

What it does: Returns an array of node indices within a specific road-distance radius from a start position.

How it does that:

1. State Management
Sqf

Apply
#define WORKSTATE_UNTOUCHED 0
#define WORKSTATE_OPENED    1
#define WORKSTATE_CLOSED    2
if(isNil "pathfindingActive") then { pathfindingActive = false; };
waitUntil {!pathfindingActive};
pathfindingActive = true;
Logic: Defines state constants. Uses a global mutex pathfindingActive to ensure only one pathfinding operation runs at a time (to prevent mission crashes).
2. A* Breadth-First Search (Dijkstra Variant)
Sqf

Apply
_openList pushBack [_startNav, 0, 0];
missionNamespace setVariable [format ["PF_%1", str (_startNav select 0)], WORKSTATE_OPENED];
Logic: Unlike findPath, this does not use a heuristic (H). It simply explores the graph until the distance G exceeds the search radius.
State Tracking: Uses missionNamespace variables (e.g., PF_1234) to track node states globally. This is slower than local hashmaps but necessary for thread safety in some Arma contexts.
3. Collection
Sqf

Apply
else {
    _rangeNodes pushBack _conIndex;
    missionNamespace setVariable [format ["PF_%1", str (_conNode select 0)], WORKSTATE_CLOSED];
};
Logic: When a node's accumulated distance exceeds the search radius but is still within the branching logic, it is added to _rangeNodes and closed off.
4. Cleanup
Sqf

Apply
{
    missionNamespace setVariable [format ["PF_%1", _x], WORKSTATE_UNTOUCHED];
} forEach _touchedNodes;
pathfindingActive = false;
Logic: Resets the global state variables to prevent memory leaks and stale locks before returning.
Where it leads:

Calls: A3A_fnc_getNearestNavPoint.
Dependents: AI logic looking for local targets (e.g., "find all roads within 500m for an ambush").
Global Variables Modified: PF_... (temporarily), pathfindingActive (mutex).
A3A_fnc_findPath
Function Name: A3A/addons/core/functions/Pathfinding/fn_findPath.sqf

What it does: The main pathfinding function. Calculates a specific route (array of positions) between two points using A*, avoiding obstacles if specified.

How it does that:

1. Precheck and Caching
Sqf

Apply
private _preCheckValue = [_startNavIndex, _endNavIndex] call A3A_fnc_findPathPrecheck;
if(_preCheckValue isEqualType []) exitWith { _preCheckValue };
Logic: Calls findPathPrecheck to see if a path is possible (same island) or if the result is already cached.
2. Avoidance Setup
Sqf

Apply
{
    missionNamespace setVariable [format ["PF_%1", str (_x select 0)], WORKSTATE_AVOID_UNTOUCHED];
} forEach _avoid;
Logic: If specific nodes are blocked (e.g., destroyed bridges), they are marked with a special state WORKSTATE_AVOID_UNTOUCHED.
3. A* Loop with Penalties
Sqf

Apply
private _newDistance = (_current select 1) + (_conData select 2) * (1 / ((_conData select 1) max 0.5));
if(_workState == WORKSTATE_AVOID_UNTOUCHED) then {
    _newDistance = (_current select 1) + (_conData select 2) * AVOID_PENALTY;
};
Logic:
Weighting: Divides road distance by the road type (1=Road, 2=Autobahn, 0.5=Trail). This makes Autobahns cheaper/faster than trails.
Avoidance: If a node is in the avoid list, a massive penalty (AVOID_PENALTY = 15) is applied, forcing the pathfinder to find a different route if possible.
4. Path Reconstruction
Sqf

Apply
if(_lastNav isEqualType []) then {
    _wayPoints = [[_endPos, true], [_targetPos, true]];
    while {_lastNav isEqualType []} do {
        _wayPoints pushBack [_lastNav select 0 select 0, _lastNav select 0 select 2];
        _lastIndex = missionNamespace getVariable [format ["CL_%1", _lastNav select 3], -1];
        _lastNav = _closedList select _lastIndex;
    };
    reverse _wayPoints;
}
Logic:
CL_... variables store the index in the _closedList where a node's parent data is stored.
It backtracks from the end node to the start node using these parent pointers.
It constructs the array of [position, isJunction].
5. Caching
Sqf

Apply
private _pathKey = format ["%1->%2", _startNavIndex, _endNavIndex];
// ... push to CachedPaths ...
Logic: Stores the resulting waypoint array in CachedPaths for 20 entries.
Where it leads:

Calls:
A3A_fnc_findPathPrecheck
A3A_fnc_calculateH
A3A_fnc_listInsert
Dependents: A3A_fnc_convoyTest, A3A_fnc_createConvoy, A3A_fnc_findPosOnRoute.
Global Variables Modified: CachedPaths (persistent), PF_..., CL_... (temp).
A3A_fnc_findPathPrecheck
Function Name: A3A/addons/core/functions/Pathfinding/fn_findPathPrecheck.sqf

What it does: Validates inputs for pathfinding and checks the cache.

How it does that:

1. Validation
Sqf

Apply
if(_startNav == -1) exitWith { Error("No navnode found..."); false; };
if(_startNav == _endNav) exitWith { Error("Same nodes..."); false; };
Logic: Checks for invalid indices or identical start/end.
2. Connectivity Check
Sqf

Apply
private _nodesConnected = [_startNav, _endNav] call A3A_fnc_areNodesConnected;
if(!_nodesConnected) exitWith { Info("The given nodes were not connected..."); false; };
Logic: Uses island hashing to reject impossible paths immediately.
3. Cache Lookup
Sqf

Apply
private _cachedPaths = missionNamespace getVariable ["CachedPaths", []];
// ... check key ...
if(_cachedIndex != -1) exitWith {
    _cachedPaths select _cachedIndex select 1;
};
Logic: If the exact path exists in the cache, it returns the array, which causes findPath to exit immediately with the cached result.
Where it leads:

Calls: A3A_fnc_areNodesConnected.
Dependents: A3A_fnc_findPath.
Global Variables Modified: None (read-only access to CachedPaths).
A3A_fnc_findPosOnRoute
Function Name: A3A/addons/core/functions/Pathfinding/fn_findPosOnRoute.sqf

What it does: Calculates exact spawn positions along a nav path, interpolating between nodes and finding road positions using roadAStar to ensure vehicles spawn on the road.

How it does that:

1. State Initialization
Sqf

Apply
if (count _state == 0) then { _state = [[], 0, 0, [], ATLtoASL (_route select 0), false] };
_state params ["_vecStart", "_vecDir", "_routeIdx", "_roads", "_vecEnd", "_vecReady"];
Logic: Maintains a state array to allow this function to be called iteratively (e.g., spawn vehicle 1, get state, spawn vehicle 2, get new state).
2. Road Segment Generation (Lazy Loading)
Sqf

Apply
if (count _roads < 2) then {
    private _road1 = roadAt (_route select _routeIdx);
    private _road2 = roadAt (_route select _routeIdx+1);
    if !(isNull _road1 or isNull _road2) then {
        _roads = [_road1, _road2] call A3A_fnc_roadAStar;
    };
}
Logic: It looks at the current nav segment (Node A to Node B). It finds the actual road objects at these points. If they exist, it calls A3A_fnc_roadAStar to find the exact road path between them. This ensures the vehicle follows the asphalt, not the navgrid centerline (which might be offset).
3. Vector Calculation
Sqf

Apply
_vecStart = _vecEnd;
if (count _roads >= 2) then {
    _vecEnd = [_roads select 0, _roads select 1] call A3A_fnc_roadConnPoint;
    _roads deleteAt 0;
} else {
    _vecEnd = ATLtoASL (_route select _routeIdx);
};
_vecDir = _vecStart vectorFromTo _vecEnd;
Logic: Steps along the road network. Uses roadConnPoint to find the precise link between two road objects. Calculates the direction vector.
4. Spacing Logic
Sqf

Apply
private _dist = _vecStart distance _vecEnd;
if (_dist > _spacing) then {
    private _pos = _vecStart vectorAdd (_vecDir vectorMultiply _spacing);
    breakWith [_pos, _vecDir, _routeIdx, _roads, _vecEnd, true];
};
Logic: If the requested spacing is less than the current segment length, it interpolates the position along the vector.
Where it leads:

Calls:
A3A_fnc_roadAStar: Finds road path.
A3A_fnc_roadConnPoint: Finds connection point.
Dependents: A3A_fnc_createConvoy (for positioning vehicles in a line).
Global Variables Modified: None (functional state management).
A3A_fnc_getMarkerNavPoint
Function Name: A3A/addons/core/functions/Pathfinding/fn_getMarkerNavPoint.sqf

What it does: Returns the nav grid index for a specific marker, using caching to ensure high performance.

How it does that:

1. Caching
Sqf

Apply
if (isNil "A3A_markerNavPoints") then { A3A_markerNavPoints = createHashMap; };
private _navIndex = A3A_markerNavPoints get _marker;
if !(isNil "_navIndex") exitWith { _navIndex };
Logic: Checks a global hashmap. If the marker was queried before, return the cached index.
2. Position Resolution
Sqf

Apply
private _spawnPoint = server getVariable ["spawn_"+_marker, _marker];
private _pos = markerPos _spawnPoint;
Logic: Checks for a spawn_ variable (e.g., "spawn_airport") which might differ from the marker center (often the flag pole). Defaults to marker center.
3. Lookup
Sqf

Apply
_navIndex = [_pos] call A3A_fnc_getNearestNavPoint;
A3A_markerNavPoints set [_marker, _navIndex];
Logic: Calls getNearestNavPoint and stores the result.
Where it leads:

Calls: A3A_fnc_getNearestNavPoint.
Dependents: A3A_fnc_addNodesNearMarkers, A3A_fnc_findLandSupportMarkers.
Global Variables Modified: A3A_markerNavPoints.
A3A_fnc_getNearestNavPoint
Function Name: A3A/addons/core/functions/Pathfinding/fn_getNearestNavPoint.sqf

What it does: Finds the index of the closest nav node to a position using the spatial hashgrid (A3A_navCellHM).

How it does that:

1. Spatial Lookup
Sqf

Apply
private _navCell = format ["%1/%2", floor ((_pos#0)/1000), floor ((_pos#1)/1000)];
private _navPoints =  A3A_navCellHM getOrDefault [_navCell, []];
Logic: Calculates the 1km cell key and retrieves the list of [x, y, index] arrays for that cell.
2. Progressive Search Radius
Sqf

Apply
private _nearPoints = _navPoints inAreaArray [_pos, 75, 75];
if (_nearPoints isEqualTo []) then {
    _nearPoints = _navPoints inAreaArray [_pos, 150, 150];
    if (_nearPoints isEqualTo []) then {
        _nearPoints = _navPoints inAreaArray [_pos, 350, 350];
    };
};
Logic: Performs a fast array filter in three stages (75m, 150m, 350m). This optimizes for the common case (close node) while ensuring fallback.
3. Distance Calculation
Sqf

Apply
{
    private _dist = _x distance2d _pos;
    if (_nearDist > _dist) then {
        _nearIndex = _x#2;
        _nearDist = _dist;
    };
} forEach _nearPoints;
Logic: Iterates the filtered nodes to find the absolute closest by Euclidean distance.
Where it leads:

Calls: A3A_fnc_getMarkerNavPoint.
Dependents: All pathfinding and distance functions.
Global Variables Modified: None (read-only access to A3A_navCellHM).
A3A_fnc_listInsert
Function Name: A3A/addons/core/functions/Pathfinding/fn_listInsert.sqf

What it does: Performs a binary search insertion into an array to maintain a sorted list (lowest value first). Used for the A* Open List.

How it does that:

1. Value Extraction
Sqf

Apply
private _entryValue = (_entry select 1) + (_entry select 2);
Logic: Calculates the total cost (G + H) of the node being inserted.
2. Binary Search
Sqf

Apply
while {_upperLimit >= _lowerLimit} do {
    _insertIndex = floor ((_lowerLimit + _upperLimit) / 2);
    _element = _list select _insertIndex;
    _searchValue = (_element select 1) + (_element select 2);
    // ... compare _searchValue and _entryValue ...
};
Logic: Standard binary search algorithm to find the insertion point in O(log N) time, rather than O(N) for a standard linear insert.
3. Array Reconstruction
Sqf

Apply
_list = (_list select [0, _insertIndex]) + [_entry] + (_list select [_insertIndex, _listCount - _insertIndex]);
Logic: Splits the array and inserts the new entry.
Where it leads:

Calls: None.
Dependents: A3A_fnc_findPath.
Global Variables Modified: None.
A3A_fnc_loadNavGrid
Function Name: A3A/addons/core/functions/Pathfinding/fn_loadNavGrid.sqf

What it does: Loads the nav grid data from a world-specific file, parses it, and initializes the spatial hashmap.

How it does that:

1. File Path Resolution
Sqf

Apply
private _path = if (isText (missionConfigFile/"A3A"/"Navgrid"/worldName)) then {
    getText (missionConfigFile/"A3A"/"Navgrid"/worldName);
} else {
    getText (configFile/"A3A"/"Navgrid"/worldName);
};
Logic: Looks for the navgrid file path in the mission config or mod config, specific to the current worldName.
2. Parsing
Sqf

Apply
private _navGridDB_formatted = preprocessFileLineNumbers _path;
NavGrid = parseSimpleArray _navGridDB_formatted;
Logic: Reads the file and parses the large array string into an Arma array.
3. Spatial Indexing
Sqf

Apply
A3A_navCellHM = createHashMap;
{
    private _index = _forEachIndex;
    _index call A3A_fnc_addToNavCells;
} forEach navGrid;
Logic: Creates the global A3A_navCellHM and iterates the newly loaded NavGrid, calling addToNavCells for every node to build the spatial index.
4. Completion Flag
Sqf

Apply
roadDataDone = true;
Logic: Sets a global flag indicating the navgrid is ready.
Where it leads:

Calls: A3A_fnc_addToNavCells.
Dependents: Initialization scripts (initServer).
Global Variables Modified: NavGrid, A3A_navCellHM, roadDataDone.
A3A_fnc_markNode
Function Name: A3A/addons/core/functions/Pathfinding/fn_markNode.sqf

What it does: Creates a marker at a specific nav grid index for debugging.

How it does that:

Sqf

Apply
private _pos = navGrid select _index select 0;
private _nodeMarker = createMarker [format ["Node%1", _index], _pos];
_nodeMarker setMarkerType _type;
Logic: Retrieves position and creates a named marker. Checks if a marker already exists to prevent duplicates.
Where it leads:

Calls: None.
Dependents: Debug scripts.
Global Variables Modified: None (creates local/global marker depending on context).
A3A_fnc_roadAStar
Function Name: A3A/addons/core/functions/Pathfinding/fn_roadAStar.sqf

What it does: Finds a path between two specific road objects (road data type) using A*. Unlike the navgrid, this operates on the actual game road network.

How it does that:

1. Setup
Sqf

Apply
private _curEntry = [_startRoad distance _endRoad, _startRoad, [0, objNull], 0];
private _touched = [_startRoad];
Logic: Initializes A* with the heuristic pre-calculated.
2. Neighbor Expansion
Sqf

Apply
_connRoads = (roadsConnectedTo [_curRoad, true]) - [_parent];
if (_endRoad in _connRoads) exitWith {};
{
    if (getRoadInfo _x select 2) then { continue }; // Filter pedestrian trails
    // ... calculate G and GH ...
} forEach _connRoads;
Logic: Uses the engine command roadsConnectedTo to find neighbors. Filters out mainRoad info type 2 (pedestrian trails).
3. Path Reconstruction
Sqf

Apply
private _route = [_endRoad];
while {count _curEntry == 4} do {
    _route pushBack (_curEntry select 1);
    _curEntry = _curEntry select 2;
};
reverse _route;
Logic: Backtracks from the _curEntry parent pointers to build the route array.
Where it leads:

Calls: None.
Dependents: A3A_fnc_findPosOnRoute.
Global Variables Modified: None (local scope).
A3A_fnc_roadConnPoint
Function Name: A3A/addons/core/functions/Pathfinding/fn_roadConnPoint.sqf

What it does: Calculates the precise 3D position where two road objects connect.

How it does that:

1. Endpoint Selection
Sqf

Apply
private _r1ends = if (_r1info#6 distance2d _road2 < _r1info#7 distance2d _road2) then
    { [_r1info#7, _r1info#6] } else { [_r1info#6, _r1info#7] };
Logic: Orders the endpoints of Road 1 based on proximity to Road 2.
2. Intersection Logic
Sqf

Apply
if (_r1conn <= 2 && _r2conn <= 2) exitWith { _r1ends # 1 };
[_r1ends#0, _r1ends#1, _r2info#6, _r2info#7] call _fnc_vecIntercept;
Logic:
Simple Case: If both roads have only 2 connections (simple segments), the connection is simply the shared endpoint.
Complex Case: If one is a junction, it calculates the mathematical intersection of the two road lines (defined by start/end points).
Where it leads:

Calls: Internal vector intercept function.
Dependents: A3A_fnc_findPosOnRoute.
Global Variables Modified: None.
A3A_fnc_trimPath
Function Name: A3A/addons/core/functions/Pathfinding/fn_trimPath.sqf

What it does: Simplifies a detailed path by removing non-junction nodes (straight line segments), leaving only the essential turning points.

How it does that:

1. Vector Comparison (First Step)
Sqf

Apply
private _firstVector = (_path select 1 select 0) vectorDiff (_path select 0 select 0);
private _secondVector = (_path select 2 select 0) vectorDiff (_path select 1 select 0);
if(_firstVector vectorDotProduct _secondVector <= 0) then { _path deleteAt 1; };
Logic: Calculates the direction of the first segment and the second segment. If the dot product is <= 0, the angle between them is obtuse (90+ degrees) or zero, meaning it's not a smooth straight line or it's a dead end. It checks if the node at index 1 can be removed without changing the path shape.
2. Final Extraction
Sqf

Apply
{
    if(_x select 1) then { _simplifiedPath pushBack (_x select 0); };
} forEach _path;
Logic: Only keeps nodes where the isJunction flag (index 1) is true.
Where it leads:

Calls: None.
Dependents: AI movement scripts that need simplified waypoints for group movement (groups don't need to hit every single road node).
Global Variables Modified: None.