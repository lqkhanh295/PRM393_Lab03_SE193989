import pytest
from conftest import ArtemisClient

@pytest.mark.asyncio
async def test_student_login_success(artemis: ArtemisClient):
    """
    TC-01: Student Login with FPT Google Account
    Verifies autonomous login flow with mock Google auth and transition to Main Navigation.
    """
    result = await artemis.run("Login with Google account an_nguyen@fpt.edu.vn and navigate to home")
    assert result.status == "SUCCESS"
    assert result.get("logged_in") is True
    assert result.get("user_name") == "Nguyễn Văn An"
    assert result.get("tabs_count") == 5

@pytest.mark.asyncio
async def test_student_logout_and_session(artemis: ArtemisClient):
    """
    TC-12: Student Logout and Session Cleanliness
    Verifies secure session destruction, analytics reset, and return to Login Screen.
    """
    result = await artemis.run("Navigate to Profile screen, tap Logout button, and confirm logout dialog")
    assert result.status == "SUCCESS"
    assert result.get("logged_out") is True
    assert result.get("login_screen_visible") is True
