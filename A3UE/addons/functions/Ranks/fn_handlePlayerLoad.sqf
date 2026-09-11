#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!hasInterface) exitWith {};

params [
    ["_pluginsData", createHashMap, [createHashMap]],
    ["_syncId", -1, [0]]
];

if (_syncId < 0) then {
    _syncId = (missionNamespace getVariable [QGVARMAIN(playerLoadSyncId), 0]) + 1;
    missionNamespace setVariable [QGVARMAIN(playerLoadSyncId), _syncId];
};

if (_syncId != (missionNamespace getVariable [QGVARMAIN(playerLoadSyncId), 0])) exitWith {};
if (_syncId isEqualTo (missionNamespace getVariable [QGVARMAIN(playerLoadHandledSyncId), -1])) exitWith {};
private _scheduleRetry = {
    params ["_pluginsData", "_syncId"];
    [_pluginsData, _syncId] spawn {
        params ["_pluginsData", "_syncId"];
        uiSleep 0.1;
        [_pluginsData, _syncId] call a3ue_extended_ranks_fnc_handlePlayerLoad;
    };
};

if (isNull player) exitWith {
    [_pluginsData, _syncId] call _scheduleRetry;
};

private _realPlayer = player getVariable ["owner", player];
if (isNull _realPlayer) exitWith {
    [_pluginsData, _syncId] call _scheduleRetry;
};

if !(_realPlayer getVariable ["canSave", false]) exitWith {
    [_pluginsData, _syncId] call _scheduleRetry;
};

if (_syncId != (missionNamespace getVariable [QGVARMAIN(playerLoadSyncId), 0])) exitWith {};
if (_syncId isEqualTo (missionNamespace getVariable [QGVARMAIN(playerLoadHandledSyncId), -1])) exitWith {};

private _targetRank = [_realPlayer] call a3ue_extended_ranks_fnc_getStoredCustomRank;
private _targetEngineRank = [_targetRank] call a3ue_extended_ranks_fnc_getEngineRank;
private _score = _realPlayer getVariable ["score", 0];
private _unitsToSync = [_realPlayer] call a3ue_extended_ranks_fnc_getRankSyncUnits;
private _needsRankSync = false;

{
    private _customRankValue = _x getVariable [QGVARMAIN(customRank), ""];
    private _customRank = if (_customRankValue isEqualType "") then { toUpper _customRankValue } else { "" };
    private _storedRankValue = _x getVariable ["rankX", rank _x];
    private _storedEngineRank = if (_storedRankValue isEqualType "") then { toUpper _storedRankValue } else { toUpper (rank _x) };

    if (!(_storedEngineRank isEqualTo _targetEngineRank) || { !(_customRank isEqualTo _targetRank) }) exitWith {
        _needsRankSync = true;
    };
} forEach _unitsToSync;

if (_needsRankSync) then {
    {
        [_x, _targetRank, _score, true, false] call a3ue_extended_ranks_fnc_applyRankState;
    } forEach _unitsToSync;
};

{
    _x setVariable [QGVARMAIN(sessionStartTime), time, false];
} forEach _unitsToSync;
missionNamespace setVariable [QGVARMAIN(playerLoadHandledSyncId), _syncId];

call a3ue_extended_ranks_fnc_refreshLocalUi;
