#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_rank", "PRIVATE", [""]]];

_rank = toUpper _rank;
if (_rank isEqualTo "LIEUTENANT") then { _rank = "SECOND_LIEUTENANT"; };

private _hashMapType = createHashMap;
private _lookup = missionNamespace getVariable [QGVARMAIN(rankIndexCache), objNull];
if !(_lookup isEqualType _hashMapType) then {
    call a3ue_extended_ranks_fnc_getRankData;
    _lookup = missionNamespace getVariable [QGVARMAIN(rankIndexCache), objNull];
    if !(_lookup isEqualType _hashMapType) exitWith { -1 };
};

_lookup getOrDefault [_rank, -1];
