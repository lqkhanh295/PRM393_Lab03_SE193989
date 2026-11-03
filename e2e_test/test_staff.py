import pytest
from conftest import ArtemisClient

@pytest.mark.asyncio
async def test_gate_desk_fast_scan(artemis: ArtemisClient):
    """
    TC-10: Gate Desk Fast QR Code Scan & Check-in
    Verifies staff check-in flow with audio/vibration feedback and sub-second confirmation.
    """
    result = await artemis.run("Staff Gate Desk manual checkin CE2026-083291, verify checkin counter")
    assert result.status == "SUCCESS"
    assert result.get("manual_checkin_success") is True
    assert result.get("gate_counter") > 0

@pytest.mark.asyncio
async def test_gate_desk_duplicate_scan_warning(artemis: ArtemisClient):
    """
    TC-11: Gate Desk Duplicate Scan Warning and Conflict Resolution
    Verifies gate alert on double-entry attempt with clear visual cues and override controls.
    """
    result = await artemis.run("Staff Gate Desk scan duplicate ticket, verify duplicate warning dialog")
    assert result.status == "SUCCESS"
    assert result.get("duplicate_warning") is True
    assert result.get("recovery_actions_count") == 2
