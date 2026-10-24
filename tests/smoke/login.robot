*** Settings ***
Library     Collections
Resource    ../../resources/api/login_api.resource

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
    ${allowed}=    Create List    ${400}    ${401}    ${422}
    List Should Contain Value    ${allowed}    ${result}[status_code]
