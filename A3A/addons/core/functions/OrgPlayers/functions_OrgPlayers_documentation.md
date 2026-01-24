Function Name: fn_addMoneyPlayer.sqf
What it does: This function adds a specified amount of money to a player's internal money variable. It handles both the financial update and provides a visual notification to the player regarding the money gain (unless silenced). It ensures only valid players (teamPlayer or civilian side) receive money.

How it does that:

Parameter Validation: The function first accepts parameters: _moneyToAdd, _player, and an optional _isSilent (defaulting to false).

Sqf

Apply
params ["_moneyToAdd", "_player", ["_isSilent", false]];
It then performs a sanity check: if the target is not a player unit or if the side is not teamPlayer or civilian, the function exits immediately without action.

Sqf

Apply
if (!isPlayer _player || {!(side _player in [teamPlayer, civilian])}) exitWith {};
Variable Initialization and Calculation: It resolves the player object (in case of remote control) and retrieves the current stored money.

Sqf

Apply
_player = _player getVariable ["owner",_player];
private _storedMoney = _player getVariable ["moneyX",0];
It adds the new amount to the existing total.

Sqf

Apply
_storedMoney = _storedMoney + _moneyToAdd;
State Update and Synchronization: It updates the global variable on the player object with the new total. The true argument ensures this value is synchronized across the network to the server and other relevant clients.

Sqf

Apply
_player setVariable ["moneyX",_storedMoney, true];
Notification Logic: If the money added is greater than 1, it checks if the notification is silenced.

Non-Silent: It constructs a formatted HTML hint string using the localize command for internationalization and appends the currency symbol from A3A_faction_civ.
It then calls A3A_fnc_commsMP to send a "income" message via the MP communications system to the specific player.
Silent: It executes A3A_fnc_statistics locally on the player to update the UI without a pop-up message.
Sqf

Apply
if (_moneyToAdd > 1) then {
    if (!_isSilent) then {
        _textX = format [
            "<br/><br/><br/><br/><br/><br/>%1 <t color='#00FF00'>+%2%3</t>", 
            (localize "STR_antistasi_actions_common_notifications_money_found_title"), 
            _moneyToAdd,
            A3A_faction_civ get "currencySymbol"
        ];
        [petros,"income",_textX] remoteExec ["A3A_fnc_commsMP",_player];
    } else {
        [] remoteExec ["A3A_fnc_statistics",_player];
    };
};
Where it leads:

Called Functions:
A3A_fnc_commsMP: Used to send the money notification message to the player's screen.
A3A_fnc_statistics: Used to update the player's stats display (money count) if the action is silent.
Dependencies: Relies on the global variable A3A_faction_civ existing and containing the currencySymbol key.
System Fit: Part of the economy system. Called when players loot bodies, complete missions, or receive passive income.
Global Variables: Modifies _player moneyX. Reads A3A_faction_civ.
Network Implications: setVariable with true synchronizes moneyX to the server. remoteExec triggers code execution on the client of _player.
Function Name: fn_addScorePlayer.sqf
What it does: Adds points to a player's score variable, ensuring the score never drops below zero. It acts as a wrapper for the score system, providing validation and sanitization of the input.

How it does that:

Parameter Validation: Accepts _scoreToAdd and _player. Checks if the target is a valid player unit on allowed sides.

Sqf

Apply
params ["_scoreToAdd", "_player"];
if (!isPlayer _player || {!(side _player in [teamPlayer, civilian])}) exitWith {};
Variable Resolution and Calculation: Resolves the owner (for remote control) and fetches the current score.

Sqf

Apply
_player = _player getVariable ["owner",_player];
private _storedPoints = _player getVariable ["score",0];
Performs the addition.

Sqf

Apply
_scoreToAdd = _storedPoints + _scoreToAdd;
Sanitization (Floor Check): Ensures the resulting score is not negative. If the calculation results in a negative number, it forces the score to 0.

Sqf

Apply
if (_scoreToAdd < 0) then {
    _scoreToAdd = 0;
};
State Update and Synchronization: Applies the calculated score to the player variable with network synchronization.

Sqf

Apply
_player setVariable ["score",_scoreToAdd,true];
Where it leads:

Called Functions: None directly called within this function.
Dependencies: Relies on A3A_fnc_numericRank (indirectly) for rank calculation logic elsewhere, as score determines rank.
System Fit: Used by the reputation and ranking system. Triggered by mission completion, donations, or specific actions (like stealing from the boss).
Global Variables: Modifies _player score. Reads _player owner.
Network Implications: setVariable with true syncs the score to the server.
Function Name: fn_assignBossIfNone.sqf
What it does: This function runs an election to determine a new commander (Boss) for the rebel faction. It is called when the current commander is invalid, inactive, or specifically forced (e.g., via menu). It evaluates all eligible players based on rank and membership status to find the best candidate.

How it does that:

Server-Side Guard and Initialization: Restricts execution to the server only. Sets a global lock A3A_electionInProgress to prevent overlapping elections.

Sqf

Apply
if !(isServer) exitWith { Error("Attempted to call server function as non-server") };
params [["_memberForced", false]];
if (!isNil "A3A_electionInProgress") exitWith {};
A3A_electionInProgress = true;
Eligibility Check (Existing Boss): It determines if an election is actually needed. It uses a call block to return a reason string if the current theBoss is still valid. It checks:

Existence of theBoss.
If _memberForced is true, checks if the boss is actually a member.
Checks the eligible variable.
Checks the isAFK variable.
Sqf

Apply
private _electionReason = call {
    if (isNull theBoss || {theBoss isEqualTo ObjNull}) exitWith { "there is no boss" };
    if (_memberForced && !([theBoss] call A3A_fnc_isMember)) exitWith { "the boss is a guest" };
    if !(theBoss getVariable ["eligible", true]) exitWith { "the boss is not eligible" };
    if (theBoss getVariable ["isAFK", false]) exitWith { "the boss is AFK" };
};
If no reason is returned (meaning the boss is valid), it exits the function.

Sqf

Apply
if (isNil "_electionReason") exitWith {
    Debug_1("Not attempting to assign new boss - player %1 is the boss", name theBoss);
    A3A_electionInProgress = nil;
};
Candidate Scoring Loop: Initializes tracking variables _nextBoss and _bossRank. Iterates through allPlayers (excluding Headless Clients).

Sqf

Apply
private _nextBoss = objNull;
private _bossRank = 0;
{
    private _rp = _x getVariable ["owner", _x];
    // ... validation checks ...
} forEach (allPlayers - entities "HeadlessClient_F");
Inside the loop, it filters candidates:

Skips AFK players.
Skips ineligible players.
Skips guests if A3A_guestCommander is disabled.
Calculates a priority _rank based on A3A_fnc_numericRank (returns an array, index 0 is numeric rank).
Adds 1000 points to the rank if the player is a member (prioritizing members).
Updates _nextBoss if the current candidate has a higher rank than the stored best rank.
Boss Assignment: If a valid _nextBoss is found, it calls A3A_fnc_theBossTransfer to actually switch the commander.

Sqf

Apply
if (!isNull _nextBoss) then
{
    Info_1("Player chosen for Boss: %1", name _nextBoss);
    if (theBoss != _nextBoss) then { [_nextBoss] call A3A_fnc_theBossTransfer };
}
If no one is eligible, it logs the failure and removes the current boss by calling A3A_fnc_theBossTransfer with no arguments (or ObjNull).

Cleanup: Ensures theBoss is defined (even if ObjNull) and removes the election lock.

Sqf

Apply
if (isNil "theBoss" || {isNull theBoss}) then {
    theBoss = ObjNull;
    publicVariable "theBoss";
};
A3A_electionInProgress = nil;
Where it leads:

Called Functions:
A3A_fnc_isMember: Checks if a player is a registered member.
A3A_fnc_numericRank: Gets the numerical rank value of a player for comparison.
A3A_fnc_theBossTransfer: Performs the actual transfer of command.
Dependencies: Requires theBoss, membersX, A3A_guestCommander variables.
System Fit: Core command structure system. Triggered by mission start (if no boss), boss inactivity, or admin tools.
Global Variables: Reads/Modifies theBoss, A3A_electionInProgress. Writes publicVariable "theBoss".
Network Implications: publicVariable broadcasts the new boss to all clients.
Function Name: fn_donateMoney.sqf
What it does: Allows a player to donate a fixed amount of money (250) to the faction pool (FIA resources) or a specific player. It handles the deduction from the donor and provides feedback.

How it does that:

Setup and Validation: Defines a constant AMOUNT (250). Gets the player's current money. Checks if the player has enough funds.

Sqf

Apply
#define AMOUNT 250
private _resourcesPlayer = player getVariable "moneyX";
private _amount = AMOUNT;
if (_resourcesPlayer <= 0) exitWith { ... };
Amount Calculation: If the player has less than the standard donation amount (but more than 0), it adjusts the donation amount to their total balance.

Sqf

Apply
if (_resourcesPlayer < _amount && {_resourcesPlayer != 0}) then {
    _amount = _resourcesPlayer;
};
Target Selection:

Faction Donation: If no arguments are passed (count _this == 0), it donates to the server's FIA resources using A3A_fnc_resourcesFIA.
Player Donation: It attempts to identify a target using cursorTarget. If the cursor target is not a player, it errors out.
Sqf

Apply
if (count _this == 0) exitWith { ... Faction Donation Logic ... };
_target = cursorTarget;
if (!isPlayer _target) exitWith { ... };
Transaction Execution: Deducts the amount from the local player's money using A3A_fnc_resourcesPlayer.

Faction Donation: Adds 1 score point and sends the money to the server.
Player Donation: Sends the money to the remote target using remoteExec.
Sqf

Apply
// Faction example
[-_amount] call A3A_fnc_resourcesPlayer;
[0,_amount] remoteExec ["A3A_fnc_resourcesFIA",2];

// Player example
[-_amount] call A3A_fnc_resourcesPlayer;
[_amount] remoteExec ["A3A_fnc_resourcesPlayer", _target];
Notification: Displays a success hint to the donor (and the recipient, in the case of player donation).

Sqf

Apply
[localize "STR_A3A_OrgPlayers_donateMoney_header", ... ] call A3A_fnc_customHint;
Where it leads:

Called Functions:
A3A_fnc_resourcesPlayer: Updates the local player's money.
A3A_fnc_resourcesFIA: Updates the global faction money.
A3A_fnc_customHint: Displays UI feedback.
SCRT_fnc_misc_deniedHint: Displays error messages.
Dependencies: Relies on A3A_faction_civ for currency symbol.
System Fit: Economy and social interaction system.
Global Variables: Modifies moneyX (local/remote) and resourcesFIA (server).
Network Implications: Uses remoteExec to transfer money to other players or the server.
Function Name: fn_donateMoneyPercentage.sqf
What it does: Similar to fn_donateMoney, but allows donating a percentage of the player's current funds rather than a fixed amount. It supports donating to the faction or a specific player.

How it does that:

Parameter Setup: Accepts _unit, _target, _donateToPlayer (boolean), and _moneyPercent (float).

Sqf

Apply
params [
  ["_unit", ObjNull],
  ["_target", ObjNull],
  ["_donateToPlayer", false],
  ["_moneyPercent", 0]
];
Calculation: Calculates the donation amount by rounding the product of current money and the percentage.

Sqf

Apply
private _resourcesPlayer = _unit getVariable "moneyX";
private _amount = round (_resourcesPlayer * _moneyPercent);
Validation: Checks if the player has funds and if the target configuration is valid.

If donating to faction (_donateToPlayer is false and _target is ObjNull), it proceeds to faction logic.
If donating to player but _target is invalid, it errors.
Sqf

Apply
if (_target isEqualTo ObjNull && {_donateToPlayer isEqualTo false}) exitWith { ... Faction Logic ... };
if ((!isPlayer _target || _target isEqualTo ObjNull) && {_donateToPlayer}) exitWith { ... Error ... };
Transaction and Scoring (Faction): When donating to the faction, it calculates score points based on the amount (1 point per 250 currency, rounded). It then updates the player's score and money.

Sqf

Apply
_pointsXJC = round (_resourcesPlayer / 250);
_pointsXJ = (_unit getVariable "score") + _pointsXJC;
_unit setVariable ["score", _pointsXJ, true];
[-_amount] call A3A_fnc_resourcesPlayer;
Transaction (Player): When donating to a player, it simply transfers the money from the donor to the recipient without granting score points.

Sqf

Apply
[-_amount] call A3A_fnc_resourcesPlayer;
[_amount] remoteExec ["A3A_fnc_resourcesPlayer", _target];
Notification: Notifies the donor of the success.

Sqf

Apply
[localize "STR_A3A_OrgPlayers_donateMoney_header", format [localize "STR_A3A_OrgPlayers_donateMoney_success", _amount, ...]] call A3A_fnc_customHint;
Where it leads:

Called Functions:
A3A_fnc_resourcesFIA (Faction donation).
A3A_fnc_resourcesPlayer (Local and remote update).
SCRT_fnc_misc_deniedHint (Error handling).
Dependencies: Requires _unit to be valid and have moneyX.
System Fit: Economy system, often used via UI sliders.
Global Variables: Modifies score and moneyX.
Network Implications: Uses remoteExec for player-to-player transfers.
Function Name: fn_isMember.sqf
What it does: Checks if a given player object is a registered member of the organization. It handles membership logic and ignores remote-controlled AI units.

How it does that:

Global Check: If membershipEnabled is false, all players are treated as members (returns true).

Sqf

Apply
if !(membershipEnabled) exitWith {true};
Parameter Resolution: Accepts _player. Checks if the unit is a remote-controlled AI (by comparing owner variable). If it is an AI unit, it returns false.

Sqf

Apply
if (_player getVariable ["owner", _player] != _player) exitWith {false};
UID Lookup: Retrieves the player's UID (preferring the stored A3A_playerUID, falling back to getPlayerUID) and checks if it exists in the global membersX array.

Sqf

Apply
(_player getVariable ["A3A_playerUID", getPlayerUID _player]) in membersX;
Where it leads:

Called Functions: None.
Dependencies: Requires membershipEnabled (boolean) and membersX (array of UIDs).
System Fit: Core permission system used by fn_assignBossIfNone, fn_memberAdd, etc.
Global Variables: Reads membershipEnabled, membersX, A3A_playerUID.
Network Implications: None (local check).
Function Name: fn_makePlayerBossIfEligible.sqf
What it does: A direct wrapper to attempt to make a specific player the boss, checking their eligibility first. It is usually called by admin actions or specific triggers.

How it does that:

Input Validation: Checks if the player has the eligible variable set to true.

Sqf

Apply
if !(_player getVariable ["eligible", false]) exitWith { ... };
Membership Check: Checks if the guest commander setting allows guests. If not, verifies membership via fn_isMember.

Sqf

Apply
if (!A3A_guestCommander and !(_player call A3A_fnc_isMember)) exitWith { ... };
Transfer Execution: If checks pass, it calls fn_theBossTransfer to perform the actual switch.

Sqf

Apply
[_player] call A3A_fnc_theBossTransfer;
true;
Where it leads:

Called Functions:
A3A_fnc_isMember: Checks membership status.
A3A_fnc_theBossTransfer: Performs the transfer.
Dependencies: Relies on A3A_guestCommander and player eligible variable.
System Fit: Command structure system, used by UI menus and admin tools.
Global Variables: Modifies theBoss (via transfer function).
Network Implications: Triggers theBossTransfer which uses publicVariable.
Function Name: fn_memberAdd.sqf
What it does: Allows an administrator to add or remove a member from the membersX list via an action menu interaction (looking at a target).

How it does that:

Privilege Validation: Checks if the user has admin privileges (serverCommandAvailable "#logout") or is the server. If not, denies access.

Sqf

Apply
if (!(serverCommandAvailable "#logout") and {!isServer}) exitWith { ... };
System Checks: Verifies membershipEnabled is true and membersX is initialized.

Sqf

Apply
if !(membershipEnabled) exitWith { ... };
if (isNil "membersX") exitWith { ... };
Target Validation: Uses cursortarget to find the player. Checks if the target is a player and verifies their current status (adding a member who is already a member is invalid, removing a non-member is invalid).

Sqf

Apply
_target = cursortarget;
if (!isPlayer _target) exitWith { ... };
if ((_action == "add") and {[_target] call A3A_fnc_isMember}) exitWith { ... };
Data Modification:

Add: Pushes the UID to membersX, sets eligible to true.
Remove: Subtracts the UID from membersX.
Sqf

Apply
if (_action == "add") then {
    membersX pushBackUnique _uid;
    _target setVariable ["eligible", true, true];
} else {
    membersX = membersX - [_uid];
};
Synchronization: Publicizes the updated membersX array and plays a success sound.

Sqf

Apply
publicVariable "membersX";
playSound "A3AP_UiSuccess";
Where it leads:

Called Functions:
A3A_fnc_isMember: Checks current status.
A3A_fnc_customHint: Notifies the admin.
SCRT_fnc_misc_deniedHint: Notifies the target (if removed) or admin (if error).
Dependencies: Requires membersX array and membershipEnabled.
System Fit: Membership management system.
Global Variables: Modifies membersX and _target eligible.
Network Implications: publicVariable "membersX" synchronizes the list to all clients.
Function Name: fn_membersList.sqf
What it does: Generates a formatted text string listing all current members and the count of guests in the server.

How it does that:

Initialization: Initializes an empty string _membersText.

Sqf

Apply
private _membersText = "";
Iteration and Filtering: Loops through playableUnits. For each unit, it resolves the owner (to check the actual player, not an AI unit). It checks if the player is a member using fn_isMember.

Sqf

Apply
if (membershipEnabled) then {
    private _countN = 0;
    {
        _playerX = _x getVariable ["owner",objNull];
        if (!isNull _playerX) then {
            if (_playerX call A3A_fnc_isMember) then {
                _membersText = format ["%1%2, ", _membersText, name _playerX]
            } else {
                _countN = _countN + 1
            };
        };
    } forEach (playableUnits);
    ...
};
Formatting: Uses a localized string format to insert the member list and guest count.

Sqf

Apply
_membersText = format [localize "STR_commander_menu_server_members_guests", _membersText, _countN];
Fallback: If membership is disabled, it returns a specific localized string indicating this.

Sqf

Apply
} else {
    _membersText = localize "STR_commander_menu_server_members_disabled";
};
Where it leads:

Called Functions:
A3A_fnc_isMember: Used to filter the list.
Dependencies: Requires membershipEnabled and membersX.
System Fit: UI/Display system, likely used in the commander or admin menu.
Global Variables: Reads membershipEnabled, membersX.
Network Implications: None (local generation of text).
Function Name: fn_music.sqf
What it does: Manages the dynamic music system for the player. It handles playing music based on the player's behavior (combat, stealth, night/day) and manages the music event handler for automatic transitions.

How it does that:

Global Toggle Check: Checks the musicON global variable. If off, it fades music out and exits.

Sqf

Apply
if (!musicON) exitWith {
    1 fadeMusic 0.5; playMusic ""
};
Event Handler Initialization: Checks if EHMusic exists. If not, it creates a MusicStop event handler. This handler defines the logic for what happens when a song finishes.

It determines the context (Combat, Stealth, Night, Default).
It selects a random track from a predefined array (excluding the track that just finished to prevent repeats).
It fades in the new music.
Sqf

Apply
if (isNil "EHMusic") then {
    playMusic selectRandom [...];
    EHMusic = addMusicEventHandler ["MusicStop", {
        private _song = "";
        private _behaviour = behaviour player;
        // ... switch case for song selection ...
        1 fadeMusic 0.5;
        playmusic _song;
    }];
};
Immediate Play (If Handler Exists): If the event handler is already active, it manually triggers the selection logic immediately (essentially skipping the current track or starting a new one based on current context).

Sqf

Apply
else {
    private _song = "";
    private _behaviour = behaviour player;
    // ... selection logic ...
    1 fadeMusic 0.5;
    playmusic _song;
};
Where it leads:

Called Functions: None directly, but playMusic is a native command.
Dependencies: Requires musicON (global boolean).
System Fit: Audio/Ambience system.
Global Variables: Reads musicON. Sets EHMusic.
Network Implications: None (local client side only).
Function Name: fn_promotePlayer.sqf
What it does: Scans all playable players, checks their scores against promotion thresholds, and promotes those who qualify. It broadcasts a notification to the server.

How it does that:

Initialization: Prepares a text buffer for the promotion message.

Sqf

Apply
private _textX = "Promoted Players:<br/><br/>";
private _promoted = false;
Player Loop: Iterates through playable units (filtered for teamPlayer/civilian sides).

Sqf

Apply
forEach ((call A3A_fnc_playableUnits) select {(side (group _x) in [teamPlayer, civilian])});
Inside the loop:

Resolves owner.
Gets current score and current rank.
Calculates the potential new rank (_newRank) using A3A_fnc_numericRank.
Skips if already COLONEL.
Threshold Check: Retrieves the required score for the new rank using SCRT_fnc_common_getPromotionThreshold.

Sqf

Apply
private _promotionThreshold = _newRank call SCRT_fnc_common_getPromotionThreshold;
If the player's score exceeds the threshold:

Sets _promoted to true.
Calls A3A_fnc_ranksMP remotely to update the player's rank on their client.
Updates the local rank variable.
Appends the name to the notification text.
Pauses for 5 seconds (staggering promotions).
Notification: If any promotions occurred, it wraps the text in a localized string and broadcasts it using A3A_fnc_commsMP.

Sqf

Apply
if (_promoted) then {
    _textX = format [localize "STR_hints_promotion_congrats",_textX];
    [petros,"hint",_textX, localize "STR_hints_promotion_header"] remoteExec ["A3A_fnc_commsMP"];
};
Where it leads:

Called Functions:
A3A_fnc_playableUnits: Gets the list of players.
A3A_fnc_numericRank: Calculates rank based on score.
SCRT_fnc_common_getPromotionThreshold: Defines rank requirements.
A3A_fnc_ranksMP: Updates the player's rank visually.
A3A_fnc_commsMP: Sends the global notification.
Dependencies: Requires rank definitions and score variables.
System Fit: Progression and ranking system. Usually run periodically by a scheduler.
Global Variables: Reads score and rankX.
Network Implications: Uses remoteExec to update individual players and broadcast messages.
Function Name: fn_radioJam.sqf
What it does: Simulates radio jamming. It checks if the player is within range of an enemy-controlled antenna. If so, it degrades the transmission/reception range (simulated via Task Force Arrowhead Radio or ACRE).

How it does that:

Pre-generation of Mappings: To save performance, it creates a HashMap (_antennaBases) mapping every antenna object to the base/marker it belongs to. This allows instant lookup of the side controlling the antenna.

Sqf

Apply
private _antennaBases = createHashMap;
{
    private _base = [_bases, _x] call BIS_fnc_nearestPosition;
    _antennaBases set [netId _x, _base];
} forEach (antennas + antennasDead);
Interference Function: Defines a helper function _fnc_setInterference that takes reception and sending multipliers.

TFAR: Sets variables tf_receivingDistanceMultiplicator and tf_sendingDistanceMultiplicator.
ACRE: Sets a custom signal function to simulate signal degradation based on distance.
Sqf

Apply
private _fnc_setInterference = {
    params ["_recInterference", "_sendInterference"];
    player setVariable ["tf_receivingDistanceMultiplicator", _recInterference];
    // ... TFAR logic ...
    if(A3A_hasACRE) then { ... ACRE logic ... };
};
Main Loop: Runs every 10 seconds.

Finds live enemy antennas within JAM_RADIUS (1000m) using inAreaArray.
If no jammers are found, sets interference to normal (1, 1).
If jammers exist, finds the nearest one.
Calculates interference based on distance: _interference = 1 + JAM_STRENGTH * (1 - _dist/JAM_RADIUS). Closer = higher interference (weaker signal).
Calls _fnc_setInterference with calculated values.
Sqf

Apply
while {true} do {
    sleep 10;
    private _jammers = antennas inAreaArray [getPosATL player, JAM_RADIUS, JAM_RADIUS];
    _jammers = _jammers select { sidesX getVariable (_antennaBases get netId _x) != _sideX };
    if (_jammers isEqualTo []) then { [1, 1] call _fnc_setInterference; continue; };
    private _jammer = [_jammers, player] call BIS_fnc_nearestPosition;
    private _dist = player distance _jammer;
    private _interference = 1 + JAM_STRENGTH * (1 - _dist/JAM_RADIUS);
    [_interference, 1/_interference] call _fnc_setInterference;
};
Where it leads:

Called Functions:
BIS_fnc_nearestPosition: Finds closest base for an antenna.
Native TFAR/ACRE API calls.
Dependencies: Requires antennas, antennasDead, sidesX, outposts, etc. Requires A3A_hasACRE for mod detection.
System Fit: Radio/Tactical communication system. Runs on loop for active players.
Global Variables: Modifies tf_receivingDistanceMultiplicator, tf_sendingDistanceMultiplicator (local to player). Reads sidesX.
Network Implications: None (local simulation of radio effects).
Function Name: fn_ranksMP.sqf
What it does: A small utility function to set a unit's rank in the game engine and update their statistics display.

How it does that:

Parameter Resolution: Accepts _playerX and _rank. Resolves the owner unit.

Sqf

Apply
_playerX = _playerX getVariable ["owner",_playerX];
Rank Application: Uses the native setRank command to apply the rank (e.g., "SERGEANT") to the unit.

Sqf

Apply
_playerX setRank _rank;
UI Update: Spawns A3A_fnc_statistics to refresh the UI with the new rank.

Sqf

Apply
[] spawn A3A_fnc_statistics;
Where it leads:

Called Functions:
A3A_fnc_statistics: Updates the UI.
Dependencies: None specific.
System Fit: Rank synchronization.
Network Implications: Called via remoteExec to update a specific client's unit rank.
Function Name: fn_resourcesPlayer.sqf
What it does: Updates the local player's money variable. It handles adding/subtracting money, plays a sound on positive changes (if enabled), prevents negative money (floor at 0), and updates the statistics UI.

How it does that:

Audio Feedback: If _hasSound is true and the money change is positive, plays the "3DEN_notificationDefault" sound.

Sqf

Apply
if (_hasSound && {_moneyX > 0}) then {
    playSound "3DEN_notificationDefault";
};
Calculation: Adds the input _moneyX to the current player getVariable "moneyX".

Sqf

Apply
_moneyX = _moneyX + (player getVariable "moneyX");
Sanitization: Ensures the money cannot go below zero.

Sqf

Apply
if (_moneyX < 0) then {_moneyX = 0};
State Update: Sets the new value to the player variable and triggers the UI update.

Sqf

Apply
player setVariable ["moneyX",_moneyX,true];
[] spawn A3A_fnc_statistics;
true
Where it leads:

Called Functions:
A3A_fnc_statistics: Updates UI.
Dependencies: None.
System Fit: Economy utility. Called by buy actions, donations, looting.
Global Variables: Modifies player moneyX.
Network Implications: setVariable with true synchronizes the money to the server.
Function Name: fn_theBossSteal.sqf
What it does: Allows the current commander (Boss) to steal a fixed amount from the faction's main funds into their personal pocket, at the cost of reputation (score).

How it does that:

Resource Check: Checks if the server's resourcesFIA have enough money for the steal (MONEY_AMOUNT = 500).

Sqf

Apply
private _resourcesFIA = server getVariable "resourcesFIA";
if (_resourcesFIA < MONEY_AMOUNT) exitWith { ... };
Transaction: Subtracts the money from the server.

Sqf

Apply
server setvariable ["resourcesFIA", _resourcesFIA - MONEY_AMOUNT, true];
Deducts score from the boss (using fn_addScorePlayer with a negative value).

Sqf

Apply
[-_ratingLoss,theBoss] call A3A_fnc_addScorePlayer;
Adds the money to the boss's personal account (using fn_resourcesPlayer).

Sqf

Apply
[MONEY_AMOUNT] call A3A_fnc_resourcesPlayer;
Notification: Displays a success message to the boss via SCRT_fnc_ui_showMessage.

Sqf

Apply
[ ... success message ... ] spawn SCRT_fnc_ui_showMessage;
Where it leads:

Called Functions:
A3A_fnc_addScorePlayer: Deducts reputation.
A3A_fnc_resourcesPlayer: Adds money to boss.
SCRT_fnc_ui_showMessage: Shows UI notification.
Dependencies: Requires resourcesFIA and theBoss.
System Fit: Economy/Commander specific action.
Global Variables: Modifies resourcesFIA (server), score (theBoss), moneyX (theBoss).
Network Implications: server setvariable is public (synchronized). Local updates for the Boss.
Function Name: fn_theBossToggleEligibility.sqf
What it does: Toggles a player's eligibility for commander. If they were eligible and are the current boss, it forces a resignation/election. If they weren't eligible, it marks them as eligible.

How it does that:

Target Resolution: Resolves the owner unit for the target player.

Sqf

Apply
_playerX = _playerX getVariable ["owner", _playerX];
Toggle Logic: Checks the current eligible state.

If Eligible (Turning Off): Sets eligible to false.
If the player is the current boss, it attempts to transfer the boss role (either to a forced new boss or triggers an election).
If Ineligible (Turning On): Sets eligible to true. If the player is a member, it forces an election check immediately (in case the previous boss was ineligible).
Sqf

Apply
if (_playerX getVariable ["eligible",false]) then {
    _playerX setVariable ["eligible",false,true];
    if (_playerX == theBoss) then { ... Transfer Logic ... };
} else {
    if ([_playerX] call A3A_fnc_isMember) then { _forceElection = true };
    _playerX setVariable ["eligible",true,true];
};
Update and Election: Sends a hint to the affected player. Calls fn_assignBossIfNone to run the election if necessary.

Sqf

Apply
[localize "STR_antistasi_actions_commander_text", _text] remoteExec ["A3A_fnc_customHint", _playerX];
[_forceElection] call A3A_fnc_assignBossIfNone;
Where it leads:

Called Functions:
A3A_fnc_makePlayerBossIfEligible: Used if transferring to a specific new boss.
A3A_fnc_assignBossIfNone: Runs the election.
A3A_fnc_customHint: Notifies the player.
Dependencies: Requires theBoss, eligible variable.
System Fit: Commander management (Admin/Menu tool).
Global Variables: Modifies _playerX eligible.
Network Implications: remoteExec sends hint to specific client.
Function Name: fn_theBossTransfer.sqf
What it does: The core function for transferring commander authority. It handles removing the old boss's HC groups, assigning them to the new boss, and notifying the server.

How it does that:

Old Boss Cleanup: If a current boss exists, it saves their High Command groups (bossHCGroupsTransfer), removes all HC groups from them, and unsynchronizes them from the HC commander object (HC_commanderX).

Sqf

Apply
if (!isNull theBoss) then {
    bossHCGroupsTransfer = hcAllGroups theBoss;
    hcRemoveAllGroups theBoss;
    theBoss synchronizeObjectsRemove [HC_commanderX];
    HC_commanderX synchronizeObjectsRemove [theBoss];
};
New Boss Assignment: Updates the global theBoss variable and publicizes it.

Sqf

Apply
theBoss = _newBoss;
publicVariable "theBoss";
HC Group Transfer:

If _newBoss is null (no commander), it spawns a cleanup routine to clear UI and statistics.
If a new boss is assigned, it synchronizes the group leader, adds the HC commander object, and transfers the saved HC groups to the new boss.
If no saved groups exist (edge case), it scans allGroups looking for AI groups owned by the rebels to assign to the new boss.
Sqf

Apply
if (!isNull _newBoss) exitWith { ... };
// ... Group Transfer Logic ...
if (!isNil "bossHCGroupsTransfer") then {
    { theBoss hcSetGroup [_x]; ... } forEach bossHCGroupsTransfer;
} else {
    { ... Scan allGroups ... } forEach allGroups;
};
Notification: Spawns a delayed routine (sleep 5) to send a hint to all players announcing the new commander (unless silent).

Sqf

Apply
[_silent] spawn {
    params ["_silent"];
    sleep 5;
    if (!_silent) then { ... };
    [] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
};
Where it leads:

Called Functions:
A3A_fnc_statistics: Updates stats for all players.
Dependencies: Requires theBoss, HC_commanderX, bossHCGroupsTransfer.
System Fit: Core command structure.
Global Variables: Modifies theBoss, bossHCGroupsTransfer.
Network Implications: publicVariable "theBoss" syncs to all. remoteExec updates stats for all rebel/civilian players.
Function Name: fn_tierCheck.sqf
What it does: Calculates the current "War Tier" based on the number and type of territories held by rebels. If the tier changes, it updates the global variable and triggers a UI notification and preference update.

How it does that:

Point Calculation (Total): Calculates the maximum possible points available in the mission based on all map features (airports, bases, cities, etc.).

Sqf

Apply
private _totalPoints = (8 * count airportsX) + (6 * count milbases) + ...;
Point Calculation (Rebel): Filters markersX to find rebel-controlled sites. Iterates through them and sums points based on the marker type (Airports are 8 points, Outposts are 2, etc.).

Sqf

Apply
private _rebelSites = markersX select {sidesX getVariable [_x,sideUnknown] == teamPlayer};
private _rebelPoints = 0;
{ ... } forEach _rebelSites;
Tier Calculation: Uses a formula based on the percentage of total points held.

Sqf

Apply
private _tierWar = 1 + floor (9 * sqrt (_rebelPoints / (0.7 * _totalPoints)));
if (_tierWar > 10) then {_tierWar = 10};
Update Logic: Compares the new tier with the global tierWar.

If different, updates tierWar.
Publicizes tierWar.
Sends a "tier" hint via A3A_fnc_commsMP (unless silent).
Calls A3A_fnc_updatePreference to refresh unit/vehicle availability.
Sqf

Apply
if (_tierWar != tierWar) then {
    tierWar = _tierWar;
    publicVariable "tierWar";
    if (!_silent) then { [petros,"tier",""] remoteExec ["A3A_fnc_commsMP",[teamPlayer,civilian]] };
    [] call A3A_fnc_updatePreference;
};
Where it leads:

Called Functions:
A3A_fnc_commsMP: Sends tier notification.
A3A_fnc_updatePreference: Updates spawning preferences.
Dependencies: Requires marker arrays (airportsX, milbases, etc.) and sidesX variable.
System Fit: Difficulty/Progression system. Run periodically.
Global Variables: Modifies tierWar. Reads sidesX.
Network Implications: publicVariable "tierWar" synchronizes difficulty to all clients.
Function Name: fn_unitTraits.sqf
What it does: Applies specific unit traits (medic, engineer, camouflage, etc.) based on the player's role description or unit type. It also updates Discord rich presence.

How it does that:

Role Detection: Checks roleDescription of the player. If it matches the default commander role, it applies commander traits (medic, explosive specialist, higher load capacity, etc.).

Sqf

Apply
if(roleDescription player isEqualTo "@STR_role_default_commander_role_name") then {
    player setUnitTrait ["medic", true];
    player setUnitTrait ["engineer", true];
    // ...
};
Unit Type Switch: If not the commander, it uses a switch statement on typeOf player to apply role-specific traits.

Medic: Increased camouflage, load capacity.
Rifleman: Lower camouflage, lower load capacity.
Engineer: UAV hacker, explosive specialist.
Sqf

Apply
switch (_type) do {
    case "I_G_medic_F": { ... };
    case "I_G_Soldier_F": { ... };
    // ...
};
Discord Integration: If Discord Rich Presence is active, it updates the status with the current role or "Commander".

Sqf

Apply
if (isDiscordRichPresenceActive) then {
    if(player != theBoss) then { ... } else { ... };
};
Notification: Sleeps for 5 seconds (to allow spawn to complete) and shows a hint about the role applied.

Sqf

Apply
if (_text isNotEqualTo "") then {
    sleep 5;
    [localize "STR_role_unit_traits", _text] call A3A_fnc_customHint;
};
Where it leads:

Called Functions:
SCRT_fnc_misc_updateRichPresence: Updates Discord.
A3A_fnc_customHint: Shows role info.
Dependencies: Requires theBoss for commander check. Requires isDiscordRichPresenceActive (external mod).
System Fit: Loadout/Player setup system. Run on spawn.
Global Variables: Reads theBoss.
Network Implications: None (local to player).