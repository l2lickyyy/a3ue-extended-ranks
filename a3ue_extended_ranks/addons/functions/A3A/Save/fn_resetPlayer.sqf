#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!isServer) exitWith {};
params ["", "_unit"];
_unit setVariable [QGVARMAIN(customRank), "PRIVATE", true];
_unit setVariable [QGVARMAIN(respawnSyncPending), false, true];
private _original = ["\x\A3A\addons\core\functions\Save\fn_resetPlayer.sqf"] call a3ue_extended_ranks_fnc_getUpstreamFunction;
_this call _original
