#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

if (player != player getVariable ["owner", player]) exitWith {
    [false, localize "STR_A3A_fn_undercover_canGoUn_no_ai"];
};

if (captive player) exitWith {
    [false, localize "STR_A3A_fn_undercover_canGoUn_already"];
};

private _lowCiv = Faction(civilian) getOrDefault ["attributeLowCiv", false];
private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];
if (_lowCiv || {_civNonHuman}) exitWith {
    [false, localize "STR_A3A_fn_undercover_canGoUn_no_lowciv"];
};

private _secureBases = airportsX + milbases + outposts + seaports + (controlsX select {isOnRoad (getMarkerPos _x)});
private _result = [];

if !(isNull (objectParent player)) then
{
    if (!(typeOf (objectParent player) in undercoverVehicles)) exitWith {
        _result = [false, localize "STR_A3A_fn_undercover_canGoUn_no_nociv"];
    };
    if ((objectParent player) getVariable ["A3A_reported", false]) exitWith {
        _result = [false, localize "STR_A3A_fn_undercover_canGoUn_no_reported1"];
    };
    if ((objectParent player) getVariable ["SA_Tow_Ropes", []] isNotEqualTo []) exitWith {
        _result = [false, localize "STR_A3A_fn_undercover_canGoUn_no_towrope"];
    };
}
else
{
    if (dateToNumber date < (player getVariable ["compromised", 0])) exitWith {
        _result = [false, localize "STR_A3A_fn_undercover_canGoUn_no_reported2"];
    };

    private _text = localize "STR_A3A_fn_undercover_canGoUn_no_while";
    _result = [true];
    if (primaryWeapon player != "" || secondaryWeapon player != "" || handgunWeapon player != "") then
    {
        _text = format [localize "STR_A3A_fn_undercover_canGoUn_no_reason_weapon", _text];
        _result set [0, false];
    };
    if (vest player != "") then
    {
        _text = format [localize "STR_A3A_fn_undercover_canGoUn_no_reason_vest", _text];
        _result set [0, false];
    };
    if (headgear player in allArmoredHeadgear) then
    {
        _text = format [localize "STR_A3A_fn_undercover_canGoUn_no_reason_helmet", _text];
        _result set [0, false];
    };
    if (hmd player != "") then
    {
        _text = format [localize "STR_A3A_fn_undercover_canGoUn_no_reason_ngv", _text];
        _result set [0, false];
    };
    if ((uniform player != "") && !(uniform player in (A3A_faction_civ get "uniforms"))) then
    {
        _text = format [localize "STR_A3A_fn_undercover_canGoUn_no_reason_uniform", _text];
        _result set [0, false];
    };
    if (uniform player == "") then
    {
        _text = format [localize "STR_A3A_fn_undercover_canGoUn_no_reason_naked", _text];
        _result set [0, false];
    };
    if (!isNull (player getVariable ["SA_Tow_Ropes_Vehicle", objNull])) then
    {
        _text = format [localize "STR_A3A_fn_undercover_canGoUn_no_reason_rope", _text];
        _result set [0, false];
    };

    if !(_result # 0) exitWith {
        _result = [false, _text];
    };
};

if (count _result != 0 && {!(_result # 0)}) exitWith {
    _result;
};

private _base = [_secureBases, player] call BIS_fnc_nearestPosition;
private _size = [_base] call A3A_fnc_sizeMarker;
if ((player distance2D getMarkerPos _base < _size * 2) && {(sidesX getVariable [_base, sideUnknown]) != teamPlayer}) exitWith {
    [false, localize "STR_A3A_fn_undercover_canGoUn_no_close"];
};

if ({
    ((side _x == Invaders) || (side _x == Occupants)) &&
    {(_x knowsAbout player > 1.4) && {_x distance player < 500}}
} count allUnits > 0) exitWith {
    [false, localize "STR_A3A_fn_undercover_canGoUn_no_spotted"];
};

[true, ""];
