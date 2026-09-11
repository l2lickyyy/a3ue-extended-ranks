#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

private _cacheKey = QGVARMAIN(rankDataCache);
private _lookupCacheKey = QGVARMAIN(rankIndexCache);

private _data = missionNamespace getVariable [_cacheKey, []];
if (_data isEqualType [] && {count _data > 0}) exitWith { _data };

_data = [
    ["PRIVATE", 0, "PRIVATE", "STR_A3UER_RANK_PRIVATE", "\x\a3ue_extended_ranks\addons\core\images\private.paa"],
    ["PRIVATE_FIRST_CLASS", 35, "PRIVATE", "STR_A3UER_RANK_PRIVATE_FIRST_CLASS", "\x\a3ue_extended_ranks\addons\core\images\private_first_class.paa"],
    ["CORPORAL", 100, "CORPORAL", "STR_A3UER_RANK_CORPORAL", "\x\a3ue_extended_ranks\addons\core\images\corporal.paa"],
    ["SERGEANT", 200, "SERGEANT", "STR_A3UER_RANK_SERGEANT", "\x\a3ue_extended_ranks\addons\core\images\sergeant.paa"],
    ["STAFF_SERGEANT", 325, "SERGEANT", "STR_A3UER_RANK_STAFF_SERGEANT", "\x\a3ue_extended_ranks\addons\core\images\staff_sergeant.paa"],
    ["SERGEANT_MAJOR", 475, "SERGEANT", "STR_A3UER_RANK_SERGEANT_MAJOR", "\x\a3ue_extended_ranks\addons\core\images\sergeant_major.paa"],
    ["SECOND_LIEUTENANT", 650, "LIEUTENANT", "STR_A3UER_RANK_SECOND_LIEUTENANT", "\x\a3ue_extended_ranks\addons\core\images\2nd_lt.paa"],
    ["FIRST_LIEUTENANT", 850, "LIEUTENANT", "STR_A3UER_RANK_FIRST_LIEUTENANT", "\x\a3ue_extended_ranks\addons\core\images\1st_lt.paa"],
    ["CAPTAIN", 1100, "CAPTAIN", "STR_A3UER_RANK_CAPTAIN", "\x\a3ue_extended_ranks\addons\core\images\captain.paa"],
    ["MAJOR", 1400, "MAJOR", "STR_A3UER_RANK_MAJOR", "\x\a3ue_extended_ranks\addons\core\images\major.paa"],
    ["LIEUTENANT_COLONEL", 1750, "MAJOR", "STR_A3UER_RANK_LIEUTENANT_COLONEL", "\x\a3ue_extended_ranks\addons\core\images\lt_col.paa"],
    ["COLONEL", 2200, "COLONEL", "STR_A3UER_RANK_COLONEL", "\x\a3ue_extended_ranks\addons\core\images\colonel.paa"],
    ["BRIGADIER_GENERAL", 2750, "COLONEL", "STR_A3UER_RANK_BRIGADIER_GENERAL", "\x\a3ue_extended_ranks\addons\core\images\brig_gen.paa"],
    ["MAJOR_GENERAL", 3400, "COLONEL", "STR_A3UER_RANK_MAJOR_GENERAL", "\x\a3ue_extended_ranks\addons\core\images\maj_gen.paa"],
    ["LIEUTENANT_GENERAL", 4150, "COLONEL", "STR_A3UER_RANK_LIEUTENANT_GENERAL", "\x\a3ue_extended_ranks\addons\core\images\lt_gen.paa"],
    ["GENERAL", 5000, "COLONEL", "STR_A3UER_RANK_GENERAL", "\x\a3ue_extended_ranks\addons\core\images\gen.paa"]
];

private _rankIndexLookup = createHashMap;
{
    _rankIndexLookup set [_x # 0, _forEachIndex];
} forEach _data;

missionNamespace setVariable [_cacheKey, _data];
missionNamespace setVariable [_lookupCacheKey, _rankIndexLookup];

_data;
