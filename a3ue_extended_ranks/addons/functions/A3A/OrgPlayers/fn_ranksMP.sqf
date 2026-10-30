params ["_playerX", "_rank"];
{
    [_x, _rank, false] call a3ue_extended_ranks_fnc_applyRankState;
} forEach ([_playerX] call a3ue_extended_ranks_fnc_getRankSyncUnits);
call a3ue_extended_ranks_fnc_refreshLocalUi;
