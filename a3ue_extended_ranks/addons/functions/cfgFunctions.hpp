class CfgFunctions
{
    class A3A
    {
        class Base
        {
            class numericRank
            {
                file = QPATHTOFOLDER(A3A\Base\fn_numericRank.sqf);
            };
            class statistics
            {
                file = QPATHTOFOLDER(A3A\Base\fn_statistics.sqf);
            };
        };

        class GUI
        {
            class playerTab
            {
                file = QPATHTOFOLDER(A3A\GUI\fn_playerTab.sqf);
            };
        };

        class OrgPlayers
        {
            class promotePlayer
            {
                file = QPATHTOFOLDER(A3A\OrgPlayers\fn_promotePlayer.sqf);
            };
            class ranksMP
            {
                file = QPATHTOFOLDER(A3A\OrgPlayers\fn_ranksMP.sqf);
            };
            class theBossTransfer
            {
                file = QPATHTOFOLDER(A3A\OrgPlayers\fn_theBossTransfer.sqf);
            };
        };

        class CREATE
        {
            class createUnit
            {
                file = QPATHTOFOLDER(A3A\CREATE\fn_createUnit.sqf);
            };
        };

        class Save
        {
            class loadPlayer
            {
                file = QPATHTOFOLDER(A3A\Save\fn_loadPlayer.sqf);
            };
            class savePlayer
            {
                file = QPATHTOFOLDER(A3A\Save\fn_savePlayer.sqf);
            };
            class resetPlayer
            {
                file = QPATHTOFOLDER(A3A\Save\fn_resetPlayer.sqf);
            };
        };

        class proxy
        {
            class onPlayerRespawn
            {
                file = QPATHTOFOLDER(A3A\proxy\fn_onPlayerRespawn.sqf);
            };
        };

        class init
        {
            class tags
            {
                file = QPATHTOFOLDER(A3A\init\fn_tags.sqf);
            };
        };
    };

    class SCRT
    {
        class Common
        {
            class common_getPromotionThreshold
            {
                file = QPATHTOFOLDER(SCRT\Common\fn_common_getPromotionThreshold.sqf);
            };
        };
    };

    class a3ue_extended_ranks
    {
        class Ranks
        {
            file = QPATHTOFOLDER(Ranks);
            class registerClientHandlers { postInit = 1; };
            class handlePlayerLoad {};
            class refreshLocalUi {};
            class applyRankState {};
            class getRankSyncUnits {};
            class getRankData {};
            class getRankIndex {};
            class getRankByIndex {};
            class getRankByScore {};
            class getPromotionThreshold {};
            class getEffectiveRank {};
            class getEngineRank {};
            class getRankFromEngineRank {};
            class getDisplayName {};
            class getShortDisplayName {};
            class getUpstreamFunction {};
            class encodeRankSave {};
            class decodeRankSave {};
            class escapeText {};
            class getStoredCustomRank {};
            class isPetros {};
            class reconcileRespawnRankState {};
            class getTexture {};
            class getAiRankRole {};
            class getWeightedAiRank {};
            class applyAiRankState {};
        };
    };
};
