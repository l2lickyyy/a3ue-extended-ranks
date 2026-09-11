/*
Maintainer: breadServer
    Returns how many points are required to reach the supplied custom rank.
*/

params [["_rank", "PRIVATE", [""]]];

[_rank] call a3ue_extended_ranks_fnc_getPromotionThreshold;
