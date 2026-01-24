Configuration File Documentation
CfgMagazines.hpp
File: A3A/addons/config_fixes/CfgMagazines.hpp
What it does:
Defines magazine configurations for the mod. Currently empty, serving as a placeholder for future magazine definitions.
How it does that:

Cpp

Apply
class CfgMagazines {
    // Empty class - no magazines defined yet
};
Opens the CfgMagazines configuration class
Creates an empty scope for future magazine definitions
Will contain magazine classes when populated
Where it leads:

This file is included by config.cpp (line 39, commented out)
When uncommented, it will provide magazine definitions for the config_fixes addon
No dependencies - it's a standalone configuration scope
Requirements:

No validation needed (empty class)
No parameter validation (configuration only)
Will be processed by Arma's configuration system when loaded
CfgVehicles.hpp
File: A3A/addons/config_fixes/CfgVehicles.hpp
What it does:
Defines vehicle configurations for the mod. Currently empty, serving as a placeholder for future vehicle definitions.
How it does that:

Cpp

Apply
class CfgVehicles {
    // Empty class - no vehicles defined yet
};
Opens the CfgVehicles configuration class
Creates an empty scope for future vehicle definitions
Will contain vehicle classes when populated
Where it leads:

This file is included by config.cpp (line 40, commented out)
When uncommented, it will provide vehicle definitions for the config_fixes addon
No dependencies - it's a standalone configuration scope
Requirements:

No validation needed (empty class)
No parameter validation (configuration only)
Will be processed by Arma's configuration system when loaded
CfgWeapons.hpp
File: A3A/addons/config_fixes/CfgWeapons.hpp
What it does:
Defines weapon configurations for the mod. Currently contains a forward declaration and an include statement for bomb weapons.
How it does that:

Cpp

Apply
class Mode_SemiAuto;  // Forward declaration - allows reference before definition
class CfgWeapons {
    //#include "CfgWeapons\bomb_weapons.hpp"  // Commented out include
};
Line 1: Forward declares Mode_SemiAuto class, allowing references to it before its full definition
Lines 2-5: Opens the CfgWeapons configuration class
Line 4: Commented-out include for bomb weapons configuration (would be used for aircraft bomb launchers)
Where it leads:

This file is included by config.cpp (line 41, commented out)
The Mode_SemiAuto forward declaration is used by bomb_weapons.hpp (in subdirectory)
When uncommented, includes will bring in weapon definitions
Dependency chain: CfgWeapons → bomb_weapons.hpp
Requirements:

Forward declaration required for proper class hierarchy
Include statements must resolve relative paths correctly
Configuration system must process before runtime
CfgWorlds.hpp
File: A3A/addons/config_fixes/CfgWorlds.hpp
What it does:
Defines custom names for Vietnamese and Lao men (first and last names) used in the game world for identity generation.
How it does that:

Cpp

Apply
class CfgWorlds {
    class GenericNames {
        class VietnameseMen {
            class FirstNames {
                An = "An";
                Bao = "Bao";
                Cuong = "Cuong";
                // ... 10 total names
            };
            class LastNames {
                Nguyen = "Nguyen";
                Tran = "Tran";
                Le = "Le";
                // ... 30 total names
            };
        };
        class LaoMen {
            class FirstNames {
                Somchai = "Somchai";
                Bounthavy = "Bounthavy";
                // ... 20 total names
            };
            class LastNames {
                Sisavath = "Sisavath";
                Souvanthong = "Souvanthong";
                // ... 45 total names
            };
        };
    };
};
Structure: CfgWorlds → GenericNames → VietnameseMen/LaoMen → FirstNames/LastNames
Vietnamese Names: 10 first names + 30 last names (total 40 names)
Lao Names: 20 first names + 45 last names (total 65 names)
Format: Each name is defined as code = "display name" for localization
Where it leads:

Included by config.cpp (line 2)
Used by Arma's identity system to generate civilian and faction identities
Referenced by world configuration for Vietnamese/Lao populations
Global variable: CfgWorlds configuration namespace
Requirements:

Names must be unique within each category
No special characters that break config parser
Proper UTF-8 encoding for special characters (Vietnamese diacritics)
Configuration validation: each class must have unique identifiers
Technical Details:

Config values are strings that become display names
Used by BIS_fnc_selectRandom for identity selection
Part of Arma's generic names system (CfgWorlds → GenericNames)
Network implications: configs are client-side, no synchronization needed
CfgWorlds.hpp (continued)
File: A3A/addons/config_fixes/CfgWorlds.hpp
Additional Context:
The GenericNames configuration is used by Arma's identity system when spawning units without explicit identity definitions. The names are selected randomly based on the faction's nationality or world context.

Implementation Details:

Cpp

Apply
// Vietnamese names structure
class VietnameseMen {
    class FirstNames {
        // 10 entries: An, Bao, Cuong, Dung, Hai, Khoa, Linh, Minh, Quang, Tu
        // Each maps to localized display name
    };
    class LastNames {
        // 30 entries: Nguyen, Tran, Le, Pham, Hoang, Phan, Vu, Dang, Bui, Ngo,
        // Duong, Dinh, Ly, Luu, Thach, Ton, Tieu, Quach, Diep, Huynh, Trinh,
        // Tu, Gia, Van, Luong, Nghiem, Khanh, Son, Dao, Tam, Hien
    };
};

// Lao names structure
class LaoMen {
    class FirstNames {
        // 20 entries with Lao-specific names
    };
    class LastNames {
        // 45 entries with Lao-specific names
    };
};
Edge Cases:

If a name is missing, identity system falls back to default English names
Empty string values would cause config errors
Duplicate keys (e.g., "Tu" appears in Vietnamese first and last names) are allowed in different scopes
config.cpp (Base)
File: A3A/addons/config_fixes/config.cpp
What it does:
Main configuration file for the config_fixes addon. Defines the addon's metadata, dependencies, and includes various sub-configuration files.
How it does that:

Cpp

Apply
#include "script_component.hpp"
#include "CfgWorlds.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;  // Resolves to "config_fixes"
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        
        // Conditional dependency on CUP
        #if __has_include("\CUP\Weapons\CUP_Weapons_DynamicLoadout\mk82\CUP_mk82_pod.p3d")
        requiredAddons[] = {"A3_Weapons_F", "CUP_Weapons_DynamicLoadout"};
        #else
        requiredAddons[] = {"A3_Weapons_F"};
        #endif
        
        author = AUTHOR;
        authors[] = { AUTHORS };
        authorUrl = "";
        VERSION_CONFIG;
    };
};

// Includes (commented out)
//#include "CfgMagazines.hpp"
//#include "CfgVehicles.hpp"
//#include "CfgWeapons.hpp"
Component Breakdown:

Includes (lines 1-2):

script_component.hpp
: Defines COMPONENT macro as "config_fixes"
CfgWorlds.hpp
: Includes custom name definitions
CfgPatches (lines 4-20):

name: Display name for the addon
units[] / weapons[]: Empty arrays - no new units/weapons defined
requiredVersion: Ensures minimum Arma 3 version compatibility
Conditional dependencies: Uses __has_include preprocessor to check for CUP
If CUP's mk82 pod exists → requires both A3_Weapons_F and CUP_Weapons_DynamicLoadout
Otherwise → requires only A3_Weapons_F
Author metadata: AUTHOR and AUTHORS macros from script_component
VERSION_CONFIG: Auto-generates version information
Commented Includes (lines 23-26):

CfgMagazines.hpp - Magazine configurations
CfgVehicles.hpp - Vehicle configurations
CfgWeapons.hpp - Weapon configurations
Where it leads:

This is the entry point for the config_fixes addon
Dependency Chain:
Requires: A3_Weapons_F (always)
Optionally requires: CUP_Weapons_DynamicLoadout (if CUP present)
Includes:
Direct: CfgWorlds.hpp
Indirect (when uncommented): CfgMagazines.hpp, CfgVehicles.hpp, CfgWeapons.hpp
Global Impact: Creates CONFIG_FIXES addon class in CfgPatches
Requirements:

Script_component.hpp must define all required macros (COMPONENT, AUTHOR, AUTHORS, REQUIRED_VERSION, VERSION_CONFIG)
Preprocessor must support __has_include
All included files must exist in correct relative paths
No circular dependencies allowed
Preprocessor Logic Details:

Cpp

Apply
// __has_include check
#if __has_include("\CUP\Weapons\CUP_Weapons_DynamicLoadout\mk82\CUP_mk82_pod.p3d")
// If this path exists in mod file system:
requiredAddons[] = {"A3_Weapons_F", "CUP_Weapons_DynamicLoadout"};
// This ensures CUP weapons are loaded before this addon
#else
requiredAddons[] = {"A3_Weapons_F"};
// Base game only, no CUP dependency
#endif
Uses compile-time file existence check
Prevents missing dependency errors
Allows flexible mod support
VERSION_CONFIG Details:

Cpp

Apply
// This macro expands to:
version = 1.0.0;  // From mod version
versionStr = "1.0.0";
versionAr[] = {1, 0, 0};  // Array representation
Automatically populated from mod metadata
Used by Arma's version checking system
script_component.hpp
File: A3A/addons/config_fixes/script_component.hpp
What it does:
Defines macros and includes base script component functionality for the config_fixes addon.
How it does that:

Cpp

Apply
#define COMPONENT config_fixes
#include "\x\A3A\addons\core\Includes\script_mod.hpp"
#define PATCHNAME(x) ADDON##_##x
Macro Definitions:

Line 1: Defines COMPONENT as "config_fixes"
Line 2: Includes core script modification header
Line 3: Defines PATCHNAME(x) macro that concatenates ADDON with x and an underscore
Where it leads:

Included by config.cpp (line 1)
Includes: script_mod.hpp from A3A core addon
Defines used by:
config.cpp: COMPONENT_NAME, AUTHOR, AUTHORS, REQUIRED_VERSION, VERSION_CONFIG
Other config files: COMPONENT for debugging/logging
Macro expansion: PATCHNAME(WS) expands to ADDON_WS
Requirements:

Must be included before any component-specific macros are used
script_mod.hpp must define core macros (ADDON, AUTHOR, etc.)
No variable definitions - only macros
Stringtable.xml
File: A3A/addons/config_fixes/Stringtable.xml
What it does:
Defines localization entries for the config_fixes addon. Currently empty, serving as a placeholder.
How it does that:

Xml

Apply
<?xml version="1.0" encoding="utf-8"?>
<Project name="A3-Antistasi">
    <Package name="A3-Antistasi Mission">
        <Container name="config_fixes">
        </Container>
    </Package>
</Project>
XML Structure:

Project: Defines overall mod context (A3-Antistasi)
Package: Mission-level package container
Container: config_fixes specific localization entries (empty)
Where it leads:

Referenced by Arma's stringtable system
When populated, entries would be accessible via localize command
No direct dependencies - standalone localization file
Requirements:

Valid XML structure
UTF-8 encoding for special characters
Container names must be unique
WS/CfgMarkers.hpp
File: A3A/addons/config_fixes/WS/CfgMarkers.hpp
What it does:
Defines a custom flag marker for the SFIA (Security Forces of Independent Afghanistan) faction in the WS DLC.
How it does that:

Cpp

Apply
class CfgMarkers {
    class flag_NATO;  // Inherits from base NATO flag marker
    class a3a_flag_SFIA : flag_NATO {  // Inherits all properties from flag_NATO
        name = "SFIA";
        icon = "\lxws\data_f_lxws\img\flags\flag_SFIA_CO.paa";
        texture = "\lxws\data_f_lxws\img\flags\flag_SFIA_CO.paa";
    };
};
Inheritance Chain:

flag_NATO (base class) → a3a_flag_SFIA (child class)
Child inherits: shape, size, color, behavior from parent
Override: name, icon, texture
Property Breakdown:

name: Display name in marker list ("SFIA")
icon: Path to marker icon (small map symbol)
texture: Path to full flag texture (used for object representation)
Where it leads:

Used by WS configuration (Worlds Sa'hatra DLC)
Referenced by WS/CfgVehicles.hpp for vehicle flag textures
Global marker system: accessible via marker commands (createMarker, setMarkerType)
Dependencies: Requires WS DLC assets (lxws paths)
Requirements:

Base class flag_NATO must exist in Arma base configs
Texture paths must be valid (within WS DLC)
No network synchronization needed - client-side config
WS/CfgVehicles.hpp (Main)
File: A3A/addons/config_fixes/WS/CfgVehicles.hpp
What it does:
Defines custom vehicle variants for the WS DLC, including armored offroads, trucks, APCs, and helicopters with custom textures and configurations.
How it does that:

Section 1: Base Class Declarations (Lines 5-18)

Cpp

Apply
class B_G_Offroad_01_AT_F;  // Base offroad AT variant
class B_G_Offroad_01_armed_F;  // Base offroad armed variant
class B_Tura_Offroad_armor_AT_lxWS;  // WS armored offroad AT
class B_Tura_Offroad_armor_armed_lxWS;  // WS armed offroad
class B_Tura_Offroad_armor_lxWS;  // WS unarmed armored offroad
class I_Truck_02_MRL_F;  // MRL truck
class O_Truck_02_Ammo_F;  // Ammo truck
// ... more base class declarations
These are forward declarations allowing references before full definitions
Used to reference base classes when creating variants
Section 2: Includes (Lines 20-21)

Cpp

Apply
#include "ws_apc.hpp"
#include "ws_ion.hpp"
ws_apc.hpp
: APC-specific configurations
ws_ion.hpp
: ION faction vehicle configurations
Section 3: Tan Offroad Variants (Lines 23-42)

Cpp

Apply
class a3a_tan_Offroad_armor : B_Tura_Offroad_armor_lxWS {
    textureList[] = {};  // Clear default textures
    hiddenSelectionsTextures[] = {
        "a3\soft_f\offroad_01\data\offroad_01_ext_base01_co.paa",  // Body
        "a3\soft_f\offroad_01\data\offroad_01_ext_base01_co.paa",  // Body duplicate?
        "lxws\vehicles_f_lxws\offroad_01\data\offroad_01_adds_black_co.paa",  // Addons
        "lxws\vehicles_f_lxws\offroad_01\data\offroad_01_armor_sfia2_co.paa"  // Armor
    };
};
Inherits from WS armored offroad
Defines 4 texture layers for hidden selections
textureList[] = {} clears default texture sources
Section 4: Green Offroad Variants (Lines 44-60)

Cpp

Apply
class a3a_green_Offroad_armor : B_Tura_Offroad_armor_lxWS {
    textureList[] = {};
    hiddenSelectionsTextures[] = {
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_grn_co.paa",
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_grn_co.paa",
        "lxws\vehicles_f_lxws\offroad_01\data\offroad_01_adds_black_co.paa",
        "lxws\vehicles_f_lxws\offroad_01\data\offroad_01_armor_rust_co.paa"
    };
};
Uses Enoch DLC (Contact) green textures
Different armor texture (rust)
Section 5: LDF (Livonian Defense Force) Variants (Lines 62-86)

Cpp

Apply
class a3a_ldf_Offroad_armor : B_Tura_Offroad_armor_lxWS {
    textureList[] = {};
    crew = "I_E_Soldier_F";
    faction = "IND_E_F";
    side = 2;  // Independent
    hiddenSelectionsTextures[] = {
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_eaf_co.paa",
        // ... 4 textures total
    };
};
Sets faction to LDF (IND_E_F)
Sets crew class and side
Uses LDF-specific textures
Section 6: SFIA Truck Variants (Lines 88-96)

Cpp

Apply
class a3a_SFIA_Truck_02_medical_F : O_Truck_02_medical_F {
    side = 0;  // Opfor
    crew = "O_SFIA_soldier_lxWS";
    faction = "OPF_SFIA_lxWS";
    hiddenSelectionsTextures[] = {
        "lxws\vehicles_f_lxws\data\truck_02\truck_02_kab_sfia_co.paa",
        // ... 3 textures
    };
};
Custom SFIA medical truck
Sets specific crew and faction for SFIA
Section 7: ZU-23 Variants (Lines 98-141)

Cpp

Apply
class a3a_O_Truck_02_zu23_F : O_Tura_Truck_02_aa_lxWS {
    side = 0;
    crew = "O_soldier_F";
    faction = "OPF_F";
    hiddenSelectionsTextures[] = {
        "a3\soft_f_beta\truck_02\data\truck_02_kab_opfor_co.paa",
        "lxws\vehicles_f_lxws\truck_02\data\truck_02_cargo_opfor_co.paa",
        "a3\soft_f_beta\truck_02\data\truck_02_int_co.paa",
        "lxws\vehicles_f_lxws\zu23\data\zu23_base_sfia_co.paa",
        "lxws\vehicles_f_lxws\zu23\data\zu23_sfia_co.paa",
        "lxws\vehicles_f_lxws\zu23\data\zu23_addon_1_hex_co.paa",
        "lxws\vehicles_f_lxws\zu23\data\zu23_addon_2_sfia_co.paa",
        "lxws\vehicles_f_lxws\truck_02\data\addons_black_co.paa"
    };
};
8 texture layers (truck cabin, cargo, interior, ZU-23 gun, addons)
Variants for different camos: tan (OPF_F), brown (OPF_T_F), green (IND_E_F)
Section 8: Helicopter Base Classes (Lines 143-148)

Cpp

Apply
class Heli_Light_02_dynamicLoadout_base_F: Heli_Light_02_base_F {
    class Components;  // Forward declaration for components
};
class B_ION_Heli_Light_02_dynamicLoadout_lxWS: Heli_Light_02_dynamicLoadout_base_F {
    class Components : Components {
        class TransportPylonsComponent;  // Forward declaration
    };
};
Defines base helicopter class with dynamic loadout capability
Forward declares Components class hierarchy
Section 9: ION Helicopter Configuration (Lines 149-181)

Cpp

Apply
class a3a_ION_Heli_Light_02_dynamicLoadout_lxWS : B_ION_Heli_Light_02_dynamicLoadout_lxWS {
    class Components : Components {
        side = 1;  // Blufor
        crew = "B_ION_Soldier_lxWS";
        faction = "BLU_ION_lxWS";
        class TransportPylonsComponent : TransportPylonsComponent {
            class Presets {
                class Default {
                    attachment[] = {
                        "PylonWeapon_2000Rnd_65x39_belt",
                        "PylonRack_12Rnd_missiles"
                    };
                    displayName = "Default";
                };
                class Empty {
                    attachment[] = {};
                    displayName = "Empty";
                };
            };
            class Pylons {
                class PylonLeft1 {
                    attachment = "PylonWeapon_2000Rnd_65x39_belt";
                    hardpoints[] = {
                        "DAR", "DAGR", "B_SHIEKER", "UNI_SCALPEL",
                        "20MM_TWIN_CANNON", "B_ASRRAM_EJECTOR",
                        "WEAPON_PODS_RF", "B_BOMB_PYLON"
                    };
                    priority = 5;
                    turret[] = {0};
                    UIposition[] = {"0.06 + 0.02", 0.4};
                };
                // ... PylonRight1 definition
            };
        };
    };
};
Components Override: Defines faction, side, crew
TransportPylonsComponent: Configures weapon hardpoints
Presets: Defines two loadout presets (Default with minigun + missiles, Empty)
Pylons: Defines 2 pylons (left and right) with:
Default attachments
Compatible hardpoint types
UI positioning
Turret assignment (0 = helicopter gunner)
Hardpoints: Array of compatible weapon types (DAR, DAGR, etc.)
Section 10: Commented Alternative Textures (Lines 182-210)

Cpp

Apply
/* class a3a_CSAT_Heli_Light_02_hex_dynamicLoadout_lxWS : a3a_ION_Heli_Light_02_dynamicLoadout_lxWS {
    textureList[] = {"ION_BLACK",0,"Black",0,"Blackcustom",0,"Opfor",1};
    hiddenSelectionsTextures[] = {
        "\A3\Air_F\Heli_Light_02\Data\Heli_Light_02_ext_OPFOR_CO.paa",
        "\a3\air_f\data\rockets_co.paa",
        "\lxWS\air_f_lxWS\heli_light_02\data\lxws_heli_light_02_adds_hex_co.paa"
    };
}; */
Commented out - not currently active
Would provide CSAT-themed variant
TextureList overrides selection from parent class
Where it leads:

Included by WS/config.cpp (line 26)
Dependencies:
Requires: Vehicles_F_lxWS (WS DLC vehicles)
Inherits from: Base Arma 3 vehicle classes
Global Impact: Adds 10+ new vehicle variants to mission
Network: Vehicle configs are client-side, but vehicle instances sync over network
Mission Editor: Vehicles appear in Eden editor under specific factions
Technical Details:

textureList[]: Controls which textures appear in texture selection UI (empty = no selection)
hiddenSelectionsTextures[]: Array of texture paths mapped to hidden selections
AnimationList[]: Controls model animations (present in some variants)
Side/Faction/Crew: Determines spawn behavior and crew type
WS/ws_apc.hpp
File: A3A/addons/config_fixes/WS/ws_apc.hpp
What it does:
Defines armored personnel carrier (APC) variants for the WS DLC, including Marshall, Iskatel/Kamysh, and their faction variants.
How it does that:

Section 1: Base Class Forward Declarations (Lines 4-7)

Cpp

Apply
class APC_Wheeled_01_base_F;  // Marshall base
class APC_Wheeled_01_command_base_lxWS : APC_Wheeled_01_base_F {
    class EventHandlers;  // Forward declaration
};
Declares base classes for inheritance
Forward declares EventHandlers for modification
Section 2: ION APC Variants (Lines 9-28)

Cpp

Apply
class B_ION_APC_Wheeled_01_command_lxWS: APC_Wheeled_01_command_base_lxWS {};
class a3a_ION_APC_Wheeled_01_command_lxWS : B_ION_APC_Wheeled_01_command_lxWS {
    animationList[] = {
        "showBags", 0.5,
        "showCamonetHull", 0,
        "showCamonetTurret", 0,
        "showSLATHull", 1,
        "showSLATTurret", 1
    };
    class EventHandlers : EventHandlers {
        init = "if (local (_this select 0)) then {[(_this select 0), """", [], false] call bis_fnc_initVehicle;};";
    };
};
animationList: Controls model animations (0-1 values):
showBags: 0.5 = partially visible
showCamonetHull/Turret: 0 = hidden
showSLATHull/Turret: 1 = visible (active)
EventHandlers.init: Script executed on vehicle initialization
Checks if vehicle is local to machine
Calls bis_fnc_initVehicle with empty string, empty array, false
Purpose: Ensures proper vehicle initialization on spawn
Section 3: ION Cannon APC (Lines 30-40)

Cpp

Apply
class B_ION_APC_Wheeled_01_cannon_lxWS: B_APC_Wheeled_01_cannon_lxWS {
    class EventHandlers;
};
class a3a_ION_APC_Wheeled_01_cannon_lxWS : B_ION_APC_Wheeled_01_cannon_lxWS {
    scope = 2;  // Visible in editor
    animationList[] = { /* same as command */ };
    class EventHandlers : EventHandlers { /* same init */ };
};
scope = 2: Makes vehicle available in editor and Zeus
Same animation and event handler setup as command variant
Section 4: ION ATGM APC (Lines 42-52)

Cpp

Apply
class B_D_APC_Wheeled_01_atgm_lxWS;  // Base ATGM variant
class a3a_ION_APC_Wheeled_01_atgm : B_D_APC_Wheeled_01_atgm_lxWS {
    side = 1;  // Blufor
    crew = "B_ION_Soldier_lxWS";
    faction = "BLU_ION_lxWS";
    textureList[] = {"ION_BLACK", 1};  // Select black texture
    hiddenSelectionsTextures[] = {
        "lxws\vehicles_f_lxws\data\APC_Wheeled_01\APC_Wheeled_ion_base_CO.paa",
        "lxws\vehicles_f_lxws\data\APC_Wheeled_01\apc_wheeled_ion_adds_co.paa",
        "lxws\vehicles_f_lxws\data\APC_Wheeled_01\apc_wheeled_ion_tows_co.paa",
        "a3\armor_f\Data\camonet_AAF_stripe_desert_CO.paa",
        "lxws\vehicles_f_lxws\data\APC_Wheeled_01\cage_black_CO.paa",
        "lxws\vehicles_f_lxws\data\APC_Wheeled_01\APC_Wheeled_ion_lxws_CO.paa"
    };
};
Sets faction to ION (BLU_ION_lxWS)
textureList = {"ION_BLACK", 1} selects black texture from available options
6 texture layers defined
Section 5: NATO Marshall Variants (Lines 54-84)

Cpp

Apply
class a3a_APC_Wheeled_01_command_lxWS : APC_Wheeled_01_command_base_lxWS {
    // Inherits animation list and event handlers
};
class B_T_APC_Wheeled_01_command_lxWS : APC_Wheeled_01_command_base_lxWS {};
class a3a_T_APC_Wheeled_01_command_lxWS : B_T_APC_Wheeled_01_command_lxWS {
    // Same configuration as base NATO variant
};
Two NATO variants: standard and tropical (T)
Same animation and event handler configuration
Section 6: Iskatel/Kamysh Variants (Lines 86-128)

Cpp

Apply
class O_APC_Tracked_02_30mm_lxWS;  // 30mm variant
class a3a_APC_Tracked_02_30mm_lxWS : O_APC_Tracked_02_30mm_lxWS {
    animationList[] = {
        "showTracks", 0.5,
        "showCamonetHull", 0,
        "showBags", 0.5,
        "showSLATHull", 1
    };
    // Has initVehicle EH already (no override)
};
Tracked APC: Different from wheeled Marshall
Animation list:
showTracks: 0.5 = partially visible
showCamonetHull: 0 = hidden
showBags: 0.5 = partially visible
showSLATHull: 1 = active
No EventHandlers override (inherits default)
Section 7: Faction Variants (Lines 90-118)

Cpp

Apply
// Arid
class O_T_APC_Tracked_02_30mm_lxWS;
class a3a_T_APC_Tracked_02_30mm_lxWS : O_T_APC_Tracked_02_30mm_lxWS {
    // Same animations
};
// SFIA
class O_SFIA_APC_Tracked_02_30mm_lxWS;
class a3a_SFIA_APC_Tracked_02_30mm_lxWS : O_SFIA_APC_Tracked_02_30mm_lxWS {
    // Same animations
};
// ION
class a3a_ION_APC_Tracked_02_30mm : O_APC_Tracked_02_30mm_lxWS {
    side = 1;
    crew = "B_ION_Soldier_lxWS";
    faction = "BLU_ION_lxWS";
    textureList[] = {"Grey", 1};
    hiddenSelectionsTextures[] = {
        "lxWS\vehicles_1_f_lxws\APC_Tracked_02\data\APC_Tracked_02_ext_01_black_CO.paa",
        // ... 6 total textures
    };
};
SFIA variant: Uses O_SFIA faction
ION variant:
Side = 1 (Blufor)
Crew = ION soldier
Texture = Grey
6 black/grey textures for different hull/turret parts
Where it leads:

Included by WS/CfgVehicles.hpp (line 20)
Dependencies:
Requires: Vehicles_F_lxWS (WS DLC)
Inherits: Base Arma APC classes
Inheritance Chain:
Base → Faction Base → a3a variant
Global Variables:
Adds 10+ APC variants to mission pool
Modifies vehicle spawn availability by faction
WS/ws_ion.hpp
File: A3A/addons/config_fixes/WS/ws_ion.hpp
What it does:
Defines ION faction vehicle variants for the WS DLC, including trucks, offroads, and APCs with custom textures and faction assignments.
How it does that:

Section 1: ION Truck Variants (Lines 4-64)

Cpp

Apply
class a3a_ION_Truck_02_MRL_F : I_Truck_02_MRL_F {
    side = 1;  // Blufor
    crew = "B_ION_Soldier_lxWS";
    faction = "BLU_ION_lxWS";
    hiddenSelectionsTextures[] = {
        "lxws\vehicles_f_lxws\data\truck_02\truck_02_kab_black_co.paa",
        "a3\soft_f_beta\truck_02\data\truck_02_int_co.paa",
        "lxws\vehicles_f_lxws\data\truck_02\zamak_mrl_brown_co.paa"
    };
};
MRL Truck: Multiple Rocket Launcher
3 texture layers: cabin, interior, MRL pod
Black/brown color scheme
Section 2: Support Trucks (Lines 66-112)

Cpp

Apply
class a3a_ION_Truck_02_Ammo_F : O_Truck_02_Ammo_F {
    side = 1;
    crew = "B_ION_Soldier_lxWS";
    faction = "BLU_ION_lxWS";
    hiddenSelectionsTextures[] = {
        "lxws\vehicles_f_lxws\data\truck_02\truck_02_kab_black_co.paa",
        "a3\soft_f_beta\truck_02\data\truck_02_repair_green_co.paa",
        "a3\soft_f_beta\truck_02\data\truck_02_int_co.paa"
    };
};
class a3a_ION_Truck_02_Fuel_F : O_Truck_02_Fuel_F {
    // Similar structure, fuel texture
};
class a3a_ION_Truck_02_repair_F : O_Truck_02_box_F {
    // Repair truck variant
};
Four support truck types: Ammo, Fuel, Repair, Transport
Same faction/side/crew settings
Different texture for each type
Section 3: ION Offroad Variants (Lines 114-156)

Cpp

Apply
class a3a_ION_Offroad_armor : B_Tura_Offroad_armor_lxWS {
    side = 1;
    crew = "B_ION_Soldier_lxWS";
    faction = "BLU_ION_lxWS";
    textureList[] = {"Black", 1};  // Select black texture
    hiddenSelectionsTextures[] = {
        "lxws\vehicles_f_lxws\data\offroad_01\offroad_01_ext_black_co.paa",
        "lxws\vehicles_f_lxws\data\offroad_01\offroad_01_ext_black_co.paa",
        "lxws\vehicles_f_lxws\offroad_01\data\offroad_01_adds_black_co.paa",
        "lxws\vehicles_f_lxws\offroad_01\data\offroad_01_armor_black_co.paa"
    };
};
Offroad Variants: Unarmed, AT, Armed
All use same black texture scheme
4 texture layers for different vehicle parts
Section 4: ION ZU-23 Variant (Lines 128-140)

Cpp

Apply
class a3a_ION_Truck_02_zu23_F : O_Tura_Truck_02_aa_lxWS {
    side = 1;
    crew = "B_ION_Soldier_lxWS";
    faction = "BLU_ION_lxWS";
    hiddenSelectionsTextures[] = {
        "lxws\vehicles_f_lxws\data\truck_02\truck_02_kab_black_co.paa",
        "lxws\vehicles_f_lxws\truck_02\data\truck_02_cargo_olive_co.paa",
        "a3\soft_f_beta\truck_02\data\truck_02_int_co.paa",
        "lxws\vehicles_f_lxws\zu23\data\zu23_base_co.paa",
        "lxws\vehicles_f_lxws\zu23\data\zu23_co.paa",
        "lxws\vehicles_f_lxws\zu23\data\zu23_addon_1_co.paa",
        "lxws\vehicles_f_lxws\zu23\data\zu23_addon_2_co.paa",
        "lxws\vehicles_f_lxws\truck_02\data\addons_black_co.paa"
    };
};
ZU-23 Anti-Air Truck: 8 texture layers
Black/olive color scheme for ION faction
Where it leads:

Included by WS/CfgVehicles.hpp (line 21)
Dependencies: Requires WS DLC vehicles and specific ION faction assets
Faction: All variants use BLU_ION_lxWS faction
Side: All set to side = 1 (Blufor)
Vanilla/air.hpp
File: A3A/addons/config_fixes/Vanilla/air.hpp
What it does:
Defines custom air vehicle variants for vanilla Arma 3, including black helicopters, ION variants, grey jets, and civilian aircraft.
How it does that:

Section 1: Black Helicopter (Lines 4-21)

Cpp

Apply
class a3a_Heli_Light_02_black_F : O_Heli_Light_02_dynamicLoadout_F {
    class TextureSources {
        class Black {
            author = "Bohemia Interactive";
            displayName = "Black";
            textures[] = {
                "\A3\Air_F\Heli_Light_02\Data\Heli_Light_02_ext_CO.paa"
            };
        };
        class Blackcustom {
            author = "Bohemia Interactive";
            displayName = "Black Custom";
            textures[] = {
                "\A3\Air_F_Heli\Heli_Light_02\Data\Heli_Light_02_ext_OPFOR_V2_CO.paa"
            };
        };
    };
    textureList[] = {"Black", 1, "Blackcustom", 1};  // Enable both textures
    hiddenSelectionsTextures[] = {
        "\A3\Air_F\Heli_Light_02\Data\Heli_Light_02_ext_CO.paa"
    };
};
TextureSources: Defines new texture options for selection
textureList: Enables both "Black" and "Blackcustom" textures
hiddenSelectionsTextures: Sets default texture (Black)
Section 2: ION Helicopters (Lines 23-44)

Cpp

Apply
class a3a_Heli_Light_01_Stripped_ION_F : B_Heli_Light_01_stripped_F {
    hiddenSelectionsTextures[] = {
        "a3\air_f\heli_light_01\data\heli_light_01_ext_ion_co.paa",
        ""  // Empty second texture
    };
};
class a3a_Heli_Light_01_ION_F : B_Heli_Light_01_F {
    hiddenSelectionsTextures[] = {
        "a3\air_f\heli_light_01\data\heli_light_01_ext_ion_co.paa",
        ""  // Empty second texture
    };
};
class a3a_Heli_Light_01_dynamicLoadout_ION_F : B_Heli_Light_01_dynamicLoadout_F {
    hiddenSelectionsTextures[] = {
        "a3\air_f\heli_light_01\data\heli_light_01_ext_ion_co.paa",
        "a3\air_f\heli_light_01\data\heli_light_01_dot_ca.paa"  // Dot texture
    };
};
3 ION helicopter variants: Stripped, standard, dynamic loadout
ION-specific texture on body
Second texture varies (empty, empty, dot)
Section 3: ION Heli Transport (Lines 46-54)

Cpp

Apply
class a3a_ION_Heli_Transport_02_F : I_Heli_Transport_02_F {
    textureList[] = {"ION", 1, "AAF", 0, "IDAP", 0, "Dahoman", 0};  // Select ION
    hiddenSelectionsTextures[] = {
        "a3\air_f_beta\heli_transport_02\data\skins\heli_transport_02_1_ion_co.paa",
        "a3\air_f_beta\heli_transport_02\data\skins\heli_transport_02_2_ion_co.paa",
        "a3\air_f_beta\heli_transport_02\data\skins\heli_transport_02_3_ion_co.paa",
        "a3\air_f_beta\heli_transport_02\data\heli_transport_02_int_02_co.paa"
    };
};
TextureList: Selects ION texture (value=1), disables others (value=0)
4 texture layers (3 external, 1 internal)
Section 4: Grey Jets (Lines 56-70)

Cpp

Apply
class a3a_Plane_Fighter_04_grey_F : I_Plane_Fighter_04_F {
    textureList[] = {"CamoGrey", 1, "DigitalCamoGreen", 0, "DigitalCamoGrey", 0};
    hiddenSelectionsTextures[] = {
        "a3\air_f_jets\plane_fighter_04\data\fighter_04_fuselage_01_co.paa",
        "a3\air_f_jets\plane_fighter_04\data\fighter_04_fuselage_02_co.paa",
        "a3\air_f_jets\plane_fighter_04\data\fighter_04_misc_01_co.paa",
        "a3\air_f_jets\plane_fighter_04\data\numbers\fighter_04_number_04_ca.paa",
        "a3\air_f_jets\plane_fighter_04\data\numbers\fighter_04_number_04_ca.paa",
        "a3\air_f_jets\plane_fighter_04\data\numbers\fighter_04_number_08_ca.paa"
    };
};
class a3a_Plane_Fighter_03_grey_F : I_Plane_Fighter_03_dynamicLoadout_F {
    textureList[] = {"Grey", 1, "Green", 0, "Hex", 0};
    hiddenSelectionsTextures[] = {
        "a3\air_f_gamma\plane_fighter_03\data\plane_fighter_03_body_1_greyhex_co.paa",
        "a3\air_f_gamma\plane_fighter_03\data\plane_fighter_03_body_2_greyhex_co.paa"
    };
};
F-14 (Fighter 04): 6 texture layers (fuselage, misc, numbers)
Gripen (Fighter 03): 2 texture layers (body sections)
Both select grey camo texture
Section 5: Civilian Aircraft (Lines 72-92)

Cpp

Apply
class a3a_C_Heli_Transport_02_F : I_Heli_Transport_02_F {
    crew = "C_man_pilot_F";  // Civilian pilot
    faction = "CIV_F";  // Civilian faction
    side = 3;  // Civilian side
    textureList[] = {"ION", 0, "AAF", 0, "IDAP", 0, "Dahoman", 1};  // Select Dahoman
    hiddenSelectionsTextures[] = {
        "a3\air_f_beta\heli_transport_02\data\skins\heli_transport_02_1_dahoman_co.paa",
        // ... 4 textures
    };
};
class a3a_C_Heli_Light_02_blue_F : O_Heli_Light_02_unarmed_F {
    crew = "C_man_pilot_F";
    faction = "CIV_F";
    side = 3;
    textureList[] = {"Opfor", 0, "Black", 0, "Blackcustom", 0, "Blue", 1};  // Select Blue
    hiddenSelectionsTextures[] = {
        "\a3\air_f\Heli_Light_02\Data\heli_light_02_ext_civilian_co.paa",
        // ... 4 textures
    };
};
Civilian Conversion: Changes crew, faction, side from military to civilian
Texture Selection: Dahoman for transport, Blue for light heli
Used for civilian air vehicle pool
Where it leads:

Included by CfgVehicles.hpp (line 5)
Dependencies: Requires vanilla Arma 3 air vehicles
Usage: Added to mission vehicle pools by faction
Vanilla/armor.hpp
File: A3A/addons/config_fixes/Vanilla/armor.hpp
What it does:
Defines custom armor vehicle variants for vanilla Arma 3, including grey MRAPs, olive APCs, black tanks, and grey railgun tanks.
How it does that:

Section 1: Grey MRAP Variants (Lines 4-20)

Cpp

Apply
class a3a_MRAP_03_grey_F : I_MRAP_03_F {
    hiddenSelectionsTextures[] = {
        "a3\soft_f_beta\mrap_03\data\mrap_03_ext_co.paa",
        "a3\data_f\vehicles\turret_co.paa"
    };
};
class a3a_MRAP_03_gmg_grey_F : I_MRAP_03_gmg_F {
    hiddenSelectionsTextures[] = {
        "a3\soft_f_beta\mrap_03\data\mrap_03_ext_co.paa",
        "a3\data_f\vehicles\turret_co.paa"
    };
};
class a3a_MRAP_03_hmg_grey_F : I_MRAP_03_hmg_F {
    hiddenSelectionsTextures[] = {
        "a3\soft_f_beta\mrap_03\data\mrap_03_ext_co.paa",
        "a3\data_f\vehicles\turret_co.paa"
    };
};
3 MRAP variants: Unarmed, GMG, HMG
Grey texture: Base MRAP texture + turret texture
No textureList override (uses parent)
Section 2: Olive APC (Lines 22-30)

Cpp

Apply
class a3a_APC_Wheeled_03_cannon_blufor_F : I_APC_Wheeled_03_cannon_F {
    textureList[] = {};  // Clear texture list
    hiddenSelectionsTextures[] = {
        "a3\armor_f_gamma\APC_Wheeled_03\data\APC_Wheeled_03_Ext_CO.paa",
        "a3\armor_f_gamma\APC_Wheeled_03\data\APC_Wheeled_03_Ext2_CO.paa",
        "a3\armor_f_gamma\APC_Wheeled_03\data\RCWS30_CO.paa",
        "a3\armor_f_gamma\APC_Wheeled_03\data\APC_Wheeled_03_Ext_alpha_CO.paa",
        "a3\armor_f\data\camonet_aaf_fia_desert_co.paa",
        "a3\armor_f\data\cage_sand_co.paa"
    };
};
Olive/Desert Camouflage: 6 texture layers
textureList[] = {} removes texture selection options
Uses AAF/FIA desert camonet and cage
Section 3: Black Tanks (Lines 32-50)

Cpp

Apply
class a3a_MBT_04_cannon_black_F : O_MBT_04_cannon_F {
    textureList[] = {};  // No texture selection
    hiddenSelectionsTextures[] = {
        "a3\armor_f_tank\mbt_04\data\mbt_04_exterior_1_co.paa",
        "a3\armor_f_tank\mbt_04\data\mbt_04_exterior_2_co.paa",
        "a3\armor_f\data\camonet_csat_stripe_desert_co.paa"
    };
};
class a3a_MBT_04_command_black_F : O_MBT_04_command_F {
    textureList[] = {};
    hiddenSelectionsTextures[] = {
        "a3\armor_f_tank\mbt_04\data\mbt_04_exterior_1_co.paa",
        "a3\armor_f_tank\mbt_04\data\mbt_04_exterior_2_co.paa",
        "a3\armor_f\data\camonet_csat_stripe_desert_co.paa"
    };
};
T-14 Armata Black: Command and cannon variants
3 texture layers (exterior parts + CSAT desert camonet)
Solid black exterior
Section 4: Grey T-100 Railgun Tanks (Lines 52-74)

Cpp

Apply
class a3a_MBT_02_cannon_grey_F : O_MBT_02_cannon_F {
    class TextureSources : TextureSources {
        class Grey {
            author = "Bohemia Interactive";
            displayName = "Grey";
            textures[] = {
                "a3\Armor_F_Decade\MBT_02\Data\MBT_02_body_expo_CO.paa",
                "a3\Armor_F_Decade\MBT_02\Data\MBT_02_turret_expo_CO.paa",
                "a3\Armor_F_Decade\MBT_02\Data\MBT_02_expo_CO.paa",
                "A3\Armor_F\Data\camonet_CSAT_HEX_Green_CO.paa"
            };
        };
    };
    textureList[] = {"Grey", 1};  // Select Grey texture
    hiddenSelectionsTextures[] = {
        "a3\Armor_F_Decade\MBT_02\Data\MBT_02_body_expo_CO.paa",
        "a3\Armor_F_Decade\MBT_02\Data\MBT_02_turret_expo_CO.paa",
        "a3\Armor_F_Decade\MBT_02\Data\MBT_02_expo_CO.paa",
        "A3\Armor_F\Data\camonet_CSAT_HEX_Green_CO.paa"
    };
};
class a3a_MBT_02_railgun_grey_F : O_MBT_02_railgun_F {
    textureList[] = {"Grey", 1};  // Select Grey texture
    hiddenSelectionsTextures[] = {
        "a3\Armor_F_Decade\MBT_02\Data\MBT_02_body_expo_CO.paa",
        "a3\Armor_F_Decade\MBT_02\Data\MBT_02_turret_expo_CO.paa",
        "a3\Armor_F_Decade\MBT_02\Data\MBT_02_expo_CO.paa",
        "A3\Armor_F\Data\camonet_CSAT_HEX_Green_CO.paa"
    };
};
TextureSources Override: Adds new "Grey" texture option
Grey Texture: Uses exhibition/exposure (expo) textures for grey color
Railgun Variant: Inherits textureList and hiddenSelectionsTextures
4 texture layers (body, turret, extra, camonet)
Where it leads:

Included by CfgVehicles.hpp (line 6)
Dependencies: Vanilla Arma 3 armor vehicles
Texture Sources: Adds new options to texture selection UI
Vanilla/CfgVehicles.hpp
File: A3A/addons/config_fixes/Vanilla/CfgVehicles.hpp
What it does:
Aggregates all vanilla vehicle configuration files into a single CfgVehicles class.
How it does that:

Cpp

Apply
class CfgVehicles {
    #include "air.hpp"
    #include "armor.hpp"
    #include "sea.hpp"
    #include "soft.hpp"
};
Structure: Creates CfgVehicles class with included sub-files
Includes:
air.hpp: Aircraft variants
armor.hpp: Tank/APC variants
sea.hpp: Boat variants
soft.hpp: Car/truck variants
Where it leads:

Included by Vanilla/config.cpp (line 22)
Sub-file Dependencies:
air.hpp → Vanilla/air.hpp
armor.hpp → Vanilla/armor.hpp
sea.hpp → Vanilla/sea.hpp
soft.hpp → Vanilla/soft.hpp
Global Impact: Adds all vanilla vehicle variants to mission
Vanilla/sea.hpp
File: A3A/addons/config_fixes/Vanilla/sea.hpp
What it does:
Defines custom boat variants for vanilla Arma 3.
How it does that:

Cpp

Apply
class a3a_Boat_Armed_01_hmg_blufor_F : O_Boat_Armed_01_hmg_F {
    scope = 2;
    textureList[] = {"Blufor", 1, "Indep", 0, "Opfor", 0};  // Select Blufor
    hiddenSelectionsTextures[] = {
        "a3\boat_f\boat_armed_01\data\boat_armed_01_ext_co.paa",
        "a3\boat_f\boat_armed_01\data\boat_armed_01_int_co.paa",
        "a3\boat_f\boat_armed_01\data\boat_armed_01_crows_blufor_co.paa"
    };
};
Blufor Boat Variant: Converts Opfor boat to Blufor
scope = 2: Available in editor
Texture Selection: Blufor = 1, others = 0
3 Texture Layers: Exterior, interior, weapon stations
Where it leads:

Included by CfgVehicles.hpp (line 7)
Base class: O_Boat_Armed_01_hmg_F (Opfor)
Result: Blufor-armed boat variant
Vanilla/soft.hpp
File: A3A/addons/config_fixes/Vanilla/soft.hpp
What it does:
Defines custom soft vehicle (cars, trucks, offroads, vans) variants for vanilla Arma 3.
How it does that:

Section 1: Base Class Declarations (Lines 4-16)

Cpp

Apply
class B_G_Offroad_01_AT_F;
class B_G_Offroad_01_F;
class B_G_Offroad_01_armed_F;
// ... more base class declarations
class Van_02_medevac_base_F;
class C_Van_02_medevac_F : Van_02_medevac_base_F {
    class TextureSources;  // Forward declaration
};
Forward declares all base vehicle classes
Forward declares TextureSources for Van_02_medevac
Section 2: Black Offroad Variants (Lines 18-42)

Cpp

Apply
class a3a_Offroad_01_black_F : B_G_Offroad_01_F {
    scope = 2;
    hiddenSelectionsTextures[] = {
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_blk_co.paa",
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_blk_co.paa"
    };
    textureList[] = {};  // Clear texture options
    animationList[] = {
        "HideDoor1", 0,
        "HideDoor2", 0,
        "HideDoor3", 0.333333,
        "HideBumper1", 0.5,
        "HideBumper2", 0.5
    };
};
Black Unarmed Offroad: 2 texture layers (body, body duplicate)
animationList: Controls model parts visibility
Doors: 0 = visible (except door3 = 0.333)
Bumpers: 0.5 = partially visible
Section 3: Black Armed Offroads (Lines 44-62)

Cpp

Apply
class a3a_Offroad_01_black_armed_F : B_G_Offroad_01_armed_F {
    scope = 2;
    hiddenSelectionsTextures[] = {
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_blk_co.paa",
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_blk_co.paa"
    };
    textureList[] = {};
    animationList[] = {
        "HideDoor1", 1,  // Doors hidden
        "HideDoor2", 1,
        "HideDoor3", 1,
        "HideBumper1", 0.5,
        "HideBumper2", 0.5
    };
};
AT Variant: Same as armed but with AT weapon
Doors: All hidden (value = 1)
Bumpers: Partially visible
Section 4: Black Offroad 02 Variants (Lines 64-82)

Cpp

Apply
class a3a_Offroad_02_black_unarmed_F : I_C_Offroad_02_unarmed_F {
    scope = 2;
    textureList[] = {
        "Black", 1, "Blue", 0, "Green", 0, "Orange", 0,
        "Red", 0, "White", 0, "Brown", 0, "Olive", 0, "IDAP", 0
    };
};
class a3a_Offroad_02_black_AT_F : I_C_Offroad_02_AT_F {
    scope = 2;
    textureList[] = {
        "Black", 1, "Blue", 0, "Green", 0, "Orange", 0,
        "Red", 0, "White", 0, "Brown", 0, "Olive", 0, "IDAP", 0
    };
};
class a3a_Offroad_02_LMG_black_F : I_C_Offroad_02_LMG_F {
    scope = 2;
    textureList[] = {
        "Black", 1, "Blue", 0, "Green", 0, "Orange", 0,
        "Red", 0, "White", 0, "Brown", 0, "Olive", 0, "IDAP", 0
    };
};
Offroad 02: Different model from Offroad 01
Texture Selection: Black = 1, all others = 0
3 Variants: Unarmed, AT, LMG
Section 5: Black LSV Variants (Lines 84-94)

Cpp

Apply
class a3a_LSV_02_AT_black_F : O_LSV_02_AT_F {
    scope = 2;
    textureList[] = {"Black", 1, "GreenHex", 0, "Arid", 0};
};
class a3a_LSV_01_AT_black_F : B_LSV_01_AT_F {
    scope = 2;
    textureList[] = {"Black", 1, "Olive", 0, "Sand", 0};
};
LSV 02 (Prowler): Black = 1, others = 0
LSV 01 (Hurricane): Black = 1, Olive/Sand = 0
Section 6: Van 02 Variants (Lines 96-138)

Cpp

Apply
class a3a_Van_02_black_transport_F : C_Van_02_transport_F {
    scope = 2;
    textureList[] = {
        "Swifd", 0, "IdapCargo", 0, "IdapTransport", 0, "IdapAmbulance", 0,
        "CivAmbulance", 0, "CivService", 0, "Syndikat", 0, "FIA3", 0,
        "FIA2", 0, "FIA1", 0, "Daltgreen", 0, "Vrana", 0, "BluePearl", 0,
        "Fuel", 0, "BattleBus", 0, "Green", 0, "Black", 1, "Red", 0,
        "Blue", 0, "Orange", 0, "White", 0
    };
};
Van 02: Modern van model with many texture options
TextureList: Selects Black texture, disables all others
Multiple variants: Transport, vehicle, service, medevac
Section 7: Van 02 Medevac (Lines 140-162)

Cpp

Apply
class a3a_Van_02_black_medevac_F : C_Van_02_medevac_F {
    scope = 2;
    class TextureSources : TextureSources {
        class Black {
            author = "Bohemia Interactive";
            displayName = "Black";
            materials[] = {
                "\a3\Soft_F_Orange\Van_02\Data\van_body.rvmat",
                "\A3\Soft_F_Orange\Van_02\Data\van_wheel.rvmat",
                "",
                "\a3\Data_f\Lights\Car_Beacon_Orange_emit.rvmat"
            };
            textures[] = {
                "\a3\Soft_F_Orange\Van_02\Data\van_body_Black_CO.paa",
                "\a3\soft_f_orange\van_02\data\van_wheel_co.paa",
                "\a3\soft_f_orange\van_02\data\van_glass_utility_CA.paa",
                "\a3\Soft_F_Orange\Van_02\Data\van_body_Black_CO.paa"
            };
        };
    };
    textureList[] = {"Black", 1, "White", 0, "CivAmbulance", 0, "IdapAmbulance", 0, "LDFAmbulance", 0};
};
TextureSources Override: Adds Black texture definition
Materials: 4 entries (body, wheel, empty, beacon)
Textures: 4 entries matching materials
TextureList: Selects Black
Section 8: Green/Tan/LDF/Gendarmerie Variants (Lines 164-208)

Cpp

Apply
class a3a_Offroad_01_green_F : B_G_Offroad_01_F {
    scope = 2;
    hiddenSelectionsTextures[] = {
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_grn_co.paa",
        "a3\soft_f_enoch\offroad_01\data\offroad_01_ext_grn_co.paa"
    };
    textureList[] = {"Green", 1};
};
Green Variant: Uses Enoch DLC green texture
textureList: Enables Green option
Tan Variant: Uses vanilla beige texture
LDF Variant: Sets faction to IND_E_F, crew to I_E_Soldier_F
Gendarmerie Variant: Sets faction to BLU_GEN_F, side = 1 (Blufor)
Where it leads:

Included by CfgVehicles.hpp (line 8)
Dependencies: Vanilla Arma 3 soft vehicles, Enoch DLC for some textures
Variant Types: 20+ vehicle variants across categories
SPEX/CfgVehicles.hpp
File: A3A/addons/config_fixes/SPEX/CfgVehicles.hpp
What it does:
Defines a civilian C-47 Skytrain variant for the SPEX WWII mod.
How it does that:

Cpp

Apply
class SPEX_C47_Skytrain;  // Base class
class SPEX_C47_CIV_Skytrain : SPEX_C47_Skytrain {
    crew = "C_man_pilot_F";  // Civilian pilot
    faction = "CIV_F";  // Civilian faction
    side = 3;  // Civilian side
    textureList[] = {"standard", 0, "bare", 1};  // Select bare metal
    hiddenSelectionsTextures[] = {
        "WW2\SPEX\addons\Assets_t_Vehicles_Planes_t\C47\DC3_Body_01_bare_co.paa",
        "WW2\SPEX\addons\Assets_t_Vehicles_Planes_t\C47\DC3_Body_02_bare_co.paa",
        "WW2\SPEX\addons\Assets_t_Vehicles_Planes_t\C47\DC3_Cargo_01_co.paa",
        ""  // Empty fourth texture
    };
};
Civilian Conversion: Changes from military to civilian
Texture Selection: "bare" = 1, "standard" = 0
3 Texture Layers: Body parts + cargo (4 total, one empty)
Where it leads:

Included by SPEX/config.cpp (line 21)
Dependencies: SPEX WWII mod (WW2\SPEX paths)
Base Class: SPEX_C47_Skytrain (military C-47)
Result: Civilian cargo plane variant
SPEX/config.cpp
File: A3A/addons/config_fixes/SPEX/config.cpp
What it does:
Configuration file for the SPEX (WWII) addon, defines dependencies and includes vehicle configurations.
How it does that:

Cpp

Apply
class CfgPatches {
    class PATCHNAME(SPEX) {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "A3_Data_F_AoW_Loadorder",
            "ww2_spex_assets_c_characters_americans_c"
        };
        author = AUTHOR;
        authors[] = { AUTHORS };
        authorUrl = "";
        VERSION_CONFIG;
        skipWhenMissingDependencies = 1;  // Skip if SPEX not installed
    };
};

#include "CfgVehicles.hpp"
Required Addons:
A3_Data_F_AoW_Loadorder: Arma 3 load order
ww2_spex_assets_c_characters_americans_c: SPEX character assets
skipWhenMissingDependencies = 1: Allows mod to load even if SPEX not installed
Includes: CfgVehicles.hpp with civilian C-47
Where it leads:

Dependencies: Requires SPEX mod or skips loading
Includes: SPEX/CfgVehicles.hpp
Global Impact: Adds civilian C-47 if SPEX is present
SPE/CfgVehicles.hpp
File: A3A/addons/config_fixes/SPE/CfgVehicles.hpp
What it does:
Defines custom vehicle variants for the SPE WWII mod, including trucks, tanks, and aircraft without insignias (removing unit markings).
How it does that:

Section 1: Base Class Declarations (Lines 4-50)

Cpp

Apply
class SPE_FFI_SdKfz250_1;  // German half-track
class SPE_FFI_OpelBlitz;  // German truck
// ... 50+ base class declarations
Forward declares all SPE vehicle classes
Allows reference before full definition
Section 2: No Insignia Variants (Lines 52-537)

Cpp

Apply
class SPE_FFI_SdKfz250_1_noinsignia : SPE_FFI_SdKfz250_1 {
    textureList[] = {};  // Clear texture list
    hiddenSelectionsTextures[] = {
        "WW2\SPE_Assets_t\Vehicles\WheeledAPC_t\SdKfz_250\250_Exterior_co.paa",
        "WW2\SPE_Assets_t\Vehicles\WheeledAPC_t\SdKfz_250\250_Wheels_co.paa",
        "WW2\SPE_Assets_t\Vehicles\WheeledAPC_t\SdKfz_250\250_Interior_co.paa",
        "WW2\SPE_Assets_t\Vehicles\WheeledAPC_t\SdKfz_250\250_Interior_Low_co.paa",
        "\a3\data_f\clear_empty.paa"  // Empty texture for insignia layer
    };
};
_noinsignia Suffix: Naming convention for variants without unit markings
textureList[] = {}: Removes texture selection options
hiddenSelectionsTextures: Override textures
\a3\data_f\clear_empty.paa: Used to hide insignia layer (transparent texture)
Section 3: Multiple No-Insignia Variants (Lines 54-537) The file contains 100+ no-insignia variants across:

German Vehicles: OpelBlitz (truck), PzKpfwIII (tank), Nashorn (tank destroyer)
French Vehicles: M10, M4A0, M4A1 variants
US Vehicles: M18 Hellcat, M4A1 Calliope, G503 MB (jeep), CCKW (truck)
Halftracks: M3, M16 variants
Aircraft: FW190F8, P-47
Each follows the same pattern:

Cpp

Apply
class <Original>_noinsignia : <Original> {
    textureList[] = {};  // Clear selection
    hiddenSelectionsTextures[] = { /* textures with empty for insignia */ };
};
Where it leads:

Included by SPE/config.cpp (line 22)
Dependencies: Requires SPE WWII mod
Base Classes: All SPE vehicle classes
Result: 100+ vehicle variants without unit markings
SOG_NK/CfgVehicles.hpp
File: A3A/addons/config_fixes/SOG_NK/CfgVehicles.hpp
What it does:
Defines custom AC-119 gunship variants for the SOG Nickel Steel mod, removing insignias.
How it does that:

Cpp

Apply
class vnx_i_air_ac119_01_01;  // Base AC-119
class vnx_i_air_ac119_01_01_noinsignia : vnx_i_air_ac119_01_01 {
    hiddenSelections[] = {
        "camo1", "camo2", "camo3", "camo4", "camo5", "camo6",
        "none", "d_rank_pilot", "d_rank_copilot",
        "d_name_pilot_01", "d_name_pilot_02", "d_name_pilot_03",
        // ... 10 pilot name slots
        "d_name_copilot_01", "d_name_copilot_02", "d_name_copilot_03",
        // ... 10 copilot name slots
    };
    hiddenSelectionsTextures[] = {
        "vnx\air_f_vietnam_04\ac119\data\vnx_air_ac119_ext_01_01_co.paa",
        // ... 6 camouflage textures
        "\a3\data_f\clear_empty.paa"  // Empty for insignia/none selection
    };
};
hiddenSelections[]: Lists all selectable model parts (camo, ranks, names)
hiddenSelectionsTextures[]: 6 camo textures + 1 empty (for "none" selection)
Naming Convention: _noinsignia suffix
Variants: 10+ AC-119 variants (different factions, camos, configurations)

Where it leads:

Included by SOG_NK/config.cpp (when implemented)
Dependencies: SOG Nickel Steel mod (vnx paths)
Base Classes: All AC-119 variants
Result: Gunships without unit markings
SOG/CfgVehicles.hpp
File: A3A/addons/config_fixes/SOG/CfgVehicles.hpp
What it does:
Defines extensive custom vehicle variants for the SOG WWII mod, removing insignias and providing texture variants.
How it does that:

Section 1: Base Class Declarations (Lines 4-70)

Cpp

Apply
class vn_b_armor_m113_01_aus_army;  // Australian M113
class vn_b_armor_m125_01_aus_army;  // Australian M125
// ... 70+ base class declarations
Forward declares SOG vehicle classes
Section 2: Vehicle Variants Without Insignias (Lines 72-757) The file contains 100+ no-insignia variants for:

Australian Vehicles: M113 variants, LR2A variants
Soviet Vehicles: BTR-40 variants, M151 variants
Vietnamese Vehicles: BTR-40, PT-76, T-54 variants
Aircraft: OH-6A Little Bird, MiG-19, MiG-21, UH-1 variants
Helicopters: Ach47, Ah1g, Ch34, Ch47 variants
Example - Little Bird (Lines 146-170):

Cpp

Apply
class vn_b_air_oh6a_07_noinsignia : vn_b_air_oh6a_07 {
    hiddenSelectionsTextures[] = {
        "\vn\air_f_vietnam\oh6a\data\vn_b_air_oh6_ext_01_co.paa",  // Main body
        "\a3\data_f\clear_empty.paa",  // Empty for insignia
        "\a3\data_f\clear_empty.paa",  // Empty for insignia
        "\a3\data_f\clear_empty.paa",  // Empty for insignia
        "\a3\data_f\clear_empty.paa",  // Empty for insignia
        "\a3\data_f\clear_empty.paa",  // Empty for insignia
        "\a3\data_f\clear_empty.paa",  // Empty for insignia
        "\a3\data_f\clear_empty.paa",  // Empty for insignia
        "\a3\data_f\clear_empty.paa"   // Empty for insignia
    };
};
9 Texture Layers: 1 body texture + 8 empty layers for insignias
Example - TextureList Variants (Lines 200-300):

Cpp

Apply
class vn_b_armor_m113_01_aus_army_noinsignia : vn_b_armor_m113_01_aus_army {
    textureList[] = {"m113_01", 1, "m113_43", 1};  // Enable both textures
};
textureList[]: Defines available textures and enables them (value = 1)
Example - MiG Variants (Lines 400-500):

Cpp

Apply
class vn_o_air_mig19_bmb_noinsignia : vn_o_air_mig19_bmb {
    hiddenSelectionsTextures[] = {
        "vn\air_f_vietnam_02\mig19\data\vn_air_mig19_01_01_co.paa",
        "vn\air_f_vietnam_02\mig19\data\vn_air_mig19_02_01_co.paa",
        "vn\air_f_vietnam_02\mig19\data\vn_air_mig19_03_01_co.paa",
        "vn\air_f_vietnam_02\mig19\data\vn_air_mig19_04_01_co.paa",
        "\a3\data_f\clear_empty.paa",
        "\a3\data_f\clear_empty.paa"
    };
};
MiG-19: 4 body textures + 2 empty layers
Example - UH-1 Variants (Lines 550-650):

Cpp

Apply
class vn_b_air_uh1c_01_01_noinsignia : vn_b_air_uh1c_01_01 {
    textureList[] = {"uh1c_05", 1, "uh1c_04", 1, "uh1c_17", 1, "uh1c_18", 1, "uh1c_01", 0, "uh1c_21", 0};
    hiddenSelectionsTextures[] = {
        "vn\air_f_vietnam\uh1\data\vn_air_uh1_c_ext_01_co.paa",
        "vn\air_f_vietnam\uh1\data\vn_air_uh1_c_ext_02_co.paa",
        "a3\data_f\clear_empty.paa",
        "a3\data_f\clear_empty.paa",
        "a3\data_f\clear_empty.paa",
        "vn\air_f_vietnam_02\uh1\data\vn_air_uh1_kitbash_01_co.paa"
    };
};
UH-1C: textureList with 6 options (4 enabled, 2 disabled)
6 Texture Layers: 2 body + 3 empty + 1 kitbash
Where it leads:

Included by SOG/config.cpp (when implemented)
Dependencies: SOG WWII mod (vn paths)
Base Classes: All SOG vehicle classes
Result: 100+ variants without insignias, multiple texture options
RF/CfgVehicles.hpp
File: A3A/addons/config_fixes/RF/CfgVehicles.hpp
What it does:
Defines custom vehicle and helicopter variants for the RF (Response Force) DLC, including pickup trucks with miniguns and helicopters with custom loadouts.
How it does that:

Section 1: AU Pickup Minigun Variants (Lines 4-94)

Cpp

Apply
class AU_B_Pickup_Minigun_RF: Pickup_01_minigun_base_rf {
    scope = 2;
    faction = "BLU_F";  // NATO
    side = 1;
    textureList[] = {"NATO", 1};  // Select NATO texture
    animationList[] = {
        "hide_bullbar", 0.5,
        "hide_snorkel", 0.5,
        "hide_trunk_door", 0,
        "hide_sidesteps", 0,
        "hide_frame", 1,
        "hide_box", 0,
        "hide_box_door", 0
    };
    editorPreview = QPATHTOFOLDER(Pictures\vehicles\AU_B_Pickup_Minigun_RF.jpg);
};
AnimationList: Controls model parts:
bullbar/snorkel: 0.5 = partially visible
trunk door/sidesteps: 0 = visible
frame: 1 = visible (rolled bar)
box/box_door: 0 = visible
editorPreview: Path to editor preview image (macro expanded)
Multiple Faction Variants: NATO, NATO_T, CSAT, CSAT_T, AAF, LDF, Guerrilla
Section 2: Black Pickup Variants (Lines 96-130)

Cpp

Apply
class a3a_black_Pickup_rf : C_Pickup_rf {
    textureList[] = {};
    hiddenSelectionsTextures[] = {
        "\lxRF\vehicles_rf\pickup_01\Data\pickup_01_ext_black_co.paa",
        "\lxRF\vehicles_rf\pickup_01\Data\pickup_01_adds_white_tank_co.paa",
        "\lxrf\vehicles_rf\pickup_01\data\pickup_01_ext2_co.paa",
        "\lxrf\vehicles_rf\pickup_01\data\pickup_01_AAT_olive_co.paa",
        "\lxrf\vehicles_rf\pickup_01\data\pickup_01_launcher_co.paa",
        "\lxRF\vehicles_rf\pickup_01\Data\pickup_01_service_black_co.paa"
    };
};
class a3u_black_Pickup_rival_rf : a3a_black_Pickup_rf {
    animationList[] = {
        "hide_rack", 0,
        "hide_antenna", 1,
        "hide_bullbar", 0,
        "hide_snorkel", 1,
        "hide_armor_window_armor_top", 1,
        "hide_trunk_cover", 0,
        "hide_sidesteps", 0,
        "trunk_door_open", 0
    };
};
Black Pickup: 6 texture layers (exterior, adds, exterior2, AAT, launcher, service)
Rival Variant: Different animation configuration
Section 3: Helicopter Loadout Configuration (Lines 140-220)

Cpp

Apply
class a3a_Heli_light_03_dynamicLoadout_RF : B_Heli_light_03_dynamicLoadout_RF {
    class Components : Components {
        class TransportPylonsComponent : TransportPylonsComponent {
            class Presets {
                class Default {
                    attachment[] = {
                        "PylonRack_19Rnd_missiles_gray_RF",
                        "PylonWeapon_1000Rnd_20x102mm_shells_gray_RF",
                        "PylonRack_19Rnd_missiles_gray_RF",
                        "PylonWeapon_1000Rnd_20x102mm_shells_gray_RF"
                    };
                    displayName = "Default";
                };
                class Empty {
                    attachment[] = {};
                    displayName = "Empty";
                };
            };
            class Pylons {
                class PylonLeft1 {
                    attachment = "PylonRack_19Rnd_missiles_gray_RF";
                    hardpoints[] = {
                        "DAR", "DAGR", "B_SHIEKER", "UNI_SCALPEL",
                        "20MM_TWIN_CANNON", "B_ASRRAM_EJECTOR",
                        "WEAPON_PODS_RF", "B_BOMB_PYLON"
                    };
                    priority = 5;
                    turret[] = {0};
                    UIposition[] = {"0.06 + 0.02", 0.4};
                };
                // ... 3 more pylons
            };
        };
    };
};
Pylons Configuration:
4 Pylons: Left1, Left2, Right1, Right2
Default Preset: 2 missile racks + 2 cannon pods
Hardpoints: Compatible weapon types array
UIposition: Visual placement in UI
Section 4: Helicopter Texture Variants (Lines 222-270)

Cpp

Apply
class a3a_AAF_Heli_light_03_dynamicLoadout_RF : a3a_Heli_light_03_dynamicLoadout_RF {
    textureList[] = {};
    hiddenSelectionsTextures[] = {
        "\A3\Air_F_EPB\Heli_Light_03\data\Heli_Light_03_base_INDP_CO.paa",
        "\lxRF\air_rf\Heli_Light_03\data\wildcat_addons_INDP_co.paa"
    };
};
class a3a_black_Heli_light_03_dynamicLoadout_RF : a3a_Heli_light_03_dynamicLoadout_RF {
    textureList[] = {};
    hiddenSelectionsTextures[] = {
        "\lxRF\air_rf\Heli_Light_03\data\Heli_Light_03_base_black_CO.paa",
        "\lxRF\air_rf\Heli_Light_03\data\wildcat_addons_black_co.paa"
    };
};
Texture Variants: AAF, LDF, Black
2 Texture Layers: Main body + addons
Section 5: Heli EC-02 Configuration (Lines 272-313)

Cpp

Apply
class a3a_Heli_EC_02_RF : Heli_EC_02_base_RF {
    scope = 2;
    faction = "IND_F";
    side = 2;
    hiddenSelectionsTextures[] = {
        "\lxRF\air_rf\heli_medium_ec\data\as332_exterior_02_aaf_co.paa",
        "\lxRF\air_rf\heli_medium_ec\data\as332_int_cargo_co.paa",
        "#(rgb,1024,1024,1)ui('lxRF_MFDMinimap','lxRF_MFDMinimap')",
        "\lxRF\air_rf\heli_medium_ec\data\as332_adds_02_aaf_co.paa",
        "\lxRF\air_rf\heli_medium_ec\data\as332_exterior_02_aaf_co.paa",
        "\lxRF\air_rf\heli_medium_ec\data\as332_int_cargo_co.paa"
    };
    class Components : Components {
        class TransportPylonsComponent {
            uiPicture = "\lxRF\air_rf\heli_medium_ec\data\UI\heli_medium_ec_02_3DEN_CA.paa";
            class Presets {
                class AT {
                    attachment[] = {
                        "PylonRack_4Rnd_LG_scalpel",
                        "PylonRack_4Rnd_LG_scalpel",
                        "PylonRack_4Rnd_LG_scalpel",
                        "PylonRack_4Rnd_LG_scalpel"
                    };
                    displayName = "AT";
                };
                // ... Default and Empty presets
            };
            class Pylons {
                // 4 pylons configuration
            };
        };
    };
};
Heli EC-02 (AS332 Super Puma):
Faction: AAF (IND_F)
6 texture layers (exterior, interior, MFD, addons, exterior duplicate, interior duplicate)
uiPicture: 3D Eden editor preview
Pylons: 4 hardpoints with AT/Default/Empty presets
Where it leads:

Included by RF/config.cpp (when implemented)
Dependencies: RF DLC (lxRF paths)
Base Classes: RF vehicle and helicopter classes
Result: 20+ pickup variants, 10+ helicopter variants with custom loadouts
IFA/CfgVehicles.hpp
File: A3A/addons/config_fixes/IFA/CfgVehicles.hpp
What it does:
Defines custom vehicle variants for the IFA WWII mod, including German C-47, Soviet Willys, German Panzer IV, and Italian repair truck.
How it does that:

Section 1: German C-47 (Lines 2-18)

Cpp

Apply
class LIB_C47_Skytrain;  // Base C-47
class A3U_LIB_C47_German: LIB_C47_Skytrain {
    author = AUTHOR;
    displayName = "C-47 Skytrain (German)";
    scope = 2;
    side = -1;  // No side (neutral)
    faction = "LIB_WEHRMACHT";  // German faction
    hiddenSelectionsTextures[] = {
        QPATHTOFOLDER(IFA\data\dc3_body_01_bob_co.paa),
        QPATHTOFOLDER(IFA\data\dc3_body_02_co.paa)
    };
};
German C-47: Side = -1 (neutral), Faction = German
2 Texture Layers: Body sections
QPATHTOFOLDER: Macro that expands to absolute path
Section 2: Soviet Willys (Lines 20-30)

Cpp

Apply
class a3a_LIB_Willys_MB_M1919 : LIB_US_Willys_MB_M1919 {
    hiddenSelectionsTextures[] = {
        "WW2\Assets_t\Vehicles\Cars_t\IF_Willys_MB\Willys_co.paa",
        "WW2\Assets_t\Vehicles\Cars_t\IF_Willys_MB\Willys_Additional_co.paa"
    };
    typicalCargo[] = {"LIB_SOV_AT_soldier"};  // Soviet cargo
    crew = "LIB_SOV_unequip";  // Soviet crew
    faction = "LIB_RKKA";  // Soviet faction
    side = 0;  // Opfor
};
Soviet Conversion: Changed from US to Soviet
Cargo/Crew: Soviet soldier classes
2 Texture Layers: Body + additional
Section 3: German Panzer IV (Lines 32-40)

Cpp

Apply
class a3a_lib_PzKpfwIV_noShield : LIB_DAK_PzKpfwIV_H {
    faction = "LIB_WEHRMACHT";
    hiddenSelectionsTextures[] = {
        "\WW2\Assets_t\Vehicles\Tanks_t\IF_PzKpfwIV_H\Body_co.paa",
        "\WW2\Assets_t\Vehicles\Tanks_t\IF_PzKpfwIV_H\Turret_co.paa",
        "\WW2\Assets_t\Vehicles\Tanks_t\IF_PzKpfwIV_H\Wheels_co.paa",
        "\WW2\Assets_t\Vehicles\Tanks_t\IF_PzKpfwIV_H\Tracks_co.paa"
    };
};
Panzer IV: German faction
4 Texture Layers: Body, turret, wheels, tracks
Section 4: Italian Repair Truck (Lines 42-48)

Cpp

Apply
class a3a_lib_Zis6_BOX : LIB_Zis6_Parm {
    displayName = "ZIS-5V (Box)";
    transportRepair = 0;  // No repair cargo
    typicalCargo[] = {"LIB_FFI_LAT_Soldier"};  // French partisan
    faction = "LIB_FFI";  // French faction
    side = 2;  // Independent
};
Repair Truck: Converted to French partisan vehicle
transportRepair = 0: Disables repair functionality
French Cargo/Faction
Section 5: Event Handlers Fix (Lines 50-55)

Cpp

Apply
class Tank;
class LIB_Armored_Target_Dummy : Tank {
    delete EventHandlers;  // Remove event handlers
};
EventHandlers Fix: Removes problematic event handlers from dummy tank
Prevents errors on spawn
Section 6: Aircraft Nose-Fall Tweaks (Lines 57-86)

Cpp

Apply
class LIB_GER_Plane_base;
class LIB_FW190F8 : LIB_GER_Plane_base {
    draconicTorqueXCoef = 2;  // Increase AI turn rate
};
class LIB_SU_Plane_base;
class LIB_P39 : LIB_SU_Plane_base {
    draconicTorqueXCoef = 2;
};
draconicTorqueXCoef: Controls AI plane turn rate
Value = 2: Increases from default (usually 1)
Applies to: FW190F8, P-39, Pe-2, P-47
Purpose: Improves AI dogfighting behavior
Where it leads:

Included by IFA/config.cpp (when implemented)
Dependencies: IFA WWII mod (WW2\Assets_t paths)
Base Classes: IFA vehicle and plane classes
Result: 5+ custom variants, AI plane handling improvements
GM/CfgVehicles.hpp
File: A3A/addons/config_fixes/GM/CfgVehicles.hpp
What it does:
Defines custom vehicle variants for the GM (Global Mobilization) DLC, removing insignias from 100+ Cold War vehicles.
How it does that:

Section 1: Base Class Declarations (Lines 4-70)

Cpp

Apply
class gm_dk_army_m113a1dk_apc;  // Danish M113
class gm_dk_army_m113a1dk_command;  // Danish command M113
// ... 70+ base class declarations
Forward declares GM vehicle classes
Section 2: No Insignia Variants (Lines 72-717) The file contains 100+ no-insignia variants using the gm_InsigniasDefaultNation and gm_InsigniasDefaultFlag properties:

Cpp

Apply
class gm_ge_army_fuchsa1_jammer_noinsignia : gm_ge_army_fuchsa1_jammer {
    gm_InsigniasDefaultNation = "gm_insignia_none";
    gm_InsigniasDefaultFlag = "gm_insignia_none";
};
gm_InsigniasDefaultNation: Sets nation insignia to "none"
gm_InsigniasDefaultFlag: Sets flag insignia to "none"
Naming: _noinsignia suffix
Variants Include:

Danish Vehicles: M113A1DK, M109, Leopard1a3 variants
German Vehicles: M113A1G, Leopard1a1-1a5, Marder, Fuchs, Bo105 helicopters
East German Vehicles: BMP1, BRDM2, BTR60, T-55 variants
Polish Vehicles: Similar to East German
Various Support Vehicles: MLRS, artillery, medical, repair, etc.
Where it leads:

Included by GM/config.cpp (when implemented)
Dependencies: GM DLC (gm paths)
Base Classes: All GM vehicle classes
Result: 100+ variants without insignias
CUP/CfgVehicles.hpp
File: A3A/addons/config_fixes/CUP/CfgVehicles.hpp
What it does:
Defines custom vehicle variants for the CUP (Community Upgrade Project) mod, including HMMWVs, Land Rovers, trucks, and aircraft with nose-fall tweaks.
How it does that:

Section 1: HMMWV Variants (Lines 4-100)

Cpp

Apply
class a3u_cup_m1025_unarmed_olive : CUP_B_nM1025_Unarmed_USA_DES {
    textureList[] = {"NATOGreen", 1};  // Select NATO Green
    animationList[] = {
        "hide_front_left_antenna", 1,
        "hide_front_right_antenna", 1,
        "hide_rear_left_antenna", 1,
        "hide_rear_right_antenna", 0,
        "hide_left_mirror", 0,
        "hide_right_mirror", 0,
        "hide_brushguard", 1,
        "hide_blue_force_tracker", 1,
        "hide_jerrycans", 1,
        "hide_spare_wheel", 1,
        "hide_spare_wheel_mount", 1,
        "hide_door_front_left", 1,
        "hide_door_front_right", 1,
        "hide_door_rear_left", 1,
        "hide_door_rear_right", 1,
        "hide_ammo_cans", 1,
        "hide_cip", 1,
        "hide_rear_view_camera", 1,
        "hide_radio_small", 0,
        "hide_radio_large", 1,
        "hide_old_front_bumper", 1,
        "hide_old_rear_bumper", 1
    };
    hiddenSelectionsTextures[] = {
        "CUP\WheeledVehicles\CUP_WheeledVehicles_NewHMMWV\Data\nato_olive\body_co.paa",
        "CUP\WheeledVehicles\CUP_WheeledVehicles_NewHMMWV\Data\nato_olive\roof_co.paa",
        "CUP\WheeledVehicles\CUP_WheeledVehicles_NewHMMWV\Data\nato_olive\snorkel_mesh_ca.paa",
        "CUP\WheeledVehicles\CUP_WheeledVehicles_NewHMMWV\Data\nato_olive\chassis_co.paa",
        "CUP\WheeledVehicles\CUP_WheeledVehicles_NewHMMWV\Data\attachments_co.paa",
        "CUP\WheeledVehicles\CUP_WheeledVehicles_NewHMMWV\Data\nato_olive\interior_co.paa",
        "CUP\WheeledVehicles\CUP_WheeledVehicles_NewHMMWV\Data\nato_olive\interior_detail_co.paa",
        // ... 16+ more texture entries (mostly empty/transparent)
    };
};
AnimationList: 22+ animations to control HMMWV attachments
hiddenSelectionsTextures: 23 texture entries (many empty/transparent for removed parts)
Multiple HMMWV Variants: Unarmed, M240, SOV M2, TOW
Section 2: Land Rover & Truck Variants (Lines 102-130)

Cpp

Apply
class a3u_cup_lr_mg_wl : CUP_B_LR_MG_GB_W {
    animationList[] = {
        "selection_tool", 1,
        "selection_jerry", 1,
        "selection_antenna", 1,
        "selection_antenna_rear", 1,
        "selection_box", 1,
        "selection_steps", 0,
        "selection_wheelfront", 1,
        "selection_wheels", 1,
        "selection_bar", 0,
        "selection_tarp", 0,
        "selection_doors", 1,
        "selection_rear", 1,
        "selection_wind", 0
    };
    hiddenSelectionsTextures[] = {
        "cup\wheeledvehicles\cup_wheeledvehicles_lr\data\textures\gb_w_lr_base_co.paa",
        "cup\wheeledvehicles\cup_wheeledvehicles_lr\data\textures\gb_w_lr_special_co.paa",
        "cup\wheeledvehicles\cup_wheeledvehicles_lr\data\jackal_base_woodlnd_co.paa",
        "cup\wheeledvehicles\cup_wheeledvehicles_lr\data\jackal_mount_woodlnd_co.paa"
    };
};
class a3u_cup_mtvr_wl: CUP_B_MTVR_USA {
    animationList[] = {"hideTarp", 1};  // Hide tarp
    hiddenSelectionsTextures[] = {
        "CUP\WheeledVehicles\CUP_WheeledVehicles_MTVR\Data\Textures\mtvr_body_baf_wood_co.paa",
        // ... 4 textures
    };
};
Land Rover: 13 animations, 4 textures (woodland camo)
MTVR: 1 animation (hide tarp), 4 textures (woodland)
Section 3: Cessna Aircraft (Lines 132-142)

Cpp

Apply
class a3u_cup_cessna: CUP_C_CESSNA_CIV {
    textureList[] = {"mil_olive", 1};  // Select military olive
    hiddenSelectionsTextures[] = {
        "CUP\AirVehicles\CUP_AirVehicles_Cessna\data\new\skins\body_olivedrab_co.paa"
    };
};
class a3u_cup_cessna_t41: CUP_I_CESSNA_T41_ARMED_ION {
    textureList[] = {"mil_olive", 1};
    hiddenSelectionsTextures[] = {
        "CUP\AirVehicles\CUP_AirVehicles_Cessna\data\new\skins\body_olivedrab_co.paa"
    };
};
Cessna T-41: Military olive texture
T-41 Armed: Same texture
Section 4: Eastern Militia Vehicles (Lines 144-162)

Cpp

Apply
class a3u_cup_uaz_unarmed_convertible_1 : CUP_B_UAZ_Unarmed_CDF {
    textureList[] = {"CDF", 1};  // Select CDF texture
    animationList[] = {
        "hide_spare_wheel", 0,
        "hide_lower_tarp", 0,
        "hide_upper_tarp", 1,
        "hide_light_covers", 0
    };
};
class a3u_cup_kamaz_olive : CUP_B_Kamaz_CDF {
    textureList[] = {"Green", 1};  // Select Green
};
UAZ: CDF texture, 4 animations
Kamaz: Green texture
Section 5: Aircraft Nose-Fall Tweaks (Lines 164-220)

Cpp

Apply
class CUP_A10_Base : Plane_Base_F {
    draconicTorqueXCoef = 2;  // Increase AI turn rate
};
class CUP_L39_base : Plane_base_F {
    draconicTorqueXCoef = 2;
};
class CUP_AV8B_Base : Plane {
    draconicTorqueXCoef[] = {2,3,4,5,6,7,8,9,10,10.1,10.2};  // Speed-based array
};
class CUP_Su25_base : Plane {
    draconicTorqueXCoef[] = {2,3,4,5,6,7,8,9,10,10.1,10.2};
};
class CUP_F35B_base : Plane {
    draconicTorqueXCoef[] = {2,3.5,5,6.5,8,9,10,11,12,12.1,12.2};
};
draconicTorqueXCoef: Controls AI plane turn rate
Scalar (A10, L39): Constant value = 2
Array (AV8B, Su25, F35, Su34): Speed-dependent values
Index 0 = 0 m/s, index 10 = max speed
Higher values at higher speeds for better turning
Where it leads:

Included by CUP/config.cpp (line 22)
Dependencies: CUP mod (CUP paths)
Base Classes: CUP vehicle and plane classes
Result: 20+ vehicle variants, aircraft handling improvements
CUP/sfp_air.hpp
File: A3A/addons/config_fixes/CUP/sfp_air.hpp
What it does:
Defines custom Swedish Air Force (SFP) helicopter variants for CUP, specifically UH-60M Blackhawk variants.
How it does that:

Cpp

Apply
class a3a_SFP_B_UH60S_USN : CUP_B_UH60S_USN {
    displayName = "UH-60M (M3M)";
    textureList[] = {"Black", 1};  // Select Black texture
    animationList[] = {
        "Navyclan_hide", 1,
        "Navyclan2_hide", 1,
        "Filters_Hide", 1,
        "mainRotor_folded", 1,
        "mainRotor_unfolded", 0,
        "Hide_ESSS2x", 1,
        "Hide_ESSS4x", 1,
        "Hide_Nose", 0,
        "Blackhawk_Hide", 0,
        "Hide_FlirTurret", 1,
        "Hide_Probe", 1,
        "Doorcock_Hide", 0
    };
};
3 Variants: M3M armed, Unarmed, Unarmed/FFV
Black Texture: All use black color scheme
AnimationList: 12 animations (rotor fold, ESSS, FLIR, probe, doors)
Where it leads:

Included by CUP/CfgVehicles.hpp (line 4)
Dependencies: CUP UH-60 models
Result: 3 Swedish UH-60M variants
CSLA/CfgVehicles.hpp
File: A3A/addons/config_fixes/CSLA/CfgVehicles.hpp
What it does:
Defines custom vehicle variants for the CSLA (Czechoslovak Socialist Army) mod, removing insignias from 100+ Cold War vehicles.
How it does that:

Section 1: Base Class Declarations (Lines 4-34)

Cpp

Apply
class CSLA_PLdvK59V3S;  // V3S truck
class CSLA_BVP1;  // APC
// ... 30+ base class declarations
Section 2: No Insignia Variants (Lines 36-267) The file contains 100+ no-insignia variants using hiddenSelections[] to disable insignia layers:

Cpp

Apply
class CSLA_PLdvK59V3S_noinsignia : CSLA_PLdvK59V3S {
    hiddenSelections[] = {
        "camo1", "camo2", "camo3", "camo4", "camo5",
        "none", "none2",
        "emblem1_hull",  // Insignia/emblem layer
        "cislo1", "cislo2", "cislo3", "cisloN",  // Number/serial layers
        "emblem1_turret"  // Turret emblem
    };
};
hiddenSelections[]: Lists all selectable model parts
Insignia Layers: emblem1_hull, cislo1-3, cisloN, emblem1_turret
By disabling these: Removes unit markings and numbers
Variants Include:

Vehicles: V3S trucks, BTR-60, OT-64, T-55 variants
Helicopters: Mi-17, Mi-24V
Support Vehicles: MLRS, artillery, medical, repair
FIA Vehicles: Insurgent variants
AFMC Vehicles: US vehicles in CSLA context
Where it leads:

Included by CSLA/config.cpp (when implemented)
Dependencies: CSLA mod (CSLA paths)
Base Classes: All CSLA vehicle classes
Result: 100+ variants without insignias
CfgWeapons/bomb_weapons.hpp
File: A3A/addons/config_fixes/CfgWeapons/bomb_weapons.hpp
What it does:
Defines weapon modes for bomb launchers, converting them from rocket pods to full-auto capable weapons for AI targeting.
How it does that:

Section 1: Mode Definitions (Lines 2-20)

Cpp

Apply
class Single_Mode: Mode_SemiAuto {
    showEmpty = 1;
    reloadTime = 0;  // Instant reload for AI
    dispersion = 0.008;  // Accuracy
    aiRateOfFire = 4;  // Seconds between shots
    autoFire = 1;  // Auto-fire enabled
    aiRateOfFireDistance = 800;  // Effective range
    aiRateOfFireDispersion = 0;
    minRange = 200;  // Minimum engagement range
    minRangeProbab = 0.4;  // Probability at min range
    midRange = 600;
    midRangeProbab = 0.9;
    maxRange = 1200;
    maxRangeProbab = 0.05;
    sounds[] = {};  // No sound
};
class FullAuto_Mode: Single_Mode {
    aiRateOfFire = 10;  // Slower rate for full auto
    aiRateOfFireDistance = 800;
    autoFire = 1;
    displayName = "Full";
    showToPlayer = 0;  // Hidden from player
    textureType = "fullAuto";
};
Single_Mode: Semi-auto mode (but with autoFire = 1)
FullAuto_Mode: Full-auto mode (slower ROF, hidden from player)
No sounds: Silent for AI targeting
Ranges: 200-1200m effective range
Probabilities: High at mid-range (0.9)
Section 2: Mk82 Bomb Launcher (Lines 22-36)

Cpp

Apply
class Mk82BombLauncher: RocketPods {
    canLock = 0;  // Cannot lock (bombs are dumb)
    autoFire = 1;  // Auto-fire enabled
    ballisticsComputer = 0;  // No ballistic computer
    magazineReloadSwitchPhase = 0;
    magazineReloadTime = 0;  // Instant reload
    aiRateOfFire = 0.5;  // Fast AI fire rate
    aiRateOfFireDistance = 300;
    minRange = 50;  // Minimum range 50m
    modes[] = {"Single", "FullAuto"};
    class Single: Single_Mode {};
    class FullAuto: FullAuto_Mode {};
};
Inherits from: RocketPods (base class)
Modes: Uses Single and FullAuto modes defined above
Instant reload: For AI targeting purposes
No lock: Bombs are unguided
Section 3: CUP Mk82 Launcher (Lines 38-58)

Cpp

Apply
class CUP_Vblauncher_Mk82_veh: RocketPods {
    canLock = 0;
    autoFire = 1;
    ballisticsComputer = 0;
    magazineReloadSwitchPhase = 0;
    magazineReloadTime = 0;
    aiRateOfFire = 0.5;
    aiRateOfFireDistance = 300;
    minRange = 50;
    modes[] = {"Single", "FullAuto"};
    class Single: Single_Mode {};
    class FullAuto: FullAuto_Mode {};
};
Same configuration as Mk82BombLauncher
Used for CUP vehicle bomb launchers
Where it leads:

Included by CfgWeapons.hpp (line 4, commented out)
Dependencies: Requires CfgWeapons.hpp and base Mode_SemiAuto class
Base Classes: RocketPods (LauncherCore)
Result: AI can use bomb launchers effectively (instant reload, proper fire modes)
3CBF/config.cpp
File: A3A/addons/config_fixes/3CBF/config.cpp
What it does:
Configuration file for the 3CB Factions addon, defines dependencies and includes vehicle configurations.
How it does that:

Cpp

Apply
class CfgPatches {
    class PATCHNAME(3CBF) {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"UK3CB_Factions_AAF_B"};
        author = AUTHOR;
        authors[] = { AUTHORS };
        authorUrl = "";
        VERSION_CONFIG;
        skipWhenMissingDependencies = 1;
    };
};

#include "CfgVehicles.hpp"
Required Addon: UK3CB_Factions_AAF_B (3CB Factions mod)
skipWhenMissingDependencies = 1: Allows load without 3CB
Includes: CfgVehicles.hpp (which currently doesn't exist in provided files)
Where it leads:

Dependencies: 3CB Factions mod or skips loading
Includes: CfgVehicles.hpp (placeholder)
Result: Would add 3CB vehicle variants if present
Summary
Total Files Documented: 28 configuration files
Total Variants Created: 500+ custom vehicle/weapon variants across all mods
Key Patterns:

No Insignia Variants: Remove unit markings via hiddenSelections or gm_InsigniasDefaultNation
Texture Variants: Select specific textures via textureList
Animation Control: Customize model parts via animationList
Faction/Side Conversion: Change faction and side for different factions
AI Handling Tweaks: Adjust draconicTorqueXCoef for better AI flight
Weapon Modes: Convert bomb launchers to AI-friendly firing modes
Conditional Dependencies: Use __has_include for optional mod support
Event Handler Fixes: Remove problematic EHs or add initVehicle scripts
Mod Categories: Vanilla Arma 3, WS, SPE, SPEX, SOG, SOG_NK, RF, IFA, GM, CUP, CSLA, 3CBF
All configurations follow Arma 3 CfgPatches structure for proper mod loading.