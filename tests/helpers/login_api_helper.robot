*** Settings ***
Library     Process
Library     Collections

Suite Setup      Start Mock API
Suite Teardown   Stop Mock API

*** Variables ***
${LOGIN_HELPER}       ${CURDIR}/pst_login_api_check.py
${MOCK_SERVER}        ${CURDIR}/mock_login_api_server.py
${API_BASE_URL}       http://127.0.0.1:8899
${HEALTH_URL}         ${API_BASE_URL}/health
${VALID_PASSWORD}     welcome01

*** Test Cases ***
Reachability Returns Success For Healthy Endpoint
    ${result}=    Run Process    python    ${LOGIN_HELPER}    --mode    reachability    --base-url    ${HEALTH_URL}
    Should Be Equal As Integers    ${result.rc}    0

Reachability Returns Failure For Unavailable Endpoint
    ${result}=    Run Process    python    ${LOGIN_HELPER}    --mode    reachability    --base-url    http://127.0.0.1:8999/health
    Should Be Equal As Integers    ${result.rc}    1

Login With Access Token Response
    ${payload}=    Execute Login Request    customer@practicesoftwaretesting.com    ${VALID_PASSWORD}
    Should Be Equal As Integers    ${payload}[status_code]    200
    Should Be Equal    ${payload}[token]    access-token-value

Login With Token Response
    ${payload}=    Execute Login Request    token@test.com    ${VALID_PASSWORD}
    Should Be Equal As Integers    ${payload}[status_code]    200
    Should Be Equal    ${payload}[token]    token-value

Login With Jwt Response
    ${payload}=    Execute Login Request    jwt@test.com    ${VALID_PASSWORD}
    Should Be Equal As Integers    ${payload}[status_code]    200
    Should Be Equal    ${payload}[token]    jwt-value

Login With Invalid Credentials Is Rejected
    ${payload}=    Execute Login Request    wrong@test.com    wrongpass
    Should Be Equal As Integers    ${payload}[status_code]    401
    Should Be Equal    ${payload}[token]    ${EMPTY}

Login With Empty Email Is Rejected
    ${payload}=    Execute Login Request    ${EMPTY}    ${VALID_PASSWORD}
    ${allowed}=    Create List    400    422
    List Should Contain Value    ${allowed}    ${payload}[status_code]
    Should Be Equal    ${payload}[token]    ${EMPTY}

Login With Empty Password Is Rejected
    ${payload}=    Execute Login Request    customer@practicesoftwaretesting.com    ${EMPTY}
    ${allowed}=    Create List    400    422
    List Should Contain Value    ${allowed}    ${payload}[status_code]
    Should Be Equal    ${payload}[token]    ${EMPTY}

Login With Both Fields Empty Is Rejected
    ${payload}=    Execute Login Request    ${EMPTY}    ${EMPTY}
    ${allowed}=    Create List    400    422
    List Should Contain Value    ${allowed}    ${payload}[status_code]
    Should Be Equal    ${payload}[token]    ${EMPTY}

Login With SQL Injection In Email Is Rejected
    ${payload}=    Execute Login Request    ' OR '1'='1    ${VALID_PASSWORD}
    ${allowed}=    Create List    400    401    422
    List Should Contain Value    ${allowed}    ${payload}[status_code]
    Should Be Equal    ${payload}[token]    ${EMPTY}

Login With Very Long Email Is Rejected
    ${long_email}=    Evaluate    "a" * 500 + "@test.com"
    ${payload}=    Execute Login Request    ${long_email}    ${VALID_PASSWORD}
    ${allowed}=    Create List    400    401    413    422
    List Should Contain Value    ${allowed}    ${payload}[status_code]
    Should Be Equal    ${payload}[token]    ${EMPTY}

*** Keywords ***
Start Mock API
    Start Process    python    ${MOCK_SERVER}    alias=mock_api
    Sleep    1s

Stop Mock API
    Terminate Process    mock_api    kill=True

Execute Login Request
    [Arguments]    ${email}    ${password}
    ${result}=    Run Process
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
    Should Be Equal As Integers    ${result.rc}    0
    ${payload}=    Evaluate    json.loads(r'''${result.stdout}''')    modules=json
    RETURN    ${payload}
