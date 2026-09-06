*** Settings ***
Library    Browser
Resource    ../variables/env.resource

*** Variables ***
${EMAIL_INPUT}       css=input[data-test="email"]
${PASSWORD_INPUT}    css=input[data-test="password"]
${LOGIN_BUTTON}      css=[data-test="login-submit"]
${ERROR_MESSAGE}     css=[data-test="login-error"]

*** Keywords ***
Open Login Page
    New Page    ${BASE_URL}/auth/login
    # ng serve compiles each route lazily on first request, so the form
    # can take much longer than Browser's default 10s action timeout to
    # actually render on a cold dev server.
    Wait For Elements State    ${EMAIL_INPUT}    visible    timeout=60s

Login With Credentials
    [Arguments]    ${email}    ${password}
    Fill Text      ${EMAIL_INPUT}       ${email}
    Fill Text      ${PASSWORD_INPUT}    ${password}
    Click          ${LOGIN_BUTTON}

Login With Credentials And Capture Response
    [Documentation]    Same as "Login With Credentials" but returns the
    ...    actual /users/login HTTP response (status, body) for diagnosis,
    ...    instead of only observing what the UI does with it.
    [Arguments]    ${email}    ${password}
    ${promise}=    Promise To Wait For Response    matcher=**/users/login    timeout=15s
    Fill Text      ${EMAIL_INPUT}       ${email}
    Fill Text      ${PASSWORD_INPUT}    ${password}
    Click          ${LOGIN_BUTTON}
    ${response}=    Wait For    ${promise}
    RETURN    ${response}
