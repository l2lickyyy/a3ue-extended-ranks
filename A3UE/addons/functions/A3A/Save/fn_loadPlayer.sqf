#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer) exitWith {
    Error("Miscalled server-only function");
};

params ["_playerId", "_unit"];

private _schemaKey = QGVARMAIN(rankSchema);
private _schemaVersion = "custom_v2";

if !(_playerId in A3A_playerSaveData) exitWith {
    Info_1("No save found for player ID %1", _playerId);
    [_playerId, _unit] call A3A_fnc_resetPlayer;
    A3A_playerSaveData set [_playerId, createHashMapFromArray [
        ["moneyX", initialPlayerMoney],
        ["scorePlayer", 0],
        ["rankPlayer", "PRIVATE"],
        ["personalGarage", []],
        ["pluginsData", createHashMapFromArray [[_schemaKey, _schemaVersion]]]
    ]];
};

Info_2("Loading player data for ID %1 into unit %2", _playerId, _unit);

private _playerHM = A3A_playerSaveData get _playerId;
private _loadout = _playerHM get "loadoutPlayer";
if (!isNil "_loadout") then { _unit setUnitLoadout _loadout };

private _score = 0;
private _saveScore = _playerHM get "scorePlayer";
if (!isNil "_saveScore" && { _saveScore isEqualType 0 }) then { _score = _saveScore max 0 };

private _saveRank = "PRIVATE";
private _saveRankValue = _playerHM get "rankPlayer";
if (!isNil "_saveRankValue" && { _saveRankValue isEqualType "" }) then { _saveRank = toUpper _saveRankValue };

private _pluginsData = _playerHM get "pluginsData";
private _hashMapType = createHashMap;
if (isNil "_pluginsData" || { !(_pluginsData isEqualType _hashMapType) }) then { _pluginsData = _hashMapType };

private _isManagedSave = (_pluginsData getOrDefault [_schemaKey, ""]) isEqualTo _schemaVersion;
private _rankState = [_unit, _saveRank, _score, _isManagedSave, true, true] call a3ue_extended_ranks_fnc_applyRankState;
private _rank = _rankState # 0;

private _money = _playerHM get "moneyX";
if (isNil "_money" || {!(_money isEqualType 0)}) then { _money = initialPlayerMoney };

private _garage = _playerHM get "personalGarage";
if (isNil "_garage" || {!(_garage isEqualType [])}) then { _garage = [] };
[_garage, _playerId] call HR_GRG_fnc_addVehiclesByClass;

_pluginsData set [_schemaKey, _schemaVersion];
_playerHM set ["pluginsData", _pluginsData];
_playerHM set ["scorePlayer", _score];
_playerHM set ["rankPlayer", _rank];

_unit setVariable [QGVARMAIN(respawnSyncPending), false, true];
_unit setVariable ["moneyX", _money, true];
_unit setVariable ["canSave", true, true];

["A3A_event_clientPlayerLoad", [_pluginsData], owner _unit] call A3A_fnc_triggerOwnerEvent;

[] remoteExec ["A3A_fnc_statistics", _unit];

Info_5("Player %1: Score %2, rank %3, money %4, garage count %5", _playerId, _score, _rank, _money, count _garage);
