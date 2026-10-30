params [["_index", 0, [0]]];

private _data = call a3ue_extended_ranks_fnc_getRankData;
if (_data isEqualTo []) exitWith { "PRIVATE" };

_index = floor _index;
_index = _index max 0;
_index = _index min ((count _data) - 1);

(_data select _index) # 0;
