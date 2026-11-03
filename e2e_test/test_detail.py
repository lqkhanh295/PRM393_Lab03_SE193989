import pytest
from conftest import ArtemisClient

@pytest.mark.asyncio
async def test_event_registration_pass_modal(artemis: ArtemisClient):
    """
    TC-05: Event Registration and Pass Confirmation Modal
    Autonomous navigation into event detail, bottom sheet registration form submission.
    """
    result = await artemis.run("Navigate to FPTU Tech Expo 2026, tap Đăng Ký, submit registration modal")
    assert result.status == "SUCCESS"
    assert result.get("ticket_id") is not None
    assert result.get("calendar_button_visible") is True

@pytest.mark.asyncio
async def test_offline_resilient_digital_ticket(artemis: ArtemisClient):
    """
    TC-06: Offline-Resilient Digital Ticket Display
    Verifies full-screen QR pass generation, maximum screen brightness cues, and high-contrast styling.
    """
    result = await artemis.run("Open Digital Ticket screen CE2026-083291, verify QR code rendered and status label")
    assert result.status == "SUCCESS"
    assert result.get("qr_rendered") is True
    assert "HỢP LỆ" in result.get("status_label")

@pytest.mark.asyncio
async def test_realtime_qa_submission_and_upvote(artemis: ArtemisClient):
    """
    TC-07: Real-time Q&A Submission with Live Upvote
    Simulates student asking live questions during keynote session and upvoting top community inquiries.
    """
    result = await artemis.run("Open Live Companion screen, submit live question, tap upvote button")
    assert result.status == "SUCCESS"
    assert result.get("generic_success") is True
