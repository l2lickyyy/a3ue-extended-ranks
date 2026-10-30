#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_unit", objNull, [objNull]]];
if (isNull _unit || { isPlayer _unit } || { !(_unit isKindOf "CAManBase") }) exitWith { "" };
if ((_unit getVariable ["A3A_playerUID", ""]) isNotEqualTo "") exitWith { "" };
if ([_unit] call a3ue_extended_ranks_fnc_isPetros) exitWith { "PETROS" };
if (side group _unit isEqualTo civilian) exitWith { "" };

private _unitType = _unit getVariable ["unitType", ""];
if !(_unitType isEqualType "" && { _unitType isNotEqualTo "" }) exitWith { "" };
private _typeLower = toLower _unitType;
if (["_unarmed", "_press", "_worker"] findIf { (_typeLower find _x) >= 0 } >= 0) exitWith { "" };

private _isOfficial = false;
{
    private _faction = missionNamespace getVariable [_x, createHashMap];
    if (_faction isEqualType createHashMap && { _unitType isEqualTo (_faction getOrDefault ["unitOfficial", ""]) }) exitWith {
        _isOfficial = true;
    };
} forEach ["A3A_faction_occ", "A3A_faction_inv", "A3A_faction_reb", "A3A_faction_riv"];
if (_isOfficial || { (_typeLower find "_other_official") >= 0 }) exitWith { "OFFICER" };

private _factions = missionNamespace getVariable ["A3A_faction_all", createHashMap];
private _squadLeaders = if (_factions isEqualType createHashMap) then { _factions getOrDefault ["SquadLeaders", []] } else { [] };
if (_unitType in _squadLeaders) exitWith { "SQUAD_LEADER" };
if (["squadleader", "cellleader", "_militia_commander"] findIf { (_typeLower find _x) >= 0 } >= 0) exitWith { "SQUAD_LEADER" };
"NORMAL"
