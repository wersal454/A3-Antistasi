/*
    Author:
        jwoodruff40
    
    Description:
        Generates the A3A_rebelGear hashmap of all equipment used to equip rebel AI
    
    Params:
        None
    
    Dependencies:
        N/A
    
    Scope:
        N/A
    
    Environment:
        Scheduled, any machine
    
    Usage:
        [] call A3A_fnc_generateRebelGear;
    
    Return:
        Nothing
*/

#include "..\..\script_component.hpp"
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"     // jna_datalist indices
FIX_LINE_NUMBERS()
if (!isServer) exitWith { Error("Server-only function miscalled") };
Info("Started updating A3A_rebelGear");

// Base weight mappings, MIN->0, MAX->1
// #define ITEM_MIN 10
#define ITEM_MAX 50

private _fnc_addItemNoUnlocks = {
    params ["_array", "_class", "_amount", ["_arrayWeight", 1]];
    if (_amount < 0) exitWith { _array append [_class, _arrayWeight] };
    if (_amount <= A3A_guestItemLimit) exitWith {};
    _array pushBack _class;
    _array pushBack (linearConversion [A3A_guestItemLimit, ITEM_MAX, _amount, 0, 1, true] * _arrayWeight); // multiply weight (preference) by ratio of amount of item to max amount of that item such that items rebels have more of are more likely to be selected
};

private _fnc_addItemUnlocks = {
    params ["_array", "_class", "_amount", ["_arrayWeight", 1]];
    if (_amount < 0) exitWith { _array append [_class, _arrayWeight] };
};

private _fnc_addGuidedLauncher = [_fnc_addItemNoUnlocks, _fnc_addItemUnlocks] select (allowGuidedLaunchers isEqualTo 1 && {minWeaps > 0});

private _fnc_addExplosiveCharge = [_fnc_addItemNoUnlocks, _fnc_addItemUnlocks] select (allowUnlockedExplosives isEqualTo 1 && {minWeaps > 0});

private _fnc_addItem = [_fnc_addItemUnlocks, _fnc_addItemNoUnlocks] select (minWeaps < 0);

private _fnc_getAvailableMagazines = {
    params ["_class", "_categories", ["_baseClass", ""]];

    private _hasMags = false;
    private _allMags = jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL;
    private _cmpMags = compatibleMagazines ([[_baseClass, _class], [_class, "this"]] select (_baseClass == ""));
    if (_cmpMags isEqualTo ["CBA_FakeLauncherMagazine"]) then { _cmpMags = compatibleMagazines (_class + "_Loaded") }; // handle fake launchers
    {
        _x params ["_magClass", "_magQty"];
        private _unlocked = [_magQty == -1, _magQty == -1 || {_magQty > A3A_guestItemLimit}] select (minWeaps < 0);
        if (_unlocked && {_magClass in _cmpMags}) then { (_rebelGear get "Magazines") getOrDefault [_class, [], true] pushBackUnique _magClass; _hasMags = true; };
    } forEach (_allMags);

    if ("GrenadeLaunchers" in _categories && {"Rifles" in _categories} ) then {
        // lookup real underbarrel GL magazine, because not everything is 40mm
        private _config = configFile >> "CfgWeapons" >> _class;
        private _glmuzzle = getArray (_config >> "muzzles") select 1;		// guaranteed by category
        _glmuzzle = configName (_config >> _glmuzzle);                      // bad-case fix. compatibleMagazines is case-sensitive as of 2.12
        [_glmuzzle, [], _class] call _fnc_getAvailableMagazines;    
    };

    _hasMags;
};

// Work with temporary array so that we're not transferring partials
private _rebelGear = createHashMap;

// Primary weapon filtering
private _rifle = [];
private _smg = [];
private _shotgun = [];
private _sniper = [];
private _mg = [];
private _gl = [];
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;

    call {
        if ("GrenadeLaunchers" in _categories) exitWith { [_gl, _class, _amount] call _fnc_addItem };       // call before rifles
        if ("Rifles" in _categories) exitWith { [_rifle, _class, _amount/2] call _fnc_addItem };
        if ("SniperRifles" in _categories) exitWith { [_sniper, _class, _amount] call _fnc_addItem };
        if ("MachineGuns" in _categories) exitWith { [_mg, _class, _amount] call _fnc_addItem };
        if ("SMGs" in _categories) exitWith { [_smg, _class, _amount] call _fnc_addItem };
        if ("Shotguns" in _categories) exitWith { [_shotgun, _class, _amount] call _fnc_addItem };
    };
} forEach (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON);

if (count A3A_specialGrenadeLaunchers > 0) then {
    // muzzle + base grenade launchers, broken down in the arsenal
    private _rifleHM = createHashMapFromArray (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON);
    private _muzzleHM = createHashMapFromArray (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMMUZZLE);
    {
        private _weapCount = _rifleHM getOrDefault [_y#0, 0];
        if (_weapCount >= 0 and _weapCount < 2*ITEM_MIN) then { continue };        // slightly hacky but whatever
        [_gl, _x, _muzzleHM getOrDefault [_y#1, 0]] call _fnc_addItem;
    } forEach A3A_specialGrenadeLaunchers;
};

_rebelGear set ["Rifles", _rifle];
_rebelGear set ["SMGs", _smg];
_rebelGear set ["Shotguns", _shotgun];
_rebelGear set ["MachineGuns", _mg];
_rebelGear set ["SniperRifles", _sniper];
_rebelGear set ["GrenadeLaunchers", _gl];

// Secondary weapon filtering
private _rlaunchers = [];
private _mlaunchersAT = [];
private _mlaunchersAA = [];
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
/*    if !("Disposable" in _categories) then {
        private _magcount = _class call _fnc_magCount;
        _amount = _amount min (_magcount/2);
    };*/

    if ("RocketLaunchers" in _categories) then { [_rlaunchers, _class, _amount] call _fnc_addItem; continue };
    if ("MissileLaunchers" in _categories) then {
        if ("AA" in _categories) exitWith { [_mlaunchersAA, _class, _amount] call _fnc_addItemNoUnlocks };
        if ("AT" in _categories) exitWith { [_mlaunchersAT, _class, _amount] call _fnc_addItemNoUnlocks };
    };
} forEach (jna_datalist select IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON);

_rebelGear set ["RocketLaunchers", _rlaunchers];
_rebelGear set ["MissileLaunchersAT", _mlaunchersAT];
_rebelGear set ["MissileLaunchersAA", _mlaunchersAA];

// Vest filtering
private _avests = ["", [1.5,0.5] select (minWeaps < 0)];     // blank entry to phase in armour use gradually
private _uvests = [];
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
    private _array = [_uvests, _avests] select ("ArmoredVests" in _categories);
    [_array, _class, _amount] call _fnc_addItem;
} forEach (jna_datalist select IDC_RSCDISPLAYARSENAL_TAB_VEST);

_rebelGear set ["ArmoredVests", _avests];
_rebelGear set ["CivilianVests", _uvests];

// Helmet filtering
private _aheadgear = ["", [1.5,0.5] select (minWeaps < 0)];     // blank entry to phase in armour use gradually
private _uheadgear = [];
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
    private _array = [_uheadgear, _aheadgear] select ("ArmoredHeadgear" in _categories);
    [_array, _class, _amount] call _fnc_addItem;
} forEach (jna_datalist select IDC_RSCDISPLAYARSENAL_TAB_HEADGEAR);

_rebelGear set ["ArmoredHeadgear", _aheadgear];
//_rebelGear set ["CosmeticHeadgear", _uheadgear];           // not used, rebels have template-defined basic headgear

// Backpack filtering
private _backpacks = [];
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
    if ("BackpacksCargo" in _categories) then { [_backpacks, _class, _amount] call _fnc_addItem };
} forEach (jna_datalist select IDC_RSCDISPLAYARSENAL_TAB_BACKPACK);

_rebelGear set ["BackpacksCargo", _backpacks];

// NVG filtering
private _nvgs = ["", 0.5];          // blank entry for phase-in
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
    if !("NVGThermal" in _categories) then { [_nvgs, _class, _amount] call _fnc_addItem };
} forEach (jna_datalist select IDC_RSCDISPLAYARSENAL_TAB_NVGS);

_rebelGear set ["NVGs", _nvgs];

// Unfiltered stuff (just radios atm? could add GPS)
private _radios = [];
{ [_radios, _x#0, _x#1] call _fnc_addItem } forEach (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_RADIO);
_rebelGear set ["Radios", _radios];

// Misc items. Don't really need weighting but whatever
private _minedetectors = [];
private _toolkits = [];
private _medikits = [];
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
    call {
        if ("MineDetectors" in _categories) exitWith { [_minedetectors, _class, _amount] call _fnc_addItem };
        if ("Toolkits" in _categories) exitWith { [_toolkits, _class, _amount] call _fnc_addItem };
        if ("Medikits" in _categories) exitWith { [_medikits, _class, _amount] call _fnc_addItem };
    };
} forEach (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC);

_rebelGear set ["MineDetectors", _minedetectors];
_rebelGear set ["Toolkits", _toolkits];
_rebelGear set ["Medikits", _medikits];

// Hand grenades
private _smokes = [];
private _nades = [];
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
    call {
        if ("SmokeGrenades" in _categories) exitWith { [_smokes, _class, _amount] call _fnc_addItem };
        if ("Grenades" in _categories) exitWith { [_nades, _class, _amount] call _fnc_addItem };
    };
} forEach (jna_datalist select IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW);

_rebelGear set ["SmokeGrenades", _smokes];
_rebelGear set ["Grenades", _nades];

// Explosives. Could add mines but don't want them atm.
private _charges = [];
{
    _x params ["_class", "_amount"];
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
    if ("ExplosiveCharges" in _categories) then { [_charges, _class, _amount] call _fnc_addItemNoUnlocks };
} forEach (jna_datalist select IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT);

_rebelGear set ["ExplosiveCharges", _charges];

// Optic filtering. No weighting because of weapon compatibilty complexity
private _opticClose = [];
private _opticMid = [];
private _opticLong = [];
private _midCount = 0;
{
    _x params ["_class", "_amount"];
    if (_amount > 0 and {minWeaps > 0 or _amount < ITEM_MIN}) then { continue };
    private _categories = _class call A3A_fnc_equipmentClassToCategories;
    call {
        if ("OpticsMid" in _categories) exitWith {                      // most common first
            _opticMid pushBack _class;
            _midCount = [_midCount + _amount, 1e6] select (_amount < 0);
        };
        if ("OpticsClose" in _categories) exitWith { _opticClose pushBack _class };
        if ("OpticsLong" in _categories) exitWith { _opticLong pushBack _class };
    };
} forEach (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC);

// Mix in some short-range optics if mid-range count is low
private _opticMid = _rebelGear get "OpticsMid";
private _opticClose = _rebelGear get "OpticsClose";
private _opticLong = _rebelGear get "OpticsLong";

if (_opticsMidCount < ITEM_MAX*2) then {
    if (_opticsMidCount == 0) exitWith { _opticMid = _opticClose };
    private _mixCount = round (count _opticMid * (ITEM_MAX / _opticsMidCount));
    if (_mixCount >= count _opticClose) exitWith { _opticMid append _opticClose };

    private _opticClose2 = +_opticClose;
    for "_i" from 1 to _mixCount do {
        private _optic = selectRandom _opticClose2;
        _opticClose2 deleteAt (_opticClose2 find _optic);
        _opticMid pushBack _optic;
    };
};

_rebelGear set ["OpticsAll", _opticClose + _opticMid + _opticLong];     // for launchers

// normalize all item weights, within their own array
{
    private _array = _y; 
    if !(_array isEqualType []) then {continue}; 
    private _totalWeight = 0;  
    { _totalWeight = _totalWeight + _x } forEach (_array select {_x isEqualType 1}); 
    _rebelGear set [_x, _array apply {if (_x isEqualType 1) then {_x / _totalWeight} else {_x}}];
} forEach _rebelGear;

// Update everything while unscheduled so that version numbers match
isNil {
    A3A_rebelGearVersion = time;
    _rebelGear set ["Version", A3A_rebelGearVersion];
    A3A_rebelGear = _rebelGear;

    // Clear these locally
    A3A_rebelOpticsCache = createHashMap;
    A3A_rebelFlashlightsCache = createHashMap;
    A3A_rebelLasersCache = createHashMap;
    A3A_rebelSilencersCache = createHashMap;
    A3A_rebelBipodsCache = createHashMap;
};
// Only broadcast the version number so that clients & HCs can request as required
publicVariable "A3A_rebelGearVersion";

Info("Finished updating A3A_rebelGear");

/*
// Alternatively just broadcast it
A3A_rebelGear = _rebelGear;
publicVariable "A3A_rebelGear";
*/
