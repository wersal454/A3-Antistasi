Function: fn_collectSaveData.sqf
What it does: This function collects and aggregates all saved game data from the profile namespace and mission profile namespace. It builds a list of available save data that can be loaded by the save selector, returning a hashmap array containing metadata for each save game. The function is designed to be run before the game starts to populate save data for user selection, and it destroys A3A_saveTarget during its operation.

How it does that:

Step 1: Define Optional Save Variables

Apply
private _optionalVars = ["name", "version", "saveTime", "ended", "params", "factions", "DLC", "addonVics"];
Creates an array of metadata variable names to extract from each save
These are informational variables used by the save selector UI
Step 2: Create Game Missing Check Function

Apply
private _fnc_gameMissing = { isNil {"membersX" call A3A_fnc_returnSavedStat} };
Defines a closure that checks if a save exists by testing if the "membersX" variable exists
"membersX" is a core save variable that should exist in any valid save
Step 3: Initialize Data Structures

Apply
private _saveData = [];
private _campaignIDs = [];
private _serverID = profileNameSpace getVariable ["ss_ServerID",""];
saveData: Array to store the aggregated save metadata
campaignIDs: Array to track which campaign IDs have been processed
serverID: Retrieves the server identifier from profile namespace
Step 4: Process Old Plus Saves (Profile Namespace)

Apply
private _saveList = [profileNamespace getVariable "antistasiUltimate2SavedGames"] param [0, [], [[]]];
{
    _x params ["_cid", "_map", "_gameType"];
    _campaignIDs pushBack _cid;
    if (_gameType == "Blufor") then { continue };
    A3A_saveTarget = [_serverID, _cid, _map];
    if (call _fnc_gameMissing) then { continue };

    private _game = createHashMapFromArray [["serverID", _serverID], ["gameID", _cid], ["map", _map]];
    { _game set [_x, _x call A3A_fnc_returnSavedStat] } forEach _optionalVars;
    _saveData pushBack _game;
} forEach _saveList;
Implementation Breakdown:

Retrieves the save list from antistasiUltimate2SavedGames variable in profile namespace
Uses param to default to empty array if variable doesn't exist
Iterates through each save entry containing [campaignID, map, gameType]
Filters out "Blufor" game types (legacy incompatible saves)
Sets A3A_saveTarget to point to the specific save's location
Checks if the save actually exists (has membersX data)
Creates a hashmap containing core metadata and optional variables
Adds the hashmap to the save data collection
Key Technical Details:

Uses createHashMapFromArray for efficient key-value storage
Calls A3A_fnc_returnSavedStat for each optional variable
The continue statement skips invalid/incompatible saves
Step 5: Handle Pre-2.3 Saves

Apply
private _oldCampaignID = profileNameSpace getVariable ["ss_CampaignID", ""];
if !(_oldCampaignID in _campaignIDs) then {
    A3A_saveTarget = [_serverID, _oldCampaignID, worldName];
    if (call _fnc_gameMissing) then { A3A_saveTarget set [1, ""] };
    if (call _fnc_gameMissing) exitWith {};
    _saveData pushBack createHashMapFromArray [["serverID", _serverID], ["gameID", A3A_saveTarget#1], ["map", worldName]];
};
Implementation Breakdown:

Retrieves the old campaign ID from legacy save location
Checks if this campaign ID hasn't been processed already
Sets A3A_saveTarget for pre-2.3 saves (which use worldName as map identifier)
If save is missing with campaign ID, tries again with empty campaign ID (original saves)
If still missing, exits the block
Creates a minimal hashmap for legacy saves (only metadata, no optional vars)
Step 6: Process Mission Profile Namespace Saves

Apply
private _saveList2 = [missionProfileNamespace getVariable "antistasiUltimate2SavedGames"] param [0, [], [[]]];
{
    _x params ["_cid", "_map"];
    A3A_saveTarget = [false, _cid, _map];
    if (call _fnc_gameMissing) then { continue };

    private _game = createHashMapFromArray [["serverID", false], ["gameID", _cid], ["map", _map]];
    { _game set [_x, _x call A3A_fnc_returnSavedStat] } forEach _optionalVars;
    _saveData pushBack _game;
} forEach _saveList2;
Implementation Breakdown:

Retrieves save list from mission profile namespace (new save system)
Each entry is [campaignID, map] (no gameType needed)
Sets A3A_saveTarget with false for serverID (indicates mission profile save)
Processes similarly to profile namespace saves
Creates hashmaps with serverID: false to identify mission profile saves
Step 7: Final Processing

Apply
reverse _saveData;
_saveData;
Reverses the array so newest saves appear first
Returns the final array of save metadata
Where it leads:

Calls A3A_fnc_returnSavedStat - Retrieves individual save variables for each optional var
Uses A3A_saveTarget - Global variable set and used throughout the save system
Modifies A3A_saveTarget - Destroys it during operation (as noted in comments)
Calls A3A_fnc_loadServer - This function uses the collected data to load saves
Used by save selector UI - The returned array populates the load game menu
Dependencies:

A3A_fnc_returnSavedStat - Core save variable retrieval function
A3A_saveTarget - Global state for current save operation
Profile/mission profile namespaces - Storage for save data
Global Variables Modified:

A3A_saveTarget - Set, modified, and potentially left in modified state (documented as destructive)
No network synchronization (purely local data collection)
Technical Details:

Returns [] if no saves exist
Handles both legacy (pre-2.3) and modern save formats
Filters out incompatible Blufor saves
Uses hashmaps for efficient data storage (O(1) lookups)
No error handling - assumes valid save structure
Performance: O(n) where n = number of saves
Edge Cases Handled:

Missing antistasiUltimate2SavedGames variable (defaults to empty array)
Missing campaign IDs in legacy saves (tries empty string fallback)
Blufor game types (filtered out)
Missing optional variables (returns nil, which is handled)
Multiple saves with same campaign ID (only first is processed)
Function: fn_deleteSave.sqf
What it does: This function completely removes a specific save game from the persistent storage. It deletes all player data (loadouts, scores, ranks, garage, money) and all server data (garrisons, resources, markers, etc.) for a specified campaign ID. It then removes the save from the master save list and saves the namespace.

How it does that:

Step 1: Parameter Validation and Initialization

Apply
params ["_serverID", "_campaignID", "_worldname", ["_gametype", "Greenfor"]];

Info_1("Deleting saved game with parameters %1", _this);

private _namespace = [profileNamespace, missionProfileNamespace] select (_serverID isEqualType false);
Implementation Breakdown:

Unpacks parameters: server ID, campaign ID, world name, and game type
Logs deletion attempt with Info_1
Determines namespace based on serverID type:
serverID isEqualType false means mission profile namespace (new system)
Otherwise uses profile namespace (legacy system)
Step 2: Generate Postfix for Variable Names

Apply
private _postfix = if (_serverID isEqualTo false) then { 
	_campaignID 
} else {
	format["%1%2Antistasi%3",_serverID,_campaignID,_worldName]; 
};
Implementation Breakdown:

Mission profile saves: Postfix is just the campaign ID
Profile namespace saves: Postfix follows format: {serverID}{campaignID}Antistasi{worldName}
This postfix is appended to all save variable names
Step 3: Delete All Player Data

Apply
private _savedPlayers = _namespace getVariable ["savedPlayers" + _postfix, []];
{
	private _playerID = _x;
	{
		private _varName = format ["player_%1_%2", _playerID, _x];
		_namespace setVariable [_varname + _postfix, nil];

	} forEach ["loadoutPlayer", "scorePlayer", "rankPlayer", "personalGarage", "moneyX"];

} forEach _savedPlayers;
Implementation Breakdown:

Retrieves the list of saved player IDs for this campaign
Iterates through each player ID
For each player, deletes 5 variables:
loadoutPlayer - Unit loadout
scorePlayer - Player score
rankPlayer - Player rank
personalGarage - Personal garage vehicles
moneyX - Player money
Variable naming: player_{uid}_{varName}{postfix}
Sets variable to nil to delete it
Uses nested loops: outer for players, inner for variable types
Step 4: Delete All Server Data

Apply
{
	_namespace setVariable [_x + _postfix, nil];

} forEach [
	"countCA", "gameMode", "difficultyX", "bombRuns", "smallCAmrk", "membersX", "antennas",
	"mrkSDK", "mrkCSAT", "posHQ", "dateX", "skillFIA", "destroyedSites", "distanceSPWN",
	"chopForest", "nextTick", "weather", "destroyedBuildings", "aggressionOccupants",
	"aggressionInvaders", "resourcesFIA", "hr", "staticsX", "jna_datalist",
	"prestigeOPFOR", "prestigeBLUFOR", "garrison", "wurzelGarrison", "usesWurzelGarrison", "minesX",
	"tasks", "killZones", "controlsSDK", "params",
	"attackCountdownOccupants", "attackCountdownInvaders",
	"savedPlayers", "testingTimerIsActive", "HR_Garage", "A3A_fuelAmountleftArray", "HQKnowledge", "enemyResources",
	"version", "name", "saveTime", "ended", "factions", "addonVics", "DLC",
	
	"supportPoints",
    "constructionsX",
    "watchpostsFIA", "roadblocksFIA", "aapostsFIA", "atpostsFIA", "hmgpostsFIA",
    "traderDiscount", "isTraderQuestAssigned", "isTraderQuestCompleted", "traderPosition",
    "areOccupantsDefeated", "areInvadersDefeated",
    "destroyedMilAdmins",
    "rebelLoadouts", "randomizeRebelLoadoutUniforms",
    "areRivalsDefeated", "areRivalsDiscovered", "inactivityRivals", "rivalsLocationsMap", "rivalsExcludedLocations",
    "nextRivalsLocationReveal", "isRivalsDiscoveryQuestAssigned"
];
Implementation Breakdown:

Iterates through a comprehensive list of 44+ server-side variables
Each variable follows naming pattern: {varName}{postfix}
Variables cover all game aspects:
Campaign state (gameMode, difficultyX)
Resources (resourcesFIA, hr, bombRuns)
Military (staticsX, garrison, minesX)
Territory (mrkSDK, mrkCSAT, controlsSDK)
Rivals system (areRivalsDefeated, rivalsLocationsMap)
Traders and economy (traderDiscount, traderPosition)
Miscellaneous (weather, dateX, tasks, etc.)
Step 5: Remove Save from Master List

Apply
private _saveList = [_namespace getVariable "antistasiUltimate2SavedGames"] param [0, [], [[]]];
_saveIndex = _saveList findIf { _x#0 == _campaignID };
_saveList deleteAt _saveIndex;
_namespace setVariable ["antistasiUltimate2SavedGames", _saveList];
Implementation Breakdown:

Retrieves the master save list
Uses param to default to empty array if not exists
Finds index where campaign ID matches
Deletes the entry at that index
Sets the updated list back to the namespace
Note: findIf returns -1 if not found (would crash with deleteAt -1)
Step 6: Save the Namespace

Apply
if (_serverID isEqualType false) then { saveMissionProfileNamespace } else { saveProfileNamespace };
Saves the appropriate namespace to disk
Mission profile namespace uses saveMissionProfileNamespace
Profile namespace uses saveProfileNamespace
Where it leads:

Used by delete save dialog - Called when user selects a save to delete
Calls save namespace functions - saveProfileNamespace or saveMissionProfileNamespace
Calls A3A_fnc_collectSaveData - After deletion, this would need to be called to refresh the save list
Used by A3A_fnc_saveLoop - During cleanup operations
Calls A3A_fnc_loadServer - Not directly, but subsequent load will fail for deleted save
Dependencies:

No direct function calls, but relies on save namespace structure
Depends on A3A_fnc_setStatVariable for save structure (reverse dependency)
Uses profileNamespace and missionProfileNamespace storage
Global Variables Modified:

None - Operates on specified namespace only
No network synchronization
Technical Details:

Performance: O(n) where n = number of players + number of server variables
Memory: Frees up space in profile namespace
Error handling: None - assumes valid parameters
Safety: Uses param with default empty array to prevent errors
Edge Cases Handled:

Missing save list (defaults to empty array)
Campaign ID not in save list (findIf returns -1, would crash on deleteAt -1)
Missing player data (savedPlayers defaults to empty array)
Mission profile vs profile namespace selection
Known Issues:

deleteAt _saveIndex will crash if campaign ID not found (saveIndex = -1)
No verification that save exists before deletion
No user confirmation in function (should be handled by caller)
Function: fn_getStatVariable.sqf
What it does: This function retrieves a single variable from the current save and immediately loads it into the game state. It's a wrapper around A3A_fnc_returnSavedStat and A3A_fnc_loadStat, providing a convenient way to load one variable at a time.

How it does that:

Step 1: Extract Variable Name

Apply
private _varName = _this select 0;
Gets the first parameter as the variable name to retrieve
Step 2: Retrieve Saved Value

Apply
private _varValue = [_varName] call A3A_fnc_returnSavedStat;
Calls the save retrieval function to get the saved value
Returns nil if the variable doesn't exist in the save
Step 3: Early Exit if Missing

Apply
if (isNil "_varValue") exitWith {};
If variable doesn't exist in save, exits silently
No error message (silent failure)
Step 4: Load the Variable

Apply
[_varName,_varValue] call A3A_fnc_loadStat;
Calls loadStat to restore the variable into game state
loadStat handles special variable loading logic
Where it leads:

Calls A3A_fnc_returnSavedStat - Retrieves variable from persistent storage
Calls A3A_fnc_loadStat - Applies the variable to game state
Used by A3A_fnc_loadServer - Called dozens of times to load server state
Used by save system - Multiple calls during load operations
Dependencies:

A3A_fnc_returnSavedStat - Core retrieval function
A3A_fnc_loadStat - Variable loading logic
A3A_saveTarget - Global state for current save operation
Global Variables Modified:

None - Delegates all modification to A3A_fnc_loadStat
No network synchronization
Technical Details:

Performance: Minimal overhead, just two function calls
Safety: Handles nil values gracefully
Pattern: Common utility function for save system
Edge Cases Handled:

Missing variable (silent exit)
Nil variable value (silent exit)
Empty variable name (handled by returnSavedStat)
Function: fn_loadPlayer.sqf
What it does: This function loads a single player's saved data into the game. It retrieves the player's saved data from the hashmaps, sets their loadout, score, rank, money, and garage, and updates their statistics. This is called during mission load and when a player joins.

How it does that:

Step 1: Parameter Validation and Server Check

Apply
if (!isServer) exitWith {
    Error("Miscalled server-only function");
};

params ["_playerId", "_unit"];
Ensures function only runs on server (critical for save operations)
Extracts player ID and unit reference
Step 2: Check if Player Has Save Data

Apply
if !(_playerId in A3A_playerSaveData) then {
    Info_1("No save found for player ID %1", _playerId);
	[_playerId, _unit] call A3A_fnc_resetPlayer;
};
Implementation Breakdown:

Checks if player ID exists in A3A_playerSaveData hashmap
If not found, logs info message and calls resetPlayer to set defaults
A3A_playerSaveData is populated during server load from saved players list
Step 3: Retrieve Player Data Hashmap

Apply
Info_2("Loading player data for ID %1 into unit %2", _playerId, _unit);

private _playerHM = A3A_playerSaveData get _playerID;
Logs loading operation
Retrieves the player's data hashmap from global A3A_playerSaveData
Step 4: Load Loadout

Apply
private _loadout = _playerHM get "loadoutPlayer";
if (!isNil "_loadout") then { _unit setUnitLoadout _loadout };
Gets the saved loadout from hashmap
Applies it to the unit if it exists
If loadout is nil, player keeps current loadout
Step 5: Load Score and Rank

Apply
private _score = 0;
private _rank = "PRIVATE";

private _saveScore = _playerHM get "scorePlayer";
if (!isNil "_saveScore" && { _saveScore isEqualType 0 }) then {_score = _saveScore};

private _saveRank = _playerHM get "rankPlayer";
if (!isNil "_saveRank" && { _saveRank isEqualType "" }) then {_rank = _saveRank};
Implementation Breakdown:

Initializes default values (0 score, "PRIVATE" rank)
Retrieves saved score with type checking (must be number)
Retrieves saved rank with type checking (must be string)
Type checking prevents corruption from invalid data
Step 6: Load Money

Apply
private _money = _playerHM get "moneyX";
if (isNil "_money" || {!(_money isEqualType 0)}) then {_money = initialPlayerMoney};
Retrieves saved money
If missing or not a number, defaults to initialPlayerMoney
Provides safe fallback for corrupted data
Step 7: Load Personal Garage

Apply
private _garage = _playerHM get "personalGarage";
if (isNil "_garage" || {!(_garage isEqualType [])}) then {_garage = []};
[_garage, _playerId] call HR_GRG_fnc_addVehiclesByClass;
Retrieves saved garage array
Defaults to empty array if missing/invalid
Calls garage system to add vehicles by class
Step 8: Apply Variables to Unit

Apply
_unit setVariable ["score", _score, true];
_unit setUnitRank _rank;
_unit setVariable ["rankX", _rank, true];
_unit setVariable ["moneyX", _money, true];

[] remoteExec ["A3A_fnc_statistics", _unit];
_unit setVariable ["canSave", true, true];
Sets score variable (public)
Sets unit rank via command
Sets rank variable (public)
Sets money variable (public)
Executes statistics update remotely on the unit's client
Enables save functionality for the unit
Step 9: Log Results

Apply
Info_5("Player %1: Score %2, rank %3, money %4, garage count %5", _playerId, _score, _rank, _money, count _garage);
Logs player restoration details for debugging
Where it leads:

Calls A3A_fnc_resetPlayer - When no save data exists
Calls HR_GRG_fnc_addVehiclesByClass - To restore personal garage
Calls A3A_fnc_statistics - Remote execution to update UI on player's client
Used by A3A_fnc_loadServer - When loading all saved players
Used by A3A_fnc_saveLoop - Not directly, but during player saving
Dependencies:

A3A_playerSaveData - Global hashmap containing all player data
A3A_fnc_resetPlayer - Reset function for missing saves
HR_GRG_fnc_addVehiclesByClass - Garage system function
A3A_fnc_statistics - Statistics display function
initialPlayerMoney - Global default money value
Global Variables Modified:

Unit variables: score, rankX, moneyX, canSave
A3A_playerSaveData - Read-only (populated during server load)
No network synchronization (unit variables are public)
Technical Details:

Performance: Fast, O(1) hashmap lookups
Type safety: Extensive type checking on loaded data
Public variables: Set with true parameter for JIP compatibility
Remote execution: remoteExec sends statistics update to player's client
Edge Cases Handled:

Missing player data (calls resetPlayer)
Missing loadout (skips loading)
Invalid score/rank type (uses defaults)
Invalid money (uses default)
Invalid garage (uses empty array)
Server-only enforcement (prevents desync)
Error Handling:

Silent handling of missing variables
Defaults provided for all optional data
No exceptions thrown (Arma SQF doesn't have exceptions)
Function: fn_loadServer.sqf
What it does: This is the main server load function. It restores the entire game state from a saved game, including map state, resources, garrisons, player data, enemy states, and all game mechanics. It's called when loading a saved game during mission initialization.

How it does that:

Step 1: Initialization and Setup

Apply
if (isServer) then {
    Info("loadServer Starting.");
	petros allowdamage false;

    // ... rest of function ...
};
Ensures server-only execution
Disables damage on Petros (HQ unit) during load
Logs function start
Step 2: Set Default Marker States

Apply
{
    if (sidesX getVariable _x != Occupants) then { sidesX setVariable [_x, Occupants, true] };
} forEach (airportsX + resourcesX + factories + outposts + seaports + milbases);
Sets all main markers to Occupant control by default
Later overridden by actual saved states (mrkSDK, mrkCSAT)
Step 3: Load Core Save Variables

Apply
A3A_saveVersion = 0;
["version"] call A3A_fnc_getStatVariable;
["mrkSDK"] call A3A_fnc_getStatVariable;
["mrkCSAT"] call A3A_fnc_getStatVariable;
// ... dozens more calls ...
Implementation Breakdown:

Initializes A3A_saveVersion to 0
Calls fn_getStatVariable for each save variable in sequence
Each call loads one variable and applies its effects via fn_loadStat
Loads in specific order (version first, then territory, then resources, etc.)
Step 4: Load Antistasi Plus Variables

Apply
// Antistasi Plus variables
["watchpostsFIA"] call A3A_fnc_getStatVariable; publicVariable "watchpostsFIA";
["roadblocksFIA"] call A3A_fnc_getStatVariable; publicVariable "roadblocksFIA";
// ... more plus variables ...
Loads faction-specific features (watchposts, roadblocks, etc.)
Publics each variable for client synchronization
Step 5: Restore Unlocked Arsenal Categories

Apply
private _categoriesToPublish = createHashMap;
{
    private _arsenalTabDataArray = _x;
    private _unlockedItemsInTab = _arsenalTabDataArray select { _x select 1 == -1 } apply { _x select 0 };
    {
        private _categories = [_x, true, true] call A3A_fnc_unlockEquipment;
        _categoriesToPublish insert [true, _categories, []];
    } forEach _unlockedItemsInTab;
} forEach jna_dataList;

Info_1("Categories to publish: %1", keys _categoriesToPublish);
{ publicVariable ("unlocked" + _x) } forEach keys _categoriesToPublish;
Processes jna_dataList to restore unlocked equipment
Determines which categories are unlocked
Publishes unlocked{Category} variables for clients
Uses hashmap to avoid duplicate publications
Step 6: Check Radio Unlock Status

Apply
call A3A_fnc_checkRadiosUnlocked;
Calls function to update haveRadio global variable based on unlocked equipment
Step 7: Set Enemy Roadblock Allegiance

Apply
private _mainMarkers = markersX - controlsX -  watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - hmgpostsFIA;
{
    if (sidesX getVariable [_x,sideUnknown] != teamPlayer) then {
        private _nearX = [_mainMarkers, markerPos _x] call BIS_fnc_nearestPosition;
        private _sideX = sidesX getVariable [_nearX,sideUnknown];
        sidesX setVariable [_x,_sideX,true];
    };
} forEach controlsX;
Finds nearest main marker for each control point
Sets control point allegiance to match nearest main marker
Skips teamPlayer-controlled controls
Step 8: Update Markers and Add FIA Outposts

Apply
{
    [_x] call A3A_fnc_mrkUpdate
} forEach (markersX - controlsX);

if (count watchpostsFIA > 0) then {
    markersX = markersX + watchpostsFIA;
    publicVariable "markersX";
};
// ... similar for other FIA outpost types ...
Updates all non-control markers
Adds FIA outpost markers to main markers list
Publics updated markers array
Step 9: Destroyed Cities Processing

Apply
{
    if (_x in destroyedSites) then {
        sidesX setVariable [_x, Invaders, true];
        [_x] call A3A_fnc_destroyCity
    };
} forEach citiesX;
Checks each city against destroyedSites array
Marks destroyed cities as Invader-controlled
Calls destroyCity to apply visual effects
Step 10: Load Aggression and Rivals Activity

Apply
["aggressionOccupants"] call A3A_fnc_getStatVariable;
["aggressionInvaders"] call A3A_fnc_getStatVariable;
[true] call A3A_fnc_calculateAggression;

["inactivityRivals"] call A3A_fnc_getStatVariable;
[true] call SCRT_fnc_rivals_calculateActivity;
Loads aggression stacks and levels
Recalculates current aggression levels
Loads rivals inactivity and recalculates activity
Step 11: Load Special Variables

Apply
["chopForest"] call A3A_fnc_getStatVariable;
["posHQ"] call A3A_fnc_getStatVariable;
["nextTick"] call A3A_fnc_getStatVariable;
["staticsX"] call A3A_fnc_getStatVariable;
Loads HQ position, forest state, timer values, and static objects
Step 12: Reset Playable Units to HQ

Apply
{_x setPos getMarkerPos respawnTeamPlayer} forEach ((call A3A_fnc_playableUnits) select {side _x == teamPlayer});
Teleports all rebel players to respawn point at HQ
Step 13: Move Headless Client Objects

Apply
private _hcpos = markerPos respawnTeamPlayer vectorAdd [-100, -100, 0];
{ _x setPosATL _hcpos } forEach (entities "HeadlessClient_F");
Positions headless client logic objects near HQ for reliability
Step 14: Initialize War Tier

Apply
tierPreference = 1;
publicVariable "tierPreference";
[true] call A3A_fnc_tierCheck;
Sets default war tier
Calls tier check to update preference
Step 15: Handle Garrison (Wurzel vs Legacy)

Apply
if (isNil "usesWurzelGarrison") then {
    // Create new garrison
    [airportsX, "Airport", [0,0,0]] spawn A3A_fnc_createGarrison;
    // ... more garrison creations ...
} else {
    // Load Wurzel format garrison
    ["wurzelGarrison"] call A3A_fnc_getStatVariable;
};
Detects save type (Wurzel vs legacy format)
Creates new garrisons if using legacy format
Loads Wurzel garrison data if using new format
Step 16: Load Testing Timer State

Apply
["testingTimerIsActive"] call A3A_fnc_getStatVariable;
Loads and applies testing timer state
Step 17: Load Player Data into Hashmaps

Apply
_savedPlayers = "savedPlayers" call A3A_fnc_returnSavedStat;
if (isNil "_savedPlayers") then { _savedPlayers = [] };
{
    private _uid = _x;
    private _playerData = createHashMap;
    {
        _playerData set [_x, [_uid, _x] call A3A_fnc_retrievePlayerStat];
    } forEach ["moneyX", "loadoutPlayer", "scorePlayer", "rankPlayer", "personalGarage"];

    if (isNil {_playerData get "moneyX"}) then { Error_1("Saved player %1 has no money var", _uid); continue };
    A3A_playerSaveData set [_uid, _playerData];
} forEach _savedPlayers;
Retrieves list of saved player UIDs
For each player, creates a hashmap with their data
Loads each player's 5 variables
Validates money exists (critical)
Stores in A3A_playerSaveData for later use
Step 18: Load Tasks and Finalize

Apply
["tasks"] call A3A_fnc_getStatVariable;

statsLoaded = 0; publicVariable "statsLoaded";
petros allowdamage true;

{specialVarLoads deleteAt _x;} forEach (keys specialVarLoads);
specialVarLoads = nil;
Loads active tasks
Sets stats loaded flag
Re-enables Petros damage
Cleans up specialVarLoads hashmap
Where it leads:

Calls dozens of functions - fn_getStatVariable, fn_loadStat, fn_unlockEquipment, etc.
Calls fn_calculateAggression - To recalculate aggression levels
Calls SCRT_fnc_rivals_calculateActivity - To recalculate rivals activity
Calls fn_mrkUpdate - To update marker states
Calls fn_destroyCity - For destroyed cities
Calls fn_createGarrison - For legacy garrison creation
Calls fn_retrievePlayerStat - For each saved player's data
Called by mission load system - During server initialization
Used by save system - Main entry point for loading saves
Dependencies:

A3A_fnc_getStatVariable - Core variable loading
A3A_fnc_loadStat - Special variable handling
A3A_fnc_unlockEquipment - Arsenal system
A3A_fnc_calculateAggression - Aggression calculation
A3A_fnc_mrkUpdate - Marker updates
A3A_fnc_retrievePlayerStat - Player data retrieval
Global arrays: airportsX, resourcesX, factories, etc.
Global hashmaps: A3A_playerSaveData
Global Variables Modified:

A3A_saveVersion - Save version
statsLoaded - Loading completion flag
tierPreference - War tier
jna_dataList - Arsenal data
haveRadio - Radio availability
sidesX - Marker allegiance
destroyedSites - Destroyed locations
A3A_playerSaveData - Player save data
specialVarLoads - Special variables registry (cleaned up)
petros - Damage state
markersX - Marker list
watchpostsFIA, roadblocksFIA, etc. - FIA outposts
jna_dataList - Arsenal data
Network Implications:

Publics multiple variables: watchpostsFIA, roadblocksFIA, markersX, haveRadio, statsLoaded, etc.
Executes remote functions on players: A3A_fnc_statistics
Modifies public marker states via sidesX
All changes are public for JIP compatibility
Technical Details:

Performance: Heavy - loads hundreds of variables and processes thousands of objects
Order matters: Some variables depend on others being loaded first
Type safety: Uses fn_loadStat for special handling and validation
Error handling: Logs errors but continues loading
Asynchronous: Uses spawn for garrison creation
Edge Cases Handled:

Missing savedPlayers (defaults to empty array)
Missing money on player (logs error, skips player)
Missing usesWurzelGarrison (creates legacy garrison)
Missing specialVarLoads (initializes new hashmaps)
Petros damage during load (disabled)
Headless clients (repositioned)
Known Issues:

Load order dependencies not fully documented
Some variables might load in wrong order causing issues
Performance impact could be significant with large saves
No timeout or progress reporting
Function: fn_loadStat.sqf
What it does: This function handles loading of individual save variables, with special logic for complex variables that need processing beyond simple assignment. It contains switch statements for dozens of special variables that require custom loading logic.

How it does that:

Step 1: Initialize Special Variables Registry

Apply
if (isNil "specialVarLoads") then {
    specialVarLoads = [
        "minesX","staticsX","antennas","mrkNATO","mrkSDK",
        // ... 35+ more variable names ...
    ] createHashMapFromArray [];
};
Creates a hashmap registry of special variables
These variables require custom loading logic
Uses createHashMapFromArray for efficient lookup
Step 2: Check if Variable is Special

Apply
if (_varName in specialVarLoads) then {
    // Special handling switch statement
} else {
    call compile format ["%1 = %2",_varName,_varValue];
};
Step 3: Special Variable Switch Statement (Examples)
Version:


Apply
case 'version': {
    _s = _varValue splitString ".";
    if (count _s < 2) exitWith {
        Error_1("Bad version string: %1", _varValue);
    };
    A3A_saveVersion = 10000*parsenumber(_s#0) + 100*parseNumber(_s#1);
    if (count _s == 3) then {
        A3A_saveVersion = A3A_saveVersion + parseNumber(_s#2);
    };
};
Parses version string (e.g., "2.5.1")
Converts to numeric format (25100)
Stores in A3A_saveVersion
Bomb Runs:


Apply
case 'bombRuns': {
    bombRuns = _varValue; 
    publicVariable "bombRuns";
};
Simple assignment with publicVariable for sync
MembersX:


Apply
case 'membersX': {
    membersX = +_varValue; 
    publicVariable "membersX";
};
Uses +_varValue to create a copy (prevents reference issues)
Public for client synchronization
Markets (mrkSDK, mrkCSAT, mrkNATO):


Apply
case 'mrkSDK': {
    {sidesX setVariable [_x,teamPlayer,true]} forEach _varValue;
};
Iterates through saved marker array
Sets each marker's side in sidesX namespace
Third parameter true makes it public
Aggression:


Apply
case 'aggressionOccupants': {
    aggressionLevelOccupants = _varValue select 0;
    aggressionStackOccupants = +(_varValue select 1);
    [true] spawn A3A_fnc_calculateAggression;
};
Unpacks level and stack from saved array
Spawns calculation function to update current level
Garrison (Legacy Format):


Apply
case 'garrison': {
    private _loadoutNames = createHashMapFromArray ((...));
    {
        private _marker = _x select 0;
        private _garrison = [];
        private _replacements = switch (sidesX getVariable _marker) do {...};
        
        {
            // ... validation and normalization ...
            _garrison pushBack _x;
        } forEach (_x select 1);

        garrison setVariable [_marker, _garrison, true];
        if (count _x > 2) then { garrison setVariable [_marker + "_lootCD", _x select 2, true] };
        // ... more garrison data ...
    } forEach _varvalue;
};
Complex processing for garrison data
Normalizes loadout names (compatibility)
Handles loot cooldowns, POW cooldowns, SAM destroyed cooldowns
Stores in garrison namespace
Static Objects:


Apply
case 'staticsX': {
    private _list = +_varValue;
    private _index = count _list;
    
    // Sort by restore priority
    _list = _list apply {...};
    _list sort false;
    
    _list apply {
        _x params["","","_data"];
        _data params ["_typeVehX", "_posVeh", "_xVectorUp", "_xVectorDir", "_state", "_customization", "_flipped"];
        private _veh = createVehicle [_typeVehX,[0,0,1000],[],0,"CAN_COLLIDE"];
        // ... set position, vector, etc. ...
        [_veh, teamPlayer] call A3A_fnc_AIVEHinit;
        // ... handle buyable items, buildings, state, customization, flipping ...
    };
};
Creates static vehicles/buildings from saved data
Handles old vs new save format (getDir vs vectorDir)
Initializes with AIVEHinit
Restores state, customization, and flipping
Adds to appropriate save arrays
Garrison (Wurzel Format):


Apply
case 'wurzelGarrison': {
    {
        garrison setVariable [format ["%1_garrison", (_x select 0)], +(_x select 1), true];
        garrison setVariable [format ["%1_requested", (_x select 0)], +(_x select 2), true];
        garrison setVariable [format ["%1_over", (_x select 0)], +(_x select 3), true];
        [(_x select 0)] call A3A_fnc_updateReinfState;
    } forEach _varvalue;
};
Loads Wurzel format garrison data
Sets garrison, requested, and over-strength arrays
Calls update function to refresh state
Antennas:


Apply
case 'antennas': {
    antennasDead = [];
    for "_i" from 0 to (count _varvalue - 1) do {
        _posAnt = _varvalue select _i;
        _mrk = [mrkAntennas, _posAnt] call BIS_fnc_nearestPosition;
        _antenna = [antennas,_mrk] call BIS_fnc_nearestPosition;
        {if (([antennas,_x] call BIS_fnc_nearestPosition) == _antenna) then {[_x,false] spawn A3A_fnc_blackout}} forEach citiesX;
        antennas = antennas - [_antenna];
        antennasDead pushBack _antenna;
        _antenna removeAllEventHandlers "Killed";
        
        private _ruin = [_antenna] call BIS_fnc_createRuin;
        if !(isNull _ruin) then {
            [_antenna, true] remoteExec ["hideObject", 0, _ruin];
        } else {
            Error_1("Loading Antennas: Unable to create ruin for %1", typeOf _antenna);
        };
        deleteMarker _mrk;
    };
    publicVariable "antennas";
    publicVariable "antennasDead";
};
Processes dead antenna positions
Finds corresponding antenna and marker
Blackouts affected cities
Creates ruin objects
Hides original antenna on all clients
Deletes antenna marker
Publics updated arrays
Prestige (OPFOR/BLUFOR):


Apply
case 'prestigeOPFOR': {
    if (count citiesX != count _varValue) exitWith {};
    for "_i" from 0 to (count citiesX) - 1 do {
        _city = citiesX select _i;
        _dataX = server getVariable _city;
        _numCiv = _dataX select 0;
        _numVeh = _dataX select 1;
        _prestigeOPFOR = _varvalue select _i;
        _prestigeBLUFOR = _dataX select 3;
        _dataX = [_numCiv,_numVeh,_prestigeOPFOR,_prestigeBLUFOR];
        server setVariable [_city,_dataX,true];
    };
};
Updates city prestige values
Handles city count mismatch (exits silently)
Retrieves current city data
Updates prestige values while preserving other data
Sets back to server namespace
Static Weapons/Buildings/Constructions:


Apply
case 'constructionsX': {
    for "_i" from 0 to (count _varvalue) - 1 do {
        _typeVehX = _varvalue select _i select 0;
        _posVeh = _varvalue select _i select 1;
        _xVectorUp = _varvalue select _i select 2;
        _xVectorDir = _varvalue select _i select 3;
        private _veh = createVehicle [_typeVehX,[0,0,1000],[],0,"CAN_COLLIDE"];
        _veh setPosWorld _posVeh;
        _veh setVectorDirAndUp [_xVectorDir,_xVectorUp];
        constructionsToSave pushBack _veh;
    };
    publicVariable "constructionsToSave";
};
Creates construction objects
Sets world position and orientation
Adds to constructions array
Publics the array for clients
FIA Outposts:


Apply
case 'watchpostsFIA': {
    if (count (_varValue select 0) == 2) then {
    {
            _positionX = _x select 0;
            _garrison = _x select 1;
            _mrk = createMarker [format ["FIAWatchpost%1", random 1000], _positionX];
            _mrk setMarkerShape "ICON";
            _mrk setMarkerType "n_recon";
            _mrk setMarkerColor colorTeamPlayer;
            _mrk setMarkerText format [localize "STR_marker_watchpost",FactionGet(reb,"name")];
            spawner setVariable [_mrk,2,true];
            if (count _garrison > 0) then {garrison setVariable [_mrk,_garrison,true]};
            watchpostsFIA pushBack _mrk;
            sidesX setVariable [_mrk,teamPlayer,true];
        } forEach _varvalue;
    };
};
Creates FIA watchpost markers
Sets marker properties (icon, color, text)
Stores in spawner namespace
Sets garrison if present
Adds to watchpostsFIA array
Sets side to teamPlayer
Rivals System:


Apply
case 'areRivalsDefeated': {
    Info_1("Rivals defeated: %1", str _varvalue);
    areRivalsDefeated = _varvalue;
    publicVariable "areRivalsDefeated";
};
Simple assignment for rivals state
Publics for client synchronization
Revealed Zones:


Apply
case 'revealedZones': {
    revealedZones = _varValue;

    if (isNil "revealedZones") then {
        revealedZones = [];
    };

    publicVariable "revealedZones";
};
Assigns revealed zones array
Ensures it's not nil
Publics for clients
Step 4: Non-Special Variables (Fallback)

Apply
call compile format ["%1 = %2",_varName,_varValue];
For non-special variables, uses call compile to assign
Simple assignment: variableName = variableValue
Where it leads:

Calls dozens of functions - AIVEHinit, blackout, calculateAggression, updateReinfState, etc.
Uses call compile - For simple variable assignments
Publics variables - For many special cases
Called by fn_getStatVariable - Which is called by fn_loadServer
Used during save loading - For every variable
Dependencies:

specialVarLoads - Registry of special variables
Global namespaces: sidesX, garrison, server, spawner
Global arrays: airportsX, resourcesX, etc.
A3A_fnc_AIVEHinit - Vehicle initialization
A3A_fnc_blackout - City blackout effect
A3A_fnc_calculateAggression - Aggression calculation
A3A_fnc_updateReinfState - Garrison state update
HR_GRG_fnc_setState - Vehicle state restoration
BIS_fnc_initVehicle - Vehicle customization
Global Variables Modified:

Hundreds of variables modified via special handling
Each case in switch modifies specific globals:
Version, bomb runs, members, markers, aggression, garrison, statics, etc.
Multiple FIA outpost arrays: watchpostsFIA, roadblocksFIA, etc.
Rivals variables: areRivalsDefeated, rivalsLocationsMap, etc.
Market/trader variables: traderDiscount, traderPosition, etc.
Revealed zones, unlocked vehicle types
Network Implications:

Publics many variables: bombRuns, membersX, chopForest, staticsToSave, etc.
Remote executes blackout effects
Modifies public marker states via sidesX
All changes are public for JIP compatibility
Technical Details:

Performance: Variable - depends on complexity of loaded data
Error handling: Logs errors but continues (except version parsing)
Type safety: Extensive validation in special cases
Memory: Creates many temporary arrays/hashmaps
Compatibility: Handles old save formats
Edge Cases Handled:

Missing specialVarLoads (initializes new)
Invalid version string (logs error)
City count mismatch in prestige (exits)
Missing garrison loadout names (creates default)
Old static object format (handles both getDir and vectorDir)
Nil revealed zones (initializes empty array)
Known Issues:

call compile for non-special variables is vulnerable to code injection
Some special cases might have performance issues
Memory usage could be high with large saves
No validation of loaded data values
Function: fn_resetPlayer.sqf
What it does: This function resets a player's data to default values when no save exists. It preserves any existing money the player had if available, preventing loss of money when a new player joins.

How it does that:

Step 1: Parameter Validation and Server Check

Apply
if (!isServer) exitWith {
    Error("Miscalled server-only function");
};

params ["_playerId", "_unit"];
Ensures server-only execution
Extracts player ID and unit
Step 2: Log Reset Operation

Apply
Info_2("Resetting player data for ID %1, unit %2", _playerId, _unit);
Logs the reset for debugging
Step 3: Determine Money (Preserve Existing)

Apply
private _money = initialPlayerMoney;
if (_playerId in A3A_playerSaveData) then {
    private _oldMoney = A3A_playerSaveData get _playerId get "moneyX";
    if !(isNil "_oldMoney") then { _money = _money min _oldMoney };
};
Starts with default initial money
Checks if player data exists in save hashmap
If exists, retrieves old money value
Uses minimum of default and old money to prevent gaining money on reset
Step 4: Apply Default Values to Unit

Apply
_unit setVariable ["moneyX", _money, true];
_unit setVariable ["score", 0, true];
_unit setVariable ["rankX", "PRIVATE", true];
_unit setUnitRank "PRIVATE";

[] remoteExec ["A3A_fnc_statistics", _unit];
_unit setVariable ["canSave", true, true];
Sets money (preserved or default)
Resets score to 0
Sets rank to "PRIVATE"
Executes statistics update remotely
Enables save functionality
Where it leads:

Used by fn_loadPlayer - When no save data exists
Calls A3A_fnc_statistics - Remote execution on player's client
Called by fn_loadServer - During player data loading
Called by A3A_fnc_onPlayerDisconnect - Not directly, but similar logic
Dependencies:

A3A_playerSaveData - Global hashmap for player data
initialPlayerMoney - Global default money value
A3A_fnc_statistics - Statistics display function
Global Variables Modified:

Unit variables: moneyX, score, rankX, canSave
No network synchronization beyond unit variables (public)
Technical Details:

Performance: Very fast, minimal operations
Safety: Preserves old money if available
Public variables: Set with true parameter
Edge Cases Handled:

Missing player data (uses default money)
Missing money in save data (uses default money)
Player has more money than default (preserves player's money)
Known Issues:

No type checking on old money value
Could potentially preserve corrupted money data
Function: fn_retrievePlayerStat.sqf
What it does: This function retrieves a specific player variable from persistent storage. It constructs the variable name based on player UID and returns the saved value.

How it does that:

Step 1: Parameter Validation

Apply
if (isNil "_playerUID" || isNil "_varName") exitWith {Error_2("Load invalid for player %1 var %2", _playerUID, _varName)};
Checks for missing parameters
Logs error and exits if either is nil
Step 2: Construct Variable Name

Apply
private _playerVarName = format ["player_%1_%2", _playerUID, _varName];
Builds the complete save variable name
Format: player_{uid}_{varName}
Step 3: Retrieve Value

Apply
[_playerVarName] call A3A_fnc_returnSavedStat;
Calls returnSavedStat to get the value
Returns the value (or nil if not found)
Where it leads:

Calls A3A_fnc_returnSavedStat - Core retrieval function
Used by fn_loadServer - When loading player data into hashmaps
Used by fn_savePlayerStat - Not directly, but similar logic
Dependencies:

A3A_fnc_returnSavedStat - Core save retrieval
A3A_saveTarget - Global save target
Global Variables Modified:

None - Pure retrieval function
Technical Details:

Performance: Fast, just string formatting and function call
Error handling: Logs error for nil parameters
Returns: Saved value or nil
Edge Cases Handled:

Missing player UID (logs error, exits)
Missing variable name (logs error, exits)
Missing variable in save (returns nil via returnSavedStat)
Known Issues:

No validation of player UID format
No type checking on variable name
Function: fn_returnSavedStat.sqf
What it does: This function retrieves a single variable from the persistent storage for the current save target. It handles both mission profile namespace and profile namespace saves.

How it does that:

Step 1: Extract Variable Name and Save Target

Apply
params ["_varname"];
A3A_saveTarget params ["_serverID", "_campaignID", "_map"];
Unpacks the variable name parameter
Extracts current save target components
Step 2: Handle Mission Profile Namespace Saves

Apply
if (_serverID isEqualType false) exitWith {
    missionProfileNamespace getVariable format ["%1%2", _varName, _campaignID];
};
Checks if save target is mission profile (serverID is boolean false)
Constructs variable name: {varName}{campaignID}
Retrieves from mission profile namespace
Exits early
Step 3: Handle Profile Namespace Saves

Apply
private _saveExt = format["%1%2Antistasi%3",_serverID,_campaignID,_map];
private _varValue = profileNamespace getVariable (_varname + _saveExt);
if (isNil "_varValue") exitWith {};
_varValue;
Constructs save extension for profile namespace: {serverID}{campaignID}Antistasi{map}
Gets variable with full name: {varName}{saveExt}
Checks if variable exists (not nil)
Returns the value or nil if not found
Where it leads:

Used by fn_getStatVariable - For single variable loading
Used by fn_retrievePlayerStat - For player-specific variables
Used by fn_collectSaveData - For collecting optional variables
Called by fn_loadServer - Through fn_getStatVariable
Dependencies:

A3A_saveTarget - Global save target state
profileNamespace - Legacy save storage
missionProfileNamespace - Modern save storage
Global Variables Modified:

None - Pure retrieval
Technical Details:

Performance: Fast, simple variable lookup
Type safety: No validation
Returns: Variable value or nil
Edge Cases Handled:

Mission profile saves (different variable naming)
Missing variables (returns nil)
Empty variable name (handled by string concatenation)
Known Issues:

Assumes A3A_saveTarget is properly set
No error if save target is malformed
Function: fn_saveLoop.sqf
What it does: This is the main save function that persists the current game state. It saves all server data (resources, garrisons, markers, etc.) and all player data (loadouts, scores, money, garage) to the appropriate namespace. It's called periodically by the autosave system or manually.

How it does that:

Step 1: Setup and Initialization

Apply
if (!isServer) exitWith {
    Error("Miscalled server-only function");
};

if (savingServer) exitWith {[localize "STR_A3A_save_persisent_save", localize "STR_A3A_save_save_game_desc"] remoteExecCall ["A3A_fnc_customHint",theBoss]};
savingServer = true;
Info("Starting persistent save");
[localize "STR_A3A_save_persisent_save",localize "STR_A3A_save_save_game_starting"] remoteExecCall ["A3A_fnc_customHint",0,false];
Ensures server-only execution
Checks for concurrent save operation
Sets savingServer flag to prevent duplicates
Logs and notifies clients of save start
Step 2: Set Next Autosave Time

Apply
autoSaveTime = time + autoSaveInterval;
Schedules next autosave
Prevents immediate re-save after manual save
Step 3: Select Save Namespace

Apply
A3A_saveTarget params ["_serverID", "_campaignID"];
private _saveToNewNamespace = _serverID isEqualType false;
if (!_saveToNewNamespace) then { profileNamespace setVariable ["ss_serverID", _serverID] };
private _namespace = [profileNamespace, missionProfileNamespace] select _saveToNewNamespace;
Determines which namespace to use
Sets legacy server ID for backwards compatibility
Selects appropriate namespace
Step 4: Save All Player Data

Apply
{
    [getPlayerUID _x, _x, true] call A3A_fnc_savePlayer;
} forEach (call A3A_fnc_playableUnits);
Iterates through all playable units
Calls savePlayer for each with global save flag
Saves loadout, score, rank, money, garage
Step 5: Write Player Data to Namespace

Apply
{
    private _uid = _x;
    private _playerData = _y;
    {
        if (isNil {_playerData get _x}) then { continue };
        [_uid, _x, _playerData get _x] call A3A_fnc_savePlayerStat;
    } forEach ["moneyX", "loadoutPlayer", "scorePlayer", "rankPlayer", "personalGarage"];
} forEach A3A_playerSaveData;
Iterates through A3A_playerSaveData hashmap
For each player, saves their 5 variables
Skips nil values
Calls savePlayerStat for each variable
Step 6: Save Player ID List

Apply
["savedPlayers", keys A3A_playerSaveData] call A3A_fnc_setStatVariable;
Saves list of all saved player UIDs
Stored as savedPlayers{postfix}
Step 7: Update Save List

Apply
private _saveList = [_namespace getVariable "antistasiUltimate2SavedGames"] param [0, [], [[]]];
_saveList deleteAt (_saveList findIf { _x select 0 == _campaignID });
_saveList pushBack [_campaignID, worldName, "Greenfor"];
_namespace setVariable ["antistasiUltimate2SavedGames", _saveList];
Retrieves save list
Finds and removes existing entry for current campaign
Adds updated entry to end (newest)
Saves back to namespace
Step 8: Update Legacy Campaign ID

Apply
if (!_saveToNewNamespace) then { _namespace setVariable ["ss_campaignID", _campaignID] };
For profile namespace, updates legacy campaign ID variable
Step 9: Save Mission Parameters

Apply
private _savedParams = [];
{
    if (getArray (_x/"texts") isEqualTo [""]) then { continue };
    _savedParams pushBack [configName _x, missionNameSpace getVariable configName _x];
} forEach ("true" configClasses (configFile/"A3A"/"Params"));
["params", _savedParams] call A3A_fnc_setStatVariable;
Collects all mission parameters from config
Filters out spacer/empty parameters
Saves as params{postfix}
Step 10: Save Selector Metadata

Apply
["name", A3A_saveData get "name"] call A3A_fnc_setStatVariable;
["factions", A3A_saveData get "factions"] call A3A_fnc_setStatVariable;
["DLC", A3A_saveData get "DLC"] call A3A_fnc_setStatVariable;
["addonVics", A3A_saveData get "addonVics"] call A3A_fnc_setStatVariable;
Saves save name, factions, DLC, and addon vehicles
Step 11: Save Core Game State

Apply
["version", QUOTE(VERSION_FULL)] call A3A_fnc_setStatVariable;
["saveTime", systemTimeUTC] call A3A_fnc_setStatVariable;
["gameMode", gameMode] call A3A_fnc_setStatVariable;
["difficultyX", skillMult] call A3A_fnc_setStatVariable;
["bombRuns", bombRuns] call A3A_fnc_setStatVariable;
["smallCAmrk", smallCAmrk] call A3A_fnc_setStatVariable;
["membersX", membersX] call A3A_fnc_setStatVariable;
Saves version, timestamp, game mode, difficulty
Saves bomb runs, small CA markers, members
Step 12: Save Antennas

Apply
private _antennasDeadPositions = [];
{ _antennasDeadPositions pushBack getPos _x; } forEach antennasDead;
["antennas", _antennasDeadPositions] call A3A_fnc_setStatVariable;
Collects positions of dead antennas
Saves as array of positions
Step 13: Save Markers

Apply
["mrkSDK", (markersX - controlsX -  watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - hmgpostsFIA) select {sidesX getVariable [_x,sideUnknown] == teamPlayer}] call A3A_fnc_setStatVariable;
["mrkCSAT", (markersX - controlsX) select {sidesX getVariable [_x,sideUnknown] == Invaders}] call A3A_fnc_setStatVariable;
Saves rebel-controlled markers (excludes controls and FIA outposts)
Saves invader-controlled markers (excludes controls)
Step 14: Save HQ Position and Special Objects

Apply
["posHQ", [getMarkerPos respawnTeamPlayer,[getDir boxX,getPos boxX],[getDir mapX,getPos mapX],getPos flagX,[getDir vehicleBox,getPos vehicleBox]]] call A3A_fnc_setStatVariable;
["dateX", date] call A3A_fnc_setStatVariable;
["skillFIA", skillFIA] call A3A_fnc_setStatVariable;
["destroyedSites", destroyedSites] call A3A_fnc_setStatVariable;
["distanceSPWN", distanceSPWN] call A3A_fnc_setStatVariable;
["chopForest", chopForest] call A3A_fnc_setStatVariable;
["nextTick", nextTick - time] call A3A_fnc_setStatVariable;
Saves HQ object positions and orientations
Saves date, skill, destroyed sites, spawn distance
Saves forest state, next tick timer (relative to current time)
Step 15: Save Weather

Apply
["weather",[fogParams,overcast,gusts,humidity,lightnings,rain,rainParams,rainbow,waves,wind,windDir,windStr]] call A3A_fnc_setStatVariable;
Saves comprehensive weather state
Step 16: Save Destroyed Buildings

Apply
private _destroyedPositions = destroyedBuildings apply { getPosATL _x };
["destroyedBuildings",_destroyedPositions] call A3A_fnc_setStatVariable;
Collects positions of destroyed buildings
Saves as array of positions
Step 17: Save Aggression

Apply
["aggressionOccupants", [aggressionLevelOccupants, aggressionStackOccupants]] call A3A_fnc_setStatVariable;
["aggressionInvaders", [aggressionLevelInvaders, aggressionStackInvaders]] call A3A_fnc_setStatVariable;
Saves aggression level and stack for both factions
Step 18: Save Plus Variables

Apply
["supportPoints", supportPoints] call A3A_fnc_setStatVariable;
["areOccupantsDefeated", areOccupantsDefeated] call A3A_fnc_setStatVariable;
["areInvadersDefeated", areInvadersDefeated] call A3A_fnc_setStatVariable;
["isTraderQuestCompleted", isTraderQuestCompleted] call A3A_fnc_setStatVariable;
// ... more plus variables ...
Saves Antistasi Plus features
Step 19: Save Rivals Variables

Apply
["areRivalsDefeated", areRivalsDefeated] call A3A_fnc_setStatVariable;
["areRivalsDiscovered", areRivalsDiscovered] call A3A_fnc_setStatVariable;
["rivalsLocationsMap", rivalsLocationsMap] call A3A_fnc_setStatVariable;
// ... more rivals variables ...
Saves rivals system state
Step 20: Save Destroyed Military Admins

Apply
private _milAdminPositions = [];
{ _milAdminPositions pushBack getPos _x; } forEach A3A_destroyedMilAdministrations;
["destroyedMilAdmins", _milAdminPositions] call A3A_fnc_setStatVariable;
Collects positions of destroyed military admins
Saves as array of positions
Step 21: Save Antistasi Ultimate Variables

Apply
private _revealedZones = [];

{
    private _markerSide = sidesX getVariable [_x, sideUnknown];
    if (_markerSide isNotEqualTo sideUnknown && {_markerSide isNotEqualTo resistance} && {!(_x in markersImmune)}) then 
    {
        private _dummyMarker = "Dum"+_x;
        if (markerAlpha _dummyMarker isNotEqualTo 0) then {_revealedZones pushBack _x};
    };
} forEach markersX;

["revealedZones", _revealedZones] call A3A_fnc_setStatVariable;

if (isNil "unlockedVehicleTypes") then {
    unlockedVehicleTypes = [];
};

["unlockedVehicleTypes", unlockedVehicleTypes] call A3A_fnc_setStatVariable;
Determines which zones are revealed
Saves revealed zones and unlocked vehicle types
Step 22: Calculate and Save Background Resources

Apply
private _hrBackground = (server getVariable "hr") + ({(alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == teamPlayer))} count allUnits);
private _resourcesBackground = server getVariable "resourcesFIA";
{
    _friendX = _x;
    if ((_friendX getVariable ["spawner",false]) and (side group _friendX == teamPlayer))then {
        if ((alive _friendX) and (!isPlayer _friendX)) then {
            if (group _friendX in (hcAllGroups theBoss)) then {
                _resourcesBackground = _resourcesBackground + (server getVariable [(_friendX getVariable "unitType"),0]) / 2;
                // ... more resource calculations ...
            };
        };
    };
} forEach allUnits;
Calculates background HR (active units not in garage)
Calculates background resources (units, vehicles, loot crates)
Complex calculations for resource management
Step 23: Save Resources and HR

Apply
["resourcesFIA", _resourcesBackground] call A3A_fnc_setStatVariable;
["hr", _hrBackground] call A3A_fnc_setStatVariable;
["HR_Garage", [] call HR_GRG_fnc_getSaveData] call A3A_fnc_setStatVariable;
Saves calculated resources and HR
Saves garage data from garage system
Step 24: Save Static Objects (HQ Area)

Apply
private _arrayEst = [];
{
    // Include buyable items marked as saveable
    if !(typeof _x in A3A_utilityItemHM and {"save" in (A3A_utilityItemHM get typeof _x)#4}) then {
        if (fullCrew [_x, "", true] isEqualTo []) then { continue };
        if (_x in staticsToSave) then { continue };
        if ({(alive _x) and (!isPlayer _x)} count crew _x > 0) then { continue };
    };

    _arrayEst pushBack [typeof _x, getPosWorld _x, vectorUp _x, vectorDir _x, [_x] call HR_GRG_fnc_getState, [_x] call BIS_fnc_getVehicleCustomization];

} forEach (vehicles inAreaArray [markerPos respawnTeamPlayer, 100, 100] select { alive _x });
Collects vehicles within 100m of HQ
Filters for valid, saveable vehicles
Includes position, orientation, state, customization
Adds to static objects array
Step 25: Save Static Weapons and Buildings

Apply
private _nearFriendlyMarker = {
    params ["_obj"];
    private _nearestMarker = [markersX, _obj] call BIS_fnc_nearestPosition;
    (sidesX getVariable [_nearestMarker, sideUnknown] isEqualTo teamPlayer) && {_obj inArea _nearestMarker};
};

{
    if ((!alive _x) || {(surfaceIsWater position _x) || {(!isNull attachedTo _x) || {(!(_x call _nearFriendlyMarker))}}}) then { continue };
    _arrayEst pushBack [typeOf _x, getPosWorld _x, vectorUp _x, vectorDir _x, nil, [_x] call BIS_fnc_getVehicleCustomization, _x in staticsToFlip];
} forEach staticsToSave;

private _rebMarkers = (airportsX + outposts + seaports + factories + resourcesX + milbases) select { sidesX getVariable _x == teamPlayer };
_rebMarkers pushBack "Synd_HQ";
{
    if (isOnRoad _x && {A3A_builderAllowRoads isEqualTo false}) then {continue};
    if (surfaceIsWater getPosASL _x) then {continue};

    _arrayEst pushBack [typeOf _x, getPosWorld _x, vectorUp _x, vectorDir _x];
} forEach A3A_buildingsToSave;

reverse _arrayEst;
["staticsX", _arrayEst] call A3A_fnc_setStatVariable;
Saves static weapons (from staticsToSave)
Saves buildings (from A3A_buildingsToSave)
Checks marker allegiance and water
Handles flipped vehicles
Reverses array for proper load order
Saves as staticsX
Step 26: Save Constructions

Apply
private _excessiveConstructions = maxConstructions - (count constructionsToSave);
if(_excessiveConstructions < 0) then {
    private _top = abs _excessiveConstructions;
    for "_i" from 0 to _top do {
        constructionsToSave deleteAt _i;
    };
};

_arrayConstructions = [];
{
    _positionX = position _x;
    if ((alive _x) and !(surfaceIsWater _positionX) and !(isNull _x)) then {
        _arrayConstructions pushBack [typeOf _x,getPosWorld _x,vectorUp _x, vectorDir _x];
    };
} forEach constructionsToSave;
["constructionsX", _arrayConstructions] call A3A_fnc_setStatVariable;
Trims constructions to max limit
Saves valid constructions (alive, not on water)
Saves as constructionsX
Step 27: Manage Arsenal

Apply
[] call A3A_fnc_arsenalManage;
Calls arsenal management function to update unlock data
Step 28: Save Arsenal Data

Apply
_jna_dataList = [];
_jna_dataList = _jna_dataList + jna_dataList;
["jna_dataList", _jna_dataList] call A3A_fnc_setStatVariable;
Copies and saves jna_dataList
Used for arsenal unlock state
Step 29: Save City Prestige

Apply
_prestigeOPFOR = [];
_prestigeBLUFOR = [];

{
    _city = _x;
    _dataX = server getVariable _city;
    _prestigeOPFOR = _prestigeOPFOR + [_dataX select 2];
    _prestigeBLUFOR = _prestigeBLUFOR + [_dataX select 3];
} forEach citiesX;

["prestigeOPFOR", _prestigeOPFOR] call A3A_fnc_setStatVariable;
["prestigeBLUFOR", _prestigeBLUFOR] call A3A_fnc_setStatVariable;
Collects prestige values for all cities
Saves as separate arrays
Step 30: Save Garrison

Apply
_markersX = markersX - controlsX - watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - hmgpostsFIA;
_garrison = [];
_wurzelGarrison = [];

{
    _garrison pushBack [
        _x,
        garrison getVariable [_x,[]],
        garrison getVariable [_x + "_lootCD", 0],
        garrison getVariable [_x + "_powCD", 0],
        garrison getVariable [_x + "_samDestroyedCD", 0]
    ];
    _wurzelGarrison pushBack [
        _x,
        garrison getVariable [format ["%1_garrison",_x], []],
        garrison getVariable [format ["%1_requested",_x], []],
        garrison getVariable [format ["%1_over", _x], []]
    ];
} forEach _markersX;

["garrison", _garrison] call A3A_fnc_setStatVariable;
["wurzelGarrison", _wurzelGarrison] call A3A_fnc_setStatVariable;
["usesWurzelGarrison", true] call A3A_fnc_setStatVariable;
Collects garrison data for all markers
Saves both legacy and Wurzel formats
Saves cooldown values
Sets usesWurzelGarrison flag
Step 31: Save Mines

Apply
_arrayMines = [];
private _mineChance = 500 / (500 max count allMines);
{
    if (random 1 > _mineChance) then { continue };
    _typeMine = typeOf _x;
    _posMine = getPos _x;
    _dirMine = getDir _x;
    _detected = [];
    if (_x mineDetectedBy teamPlayer) then { _detected pushBack teamPlayer };
    if (_x mineDetectedBy Occupants) then { _detected pushBack Occupants };
    if (_x mineDetectedBy Invaders) then { _detected pushBack Invaders };
    _arrayMines pushBack [_typeMine,_posMine,_detected,_dirMine];
} forEach allMines;

["minesX", _arrayMines] call A3A_fnc_setStatVariable;
Samples mines (down to ~500 to limit save size)
Saves type, position, detection status, direction
Saves as minesX
Step 32: Save FIA Outposts

Apply
private _arrayWatchpostsFIA = [];
{
    _positionOutpost = getMarkerPos _x;
    _arrayWatchpostsFIA pushBack [_positionOutpost,garrison getVariable [_x,[]]];
} forEach watchpostsFIA;
["watchpostsFIA", _arrayWatchpostsFIA] call A3A_fnc_setStatVariable;

// Similar for roadblocksFIA, aapostsFIA, atpostsFIA, hmgpostsFIA
Collects position and garrison for each FIA outpost
Saves separately for each outpost type
Step 33: Save Tasks (Client-Only)

Apply
if (!isDedicated) then {
    _typesX = [];
    {
        private _type = _x;
        private _index = A3A_tasksData findIf { (_x#1) isEqualTo _type and (_x#2) isEqualTo "CREATED" };
        if (_index != -1) then { _typesX pushBackUnique _type };
    } forEach ["AS","CON","DES","LOG","RES","TRADER","RIV_ENC","CONVOY","DEF_HQ","rebelAttack","invaderPunish"];
    ["tasks",_typesX] call A3A_fnc_setStatVariable;
};
Only runs on non-dedicated servers (mission host)
Saves active task types
Step 34: Calculate and Save Enemy Resources

Apply
private _resAttOcc = A3A_resourcesAttackOcc;
private _resDefOcc = A3A_resourcesDefenceOcc;
private _resAttInv = A3A_resourcesAttackInv;
private _resDefInv = A3A_resourcesDefenceInv;

{
    private _veh = _x;
    private _side = _veh getVariable ["ownerSide", teamPlayer];
    private _vehCost = A3A_vehicleResourceCosts getOrDefault [typeof _veh, 0];
    if (!alive _veh || (_side != Occupants && _side != Invaders) || _vehCost == 0) exitWith {};

    private _vehDamage = damage _veh;
    if (getAllHitPointsDamage _veh isNotEqualTo []) then {
        private _allHP = getAllHitPointsDamage _veh select 2;
        private _total = 0; { _total = _total + _x } forEach _allHP;
        _vehDamage = _vehDamage max (_total / count _allHP);
    };

    private _pool = _veh getVariable ["A3A_resPool", "legacy"];
    if (_pool == "legacy") then {
        if (_side == Occupants) then {
            _resAttOcc = _resAttOcc - _vehDamage*_vehCost/2;
            _resDefOcc = _resDefOcc - _vehDamage*_vehCost/2;
        } else {
            _resAttInv = _resAttInv - _vehDamage*_vehCost/2;
            _resDefInv = _resDefInv - _vehDamage*_vehCost/2;
        };
    } else {
        if (_side == Occupants) then {
            if (_pool == "attack") then { _resAttOcc = _resAttOcc + (1-_vehDamage)*_vehCost };
            if (_pool == "defence") then { _resDefOcc = _resDefOcc + (1-_vehDamage)*_vehCost };
        } else {
            if (_pool == "attack") then { _resAttInv = _resAttInv + (1-_vehDamage)*_vehCost };
            if (_pool == "defence") then { _resDefInv = _resDefInv + (1-_vehDamage)*_vehCost };
        };
    };
} forEach vehicles;

{
    if !(_x call A3A_fnc_canFight) then { continue };
    private _resPool = _x getVariable ["A3A_resPool", ""];
    if (_resPool == "defence") then { _resDefOcc = _resDefOcc + 10; continue };
    if (_resPool == "attack") then { _resAttOcc = _resAttOcc + 10 };
} forEach units Occupants;

{
    if !(_x call A3A_fnc_canFight) then { continue };
    private _resPool = _x getVariable ["A3A_resPool", ""];
    if (_resPool == "defence") then { _resDefInv = _resDefInv + 10; continue };
    if (_resPool == "attack") then { _resAttInv = _resAttInv + 10 };
} forEach units Invaders;

// Adjust for player scale
_resDefOcc = _resDefOcc / A3A_balancePlayerScale;
_resDefInv = _resDefInv / A3A_balancePlayerScale;

["enemyResources", [_resDefOcc, _resDefInv, _resAttOcc, _resAttInv]] call A3A_fnc_setStatVariable;
Calculates enemy resources based on active units and vehicles
Handles damage and resource pools
Adjusts for player scale
Saves as enemyResources
Step 35: Save HQ Knowledge

Apply
["HQKnowledge", [A3A_curHQInfoOcc, A3A_curHQInfoInv, A3A_oldHQInfoOcc, A3A_oldHQInfoInv]] call A3A_fnc_setStatVariable;
Saves HQ intelligence knowledge
Step 36: Save Kill Zones

Apply
_dataX = [];
{
    _dataX pushBack [_x,killZones getVariable [_x,[]]];
} forEach airportsX + outposts + milbases;

["killZones",_dataX] call A3A_fnc_setStatVariable;
Collects kill zone data for military bases
Step 37: Save Controls (SDK)

Apply
_controlsX = controlsX select {(sidesX getVariable [_x,sideUnknown] == teamPlayer) and (controlsX find _x < defaultControlIndex)};
["controlsSDK",_controlsX] call A3A_fnc_setStatVariable;
Saves rebel-controlled controls
Only hard-coded controls (up to defaultControlIndex)
Step 38: Save Fuel Stations

Apply
_fuelAmountleftArray = [];
{
    if (A3A_hasACE) then {
        private _keyPairsFuel = [position _x, [_x] call ace_refuel_fnc_getFuel];
        _fuelAmountleftArray pushback _keyPairsFuel;
    } else {
        private _keyPairsFuel = [position _x, getFuelCargo _x];
        _fuelAmountleftArray pushback _keyPairsFuel;
    };
} forEach A3A_fuelStations;
["A3A_fuelAmountleftArray",_fuelAmountleftArray] call A3A_fnc_setStatVariable;
Collects fuel station positions and fuel amounts
Handles ACE and vanilla fuel systems
Saves as array of [position, fuelAmount]
Step 39: Save Testing Timer

Apply
["testingTimerIsActive", testingTimerIsActive] call A3A_fnc_setStatVariable;
Saves testing timer state
Step 40: Save Namespace

Apply
if (_saveToNewNamespace) then { saveMissionProfileNamespace } else { saveProfileNamespace };
Saves the appropriate namespace to disk
Step 41: Finalization and Notification

Apply
savingServer = false;
_saveHintText = [
    "<t size='1.5'>",FactionGet(reb,"name"),
    " Assets:<br/><t color='#f0d498'>HR: ",
    _hrBackground toFixed 0,
    "<br/>Money: ",
    _resourcesBackground toFixed 0,
    A3A_faction_civ get "currencySymbol",
    "</t></t><br/><br/>"
] joinString "";
[localize "STR_A3A_save_persisent_save",_saveHintText] remoteExecCall ["A3A_fnc_customHint",0,false];
Info("Persistent Save Completed");
Resets saving flag
Builds success notification with resources
Sends notification to all clients
Logs completion
Where it leads:

Calls dozens of functions - fn_savePlayer, fn_savePlayerStat, fn_setStatVariable, fn_arsenalManage, fn_getSaveData, etc.
Calls namespace save functions - saveProfileNamespace, saveMissionProfileNamespace
Used by autosave system - Periodic save
Used by manual save - Player-triggered save
Calls fn_customHint - For user notifications
Calls A3A_fnc_canFight - For enemy resource calculation
Dependencies:

A3A_fnc_savePlayer - Player save function
A3A_fnc_savePlayerStat - Player variable save
A3A_fnc_setStatVariable - Variable save
A3A_fnc_arsenalManage - Arsenal management
HR_GRG_fnc_getSaveData - Garage save data
HR_GRG_fnc_getState - Vehicle state
BIS_fnc_getVehicleCustomization - Vehicle customization
A3A_fnc_customHint - Notification system
A3A_fnc_canFight - Unit combat check
ace_refuel_fnc_getFuel - ACE fuel check (if ACE present)
Global arrays: airportsX, resourcesX, citiesX, etc.
Global hashmaps: A3A_playerSaveData, A3A_fuelStations, etc.
Global variables: savingServer, autoSaveTime, membersX, bombRuns, etc.
Global Variables Modified:

savingServer - Save flag
autoSaveTime - Next autosave time
A3A_playerSaveData - Read (populated during server load)
No network synchronization (save is server-side only)
Network Implications:

Publics variables: saveProfileNamespace/saveMissionProfileNamespace functions handle synchronization
Sends custom hints to all clients
No direct publicVariable calls for game state (storage handles it)
Technical Details:

Performance: Heavy - processes thousands of objects
Error handling: Logs errors but continues (except concurrent save check)
Memory: Uses temporary arrays for data collection
Order: Saves players first, then server data
Synchronization: Namespace save functions handle persistence
Edge Cases Handled:

Concurrent save prevention
Missing antistasiUltimate2SavedGames (defaults to empty array)
Invalid mission parameters (filtered out)
Missing unlockedVehicleTypes (initializes empty array)
Excessive constructions (trims to limit)
Mine sampling (prevents save bloat)
ACE fuel check (conditional)
Dedicated server vs mission host (task saving)
Known Issues:

Performance impact with large games
Memory usage with many objects
call compile used in save system (security risk)
Complex resource calculations (potential performance bottleneck)
No validation of saved data ranges
Some variables might be saved multiple times
Function: fn_savePlayer.sqf
What it does: This function collects a single player's data (loadout, score, rank, money, garage) and stores it in the global A3A_playerSaveData hashmap. It's called during save operations to gather player data before it's written to persistent storage.

How it does that:

Step 1: Parameter Validation and Server Check

Apply
if (!isServer) exitWith {
    Error("Miscalled server-only function");
};

params ["_playerId", "_playerUnit", ["_globalSave", false]];
Ensures server-only execution
Extracts parameters with optional globalSave flag
Step 2: Get Real Player Unit

Apply
_playerUnit = _playerUnit getVariable ["owner", _playerUnit];
If unit is remote-controlled AI, get the real player unit
Prevents saving remote controlled unit instead of player
Step 3: Validate Player ID and Unit

Apply
if (isNil "_playerId" || {_playerId == ""}) exitWith {
    Error_1("Not saving player of unit %1 due to missing UID", _playerUnit);
};

if (isNil "_playerUnit" || { isNull _playerUnit }) exitWith {
    Error_1("Not saving player %1 due to missing unit", _playerId);
};
Checks for missing UID or unit
Logs errors and exits
Step 4: Check Player Side

Apply
if (side group _playerUnit != teamPlayer && side group _playerUnit != sideUnknown) exitWith {
    Info_1("Not saving player %1 due to them being on the wrong team.", _playerId);
};
Only saves rebel players (teamPlayer) or unknown side
Logs info for wrong team players
Step 5: Check Save Permission

Apply
if !(_playerUnit getVariable ['canSave', false]) exitWith {
    Info_1("Not saving player %1 due to canSave being false.", _playerId);
};
Checks if player has save permission enabled
Prevents saving during initialization
Step 6: Check for Money Variable

Apply
if (isNil { _playerUnit getVariable "moneyX" }) exitWith {
    Error_1("Not saving player %1 due to missing variables. What happened here?", _playerId);
};
Validates that money variable exists (critical)
Exits with error if missing
Step 7: Get or Create Player Hashmap

Apply
Info_2("Saving player %1 on side %2", _playerId, side group _playerUnit);

private _playerHM = A3A_playerSaveData getOrDefault [_playerID, createHashMap, true];
Logs save operation
Gets existing player hashmap or creates new one
true parameter creates and stores if missing
Step 8: Determine Loadout Stripping

Apply
private _shouldStripLoadout = false;
if (!(alive _playerUnit) || (_playerUnit getVariable ["incapacitated", false])) then
{
	_shouldStripLoadout = true;
    Info_1("Stripping saved loadout of player %1 due to saving while dead or unconcious", _playerId);
};
Flags loadout for stripping if player is dead or unconscious
Logs the decision
Step 9: Get and Conditionally Strip Loadout

Apply
private _loadout = getUnitLoadout _playerUnit;
if (_shouldStripLoadout) then { _loadout = _loadout call A3A_fnc_stripGearFromLoadout };
_playerHM set ["loadoutPlayer", _loadout];
Retrieves current unit loadout
Strips gear if needed (removes weapons, magazines)
Stores in player hashmap
Step 10: Get Score and Rank

Apply
private _scorePlayer = _playerUnit getVariable ["score", 0];
private _rankPlayer = _playerUnit getVariable ["rankX", "PRIVATE"];
_playerHM set ["scorePlayer", _scorePlayer];
_playerHM set ["rankPlayer", _rankPlayer];
_playerHM set ["personalGarage", []];
Retrieves score and rank from unit variables
Stores in hashmap with default values
Initializes personal garage as empty array
Step 11: Calculate and Save Money

Apply
private _totalMoney = _playerUnit getVariable ["moneyX", 0];
if (_shouldStripLoadout) then { _totalMoney = round (_totalMoney * 0.85) };

if (_globalSave) then
{
	// Add value of live AIs owned by player
	{
		if (alive _x && (_x getVariable ["owner", objNull] == _playerUnit))
		{
			if (_x != _playerUnit) then {
				private _unitPrice = server getVariable [_x getVariable "unitType", 0];
				_totalMoney = _totalMoney + _unitPrice;
			};
			private _veh = vehicle _x;
			if (_veh == _x || {_veh in staticsToSave}) exitWith {};
			if (_x == driver _veh || {_x == gunner _veh && {_veh isKindOf "LandVehicle" || {_veh isKindOf "Ship"}}}) then {
				private _vehPrice = [typeof _veh] call A3A_fnc_vehiclePrice;
				_totalMoney = _totalMoney + _vehPrice;
			};
		};
	} forEach (units group _playerUnit);
};
_playerHM set ["moneyX", _totalMoney];
Starts with player's current money
Applies 15% penalty if loadout stripped
If globalSave flag is true:
Adds value of player-owned AI units
Adds value of vehicles driven by player-owned units
Calculates using A3A_fnc_vehiclePrice
Stores final money in hashmap
Step 12: Log Results

Apply
Info_4("Saved player %1: %2 rank, %3 money, %4 score", _playerId, _rankPlayer, _totalMoney toFixed 0, _scorePlayer);
Logs player save details for debugging
Where it leads:

Calls A3A_fnc_stripGearFromLoadout - To strip loadout if dead/unconscious
Calls A3A_fnc_vehiclePrice - For vehicle value calculation (globalSave)
Called by A3A_fnc_saveLoop - For each playable unit
Called by A3A_fnc_saveLoop - For background save (globalSave=true)
Used by save system - During save operations
Dependencies:

A3A_playerSaveData - Global hashmap for player data
A3A_fnc_stripGearFromLoadout - Loadout stripping function
A3A_fnc_vehiclePrice - Vehicle valuation function
server namespace - For unit type prices
Global arrays: staticsToSave
initialPlayerMoney - Default money (used elsewhere)
Global Variables Modified:

A3A_playerSaveData - Modified (player data added/updated)
No network synchronization (purely server-side)
Technical Details:

Performance: Fast, O(1) hashmap operations
Type safety: Extensive validation
Memory: Modifies hashmap in place
Edge Cases Handled:

Remote controlled players (gets real player)
Missing UID (exits)
Missing unit (exits)
Wrong team (skips)
No save permission (skips)
Missing money (exits with error)
Dead/unconscious loadout stripping
Global save with owned units/vehicles
Known Issues:

personalGarage always set to empty (might be intentional)
Global save calculations complex (performance)
No type checking on retrieved variables
Assumes unitType variable exists on units
Function: fn_savePlayerStat.sqf
What it does: This function saves a single player variable to persistent storage. It's a helper function that constructs the player variable name and calls fn_setStatVariable.

How it does that:

Step 1: Extract Parameters

Apply
params ["_playerUID", "_varName", "_varValue"];
Step 2: Validate Parameters

Apply
private _abort = false;

if (isNil "_playerUID") then {
	_playerUID = "";
	_abort = true;
};
if (isNil "_varName") then {
	_varName = "";
	_abort = true;
};
if (isNil "_varValue") then {
	_varValue = "";
	_abort = true;
};
if (_abort) exitWith {
    Error_3("Save invalid for %1, saving %3 as %2", _playerUID, _varName, _varValue);
};
Checks each parameter for nil
Sets to empty string and abort flag if missing
Logs error and exits if any parameter missing
Step 3: Construct Variable Name and Save

Apply
private _playerVarName = format ["player_%1_%2", _playerUID, _varName];
[_playerVarName, _varValue] call A3A_fnc_setStatVariable;
Builds variable name: player_{uid}_{varName}
Calls setStatVariable to save
Where it leads:

Calls A3A_fnc_setStatVariable - Core save function
Used by A3A_fnc_saveLoop - For saving player variables
Called by A3A_fnc_writebackSaveVar - Not directly, but similar pattern
Dependencies:

A3A_fnc_setStatVariable - Variable save function
A3A_saveTarget - Global save target
Global Variables Modified:

None - Delegates to setStatVariable
Technical Details:

Performance: Very fast
Error handling: Logs errors for nil parameters
Pattern: Wrapper around setStatVariable
Edge Cases Handled:

Missing parameters (sets to empty string, logs error)
Nil values (sets to empty string)
Known Issues:

Sets parameters to empty string on error (might not be ideal)
Function: fn_setStatVariable.sqf
What it does: This function saves a single variable to persistent storage for the current save target. It handles both mission profile namespace and profile namespace saves.

How it does that:

Step 1: Extract Parameters and Save Target

Apply
params ["_varName", "_varValue"];
A3A_saveTarget params ["_serverID", "_campaignID", "_map"];
Unpacks variable name and value
Extracts current save target components
Step 2: Validate Value

Apply
if (isNil "_varValue") exitWith {};			// hmm...
Silently exits if value is nil
Note comment indicates this might be questionable
Step 3: Handle Mission Profile Namespace Saves

Apply
if (_serverID isEqualType false) exitWith {
	missionProfileNamespace setVariable [format ["%1%2", _varName, _campaignID], _varValue];
};
Checks if save target is mission profile (serverID is boolean false)
Sets variable in mission profile namespace
Format: {varName}{campaignID}
Exits early
Step 4: Handle Profile Namespace Saves

Apply
private _saveExt = format["%1%2%3%4",_serverID,_campaignID,"Antistasi",_map];
profileNamespace setVariable [_varName + _saveExt, _varValue];
Constructs save extension: {serverID}{campaignID}Antistasi{map}
Sets variable in profile namespace
Format: {varName}{saveExt}
Where it leads:

Used by A3A_fnc_savePlayerStat - For player variables
Used by A3A_fnc_saveLoop - For all server variables
Used by A3A_fnc_writebackSaveVar - For single variable saves
Called by A3A_fnc_setStatVariable - Recursive pattern (but not actually)
Used during save operations - For all variable saves
Dependencies:

A3A_saveTarget - Global save target state
profileNamespace - Legacy save storage
missionProfileNamespace - Modern save storage
Global Variables Modified:

None - Modifies namespace variables (persistent storage)
Network Implications:

Namespace save functions (saveProfileNamespace, saveMissionProfileNamespace) handle synchronization
Values are saved to disk, available on server restart
Technical Details:

Performance: Fast, simple namespace operation
Error handling: Minimal (silently exits on nil value)
Returns: Nothing
Edge Cases Handled:

Mission profile vs profile namespace selection
Nil values (silently skipped)
Known Issues:

Silent exit on nil value (might hide errors)
Assumes A3A_saveTarget is properly set
No validation of variable name format
Function: fn_writebackSaveVar.sqf
What it does: This function writes a single variable to persistent storage and immediately saves the namespace. It's designed for one-off operations where immediate persistence is required.

How it does that:

Step 1: Log Operation

Apply
Info_1("Writing back save var with params %1", _this);
Logs the write operation
Step 2: Save and Restore Save Target

Apply
isNil {
    private _oldTarget = if (!isNil "A3A_saveTarget") then { A3A_saveTarget };
    if (!isNil "_saveTarget") then { A3A_saveTarget = _saveTarget };

    [_varname, _varValue] call A3A_fnc_setStatVariable;

    if (A3A_saveTarget#0 isEqualType false) then { saveMissionProfileNamespace } else { saveProfileNamespace };

    if (!isNil "_oldTarget") then { A3A_saveTarget = _oldTarget };
};
Uses isNil for guaranteed execution (prevents errors)
Saves current save target
Optionally sets new save target
Calls setStatVariable to save the variable
Immediately saves the namespace
Restores original save target
Where it leads:

Calls A3A_fnc_setStatVariable - To save the variable
Calls namespace save functions - saveProfileNamespace/saveMissionProfileNamespace
Used for one-off operations - Manual save operations, admin tools
Called by admin/mod functions - For fixing corrupted saves
Dependencies:

A3A_fnc_setStatVariable - Variable save function
A3A_saveTarget - Global save target
Namespace save functions
Global Variables Modified:

A3A_saveTarget - Temporarily modified and restored
Namespace variables - Written to persistent storage
Network Implications:

Namespace save functions handle synchronization
Immediate persistence to disk
Technical Details:

Performance: Slower than normal save (includes disk write)
Error handling: Uses isNil for safety
Atomic: Saves variable and namespace together
Edge Cases Handled:

Missing A3A_saveTarget (saved and restored)
Optional save target parameter (sets if provided)
Namespace type detection (profile vs mission profile)
Known Issues:

Slower performance (disk I/O)
Should be used sparingly (not for bulk operations)
isNil wrapper might hide other errors
Function: CfgFunctions.hpp
What it does: This is a configuration file that registers all Antistasi functions with the Arma 3 engine. It defines function class names, file paths, and special attributes like preInit/postInit flags. This file is not a runtime function but a configuration that must be compiled before the mission starts.

How it does that:

Structure
The file uses Arma's CfgFunctions class structure:


Apply
class CfgFunctions
{
    class A3A
    {
        class AI {
            file = QPATHTOFOLDER(functions\AI);
            class AIdrag {};
            // ... more function definitions
        };
        class Save {
            file = QPATHTOFOLDER(functions\Save);
            class collectSaveData {};
            // ... more function definitions
        };
    };
};
Implementation Breakdown:

Main class structure: class CfgFunctions - Arma's function registry
Namespace class: class A3A - Antistasi-specific functions
Category classes: Each section (AI, Ammunition, Save, etc.) represents a functional area
File path: file = QPATHTOFOLDER(...) - Defines where functions are stored
Function definitions: class functionName {}; - Registers each function
Key Sections:

Save Category:


Apply
class Save {
    file = QPATHTOFOLDER(functions\Save);
    class collectSaveData {};
    class deleteSave {};
    class loadPlayer {};
    class loadServer {};
    class savePlayer {};
    class getStatVariable {};
    class loadStat {};
    class resetPlayer {};
    class retrievePlayerStat {};
    class returnSavedStat {};
    class savePlayerStat {};
    class setStatVariable {};
    class saveLoop {};
    class writebackSaveVar {};
};
All 14 save system functions registered
File path: A3A/addons/core/functions/Save/
Other Categories:

AI: 40+ AI behavior functions
Ammunition: 20+ arsenal and equipment functions
Base: 50+ mission and base management functions
CREATE: 40+ spawning and creation functions
Missions: 30+ mission types
Supports: 30+ support functions
Revive: 10+ medical/revival functions
And many more...
Special Attributes:


Apply
class initPreJIP { preInit = 1; };
Some functions have preInit = 1 (runs before mission start)
Some could have postInit = 1 (runs after mission start)
Where it leads:

Used by Arma engine - When mission loads, engine reads this config
Creates function handlers - Each class functionName {}; creates a callable function
Enables remote execution - Functions can be called via call, spawn, remoteExec
Called by mission code - All other code references these registered functions
Dependencies:

Arma engine - Reads and processes this config file
Mission config system - Includes this file in mission
QPATHTOFOLDER macro - Resolves file paths at compile time
Global Variables Modified:

None at runtime - This is a configuration file
Registers function names in mission namespace
Network Implications:

No network operations
Functions registered can be remote executed
Technical Details:

Not executable code - Configuration only
Compiled before mission - Read during mission loading
Defines function availability - Makes functions callable
Organizes function library - Groups by functionality
Edge Cases Handled:

File paths - Uses preprocessor macros for portability
Function naming - Follows Arma naming conventions
Category organization - Logical grouping for maintainability
Known Issues:

Not a function - Cannot be "called" at runtime
Compile-time only - Changes require mission restart
No error handling - Arma engine handles missing functions
Cannot be hot-reloaded - Requires mission restart
Important Notes:

This file is attached for context only as per instructions
It is NOT a runtime function
It does NOT execute code
It is a CONFIGURATION file
All functions listed are called by other code (save system, etc.)
Connection to Save System: The Save category in this file references all 14 save functions we documented:

fn_collectSaveData.sqf
fn_deleteSave.sqf
fn_loadPlayer.sqf
fn_loadServer.sqf
fn_savePlayer.sqf
fn_getStatVariable.sqf
fn_loadStat.sqf
fn_resetPlayer.sqf
fn_retrievePlayerStat.sqf
fn_returnSavedStat.sqf
fn_savePlayerStat.sqf
fn_setStatVariable.sqf
fn_saveLoop.sqf
fn_writebackSaveVar.sqf
These are the functions documented in detail above.

Summary of Save System Architecture
Data Flow
Save Operation (fn_saveLoop.sqf)
Save Players: fn_saveLoop → fn_savePlayer (for each player)
Save Player Variables: fn_saveLoop → fn_savePlayerStat → fn_setStatVariable
Save Server Variables: fn_saveLoop → fn_setStatVariable (for each variable)
Save Metadata: fn_saveLoop → fn_setStatVariable (name, factions, DLC, etc.)
Save List: fn_saveLoop updates antistasiUltimate2SavedGames
Save Namespace: fn_saveLoop calls saveProfileNamespace/saveMissionProfileNamespace
Load Operation (fn_loadServer.sqf)
Load Server Variables: fn_loadServer → fn_getStatVariable → fn_returnSavedStat → fn_loadStat
Load Player Data: fn_loadServer → fn_retrievePlayerStat → fn_returnSavedStat
Load Player Variables: fn_loadServer → fn_loadPlayer (for each saved player)
Load Player Data: fn_loadPlayer → (direct hashmaps) → fn_resetPlayer (if missing)
Delete Operation (fn_deleteSave.sqf)
Delete Player Data: fn_deleteSave deletes variables from namespace
Delete Server Data: fn_deleteSave deletes variables from namespace
Update Save List: fn_deleteSave removes entry from list
Save Namespace: fn_deleteSave calls saveProfileNamespace/saveMissionProfileNamespace
Save Selection (fn_collectSaveData.sqf)
Scan Profile Namespace: Check for old saves
Scan Mission Profile Namespace: Check for new saves
Build Save List: Create hashmaps for each save
Return List: Returns array of save metadata for UI
Data Structures
Save Target

Apply
A3A_saveTarget = [_serverID, _campaignID, _map];
Profile Namespace: [serverID, campaignID, worldName]
Mission Profile: [false, campaignID, worldName]
Variable Naming
Profile Namespace: {varName}{serverID}{campaignID}Antistasi{worldName}
Mission Profile: {varName}{campaignID}
Player Variables: player_{uid}{varName}{postfix} (postfix depends on namespace)
Data Storage
Profile Namespace: profileNamespace (persistent, server-wide)
Mission Profile: missionProfileNamespace (mission-specific)
Memory: A3A_playerSaveData hashmap (loaded during server init)
Key Relationships
Functions Call Hierarchy

Apply
fn_saveLoop
├── fn_savePlayer (for each player)
│   ├── fn_stripGearFromLoadout
│   ├── fn_vehiclePrice (global save)
│   └── A3A_playerSaveData hashmap
├── fn_savePlayerStat (for each player variable)
│   └── fn_setStatVariable
├── fn_setStatVariable (for server variables)
└── namespace save functions

fn_loadServer
├── fn_getStatVariable (for each variable)
│   ├── fn_returnSavedStat
│   └── fn_loadStat
│       ├── fn_AIVEHinit
│       ├── fn_blackout
│       ├── fn_calculateAggression
│       ├── fn_updateReinfState
│       ├── fn_destroyCity
│       └── fn_createGarrison
├── fn_retrievePlayerStat (for each saved player)
│   └── fn_returnSavedStat
└── fn_loadPlayer (for each saved player)
    ├── fn_resetPlayer (if no save)
    └── HR_GRG_fnc_addVehiclesByClass

fn_collectSaveData
└── fn_returnSavedStat (for each optional variable)

fn_deleteSave
└── namespace save functions
Data Dependencies
A3A_saveTarget: Used by almost all save functions
A3A_playerSaveData: Used by load/save functions for player data
specialVarLoads: Used by fn_loadStat to identify special variables
namespace variables: Persistent storage for all game data
Network Synchronization
Public Variables: Many variables are public'ed during load
Remote Execution: Statistics updates sent to players
Namespace Saves: Engine handles synchronization