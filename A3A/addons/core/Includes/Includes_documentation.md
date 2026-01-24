File: A3A/addons/core/Includes/cba_settings.sqf
This file contains CBA (Community Base Addons) Settings. It is not a function file but a configuration file used to force specific mod settings for the server. These settings apply globally to all clients and ensure a standardized experience for the Antistasi mission.

What it does: Overrides the default values of settings from various mods (Task Force Arrowhead Radio, ACE) to values compatible with the Antistasi gameplay loop.

Implementation Details: The file uses the force command. In CBA settings, force sets the value and prevents clients from changing it locally. This ensures that radio frequencies, captivity mechanics, and UI elements behave exactly as the mission designers intended.

1. Task Force Arrowhead Radio (TFAR) Settings

Purpose: Configures radio logistics and frequency standardization.
Settings:
force TF_give_microdagr_to_soldier = false;: Prevents standard soldiers from receiving the microDAGR GPS device (reserved for leadership or specialized roles).
force TF_give_personal_radio_to_regular_soldier = true;: Ensures every infantryman gets a short-range radio (SR).
force TF_no_auto_long_range_radio = true;: Prevents auto-assignment of long-range (LR) radios; these must be manually carried (logistics mechanic).
force TF_same_*_frequencies_for_side = true;: Forces all units on the same side (e.g., all Independents) to share radio frequencies, enabling side-wide communication.
2. TFAR Beta Settings

Purpose: Configures the newer version of the radio mod.
Settings:
force TFAR_giveLongRangeRadioToGroupLeaders = false;: Disables auto-giving of LR radios to squad leaders (relying on logistics to provide them).
force TFAR_SameLRFrequenciesForSide = true;: Standardizes long-range frequencies per side.
3. ACE Captives Settings

Purpose: Configures the interaction system for surrendering and handcuffing.
Settings:
force ace_captives_allowHandcuffOwnSide = false;: Prevents friendly fire (handcuffing teammates).
force ace_captives_allowSurrender = false;: Disables manual surrendering by players (controlled by mission logic).
force ace_captives_requireSurrender = 2;: Requires 2 interactions (key presses) to force a surrender on an AI.
force ace_captives_requireSurrenderAi = true;: AI must be physically restrained or told to surrender.
4. ACE Crew Served Weapons

Purpose: Configures static weapon handling.
Settings:
force ace_csw_defaultAssemblyMode = false;: Disables automatic assembly of tripods and weapons (requires manual setup).
force ace_csw_handleExtraMagazines = false;: Disables automatic magazine handling for crew-served weapons (uses standard inventory).
5. ACE User Interface

Purpose: Configures HUD elements.
Settings:
force ace_ui_groupBar = true;: Enables the group status bar on the HUD.
6. ACEX Headless

Purpose: Configures AI processing.
Settings:
force acex_headless_enabled = false;: Disables Headless Client support (AI processing remains on the server).
File: A3A/addons/core/Includes/common.inc
This file is a C/C++ style preprocessor header designed to include commonly used definitions and macros across the codebase. It centralizes dependencies to reduce code duplication.

1. FIX_LINE_NUMBERS Macros

Function Name: FIX_LINE_NUMBERS2 / FIX_LINE_NUMBERS
Purpose: Ensures that compiler error messages reference the correct file and line number of the source file, rather than the included header file. This is critical for debugging.
Implementation:
Code:
Sqf

Apply
#define FIX_LINE_NUMBERS2(sharp) sharp##line __LINE__ __FILE__
#define FIX_LINE_NUMBERS() FIX_LINE_NUMBERS2(#)
Logic: Uses token concatenation (##) to generate the #line preprocessor directive. __LINE__ and __FILE__ are standard preprocessor macros representing the current line and file.
Usage: Must be called immediately after including files to reset the error context.
2. Faction Macros

Function Name: Faction
Purpose: Maps a side variable (west, east, etc.) to a global faction hashmap variable (A3A_faction_occ, etc.).
Implementation:
Code:
Sqf

Apply
#define Faction(SIDE) (switch SIDE do {
    case west:{A3A_faction_occ};
    case east:{A3A_faction_inv};
    case resistance:{A3A_faction_reb};
    case civilian:{A3A_faction_civ};
    case opfor:{A3A_faction_riv};
    default {Error_1("Bad side passed passed to Faction(side), Side: %1", SIDE); createHashMap};
})
Logic: Uses a switch statement to map the input SIDE to the correct global hashmap.
Error Handling: If an invalid side is passed, it triggers an Error_1 macro (from LogMacros.inc) and returns an empty createHashMap to prevent script crashes.
Called Functions:
Error_1: Logs the error regarding the invalid side.
3. FactionGet Macros

Function Name: FactionGet
Purpose: Retrieves a value from a specific faction's hashmap.
Implementation:
Code:
Sqf

Apply
#define FactionGet(FAC, VAR) (A3A_faction_##FAC get VAR)
Logic: Uses token pasting (##) to construct the variable name (e.g., A3A_faction_occ) and performs a hashmap get operation.
4. FactionGetTiered Macro

Function Name: FactionGetTiered
Purpose: Retrieves tiered data (Early, Mid, Late game) based on the global tierWar variable.
Implementation:
Code:
Sqf

Apply
#define FactionGetTiered(FAC, VAR) (switch true do {
    case (tierWar < 5):{(A3A_faction_##FAC get VAR) select 0};
    case (tierWar < 8 && {tierWar > 4}):{(A3A_faction_##FAC get VAR) select 1};
    case (tierWar > 7):{(A3A_faction_##FAC get VAR) select 2};
    default {Error("Something wrong.");""};
})
Logic:
Checks the global variable tierWar (represents the progression of the war).
tierWar < 5: Early game (selects index 0 of the array stored in the hashmap).
tierWar 5-8: Mid game (index 1).
tierWar > 7: Late game (index 2).
Returns a string "" on failure.
Dependencies: Requires tierWar to be defined globally. Requires the value stored in the hashmap to be an array with at least 3 elements.
5. Feature Toggles

Purpose: Defines compile-time flags to enable/disable experimental features.
Implementation:
Code:
Sqf

Apply
// #define UseDoomGUI
#define UseDoomGUIPreview
Logic: UseDoomGUI is commented out (disabled). UseDoomGUIPreview is active, likely enabling specific segments of a new UI system.
File: A3A/addons/core/Includes/includesBasics.txt
This is a documentation file, not executable code. It explains the syntax for the preprocessor #include directive used in the rest of the codebase.

Content Breakdown:

Standard Include Syntax:

Description: Explains that #include "filepath" embeds the contents of the target file into the current file during compilation.
Context: Includes are relative to the file using them, not the root project directory.
Navigating Directories:

Description: Explains how to traverse the directory tree using .. (parent directory).
Example: #include "..\script_component.hpp" moves up one folder level.
Logic: This is essential for including shared headers (like 
LogMacros.inc
) from deeper subdirectories (e.g., Functions/Folder/File.sqf needing to include Includes/LogMacros.inc).
Antistasi Specific Pathing:

Description: Provides a concrete example for typical Antistasi function structures.
Example: #include "..\..\script_component.hpp" moves up two levels (out of the function subfolders) to access the core includes.
File: A3A/addons/core/Includes/LogMacros.inc
This is a comprehensive logging library providing compile-time configurable macros for debugging and error tracking. It handles server/client synchronization and log formatting.

1. Configuration Variables

_LOG_prefix "Antistasi": The tag prepended to every log entry.
VARDEF(Var, Def): A utility macro that checks if a variable is nil; if so, it returns Def, otherwise returns Var. Used for defaulting log levels.
2. _LOG_breakUpLogLine

Purpose: Prevents RPT (Realtime Performance Tool) log truncation by splitting long messages (>1020 chars) into multiple lines.
Implementation:
Logic:
Checks if the log line is short enough (1020 chars). If yes, returns immediately.
If too long, enters a while loop.
Tries to find a space or comma near the 980th character to split cleanly (prevents cutting words in half).
If no delimiter is found, forces a cut at 1020 characters.
Prepends >>> to continuation lines to visually link them.
Return: An array of log line segments.
3. _LOG_STANDARD_FORMAT

Purpose: Constructs the standardized log header.
Format: {Time UTC} | {Prefix} | {Level} | File: {filename} | {Message} | Called By: {ParentScript}
Logic:
Uses systemTimeUTC and A3A_fnc_systemTime_format_S (external function) for time.
Extracts filename from __FILE__ if _fnc_scriptName is not available.
Includes _fnc_scriptNameParent if available (traces the call stack).
4. _LOG_Message and _LOG_ServerMessage

_LOG_Message: Formats the message and outputs to the local RPT via diag_log.
_LOG_ServerMessage:
Server Side: Acts like _LOG_Message.
Client Side: Formats the message, appends Client ID/Player info, and sends it to Server ID 2 (server) using remoteExec ["A3A_fnc_localLog", 2]. This centralizes client logs on the server.
5. Log Level Macros (Error, Warning, Info, Debug, Trace, Verbose) Each log level is wrapped in #ifdef Log_LevelName blocks. If the specific Log_LevelName is not defined, the macros become empty (no-op), optimizing performance.

Error Macros (Error, Error_1...Error_8, ServerError, etc.)

Logic:
Sqf

Apply
#define Error(Message) if (0 < VARDEF(LogLevel,4)) then { ... }
Behavior:
Checks LogLevel (default 4). Errors (Level 1) always pass if LogLevel > 0.
Logs locally via _LOG_Message.
If not server, logs remotely via _LOG_ServerMessage (ensures errors are seen by admins even if client doesn't notice).
Variants:
Error_N: Accepts N arguments for format string interpolation.
ErrorArray: Logs an array by joining elements with newlines for readability.
ErrorArrayFormat: Applies a specific format string to each array element before logging.
Warning Macros

Logic: Similar to Error but uses "Warning" level. Does not force remote logging to server (unlike Error).
Info Macros

Logic: Checks if (1 < VARDEF(LogLevel,4)). Only logs if LogLevel is 2 or higher.
Scope: Local only (no remote execution to server).
Debug Macros

Logic: Checks if (2 < VARDEF(LogLevel,4)). Only logs if LogLevel is 3 or higher.
Scope: Local only.
Trace Macros

Logic: Checks if (2 < VARDEF(LogLevel,4)) AND #ifdef Log_Trace (which is only defined if __A3_DEBUG__ is active).
Purpose: Extremely verbose logging for deep debugging (e.g., loop iterations).
Verbose Macros

Logic: Checks if (3 < VARDEF(LogLevel,4)). Highest detail level (Level 4).
File: A3A/addons/core/Includes/performance.inc
This file provides macros for performance profiling (timing code execution). It is conditionally compiled based on the diag_performance define.

Configuration:

#ifndef diag_performance: Defaults to 0 (disabled). Must be defined as 1 in the including file to activate.
1. startCounter / stopCounter

Purpose: Measures the execution time of a single block of code.
Implementation:
startCounter(X):
Sqf

Apply
#define startCounter(X) HR_performanceCounter_##X = diag_tickTime;
Logic: Stores the current tick time in a global variable HR_performanceCounter_X.
stopCounter(X):
Sqf

Apply
#define stopCounter(X) \
    private _HR_perf_counter_time = diag_tickTime; \
    if (isNil {HR_performanceCounter_##X}) then { ... } else { ... }; \
    HR_performanceCounter_##X = nil;
Logic:
Captures end time.
Checks if startCounter was called (variable exists).
Calculates delta: (EndTime - StartTime) * 1000 (converts to ms).
Logs the result via diag_log.
Cleans up the global variable to nil to prevent memory leaks.
2. startBatch / markBatch / stopBatch

Purpose: Measures multiple phases within a single process.
Implementation:
startBatch(X):
Sqf

Apply
#define startBatch(X) HR_performanceBatch_##X = []; HR_performanceBatch_##X##_startTime = diag_tickTime;
Logic: Initializes an array to hold marks and stores the start time.
markBatch(X, C):
Sqf

Apply
#define markBatch(X, C) if (!isNil {HR_performanceBatch_##X}) then {HR_performanceBatch_##X pushBack [C, diag_tickTime]};
Logic: Pushes a tuple [Comment, Time] into the batch array.
stopBatch(X, C):
Sqf

Apply
#define stopBatch(X, C) \
    private _HR_perf_CurTime = diag_tickTime; \
    if (isNil {HR_performanceBatch_##X} || {isNil {HR_performanceBatch_##X##_startTime}}) then { ... } else { \
        HR_performanceBatch_##X pushBack [C, _HR_perf_CurTime]; \
        private _deltaTime = HR_performanceBatch_##X##_startTime; \
        diag_log text ("Performance Batch | " + #X + " | Time: " + str ((_Hr_perf_CurTime - HR_performanceBatch_##X##_startTime) * 1000) +" ms | [" + endl + (HR_performanceBatch_##X apply { \
            _deltaTime = (_x select 1) - _deltaTime; \
            "    " + (_x select 0) + ": " + str (_deltaTime * 1000 ) + " ms" + endl \
        } joinString "") + "]") \
    }; \
    HR_performanceBatch_##X = nil; \
    HR_performanceBatch_##X##_startTime = nil;
Logic:
Adds the final mark.
Iterates through the HR_performanceBatch_X array.
Calculates delta time between sequential marks (e.g., Time between "Phase 1" and "Phase 2").
Generates a formatted string listing each phase and its duration.
Logs the full report.
Cleans up global variables.
Where it leads / System Fit: These macros are typically used in init.sqf or server-side loops (like initServer.sqf) to identify bottlenecks in the mission initialization or heavy AI calculation loops. They do not call external functions but rely on diag_tickTime and diag_log.