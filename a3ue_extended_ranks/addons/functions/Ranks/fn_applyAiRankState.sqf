#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_unit", objNull, [objNull]]];
if (isNull _unit) exitWith { ["", ""] };
private _role = [_unit] call a3ue_extended_ranks_fnc_getAiRankRole;
if (_role isEqualTo "") exitWith { ["", ""] };

// Draw once per unit. Ownership changes and repeated initialization do not reroll.
private _rank = _unit getVariable [QGVARMAIN(customRank), ""];
if !(_rank isEqualType "") then { _rank = "" };
if (!(_unit getVariable [QGVARMAIN(aiRankManaged), false]) || { ([_rank] call a3ue_extended_ranks_fnc_getRankIndex) < 0 }) then {
    _rank = [_role] call a3ue_extended_ranks_fnc_getWeightedAiRank;
    _unit setVariable [QGVARMAIN(aiRankManaged), true, true];
    _unit setVariable [QGVARMAIN(customRank), _rank, true];
};
// No rankX, native rank, rating, traits, or leadership writes.
[_rank, rank _unit]
