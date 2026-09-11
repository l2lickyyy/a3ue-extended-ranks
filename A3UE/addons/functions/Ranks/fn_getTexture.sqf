params [["_rank", "PRIVATE", [""]]];

private _index = [_rank] call a3ue_extended_ranks_fnc_getRankIndex;
if (_index isEqualTo -1) then {
    _index = 0;
};

private _data = call a3ue_extended_ranks_fnc_getRankData;
if (_data isEqualTo []) exitWith { "" };

(_data select _index) param [4, ""];
