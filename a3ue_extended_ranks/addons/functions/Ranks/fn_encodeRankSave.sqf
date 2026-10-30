#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

// A fresh map prevents modifying another subscriber's data by reference.
params [["_pluginsData", createHashMap, [createHashMap]], ["_rank", "PRIVATE", [""]]];
private _result = createHashMap;
{ _result set [_x, _y] } forEach _pluginsData;
private _resolvedRank = [_rank] call a3ue_extended_ranks_fnc_getRankFromEngineRank;
if (_resolvedRank isEqualTo "") then { _resolvedRank = "PRIVATE" };
_result set [QGVARMAIN(rankSchema), "custom_v3"];
_result set [QGVARMAIN(customRank), _resolvedRank];
_result
