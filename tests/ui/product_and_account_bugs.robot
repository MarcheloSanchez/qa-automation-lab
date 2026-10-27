*** Settings ***
Documentation    Product-detail and account checks derived from known UI defects in the app's
...              ``sprint5-with-bugs`` version (``testSessions/listOfBugs.md``). Each test
...              passes on a correct app; the ``bug:<id>`` tag names the defect it detects.
...              Verified against both versions' Angular source at the pinned submodule.
Resource    ../../resources/pages/common.resource
Resource    ../../resources/pages/login.resource
Resource    ../../resources/pages/product.resource

Suite Setup       Open Browser To Application
Suite Teardown    Close Application Browser

*** Variables ***
${PROFILE_FIRST_NAME}    css=[data-test="first-name"]
${ADDED_TO_CART}         Product added to shopping cart.

*** Test Cases ***
Increase Button Raises The Quantity
    [Tags]    ui    products    bug:40
    Open Product Detail Page
    Get Property    ${QUANTITY_INPUT}    value    ==    1
    Click    ${INCREASE_QUANTITY}
    Get Property    ${QUANTITY_INPUT}    value    ==    2

Add To Cart Confirms Success
    [Tags]    ui    cart    bug:43
    Open Product Detail Page
    Click    ${ADD_TO_CART}
    Wait For Condition    Text    body    contains    ${ADDED_TO_CART}    timeout=10s
    Get Text    body    not contains    something went wrong

More Than Ten Pieces Can Be Added To The Cart
    [Tags]    ui    cart    bug:47
    Open Product Detail Page
    Fill Text    ${QUANTITY_INPUT}    11
    Click    ${ADD_TO_CART}
    Wait For Condition    Text    ${CART_QUANTITY}    ==    11    timeout=10s

Profile Shows First Name In First Name Field
    [Tags]    ui    account    bug:36
    ${token}=    Get Token    ${VALID_EMAIL}    ${VALID_PASSWORD}
    ${me}=    Get Current User    ${token}
    Open Login Page
    Login With Credentials    ${VALID_EMAIL}    ${VALID_PASSWORD}
    Wait For Condition    Url    not contains    /login    timeout=15s
    Go To    ${BASE_URL}${ROUTE_PREFIX}/account/profile
    # The field only exists on the profile page; wait until the form is filled.
    Wait For Condition    Property    ${PROFILE_FIRST_NAME}    value    !=    ${EMPTY}    timeout=30s
    Get Property    ${PROFILE_FIRST_NAME}    value    ==    ${me}[first_name]
