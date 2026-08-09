#!/usr/bin/env python3
"""Gate de paridad MQL4/MQL5 para herramientas de Gueta Quant. / MQL4/MQL5 parity gate for Gueta Quant tools.

Checks (fail => exit 1):
  1. No `.mq4` file may use MQL5-only API:
       - `indicator_plots`  (property is MQL5-only; MQL4 uses indicator_buffers)
       - `PlotIndexSetInteger(`  (MQL5-only)
       - 3-argument `SetIndexBuffer(` where the 3rd arg is `INDICATOR_DATA`
         (MQL4 SetIndexBuffer takes exactly 2 args)
       - `CopyBuffer(`  (MQL5-only buffer copy API)
       - `IndicatorCreate(`  (MQL5-only indicator handle creation)
  2. Every `.mq4` must have a same-named `.mq5` twin, and vice versa.
  3. Every `.pb` (Pine Script) file must declare `//@version=6` on the first
     line (trailing whitespace tolerated).

Usage: python3 scripts/check_mql_parity.py [repo_root]
Run from the repository root. Exit 0 = pass, 1 = fail.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration (keep conservative: only hard MQL5-only API, no style checks)
# ---------------------------------------------------------------------------
MQL5_ONLY_PATTERNS = {
    "indicator_plots": re.compile(r"#property\s+indicator_plots\b"),
    "PlotIndexSetInteger(": re.compile(r"\bPlotIndexSetInteger\s*\("),
    "3-arg SetIndexBuffer(..., INDICATOR_DATA)": re.compile(
        r"\bSetIndexBuffer\s*\(\s*[^,)]+\s*,\s*[^,)]+\s*,\s*INDICATOR_DATA\s*\)"
    ),
    "CopyBuffer(": re.compile(r"\bCopyBuffer\s*\("),
    "IndicatorCreate(": re.compile(r"\bIndicatorCreate\s*\("),
}

PINE_VERSION_RE = re.compile(r"^\s*//@version=6\s*$")


def check_mq4_purity(mq4: Path, errors: list[str]) -> None:
    """Fail if an MQL4 file uses MQL5-only API."""
    try:
        text = mq4.read_text(encoding="utf-8-sig", errors="replace")
    except OSError as exc:
        errors.append(f"[mq4-read] {mq4}: {exc}")
        return
    for label, pattern in MQL5_ONLY_PATTERNS.items():
        if pattern.search(text):
            errors.append(f"{mq4}: contiene API solo-MQL5: {label}")


def check_mq4_mq5_twins(mql_dir: Path, errors: list[str]) -> None:
    """Every .mq4 must have a .mq5 twin and vice versa."""
    mq4 = {p.stem for p in mql_dir.glob("*.mq4")}
    mq5 = {p.stem for p in mql_dir.glob("*.mq5")}
    for stem in sorted(mq4 - mq5):
        errors.append(f"mql/{stem}.mq4 no tiene gemelo {stem}.mq5")
    for stem in sorted(mq5 - mq4):
        errors.append(f"mql/{stem}.mq5 no tiene gemelo {stem}.mq4")


def check_pine_version(pinescript_dir: Path, errors: list[str]) -> None:
    """Every .pb file must declare //@version=6 on its first line."""
    for pb in sorted(pinescript_dir.glob("*.pb")):
        try:
            first = pb.read_text(encoding="utf-8-sig", errors="replace").splitlines()
            if not first or not PINE_VERSION_RE.match(first[0]):
                errors.append(f"{pb}: falta //@version=6 en la primera línea")
        except OSError as exc:
            errors.append(f"[pb-read] {pb}: {exc}")


def main() -> int:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    mql_dir = root / "mql"
    pinescript_dir = root / "pinescript"

    errors: list[str] = []

    if not mql_dir.is_dir():
        errors.append(f"No se encontró el directorio mql/ en {root}")
    else:
        for mq4 in sorted(mql_dir.glob("*.mq4")):
            check_mq4_purity(mq4, errors)
        check_mq4_mq5_twins(mql_dir, errors)

    if pinescript_dir.is_dir():
        check_pine_version(pinescript_dir, errors)

    if errors:
        print(f"check_mql_parity: FALLO ({len(errors)} problema(s))")
        for err in errors:
            print(f"  - {err}")
        return 1

    print("check_mql_parity: OK — sin API solo-MQL5 en MQL4, "
          "gemelos mq4/mq5 completos, todos los .pb en //@version=6")
    return 0


if __name__ == "__main__":
    sys.exit(main())
