private _original = ["\x\A3A\addons\core\functions\CREATE\fn_createUnit.sqf"] call a3ue_extended_ranks_fnc_getUpstreamFunction;
private _unit = _this call _original;
[_unit] call a3ue_extended_ranks_fnc_applyAiRankState;
_unit
