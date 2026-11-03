import pytest
from conftest import ArtemisClient

@pytest.mark.asyncio
async def test_pdf_export_and_storage_upload(artemis: ArtemisClient):
    """
    TC-08: PDF Certificate / Attendance Summary Generation and Cloud Upload
    Verifies on-device PDF synthesis and Firebase Cloud Storage upload with progress indicator.
    """
    result = await artemis.run("Generate attendance summary PDF and upload to Firebase Storage")
    assert result.status == "SUCCESS"
    assert result.get("upload_success") is True
    assert "firebasestorage.googleapis.com" in result.get("download_url")

@pytest.mark.asyncio
async def test_event_feedback_submission(artemis: ArtemisClient):
    """
    TC-09: Event Feedback Submission with 5-Star Rating
    Verifies completion of post-event satisfaction survey with rating bar and text comments.
    """
    result = await artemis.run("Open Event Feedback, select 5 stars, submit review")
    assert result.status == "SUCCESS"
    assert result.get("generic_success") is True
