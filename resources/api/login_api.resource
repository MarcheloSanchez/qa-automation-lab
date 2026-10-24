*** Settings ***
Resource    ../variables/env.resource
Library     PstApi.py    ${API_BASE_URL}

*** Keywords ***
Skip If Api Is Unreachable
    ${reachable}=    Api Is Reachable
    IF    not ${reachable}
        IF    $REQUIRE_API.lower() == 'true'
            Fail    Practice Software Testing API at ${API_BASE_URL} is not reachable (REQUIRE_API=true).
        END
        Skip    Practice Software Testing API is not reachable from this environment.
    END

Execute Login Request
    [Arguments]    ${email}    ${password}
    ${result}=    Login Request    ${email}    ${password}
    RETURN    ${result}

Get Current User
    [Arguments]    ${token}
    ${response}=    Api Request    GET    /users/me    token=${token}
    Should Be Equal As Integers    ${response}[status_code]    200
    RETURN    ${response}[json]
