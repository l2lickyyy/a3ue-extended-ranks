/*
    Path and namespace macros derived from script_macros_common.hpp.
    Original authors: Sickboy <sb_at_dev-heaven.net> and Spooner.
    Retained subset used by Extended Ranks.
*/
#define SUBPREFIX addons
#define DOUBLES(var1,var2) ##var1##_##var2
#define QUOTE(var1) #var1
#define QDOUBLES(var1,var2) QUOTE(DOUBLES(var1,var2))
#define ADDON DOUBLES(PREFIX,COMPONENT)
#define VERSION_CONFIG version = VERSION; versionStr = QUOTE(VERSION); versionAr[] = {VERSION_AR}

#define GVARMAINS(var1,var2) ##var1##_##var2##
#define GVARMAIN(var1) GVARMAINS(PREFIX,var1)
#define QGVARMAIN(var1) QUOTE(GVARMAIN(var1))

#define PATHTOFOLDER_SYS(var1,var2,var3) \MAINPREFIX\##var1\SUBPREFIX\##var2\##var3
#define PATHTOFOLDER(var1) PATHTOFOLDER_SYS(MODFOLDER,COMPONENT,var1)
#define QPATHTOFOLDER(var1) QUOTE(PATHTOFOLDER(var1))

#define FIX_LINE_NUMBERS2(sharp) sharp##line __LINE__ __FILE__
#define FIX_LINE_NUMBERS() FIX_LINE_NUMBERS2(#)
