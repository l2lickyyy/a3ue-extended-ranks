#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_unit", objNull, [objNull]], ["_targetRank", "PRIVATE", [""]]];
if (isNull _unit) exitWith {};
uiSleep 0.35;
if (isNull _unit) exitWith {};
{
    [_x, _targetRank] call a3ue_extended_ranks_fnc_applyRankState;
    _x setVariable [QGVARMAIN(respawnSyncPending), false, true];
} forEach ([_unit] call a3ue_extended_ranks_fnc_getRankSyncUnits);
if (hasInterface) then { call a3ue_extended_ranks_fnc_refreshLocalUi };
