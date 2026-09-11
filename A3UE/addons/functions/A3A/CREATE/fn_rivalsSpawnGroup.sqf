#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_positionX","_sideX","_typesX"];

private _groupX = createGroup _sideX;
private _countX = count _typesX;
private _squadLeaders = if (!isNil "A3A_faction_all" && { A3A_faction_all isEqualType createHashMap }) then {
    A3A_faction_all getOrDefault ["SquadLeaders", []]
} else {
    []
};

Debug_2("Side: %1 spawning group composition: %2", _sideX, _typesX);

for "_i" from 0 to (_countX - 1) do {
    _unit = [_groupX, (_typesX select _i), _positionX, [], 0, "NONE"] call A3A_fnc_createUnit;
    _unit allowDamage false;

    if ((_typesX select _i) in _squadLeaders) then {
        _groupX selectLeader _unit
    };

    sleep 0.25;
};

{_x allowDamage true} forEach units _groupX;

_groupX
