#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_unit", objNull, [objNull]],
    ["_targetRank", "PRIVATE", [""]]
];

if (isNull _unit) exitWith {};

uiSleep 0.35;

if (isNull _unit) exitWith {};

private _rank = toUpper _targetRank;
private _engineRank = [_rank] call a3ue_extended_ranks_fnc_getEngineRank;
private _unitsToSync = [_unit] call a3ue_extended_ranks_fnc_getRankSyncUnits;

if (_unitsToSync isEqualTo []) exitWith {};

private _needsRepair = false;
{
    private _customRankValue = _x getVariable [QGVARMAIN(customRank), ""];
    private _customRank = if (_customRankValue isEqualType "") then { toUpper _customRankValue } else { "" };
    private _storedRankValue = _x getVariable ["rankX", ""];
    private _storedEngineRank = if (_storedRankValue isEqualType "") then { toUpper _storedRankValue } else { "" };
    private _actualEngineRank = toUpper (rank _x);

    if !(_customRank isEqualTo _rank) exitWith {
        _needsRepair = true;
    };

    if !(_storedEngineRank isEqualTo _engineRank) exitWith {
        _needsRepair = true;
    };

    if !(_actualEngineRank isEqualTo _engineRank) exitWith {
        _needsRepair = true;
    };
} forEach _unitsToSync;

if (_needsRepair) then {
    {
        [_x, _rank, _x getVariable ["score", 0], true, false] call a3ue_extended_ranks_fnc_applyRankState;
    } forEach _unitsToSync;
};

{
    _x setVariable [QGVARMAIN(respawnSyncPending), false, true];
} forEach _unitsToSync;

if (hasInterface) then {
    call a3ue_extended_ranks_fnc_refreshLocalUi;
};
