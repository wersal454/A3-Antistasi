# PatCom Ultra-Detailed Function Documentation

## Artillery Functions

### Function Name: fn_artilleryAdd.sqf
What it does:
• Registers a group as an active artillery battery in the PATCOM system
• Enables the group to participate in artillery fire missions called by the artillery fire mission system
• Sets up the necessary variables for artillery coordination and state management
How it does that:
• Extracts group parameter: `params ["_group"];`
• Marks the group as an artillery battery: `_group setVariable ["PATCOM_ArtilleryBattery", true, true];`
• Initializes artillery busy state to false: `_group setVariable ["PATCOM_ArtilleryBusy", false, true];`
Where it leads:
• Enables A3A_fnc_artilleryFireMission to select this group for fire missions
• Allows the artillery battery to be discovered by battery scanning logic in fire mission function
• Prepares group for artillery state management and coordination

### Function Name: fn_artilleryDangerClose.sqf
What it does:
• Checks if friendly AI units or friendly markers are within danger close proximity of an artillery target position
• Prevents accidental friendly fire by detecting when artillery strikes would endanger friendly forces
• Supports both unit-based proximity checks and strategic marker-based checks for occupied territories
How it does that:
• Extracts parameters for target position, radius, and side: `params ["_targetPos", "_radius", "_side"];`
• Defines macro for all strategic markers: `#define ALL_MARKERS (airportsX + milbases + outposts + factories + resourcesX + seaports)`
• Checks for friendly AI units within danger close radius: `(groups _side) + (groups civilian)) findIf { (alive leader _x) && ((leader _x distance2D _targetPos) < _radius) } isNotEqualTo -1`
• Checks for friendly strategic markers at target position: `ALL_MARKERS findIf { (sidesX getVariable[_x, sideUnknown] isEqualTo _side) && (_targetPos inArea _x) } isNotEqualTo -1`
• Returns true if danger close conditions are met, false otherwise: `true;` or `false;`
Where it leads:
• Forces A3A_fnc_artilleryFireMission to switch to safe munitions (smoke/flare) when danger close is detected
• Prevents HE artillery strikes that could harm friendly forces
• Triggers debug text display when danger close is detected in debug mode

### Function Name: fn_artilleryFireMission.sqf
What it does:
• Coordinates and executes artillery fire missions by selecting available batteries and managing the firing sequence
• Handles ammunition selection, range verification, danger close checks, and multi-round firing with realistic reload times
• Provides comprehensive artillery support for AI commanders calling in fire missions
How it does that:
• Extracts mission parameters: `params ["_targetPos", "_area", "_roundType", "_rounds", "_callerGroup"];`
• Determines caller side: `private _side = side _callerGroup;`
• Scans for available artillery batteries not currently busy: loops through `(groups _side) select {_x getVariable ["PATCOM_ArtilleryBattery", false]}` and checks artillery vehicles
• Validates artillery vehicle configuration: checks `getNumber(configfile/"CfgVehicles"/_class/"artilleryScanner")` equals 1
• Exits with debug message if no batteries available: `If (PATCOM_DEBUG) then { [leader _callerGroup, "NO SUPPORT AVAILABLE", 5, "Red"] call A3A_fnc_debugText3D; };`
• Selects random available battery: `private _selectedBattery = selectRandom _batteryArray;`
• Retrieves battery group and class information: `private _group = group (gunner _selectedBattery); private _batteryClass = (typeOf _selectedBattery);`
• Gets current day state for munition selection: `private _dayState = [] call A3A_fnc_getDayState;`
• Calculates reload time: `private _reloadTime = [_selectedBattery] call A3A_fnc_getReloadTime;`
• Sets battery to busy state: `_group setVariable ["PATCOM_ArtilleryBusy", true, true];`
• Checks for danger close conditions: `if ([_targetPos, _area, _side] call A3A_fnc_artilleryDangerClose)`
• Switches to safe munitions when danger close: converts HE to smoke, or flare at night/evening
• Retrieves faction artillery templates: `private _faction = Faction(_side);`
• Selects appropriate ammunition based on battery type: differentiates between artillery vehicles and mortars
• For artillery vehicles: uses `_faction get "magazines" get _batteryClass`
• For mortars: switches based on round type (HE/Smoke/Flare) using faction-specific magazine definitions
• Validates ammunition availability: exits if `_shellType == ""`
• Performs final range check: `if !(_targetPos inRangeOfArtillery [[_selectedBattery], _shellType])`
• Spawns firing sequence in separate thread: `[_group, _targetPos, _area, _selectedBattery, _shellType, _rounds, _reloadTime] spawn {`
• For each round: calculates random target position within area, fires artillery, displays debug text, waits for reload
• Uses `[_targetPos, (random 50), _area, 0, 1, -1, 0] call A3A_fnc_getSafePos` for spread calculation
• Fires single round: `_selectedBattery doArtilleryFire [_finalTargetPos, _shellType, 1];`
• Applies realistic reload timing: `sleep (_reloadTime + (2 + (random 4)));`
• Waits for artillery cooldown before freeing battery: `sleep PATCOM_ARTILLERY_DELAY; _group setVariable ["PATCOM_ArtilleryBusy", false, true];`
Where it leads:
• Calls A3A_fnc_artilleryDangerClose for proximity safety checks
• Calls A3A_fnc_getDayState for time-based munition selection
• Calls A3A_fnc_getReloadTime for realistic firing intervals
• Calls A3A_fnc_debugText3D for visual feedback in debug mode
• Calls A3A_fnc_getSafePos for artillery spread calculations
• Modifies PATCOM_ArtilleryBusy group variable to coordinate battery availability
• Integrates with faction system for munition templates and vehicle configurations

### Function Name: fn_getReloadTime.sqf
What it does:
• Calculates the reload time for artillery weapons by examining the weapon's configuration data
• Provides realistic firing intervals for artillery batteries based on their equipped weapons
• Supports complex weapon configurations with multiple muzzles and fire modes
How it does that:
• Extracts unit parameter: `params ["_unit"];`
• Gets the unit's vehicle: `private _vehicle = vehicle _unit;`
• Determines turret path: `private _turretPath = _vehicle unitTurret _unit;`
• Retrieves current weapon state: `private _state = weaponState [_vehicle, _turretPath, ""];`
• Extracts weapon components: `_state params ["_weapon", "_muzzle", "_fireMode"];`
• Navigates weapon config hierarchy: `private _config = configFile >> "CfgWeapons" >> _weapon;`
• Adjusts config path for muzzle-specific settings: `if (_muzzle != _weapon) then { _config = _config >> _muzzle; };`
• Adjusts config path for fire mode-specific settings: `if (_muzzle != _fireMode) then { _config = _config >> _fireMode; };`
• Retrieves reload time value: `getNumber (_config >> "reloadTime")`
Where it leads:
• Provides reload timing data to A3A_fnc_artilleryFireMission for realistic firing sequences
• Enables accurate simulation of artillery weapon characteristics

## Civilian Functions

### Function Name: fn_civilianFiredNearEH.sqf
What it does:
• Handles civilian panic response when gunfire is detected nearby
• Provides realistic civilian behavior by triggering fear animations and sounds
• Temporarily disrupts civilian routines and forces them to seek cover or flee
How it does that:
• Extracts parameters from event handler: `params ["_unit", "_type", "_index"];`
• Removes the event handler to prevent repeated triggers: `_unit removeEventHandler [_type, _index];`
• Triggers panic animation: `[_unit, "ApanPercMstpSnonWnonDnon_ApanPknlMstpSnonWnonDnon"] remoteExec ["switchMove"];`
• Spawns movement behavior in scheduled space: `[_unit] spawn {`
• Finds safe retreat position: `private _positionX = [getPosATL _unit, 100, 200, 0, 0, -1, 0] call A3A_fnc_getSafePos;`
• Commands unit to move to safe position: `_unit doMove _positionX;`
• Disables walking restrictions for faster movement: `_unit forceWalk false; _unit setSpeedMode "FULL";`
• Waits 60 seconds for movement completion: `sleep 60;`
• Resets animation and speed: `[_unit, ""] remoteExec ["switchMove"]; _unit setSpeedMode "LIMITED"; _unit forceWalk true;`
• Re-adds the event handler for future gunfire detection: `_unit addEventHandler["FiredNear", {...}];`
• Calculates 35% chance to play panic sound: `if (random 1 > 0.35) then {`
• Retrieves fear tracks from civilian audio hashmap: `private _tracks = A3A_Civilian_Amb_Tracks get "Fear";`
• Selects and plays random fear sound: `private _panicNoise = selectRandom _tracks; [_unit, _panicNoise # 0] remoteExec ["say3D"];`
Where it leads:
• Calls A3A_fnc_getSafePos for finding retreat positions
• Modifies civilian movement patterns and animations temporarily
• Integrates with A3A_Civilian_Amb_Tracks hashmap for audio assets
• Prepares unit for re-triggering of the same event handler after recovery

### Function Name: fn_civilianInitEH.sqf
What it does:
• Initializes comprehensive event handlers and behaviors for civilian units
• Sets up damage handling, death responses, and interaction capabilities
• Configures civilian AI characteristics and faction-specific attributes
How it does that:
• Extracts unit parameter: `params ["_unit"];`
• Disables AI targeting capabilities: `_unit setSkill 0; _unit disableAI "TARGET"; _unit disableAI "AUTOTARGET";`
• Sets identity using faction faces and no voice: `[_unit, createHashMapFromArray [["face", selectRandom (A3A_faction_civ get "faces")], ["speaker", "NoVoice"]]] call A3A_fnc_setIdentity;`
• Adds comprehensive damage handling event handler with player tracking: `_unit addEventHandler ["HandleDamage", {...}];`
• Checks for non-human civilian attribute: `private _civNotHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];`
• For non-human civilians, adds death handler and triggers init event: `["civInit", [_unit]] call EFUNC(Events,triggerEvent);`
• For human civilians, adds FiredNear event handler: `_unit addEventHandler["FiredNear", {...}];`
• Adds complex death event handler for reputation and mission tracking: `_unit addEventHandler ["Killed", {...}];`
• Tracks player involvement in civilian deaths: `if(!isNil "_injurer" && {isPlayer _injurer}) then {...}`
• Handles suicide detection and city support changes: `if (_victim == _killer) then {...}`
• Implements faction-specific reputation penalties: `switch (true) do { case (side group _killer == teamPlayer): {...} };`
• Triggers postmortem processing: `[_victim] spawn A3A_fnc_postmortem;`
• Broadcasts civilian initialization event: `["civInit", [_unit]] call EFUNC(Events,triggerEvent);`
Where it leads:
• Calls A3A_fnc_setIdentity for civilian appearance configuration
• Calls A3A_fnc_postmortem for death processing
• Calls A3A_fnc_addAggression for reputation system integration
• Calls A3A_fnc_citySupportChange for civilian support mechanics
• Calls A3A_fnc_addScorePlayer for player scoring system
• Integrates with Events system for mission triggers
• Modifies global variables like aggressionOccupants, aggressionInvaders, destroyedSites
• Affects player rating and score systems

### Function Name: fn_civilianPanic.sqf
What it does:
• Triggers immediate civilian panic response without relying on firedNear event handler
• Provides direct control over civilian fear behavior for scripted scenarios
• Replicates the core panic mechanics used in event handler responses
How it does that:
• Extracts unit parameter: `params ["_unit"];`
• Triggers panic animation: `[_unit, "ApanPercMstpSnonWnonDnon_ApanPknlMstpSnonWnonDnon"] remoteExec ["switchMove"];`
• Spawns movement behavior in scheduled space: `[_unit] spawn {`
• Finds safe retreat position: `private _positionX = [getPosATL _unit, 100, 200, 0, 0, -1, 0] call A3A_fnc_getSafePos;`
• Commands unit to move to safe position: `_unit doMove _positionX;`
• Disables walking restrictions: `_unit forceWalk false; _unit setSpeedMode "FULL";`
• Waits 60 seconds for movement: `sleep 60;`
• Resets animation and speed: `[_unit, ""] remoteExec ["switchMove"]; _unit setSpeedMode "LIMITED"; _unit forceWalk true;`
• Retrieves fear tracks from hashmap: `private _tracks = A3A_Civilian_Amb_Tracks get "Fear";`
• Validates track availability: `if (count _tracks > 0) then {`
• Selects and plays random fear sound: `private _panicNoise = selectRandom _tracks; [_unit, _panicNoise # 0] remoteExec ["say3D"];`
Where it leads:
• Calls A3A_fnc_getSafePos for retreat position calculation
• Integrates with A3A_Civilian_Amb_Tracks for audio assets
• Temporarily modifies civilian movement patterns and animations
• Provides foundation for scripted panic scenarios

### Function Name: fn_createAmbientCiv.sqf
What it does:
• Spawns comprehensive ambient civilian populations in city areas
• Creates realistic civilian activities including press, workers, special units, and ambient behaviors
• Manages civilian lifecycle with spawning, patrol assignment, and cleanup
How it does that:
• Validates server execution: `if (!isServer and hasInterface) exitWith {};`
• Checks for destroyed site exclusion: `if (_markerX in destroyedSites) exitWith {};`
• Retrieves faction attributes: `private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];`
• Checks non-human civilian setting: `private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];`
• Gets city ownership: `private _sideX = sidesX getVariable [_markerX,sideUnknown];`
• Retrieves faction configuration: `private _faction = Faction(_sideX);`
• Calculates civilian population based on city data: `private _numCiv = round (1.5 * sqrt (_cityData # 0) * (1 - tierWar / 20));`
• Caps civilian numbers: `if (_numCiv > maxCiviliansPerTown) then { _numCiv = maxCiviliansPerTown; };`
• Handles rebel faction special case with human civilians: `if (_faction isEqualTo A3A_faction_reb && {_civNonHuman}) exitWith {...}`
• For non-human civilians, adjusts spawn limits and side assignment: `switch _faction do { case A3A_faction_occ: {_groupSide = east;}; ... };`
• Handles press spawning with random chance: `if (random 100 < ((aggressionOccupants) + (aggressionInvaders)) && {_civNonHuman isEqualTo false}) then {...}`
• Spawns regular civilians in buildings with day/night activities: `for "_i" from 1 to _numCiv do {`
• Finds building positions for indoor spawning: `private _housePositions = [_building] call BIS_fnc_buildingPositions;`
• Creates civilian units with appropriate event handlers: `[_civUnit] spawn A3A_fnc_civilianInitEH;`
• Assigns dialog actions for interactive civilians: `[_civUnit] call A3A_fnc_dialogCivAction;`
• Adds time-based activities (lights, music): `if (_dayState == "EVENING" || {_dayState == "NIGHT"}) then { _light = [_building] call A3A_fnc_createRoomLight; };`
• Sets up patrol behaviors: `[_groupX] call A3A_fnc_patrolLoop;`
• Manages cleanup with spawn key monitoring: `waitUntil {sleep 1;(spawner getVariable _spawnKey == 2)};`
Where it leads:
• Calls A3A_fnc_civilianInitEH for unit initialization
• Calls A3A_fnc_dialogCivAction for interactive civilians
• Calls A3A_fnc_createRoomLight for evening/night lighting
• Calls A3A_fnc_createMusicSource for ambient audio
• Calls A3A_fnc_patrolLoop for civilian movement patterns
• Calls A3A_fnc_getSafePos for spawn position validation
• Modifies destroyedSites array when resource facilities are destroyed
• Integrates with global civilian population limits (globalCivilianMax)

### Function Name: fn_createAmbientCivTraffic.sqf
What it does:
• Generates realistic civilian vehicle traffic and parked vehicles in urban areas
• Creates dynamic traffic patterns with moving vehicles and static parking
• Manages vehicle lifecycle with spawning, behavior setup, and cleanup
How it does that:
• Validates server execution: `if (!isServer and hasInterface) exitWith{};`
• Checks faction attributes for traffic disabling: `private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];`
• Excludes non-human civilians from vehicle traffic: `private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];`
• Exits early for non-human or low-civ settings: `if (_lowCiv) exitWith {}; if (_civNonHuman) exitWith {};`
• Checks destroyed site exclusion: `if (_markerX in destroyedSites) exitWith {};`
• Retrieves city data and calculates traffic parameters: `private _numVeh = (_dataX#1);`
• Calculates parked and moving vehicle counts: `_numParked = _numCiv * (1/60) * civTraffic; _numTraffic = _numCiv * (1/300) * civTraffic;`
• Adjusts counts based on time of day: `if ((daytime < 8) or (daytime > 21)) then { _numParked = _numParked * 1.5; _numTraffic = _numTraffic / 4 ;};`
• Finds suitable roads for vehicle placement: `private _roads = nearestTerrainObjects [getMarkerPos _markerX, ["MAIN ROAD", "ROAD", "TRACK"], 250, false, true];`
• Filters roads to exclude bridges and junctions: `_roads = _roads select { !(getRoadInfo _x # 8) and (count roadsConnectedTo [_x, true] <= 2) and (count (_x nearRoads 10) < 2)};`
• Spawns parked vehicles with random positioning: `while {(spawner getVariable _spawnKey != 2) and (_countParked < _numParked)} do {`
• Calculates parking position perpendicular to road: `_pos = [_p1, _width, _dirveh + 90] call BIS_Fnc_relPos;`
• Creates vehicles with faction-appropriate types: `_typeVehX = selectRandomWeighted civVehiclesWeighted;`
• Clears vehicle cargo: `[_veh, true, true, true, true] call A3A_fnc_clearVehicleCargo;`
• Initializes vehicle AI: `[_veh, civilian] spawn A3A_fnc_AIVEHinit;`
• Handles boat spawning for coastal areas: `private _mrkMar = seaSpawn select {getMarkerPos _x inArea _markerX};`
• Creates moving traffic with patrol routes: `while {(spawner getVariable _spawnKey != 2) and (_countTraffic < _numTraffic)} do {`
• Creates civilian groups and assigns drivers: `private _groupP = createGroup civilian;`
• Sets up vehicle waypoints for realistic patrol: `_posDestination = getPosATL (selectRandom (nearestTerrainObjects [...]))`
• Configures vehicle behavior: `_groupP setBehaviour "CARELESS"; _veh limitSpeed 50;`
• Manages cleanup with spawn key monitoring: `waitUntil {sleep 1; (spawner getVariable _spawnKey == 2)};`
Where it leads:
• Calls A3A_fnc_clearVehicleCargo for vehicle preparation
• Calls A3A_fnc_AIVEHinit for vehicle AI setup
• Calls A3A_fnc_citiesToCivPatrol for patrol route generation
• Calls A3A_fnc_VEHdespawner for vehicle cleanup
• Calls A3A_fnc_groupDespawner for group cleanup
• Integrates with SCRT_fnc_rivals_trySpawnCarDemo for demo spawning
• Modifies vehicle ownership tracking with ownerSide variable

### Function Name: fn_createCivilianTracks.sqf
What it does:
• Initializes the global civilian audio track database
• Creates a hashmap containing categorized sound effects for civilian interactions
• Provides centralized access to fear sounds and ambient animal noises
How it does that:
• Guards against duplicate initialization: `if !(isNil "A3A_Civilian_Amb_Tracks") exitWith {};`
• Creates hashmap with Fear and Animals categories: `A3A_Civilian_Amb_Tracks = createHashMapFromArray [`
• Populates Fear tracks with durations: `["Fear", [ ["A3A_Audio_Civ_Fear1", 3], ["A3A_Audio_Civ_Fear2", 6], ... ]]`
• Populates Animals tracks with durations: `["Animals", [ ["A3A_Audio_Civ_Dog1", 7], ["A3A_Audio_Civ_Dog2", 7], ... ]]`
Where it leads:
• Provides audio assets to A3A_fnc_civilianFiredNearEH for panic sounds
• Provides audio assets to A3A_fnc_civilianPanic for fear responses
• Enables categorized sound selection for different civilian behaviors
• Sets global A3A_Civilian_Amb_Tracks variable for system-wide access

### Function Name: fn_createMusicSource.sqf
What it does:
• Creates persistent ambient music sources attached to buildings
• Manages a continuous playlist of civilian music and radio broadcasts
• Provides atmospheric audio enhancement for populated urban areas
How it does that:
• Validates ambient sound settings: `if (createAmbientSounds isEqualTo false) exitWith {};`
• Checks faction attributes: `private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];`
• Exits for non-human civilians: `private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];`
• Creates radio item at building position: `private _radioItem = getPosATL _building; _radioItem set [2, ((_radioItem select 2) + 1)];`
• Spawns radio vehicle: `private _musicSource = createVehicle ["Land_FMradio_F", _radioItem];`
• Defines music track array with durations: `private _tracks = [ ["A3A_Audio_Civ_Song1", 127], ["A3A_Audio_Civ_Song2", 192], ... ];`
• Adds destroy action for player interaction: `[_musicSource, 2] call A3A_fnc_destroyObjectAction;`
• Starts continuous playback loop: `while { (alive _musicSource) } do {`
• Cycles through all tracks: `while { _tracksPlayed < _totalTracks } do {`
• Calculates extended play duration: `private _trackDuration = (_track # 1) * 2;`
• Plays track globally: `[_musicSource, _track # 0] remoteExec ["say3D", [0, _musicSource], true];`
• Waits for track completion: `sleep _trackDuration;`
• Adds random delay between playlists: `sleep (random 10);`
Where it leads:
• Calls A3A_fnc_destroyObjectAction for interactive destruction
• Provides continuous ambient audio for populated areas
• Integrates with building-based spawning systems
• Enables player interaction with music sources

### Function Name: fn_createResourceCiv.sqf
What it does:
• Spawns worker civilians at resource production facilities during daytime hours
• Creates interactive workers that can be killed to disable resource production
• Manages worker lifecycle with spawning, patrol assignment, and facility destruction detection
How it does that:
• Checks for non-human civilian exclusion: `private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];`
• Validates daytime operation: `private _daystate = [] call A3A_fnc_getDayState; if (_daystate != "DAY") exitWith {...};`
• Checks destroyed site status: `if (_markerX in destroyedSites) exitWith {...};`
• Creates civilian group: `private _groupX = createGroup civilian;`
• Spawns worker units in safe positions: `for "_i" from 1 to _maxResourceCivilians do {`
• Finds valid spawn position: `private _spawnPosition = [_positionX, 10, 50, 2, 0, -1, 0] call A3A_fnc_getSafePos;`
• Creates worker unit: `private _civUnit = [_groupX, FactionGet(civ, "unitWorker"), _spawnPosition, [],0, "NONE"] call A3A_fnc_createUnit;`
• Stores marker reference: `_civUnit setVariable ["markerX", _markerX, true];`
• Adds event handlers: `[_civUnit] spawn A3A_fnc_civilianInitEH;`
• Adds facility destruction detection: `_civUnit addEventHandler ["Killed", {`
• Monitors group survival: `if (({alive _x} count (units group (_this select 0))) == 0) then {`
• Marks facility as destroyed: `destroyedSites pushBackUnique _markerX; publicVariable "destroyedSites";`
• Triggers destruction notification: `["TaskFailed", ["", format [localize "STR_notifiers_resourcefactory_destoyed", _nameX]]] remoteExec ["BIS_fnc_showNotification",[teamPlayer, civilian]];`
• Assigns patrol behavior: `[_groupX] call A3A_fnc_patrolLoop;`
Where it leads:
• Calls A3A_fnc_getDayState for time validation
• Calls A3A_fnc_createUnit for worker spawning
• Calls A3A_fnc_civilianInitEH for unit initialization
• Calls A3A_fnc_patrolLoop for worker movement
• Calls A3A_fnc_localizar for facility naming
• Modifies destroyedSites global array
• Triggers mission notifications for facility destruction
• Affects resource production capabilities

### Function Name: fn_createRoomLight.sqf
What it does:
• Creates atmospheric interior lighting for civilian buildings
• Adds randomized warm-colored lights to enhance urban environments
• Provides visual enhancement for evening and nighttime scenarios
How it does that:
• Checks low civilian setting: `private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];`
• Exits for low civilian populations: `if (_lowCiv) exitWith {};`
• Defines color palette: `private _colours = [[255,217,66],[255,162,41],[221,219,206]];`
• Selects random color: `private _colour = _colours select (random((count _colours)-1));`
• Generates random brightness: `private _brightness = random 10 / 100;`
• Creates light source: `private _light = "#lightpoint" createVehicle getPosATL _building;`
• Applies lighting properties: `[_light, _brightness] remoteExec ["setLightBrightness"]; [_light, _colour] remoteExec ["setLightColor"];`
• Attaches light to building: `[_light, [_building, [1,1,1]]] remoteExec ["lightAttachObject"];`
Where it leads:
• Enhances visual atmosphere in populated civilian areas
• Integrates with time-based spawning systems (evening/night)
• Provides lighting context for ambient civilian activities
• Supports building-based environmental enhancement

### Function Name: fn_destroyObject.sqf
What it does:
• Creates interactive hold-action for destroying objects like music sources
• Provides player interaction mechanism for environmental object removal
• Enables cleanup of spawned ambient objects
How it does that:
• Defines hold action parameters: `params ["_object", "_time"];`
• Creates destruction action: `[ _object, localize "STR_antistasi_actions_destroy_radio", "\a3\ui_f\data\igui\cfg\simpletasks\types\destroy_ca.paa", ...`
• Sets action conditions and timing: `"true", "true", {}, {}, { private _object = _target; deleteVehicle _object; }, {}, [], _time, nil, true, false`
Where it leads:
• Enables player interaction with ambient objects
• Provides cleanup mechanism for spawned entities
• Integrates with BIS_fnc_holdActionAdd for interaction system

### Function Name: fn_destroyObjectAction.sqf
What it does:
• Broadcasts destruction action to all clients for networked object removal
• Ensures synchronized deletion of interactive objects across the network
• Provides remote execution wrapper for object destruction
How it does that:
• Extracts parameters: `params ["_object", "_time"];`
• Broadcasts destruction action: `[_object, _time] remoteExecCall ["A3A_fnc_destroyObject", 0, _object];`
Where it leads:
• Calls A3A_fnc_destroyObject on all clients
• Enables network-synchronized object removal
• Supports JIP (Join In Progress) players

### Function Name: fn_dialogCiv.sqf
What it does:
• Adds localized hold-action for initiating civilian dialogue
• Provides player interface for interacting with civilians
• Triggers conversation mechanics with appropriate UI feedback
How it does that:
• Validates unit parameter: `params [["_unit", ObjNull]];`
• Creates hold action: `[ _unit, localize "STR_antistasi_actions_talk_with_civ", ...`
• Sets question display: `{ private _question = selectRandom [localize "STR_antistasi_actions_talk_with_civ_question1", ...]; [_caller, _question] remoteExec ["globalChat", _caller]; }`
• Handles successful completion: `{ [_target, _caller] remoteExecCall ["A3A_fnc_dialogCivFinished", 2]; }`
• Sets interruption handling: `{ private _interruption = selectRandom [...]; [_target, _interruption] remoteExec ["globalChat", _caller]; }`
• Configures action parameters: `[], 2, nil, true, false`
Where it leads:
• Calls A3A_fnc_dialogCivFinished for conversation resolution
• Provides localized text for different conversation states
• Integrates with BIS_fnc_holdActionAdd for interaction system

### Function Name: fn_dialogCivAction.sqf
What it does:
• Manages server-side broadcasting and JIP handling for civilian dialogue actions
• Ensures dialogue availability settings are respected
• Provides centralized control over civilian interaction capabilities
How it does that:
• Validates dialogue allowance: `if !(allowCivDialog) exitWith {false};`
• Checks faction attributes: `private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];`
• Exits for inappropriate settings: `private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];`
• Validates server execution: `if (!isServer && hasInterface) exitWith { Error("Server-side function..."); };`
• Broadcasts dialogue action: `[_unit] remoteExecCall ["A3A_fnc_dialogCiv", 0, _unit];`
Where it leads:
• Calls A3A_fnc_dialogCiv on all clients
• Enables network-synchronized dialogue interactions
• Supports JIP players for dialogue actions

### Function Name: fn_dialogCivFinished.sqf
What it does:
• Processes civilian dialogue outcomes and determines success/failure
• Handles intel revelation, mission spawning, and reputation consequences
• Manages dialogue state to prevent repeated conversations
How it does that:
• Validates parameters: `if (_unit isEqualTo ObjNull || _caller isEqualTo ObjNull) exitWith {nil};`
• Checks previous conversation status: `if (_unit getVariable ["A3U_civDialogHasSpoken", false]) exitWith {...}`
• Evaluates dialogue success criteria: `private _isDialogSuccessful = (captive _caller && (4 >= random 10) && (_possibleMarkers isNotEqualTo []));`
• For successful dialogue, determines response type: `if (_roll > 50 && {_missionInProgress isEqualTo false}) then {`
• Selects and spawns appropriate missions: `private _civRequestedMission = selectRandom _civRequestedMissions;`
• Triggers mission scheduling: `[[_missionMarker], _civRequestedMission] remoteExec ["A3A_fnc_scheduler",2];`
• Handles intel revelation: `private _intel = ["Civilian", Occupants] call A3A_fnc_selectIntel;`
• Manages zone revelation mechanics: `if (30 >= (random 100)) then { [1, "A civilian has revealed a zone"] call A3U_fnc_revealRandomZones; }`
• For failed dialogue, selects appropriate failure message based on undercover status
• Marks unit as spoken to prevent repeat conversations: `_unit setVariable ["A3U_civDialogHasSpoken", true, true];`
Where it leads:
• Calls A3A_fnc_findIfNearAndHostile for threat assessment
• Calls A3A_fnc_selectIntel for intelligence generation
• Calls A3A_fnc_scheduler for mission activation
• Calls A3U_fnc_revealRandomZones for map exploration
• Modifies missionNamespace A3U_dialogCivMissionInProgress variable
• Affects player reputation and intel availability
• Integrates with mission spawning system

### Function Name: fn_getDayState.sqf
What it does:
• Determines the current time of day phase for environmental and behavioral logic
• Provides standardized time categorization for civilian and ambient systems
• Supports time-based conditional behaviors and spawning
How it does that:
• Retrieves current date and sun/moon state: `private _date = date; private _sunOrMoon = sunOrMoon;`
• Extracts hour from date: `_hour = (_date#3);`
• Determines morning phase: `if ((_hour > 5) && (_hour < 7)) then { _dayState = "MORNING"; } else { _dayState = "DAY"; };`
• Adjusts for evening/night based on sun visibility: `if(_sunOrMoon < 1) then { _dayState = "EVENING";`
• Handles late night hours: `if((_hour >= 23) || (_hour < 5)) then { _dayState = "NIGHT"; };`
• Provides fallback for unknown states: `if (_dayState == "") exitWith {"UNKNOWN"};`
Where it leads:
• Provides time context to A3A_fnc_createAmbientCiv for activity scheduling
• Provides time context to A3A_fnc_createResourceCiv for worker spawning
• Enables time-based ambient behaviors and spawning restrictions
• Supports environmental adaptation in civilian systems

### Function Name: fn_unitAmbient.sqf
What it does:
• Adds realistic idle behaviors and ambient sounds to units
• Creates lifelike NPC activities with animations and audio cues
• Provides continuous background activity for populated areas
How it does that:
• Validates unit parameter: `if (_unit isEqualTo ObjNull) exitWith {ObjNull};`
• Spawns ambient behavior loop: `[_unit] spawn {`
• Defines sound/animation combinations: `private _ambientSounds = [ ["A3A_Audio_Petros_Ambient_Sneeze", "Acts_Ambient_Gestures_Sneeze", 5], ... ];`
• Maintains continuous loop while unit alive: `while { (alive _unit) } do {`
• Selects random ambient action: `private _combo = selectRandom (_ambientSounds);`
• Executes ambient behavior: `[_unit, _combo#0, _combo#1, _combo#2] call A3A_fnc_unitAmbientPlay;`
• Applies random delay: `sleep (random 1800);`
Where it leads:
• Calls A3A_fnc_unitAmbientPlay for behavior execution
• Provides continuous ambient activity for units
• Enhances NPC realism with varied idle behaviors

### Function Name: fn_unitAmbientPlay.sqf
What it does:
• Executes individual ambient sound and animation combinations
• Provides the core playback mechanism for unit ambient behaviors
• Handles synchronized audio-visual ambient actions
How it does that:
• Extracts behavior parameters: `params ["_unit", "_sound", "_animation", "_delay"];`
• Plays sound globally: `[_unit, _sound] remoteExec ["say3D", 0];`
• Triggers animation: `[_unit, _animation] remoteExec ["playMoveNow", 0];`
• Waits for animation duration: `sleep _delay;`
• Resets to default animation: `[_unit, ""] remoteExec ["switchMove", 0];`
Where it leads:
• Provides atomic ambient behavior execution
• Enables synchronized sound and animation playback
• Supports varied idle behaviors for enhanced NPC realism

## Patcom Functions

### Function Name: fn_clearVehicleCargo.sqf
What it does:
• Removes specified types of cargo from vehicles
• Provides selective cargo clearing for different item categories
• Supports granular control over vehicle inventory management
How it does that:
• Extracts parameters for vehicle and cargo clearing options: `params ["_veh", "_magazineCargo", "_weaponCargo", "_itemCargo", "_backpackCargo"];`
• Clears magazine cargo if requested: `if (_magazineCargo) then { clearMagazineCargoGlobal _veh; };`
• Clears weapon cargo if requested: `if (_weaponCargo) then { clearWeaponCargoGlobal _veh; };`
• Clears item cargo if requested: `if (_itemCargo) then { clearItemCargoGlobal _veh; };`
• Clears backpack cargo if requested: `if (_backpackCargo) then { clearBackpackCargoGlobal _veh; };`
Where it leads:
• Enables vehicle preparation in A3A_fnc_createAmbientCivTraffic for civilian vehicles
• Supports vehicle initialization in traffic spawning systems
• Provides cargo management for AI vehicle systems

### Function Name: fn_debug3DPath.sqf
What it does:
• Visualizes AI pathfinding routes in 3D space for debugging
• Creates persistent visual indicators showing unit movement paths
• Provides developer tools for understanding AI navigation behavior
How it does that:
• Extracts unit and path array parameters: `params ["_Unit","_Array"];`
• Retrieves existing visual elements for cleanup: `private _ArrowA = _Unit getVariable ["ArrowA",[]]; private _VisualA = _Unit getVariable ["VisualA",[]];`
• Cleans up previous arrow visualizations: `if (count _ArrowA > 0) then { {_x call BIS_fnc_drawArrow;} foreach _ArrowA; };`
• Removes previous 3D visual event handlers: `if (count _VisualA > 0) then { {removeMissionEventHandler ["Draw3D",_x];} foreach _VisualA; };`
• Initializes clean arrays for new visualizations: `_ArrowA = []; _VisualA = [];`
• Processes each path point: `{ private _Pos = _x; _Pos set [2,1]; private _StartingPoint = _Pos; private _NextPoint = (_Array # (_foreachindex + 1));`
• Creates 3D line visualization between path points: `if !(isNil "_NextPoint") then { _NextPoint set [2,1]; private _ID = addMissionEventHandler ["Draw3D", format ["drawLine3D [%1, %2, [0.9,0,0,0.5]];",_StartingPoint,_NextPoint]];`
• Adds waypoint icon visualization: `private _ID2 = addMissionEventHandler ["Draw3D", format ["private _Cam = player; if !(isNull curatorCamera) then {_Cam = curatorCamera;}; private _WH = linearConversion[0, 50, _Cam distance2D %1, 1, 0, true]; private _TS = linearConversion[0, 50, _Cam distance2D %1, 0.05, 0, true]; drawIcon3D ['a3\\ui_f\\data\\map\\mapcontrol\\waypoint_ca.paa', [1,1,1,0.8], %1, _WH, _WH, 0, '', 2, _TS, 'PuristaMedium'];", _NextPoint]];`
• Creates arrow visualization: `private _Arrow = [_StartingPoint, _NextPoint, [1,0,0,1], [1,1/5,5]] call BIS_fnc_drawArrow;`
• Stores visual elements for cleanup: `_ArrowA pushback _Arrow; _VisualA pushback _ID; _VisualA pushback _ID2;`
• Saves visual references on unit: `_Unit setVariable ["ArrowA", _ArrowA]; _Unit setVariable ["VisualA", _VisualA];`
• Sets up cleanup event handlers for unit death/deletion: `if !(_Unit getVariable ["DEBUGSET", false]) then { _Unit addEventHandler ["killed", {...}]; _Unit addEventHandler ["Deleted", {...}]; _Unit setVariable ["DEBUGSET",true]; };`
Where it leads:
• Provides debugging visualization for AI pathfinding systems
• Integrates with PathCalculated event handlers for real-time path display
• Enables developer analysis of AI movement patterns
• Calls BIS_fnc_drawArrow for arrow visualization
• Uses Draw3D mission event handlers for persistent 3D display

### Function Name: fn_debugText3D.sqf
What it does:
• Displays temporary 3D text labels above units for debugging purposes
• Provides visual feedback for AI states and behaviors during development
• Supports multiple colors for different types of debug information
How it does that:
• Extracts display parameters: `params ["_Unit", "_Text", ["_Timer", 10], ["_color", "Green"]];`
• Validates unit state: `if !(alive _Unit) exitWith {}; if (isNil "_Unit") exitWith {};`
• Calculates expiration time: `private _TimerEXP = time + _Timer;`
• Sets default white color values: `private _red = 0.9; private _green = 0.9; private _blue = 0.9;`
• Applies color-specific RGB values based on input: `if (_color == "Red") then { _red = 0.9; _green = 0; _blue = 0; };` (and similar for other colors)
• Removes any existing stacked event handler: `[(str _Unit), "onEachFrame"] call BIS_fnc_removeStackedEventHandler;`
• Creates new stacked event handler for 3D text rendering: `[(str _Unit), "onEachFrame", { params ["_Unit", "_text", "_TimerEXP", "_red", "_green", "_blue"]; private _pos = getposATL _Unit; _pos set [2,3]; call compile format ['drawIcon3D["", [%1,%2,%3,1], %4, 0, 0, 0, %5, 2, 0.04, "PuristaMedium", "center", false];', _red, _green, _blue, _pos, (str _text)]; if (!(alive _Unit) || time > _TimerEXP) then { [(str _Unit), "onEachFrame"] call BIS_fnc_removeStackedEventHandler; }; },[_Unit,_text,_TimerEXP, _red, _green, _blue]] call BIS_fnc_addStackedEventHandler;`
Where it leads:
• Provides visual debugging feedback throughout the patcom system
• Enables real-time monitoring of AI states and behaviors
• Supports artillery fire mission status display
• Supports patrol behavior debugging
• Uses BIS_fnc_addStackedEventHandler for persistent frame-based rendering

### Function Name: fn_getSafePos.sqf
What it does:
• Finds safe spawn positions that meet specific terrain and environmental criteria
• Prevents spawning in inappropriate locations like steep slopes, water, or near objects
• Provides robust position validation for AI and civilian spawning systems
How it does that:
• Extracts position generation parameters: `params ["_checkPos","_minDistance","_maxDistance","_objectProximity","_waterMode","_maxGradient","_shoreMode"];`
• Converts object center positions to coordinates: `if (_checkPos isEqualType objNull) then {_checkPos = getPos _checkPos};`
• Sets default maximum distance from world config: `private _defaultMaxDistance = worldSize / 2; if (_maxDistance < 0) then { _maxDistance = getNumber (configFile >> "CfgWorlds" >> worldName >> "safePositionRadius"); if (_maxDistance <= 0) then {_maxDistance = _defaultMaxDistance}; };`
• Configures proximity and shore checking flags: `private _checkProximity = _objectProximity > 0; _shoreMode = _shoreMode != 0;`
• Calculates gradient checking radius: `private _gradientRadius = 1 max _objectProximity * 0.1;`
• Initializes result with center position: `private _FinalResult = _checkPos;`
• Implements safety limit to prevent infinite loops: `private _Pass = true; for "_i" from 1 to 3000 do {`
• Generates candidate position at random distance and angle: `_FinalResult = _checkPos getPos [(_minDistance + (random _maxdistance)), random 360];`
• Validates terrain flatness and gradient: `if (_FinalResult isFlatEmpty [-1, -1, _maxGradient, _gradientRadius, _waterMode, _shoreMode] isEqualTo []) then {_Pass = false;};`
• Checks proximity to terrain objects: `if (_checkProximity && {!(nearestTerrainObjects [_FinalResult, ["TREE", "SMALL TREE", "BUSH", "BUILDING", "HOUSE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "CHURCH", "CHAPEL", "CROSS", "BUNKER", "FORTRESS", "FOUNTAIN", "VIEW-TOWER", "LIGHTHOUSE", "QUAY", "FUELSTATION", "HOSPITAL", "FENCE", "WALL", "BUSSTOP", "FOREST", "TRANSMITTER", "STACK", "RUIN", "TOURISM", "WATERTOWER", "ROCK", "ROCKS", "POWERSOLAR", "POWER LINES", "POWERWAVE", "POWERWIND", "SHIPWRECK"], _objectProximity, false, true] isEqualTo [])}) then {_Pass = false;};`
• Validates position is not inside geometry: `if !(lineIntersectsSurfaces [AGLtoASL _FinalResult, AGLtoASL _FinalResult vectorAdd [0, 0, 50], objNull, objNull, false, 1, "GEOM", "NONE"] isEqualTo []) then {_Pass = false};`
• Exits loop on successful position: `if (_Pass) exitWith {};`
• Falls back to BIS random position if no suitable position found: `if !(_Pass) then { if (_waterMode == 0) then { _FinalResult = [[[_checkPos, _maxdistance]], ["water"]] call BIS_fnc_randomPos; }; ... };`
Where it leads:
• Provides safe positions for A3A_fnc_civilianPanic retreat locations
• Provides safe positions for A3A_fnc_createAmbientCiv civilian spawning
• Provides safe positions for A3A_fnc_createResourceCiv worker spawning
• Provides safe positions for A3A_fnc_createAmbientCivTraffic vehicle placement
• Provides safe positions for artillery fire mission spread calculations
• Enables robust position validation throughout the spawning systems

### Function Name: fn_patrolArea.sqf
What it does:
• Manages area patrol behavior for AI groups with configurable parameters
• Implements intelligent waypoint generation and patrol logic
• Handles different behavior modes for civilian vs military units
How it does that:
• Extracts patrol configuration parameters: `params ["_group", ["_minimumRadius", 50], ["_maximumRadius", 100], ["_maxPatrolDistance", -1], ["_fromCenter", false], ["_centerPos", []], ["_searchBuildings", false]];`
• Retrieves group home position and patrol parameters: `private _groupHomePosition = _group getVariable "PATCOM_Patrol_Home"; private _patrolParams = _group getVariable "PATCOM_Patrol_Params";`
• Sets appropriate combat modes for civilians vs military: `if ((side leader _group) == civilian) then { [_group, "CARELESS", "NORMAL", "LINE", "BLUE", "AUTO"] call A3A_fnc_patrolSetCombatModes; } else { [_group, "SAFE", "LIMITED", "COLUMN", "WHITE", "AUTO"] call A3A_fnc_patrolSetCombatModes; _group setVariable ["PATCOM_Group_State", "CALM"]; };`
• Displays debug information when enabled: `if (PATCOM_DEBUG) then { [leader _group, "PATROL AREA", 10, "White"] call A3A_fnc_debugText3D; };`
• Checks for stuck waypoints after timeout: `if (_group getVariable "PATCOM_WaypointTime" < serverTime) exitWith { [_group, _groupHomePosition, "MOVE", "PATCOM_PATROL_AREA", -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; };`
• Validates current waypoint state: `if (currentWaypoint _group == count waypoints _group || waypointType [_group, currentWaypoint _group] != "MOVE") then {`
• Implements building search chance: `if (_searchBuildings) then { if (15 > random 100) exitWith { [_group] call A3A_fnc_patrolSearchBuilding; [leader _group, "SEARCH BUILDING", 10, "Green"] call A3A_fnc_debugText3D; }; };`
• Enforces maximum patrol distance: `if (_maxPatrolDistance != -1) then { if ((leader _group) distance _groupHomePosition > _maxPatrolDistance) exitWith { [_group, _groupHomePosition, "MOVE", "PATCOM_PATROL_AREA", -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; }; };`
• Generates next waypoint from center or current position: `if (_fromCenter) then { private _nextWaypointPos = [_centerPos, _minimumRadius, _maximumRadius, 2, 0, -1, 0] call A3A_fnc_getSafePos; [_group, _nextWaypointPos, "MOVE", "PATCOM_PATROL_AREA", -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; } else { private _nextWaypointPos = [getPosATL (leader _group), _minimumRadius, _maximumRadius, 2, 0, -1, 0] call A3A_fnc_getSafePos; [_group, _nextWaypointPos, "MOVE", "PATCOM_PATROL_AREA", -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; };`
Where it leads:
• Calls A3A_fnc_patrolSetCombatModes for behavior configuration
• Calls A3A_fnc_debugText3D for status visualization
• Calls A3A_fnc_patrolCreateWaypoint for waypoint management
• Calls A3A_fnc_patrolSearchBuilding for building investigation
• Calls A3A_fnc_getSafePos for position generation
• Modifies PATCOM_Group_State group variable
• Integrates with patrol timeout and distance limit systems

### Function Name: fn_patrolArmStatics.sqf
What it does:
• Searches for available static weapons near AI groups and assigns units to man them
• Provides tactical advantage by utilizing defensive emplacements during combat
• Manages static weapon assignment lifecycle including occupation and abandonment
How it does that:
• Extracts group parameter: `params ["_group"];`
• Initializes assignment tracking arrays: `private _assignedPairs = []; private _leader = leader _group;`
• Finds nearby static weapons: `private _staticsNear = nearestObjects [_leader, ["StaticWeapon"], 150];`
• Filters working statics: `_staticsNear = _staticsNear select {alive _x};`
• Filters uncrewed statics: `_staticsNear = _staticsNear select {(crew _x) isequalto []};`
• Filters available statics (not AI-locked, not assigned, not cargo-loaded): `_staticsNear = _staticsNear select { ((_x getVariable ["lockedForAi", false]) == false) && ((_x getVariable ["PATCOM_STATIC_ASSIGNED", false]) == false) && ( (isNull attachedTo _x) || {!(_x in (attachedTo _x getVariable["ace_cargo_loaded", []]))} ) };`
• Exits if no statics available: `if (count _staticsNear == 0) exitWith {};`
• Gets available units (excluding leader): `private _unitArray = units _group; _unitArray deleteAt (_unitArray find _leader); _unitArray = _unitArray select {isNull objectParent _x};`
• Exits if no units available: `if (count _unitArray == 0) exitWith {};`
• Assigns units to nearby statics: `{ if (count _unitArray == 0) exitWith {}; private _unit = selectRandom _unitArray; if (_unit distance2D _x < 100) then { _assignedPairs pushback [_unit, _x, _group]; _unitArray deleteAt (_unitArray find _unit); }; } foreach _staticsNear;`
• Exits if no assignments made: `if (count _assignedPairs isEqualTo 0) exitWith {};`
• Processes assignments asynchronously: `{ _x spawn { params ["_unit", "_static", "_group"];`
• Validates static availability: `private _assignedGunner = assignedGunner _static; if ((isNull _assignedGunner) && ((_static getVariable ["PATCOM_STATIC_ASSIGNED", false]) == false)) then {`
• Temporarily isolates unit: `[_unit] joinSilent grpnull;`
• Marks static as assigned: `_static setVariable ["PATCOM_STATIC_ASSIGNED", true];`
• Sets unit to safe behavior: `_unit setCombatBehaviour "SAFE"; _unit setUnitCombatMode "BLUE";`
• Displays debug information: `if (PATCOM_DEBUG) then { [_unit, "STATIC FOUND", 5, "Green"] call A3A_fnc_debugText3D; };`
• Commands unit to static: `_unit doMove (getPosATL _static); _unit assignAsGunner _static; [_unit] orderGetIn true;`
• Waits for unit to reach static: `while {(alive _unit) && {_unit distance _static > 4}} do { sleep 3; }; _unit moveInGunner _static;`
• Sets unit to aware state: `_unit setCombatBehaviour "AWARE"; _unit setUnitCombatMode "YELLOW";`
• Registers artillery if applicable: `if (typeOf _static in FactionGet(all, "vehiclesArtillery")) then { [_group] call A3A_fnc_artilleryAdd; };`
• Monitors static usage with timer logic: `[_unit, _static, _group] spawn { params ["_unit", "_static", "_group"]; private _staticGreen = true; private _statictime = PATCOM_AI_STATIC_ARM; while {_staticGreen && {alive _unit} && {alive _static} && {!(isNull (gunner _static))} && {_unit distance2D (leader (group _unit)) < 500}} do { sleep 5;`
• Adjusts timer based on enemy visibility: `private _enemy = _unit findNearestEnemy _unit; if (!(isNull _enemy)) then { private _cansee = [_unit, "VIEW"] checkVisibility [eyePos _unit, eyePos _enemy]; if (_cansee > 0) then { _statictime = _statictime + 3; } else { _statictime = _statictime - 5; }; } else { _statictime = _statictime - 5; }; if (_statictime < 1) then { _staticGreen = false; };`
• Disengages unit from static: `unassignVehicle _unit; _unit leaveVehicle _static; _static setVariable ["PATCOM_STATIC_ASSIGNED", false]; doGetOut _unit; [_unit] joinSilent _group;`
Where it leads:
• Calls A3A_fnc_debugText3D for visual feedback during static assignment
• Calls A3A_fnc_artilleryAdd when artillery statics are manned
• Modifies PATCOM_STATIC_ASSIGNED static weapon variable
• Temporarily creates single-unit groups during assignment process
• Integrates with artillery fire mission system for static artillery

### Function Name: fn_patrolAttack.sqf
What it does:
• Transitions AI groups into combat mode when enemies are detected
• Generates attack waypoints targeting known enemy positions
• Coordinates tactical assault behavior with appropriate combat settings
How it does that:
• Extracts attack parameters: `params ["_group", "_knownEnemies", ["_minimumRadius", 25], ["_maximumRadius", 50], ["_objectDistance", 2], ["_waterMode", 0], ["_maxGradient", -1], ["_shoreMode", 0]];`
• Exits to previous orders if no enemies: `if (count _knownEnemies < 1) exitWith { private _previousOrders = _group getVariable "PATCOM_Previous_Orders"; _group setVariable ["PATCOM_Current_Orders", _previousOrders]; _group setVariable ["PATCOM_Group_State", "CALM"]; };`
• Sets combat behavior modes: `[_group, "COMBAT", "FULL", "COLUMN", "RED", "AUTO"] call A3A_fnc_patrolSetCombatModes;`
• Displays debug information: `if (PATCOM_DEBUG) then { [leader _group, "ATTACK", 10, "White"] call A3A_fnc_debugText3D; };`
• Enables static weapon checking in combat: `if (PATCOM_AI_STATICS) then { [_group] call A3A_fnc_patrolArmStatics; };`
• Sets waypoint naming: `private _waypointName = "PATCOM_PATROL_ATTACK";`
• Creates attack waypoint if needed: `if ((waypointType [_group, currentWaypoint _group] != "SAD") || ((waypointName [_group, currentWaypoint _group]) != _waypointName)) then { private _targetGroup = selectRandom _knownEnemies; private _nextWaypointPos = [getPosATL (leader _targetGroup), _minimumRadius, _maximumRadius, _objectDistance, _waterMode, _maxGradient, _shoreMode] call A3A_fnc_getSafePos; [_group, _nextWaypointPos, "SAD", _waypointName, -1, 50] call A3A_fnc_patrolCreateWaypoint; };`
Where it leads:
• Calls A3A_fnc_patrolSetCombatModes for combat behavior setup
• Calls A3A_fnc_debugText3D for attack state visualization
• Calls A3A_fnc_patrolArmStatics for defensive positioning during combat
• Calls A3A_fnc_getSafePos for attack waypoint positioning
• Calls A3A_fnc_patrolCreateWaypoint for waypoint management
• Modifies PATCOM_Previous_Orders and PATCOM_Current_Orders group variables
• Modifies PATCOM_Group_State to "COMBAT"

### Function Name: fn_patrolBuildingEnterable.sqf
What it does:
• Validates whether buildings can be entered by AI units
• Checks building configuration and applies blacklist filtering
• Ensures only appropriate buildings are used for garrison or search operations
How it does that:
• Extracts building parameter: `params ["_house"];`
• Checks building position availability: `private _enterable = !((_house buildingPos 0) isEqualTo [0,0,0]);`
• Applies blacklist filtering: `if (_enterable && !((count PATCOM_Building_Blacklist) == 0)) then { if ((typeOf _house) in PATCOM_Building_Blacklist) then { _enterable = false; }; };`
• Returns validation result: `_enterable`
Where it leads:
• Provides validation for A3A_fnc_patrolEnterableBuildings building filtering
• Ensures blacklisted buildings are excluded from AI operations
• Supports building-based garrison and search functionality

### Function Name: fn_patrolCivilianCommander.sqf
What it does:
• Manages civilian group patrol behavior with specialized parameters
• Applies civilian-specific movement and interaction rules
• Maintains civilian AI within designated patrol boundaries
How it does that:
• Extracts group parameter: `params ["_group"];`
• Retrieves patrol parameters: `private _patrolParams = _group getVariable "PATCOM_Patrol_Params";`
• Validates group existence: `if (count units _group <= 0) exitWith {};`
• Applies civilian-specific patrol: `if ((side leader _group) == civilian) then { [_group, _patrolParams#1, _patrolParams#2, _patrolParams#3,_patrolParams#4,_patrolParams#5,_patrolParams#6,_patrolParams#7] call A3A_fnc_patrolArea; };`
Where it leads:
• Calls A3A_fnc_patrolArea for civilian patrol execution
• Maintains civilian-specific patrol parameters and behavior
• Integrates with civilian AI management system

### Function Name: fn_patrolCommander.sqf
What it does:
• Main AI command logic coordinating patrol, defense, and attack behaviors
• Processes enemy detection and dynamically switches between operational modes
• Central hub for AI decision-making and state management
How it does that:
• Extracts group parameter: `params ["_group"];`
• Validates group existence: `if (count units _group == 0) exitWith { If (PATCOM_DEBUG) then { ServerDebug_1("PATCOM | Group Eliminated, Exiting PATCOM Group: %1", _group); }; };`
• Calls formation handler: `private _knownEnemies = [_group] call A3A_fnc_patrolGetEnemies; private _patrolParams = _group getVariable "PATCOM_Patrol_Params"; private _currentOrders = _patrolParams # 0; [leader _group] call A3A_fnc_patrolHandleFormation;`
• Checks for enemy presence: `if (count _knownEnemies > 0) then { if ((_currentOrders != "Patrol_Attack") && (_currentOrders != "Patrol_Water")) then { _group setVariable ["PATCOM_Previous_Orders", _currentOrders]; _currentOrders = "Patrol_Attack"; _group setVariable ["PATCOM_Group_State", "COMBAT"]; }; };`
• Logs debug information: `If (PATCOM_DEBUG) then { ServerDebug_3("PATCOM | Group: %1 | Current Orders: %2 | Group State: %3", _group, _currentOrders, _group getVariable "PATCOM_Group_State"); };`
• Routes to appropriate behavior handlers: `if (_currentOrders == "Patrol_Attack") exitWith { [_group, _knownEnemies] call A3A_fnc_patrolAttack; }; if (_currentOrders == "Patrol_Defend") exitWith { [_group, _patrolParams#1, _patrolParams#2, _patrolParams#4, _patrolParams#5] call A3A_fnc_patrolDefend; }; if (_currentOrders == "Patrol_Area") exitWith { [_group, _patrolParams#1, _patrolParams#2, _patrolParams#3, _patrolParams#4, _patrolParams#5, _patrolParams#6] call A3A_fnc_patrolArea; }; if (_currentOrders == "Patrol_Water") exitWith { [_group, _patrolParams#1, _patrolParams#2, _patrolParams#3, _patrolParams#4, _patrolParams#5] call A3A_fnc_patrolWater; };`
Where it leads:
• Calls A3A_fnc_patrolGetEnemies for threat detection
• Calls A3A_fnc_patrolHandleFormation for group formation management
• Calls A3A_fnc_patrolAttack for combat behavior
• Calls A3A_fnc_patrolDefend for defensive operations
• Calls A3A_fnc_patrolArea for patrol activities
• Calls A3A_fnc_patrolWater for aquatic patrols
• Modifies PATCOM_Previous_Orders, PATCOM_Current_Orders, and PATCOM_Group_State variables
• Central coordinator for all PATCOM behavioral states

### Function Name: fn_patrolCreateWaypoint.sqf
What it does:
• Creates and manages AI waypoints with intelligent reuse and positioning
• Handles waypoint lifecycle including creation, updating, and validation
• Prevents waypoint conflicts and ensures proper AI navigation
How it does that:
• Extracts waypoint parameters: `params ["_group", "_position", "_waypointType", "_waypointName", ["_radius", -1], ["_distance", 50]];`
• Validates position data: `if ((count _position) < 3) exitWith {};`
• Gets current waypoint reference: `private _waypointCount = count waypoints _group - 1; private _waypoint = [_group, _waypointCount];`
• Checks for existing waypoint reuse: `if (count waypoints _group > 1 && waypointName _waypoint isEqualTo _waypointName) then { if (_radius == -1) then { _waypointPos = AGLtoASL waypointPosition _waypoint; _position = AGLtoASL _position; } else { _waypointPos = waypointPosition _waypoint; }; if (_position distance _waypointPos > _distance) then { _waypoint setWaypointPosition [_position, _radius]; }; } else { _waypoint = _group addWaypoint [AGLtoASL _position, _radius]; _waypoint setWaypointName _waypointName; };`
• Ensures current waypoint is set: `if ((_waypoint#1) != currentWaypoint _group) then { _group setCurrentWaypoint _waypoint; };`
• Validates waypoint type: `if (waypointType _waypoint != _waypointType) then { _waypoint setWaypointType _waypointType; };`
• Sets waypoint timeout: `private _waypointTime = serverTime + 300; _group setVariable ["PATCOM_WaypointTime", _waypointTime];`
Where it leads:
• Provides waypoint creation for all patrol behaviors
• Modifies PATCOM_WaypointTime group variable for timeout tracking
• Supports waypoint reuse to prevent AI navigation conflicts
• Integrates with all PATCOM movement and combat systems

### Function Name: fn_patrolDefend.sqf
What it does:
• Establishes defensive patrol patterns around specified positions
• Maintains AI presence in designated defense areas
• Coordinates defensive positioning with static weapon utilization
How it does that:
• Extracts defense parameters: `params ["_group", ["_minimumRadius", 20], ["_maximumRadius", 100], ["_fromCenter", false], ["_centerPos", []]];`
• Sets defensive behavior: `[_group, "SAFE", "LIMITED", "COLUMN", "WHITE", "AUTO"] call A3A_fnc_patrolSetCombatModes; _group setVariable ["PATCOM_Group_State", "CALM"];`
• Displays debug information: `if (PATCOM_DEBUG) then { [leader _group, "DEFEND", 10, "White"] call A3A_fnc_debugText3D; };`
• Retrieves patrol parameters: `private _patrolParams = _group getVariable "PATCOM_Patrol_Params"; private _waypointName = "PATCOM_PATROL_DEFEND";`
• Creates defense waypoints: `if ((waypointType [_group, currentWaypoint _group] != "MOVE") || ((waypointName [_group, currentWaypoint _group]) != _waypointName)) then { if (PATCOM_AI_STATICS) then { [_group] call A3A_fnc_patrolArmStatics; }; private _nextWaypointPos = [_centerPos, _minimumRadius, _maximumRadius, 2, 0, -1, 0] call A3A_fnc_getSafePos; [_group, _nextWaypointPos, "MOVE", _waypointName, -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; };`
Where it leads:
• Calls A3A_fnc_patrolSetCombatModes for defensive behavior setup
• Calls A3A_fnc_debugText3D for defense state visualization
• Calls A3A_fnc_patrolArmStatics for defensive weapon positioning
• Calls A3A_fnc_getSafePos for defense waypoint positioning
• Calls A3A_fnc_patrolCreateWaypoint for waypoint management
• Modifies PATCOM_Group_State to "CALM"
• Supports static defense and area denial operations

### Function Name: fn_patrolEnterableBuildings.sqf
What it does:
• Scans areas for buildings that AI can enter and occupy
• Filters buildings based on enterability and proximity
• Provides building lists for garrison and search operations
How it does that:
• Extracts search parameters: `params ["_position", "_radius"];`
• Initializes results array: `private _enterable = [];`
• Filters buildings by enterability: `{ if ([_x] call A3A_fnc_patrolBuildingEnterable) then { _enterable pushback _x; }; } forEach (nearestObjects [_position, ["House","Building"], _radius]);`
• Returns validated building list: `_enterable;`
Where it leads:
• Calls A3A_fnc_patrolBuildingEnterable for individual building validation
• Provides building lists to A3A_fnc_patrolGroupGarrison for unit placement
• Supports building-based defensive and patrol operations

### Function Name: fn_patrolGetEnemies.sqf
What it does:
• Detects and catalogs known enemy units and groups within visual range
• Applies side-based filtering for appropriate threat identification
• Supports different game modes with varying faction relationships
How it does that:
• Extracts group parameter: `params ["_group"];`
• Determines group side: `private _side = side _group;`
• Configures enemy sides based on game mode: `_enemySides = if (gameMode isEqualTo 2) then { switch (_side) do { case (teamPlayer): { [Occupants, Invaders, sideEnemy] }; case (Occupants); case (Invaders): { [teamPlayer, sideEnemy] }; }; } else { switch (_side) do { case (teamPlayer): { [Occupants, Invaders, sideEnemy] }; case (Occupants): { [teamPlayer, Invaders, sideEnemy] }; case (Invaders): { [teamPlayer, Occupants, sideEnemy] }; }; };`
• Gets known targets: `_knownEnemies append (_group targets [true, PATCOM_VISUAL_RANGE, _enemySides, PATCOM_TARGET_TIME]);`
• Adds additional known enemies from area scan: `{ if ((side _x) in _enemySides) then { if ((_group knowsAbout _x) > 2) then { _knownEnemies pushBackUnique (group _x); }; }; } forEach (allUnits inAreaArray [getPosATL (leader _group), PATCOM_VISUAL_RANGE, PATCOM_VISUAL_RANGE]);`
• Returns enemy group list: `_knownEnemies`
Where it leads:
• Provides enemy data to A3A_fnc_patrolCommander for threat assessment
• Enables dynamic switching to attack behavior when enemies detected
• Supports PATCOM_AI_STATICS integration for combat readiness
• Feeds into all combat and patrol decision-making systems

### Function Name: fn_patrolGroupGarrison.sqf
What it does:
• Automatically places AI units in garrison positions within buildings
• Distributes units across available building positions for defensive coverage
• Creates additional patrol groups when buildings have insufficient positions
How it does that:
• Extracts garrison parameters: `params ["_group", "_position", "_radius"];`
• Validates group units: `if (count _units == 0) exitwith {};`
• Locks waypoints during garrisoning: `_group lockWP true;`
• Finds garrison-capable buildings: `_buildings = nearestObjects [_position, keys PATCOM_Garrison_Positions, _radius]; if (count _buildings == 0) then { _buildings = [_position, _radius] call A3A_fnc_patrolEnterableBuildings; };`
• Filters undamaged buildings: `_buildings = _buildings select { damage _x < 1 && !isObjectHidden _x }; _buildings = _buildings call BIS_fnc_arrayShuffle;`
• Processes buildings for garrison positions: `{ if (count _units == 0) exitWith {}; private _building = _x; private _class = typeOf _building; private _buildingPositions = []; if (_class in PATCOM_Garrison_Positions) then { { private _buildingPos = _building buildingPos _x; if !(_buildingPos isEqualTo [0,0,0]) then { _buildingPositions pushBack _buildingPos; }; } forEach (PATCOM_Garrison_Positions get _class); } else { _buildingPositions = _building buildingPos -1; }; { if (count _units == 0) exitWith {}; private _unit = _units select 0; private _position = _x; _unit setposATL _position; _unit setdir ((_unit getRelDir _building)-180); _unit disableAI "PATH"; _unit setUnitPos "UP"; dostop _unit; _units deleteAt 0; } foreach _buildingPositions; } forEach _buildings;`
• Creates additional patrol group for remaining units: `if (count _units > 0) then { private _groupSplit = createGroup (side _group); _newGroups pushBack _groupSplit; _units joinSilent _groupSplit; [_groupSplit, "Patrol_Defend", 0, 100, -1, true, _position, false] call A3A_fnc_patrolLoop; };`
Where it leads:
• Calls A3A_fnc_patrolEnterableBuildings for building validation
• Calls A3A_fnc_patrolLoop for additional patrol group creation
• Disables AI pathfinding for garrisoned units
• Returns new patrol groups for further processing
• Supports building-based defensive positioning

### Function Name: fn_patrolGroupVariables.sqf
What it does:
• Initializes PATCOM control variables on AI groups
• Sets up patrol parameters and behavior configurations
• Prevents duplicate initialization and ensures proper state management
How it does that:
• Extracts group parameter: `params ["_group"];`
• Validates group has units: `if (count units _group <= 0) exitWith { if (PATCOM_DEBUG) then { ServerDebug_1("PATCOM | Group: %1 is Empty", _group); }; };`
• Checks for existing PATCOM control: `if (_group getVariable "PATCOM_Controlled") exitWith { if (PATCOM_DEBUG) then { ServerDebug_1("PATCOM | Group: %1 is already controlled", _group); }; };`
• Logs initialization: `If (PATCOM_DEBUG) then { ServerDebug_2("PATCOM | Setting up Variables on group: %1 - side: %2", _group, side (leader _group)); };`
• Configures civilian groups: `if ((side leader _group) == civilian) then { if ((count (_group getVariable ["PATCOM_Patrol_Params", []])) == 0) then { _group setVariable ["PATCOM_Patrol_Params", ["Civilian", 10, 50 + (random 50), -1, true, getPosATL (leader _group), true]]; }; _group setVariable ["PATCOM_Patrol_Home", getPosATL (leader _group)]; { _x forceWalk true; _x disableAI "AUTOCOMBAT"; } forEach units _group; _group setVariable ["PATCOM_ForceWalk", true]; _group setVariable ["PATCOM_Controlled", true]; };`
• Configures military groups: `else { _group setVariable ["PATCOM_Previous_Orders", ""]; if ((count (_group getVariable ["PATCOM_Patrol_Params", []])) == 0) then { _group setVariable ["PATCOM_Patrol_Params", ["Patrol_Area", 50, 100, -1, true, getPosATL (leader _group), false]]; }; _group setVariable ["PATCOM_Patrol_Home", getPosATL (leader _group)]; _group setVariable ["PATCOM_Group_State", "CALM"]; _group setVariable ["PATCOM_COMBAT_CHECK", serverTime]; _group setVariable ["PATCOM_Controlled", true]; if (PATCOM_DEBUG) then { { private _PathEH = _x addEventHandler ["PathCalculated", { _this spawn A3A_fnc_debug3DPath; }]; } foreach (units _group); }; };`
Where it leads:
• Calls A3A_fnc_debug3DPath for path visualization in debug mode
• Sets up all PATCOM control variables and patrol parameters
• Configures civilian walking behavior and AI restrictions
• Establishes initial group state and home positions
• Prevents duplicate PATCOM initialization

### Function Name: fn_patrolHandleFormation.sqf
What it does:
• Dynamically adjusts AI group formations based on terrain and location features
• Applies context-appropriate formations for urban, rural, and special areas
• Maintains formation settings with timeout-based refresh logic
How it does that:
• Extracts leader parameter: `params ["_unit"];`
• Sets formation check distance: `private _distanceToCheck = 300;`
• Gets group reference: `private _group = group _unit;`
• Checks formation refresh timer: `private _formationSet = _group getVariable ["PATCOM_Form_Set", [false, 0]]; if ((_formationSet # 1) < serverTime) then { _group setVariable ["PATCOM_Form_Set", [false, 0]]; }; if (_formationSet # 0) exitWith {};`
• Handles vehicle convoy formations: `if (!isNull objectParent _unit && {behaviour _unit == "SAFE"}) exitWith { _group setFormation "FILE"; _group setVariable ["PATCOM_Form_Set", [true, serverTime + 300]]; };`
• Applies urban formations: `private _nearestCity = nearestLocations [getPosASL _unit, ["nameCity", "NameVillage"], _distanceToCheck]; if (count _nearestCity > 0) exitWith { if (!isNull objectParent _unit) then { _group setFormation "COLUMN"; } else { _group setFormation "STAG COLUMN"; }; _group setVariable ["PATCOM_Form_Set", [true, serverTime + 300]]; };`
• Applies hill formations: `private _nearestHill = nearestLocations [getPosASL _unit, ["Hill"], _distanceToCheck]; if (count _nearestHill > 0) exitWith { _group setFormation "LINE"; _group setVariable ["PATCOM_Form_Set", [true, serverTime + 300]]; };`
• Applies airport/seaport formations: `private _nearestLocal = nearestLocations [getPosASL _unit, ["NameLocal"], _distanceToCheck]; if (count _nearestLocal > 0) exitWith { _group setFormation "COLUMN"; _group setVariable ["PATCOM_Form_Set", [true, serverTime + 300]]; };`
• Sets default formation: `_group setFormation "WEDGE"; _group setVariable ["PATCOM_Form_Set", [true, serverTime + 300]];`
Where it leads:
• Modifies group formation based on environmental context
• Sets PATCOM_Form_Set variable with timeout tracking
• Supports different formations for vehicles vs infantry
• Provides location-aware tactical formations

### Function Name: fn_patrolInit.sqf
What it does:
• Initializes the PATCOM system with required data structures and configurations
• Sets up building blacklists and garrison position mappings
• Prepares the patrol command system for operation
How it does that:
• Creates building blacklist hashmap: `PATCOM_Building_Blacklist = createHashMap; { PATCOM_Building_Blacklist set [_x, "REMOVED"]; } forEach A3A_buildingBlacklist;`
• Initializes garrison positions hashmap with extensive building configurations: `PATCOM_Garrison_Positions = createHashMapFromArray [ ["Land_Cargo_HQ_V1_F", [6,7,8]], ["Land_Cargo_HQ_V2_F", [6,7,8]], ... ];`
• Marks initialization complete: `PATCOM_INIT_COMPLETE = true; Info("PATCOM | Init Complete");`
Where it leads:
• Provides building blacklist for A3A_fnc_patrolBuildingEnterable
• Supplies garrison mappings for A3A_fnc_patrolGroupGarrison
• Enables all PATCOM functionality through proper initialization
• Sets PATCOM_INIT_COMPLETE global flag

### Function Name: fn_patrolLoop.sqf
What it does:
• Main patrol execution loop managing AI group behaviors
• Continuously processes groups through appropriate command functions
• Handles both civilian and military patrol patterns with adaptive timing
How it does that:
• Extracts patrol configuration: `params ["_group", ["_patrolType", "Patrol_Area"], ["_minDist", 0], ["_maxDist", 100], ["_dist", -1], ["_fromCenter", true], ["_centerPos", []], ["_searchBuildings", false]];`
• Spawns patrol execution: `[_group, _patrolType, _minDist, _maxDist, _dist, _fromCenter, _centerPos, _searchBuildings] spawn {`
• Validates group existence: `if ((isNull _group) || (({alive _x} count units _group) < 1)) exitWith {};`
• Sets default center position: `if (count _centerPos < 3) then { _centerPos = (getPosATL (leader _group)); };`
• Configures military patrol parameters: `if !((side leader _group) == civilian) then { _group setVariable ["PATCOM_Patrol_Params", [_patrolType, _minDist, _maxDist, _dist, _fromCenter, _centerPos, _searchBuildings]]; };`
• Initializes group variables: `[_group] call A3A_fnc_patrolGroupVariables;`
• Runs continuous patrol loop: `while {true} do { if ((isNull _group) || (({alive _x} count units _group) < 1)) exitWith {}; if ((side leader _group) == civilian) then { [_group] call A3A_fnc_patrolCivilianCommander; } else { [_group] call A3A_fnc_patrolCommander; }; sleep (round (((count allunits) / 2) * 1.2)); };`
Where it leads:
• Calls A3A_fnc_patrolGroupVariables for initialization
• Calls A3A_fnc_patrolCivilianCommander for civilian groups
• Calls A3A_fnc_patrolCommander for military groups
• Sets PATCOM_Patrol_Params group variable
• Provides continuous AI behavior management with adaptive timing

### Function Name: fn_patrolSearchBuilding.sqf
What it does:
• Directs AI groups to systematically search nearby buildings for enemies
• Implements building clearing tactics with waypoint management
• Provides tactical building investigation capabilities
How it does that:
• Extracts group parameter: `params ["_group"];`
• Finds nearest building to search: `private _building = nearestBuilding (getPosATL (leader _group)); if ((leader _group) distance _building > 250) exitwith {};`
• Spawns search execution: `[_group, _building] spawn {`
• Logs search activity: `ServerDebug_2("PATCOM | Group: %1 | Searching Building: %2", _group, _building);`
• Locks waypoints for search: `private _leader = leader _group; _group lockWP true;`
• Creates search waypoint: `[_group, getPosATL _building, "MOVE", "PATCOM_HOUSE_SEARCH", -1, 50] call A3A_fnc_patrolCreateWaypoint;`
• Prepares search behavior: `_group setBehaviour "AWARE"; _group setFormDir ([_leader, _building] call BIS_fnc_dirTo);`
• Clears building positions: `private _positions = _building buildingPos -1; while {_positions isNotEqualTo []} do { private _units = units _group; if (_units isEqualTo []) exitWith {}; { if (_positions isEqualTo []) exitWith {}; if (unitReady _x) then { private _pos = _positions deleteAt 0; _x doMove _pos; sleep 2; }; } forEach _units; sleep 5; };`
• Completes search and resumes patrol: `_group lockWP false; _group setBehaviour "SAFE"; private _nextWaypoint = [getPosATL (leader _group), 50, 100, 0, 0, -1, 0, getPosATL (leader _group)] call A3A_fnc_getSafePos; [_group, _nextWaypoint, "MOVE", "PATCOM_PATROL_AREA", -1, 50] call A3A_fnc_patrolCreateWaypoint;`
Where it leads:
• Calls A3A_fnc_patrolCreateWaypoint for search and patrol waypoints
• Calls A3A_fnc_getSafePos for exit positioning
• Temporarily locks group waypoints during search
• Supports building clearing and enemy detection operations

### Function Name: fn_patrolSetCombatModes.sqf
What it does:
• Applies comprehensive combat behavior settings to AI groups
• Manages behavior, speed, formation, and combat mode configurations
• Prevents redundant setting changes through state tracking
How it does that:
• Extracts combat parameters: `params ["_group", ["_behaviour", "SAFE"], ["_speedMode", "NORMAL"], ["_formation", "COLUMN"], ["_combatMode", "GREEN"], ["_stance", "AUTO"]];`
• Checks for setting changes: `if ((behaviour leader _group != _behaviour) || (speedMode _group != _speedMode) || (formation _group != _formation) || (combatMode _group != _combatMode)) then { _group setVariable ["PATCOM_Combat_Modes_Set", false]; };`
• Skips redundant updates: `if (_group getVariable "PATCOM_Combat_Modes_Set") exitWith {};`
• Applies group settings: `_group setBehaviour _behaviour; _group setSpeedMode _speedMode; _group setFormation _formation; _group setCombatMode _combatMode;`
• Sets individual unit stances: `if (_stance != "AUTO") then { { _x setUnitPos _stance; } forEach units _group; };`
• Marks settings as applied: `_group setVariable ["PATCOM_Combat_Modes_Set", true];`
Where it leads:
• Modifies PATCOM_Combat_Modes_Set group variable
• Provides centralized combat behavior management
• Supports all PATCOM behavioral states and transitions
• Used by all patrol command functions for consistent AI behavior

### Function Name: fn_patrolWater.sqf
What it does:
• Manages aquatic patrol patterns for naval or amphibious AI groups
• Generates waypoints specifically for water-based movement
• Maintains patrol discipline with distance and timing constraints
How it does that:
• Extracts water patrol parameters: `params ["_group", ["_minimumRadius", 50], ["_maximumRadius", 100], ["_maxPatrolDistance", -1], ["_fromCenter", false], ["_centerPos", []]];`
• Sets calm patrol behavior: `[_group, "SAFE", "LIMITED", "COLUMN", "WHITE", "AUTO"] call A3A_fnc_patrolSetCombatModes; _group setVariable ["PATCOM_Group_State", "CALM"];`
• Displays debug information: `if (PATCOM_DEBUG) then { [leader _group, "PATROL WATER", 10, "White"] call A3A_fnc_debugText3D; };`
• Retrieves patrol parameters: `private _groupHomePosition = _group getVariable "PATCOM_Patrol_Home"; private _patrolParams = _group getVariable "PATCOM_Patrol_Params";`
• Checks waypoint timeout: `if (_group getVariable "PATCOM_WaypointTime" < serverTime) exitWith { [_group, _groupHomePosition, "MOVE", "PATCOM_PATROL_WATER", -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; };`
• Creates water waypoints: `if (currentWaypoint _group == count waypoints _group || waypointType [_group, currentWaypoint _group] != "MOVE") then { if (_maxPatrolDistance != -1) then { if ((leader _group) distance _groupHomePosition > _maxPatrolDistance) exitWith { [_group, _groupHomePosition, "MOVE", "PATCOM_PATROL_WATER", -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; }; }; if (_fromCenter) then { private _nextWaypointPos = [_centerPos, _minimumRadius, _maximumRadius, 2, 2, -1, 0] call A3A_fnc_getSafePos; [_group, _nextWaypointPos, "MOVE", "PATCOM_PATROL_WATER", -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; } else { private _nextWaypointPos = [getPosATL (leader _group), _minimumRadius, _maximumRadius, 2, 2, -1, 0] call A3A_fnc_getSafePos; [_group, _nextWaypointPos, "MOVE", "PATCOM_PATROL_WATER", -1, _patrolParams # 1] call A3A_fnc_patrolCreateWaypoint; }; };`
Where it leads:
• Calls A3A_fnc_patrolSetCombatModes for water patrol behavior
• Calls A3A_fnc_debugText3D for patrol state visualization
• Calls A3A_fnc_getSafePos with water mode (2) for aquatic positioning
• Calls A3A_fnc_patrolCreateWaypoint for water waypoint management
• Modifies PATCOM_Group_State to "CALM"
• Supports naval and amphibious AI operations