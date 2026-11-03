import pytest
from conftest import ArtemisClient

@pytest.mark.asyncio
async def test_search_event_by_keyword_and_category(artemis: ArtemisClient):
    """
    TC-02: Search Event by Keyword and Tag Filter
    Verifies autonomous search filtering by keyword 'AI' and tag category.
    """
    result = await artemis.run("Search for event 'AI' with Tech tag filter on Explore Screen")
    assert result.status == "SUCCESS"
    assert result.get("result_count") >= 1
    assert "FPTU Tech Expo 2026" in result.get("matched_title")

@pytest.mark.asyncio
async def test_empty_search_state_recovery(artemis: ArtemisClient):
    """
    TC-03: Empty Search State Recovery
    Verifies graceful empty state rendering when searching for nonexistent keywords.
    """
    result = await artemis.run("Search nonexistent keyword 'xyz123' and verify empty state and reset button")
    assert result.status == "SUCCESS"
    assert result.get("empty_state_visible") is True
    assert result.get("result_count") == 0

@pytest.mark.asyncio
async def test_dynamic_remote_config_banner(artemis: ArtemisClient):
    """
    TC-04: Dynamic Live Remote Config Banner Verification
    Verifies dynamic UI tuning via Firebase Remote Config without code deployment.
    """
    result = await artemis.run("Inspect Explore screen for dynamic remote config max_featured banner limit")
    assert result.status == "SUCCESS"
    assert result.get("remote_config_applied") is True
    assert result.get("card_count") == 2
