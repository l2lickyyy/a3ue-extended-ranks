if !(isServer) exitWith {};
#include "\x\A3A\addons\core\script_component.hpp"
FIX_LINE_NUMBERS()
params [["_newBoss", objNull], ["_silent", false]];

if (!isNull theBoss) then
{
    Debug_1("Removing %1 from Boss roles.", name theBoss);

    bossHCGroupsTransfer = hcAllGroups theBoss;
    hcRemoveAllGroups theBoss;

    theBoss synchronizeObjectsRemove [HC_commanderX];
    HC_commanderX synchronizeObjectsRemove [theBoss];
};

theBoss = _newBoss;
publicVariable "theBoss";

if (isNull _newBoss) exitWith {
    [_silent] spawn {
        params ["_silent"];
        sleep 5;
        if (!_silent) then {
            [petros,"hint", localize "STR_hints_commander_transfer_no_comm", localize "STR_hints_commander_transfer_header"] remoteExec ["A3A_fnc_commsMP", 0]
        };
        [] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
    };
};

[group theBoss, theBoss] remoteExec ["selectLeader", groupOwner group theBoss];

theBoss synchronizeObjectsAdd [HC_commanderX];
HC_commanderX synchronizeObjectsAdd [theBoss];

if (!isNil "bossHCGroupsTransfer") then
{
    Debug("Found previous HC groups, transferring.");
    {
        theBoss hcSetGroup [_x];
        _x setGroupOwner owner theBoss;
    } forEach bossHCGroupsTransfer;
    bossHCGroupsTransfer = nil;
}
else {
    Debug("No previous HC groups found, scanning all groups.");
    {
        if ((leader _x getVariable ["spawner",false]) and (!isPlayer leader _x) and (side _x == teamPlayer)) then
        {
            theBoss hcSetGroup [_x];
            _x setGroupOwner owner theBoss;
        };
    } forEach allGroups;
};

Debug_1("New boss %1 set.", name theBoss);

[_silent] spawn {
    params ["_silent"];
    sleep 5;
    if (!_silent) then {
        private _rank = [theBoss] call a3ue_extended_ranks_fnc_getStoredCustomRank;
        private _rankName = [_rank] call a3ue_extended_ranks_fnc_getShortDisplayName;
        private _rankTexture = [_rank] call a3ue_extended_ranks_fnc_getTexture;
        private _insigniaMarkup = if (_rankTexture isEqualTo "") then { "" } else {
            format ["<t align='center'><img align='center' size='1.65' image='%1'/></t><br/>", _rankTexture]
        };
        private _commanderLabel = format [
            "%1<t align='center'><t size='1.15'>%2. %3</t></t><br/><br/>",
            _insigniaMarkup,
            _rankName,
            [name theBoss] call a3ue_extended_ranks_fnc_escapeText
        ];
        [petros,"hint", format [localize "STR_hints_commander_transfer_new_comm", _commanderLabel], localize "STR_hints_commander_transfer_header"] remoteExec ["A3A_fnc_commsMP", 0]
    };
    [] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
};
