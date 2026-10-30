#include "..\script_component.hpp"
#include "\x\A3A\addons\gui\dialogues\ids.inc"
FIX_LINE_NUMBERS()

if (!hasInterface) exitWith {};
if (missionNamespace getVariable [QGVARMAIN(uiRefreshPending), false]) exitWith {};
missionNamespace setVariable [QGVARMAIN(uiRefreshPending), true];

// A burst of rank changes needs only one refresh of the latest state.
[] spawn {
    uiSleep 0.05;
    missionNamespace setVariable [QGVARMAIN(uiRefreshPending), false];

    private _mainDisplay = findDisplay A3A_IDD_MAINDIALOG;
    private _hudDisplay = uiNamespace getVariable ["H8erHUD", displayNull];
    if (!isNull _hudDisplay) then { [] call A3A_fnc_statistics };
    if (!isNull _mainDisplay) then { ["update"] call A3A_fnc_playerTab };
};
