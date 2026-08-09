#!/usr/bin/env python3
"""README claims gate for Gueta Quant tools.

Checks (fail => exit 1):
  1. Every file reference with an extension (.mq4/.mq5/.pb/.cs) mentioned in
     any scanned README must exist in the repository (relative paths resolved
     against the repo root, then against the README's own directory).
  2. No overclaim phrase from the blocklist below may appear in a scanned
     README — UNLESS the phrase is whitelisted in
     scripts/claim_exceptions.json (mapping phrase -> file(s) that prove the
     feature exists in code).

Scanned files: README.md + mql/README.md + pinescript/README.md +
ctrader/README.md (missing platform READMEs are reported as errors: the root
README promises a quality-status page per platform).

Usage: python3 scripts/check_readme_claims.py [repo_root]
Run from the repository root. Exit 0 = pass, 1 = fail.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Blocklist de frases sobre-claim. CONSERVADOR: solo frases que el auditor
# externo marcó como no verificables o engañosas. Para permitir una frase,
# NO la borres de aquí: agrega una entrada deliberada en claim_exceptions.json.
# ---------------------------------------------------------------------------
OVERCLAIM_PHRASES = [
    "institucional",      # "grado institucional" / institutional-grade: no verificable en FX retail
    "institutional",      # EN mirror
    "compiladores",       # sugiere suite de compilación propia (no existe)
    "FVG",                # Fair Value Gaps: claim solo válido si el código lo implementa
    "CHoCH",              # Change of Character: idem
    "Order Blocks",       # idem
    "hidden divergence",  # divergencias ocultas: solo válido si el código las detecta
    "divergencias ocultas",  # ES mirror
    "trailing stop",      # solo válido si existe trailing stop real en el código
]

README_FILES = ["README.md", "mql/README.md", "pinescript/README.md", "ctrader/README.md"]

FILE_REF_RE = re.compile(r"([\w./\-]+)\.(mq4|mq5|pb|cs)\b")
VALID_EXTS = {"mq4", "mq5", "pb", "cs"}
SOURCE_DIRS = ["mql", "pinescript", "ctrader"]


def is_fenced(text: str, start: int) -> bool:
    """True if char offset `start` falls inside a ``` fenced code block."""
    offset = 0
    in_fence = False
    for line in text.splitlines(keepends=True):
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
        if offset <= start < offset + len(line):
            return in_fence
        offset += len(line)
    return False


def load_exceptions(root: Path, errors: list[str]) -> dict:
    cfg_path = root / "scripts" / "claim_exceptions.json"
    if not cfg_path.is_file():
        errors.append(f"Falta scripts/claim_exceptions.json (obligatorio: define el whitelist de claims)")
        return {}
    try:
        data = json.loads(cfg_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"scripts/claim_exceptions.json inválido: {exc}")
        return {}
    if not isinstance(data, dict):
        errors.append("scripts/claim_exceptions.json debe ser un objeto JSON")
        return {}
    exceptions = {}
    for phrase, entry in data.items():
        if phrase.startswith("_"):
            continue  # claves de comentario/instrucción permitidas
        if not isinstance(entry, dict) or "files" not in entry:
            errors.append(f"claim_exceptions.json: '{phrase}' debe tener una lista 'files'")
            continue
        files = entry["files"]
        if not isinstance(files, list) or not all(isinstance(f, str) for f in files):
            errors.append(f"claim_exceptions.json: 'files' de '{phrase}' debe ser lista de rutas")
            continue
        exceptions[phrase] = files
    return exceptions


def check_file_refs(readme: Path, root: Path, errors: list[str]) -> None:
    """Every `path/to/file.ext` mentioned must exist.

    Bare tool names (no dir prefix) resolve against the source dirs
    (mql/, pinescript/, ctrader/) and the README's own dir. References inside
    fenced code blocks (ASCII structure diagrams) are illustrative and skipped.
    """
    text = readme.read_text(encoding="utf-8", errors="replace")
    seen = set()
    for m in FILE_REF_RE.finditer(text):
        token = m.group(1) + "." + m.group(2)
        if token.startswith(".") or token in seen or is_fenced(text, m.start()):
            continue
        seen.add(token)
        candidates = [root / token, readme.parent / token]
        candidates += [root / d / token for d in SOURCE_DIRS]
        if not any(cand.is_file() for cand in candidates):
            errors.append(f"{readme}: referencia a archivo inexistente: {token}")


def check_overclaims(readme: Path, root: Path, exceptions: dict, errors: list[str]) -> None:
    """Blocklisted phrase found => fail unless whitelisted AND backed by a file."""
    text = readme.read_text(encoding="utf-8", errors="replace")
    lower = text.lower()
    for phrase in OVERCLAIM_PHRASES:
        if phrase.lower() not in lower:
            continue
        # Negaciones honestas ("no order-flow institucional", "not institutional")
        # no son overclaims: son disclaimers. Ignorar frases precedidas de "no "/"not ".
        for m in re.finditer(re.escape(phrase.lower()), lower):
            start = m.start()
            prefix = lower[max(0, start - 24):start]
            if re.search(r"(no |not |sin )\w*[ -]", prefix) or re.search(r"(no |not |sin )$", prefix):
                continue
            proof = exceptions.get(phrase) or exceptions.get(phrase.lower())
            if proof and any((root / f).is_file() for f in proof):
                break
            errors.append(
                f"{readme}: claim sin respaldo: '{phrase}' "
                f"(agrégalo a scripts/claim_exceptions.json SOLO si el código lo implementa)"
            )
            break
        continue
        proof = exceptions.get(phrase) or exceptions.get(phrase.lower())
        if proof and any((root / f).is_file() for f in proof):
            continue  # claim whitelisted: existe archivo en el repo que lo respalda
        errors.append(
            f"{readme}: claim sin respaldo: '{phrase}' "
            f"(agrégalo a scripts/claim_exceptions.json SOLO si el código lo implementa)"
        )


def main() -> int:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    errors: list[str] = []

    exceptions = load_exceptions(root, errors)

    for rel in README_FILES:
        readme = root / rel
        if not readme.is_file():
            errors.append(f"Falta {rel} (el README raíz promete estado de calidad por plataforma)")
            continue
        check_file_refs(readme, root, errors)
        if exceptions:
            check_overclaims(readme, root, exceptions, errors)

    if errors:
        print(f"check_readme_claims: FALLO ({len(errors)} problema(s))")
        for err in errors:
            print(f"  - {err}")
        return 1

    print("check_readme_claims: OK — toda referencia de archivo existe y "
          "ningún claim no respaldado")
    return 0


if __name__ == "__main__":
    sys.exit(main())
