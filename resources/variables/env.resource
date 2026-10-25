*** Variables ***
${BASE_URL}          https://practicesoftwaretesting.com
${API_BASE_URL}      https://api.practicesoftwaretesting.com
# Set to true (e.g. in CI) to fail instead of skip when the API is unreachable.
${REQUIRE_API}       false
# Prefix for UI routes: empty for sprint5 (path routing); "/#" for
# sprint5-with-bugs, which uses Angular hash routing (useHash: true).
${ROUTE_PREFIX}      ${EMPTY}
${BROWSER}           chromium
${HEADLESS}          true
${VALID_EMAIL}       customer@practicesoftwaretesting.com
${VALID_PASSWORD}    welcome01
${ADMIN_EMAIL}       admin@practicesoftwaretesting.com
${ADMIN_PASSWORD}    welcome01
${INVALID_EMAIL}     wrong@test.com
${INVALID_PASSWORD}  wrongpass
