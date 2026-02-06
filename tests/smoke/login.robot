*** Settings ***
Resource    ../../resources/pages/login.resource
Resource    ../../resources/variables/env.resource
Suite Setup     New Browser    ${BROWSER}    headless=${HEADLESS}
Suite Teardown  Close Browser

*** Test Cases ***
Login With Invalid Credentials Shows Error
    Open Login Page
    Login With Credentials    wrong@test.com    wrongpass
    Wait For Elements State   ${ERROR_MESSAGE}    visible
