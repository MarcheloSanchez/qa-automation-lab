*** Settings ***
Library     Browser
Resource    ../../resources/pages/login.resource
Resource    ../../resources/pages/common.resource
Resource    ../../resources/variables/env.resource

Suite Setup       Open Browser To Application
Suite Teardown    Close Application Browser
Test Setup        Open Login Page

*** Test Cases ***
Successful Login Redirects Away From Login Page
    [Tags]    smoke    ui    login
    Login With Credentials    ${VALID_EMAIL}    ${VALID_PASSWORD}
    Wait For Elements State    ${ERROR_MESSAGE}    hidden    timeout=5s
    ${url}=    Get Url
    Should Not Contain    ${url}    /login

Invalid Login Shows Error Message
    [Tags]    smoke    ui    login
    Login With Credentials    ${INVALID_EMAIL}    ${INVALID_PASSWORD}
    Wait For Elements State    ${ERROR_MESSAGE}    visible    timeout=5s
    ${error_text}=    Get Text    ${ERROR_MESSAGE}
    Should Not Be Empty    ${error_text}
