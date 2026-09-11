#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_unit"];

private _currentRank = [_unit] call a3ue_extended_ranks_fnc_getStoredCustomRank;
private _currentIndex = [_currentRank] call a3ue_extended_ranks_fnc_getRankIndex;
private _rankData = call a3ue_extended_ranks_fnc_getRankData;

if (_currentIndex isEqualTo -1) then {
    _currentIndex = 0;
    _currentRank = "PRIVATE";
};

private _nextIndex = (_currentIndex + 1) min (((count _rankData) - 1) max 0);
private _nextRank = [_nextIndex] call a3ue_extended_ranks_fnc_getRankByIndex;

[(_currentIndex + 1), _nextRank];
