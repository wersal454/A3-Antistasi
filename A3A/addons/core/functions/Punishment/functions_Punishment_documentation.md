fn_outOfBounds.sqf
Function Name: fn_outOfBounds.sqf What it does: This is a client-side scheduled loop that monitors the player's position. If the player is outside the defined playable area (world boundaries) and not at HQ, it initiates a countdown. If the player does not return to the valid area within 30 seconds, the player is neutralized (kicked back to the lobby or penalized). It allows planes a larger buffer zone.

How it does that: The function executes a while loop that runs once per second as long as the player is alive.

Initialization & Guard Clause: The function first ensures it runs only on a client with an interface (hasInterface). It checks a variable outOfBoundsInit on the player to prevent multiple concurrent loops (idempotency).

Sqf

Apply
if !(hasInterface) exitWith {};
if (player getVariable ["outOfBoundsInit", false]) exitWith {};
player setVariable ["outOfBoundsInit", true];
Variable Setup: Initializes the countdown timer (_timeLeft = 30) and a reset timeout for the timer logic (_timerResetTimeOut = 0).

Sqf

Apply
private _timeLeft = 30;
private _timerResetTimeOut = 0;
Main Loop: The loop runs continuously while the player is alive.

Position Check: It extracts the X and Y coordinates from the player's position.
Limit Definition: It determines the boundary limit. For planes, the limit is 10,000 meters; for all other vehicles/infantry, it is 0 (strict adherence to world edges).
Out of Bounds Logic: It uses findIf to check if either X or Y coordinate is less than -_limit or greater than worldSize + _limit.
HQ Check: It verifies if the player is within 200 meters of the HQ respawn marker (respawnTeamPlayer).
Sqf

Apply
while {alive player} do {
    private _pos = getPos player select [0,2];
    private _limit = if (vehicle player isKindOf "Plane") then {10000} else {0};

    private _outOfBounds = _pos findIf { (_x < -_limit) || (_x > worldSize + _limit)} != -1;
    private _atHQ = (player distance2D getMarkerPos respawnTeamPlayer) < 200;
Penalty Logic:

Case: Out of Bounds: If _outOfBounds is true and _atHQ is false:
If the timer (_timeLeft) reaches 0, it executes BIS_fnc_neutralizeUnit to kill/despawn the player.
Otherwise, it decrements _timeLeft by 1 and sets _timerResetTimeOut to 60 (prevents the timer from resetting immediately for a minute). It displays a hint to the user using A3A_fnc_customHint.
Case: In Bounds: If the player is within bounds:
If _timerResetTimeOut is 0, it resets _timeLeft to 30.
Otherwise, it decrements _timerResetTimeOut.
Sqf

Apply
    if (_outOfBounds and !_atHQ) then {
        if (_timeLeft isEqualTo 0) then {player call BIS_fnc_neutralizeUnit} else {
            _timerResetTimeOut = 60;
            _timeLeft = _timeLeft -1;
            [localize "STR_A3A_punishment_oob_header", format [localize "STR_A3A_punishment_oob", _timeLeft]] call A3A_fnc_customHint;
        };
    } else {
        if (_timerResetTimeOut == 0) then {
            _timeLeft = 30;
        } else {
            _timerResetTimeOut = _timerResetTimeOut -1;
        };
    };
    uiSleep 1;
};
Cleanup: When the loop terminates (player dies), the initialization variable is reset to false so the script can run again on the next respawn (though the script logic suggests it is meant to persist only until death, as noted by the comment "dosnt reset across respawn").

Sqf

Apply
player setVariable ["outOfBoundsInit", false];
Where it leads:

Calls:
A3A_fnc_customHint: Displays the warning message.
BIS_fnc_neutralizeUnit: Executes the punishment when the timer runs out.
getPos, findIf, vehicle, isKindOf: Standard Arma 3 commands for positioning and checking vehicle types.
Dependencies: Relies on respawnTeamPlayer global variable (set by mission initialization) to define HQ location.
Network Implications: This is strictly local (client-side only). It does not sync data to the server.
2. fn_punishment_addActionForgive.sqf
Function Name: fn_punishment_addActionForgive.sqf What it does: Adds a scroll wheel action to an admin (or host) allowing them to forgive a specific detained player (detainee). It also prevents duplicate actions from being added to the same unit.

How it does that:

Parameter Validation: The function accepts the detainee's UID, their total offense count, and their name. It exits immediately if the offense total is less than 1, as there is no need to forgive if the player isn't detained.

Sqf

Apply
params ["_UID","_offenceTotal","_name"];
if (_offenceTotal < 1) exitWith {false};
Duplicate Prevention: It iterates through all existing actions on the local unit (the admin) to check if an action with the specific name format [Forgive FF] [Name] already exists.

Sqf

Apply
private _actionsSelf = actionIDs player;
private _alreadyHasAction = false;
private _actionName = [localize "STR_antistasi_actions_ff_forgive",_name,""] joinString """"; // Creating unique action name

if ((!isNil "_actionsSelf") && {!(_actionsSelf isEqualTo [])}) then {
    {
        if (((player actionParams _x)#0) isEqualTo _actionName) exitWith {
            _alreadyHasAction = true;
        };
    } forEach _actionsSelf;
};
Action Creation: If the action does not exist, it creates an action array. The code block checks if the caller is an admin (BIS_fnc_admin > 0) or the host server (isServer && hasInterface). Upon activation, it executes A3A_fnc_punishment_release remotely on the server (target 2) and removes the action from the local admin.

Sqf

Apply
if (!_alreadyHasAction) then {
    private _addAction_parameters = [
        _actionName,
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            if ([] call BIS_fnc_admin > 0 || isServer && hasInterface) then {
                [_arguments,"forgive"] remoteExecCall ["A3A_fnc_punishment_release",2,false];
            };
            player removeAction _actionId;
        },
        _UID,
        0.1
    ];
    player addAction _addAction_parameters;
};
Where it leads:

Calls:
A3A_fnc_punishment_release: Called remotely on the server to reset the sentence.
BIS_fnc_admin: Checks local admin state.
localize: For UI text.
Dependencies: Requires the STR_antistasi_actions_ff_forgive localized string.
Network Implications: The action is local to the admin. When executed, it triggers a networked call (remoteExecCall) to the server to apply the release logic.
3. fn_punishment_checkStatus.sqf
Function Name: fn_punishment_checkStatus.sqf What it does: This function runs on the server. It checks if a specific UID has an accumulated offense count of 1 or higher. If so, it retrieves the unit object associated with that UID and applies a punishment (likely starting a sentence). It clears the lastOffenceTime to reset depreciation before processing.

How it does that:

Validation: Checks if the punishment system (tkPunish) is enabled and if a valid UID was provided.

Sqf

Apply
if ((!tkPunish) || {_UID isEqualTo ""}) exitWith {false;};
Data Retrieval: Fetches the offenceTotal from the global punishment namespace A3A_FFPun. This namespace is a location object managed by A3A_fnc_getNestedObject.

Sqf

Apply
private _offenceTotal = [missionNamespace,"A3A_FFPun",_UID,"offenceTotal",0] call A3A_fnc_getNestedObject;
Execution Logic: If offenceTotal is 1 or greater:

It converts the UID back to a live unit object using BIS_fnc_getUnitByUid.
It verifies the unit is actually a player object.
It clears the lastOffenceTime (setting to nil) to prevent depreciation logic from reducing the time before punishment is applied.
It calls A3A_fnc_punishment to process the actual sentence logic.
Sqf

Apply
if (_offenceTotal >= 1) then {
    _instigator = [_UID] call BIS_fnc_getUnitByUid;
    if (!isPlayer _instigator) exitWith {};
    [missionNamespace,"A3A_FFPun",_UID,"lastOffenceTime",nil] call A3A_fnc_setNestedObject;
    [_instigator, 0, 0] call A3A_fnc_punishment;
};
Where it leads:

Calls:
A3A_fnc_getNestedObject: Accesses the A3A_FFPun hash structure.
BIS_fnc_getUnitByUid: Converts UID to object.
A3A_fnc_setNestedObject: Clears the depreciation timer.
A3A_fnc_punishment: The core punishment logic.
Dependencies: Relies on the A3A_FFPun namespace being populated (usually by A3A_fnc_punishment).
Network Implications: Must be executed on the server (target 2) to access the global namespace and valid player objects.
4. fn_punishment_evaluateEvent.sqf
Function Name: fn_punishment_evaluateEvent.sqf What it does: This is the decision engine for Friendly Fire (FF). It receives a reported FF event (damage or kill), validates if it meets the criteria for punishment (e.g., is the victim a rebel? Is the instigator a rebel? Is it a collision? Is the instigator an admin/vehicle type with immunity?), and then passes the judgement to A3A_fnc_punishment.

How it does that:

Parameter Parsing & Collision Detection: The first argument _instigator can be an object or an array [instigator, source]. If it's an array (typical for Hit events with collisions), the function determines if it's a vehicle collision. If it is, the actual unit causing damage is extracted from the array. The _isCollision flag is set for later logic.

Sqf

Apply
params [ ["_instigator",objNull, [objNull,[]], [] ], ... ];
private _isCollision = false;
if (_instigator isEqualType []) then {
    _isCollision = !(((_instigator#0) isEqualType objNull) && {isPlayer (_instigator#0)});
    _instigator = _instigator select _isCollision;
};
Basic Object Checks: Ensures the instigator is a valid, live player object. If not, it exits with a reason code (e.g., "AI", "NOT OBJECT").

Sqf

Apply
if (!(_instigator isEqualType objNull) || {isNull _instigator}) exitWith {"NOT OBJECT"};
if (!isPlayer _instigator) exitWith {"AI"};
Cool-down Mechanism: Checks a local variable A3A_FFPun_CD on the instigator. If it is greater than servertime, the function exits to prevent spamming (e.g., multi-hit damage in a single frame).

Sqf

Apply
if (_instigator getVariable ["A3A_FFPun_CD", 0] > servertime) exitWith {"PUNISHMENT COOL-DOWN ACTIVE"};
_instigator setVariable ["A3A_FFPun_CD", servertime + 1, false];
Logging: Prepares a detailed log string involving the instigator's name, UID, position relative to HQ, and grid reference. This is sent to the server log (RPT).

Exemption Checks: A series of switch statements determine if the event is valid FF.

Victim Specific: Checks if the victim is a Man (to ignore FF on empty vehicles), if the instigator and victim are in the same vehicle (accidental TK), or if the victim is not a rebel (counts as PvP, not FF).
Instigator Specific: Checks if FF is globally disabled (tkPunish), if the instigator is a Headless Client (HC), if the instigator is not a rebel, or if the instigator is AI.
Role/Unit Specific: Checks if the instigator is an Admin (local host), if the vehicle is an Air vehicle (CAS immunity), or if the vehicle is artillery (artillery immunity). If any exemption is found, it logs it and exits with the exemption string.
Sqf

Apply
if (!(_exemption isEqualTo "")) exitWith {
    format["NOT FF, %1", _exemption];
};
Collision Overrides: If the flag _isCollision was set, it overrides or adds specific punishment parameters (time added, offense added) and appends a custom message about the collision.

Sqf

Apply
if (_isCollision) then {
    _customMessage = [_customMessage,localize "STR_A3A_punishment_damaged_driver"] joinString "<br/>";
    _timeAdded = 27;
    _offenceAdded = 0.15;
};
Final Execution: If no exemptions apply and the collision logic (if any) is processed, it calls the core punishment function. Returns "PROSECUTED" if successful.

Sqf

Apply
[_instigator,_timeAdded,_offenceAdded,_victim,_customMessage] call A3A_fnc_punishment;
"PROSECUTED";
Where it leads:

Calls:
A3A_fnc_punishment: The actual penalty applier.
A3A_fnc_customHint: Notifies the instigator and victim.
ServerInfo/Info: Logging functions.
isPlayer, side, vehicle, configFile (CfgVehicles): Standard checks.
Dependencies: Requires tkPunish global variable, teamPlayer side definition, posHQ for distance calculation.
Network Implications: This function executes the notification logic (remote exec of hints) and passes the verdict to the punishment system. It relies on the event handlers calling it with correct [instigator, source] arrays.
5. fn_punishment_FF_AddEH.sqf
Function Name: fn_punishment_FF_AddEH.sqf What it does: Initializes the Friendly Fire monitoring system for a specific unit. It adds the necessary Event Handlers (Killed, Hit, Fired) to the unit to trigger the evaluation logic. It also handles ACE-specific events if present and checks the player's current punishment status.

How it does that:

Validation & Context Check: Checks if the punishment system is active (tkPunish). Determines if the target unit is AI (_isAI) to avoid adding fire event handlers to AI (which would cause performance issues and false positives). It only proceeds if the unit is AI and _addToAI is specifically requested.

Sqf

Apply
if (!tkPunish) exitWith {false};
if (!(_unit isKindOf "Man")) exitWith {false;};
private _isAI = !isPlayer _unit || !hasInterface || {!(_unit isEqualTo player)};
if (_isAI && !_addToAI) exitWith {true};
Adding Damage/Kill Handlers: Adds Killed and Hit Event Handlers to the unit. These handlers are the primary entry point for FF detection. They pack the _instigator and _source/_killer into an array and pass it to A3A_fnc_punishment_evaluateEvent on the server (target 2).

Sqf

Apply
_unit addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    [[_instigator,_killer], 60, 0.4, _unit] remoteExecCall ["A3A_fnc_punishment_evaluateEvent",2,false];
}];
Adding Fire Handlers (ACE vs Vanilla):

ACE: If A3A_hasACE is true, it uses CBA event handlers (ace_firedPlayer, ace_explosives_place, ace_throwableThrown) to detect weapon firing, explosive placement, and throwing. It calls A3A_fnc_punishment_FF_checkNearHQ (local check for HQ violations) and a remote execution for FF checks.
Vanilla: Adds the standard FiredMan event handler.
Sqf

Apply
if (A3A_hasACE) then {
    ["ace_firedPlayer", {
        params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];
        [_unit,_weapon,_projectile] call A3A_fnc_punishment_FF_checkNearHQ;
    }] call CBA_fnc_addEventHandler;
} else {
    _unit addEventHandler ["FiredMan", {
        params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
        [_unit,_weapon,_projectile] call A3A_fnc_punishment_FF_checkNearHQ;
    }];
};
Status Check: Immediately calls A3A_fnc_punishment_checkStatus on the server using the player's UID. This ensures that if the player was already punished (detained) and manages to respawn or reconnect, their status is re-validated.

Sqf

Apply
[getPlayerUID player] remoteExecCall ["A3A_fnc_punishment_checkStatus",2,false];
Where it leads:

Calls:
A3A_fnc_punishment_evaluateEvent: Receives the event data.
A3A_fnc_punishment_FF_checkNearHQ: Checks local HQ boundaries for grenades/explosives.
A3A_fnc_punishment_checkStatus: Verifies if the player should already be detained.
CBA_fnc_addEventHandler: Adds ACE-specific listeners.
Dependencies: Requires A3A_hasACE to be set (usually in initClient.sqf).
Network Implications:
Local: Adds handlers to the local unit.
Remote: Sends data to Server (2) for evaluation.
6. fn_punishment_FF_checkNearHQ.sqf
Function Name: fn_punishment_FF_checkNearHQ.sqf What it does: A purely client-side check to prevent the usage of grenades, explosives, or throws within 75 meters of Petros (the HQ unit). If the player attempts this, the projectile is deleted, and a heavy punishment is triggered remotely.

How it does that:

Weapon Check: Accepts _unit, _weapon, and _projectile. It only proceeds if the weapon type is "Put" (placed explosives) or "Throw" (grenades).

Sqf

Apply
if !(_weapon in ["Put","Throw"]) exitWith {false};
Distance Check: Calculates the distance between the unit and the global object petros. If the distance is greater than 75 meters, it exits.

Sqf

Apply
private _distancePetros = _unit distance petros;
if !(_distancePetros <= 75) exitWith {false};
Punishment Execution: If the checks pass (player is within range):

deleteVehicle _projectile: Removes the explosive/grenade immediately to prevent damage.
remoteExec: Sends a request to the server to execute A3A_fnc_punishment_evaluateEvent. It passes high punishment values (60 seconds, 0.4 offense) and a custom localized message explaining the violation.
Sqf

Apply
deleteVehicle _projectile;
[_unit, 60, 0.4, objNull, localize "STR_A3A_punishment_no_grenades"] remoteExec ["A3A_fnc_punishment_evaluateEvent",2,false];
Where it leads:

Calls:
A3A_fnc_punishment_evaluateEvent: Called remotely on the server to apply the sentence.
deleteVehicle: Standard Arma command.
Dependencies: Requires the global object petros to be present and valid.
Network Implications: Local execution to delete the projectile, remote execution to sync the penalty to the server.
7. fn_punishment_oceanGulag.sqf
Function Name: fn_punishment_oceanGulag.sqf What it does: Manages the physical representation of the punishment. It creates a "surfboard" (object) at a random corner of the map (100m from the world edges) and teleports the detainee to it. Conversely, it can remove the detainee and destroy the board.

How it does that:

Environment Check: Must run on the server to create objects and manage public variables.

Operation Selection ("add"):

Retrieves the player object and their current position from the A3A_FFPun namespace.
Checks if the player is already at the punishment area to prevent re-adding.
Adds the UID to the global array A3A_FFPun_Jailed (synced to all clients) so the punishment state is known everywhere.
Calculates a random 2D position [_pos2D] near the map corner (0,0 area).
Creates the "surfboard" object (Land_Sun_chair_green_F) at -0.25 meters height (underwater).
Detention: Moves the player out of any vehicle, detaches them from any current parent, and attaches them to the surfboard at Z offset 0.5.
Physics: Disables simulation and damage on the board so it doesn't move or break.
Sqf

Apply
private _pos2D = [random 100,random 100];
_platform = createVehicle ["Land_Sun_chair_green_F", [_pos2D #0, _pos2D #1, -0.25], [], 0, "CAN_COLLIDE"];
_platform enableSimulation false;
_platform allowDamage false;
// ... attachTo [_platform,[0, 0, 0.5]];
Operation Selection ("remove"):

Verifies the player is actually at the punishment location (checks area around 0,0).
Detaches the player and moves them back to their initialPosASL (saved before sending to gulag).
Deletes the surfboard object.
Removes the UID from A3A_FFPun_Jailed and syncs the variable.
Sqf

Apply
detach _detainee;
_detainee setVehiclePosition [_emptyPos, [], 0, "NONE"];
deleteVehicle _platform;
Where it leads:

Calls:
A3A_fnc_getNestedObject: Retrieves player data.
A3A_fnc_setNestedObject: Updates platform reference.
publicVariable: Syncs A3A_FFPun_Jailed.
Dependencies: Relies on A3A_FFPun namespace and A3A_FFPun_Jailed array.
Network Implications:
Modifies A3A_FFPun_Jailed which is a public variable. This array is often used by other systems (like map markers) to identify jailed players.

Function Name: fn_punishment_release.sqf
What it does: This function releases a detainee from Ocean Gulag (imprisonment) and forgives their punishment statistics. It is the primary server-side mechanism for clearing punishment records. It handles two main scenarios: standard release (handled by the punishment warden system) and administrative forgiveness (manual override). It also supports a "forgive" mode used by other systems to wipe stats without necessarily triggering immediate release if the user is already free.

How it does that:

Parameter Validation & Server Check:
Validates that the function is executed on the server.
Extracts the UID and source of the call (e.g., "punishment_warden", "forgive").
Variable Retrieval:
Fetches the nested object associated with the specific UID from missionNamespace at path A3A_FFPun.
Retrieves the player's name and object handle (if connected).
Helper Functions Definition:
_releaseFromSentence: Removes the "Forgive" action from all clients and removes the player from the Ocean Gulag system.
_forgiveStats: Wipes the specific punishment variables (timeTotal, offenceTotal, overhead, sentenceEndTime) for the user.
Switch Logic:
"punishment_warden": Calls both stats forgiveness and physical release. Logs the release and sends a hint to the detainee.
"punishment_warden_manual": Similar to above but logs as "FORGIVE" and sends a different hint (admin forgive).
"forgive": Sets sentenceEndTime to 0. This is typically used to clear the imprisonment flag if the player is already released, or to signal forgiveness without triggering the physical release logic (which is handled by the caller).
Default: Logs an error if an invalid source is provided.
Code Snippets:

Server Check & Initial Setup:

Sqf

Apply
if (!isServer) exitWith {
    Error("NOT SERVER");
    false;
};

private _varspace = [missionNamespace,"A3A_FFPun",_UID,locationNull] call A3A_fnc_getNestedObject;
private _name = _varspace getVariable ["name","NO NAME"];
private _detainee = _varspace getVariable ["player",objNull];
Helper Functions:

Sqf

Apply
private _releaseFromSentence = {
    [_name] remoteExecCall ["A3A_fnc_punishment_removeActionForgive",0,false];
    [_UID,"remove"] call A3A_fnc_punishment_oceanGulag;
};
private _forgiveStats = {
    private _varspace = [missionNamespace,"A3A_FFPun",_UID,"timeTotal",nil] call A3A_fnc_setNestedObject;
    _varspace setVariable ["offenceTotal",nil];
    _varspace setVariable ["overhead",nil];
    _varspace setVariable ["sentenceEndTime",nil];
};
Execution Switch:

Sqf

Apply
switch (_source) do {
    case "punishment_warden": {
        call _forgiveStats;
        call _releaseFromSentence;
        Info_1("RELEASE | %1", _playerStats);
        if (isPlayer _detainee) then {
            [localize "STR_A3A_punishment_FF_header", localize "STR_A3A_punishment_enough"] remoteExecCall ["A3A_fnc_customHint", _detainee, false];
        };
        true;
    };
    case "forgive": {
        [missionNamespace,"A3A_FFPun",_UID,"sentenceEndTime",0] call A3A_fnc_setNestedObject;
        true;
    };
    // ... other cases ...
};
Where it leads:

Calls A3A_fnc_getNestedObject: Retrieves the punishment data object for the specified UID.
Calls A3A_fnc_setNestedObject: Updates the timeTotal and sentenceEndTime in the data structure.
Calls A3A_fnc_punishment_removeActionForgive: (Via remoteExecCall) Updates all clients to remove the scroll action allowing admins to forgive this player.
Calls A3A_fnc_punishment_oceanGulag: (Via remoteExecCall or local call) Modifies the player's state (e.g., moves them out of the gulag area).
Called By: A3A_fnc_punishment_sentence_server (upon timer expiration), A3A_fnc_punishment (for self-forgive), or direct admin command.
System Fit: Part of the Punishment subsystem. It cleans up data and visual indicators (actions) associated with a guilty player.
Global Variables: Modifies nested variables within missionNamespace under A3A_FFPun.
Function Name: fn_punishment_removeActionForgive.sqf
What it does: Removes a specific scroll-wheel action ("[Forgive FF] PlayerName") from the player's local action menu. This runs on all clients to ensure that if a detainee is released or forgiven, the "Forgive" action disappears from the admin's scroll menu immediately.

How it does that:

Parameter Reception: Receives the _name of the detainee.
Action Scanning: Retrieves the list of action IDs currently attached to the local player.
Identification: Iterates through all actions. For each action, it retrieves the action's title string.
Comparison: Checks if the action title matches the expected format: "[Forgive FF] " + _name.
Removal: If a match is found, it removes that specific action ID from the player and exits the loop immediately.
Code Snippets:

Parameter & Action Retrieval:

Sqf

Apply
params ["_name"];
private _actionsSelf = actionIDs player;
Iteration & Matching:

Sqf

Apply
if ((!isNil "_actionsSelf") && {!(_actionsSelf isEqualTo [])}) then {
    private _actionName = ["[Forgive FF] ",_name,""] joinString """"; // Note: The code uses joinString """" which is likely a bug, but we document as written.
    {
        if (((player actionParams _x)#0) isEqualTo _actionName) exitWith {
            player removeAction _x;
        };
    } forEach _actionsSelf;
};
Note: The use of joinString """" in the source code is unusual (usually empty string ""). It suggests the action name might be constructed with quotes in the title, or it is a typo in the original source. The logic relies on exact string matching.

Where it leads:

Calls: None directly (standard SQF commands used).
Called By: A3A_fnc_punishment_release (when a player is released).
System Fit: Client-side UI management for the Punishment system. It ensures the "Forgive" UI element is dynamic and responsive to server-side state changes.
Network Implications: Executed on specific targets (admins) via remoteExecCall from the server. It does not communicate back to the server.
Function Name: fn_punishment_sentence_client.sqf
What it does: Displays a countdown timer notification to the detained player, indicating how much time is left in their sentence. It runs on the client (the detained player) to utilize local processing power for the UI loop.

How it does that:

Parameter Validation: Receives the _detainee object and _timeLeft.
Safety Minimum: Enforces a minimum time of 5 seconds if the passed time is lower (preventing instant return if sync issues occur).
Countdown Loop: Iterates 5 times (stepping down by 1).
Continuity Check: Checks isPlayer _detainee every iteration to abort if the player disconnects or dies.
UI Update: Calls A3A_fnc_customHint to display a localized message with the remaining time.
Pause: Uses uiSleep 1 to pause execution for 1 second without freezing the game UI.
Code Snippets:

Setup & Safety Check:

Sqf

Apply
params ["_detainee","_timeLeft"];
if (_timeLeft < 5) then {_timeLeft = 5;};
Countdown Loop:

Sqf

Apply
for "_timeLeft" from _timeLeft to _timeLeft-4 step -1 do {
    if (!isPlayer _detainee) exitWith {false};
    [localize "FF Punishment", format [localize "STR_A3A_punishment_client_notification",_timeLeft], true] call A3A_fnc_customHint;
    uiSleep 1;
};
true;
Where it leads:

Calls A3A_fnc_customHint: Renders the UI notification box.
Called By: A3A_fnc_punishment_sentence_server (executed remotely on the detainee).
System Fit: The visual feedback mechanism of the Punishment system. It ensures the player knows their status.
Network Implications: Executed locally on the client. No network traffic generated during execution.
Function Name: fn_punishment_sentence_server.sqf
What it does: This is the core server-side controller for a player's imprisonment. It initializes the sentence, manages the timer loop, handles admin actions (adding/removing the "Forgive" scroll action), syncs the timer to the client, and performs the release when the time expires.

How it does that:

Initialization: Rounds the sentence time to the nearest 5 seconds. Calculates the sentenceEndTime based on serverTime.
Data Storage: Saves the sentence details into the A3A_FFPun nested object for the specific UID.
Spawned Loop: Spawns a separate thread (unscheduled execution context) to manage the sentence duration.
Continuity Check: Verifies the player is still connected (isPlayer _detainee).
Admin Monitoring: Fetches the current admin (A3A_fnc_getAdmin) every loop iteration.
Admin Change Detection: If the admin changes:
Removes the "Forgive" action from the previous admin.
If a new admin exists (and isn't the detainee), sends a notification and adds the "Forgive" action to the new admin.
Sync to Client: Every 5 seconds, it calculates remaining time and calls A3A_fnc_punishment_sentence_client on the detainee.
Ocean Gulag Management: Calls A3A_fnc_punishment_oceanGulag to keep the player in the gulag (e.g., preventing escape).
Polling: Updates the sentenceEndTime from the global variable in case it was modified by an admin (e.g., reducing time).
Termination:
Disconnect/Die: If the loop exits because the player is gone, logs the event and removes them from the gulag.
Timer Expired: Calls A3A_fnc_punishment_release with the appropriate source ("punishment_warden" if time expired normally, "punishment_warden_manual" if admin reduced time to zero).
Code Snippets:

Initialization:

Sqf

Apply
_timeTotal = 5*(floor (_timeTotal/5));
private _sentenceEndTime = (floor serverTime) + _timeTotal;
private _varspace = [missionNamespace,"A3A_FFPun",_UID,"sentenceEndTime",_sentenceEndTime] call A3A_fnc_setNestedObject;
Admin Monitoring & Action Management:

Sqf

Apply
_admin = [] call A3A_fnc_getAdmin;
if !(_admin isEqualTo _lastAdmin) then {
    if (!isNull _lastAdmin) then {
        [_name] remoteExecCall ["A3A_fnc_punishment_removeActionForgive",_lastAdmin,false];
    };
    if (!isNull _admin) then {
        if (_admin isEqualTo _detainee) exitWith { [_UID,"forgive"] call A3A_fnc_punishment_release; };
        [localize "STR_A3A_punishment_FF_header", [_name,localize "STR_A3A_punishment_guilty"] joinString ""] remoteExecCall ["A3A_fnc_customHint",_admin,false];
        [_UID,[missionNamespace,"A3A_FFPun",_UID,"offenceTotal",0] call A3A_fnc_getNestedObject,_name] remoteExecCall ["A3A_fnc_punishment_addActionForgive",_admin,false];
    };
    _lastAdmin = _admin;
};
Timer Loop & Sync:

Sqf

Apply
while {(ceil serverTime) < _sentenceEndTime-1} do {
    // ... admin checks ...
    [_detainee,_sentenceEndTime - (floor serverTime)] remoteExec ["A3A_fnc_punishment_sentence_client",_detainee,false];
    [_UID,"add"] call A3A_fnc_punishment_oceanGulag;
    uiSleep 5;
    _sentenceEndTime = [missionNamespace,"A3A_FFPun",_UID,"sentenceEndTime",floor serverTime] call A3A_fnc_getNestedObject;
};
Release Logic:

Sqf

Apply
if (_disconnected) then {
    // Log disconnect
    [_UID,"remove"] call A3A_fnc_punishment_oceanGulag;
} else {
    [_UID,["punishment_warden_manual","punishment_warden"] select (_sentenceEndTime_old isEqualTo _sentenceEndTime)] call A3A_fnc_punishment_release;
};
Where it leads:

Calls A3A_fnc_getNestedObject: Retrieves current sentence time (for polling).
Calls A3A_fnc_setNestedObject: Initializes sentence data.
Calls A3A_fnc_getAdmin: Identifies the server admin.
Calls A3A_fnc_punishment_addActionForgive: Adds scroll action to admin.
Calls A3A_fnc_punishment_removeActionForgive: Removes scroll action from admin.
Calls A3A_fnc_punishment_sentence_client: Updates the detainee's UI.
Calls A3A_fnc_punishment_oceanGulag: Enforces the physical location/status of the detainee.
Calls A3A_fnc_punishment_release: Ends the sentence.
Called By: A3A_fnc_punishment (when an offender is sentenced).
System Fit: The heart of the imprisonment mechanism. It bridges the physical gulag, the UI timer, and admin controls.
Function Name: fn_punishment.sqf
What it does: Evaluates a Friendly Fire (FF) event, calculates punishment severity (time and offence level), updates statistics, notifies relevant players, and triggers imprisonment if the offence threshold is met. It also handles the special case where a player is remote-controlling a unit (UAV/Drone) and ensures punishment applies to the original body.

How it does that:

Parameter & Context Retrieval: Gets instigator, time added, offence added, victim. Determines the _originalBody (the unit the player is actually controlling).
Data Retrieval: Fetches current stats (timeTotal, offenceTotal, overhead, lastOffenceTime) for the instigator's UID.
Data Validation: Clamps all values to valid ranges (e.g., offenceTotal max 2, ensures time doesn't go negative).
Punishment Calculation:
Calculates time elapsed since last offence (_periodDelta).
Applies depreciation to old offences (offences become less severe over time if the player behaves).
Updates the overhead (a buffer that accumulates and prevents instant punishment for minor offenses).
Updates offenceTotal and timeTotal with new additions.
Data Persistence: Saves the new stats back to the nested object.
Notifications:
Notifies the victim.
Logs the event (Info).
Notifies the instigator with detailed stats.
Threshold Check: If offenceTotal < 1, returns "WARNING" (just a warning log, no imprisonment).
Imprisonment Trigger:
Direct Control: If the instigator is their own body, calls A3A_fnc_punishment_sentence_server immediately.
Remote Control (UAV): If the instigator is a drone/UAV:
Returns control to the original body.
Spawns a loop that waits for the player to re-occupy their original body.
Once re-occupied, calls A3A_fnc_punishment_sentence_server.
Code Snippets:

Punishment Calculation (Depreciation & Addition):

Sqf

Apply
private _periodDelta = _currentTime - _lastTime;
_offenceTotal = _offenceTotal - _overhead;
_overhead = (_overhead + _offenceAdded * _overheadPercent) min 1;

// Exponential decay formula
_offenceTotal = _offenceTotal * (1-_depreciationCoef*(1-(_offenceTotal))) ^(_periodDelta/300);

_offenceTotal = (_offenceTotal + _offenceAdded * (1-_overheadPercent)) min 1;
_offenceTotal = _offenceTotal + _overhead;
_timeTotal = _timeTotal * (1-_depreciationCoef) ^(_periodDelta/3000);
_timeTotal = _timeTotal + _timeAdded;
Remote Control Handling (UAV Logic):

Sqf

Apply
if (_instigator isEqualTo _originalBody) then {
    [_UID,_timeTotal] spawn A3A_fnc_punishment_sentence_server;
} else {
    // Return control logic
    (units group _originalBody) joinSilent group _originalBody;
    group _instigator selectLeader _originalBody;
    [localize "STR_A3A_punishment_unitcontrol", ...] remoteExecCall ["A3A_fnc_customHint",_instigator,false];
    [_originalBody] remoteExec ["selectPlayer",_instigator,false];

    [_instigator,_originalBody,_UID,_timeTotal,_name,_customMessage] spawn {
        params ["_instigator","_originalBody","_UID","_timeTotal","_name","_customMessage"];
        private _timeOut = serverTime + 20;
        waitUntil {isPlayer _originalBody || _timeOut < serverTime};
        if !(isPlayer _originalBody) exitWith { /* Timeout error */ };
        [_UID,_timeTotal] call A3A_fnc_punishment_sentence_server;
    };
};
Where it leads:

Calls A3A_fnc_getNestedObject / A3A_fnc_setNestedObject: Manages punishment stats.
Calls A3A_fnc_customHint: Notifies players.
Calls A3A_fnc_punishment_sentence_server: Initiates imprisonment.
Called By: A3A_fnc_punishment_evaluateEvent (the detector of FF events).
System Fit: The decision logic for the Punishment system. It translates raw FF events into statistical penalties and state changes.
Global Variables: Updates A3A_FFPun nested variables.
Network Implications: Uses remoteExecCall to notify victims and instigators. Uses remoteExec to transfer control back to the original body if necessary.