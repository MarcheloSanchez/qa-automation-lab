*** Settings ***
Library    Browser

*** Variables ***
${EMAIL_INPUT}       css=input[data-test="email"]
${PASSWORD_INPUT}    css=input[data-test="password"]
${LOGIN_BUTTON}      css=button[data-test="login-submit"]
${ERROR_MESSAGE}     css=.alert-danger

*** Keywords ***
Open Login Page
    New Page    ${BASE_URL}/login

Login With Credentials
    [Arguments]    ${email}    ${password}
    Fill Text      ${EMAIL_INPUT}    ${email}
    Fill Text      ${PASSWORD_INPUT} ${password}
    Click          ${LOGIN_BUTTON}
