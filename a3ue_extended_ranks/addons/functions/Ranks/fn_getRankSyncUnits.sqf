#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_unit", objNull, [objNull]]];
if (isNull _unit) exitWith { [] };

// Antistasi's owner points to the player body while controlling an AI.
// Never copy player rank state to recruited or temporarily controlled AI.
private _rankUnit = _unit getVariable ["owner", _unit];
if (isNull _rankUnit) exitWith { [] };
if (_rankUnit getVariable [QGVARMAIN(aiRankManaged), false]) exitWith { [] };

[_rankUnit];
