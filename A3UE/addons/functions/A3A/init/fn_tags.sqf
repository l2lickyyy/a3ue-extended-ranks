#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!hasInterface) exitWith {};

#define _refresh 0.34
#define _distance 300

private _layer = ["A3A_tags"] call BIS_fnc_rscLayer;
private _distanceSqr = _distance * _distance;
private _cachedSignature = [];
private _cachedText = "";
private _hashMapType = createHashMap;
private _weaponCache = missionNamespace getVariable [QGVARMAIN(tagWeaponCache), objNull];
if !(_weaponCache isEqualType _hashMapType) then {
    _weaponCache = createHashMap;
    missionNamespace setVariable [QGVARMAIN(tagWeaponCache), _weaponCache];
};

private _isPlayerOwnedTarget = {
    params ["_target"];

    if (isNull _target) exitWith { false };
    if (isPlayer _target) exitWith { true };
    if !((_target getVariable ["A3A_playerUID", ""]) isEqualTo "") exitWith { true };

    private _ownerUnit = _target getVariable ["owner", objNull];
    !(isNull _ownerUnit) && { isPlayer _ownerUnit }
};

private _resolveTagRank = {
    params ["_target", "_useCustomRank"];

    if (_useCustomRank) exitWith {
        [[_target] call a3ue_extended_ranks_fnc_getStoredCustomRank] call a3ue_extended_ranks_fnc_getShortDisplayName
    };

    [_target, "displayNameShort"] call BIS_fnc_rankParams
};

private _resolveTagTarget = {
    private _directTarget = cursorTarget;
    if (!isNull _directTarget && { _directTarget isKindOf "CAManBase" } && { _directTarget != player }) exitWith {
        _directTarget
    };

    private _cursorObject = cursorObject;
    if (!isNull _cursorObject && { _cursorObject isKindOf "CAManBase" } && { _cursorObject != player }) exitWith {
        _cursorObject
    };

    objNull
};

while { true } do {
    private _target = call _resolveTagTarget;
    if (!isNull _target && { isNull objectParent player }) then {
        private _targetSide = side (group _target);
        private _isFriendly =
            (_targetSide isEqualTo playerSide)
            || { _targetSide in [teamPlayer, civilian] && { playerSide in [teamPlayer, civilian] } };

        if ((_target != player) && { _isFriendly } && { (player distanceSqr _target) < _distanceSqr }) then {
            private _displayName = _target getVariable ["unitname", name _target];
            private _useManagedAiRank = _target getVariable [QGVARMAIN(aiRankManaged), false];
            private _useCustomPlayerRank = !_useManagedAiRank && { [_target] call _isPlayerOwnedTarget };
            private _useCustomRank = _useManagedAiRank || { _useCustomPlayerRank };
            private _rank = [_target, _useCustomRank] call _resolveTagRank;
            private _weaponClass = currentWeapon _target;
            if (_weaponClass isEqualTo "") then {
                _weaponClass = (weapons _target) param [0, ""];
            };
            if (_rank isEqualTo "") then { _rank = "Pvt"; };

            private _signature = [
                _target,
                _displayName,
                _rank,
                _useCustomRank,
                _weaponClass
            ];

            if !(_signature isEqualTo _cachedSignature) then {
                private _weaponClass = _signature # 4;
                if !(_weaponClass isEqualTo "") then {
                    private _weaponInfo = _weaponCache getOrDefault [_weaponClass, []];
                    if (_weaponInfo isEqualTo []) then {
                        private _weaponConfig = configFile >> "CfgWeapons" >> _weaponClass;
                        _weaponInfo = [
                            getText (_weaponConfig >> "displayName"),
                            getText (_weaponConfig >> "picture")
                        ];
                        _weaponCache set [_weaponClass, _weaponInfo];
                    };

                    _cachedText = format [
                        "<t size='0.5' color='#f0e68c'>%4. </t><t size='0.5' color='#f0e68c'>%1</t><br/><t size='0.5' color='#f0e68c'>%2</t><br/><img size='0.8' image='%3'/><br/>",
                        _displayName,
                        _weaponInfo # 0,
                        _weaponInfo # 1,
                        _rank
                    ];
                } else {
                    _cachedText = format [
                        "<t size='0.5' color='#f0e68c'>%2. </t><t size='0.5' color='#f0e68c'>%1</t>",
                        _displayName,
                        _rank
                    ];
                };

                _cachedSignature = _signature;
            };

            [_cachedText, 0.5, 0.9, _refresh, 0, 0, _layer] spawn BIS_fnc_dynamicText;
        };
    };

    sleep _refresh;
};
