#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

if (!hasInterface) exitWith {};
private _previous = missionNamespace getVariable [QGVARMAIN(playerLoadWorker), scriptNull];
if !(scriptDone _previous) then { terminate _previous };
private _worker = [] spawn {
    private _deadline = diag_tickTime + 120;
    private _body = objNull;
    waitUntil {
        uiSleep 0.1;
        _body = if (isNull player) then { objNull } else { player getVariable ["owner", player] };
        (diag_tickTime > _deadline) || { !isNull _body && { _body getVariable ["canSave", false] } }
    };
    if (isNull _body || { !(_body getVariable ["canSave", false]) }) exitWith {};
    private _rank = [_body] call a3ue_extended_ranks_fnc_getStoredCustomRank;
    [_body, _rank, false] call a3ue_extended_ranks_fnc_applyRankState;
    call a3ue_extended_ranks_fnc_refreshLocalUi;
};
missionNamespace setVariable [QGVARMAIN(playerLoadWorker), _worker];
