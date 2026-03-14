*** Settings ***
Library     Browser
Resource    ../../resources/variables/env.resource
Resource    ../../resources/pages/common.resource
Resource    ../../resources/pages/login.resource

Suite Setup     Open Browser Session
Suite Teardown  Close Browser Session

*** Test Cases ***
Valid Credentials Login Succeeds
    [Tags]    ui    login    positive
    Open Login Page
    Login With Credentials    ${VALID_EMAIL}    ${VALID_PASSWORD}
    Wait For Condition    URL    matches    ^(?!.*/auth/login).*$
    Get Title    validate    !=    Login

Invalid Credentials Shows Error Message
    [Tags]    ui    login    negative
    Open Login Page
    Login With Credentials    ${INVALID_EMAIL}    ${INVALID_PASSWORD}
    ${error}=    Wait For Element And Get Text    ${ERROR_MESSAGE}
    Should Contain    ${error}    Invalid    msg=Expected "Invalid" in error text, got: ${error}

Wrong Password For Valid Account Shows Error
    [Tags]    ui    login    negative
    Open Login Page
    Login With Credentials    ${VALID_EMAIL}    ${INVALID_PASSWORD}
    ${error}=    Wait For Element And Get Text    ${ERROR_MESSAGE}
    Should Contain    ${error}    Invalid    msg=Expected "Invalid" in error text, got: ${error}

Empty Email Shows Error
    [Tags]    ui    login    negative
    Open Login Page
    Login With Credentials    ${EMPTY}    ${VALID_PASSWORD}
    ${error}=    Wait For Element And Get Text    ${ERROR_MESSAGE}
    Should Not Be Empty    ${error}    Expected a non-empty error message for empty email

Empty Password Shows Error
    [Tags]    ui    login    negative
    Open Login Page
    Login With Credentials    ${VALID_EMAIL}    ${EMPTY}
    ${error}=    Wait For Element And Get Text    ${ERROR_MESSAGE}
    Should Not Be Empty    ${error}    Expected a non-empty error message for empty password
