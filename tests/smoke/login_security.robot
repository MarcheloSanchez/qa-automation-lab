*** Settings ***
Documentation    Login checks derived from known defects in the app's ``sprint5-with-bugs``
...              version (see ``testSessions/listOfBugs.md`` in the submodule). Each test
...              passes on a correct app; the ``bug:<id>`` tag names the defect it detects.
Resource    ../../resources/api/login_api.resource

*** Variables ***
# customer2 keeps these tests from touching the account the other suites log in with.
${LOCKOUT_EMAIL}       customer2@practicesoftwaretesting.com
# MySQL needs whitespace after '--'; the trailing 'x' keeps Robot from stripping it.
${SQLI_EMAIL}          customer@practicesoftwaretesting.com' -- x

*** Test Cases ***
Login Rejects SQL Injection In Email
    [Tags]    smoke    login    security    bug:79
    Skip If Api Is Unreachable
    ${result}=    Execute Login Request    ${SQLI_EMAIL}    not-the-password
    Should Be Equal As Integers    ${result}[status_code]    401
    Should Be Empty    ${result}[token]

One Failed Login Does Not Lock The Account
    [Tags]    smoke    login    bug:21
    Skip If Api Is Unreachable
    ${failed}=    Execute Login Request    ${LOCKOUT_EMAIL}    wrong-password
    Should Be Equal As Integers    ${failed}[status_code]    401
    ${result}=    Execute Login Request    ${LOCKOUT_EMAIL}    ${VALID_PASSWORD}
    Should Be Equal As Integers    ${result}[status_code]    200
    Should Not Be Empty    ${result}[token]
