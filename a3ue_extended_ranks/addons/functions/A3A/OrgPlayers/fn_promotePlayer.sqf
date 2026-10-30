#include "\x\A3A\addons\core\script_component.hpp"
FIX_LINE_NUMBERS()

if (!isServer) exitWith {};
if (missionNamespace getVariable ["a3ue_extended_ranks_promotionRunning", false]) exitWith {};
missionNamespace setVariable ["a3ue_extended_ranks_promotionRunning", true];
private _text = "";
try {
    private _players = [];
    {
        private _body = _x getVariable ["owner", _x];
        if (!isNull _body && { side group _x in [teamPlayer, civilian] }) then {
            _players pushBackUnique _body;
        };
    } forEach (call A3A_fnc_playableUnits);
    {
        private _body = _x;
        if (_body getVariable ["a3ue_extended_ranks_respawnSyncPending", false]) then { continue };
        private _currentRank = [_body] call a3ue_extended_ranks_fnc_getStoredCustomRank;
        private _targetRank = [_body getVariable ["score", 0]] call a3ue_extended_ranks_fnc_getRankByScore;
        if (([_targetRank] call a3ue_extended_ranks_fnc_getRankIndex) > ([_currentRank] call a3ue_extended_ranks_fnc_getRankIndex)) then {
            [_body, _targetRank] call a3ue_extended_ranks_fnc_applyRankState;
            [_body, _targetRank] remoteExecCall ["A3A_fnc_ranksMP", _body];
            _text = _text + format [
                "<t align='center' font='PuristaSemibold'>%1</t><br/><t align='center'>%2</t><br/><t align='center'><img size='1.65' image='%3'/></t><br/><br/>",
                [name _body] call a3ue_extended_ranks_fnc_escapeText,
                [_targetRank] call a3ue_extended_ranks_fnc_getDisplayName,
                [_targetRank] call a3ue_extended_ranks_fnc_getTexture
            ];
            // Keep Ultimate's existing per-promotion spacing.
            sleep 5;
        };
    } forEach _players;
    if (_text isNotEqualTo "") then {
        _text = format [localize "STR_hints_promotion_congrats", (localize "STR_A3UER_PROMOTED_PLAYERS") + "<br/><br/>" + _text];
        [petros, "hint", _text, localize "STR_hints_promotion_header"] remoteExec ["A3A_fnc_commsMP"];
    };
} catch {
    Error_1("Promotion processing failed: %1", _exception);
};
missionNamespace setVariable ["a3ue_extended_ranks_promotionRunning", false];
