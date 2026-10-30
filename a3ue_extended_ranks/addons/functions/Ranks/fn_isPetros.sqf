#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_unit", objNull, [objNull]]];
if (isNull _unit) exitWith { false };

// Check the live reference first: Petros is assigned after createUnit returns.
if (_unit isEqualTo (missionNamespace getVariable ["petros", objNull])) exitWith { true };
if (isPlayer _unit || { !((_unit getVariable ["A3A_playerUID", ""]) isEqualTo "") }) exitWith { false };

private _faction = missionNamespace getVariable ["A3A_faction_reb", createHashMap];
if !(_faction isEqualType createHashMap) exitWith { false };
private _petrosType = _faction getOrDefault ["unitPetros", ""];
if !(_petrosType isEqualType "" && { _petrosType isNotEqualTo "" }) exitWith { false };

// This definition also recognizes faction-specific names during creation.
// Do not cache a negative result while faction/unit initialization is incomplete.
private _unitType = _unit getVariable ["unitType", ""];
_unitType isEqualTo _petrosType;
