params [["_savedRank", "", [""]], ["_score", 0, [0]]];

private _rank = [_savedRank] call a3ue_extended_ranks_fnc_getRankFromEngineRank;
if (_rank isNotEqualTo "") exitWith { _rank };
[_score] call a3ue_extended_ranks_fnc_getRankByScore
