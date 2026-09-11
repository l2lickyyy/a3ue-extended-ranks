#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith { false };

private _cacheKey = QGVARMAIN(isPetrosCache);
private _cacheValue = _unit getVariable [_cacheKey, -1];
if (_cacheValue isEqualType true) exitWith { _cacheValue };

private _setResult = {
    params ["_result"];
    _unit setVariable [_cacheKey, _result];
    _result
};

if (
    (!isNil "Petros" && { _unit isEqualTo Petros })
    || { !isNil "petros" && { _unit isEqualTo petros } }
) exitWith { [true] call _setResult };

private _typeName = toLower (typeOf _unit);
if ((_typeName find "petros") >= 0) exitWith { [true] call _setResult };

private _unitTypeName = toLower (_unit getVariable ["unitType", ""]);
if ((_unitTypeName find "petros") >= 0) exitWith { [true] call _setResult };

private _displayName = toLower (_unit getVariable ["unitname", name _unit]);
if ((_displayName find "petros") >= 0 || { _displayName isEqualTo "r petros" }) exitWith { [true] call _setResult };

private _vehicleName = toLower (vehicleVarName _unit);
if ((_vehicleName find "petros") >= 0) exitWith { [true] call _setResult };

private _cfgName = toLower getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName");
if ((_cfgName find "petros") >= 0) exitWith { [true] call _setResult };

[false] call _setResult;
