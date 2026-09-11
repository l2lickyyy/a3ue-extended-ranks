#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith { "" };
if (isPlayer _unit) exitWith { "" };
if !(_unit isKindOf "CAManBase") exitWith { "" };
if ([_unit] call a3ue_extended_ranks_fnc_isPetros) exitWith { "PETROS" };

private _unitTypeValue = _unit getVariable ["unitType", ""];
private _unitType = if (_unitTypeValue isEqualType "") then { _unitTypeValue } else { "" };
if (_unitType isEqualTo "") exitWith { "" };

private _typeLower = toLower _unitType;

if (
    (_typeLower find "loadouts_civ_") isEqualTo 0
    || { (_typeLower find "civ") >= 0 }
    || { (_typeLower find "_unarmed") >= 0 }
    || { (_typeLower find "_press") >= 0 }
    || { (_typeLower find "_worker") >= 0 }
) exitWith { "" };

if ((_typeLower find "_other_official") >= 0) exitWith { "OFFICER" };

if (!isNil "A3A_faction_occ" && { A3A_faction_occ isEqualType createHashMap } && { _unitType isEqualTo (A3A_faction_occ getOrDefault ["unitOfficial", ""]) }) exitWith { "OFFICER" };
if (!isNil "A3A_faction_inv" && { A3A_faction_inv isEqualType createHashMap } && { _unitType isEqualTo (A3A_faction_inv getOrDefault ["unitOfficial", ""]) }) exitWith { "OFFICER" };

private _squadLeaders = [];
if (!isNil "A3A_faction_all" && { A3A_faction_all isEqualType createHashMap }) then {
    _squadLeaders = A3A_faction_all getOrDefault ["SquadLeaders", []];
};

if (_unitType in _squadLeaders) exitWith { "SQUAD_LEADER" };
if ((_typeLower find "squadleader") >= 0) exitWith { "SQUAD_LEADER" };
if ((_typeLower find "cellleader") >= 0) exitWith { "SQUAD_LEADER" };
if ((_typeLower find "_militia_commander") >= 0) exitWith { "SQUAD_LEADER" };

"NORMAL";
