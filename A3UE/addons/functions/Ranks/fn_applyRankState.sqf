#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_unit", objNull, [objNull]],
    ["_savedRank", "PRIVATE", [""]],
    ["_score", 0, [0]],
    ["_isManagedSave", true, [true]],
    ["_isPublic", true, [true]],
    ["_setScore", false, [true]]
];

if (isNull _unit) exitWith { ["PRIVATE", "PRIVATE"] };

private _scoreValue = floor (_score max 0);
private _rank = [_savedRank, _scoreValue, _isManagedSave] call a3ue_extended_ranks_fnc_getEffectiveRank;
private _engineRank = [_rank] call a3ue_extended_ranks_fnc_getEngineRank;
private _hasStoredCustomRank = !(isNil { _unit getVariable QGVARMAIN(customRank) });
private _storedCustomRankValue = if (_hasStoredCustomRank) then {
    _unit getVariable [QGVARMAIN(customRank), ""]
} else {
    ""
};
private _storedCustomRank = if (_storedCustomRankValue isEqualType "") then { toUpper _storedCustomRankValue } else { "" };
private _hasStoredEngineRank = !(isNil { _unit getVariable "rankX" });
private _storedRankValue = if (_hasStoredEngineRank) then { _unit getVariable ["rankX", ""] } else { "" };
private _storedEngineRank = if (_storedRankValue isEqualType "") then { toUpper _storedRankValue } else { "" };
private _actualEngineRank = toUpper (rank _unit);

if (_setScore && { (_unit getVariable ["score", -1]) != _scoreValue }) then {
    _unit setVariable ["score", _scoreValue, _isPublic];
};

if (!_hasStoredCustomRank || { !(_storedCustomRank isEqualTo _rank) }) then {
    _unit setVariable [QGVARMAIN(customRank), _rank, _isPublic];
};

if (!_hasStoredEngineRank || { !(_storedEngineRank isEqualTo _engineRank) }) then {
    _unit setVariable ["rankX", _engineRank, _isPublic];
};

if !(_actualEngineRank isEqualTo _engineRank) then {
    _unit setUnitRank _engineRank;
};

[_rank, _engineRank];
