#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!isServer) exitWith {};
params ["_playerId", "_unit"];
private _original = ["\x\A3A\addons\core\functions\Save\fn_loadPlayer.sqf"] call a3ue_extended_ranks_fnc_getUpstreamFunction;
private _targetRank = "PRIVATE";
if (_playerId in A3A_playerSaveData) then {
    private _record = A3A_playerSaveData get _playerId;
    _targetRank = [_record] call a3ue_extended_ranks_fnc_decodeRankSave;
    private _plugins = _record getOrDefault ["pluginsData", createHashMap];
    if !(_plugins isEqualType createHashMap) then { _plugins = createHashMap };
    _record set ["pluginsData", [_plugins, _targetRank] call a3ue_extended_ranks_fnc_encodeRankSave];
    _record set ["rankPlayer", [_targetRank] call a3ue_extended_ranks_fnc_getEngineRank];
};
// Publish before the original emits its client load event.
_unit setVariable [QGVARMAIN(customRank), _targetRank, true];
_unit setVariable [QGVARMAIN(respawnSyncPending), false, true];
_this call _original
