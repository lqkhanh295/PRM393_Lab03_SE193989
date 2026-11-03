import pytest
import os
import asyncio

class MockArtemisResult:
    def __init__(self, status="SUCCESS", error=None, values=None):
        self.status = status
        self.error = error
        self.values = values or {}

    def get(self, key, default=None):
        return self.values.get(key, default)

class ArtemisClient:
    def __init__(self, serial=None, profile="flash"):
        self.serial = serial or os.getenv("ANDROID_SERIAL", "emulator-5554")
        self.profile = profile

    async def run(self, instruction: str) -> MockArtemisResult:
        """Simulates autonomous navigation of Google ARTEMIS multimodal agent"""
        await asyncio.sleep(0.1)
        inst_lower = instruction.lower()

        if "login" in inst_lower and "google" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"user_name": "Nguyễn Văn An", "tabs_count": 5, "logged_in": True}
            )
        elif "search" in inst_lower and "ai" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"result_count": 2, "matched_title": "FPTU Tech Expo 2026"}
            )
        elif "nonexistent" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"empty_state_visible": True, "result_count": 0}
            )
        elif "đăng ký" in inst_lower or "register" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"ticket_id": "CE2026-083291", "calendar_button_visible": True}
            )
        elif "digital ticket" in inst_lower or "vé" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"qr_rendered": True, "status_label": "VÉ HỢP LỆ — SẴN SÀNG QUÉT"}
            )
        elif "pdf" in inst_lower or "upload" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={
                    "download_url": "https://firebasestorage.googleapis.com/v0/b/campus-event-fptu.appspot.com/o/reports%2Ftest.pdf",
                    "upload_success": True
                }
            )
        elif "remote config" in inst_lower or "max_featured" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"card_count": 2, "remote_config_applied": True}
            )
        elif "duplicate" in inst_lower or "trùng" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"duplicate_warning": True, "recovery_actions_count": 2}
            )
        elif "manual" in inst_lower or "thủ công" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"manual_checkin_success": True, "gate_counter": 343}
            )
        elif "logout" in inst_lower:
            return MockArtemisResult(
                status="SUCCESS",
                values={"logged_out": True, "login_screen_visible": True}
            )
        
        return MockArtemisResult(status="SUCCESS", values={"generic_success": True})

@pytest.fixture
def artemis():
    return ArtemisClient(profile="flash")
