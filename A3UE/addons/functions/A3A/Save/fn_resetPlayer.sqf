#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer) exitWith {
    Error("Miscalled server-only function");
};

params ["_playerId", "_unit"];

Info_2("Resetting player data for ID %1, unit %2", _playerId, _unit);

private _money = initialPlayerMoney;
if (_playerId in A3A_playerSaveData) then {
    private _oldMoney = A3A_playerSaveData get _playerId get "moneyX";
    if !(isNil "_oldMoney") then { _money = _money min _oldMoney };
};

_unit setVariable ["moneyX", _money, true];
[_unit, "PRIVATE", 0, true, true, true] call a3ue_extended_ranks_fnc_applyRankState;
_unit setVariable [QGVARMAIN(respawnSyncPending), false, true];
_unit setVariable ["canSave", true, true];

["A3A_event_clientPlayerLoad", [createHashMap], owner _unit] call A3A_fnc_triggerOwnerEvent;

[] remoteExec ["A3A_fnc_statistics", _unit];
