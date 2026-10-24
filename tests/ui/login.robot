*** Settings ***
Documentation    UI login checks against ${BASE_URL} (Browser library).
Resource    ../../resources/pages/common.resource
Resource    ../../resources/pages/login.resource

Suite Setup       Open Browser To Application
Suite Teardown    Close Application Browser
Test Setup        Open Login Page

*** Test Cases ***
Successful Login Leaves The Login Page
    [Tags]    ui    login
    Login With Credentials    ${VALID_EMAIL}    ${VALID_PASSWORD}
    # The app redirects with a full page navigation; Get Url retries the
    # assertion until Browser's timeout instead of reading it once.
    Get Url    not contains    /login

Invalid Login Shows Error Message
    [Tags]    ui    login
    Login With Credentials    ${INVALID_EMAIL}    ${INVALID_PASSWORD}
    Wait For Elements State    ${ERROR_MESSAGE}    visible    timeout=5s
    Get Text    ${ERROR_MESSAGE}    !=    ${EMPTY}
