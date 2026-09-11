#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    ["_role", "NORMAL", [""]]
];

switch (toUpper _role) do {
    case "PETROS": { "GENERAL" };
    case "OFFICER": {
        selectRandomWeighted [
            "FIRST_LIEUTENANT", 65,
            "CAPTAIN", 25,
            "MAJOR", 10
        ]
    };
    case "SQUAD_LEADER": {
        selectRandomWeighted [
            "SERGEANT", 70,
            "STAFF_SERGEANT", 25,
            "SERGEANT_MAJOR", 5
        ]
    };
    case "NORMAL": {
        selectRandomWeighted [
            "PRIVATE", 60,
            "PRIVATE_FIRST_CLASS", 30,
            "CORPORAL", 10
        ]
    };
    default { "" };
};
