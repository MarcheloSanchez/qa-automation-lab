*** Settings ***
Documentation    Data-exposure checks derived from known defects (OWASP API Top 10) in the
...              app's ``sprint5-with-bugs`` version. Each test passes on a correct app;
...              the ``bug:<id>`` tag names the defect it detects.
Library     Collections
Resource    ../../resources/api/login_api.resource

*** Test Cases ***
User Profile Hides Internal Fields
    [Tags]    smoke    data-exposure    security    bug:73
    Skip If Api Is Unreachable
    ${token}=    Get Token    ${VALID_EMAIL}    ${VALID_PASSWORD}
    ${me}=    Get Current User    ${token}
    FOR    ${field}    IN    password    failed_login_attempts    enabled
        Dictionary Should Not Contain Key    ${me}    ${field}
    END

Product List Hides Stock From The Public
    [Tags]    smoke    data-exposure    security    bug:75
    Skip If Api Is Unreachable
    ${response}=    Api Request    GET    /products
    Should Be Equal As Integers    ${response}[status_code]    200
    Should Not Be Empty    ${response}[json][data]
    FOR    ${product}    IN    @{response}[json][data]
        Dictionary Should Not Contain Key    ${product}    stock
    END

Application Log Is Not Served
    [Tags]    smoke    data-exposure    security    bug:80
    Skip If Api Is Unreachable
    ${response}=    Api Request    GET    /logs/laravel.log
    ${blocked}=    Create List    ${401}    ${403}    ${404}
    List Should Contain Value    ${blocked}    ${response}[status_code]

User Ids Are Not Sequential Numbers
    [Tags]    smoke    data-exposure    security    bug:82
    Skip If Api Is Unreachable
    ${token}=    Get Token    ${VALID_EMAIL}    ${VALID_PASSWORD}
    ${me}=    Get Current User    ${token}
    Should Not Match Regexp    ${{ str($me['id']) }}    ^\\d+$
