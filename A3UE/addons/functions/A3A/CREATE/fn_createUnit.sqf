/*
 * File: fn_createUnit.sqf
 * Description:
 *    A3UE override of current Antistasi createUnit with AI rank initialization.
*/

#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_group", "_type", "_position", ["_markers", []], ["_placement", 0], ["_special", "NONE"], "_identity"];

private _fnc_getFaction = {
    switch (_this) do {
        case teamPlayer: { A3A_faction_reb };
        case Occupants: { A3A_faction_occ };
        case Invaders: { A3A_faction_inv };
        case civilian: { A3A_faction_civ };
        default { A3A_faction_reb };
    };
};

private _unitDefinition = A3A_customUnitTypes getVariable [_type, []];

if !(_unitDefinition isEqualTo []) exitWith {
    _unitDefinition params ["_loadouts", "_traits",  "_unitProperties", "_unitClass"];
    private _canSkip = false;

    {
        if (_x select 0 isEqualTo "baseClass") then
        {
            _unitClass = _x select 1;
            if (_unitClass isEqualType []) then
            {
                if ((_unitClass select 0) isEqualType []) exitWith
                {
                    private _weights = ((_x select 1) select 1);
                    private _units = ((_x select 1) select 0);
                    _unitClass = _units selectRandomWeighted _weights;
                };
                _unitClass = selectRandom (_x select 1);
            };
        };
        if (_x select 2 isEqualTo true) then
        {
            _canSkip = true;
        };
    } forEach _traits;

    private _unit = _group createUnit [_unitClass, _position, _markers, _placement, _special];
    [_unit] joinSilent _group;

    if (_canSkip isEqualTo false) then {
        _unit setUnitLoadout selectRandom _loadouts;
    };
    _unit setVariable ["unitType", _type, true];

    private _identity = if (isNil "_identity") then {
        [(side _unit) call _fnc_getFaction, _type] call A3A_fnc_createRandomIdentity;
    } else {
        _identity;
    };
    [_unit, _identity] call A3A_fnc_setIdentity;

    {
        switch (true) do {
            case (_x isEqualType true): {
                _unit setVariable ["isRival", _x, true];
            };
            case (_x isEqualType ""): {
                _unit setVariable ["unitPrefix", _x, true];
            };
        };
    } forEach _unitProperties;

    {
        if (_x select 0 isNotEqualTo "baseClass") then {
            _unit setUnitTrait _x;
        };
    } forEach _traits;

    [_unit, true] call a3ue_extended_ranks_fnc_applyAiRankState;
    _unit
};

private _unit = _group createUnit [_type, _position, _markers, _placement, _special];
_unit setVariable ["unitType", _type, true];
[_unit, true] call a3ue_extended_ranks_fnc_applyAiRankState;
_unit
