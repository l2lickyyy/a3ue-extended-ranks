#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_unit", objNull, [objNull]],
    ["_force", false, [true]]
];

if (isNull _unit) exitWith { ["", ""] };

private _role = [_unit] call a3ue_extended_ranks_fnc_getAiRankRole;
if (_role isEqualTo "") exitWith { ["", ""] };

private _validRanks = switch (_role) do {
    case "PETROS": { ["GENERAL"] };
    case "OFFICER": { ["FIRST_LIEUTENANT", "CAPTAIN", "MAJOR"] };
    case "SQUAD_LEADER": { ["SERGEANT", "STAFF_SERGEANT", "SERGEANT_MAJOR"] };
    default { ["PRIVATE", "PRIVATE_FIRST_CLASS", "CORPORAL"] };
};

private _currentRankValue = _unit getVariable [QGVARMAIN(customRank), ""];
private _currentRank = if (_currentRankValue isEqualType "") then { toUpper _currentRankValue } else { "" };
private _rank = if (_currentRank in _validRanks) then {
    _currentRank
} else {
    [_role] call a3ue_extended_ranks_fnc_getWeightedAiRank
};

if (_rank isEqualTo "") exitWith { ["", ""] };

private _engineRank = [_rank] call a3ue_extended_ranks_fnc_getEngineRank;

private _setPublicIfChanged = {
    params ["_key", "_value"];

    private _missing = [QGVARMAIN(missingAiRankValue)];
    private _currentValue = _unit getVariable [_key, _missing];
    if (_currentValue isEqualTo _missing || { !(_currentValue isEqualTo _value) }) then {
        _unit setVariable [_key, _value, true];
    };
};

[QGVARMAIN(aiRankManaged), true] call _setPublicIfChanged;
[QGVARMAIN(aiRankRole), _role] call _setPublicIfChanged;
[QGVARMAIN(customRank), _rank] call _setPublicIfChanged;
["rankX", _engineRank] call _setPublicIfChanged;

if (_force || { !((toUpper (rank _unit)) isEqualTo _engineRank) }) then {
    _unit setUnitRank _engineRank;
};

[_rank, _engineRank];
