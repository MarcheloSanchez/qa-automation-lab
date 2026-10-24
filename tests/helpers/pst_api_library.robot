*** Settings ***
Documentation    Offline tests of the PstApi keyword library against the local mock API.
Library     Process
Library     ../../resources/api/PstApi.py    ${API_BASE_URL}    AS    Api
Library     ../../resources/api/PstApi.py    http://127.0.0.1:8999    AS    DeadApi

Suite Setup      Start Mock API
Suite Teardown   Terminate Process    mock_api    kill=True

*** Variables ***
${API_BASE_URL}       http://127.0.0.1:8899
${MOCK_SERVER}        ${CURDIR}/mock_login_api_server.py
${VALID_PASSWORD}     welcome01

*** Test Cases ***
Reachability Reflects The Status Route
    ${up}=    Api.Api Is Reachable
    Should Be True    ${up}
    ${down}=    DeadApi.Api Is Reachable
    Should Not Be True    ${down}

Login Request Extracts Each Token Field
    FOR    ${email}    ${expected}    IN
    ...    customer@practicesoftwaretesting.com    access-token-value
    ...    token@test.com    token-value
    ...    jwt@test.com    jwt-value
        ${result}=    Api.Login Request    ${email}    ${VALID_PASSWORD}
        Should Be Equal As Integers    ${result}[status_code]    200
        Should Be Equal    ${result}[token]    ${expected}
    END

Login Request Reports Rejection
    ${result}=    Api.Login Request    wrong@test.com    wrongpass
    Should Be Equal As Integers    ${result}[status_code]    401
    Should Be Equal    ${result}[token]    ${EMPTY}

Get Token Fails On Rejected Login
    Run Keyword And Expect Error    Login as wrong@test.com failed with HTTP 401.
    ...    Api.Get Token    wrong@test.com    wrongpass

Api Request Sends Bearer Token
    ${token}=    Api.Get Token    jwt@test.com    ${VALID_PASSWORD}
    ${response}=    Api.Api Request    GET    /users/me    token=${token}
    Should Be Equal As Integers    ${response}[status_code]    200
    Should Be Equal    ${response}[json][token_seen]    jwt-value

Api Request Without Token Is Unauthenticated
    ${response}=    Api.Api Request    GET    users/me
    Should Be Equal As Integers    ${response}[status_code]    401

Decode Jwt Claims Reads The Payload
    # header.payload.signature with payload {"iat": 100, "exp": 400}
    ${claims}=    Api.Decode Jwt Claims    eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjEwMCwiZXhwIjo0MDB9.sig
    Should Be Equal As Integers    ${claims}[exp]    400
    Should Be Equal As Integers    ${claims}[iat]    100

Decode Jwt Claims Rejects Non Jwt
    Run Keyword And Expect Error    Not a JWT:*    Api.Decode Jwt Claims    access-token-value

*** Keywords ***
Start Mock API
    Start Process    python    ${MOCK_SERVER}    alias=mock_api
    Sleep    1s
