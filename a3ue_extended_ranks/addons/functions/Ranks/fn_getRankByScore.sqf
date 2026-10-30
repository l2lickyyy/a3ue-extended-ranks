params [["_score", 0, [0]]];

_score = floor (_score max 0);

private _data = call a3ue_extended_ranks_fnc_getRankData;
if (_data isEqualTo []) exitWith { "PRIVATE" };

private _rank = "PRIVATE";
{
    if (_score < (_x # 1)) exitWith {};
    _rank = _x # 0;
} forEach _data;

_rank;
