from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import re
import struct
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCE = ROOT / "a3ue_extended_ranks"
RELEASE = ROOT / "build" / "a3ue_extended_ranks"
AUTHORITY = "a3ueExtendedRanks"
INSIGNIA_SHA256 = {
    "1st_lt.paa": "f9f90f8fa031759ab9b3aa4148286d10c206b462c9ace80e86288e9021a62291",
    "2nd_lt.paa": "e5777c3d3d61ed03061f2013bc5473fee69fcf6b8da15917966162812a069940",
    "brig_gen.paa": "4945a6ef96c3933be89027250a430b7aab80a532a223960a3b9422425a53c981",
    "captain.paa": "a53fa9e5d114fbe96b739fcd416e8c95ae49c5d45eff99b398b5b00003fff44b",
    "colonel.paa": "7e5a4750526d6763bac7856b6e59167f5bd98d2d5e160b42be9897cdd715120e",
    "corporal.paa": "10f15c3d86f7c9117f9da54caaf3b64c5b8fec618857da837deceb3e9d23930a",
    "gen.paa": "b3c9a67f79c713d1b6bfcfa09fd30d34e523500cba4bac7fc87f6a1f143b55b0",
    "lt_col.paa": "ef3e65492854b6dabc85129dfff0950b6b6720a7e7bc00ce5b9f5349c00c360b",
    "lt_gen.paa": "13fa71bf900d906aa546bd78907fee2511fed8d517a8b03e395758ea8c844ff6",
    "maj_gen.paa": "17f50c97326edbdca66361bd6b2662067fa61388da70ef86156b9fbdf5d3530a",
    "major.paa": "5a4c7c117b9668484cc48d9a53cfa5b489df8ff2a13af004ab00562fbb9f9be0",
    "private.paa": "be7581d05870a9876b3c51613295fba8e47b5d8802e32d5df48e3cc1a627d68e",
    "private_first_class.paa": "5b049f7bf7917ada9812e12f9c6c6a1f4c0e2540815f114a85c0664cb2ab04e2",
    "sergeant.paa": "b544248dbfe8fe935329a4026d856f31a1c5854747142ade78cde8374bd44438",
    "sergeant_major.paa": "1aa92163ff37fb94bed260f6dc3a310e5594a34cd79b289d41066a9987cb39b6",
    "staff_sergeant.paa": "2697147dfb503757cc77a1a56db72f7cff0601cf9e60356ed234918b1c20fbb5"
}
ENGINE_RANKS = {"PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"}
THRESHOLDS = [0, 50, 125, 250, 400, 600, 850, 1150, 1500, 1900, 2350, 2850, 3450, 4150, 5000, 6000]
RANK_IDS = ["PRIVATE", "PRIVATE_FIRST_CLASS", "CORPORAL", "SERGEANT", "STAFF_SERGEANT", "SERGEANT_MAJOR",
            "SECOND_LIEUTENANT", "FIRST_LIEUTENANT", "CAPTAIN", "MAJOR", "LIEUTENANT_COLONEL", "COLONEL",
            "BRIGADIER_GENERAL", "MAJOR_GENERAL", "LIEUTENANT_GENERAL", "GENERAL"]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def run_tool(arguments: list[str], success: bool = True) -> None:
    result = subprocess.run(arguments, cwd=ROOT, capture_output=True, text=True, timeout=60)
    require((result.returncode == 0) == success,
            f"Tool returned {result.returncode}: {arguments}\n{result.stdout}\n{result.stderr}")


def exact_path(path: pathlib.Path) -> None:
    relative = path.relative_to(SOURCE)
    here = SOURCE
    for part in relative.parts:
        require(part in {p.name for p in here.iterdir()}, f"Missing path or incorrect casing: {path}")
        here /= part


def pbo_read(path: pathlib.Path) -> tuple[dict, dict]:
    data = path.read_bytes()
    position = 0

    def cstring() -> str:
        nonlocal position
        end = data.index(0, position)
        result = data[position:end].decode("utf-8")
        position = end + 1
        return result

    properties, entries, names = {}, [], set()
    while True:
        name = cstring()
        method, original, reserved, timestamp, size = struct.unpack_from("<5I", data, position)
        position += 20
        if not name and method == 0x56657273:
            while key := cstring():
                require(key not in properties, f"Duplicate PBO property: {path}:{key}")
                properties[key] = cstring()
            continue
        if not name:
            break
        require(method == 0, f"Unsupported PBO compression: {path}:{name}")
        require(name.casefold() not in names, f"Duplicate PBO entry: {path}:{name}")
        names.add(name.casefold())
        entries.append((name, size))
    files = {}
    for name, size in entries:
        require(position + size <= len(data), f"Truncated PBO entry: {path}:{name}")
        files[name] = data[position:position + size]
        position += size
    require(data[position:position + 1] == b"\0" and position + 21 == len(data), f"Invalid PBO footer: {path}")
    require(hashlib.sha1(data[:position]).digest() == data[-20:], f"Invalid PBO checksum: {path}")
    return properties, files


def check_source() -> dict:
    require(SOURCE.is_dir() and not SOURCE.is_junction() and not SOURCE.is_symlink(), "Source root must be a real directory")
    functions = SOURCE / "addons" / "functions"
    config = (functions / "cfgFunctions.hpp").read_text(encoding="utf-8")
    registered = set(re.findall(r"class (\w+)\s*[{]", config.split("class Ranks", 1)[1]))
    helpers = {p.stem[3:] for p in (functions / "Ranks").glob("fn_*.sqf")}
    require(registered == helpers, f"Rank registration mismatch: {registered ^ helpers}")
    sqf = "\n".join(p.read_text(encoding="utf-8") for p in functions.rglob("*.sqf"))
    calls = set(re.findall(r"a3ue_extended_ranks_fnc_(\w+)", sqf))
    require(not calls - registered, f"Unregistered rank calls: {calls - registered}")
    require(registered - calls == {"registerClientHandlers"}, f"Unreferenced helpers: {registered - calls}")
    require("class registerClientHandlers { postInit = 1; };" in config, "Client handlers must be registered by postInit")

    mapped = set()
    for value in re.findall(r"QPATHTOFOLDER\(([^)]+\.sqf)\)", config):
        path = functions.joinpath(*pathlib.PureWindowsPath(value).parts)
        exact_path(path)
        mapped.add(path)
    implementations = set(functions.rglob("fn_*.sqf"))
    require(implementations == mapped | set((functions / "Ranks").glob("fn_*.sqf")), "Unregistered SQF implementation")

    rows = re.findall(r'\["([A-Z_]+)", (\d+), "([A-Z_]+)", "(STR_A3UER_\w+)", "([^"]+\.paa)"\]',
                      (functions / "Ranks" / "fn_getRankData.sqf").read_text(encoding="utf-8"))
    require([r[0] for r in rows] == RANK_IDS, "Rank identity/order changed")
    require([int(r[1]) for r in rows] == THRESHOLDS, "Approved progression changed")
    require(all(r[2] in ENGINE_RANKS for r in rows), "Invalid ordinary engine rank")
    xml = ET.parse(SOURCE / "addons" / "core" / "Stringtable.xml")
    translations = {key.attrib["ID"]: key for key in xml.iter("Key")}
    require(len(translations) == len(list(xml.iter("Key"))), "Duplicate localization key")
    required_keys = {r[3] for r in rows} | set(re.findall(r'"(STR_A3UER_\w+)"', sqf))
    require(required_keys == translations.keys(), "Missing or unused mod localization keys")
    for key in translations.values():
        require(bool(key.findtext("Original")) and bool(key.findtext("English")), "Empty rank translation")

    for addon in ("core", "functions"):
        prefix = (SOURCE / "addons" / addon / "$PBOPREFIX$").read_text(encoding="ascii")
        require(prefix == f"x\\a3ue_extended_ranks\\addons\\{addon}", "PBO virtual prefix changed")
    assets = set()
    for name, expected_hash in INSIGNIA_SHA256.items():
        asset = SOURCE / "addons" / "core" / "images" / name
        exact_path(asset)
        require(sha256(asset.read_bytes()) == expected_hash, f"Insignia hash mismatch: {name}")
        assets.add(asset)
    referenced_assets = set()
    for row in rows:
        virtual = row[4]
        require(virtual.startswith("\\x\\a3ue_extended_ranks\\addons\\core\\images\\"), "Invalid insignia path")
        asset = SOURCE / "addons" / "core" / "images" / pathlib.PureWindowsPath(virtual).name
        exact_path(asset)
        referenced_assets.add(asset)
    require(assets == referenced_assets == set((SOURCE / "addons" / "core" / "images").iterdir()), "Unused or missing insignia")

    names = set()
    for path in SOURCE.rglob("*"):
        require(not path.is_symlink() and not path.is_junction(), f"Source link is not portable: {path}")
        name = path.relative_to(SOURCE).as_posix()
        require(name.casefold() not in names, f"Case-insensitive duplicate: {name}")
        names.add(name.casefold())
        if not path.is_file():
            continue
        require(path.suffix.lower() in {".sqf", ".hpp", ".cpp", ".xml", ".paa", ""}, f"Unexpected source artifact: {path}")
        if path.suffix.lower() == ".paa" or path.name == "$PBOPREFIX$":
            continue
        data = path.read_bytes()
        require(b"\r" not in data and not data.startswith(b"\xef\xbb\xbf"), f"Noncanonical text encoding/line endings: {path}")
        text = data.decode("utf-8")
        require(not any(line.endswith((" ", "\t")) for line in text.splitlines()), f"Trailing whitespace: {path}")
        for include in re.findall(r'^\s*#include "([^"]+)"', text, flags=re.M):
            if include.startswith("\\x\\A3A\\"):
                continue  # Provided by the declared Ultimate dependencies.
            if include.startswith("\\x\\a3ue_extended_ranks\\"):
                target = SOURCE.joinpath(*pathlib.PureWindowsPath(include).parts[3:])
            else:
                target = path.parent.joinpath(*pathlib.PureWindowsPath(include).parts).resolve()
            require(target.is_relative_to(SOURCE), f"Include escaped source: {path}:{include}")
            exact_path(target)

    version = (SOURCE / "addons/core/Includes/script_version.hpp").read_text()
    require(dict(re.findall(r"#define (\w+) (\d+)", version)) == {"MAJOR":"1", "MINOR":"1", "PATCHLVL":"0", "BUILD":"0"}, "Release version mismatch")
    metadata = (SOURCE / "meta.cpp").read_text()
    require("publishedid = 3711728487;" in metadata, "Workshop item changed")
    require('action = "https://github.com/l2lickyyy/a3ue-extended-ranks";' in (SOURCE / "mod.cpp").read_text(), "Incorrect project link")
    ai = (functions / "Ranks/fn_applyAiRankState.sqf").read_text()
    require(not re.search(r"\b(setUnitRank|setRank|addRating|selectLeader)\b|setVariable\s*\[\s*\"rankX\"", ai), "Cosmetic AI writes native state")
    require("A3A_fnc_formatTime" not in sqf and "BIS_fnc_secondsToString" in sqf, "Unsupported menu time formatter")
    return {"rankCount":len(rows), "assetsVerified":len(assets), "rankHelpers":len(registered),
            "sqfImplementations":len(implementations), "pathsAndCasing":True}


def signature_version(path: pathlib.Path) -> tuple[str, int]:
    data = path.read_bytes()
    end = data.index(0)
    key_size = struct.unpack_from("<I", data, end + 1)[0]
    offset = end + 5 + key_size
    size = struct.unpack_from("<I", data, offset)[0]
    return data[:end].decode("ascii"), struct.unpack_from("<I", data, offset + 4 + size)[0]


def check_package() -> dict:
    checks = check_source()
    for folder in (ROOT / "build", RELEASE):
        require(folder.is_dir() and not folder.is_symlink() and not folder.is_junction(), f"Linked package root: {folder}")
    for path in RELEASE.rglob("*"):
        require(not path.is_junction() and not path.is_symlink(), f"Linked package entry: {path}")
    manifest_path = ROOT / "build/release-manifest.json"
    require(not manifest_path.is_symlink() and not manifest_path.is_junction(), "Linked release manifest")
    expected = {"mod.cpp", "meta.cpp", f"keys/{AUTHORITY}.bikey"}
    public_key = RELEASE / "keys" / f"{AUTHORITY}.bikey"
    verifier = str(ROOT / "Tools" / "Builder" / "hemtt.exe")
    for addon in ("core", "functions"):
        pbo = RELEASE / "addons" / f"{addon}.pbo"
        signature = pbo.with_name(f"{pbo.name}.{AUTHORITY}.bisign")
        expected |= {f"addons/{pbo.name}", f"addons/{signature.name}"}
        properties, files = pbo_read(pbo)
        require(properties["prefix"] == f"x\\a3ue_extended_ranks\\addons\\{addon}", "Incorrect packed virtual path")
        local = SOURCE / "addons" / addon
        original = {str(pathlib.PureWindowsPath(p.relative_to(local))):p.read_bytes()
                    for p in local.rglob("*") if p.is_file() and p.name != "$PBOPREFIX$"}
        require(files == original, f"Packed contents differ from source: {addon}")
        require(signature_version(signature) == (AUTHORITY, 3), f"Incorrect signature authority/version: {signature}")
        run_tool([verifier, "armake", "verify", str(public_key), str(pbo), str(signature)])
        with tempfile.TemporaryDirectory(prefix=".integrity-", dir=ROOT / "build") as temporary:
            require(pathlib.Path(temporary).resolve().parent == (ROOT / "build").resolve(), "Invalid verification temporary path")
            changed = pathlib.Path(temporary) / pbo.name
            data = bytearray(pbo.read_bytes())
            data[-22] ^= 1
            changed.write_bytes(data)
            try:
                pbo_read(changed)
            except ValueError:
                pass
            else:
                raise ValueError("Modified PBO passed checksum validation")
            # Recompute the footer to test the signature independently of SHA-1.
            data[-20:] = hashlib.sha1(data[:-21]).digest()
            changed.write_bytes(data)
            run_tool([verifier, "armake", "verify", str(public_key), str(changed), str(signature)], success=False)
    actual = {p.relative_to(RELEASE).as_posix() for p in RELEASE.rglob("*") if p.is_file()}
    require(actual == expected, f"Incorrect release contents: {actual ^ expected}")
    for name in ("mod.cpp", "meta.cpp"):
        require((RELEASE / name).read_bytes() == (SOURCE / name).read_bytes(), f"Outdated metadata: {name}")
    manifest = {"version":"1.1.0", "workshopId":"3711728487", "authority":AUTHORITY, "checks":checks,
                "signatureVersion":3, "tamperRejection":True,
                "files":{name:sha256((RELEASE / name).read_bytes()) for name in sorted(actual)}}
    manifest_path.write_text(json.dumps(manifest, indent=2)+"\n", encoding="utf-8", newline="\n")
    return manifest


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["source", "package"])
    options = parser.parse_args()
    print(json.dumps(check_package() if options.mode == "package" else check_source(), indent=2))
