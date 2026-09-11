#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!hasInterface) exitWith {};

params ["_newUnit", "_oldUnit"];
if (isNull _oldUnit) exitWith {};

private _customRank = [_oldUnit] call a3ue_extended_ranks_fnc_getStoredCustomRank;
private _engineRank = [_customRank] call a3ue_extended_ranks_fnc_getEngineRank;

private _original = missionNamespace getVariable [QGVARMAIN(originalOnPlayerRespawn), objNull];
if !(_original isEqualType {}) then {
    _original = compile preprocessFileLineNumbers "\x\A3A\addons\core\functions\proxy\fn_onPlayerRespawn.sqf";
    missionNamespace setVariable [QGVARMAIN(originalOnPlayerRespawn), _original];
};

// The upstream respawn flow still copies rankX, so we normalize the old unit first.
_oldUnit setVariable [QGVARMAIN(customRank), _customRank, true];
_oldUnit setVariable ["rankX", _engineRank, true];
_newUnit setVariable [QGVARMAIN(respawnSyncPending), true, true];
[_newUnit, _oldUnit] call _original;

if (isNull _newUnit) exitWith {};

private _unitsToSync = [_newUnit] call a3ue_extended_ranks_fnc_getRankSyncUnits;

{
    _x setVariable [QGVARMAIN(respawnSyncPending), true, true];
    [_x, _customRank, _x getVariable ["score", 0], true, false] call a3ue_extended_ranks_fnc_applyRankState;
} forEach _unitsToSync;

{
    _x setVariable [QGVARMAIN(sessionStartTime), time, false];
} forEach _unitsToSync;

[_newUnit, _customRank] spawn a3ue_extended_ranks_fnc_reconcileRespawnRankState;
