*** Settings ***
Documentation    Authorization checks derived from known defects (OWASP API Top 10) in the
...              app's ``sprint5-with-bugs`` version. Each test passes on a correct app;
...              the ``bug:<id>`` tag names the defect it detects.
Library     Collections
Resource    ../../resources/api/login_api.resource

*** Variables ***
${OTHER_EMAIL}    customer2@practicesoftwaretesting.com

*** Test Cases ***
Customer Cannot Read Another User
    [Tags]    smoke    authorization    security    bug:71
    Skip If Api Is Unreachable
    ${token}=    Get Token    ${VALID_EMAIL}    ${VALID_PASSWORD}
    ${other_token}=    Get Token    ${OTHER_EMAIL}    ${VALID_PASSWORD}
    ${other}=    Get Current User    ${other_token}
    ${response}=    Api Request    GET    /users/${other}[id]    token=${token}
    ${denied}=    Create List    ${403}    ${404}
    List Should Contain Value    ${denied}    ${response}[status_code]
    Should Not Contain    ${{ str($response['json']) }}    ${OTHER_EMAIL}

Customer Cannot Delete A Brand
    [Tags]    smoke    authorization    security    bug:74
    Skip If Api Is Unreachable
    VAR    ${brand}    ${None}
    ${brand}=    Create Throwaway Brand
    ${token}=    Get Token    ${VALID_EMAIL}    ${VALID_PASSWORD}
    ${response}=    Api Request    DELETE    /brands/${brand}[id]    token=${token}
    Should Be Equal As Integers    ${response}[status_code]    403
    ${still_there}=    Api Request    GET    /brands/${brand}[id]
    Should Be Equal As Integers    ${still_there}[status_code]    200
    [Teardown]    Delete Brand As Admin    ${brand}

*** Keywords ***
Create Throwaway Brand
    ${slug}=    Evaluate    f"qa-lab-{uuid.uuid4().hex[:12]}"    modules=uuid
    ${response}=    Api Request    POST    /brands    json=${{ {'name': $slug, 'slug': $slug} }}
    Should Be Equal As Integers    ${response}[status_code]    201
    RETURN    ${response}[json]

Delete Brand As Admin
    [Arguments]    ${brand}
    IF    $brand is None    RETURN
    ${token}=    Get Token    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Api Request    DELETE    /brands/${brand}[id]    token=${token}
