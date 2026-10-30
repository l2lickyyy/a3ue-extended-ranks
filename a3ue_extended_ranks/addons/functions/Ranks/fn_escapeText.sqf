// Escape structured-text content without damaging non-ASCII player names.
params [["_text", "", [""]]];
private _escaped = [];
{
    switch (_x) do {
        case 38: { _escaped append [38,97,109,112,59] };
        case 60: { _escaped append [38,108,116,59] };
        case 62: { _escaped append [38,103,116,59] };
        default { _escaped pushBack _x };
    };
} forEach toArray _text;
toString _escaped
