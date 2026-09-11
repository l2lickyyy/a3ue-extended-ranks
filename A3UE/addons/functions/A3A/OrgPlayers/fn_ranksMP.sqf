params ["_playerX", "_rank"];

private _unitsToSync = [_playerX] call a3ue_extended_ranks_fnc_getRankSyncUnits;

{
    if (!isNull _x) then {
        [_x, _rank, _x getVariable ["score", 0], true, false] call a3ue_extended_ranks_fnc_applyRankState;
    };
} forEach _unitsToSync;

call a3ue_extended_ranks_fnc_refreshLocalUi;
