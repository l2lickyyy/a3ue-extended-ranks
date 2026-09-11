#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Trace_1(QFUNCMAIN(savePlayer),_this);

if (!isServer) exitWith {
    Error("Miscalled server-only function");
};

#define SET_UUID() if !(isNil "_uuid") then { \
    /* Stock Antistasi persistentSave waits on A3A_core_saveUUID. */ \
    _playerUnit setVariable["A3A_core_saveUUID", _uuid, owner _playerUnit]; \
}

params ["_playerId", "_playerUnit", ["_globalSave", false], ["_pluginsData", nil, [createHashMap]], ["_uuid", nil, [""]]];

_playerUnit = _playerUnit getVariable ["owner", _playerUnit];

if (isNil "_playerUnit" || { isNull _playerUnit }) exitWith {
    Error_1("Not saving player %1 due to missing unit", _playerId);
};

private _continue = try {
    if (isNil "_playerId" || {_playerId == ""}) then {
        throw format["Not saving player of unit %1 due to missing UID", _playerUnit];
    };

    if (side group _playerUnit != teamPlayer && side group _playerUnit != sideUnknown) then {
        throw format["Not saving player %1 due to them being on the wrong team.", _playerId];
    };

    if !(_playerUnit getVariable ["canSave", false]) then {
        throw format["Not saving player %1 due to canSave being false.", _playerId];
    };

    if (isNil { _playerUnit getVariable "moneyX" }) then {
        throw format["Not saving player %1 due to missing variables. What happened here?", _playerId];
    };

    true;
} catch {
    SET_UUID();
    false;
};

if (!_continue) exitWith {};

Info_2("Saving player %1 on side %2", _playerId, side group _playerUnit);

private _schemaKey = QGVARMAIN(rankSchema);
private _schemaVersion = "custom_v2";
private _playerHM = A3A_playerSaveData getOrDefault [_playerId, createHashMap, true];

private _shouldStripLoadout = false;
if (!(alive _playerUnit) || (_playerUnit getVariable ["incapacitated", false])) then
{
    _shouldStripLoadout = true;
    Info_1("Stripping saved loadout of player %1 due to saving while dead or unconcious", _playerId);
};

private _loadout = getUnitLoadout _playerUnit;
if (_shouldStripLoadout) then { _loadout = _loadout call A3A_fnc_stripGearFromLoadout };
_playerHM set ["loadoutPlayer", _loadout];

private _scorePlayer = _playerUnit getVariable ["score", 0];
private _rankPlayer = [_playerUnit] call a3ue_extended_ranks_fnc_getStoredCustomRank;
_playerHM set ["scorePlayer", _scorePlayer];
_playerHM set ["rankPlayer", _rankPlayer];
_playerHM set ["personalGarage", []];

private _totalMoney = _playerUnit getVariable ["moneyX", 0];
if (_shouldStripLoadout) then { _totalMoney = round (_totalMoney * 0.85) };

if (_globalSave) then
{
    {
        if (alive _x && (_x getVariable ["owner", objNull] == _playerUnit)) then
        {
            if (_x != _playerUnit) then {
                private _unitPrice = server getVariable [_x getVariable "unitType", 0];
                _totalMoney = _totalMoney + _unitPrice;
            };
            private _veh = vehicle _x;
            if (_veh == _x || {_veh in staticsToSave}) exitWith {};
            if (_x == driver _veh || {_x == gunner _veh && {_veh isKindOf "LandVehicle" || {_veh isKindOf "Ship"}}}) then {
                private _vehPrice = [typeof _veh] call A3A_fnc_vehiclePrice;
                _totalMoney = _totalMoney + _vehPrice;
            };
        };
    } forEach (units group _playerUnit);
};
_playerHM set ["moneyX", _totalMoney];

private _hashMapType = createHashMap;
private _resolvedPluginsData = _playerHM get "pluginsData";
if (isNil "_resolvedPluginsData" || { !(_resolvedPluginsData isEqualType _hashMapType) }) then {
    _resolvedPluginsData = createHashMap;
};

if !(isNil "_pluginsData") then {
    _resolvedPluginsData = _pluginsData;
    if !(_resolvedPluginsData isEqualType _hashMapType) then {
        _resolvedPluginsData = createHashMap;
    };
};

_resolvedPluginsData set [_schemaKey, _schemaVersion];
_playerHM set ["pluginsData", _resolvedPluginsData];

SET_UUID();

Trace_1(QFUNCMAIN(savePlayer),_playerHM);
Info_4("Saved player %1: %2 rank, %3 money, %4 score", _playerId, _rankPlayer, _totalMoney toFixed 0, _scorePlayer);

true;
