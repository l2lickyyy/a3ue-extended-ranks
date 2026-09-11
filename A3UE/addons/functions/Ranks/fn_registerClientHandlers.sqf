#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!hasInterface) exitWith {};
if !(isClass (missionConfigFile >> "A3A")) exitWith {};
if (isNil "CBA_fnc_addEventHandler") exitWith {};

["A3A_event_clientPlayerLoad", {
    [] call a3ue_extended_ranks_fnc_handlePlayerLoad;
}] call CBA_fnc_addEventHandler;

[] spawn {
    uiSleep 0.1;
    if ((missionNamespace getVariable [QGVARMAIN(playerLoadSyncId), 0]) > 0) exitWith {};
    [] call a3ue_extended_ranks_fnc_handlePlayerLoad;
};
