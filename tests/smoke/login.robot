*** Settings ***
Library     Process
Library     Collections
Resource    ../../resources/variables/env.resource

*** Variables ***
${LOGIN_HELPER}    ${CURDIR}/../helpers/pst_login_api_check.py

*** Test Cases ***
Login API With Valid Credentials Returns Token
    [Tags]    smoke    login
    Skip If Api Is Unreachable
    ${result}=    Execute Login Request    ${VALID_EMAIL}    ${VALID_PASSWORD}
    Should Be Equal As Integers    ${result}[status_code]    200
    Should Not Be Empty    ${result}[token]

Login API With Invalid Credentials Is Rejected
    [Tags]    smoke    login
    Skip If Api Is Unreachable
    ${result}=    Execute Login Request    ${INVALID_EMAIL}    ${INVALID_PASSWORD}
    ${allowed}=    Create List    400    401    422
    List Should Contain Value    ${allowed}    ${result}[status_code]

*** Keywords ***
Skip If Api Is Unreachable
    ${check}=    Run Process    python    ${LOGIN_HELPER}    --mode    reachability    --base-url    ${API_BASE_URL}
    IF    ${check.rc} != 0
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
