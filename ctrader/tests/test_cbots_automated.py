"""
Automated Validation & Invariant Test Suite for cTrader cBots
=============================================================
Verifies syntax, access rights, risk invariants, and regulatory compliance.

Copyright (c) 2026 Gueta Quant.
"""

from pathlib import Path
import re
import pytest

CTRADER_DIR = Path(__file__).resolve().parent.parent
CBOT_FILES = sorted(list(CTRADER_DIR.glob("GQ_*.cs")))


def test_cbot_file_count():
    assert len(CBOT_FILES) == 11, f"Expected 11 cBots, found {len(CBOT_FILES)}"


@pytest.mark.parametrize("cbot_path", CBOT_FILES, ids=lambda p: p.name)
def test_cbot_regulatory_disclaimer(cbot_path):
    content = cbot_path.read_text(encoding="utf-8")
    assert "Decreto 2555 de 2010" in content or "Decreto 2555/2010" in content, (
        f"{cbot_path.name} is missing the mandatory SFC Colombia disclaimer."
    )


@pytest.mark.parametrize("cbot_path", CBOT_FILES, ids=lambda p: p.name)
def test_cbot_zero_privilege_access_rights(cbot_path):
    content = cbot_path.read_text(encoding="utf-8")
    assert "AccessRights = AccessRights.None" in content, (
        f"{cbot_path.name} does not enforce zero-privilege (AccessRights.None)."
    )


@pytest.mark.parametrize("cbot_path", CBOT_FILES, ids=lambda p: p.name)
def test_cbot_lifecycle_methods(cbot_path):
    content = cbot_path.read_text(encoding="utf-8")
    assert "protected override void OnStart()" in content, (
        f"{cbot_path.name} missing OnStart() lifecycle method."
    )
    has_event = any(m in content for m in [
        "protected override void OnBar()",
        "protected override void OnBarClosed()",
        "protected override void OnTick()",
        "protected override void OnPositionOpened(",
        "protected override void OnPositionClosed("
    ])
    assert has_event, f"{cbot_path.name} has no recognized execution event handler."


@pytest.mark.parametrize("cbot_path", CBOT_FILES, ids=lambda p: p.name)
def test_cbot_risk_management_guard(cbot_path):
    content = cbot_path.read_text(encoding="utf-8")
    # All execution robots must have risk controls (SL, MaxLots, Drawdown, or ATR spacing)
    has_risk_guard = any(k in content for k in [
        "StopLoss", "SL", "RiskPercent", "MaxDrawdown", "MaxPositions", "ATR", "MaxLots"
    ])
    assert has_risk_guard, f"{cbot_path.name} has no explicit risk management parameters."


if __name__ == "__main__":
    pytest.main(["-v", __file__])
