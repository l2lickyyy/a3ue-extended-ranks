#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Debug("Working on player ranks");

private _rankData = call a3ue_extended_ranks_fnc_getRankData;
private _maxRankIndex = (count _rankData) - 1;
private _promoted = false;
private _textX = "Promoted Players:<br/><br/>";
private _playableUnits = (call A3A_fnc_playableUnits) select {(side (group _x) in [teamPlayer, civilian])};

{
    private _player = _x getVariable ["owner", _x];
    private _respawnSyncPending = (_x getVariable [QGVARMAIN(respawnSyncPending), false]) || { _player getVariable [QGVARMAIN(respawnSyncPending), false] };
    private _pointsX = _player getVariable ["score", 0];
    private _currentRank = [_player] call a3ue_extended_ranks_fnc_getStoredCustomRank;
    private _currentIndex = [_currentRank] call a3ue_extended_ranks_fnc_getRankIndex;

    if (!_respawnSyncPending && { _currentIndex < _maxRankIndex }) then {
        private _targetRank = [_pointsX] call a3ue_extended_ranks_fnc_getRankByScore;
        private _targetIndex = [_targetRank] call a3ue_extended_ranks_fnc_getRankIndex;

        if (_targetIndex > _currentIndex) then {
            private _targetRankName = [_targetRank] call a3ue_extended_ranks_fnc_getDisplayName;
            private _targetRankTexture = [_targetRank] call a3ue_extended_ranks_fnc_getPromotionInsigniaPath;
            private _insigniaMarkup = if (_targetRankTexture isEqualTo "") then { "" } else {
                format ["<t align='center'><img align='center' size='1.65' image='%1'/></t><br/>", _targetRankTexture]
            };
            Info_3(
                "Promoting %1 player (Current Rank: %2) to new %3.",
                name _player,
                [_currentRank] call a3ue_extended_ranks_fnc_getDisplayName,
                _targetRankName
            );
            private _unitsToSync = [_x] call a3ue_extended_ranks_fnc_getRankSyncUnits;
            private _promotionApplied = false;

            {
                private _rankState = [_x, _targetRank, _pointsX, true] call a3ue_extended_ranks_fnc_applyRankState;
                if ((_rankState # 0) isEqualTo _targetRank) then {
                    _promotionApplied = true;
                };
            } forEach _unitsToSync;

            if (_promotionApplied) then {
                [_player, _targetRank] remoteExec ["A3A_fnc_ranksMP", _player];
                _promoted = true;
                _textX = format [
                    "%1<t align='center' font='PuristaSemibold' size='1.0'>%2</t><br/><t align='center' size='0.9'>%3</t><br/>%4<br/>",
                    _textX,
                    name _player,
                    _targetRankName,
                    _insigniaMarkup
                ];
                sleep 5;
            };
        };
    };
} forEach _playableUnits;

Debug(_textX);

if (_promoted) then {
    _textX = format [localize "STR_hints_promotion_congrats", _textX];
    [petros, "hint", _textX, localize "STR_hints_promotion_header"] remoteExec ["A3A_fnc_commsMP"];
};
