#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!hasInterface) exitWith {};
params ["_newUnit", "_oldUnit"];
if (isNull _oldUnit) exitWith {};
private _original = ["\x\A3A\addons\core\functions\proxy\fn_onPlayerRespawn.sqf"] call a3ue_extended_ranks_fnc_getUpstreamFunction;
if (side group _newUnit isNotEqualTo teamPlayer) exitWith { _this call _original };

// Upstream returns to the original player when a controlled AI dies.
if ((_oldUnit getVariable ["owner", _oldUnit]) isNotEqualTo _oldUnit) exitWith {
    _this call _original;
    call a3ue_extended_ranks_fnc_refreshLocalUi;
};

private _rank = [_oldUnit] call a3ue_extended_ranks_fnc_getStoredCustomRank;
_newUnit setVariable [QGVARMAIN(respawnSyncPending), true, true];
_newUnit setVariable [QGVARMAIN(customRank), _rank, true];
// Upstream copies rankX, changes score/money, restores controls and handles gear.
_oldUnit setVariable ["rankX", [_rank] call a3ue_extended_ranks_fnc_getEngineRank];
_this call _original;
if (isNull _newUnit) exitWith {};
[_newUnit, _rank] call a3ue_extended_ranks_fnc_applyRankState;
[_newUnit, _rank] spawn a3ue_extended_ranks_fnc_reconcileRespawnRankState;
