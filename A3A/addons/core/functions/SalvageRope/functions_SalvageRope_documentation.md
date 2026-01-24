Documentation for 
fn_salvageRope.sqf
 Functions
This file contains the core functionality for the Salvage Rope system, which allows players to deploy a winch rope from a ship, attach it to underwater salvage crates, and load them onto the ship. The system includes deploy, stow, attach, and load operations, with associated condition checks and cleanup logic.

A3A_SR_canDeployWinch
Function Name: A3A_SR_canDeployWinch (defined within 
fn_salvageRope.sqf
)

What it does: This function checks if a player can deploy a winch rope. It serves as the condition predicate for the "Deploy Winch" action menu entry. It ensures the player meets specific criteria: they must be on foot, within 10 meters of a valid ship, that ship must not already have a winch deployed, and the ship must be able to load a specific cargo type (boxX).

How it does that:

Parameter Validation & Variable Initialization: The function takes no parameters. It initializes a local variable _vehicle by retrieving the object the player is currently looking at (cursor target).

Sqf

Apply
private _vehicle = cursorTarget;
Primary Logic & Type Check: It first checks if the _vehicle is a ship ("Ship"). This is the main gate for the entire action's viability. If the target is not a ship, the function immediately returns false.

Sqf

Apply
if (_vehicle isKindOf "Ship") then {
Condition Chain (Within the then block): Inside the then block, a compound boolean expression is evaluated. All conditions must be true for the function to return true.

vehicle player == player: Ensures the player is not inside any vehicle (including helicopters, boats, etc.).
player distance _vehicle < 10: Ensures the player is within a 10-meter radius of the ship.
isNil {_vehicle getVariable "WinchRope"}: Checks if the ship has a WinchRope variable set. isNil returns true if the variable does not exist, meaning no rope is currently deployed.
!([_vehicle, boxX] call A3A_Logistics_fnc_canLoad isEqualTo -7): This is a critical logistics check. It calls the external function A3A_Logistics_fnc_canLoad to see if the ship (_vehicle) can load the designated salvage crate class (boxX). The result is compared to -7, which presumably indicates "cannot load". The ! negates this, so the condition is true if the ship CAN load the cargo.
Sqf

Apply
vehicle player == player && player distance _vehicle < 10 && isNil {_vehicle getVariable "WinchRope"} && !([_vehicle, boxX] call A3A_Logistics_fnc_canLoad isEqualTo -7);
Final Return: If the target is a ship and all conditions pass, the function returns true. Otherwise (if target is not a ship, or any condition fails), it returns false.

Where it leads:

Calls:
A3A_Logistics_fnc_canLoad: This is the primary dependency. It's called with parameters [_vehicle, boxX] to check the ship's cargo capacity against the specific salvage crate class. Its return value is crucial for the deployment condition.
Depends on:
cursorTarget: Relies on the game engine's cursorTarget variable.
player: Relies on the global player object.
boxX: This is a global variable (likely defined in a parent script or Cfg file) that specifies the class name of the salvage crate.
Fits into Larger System: This is the first gate in the salvaging workflow. It prevents deployment on invalid targets (non-ships, over capacity, already equipped) and ensures the player is in a suitable position. It's used to conditionally show the "Deploy Winch" action in the player's action menu.
Global Variables Modified: None.
Network/Code Synchronization: None. It's a purely local client-side check. No remote execution is performed.
A3A_SR_DeployWinch
Function Name: A3A_SR_DeployWinch (defined within 
fn_salvageRope.sqf
)

What it does: This function executes the deployment of the winch rope from a ship to the player. It creates a physical rope between the ship and a hidden helper object attached to the player, sets necessary variables on the ship and player, and initiates the rope adjustment loop.

How it does that:

Parameter Validation & Exit Condition: It accepts one parameter, _player, which should be the player object. It first checks if the player is captive (undercover). If so, it ends their captive status. This is likely a gameplay choice to prevent undercover players from using obvious mechanical tools.

Sqf

Apply
if (captive player) then {player setCaptive false};
params ["_player"];
Variable Initialization: It retrieves the target ship from the cursor and creates a hidden helper object ("Land_Can_V1_F"). This helper is essential as an intermediate anchor point for the rope and for tracking the player's hand position.

Sqf

Apply
private _vehicle = cursorTarget;
private _helper = "Land_Can_V1_F" createVehicle [random 100,random 100, random 100];
Helper Configuration: The helper is made globally invisible to avoid visual glitches and is attached to the player's "pelvis" bone. This ensures it follows the player's movement and orientation, simulating a winch gun.

Sqf

Apply
_helper hideObjectGlobal true;
_helper attachTo [_player,[0,0.1,0], "pelvis"];
Rope Creation & Variable Assignment:

A rope is created using ropeCreate, linking the ship's bow/stern point ([0,-2.8,-0.8]) to the helper's position ([0,0,0]).
The rope object is stored in the ship's WinchRope variable, set to true for public (global) network synchronization. This makes the rope state known to all clients.
The helper object is stored in the ship's WinchHelper variable, also public.
The helper is also stored in the player's WinchHelperObj variable, making it easily accessible later.
Sqf

Apply
_vehicle setVariable ["WinchRope", (ropeCreate [_vehicle, [0,-2.8,-0.8], _helper, [0,0,0], 10]), true];
_vehicle setVariable ["WinchHelper", _helper, true];
player setVariable ["WinchHelperObj", _helper];
Initiate Adjustment Loop: The function calls A3A_SR_adjustRope to start a monitor loop that will dynamically adjust the rope length based on player-ship distance, keeping it taut and within bounds.

Sqf

Apply
[_player, _vehicle] call A3A_SR_adjustRope;
Where it leads:

Calls:
A3A_SR_adjustRope: The core maintenance function. This is a blocking call (it contains a while loop with sleep), meaning execution will pause here until the rope is destroyed or the player detaches. The player cannot perform other actions while this loop is active.
Depends on:
cursorTarget: Relies on the player's current look target.
ropeCreate: Game engine function.
setCaptive: Game engine function.
setVariable: Game engine function for object variable storage.
Fits into Larger System: This is the execution step following a successful A3A_SR_canDeployWinch check. It initializes the physical and data state of the deployed winch system. The WinchRope, WinchHelper, and WinchHelperObj variables are the cornerstone data structures for the entire salvaging process, used by all subsequent functions (stow, attach, cleanHelper, adjustRope).
Global Variables Modified:
Ship (_vehicle):
WinchRope (public): Stores the rope object.
WinchHelper (public): Stores the helper object.
Player (player):
WinchHelperObj: Stores the helper object (local to player).
Captive Status: Player's captive state is modified.
Network/Code Synchronization: Significant synchronization is involved. The WinchRope and WinchHelper variables are set to true for public broadcasting, ensuring all players on the same server see the rope's existence. The helper is hidden globally. The rope itself is a network-synchronized object.
A3A_SR_cleanHelper
Function Name: A3A_SR_cleanHelper (defined within 
fn_salvageRope.sqf
)

What it does: This function performs cleanup of the winch system's helper object and associated variables. It detaches the helper, deletes it, and clears the WinchHelper variable from the ship and the WinchHelperObj variable from the player.

How it does that:

Parameter Validation: It expects two parameters: _helper (the object to clean up) and _vehicle (the ship it's associated with). It also retrieves the player object attached to the helper (if any) for cleanup of the player's variable.

Sqf

Apply
params ["_helper", "_vehicle"];
private _player = attachedTo _helper;
Object Detachment & Deletion: It detaches the helper from whatever it's attached to (usually the player) and then deletes the helper object from the game world.

Sqf

Apply
detach _helper;
deleteVehicle _helper;
Variable Cleanup:

It clears the WinchHelper variable from the ship (_vehicle). This is a critical step for the state machine.
It clears the WinchHelperObj variable from the player (_player). This ensures the player's reference is also cleaned up.
Sqf

Apply
_vehicle setVariable ["WinchHelper", nil];
_player setVariable ["WinchHelperObj", nil];
Where it leads:

Calls: None directly in this function.
Depends on:
detach: Game engine function.
deleteVehicle: Game engine function.
setVariable: Game engine function.
Fits into Larger System: This is a utility function called by multiple other functions (A3A_SR_stowRope, A3A_SR_attachRope, and A3A_SR_adjustRope) to perform the common task of cleaning up the helper object and its associated variables. It's essential for preventing memory leaks and leaving stale data.
Global Variables Modified:
Ship (_vehicle): WinchHelper variable is removed.
Player (_player): WinchHelperObj variable is removed.
Network/Code Synchronization: Removing the WinchHelper variable on the ship is a local action unless the variable was public. Since it was set with setVariable ["WinchHelper", _helper, true] during deployment, the cleanup here (without true) only affects the local machine. A full public cleanup would require _vehicle setVariable ["WinchHelper", nil, true]. The helper's global deletion and position change are network-synchronized.
A3A_SR_adjustRope
Function Name: A3A_SR_adjustRope (defined within 
fn_salvageRope.sqf
)

What it does: This function runs a continuous loop that monitors the player-ship distance and dynamically adjusts the winch rope's length to keep it within optimal bounds (neither too loose nor too tight). It also handles termination conditions and cleanup when the winch system is broken (player death, helper destruction, rope detachment).

How it does that:

Parameter & State Initialization: It takes the _player and _vehicle as parameters. It retrieves the current rope object and helper object from the ship's variables. This defines the starting state of the monitoring loop.

Sqf

Apply
params ["_player", "_vehicle"];
private _rope = _vehicle getVariable "WinchRope";
private _helper = _vehicle getVariable ["WinchHelper", objNull];
Main Monitoring Loop: The core is a while loop that continues as long as the helper is attached to something and the entity that helper is attached to (the player) is alive.

Sqf

Apply
while {!isNull ropeAttachedTo _helper && alive attachedTo _helper} do {
Distance Calculations (Inside Loop):

Calculates the current straight-line distance between the ship and the player (_dist).
Calculates an "optimal" rope length, which is the current distance plus 3 meters. This provides slack.
Calculates a "max" rope length, which is the current distance plus 7 meters. This defines an upper bound for adjustment.
These values create a "hysteresis" buffer zone; the rope won't constantly re-adjust for tiny distance changes.
Sqf

Apply
private _dist = _vehicle distance _player;
private _optimalDist = _dist + 3;
private _maxDist = _dist + 7;
Rope Adjustment Logic: It checks the rope's current length against the calculated bounds:

If the rope is shorter than the straight-line distance (< _dist), it's "over-wound" or too tight. It unwinds the rope to the optimal distance at a speed of 10 m/s.
If the rope is longer than the max distance (> _maxDist), it's too loose. It also unwinds to the optimal distance.
The ropeUnwind function is used for both tightening and loosening, controlling the rope's length.
Sqf

Apply
if ((ropeLength _rope) < _dist) then {
    ropeUnwind [_rope, 10, _optimalDist];
} else {
    if ((ropeLength _rope) > _maxDist) then {
        ropeUnwind [_rope, 10, _optimalDist];
    };
};
Loop Throttling: The loop sleeps for 0.1 seconds to prevent excessive CPU usage. This means the rope length is checked and adjusted roughly 10 times per second.

Sqf

Apply
sleep 0.1;
Termination & Cleanup: The loop terminates when the helper is no longer attached or the attached entity (player) dies. After the loop ends, it checks if the helper still exists (alive _helper). If it does, it means the loop ended due to player death or rope detachment, not the helper being deleted. In this case, it performs a full cleanup:

Calls A3A_SR_cleanHelper to remove the helper and its variables.
Destroys the rope object using ropeDestroy.
Removes the WinchRope variable from the ship.
Sqf

Apply
if (alive _helper) then { //vehicle destroyed, rope broken or player died
    [_helper, _vehicle] call A3A_SR_cleanHelper;
    ropeDestroy (_vehicle getVariable "WinchRope");
    _vehicle setVariable ["WinchRope", nil, true];
};
Where it leads:

Calls:
A3A_SR_cleanHelper: Called for cleanup if the loop terminates abnormally.
ropeUnwind: Game engine function for adjusting rope length.
ropeAttachedTo, attachedTo, ropeLength, alive: Game engine functions for state queries.
ropeDestroy: Game engine function to delete the rope.
Depends on:
The WinchRope and WinchHelper variables set by A3A_SR_DeployWinch.
The attachedTo state of the helper, which is set by the player's physical action (moving) or the A3A_SR_attachRope function.
Fits into Larger System: This is the core maintenance system for an active winch. It ensures the rope behaves as a dynamic, physics-aware tether rather than a static line. It's the reason the salvage rope feels interactive. Its termination triggers the end of the salvaging operation for that rope.
Global Variables Modified:
Ship (_vehicle): WinchRope variable is set to nil (public true).
The loop itself does not modify variables; it only queries them and calls engine functions.
Network/Code Synchronization: The ropeUnwind and ropeDestroy calls are network-synchronized actions. The WinchRope variable removal with true broadcasts this change, signaling to all clients that the rope is gone.
A3A_SR_canStow
Function Name: A3A_SR_canStow (defined within 
fn_salvageRope.sqf
)

What it does: This function checks if a player can stow (retract and store) the winch rope. It ensures the player is on foot, close to the ship, a rope is deployed, and the player is either the one using the rope or the rope is free (helper not attached to a living player).

How it does that:

Target & Initial State Check: It gets the player's cursor target (_vehicle). It first validates that the target exists and that a winch rope is actually deployed (by checking for the WinchRope variable). If these fail, it exits early with false.

Sqf

Apply
private _vehicle = cursorTarget;
if (isNull _vehicle) exitWith {false};
if (isNull (_vehicle getVariable ["WinchRope", objNull])) exitWith {false};
Helper & Player State Check: It retrieves the helper object from the ship. If the helper is null, it exits, as this indicates a state mismatch (e.g., in the middle of an attach operation or after deployment failure). It then finds out who, if anyone, is currently attached to the helper (_attachedPlayer).

Sqf

Apply
private _helper = _vehicle getVariable ["WinchHelper", objNull];
if (isNull _helper) exitWith {false};
private _attachedPlayer = attachedTo _helper;
Final Compound Condition: It evaluates four conditions:

vehicle player == player: Player is on foot.
player distance _vehicle < 10: Player is within 10m of the ship.
(!alive _attachedPlayer || player == _attachedPlayer): This is the key stow logic. It allows stowing if either the player attached to the helper is dead (!alive _attachedPlayer) or the current player is the one who is attached (player == _attachedPlayer). This prevents a different player from stowing a rope that's actively being used by another living player.
Sqf

Apply
vehicle player == player && player distance _vehicle < 10 && (!alive _attachedPlayer || player == _attachedPlayer);
Where it leads:

Calls: None directly.
Depends on:
WinchRope and WinchHelper variables set by A3A_SR_DeployWinch.
attachedTo on the helper object.
cursorTarget, player global objects.
Fits into Larger System: This is the condition function for the "Stow Winch" action menu entry. It's the safety gate that allows players to clean up their own winch or clean up after a deceased player, but prevents griefing where another player could steal or interfere with an active winch operation.
Global Variables Modified: None.
Network/Code Synchronization: Relies on public variables (WinchRope, WinchHelper) and the synchronized state of the helper object. It's a local check.
A3A_SR_stowRope
Function Name: A3A_SR_stowRope (defined within 
fn_salvageRope.sqf
)

What it does: This function executes the stowing process: it cleans up the helper object and its variables, destroys the rope, and clears the winch state from the ship.

How it does that:

Parameter Validation: It accepts the _player parameter. It then retrieves the target ship from the cursor and the helper object from the ship's variables.

Sqf

Apply
params ["_player"];
private _vehicle = cursorTarget;
private _helper = _vehicle getVariable ["WinchHelper", objNull];
Execution of Cleanup: It calls A3A_SR_cleanHelper to perform the helper deletion and variable cleanup.

Sqf

Apply
[_helper, _vehicle] call A3A_SR_cleanHelper;
Rope Destruction & State Reset:

It destroys the physical rope object.
It removes the WinchRope variable from the ship, publicly (true), to signal the winch is no longer deployed.
Sqf

Apply
ropeDestroy (_vehicle getVariable "WinchRope");
_vehicle setVariable ["WinchRope", nil, true];
Where it leads:

Calls:
A3A_SR_cleanHelper: To perform the detailed cleanup.
ropeDestroy: Game engine function.
Depends on:
WinchRope and WinchHelper variables.
cursorTarget.
Fits into Larger System: This is the action executor for the "Stow Winch" menu entry. It transitions the ship's state from "rope deployed" to "no rope." It's the logical conclusion of a salvaging operation or the active termination of one.
Global Variables Modified:
Ship (_vehicle): WinchRope variable is removed (publicly). WinchHelper is cleaned up by the called function.
Player (player): WinchHelperObj is cleaned up by the called function.
Network/Code Synchronization: The ropeDestroy call is network-synchronized. The setVariable with true broadcasts the removal of WinchRope to all clients.
A3A_SR_LoadSalvage
Function Name: A3A_SR_LoadSalvage (defined within 
fn_salvageRope.sqf
)

What it does: This function attempts to load a specified cargo object onto a vehicle using the logistics system. It performs a capacity check and, if valid, initiates the loading process. It provides feedback to the player and handles errors (e.g., insufficient space).

How it does that:

Parameter Validation & Notification: It takes two parameters: _vehicle and _cargo. It immediately sends a localized system chat message to the player, informing them that the loading process has started. This is executed via remoteExec, so it's likely run on the server and broadcast to the client.

Sqf

Apply
params ["_vehicle", "_cargo"];
[(localize "STR_antistasi_schat_loading_cargo")] remoteExec ["systemChat"];
Capacity Check: It calls the external function A3A_Logistics_fnc_canLoad to check if the vehicle can load the cargo. The result (_return) is stored.

Sqf

Apply
_return = [_vehicle, _cargo] call A3A_Logistics_fnc_canLoad;
Error Handling: It checks if the _return is of type 0. If it is, it indicates a failure (likely an error code). It then constructs a detailed error message:

Extracts the display name of the cargo (_object—note: there's a potential bug here; it uses _object which isn't defined in the function's scope. It should probably be _cargo).
Extracts the display name of the vehicle (_vehicle).
Uses the A3A_fnc_customHint function to display the error message to the remote client (the player).
Sqf

Apply
if (_return isEqualType 0) exitWith {
    private _cargoName = getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName");
    private _vehicleName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
    [localize "STR_A3A_Logistics_header", format [localize "STR_A3A_Logistics_tryLoad_not_enough_space", _vehicleName, _cargoName]] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner];
};
Successful Load Initiation: If the check passes (or if _return is not 0, indicating success), the function spawns the actual loading routine. It calls A3A_Logistics_fnc_load with the _return value, which is the logistics system's internal representation of the load task.

Sqf

Apply
_return spawn A3A_Logistics_fnc_load;
Where it leads:

Calls:
A3A_Logistics_fnc_canLoad: To check capacity. Returns a value (0 for error, other data structure for success).
A3A_fnc_customHint: For error message display.
A3A_Logistics_fnc_load: The core function that executes the loading animation and moves the cargo. Called via spawn to run asynchronously.
remoteExec: For network communication of chat and hint messages.
Depends on:
The external A3A_Logistics system.
The remoteExecutedOwner global variable for targeting the correct client with hints.
_object in the error message (a likely bug where _cargo should be used).
Fits into Larger System: This is the final step in the salvage rope workflow. After the attach operation creates the rope and positions the cargo, this function is called (via remote execution) to move the cargo from the water onto the ship's inventory. It's the bridge between the SalvageRope subsystem and the core Logistics system.
Global Variables Modified: None.
Network/Code Synchronization: Highly network-intensive. It's designed to be called remotely. It sends a system chat, potentially sends a custom hint to a specific owner, and spawns the logistics load function (which itself manages network synchronization for the cargo movement).
A3A_SR_canAttach
Function Name: A3A_SR_canAttach (defined within 
fn_salvageRope.sqf
)

What it does: This function checks if a player can attach the winch rope to an underwater salvage crate. It validates that the target is a valid "SalvageCrate," is underwater, is within range, and the player has an active winch rope.

How it does that:

Parameter & Target Validation: It gets the cursor target (_cargo). It checks if the target is null or if it lacks the SalvageCrate variable (or if that variable is false). These conditions immediately return false.

Sqf

Apply
_cargo = cursorTarget;
if (isNull _cargo) exitWith {false};
if !(_cargo getVariable ["SalvageCrate", false]) exitWith {false};
Underwater Check: It gets the "above water" height of the cargo (_cargo#2 from getPosASLW). If this value is greater than 0, the cargo is above water, and the function returns false. This restricts attachment to submerged objects.

Sqf

Apply
if ((getPosASLW _cargo#2)>0) exitWith {false};
Proximity & Active Rope Check: It retrieves the helper object from the player's WinchHelperObj variable. It then verifies two final conditions:

player distance _cargo <= 13: Player must be within 13 meters of the cargo.
!isNull(ropeAttachedTo _helper): The helper must have a rope attached to it (i.e., the winch is deployed).
Sqf

Apply
private _helper = player getVariable ["WinchHelperObj", objNull];
player distance _cargo <= 13 && !isNull(ropeAttachedTo _helper);
Where it leads:

Calls: None directly. Calls getPosASLW and ropeAttachedTo (game engine functions).
Depends on:
A3A_SR_DeployWinch having set WinchHelperObj on the player.
The SalvageCrate variable being set on target objects (likely done by a mission system or mission init).
cursorTarget, player globals.
Fits into Larger System: This is the condition function for the "Attach Winch" action menu entry. It defines the precise, tactical conditions for the salvaging operation: targeting submerged crates, ensuring the player has the tool ready (deployed winch), and being in close range for manual operation.
Global Variables Modified: None.
Network/Code Synchronization: Relies on synchronized state (helper variables, crate variables). Local check.
A3A_SR_attachRope
Function Name: A3A_SR_attachRope (defined within 
fn_salvageRope.sqf
)

What it does: This function executes the core salvaging operation. It detaches the rope from the player, attaches it to a submerged salvage crate, winches the crate up to the ship, and then initiates the load process.

How it does that:

Variable Initialization: It gets the cargo from cursor target, the helper from the player's variable, and the ship from the helper's attachment (using ropeAttachedTo). It also breaks undercover status.

Sqf

Apply
private _cargo = cursorTarget;
private _helper = player getVariable ["WinchHelperObj", objNull];
private _vehicle = ropeAttachedTo _helper;
player setCaptive false;
Winch Calculation: It calculates the horizontal distance between the ship and the cargo. The _unwind distance is the cable length needed (distance - 0.5 for slack). The _time is an estimate of how long the winching will take, based on distance and a base time.

Sqf

Apply
private _distance = _vehicle distance _cargo;
private _unwind = _distance - 0.5;
private _time = time + 5 + (_unwind*2);
Rope Repositioning (Player -> Cargo):

Calls A3A_SR_cleanHelper to remove the helper and the rope/variable link to the player. This severs the old connection.
Destroys the original rope (_vehicle getVariable "WinchRope").
Creates a new rope directly from the ship to the cargo object.
Sqf

Apply
[_helper, _vehicle] call A3A_SR_cleanHelper;
ropeDestroy (_vehicle getVariable "WinchRope");

private _rope = ropeCreate [_vehicle, [0,-2.8,-0.8], _cargo, [0,0,0], _distance];
_vehicle setVariable ["WinchRope", _rope, true];
Winching Process:

Sleeps for 1 second (for visual effect).
Uses ropeUnwind with the _unwind distance and a true flag for "pulling in" (winding). It winds at a very slow speed (0.5 m/s) to simulate a heavy winch.
Waits until the estimated time has passed OR the rope is destroyed (e.g., by damage or deletion).
Sqf

Apply
sleep 1;
ropeUnwind [_rope, 0.5, -(_unwind), true];
waitUntil {time > _time || isNull _rope};
if (isNull _rope) exitWith {};
Load Initiation & Final Cleanup:

If the rope wasn't destroyed during the wait, it destroys the rope.
It remotely executes A3A_SR_LoadSalvage on a server (remote execution level 2). This is crucial because the load operation is server-side. The parameters [_vehicle, _cargo] are passed.
It calls A3A_Logistics_fnc_addLoadAction on the cargo to add a "Unload" action to it.
It cleans up the WinchRope variable on the ship.
Sqf

Apply
ropeDestroy _rope;
[[_vehicle, _cargo], A3A_SR_LoadSalvage] remoteExecCall ["call", 2];
[_cargo] call A3A_Logistics_fnc_addLoadAction;
_vehicle setVariable ["WinchRope",nil,true];
Where it leads:

Calls:
A3A_SR_cleanHelper: For cleanup of the old helper.
ropeCreate: Game engine function to create new rope.
ropeUnwind: Game engine function for winching.
A3A_SR_LoadSalvage: Called remotely on the server to start the loading process.
A3A_Logistics_fnc_addLoadAction: Called locally to add an unload action to the cargo.
Depends on:
A3A_SR_DeployWinch for the initial state.
A3A_SR_canAttach for precondition checking.
The cargo having the SalvageCrate variable.
Fits into Larger System: This is the master function that orchestrates the entire salvage mission. It transitions from the "holding a rope" state to the "loaded cargo" state, managing the physical, visual, and logical process of salvaging. It's the most complex and state-dependent function in the system.
Global Variables Modified:
Player: Closes over player and modifies its captive state.
Ship (_vehicle): WinchRope variable is updated with the new rope (then set to nil later). The cleanup calls remove WinchHelper.
Cargo (_cargo): The addLoadAction call will modify the object's action menu.
Network/Code Synchronization: Heavy network use. ropeCreate, ropeDestroy, and ropeUnwind are synchronized. The remoteExecCall is critical for ensuring the load operation runs on the server. The client initiates a server-side process.
A3A_SR_addplayerWinchActions
Function Name: A3A_SR_addplayerWinchActions (defined within 
fn_salvageRope.sqf
)

What it does: This function adds three action menu entries to the player for the winch system: Deploy, Stow, and Attach. Each action is linked to its respective execution function and condition check.

How it does that:

Deploy Action:

Adds an action with localized text STR_antistasi_actions_deploy_winch.
On activation, it calls A3A_SR_DeployWinch with the [player] parameter.
It has no parameters (nil), a priority of 0, and is not shown in the player's command menu (false). It's only available while moving (true).
The crucial part is the condition string: "call A3A_SR_canDeployWinch". This is evaluated by the game engine continuously to show/hide the action. It must return true for the action to appear.
Sqf

Apply
player addAction [(localize "STR_antistasi_actions_deploy_winch"), {
    [player] call A3A_SR_DeployWinch;
}, nil, 0, false, true, "", "call A3A_SR_canDeployWinch"];
Stow Action:

Similar structure to deploy.
Calls A3A_SR_stowRope.
Condition is "call A3A_SR_canStow".
Sqf

Apply
player addAction [(localize "STR_antistasi_actions_stow_winch"), {
    [player] call A3A_SR_stowRope;
}, nil, 0, false, true, "", "call A3A_SR_canStow"];
Attach Action:

Calls A3A_SR_attachRope.
Condition is "call A3A_SR_canAttach".
Sqf

Apply
player addAction [(localize "STR_antistasi_actions_attach_winch"), {
    [player] call A3A_SR_attachRope;
}, nil, 0, false, true, "", "call A3A_SR_canAttach"];
Respawn Handler:

Adds an event handler to the player for the Respawn event.
When the player respawns, it sets the SalvageRopeAction variable to false, preparing the system to re-add the actions after respawn.
Sqf

Apply
player addEventHandler ["Respawn",{
    player setVariable ["SalvageRopeAction",false];
}];
Where it leads:

Calls:
A3A_SR_DeployWinch, A3A_SR_stowRope, A3A_SR_attachRope: The execution functions.
A3A_SR_canDeployWinch, A3A_SR_canStow, A3A_SR_canAttach: The condition functions.
Depends on:
The player object.
The defined functions and condition strings.
Fits into Larger System: This function is the user interface layer for the entire SalvageRope module. It binds the backend logic to player interactions. It's the setup step that makes the system usable in-game.
Global Variables Modified:
Player: SalvageRopeAction variable is set to true after adding actions (see the spawning loop below). The Respawn event handler will set it to false later.
Actions are added to the player's action menu (a global list managed by the engine).
Network/Code Synchronization: Action menus are local to the player. No network synchronization is performed by this function itself. However, the actions themselves trigger functions that do use the network.
Initiation Script (The _spawn Block)
Script Name: (Anonymous initialization block in 
fn_salvageRope.sqf
)

What it does: This is the entry-point script for the SalvageRope module. It's a spawning loop that runs once when the mission starts. Its job is to ensure the winch actions are added to the player's action menu after the mission is complete, and to monitor for mission completion to stop the loop.

How it does that:

Variable Initialization & Loop Condition: It initializes _missionComplete to false and enters a while loop that continues until _missionComplete becomes true.

Sqf

Apply
private _missionComplete = false;
while {!_missionComplete} do {
Player & Action Check: Inside the loop, it first checks if the player is valid and a player object (!isNull player && isplayer player).

Then, it checks the SalvageRopeAction variable. If it's false (which it is initially, and after respawn), it calls A3A_SR_addplayerWinchActions to add the actions.
It sets SalvageRopeAction to true to prevent re-adding the same actions every 2 seconds.
Sqf

Apply
if (!isNull player && isplayer player) then {
    if !(player getVariable ["SalvageRopeAction",false]) then {
        [] call A3A_SR_addplayerWinchActions;
        player setVariable ["SalvageRopeAction",true];
    };
};
Loop Throttling & Mission Check:

Sleeps for 2 seconds to avoid performance issues.
Checks if the "LOG" task (presumably the Salvage mission) is completed using BIS_fnc_taskCompleted. If so, it sets _missionComplete to true, breaking the loop.
Sqf

Apply
sleep 2;
_missionComplete = "LOG" call BIS_fnc_taskCompleted;
Where it leads:

Calls:
A3A_SR_addplayerWinchActions: The primary function this script calls.
BIS_fnc_taskCompleted: Game engine function to check mission state.
player getVariable, player setVariable: Game engine functions for variable management.
Depends on:
The SalvageRopeAction variable on the player.
The existence of a "LOG" task in the mission framework.
Fits into Larger System: This is the module's bootstrapper. It ensures the SalvageRope system is only active when the appropriate mission type is running, preventing the UI from cluttering the interface during other mission types (like combat, transport, etc.). The respawn handler ensures functionality persists through death.
Global Variables Modified:
Player: SalvageRopeAction is set to true when actions are added, false on respawn.
Network/Code Synchronization: Entirely client-side. Runs in a separate scheduled environment (spawn). The task completion check is likely global/synchronized via the mission framework.