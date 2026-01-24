Function Name: 
fn_briefing.sqf
What it does: This function generates the in-game diary entries (Journey/Overview tab) for the player. It acts as the primary in-game manual and briefing system. It populates the diary with tutorials, commander options, special keybinds, faction features, AI management instructions, game options, mission-specific rules, victory conditions, and credits. The content is localized using stringtable keys.

How it does that:

Initialization and Safety:

Waits for the player entity to be fully initialized (waitUntil {!isNull player}).
Retrieves faction names for use in the text.
Sqf

Apply
waitUntil {!isNull player};
private _nameOcc = FactionGet(occ,"name");
private _nameInv = FactionGet(inv,"name");
private _nameReb = FactionGet(reb,"name");
Rebel/Player-Specific Entries:

Checks if the player is on the rebel side (side player isEqualTo teamPlayer).
Creates several diary subjects (tabs): "Tutorial", "Commander", "SpecialK" (Special Keys), "Features", "AI", "Options", and "Diary".
Populates these subjects with localized text using player createDiaryRecord.
Specifically for "Features", it dynamically generates breach charge text based on the faction configuration.
Sqf

Apply
if (side player isEqualTo teamPlayer) then {
    _index = player createDiarySubject ["Tutorial", localize "STR_antistasi_journal_entry_header_tutorial_name"];
    // ... creates multiple diary records ...
};
Game Mode Specific Entries:

Uses a switch statement on the global variable gameMode.
Creates a "Diary" record explaining the current rules of engagement (e.g., "GameMode 4" vs "GameMode 3").
Sqf

Apply
switch (gameMode) do {
    case 1: { ... };
    case 2: { ... };
    // ...
};
Victory Condition Entries:

Uses a switch statement on the global variable victoryCondition.
Explains how to win the mission (e.g., defeating all enemies, economic victory, logistical victory).
Calculates economic requirements for specific victory types using resourcesX count.
Sqf

Apply
switch (victoryCondition) do {
    case 0: { ... };
    case 2: {
        private _resourcesCount = count (resourcesX);
        // ... calculation ...
    };
    // ...
};
Default/Welcome Entries:

Adds standard welcome messages and the current mission title.
Sqf

Apply
player createDiaryRecord ["Diary",[format [localize "STR_antistasi_journal_entry_header_Default_1"],format [localize "STR_antistasi_journal_entry_text_Default_1",(call SCRT_fnc_misc_getMissionTitle)]]];
Credits:

Creates a "Credits" subject and adds acknowledgments.
Sqf

Apply
_index = player createDiarySubject ["Credits", localize "STR_antistasi_journal_entry_header_Credits_name"];
// ... creates credits records ...
Where it leads:

Calls: FactionGet (to retrieve faction names), A3A_fnc_createBreachChargeText (to format explosion info), SCRT_fnc_misc_getMissionTitle (to get mission name).
Dependencies: Relies on global variables: teamPlayer, gameMode, victoryCondition, resourcesX, destroyedSites.
System Fit: Part of the client initialization sequence. It runs locally on the player's machine to set up their UI information. It has no server-side impact or synchronization.
Function Name: 
fn_cityinfo.sqf
What it does: This function provides an interactive map overlay tool. When executed, it opens the map and allows the player to click on markers (cities, airports, resources, etc.) to get detailed information about that location, such as population, local support levels, garrison status, and current owner.

How it does that:

Global Statistics Calculation:

Iterates through all citiesX markers to calculate total population (_pop), FIA support (_popFIA), AAF support (_popAAF), and CSAT destruction impact (_popCSAT).
Sends a summary hint to the user immediately.
Sqf

Apply
{
    _dataX = server getVariable _x;
    // ... math ...
} forEach citiesX;
[localize "STR_A3A_cityinfo_header", format [...] ] call A3A_fnc_customHint;
Map Interaction Setup:

Opens the map (openMap true).
Sets up a onMapSingleClick event handler to store the clicked position in positionTel.
Sqf

Apply
onMapSingleClick "positionTel = _pos;";
Interactive Loop:

Enters a while {visibleMap} loop that checks for clicks every second.
When a click is detected, it finds the nearest marker to the click position using BIS_Fnc_nearestPosition.
Information Gathering (Conditional Logic):

Determines the type of the clicked marker (City, Airport, Resource, Factory, Outpost, Roadblock, etc.) and generates specific text based on that type.
Cities: Retrieves prestige (support) and power (radio tower influence) data from the server.
Airports/Outposts: Checks if the site is busy (aircraft cooldown) and measures garrison strength using a local helper code block _measureGarrison.
Rebel Controlled: If the site belongs to teamPlayer, it displays garrison info.
Hidden Enemies: If hideEnemyMarkers is active, it restricts info display for neutral/enemy sites unless they are immune or friendly.
Sqf

Apply
if (_siteX in citiesX) then {
    _dataX = server getVariable _siteX;
    _power = [_siteX] call A3A_fnc_getSideRadioTowerInfluence;
    // ... text formatting ...
};
Garrison Measurement (Local Function):

A local function _measureGarrison is defined and used to translate the number of garrison units into text strings like "Strong", "Weakened", or "Decimated".
Sqf

Apply
private _measureGarrison = {
    params ["_siteX", "_textX", "_thresholds"];
    _garrison = count (garrison getVariable [_siteX, []]);
    // ... switch logic ...
};
Cleanup:

Clears the click handler when the map is closed.
Sqf

Apply
onMapSingleClick "";
Where it leads:

Calls: A3A_fnc_customHint (UI output), BIS_Fnc_nearestPosition (spatial lookup), A3A_fnc_getSideRadioTowerInfluence (determine control), A3A_fnc_garrisonInfo (friendly sites), A3A_fnc_airportCanAttack (site status).
Dependencies: server namespace (read-only), garrison namespace, destroyedSites, sidesX, markersX.
System Fit: A client-side utility function. It relies on server-stored data but processes and displays it locally. It is non-destructive.
Function Name: 
fn_clientIdleChecker.sqf
What it does: This function monitors player activity locally to detect if they are AFK (Away From Keyboard). If the player is inactive for a configured timeout period (A3A_idleTimeout), it sets a variable isAFK and notifies the server/system. It specifically handles movement, look direction, UAV control, and Zeus interface usage.

How it does that:

Initialization:

Sets initial baseline variables A3A_lastActiveTime and A3A_lastPlayerDir.
Sqf

Apply
A3A_lastActiveTime = time;
A3A_lastPlayerDir = getDir player;
Event Handler for Commander Mode:

Adds a mission event handler HCGroupSelectionChanged. If the player is flagged as AFK while using High Command (HC), it removes the AFK flag immediately because interacting with HC groups counts as activity.
Sqf

Apply
addMissionEventHandler ["HCGroupSelectionChanged", {
    if (player getVariable ["isAFK", false]) then {
        // ... unset AFK ...
    };
    A3A_lastActiveTime = time;
}];
Main Monitoring Loop:

Runs an infinite while {true} loop with a 10-second sleep.
Activity Checks: It calculates activity by comparing:
Current look direction vs _oldDir.
Velocity magnitude (handles slow walking/crawling).
UAV Control status (active control or viewing feed).
Zeus Camera presence.
Active Logic: If activity is detected, it updates A3A_lastActiveTime and clears the isAFK variable if set.
AFK Logic: If time - A3A_lastActiveTime exceeds the timeout, it sets isAFK to true and sends a hint if the player is the Commander (theBoss).
Sqf

Apply
while {true} do {
    sleep 10;
    // ... checks ...
    if (A3A_lastPlayerDir != _oldDir || {vectorMagnitude velocity player > 0.1} || ... ) then {
        // Reset Timer
    };
    if (time - A3A_lastActiveTime > A3A_idleTimeout ... ) then {
        // Set AFK
        player setVariable ["isAFK", true, [2, clientOwner]];
    };
};
Where it leads:

Calls: A3A_fnc_statistics (to update UI status).
Dependencies: A3A_idleTimeout (config), A3A_isUAVAFK, A3A_isZeusAFK (settings), theBoss (global unit).
System Fit: Runs strictly locally in a spawned process. It modifies local UI state and the isAFK variable, which is synchronized to the server [2, clientOwner] so the server knows the player's status (useful for pausing game loops or auto-kick logic).
Function Name: 
fn_credits.sqf
What it does: This function creates a cinematic scrolling credit sequence on the client screen, similar to movie credits. It displays the mission title, version, and a list of authors/teams involved in the development.

How it does that:

Data Definition:

Defines an array _credits containing title, name list, and optional icons (like the mission logo).
Sqf

Apply
private _credits = [
    [ (call SCRT_fnc_misc_getMissionTitle), ... ],
    [ (localize "STR_antistasi_credits_authors_ultimate"), ["Antistasi Ultimate Team"] ],
    // ...
];
Formatting Logic:

Iterates through the credit entries.
Constructs an HTML-formatted string (<t>...</t>) for each block.
Handles the "Icon" logic: If an icon is provided (like the logo), it inserts the <img> tag.
Rendering:

Uses bis_fnc_rscLayer ("credits1") to reserve a UI layer.
Spawns a sub-process for each credit block to handle the visual rendering:
cutRsc ["RscDynamicText","plain"] creates the text control.
Calculates position (safezoneX, safeZoneY).
Uses ctrlCommit to fade the text in and out over the DURATION.
The main thread waits for the duration before processing the next credit block.
Where it leads:

Calls: SCRT_fnc_misc_getMissionTitle, bis_fnc_rscLayer, cutRsc.
Dependencies: None (pure UI effect).
System Fit: Usually called during mission initialization or via a debug/curator command. It is purely cosmetic and runs entirely on the client machine. No network traffic.
Function Name: 
fn_generateRoadblock.sqf
What it does: This function procedurally generates a defensive roadblock marker on the map. It is designed to be run on the server during map initialization. It finds a valid location on a road, ensures it isn't too close to existing roadblocks or the main base, and registers it as a control point.

How it does that:

Pre-conditions & Early Exit:

Ensures it runs only on the server.
Takes a parent marker (e.g., a city or outpost) and a list of existing roadblock positions (_rbPositions).
Checks if the parent marker already has too many roadblocks nearby (max 3 within 1.2km) or if there is a solution already within 500m.
Sqf

Apply
if (_nearRB inAreaArray [_markerPos, 500, 500] isNotEqualTo []) exitWith {};
if (count (_nearRB inAreaArray [_markerPos, 1200, 1200]) >= 3) exitWith {};
Road Selection:

Finds roads in a specific ring (400m to 500m from the center) to ensure the roadblock isn't right on top of the base.
Loops through available roads randomly.
Filtering: Skips roads if they are bridges (getRoadInfo _road # 8), dead ends, or junctions (too many connections). This ensures the roadblock is on a straight section of road.
Sqf

Apply
private _roads = (_markerPos nearRoads 500) - (_markerPos nearRoads 400);
// ... loop ...
if (getRoadInfo _road # 8 or count roadsConnectedTo [_road, true] != 2 ... ) then {continue};
Creation & Registration:

Calculates the precise road position.
Creates a local marker _mrk (shape: RECTANGLE, size: 30x30).
Adds it to global arrays: controlsX, markersX.
Sets ownership in sidesX (defaulting to the side of the parent marker).
Adds the position to _rbPositions to prevent overlap in subsequent calls.
Sqf

Apply
controlsX pushBack _mrk;
markersX pushBack _mrk;
sidesX setVariable [_mrk, sidesX getVariable _marker, true];
Where it leads:

Calls: getRoadInfo, roadsConnectedTo.
Dependencies: controlsX, markersX, sidesX, spawner arrays. Requires a valid _marker input (usually from initBases).
System Fit: Called exclusively by fn_initBases during server startup. It populates the map with tactical chokepoints.
Function Name: 
fn_initACE.sqf
What it does: This function handles configuration and event handler setup for the ACE3 mod (if loaded). It disables default ACE interactions on Antistasi supply boxes, removes specific ACE actions from rebel units (like group joining), and sets up handlers to break stealth when players use explosives or towing ropes.

How it does that:

Medical Logging:

If ACE Medical is present, it adds an event listener to ace_treatmentStarted.
Logs the usage of Atropine, Epinephrine, and Morphine to the server log for administrative tracking.
Sqf

Apply
["ace_treatmentStarted", {
    params ["_caller", "_target", ..., "_usedItem"];
    if (_usedItem in ["ACE_atropine", ...]) then { ServerInfo_3(...); };
}] call CBA_fnc_addEventHandler;
Stealth Breaking Handlers:

Adds event handlers for ace_explosives_place, ace_throwableThrown, and ace_towing_ropeDeployed.
If the player is captive (undercover/sneaking) and performs these actions, it forces player setCaptive false.
Sqf

Apply
["ace_explosives_place", {
    params ["_explosive","_dir","_pitch","_unit"];
    if (captive player && _unit == player) then { player setCaptive false };
}] call CBA_fnc_addEventHandler;
Box Protection:

Uses ace_common_fnc_claim on boxX and vehicleBox. This prevents ACE interact menus from opening on these objects, effectively disabling standard ACE inventory access/gear loading (Antistasi handles this separately).
Sqf

Apply
[boxX, boxX] call ace_common_fnc_claim;
Unit Action Removal:

Defines a list of unit classnames (rebels, AI, etc.).
Iterates through them to compile ACE menus and then remove specific actions: ACE_ApplyHandcuffs, ACE_LeaveGroup, ACE_JoinGroup. This forces players to use Antistasi-specific systems for these actions.
Sqf

Apply
{
    [_x] call ace_interact_menu_fnc_compileMenu;
    [_x, 0, ["ACE_ApplyHandcuffs"]] call ace_interact_menu_fnc_removeActionFromClass;
    // ...
} forEach _unitTypes;
Where it leads:

Calls: ace_common_fnc_claim, ace_interact_menu_fnc_compileMenu, ace_interact_menu_fnc_removeActionFromClass.
Dependencies: A3A_hasACEMedical (flag), CBA_fnc_addEventHandler.
System Fit: Runs locally on clients (and server) if ACE is detected. It modifies UI behavior to maintain game balance.
Function Name: 
fn_initACEUnconsciousHandler.sqf
What it does: This function installs a specific event handler for the ACE Medical "Unconscious" event. It manages the transition of AI units into unconsciousness, handles group leadership transfer, triggers AI reactions, and manages the surrender logic for downed enemies.

How it does that:

Event Listener Setup:

Registers a handler for ace_unconscious.
Scope Check: if !(local _unit) exitWith {}; ensures the code only runs on the machine owning the unit to prevent desync.
Knockout Logic (True branch):

Sets the global variable incapacitated to true (used by Antistasi cover systems).
Leadership Transfer: If the unit was a squad leader, it scans for the nearest capable unit (A3A_fnc_canFight) and promotes them.
AI Reaction: If the unit is AI (Side Occupants/Invaders), it spawns A3A_fnc_AIReactOnKill to make nearby enemies attack the source of damage.
Wake Up Logic (False branch):

Resets incapacitated to false.
Captive State: If not handcuffed, it removes the captive status (setCaptive false) unless the unit is a player.
Surrender Logic:
Skips players.
Checks if the unit has a primary weapon.
If unarmed or if a nearby enemy is within 50m, it spawns A3A_fnc_surrenderAction.
Sqf

Apply
if (primaryWeapon _unit == "") exitWith { [_unit] spawn A3A_fnc_surrenderAction };
// ... proximity check ...
if (side _nearestUnit == teamPlayer) then { [_unit] spawn A3A_fnc_surrenderAction };
Where it leads:

Calls: A3A_fnc_AIReactOnKill, A3A_fnc_surrenderAction, A3A_fnc_canFight.
Dependencies: incapacitated variable, surrendered variable.
System Fit: Runs on all machines. Ensures ACE medical events integrate seamlessly with Antistasi AI logic and surrender mechanics.
Function Name: 
fn_initBases.sqf
What it does: This function initializes the map state for all major markers (Airports, Resources, Factories, Outposts, Milbases, Seaports) during server startup. It sets the visual map markers (flags, icons), assigns default sides, initializes garrisons, and triggers the generation of roadblocks.

How it does that:

Pre-Setup:

Retrieves map configuration data from missionConfigFile or configFile (specifically the A3A/mapInfo class) to determine which markers belong to CSAT (Invaders) vs NATO (Occupants).
Roadblock Side Assignment:

Assigns sides to pre-defined control points (roadblocks) based on the map config.
Sqf

Apply
private _controlsNATO = controlsX - _controlsCSAT;
{sidesX setVariable [_x, Occupants, true]} forEach _controlsNATO;
Marker Initialization (Local Function _fnc_initMarkerList):

This internal function is called repeatedly for different marker types.
It loops through the markers (e.g., airportsX).
Visuals: Creates a "Dum" marker (dummy) to represent the base on the map. It selects the icon (Flag, HQ, Naval) and Color (Blue/Red) based on the side (Occupant/Invader).
State: Sets sidesX (ownership), garrison (empty array), and killZones (if applicable).
Roadblocks: Calls A3A_fnc_generateRoadblock for every major base to spawn nearby control points.
Sqf

Apply
private _fnc_initMarkerList = {
    params ["_mrkCSAT", "_markers", ...];
    {
        private _isInvader = _x in _mrkCSAT;
        // ... Visual Logic ...
        sidesX setVariable [_x, [Occupants, Invaders] select _isInvader, true];
        garrison setVariable [_x, [], true];
        [_x, _roadblockPositions] call A3A_fnc_generateRoadblock;
    } forEach _markers;
};
Execution:

Calls _fnc_initMarkerList for airports, resources, factories, outposts, milbases, and seaports.
Where it leads:

Calls: A3A_fnc_generateRoadblock.
Dependencies: controlsX, airportsX, resourcesX, etc. (global arrays), sidesX, garrison, killZones (namespaces).
System Fit: Runs once on the server at mission start. It defines the "State Zero" of the map.

Function Name: A3A\initClient.sqf
What it does: This is the main client initialization function for the Antistasi mod. It is responsible for setting up all client-side logic, variables, event handlers, and UI elements required for a player to interact with the mission. It handles version verification, client-state initialization, player setup, and the spawning of background maintenance loops.

How it does that:

1. Initial Configuration and Logging Setup
Step: Ensure logLevel is initialized and set debug console flags. Explanation: If the server hasn't set the log level (which is usually handled by initServer), the client sets a default. This ensures logging functions work immediately.

Sqf

Apply
//Make sure logLevel is always initialised.
//This should be overridden by the server, as appropriate. Hence the nil check.
if (isNil "logLevel") then { logLevel = 2; A3A_logDebugConsole = 1 };
Step: Log the startup and version. Explanation: Logs the start of the client initialization and checks the mod version against the packed version string QUOTE(VERSION) and QUOTE(VERSION_FULL).

Sqf

Apply
Info("initClient started");
A3A_clientVersion = QUOTE(VERSION);
Info_1("Client version: %1", QUOTE(VERSION_FULL));
2. Client Pre-Setup and Setup Checks
Step: Run Mod Blacklist Check. Explanation: Calls A3A_fnc_modBlacklist to check if the client is using any blacklisted mods. If the check returns true (indicating a blacklisted mod), the function exits immediately, preventing the client from joining.

Sqf

Apply
if (call A3A_fnc_modBlacklist) exitWith {};
Step: Temporary Uniform Assignment. Explanation: Forces the player into a default uniform immediately to prevent naked player spawns during the lag of loading the correct loadout later.

Sqf

Apply
player forceAddUniform "U_C_WorkerCoveralls";
Step: Initialize State Variables. Explanation: Sets up global client-side state flags.

Sqf

Apply
musicON = false;
recruitCooldown = 0;
incomeRep = false;
isPowPaycheckAnnounced = false;
isSupportAnnounced = false;
isMenuOpen = false;
isPlayerParadropable = true;
hasHeadlessClients = false;
Step: Discord Rich Presence Setup. Explanation: Checks if the Discord RPC function exists and if the game language is English. If both are true, it enables the RPC integration.

Sqf

Apply
private _richPresenceFunc = missionNamespace getVariable "DiscordRichPresence_fnc_update";
private _isEnglish = ((localize "STR_antistasi_dialogs_generic_button_yes_text") isEqualTo "Yes");
isDiscordRichPresenceActive = if (isNil "_richPresenceFunc") then {false} else {true};
Step: Environment Optimization. Explanation: Disables passive animals (rabbits/snakes) to prevent log spam from non-network object references.

Sqf

Apply
enableEnvironment [false, true];
3. Client-Specific Initialization Block
Step: Variable Initialization for Clients. Explanation: If the client is not the host server (MP client), it initializes common variables.

Sqf

Apply
if !(isServer) then {
    call A3A_fnc_initVarCommon;
    // ... rest of block
};
Step: Towing System Initialization. Explanation: Executes the external towing script.

Sqf

Apply
[] execVM QPATHTOFOLDER(Scripts\fn_advancedTowingInit.sqf);
Step: JNA (Just Newcastle Arsenal) Preload. Explanation: Calls the preloader for the custom arsenal system to prevent lag when the player opens the arsenal for the first time.

Sqf

Apply
Info("Running client JNA preload");
["Preload"] call jn_fnc_arsenal;
Step: Headless Client (HC) Specific Initialization. Explanation: If the machine is an HC (no interface), it initializes the patrol AI system and the navigation grid.

Sqf

Apply
if (!hasInterface) then {
    Info("HC Initialising PATCOM Variables");
    [] call A3A_fnc_patrolInit;

    call A3A_fnc_loadNavGrid;
    waitUntil { sleep 0.1; !isNil "serverInitDone" };          // Wait for server to finish basic setup
    call A3A_fnc_addNodesNearMarkers;
};
Step: Lambs Danger FSM Integration. Explanation: Checks for the CBA and Lambs Danger mods. If present, it adds an event handler to AI units to disable the Lambs FSM, as it conflicts with Antistasi's custom AI logic.

Sqf

Apply
if ((isClass (configfile >> "CBA_Extended_EventHandlers")) && (
    isClass (configfile >> "CfgPatches" >> "lambs_danger"))) then {
    ["CAManBase", "InitPost", {
        params ["_unit"];
        (group _unit) setVariable ["lambs_danger_disableGroupAI", true];
        _unit setVariable ["lambs_danger_disableAI", true];
    }] call CBA_fnc_addClassEventHandler;
};
4. Version and Startup State Synchronization
Step: Version Verification. Explanation: Waits for the server to finish zone initialization (initZonesDone). If the server version variable doesn't exist (legacy or pre-2.2), it sets a default. If the client version string does not match the server's, the mission is aborted with an error message.

Sqf

Apply
waitUntil { sleep 0.1; !isNil "initZonesDone" };
if (isNil "A3A_serverVersion") then { A3A_serverVersion = "pre-2.2" };
if (A3A_clientVersion != A3A_serverVersion) exitWith {
    private _errorStr = format [localize "STR_A3A_feedback_serverinfo_mismatch", A3A_serverVersion, A3A_clientVersion];
    [localize "STR_A3A_feedback_serverinfo", _errorStr] call A3A_fnc_customHint;
};
Step: Startup State Notification Loop. Explanation: Displays a localized hint to the user indicating the server startup progress (e.g., "Creating Map", "Generating HQ"). It loops until A3A_startupState becomes "completed".

Sqf

Apply
if (isNil "A3A_startupState") then { A3A_startupState = "waitserver" };
while {true} do {
    if (dialog) then { sleep 0.1; continue };           // Don't spam hints
    private _stateStr = localize ("STR_A3A_feedback_serverinfo_" + A3A_startupState);
    isNil { [localize "STR_A3A_feedback_serverinfo", _stateStr, true] call A3A_fnc_customHint };
    if (A3A_startupState == "completed") exitWith {};
    sleep 0.1;
};
5. Post-Server-Start Client Setup
Step: Structural Integrity Fix. Explanation: Calls a fix for Arma 3's building destruction physics (Schrodingers Building Fix).

Sqf

Apply
call A3A_fnc_installSchrodingersBuildingFix;
Step: Destroyed Buildings Sync (Non-Server). Explanation: Registers a handler for the destroyedBuildings public variable. When the server updates this list, the client hides the corresponding objects locally. It then requests the current list from the server.

Sqf

Apply
if (!isServer) then {
    "destroyedBuildings" addPublicVariableEventHandler {
        { hideObject _x } forEach (_this select 1);
    };
    [clientOwner, "destroyedBuildings"] remoteExecCall ["publicVariableClient", 2];
    // ... Arsenal and Medical init
};
Step: HC Exit Block. Explanation: HCs do not need player UI or event handlers. They are placed in a buffer zone and registered with the server via A3A_fnc_addHC before exiting this function.

Sqf

Apply
if (!isServer and !hasInterface) exitWith {
    player setPosATL (markerPos respawnTeamPlayer vectorAdd [-100, -100, 0]);
    [clientOwner] remoteExecCall ["A3A_fnc_addHC",2];
};
Step: Player Existence Wait. Explanation: Ensures the player object is locally controlled before proceeding with camera/UI setup.

Sqf

Apply
waitUntil {local player};
Step: Briefing and Script Execution. Explanation: Starts the mission briefing and executes various optional/mod scripts (Spectrum Device, RRTurretMagazines).

Sqf

Apply
[] spawn A3A_fnc_briefing;

if (enableSpectrumDevice) then {
    [] execVM QPATHTOFOLDER(Scripts\SpectumDevice\spectrum_device.sqf);
    // ...
};
6. Player Variable Setup and Positioning
Step: Variable Placeholders. Explanation: Sets initial placeholders for score, money, and rank. These are overwritten by server data or saved stats later.

Sqf

Apply
player setVariable ["score",0];
player setVariable ["moneyX",0];
player setVariable ["rankX",rank player];
Step: Player Identity and Ownership. Explanation: Marks the player with their UID for commander remote control routines and sets ownership tags.

Sqf

Apply
player setVariable ["owner",player,true];
player setVariable ["A3A_playerUID",getPlayerUID player,true];
Step: Safe Spawning. Explanation: Calculates a safe position near the HQ respawn marker (using BIS_fnc_findSafePos) to prevent spawning inside walls or objects. Sets the player direction to face the arsenal (boxX).

Sqf

Apply
private _respawnPos = (getMarkerPos respawnTeamPlayer);
private _safePos = [
    _respawnPos, 0, 15, 1, 0, 0, 0, [], [_respawnPos, _respawnPos]
] call BIS_fnc_findSafePos;
player setPos _safePos;
player setDir ([player, boxX] call BIS_fnc_dirTo);
player setVariable ["spawner",true,true];
7. UI and Visual Setup
Step: Radio Jamming. Explanation: If TFAR/ACRE is active, starts the radio jamming logic loop.

Sqf

Apply
if (A3A_hasTFAR || A3A_hasTFARBeta || A3A_hasACRE) then {
    [] spawn A3A_fnc_radioJam;
};
Step: 3D Icons. Explanation: Calls SCRT function to enable 3D icons on units/objects.

Sqf

Apply
[] call SCRT_fnc_common_set3dIcons;
Step: Intro Camera (Establishing Shot). Explanation: Creates the cinematic top-down map camera view that pans over the HQ. It calculates colors for the player side and the enemy side (Invaders) and places markers for the insertion point and radio towers.

Sqf

Apply
private _colourTeamPlayer = teamPlayer call BIS_fnc_sideColor;
private _colorInvaders = Invaders call BIS_fnc_sideColor;
{
    _x set [3, 0.33]
} forEach [_colourTeamPlayer, _colorInvaders];

private _introShot = [
    (position petros),
    format ["%1, %2 %3", worldName, (localize (rank player)), name player],
    50, 50, 90, 0,
    [
        ["\a3\ui_f\data\map\markers\Nato\o_inf.paa", _colourTeamPlayer, markerPos "insertMrk", 1, 1, 0, "Insertion Point", 0],
        ["\a3\ui_f\data\map\markers\Nato\o_inf.paa", _colorInvaders, markerPos "towerBaseMrk", 1, 1, 0, "Radio Towers", 0]
    ]
] spawn BIS_fnc_establishingShot;
Step: HUD and Markers. Explanation: Starts the player marker script and the revive system.

Sqf

Apply
if (playerMarkersEnabled) then {
    [] spawn A3A_fnc_playerMarkers;
};
[player] spawn A3A_fnc_initRevive;
8. Group and Identity Logic
Step: Group Management. Explanation: Creates the stragglers group for independent AI. Disables the attack order on the player's group to prevent AI from taking control of fire. Prevents the Ace "No Radio" feature from overriding the rebel voice selection.

Sqf

Apply
stragglers = creategroup teamPlayer;
(group player) enableAttack false;

if (isNil "ace_noradio_enabled" or {!ace_noradio_enabled}) then {
    [player, createHashMapFromArray [["speaker", selectRandom (A3A_faction_reb get "voices")]]] call A3A_fnc_setIdentity;
};
Step: Base Loadout. Explanation: Applies the default rebel loadout using A3A_fnc_dress.

Sqf

Apply
[player] call A3A_fnc_dress;
9. Event Handler Registration
Step: Fired Man (Captive System). Explanation: When the player fires, the captive status is checked. If enemies are within 300m, the player is revealed. If in a city with high civilian presence, there's a random chance of being revealed.

Sqf

Apply
player addEventHandler ["FiredMan", {
    _player = _this select 0;
    if (captive _player) then {
        // ... distance check logic ...
        if ({if (((side _x == Occupants) or (side _x == Invaders)) and (_x distance player < 300)) exitWith {1}} count allUnits > 0) then {
            [_player,false] remoteExec ["setCaptive",0,_player];
            _player setCaptive false;
        };
    };
}];
Step: Inventory Opened (Captive System). Explanation: Prevents looting enemy or faction ammoboxes while in captivity without being revealed. Similar logic to FiredMan but triggered when opening cargo.

Sqf

Apply
player addEventHandler ["InventoryOpened", {
    private ["_playerX","_containerX","_typeX"];
    // ... check if container is enemy ammobox or dead man ...
    if (((_containerX isKindOf "Man") and (!alive _containerX)) or (_typeX in [A3A_faction_occ get "ammobox", ...])) then {
        // ... reveal logic ...
    };
}];
Step: Handle Heal (Captive System). Explanation: Healing a unit while in captivity may reveal the player, depending on proximity to enemies.

Sqf

Apply
player addEventHandler ["HandleHeal", {
    // ... reveal logic ...
}];
Step: Weapon Assembly/Disassembly (Static Weapons). Explanation: When assembling a static weapon, it initializes it as a persistent vehicle (adding to staticsToSave) and adds a logistics action to it. When disassembling, it calls postmortem to remove server references.

Sqf

Apply
player addEventHandler ["WeaponAssembled", {
    private _veh = _this select 1;
    [_veh, teamPlayer] call A3A_fnc_AIVEHinit;
    if (_veh isKindOf "StaticWeapon") then {
        if (not(_veh in staticsToSave)) then {
            staticsToSave pushBack _veh;
            publicVariable "staticsToSave";
        };
        [_veh] call A3A_Logistics_fnc_addLoadAction;
    };
}];
Step: Rivals Killing. Explanation: If the player kills a rival, it reduces rival activity on the server.

Sqf

Apply
if (areRivalsDiscovered) then {
    player addEventHandler ["Killed", {
        if (_killer getVariable ["isRival", false]) then {
            [-5, 60] remoteExec ["SCRT_fnc_rivals_reduceActivity",2];
        };
    }];
};
Step: Vehicle Entry (Access Control & Undercover). Explanation: Checks if the vehicle is locked by a player owner (non-member logic). If the player is not a member and doesn't own the vehicle, they are kicked out. Also triggers undercover if entering a stealth vehicle.

Sqf

Apply
player addEventHandler ["GetInMan", {
    if !([player] call A3A_fnc_isMember) then {
        if (!isNil {_veh getVariable "A3A_locked"}) then {
            // ... access deny logic ...
        };
    };
    // ... undercover trigger ...
}];
Step: Black Market Artillery Disable. Explanation: If the player enters a vehicle classified as "ARTILLERY" in the Black Market stock, it disables the vanilla engine artillery computer.

Sqf

Apply
private _blackMarketStock = call A3U_fnc_grabBlackMarketVehicles;
player addEventHandler ["GetInMan", {
    if ((typeOf _vehicle) in _artyTypes) then {
        enableEngineArtillery false;
    };
}];
Step: Discord Rich Presence Updates. Explanation: Updates the Discord status text based on what vehicle the player is in and their role (Driver/Gunner/Passenger).

Sqf

Apply
if(isDiscordRichPresenceActive) then {
    player addEventHandler ["GetInMan", {
        // ... switch case logic for vehicle types ...
        ["UpdateState", format ["Pilots %1", _vehicleName]]] call SCRT_fnc_misc_updateRichPresence;
    }];
};
Step: ACE Explosives. Explanation: If ACE is active, setting an explosive as a captive reveals the player.

Sqf

Apply
if (A3A_hasACE) then {
    ["ace_explosives_place", {
        params ["_explosive","_dir","_pitch","_unit"];
        if (_unit == player) then { player setCaptive false };
    }] call CBA_fnc_addEventHandler;
};
Step: HandleRating (Friendly Fire). Explanation: Prevents the player from losing reputation (rating) for friendly fire incidents within the mission system.

Sqf

Apply
player addEventHandler ["HandleRating", {0}];
10. Post-Setup and Cleanup
Step: Undercover Initialization. Explanation: Runs the script to check the initial undercover state.

Sqf

Apply
call A3A_fnc_initUndercover;
Step: Dynamic Groups. Explanation: Initializes the Arma 3 Dynamic Groups framework.

Sqf

Apply
["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;
Step: Membership and Admin Check. Explanation: If membership is enabled, checks if the player is on the membersX list. If the player is a server admin (logged in or local host), they are automatically granted member status.

Sqf

Apply
if (membershipEnabled) then {
    if (player call A3A_fnc_isMember) exitWith {};
    // ... admin check ...
    if (_isMember) then {
        membersX pushBack (getPlayerUID player);
        publicVariable "membersX";
    };
};
Step: Group Leadership Fix. Explanation: If the player is not the leader of their group (e.g., rejoining a persistent squad), it forces the group to select the player as leader remotely.

Sqf

Apply
if !(isPlayer leader group player) then {
    [group player, player] remoteExec ["selectLeader", groupOwner group player];
};
Step: Transition from Intro. Explanation: Waits for the intro camera to finish (_introshot script done), then fades the screen in.

Sqf

Apply
waitUntil { scriptDone _introshot };
cutText ["","BLACK IN", 3];
Step: Commander Assignment. Explanation: Requests the server to assign a commander if none exists.

Sqf

Apply
[] remoteExecCall ["A3A_fnc_assignBossIfNone", 2];
Step: Mod List Display. Explanation: If the player is a server, commander, or admin, it displays a hint listing loaded mods and templates (TFAR, ACE, etc.).

Sqf

Apply
if (isServer || (!isNil "theBoss" && {player isEqualTo theBoss}) || (call BIS_fnc_admin) > 0) then {
    // ... construct mod list text ...
    [localize "STR_A3A_initClient_mods_header",_textXML] call A3A_fnc_customHint;
};
Step: ACE Interaction Cleanup. Explanation: Removes specific ACE interaction actions (Handcuffs, Join/Leave Group) from rebel units to prevent conflicts with the mission's custom interaction system.

Sqf

Apply
if (A3A_hasACE) then {
    {
        [_x] call ace_interact_menu_fnc_compileMenu;
        [_x, 0, ["ACE_ApplyHandcuffs"]] call ace_interact_menu_fnc_removeActionFromClass;
        // ... removal of group actions ...
    } forEach _unitTypes;
};
Step: HQ Object Actions. Explanation: Adds actions to HQ objects (boxX, flagX, vehicleBox, mapX).

boxX: Add to arsenal, move object (commander only).
flagX: Recruit units, Rally point travel, Move object.
vehicleBox: Restore vehicles, Buy vehicle, Garage integration.
mapX: City info, Commander/Rebel menu, Move object.
Sqf

Apply
boxX addAction [format ["<img image='\a3\ui_f\data\igui\cfg\simpletasks\types\container_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", localize "STR_antistasi_actions_transfer_to_arsenal"], {[] spawn A3A_fnc_empty;}, 3];
// ... similar additions for other objects ...
Step: Object Managers. Explanation: Starts scripts for dropable objects, unit traits, buildable objects list, and the builder monitor loop (for adding build actions to curors objects).

Sqf

Apply
call A3A_fnc_dropObject;
// ...
call A3A_fnc_initBuildableObjects;
0 spawn A3A_fnc_initBuilderMonitors;
Step: GUI and Statistics. Explanation: Loads the HUD layer (H8erHUD) and starts the background statistics loop.

Sqf

Apply
_layer = ["statisticsX"] call bis_fnc_rscLayer;
_layer cutRsc ["H8erHUD","PLAIN",0,false];
[] spawn A3A_fnc_statistics;
Step: Zeus and Advanced Scripting. Explanation: Initializes Zeus logging, Mag Repack (if enabled), and Discord presence updates. Sets up persistent building saving for Zeus curators if enabled.

Sqf

Apply
[allCurators] remoteExecCall ["A3A_fnc_initZeusLogging",0];
// ... MagRepack ...
// ... Zeus Persistent Buildings ...
Step: Final State Flags and Checks. Explanation: Sets initClientDone, checks for singleplayer (aborts if singleplayer is detected), checks for mod conflicts, initializes ACE specific handlers, and applies mission settings for fatigue/stamina/weapon sway.

Sqf

Apply
initClientDone = true;
// ... singleplayer check ...
if (fatigueEnabled isEqualTo false) then { player enableFatigue false; };
if (staminaEnabled isEqualTo false) then { player enableStamina false; };
private _newWeaponSway = swayEnabled / 100;
player setCustomAimCoef _newWeaponSway;
Where it leads:

Called Functions: A3A_fnc_modBlacklist, A3A_fnc_initVarCommon, A3A_fnc_patrolInit, A3A_fnc_loadNavGrid, A3A_fnc_addNodesNearMarkers, A3A_fnc_customHint, A3A_fnc_installSchrodingersBuildingFix, A3A_fnc_briefing, A3A_fnc_radioJam, SCRT_fnc_common_set3dIcons, A3A_fnc_playerMarkers, A3A_fnc_initRevive, A3A_fnc_outOfBounds, A3A_fnc_darkMapFix, A3A_fnc_clientIdleChecker, A3A_fnc_tags, A3A_fnc_setIdentity, A3A_fnc_dress, A3A_fnc_AIVEHinit, A3A_fnc_postmortem, SCRT_fnc_rivals_reduceActivity, A3A_fnc_goUndercover, A3A_fnc_vehicleBoxRestore, HR_GRG_fnc_initGarage, A3A_fnc_dropObject, A3A_fnc_cityinfo, SCRT_fnc_misc_orbitingCamera, SCRT_fnc_ui_populateGameOptionsMenu, SCRT_fnc_ui_populateRebelMenu, A3A_fnc_AILoadInfo, A3A_fnc_moveHQObject, A3A_fnc_unitTraits, A3A_fnc_initBuildableObjects, A3A_fnc_initBuilderMonitors, A3A_fnc_statistics, A3A_fnc_createDialog_shouldLoadPersonalSave, A3A_fnc_initZeusLogging, SCRT_fnc_misc_updateRichPresence, SCRT_fnc_build_saveConstruction, A3U_fnc_checkMods, A3A_fnc_initACE, A3U_fnc_IMS_stealthKill.
Dependents: This is the root client-side initialization script. All other client-side loops and handlers depend on variables and states initialized here.
Global Variables Modified: A3A_clientVersion, logLevel, A3A_logDebugConsole, musicON, recruitCooldown, incomeRep, isPowPaycheckAnnounced, isSupportAnnounced, isMenuOpen, isPlayerParadropable, hasHeadlessClients, isDiscordRichPresenceActive, initZonesDone, A3A_serverVersion, A3A_startupState, stragglers, staticsToSave, initClientDone. It also modifies the local state of player (position, direction, variables, event handlers).
Network Implications: Uses remoteExecCall to communicate with the server for version checks, building syncing, HC registration, and commander assignment. Uses publicVariable and addPublicVariableEventHandler for synchronization of destroyed buildings and member lists. The function waits for server-sent variables (initZonesDone, A3A_serverVersion, A3A_startupState).
Requirements and Edge Cases:

Headless Clients: The function detects !hasInterface and exits early after initializing HC-specific logic (NavGrid, Patrol), ensuring no UI or player event handlers are created.
Version Mismatch: If client and server versions do not match, the function exits immediately with an error hint.
Blacklist Mods: If A3A_fnc_modBlacklist returns true, the function exits immediately.
Race Conditions: The while loop for A3A_startupState includes a check for dialog to prevent hint spam if the user is interacting with menus during startup.
Localhost: The isServer check ensures that if a player is hosting the mission solo, they still undergo client initialization, though some network-specific calls may be skipped or handled differently.

Function: fn_initGarrisons.sqf
Function Name: fn_initGarrisons.sqf
What it does: This function initializes garrison data for all markers (outposts, airports, milbases, resources, factories, seaports) in a new game. It determines the garrison composition for each location based on its controlling side (Occupants/Invaders) and assigns randomly selected unit groups to garrison slots. The function sets up the initial distribution of forces across the map.

Context:

Called only during new game initialization (line 4 comment)
Executes after faction data is loaded and marker ownership is established
Part of the server-side initialization sequence
Runs before any player joins (Pre-JIP)
How it does that:
Step 1: Function Definition and Parameters

Sqf

Apply
_fnc_initGarrison =
{
    params ["_marker", "_occGroups", "_invGroups"];
Defines a local function _fnc_initGarrison that takes three parameters:
_marker: Marker name (e.g., "marker_123")
_occGroups: Array of Occupant group classnames
_invGroups: Array of Invader group classnames
Parameters are validated implicitly by SQF's type checking
Step 2: Calculate Garrison Size

Sqf

Apply
private _garrNum = [_marker] call A3A_fnc_garrisonSize;
Calls A3A_fnc_garrisonSize to get the maximum garrison capacity for this marker
Returns a number based on marker type (airports have larger garrisons than resources)
This size determines how many unit groups will be assigned
Step 3: Determine Side and Group Selection

Sqf

Apply
private _side = sidesX getVariable _marker;
private _groupsRandom = [_occGroups, _invGroups] select (_side == Invaders);
Retrieves the controlling side from the sidesX global namespace variable
Selects appropriate group array using a boolean selection:
If _side == Invaders (true), selects _invGroups (index 1)
Otherwise selects _occGroups (index 0)
This ensures garrisons match the faction controlling the marker
Step 4: Build Garrison Array

Sqf

Apply
private _garrison = [];
while {count _garrison < _garrNum} do {
    _garrison append (selectRandom _groupsRandom);
};
Initializes empty _garrison array
Loops until garrison reaches required size
Each iteration appends one randomly selected group from _groupsRandom
selectRandom picks a group class name (e.g., "O_InfSquad", "I_InfSection")
Step 5: Resize and Store Garrison

Sqf

Apply
_garrison resize _garrNum;
garrison setVariable [_marker, _garrison, true];
Ensures exact size by truncating if necessary (though loop should produce correct size)
Stores garrison in the garrison namespace with marker as key
Third parameter true makes the variable public across the network
This garrison data will be used later when spawning units
Step 6: Marker Ownership Fix (Game Mode 3)

Sqf

Apply
private _updateMarkers = outposts + airportsX + milbases;
if (gameMode == 3) then
{
    // Set everything to government control if we have no invaders
    {
        if (sidesX getVariable _x == Occupants) then { continue };
        sidesX setVariable [_x, Occupants, true];
        _updateMarkers pushBackUnique _x;
    } forEach (markersX - ["Synd_HQ"]);
};
Creates array of all strategic markers
In "Government Only" mode (gameMode == 3), ensures all markers except Synd_HQ are owned by Occupants
Uses continue to skip already Occupant-owned markers
Adds modified markers to _updateMarkers for visual updates
Step 7: Update Marker Visuals

Sqf

Apply
{ _x call A3A_fnc_mrkUpdate } forEach _updateMarkers;
Calls A3A_fnc_mrkUpdate for each marker to refresh flag colors and ownership visuals
This updates map markers to reflect current control
Step 8: Initialize Strategic Locations

Sqf

Apply
private _occGroups = ((A3A_faction_occ get "groupsTierSquads") apply {_x select 1}) + ((A3A_faction_occ get "groupsTierMedium") apply {_x select 1});
private _invGroups = ((A3A_faction_inv get "groupsTierSquads") apply {_x select 1}) + ((A3A_faction_inv get "groupsTierMedium") apply {_x select 1});
{ [_x, _occGroups, _invGroups] call _fnc_initGarrison } forEach airportsX + milbases + (outposts select {sidesX getVariable [_x, sideUnknown] == Invaders});
Builds group arrays for Occupants (tier 1 & 2 infantry squads)
Builds group arrays for Invaders (tier 1 & 2 infantry squads)
Applies garrison initialization to:
All airports
All milbases
Outposts controlled by Invaders
Uses apply to extract group classnames from faction data
Step 9: Initialize Militia Locations

Sqf

Apply
private _milGroups = (A3A_faction_occ get "groupsMilitiaSquads") + (A3A_faction_occ get "groupsMilitiaMedium");
{ [_x, _milGroups, _invGroups] call _fnc_initGarrison } forEach resourcesX + factories + seaports + (outposts select {sidesX getVariable [_x, sideUnknown] == Occupants});
Builds militia group array for Occupants
Applies garrison initialization to:
Resources
Factories
Seaports
Outposts controlled by Occupants
Uses different group composition for these locations (militia instead of regular troops)
Step 10: Finalization

Sqf

Apply
Info("InitGarrisons completed");
Logs completion message
Where it leads:
Functions called:

A3A_fnc_garrisonSize - Returns garrison capacity for a marker
A3A_fnc_mrkUpdate - Updates visual marker state (flag, color, ownership)
Local function _fnc_initGarrison - Initializes garrison for individual marker
Dependencies:

Pre-requisites:
A3A_faction_occ and A3A_faction_inv hashmaps must be initialized (from initVarServer.sqf)
sidesX namespace must have marker ownership data
garrison namespace must exist
Marker arrays (airportsX, milbases, outposts, etc.) must be populated
Post-requisites:
garrison namespace now contains garrison data for all strategic markers
sidesX namespace updated for game mode 3
Visual marker state updated via A3A_fnc_mrkUpdate
System Integration:

Part of server initialization chain (usually called from initServer.sqf)
Runs before any spawn functions (A3A_fnc_createAIAirplane, etc.)
Garrison data used by:
A3A_fnc_createAI... functions for spawning units
A3A_fnc_garrisonUpdate for reinforcement logic
A3A_fnc_getGarrison for querying garrison strength
Global Variables Modified:

garrison namespace: Adds entry for each strategic marker
sidesX namespace: May update ownership for game mode 3
Marker visual state (via A3A_fnc_mrkUpdate)
Synchronization/Network Implications:

All garrison data is set public (third parameter true in setVariable)
Changes to sidesX are public
A3A_fnc_mrkUpdate likely triggers network updates to clients
Function runs only on server (uses sidesX and garrison server-side namespaces)
Edge Cases:

Game mode 3 (government only): All non-HQ markers become Occupant-owned
Marker with sideUnknown: Falls back to Occupant in selection logic
Empty group arrays: Would cause errors (assumes factions have groups defined)
Marker not in sidesX: Would default to sideUnknown in select condition
Function: fn_initPreJIP.sqf
Function Name: fn_initPreJIP.sqf
What it does: This function performs pre-Join-In-Progress initialization for Antistasi. It validates mission/mod compatibility, checks version compatibility, and initializes core systems that must run before any player joins the mission. It's the first initialization step that runs on every machine (client or server) when joining a mission.

Context:

Runs as a pre-init function (line 16: preInit = 1)
Executes before mission objects initialize
Executes before player object is available
Runs on ALL machines (clients and server)
Designed to run in unscheduled environment
How it does that:
Step 1: Warning Message Function

Sqf

Apply
private _fnc_warningMessage = {
    if (!hasInterface) exitWith {};
    params ["_title", "_message"];
    waituntil {!isNull (findDisplay 46)};
    9000 cutText [format ["<t size='5'>%1</t><br/><t size='2'>%2</t>", _title, _message], "BLACK", nil, nil, true];
    uiSleep 20;
    {_x cutFadeOut 20} forEach allActiveTitleEffects;
};
Defines local warning function for compatibility issues
Check: !hasInterface - Exits immediately on headless clients (no display)
Parameters: Title and message for the warning
Wait: Waits for mission display 46 (main display) to exist
Display: Shows full-screen black overlay with large text using cutText
Format: 5px title, 2px message
Duration: 20 seconds (while loop continues)
Effects: Black overlay that fades in
Cleanup: After 20 seconds, fades out all title effects
Network: Local function, runs only on machine with interface
Step 2: Pre-Mod Mission Check

Sqf

Apply
if (isClass (missionConfigFile/"CfgFunctions"/"A3A")) exitWith {
    Error("Non-mod Antistasi mission detected");
    [localize "STR_A3A_missioncheck_nonmodmission_title", localize "STR_A3A_missioncheck_nonmodmission"] spawn _fnc_warningMessage;
};
Check: Looks for CfgFunctions/A3A in mission config
Meaning: If present, mission has its own A3A functions (pre-mod version)
Action: Logs error and shows warning message
Exit: Uses exitWith to stop execution immediately
Localize: Uses stringtable entries for multi-language support
Step 3: Non-Antistasi Mission Check

Sqf

Apply
if (!isClass (missionConfigFile/"A3A")) exitWith {
    Info("Probable non-Antistasi mission detected, ignoring");
};
Check: Looks for A3A class in mission config
Meaning: If absent, mission isn't Antistasi
Action: Logs info and exits cleanly
Purpose: Prevents Antistasi mod from affecting non-Antistasi missions
Step 4: Version Compatibility Check

Sqf

Apply
getArray (missionConfigFile/"A3A"/"version") params [["_major", 0, [0]], ["_minor", 0, [0]], ["_patchLvl", 0, [0]]];
[MINIMUM_MISSION_VERSION_AR] params [["_reqMajor", 0], ["_reqMinor", 0], ["_reqPatchLvl", 0]];
Parse Mission Version: Extracts major, minor, patch from mission config
Uses params with default values [0, [0]] for type checking
Type [0] enforces number type, prevents string injection
Parse Mod Requirement: Gets minimum required version from mod config
MINIMUM_MISSION_VERSION_AR is likely a global variable from mod initialization
Same default pattern for type safety
Step 5: Version Comparison

Sqf

Apply
if (_reqMajor > _major || (_reqMajor == _major && (_reqMinor > _minor || (_reqMinor == _minor && _reqPatchLvl > _patchLvl)))) then {
    Error("This mission is outdated and could lack important map details that may break your game, inform your mission maker or update the extension to the latest version.");
    [localize "STR_A3A_missioncheck_oldmission_title", localize "STR_A3A_missioncheck_oldmission"] spawn _fnc_warningMessage;
};
Logic: Checks if required version > mission version
Breakdown:
If reqMajor > major: Different major version - too old
Else if same major and reqMinor > minor: Minor version mismatch
Else if same minor and reqPatchLvl > patchLvl: Patch level mismatch
Action: Logs error and shows warning for outdated missions
Warning: Informs user that mission may lack map details or break
Step 6: Core Initialization

Sqf

Apply
call A3A_fnc_uintToHexGenTables;
call A3A_fnc_shortID_init;
uintToHexGenTables: Generates lookup tables for uint to hexadecimal conversion
Used for short IDs and other systems
Called early to ensure tables are available
shortID_init: Initializes short ID system
Used for creating compact identifiers
Called before any other systems might need short IDs
Step 7: Final Debug

Sqf

Apply
Debug("fn_initPreJIP Finished");
Logs completion message for debugging
Where it leads:
Functions called:

A3A_fnc_uintToHexGenTables - Generates hex conversion lookup tables
A3A_fnc_shortID_init - Initializes short ID system
Local function _fnc_warningMessage - Shows compatibility warnings
Dependencies:

Pre-requisites:
missionConfigFile must be accessible (Arma engine provides)
MINIMUM_MISSION_VERSION_AR must be defined (from mod config)
Stringtable entries for localization must exist
Post-requisites:
Hex tables available for encoding/decoding
Short ID system ready for use
Mission compatibility determined
System Integration:

First step in mod initialization chain (pre-init)
Runs on every machine joining a mission
Prevents incompatible mod/mission combinations
Ensures core utilities are available for later init functions
Part of Antistasi's "wrapper" system for mission compatibility
Global Variables Modified:

None directly, but enables:
Short ID generation system
Hex conversion tables
Mission compatibility state
Synchronization/Network Implications:

Runs locally on each machine (clients and server)
No network synchronization needed
Warnings are local (only visible to affected machine)
Initialization is idempotent (safe to run multiple times)
Edge Cases:

Headless Client: Exits early due to !hasInterface check
Missing stringtable: Warning function will error (dependency on strings)
Invalid version format: params with type checking prevents most issues
Missing mission config: Handled by non-Antistasi check
Networked: No synchronization issues since all machines run same validation
Function: fn_initRivalsVehClassToCrew.sqf
Function Name: fn_initRivalsVehClassToCrew.sqf
What it does: Creates a lookup table (hashmap) that maps vehicle classnames to crew loadout arrays for different sides. This system allows vehicles to spawn with faction-appropriate crew based on which side controls or operates them. The lookup uses priority-based vehicle categories, where specialized categories override general ones.

Context:

Called from initVarServer.sqf during server initialization
Used when spawning vehicle crew with A3A_fnc_createVehicleCrew
Provides faction-specific crew loadouts for Rivals and other factions
How it does that:
Step 1: Category Definition (Template Section)

Sqf

Apply
private _allVehClassToCrew = [
    [FactionGet(all,"vehiclesRivalsArmor"),[FactionGet(riv,"unitCrew")]],
    [FactionGet(all,"vehiclesRivalsLight"),[FactionGet(riv,"unitRifle")]],
    [FactionGet(all,"vehiclesRivalsStatics"),[FactionGet(riv,"unitRifle")]],
    [FactionGet(riv,"vehiclesRivalsUavs"), ["O_UAV_AI"]],
    [FactionGet(all,"vehiclesRivalsAir"),[FactionGet(riv,"unitRifle")]],
    [FactionGet(all,"vehiclesRivals"),[FactionGet(riv,"unitRifle")]]
];
Structure: Array of arrays: [ [vehicleClassnames], [crewLoadout1, crewLoadout2, ...] ]
FactionGet Usage:
FactionGet(all,"vehiclesRivalsArmor") - All factions' rival armor vehicles
FactionGet(riv,"unitCrew") - Rivals' crew unit class
FactionGet(riv,"unitRifle") - Rivals' rifleman unit class
["O_UAV_AI"] - Direct classname for UAV AI
Priority Order: Top categories have higher priority
Example: "vehiclesRivalsArmor" processed before "vehiclesRivals"
Specialized armor overrides general rivals list
Step 2: Reverse for Priority

Sqf

Apply
reverse _allVehClassToCrew;
Why: Later processing loops through array sequentially
Effect: Original top elements (higher priority) are processed LAST
Logic: When hashmap has duplicate keys, last assignment wins
Result: Higher priority categories override lower ones
Step 3: HashMap Initialization

Sqf

Apply
private _const_emptyArray = [];
private _const_emptyString = "";
private _vehClassToCrew = createHashMap;
Constants: Pre-define empty values for type checking
Hashmap: Creates efficient key-value store for lookups
Hashmap Advantages: O(1) lookup time, no array iteration needed
Step 4: Category Processing Loop

Sqf

Apply
{
    private _currentVehClassToCrew = _x;
Loop: Iterates through each category array
Variable: _currentVehClassToCrew contains [vehClassArray, crewLoadoutArray]
Step 5: Input Validation

Sqf

Apply
if !((_currentVehClassToCrew#0) isEqualType _const_emptyArray) then {
    Error("VehicleClassesNotArray | A vehicle category was not an array, but was instead '"+str (_currentVehClassToCrew#0)+"'. Please fix this.");
    assert false;
};
Check: First element must be an array of vehicle classnames
Error: Logs detailed error message with actual value
Assert: Triggers script error to stop execution
Type Safety: Prevents malformed category definitions
Step 6: Vehicle Classname Processing

Sqf

Apply
{
    if !(_x isEqualType _const_emptyString) then {
        Error("VehicleClassNotString | A vehicle was not a classname, but was instead '"+str _x+"'. Please fix this.");
        assert false;
    } else {
        _vehClassToCrew set [_x,_currentVehClassToCrew#1];
    };
} forEach (_currentVehClassToCrew#0);
Inner Loop: Iterates through each vehicle classname in category
Type Check: Each element must be a string (classname)
Assignment: Sets hashmap entry: vehicleClassname -> crewLoadoutArray
_currentVehClassToCrew#1 is the crew loadout array for entire category
Each vehicle in category gets same crew loadouts
Priority Resolution: If vehicle appears in multiple categories, last assignment wins (due to reverse)
Step 7: Return Result

Sqf

Apply
_vehClassToCrew;
Output: Returns the completed hashmap
Type: HashMap where keys are vehicle classnames, values are crew loadout arrays
Where it leads:
Functions called:

FactionGet - Retrieves faction data from hashmaps
No other SQF functions called directly
Dependencies:

Pre-requisites:
FactionGet function must be available (from template system)
Faction hashmaps must be loaded (riv, all)
Vehicle classnames must exist in mission/campaign
Crew unit classnames must exist (O_UAV_AI, etc.)
Post-requisites:
Hashmap available for vehicle crew spawning
Used by A3A_fnc_createVehicleCrew and similar functions
System Integration:

Part of template/faction data system
Used during mission runtime for dynamic crew assignment
Allows flexible faction switching without hardcoding
Enables AI to spawn with appropriate crew for vehicle type and faction
Global Variables Modified:

None directly, but returned hashmap is typically stored in server variable:
DECLARE_SERVER_VAR(A3A_vehClassToCrew,_vehClassToCrew) (from example)
Synchronization/Network Implications:

Runs on server during initialization
Hashmap is local to server (not networked)
Used server-side for spawning
Clients don't need this data directly
Edge Cases:

Duplicate Vehicle Classes: Higher priority category wins (due to reverse processing)
Empty Category: Would cause error in validation
Missing Faction Data: FactionGet may return nil, causing issues
Non-String Classname: Caught by type validation
Non-Array Categories: Caught by outer validation
Code Snippet Examples (from comments):

Usage Example 1:
Sqf

Apply
private _sideIndex = [west,east,resistance,civilian] find (side player);
private _typeX = typeOf _vehicle;
private _crewLoadout = A3A_vehClassToCrew getOrDefault [_typeX,[_groupsOcc get "grunt", _groupsInv get "grunt", _groupsReb get "staticCrew", "C_Man_1"]] select _sideIndex;
Finds side index for player's side
Gets vehicle type
Looks up crew loadout with default fallback
Selects appropriate loadout for side
Usage Example 2:
Sqf

Apply
private _vehClassToCrew = call A3A_fnc_initVehClassToCrew;
DECLARE_SERVER_VAR(A3A_vehClassToCrew,_vehClassToCrew);
Calls initialization function
Stores result in server variable
Parameter Flow:

Input: None (uses FactionGet to retrieve data)
Output: Hashmap with structure:

Apply
{
  "B_Heli_Light_01_F": ["O_UAV_AI"],
  "B_T_MBT_01_cannon_F": ["I_soldier_F"],
  "O_UAV_02_F": ["O_UAV_AI"],
  ...
}
Summary of Documented Functions
fn_initGarrisons.sqf
Purpose: Initialize garrison composition for all strategic markers in new game Key Operations:

Determines garrison size per marker type
Selects faction-appropriate groups based on marker ownership
Builds garrison arrays with random group selection
Updates visual markers and handles game mode 3 special case
Separates strategic vs militia garrisons
Critical Dependencies:

Faction data (A3A_faction_occ, A3A_faction_inv)
Marker ownership (sidesX)
Garrison size function (A3A_fnc_garrisonSize)
Marker update function (A3A_fnc_mrkUpdate)
fn_initPreJIP.sqf
Purpose: Pre-JIP validation and core system initialization Key Operations:

Validates mission/mod compatibility
Checks version compatibility with warnings
Initializes hex conversion and short ID systems
Runs on all machines before mission load
Critical Dependencies:

Mission config structure (missionConfigFile)
Version constants (MINIMUM_MISSION_VERSION_AR)
Stringtable for localization
Display availability (findDisplay 46)
fn_initRivalsVehClassToCrew.sqf
Purpose: Create vehicle-to-crew loadout lookup table Key Operations:

Defines vehicle categories with priority
Validates input structure and types
Builds hashmap for efficient lookup
Handles category priority through reverse processing
Critical Dependencies:

Faction data system (FactionGet)
Vehicle classnames from templates
Unit classnames for crew loadouts
Type validation for safety
System Flow:


Apply
PreJIP Init → Hex/ShortID tables → Var Init (faction data) → Vehicle Crew Lookup → Garrisons Init
   ↓
Server Only: Faction templates loaded
   ↓
Server Only: Garrison data created
   ↓
Runtime: Vehicle spawning uses crew lookup
Network Flow:

PreJIP: Local per machine
Vehicle Crew: Server-only initialization
Garrisons: Server initialization, public variables set
All synchronization handled through setVariable public flags

Function Name: fn_initServer.sqf
What it does:
This is the main server initialization function for the Antistasi 3 (A3A) persistent campaign. It is called after the mission starts and orchestrates the entire server-side setup, including parameter loading, database interactions, faction initialization, system activation, and persistent campaign management. It ensures the server is in a ready state before allowing game loops and player actions to begin.

How it does that:

1. Initial Logging and Parameter Setup

Sqf

Apply
logLevel = "LogLevel" call BIS_fnc_getParamValue; publicVariable "logLevel";
A3A_logDebugConsole = "A3A_logDebugConsole" call BIS_fnc_getParamValue; publicVariable "A3A_logDebugConsole";
Info("Server init started");
A3A_serverVersion = QUOTE(VERSION); publicVariable "A3A_serverVersion";
Step 1: Retrieves mission parameters for logging verbosity and debug console accessibility. Publishes them globally for client access.
Step 2: Logs the start of server initialization.
Step 3: Sets and publishes the server version for version checking and compatibility.
Edge Cases: If parameters are missing, defaults are used by BIS_fnc_getParamValue.
2. Pre-Setup Checks and HQ Object Handling

Sqf

Apply
if (isClass (missionConfigFile/"CfgFunctions"/"A3A")) exitWith {};
if (call A3A_fnc_modBlacklist) exitWith {};
{
    _x enableRopeAttach false;
    _x allowDamage false;
    _x hideObjectGlobal true;
} forEach [boxX, flagX, vehicleBox, mapX, petros];
Step 1: Checks if the mission already has A3A functions defined (pre-mod mission compatibility). Exits if true to prevent conflict.
Step 2: Calls modBlacklist to check if incompatible mods are active. Exits if blacklist triggers.
Step 3: Hides HQ objects (arsenal box, flag, vehicle box, map board, Petros) and disables rope attach and damage for safety.
Global Variables Modified: boxX, flagX, vehicleBox, mapX, petros (object references).
3. Map Texture Customization

Sqf

Apply
switch (toLower worldname) do {
    case "cam_lao_nam": {};
    case "vn_khe_sanh": {mapX setObjectTextureGlobal [0,"Pictures\Mission\whiteboard.paa"];};
    default {mapX setObjectTextureGlobal [0,"Pictures\Mission\whiteboard.jpg"];};
};
Step: Sets map texture based on world name. Uses default whiteboard image unless on specific VTEM maps (cam_lao_nam, vn_khe_sanh) where custom textures are applied.
Global Variable Modified: mapX (object texture state).
4. Save System and Background Initialization

Sqf

Apply
enableSaving [false,false];
call A3A_fnc_initVarCommon;
call A3A_fnc_initZones;
[] spawn A3A_fnc_setupMonitor;
Step 1: Disables in-game saving (handled by A3A's persistent save system).
Step 2: Calls initVarCommon to set up common variables (faction definitions, vehicle classes, etc.).
Step 3: Calls initZones to initialize map marker zones (capturable territories, objectives).
Step 4: Spawns setupMonitor to handle the setup UI (new campaign, load save, etc.) in parallel.
Called Functions: A3A_fnc_initVarCommon, A3A_fnc_initZones, A3A_fnc_setupMonitor.
5. Background Systems Activation

Sqf

Apply
["Initialize"] call BIS_fnc_dynamicGroups;
[] execVM QPATHTOFOLDER(Scripts\fn_advancedTowingInit.sqf);
call A3A_fnc_loadNavGrid;
call A3A_fnc_addNodesNearMarkers;
Info("Server JNA preload started");
["Preload"] call jn_fnc_arsenal;
A3A_backgroundInitDone = true;
Step 1: Initializes dynamic groups for squad management.
Step 2: Executes external advanced towing script.
Step 3: Loads pathfinding navigation grid for AI and convoy routing.
Step 4: Adds navigation nodes near map markers for better pathfinding.
Step 5: Preloads the JNA (Just Enough Arsenal) system, caching item types for performance.
Step 6: Sets A3A_backgroundInitDone flag for other systems to know initialization is progressing.
Called Functions: A3A_fnc_loadNavGrid, A3A_fnc_addNodesNearMarkers, jn_fnc_arsenal (external).
Global Variables Modified: A3A_backgroundInitDone.
6. PATCOM Variables Initialization

Sqf

Apply
Info("Server Initialising PATCOM Variables");
[] call A3A_fnc_patrolInit;
Step: Calls patrolInit to set up patrol command (PATCOM) system variables, used for AI squad management and garrison behavior.
Called Function: A3A_fnc_patrolInit.
7. Game Start and Parameter-Dependent Initialization

Sqf

Apply
waitUntil {sleep 0.1; !isNil "A3A_saveData"};
A3A_startupState = "starting"; publicVariable "A3A_startupState";
Step: Waits for A3A_saveData to be set by the setup monitor (new campaign or loaded save). Sets startup state to "starting" and publishes it.
Global Variables Modified: A3A_saveData, A3A_startupState.
8. Parameter Synchronization from Save Data

Sqf

Apply
private _savedParamsHM = createHashMapFromArray (A3A_saveData get "params");
{
    // ... loop through all A3A params
} forEach ("true" configClasses (configFile/"A3A"/"Params"));
Step: Extracts saved mission parameters from A3A_saveData. For each param class:
Skips spacers/titles.
Retrieves saved value or defaults to param's default.
Converts bool ↔ number if needed.
Publishes the value to all clients.
Global Variables Modified: All mission parameters (e.g., gameMode, minWeaps, etc.) are set in missionNamespace.
9. ACE Medical Initialization

Sqf

Apply
if (A3A_hasACEMedical) then { call A3A_fnc_initACEUnconsciousHandler };
Step: If ACE Medical is detected, initializes the custom unconscious handler for compatibility.
Called Function: A3A_fnc_initACEUnconsciousHandler.
10. Arsenal Initialization

Sqf

Apply
boxX call jn_fnc_arsenal_init;
Step: Initializes JNA on the arsenal box using saved data.
Called Function: jn_fnc_arsenal_init (external).
11. Server-Side Variable Initialization

Sqf

Apply
[A3A_saveData] call A3A_fnc_initVarServer;
Step: Calls initVarServer to set up server-specific variables (faction data, side relations, etc.) based on saved data and mission parameters.
Called Function: A3A_fnc_initVarServer.
12. Game Mode Side Relations

Sqf

Apply
switch (gameMode) do {
    case (2): {
        Occupants setFriend [Invaders,1];
        Invaders setFriend [Occupants,1];
    };
    case (3): { "CSAT_carrier" setMarkerAlpha 0 };
};
Step: Adjusts side relations for Cooperative mode (gameMode 2) and hides CSAT carrier marker for Enemy Only mode (gameMode 3).
Global Variables Modified: Occupants, Invaders, CSAT_carrier (marker).
13. Time Multiplier

Sqf

Apply
setTimeMultiplier settingsTimeMultiplier;
Step: Sets the game time speed based on the settingsTimeMultiplier parameter.
14. Campaign Load or New Game Setup

Sqf

Apply
private _startType = A3A_saveData get "startType";
if (_startType != "new") then {
    // ... load campaign
} else {
    // ... new game setup
};
Case: Load Campaign

Sqf

Apply
A3A_saveTarget = [A3A_saveData get "serverID", A3A_saveData get "gameID", worldName];
call A3A_fnc_loadServer;
Sets A3A_saveTarget (server ID, game ID, world name) and calls loadServer to restore game state from database.
Case: New Game

Sqf

Apply
call A3A_fnc_initGarrisons;
// ... arsenal filling logic
private _categoriesToPublish = createHashMap;
private _addedClasses = createHashMap;
{ ... } foreach FactionGet(reb,"initialRebelEquipment");
// ... pistol start logic
{ publicVariable ("unlocked" + _x) } forEach keys _categoriesToPublish;
call A3A_fnc_checkRadiosUnlocked;
private _posHQ = A3A_saveData get "startPos";
{ sidesX setVariable [_x, teamPlayer, true]; } forEach controlsX;
petros setPos _posHQ;
[_posHQ, true] call A3A_fnc_relocateHQObjects;
Calls initGarrisons to populate all territory markers with garrison units.
Adds initial rebel equipment to JNA data and unlocks categories.
If pistolStart is true, removes primary/secondary weapons and magazines, keeping only handguns.
Publishes unlocked categories to clients.
Disables nearby roadblocks/specops around HQ start position.
Places Petros at HQ and calls relocateHQObjects to set up other HQ objects.
Called Functions: A3A_fnc_initGarrisons, A3A_fnc_checkRadiosUnlocked, A3A_fnc_relocateHQObjects.
15. Campaign ID Management

Sqf

Apply
if (_startType != "load") then {
    private _serverID = profileNamespace getVariable ["ss_serverID", ""];
    _serverID = [_serverID, false] select (A3A_saveData get "useNewNamespace");
    private _allIDs = call A3A_fnc_collectSaveData apply { _x get "gameID" };
    private _newID = str(floor(random(90000) + 10000));
    while { _newID in _allIDs } do { _newID = str(floor(random(90000) + 10000)) };
    A3A_saveTarget = [_serverID, _newID, worldName];
};
Step: For new campaigns (not loading), generates a unique 5-digit game ID, avoiding collisions with existing IDs. Sets A3A_saveTarget for future saves.
Called Function: A3A_fnc_collectSaveData to list existing game IDs.
16. Admin and Member List Setup

Sqf

Apply
if (isClass (configFile >> "AntistasiServerMembers")) then {
    // Load members from config
};
if (isPlayer A3A_setupPlayer) then {
    membersX pushBackUnique getPlayerUID A3A_setupPlayer;
    theBoss = A3A_setupPlayer; publicVariable "theBoss";
};
addMissionEventHandler ["OnUserAdminStateChanged", { ... }];
publicVariable "membersX";
Step 1: Loads member UIDs from mission config file if present.
Step 2: Adds the setup player (admin) to members and sets them as commander (theBoss).
Step 3: Adds mission event handler to auto-add admin players to members list when they log in.
Step 4: Publishes membersX to all clients.
Global Variables Modified: membersX, theBoss.
17. Support System and Rebel Gear

Sqf

Apply
call A3A_fnc_initSupports;
call A3A_fnc_generateRebelGear;
call A3A_fnc_createPetros;
Step 1: Initializes support system (artillery, airstrikes, etc.) based on factions and mods.
Step 2: Generates rebel gear loadouts (uniforms, vests, weapons) for the faction.
Step 3: Creates Petros (HQ commander) with his loadout and behavior.
Called Functions: A3A_fnc_initSupports, A3A_fnc_generateRebelGear, A3A_fnc_createPetros.
18. Unhide HQ Objects

Sqf

Apply
{ _x hideObjectGlobal false } forEach [boxX, flagX, vehicleBox, mapX, petros];
Step: Makes all HQ objects visible after initialization is complete.
19. Event Handlers for Disconnect and Game Events

Sqf

Apply
addMissionEventHandler ["HandleDisconnect", { ... }];
addMissionEventHandler ["PlayerDisconnected", { ... }];
addMissionEventHandler ["BuildingChanged", { ... }];
addMissionEventHandler ["EntityKilled", { ... }];
HandleDisconnect: Calls A3A_fnc_onPlayerDisconnect for standard player disconnect.
PlayerDisconnected: Removes player from JNA arsenal queue and calls A3A_fnc_onHeadlessClientDisconnect.
BuildingChanged: Tracks ruined buildings for rebuild quests and antenna states.
EntityKilled: Logs kills, handles vehicle destruction/capture, and triggers post-mortem (loot, cleanup).
Called Functions: A3A_fnc_onPlayerDisconnect, A3A_fnc_onHeadlessClientDisconnect, A3A_fnc_vehKilledOrCaptured, A3A_fnc_postmortem.
20. Finalize Initialization and Start Loops

Sqf

Apply
serverInitDone = true; publicVariable "serverInitDone";
A3A_startupState = "completed"; publicVariable "A3A_startupState";
Step: Sets serverInitDone flag and updates startup state to "completed". All systems should check serverInitDone before proceeding.
Global Variables Modified: serverInitDone, A3A_startupState.
21. Spawn Persistent Loops

Sqf

Apply
[] spawn A3A_fnc_distance;
[] spawn A3A_fnc_resourcecheck;
[] spawn A3A_fnc_aggressionUpdateLoop;
[] spawn A3A_fnc_garbageCleanerTracker;
[] spawn SCRT_fnc_rivals_activityUpdateLoop;
[] spawn SCRT_fnc_rivals_eventLoop;
if (areRandomEventsEnabled) then { [] spawn SCRT_fnc_encounter_gameEventLoop; };
[] spawn A3A_fnc_saveLoop;
[] spawn A3A_fnc_spawnDebuggingLoop;
[] spawn { ... performance logging ... };
Step 1: distance – Spawns unit/vehicle distance monitoring for spawning/despawning.
Step 2: resourcecheck – 10-minute loop for resource income and revolt status.
Step Step 3: aggressionUpdateLoop – Updates aggression levels and triggers QRFs.
Step 4: garbageCleanerTracker – 5-minute loop for object cleanup.
Step 5: Rivals activity and event loops (if enabled).
Step 6: Random event loop (if enabled).
Step 7: Autosave loop that triggers saveLoop if players are active.
Step 8: Debug loop for monitoring.
Step 9: Performance logging based on log level.
Called Functions: A3A_fnc_distance, A3A_fnc_resourcecheck, A3A_fnc_aggressionUpdateLoop, A3A_fnc_garbageCleanerTracker, A3A_fnc_saveLoop, A3A_fnc_spawnDebuggingLoop, A3A_fnc_logPerformance.
22. AI Compatibility Fixes

Sqf

Apply
if ((isClass (configfile >> "CBA_Extended_EventHandlers")) && (isClass (configfile >> "CfgPatches" >> "lambs_danger"))) then {
    ["CAManBase", "InitPost", { ... }] call CBA_fnc_addClassEventHandler;
};
Step: Disables Lambs Danger FSM for all units if both CBA and Lambs are present, preventing AI interference.
Technical Detail: Uses CBA class event handler for unit initialization.
23. Zeus Logging Integration

Sqf

Apply
if(A3A_hasZen) then { ["zen_common_createZeus", { ... }] call CBA_fnc_addEventHandler; };
if(A3A_hasACE) then { ["ace_zeus_createZeus", { ... }] call CBA_fnc_addEventHandler; };
Step: If Zenith or ACE is present, adds Zeus logging handlers to record admin actions.
Called Function: A3A_fnc_initZeusLogging (remote executed).
24. Spectrum Device Scripts

Sqf

Apply
if (enableSpectrumDevice) then {
    [] execVM QPATHTOFOLDER(Scripts\SpectumDevice\spectrum_device.sqf);
    [] execVM QPATHTOFOLDER(Scripts\SpectumDevice\sa_ewar.sqf);
};
Step: If spectrum device is enabled in params, executes external scripts for electronic warfare.
Scripts: spectrum_device.sqf, sa_ewar.sqf.
25. Zone Initialization

Sqf

Apply
call A3U_fnc_initZones;
Step: Initializes zones for the A3U (Antistasi Unlimited) subsystem.
Called Function: A3U_fnc_initZones.
Where it leads:

Functions Called:

A3A_fnc_initVarCommon – Sets up common variables (faction data, vehicle classes, etc.).
A3A_fnc_initZones – Initializes map marker zones for capture and missions.
A3A_fnc_setupMonitor – Manages the setup UI and triggers save data collection.
A3A_fnc_loadNavGrid – Loads pathfinding navigation grid.
A3A_fnc_addNodesNearMarkers – Adds navigation nodes near markers.
jn_fnc_arsenal – External JNA arsenal system (preload and init).
A3A_fnc_patrolInit – Initializes PATCOM variables for AI squad control.
A3A_fnc_initACEUnconsciousHandler – Handles ACE Medical unconsciousness.
A3A_fnc_initVarServer – Sets server-specific variables based on saved data.
A3A_fnc_loadServer – Loads saved campaign state from database.
A3A_fnc_initGarrisons – Populates territory garrisons.
A3A_fnc_checkRadiosUnlocked – Unlocks radios if needed.
A3A_fnc_relocateHQObjects – Moves HQ objects to the new position.
A3A_fnc_collectSaveData – Lists existing campaign IDs.
A3A_fnc_initSupports – Initializes support systems.
A3A_fnc_generateRebelGear – Creates rebel equipment loadouts.
A3A_fnc_createPetros – Creates Petros unit.
A3A_fnc_onPlayerDisconnect – Handles player disconnect.
A3A_fnc_onHeadlessClientDisconnect – Handles headless client disconnect.
A3A_fnc_vehKilledOrCaptured – Manages vehicle destruction/capture.
A3A_fnc_postmortem – Handles post-mortem effects.
A3A_fnc_distance – Spawns/despawns units based on distance.
A3A_fnc_resourcecheck – Resource and revolt status updates.
A3A_fnc_aggressionUpdateLoop – Aggression and QRF management.
A3A_fnc_garbageCleanerTracker – Object cleanup.
A3A_fnc_saveLoop – Persistent save routine.
A3A_fnc_spawnDebuggingLoop – Debug monitoring.
A3A_fnc_logPerformance – Performance logging.
A3A_fnc_initZeusLogging – Zeus action logging.
A3U_fnc_initZones – A3U zone initialization.
Functions Dependent on This:

All client-side functions that check serverInitDone (e.g., initClient).
Mission functions that require A3A_saveData (e.g., initClient, loadPlayer).
Support systems that depend on initSupports results.
Persistent loops (distance, resource check, etc.) that rely on proper variable initialization.
Larger System Fit:
This is the root initialization script for the A3A persistent campaign. It orchestrates all subsystems:

Persistent State: Manages save data, campaign IDs, and database interactions.
Faction Management: Sets up rebel, occupant, and invader factions.
Map Control: Initializes zones, garrisons, and HQ objects.
Gameplay Systems: Activates supports, arsenal, recruitment, and AI patrols.
Player Management: Handles admins, members, and disconnects.
Performance: Spawns monitoring loops and cleanup systems.
Global Variables It Modifies:

logLevel, A3A_logDebugConsole – Logging controls.
A3A_serverVersion – Version string.
A3A_saveData – Save data from setup.
A3A_saveTarget – Server/game ID for saves.
A3A_startupState – Server state ("starting", "completed").
A3A_backgroundInitDone – Background init flag.
A3A_hasACEMedical, A3A_hasZen, A3A_hasACE – Mod detection flags.
membersX – Server member UID list.
theBoss – Current commander.
serverInitDone – Main init flag.
A3A_rebelGear – Generated rebel equipment.
A3A_hasACEMedical, A3A_hasZen, A3A_hasACE – Mod detection flags.
All mission parameters (via missionNamespace).
Side relations (Occupants, Invaders).
Marker states (CSAT_carrier).
Synchronization/Network Implications:

Public Variables: Many variables are broadcast via publicVariable for client access (e.g., logLevel, serverInitDone, A3A_startupState, membersX, theBoss).
Remote Executions:
A3A_fnc_onPlayerDisconnect is called on server.
A3A_fnc_saveLoop is remote executed to all clients for saving checks.
A3A_fnc_initZeusLogging is remote executed for Zeus logging.
Database: Uses jn_fnc_arsenal_init and A3A_fnc_loadServer for database persistence.
Event Handlers: HandleDisconnect, PlayerDisconnected, BuildingChanged, EntityKilled are server-side handlers affecting all clients.
AI and Gameplay Loops: Persistent loops (distance, resourcecheck) run on server, affecting client-spawned units.
Edge Cases and Error Handling:

Pre-Mod Mission Exit: Exits if A3A functions already exist (prevents conflict).
Mod Blacklist: Exits if incompatible mods detected.
Parameter Defaults: Uses default values if saved params missing.
Unique Campaign ID: Random 5-digit ID with collision avoidance.
Headless Client Disconnect: Separate handler from player disconnect.
Lambs AI Disable: Conditional check for CBA and Lambs presence.
Spectrum Device: Only enabled if enableSpectrumDevice param is true.

Function: fn_initSpawnPlaces.sqf
Function Name: 
fn_initSpawnPlaces.sqf
 What it does: This function initializes the spawn positions for vehicles, helicopters, planes, mortars, and SAMs within a specific location (marker). It processes predefined placement markers to calculate precise spawn coordinates, cleans terrain objects (trees, bushes, rocks) that might obstruct spawning, and stores the resulting spawn data in the spawner namespace for use by the spawn system. It is called during mission initialization to prepare locations for AI unit and vehicle spawning.

How it does that:

Parameter Handling & Validation: The function accepts two parameters: the main location marker (_marker) and an array of placement markers (_placementMarker). It initializes empty arrays for different vehicle types.

Sqf

Apply
params ["_marker", "_placementMarker"];

private ["_vehicleMarker", "_heliMarker", "_hangarMarker", "_mortarMarker", "_planeMarker", "_markerPrefix", "_markerSplit", "_first", "_fullName"];

_vehicleMarker = [];
_heliMarker = [];
_hangarMarker = [];
_mortarMarker = [];
_samMarker = [];
_planeMarker = [];
Prefix Calculation: It calculates a prefix for marker names based on the input _marker type (e.g., "airport", "outpost"). This prefix is used to construct full marker names from short names.

Sqf

Apply
_markerPrefix = "";
_markerSplit = _marker splitString "_";
switch (_markerSplit select 0) do
{
  case ("airport"): {_markerPrefix = "airp_";};
  case ("outpost"): {_markerPrefix = "outp_";};
  case ("resource"): {_markerPrefix = "reso_";};
  case ("factory"): {_markerPrefix = "fact_";};
  case ("seaport"): {_markerPrefix = "seap_";};
  case ("milbase"): {_markerPrefix = "milb_";};
};
if(count _markerSplit > 1) then
{
  _markerPrefix = format ["%1%2_", _markerPrefix, _markerSplit select 1];
};
Sort Markers: It iterates through the _placementMarker array. For each marker, it prepends the calculated prefix to get the full marker name. It checks if the marker is within 500 meters of the main marker (error logging if not). It categorizes the marker (vehicle, helipad, hangar, plane, mortar, sam) and adds it to the corresponding list. It also hides the marker visually (setMarkerAlpha 0).

Sqf

Apply
_mainMarker = getMarkerPos _marker;
{
  _first = (_x splitString "_") select 0;
  _fullName = format ["%1%2", _markerPrefix, _x];
  if(_mainMarker distance (getMarkerPos _fullName) > 500) then
  {
    Error_2("Placementmarker %1 is more than 500 meter away from its mainMarker %2. You may want to check that!", _fullName, _marker);
  };
  switch (_first) do
  {
    case ("vehicle"): {_vehicleMarker pushBack _fullName;};
    case ("helipad"): {_heliMarker pushBack _fullName;};
    case ("hangar"): {_hangarMarker pushBack _fullName;};
    case ("plane"): {_planeMarker pushBack _fullName;};
    case ("mortar"): {_mortarMarker pushBack _fullName;};
    case ("sam"): {_samMarker pushBack _fullName;};
  };
  _fullName setMarkerAlpha 0;
} forEach _placementMarker;

if(count _vehicleMarker == 0) then
{
  Info_1("InitSpawnPlaces: Could not find any vehicle places on %1!", _marker);
};
Building Detection (Base Location): It calculates a search radius based on the main marker's size. It scans for specific building types (hangars, garages, helipads) within that radius using nearestObjects. It filters the results to ensure they are inside the main marker area. It sorts them into _hangars, _helipads, and _garages.

Sqf

Apply
private ["_markerSize", "_distance", "_buildings", "_hangars", "_garages", "_helipads", "_markerX"];

_markerSize = markerSize _marker;
_distance = sqrt ((_markerSize select 0) * (_markerSize select 0) + (_markerSize select 1) * (_markerSize select 1));

_buildings = nearestObjects [getMarkerPos _marker, ["Land_Hangar_2", "Helipad_Base_F", "land_bunker_garage", "Land_vn_b_helipad_01", "Land_BludpadCircle", "Land_Hangar_F", "Land_TentHangar_V1_F", "Land_Airport_01_hangar_F", "Land_Mil_hangar_EP1", "Land_Ss_hangar", "Land_Ss_hangard", "Land_vn_helipad_base", "Land_vn_airport_01_hangar_f", "Land_vn_usaf_hangar_01", "Land_vn_usaf_hangar_02", "Land_vn_usaf_hangar_03"], _distance, true];

_hangars = [];
_helipads = [];
_garages = [];

{
  if((getPos _x) inArea _marker) then {
    private _type = typeOf _x;
    switch (true) do {
      case (_x isKindOf "Land_BludpadCircle");
      case (_x isKindOf "Land_vn_helipad_base");
      case (_x isKindOf "Land_vn_b_helipad_01");
      case (_x isKindOf "Helipad_Base_F"): {
        _helipads pushBack _x;
      };
      case (_type in ["Land_Hangar_2","land_bunker_garage"]): {
        _garages pushBack _x;
      };
      default {
        _hangars pushBack _x;
      };
    };
  };
} forEach _buildings;
Building Detection (Additional Placements): It iterates through the specific placement markers (_heliMarker and _hangarMarker) to find additional buildings (helipads and hangars) near them. These are added to the main lists if found.

Sqf

Apply
private _heliCount = count _helipads;
private _hangarCount = count _hangars;

{
  _markerX = _x;
  _markerSize = markerSize _x;
  _distance = sqrt ((_markerSize select 0) * (_markerSize select 0) + (_markerSize select 1) * (_markerSize select 1));
  _buildings = nearestObjects [getMarkerPos _x, ["Land_BludpadCircle", "Land_vn_b_helipad_01", "Helipad_Base_F", "Land_vn_helipad_base"], _distance, true];
  {
    if((getPos _x) inArea _markerX) then
    {
      _helipads pushBackUnique _x;
    };
  } forEach _buildings;
} forEach _heliMarker;

{
  _markerX = _x;
  _markerSize = markerSize _x;
  _distance = sqrt ((_markerSize select 0) * (_markerSize select 0) + (_markerSize select 1) * (_markerSize select 1));
  _buildings = nearestObjects [getMarkerPos _x, ["Land_Hangar_F", "Land_TentHangar_V1_F", "Land_Airport_01_hangar_F", "Land_Mil_hangar_EP1", "Land_Ss_hangar", "Land_Ss_hangard", "Land_vn_airport_01_hangar_f", "Land_vn_usaf_hangar_01", "Land_vn_usaf_hangar_02", "Land_vn_usaf_hangar_03"], _distance, true];
  {
    if((getPos _x) inArea _markerX) then
    {
      _hangars pushBackUnique _x;
    };
  } forEach _buildings;
} forEach _hangarMarker;
Vehicle Spawn Calculation: It iterates through _vehicleMarker. For each, it calculates how many vehicle slots fit based on marker width and SPACING (1 meter). It cleans terrain objects within the specific placement area. Then, it calculates the precise relative coordinates for each vehicle slot and stores the position and direction in _vehicleSpawns.

Sqf

Apply
_vehicleSpawns = [];
{
    _markerX = _x;
    _size = getMarkerSize _x;
    _width = (_size select 0) * 2;
    _height = (_size select 1) * 2;
    if(_width < (4 + 2 * SPACING)) then
    {
      Error_2("InitSpawnPlaces: Marker %1 is not wide enough for vehicles, required are %2 meters!", _x , (4 + 2 * SPACING));
    }
    else
    {
      if(_height < 10) then
      {
        Error_1("InitSpawnPlaces: Marker %1 is not long enough for vehicles, required are 10 meters!", _x);
      }
      else
      {
        //Cleaning area
        private _radius = [0,0] vectorDistance [_width, _height];
        if (!isMultiplayer) then
        {
          {
            if((getPos _x) inArea _markerX) then
            {
              _x hideObject true;
            };
          } foreach (nearestTerrainObjects [getMarkerPos _markerX, ["Tree","Bush", "Hide", "Rock", "Fence"], _radius, true]);
        }
        else
        {
          {
            if((getPos _x) inArea _markerX) then
            {
              [_x,true] remoteExec ["hideObjectGlobal",2];
            };
          } foreach (nearestTerrainObjects [getMarkerPos _markerX, ["Tree","Bush", "Hide", "Rock", "Fence"], _radius, true]);
        };

        //Create the places
        _vehicleCount = floor ((_width - SPACING) / (4 + SPACING));
        _realLength = _vehicleCount * 4;
        _realSpace = (_width - _realLength) / (_vehicleCount + 1);
        _markerDir = markerDir _markerX;
        for "_i" from 1 to _vehicleCount do
        {
          _dis = (_realSpace + 2 + ((_i - 1) * (4 + _realSpace))) - (_width / 2);
          _pos = [getMarkerPos _markerX, _dis, (_markerDir + 90)] call BIS_fnc_relPos;
          _pos set [2, ((_pos select 2) + 0.1) max 0.1];
          _vehicleSpawns pushBack [_pos, _markerDir];
        };
      };
    };
} forEach _vehicleMarker;
Helipad Spawn Calculation: It iterates through the collected helipads. It cleans terrain objects near the helipad position and stores the helipad's position and direction in _heliSpawns.

Sqf

Apply
_heliSpawns = [];
{
    _pos = getPos _x;
    _pos set [2, 0.4];
    if (!isMultiplayer) then
    {
      {
        _x hideObject true;
      } foreach (nearestTerrainObjects [_pos, ["Tree","Bush", "Hide", "Rock"], 5, true]);
    }
    else
    {
      {
        [_x,true] remoteExec ["hideObjectGlobal",2];
      } foreach (nearestTerrainObjects [_pos, ["Tree","Bush", "Hide", "Rock"], 5, true]);
    };
    _dir = direction _x;
    _heliSpawns pushBack [_pos, _dir];
} forEach _helipads;
Plane Spawn Calculation: It iterates through the collected hangars and specific plane placement markers. It calculates the spawn position and adjusts the direction (flipping it by 180 degrees for specific hangar types to align with the doorway). It stores these in _planeSpawns.

Sqf

Apply
_planeSpawns = [];
{
    _pos = getPos _x;
    _pos set [2, ((_pos select 2) + 0.1) max 0.1];
    _dir = direction _x;
    if(_x isKindOf "Land_Hangar_F" || {_x isKindOf "Land_Airport_01_hangar_F" || {_x isKindOf "Land_Mil_hangar_EP1" || {_x isKindOf "Land_Ss_hangar" || {_x isKindOf "Land_Ss_hangard" || {_x isKindOf "Land_vn_airport_01_hangar_f" || {_x isKindOf "Land_vn_usaf_hangar_01" || {_x isKindOf "Land_vn_usaf_hangar_02" || {_x isKindOf "Land_vn_usaf_hangar_03"}}}}}}}}) then
    {
      //This hangar is facing the wrong way...
      _dir = _dir + 180;
    };
    _planeSpawns pushBack [_pos, _dir];
} forEach _hangars;

{
  _planeSpawns pushBack [markerPos _x, markerDir _x];
} forEach _planeMarker;
Garage/Other Spawn Calculation: It iterates through specific garage types. It adjusts the spawn position to be outside the garage structure (e.g., adding vector offsets) and adjusts the direction. These are added to _vehicleSpawns.

Sqf

Apply
{
    _pos = getPos _x;
    _dir = direction _x;

    if(_x isKindOf "land_bunker_garage") then {
      _pos = _pos vectorAdd [2, -6, 0];
    };

    if (_x isKindOf "Land_Hangar_2") then {
      _pos = _pos vectorAdd [0,6, 0.3];
      _dir = _dir - 180;
    };

    _vehicleSpawns pushBack [_pos, _dir];
} forEach _garages;
Mortar & SAM Spawn Calculation: It takes the marker positions for mortars and SAMs, sets a height offset, and stores them in _mortarSpawns and _samSpawns respectively.

Sqf

Apply
_mortarSpawns = [];
{
  _pos = getMarkerPos _x;
  _pos set [2, ((_pos select 2) + 0.1) max 0.1];
  _mortarSpawns pushBack [_pos, 0];
} forEach _mortarMarker;

_samSpawns = [];
{
  _pos = getMarkerPos _x;
  _pos set [2, ((_pos select 2) + 0.1) max 0.1];
  _samSpawns pushBack [_pos, 0];
} forEach _samMarker;
Storage & Finalization: It groups the spawn arrays into _spawns. It iterates through this list. For each type, it creates a unique variable name (e.g., markerName_vehicle_places). It stores the array of positions/directions and an array of boolean flags (initially all false) indicating if a slot is occupied in the spawner namespace. These are set to be public (true).

Sqf

Apply
_spawns = [_vehicleSpawns, _heliSpawns, _planeSpawns, _mortarSpawns, _samSpawns];

{
    if (_x#0 isEqualTo []) then { continue };
    private _varName = format ["%1_%2", _marker, _x#1];
    spawner setVariable [_varName + "_places", _x#0, true];
    spawner setVariable [_varName + "_used", (_x#0) apply {false}, true];
} forEach [[_vehicleSpawns, "vehicle"], [_heliSpawns, "heli"], [_planeSpawns, "plane"], [_mortarSpawns, "mortar"], [_samSpawns, "sam"]];
Where it leads:

Calls:
BIS_fnc_relPos: Used to calculate relative positions for vehicle spawns.
remoteExec ["hideObjectGlobal", 2]: Executes on server (JIP compatible) to hide terrain objects in multiplayer.
Called By:
Likely called by initServer or initClient during the base initialization phase.
System Fit: This is a foundational function for the Spawn System. It pre-calculates all possible spawn points, which are later queried by functions like findSpawnPosition or spawnVehicle to place units without collision or terrain clipping.
Global Variables Modified:
spawner namespace: Sets variables ending in _places (array of positions/directions) and _used (array of booleans) for each marker and type combination.
Function: fn_initUtilityItems.sqf
Function Name: 
fn_initUtilityItems.sqf
 What it does: This function initializes the global lists of buyable utility items (like fuel drums, medical tents, repair stations, and build boxes). It retrieves the actual classnames and prices from the faction configuration, checks for specific mod compatibility (like ACE), and compiles them into arrays and a hash map for the buy dialog and item handling system.

How it does that:

Variable Initialization (Faction Items): It retrieves classnames and prices for specific utility items defined in the reb faction configuration. It constructs arrays containing the classname and price for items like fuel drums, medical boxes, etc.

Sqf

Apply
private _fuelDrum = FactionGet(reb,"vehicleFuelDrum");
private _fuelTank = FactionGet(reb,"vehicleFuelTank");
private _medCrate = FactionGet(reb,"vehicleMedicalBox");
private _medTent = FactionGet(reb,"vehicleHealthStation");
private _ammoStation = FactionGet(reb,"vehicleAmmoStation");
private _repairStation = FactionGet(reb,"vehicleRepairStation");
private _reviveKitBox = FactionGet(reb, "reviveKitBox");
private _lootCrate = [FactionGet(reb,"lootCrate"), lootCratePrice];
private _lightSource = [FactionGet(reb,"vehicleLightSource"), 100];
Item List Construction: It initializes an empty _items array. It conditionally pushes items to this array based on global mission parameters (lootCratesEnabled, reviveKitsEnabled). Each item entry is an array containing: [ClassName, Price, LocalizedName, ActionType, Capabilities].

Sqf

Apply
private _items = [];

if (lootCratesEnabled) then {
    _items pushBack [_lootCrate#0, _lootCrate#1, localize "STR_A3AP_buyvehdialog_loot_crate", "lootbox", ["move", "place", "loot"]];
};

if (reviveKitsEnabled) then {
    _items pushBack [_reviveKitBox#0, _reviveKitBox#1, localize "STR_A3AP_buyvehdialog_revive_kit_box", "revivebox", ["cmmdr", "move", "place", "revivekit"]];
};

_items append [
    [_fuelDrum#0, _fuelDrum#1, localize "STR_A3AP_buyvehdialog_fuel_drum", "refuel", ["fuel", "move", "save", "rotate"]],
    [_fuelTank#0, _fuelTank#1, localize "STR_A3AP_buyvehdialog_fuel_tank", "refuel", ["cmmdr", "fuel", "place", "move", "rotate", "save"]],
    [_medTent#0, _medTent#1, localize "STR_A3AP_buyvehdialog_medical_tent", "heal", ["place", "move", "rotate", "pack"]],
    [_ammoStation#0, _ammoStation#1, localize "STR_A3AP_buyvehdialog_ammo_station", "rearm", ["cmmdr", "ammo", "place", "move", "rotate", "save"]],
    [_repairStation#0, _repairStation#1, localize "STR_A3AP_buyvehdialog_repair_station", "repair", ["cmmdr", "place", "move", "rotate", "pack", "save"]],
    [_lightSource#0, _lightSource#1, localize "STR_A3AP_buyvehdialog_light", "", ["move"]],
    ["Land_PlasticCase_01_small_black_F", 250, "Build Box (Extra Small)", "", ["place", "move", "build"]],
    ["Land_PlasticCase_01_medium_black_F", 500, "Build Box (Small)", "", ["place", "move", "build"]],
    ["A3AU_Build_Box_Large_1", 2500, "Build Box (Medium)", "", ["place", "move", "build"]],
    ["Land_PlasticCase_01_large_black_F", 5000, "Build Box (Large)", "", ["place", "move", "build"]]
];
Mod-Specific Item Addition: It checks A3A_hasACE. If true, it adds ACE-specific medical crates and repair items (ACE_Wheel, ACE_Track) to the list.

Sqf

Apply
if(A3A_hasACE) then {
    _items pushBack [_medCrate#0, _medCrate#1, localize "STR_A3AP_buyvehdialog_medical_box", "heal", ["noclear", "move"]];
    _items pushBack ["ACE_Wheel", 5, "", "", []];
    _items pushBack ["ACE_Track", 5, "", "", []];       // check names
};
Packed Variant Generation: It iterates through items that have the "pack" capability. It looks up the packed object class in the config (A3A_Logistics_Packable) and adds that packed class to the item list with a negative price (indicating it's not buyable directly, but created dynamically).

Sqf

Apply
{
    private _packClass = getText (configFile >> "A3A" >> "A3A_Logistics_Packable" >> _x#0 >> "packObject");
    if (_packClass == "") then { Error_1("Packable item %1 has no packed object", _x#0); continue };
    _items pushBack [_packClass, -1, "", "", ["move", "unpack"]];
} forEach (_items select { "pack" in _x#4 });
Global Variable Assignment: It filters _items to create A3A_utilityItemList (excluding items with negative prices) and creates A3A_utilityItemHM (a hash map) mapping classnames to their full data arrays.

Sqf

Apply
A3A_utilityItemList = _items select { _x#1 >= 0 } apply { _x#0 };
A3A_utilityItemHM = (_items apply { _x#0 }) createHashMapFromArray _items;
Where it leads:

Calls:
FactionGet: Retrieves data from the faction configuration system.
localize: Retrieves string tables for UI text.
getText: Reads config values for packable items.
Called By:
Called during server initialization (likely by initServer or specific faction loading scripts) to prepare the shop data.
System Fit: This is part of the Logistics/Shop System. It provides the master data source for the "Buy Utility Item" dialog and the logic that handles purchasing, placing, and interacting with these objects.
Global Variables Modified:
A3A_utilityItemList: Array of buyable classnames.
A3A_utilityItemHM: Hash map of all utility item data (buyable and packed).
Function: fn_initVarCommon.sqf
Function Name: 
fn_initVarCommon.sqf
 What it does: This function initializes global variables, constants, and system configurations that are required on both the client and the server during the mission load phase. It handles side definitions, PATCOM (AI) configuration, item category declarations, mod detection (ACE, TFAR, etc.), and building/terrain data arrays.

How it does that:

Side & Color Definitions: Sets up the primary sides (Occupants, Invaders, TeamPlayer) and their associated marker colors.

Sqf

Apply
Occupants = west;
Invaders = east;
teamPlayer = independent;
Rivals = opfor;
colorOccupants = "colorBLUFOR";
colorInvaders = "colorOPFOR";
colorCivilian = "ColorCIV";
colorTeamPlayer = "colorGUER";
colorRivals = "ColorBrown";
respawnTeamPlayer = "respawn_guerrila";
posHQ = getMarkerPos respawnTeamPlayer;
PATCOM Variables: Initializes configuration variables for the custom AI system (PATCOM), such as visual ranges, target retention times, and artillery manager settings.

Sqf

Apply
PATCOM_DEBUG = false;
PATCOM_VISUAL_RANGE = 400;
PATCOM_TARGET_TIME = 120;
PATCOM_ARTILLERY_MANAGER = true;
PATCOM_ARTILLERY_DELAY = 30;
PATCOM_AI_STATICS = true;
PATCOM_AI_STATIC_ARM = 120;
Item Categories: Declares arrays defining how items are sorted (e.g., weaponCategories, itemCategories, magazineCategories). This is crucial for the arsenal and equipment sorting system.

Sqf

Apply
weaponCategories = ["Rifles", "Handguns", "MachineGuns", "MissileLaunchers", "Mortars", "RocketLaunchers", "Shotguns", "SMGs", "SniperRifles", "UsedLaunchers"];
itemCategories = ["Gadgets", "Bipods", "MuzzleAttachments", "PointerAttachments", "Optics", "Binoculars", "Compasses", "FirstAidKits", "GPS", "LaserDesignators",
    "Maps", "Medikits", "MineDetectors", "NVGs", "Radios", "Toolkits", "UAVTerminals", "Watches", "Glasses", "Headgear", "Vests", "Uniforms", "Backpacks"];
magazineCategories = ["MagArtillery", "MagBullet", "MagFlare", "Grenades", "MagLaser", "MagMissile", "MagRocket", "MagShell", "MagShotgun", "MagSmokeShell"];
explosiveCategories = ["Mine", "MineBounding", "MineDirectional"];
otherCategories = ["Unknown"];
Climate Detection: Reads the climate configuration from the mission config based on the world name (e.g., "temperate", "desert"). This is stored in A3A_climate and influences vegetation and weather logic.

Sqf

Apply
private _worldName = toLowerAnsi worldName;
A3A_climate = toLower (if (isText (missionConfigFile/"A3A"/"mapInfo"/_worldName/"climate")) then {
    getText (missionConfigFile/"A3A"/"mapInfo"/_worldName/"climate")
} else {
    getText (configFile/"A3A"/"mapInfo"/_worldName/"climate")
});
Mod Detection: Checks for the presence of mods by looking for specific config classes (e.g., CfgPatches for TFAR, ACRE, ACE, ZEN). Sets boolean flags like A3A_hasACE, A3A_hasTFAR. It also detects specific medical sub-mods like KAT or ADV-CPR.

Sqf

Apply
A3A_hasTFAR = isClass (configFile >> "CfgPatches" >> "task_force_radio");
A3A_hasACRE = isClass (configFile >> "cfgPatches" >> "acre_main");
A3A_hasACE = (!isNil "ace_common_fnc_isModLoaded");
A3A_hasACEMedical = isClass (configFile >> "CfgSounds" >> "ACE_heartbeat_fast_3");
A3A_hasKAT = false;
if(A3A_hasACEMedical && isClass (configFile >> "CfgWeapons" >> "kat_scalpel")) then {A3A_hasKAT = true; };
Building Arrays: Defines white and black lists for buildings used in garrisoning and base creation. Includes vanilla Arma 3 structures, Antistasi specific classes (e.g., land_bunker_garage), and common mod structures (e.g., GM, CUP, WW2, VN). Also defines A3A_lampTypes for the blackout system.

Sqf

Apply
A3A_buildingWhitelist = [
    "Land_Cargo_Tower_V1_F", "Land_Cargo_Tower_V1_No1_F", ...
];
A3A_milBuildingWhitelist = A3A_buildingWhitelist + [
    "Land_Radar_01_HQ_F", ...
];
A3A_buildingBlacklist = [
    "Bridge_PathLod_base_F", ...
];
A3A_lampTypes = [
    "Lamps_Base_F", "PowerLines_base_F", ...
];
Audio & Animation Setup: Defines arrays of sound paths for dog barks, injury moans, and radio static. Defines animation arrays for medical actions.

Sqf

Apply
A3A_sounds_dogBark = ["x\A3A\addons\core\Music\dog_bark01.wss", ...];
injuredSounds = [ "a3\sounds_f\characters\human-sfx\Person0\P0_moan_13_words.wss", ... ];
flareSounds = ["A3\Sounds_F\weapons\Flare_Gun\flaregun_1.wss", "A3\Sounds_F\weapons\Flare_Gun\flaregun_2.wss"];
medicAnims = ["AinvPknlMstpSnonWnonDnon_medic_1", ...];
Where it leads:

Calls:
A3A_fnc_categoryOverrides: (Called indirectly via the function list, but likely called here or required by the category system) Adjusts item categorization logic.
A3A_fnc_createCivilianTracks: (Called explicitly) Generates dynamic music arrays.
getMarkerPos: Used to set posHQ.
Called By:
This is the first init function called on both client and server. It is called by the main initialization script (often via init.sqf or a pre-init entry).
System Fit: It establishes the Foundation Layer of the mission. Without these variables, the mission logic (AI, Shop, Map Markers, Zeus) cannot function.
Global Variables Modified:
Sides: Occupants, Invaders, teamPlayer, Rivals.
Mod Flags: A3A_hasACE, A3A_hasTFAR, A3A_hasZen, etc.
System Config: PATCOM_* variables, A3A_climate.
Data Arrays: A3A_buildingWhitelist, A3A_lampTypes, weaponCategories, etc.
Audio: A3A_sounds_dogBark, injuredSounds, etc.

Function Name: fn_initVarServer.sqf
What it does:
This is the server-side initialization script that runs after initVarCommon.sqf. It's responsible for setting up all server-specific variables that need to be synchronized across clients. The script handles:

Initial state variables for mission progression
Aggression and tier systems
Resource management variables
Item categorization and equipment arrays
Template loading for factions
DLC/mod configuration
Vehicle and unit pricing
Garrison and reinforcement variables
It's called once when the mission starts on the server, and its primary purpose is to establish the initial game state that will be saved, loaded, and synchronized across all connected clients.

How it does that:
1. Script Initialization and Parameter Handling
Sqf

Apply
scriptName "initVarServer.sqf";
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Info("initVarServer started");

params ["_saveData"];
Explanation:

Sets the script name for debugging purposes
Includes the script component header (defines macros like Info, Debug_1, etc.)
FIX_LINE_NUMBERS() ensures proper error reporting by adjusting line numbers
Logs the start of the script using the Info macro
Takes a single parameter _saveData which contains mission data from a previous save or initial mission setup
2. Server Variable Declaration System
Sqf

Apply
serverInitialisedVariables = ["serverInitialisedVariables"];

private _declareServerVariable = {
	params ["_varName", "_varValue"];

	serverInitialisedVariables pushBackUnique _varName;

	if (!isNil "_varValue") then {
		missionNamespace setVariable [_varName, _varValue];
	};
};
Explanation:

Creates serverInitialisedVariables array to track which variables have been declared (synchronised)
Defines a closure _declareServerVariable that:
Takes a variable name and value
Adds the variable name to the tracking array (ensures uniqueness)
If the value is not nil, sets the variable in the mission namespace
This system ensures variables are tracked for later synchronization
3. Macro Definitions for Variable Declaration
Sqf

Apply
#define ONLY_DECLARE_SERVER_VAR(name) [#name] call _declareServerVariable
#define DECLARE_SERVER_VAR(name, value) [#name, value] call _declareServerVariable
#define ONLY_DECLARE_SERVER_VAR_FROM_VARIABLE(name) [name] call _declareServerVariable
#define DECLARE_SERVER_VAR_FROM_VARIABLE(name, value) [name, value] call _declareServerVariable
Explanation:

Four macros provide convenient ways to declare server variables:
ONLY_DECLARE_SERVER_VAR: Declare without initial value (for later initialization)
DECLARE_SERVER_VAR: Declare with initial value
ONLY_DECLARE_SERVER_VAR_FROM_VARIABLE: Declare using a variable name (not string literal)
DECLARE_SERVER_VAR_FROM_VARIABLE: Declare using variable name with value
These macros wrap the _declareServerVariable closure for cleaner code
4. General Server Variables Initialization
Sqf

Apply
//time to delete dead bodies, vehicles etc..
DECLARE_SERVER_VAR(cleantime, 3600);
//initial spawn distance. Less than 1Km makes parked vehicles spawn in your nose while you approach.
DECLARE_SERVER_VAR(distanceSPWN, 1000);
DECLARE_SERVER_VAR(distanceSPWN1, distanceSPWN*1.3);
DECLARE_SERVER_VAR(distanceSPWN2, distanceSPWN*0.5);
DECLARE_SERVER_VAR(distanceForAirAttack, 10000);
DECLARE_SERVER_VAR(distanceForLandAttack, 3000);
Explanation:

cleantime: Time in seconds after which dead bodies and vehicles are deleted (3600 = 1 hour)
distanceSPWN: Base spawn distance for entities (1000 meters)
distanceSPWN1: 1.3x spawn distance (1300m) - used for different spawn scenarios
distanceSPWN2: 0.5x spawn distance (500m) - used for closer spawn events
distanceForAirAttack: Maximum attack range for aircraft (10,000 meters)
distanceForLandAttack: Maximum attack range for ground vehicles (3,000 meters)
Sqf

Apply
DECLARE_SERVER_VAR(A3A_activePlayerCount, 1);
DECLARE_SERVER_VAR(difficultyCoef, 0);
DECLARE_SERVER_VAR(bigAttackInProgress, false);
DECLARE_SERVER_VAR(AAFpatrols, 0);
DECLARE_SERVER_VAR(chopForest, false);
Explanation:

A3A_activePlayerCount: Tracks active players for scaling (Headless Client support)
difficultyCoef: Legacy difficulty scaling (set to 0)
bigAttackInProgress: Boolean flag for large attack status
AAFpatrols: Counter for AAF patrols in the field
chopForest: Boolean flag for clearing vegetation around HQ
Sqf

Apply
DECLARE_SERVER_VAR(skillFIA, 5);
DECLARE_SERVER_VAR(aggressionOccupants, 0);
DECLARE_SERVER_VAR(aggressionStackOccupants, []);
DECLARE_SERVER_VAR(aggressionLevelOccupants, 1);
DECLARE_SERVER_VAR(aggressionInvaders, 0);
DECLARE_SERVER_VAR(aggressionStackInvaders, []);
DECLARE_SERVER_VAR(aggressionLevelInvaders, 1);
DECLARE_SERVER_VAR(tierWar, 1);
DECLARE_SERVER_VAR(bombRuns, 0);
DECLARE_SERVER_VAR(revealX, false);
DECLARE_SERVER_VAR(A3A_activeTasks, []);
DECLARE_SERVER_VAR(A3A_taskCount, 0);
Explanation:

skillFIA: Base skill level for FIA soldiers (1-10 scale)
aggressionOccupants/Invaders: Current aggression level (0-100)
aggressionStack: Array tracking aggression changes over time
aggressionLevel: Current tier (1-5) affecting spawn rates and difficulty
tierWar: Current war tier (1-5) affecting enemy equipment quality
bombRuns: Number of bomb run supports used
revealX: Whether enemy positions should be revealed to players
A3A_activeTasks: Array of currently active mission tasks
A3A_taskCount: Counter for generated mission IDs
Sqf

Apply
DECLARE_SERVER_VAR(staticsToSave, []);
DECLARE_SERVER_VAR(staticsToFlip, []);
DECLARE_SERVER_VAR(ungaragedVehicles, []);
DECLARE_SERVER_VAR(haveRadio, false);
server setVariable ["hr", initialHr, true];
server setVariable ["resourcesFIA", initialFactionMoney, true];
Explanation:

staticsToSave: Array of static weapons (MGs, AA, etc.) for saving/loading
staticsToFlip: Array of static weapons that need flipping (ammo depletion)
ungaragedVehicles: Array of vehicles parked outside garages
haveRadio: Boolean flag for radio access
hr: Human resources (manpower) for recruitment (set on server namespace)
resourcesFIA: Faction money pool (set on server namespace)
Sqf

Apply
DECLARE_SERVER_VAR(A3A_lastGarbageCleanTime, serverTime);
DECLARE_SERVER_VAR(A3A_arsenalLimits, createHashMap);
DECLARE_SERVER_VAR(A3A_lastGarbageCleanTimeNote, serverTime);
DECLARE_SERVER_VAR(A3A_unbuiltObjects, []);
Explanation:

A3A_lastGarbageCleanTime: Last time garbage collection ran (using serverTime for consistency)
A3A_arsenalLimits: HashMap for custom item limits per player
A3A_lastGarbageCleanTimeNote: Last time garbage clean notification was sent
A3A_unbuiltObjects: Array of partially constructed objects
5. Antistasi Plus Variables
Sqf

Apply
DECLARE_SERVER_VAR(randomizeRebelLoadoutUniforms, true);
DECLARE_SERVER_VAR(rebelLoadouts, createHashMap);
DECLARE_SERVER_VAR(paradropAttendants, []);
DECLARE_SERVER_VAR(traderDiscount, 0);
DECLARE_SERVER_VAR(traderPosition, []);
DECLARE_SERVER_VAR(constructionsToSave, []);
DECLARE_SERVER_VAR(supportPoints, 0);
DECLARE_SERVER_VAR(isTraderQuestAssigned, false);
DECLARE_SERVER_VAR(isTraderQuestCompleted, false);
DECLARE_SERVER_VAR(areOccupantsDefeated, false);
DECLARE_SERVER_VAR(areInvadersDefeated, false);
DECLARE_SERVER_VAR(areRivalsDiscovered, false);
DECLARE_SERVER_VAR(inactivityStackRivals, []);
DECLARE_SERVER_VAR(inactivityLevelRivals, 5);
DECLARE_SERVER_VAR(rivalsLocationsMap, createHashMap);
DECLARE_SERVER_VAR(rivalsExcludedLocations, createHashMap);
DECLARE_SERVER_VAR(nextRivalsLocationReveal, 0);
DECLARE_SERVER_VAR(areRivalsDefeated, false);
DECLARE_SERVER_VAR(isRivalsDiscoveryQuestAssigned, false);
Explanation:

randomizeRebelLoadoutUniforms: Whether to randomize uniform selection
rebelLoadouts: HashMap storing custom rebel loadout configurations
paradropAttendants: Array of players participating in paradrop missions
traderDiscount: Percentage discount for trader (0-100)
traderPosition: Array of trader location coordinates
constructionsToSave: Array of player-built structures for saving
supportPoints: Currency for non-lethal support (airstrikes, etc.)
isTraderQuestAssigned/Completed: Quest state flags
areOccupantsDefeated/InvadersDefeated: Victory condition flags
areRivalsDiscovered: Whether rival rebel faction is known
inactivityStackRivals: Array tracking rival inactivity
inactivityLevelRivals: Current inactivity tier (1-5)
rivalsLocationsMap: HashMap mapping locations to rival cells
rivalsExcludedLocations: HashMap of locations excluded from rival spawns
nextRivalsLocationReveal: Timestamp for next location reveal event
areRivalsDefeated: Victory condition for rivals
isRivalsDiscoveryQuestAssigned: Quest for discovering rivals
6. Server-Only Variables (Not Synchronized)
Sqf

Apply
prestigeOPFOR = [75, 50] select cadetMode;
prestigeBLUFOR = 0;
occupantsRadioKeys = 0;
invaderRadioKeys = 0;
A3A_recentDamageOcc = [];
A3A_recentDamageInv = [];
A3A_balancePlayerScale = 1;
A3A_balanceVehicleCost = 110;
A3A_balanceResourceRate = A3A_balancePlayerScale * ([A3A_balanceVehicleCost, 140] select (gameMode == 1));
A3A_resourcesDefenceOcc = A3A_balanceResourceRate * 3;
A3A_resourcesDefenceInv = A3A_balanceResourceRate * (A3A_invaderBalanceMul / 10) * 6;
A3A_resourcesAttackOcc = -10 * A3A_balanceResourceRate * (A3A_enemyAttackMul / 10);
A3A_resourcesAttackInv = -10 * A3A_balanceResourceRate * (A3A_enemyAttackMul / 10) * (A3A_invaderBalanceMul / 10) * 0.5;
A3A_curHQInfoOcc = 0;
A3A_curHQInfoInv = 0;
A3A_oldHQInfoOcc = [];
A3A_oldHQInfoInv = [];
A3A_buildingsToSave = [];
cityIsSupportChanging = false;
resourcesIsChanging = false;
savingServer = true;
prestigeIsChanging = false;
zoneCheckInProgress = false;
garrisonIsChanging = false;
movingMarker = false;
markersChanging = [];
playerHasBeenPvP = [];
A3A_playerSaveData = createHashMap;
destroyedBuildings = [];
testingTimerIsActive = false;
A3A_tasksData = [];
hcArray = [];
membersX = [];
theBoss = objNull;
activityIsChanging = false;
baseRivalsDecay = switch (rivalsDifficulty) do { case (1): { 0.28 }; case (2): { 0.42 }; case (3): { 0.65 }; default { Error_1("Can't set base rivals decay - something wrong with %1 difficulty value.", str rivalsDifficulty); }; };
publicVariable "A3A_buildingsToSave";
publicVariable "baseRivalsDecay";
Explanation:

prestigeOPFOR: NATO support percentage (75% on cadet, 50% on regular)
prestigeBLUFOR: FIA support percentage (0% initially)
occupantsRadioKeys/invaderRadioKeys: Keys for radio tower access
A3A_recentDamageOcc/Inv: Recent damage arrays for balance calculations
A3A_balancePlayerScale: Scaling factor for difficulty based on player count
A3A_balanceVehicleCost: Base vehicle resource cost
A3A_balanceResourceRate: Rate at which resources accumulate
A3A_resourcesDefenceOcc/Inv: Starting defense resources for occupants/invaders
A3A_resourcesAttackOcc/Inv: Starting attack resources (negative = time until attack)
A3A_curHQInfoOcc/Inv: Current HQ knowledge (0-1)
A3A_oldHQInfoOcc/Inv: Array of old HQ locations with knowledge values
A3A_buildingsToSave: Synced to clients for destroyed building tracking
cityIsSupportChanging/ resourcesIsChanging: State flags for concurrent operations
savingServer: Locks saves during initialization
prestigeIsChanging: Flag for prestige updates
zoneCheckInProgress: Flag for zone status updates
garrisonIsChanging: Flag for garrison updates
movingMarker: Flag for marker movement
markersChanging: Array of markers being updated
playerHasBeenPvP: Players who've engaged in PvP
A3A_playerSaveData: HashMap for player save data
destroyedBuildings: Array of destroyed buildings (synced on join)
testingTimerIsActive: Flag for mission testing mode
A3A_tasksData: Array of task data
hcArray: Headless client IDs
membersX: Array of clan members
theBoss: Object reference for leader unit
activityIsChanging: Flag for activity updates
baseRivalsDecay: Base decay rate for rivals (configurable by difficulty)
publicVariable: Synchronizes A3A_buildingsToSave and baseRivalsDecay to clients
7. Item Categories Initialization
Sqf

Apply
private _unlockableCategories = allCategoriesExceptSpecial + ["AA", "AT", "GrenadeLaunchers", "ArmoredVests", "ArmoredHeadgear", "BackpacksCargo"];
DECLARE_SERVER_VAR(allEquipmentArrayNames, allCategories apply {"all" + _x});
DECLARE_SERVER_VAR(unlockedEquipmentArrayNames, _unlockableCategories apply {"unlocked" + _x});
private _otherEquipmentArrayNames = [/* array of 19 equipment array names */];
DECLARE_SERVER_VAR(otherEquipmentArrayNames, _otherEquipmentArrayNames);
everyEquipmentRelatedArrayName = allEquipmentArrayNames + unlockedEquipmentArrayNames + otherEquipmentArrayNames;
Explanation:

_unlockableCategories: Categories that can be unlocked through progression
allEquipmentArrayNames: Array names like ["allWeapons", "allMagazines", etc.]
unlockedEquipmentArrayNames: Array names like ["unlockedWeapons", etc.]
_otherEquipmentArrayNames: Additional equipment arrays (loot, initial gear, etc.)
everyEquipmentRelatedArrayName: Combined list for synchronization
Sqf

Apply
{
	DECLARE_SERVER_VAR_FROM_VARIABLE(_x, []);
} forEach everyEquipmentRelatedArrayName;
Explanation:

Initializes all 50+ equipment arrays as empty arrays
Uses DECLARE_SERVER_VAR_FROM_VARIABLE to set each array
Sqf

Apply
DECLARE_SERVER_VAR(A3A_customUnitTypes, [true] call A3A_fnc_createNamespace);
private _arrayMoney = ["Money_bunch","Money_roll","Money_stack","Money"];
DECLARE_SERVER_VAR(arrayMoney, _arrayMoney);
private _arrayMoneyAmount = [
	HALs_money_oldManItemsPrice select 0,
	HALs_money_oldManItemsPrice select 1,
	HALs_money_oldManItemsPrice select 2,
	HALs_money_oldManItemsPrice select 3
];
DECLARE_SERVER_VAR(arrayMoneyAmount, _arrayMoneyAmount);
Explanation:

A3A_customUnitTypes: Namespace for custom unit type definitions
arrayMoney: Money item class names
arrayMoneyAmount: Corresponding money values (from HAL's system)
8. Mod Configuration (TFAR)
Sqf

Apply
if (A3A_hasTFAR) then
{
	if (isServer) then
	{
		[] spawn {
            #include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
			waitUntil {sleep 1; !isNil "TF_server_addon_version"};
            Info("Initializing TFAR settings");
			["TF_no_auto_long_range_radio", true, true,"mission"] call CBA_settings_fnc_set;
			tf_teamPlayer_radio_code = "";publicVariable "tf_teamPlayer_radio_code";
			tf_east_radio_code = tf_teamPlayer_radio_code; publicVariable "tf_east_radio_code";
			tf_guer_radio_code = tf_teamPlayer_radio_code; publicVariable "tf_guer_radio_code";
			["TF_same_sw_frequencies_for_side", true, true,"mission"] call CBA_settings_fnc_set;
			["TF_same_lr_frequencies_for_side", true, true,"mission"] call CBA_settings_fnc_set;
		};
	};
};
Explanation:

Checks if TFAR is installed (A3A_hasTFAR)
Runs on server only
Waits for TFAR server addon to load
Sets CBA settings:
Disables automatic long-range radio assignment
Sets radio codes to empty string (makes enemy vehicles usable)
Synchronizes short-range frequencies across sides
Synchronizes long-range frequencies across sides
9. DLC/Mod Configuration
Sqf

Apply
private _loadedDLC = getLoadedModsInfo select { (_x#2) and !(_x#1 in ["A3","curator","argo","tacops"]) };
_loadedDLC append (getLoadedModsInfo select { tolower (_x#1) in ["ef", "gm", "rf", "spe", "vn", "ws", "csla"] });
_loadedDLC = _loadedDLC apply { tolower (_x#1) };

A3A_enabledDLC = (_saveData get "DLC") apply {tolower _x};
{
	A3A_enabledDLC insert [0, getArray (configFile/"A3A"/"Templates"/_x/"forceDLC"), true];
} forEach (_saveData get "factions");
A3A_disabledDLC = _loadedDLC - A3A_enabledDLC;
A3A_disabledMods = A3A_disabledDLC;
A3A_vanillaMods = (getLoadedModsInfo select {_x#2 and _x#3} apply {tolower (_x#1)}) + ["", "officialmod"];
Explanation:

_loadedDLC: Detects loaded DLC (excludes core A3, curator, argo, tacops)
Includes specific CDLCs (ef, gm, rf, spe, vn, ws, csla)
A3A_enabledDLC: From save data, converted to lowercase
Forces DLC from faction templates
A3A_disabledDLC: Loaded DLC minus enabled DLC
A3A_disabledMods: Same as disabled DLC
A3A_vanillaMods: Official DLC plus junk tags
Sqf

Apply
private _fctions = _saveData get "factions";
private _occEquipFlags = getArray (configFile/"A3A"/"Templates"/(_fctions#0)/"equipFlags");
private _invEquipFlags = getArray (configFile/"A3A"/"Templates"/(_factions#1)/"equipFlags");
A3A_factionEquipFlags = _occEquipFlags arrayIntersect _invEquipFlags;
Explanation:

Gets faction names from save data
Reads equipment flags from faction templates
Creates intersection of occupant and invader flags (lowest common denominator)
Sqf

Apply
if (gameMode isEqualTo 3) then {
	areInvadersDefeated = true;
	publicVariable "areInvadersDefeated";
};
Explanation:

For game mode 3 (likely invasion-only), marks invaders as defeated
Synchronizes to all clients
Sqf

Apply
A3A_extraEquipMods = [];
{
    private _modpath = (configFile/"CfgPatches"/_x) call A3A_fnc_getModOfConfigClass;
    if (_modpath != "") then { A3A_extraEquipMods pushBackUnique _modpath };
} forEach ["task_force_radio", "acre_main", "tfar_static_radios", "ace_main"];
Explanation:

Initializes array for extra equipment mod paths
Maps specific config classes to mod paths using A3A_fnc_getModOfConfigClass
Pushes unique mod paths (TFAR, ACRE, ACE)
10. Template Loading
Sqf

Apply
{
    private _side = [west, east, resistance, civilian, opfor] # _forEachIndex;
    Info_2("Loading template %1 for side %2", _x, _side);

	private _cfg = configFile/"A3A"/"Templates"/_x;
	private _basepath = getText (_cfg/"basepath") + "\";
	private _file = getText (_cfg/"file") + ".sqf";

	if (_forEachIndex isNotEqualTo 4) then {
		[_basepath + _file, _side] call A3A_fnc_compatibilityLoadFaction;
	} else {
		[_basepath + _file] call A3A_fnc_loadRivals;
	};

    private _type = ["Occ", "Inv", "Reb", "Civ", "Riv"] # _forEachIndex;
    missionNamespace setVariable ["A3A_"+_type+"_template", _x, true];
} forEach (_saveData get "factions");
Explanation:

Iterates over faction templates from save data
Maps index to Arma side: 0=west(Occ), 1=east(Inv), 2=resistance(Reb), 3=civilian(Civ), 4=opfor(Riv)
Reads template configuration from config
Gets base path and file name
Calls compatibility loader for first 4 factions, rival loader for the 5th
Sets template variable (A3A_Occ_template, etc.)
Sqf

Apply
{
	private _cfg = configFile/"A3A"/"AddonVics"/_x;
	private _basepath = getText (_cfg/"path") + "\";
	{
		Info_2("Loading addon file %1 for side %2", _x#1, _x#0);
		[_x#0, _basepath + _x#1] call A3A_fnc_loadAddon;
	} forEach getArray (_cfg/"files");
} forEach (_saveData get "addonVics");
Explanation:

Loads additional vehicle addons
Reads addon vehicle configuration
Iterates over files array [side, filename]
Calls addon loader for each
Sqf

Apply
[] call A3U_fnc_grabBlackMarketVehicles;
call A3A_fnc_compileMissionAssets;

{ publicVariable ("A3A_faction_"+_x); } forEach ["occ", "inv", "riv", "reb", "civ", "all"];
Explanation:

Generates black market vehicle list
Compiles mission assets
Synchronizes faction data to clients:
A3A_faction_occ
A3A_faction_inv
A3A_faction_riv
A3A_faction_reb
A3A_faction_civ
A3A_faction_all
Sqf

Apply
flagX setFlagTexture FactionGet(reb,"flagTexture");
"NATO_carrier" setMarkerText FactionGet(occ,"spawnMarkerName");
"CSAT_carrier" setMarkerText FactionGet(inv,"spawnMarkerName");
"NATO_carrier" setMarkertype FactionGet(occ,"flagMarkerType");
"CSAT_carrier" setMarkertype FactionGet(inv,"flagMarkerType");
Explanation:

Sets HQ flag texture
Updates marker texts for carrier spawn points
Updates marker types for carrier markers
11. Civilian Vehicles Lists
Sqf

Apply
private _fnc_vehicleIsValid = {
	params ["_type"];
	private _cfg = configFile >> "CfgVehicles" >> _type;
	if !(isClass _cfg) exitWith { Error_1("Vehicle class %1 not found", _type); false };
	if (_cfg call A3A_fnc_getModOfConfigClass in A3A_disabledDLC) then {false} else {true};
};
Explanation:

Validates vehicle class existence
Checks if vehicle's mod is disabled
Returns true if valid and not disabled
Sqf

Apply
private _fnc_filterAndWeightArray = {
	params ["_array", "_targWeight"];
	private _output = [];
	private _curWeight = 0;

	// first pass, filter and find total weight
	for "_i" from 0 to (count _array - 2) step 2 do {
		if ((_array select _i) call _fnc_vehicleIsValid) then {
			_output pushBack (_array select _i);
			_output pushBack (_array select (_i+1));
			_curWeight = _curWeight + (_array select (_i+1));
		};
	};
	if (_curWeight == 0) exitWith {_output};

	// second pass, re-weight
	private _weightMod = _targWeight / _curWeight;
	for "_i" from 0 to (count _output - 2) step 2 do {
		_output set [_i+1, _weightMod * (_output select (_i+1))];
	};
	_output;
};
Explanation:

Takes weighted array [class, weight, class, weight...]
First pass: filters invalid vehicles, accumulates total weight
Second pass: re-weights to target weight
Returns re-weighted array
Sqf

Apply
private _civVehicles = [];
private _civVehiclesWeighted = [];

_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivCar"), 4] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivIndustrial"), 1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivMedical"), 0.1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivRepair"), 0.1] call _fnc_filterAndWeightArray);
_civVehiclesWeighted append ([FactionGet(civ,"vehiclesCivFuel"), 0.1] call _fnc_filterAndWeightArray);

for "_i" from 0 to (count _civVehiclesWeighted - 2) step 2 do {
	_civVehicles pushBack (_civVehiclesWeighted select _i);
};

_civVehicles append FactionGet(reb,"vehiclesCivCar");
_civVehicles append FactionGet(reb,"vehiclesCivTruck");
_civVehicles append FactionGet(reb,"vehiclesCivSupply");

DECLARE_SERVER_VAR(arrayCivVeh, _civVehicles);
DECLARE_SERVER_VAR(civVehiclesWeighted, _civVehiclesWeighted);
Explanation:

Creates weighted civilian vehicle arrays
Filters each vehicle type and re-weights to specified weights
Builds unweighted array for quick selection
Adds rebel civilian vehicles
Declares both weighted and unweighted arrays
Sqf

Apply
private _civBoats = [];
private _civBoatsWeighted = [];
private _civBoatData = FactionGet(civ,"vehiclesCivBoat");
for "_i" from 0 to (count _civBoatData - 2) step 2 do {
	private _boat = _civBoatData select _i;
	if (_boat call _fnc_vehicleIsValid) then {
		_civBoats pushBack _boat;
		_civBoatsWeighted pushBack _boat;
		_civBoatsWeighted pushBack (_civBoatData select (_i+1));
	};
};

DECLARE_SERVER_VAR(civBoats, _civBoats);
DECLARE_SERVER_VAR(civBoatsWeighted, _civBoatsWeighted);
Explanation:

Similar process for civilian boats
Doesn't re-weight (weights kept as-is)
Creates both unweighted and weighted arrays
Sqf

Apply
private _undercoverVehicles = (arrayCivVeh - ["C_Quadbike_01_F"]) + FactionGet(reb,"vehiclesCivBoat") + FactionGet(reb,"vehiclesCivHeli") + FactionGet(reb, "vehiclesCivPlane");
DECLARE_SERVER_VAR(undercoverVehicles, _undercoverVehicles);
Explanation:

Creates list of vehicles suitable for undercover operation
Excludes quadbike (too distinctive)
Adds rebel civilian vehicles
12. Item Initialization
Sqf

Apply
[] call A3U_fnc_grabForbiddenItems;
Info("Scanning config entries for items");
[A3A_fnc_equipmentIsValidForCurrentModset] call A3A_fnc_configSort;
Info("Categorizing vehicle classes");
[] call A3A_fnc_vehicleSort;
Info("Categorizing equipment classes");
[] call A3A_fnc_equipmentSort;
Info("Sorting grouped class categories");
[] call A3A_fnc_itemSort;
Info("Building loot lists");
[] call A3A_fnc_loot;
Explanation:

grabForbiddenItems: Identifies banned items (cheats, exploits)
configSort: Scans config for valid equipment
vehicleSort: Categorizes vehicles
equipmentSort: Categorizes weapons, magazines, etc.
itemSort: Groups items by categories
loot: Generates loot tables
Sqf

Apply
if (["tts_emission"] call A3U_fnc_hasAddon) then {call A3U_fnc_emission};
if (["diwako_anomalies_main"] call A3U_fnc_hasAddon) then {call A3U_fnc_fillMapAnomalies};
Explanation:

Checks for TTS Emission mod and initializes if present
Checks for Anomalies mod and spawns anomalies
Sqf

Apply
private _smokeMuzzleHM = createHashMap;
{
	private _muzzle = configName _x;
	{
		if (_x in allSmokeGrenades) then { _smokeMuzzleHM set [_x, _muzzle] };
	} forEach compatibleMagazines ["Throw", _muzzle];
} forEach ("true" configClasses (configFile / "CfgWeapons" / "Throw"));
DECLARE_SERVER_VAR(A3A_smokeMuzzleHM, _smokeMuzzleHM);
Explanation:

Creates hashmap mapping smoke grenade magazines to throw muzzle
Iterates over all throw weapon muzzles
Gets compatible magazines
Maps smoke grenade magazines to their muzzle
Declares the hashmap for server
13. Vehicle Classing and Costs
Sqf

Apply
call A3A_fnc_initUtilityItems;
ONLY_DECLARE_SERVER_VAR(A3A_utilityItemList);
ONLY_DECLARE_SERVER_VAR(A3A_utilityItemHM);
Explanation:

Initializes utility items (movable objects)
Declares utility item list and hashmap without initial value
Sqf

Apply
private _vehFastRope = (FactionGet(all,"vehiclesHelisTransport") + FactionGet(all,"vehiclesHelisLight") + FactionGet(all,"vehiclesHelisAttack") + FactionGet(all,"vehiclesHelisLightAttack"));
DECLARE_SERVER_VAR(vehFastRope, _vehFastRope);
DECLARE_SERVER_VAR(A3A_vehClassToCrew,call A3A_fnc_initVehClassToCrew);
DECLARE_SERVER_VAR(A3A_RivalsVehClassToCrew,call A3A_fnc_initRivalsVehClassToCrew);
Explanation:

vehFastRope: All helicopters capable of fast-roping
A3A_vehClassToCrew: HashMap mapping vehicle class to crew type
A3A_RivalsVehClassToCrew: Similar for rival faction
Sqf

Apply
private _vehicleResourceCosts = createHashMap;
{ _vehicleResourceCosts set [_x, 20] } forEach FactionGet(all, "staticAA") + FactionGet(all, "staticAT") + FactionGet(all, "staticMortars");
{ _vehicleResourceCosts set [_x, 20] } forEach FactionGet(all, "vehiclesLightUnarmed") + FactionGet(all, "vehiclesTrucks");
{ _vehicleResourceCosts set [_x, 50] } forEach FactionGet(all, "vehiclesLightArmed");
{ _vehicleResourceCosts set [_x, 70] } forEach FactionGet(all, "vehiclesLightAPCs");
{ _vehicleResourceCosts set [_x, 100] } forEach FactionGet(all, "vehiclesAPCs");
{ _vehicleResourceCosts set [_x, 150] } forEach FactionGet(all, "vehiclesAA") + FactionGet(all, "vehiclesArtillery") + FactionGet(all, "vehiclesIFVs");
{ _vehicleResourceCosts set [_x, 170] } forEach FactionGet(all, "vehiclesLightTanks");
{ _vehicleResourceCosts set [_x, 230] } forEach FactionGet(all, "vehiclesTanks");
Explanation:

Creates hashmap for AI resource costs
Sets costs by vehicle type:
Static weapons: 20
Light unarmed: 20
Light armed: 50
Light APCs: 70
APCs: 100
AA/Artillery/IFVs: 150
Light tanks: 170
Tanks: 230
Sqf

Apply
{ _vehicleResourceCosts set [_x, 70] } forEach FactionGet(all, "vehiclesHelisLight") + FactionGet(all, "vehiclesAirPatrol");
{ _vehicleResourceCosts set [_x, 100] } forEach FactionGet(all, "vehiclesHelisTransport");
{ _vehicleResourceCosts set [_x, 130] } forEach FactionGet(all, "vehiclesHelisLightAttack") + FactionGet(all, "vehiclesPlanesTransport");
{ _vehicleResourceCosts set [_x, 150] } forEach FactionGet(all, "vehiclesDropPod") + FactionGet(all, "uavsAttack");
{ _vehicleResourceCosts set [_x, 250] } forEach FactionGet(all, "vehiclesPlanesCAS") + FactionGet(all, "vehiclesPlanesAA");
{ _vehicleResourceCosts set [_x, 250] } forEach FactionGet(all, "vehiclesHelisAttack");
{ _vehicleResourceCosts set [_x, 275] } forEach FactionGet(all, "vehiclesPlanesGunship");
{ _vehicleResourceCosts set [_x, 250] } forEach FactionGet(all, "vehiclesPlanesLargeCAS") + FactionGet(all, "vehiclesPlanesLargeAA");
Explanation:

Continues setting costs for air vehicles:
Light helicopters: 70
Transport helicopters: 100
Light attack helicopters/transport planes: 130
Drop pods/UAVs: 150
CAS/AA planes: 250
Attack helicopters: 250
Gunships: 275
Large CAS/AA: 250
Sqf

Apply
private _groundVehicleThreat = createHashMap;
{ _groundVehicleThreat set [_x, 40] } forEach FactionGet(all, "staticMGs");
{ _groundVehicleThreat set [_x, 60] } forEach FactionGet(all, "vehiclesLightArmed");
{ _groundVehicleThreat set [_x, 80] } forEach FactionGet(all, "staticAA") + FactionGet(all, "staticAT") + FactionGet(all, "staticMortars");
{ _groundVehicleThreat set [_x, 80] } forEach FactionGet(Reb, "vehiclesAA") + FactionGet(Reb, "vehiclesAT");
{ _groundVehicleThreat set [_x, 90] } forEach FactionGet(all, "vehiclesLightAPCs");
{ _groundVehicleThreat set [_x, 120] } forEach FactionGet(all, "vehiclesAPCs");
{ _groundVehicleThreat set [_x, 180] } forEach FactionGet(all, "vehiclesLightTanks");
{ _groundVehicleThreat set [_x, 200] } forEach FactionGet(all, "vehiclesAA") + FactionGet(all, "vehiclesArtillery") + FactionGet(all, "vehiclesIFVs");
{ _groundVehicleThreat set [_x, 300] } forEach FactionGet(all, "vehiclesTanks");
Explanation:

Creates hashmap for threat values
Threat values used for targeting priority and damage calculations:
Static MGs: 40
Light armed: 60
Static AT/AA/Mortars: 80
Rebel AA/AT: 80
Light APCs: 90
APCs: 120
Light tanks: 180
AA/Artillery/IFVs: 200
Tanks: 300
Sqf

Apply
private _rebelVehicleCosts = createHashMap;

_fnc_setPriceIfValid =
{
	_this params ["_hashMap", "_className", "_price"];
	private _configClass = configFile >> "CfgVehicles" >> _className;
    if (isClass _configClass) then {
		_hashMap set [_className, _price];
	};
};

{ [_rebelVehicleCosts, _x, 100] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesBasic");
{ [_rebelVehicleCosts, _x, 200] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesCivCar") + FactionGet(reb, "vehiclesCivBoat");
{ [_rebelVehicleCosts, _x, 600] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesCivTruck") + FactionGet(reb, "vehiclesMedical");
{ [_rebelVehicleCosts, _x, 300] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesTruck");
{ [_rebelVehicleCosts, _x, 200] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesLightUnarmed");
{ [_rebelVehicleCosts, _x, 800] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesLightArmed");
{ [_rebelVehicleCosts, _x, 500] call _fnc_setPriceIfValid } forEach FactionGet(reb, "staticMGs") + FactionGet(reb, "vehiclesBoat");
{ [_rebelVehicleCosts, _x, 1000] call _fnc_setPriceIfValid } forEach FactionGet(reb, "staticAT");
{ [_rebelVehicleCosts, _x, 1200] call _fnc_setPriceIfValid } forEach FactionGet(reb, "staticAA");
{ [_rebelVehicleCosts, _x, 2500] call _fnc_setPriceIfValid } forEach FactionGet(reb, "staticMortars");
{ [_rebelVehicleCosts, _x, 1500] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesAA");
{ [_rebelVehicleCosts, _x, 1200] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesAT");
{ [_rebelVehicleCosts, _x, 5000] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesCivHeli");
{ [_rebelVehicleCosts, _x, 5000] call _fnc_setPriceIfValid } forEach FactionGet(reb, "vehiclesPlane") + FactionGet(reb, "vehiclesCivPlane");
Explanation:

Creates hashmap for rebel vehicle purchase prices
Helper function validates class exists before setting price
Prices in currency units:
Basic vehicles: 100
Civilian cars/boats: 200
Trucks/medical: 600
Unarmed trucks: 300
Unarmed light: 200
Armed light: 800
Static MGs/boats: 500
Static AT: 1000
Static AA: 1200
Static mortars: 2500
AA vehicles: 1500
AT vehicles: 1200
Civilian helicopters: 5000
Planes: 5000
Sqf

Apply
private _overrides = FactionGet(Reb, "attributesVehicles") + FactionGet(Occ, "attributesVehicles") + FactionGet(Inv, "attributesVehicles");
{
	private _vehType = _x select 0;
	if !(_vehType in ((keys _vehicleResourceCosts) + (keys _rebelVehicleCosts))) then { continue };
	{
		if !(_x isEqualType []) then { continue };
		_x params ["_attr", "_val"];
		call {
			if (_attr == "threat") exitWith { _groundVehicleThreat set [_vehType, _val] };
			if (_attr == "cost") exitWith { _vehicleResourceCosts set [_vehType, _val] };
			if (_attr == "rebCost") exitWith { _rebelVehicleCosts set [_vehType, _val] };
		};
	} forEach _x;
} forEach _overrides;
Explanation:

Applies template overrides for vehicle attributes
Iterates over override arrays from all factions
For each vehicle type, applies attributes:
"threat": Updates ground vehicle threat
"cost": Updates AI resource cost
"rebCost": Updates rebel purchase price
Sqf

Apply
DECLARE_SERVER_VAR(A3A_vehicleResourceCosts, _vehicleResourceCosts);
DECLARE_SERVER_VAR(A3A_groundVehicleThreat, _groundVehicleThreat);
DECLARE_SERVER_VAR(A3A_rebelVehicleCosts, _rebelVehicleCosts);
Explanation:

Declares all three hashmaps as server variables
14. Mod Template Compatibility
Sqf

Apply
if (A3A_hasACE) then { [] call A3A_fnc_aceModCompat; };
Explanation:

If ACE is installed, calls ACE compatibility function
Modifies loadouts, medical settings, etc.
15. ACRE Radio Modifications
Sqf

Apply
if (A3A_hasACRE) then {FactionGet(reb,"initialRebelEquipment") append ["ACRE_PRC343","ACRE_PRC148","ACRE_PRC152","ACRE_SEM52SL"];};
if (A3A_hasACRE && startWithLongRangeRadio) then {FactionGet(reb,"initialRebelEquipment") append ["ACRE_SEM70", "ACRE_PRC117F", "ACRE_PRC77"];};
Explanation:

Adds ACRE radios to initial rebel equipment
Includes long-range radios if configured
16. Unit and Vehicle Prices
Sqf

Apply
{server setVariable [_x,50,true]} forEach [FactionGet(reb,"unitRifle"), FactionGet(reb,"unitCrew")];
{server setVariable [_x,75,true]} forEach [FactionGet(reb,"unitMG"), FactionGet(reb,"unitGL"), FactionGet(reb,"unitLAT")];
{server setVariable [_x,100,true]} forEach [FactionGet(reb,"unitMedic"), FactionGet(reb,"unitExp"), FactionGet(reb,"unitEng")];
{server setVariable [_x,150,true]} forEach [FactionGet(reb,"unitSL"), FactionGet(reb,"unitSniper")];
{server setVariable [_x,500,true]} forEach [FactionGet(reb,"unitAT"), FactionGet(reb,"unitAA")];
Explanation:

Sets unit recruitment prices on server namespace:
Rifleman/Crew: 50
MG/GL/LAT: 75
Medic/Explosive/Engineer: 150
SL/Sniper: 150
AT/AA specialists: 500
Sqf

Apply
{server setVariable [_x select 0, _x select 1, true]} forEach (FactionGet(reb,"blackMarketStock"));
server setVariable [FactionGet(reb,"rallyPoint"), 100, true];
{
	server setVariable [_x, _y, true];
} forEach A3A_rebelVehicleCosts;
Explanation:

Sets black market item prices
Sets rally point cost (100)
Sets vehicle purchase prices from hashmap
17. Garrison Initialization
Sqf

Apply
tierPreference = 1;
cityUpdateTiers = [4, 8];
cityStaticsTiers = [0.2, 1];
airportUpdateTiers = [3, 6, 8];
airportStaticsTiers = [0.5, 0.75, 1];
outpostUpdateTiers = [4, 7, 9];
outpostStaticsTiers = [0.4, 0.7, 1];
milbaseUpdateTiers = [3, 6, 8];
milbaseStaticsTiers = [0.45, 0.725, 1];
otherUpdateTiers = [3, 7];
otherStaticsTiers = [0.3, 1];
[] call A3A_fnc_initPreference;
Explanation:

Sets tier thresholds for different location types
tierPreference: Base tier (1)
cityUpdateTiers: When cities upgrade (tiers 4, 8)
cityStaticsTiers: Static weapon multipliers (0.2, 1)
Similar patterns for airports, outposts, military bases, other locations
Calls A3A_fnc_initPreference to initialize preference system
18. Reinforcement Variables
Sqf

Apply
DECLARE_SERVER_VAR(reinforceMarkerOccupants, []);
DECLARE_SERVER_VAR(reinforceMarkerInvaders, []);
DECLARE_SERVER_VAR(canReinforceOccupants, []);
DECLARE_SERVER_VAR(canReinforceInvaders, []);
Explanation:

reinforceMarkerOccupants/Invaders: Arrays of markers that can request reinforcements
canReinforceOccupants/Invaders: Arrays of available reinforcements
19. Synchronization
Sqf

Apply
DECLARE_SERVER_VAR(initVarServerCompleted, true);
{
	publicVariable _x;
} forEach serverInitialisedVariables;

Info("initVarServer completed");
Explanation:

Sets completion flag
Synchronizes all server-initialised variables to clients
Logs completion
Where it leads:
Functions Called Directly:
A3A_fnc_createNamespace - Creates namespace for custom unit types
A3U_fnc_grabBlackMarketVehicles - Generates black market vehicle list
A3A_fnc_compileMissionAssets - Compiles mission assets
A3U_fnc_grabForbiddenItems - Identifies forbidden items
A3A_fnc_configSort - Scans config for equipment
A3A_fnc_vehicleSort - Categorizes vehicles
A3A_fnc_equipmentSort - Categorizes equipment
A3A_fnc_itemSort - Groups items
A3A_fnc_loot - Builds loot tables
A3U_fnc_emission - Initializes TTS Emission mod
A3U_fnc_fillMapAnomalies - Initializes Anomalies mod
A3A_fnc_initUtilityItems - Initializes utility items
A3A_fnc_initVehClassToCrew - Creates vehicle class to crew mapping
A3A_fnc_initRivalsVehClassToCrew - Creates rival vehicle class to crew mapping
A3A_fnc_aceModCompat - Applies ACE compatibility
A3A_fnc_initPreference - Initializes garrison preference system
Functions that depend on this one:
fn_initClient.sqf - Client initialization that receives synchronized variables
All mission logic - Every system depends on these variables being set
Save/Load systems - All saved data references these variables
Garrison systems - Use tier preferences and resource costs
Economy systems - Use vehicle and unit prices
Mission systems - Use aggression levels, tiers, and flags
Template systems - Rely on faction data loaded here
Player progression - Uses unlockable categories and prices
Global Variables Modified:
serverInitialisedVariables - Tracks all synchronized variables
allEquipmentArrayNames - Names of all equipment arrays
unlockedEquipmentArrayNames - Names of unlockable arrays
otherEquipmentArrayNames - Additional equipment arrays
everyEquipmentRelatedArrayName - Combined list for synchronization
prestigeOPFOR/prestigeBLUFOR - Support percentages
occupantsRadioKeys/invaderRadioKeys - Radio access keys
A3A_recentDamageOcc/Inv - Recent damage tracking
A3A_balancePlayerScale/VehicleCost/ResourceRate - Balance parameters
A3A_resourcesDefenceOcc/Inv - Defense resources
A3A_resourcesAttackOcc/Inv - Attack resources
A3A_curHQInfoOcc/Inv - Current HQ knowledge
A3A_oldHQInfoOcc/Inv - Old HQ knowledge
A3A_buildingsToSave - Synced building list
cityIsSupportChanging/ resourcesIsChanging/ prestigeIsChanging - State flags
savingServer - Save lock
zoneCheckInProgress/ garrisonIsChanging/ movingMarker - Operation flags
markersChanging - Markers being updated
playerHasBeenPvP - PvP history
A3A_playerSaveData - Player save data
destroyedBuildings - Destroyed building list
testingTimerIsActive - Testing mode flag
A3A_tasksData - Task data
hcArray - Headless client IDs
membersX - Clan members
theBoss - Leader unit
activityIsChanging - Activity update flag
baseRivalsDecay - Rival decay rate
all the equipment arrays - Weapons, magazines, etc.
A3A_customUnitTypes - Custom unit namespace
arrayMoney/ arrayMoneyAmount - Money items
A3A_enabledDLC/ A3A_disabledDLC/ A3A_disabledMods/ A3A_vanillaMods - Mod configuration
A3A_factionEquipFlags - Faction equipment flags
A3A_extraEquipMods - Extra mod paths
A3A_faction_occ/inv/riv/reb/civ/all - Faction data
A3A_Occ_template/Inv_template/Reb_template/Civ_template/Riv_template - Template names
arrayCivVeh/ civVehiclesWeighted/ civBoats/ civBoatsWeighted/ undercoverVehicles - Vehicle lists
A3A_smokeMuzzleHM - Smoke grenade mapping
A3A_utilityItemList/ A3A_utilityItemHM - Utility items
vehFastRope - Fast-rope capable vehicles
A3A_vehClassToCrew - Vehicle crew mapping
A3A_RivalsVehClassToCrew - Rival vehicle crew mapping
A3A_vehicleResourceCosts - AI vehicle costs
A3A_groundVehicleThreat - Vehicle threat values
A3A_rebelVehicleCosts - Rebel vehicle prices
reinforceMarkerOccupants/Invaders - Reinforcement markers
canReinforceOccupants/Invaders - Available reinforcements
initVarServerCompleted - Completion flag
Synchronization/Network Implications:
publicVariable is used for:

All variables in serverInitialisedVariables array
A3A_buildingsToSave
baseRivalsDecay
Faction data (A3A_faction_occ, etc.)
Faction template variables
Client reception:

Clients receive these variables before their initialization
Used for client-side UI, mission logic, and local calculations
Some variables are read-only on clients (managed by server)
Save/load implications:

All these variables are serialized by the save system
Loaded values override server initialization on restore
Essential for mission continuity across restarts
JIP (Join in Progress):

JIP clients receive all synchronized variables
Must be set before client initialization
Critical for maintaining game state consistency
Headless Clients:

Receive same variables as players
Use them for AI calculations
A3A_activePlayerCount helps with scaling
Edge Cases Handled:
Missing config classes - Validation in _fnc_vehicleIsValid
Invalid vehicle types - Skipped during vehicle sorting
Disabled DLC - Vehicles filtered out
Zero total weight - Returns empty array in _fnc_filterAndWeightArray
Duplicate variable names - pushBackUnique ensures uniqueness
Nil values - Handled in _declareServerVariable
Missing factions - Template loading checks for existence
Game mode variations - Different paths for gameMode 3
Mod detection - Checks for TFAR, ACRE, ACE, TTS Emission, Anomalies
Difficulty settings - Affects prestige, decay rates

Function Name: A3A_fnc_initVehClassToCrew
What it does: This function initializes a global lookup table that maps vehicle classnames to their corresponding crew load-outs for different sides (Government/occupants, Invaders, Rebels, Civilians). It is used during server initialization to pre-compute vehicle-crew associations so that when a vehicle is spawned or interacted with, the correct crew type can be quickly selected. The function is designed to be called once on the server during mission init, typically inside fn_initVarServer.sqf.

How it does that:

Pre-Processing Definition Block:
The function includes a commented-out edit block (lines 21-39) where template load-outs are defined. In the live code, a predefined array _allVehClassToCrew holds category-to-loadout mappings. Each entry is a 2-element array:

Element 0: Array of vehicle classnames in that category (e.g., ["B_Truck_01_transport_F", "B_Truck_01_covered_F"]).
Element 1: 4-element array of load-outs for [Government, Invader, Rebel, Civilian] in that order.
Example snippet:
Sqf

Apply
private _allVehClassToCrew = [
    [FactionGet(all,"vehiclesFixedWing"),[FactionGet(occ,"unitPilot"), FactionGet(inv,"unitPilot"), FactionGet(reb,"unitCrew"), FactionGet(civ,"unitMan")]],
    [FactionGet(all,"vehiclesArmor"), [FactionGet(occ,"unitCrew"), FactionGet(inv,"unitCrew"), FactionGet(reb,"unitCrew"), FactionGet(civ,"unitMan")]],
    ...
];
Explanation: FactionGet retrieves configuration values from the mission's faction templates. The array is ordered by priority; higher priority categories (like specialized armor) are placed earlier.

Initialization of Constants and Hashmap:

Sqf

Apply
private _const_emptyArray = [];
private _const_emptyString = "";
private _vehClassToCrew = createHashMap;
reverse _allVehClassToCrew;
Explanation: Constants for type checking. The hashmap _vehClassToCrew will store the final mapping. reverse inverts the array so that the last defined categories (top in the editor) have priority when there are overlapping classnames (though the code later processes them in reverse order, ensuring top entries are processed last and overwrite earlier ones).

Loop Over Categories and Populate Hashmap:

Sqf

Apply
{
    private _currentVehClassToCrew = _x;
    if !((_currentVehClassToCrew#0) isEqualType _const_emptyArray) then {
        Error("VehicleClassesNotArray | A vehicle category was not an array...");
        assert false;
    } else {
        {
            if !(_x isEqualType _const_emptyString) then {
                Error("VehicleClassNotString | A vehicle was not a classname...");
                assert false;
            } else {
                _vehClassToCrew set [_x,_currentVehClassToCrew#1];
            };
        } forEach (_currentVehClassToCrew#0);
    }
} forEach _allVehClassToCrew;
Explanation: For each category, it validates that the first element is an array of classnames. For each classname in the array, it checks it's a string and sets the hashmap entry. The value is the entire 4-element load-out array. If validation fails, it logs an error and halts execution (via assert false). The final hashmap is returned (_vehClassToCrew).

Return Value:

Sqf

Apply
_vehClassToCrew;
Explanation: The function returns the populated hashmap for assignment to a global variable like A3A_vehClassToCrew.

Where it leads:

Called Functions:
FactionGet: Retrieves faction-specific data (defined in template configs).
Error: Logs error messages (defined in logging utilities).
assert: Halts execution on validation failure.
createHashMap: SQF native function to create a hashmap.
Functions Depending on This:
Functions that look up crew for a vehicle (e.g., A3A_fnc_crewTypeForVehicle in CREATE class) use A3A_vehClassToCrew to fetch load-outs.
Called during fn_initVarServer.sqf to set the global server variable.
Larger System Fit:
Part of the mission initialization chain. It ensures consistent crew types across spawned vehicles, linking to the faction system via FactionGet. Global variable A3A_vehClassToCrew is set and persists on the server. No network implications (server-only init).
Requirements & Edge Cases:

Input validation ensures category data is correctly structured; errors are logged and execution stops.
Overlap handling: If two categories define the same vehicle classname, the later category (higher in the original list) overwrites the earlier due to reverse and hashmap key uniqueness.
Assumes FactionGet returns valid strings/arrays; if not, errors propagate.
No error recovery—on validation failure, mission init halts.

Function Name: A3A_fnc_initZeusLogging
What it does: This function initializes event handlers on Zeus curator modules to log curator actions to the server log. It provides detailed tracking of Zeus interactions for debugging or moderation purposes. It is called when Zeus is activated in the mission, typically passing an array of curator module objects.

How it does that:

Parameter Validation and Input:

Sqf

Apply
params ["_curatorModules"];
Explanation: Accepts an array _curatorModules containing curator module objects. No explicit type checking, but assumes the array is populated with valid curator objects.

Loop Over Each Curator Module:

Sqf

Apply
{
    private _logEventId = [];
    ...
} forEach _curatorModules;
Explanation: Iterates through each curator module, attaching event handlers. The unused _logEventId variable is a leftover placeholder.

Attach Event Handlers for Logging:
For each event type (e.g., CuratorFeedbackMessage, CuratorGroupPlaced), an event handler is added:

Sqf

Apply
_x addEventHandler ["CuratorFeedbackMessage", {
    params ["_curator", "_errorID"];
    ServerInfo_2("Event: CuratorFeedbackMessage, Curator: %1, ErrorID: %2",name player,_errorID);
}];
Explanation: Uses params to extract event parameters. Logs via ServerInfo_2 (a wrapper for server-side logging) with the player's name and error ID. Similar handlers cover group, marker, object, waypoint, and ping events (total 21 handlers). Each logs specific data: e.g., for CuratorObjectPlaced, it logs object type via typeOf _entity.

Complete Handler Coverage:
Handlers are added for all major Zeus events:

Curator feedback and errors (e.g., CuratorFeedbackMessage).
Group interactions (double-click, placed, selection changed).
Marker interactions (deleted, double-click, edited, placed, selection changed).
Object interactions (deleted, double-click, edited, placed, selection changed).
Ping events (CuratorPinged).
Waypoint interactions (deleted, double-click, edited, placed, selection changed). Code snippet for waypoint placed:
Sqf

Apply
_x addEventHandler ["CuratorWaypointPlaced", {
    params ["_curator", "_group", "_waypointID"];
    ServerInfo_3("Event: CuratorWaypointPlaced, Curator: %1, Group: %2, WaypointID: %3",name player,_group,_waypointID);
}];
Explanation: Logs curator name, group, and waypoint ID. ServerInfo_2/3 are macro-based loggers that include timestamps and format strings.

No Return Value:
The function doesn't return anything; it modifies the curator modules via event handlers.

Where it leads:

Called Functions:
ServerInfo_2 and ServerInfo_3: Logging macros (likely defined in script_component.hpp or similar) that output to server RPT log.
No other functions called directly.
Functions Depending on This:
Called by Zeus initialization code (e.g., initServer or a Zeus module activation script) to set up logging.
Depends on A3A_fnc_initServer or similar to provide curator modules.
Larger System Fit:
Part of the logging and debugging framework. Integrates with the Zeus system; logs are server-side, so no client sync. Modifies global server log output; no variables modified. Used for monitoring Zeus actions in multiplayer.
Requirements & Edge Cases:

Assumes _curatorModules is a non-empty array of valid curator objects; if empty, no handlers are attached.
Event handlers use name player—on a dedicated server, player refers to the Zeus admin if logged in; otherwise, logs "Error: No Player".
No error handling for invalid curator objects; attaching handlers to non-objects may fail silently.
Handlers are attached once per call; if called multiple times, duplicates may occur (no cleanup provided).
Logging level depends on server logging settings (e.g., ServerInfo might require debug mode).
Function Name: A3A_fnc_initZones
What it does: This function initializes map zones (cities, airports, military bases, resources, factories, outposts, seaports, controls, and custom markers) for the Antistasi Altis (A3A) mission. It creates and configures markers, populates them with data (e.g., civilian population), sets up interactions (e.g., radio towers, banks, fuel stations), and publishes global variables for server-side and client-side use. It's called during mission init on the server.

How it does that:

Script Header and Map Info Loading:

Sqf

Apply
scriptName "initZones.sqf";
Info("initZones started");
forcedSpawn = [];
citiesX = [];
private _mapInfo = missionConfigFile/"A3A"/"mapInfo"/toLower worldName;
if (!isClass _mapInfo) then {_mapInfo = configFile/"A3A"/"mapInfo"/toLower worldName};
[] call A3A_fnc_prepareMarkerArrays;
Explanation: Sets script name for debugging, logs start, initializes empty arrays. Loads map-specific config from missionConfigFile or configFile based on world name. Calls prepareMarkerArrays to initialize predefined marker arrays (e.g., airportsX, milbases).

Debug/Preview Mode for Altis and Chernarus:

Sqf

Apply
if ((toLower worldName) in ["altis", "chernarus_summer"]) then {
    "((getText (_x >> ""type"")) == ""Hill"") && ..."
    configClasses (configfile >> "CfgWorlds" >> worldName >> "Names") apply {
        _name = configName _x;
        _sizeX = getNumber (_x >> "radiusA");
        _sizeY = getNumber (_x >> "radiusB");
        _size = [_sizeX, _sizeY] select (_sizeX <= _sizeY);
        _pos = getArray (_x >> "position");
        _size = [_size, 50] select (_size < 10);
        _mrk = createmarker [format ["%1", _name], _pos];
        _mrk setMarkerSizeLocal [_size, _size];
        _mrk setMarkerShapeLocal "ELLIPSE";
        _mrk setMarkerBrushLocal "SOLID";
        _mrk setMarkerColorLocal "ColorRed";
        _mrk setMarkerText _name;
        controlsX pushBack _name;
    };
};
Explanation: For debug mode, scans CfgWorlds for hill locations, creates red ellipses as preview markers, adds to controlsX. Uses config filtering to exclude "Magos". Sets marker size based on radius (minimum 50m).

Hide Marker Arrays and Set State:

Sqf

Apply
(seaMarkers + seaSpawn + seaAttackSpawn + spawnPoints + detectionAreas) apply {_x setMarkerAlpha 0};
defaultControlIndex = (count controlsX) - 1;
watchpostsFIA = [];
roadblocksFIA = [];
aapostsFIA = [];
hmgpostsFIA = [];
atpostsFIA = [];
destroyedSites = [];
garrison setVariable ["Synd_HQ", [], true];
markersX = airportsX + milbases + resourcesX + factories + outposts + seaports + controlsX + ["Synd_HQ"];
{
    _x setMarkerAlpha 0;
    spawner setVariable [_x, 2, true];
} forEach markersX;
Explanation: Hides sea-related markers (sets alpha to 0). Initializes empty arrays for FIA outposts. Sets defaultControlIndex for control markers. garrison is a namespace; sets Synd_HQ garrison empty. markersX combines all zone arrays. Iterates to hide markers and set spawner variable (2 means inactive).

Call Base Initialization:

Sqf

Apply
call A3A_fnc_initBases;
Explanation: Calls initBases to set up dummy markers and auto-gen roadblocks for predefined locations.

City (Town) Setup:

Sqf

Apply
private ["_nameX", "_roads", "_numCiv", "_roadsProv", "_roadcon", "_dmrk", "_info"];
private _townPopulations = getArray (_mapInfo/"population");
private _disabledTowns = getArray (_mapInfo/"disabledTowns");
{server setVariable [_x select 0,_x select 1]} forEach _townPopulations;
private _hardCodedPopulation = _townPopulations isNotEqualTo [];
Explanation: Loads population data and disabled towns from map config. Sets server variables for populations. Checks if hard-coded populations are used.

Sqf

Apply
private _cityConfigs = "(toLower getText (_x >> ""type"") in [""namecitycapital"",""namecity"",""namevillage"",""citycenter""]) &&
!(getText (_x >> ""Name"") isEqualTo """") && !((configName _x) in _disabledTowns)"
configClasses (configfile >> "CfgWorlds" >> worldName >> "Names");
if (toLowerANSI worldName isEqualTo "blud_vidda") then {
    private _rv133 = ("configName _x == 'DefaultKeyPoint32'" configClasses (configfile >> "CfgWorlds" >> worldName >> "Names")) select 0;
    _cityConfigs pushBack _rv133; //RV-133, big city without city marker
};
Explanation: Queries CfgWorlds for city-like entries, filtering by type and non-empty name, excluding disabled. Special case for blud_vidda adds RV-133.

For each city config:

Sqf

Apply
_cityConfigs apply {
    _nameX = getText (_x >> "Name");
    _sizeX = getNumber (_x >> "radiusA");
    _sizeY = getNumber (_x >> "radiusB");
    _size = [_sizeY, _sizeX] select (_sizeX > _sizeY);
    _pos = getArray (_x >> "position");
    _size = [_size, 400] select (_size < 400);
    _numCiv = 0;

    if (_hardCodedPopulation) then {
        _numCiv = server getVariable [_nameX, server getVariable (configName _x)];
        if (isNil "_numCiv" || {!(_numCiv isEqualType 0)}) then {
            Error_1("Bad population count data for %1", _nameX);
            _numCiv = (count (nearestObjects [_pos, ["house"], _size]));
        };
    } else {
        _numCiv = (count (nearestObjects [_pos, ["house"], _size]));
    };

    _roads = nearestTerrainObjects [_pos, ["MAIN ROAD", "ROAD", "TRACK"], _size, true, true];
    if (count _roads > 0) then {
        _pos = _roads select 0;
    };
    _numVeh = (count _roads) min (_numCiv / 3);

    _mrk = createmarkerLocal [format ["%1", _nameX], _pos];
    _mrk setMarkerSizeLocal [_size, _size];
    _mrk setMarkerShapeLocal "RECTANGLE";
    _mrk setMarkerBrushLocal "SOLID";
    _mrk setMarkerColorLocal colorOccupants;
    _mrk setMarkerTextLocal _nameX;
    _mrk setMarkerAlpha 0;
    citiesX pushBack _nameX;
    spawner setVariable [_nameX, 2, true];

    _dmrk = createMarkerLocal [format ["Dum%1", _nameX], _pos];
    _dmrk setMarkerShapeLocal "ICON";
    _dmrk setMarkerTypeLocal "loc_Ruin";
    _dmrk setMarkerColor colorOccupants;

    sidesX setVariable [_mrk, Occupants, true];
    _info = [_numCiv, _numVeh, 75, 0];
    server setVariable [_nameX, _info, true];
};
Explanation: For each city:

Retrieves name, calculates size (max radius, min 400m).
Populates _numCiv: from hard-coded server var or by counting nearby houses.
Finds nearest road and adjusts position.
Calculates _numVeh (min of road count or civilians/3).
Creates a colored rectangle marker (hidden), adds to citiesX, sets spawner inactive.
Creates a ruin icon marker for visuals.
Sets sidesX var (owns to Occupants), stores [civs, vehicles, gov%, rebel%] in server variable.
Uses local markers for client visibility but server-side data storage.
Public Variables and Side Assignments:

Sqf

Apply
markersX append citiesX;
sidesX setVariable ["Synd_HQ", teamPlayer, true];
sidesX setVariable ["NATO_carrier", Occupants, true];
sidesX setVariable ["CSAT_carrier", Invaders, true];
Explanation: Adds cities to markersX. Assigns HQ and carriers to sides.

Radio Towers (Antennas) Setup:

Sqf

Apply
private _antennatypes = ["Land_TTowerBig_1_F", ...];
private _banktypes = ["land_gm_euro_office_01", ...];
private _posAntennas = getArray (_mapInfo/"antennas");
private _blacklistIndex = getArray (_mapInfo/"antennasBlacklistIndex");
private _hardCodedAntennas = _posAntennas isNotEqualTo [];
private _replaceBadAntenna = { ... }; // Function to hide/replace problematic antennas
Explanation: Defines antenna types. Loads positions and blacklist from config. Defines _replaceBadAntenna function: if antenna is bad type (e.g., Land_Communication_F), hides it and creates a proper one.

Auto-detect if no hard-coded positions:

Sqf

Apply
if (!_hardCodedAntennas) then {
    antennas = nearestObjects [[worldSize /2, worldSize/2], _antennatypes, worldSize];
    private _replacedAntennas = [];
    { _replacedAntennas pushBack ([_x] call _replaceBadAntenna); } forEach antennas;
    antennas = _replacedAntennas;
    antennas apply { ... }; // Create markers and "Killed" event handlers
};
Explanation: Scans entire map for antennas, replaces bad ones, iterates to create markers and event handlers on each. Handler on kill: blacks out cities, removes from arrays, deletes marker, publicizes variables, notifies players.

Hard-coded positions:

Sqf

Apply
if (count _posAntennas > 0) then {
    for "_i" from 0 to (count _posAntennas - 1) do {
        _antennaProv = nearestObjects [_posAntennas select _i, _antennaTypes, 35];
        if (count _antennaProv > 0) then {
            _antenna = _antennaProv select 0;
            if (_i in _blacklistIndex) then {
                _antenna setdamage 1;
            } else {
                _antenna = ([_antenna] call _replaceBadAntenna);
                antennas pushBack _antenna;
                // Similar marker/event handler setup
            };
        };
    };
};
Explanation: Processes config positions; uses nearest antenna, optionally damages if blacklisted, otherwise replaces and sets up.

Banks Setup:

Sqf

Apply
private _posBank = getArray (_mapInfo/"banks");
if ( _posBank isEqualTo []) then {banks = nearestObjects [[worldSize/2, worldSize/2], _banktypes, worldSize]};
if (count _posBank > 0) then {
    for "_i" from 0 to (count _posBank - 1) do {
        _bankProv = nearestObjects [_posBank select _i, _banktypes, 30];
        if (count _bankProv > 0) then {
            private _banco = _bankProv select 0;
            banks = banks + [_banco];
        };
    };
};
Explanation: Auto-detects banks if no positions; otherwise, finds nearest bank to each position and adds to banks array.

Blacklist Destinations:

Sqf

Apply
blackListDest = (markersX - controlsX - ["Synd_HQ"] - citiesX) select {
    private _nearRoads = (getMarkerPos _x) nearRoads (([_x] call A3A_fnc_sizeMarker) * 1.5);
    private _badSurfaces = ["#GdtForest", "#GdtRock", "#GdtGrassTall"];
    private _idx = _nearRoads findIf { !(surfaceType (position _x) in _badSurfaces) && { count roadsConnectedTo _x != 0 } };
    if (_idx == -1) then {true} else {false};
};
Explanation: Selects zones without proper roads nearby (no connected roads on non-bad surfaces) as blacklist for convoys.

Fuel Stations Setup:

Sqf

Apply
private _fuelStationTypes = getArray (_mapInfo/"fuelStationTypes");
if( _fuelStationTypes isEqualTo [] ) then {_fuelStationTypes = ["Land_FuelStation_Feed_F", ...]};
A3A_fuelStationTypes = _fuelStationTypes;
A3A_fuelStations = nearestObjects [[worldSize/2, worldSize/2], _fuelStationTypes, worldSize];
A3A_fuelStations apply {
    _mrkFinalFuel = createMarker [format ["Ant%1", mapGridPosition _x], position _x];
    // ... marker setup ...
    if(A3A_hasACE) then {
        [_x, 250] call ace_refuel_fnc_setFuel;
    };
};
Explanation: Defines types, scans map for stations, creates hidden icons, sets fuel via ACE if mod is active.

Military Administrations Setup:

Sqf

Apply
private _milAdministrationTypes = [...];
private _milAdminPositions = getArray (_mapInfo/"milAdministrations");
{
    private _milAdmins = (nearestObjects [_x, _milAdministrationTypes, 30]) select {!isObjectHidden _x && {alive _x}};
    if (_milAdmins isEqualTo []) then { continue; };
    private _administration = _milAdmins select 0;
    A3A_milAdministrations pushBack _administration;
    // Create marker, set side, spawner, add "Killed" handler to call removeMilAdmin
} forEach _milAdminPositions;
Explanation: For each config position, finds nearest admin building, sets up marker, side, and on-kill event to remove it.

Publicize Variables and Signal Completion:

Sqf

Apply
publicVariable "blackListDest";
publicVariable "markersX";
... // All arrays/vars listed
initZonesDone = true;
publicVariable "initZonesDone";
Explanation: Publishes all global arrays and variables for network sync. Sets initZonesDone for headless clients.

Where it leads:

Called Functions:
A3A_fnc_prepareMarkerArrays: Initializes empty arrays for zones (e.g., airportsX, milbases).
A3A_fnc_initBases: Creates dummy markers and roadblocks.
A3A_fnc_sizeMarker: Returns marker size for blacklist calculation.
BIS_fnc_nearestPosition: Finds nearest antenna/marker.
A3A_fnc_blackout: Blacks out city when antenna dies.
SCRT_fnc_location_removeMilAdmin: Called on military admin kill.
ace_refuel_fnc_setFuel: (ACE mod) Sets fuel for stations.
Functions Depending on This:
All zone-dependent functions (e.g., mission spawning, convoy routing) rely on markersX, citiesX, etc.
Headless clients wait for initZonesDone to start nav init.
Larger System Fit:
Core server initialization for map state. Integrates with config system via map info. Global variables synchronize server/client state for markers, spawners, and objectives. Network implications: publicVariable syncs arrays; event handlers (e.g., on antenna kill) trigger remote notifications.
Requirements & Edge Cases:

Validation: Config entries must exist; otherwise, auto-detection is used (but may be inaccurate). Errors logged for bad population data.
Hard-coded vs Auto: Supports config overrides; auto-detection can be slow (O(world size)).
Mod Integration: Checks A3A_hasACE for fuel stations; assumes FactionGet for initial marker arrays.
Edge Cases: Empty arrays (e.g., _posBank), special world handling (blud_vidda), blacklisting for isolated zones.
Performance: Scans entire map multiple times (antennas, fuel stations); optimized by using worldSize/2 as center.
Synchronization: Local markers for clients; server variables for data; publicVariable for globals. No cross-side sync beyond notifications.

Function Name: fn_initZones.sqf
What it does: This is the primary initialization script for map zones. It detects markers on the map based on predefined naming conventions (e.g., airport, power, resource) and populates global arrays (like airportsX, resourcesX) and variables used throughout the mission. It also generates city markers dynamically based on map config data, initializes helper objects (antennas, banks, fuel stations), and sets up dynamic systems like roadblocks and military administrations. Finally, it makes all initialized data public to ensure the server and clients share the same state.

How it does that: The script follows a structured execution flow: preparing marker arrays, generating terrain zones (hills), setting up cities and spawn points, initializing static objects (antennas, banks), and finally publishing all variables.

Initialization & Map Info Setup: The script starts by declaring scriptName and includes the component header. It checks if the map is defined in the A3A/mapInfo configuration hierarchy.

Sqf

Apply
scriptName "initZones.sqf";
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Info("initZones started");

forcedSpawn = [];
citiesX = [];
private _mapInfo = missionConfigFile/"A3A"/"mapInfo"/toLower worldName;
if (!isClass _mapInfo) then {_mapInfo = configFile/"A3A"/"mapInfo"/toLower worldName};
Explanation: It sets up the environment and defines the _mapInfo variable which holds map-specific configuration data (population, disabled towns, antennas, etc.).
Marker Preparation: It calls A3A_fnc_prepareMarkerArrays to scan all map markers and categorize them into arrays based on their naming prefix.

Sqf

Apply
[] call A3A_fnc_prepareMarkerArrays;
Explanation: This populates global arrays like airportsX, milbases, resourcesX, outposts, etc., based on marker names found on the map editor.
Hill Marker Generation (Altis/Cherno): For specific maps, it automatically generates red elliptical markers for terrain areas marked as "Hill" in the config.

Sqf

Apply
if ((toLower worldName) in ["altis", "chernarus_summer"]) then {
    // Config query string to find Hill types
    "((getText (_x >> ""type"")) == ""Hill"") && ..." configClasses ... apply {
        _name = configName _x;
        _sizeX = getNumber (_x >> "radiusA");
        _size = [_sizeX, 50] select (_size < 10);
        _mrk = createmarker [format ["%1", _name], _pos];
        _mrk setMarkerSizeLocal [_size, _size];
        controlsX pushBack _name;
    };
};
Explanation: This block iterates through map definitions, creating visual markers for hills and adding them to controlsX.
Initialization of initBases: It calls A3A_fnc_initBases to set up dummy markers and autogenerate roadblocks.

Sqf

Apply
call A3A_fnc_initBases;
Explanation: This function prepares the base structures and FIA outposts (watchposts, roadblocks, etc.).
City & Town Generation: It reads population data and disabled towns from the map config. It then iterates through map locations to create city markers, calculate civilian counts, and assign side ownership.

Sqf

Apply
private _townPopulations = getArray (_mapInfo/"population");
private _disabledTowns = getArray (_mapInfo/"disabledTowns");
// ... config query for city types ...
_cityConfigs apply {
    _nameX = getText (_x >> "Name");
    _sizeX = getNumber (_x >> "radiusA");
    _size = [_sizeY, _sizeX] select (_sizeX > _sizeY);
    
    // Calculate population
    if (_hardCodedPopulation) then {
        _numCiv = server getVariable [_nameX, ...];
    } else {
        _numCiv = (count (nearestObjects [_pos, ["house"], _size]));
    };
    
    // Create city marker
    _mrk = createmarkerLocal [format ["%1", _nameX], _pos];
    _mrk setMarkerSizeLocal [_size, _size];
    citiesX pushBack _nameX;
    
    // Store info in server variable
    server setVariable [_nameX, [_numCiv, _numVeh, 75, 0], true];
};
Explanation: This logic handles the core terrain data. It calculates density, creates invisible rectangular zones for gameplay logic, and stores data like [civilians, vehicles, gov%, rebel%] on the server.
Radio Towers (Antennas) and Banks: It sets up arrays for antennas and banks. It uses a helper code block _replaceBadAntenna to hide problematic antenna objects and replace them with destroyable versions. It also attaches an event handler to antennas to trigger blackouts when destroyed.

Sqf

Apply
private _replaceBadAntenna = {
    params ["_antenna"];
    if ((typeof _antenna) in ["Land_Communication_F", ...]) then {
        hideObjectGlobal _antenna;
        private _antennaPos = getPos _antenna;
        private _antennaClass = if (worldName isEqualTo "chernarus_summer") then { "Land_Telek1" } else { "Land_TTowerBig_2_F" };
        _antenna = createVehicle [_antennaClass, _antennaPos, [], 0, "NONE"];
    };
    _antenna;
};

// Antenna Initialization
if (!_hardCodedAntennas) then {
    antennas = nearestObjects [[worldSize /2, worldSize/2], _antennatypes, worldSize];
    { _replacedAntennas pushBack ([_x] call _replaceBadAntenna); } forEach antennas;
    antennas = _replacedAntennas;
    
    // Add Killed EH
    antennas apply {
        _x addEventHandler ["Killed", {
            // Triggers blackout, updates arrays, publicVariable, sends notification
        }];
    };
};
Explanation: This section ensures antennas are "game-ready." It replaces world objects that cannot be destroyed with ones that can. The Killed event handles the gameplay consequence (blackout of nearby towns) and network synchronization.
Fuel Stations & Military Administrations: It scans for fuel station types (configurable via map info) and military administration buildings.

Sqf

Apply
// Fuel Stations
private _fuelStationTypes = getArray (_mapInfo/"fuelStationTypes");
A3A_fuelStations = nearestObjects [[worldSize/2, worldSize/2], _fuelStationTypes, worldSize];
// ... creates markers ...
if(A3A_hasACE) then { [_x, 250] call ace_refuel_fnc_setFuel; };

// Mil Administrations
// Iterates through configured positions, creates markers, adds Killed EH to delete the admin location
_administration addEventHandler ["Killed", {
    [(this select 0), "DESTROY"] call SCRT_fnc_location_removeMilAdmin;
}];
Explanation: It identifies static fuel sources and military offices. For fuel, it optionally initializes ACE fuel. For admins, it attaches an event to handle destruction logic.
Public Variable Synchronization: Finally, all relevant global arrays and variables are published to the network so clients can access them.

Sqf

Apply
publicVariable "blackListDest";
publicVariable "markersX";
publicVariable "citiesX";
// ... many other variables ...
initZonesDone = true;
publicVariable "initZonesDone";
Explanation: This ensures the state is consistent across the multiplayer environment. initZonesDone signals to other scripts that initialization is complete.
Where it leads:

Calls A3A_fnc_prepareMarkerArrays: Gathers and categorizes markers.
Calls A3A_fnc_initBases: Initializes FIA outposts and dummy markers.
Calls A3A_fnc_sizeMarker: Used in blackListDest calculation to determine the size of markers.
Calls SCRT_fnc_location_removeMilAdmin: Called when a military administration is killed.
Depended on by:
init.sqf: Usually runs this script early in the mission lifecycle.
A3A_fnc_createAI... functions: Rely on airportsX, citiesX, etc., to know where to spawn units.
A3A_fnc_mrkUpdate: Uses markersX to update visuals.
Global Variables Modified: airportsX, milbases, resourcesX, factories, outposts, seaports, controlsX, citiesX, antennas, banks, A3A_fuelStations, milAdministrationsX, initZonesDone.
Network Implications: Heavy use of publicVariable to sync state. Event Handlers on antennas trigger global notifications (remoteExec).
Function Name: fn_modBlacklist.sqf
What it does: This function acts as a security guard. It checks for specific unauthorized modifications (MCC, ALiVE, ASR AI) or blacklisted mods. If any are detected, it immediately ends the mission for the client or the entire server to prevent compatibility issues or cheating.

How it does that: It performs a series of checks using isClass and in activatedAddons, then executes the termination command.

Variable Initialization: Initializes a boolean flag _bad to false.

Sqf

Apply
_bad = false;
Mod Detection Checks: It checks for the presence of blacklisted systems.

Sqf

Apply
if (missionNamespace getVariable ["MCC_isMode",false]) then {_bad = true};
if (isClass (configfile >> "CfgVehicles" >> "ALiVE_require")) then {_bad = true};
if ("asr_ai3_main" in activatedAddons) then {_bad = true};
Explanation:
MCC: Checks if the MCC mission module is active.
ALiVE: Checks for the ALiVE mod class definition.
ASR AI: Checks the list of active addons for the ASR AI identifier.
Termination Logic: If _bad is true, it ends the mission. It distinguishes between the server and client to ensure proper termination.

Sqf

Apply
if (_bad) then
{
    if (isServer) then
    {
        ["modUnautorized",false,1,false,false] remoteExec ["BIS_fnc_endMission"];
    }
    else
    {
        ["modUnautorized",false,1,false,false] call BIS_fnc_endMission;
    };
};
Explanation: remoteExec is used on the server to trigger termination on all clients. call is used on clients (non-dedicated) to stop their instance.
Return Value: Returns _bad (true if blacklisted, false otherwise).

Sqf

Apply
_bad;
Where it leads:

Calls BIS_fnc_endMission: The standard function to terminate the game with a specific end type.
Called by: Likely executed during the initialization sequence (init.sqf or initServer.sqf) to prevent the mission from loading with incompatible mods.
Global Variables Modified: None.
Network Implications: Uses remoteExec to distribute the termination command from server to clients.
Function Name: fn_playerMarkers.sqf
What it does: This function runs in an infinite loop on the client. It creates and updates map markers for all playable units (players and headless clients) when the map or GPS is visible. It distinguishes between on-foot units and vehicle crews, updating position, direction, and text (including "Injured" status and vehicle names).

How it does that: It uses a while loop to constantly check the visibility of the map/GPS and the availability of a radio.

Main Loop Setup: An infinite loop waits for the map or GPS to be visible and the player to have a radio.

Sqf

Apply
while {true} do
{
    waitUntil {sleep 0.5; (visibleMap or visibleGPS) and ([player] call A3A_fnc_hasRadio)};
Explanation: This conserves performance by only running logic when the player is looking at the map.
Active Player Tracking: Inside the map-visible loop, it gets the list of currently playable (active) units and extracts their IDs.

Sqf

Apply
private _activePlayers = call A3A_fnc_playableUnits;
private _activeIDs = _activePlayers apply { getPlayerID _x };
Explanation: A3A_fnc_playableUnits filters out dead/unplayable units. getPlayerID creates a unique identifier for the unit.
Marker Cleanup: It deletes markers for players who are no longer active.

Sqf

Apply
{
    deleteMarkerLocal format ["A3A_playerMrk_%1", _x];
} forEach (_markedIDs - _activeIDs);
Explanation: This prevents "ghost" markers from remaining on the map if a player disconnects or dies.
Marker Creation & Update: It iterates through active players to update or create their markers.

Sqf

Apply
private _ID = getPlayerID _x;
private _realUnit = _x getVariable ["owner", _x];
private _name = name _x;
private _mrk = format ["A3A_playerMrk_%1", _ID];

if !(_ID in _markedIDs) then
{
    createMarkerLocal [_mrk, getPosATL _realUnit];
    _mrk setMarkerTypeLocal "mil_triangle";
    _mrk setMarkerColorLocal "ColorWhite";
};
Explanation: It creates a local marker with a unique name if it doesn't exist. It uses _realUnit to handle Zeus remote control (getting the actual unit being controlled).
On-Foot Logic: Checks if the unit is on foot.

Sqf

Apply
if (vehicle _realUnit == _realUnit) then
{
    _mrk setMarkerAlphaLocal 1;
    _mrk setMarkerPosLocal getPosATL _realUnit;
    _mrk setMarkerDirLocal getDir _realUnit;
    if (_realUnit getVariable ["incapacitated",false]) then
    {
        _mrk setMarkerTextLocal format ["%1 Injured", _name];
        _mrk setMarkerColorLocal "ColorRed";
    }
    else
    {
        _mrk setMarkerTextLocal format ["%1", _name];
        _mrk setMarkerColorLocal "ColorWhite";
    };
}
Explanation: Updates position/direction. Changes color to Red and text to "Injured" if the ACE/Revive variable is set.
Vehicle Logic: Checks if the unit is in a vehicle.

Sqf

Apply
private _veh = vehicle _realUnit;
private _crew = crew _veh select { _realUnit == _x or ((theBoss == _x or isPlayer _x) and alive _x) };
if (count _crew == 0 or {_crew#0 != _realUnit}) exitWith { _mrk setMarkerAlphaLocal 0 };
// ... Update marker with vehicle name and driver/gunner info ...
Explanation: It filters the vehicle crew to ensure only relevant players (the boss or players) are shown. If the player is not the primary crew or there's no relevant crew, the marker is hidden. Otherwise, it updates the text to show "PlayerName (VehicleName)" and potentially the gunner/passenger.
Loop Continuation: The inner loop sleeps for 1 second per update and repeats until the map is closed. When closed, all markers are deleted.

Sqf

Apply
sleep 1;
};
{ deleteMarkerLocal format ["A3A_playerMrk_%1", _x] } forEach _markedIDs;
Where it leads:

Calls A3A_fnc_hasRadio: Checks if the player has a radio (likely a requirement for the map marker feature).
Calls A3A_fnc_playableUnits: Gets the list of valid units to track.
Depended on by: The script runs independently on every client.
Global Variables Modified: None (local markers only).
Network Implications: None. This is purely client-side visual feedback.
Function Name: fn_prepareMarkerArrays.sqf
What it does: This script scans the entire map for markers and sorts them into global arrays based on their prefix (e.g., airport_1, resource_2). It also handles "placement markers" (temporary markers used during map setup to define spawn positions) and triggers the generation of spawn places for markers that lack them.

How it does that: It iterates through allMapMarkers, parses their names, and populates arrays.

Initialization: Declares global arrays that will hold marker names.

Sqf

Apply
airportsX = [];
milbases = [];
spawnPoints = [];
resourcesX = [];
factories = [];
outposts = [];
seaports = [];
controlsX = [];
seaMarkers = [];
// ... etc
Placement Marker Sorting Function: Defines a helper function fnc_sortPlacementMarker to parse complex marker names (e.g., airp_1_spawn) into types and linked names.

Sqf

Apply
fnc_sortPlacementMarker = {
    params ["_array", "_split"];
    // ... parses _split array to determine type (airport, outpost, etc) and name ...
    _index = _array findIf {(_x select 0) == _type};
    if(_index == -1) then { _array pushBack [_type, [_name]]; } else { ... };
};
Explanation: This creates a list of [Type, [List of Names]] for markers that define specific spawn positions.
Main Marker Iteration: Loops through allMapMarkers.

Sqf

Apply
{
    _split = _x splitString "_";
    _start = _split select 0;
    switch (toLowerANSI _start) do {
        // ... direct pushes to arrays for prefixes like "airport", "resource" ...
        case ("airport"): {airportsX pushBack _x;};
        
        // ... placement markers call the helper function ...
        case ("airp"): {[_placementMarker, _split] call fnc_sortPlacementMarker;};
    };
} forEach _allMarker;
Explanation: This is the core logic. It identifies the primary category of a marker and either adds it directly to a global array (like airportsX) or processes it further for spawn placement data.
Spawn Place Initialization: It iterates through the collected placement markers and calls A3A_fnc_initSpawnPlaces.

Sqf

Apply
{
    [_x select 0, _x select 1] call A3A_fnc_initSpawnPlaces;
} forEach _placementMarker;
Explanation: This function physically defines where units can spawn at a base (e.g., specific spots on an airfield).
Autogeneration of Spawn Places: It checks if spawn places were generated. If not (e.g., marker exists but no custom spawn points defined), it generates default ones.

Sqf

Apply
{
    private _spawnStr = format ["%1_vehicle_used", _x];
    if (isNil { spawner getVariable _spawnStr }) then {
        [_x, []] call A3A_fnc_initSpawnPlaces;
    };
} forEach (airportsX + resourcesX + factories + outposts + seaports + milbases);
Explanation: This ensures every base has at least some spawn logic, even if the map maker forgot to place specific spawn markers.
Temporary Spawn Marker Linking: Links airport markers to the nearest spawn point for temporary usage.

Sqf

Apply
{
    _nearestMarker = [spawnPoints, getMarkerPos _x] call BIS_fnc_nearestPosition;
    server setVariable [format ["spawn_%1", _x], _nearestMarker, true];
} forEach airportsX;
Where it leads:

Calls A3A_fnc_initSpawnPlaces: Configures spawn points for bases.
Called by: A3A_fnc_initZones.
Depended on by: A3A_fnc_initZones relies on these arrays to process zones.
Global Variables Modified: airportsX, milbases, resourcesX, factories, outposts, seaports, controlsX, seaMarkers, seaSpawn, seaAttackSpawn, detectionAreas, spawnPoints.
Network Implications: server setVariable is used to sync specific spawn links.

Function Name: fn_resourcecheck.sqf
What it does: This is the main server-side resource management function that runs every 10 minutes (600 seconds) to update rebel resources, human resources (HR), city support levels, trigger missions, manage economy progression, and handle various gameplay systems. It's the central hub for economic progression, territorial control updates, and random mission generation.

When/Why it's called: Called by the server scheduler as a persistent loop after the game initialization is complete. It runs continuously for the entire duration of the mission, ensuring the rebel faction's economy, territory control, and mission availability stay dynamic.

How it does that:

1. Server Validation and Initialization (Lines 1-33)
Sqf

Apply
if (!isServer) exitWith {
    Error("Server-only function miscalled");
};
Purpose: Ensures this resource-intensive function only runs on the server to prevent performance issues and sync problems.
Implementation: Immediately exits if called from a client, logging an error.
Variable Declarations (Lines 6-23):

Sqf

Apply
private _resAdd = nil;
private _hrAdd = nil;
private _popReb = nil;
private _popGov = nil;
private _popKilled = nil;
private _popTotal = nil;
private _suppBoost = nil;
private _resBoost = nil;
Purpose: Declares reusable variables outside the main loop to improve performance by avoiding repeated memory allocation.
Special Variables:
_suppBoost: Multiplier for support gains from sea ports (0.5 per owned port)
_resBoost: Multiplier for resource gains from factories (1.25 per functional factory)
_popReb/_popGov: Population under rebel/government control respectively
Trader Vehicle Conditions Loading (Lines 26-48):

Sqf

Apply
private _cfg = (configFile >> "A3U" >> "traderAddons" >> "traderVehicles");
private _condition_AA = getText (_cfg >> "condition_AA");
// ... loads 14 vehicle type conditions
private _conditions = [
	[_condition_AA, "AA"], 
	[_condition_APC, "APCs"], 
	// ... 13 more entries
];
Purpose: Loads conditions from mod configuration that determine when trader vehicles unlock.
Implementation: Reads from A3U config namespace, creating an array of [condition, displayName] pairs.
Technical Detail: Uses configFile root for mod config access. Each condition is a code block that evaluates to boolean.
2. Main Resource Check Loop (Lines 35-325)
2.1 Timer Management
Sqf

Apply
while {true} do {
	nextTick = time + 600;
	waitUntil {sleep 15; time >= nextTick};
    waitUntil {sleep 10; A3A_activePlayerCount > 0};
Purpose: Creates a non-blocking 10-minute cycle with player activity check.
Implementation:
nextTick global variable stores the next check time
Waits 15 seconds between checks for timing accuracy
Requires at least one active player to prevent wasted server resources
Synchronization: Uses time (server time) for timing, ensuring all clients stay synchronized.
2.2 Resource and Population Calculation (Lines 43-130)
Sqf

Apply
_resAdd = 25;  // Base hourly income
_hrAdd = 0;
// ... resets other counters

_suppBoost = 0.5 * (1+ ({sidesX getVariable [_x,sideUnknown] == teamPlayer} count seaports));
_resBoost = 1 + (0.25*({(sidesX getVariable [_x,sideUnknown] == teamPlayer) and !(_x in destroyedSites)} count factories));
Purpose: Calculates multipliers based on owned infrastructure.
Implementation:
_suppBoost: 0.5 * (1 + owned_seaports). Each seaport adds 0.5 support per hour.
_resBoost: 1.25 * (owned_functional_factories). Each factory multiplies resource gain.
Uses sidesX global namespace for territory ownership.
destroyedSites array tracks permanently destroyed locations.
City Processing Loop:

Sqf

Apply
{
	private _city = _x;
	private _resAddCity = 0;
	private _hrAddCity = 0;
	private _cityData = server getVariable _city;
	_cityData params ["_numCiv", "_numVeh", "_supportGov", "_supportReb"];
Purpose: Iterates through all cities (citiesX) to calculate local economic and support contributions.
Implementation:
server namespace stores city data: [civilians, vehicles, government_support, rebel_support]
Support values are percentages (0-100).
destroyedCities are skipped (kills all population).
Population Tracking:

Sqf

Apply
_popTotal = _popTotal + _numCiv;
if (_city in destroyedSites) then { _popKilled = _popKilled + _numCiv; continue };

_popReb = _popReb + (_numCiv * (_supportReb / 100));
_popGov = _popGov + (_numCiv * (_supportGov / 100));
Purpose: Tracks total population and demographics for metrics and future calculations.
Edge Case: Destroyed cities are treated as "dead" and removed from resource calculations.
Radio Tower Influence Adjustment:

Sqf

Apply
private _radioTowerSide = [_city] call A3A_fnc_getSideRadioTowerInfluence;
switch (_radioTowerSide) do
{
	case teamPlayer: {[-1,_suppBoost,_city,false,true] spawn A3A_fnc_citySupportChange};
	case Occupants: {[1,-1,_city,false,true] spawn A3A_fnc_citySupportChange};
	case Invaders: {[-1,-1,_city,false,true] spawn A3A_fnc_citySupportChange};
};
Purpose: Applies automatic support changes based on radio tower ownership.
Logic:
TeamPlayer: + support for rebels
Occupants: + support for government
Invaders: - support for both (destabilizing)
Network: Uses spawn to run asynchronously, calls A3A_fnc_citySupportChange on all clients.
Resource Gain Calculation:

Sqf

Apply
_resAddCity = _numCiv * (_supportReb / 100) / 3;
_hrAddCity = _numCiv * (_supportReb / 10000);
Purpose: Calculates hourly gains from civilian population.
Math:
Resources: 1/3 of rebel-supporting civilians
HR: 1/10000 of rebel-supporting civilians (very small)
Example: 1000 civilians with 80% rebel support = 26.6 resources/hour + 0.008 HR/hour
Territory Modifiers:

Sqf

Apply
if (sidesX getVariable [_city,sideUnknown] == Occupants) then
{
	_resAddCity = _resAddCity / 2;
	_hrAddCity = _hrAddCity / 2;
};
if (_radioTowerSide != teamPlayer) then { _resAddCity = _resAddCity / 2 };
Purpose: Applies penalties for territory under enemy control or without radio tower influence.
Result: Occupied cities and non-influenced cities yield 50% less resources.
Final Accumulation:

Sqf

Apply
_resAdd = _resAdd + _resAddCity;
_hrAdd = _hrAdd + _hrAddCity;
Purpose: Adds local city contributions to global totals.
2.3 City Conversion Logic (Lines 95-130)
Rebel Takeover:

Sqf

Apply
if (_supportGov < _supportReb && {sidesX getVariable [_city,sideUnknown] == Occupants}) then {
	["TaskSucceeded", ["", format [localize "STR_notifiers_city_joined",_city,FactionGet(reb,"name")]]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
	sidesX setVariable [_city,teamPlayer,true];
	[Occupants, 10, 60] remoteExec ["A3A_fnc_addAggression",2];
	garrison setVariable [_city,[],true];
	[_city] call A3A_fnc_mrkUpdate;
Purpose: Converts city to rebel control when rebel support exceeds government support.
Actions:
Notification to rebel players
Sets sidesX variable for territory ownership
Increases occupant aggression by 10 for 60 seconds
Clears garrison (defenders flee)
Updates map marker via A3A_fnc_mrkUpdate
Network: remoteExec calls execute on teamPlayer side and 2 (server/owner).
Military Administration Cleanup:

Sqf

Apply
private _closestAdminMarker = [milAdministrationsX, _city] call BIS_fnc_nearestPosition;
if ((getMarkerPos _closestAdminMarker) distance2D (getMarkerPos _city) < 800) then {
	private _milAdministration = [A3A_milAdministrations, _closestAdminMarker] call BIS_fnc_nearestPosition;
	[_milAdministration, "SILENT"] call SCRT_fnc_location_removeMilAdmin;
};
Purpose: Removes nearby military administrations when city falls.
Logic: If military admin is within 800m, remove it silently.
Function Call: SCRT_fnc_location_removeMilAdmin (Santos's addon functions).
Opposing Territory Change:

Sqf

Apply
if (_supportGov > _supportReb && {sidesX getVariable [_city,sideUnknown] == teamPlayer}) then {
	["TaskFailed", ["", format [localize "STR_notifiers_city_joined",_city,FactionGet(occ,"name")]]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
	sidesX setVariable [_city,Occupants,true];
	[Occupants, -10, 45] remoteExec ["A3A_fnc_addAggression",2];
	// ... similar cleanup
Purpose: Cities can revert to enemy control if government support overcomes rebel support.
Aggression: Decreases occupant aggression (stabilizes territory).
2.4 Win/Loss Condition Checks (Lines 134-140)
Sqf

Apply
call A3A_fnc_checkWinCondition;
if (lossCondition isNotEqualTo 1) then {
	call A3A_fnc_checkLossCondition;
};
Purpose: Checks if game conditions are met.
Implementation:
A3A_fnc_checkWinCondition: Checks for rebel victory
A3A_fnc_checkLossCondition: Checks for rebel defeat (if loss condition enabled)
lossCondition: Global variable, 1 = loss conditions disabled.
2.5 Resource Node Processing (Lines 142-149)
Sqf

Apply
{
	if (sidesX getVariable [_x,sideUnknown] == teamPlayer and {!(_x in destroyedSites)}) then
	{
		_resAdd = _resAdd + (300 * _resBoost);
	};
} forEach resourcesX;
Purpose: Each owned resource node (oil, etc.) provides 300 resources * factory multiplier.
variables:
resourcesX: Array of resource marker names
_resBoost: Factory multiplier (1.25 per factory)
2.6 Salary and Final Calculation (Lines 151-158)
Sqf

Apply
_resAdd = [_resAdd] call SCRT_fnc_common_rebelSalary;
_hrAdd = ceil _hrAdd;
_resAdd = ceil _resAdd;
server setVariable ["hr", _hrAdd + (server getVariable "hr"), true];
server setVariable ["resourcesFIA", _resAdd + (server getVariable "resourcesFIA"), true];
Purpose: Applies salary costs and updates global variables.
Implementation:
SCRT_fnc_common_rebelSalary: Deducts wages from income
Uses ceil to round up (always give some resources)
server namespace stores global faction resources
true parameter broadcasts to all clients
Global Variables Modified:
server getVariable "hr": Human resources (recruitment capacity)
server getVariable "resourcesFIA": Money/resources
2.7 Bomb Run Management (Lines 160-168)
Sqf

Apply
private _rebAirportsQuantity = {sidesX getVariable [_x,sideUnknown] == teamPlayer} count airportsX;
bombRuns = bombRuns + 0.25 * _rebAirportsQuantity;
publicVariable "bombRuns";

if (bombRuns > (_rebAirportsQuantity * 2)) then {
	bombRuns = _rebAirportsQuantity * 2;
};
Purpose: Slowly accumulates bomb run capabilities from owned airports.
Math: Each airport adds 0.25 bomb runs per 10 minutes (1.5 per hour).
Cap: Maximum 2 bomb runs per airport (prevents stockpiling).
Synchronization: publicVariable broadcasts to all clients.
2.8 Support Points (Lines 170-178)
Sqf

Apply
if(tierWar > 2) then {
    supportPoints = supportPoints + 1;
};

if(supportPoints > maxSupportPoints) then {
    supportPoints = maxSupportPoints;
};

publicVariable "supportPoints";
Purpose: Awards support points for requesting AI supports.
Conditions:
Only when war tier > 2 (mid-game)
Caps at maxSupportPoints (global variable)
Synchronization: publicVariable for client access.
2.9 Starter Equipment Distribution (Lines 180-193)
Sqf

Apply
private _equipMul = A3A_balancePlayerScale / 30;
{
	if (_x isEqualType "") then { continue };
	_x params ["_class", "_initCount"];
	private _count = _initCount * _equipMul;
	_count = if (_count % 1 > random 1) then { ceil _count } else { floor _count };
	private _arsenalTab = _class call jn_fnc_arsenal_itemType;
	[_arsenalTab, _class, _count] call jn_fnc_arsenal_addItem;
} forEach (A3A_faction_reb get "initialRebelEquipment");
Purpose: Distributes starter weapons based on difficulty and player count.
Math:
_equipMul: Player scale divided by 30 (0.1 per 3 players)
Random rounding: 0.5+ gets ceil, else floor (ensures not always 0)
Arsenal Integration: Uses jn_fnc_arsenal_addItem to add to faction arsenal.
Global Variables:
A3A_balancePlayerScale: Difficulty multiplier
A3A_faction_reb: Faction data (rebel)
2.10 Player Notification (Lines 195-200)
Sqf

Apply
private _textX = format [localize "STR_comms_mp_taxes_income", _hrAdd, _resAdd, A3A_faction_civ get "currencySymbol"];
private _textArsenal = [] call A3A_fnc_arsenalManage;
if (_textArsenal != "") then {_textX = format [localize "STR_comms_mp_arsenal_updated", _textX, _textArsenal]};
[petros, "taxRep", _textX] remoteExec ["A3A_fnc_commsMP", [teamPlayer, civilian]];
Purpose: Notifies players of income and arsenal changes.
Implementation:
A3A_fnc_arsenalManage: Returns changes to arsenal (locked/unlocked items)
Combines tax report with arsenal updates
remoteExec to all rebel and civilian players (not enemies)
petros: The HQ unit that delivers messages
2.11 Additional System Updates (Lines 202-215)
Sqf

Apply
[] call A3A_fnc_generateRebelGear;
[] call A3A_fnc_FIAradio;
[] call A3A_fnc_cleanConvoyMarker;
Purpose: Updates various systems.
Functions:
A3A_fnc_generateRebelGear: Refreshes AI rebel loadouts
A3A_fnc_FIAradio: Updates radio tower status
A3A_fnc_cleanConvoyMarker: Removes orphaned convoy markers
Player Promotion and Boss Assignment:

Sqf

Apply
[] spawn A3A_fnc_promotePlayer;
[] call A3A_fnc_assignBossIfNone;
Purpose: Ensures there's always a boss player.
Implementation:
spawn: Runs asynchronously (promotions can take time)
assignBossIfNone: Checks if boss exists, assigns one if not
Building Timeouts:

Sqf

Apply
call A3A_fnc_processBuildingTimeouts;
Purpose: Cleans up unconstructed builder objects that timed out.
2.12 HQ Information Decay (Lines 217-222)
Sqf

Apply
if (A3A_curHQInfoOcc < 1) then { A3A_curHQInfoOcc = 0 max (A3A_curHQInfoOcc - 0.01) };
if (A3A_curHQInfoInv < 1) then { A3A_curHQInfoInv = 0 max (A3A_curHQInfoInv - 0.01) };
A3A_oldHQInfoOcc = A3A_oldHQInfoOcc select { _x set [2, _x#2 - 0.1]; _x#2 > 0 };
A3A_oldHQInfoInv = A3A_oldHQInfoInv select { _x set [2, _x#2 - 0.1]; _x#2 > 0 };
Purpose: Enemy HQ knowledge decays over time (1% per tick, 0.1 per old HQ).
Implementation:
A3A_curHQInfoOcc: Current occupant HQ knowledge (0-1)
A3A_oldHQInfoInv: Array of old invader HQs: [[x,y,knowledge], ...]
select: Filters out knowledge < 0 (deletes old entries)
2.13 Mission Generation (Lines 224-230)
Sqf

Apply
private _missionChance = 5 * A3A_activePlayerCount;
if ((!bigAttackInProgress) and (random 100 < _missionChance)) then {[] spawn A3A_fnc_missionRequest};
[] spawn A3A_fnc_reinforcementsAI;
Purpose: Randomly generates missions and AI reinforcements.
Math: Base 5% chance per player (e.g., 10 players = 50% chance).
Conditions: No large attack in progress.
Functions:
A3A_fnc_missionRequest: Generates side missions (assassination, rescue, etc.)
A3A_fnc_reinforcementsAI: Spawns AI reinforcements for battles
2.14 Static Weapon Reset (Lines 232-240)
Sqf

Apply
{
	_veh = _x;
	if ((_veh isKindOf "StaticWeapon") and {{isPlayer _x} count crew _veh == 0 and {alive _veh}}) then {
		_veh setDamage 0;
		[_veh,1] remoteExec ["setVehicleAmmo",_veh];
	};
} forEach vehicles;
Purpose: Automatically repairs and re-arms static weapons when not crewed by players.
Implementation:
Iterates all vehicles in mission
Checks for static weapons with no player crew
Repairs to full health, refills ammo
remoteExec runs on the vehicle object (network efficient)
2.15 Antenna Repair Mission (Lines 242-260)
Sqf

Apply
_numWreckedAntennas = count antennasDead;
_shouldSpawnRepairThisTick = round(random 100) < 15;
if (_numWreckedAntennas > 0 && {_shouldSpawnRepairThisTick && {!("REP" in A3A_activeTasks)}}) then {
	_potentials = [];
	{
		if (!isNil "_x" && {!isNull _x}) then {
			_markerX = [markersX, _x] call BIS_fnc_nearestPosition;
			if (sidesX getVariable [_markerX,sideUnknown] == Occupants and {spawner getVariable _markerX == 2}) exitWith {
				_potentials pushBack [_markerX,_x];
			};
		};
	} forEach antennasDead;
	if (count _potentials > 0) then {
		_potential = selectRandom _potentials;
		[[_potential select 0,_potential select 1],"A3A_fnc_REP_Antenna"] call A3A_fnc_scheduler;
	};
Purpose: Spawns antenna repair missions.
Implementation:
15% chance per tick when wrecked antennas exist
Only if no "REP" task active
Filters to antennas in enemy territory (Occupants) with no active spawner
A3A_fnc_scheduler: Queues the mission for execution
Automatic Site Rebuilding (Lines 262-273):

Sqf

Apply
_changingX = false;
{
	_chance = 5;
	if (_x in resourcesX and {sidesX getVariable [_x,sideUnknown] == Invaders}) then {
		_chance = 20
	};
	if (random 100 < _chance) then {
		_changingX = true;
		destroyedSites = destroyedSites - [_x];
		// ... notification and cleanup
	};
} forEach ((destroyedSites - citiesX) select {sidesX getVariable [_x,sideUnknown] != teamPlayer});
Purpose: Rebuilds destroyed sites (except cities) over time.
Logic:
Base 5% chance per tick
20% chance for resource nodes under invader control
Removes from destroyedSites array
Only rebuilds non-city sites not owned by rebels
2.16 Rivals Discovery (Lines 278-293)
Sqf

Apply
if (areRivalsEnabled && tierWar > 3 && !areRivalsDiscovered && !isRivalsDiscoveryQuestAssigned) then {
	Info_1("Rivals roll: %1", _rivalsTaskChance);
	if (random 100 < _rivalsTaskChance) then {
		Info("Assigning Rivals Discovery Task...");
		[] call SCRT_fnc_rivals_prepareQuest;
	} else {
		_rivalsTaskChance = [
			_rivalsTaskChance + 5,
			_rivalsTaskChance + 10
		] select (sunOrMoon < 1);
	};
};
Purpose: Gradually increases chance of rivals discovery quest.
Conditions:
Rivals enabled globally
War tier > 3 (late game)
Rivals not yet discovered
No discovery quest assigned
Mechanics:
Base chance stored in _rivalsTaskChance (starts at 5)
Increases by 5% normally, 10% at night (higher chance after dark)
Calls SCRT_fnc_rivals_prepareQuest to spawn the mission
2.17 Arms Dealer Quest (Lines 295-304)
Sqf

Apply
if (tierWar > 2 && !isTraderQuestCompleted && !isTraderQuestAssigned) then {
	Info_1("Arms Dealer roll: %1", _traderTaskChance);
	if (random 100 < _traderTaskChance) then {
		Info("Assigning Arms Dealer Task...");
		[] remoteExec ["SCRT_fnc_trader_prepareTraderQuest", 2];
	} else {
		_traderTaskChance = _traderTaskChance + 2;
	};
};
Purpose: Spawns arms dealer quest for advanced vehicle unlocking.
Conditions: War tier > 2, not completed or assigned.
Math: Base 5%, increases by 2% each failed roll.
2.18 Rivals Progress (Lines 306-310)
Sqf

Apply
if (areRivalsDiscovered && {!areRivalsDefeated}) then{
	[random [5,7,10]] call SCRT_fnc_rivals_addProgressToRivalsLocationReveal;
};
Purpose: Adds progress to revealing rival locations after discovery.
Implementation: Random weight [5,7,10] for location reveal progress.
2.19 Vehicle Unlocking (Lines 312-344)
Sqf

Apply
if (isTraderQuestCompleted) then {
	private _vehicleTypesUnlocked = unlockedVehicleTypes;
	// ... initialization and null check
	{
		private _condition = compile (_x#0);
		private _alreadyUnlocked = ((_x#1) in _vehicleTypesUnlocked);
		if (_alreadyUnlocked) then {continue};
		
		if (call _condition) then {
			private _text = format["%1 is now unlocked in the Arms Dealer.", (_x#1)];
			_vehicleTypesUnlocked pushBack (_x#1);
			_vehicleTypesUnlockedNotify pushBack (_x#1);
			Info(_text);
		};
	} forEach _conditions;

	if (_vehicleTypesUnlockedNotify isEqualTo []) exitWith {false};

	private _unlockedMessages = "The following vehicles have been unlocked at the Arms Dealer.<br/>";
	{
		private _vehicleType = _x;
		_unlockedMessages = _unlockedMessages + "<br/>" + _vehicleType;
	} forEach _vehicleTypesUnlocked;

	[localize "STR_marker_arms_dealer", _unlockedMessages] remoteExec ["A3A_fnc_customHint", 0, false];
	unlockedVehicleTypes = _vehicleTypesUnlocked;
	publicVariable "unlockedVehicleTypes";
};
Purpose: Unlocks trader vehicles when conditions are met.
Logic:
Checks if arms dealer quest is completed
Loads unlockedVehicleTypes array (persisted vehicles)
Compiles and evaluates conditions from mod config
Adds newly unlocked vehicles to array
Broadcasts notification to all players
Updates global variable and publicVariable
Where it leads:

Direct Calls:

A3A_fnc_getSideRadioTowerInfluence: Checks which side controls radio tower
A3A_fnc_citySupportChange: Modifies city support values (client/server sync)
A3A_fnc_mrkUpdate: Updates map marker visuals
SCRT_fnc_location_removeMilAdmin: Removes military administrations (Santos addon)
A3A_fnc_checkWinCondition: Checks rebel victory conditions
A3A_fnc_checkLossCondition: Checks rebel defeat conditions
SCRT_fnc_common_rebelSalary: Calculates salary costs
jn_fnc_arsenal_addItem: Adds items to faction arsenal (Jey's Arsenal)
A3A_fnc_arsenalManage: Manages arsenal state
A3A_fnc_commsMP: Sends messages to players
A3A_fnc_generateRebelGear: Refreshes AI gear
A3A_fnc_FIAradio: Updates radio tower status
A3A_fnc_cleanConvoyMarker: Cleans convoy markers
A3A_fnc_promotePlayer: Promotes players based on score
A3A_fnc_assignBossIfNone: Assigns faction boss
A3A_fnc_processBuildingTimeouts: Cleans building timeouts
A3A_fnc_missionRequest: Generates side missions
A3A_fnc_reinforcementsAI: Spawns AI reinforcements
A3A_fnc_REP_Antenna: Spawns antenna repair mission
SCRT_fnc_rivals_prepareQuest: Prepares rivals discovery quest
SCRT_fnc_trader_prepareTraderQuest: Prepares arms dealer quest
SCRT_fnc_rivals_addProgressToRivalsLocationReveal: Adds rivals progress
A3A_fnc_customHint: Shows custom notifications
Dependent Functions (functions that call this):

A3A_fnc_scheduler: Calls this function periodically
A3A_fnc_resourceCheckSkipTime: Skips time in this function
Global Variables Modified:

server getVariable "hr": Human resources
server getVariable "resourcesFIA": Money/resources
bombRuns: Bomb run count
supportPoints: Support points
unlockedVehicleTypes: Arms dealer vehicle unlocks
destroyedSites: Array of destroyed locations
sidesX namespace: Territory ownership
garrison namespace: City garrisons
A3A_curHQInfoOcc/Inv: HQ knowledge levels
A3A_oldHQInfoOcc/Inv: Old HQ knowledge arrays
Synchronization/Network:

Uses remoteExec for client-side notifications
publicVariable for global state updates
server namespace for server-authoritative data
spawn for asynchronous operations
Runs only on server, no client replication needed
Technical Details:

Performance: 10-minute timer prevents server overload
Memory: Reuses variables outside loop
Global State: Critical for mission persistence
Mod Integration: Reads from A3U config for trader vehicles
Branching Logic: Multiple conditionals for territory changes
Math: Careful use of percentages and multipliers
Function Name: fn_setupMonitor.sqf
What it does: Monitors server setup state, manages automatic save loading, finds the admin player to start the game, and coordinates the game initialization process. It's the first function that runs on server startup to handle game loading/saving and admin interface.

When/Why it's called: Called during server initialization before A3A_saveData is set. Runs in a loop until game is started, then terminates. Part of the mission's pre-game setup phase.

How it does that:

1. Initial Setup and Patch Collection (Lines 1-23)
Sqf

Apply
Info("Setup monitor started");
private _loadedPatches = [];
private _factions = "true" configClasses (configFile/"A3A"/"Templates");
private _addonVics = "true" configClasses (configFile/"A3A"/"AddonVics");
{
    {
        if (isClass (configFile/"CfgPatches"/_x)) then { _loadedPatches pushBackUnique _x };
    } forEach getArray (_x/"requiredAddons");
} forEach (_factions + _addonVics);
Purpose: Collects all mod dependencies to validate saves later.
Implementation:
configFile/"A3A"/"Templates": Lists all faction templates
configFile/"A3A"/"AddonVics": Lists addon vehicle packs
Iterates requiredAddons array for each
pushBackUnique: Prevents duplicates
Technical Detail: Uses config scanning to discover mods without requiring active missions.
2. DLC Collection (Lines 25-28)
Sqf

Apply
private _loadedDLC = getLoadedModsInfo select { (_x#2) and !(_x#1 in ["A3","curator","argo","tacops"]) };
_loadedDLC append (getLoadedModsInfo select { tolower (_x#1) in ["ef", "gm", "rf", "spe", "vn", "ws", "csla"] });
Purpose: Collects loaded DLCs, excluding official Arma 3 DLCs.
Implementation:
getLoadedModsInfo: Returns array of [modName, modPath, isOfficial, ...]
Filters for DLCs (isOfficial=true) excluding certain keys
Hardcodes CDLCs because Arma doesn't mark them as official
tolower: Case-insensitive matching
3. Automatic Save Loading (Lines 30-60)
Sqf

Apply
private _autoLoadTime = "autoLoadLastGame" call BIS_fnc_getParamValue;
private _autoLoadData = nil;
if (_autoLoadTime >= 0) then
{
    Info("Searching for suitable saves for automatic loading");
    private _validFactions = _factions select { getArray (_x/"requiredAddons") findIf { !(_x in _loadedPatches) } == -1 } apply { configName _x };
    private _validAddons = _addonVics select { getArray (_x/"requiredAddons") findIf { !(_x in _loadedPatches) } == -1 } apply { configName _x };
    private _validDLC = _loadedDLC apply {_x#1};
Purpose: Filters save data to only include compatible saves for current modset.
Parameters:
autoLoadLastGame: Mission parameter (in minutes, -1 to disable)
_validFactions: Only factions with all required patches loaded
_validAddons: Only addon vehicle packs with all required patches
_validDLC: List of loaded DLC names
Validation Function:

Sqf

Apply
private _fnc_isValidSave = {
    if (_this get "map" != worldName) exitWith {false};
    if (!isNil {_this get "ended"}) exitWith {false};
    if (isNil {_this get "factions"}) exitWith {false};
    if (_this get "factions" findIf { !(_x in _validFactions) } != -1) exitWith {false};
    if (_this get "addonVics" findIf { !(_x in _validAddons) } != -1) exitWith {false};
    if (_this get "DLC" findIf { !(_x in _validDLC) } != -1) exitWith {false};
    true;
};
Purpose: Validates save data against current modset.
Checks:
Same map/world
Save not marked as ended/finished
All factions in save are available
All addon vehicle packs in save are available
All DLC in save are loaded
Returns: Boolean indicating compatibility.
Save Selection:

Sqf

Apply
private _saveData = call A3A_fnc_collectSaveData;
private _index = _saveData findIf { _x call _fnc_isValidSave };
if (_index == -1) exitWith {
    Info("No usable saves found for automatic loading");
    _autoLoadTime = -1;
};
_autoLoadData = _saveData select _index;
_autoLoadData set ["startType", "load"];
Info_1("Save ID %1 selected for automatic loading", _autoLoadData get "gameID");
_autoLoadTime = time + _autoLoadTime;
Purpose: Finds and selects a compatible save.
Implementation:
A3A_fnc_collectSaveData: Loads all saves from disk
findIf: Finds first matching save
startType: Marks as "load" vs "new"
gameID: Unique identifier for save
Converts autoLoadTime to absolute time
4. Admin Detection Loop (Lines 62-108)
Sqf

Apply
private _fnc_validAdmin = {
    admin owner _this == 2 or
    {_this isEqualTo player and hasInterface}
};
Purpose: Determines if a player is an admin.
Implementation:
admin owner _this == 2: Dedicated server admin
_this isEqualTo player: Local host (localhost) returns owner 0
hasInterface: Ensures it's a player
Startup State Initialization:

Sqf

Apply
private _waitState = ["adminwait", "autostartwait"] select (_autoLoadTime != -1);
A3A_startupState = _waitState; publicVariable "A3A_startupState";
Purpose: Sets initial state for clients.
States:
adminwait: Waiting for admin (manual start)
autostartwait: Auto-load timer running
Synchronization: publicVariable broadcasts to all clients.
Main Loop:

Sqf

Apply
while {isNil "A3A_saveData"} do {
    sleep 1;
Purpose: Runs until game is started.
Exit Condition: A3A_saveData is set (by A3A_fnc_startGame).
Auto-Load Timer Check:

Sqf

Apply
if (isNull A3A_setupPlayer and _autoLoadTime != -1 and time > _autoLoadTime) then {
    [_autoLoadData] call A3A_fnc_startGame;
    _autoLoadTime = -1;
    continue;
};
Purpose: Triggers auto-load when timer expires.
Conditions:
No player in setup (prevents override)
Timer is enabled and expired
Calls A3A_fnc_startGame with save data
Admin Status Check:

Sqf

Apply
if (!isNull A3A_setupPlayer) then {
    if (A3A_setupPlayer call _fnc_validAdmin) then { continue };

    Info_1("Player %1 is no longer admin, disabling their setup dialog", name A3A_setupPlayer);
    A3A_startupState = _waitState; publicVariable "A3A_startupState";
    ["serverClose"] remoteExec ["A3A_fnc_setupDialog", A3A_setupPlayer];
    A3A_setupPlayer = objNull;
};
Purpose: Monitors admin status changes.
Actions if admin lost:
Log message
Reset startup state
Close setup dialog on client
Clear admin reference
Finding New Admin:

Sqf

Apply
private _players = allPlayers - entities "HeadlessClient_F";
private _adminIndex = _players findIf { _x call _fnc_validAdmin };
if (_adminIndex == -1) then { continue };

A3A_setupPlayer = _players select _adminIndex;
Info_1("Player %1 is now admin, sending them the save data", name A3A_setupPlayer);
A3A_startupState = "adminsetup"; publicVariable "A3A_startupState";
Purpose: Finds and assigns admin for setup.
Implementation:
Excludes headless clients (AI controllers)
Uses findIf for first valid admin
Updates A3A_setupPlayer global
Notifies all clients of new state
Sending Save Data to Admin:

Sqf

Apply
private _saveData = call A3A_fnc_collectSaveData;
DebugArray("Save data found:", _saveData);
private _platform = productVersion select 6;
["sendData", [_saveData, _loadedPatches, _loadedDLC, _platform]] remoteExec ["A3A_fnc_setupDialog", A3A_setupPlayer];
Purpose: Provides admin with save data and mod information.
Implementation:
Recollects save data (deletions may have occurred)
productVersion select 6: OS platform (0=Windows, 1=Linux, 2=Mac)
Remote executes A3A_fnc_setupDialog with all data
Network: Sends only to admin's client.
5. Termination (Line 108)
Sqf

Apply
Info("Setup monitor terminated");
Purpose: Logs when setup completes (game started).
Condition: Exits loop when A3A_saveData is set.
Where it leads:

Direct Calls:
A3A_fnc_collectSaveData: Loads all save files
A3A_fnc_startGame: Starts the game with save data
A3A_fnc_setupDialog: Sends data to admin client
Dependent Functions (functions that call this):
A3A_fnc_initServer: Calls this during server initialization
Global Variables Modified:
A3A_startupState: Current setup state (public)
A3A_setupPlayer: Current admin in setup
A3A_saveData: Save data to load (set by startGame)
A3A_backgroundInitDone: Indicates background init completion (not set here)
Synchronization/Network:
publicVariable: Broadcasts A3A_startupState to all clients
remoteExec: Sends dialog data to admin only
Runs only on server
Technical Details:
Config Scanning: Reads mod dependency tree
Save Validation: Mod compatibility checking
Admin Detection: Handles different admin types (dedicated vs localhost)
State Management: Tracks setup progression
Function Name: fn_startGame.sqf
What it does: Initiates the game loading process by setting global save data, which triggers the background initialization. It validates the starting player (admin) and prepares the mission for the actual loading phase.

When/Why it's called: Called by 
fn_setupMonitor.sqf
 when an admin confirms start or auto-load timer expires. This is the bridge between setup phase and actual game initialization.

How it does that:

1. Security Validation (Lines 1-5)
Sqf

Apply
if (isRemoteExecuted and remoteExecutedOwner != owner A3A_setupPlayer) exitWith {
    Error_1("Wrong player (%1) attempted to start game, ignoring", remoteExecutedOwner);
};
Purpose: Prevents non-admin from starting the game.
Implementation:
isRemoteExecuted: Checks if called via remoteExec
remoteExecutedOwner: Network ID of calling client
owner A3A_setupPlayer: Owner ID of current admin
Mismatch = unauthorized start attempt
2. Parameter Processing (Lines 7-8)
Sqf

Apply
params ["_saveData"];
Info_1("startGame called with data %1", _saveData);
Purpose: Receives save data from setup monitor.
Parameter: _saveData (array) from A3A_fnc_collectSaveData
3. Sanity Check Placeholder (Line 10)
Sqf

Apply
// savedata sanity checks could go here
Purpose: Intended for save data validation (empty in current version).
4. Setting Global Save Data (Lines 12-14)
Sqf

Apply
A3A_saveData = _saveData;
Purpose: Triggers the initialization sequence.
Implementation:
Sets global variable that breaks setupMonitor loop
Used by other functions to detect game start
Contains complete save state (cities, resources, etc.)
5. Background Init Check (Lines 16-20)
Sqf

Apply
if (isNil "A3A_backgroundInitDone") then {
    Info("Waiting for background init to complete");
    A3A_startupState = "background"; publicVariable "A3A_startupState";
};
Purpose: Updates state if background init hasn't finished.
Logic:
A3A_backgroundInitDone: Set by A3A_fnc_initServer after async init
If nil, mission is still initializing background systems
Updates startup state for client awareness
Synchronization: publicVariable broadcasts new state.
Where it leads:

Direct Calls: None in this function (sets triggers)
Dependent Functions (functions that call this):
A3A_fnc_setupMonitor: Calls to start game
Global Variables Modified:
A3A_saveData: Main save data (triggers initialization)
A3A_startupState: Set to "background" if needed
Synchronization/Network:
publicVariable: Updates state for clients
Called remotely from admin client
Server-authoritative (validates caller)
Technical Details:
Security: Owner validation prevents exploits
State Machine: Sets A3A_saveData to progress mission states
Async Handling: Waits for background init if necessary
Function Name: fn_tags.sqf
What it does: Displays player name, rank, and primary weapon info on the screen when aiming at friendly units. Provides real-time tactical information for team coordination.

When/Why it's called: Client-side persistent loop that runs only for players (not headless clients). Executes continuously after mission start.

How it does that:

1. Client-Side Validation (Lines 1-2)
Sqf

Apply
if (isDedicated) exitWith {};
Purpose: Prevents running on server (no screen to render to).
Implementation: Immediate exit if dedicated server.
2. Configuration Constants (Lines 5-6)
Sqf

Apply
#define _refresh 0.34
#define _distance 300
Purpose: Define update rate and range.
Values:
_refresh: 0.34 seconds between updates (3 frames @ 30fps)
_distance: 300 meters maximum range
3. Layer Setup (Line 8)
Sqf

Apply
private _layer = ["A3A_tags"] call BIS_fnc_rscLayer;
Purpose: Creates dedicated UI layer for tag display.
Implementation: Uses BIS_fnc_rscLayer to manage display hierarchy.
4. Main Loop (Lines 10-37)
Sqf

Apply
while{ true } do {
   // PLAYER NAME CHECK AND DISPLAY
	_target = cursorTarget;
	if (_target isKindOf "CAManBase" && player == vehicle player) then{
			if((side _target == playerSide) && ((player distance _target) < _distance))then {
Purpose: Detects valid target for tag display.
Checks:
cursorTarget: What player is aiming at
_target isKindOf "CAManBase": Must be infantry
player == vehicle player: Player not in vehicle
side _target == playerSide: Friendly unit only
distance < 300m: Within range
Weapon Information Gathering:

Sqf

Apply
_weaponsplayer = weapons _target;
_name = name _target;
_nameString = "<t size='0.5' shadow='2' color='#7FFF00'>" + format['%1',_target getVariable ['unitname', name _target]] + "</t>";
_rank = [_target,"displayNameShort"] call BIS_fnc_rankParams;
if (count _weaponsPlayer > 0) then {
	_weaponsplayer =  _weaponsplayer select 0;
	_weaponsplayername = getText (configFile >> "CfgWeapons" >> _weaponsplayer >> "displayname");
	_weaponspic = getText (configFile >> "CfgWeapons" >> _weaponsplayer >> "picture");
Purpose: Extracts target information.
Implementation:
weapons _target: Array of primary weapon classnames
unitname: Custom variable (if set), else use name
BIS_fnc_rankParams: Gets rank abbreviation (PVT, SGT, etc.)
configFile >> "CfgWeapons": Gets weapon display name and picture
Edge Case: If no weapons, shows only rank/name.
HTML Text Construction:

Sqf

Apply
_nameString = format ["<t size='0.5' color='#f0e68c'>%4. </t><t size='0.5' color='#f0e68c'>%1</t><br/><t size='0.5' color='#f0e68c'>%2</t><br/><img size='0.8' image='%3'/><br/>",_name, _weaponsplayername,_weaponspic,_rank];
} else {
	_nameString = format ["<t size='0.5' color='#f0e68c'>%2. </t><t size='0.5' color='#f0e68c'>%1</t>",_name,_rank];
};
Purpose: Creates formatted text for display.
Format:
With weapon: Rank. Name<br/>Weapon Name<br/>Weapon Picture
Without weapon: Rank. Name
Uses HTML tags (<t>, <br/>, <img>)
Color: #f0e68c (light goldenrod)
Display Render:

Sqf

Apply
[_nameString,0.5,0.9,_refresh,0,0,_layer] spawn bis_fnc_dynamicText;
Purpose: Renders the text on screen.
Parameters:
_nameString: HTML text
0.5: X position (center)
0.9: Y position (near bottom)
_refresh: Duration (0.34s)
0,0: No fade in/out
_layer: Dedicated UI layer
Implementation: spawn prevents blocking, bis_fnc_dynamicText handles rendering.
Loop Delay:

Sqf

Apply
sleep _refresh;
Purpose: Prevents excessive CPU usage.
Timing: Matches display duration (0.34s) for smooth updates.
Where it leads:

Direct Calls:
BIS_fnc_rscLayer: Creates UI layer
BIS_fnc_rankParams: Gets rank display name
bis_fnc_dynamicText: Renders text (BIS function)
Dependent Functions (functions that call this):
A3A_fnc_initClient: Starts tag system on client
Global Variables Modified:
None (read-only display)
Synchronization/Network:
None (client-only, local display)
Runs on every player's machine independently
Technical Details:
Performance: Low CPU usage (30 updates/sec max)
UI: Uses BIS text rendering system
HTML: Supports basic HTML for formatting
Caching: No caching (reads data each frame)
Scope: Only affects local player's view
Function Dependencies Summary
Resource Check Dependencies
Calls:

A3A_fnc_getSideRadioTowerInfluence: Determines territory control
A3A_fnc_citySupportChange: Updates city support (networked)
A3A_fnc_mrkUpdate: Updates map markers
SCRT_fnc_location_removeMilAdmin: Removes military administrations
A3A_fnc_checkWinCondition: Victory check
A3A_fnc_checkLossCondition: Defeat check
SCRT_fnc_common_rebelSalary: Salary calculation
jn_fnc_arsenal_addItem: Arsenal management (Jey's)
A3A_fnc_arsenalManage: Arsenal updates
A3A_fnc_commsMP: Player notifications
A3A_fnc_generateRebelGear: AI gear generation
A3A_fnc_FIAradio: Radio tower updates
A3A_fnc_cleanConvoyMarker: Marker cleanup
A3A_fnc_promotePlayer: Player ranking
A3A_fnc_assignBossIfNone: Boss assignment
A3A_fnc_processBuildingTimeouts: Building cleanup
A3A_fnc_missionRequest: Mission generation
A3A_fnc_reinforcementsAI: AI reinforcements
A3A_fnc_REP_Antenna: Antenna repair mission
SCRT_fnc_rivals_prepareQuest: Rivals quest
SCRT_fnc_trader_prepareTraderQuest: Arms dealer quest
SCRT_fnc_rivals_addProgressToRivalsLocationReveal: Rivals progress
A3A_fnc_customHint: Custom notifications
Called by:

A3A_fnc_scheduler: Periodic execution
A3A_fnc_resourceCheckSkipTime: Time skipping
Setup Monitor Dependencies
Calls:

A3A_fnc_collectSaveData: Save loading
A3A_fnc_startGame: Game initiation
A3A_fnc_setupDialog: Admin UI
Called by:

A3A_fnc_initServer: Server initialization
Start Game Dependencies
Calls: None (sets triggers)

Called by:

A3A_fnc_setupMonitor: Game start confirmation
Tags Dependencies
Calls:

BIS_fnc_rscLayer: UI layer management
BIS_fnc_rankParams: Rank display
bis_fnc_dynamicText: Text rendering
Called by:

A3A_fnc_initClient: Client initialization
Global Variable Reference
Shared by All Functions
teamPlayer: Rebel side
Occupants: Government side
Invaders: Enemy faction
citiesX: Array of city markers
resourcesX: Array of resource node markers
airportsX: Array of airport markers
seaports: Array of seaport markers
factories: Array of factory markers
destroyedSites: Array of destroyed locations
sidesX: Location namespace for ownership
server: Server namespace for persistent data
A3A_activePlayerCount: Number of connected players
Resource Check Specific
A3A_balancePlayerScale: Difficulty multiplier
A3A_faction_reb: Rebel faction data
A3A_faction_civ: Civilian faction data
bombRuns: Bomb run count
supportPoints: Support points
maxSupportPoints: Support point cap
unlockedVehicleTypes: Arms dealer unlocks
A3A_curHQInfoOcc/Occ: Current HQ knowledge
A3A_oldHQInfoOcc/Occ: Old HQ knowledge arrays
bigAttackInProgress: Attack state flag
A3A_activeTasks: Active mission IDs
antennasDead: Destroyed antenna objects
areRivalsEnabled: Rivals system flag
tierWar: War progression level (1-5)
areRivalsDiscovered: Rivals discovered flag
isRivalsDiscoveryQuestAssigned: Quest state
isTraderQuestCompleted: Arms dealer quest state
isTraderQuestAssigned: Quest state
Setup Monitor Specific
A3A_saveData: Main save data (trigger)
A3A_startupState: Setup state (adminwait, autostartwait, adminsetup, background)
A3A_setupPlayer: Current admin in setup
A3A_backgroundInitDone: Background init completion flag
lossCondition: Defeat condition setting
maxSupportPoints: As above
A3A_milAdministrations: Military administration objects
milAdministrationsX: Military admin markers
Tags Specific
player: Local player object
cursorTarget: Aiming target (local)
side _target: Target side (local calculation)