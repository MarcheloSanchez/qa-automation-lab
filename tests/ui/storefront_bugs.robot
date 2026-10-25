*** Settings ***
Documentation    Storefront checks derived from known UI defects in the app's
...              ``sprint5-with-bugs`` version (``testSessions/listOfBugs.md``). Each test
...              passes on a correct app; the ``bug:<id>`` tag names the defect it detects.
...              Verified against both versions' Angular source at the pinned submodule.
Library     Collections
Resource    ../../resources/pages/common.resource
Resource    ../../resources/api/login_api.resource

Suite Setup       Open Browser To Application
Suite Teardown    Close Application Browser

*** Variables ***
${NAV_HOME}         css=[data-test="nav-home"]
${NAV_CONTACT}      css=[data-test="nav-contact"]
# type=submit: the buggy version also puts data-test="search-submit" on its reset button.
${SEARCH_BUTTON}    css=button[type="submit"][data-test="search-submit"]
${SORT_SELECT}      css=[data-test="sort"]
${SORT_HEADING}     xpath=//select[@data-test="sort"]/preceding::h4[1]
${PRODUCT_NAMES}    css=[data-test="product-name"]

*** Test Cases ***
Home Link Points To The Home Page
    [Tags]    ui    navigation    bug:29
    Open Storefront Page    /
    Get Attribute    ${NAV_HOME}    href    ==    /

Contact Link Is Spelled Correctly
    [Tags]    ui    navigation    bug:31
    Open Storefront Page    /
    Element Text Should Be    ${NAV_CONTACT}    Contact

Sort Heading Is Spelled Correctly
    [Tags]    ui    products    bug:33
    Open Storefront Page    /
    Element Text Should Be    ${SORT_HEADING}    Sort

Search Button Is Spelled Correctly
    [Tags]    ui    products    bug:34
    Open Storefront Page    /
    Element Text Should Be    ${SEARCH_BUTTON}    Search

Related Products Heading Is Spelled Correctly
    [Tags]    ui    products    bug:42
    ${products}=    Api Request    GET    /products
    ${first}=    Set Variable    ${products}[json][data][0]
    Open Storefront Page    /product/${first}[id]
    Get Text    body    contains    Related products

Name A To Z Sorts Category Ascending
    [Documentation]    The option label must match the sort the UI requests and renders.
    [Tags]    ui    products    bug:2
    Open Storefront Page    /category/hand-tools
    Wait For Elements State    ${PRODUCT_NAMES} >> nth=0    visible    timeout=30s
    ${request}=    Promise To    Wait For Response    matcher=/sort=name/    timeout=15s
    Select Options By    ${SORT_SELECT}    label    Name (A - Z)
    ${response}=    Wait For    ${request}
    Should Match Regexp    ${response}[url]    sort=name(,|%2C)asc
    Wait Until Keyword Succeeds    10s    500ms    Product Names Should Be Sorted Ascending

*** Keywords ***
Open Storefront Page
    [Arguments]    ${path}
    New Page    ${BASE_URL}${path}
    # ng serve compiles routes lazily; the first visit can be slow.
    Wait For Load State    networkidle    timeout=60s

Element Text Should Be
    [Arguments]    ${selector}    ${expected}
    Wait For Elements State    ${selector}    attached    timeout=30s
    ${text}=    Get Text    ${selector}
    Should Be Equal    ${{ $text.strip() }}    ${expected}

Product Names Should Be Sorted Ascending
    ${elements}=    Get Elements    ${PRODUCT_NAMES}
    ${names}=    Create List
    FOR    ${element}    IN    @{elements}
        ${name}=    Get Text    ${element}
        Append To List    ${names}    ${{ $name.strip().lower() }}
    END
    Should Not Be Empty    ${names}
    ${sorted}=    Evaluate    sorted($names)
    Lists Should Be Equal    ${names}    ${sorted}
