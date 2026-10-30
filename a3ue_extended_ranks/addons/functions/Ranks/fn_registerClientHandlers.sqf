#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!hasInterface || { !(isClass (missionConfigFile >> "A3A")) }) exitWith {};
if (missionNamespace getVariable [QGVARMAIN(clientHandlersRegistered), false]) exitWith {};
missionNamespace setVariable [QGVARMAIN(clientHandlersRegistered), true];

["A3A_event_clientPlayerLoad", {
    [] call a3ue_extended_ranks_fnc_handlePlayerLoad;
}] call CBA_fnc_addEventHandler;

["A3A_event_clientPlayerSave", {
    params ["_plugins"];
    private _body = player getVariable ["owner", player];
    private _rank = [_body] call a3ue_extended_ranks_fnc_getStoredCustomRank;
    private _rankData = [_plugins, _rank] call a3ue_extended_ranks_fnc_encodeRankSave;
    { _plugins set [_x, _y] } forEach _rankData;
}] call CBA_fnc_addEventHandler;

// The fallback also covers a late postInit after a load event.
[] call a3ue_extended_ranks_fnc_handlePlayerLoad;
