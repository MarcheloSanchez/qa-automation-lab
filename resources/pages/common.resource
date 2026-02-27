*** Settings ***
Library    Browser
Resource   ../variables/env.resource

*** Keywords ***
Open Browser Session
    [Documentation]    Opens a new browser context and navigates to the base URL.
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context
    New Page    ${BASE_URL}

Close Browser Session
    [Documentation]    Closes the active browser and all associated contexts and pages.
    Close Browser

Wait For Element And Get Text
    [Documentation]    Waits until the element is visible, then returns its text content.
    [Arguments]    ${selector}
    Wait For Elements State    ${selector}    visible
    ${text}=    Get Text    ${selector}
    RETURN    ${text}

Element Should Be Visible And Contain
    [Documentation]    Asserts that an element is visible and its text contains the expected value.
    [Arguments]    ${selector}    ${expected_text}
    Wait For Elements State    ${selector}    visible
    Get Text    ${selector}    ==    ${expected_text}
