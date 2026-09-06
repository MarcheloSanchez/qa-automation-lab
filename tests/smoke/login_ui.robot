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
    # handleSuccessfulLogin() redirects via a real window.location.href
    # assignment (a full page navigation), so give it time to land instead
    # of reading the URL immediately after the click.
    ${still_on_login}=    Run Keyword And Return Status    Get Url    contains    /login
    IF    ${still_on_login}
        ${error_shown}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${ERROR_MESSAGE}    visible    timeout=2s
        IF    ${error_shown}
            ${error_text}=    Get Text    ${ERROR_MESSAGE}
            Log To Console    Login was rejected: ${error_text}
        ELSE
            Log To Console    Login neither redirected nor showed a login-error message.
        END
    END
    Get Url    not contains    /login

Invalid Login Shows Error Message
    [Tags]    smoke    ui    login
    Login With Credentials    ${INVALID_EMAIL}    ${INVALID_PASSWORD}
    Wait For Elements State    ${ERROR_MESSAGE}    visible    timeout=5s
    ${error_text}=    Get Text    ${ERROR_MESSAGE}
    Should Not Be Empty    ${error_text}
