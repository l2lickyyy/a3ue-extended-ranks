#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith { "PRIVATE" };
if ([_unit] call a3ue_extended_ranks_fnc_isPetros) exitWith { "GENERAL" };

// Resolve this unit's identity. Player-facing UI resolves "owner" before calling;
// a controlled AI keeps its own rank instead of inheriting its owner's rank.
private _usesCustomRank =
    (_unit getVariable [QGVARMAIN(aiRankManaged), false])
    || { isPlayer _unit }
    || { !((_unit getVariable ["A3A_playerUID", ""]) isEqualTo "") };

private _customRank = "";
if (_usesCustomRank) then {
    private _value = _unit getVariable [QGVARMAIN(customRank), ""];
    if (_value isEqualType "") then { _customRank = toUpper _value };
};

private _customIndex = [_customRank] call a3ue_extended_ranks_fnc_getRankIndex;
if (_customIndex != -1) exitWith { [_customIndex] call a3ue_extended_ranks_fnc_getRankByIndex };

private _storedRank = _unit getVariable ["rankX", rank _unit];
if !(_storedRank isEqualType "") then { _storedRank = "" };
if (_storedRank isEqualTo "") then { _storedRank = rank _unit };

private _score = _unit getVariable ["score", 0];
if !(_score isEqualType 0) then { _score = 0 };

// Engine-only saves are migration hints only when no valid custom rank exists.
[_storedRank, _score] call a3ue_extended_ranks_fnc_getEffectiveRank;
