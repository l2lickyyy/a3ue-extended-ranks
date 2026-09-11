#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith { [] };

private _ownerUnit = _unit getVariable ["owner", objNull];
private _unitsToSync = [];

{
    if !(isNull _x) then {
        _unitsToSync pushBackUnique _x;
    };
} forEach [_unit, _ownerUnit];

if (hasInterface) then {
    private _localPlayer = player;
    if !(isNull _localPlayer) then {
        private _localOwnerUnit = _localPlayer getVariable ["owner", _localPlayer];
        private _isLocalPlayerOwned =
            _unit isEqualTo _localPlayer
            || { _unit isEqualTo _localOwnerUnit }
            || { _ownerUnit isEqualTo _localPlayer }
            || { _ownerUnit isEqualTo _localOwnerUnit };

        if (_isLocalPlayerOwned) then {
            {
                if !(isNull _x) then {
                    _unitsToSync pushBackUnique _x;
                };
            } forEach [_localPlayer, _localOwnerUnit];
        };
    };
};

_unitsToSync;
