#include "script_component.hpp"

class CfgPatches
{
    class ADDON
    {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {QDOUBLES(PREFIX,core), "A3A_core", "A3A_gui", "A3A_scrt", "A3A_events", "cba_main"};
        A3A_compatibility[] = {A3UER_AU_COMPATIBILITY};
        author = AUTHOR;
        authors[] = { AUTHORS };
        authorUrl = "";
        VERSION_CONFIG;
    };
};

#include "cfgFunctions.hpp"
