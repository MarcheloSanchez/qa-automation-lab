*** Settings ***
Library     Process
Resource    ../variables/env.resource

*** Variables ***
${LOGIN_HELPER}    ${CURDIR}/../../tests/helpers/pst_login_api_check.py

*** Keywords ***
Skip If Api Is Unreachable
    ${check}=    Run Process    python    ${LOGIN_HELPER}    --mode    reachability    --base-url    ${API_BASE_URL}
    IF    ${check.rc} != 0
        IF    $REQUIRE_API.lower() == 'true'
            Fail    Practice Software Testing API at ${API_BASE_URL} is not reachable (REQUIRE_API=true).
        END
        Skip    Practice Software Testing API is not reachable from this environment.
    END

Execute Login Request
    [Arguments]    ${email}    ${password}
    ${response}=    Run Process
    ...    python
    ...    ${LOGIN_HELPER}
    ...    --mode
    ...    login
    ...    --base-url
    ...    ${API_BASE_URL}
    ...    --email
    ...    ${email}
    ...    --password
    ...    ${password}
    Should Be Equal As Integers    ${response.rc}    0
    ${parsed}=    Evaluate    json.loads(r'''${response.stdout}''')    modules=json
    RETURN    ${parsed}
