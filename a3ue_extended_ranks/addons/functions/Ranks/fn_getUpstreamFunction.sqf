#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

// Load the original packed implementation, not the overridden CfgFunctions entry.
params [["_path", "", [""]]];
private _cache = missionNamespace getVariable [QGVARMAIN(upstreamFunctions), createHashMap];
private _function = _cache get _path;
if (isNil "_function") then {
    if !(fileExists _path) then { throw format ["Extended Ranks: upstream file missing: %1", _path] };
    _function = compile preprocessFileLineNumbers _path;
    _cache set [_path, _function];
    missionNamespace setVariable [QGVARMAIN(upstreamFunctions), _cache];
};
_function
