#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_rank", "", [""]]];

private _rankId = toUpper _rank;

switch (_rankId) do {
    case "PRIVATE": { "PRIVATE" };
    case "CORPORAL": { "CORPORAL" };
    case "SERGEANT": { "SERGEANT" };
    case "LIEUTENANT": { "SECOND_LIEUTENANT" };
    case "CAPTAIN": { "CAPTAIN" };
    case "MAJOR": { "MAJOR" };
    case "COLONEL": { "COLONEL" };
    default {
        private _index = [_rankId] call a3ue_extended_ranks_fnc_getRankIndex;
        if (_index isEqualTo -1) exitWith { "" };

        [_index] call a3ue_extended_ranks_fnc_getRankByIndex
    };
}
