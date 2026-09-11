#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_unit", objNull, [objNull]],
    ["_scoreOverride", -1, [0]]
];

if (isNull _unit) exitWith { "PRIVATE" };

if ([_unit] call a3ue_extended_ranks_fnc_isPetros) exitWith { "GENERAL" };

private _isPlayerRankCarrier =
    isPlayer _unit
    || { !((_unit getVariable ["A3A_playerUID", ""]) isEqualTo "") };

private _resolveCustomRank = {
    params ["_candidate"];

    if (isNull _candidate) exitWith { "" };

    private _customRankValue = _candidate getVariable [QGVARMAIN(customRank), ""];
    private _customRank = if (_customRankValue isEqualType "") then { toUpper _customRankValue } else { "" };
    if (_customRank isEqualTo "") exitWith { "" };

    private _customIndex = [_customRank] call a3ue_extended_ranks_fnc_getRankIndex;
    if (_customIndex isEqualTo -1) exitWith { "" };

    [_customIndex] call a3ue_extended_ranks_fnc_getRankByIndex
};

private _resolveFallbackRank = {
    params ["_candidate", "_scoreOverride"];

    if (isNull _candidate) exitWith { "" };

    private _storedRankValue = _candidate getVariable ["rankX", rank _candidate];
    private _storedRank = if (_storedRankValue isEqualType "") then { toUpper _storedRankValue } else { "" };
    if (_storedRank isEqualTo "") then {
        _storedRank = toUpper (rank _candidate);
    };

    private _candidateScore = if (_scoreOverride >= 0) then {
        _scoreOverride
    } else {
        _candidate getVariable ["score", 0]
    };

    // rankX is engine-safe in the new model, so only use it as a migration hint when
    // the authoritative custom variable is unavailable everywhere we can inspect.
    [_storedRank, _candidateScore, false] call a3ue_extended_ranks_fnc_getEffectiveRank
};

private _candidates = [_unit] call a3ue_extended_ranks_fnc_getRankSyncUnits;
if (_candidates isEqualTo []) then {
    _candidates pushBackUnique _unit;
};

if (!_isPlayerRankCarrier) exitWith {
    if (_unit getVariable [QGVARMAIN(aiRankManaged), false]) then {
        private _customRank = [_unit] call _resolveCustomRank;
        if !(_customRank isEqualTo "") exitWith { _customRank };
    };

    private _fallbackRank = [_unit, _scoreOverride] call _resolveFallbackRank;
    if !(_fallbackRank isEqualTo "") exitWith { _fallbackRank };
    "PRIVATE";
};

private _resolvedCustomRank = "";
private _fallbackRank = "";

{
    private _customRank = [_x] call _resolveCustomRank;
    if !(_customRank isEqualTo "") exitWith {
        _resolvedCustomRank = _customRank;
    };

    if (_fallbackRank isEqualTo "") then {
        _fallbackRank = [_x, _scoreOverride] call _resolveFallbackRank;
    };
} forEach _candidates;

if !(_resolvedCustomRank isEqualTo "") exitWith { _resolvedCustomRank };
if !(_fallbackRank isEqualTo "") exitWith { _fallbackRank };

"PRIVATE";
