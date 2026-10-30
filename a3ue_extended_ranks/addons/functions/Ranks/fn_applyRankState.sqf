#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_unit", objNull, [objNull]], ["_rank", "PRIVATE", [""]], ["_public", true, [true]]];
if (isNull _unit) exitWith { ["PRIVATE", "PRIVATE"] };
// A controlled/recruited AI must never inherit a player's rank or rating.
if (_unit getVariable [QGVARMAIN(aiRankManaged), false]) exitWith {
    [[_unit] call a3ue_extended_ranks_fnc_getStoredCustomRank, rank _unit]
};
_rank = [_rank, _unit getVariable ["score", 0]] call a3ue_extended_ranks_fnc_getEffectiveRank;
private _engineRank = [_rank] call a3ue_extended_ranks_fnc_getEngineRank;

if ((_unit getVariable [QGVARMAIN(customRank), ""]) isNotEqualTo _rank) then {
    _unit setVariable [QGVARMAIN(customRank), _rank, _public];
};
if ((_unit getVariable ["rankX", ""]) isNotEqualTo _engineRank) then {
    _unit setVariable ["rankX", _engineRank, _public];
};
// Callers synchronize the native rank on the owning client via ranksMP/load events.
if (local _unit && { alive _unit } && { (rank _unit) isNotEqualTo _engineRank }) then {
    _unit setUnitRank _engineRank;
};
[_rank, _engineRank]
