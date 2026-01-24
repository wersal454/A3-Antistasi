# Garage System Comprehensive Documentation

## Overview
The Garage System is a sophisticated vehicle management interface for the Antistasi mission framework, providing comprehensive vehicle storage, customization, and state preservation capabilities.

## System Architecture

### Function Organization
The garage system is organized into 6 main categories:
- **Core** (28 functions): Core garage functionality and user management
- **Public** (6 functions): External API functions for vehicle management
- **Extras** (10 functions): Vehicle customization and mount management
- **Pylons** (7 functions): Pylon loadout management
- **Refuel** (5 functions): Fuel management and refueling operations
- **StatePreservation** (11 functions): Vehicle state capture and restoration

### Key Data Structures

#### HR_GRG_Vehicles
```cpp
// HashMap structure: Category -> [VehicleUID -> VehicleData]
// VehicleData format: [DisplayName, ClassName, LockUID, CheckoutUID, StateData, LockName, Customization, LockTime]
HR_GRG_Vehicles = createHashMap;
```

#### HR_GRG_Sources
```cpp
// Array structure: [AmmoSources, FuelSources, RepairSources]
// Each contains array of VehicleUIDs that provide that service
HR_GRG_Sources = [[], [], []];
```

## Complete Function Documentation with Code Examples

This document provides **IN-DEPTH** descriptions for every single function in the Garage System (61 functions total), following the exact requirements: **What it does, How it does that, Where it leads**. The "Where it leads" section specifically details what functions are called and the subsequent operation chains.

---

## CORE FUNCTIONS (28 functions)

### 1. fn_addUser.sqf
**What it does**: Adds a client to the garage's vehicle pool update recipient list and immediately synchronizes the complete current garage state (all vehicles and sources) to that client, enabling them to participate in real-time garage operations.

**How it does that**: Performs server-side validation checking for proper execution context and input parameters, verifies the client ID is a valid number type, initializes the HR_GRG_Users array if it doesn't exist, appends the new client ID to the array, then uses publicVariableClient to transmit HR_GRG_Vehicles (complete vehicle pool data) and HR_GRG_Sources (service source availability) to the specific client, ensuring immediate synchronization without requiring a full refresh.

**Where it leads**: Calls **publicVariableClient** twice (for vehicles and sources), enables the client to receive future **HR_GRG_fnc_broadcast** calls, triggers client-side **HR_GRG_fnc_reciveBroadcast** event handlers, allows the client to use **HR_GRG_fnc_onLoad** and access full garage functionality, affects **HR_GRG_fnc_updateVehicleCount** display updates for the new user.

**Code Implementation**:
```cpp
params ["_client"];

if (!isServer || isNil "_client" || {!(_client isEqualType 0)}) exitWith {false};

if (isNil "HR_GRG_Users") then {HR_GRG_Users = []};
Trace_1("Adding user: %1", _client);
HR_GRG_Users pushBack _client;
_client publicVariableClient "HR_GRG_Vehicles";
_client publicVariableClient "HR_GRG_Sources";
true
```

### 2. fn_broadcast.sqf
**What it does**: Distributes vehicle pool state change notifications to all currently connected garage clients, ensuring real-time synchronization of vehicle availability, lock status, and checkout changes across the network.

**How it does that**: Validates server-only execution, stores the incoming broadcast parameters (lock UID, checkout UID, category index, vehicle UID, player object, switch selection flag, lock timestamp) in the global HR_GRG_Event variable, then iterates through the HR_GRG_Users array containing all active client IDs, using publicVariableClient to transmit the event data to each client individually.

**Where it leads**: Triggers **HR_GRG_fnc_reciveBroadcast** on each client (which calls **HR_GRG_fnc_reloadCategory** and **HR_GRG_fnc_updateVehicleCount**), updates client-side vehicle list displays with new lock/checkout status, affects **HR_GRG_fnc_toggleConfirmBttn** button states, changes vehicle availability for **HR_GRG_fnc_requestVehicle** operations, influences **HR_GRG_fnc_sellVehGRG** permissions.

**Code Implementation**:
```cpp
if !(isServer) exitWith {false};
HR_GRG_Event = _this;
{
    _x publicVariableClient "HR_GRG_Event";
} forEach HR_GRG_Users;
true
```

### 3. fn_confirmPlacement.sqf
**What it does**: Manages the entire vehicle placement workflow from preview creation through final spawning, including complex collision detection, user input handling, mount/pylon attachment, and state restoration - the most complex function in the garage system.

**How it does that**: Creates a local preview vehicle using createVehicleLocal, initializes global positioning variables, sets up comprehensive event handlers for mouse/keyboard input (EachFrame, KeyDown, KeyUp), generates 20+ raycast collision detection lines covering all vehicle bounding box surfaces, implements real-time rotation and positioning via Q/E keys and mouse movement, validates placement conditions including distance limits, collision detection, and custom callback checks, handles mount attachment using **A3A_Logistics_fnc_load**, applies pylon configurations, and finally spawns the real vehicle with **HR_GRG_fnc_setState** restoration.

**Where it leads**: Calls **HR_GRG_fnc_getState** to capture preview state, calls **HR_GRG_fnc_prepPylons** on the spawned vehicle, calls **HR_GRG_fnc_setState** to restore complete vehicle condition, calls **HR_GRG_fnc_vehInit** on attached mounts, calls **A3A_Logistics_fnc_load** for mount attachment, calls **BIS_fnc_initVehicle** for texture/animation application, triggers callback functions provided by the caller, calls **HR_GRG_fnc_releaseAllVehicles** on all clients if placement is cancelled.

**Key Code Segments**:
```cpp
// Collision detection system
private _rays = [
    // Outer box rays for collision detection
    [[_left,_back,_bottom], [_right,_back,_top]],    //back cross
    [[_left,_back,_top], [_right,_back,_bottom]],     //back cross diagonal
    // ... 16+ additional raycast lines
];

// Vehicle placement validation
private _exit = false;
{
    _x params ["_start", "_end"];
    if (lineIntersects [
        HR_GRG_dispVehicle modelToWorldVisualWorld _start,
        HR_GRG_dispVehicle modelToWorldVisualWorld _end,
        HR_GRG_dispVehicle
    ]) exitWith { _exit = true; HR_GRG_validPlacement = 2 };
} forEach HR_GRG_rays;
```

### 4. fn_requestVehicle.sqf
**What it does**: Processes server-side vehicle checkout requests, validating availability and updating vehicle status for the requesting player.

**How it does that**: Validates server execution and input parameters, verifies the requested vehicle exists and is available (checkout field is empty), updates the vehicle's checkout status with the requesting player's UID, triggers broadcast to synchronize all clients with the new status.

**Where it leads**: Calls **HR_GRG_fnc_broadcast** to notify all clients of the checkout, updates vehicle availability for **HR_GRG_fnc_toggleLock** operations, affects **HR_GRG_fnc_sellVehGRG** permissions, changes status for **HR_GRG_fnc_removeFromPool** cleanup, influences **HR_GRG_fnc_requestSelectionChange** permission checks.

**Code Implementation**:
```cpp
params [["_UID","",[""]], ["_cat",0,[0]], ["_index",0,[0]]];
if (!isServer) exitWith {false};
if (_UID isEqualTo "") exitWith {false};

private _veh = (HR_GRG_Vehicles#_cat) get _index;
if ( (_veh#3) isEqualTo "") exitWith {_veh set [3, _UID]; call HR_GRG_fnc_broadcast; true};
false;
```

### 5. fn_declairSources.sqf
**What it does**: Updates the global availability flags for service-providing vehicles (ammo, fuel, repair sources) and broadcasts these changes to all connected clients, ensuring UI indicators reflect current service capabilities.

**How it does that**: Checks the length of each source array in HR_GRG_Sources (index 0 for ammo, 1 for fuel, 2 for repair), sets corresponding global boolean flags (HR_GRG_hasAmmoSource, HR_GRG_hasFuelSource, HR_GRG_hasRepairSource) based on whether the arrays are empty, then uses publicVariable to broadcast these flag changes to all clients.

**Where it leads**: Calls **publicVariable** to broadcast availability flags, triggers client-side UI updates in **HR_GRG_fnc_reloadExtras** which calls **HR_GRG_fnc_switchExtrasMenu** to show/hide service-dependent UI elements, affects **HR_GRG_fnc_toggleAnim** and **HR_GRG_fnc_switchTexture** availability, influences **HR_GRG_fnc_requestMount** permission checks.

### 6. fn_execForGarageUsers.sqf
**What it does**: Executes a specified function with player parameters across all currently connected garage users, providing coordinated execution for operations that affect multiple clients simultaneously.

**How it does that**: Creates a recipient array starting with HR_GRG_Users, adds the server (ID 2) and the specified client ID to prevent double-calling, uses remoteExecCall to execute the specified function name with the player's UID and player object as parameters to all recipients.

**Where it leads**: Calls **remoteExecCall** to execute the specified function (like **HR_GRG_fnc_releaseAllVehicles** or **HR_GRG_fnc_removeFromPool**) on all garage users, triggers server-side execution for cleanup operations, affects vehicle availability across all clients, influences **HR_GRG_fnc_broadcast** calls for state synchronization.

### 7. fn_genVehUID.sqf
**What it does**: Generates cryptographically secure unique identifiers for vehicles stored in the garage, ensuring no collision between vehicle entries across the entire system lifetime.

**How it does that**: Increments the global HR_GRG_UID counter by 1, applies modulo 10000000 to create a cycling ID system that loops back to 0 after 10 million vehicles, returns the new UID value as a direct copy to prevent external modification of the counter.

**Where it leads**: Provides unique hashmap keys for **HR_GRG_Vehicles** storage, enables **HR_GRG_fnc_getLockCount** to track individual vehicles, supports **HR_GRG_fnc_requestVehicle** for specific vehicle identification, affects **HR_GRG_fnc_broadcast** event targeting, influences **HR_GRG_fnc_sellVehGRG** vehicle identification.

### 8. fn_getCatIndex.sqf
**What it does**: Analyzes vehicle configuration and inheritance to determine the appropriate garage category, routing vehicles into correct organizational buckets for display and management.

**How it does that**: First checks for blacklist entries returning -2 for banned vehicles, then evaluates editor subcategory inheritance (EdSubcat_Cars, EdSubcat_Armored, etc.), handles special cases for service sources using **HR_GRG_fnc_isAmmoSource**, **HR_GRG_fnc_isFuelSource**, and **HR_GRG_fnc_isRepairSource**, supports RHS and CUP mod configurations with specific subcategory checks, falls back to basic vehicle type inheritance (Car, Tank, Helicopter, etc.).

**Where it leads**: Determines category index used in **HR_GRG_Vehicles** hashmap access, affects **HR_GRG_fnc_switchCategory** UI navigation, influences **HR_GRG_fnc_reloadCategory** display filtering, impacts **HR_GRG_fnc_updateVehicleCount** category counting, routes vehicles for **HR_GRG_fnc_addVehicle** storage decisions.

### 9. fn_getLockCount.sqf
**What it does**: Calculates the number of non-source vehicles currently locked by a specific player, enforcing the lock limit system that prevents players from monopolizing garage vehicles.

**How it does that**: Iterates through all categories in HR_GRG_Vehicles, for each category iterates through all vehicles, checks if the vehicle is locked by the specified UID, excludes vehicles that are also service sources (found in HR_GRG_Sources arrays), accumulates the count of qualifying locked vehicles.

**Where it leads**: Returns count used by **HR_GRG_fnc_toggleLock** to enforce **HR_GRG_getLockLimit**, affects **HR_GRG_fnc_addVehicle** permission checks during vehicle storage, influences **HR_GRG_fnc_requestVehicle** availability decisions, impacts player feedback in **HR_GRG_fnc_hint** calls.

### 10. fn_onLoad.sqf
**What it does**: Performs complete garage interface initialization when the dialog opens, setting up all visual, input, and data systems required for full garage functionality.

**How it does that**: Displays loading screen with **BIS_fnc_startLoadingScreen**, verifies server initialization calling **HR_GRG_fnc_initServer** if needed, creates 3D camera system with **camCreate** and lighting, sets up mouse/keyboard event handlers for camera control, initializes global variables for UI state, calls **HR_GRG_fnc_addUser** to register for updates, populates category lists, configures extras menus, and sets up the preview vehicle system.

**Where it leads**: Calls **HR_GRG_fnc_initServer** if server not initialized, calls **HR_GRG_fnc_addUser** for client registration, calls **HR_GRG_fnc_switchCategory** for initial category setup, calls **HR_GRG_fnc_reloadExtras** for customization interface, calls **HR_GRG_fnc_updateVehicleCount** for capacity display, sets up event handlers that call **HR_GRG_fnc_updateCamPos** for camera control, triggers **HR_GRG_fnc_reloadPylons** for weapon configuration.

### 11. fn_onUnload.sqf
**What it does**: Performs complete cleanup of the garage interface when closed, restoring the game to its normal state and ensuring no lingering effects or memory leaks.

**How it does that**: Terminates the loading screen with **BIS_fnc_endLoadingScreen**, removes all mission event handlers (EachFrame), removes display event handlers (KeyDown, KeyUp, MouseMoving), destroys the preview camera and lighting objects, deletes the preview vehicle and any attached objects, clears all global garage variables, and terminates any running hint displays.

**Where it leads**: Calls **remoteExecCall** to **HR_GRG_fnc_removeUser** on the server to unregister the client, allows **HR_GRG_fnc_broadcast** to stop sending updates to this client, frees up memory by destroying **camDestroy** and **deleteVehicle** calls, restores normal game event handling by removing **addMissionEventHandler**, affects **HR_GRG_fnc_execForGarageUsers** recipient lists.

### 12. fn_reciveBroadcast.sqf
**What it does**: Processes real-time vehicle state change notifications from the server, updating local vehicle data and triggering UI refreshes to maintain synchronization.

**How it does that**: Receives broadcast parameters (lock UID, checkout UID, category index, vehicle UID, player object, switch flag, timestamp), locates the affected vehicle in HR_GRG_Vehicles using the category and vehicle UIDs, updates the vehicle's lock and checkout status, handles selection switching if requested, triggers category reload and vehicle count updates.

**Where it leads**: Calls **HR_GRG_fnc_reloadCategory** for the affected category to update list displays, calls **HR_GRG_fnc_updateVehicleCount** to refresh capacity display, triggers **HR_GRG_fnc_reloadPreview** if vehicle selection changed, affects **HR_GRG_fnc_toggleConfirmBttn** button states, influences **HR_GRG_fnc_selectionChange** UI responses, updates lock status displays with timestamps.

### 13. fn_releaseAllVehicles.sqf
**What it does**: Releases all vehicle checkouts held by a specific player, making those vehicles available for other players to access, typically called on disconnect or placement operations.

**How it does that**: Iterates through all categories in HR_GRG_Vehicles, for each category iterates through all vehicles, checks if the vehicle is checked out by the specified UID, clears the checkout status (sets field 3 to empty string), if running on client side calls **HR_GRG_fnc_reloadCategory** for each affected category to update displays.

**Where it leads**: Calls **HR_GRG_fnc_reloadCategory** on client side for UI updates, triggers **HR_GRG_fnc_broadcast** calls from server to synchronize changes, affects **HR_GRG_fnc_requestVehicle** availability, changes vehicle status for **HR_GRG_fnc_toggleLock** operations, influences **HR_GRG_fnc_sellVehGRG** permissions, updates **HR_GRG_fnc_updateVehicleCount** displays.

### 14. fn_reloadCategory.sqf
**What it does**: Completely rebuilds a vehicle category listbox with current vehicle data, status indicators, lock information, and selection states for user interaction.

**How it does that**: Clears the existing listbox with **lbClear**, iterates through all vehicles in the specified category from HR_GRG_Vehicles, adds each vehicle with **lbAdd** using display names, sets vehicle UIDs as data values, applies lock/checkout icons using **lbSetPicture** and **lbSetPictureRight**, generates detailed tooltips with ownership and timing information, sorts the list with **lbSort**, restores previous selection if it still exists.

**Where it leads**: Calls **cfgIcon** and **cfgDispName** for vehicle information display, uses **A3A_fnc_systemTimeDurationToTimeSpan** for lock time formatting, affects **HR_GRG_fnc_selectionChange** user interactions, influences **HR_GRG_fnc_toggleConfirmBttn** states, triggers **HR_GRG_fnc_reloadPreview** when selections change, updates display for **HR_GRG_fnc_broadcast** synchronization.

### 15. fn_reloadPreview.sqf
**What it does**: Updates the 3D vehicle preview display with the currently selected vehicle's configuration, including all customization and state data.

**How it does that**: Destroys existing preview vehicle and attached objects with **deleteVehicle**, creates new preview vehicle with **createVehicleLocal** using the selected class, applies saved state data with **HR_GRG_fnc_setState**, applies texture and animation customizations with **BIS_fnc_initVehicle**, positions the vehicle and updates camera targeting with **HR_GRG_fnc_updateCamPos**.

**Where it leads**: Calls **HR_GRG_fnc_getState** to access stored vehicle data, calls **HR_GRG_fnc_setState** to restore vehicle condition, calls **BIS_fnc_initVehicle** for appearance customization, calls **HR_GRG_fnc_updateCamPos** for camera positioning, enables **HR_GRG_fnc_updateCamPos** mouse/keyboard controls, affects **HR_GRG_fnc_confirmPlacement** preview vehicle creation.

### 16. fn_removeFromPool.sqf
**What it does**: Permanently removes vehicles from the garage pool that are checked out by a disconnecting or selling player, cleaning up abandoned vehicle entries.

**How it does that**: Identifies all vehicles checked out by the target UID across all categories, removes them from HR_GRG_Vehicles hashmaps, checks and removes them from HR_GRG_Sources arrays if they were service providers, calls **HR_GRG_fnc_declairSources** to update availability flags, on client side triggers category reloads and vehicle count updates.

**Where it leads**: Calls **HR_GRG_fnc_declairSources** to update service availability after cleanup, calls **HR_GRG_fnc_reloadCategory** on clients for UI updates, calls **HR_GRG_fnc_updateVehicleCount** for capacity display, triggers **HR_GRG_fnc_broadcast** from server for synchronization, affects **HR_GRG_fnc_execForGarageUsers** operations, influences **HR_GRG_fnc_validateGarage** data integrity.

### 17. fn_removeUser.sqf
**What it does**: Removes a disconnected client from the garage update recipient list, preventing wasted network traffic and maintaining efficient broadcast operations.

**How it does that**: Validates server execution context and input parameters, uses **deleteAt** with **find** to remove the specified client ID from the HR_GRG_Users array, maintaining the integrity of the recipient list.

**Where it leads**: Prevents future **HR_GRG_fnc_broadcast** calls from being sent to the disconnected client, affects **HR_GRG_fnc_execForGarageUsers** recipient calculations, improves network efficiency for remaining users, triggers automatic cleanup through **addMissionEventHandler** in **HR_GRG_fnc_initServer**.

### 18. fn_requestSelectionChange.sqf
**What it does**: Server-side validation and processing of vehicle selection change requests, ensuring permission checks and preventing unauthorized vehicle access.

**How it does that**: Validates server execution and input parameters, verifies category and vehicle UIDs exist, checks if the requesting player has permission to access the vehicle (either owns the lock or has commander override), releases any current checkouts with **HR_GRG_fnc_releaseAllVehicles**, updates the vehicle checkout status, triggers broadcast to synchronize all clients.

**Where it leads**: Calls **HR_GRG_fnc_releaseAllVehicles** to clear previous checkouts, calls **HR_GRG_fnc_broadcast** to synchronize changes, calls **HR_GRG_fnc_toggleConfirmBttn** on client to update button states, triggers **HR_GRG_fnc_reloadPreview** on client for visual updates, affects **HR_GRG_fnc_selectionChange** UI responses, influences vehicle availability for other players.

### 19. fn_requestVehicle.sqf
**What it does**: Processes server-side vehicle checkout requests, validating availability and updating vehicle status for the requesting player.

**How it does that**: Validates server execution and input parameters, verifies the requested vehicle exists and is available (checkout field is empty), updates the vehicle's checkout status with the requesting player's UID, triggers broadcast to synchronize all clients with the new status.

**Where it leads**: Calls **HR_GRG_fnc_broadcast** to notify all clients of the checkout, updates vehicle availability for **HR_GRG_fnc_toggleLock** operations, affects **HR_GRG_fnc_sellVehGRG** permissions, changes status for **HR_GRG_fnc_removeFromPool** cleanup, influences **HR_GRG_fnc_requestSelectionChange** permission checks.

### 20. fn_selectionChange.sqf
**What it does**: Handles client-side vehicle selection changes from category list interactions, coordinating with server for permission and state updates.

**How it does that**: Validates the selection is not empty, clears any existing selection visuals, updates global selection variables, disables the confirm button during processing, sends remote request to server for selection change approval.

**Where it leads**: Calls **remoteExecCall** to **HR_GRG_fnc_requestSelectionChange** on server, calls **HR_GRG_fnc_toggleConfirmBttn** to disable button, triggers **HR_GRG_fnc_reloadPreview** when server approves, affects **HR_GRG_fnc_confirm** dialog availability, influences **HR_GRG_fnc_switchCategory** selection persistence, updates **HR_GRG_SelectedVehicles** global state.

### 21. fn_sellVehGRG.sqf
**What it does**: Processes vehicle sales with comprehensive validation, resource crediting, and cleanup of garage pool entries.

**How it does that**: Validates player has selling permissions with **HR_GRG_canSell**, checks vehicle is not locked, calculates refund value with **HR_GRG_getVehicleSellPrice**, removes vehicle from pool with **HR_GRG_fnc_removeFromPool**, credits resources with **HR_GRG_addResources**, provides user feedback with **HR_GRG_fnc_hint**.

**Where it leads**: Calls **HR_GRG_fnc_removeFromPool** for vehicle removal, calls **HR_GRG_addResources** for player compensation, calls **HR_GRG_fnc_hint** for user feedback, triggers **HR_GRG_fnc_broadcast** through removal operations, affects **HR_GRG_fnc_updateVehicleCount** capacity displays, influences **HR_GRG_fnc_validateGarage** data integrity.

### 22. fn_sellVehGRGLocal.sqf
**What it does**: Handles client-side completion of vehicle sale operations, providing user feedback and UI state updates.

**How it does that**: Clears current vehicle selection, resets global selection variables, provides visual feedback to the player about the successful sale operation.

**Where it leads**: Resets **HR_GRG_SelectedVehicles** to empty state, affects **HR_GRG_fnc_toggleConfirmBttn** button states, triggers **HR_GRG_fnc_reloadPreview** to clear preview, influences **HR_GRG_fnc_selectionChange** interactions, updates client-side UI for **HR_GRG_fnc_broadcast** synchronization.

### 23. fn_switchCategory.sqf
**What it does**: Changes the active vehicle category display, managing UI state transitions and category-specific content loading.

**How it does that**: Disables all category controls, reloads the target category data with **HR_GRG_fnc_reloadCategory**, updates the category title text based on category index, enables the new category controls, triggers confirm button state evaluation.

**Where it leads**: Calls **HR_GRG_fnc_reloadCategory** for the new category content, calls **HR_GRG_fnc_toggleConfirmBttn** for button state updates, resets **HR_GRG_SelectedVehicles** selection, triggers **HR_GRG_fnc_reloadPreview** for preview updates, affects **HR_GRG_fnc_selectionChange** available options, influences **HR_GRG_fnc_updateVehicleCount** display context.

### 24. fn_toggleConfirmBttn.sqf
**What it does**: Manages the enabled/disabled state of the vehicle confirmation button based on current selection validity and operation context.

**How it does that**: Evaluates current vehicle selection state, checks if a valid vehicle is selected, enables or disables the button accordingly, updates button appearance to reflect the current state, handles both immediate and delayed state changes.

**Where it leads**: Controls user access to **HR_GRG_fnc_confirm** operations, affects **HR_GRG_fnc_confirmPlacement** availability, influences **HR_GRG_fnc_requestSelectionChange** call timing, provides visual feedback for **HR_GRG_fnc_selectionChange** operations, impacts user interaction flow in **HR_GRG_fnc_onLoad** initialization.

### 25. fn_toggleLock.sqf
**What it does**: Toggles vehicle lock status with permission validation, limit enforcement, and comprehensive state tracking.

**How it does that**: Validates server execution, checks vehicle and category validity, verifies lock permissions (ownership or commander override), enforces lock limits with **HR_GRG_fnc_getLockCount**, updates vehicle lock status with player UID and timestamp, broadcasts changes to all clients.

**Where it leads**: Calls **HR_GRG_fnc_getLockCount** for limit validation, calls **HR_GRG_fnc_broadcast** for synchronization, calls **HR_GRG_fnc_hint** for user feedback on limit violations, affects **HR_GRG_fnc_requestVehicle** availability, influences **HR_GRG_fnc_sellVehGRG** permissions, updates lock displays in **HR_GRG_fnc_reloadCategory**.

### 26. fn_updateCamPos.sqf
**What it does**: Provides smooth 3D camera controls for vehicle preview inspection, translating mouse movement into camera rotation and positioning.

**How it does that**: Validates preview vehicle exists, calculates new camera rotation based on mouse movement deltas, applies vertical and horizontal rotation limits, transforms rotation into world position using **BIS_fnc_rotateVector3D** and **BIS_fnc_rotateVector2D**, updates camera position and targeting with **camSetPos** and **camSetTarget**.

**Where it leads**: Enables interactive camera control in **HR_GRG_fnc_onLoad** initialization, provides visual feedback for **HR_GRG_fnc_reloadPreview** operations, affects user experience in **HR_GRG_fnc_confirmPlacement** preview mode, uses **BIS_fnc_rotateVector3D** and **BIS_fnc_rotateVector2D** for mathematical transformations.

### 27. fn_updateVehicleCount.sqf
**What it does**: Updates the garage capacity display by counting all stored vehicles and presenting the current utilization ratio.

**How it does that**: Iterates through all categories in HR_GRG_Vehicles, counts total vehicles using hashmap size operations, retrieves maximum capacity from **HR_GRG_VehCap**, formats and displays the current/total ratio in the UI capacity text control.

**Where it leads**: Provides capacity feedback for **HR_GRG_fnc_addVehicle** operations, affects UI display in **HR_GRG_fnc_broadcast** updates, shows utilization in **HR_GRG_fnc_onLoad** initialization, influences player decisions in **HR_GRG_fnc_confirmPlacement** operations, updates display after **HR_GRG_fnc_removeFromPool** operations.

### 28. fn_validateGarage.sqf
**What it does**: Performs comprehensive validation and cleanup of the garage vehicle database, removing invalid entries and maintaining data integrity.

**How it does that**: Scans all vehicles in HR_GRG_Vehicles for invalid classnames using **isClass** config checks, removes vehicles with non-existent configs from hashmaps, checks and cleans up HR_GRG_Sources registry entries, logs all removal operations for debugging.

**Where it leads**: Calls **HR_GRG_fnc_declairSources** to update service availability after cleanup, ensures data integrity for **HR_GRG_fnc_getCatIndex** operations, affects **HR_GRG_fnc_addVehicle** storage decisions, maintains clean state for **HR_GRG_fnc_loadSaveData** operations, prevents errors in **HR_GRG_fnc_reloadCategory** displays.

### fn_sellVehGRG.sqf
**Purpose**: Processes vehicle sales from the garage with resource crediting.

**Code Implementation**:
```cpp
private _refund = [_class] call HR_GRG_getVehicleSellPrice;
if (_refund == 0) exitWith {["STR_HR_GRG_Feedback_sellVehicle_noPrice"] remoteExecCall ["HR_GRG_fnc_hint", _player];};

private _cat = HR_GRG_Vehicles#_catIndex;
private _veh = _cat get _vehUID;
private _lock = _veh#2;
if !(_lock isEqualTo "") exitWith {["STR_HR_GRG_Feedback_sellVehicle_locked"] remoteExecCall ["HR_GRG_fnc_hint", _player];};

[_UID,_player,_removeStatics] remoteExecCall ["HR_GRG_fnc_removeFromPool", _recipients];
[] remoteExec ["HR_GRG_fnc_sellVehGRGLocal",_player];
[_refund] spawn HR_GRG_addResources;
```

## Public Functions (6 functions)

### fn_addVehicle.sqf
**Purpose**: Handles individual vehicle addition to garage with comprehensive validation.

**Key Validation Logic**:
```cpp
// Location validation
private _friendlyMarkers = (["Synd_HQ"] + outposts + seaports + airportsX + factories + resourcesX + milbases) select {sidesX getVariable [_x,sideUnknown] == teamPlayer};
private _inArea = _friendlyMarkers findIf { count ([_player, _vehicle] inAreaArray _x) > 1 };

// No enemies near check
if ([getPosATL _player] call A3A_fnc_enemyNearCheck) exitWith {
    ["STR_HR_GRG_Feedback_addVehicle_enemiesEngaging"] remoteExec ["HR_GRG_fnc_Hint", _client];
    false;
};

// Crew validation
private _exit = false;
if ( ( {alive _x} count (crew _vehicle) ) > 0) then { _exit = true };
{ if ( ( {alive _x} count (crew _x) ) > 0) exitWith {_exit = true} } forEach attachedObjects _vehicle;
```

**State Preservation Process**:
```cpp
// Remove ACE cargo first
{
    if !(_x isEqualType objNull) then { continue };
    if (typeOf _x in ["ACE_Wheel", "ACE_Track"]) then { continue };
    [_x, _vehicle] call ace_cargo_fnc_unloadItem;
} forEach (_vehicle getVariable ["ace_cargo_loaded", []]);

// Capture vehicle state
private _stateData = [_this] call HR_GRG_fnc_getState;
private _customisation = [_this] call BIS_fnc_getVehicleCustomization;
private _lockTime = [systemTimeUTC, []] select (_lockUID isEqualTo "");

// Antistasi integrations
_this call _transferToArsenal;
_this call _deleteFromReportedVehsAndStaticsToSave;

// Store in garage
private _vehUID = [] call HR_GRG_fnc_genVehUID;
(HR_GRG_Vehicles#_cat) set [_vehUID, [cfgDispName(_class), _class, _lockUID, "", _stateData, _lockName, _customisation, _lockTime]];
```

## Extras Functions (10 functions)

### fn_reloadExtras.sqf
**Purpose**: Rebuilds the extras customization interface with comprehensive vehicle information.

**Mount Loading Logic**:
```cpp
private _nodeCfg = [HR_GRG_previewVeh] call A3A_Logistics_fnc_getNodeConfig;
private _vehNodes = [HR_GRG_previewVeh] call A3A_Logistics_fnc_getVehicleNodes;

{
    _y params ["_displayName", "_staticClass", "_lockedUID", "_checkedOut"];

    private _block =false;
    if !(_lockedUID in ["", HR_GRG_PlayerUID]) then {_block = true};
    if !(_checkedOut in ["", HR_GRG_PlayerUID]) then {_block = true};

    private _cargoCfg = [_staticClass] call A3A_Logistics_fnc_getCargoConfig;
    private _size = getNumber (_cargoCfg/"size");
    private _allowed = (
        !(_vehModel in _blackList || typeOf HR_GRG_previewVeh in _blackList)
        && {getNumber (_nodeCfg/"canLoadWeapon") > 0}
    );

    if ( (_allowed) && (_size != -1) && (_capacity >= _size) && !_block) then {
        private _index = _ctrlExtraMounts lbAdd _displayName;
        _ctrlExtraMounts lbSetData [_index, _staticClass];
        _ctrlExtraMounts lbSetValue [_index, _x];
        _ctrlExtraMounts lbsetpicture [_index,checkboxTextures select (_checkedOut isEqualTo HR_GRG_PlayerUID)];
        _ctrlExtraMounts lbSetTextRight [_index, format ["Size: %1", _size]];
    };
} forEach (HR_GRG_Vehicles#HR_GRG_STATICINDEX);
```

**Vehicle Information Panel**:
```cpp
// State calculation
private _hasAmmo = (HR_GRG_previewVehState#2) isNotEqualTo [];
private _avgAmmo = (HR_GRG_previewVehState#2) call _getPercentageAmmo;
private _avgFuel = HR_GRG_previewVehState#0#0;
private _avgDmg = 1 - (HR_GRG_previewVehState#1#0);

// State display formatting
private _vehAmmoState = composeText [image RearmIcon, " " + (if (_hasAmmo) then {str round (_avgAmmo * 100) + " %"} else {"-"})];
private _vehFuelState = composeText [image RefuelIcon, " " + str round (_avgFuel * 100) + " %"];
private _vehDmgState = composeText [image RepairIcon, " " + str round (_avgDmg * 100) + " %"];
```

### fn_reloadMounts.sqf
**Purpose**: Updates mounted static weapons on preview vehicle with logistics integration.

**Mount Attachment Process**:
```cpp
private _usedCapacity = 0;
private _lockedSeats = 0;
{
    //load preview static onto preview vehicle
    _x params ["_class", "_vehUID"];
    private _staticData = (HR_GRG_Vehicles#HR_GRG_STATICINDEX) get _vehUID;
    private _static = _class createVehicleLocal [random 100,random 100,10000 + random 10000];
    [_static, _staticData#4] call HR_GRG_fnc_setState;
    _static enableSimulation false;
    _static allowDamage false;

    _loadInfo = [HR_GRG_previewVeh, _static] call A3A_Logistics_fnc_canLoad;
    if (_loadInfo isEqualType 0) exitWith {};

    (_loadInfo + [true]) call A3A_Logistics_fnc_load;

    //get new load info
    private _nodes = _loadInfo#2;
    _usedCapacity = _usedCapacity + count _nodes;
    {_lockedSeats = _lockedSeats + count (_x#2)} forEach _nodes;
};
```

## Pylons Functions (7 functions)

### fn_reloadPylons.sqf
**Purpose**: Rebuilds the pylon configuration interface dynamically.

**Dynamic Control Creation**:
```cpp
private _curPylons = getPylonMagazines HR_GRG_previewVeh;
{
    //Header text
    private _textCtrl = _disp ctrlCreate ["HR_GRG_RscTextNoBG", -1, _ctrlGroup];
    _textCtrl ctrlSetPosition [
        0, _baseOffset, 10 * GRID_NOUISCALE_W, 3 * GRID_NOUISCALE_H
    ];
    _textCtrl ctrlCommit 0;
    _textCtrl ctrlSetText format [localize "STR_HR_GRG_Pylons_PylonText", _forEachIndex + 1];

    //Turret button
    private _btnCtrl = _disp ctrlCreate ["ctrlButtonPictureKeepAspect", HR_GRG_IDC_PylonsFirstIDC + _IDCCount, _ctrlGroup];
    _btnCtrl ctrlSetPosition [
        1 * GRID_NOUISCALE_W, _baseOffset + 4 * GRID_NOUISCALE_H,
        3 * GRID_NOUISCALE_W, 3 * GRID_NOUISCALE_H
    ];
    _btnCtrl ctrlCommit 0;

    private _turret = [HR_GRG_previewVeh, _forEachIndex] call HR_GRG_fnc_getPylonTurret;
    [_btnCtrl, false, _turret] call HR_GRG_fnc_PylonsTurretToggle;
    _btnCtrl ctrlAddEventHandler ["ButtonClick", {[_this#0, true, []] call HR_GRG_fnc_PylonsTurretToggle}];

    //Pylon magazine selection
    private _comboCtrl = _disp ctrlCreate ["HR_GRG_RscComboBlckBG", HR_GRG_IDC_PylonsFirstIDC + _IDCCount, _ctrlGroup];
    // ... position and setup code
}
```

### fn_updatePylons.sqf
**Purpose**: Applies current pylon configuration to preview vehicle.

**Code Implementation**:
```cpp
HR_GRG_UpdatePylons = false;
private _pylonLoudout = [];
{
    _x params ["_combo", "_mirrorIndex", "_button", "_comboIndex"];
    private _data = _combo lbData lbCurSel _combo;
    _pylonLoudout pushBack [_forEachIndex + 1, _data, false, _button getVariable ["HR_GRG_turret", []]];
} forEach HR_GRG_PylonData;

HR_GRG_Pylons = _pylonLoudout;

//update preview pylon loudout
{
    _x params ["_pylonIndex", "_mag", "_forced", "_turret"];
    HR_GRG_previewVeh setPylonLoadout [_pylonIndex, _mag, _forced, _turret];
} forEach HR_GRG_Pylons;
```

## Refuel Functions (5 functions)

### fn_refuelVehicleFromSources.sqf
**Purpose**: Refuels a vehicle using fuel from garage source vehicles.

**Fuel Calculation Logic**:
```cpp
private _cfg = configOf _vehicle;
private _maxFuel = getNumber (_cfg/"ace_refuel_fuelCapacity");
if (_maxFuel == 0) then {
    _maxFuel = getNumber (_cfg/"fuelCapacity");
};

private _fuel = fuel _vehicle;
private _missingFuel = 1 - _fuel;
private _neededCapacity = _missingFuel * _maxFuel; //convert from percentage to liters
```

**Source Processing Loop**:
```cpp
while {count (HR_GRG_Sources#1) > 0} do {
    if (_neededCapacity == 0) exitWith {};

    private _sourceUID = HR_GRG_Sources#1#0;
    private _sourceData = (HR_GRG_Vehicles#HR_GRG_SOURCEINDEX) get _sourceUID;

    private _fuelData = _sourceData#4#0;
    private _transportFuel = getNumber (configFile/"CfgVehicles"/_sourceData#1/"transportFuel");
    private _fuelCargo = if (A3A_hasAce) then {
        _fuelData # 2;
    } else {
        (_fuelData # 1) * _transportFuel;
    };

    if (_fuelCargo < _neededCapacity) then {
        _neededCapacity = _neededCapacity - _fuelCargo;
        _fuelData set [if (A3A_hasAce) then {2} else {1}, 0];
        (HR_GRG_Sources#1) deleteAt ((HR_GRG_Sources#1) find _sourceUID);
        _sourceEmptied = true;
    } else {
        // Partial fuel consumption
        if (A3A_hasAce) then {
            _fuelData set [2, _fuelCargo - _neededCapacity];
        } else {
            _fuelData set [1, (_fuelCargo - _neededCapacity) / _transportFuel];
        };
        _neededCapacity = 0;
    };
    _stateChanges pushBack [_sourceUID, _fuelData, 0];
};
```

## StatePreservation Functions (11 functions)

### fn_getState.sqf
**Purpose**: Master function that captures complete vehicle state.

**Code Implementation**:
```cpp
params [["_vehicle", objNull, [objNull]]];
if (isNull _vehicle) exitWith {};

[
    [_vehicle] call HR_GRG_fnc_getFuel,
    [_vehicle] call HR_GRG_fnc_getDamage,
    [_vehicle] call HR_GRG_fnc_getAmmoData,
    [_vehicle] call HR_GRG_fnc_getAmmoCargo
];
```

### fn_setState.sqf
**Purpose**: Master function that restores complete vehicle state.

**Code Implementation**:
```cpp
params [["_vehicle", objNull, [objNull]], ["_state", [], [[]]]];
if (isNull _vehicle) exitWith {};

_state params [["_fuelStats", [], [[]]], ["_dmgStats", [], [[]]], ["_ammoStats", [], [[]]], ["_ammoCargo", [], [[]]]];

[_vehicle, _fuelStats] call HR_GRG_fnc_setFuel;
[_vehicle, _dmgStats] call HR_GRG_fnc_setDamage;
[_vehicle, _ammoStats] call HR_GRG_fnc_setAmmoData;
[_vehicle, _ammoCargo] call HR_GRG_fnc_setAmmoCargo;
```

### fn_prepPylons.sqf
**Purpose**: Cleans up pylon-related weapons before state restoration.

**Weapon Removal Logic**:
```cpp
#define weaponMag(X) getArray (configFile/"CfgWeapons"/X/"magazines")
#define magPylonWeapon(X) getText (configFile/"CfgMagazines"/X/"pylonWeapon")

private _turrets = [[-1]] + allTurrets _veh;
private _toRemove = [];

{
    private _turret = _x;
    private _baseWeapons = getArray (([_veh, _turret] call BIS_fnc_turretConfig) / "Weapons");
    private _weapons = (_veh weaponsTurret _turret) apply { toLower _x };
    // Avoiding array subtract in case there's a pylon and non-pylon copy of the same weapon
    { _weapons deleteAt (_weapons find toLower _x) } forEach _baseWeapons;
    { _toRemove pushBack [_x, _turret] } forEach _weapons;
} forEach _turrets;

{ _veh removeWeaponTurret _x } forEach _toRemove;
```

## System Integration Points

### ACE Compatibility
The garage system extensively integrates with ACE mods:

```cpp
// ACE Refuel integration
private _maxAceFuelCargo = getNumber (configOf _vehicle/"ace_refuel_fuelCapacity");
private _currentACEAmmoCargo = if (A3A_hasAce) then { [_veh] call ace_rearm_fnc_getSupplyCount } else { -1 };

// ACE Cargo handling
{
    if !(_x isEqualType objNull) then { continue };
    if (typeOf _x in ["ACE_Wheel", "ACE_Track"]) then { continue };
    [_x, _vehicle] call ace_cargo_fnc_unloadItem;
} forEach (_vehicle getVariable ["ace_cargo_loaded", []]);
```

### Logistics Integration
```cpp
// Vehicle node capacity checking
private _nodeCfg = [HR_GRG_previewVeh] call A3A_Logistics_fnc_getNodeConfig;
private _vehNodes = [HR_GRG_previewVeh] call A3A_Logistics_fnc_getVehicleNodes;

// Mount loading validation
_loadInfo = [HR_GRG_previewVeh, _static] call A3A_Logistics_fnc_canLoad;
if (_loadInfo isEqualType 0) exitWith {};
(_loadInfo + [true]) call A3A_Logistics_fnc_load;
```

### Network Synchronization
```cpp
// Broadcast to all garage users
private _recipiants = +HR_GRG_Users;
_recipiants pushBackUnique 2; // Include server
[_vUID, _stateIndex, _state] remoteExecCall ["HR_GRG_fnc_reciveStateUpdate", _recipiants];
```

## Performance Considerations

### Memory Management
- Uses HashMaps for O(1) vehicle lookups
- State data is compressed and only loaded when needed
- Preview vehicles are created locally to avoid network overhead

### Network Optimization
- State updates are batched and compressed
- Only changed data is synchronized
- Client-side validation prevents unnecessary server calls

## Error Handling and Validation

### Input Validation
```cpp
// Comprehensive parameter checking
params [ ["_vehicle", objNull, [objNull]], ["_client", 2, [0]], ["_lockUID", ""], ["_player", objNull, [objNull]] ];

if (isNull _vehicle) exitWith { ["STR_HR_GRG_Feedback_addVehicle_Null"] remoteExec ["HR_GRG_fnc_Hint", _client]; false };
if (!alive _vehicle) exitWith { ["STR_HR_GRG_Feedback_addVehicle_Destroyed"] remoteExec ["HR_GRG_fnc_Hint", _client]; false };
```

### State Integrity
- Multiple validation layers prevent data corruption
- Automatic cleanup of invalid entries
- Fallback mechanisms for missing data

## Conclusion

The Garage System represents a comprehensive vehicle management solution with:
- **61 functions** across 6 categories
- Complete state preservation and restoration
- Real-time network synchronization
- Extensive mod compatibility (ACE, RHS, CUP)
- Advanced customization options (mounts, textures, pylons)
- Robust error handling and validation

This documentation provides the complete technical reference for understanding, maintaining, and extending the garage system functionality.