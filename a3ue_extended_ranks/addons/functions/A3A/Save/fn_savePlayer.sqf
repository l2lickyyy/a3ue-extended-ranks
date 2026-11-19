#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!isServer) exitWith {};
private _original = ["\x\A3A\addons\core\functions\Save\fn_savePlayer.sqf"] call a3ue_extended_ranks_fnc_getUpstreamFunction;
params ["_playerId", "_playerUnit", "", ["_pluginsData", nil, [createHashMap]]];
if (isNull _playerUnit) exitWith { _this call _original };
private _body = _playerUnit getVariable ["owner", _playerUnit];
if (isNull _body || { !(_body getVariable ["canSave", false]) }) exitWith { _this call _original };

private _plugins = createHashMap;
private _record = A3A_playerSaveData getOrDefault [_playerId, createHashMap];
private _existing = _record getOrDefault ["pluginsData", createHashMap];
if (_existing isEqualType createHashMap) then {
    { _plugins set [_x, _y] } forEach _existing;
};
if !(isNil "_pluginsData") then {
    { _plugins set [_x, _y] } forEach _pluginsData;
};
private _customRank = [_body] call a3ue_extended_ranks_fnc_getStoredCustomRank;
private _arguments = +_this;
_arguments set [3, [_plugins, _customRank] call a3ue_extended_ranks_fnc_encodeRankSave];
// Upstream retains responsibility for score, native rank, equipment, money,
// garage data, and validation. Ultimate's save loop collects client plugin data.
_arguments call _original
