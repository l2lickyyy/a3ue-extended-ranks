#include "..\script_component.hpp"
#include "\x\A3A\addons\gui\dialogues\ids.inc"
FIX_LINE_NUMBERS()

if (!hasInterface) exitWith {};

private _requestId = (missionNamespace getVariable [QGVARMAIN(uiRefreshRequestId), 0]) + 1;
missionNamespace setVariable [QGVARMAIN(uiRefreshRequestId), _requestId];

[_requestId] spawn {
    params [["_requestId", 0, [0]]];

    uiSleep 0.05;

    if (_requestId != (missionNamespace getVariable [QGVARMAIN(uiRefreshRequestId), 0])) exitWith {};

    private _mainDisplay = findDisplay A3A_IDD_MAINDIALOG;
    private _hudDisplay = uiNameSpace getVariable ["H8erHUD", displayNull];
    if (isNull _mainDisplay && { isNull _hudDisplay }) exitWith {};

    if !(isNull _hudDisplay) then {
        [] call A3A_fnc_statistics;
    };

    if !(isNull _mainDisplay) then {
        ["update"] call A3A_fnc_playerTab;
    };
};
