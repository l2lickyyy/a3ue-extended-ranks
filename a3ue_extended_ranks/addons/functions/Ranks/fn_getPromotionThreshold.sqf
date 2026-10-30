params [["_rank", "PRIVATE", [""]]];

private _index = [_rank] call a3ue_extended_ranks_fnc_getRankIndex;
if (_index isEqualTo -1) exitWith { -1 };

private _data = call a3ue_extended_ranks_fnc_getRankData;
(_data select _index) # 1;
