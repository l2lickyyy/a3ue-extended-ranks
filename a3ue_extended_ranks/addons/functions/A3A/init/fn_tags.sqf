// Original tag behavior: Marker and Melbo (Antistasi).
// Keep Ultimate's visibility, distance, weapon choice and refresh interval.
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!hasInterface) exitWith {};
private _layer = ["A3A_tags"] call BIS_fnc_rscLayer;
private _cachedSignature = [];
private _cachedText = "";
private _weaponCache = createHashMap;

while { true } do {
    private _target = cursorTarget;
    if (!isNull _target && { _target isKindOf "CAManBase" } && { player isEqualTo vehicle player }) then {
        if (side _target isEqualTo playerSide && { player distance _target < 300 }) then {
            private _managed = _target getVariable [QGVARMAIN(aiRankManaged), false];
            private _custom = _managed || { isPlayer _target } || { (_target getVariable ["A3A_playerUID", ""]) isNotEqualTo "" } || { [_target] call a3ue_extended_ranks_fnc_isPetros };
            private _rank = if (_custom) then {
                [[_target] call a3ue_extended_ranks_fnc_getStoredCustomRank] call a3ue_extended_ranks_fnc_getShortDisplayName
            } else {
                [_target, "displayNameShort"] call BIS_fnc_rankParams
            };
            private _name = _target getVariable ["unitname", name _target];
            private _weapon = (weapons _target) param [0, ""];
            private _signature = [_target, _name, _rank, _weapon];
            if (_signature isNotEqualTo _cachedSignature) then {
                if (_weapon isEqualTo "") then {
                    _cachedText = format ["<t size='0.5' color='#f0e68c'>%2. </t><t size='0.5' color='#f0e68c'>%1</t>", [_name] call a3ue_extended_ranks_fnc_escapeText, _rank];
                } else {
                    private _info = _weaponCache get _weapon;
                    if (isNil "_info") then {
                        private _config = configFile >> "CfgWeapons" >> _weapon;
                        _info = [getText (_config >> "displayName"), getText (_config >> "picture")];
                        _weaponCache set [_weapon, _info];
                    };
                    _cachedText = format [
                        "<t size='0.5' color='#f0e68c'>%4. </t><t size='0.5' color='#f0e68c'>%1</t><br/><t size='0.5' color='#f0e68c'>%2</t><br/><img size='0.8' image='%3'/><br/>",
                        [_name] call a3ue_extended_ranks_fnc_escapeText, [_info # 0] call a3ue_extended_ranks_fnc_escapeText, _info # 1, _rank
                    ];
                };
                _cachedSignature = _signature;
            };
            [_cachedText, 0.5, 0.9, 0.34, 0, 0, _layer] spawn BIS_fnc_dynamicText;
        };
    };
    sleep 0.34;
};
