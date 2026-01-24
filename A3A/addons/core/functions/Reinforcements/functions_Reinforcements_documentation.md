Function Name: fn_landHelicopter
File: A3A/addons/core/functions/Reinforcements/fn_landHelicopter.sqf

What it does:
This function orchestrates a scripted landing sequence for a helicopter. It forces a helicopter to fly through a series of predefined waypoints (positions, directions, velocities, and orientations) to achieve a smooth landing on a specified helipad. It is primarily used in reinforcement missions to simulate AI helicopter landings where the helicopter's crew is deactivated (disableAI "MOVE") and the flight path is controlled entirely by scripted transformations to ensure precision.

Additional context:

Called by mission scripts handling reinforcement logistics or AI support (e.g., reinforcementsAI.sqf).
Typically used when an AI-controlled helicopter needs to land at a base or mission objective without player intervention.
Relies on the onEachFrame handler for frame-by-frame execution, which is resource-intensive and should be terminated properly.
How it does that:
1. Parameter Extraction and Variable Initialization
The function (though commented out) expects two parameters: _helicopter (the vehicle object) and _helipad (the target object/position). In the current implementation, these are referenced via global-like variables heli and pad (likely set by the calling function). It calculates the initial flight state and defines the landing path.

Code Snippet:

Sqf

Apply
//params ["_helicopter", "_helipad"];

_pos = (getPosASL pad);
_dir = getDir pad;
_dirVector = vectorDir pad;
_dirVector2D = +_dirVector;
_dirVector2D set [2, 0];
_upVector = vectorUp pad;

_heliPos = getPosASL heli;
_heliSpeed = velocity heli;

_heliHeigth = (_heliPos select 2) - (_pos select 2);
Explanation:

pos: The ASL (Above Sea Level) position of the helipad (pad).
dir, dirVector, dirVector2D: The direction and directional vector of the helipad. _dirVector2D is a horizontalized version (z-component set to 0) for 2D calculations.
upVector: The up orientation of the helipad.
heliPos, heliSpeed: Current ASL position and velocity of the helicopter.
heliHeigth: Altitude difference between the helicopter and the helipad. This defines the initial descent height.
2. Defining the Landing Waypoints
The function creates three intermediate waypoints (_prePos, _secPos, and the final landing position _pos) and defines corresponding velocities, directions, and up-vectors for each segment. The timeline is divided into four phases, each with a duration calculated based on the helicopter's initial height and velocity.

Code Snippet:

Sqf

Apply
//That has to be based on the velocity
_prePos = _pos vectorAdd (([0,0,1] vectorMultiply (_heliHeigth + 5)) vectorAdd (_dirVector2D vectorMultiply -15));
_secPos = _pos vectorAdd (([0,0,1] vectorMultiply _heliHeigth) vectorAdd (_dirVector2D vectorMultiply - 5));
_midDir = [0,0,1] vectorAdd (_dirVector2D vectorMultiply 2);
_midUp = _dirVector2D vectorAdd ([0,0,1] vectorMultiply 2);

//Needs to be based on velocity
tArray = [time, time + 3, time + 5, time + 20];
posArray = [_heliPos, _prePos, _secPos, _pos];
speedArray = [_heliSpeed, (_dirVector2D vectorMultiply 10), [0,0,-3], [0,0,0]];
dirArray = [vectorDir heli, _midDir, _dirVector2D, _dirVector];
upArray = [vectorUp heli, _midUp, [0,0,1], _upVector];
counter = 1;
Explanation:

_prePos: An approach point 15 meters behind the landing spot (_dirVector2D * -15) and at an altitude 5 meters higher than the landing altitude.
_secPos: A point 5 meters behind the landing spot and at the same altitude as the landing (the final approach glide path).
_midDir/_midUp: Intermediate orientation vectors for smooth transitions.
tArray: Timestamps for each phase. The durations (3, 5, 20 seconds) are hardcoded but depend on time (current server time).
posArray: ASL positions for each phase.
speedArray: Velocity vectors for each phase (starts with current velocity, ends at 0).
dirArray/upArray: Direction and up vectors for each phase.
counter: Index to track the current phase (starts at 1, corresponding to the second waypoint).
3. Crew Deactivation
The helicopter's crew (pilot, gunners) are instructed to stop controlling movement. This ensures they don't interfere with the scripted flight path.

Code Snippet:

Sqf

Apply
{
    _x disableAI "MOVE";
} forEach (crew heli);
Explanation:

Iterates over all crew members of heli and disables their MOVE AI capability. This prevents them from attempting to fly the helicopter manually, making the scripted onEachFrame movement the sole controller.
4. Frame-by-Frame Transformation via onEachFrame
The core logic is executed in the onEachFrame scope, which runs every rendered frame. It interpolates between the defined waypoints based on a linear time conversion.

Code Snippet:

Sqf

Apply
onEachFrame
{
  _t1 = tArray select (counter - 1);
  _t2 = tArray select counter;
  _interval = linearConversion [_t1, _t2, time, 0, 1];

  _curPos = posArray select (counter - 1);
  _nextPos = posArray select counter;

  _curSpeed = speedArray select (counter - 1);
  _nextSpeed = speedArray select counter;

  _curDir = dirArray select (counter - 1);
  _nextDir = dirArray select counter;

  _curUp = upArray select (counter - 1);
  _nextUp = upArray select counter;

  heli setVelocityTransformation
  [
    _curPos,
    _nextPos,
    _curSpeed,
    _nextSpeed,
    _curDir,
    _nextDir,
    _curUp,
    _nextUp,
    _interval
  ];
Explanation:

_t1, _t2: Start and end times of the current phase.
_interval: A value from 0 to 1, calculated based on current time (time) relative to _t1 and _t2. This is the interpolation factor.
setVelocityTransformation: Applies a kinematic transformation to heli. It smoothly changes:
Position from _curPos to _nextPos.
Velocity from _curSpeed to _nextSpeed.
Direction from _curDir to _nextDir.
Orientation (up vector) from _curUp to _nextUp.
The interval controls the interpolation progress.
5. Landing Condition and Phase Advancement
During the flight, the function checks for two conditions:

Landing Engine Stop: When the helicopter is within 10 meters of the helipad height, the engine is turned off to simulate touchdown.
Phase Transition: When the current time (time) exceeds the target time (tArray select counter), it advances to the next phase. If all phases are complete, the onEachFrame handler is cleared to stop execution.
Code Snippet:

Sqf

Apply
  if((((getPosASL heli) select 2) - ((getPosASL pad) select 2)) < 10) then
  {
    heli engineOn false;
  };

  if(time > (tArray select counter)) then
  {
    counter = counter + 1;
    if(counter >= count tArray) then
    {
      onEachFrame {};
    };
  };
};
Explanation:

The altitude check is done in ASL (Assumed Sea Level), which is accurate for relative height.
heli engineOn false; turns off the engine physically, causing the helicopter to settle on the ground.
When time passes the current phase's end time, counter increments. If counter reaches the end of the arrays (i.e., phase 3 is finished), onEachFrame is set to an empty code block {}, terminating the loop and the function's active control.
Where it leads:
Functions Called:
crew heli: Returns an array of all units in the helicopter (pilot, gunners, cargo). No direct function call, but a built-in command.
vectorDir, vectorUp, getPosASL, velocity: Built-in Arma 3 commands for retrieving object state.
disableAI: Command used to prevent AI actions.
linearConversion: Built-in command for linear interpolation, used to calculate the interpolation interval between time points.
setVelocityTransformation: Core command that applies the kinematic transformation. This is the critical command that moves the helicopter.
engineOn: Command to control the helicopter's engine state.
Functions Depending on This One:
reinforcementsAI.sqf: This is the most likely caller, as it handles AI reinforcement waves and may use fn_landHelicopter to land support aircraft.
Any mission script (e.g., in Missions class) that requires scripted helicopter landings for AI reinforcements.
System Integration:
This function is part of the Reinforcements system, which is responsible for spawning and directing AI support units.
It ensures that helicopters land in a controlled, predictable manner, avoiding random AI behavior that could lead to crashes or missed landings.
The use of onEachFrame makes it a real-time, non-scheduled function (though it runs in the unscheduled environment of the event handler), which must be managed carefully to avoid performance issues if not terminated.
Global Variables Modified:
tArray, posArray, speedArray, dirArray, upArray: Global arrays defined in the function's scope. They are used by the onEachFrame handler.
counter: Global integer tracking the current phase.
heli, pad: The function assumes these are global variables (or set in the calling scope) referencing the helicopter and helipad objects.
Synchronization/Network Implications:
Unscheduled Environment: The function runs in the unscheduled environment (due to onEachFrame), which means it executes immediately every frame. This is server-side if called from server scripts.
Object Synchronization: Since it manipulates heli directly, and heli is a physical object, the transformations are likely network-synced to all clients (depending on object locality). However, setVelocityTransformation is a local command; if run on the server, it should update the network object for clients, but care must be taken as the timing might differ between server and client frames.
Performance: onEachFrame is resource-heavy. The function terminates itself after ~20 seconds, but if called frequently, it could contribute to lag.
Error Handling: There is no explicit error handling (e.g., checking if heli or pad exist). If either object is null, the script would likely throw errors or behave unpredictably.
Requirements & Edge Cases:
Parameter Validation: None present. Assumes heli and pad are valid objects. If pad is missing, getPosASL will fail. If heli is empty or dead, crew will be empty, and setVelocityTransformation may not work.
Edge Cases:
Helicopter already landed: _heliHeigth might be small or negative, causing incorrect waypoint calculations.
Helipad orientation: The function uses the helipad's orientation, but if the helipad is not properly aligned (e.g., rotated sideways), the helicopter will attempt to land in that orientation, potentially causing a crash or odd landing.
Hardcoded timings: The phase durations (3, 5, 20 seconds) are fixed and may not suit all helicopter types or distances. A helicopter starting farther away may need longer times.
Collisions: The path is linear; it does not account for terrain or obstacles between waypoints, which could cause mid-air collisions.
Client-Server Consistency: If time is used (server time vs. client time), there might be desync in timing. In Arma, time is usually synchronized, but frame rate differences can affect interpolation.
Error Handling: Lacks try-catch or null checks. If setVelocityTransformation fails (e.g., for dead vehicles), it would silently fail.
Termination: The function relies on the onEachFrame condition to terminate. If the helicopter is destroyed mid-flight, the loop might continue, attempting to transform a null object, which is undefined behavior.
Complete Flow Summary:
Input: Assumes heli and pad are set globally.
Calculate Initial State: Get ASL positions, velocities, and vectors.
Define Path: Compute intermediate waypoints (_prePos, _secPos) and assign timings, positions, speeds, directions, and up-vectors to arrays.
Disable AI: Prevent crew from interfering.
Start Frame Loop: Use onEachFrame to:
Calculate interpolation factor for the current phase.
Apply setVelocityTransformation with interpolated values.
Check for landing (engine off when near ground).
Advance phase when time elapses.
Terminate when all phases are complete.
Output: Helicopter is moved to the helipad, orientation matches the helipad, engine is off, and movement AI is disabled.