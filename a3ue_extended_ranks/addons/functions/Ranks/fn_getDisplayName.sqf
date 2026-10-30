params [["_rank", "PRIVATE", [""]]];

private _index = [_rank] call a3ue_extended_ranks_fnc_getRankIndex;
if (_index isEqualTo -1) exitWith { localize "STR_A3UER_RANK_PRIVATE" };

private _data = call a3ue_extended_ranks_fnc_getRankData;
localize ((_data select _index) # 3);
