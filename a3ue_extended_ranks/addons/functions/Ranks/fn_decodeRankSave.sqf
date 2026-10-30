#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [["_record", createHashMap, [createHashMap]]];
private _rank = _record getOrDefault ["rankPlayer", "PRIVATE"];
if !(_rank isEqualType "") then { _rank = "" };
private _plugins = _record getOrDefault ["pluginsData", createHashMap];
if (_plugins isEqualType createHashMap) then {
    if ((_plugins getOrDefault [QGVARMAIN(rankSchema), ""]) isEqualTo "custom_v3") then {
        private _customRank = _plugins getOrDefault [QGVARMAIN(customRank), ""];
        if (_customRank isEqualType "" && { ([_customRank] call a3ue_extended_ranks_fnc_getRankIndex) >= 0 }) then {
            _rank = _customRank;
        };
    };
};
// custom_v2 and unversioned saves persisted the custom name in rankPlayer.
// Engine-only saves keep their recorded rank; score never grandfathers General.
private _score = _record getOrDefault ["scorePlayer", 0];
if !(_score isEqualType 0) then { _score = 0 };
[_rank, _score] call a3ue_extended_ranks_fnc_getEffectiveRank
