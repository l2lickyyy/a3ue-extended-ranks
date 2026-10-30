params [["_rank", "PRIVATE", [""]]];

private _rankIndex = [_rank] call a3ue_extended_ranks_fnc_getRankIndex;
if (_rankIndex isEqualTo -1) exitWith { "Pvt" };

private _rankId = [_rankIndex] call a3ue_extended_ranks_fnc_getRankByIndex;

switch (_rankId) do {
    case "PRIVATE": { "Pvt" };
    case "PRIVATE_FIRST_CLASS": { "PFC" };
    case "CORPORAL": { "Cpl" };
    case "SERGEANT": { "Sgt" };
    case "STAFF_SERGEANT": { "SSgt" };
    case "SERGEANT_MAJOR": { "SgM" };
    case "SECOND_LIEUTENANT": { "2Lt" };
    case "FIRST_LIEUTENANT": { "1Lt" };
    case "CAPTAIN": { "Capt" };
    case "MAJOR": { "Maj" };
    case "LIEUTENANT_COLONEL": { "Lt. Col" };
    case "COLONEL": { "Col" };
    case "BRIGADIER_GENERAL": { "Brig. Gen" };
    case "MAJOR_GENERAL": { "Maj. Gen" };
    case "LIEUTENANT_GENERAL": { "Lt. Gen" };
    case "GENERAL": { "Gen" };
    default { "Pvt" };
};
