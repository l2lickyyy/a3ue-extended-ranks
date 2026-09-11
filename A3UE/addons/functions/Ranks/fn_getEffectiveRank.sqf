params [
    ["_savedRank", "PRIVATE", [""]],
    ["_score", 0, [0]],
    ["_isManagedSave", false, [true]]
];

private _rawSavedRank = toUpper _savedRank;
if (_rawSavedRank isEqualTo "ANY") then { _rawSavedRank = ""; };

private _scoreValue = floor (_score max 0);
private _rankByScore = [_scoreValue] call a3ue_extended_ranks_fnc_getRankByScore;
private _resolvedRank = [_rawSavedRank] call a3ue_extended_ranks_fnc_getRankFromEngineRank;
if (_resolvedRank isEqualTo "") exitWith {
    if !(_rankByScore isEqualTo "") then { _rankByScore } else { "PRIVATE" };
};
if (_isManagedSave) exitWith { _resolvedRank };

if (_rankByScore isEqualTo "") exitWith { _resolvedRank };

private _savedEngineRank = [_resolvedRank] call a3ue_extended_ranks_fnc_getEngineRank;
private _scoreEngineRank = [_rankByScore] call a3ue_extended_ranks_fnc_getEngineRank;

// Legacy saves only persisted the engine ladder, so refine within the same engine bucket by score.
if (_savedEngineRank isEqualTo _scoreEngineRank) exitWith { _rankByScore };

_resolvedRank;
