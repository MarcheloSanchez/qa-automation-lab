*** Settings ***
Documentation    Product detail page and cart badge (Browser library).
Library     Browser
Resource    ../variables/env.resource
Resource    ../api/login_api.resource

*** Variables ***
${ADD_TO_CART}          css=[data-test="add-to-cart"]
${QUANTITY_INPUT}       css=[data-test="quantity"]
${INCREASE_QUANTITY}    css=[data-test="increase-quantity"]
${CART_QUANTITY}        css=[data-test="cart-quantity"]

*** Keywords ***
Get Purchasable Product
    [Documentation]    First product that can be ordered in any quantity: in stock (sprint5
    ...    exposes ``in_stock``, the buggy version ``stock``), not a rental, and not
    ...    "Thor Hammer", which the cart limits to one piece.
    ${response}=    Api Request    GET    /products
    Should Be Equal As Integers    ${response}[status_code]    200
    ${products}=    Evaluate    [p for p in $response['json']['data'] if (p.get('in_stock') or (p.get('stock') or 0) > 0) and not p.get('is_rental') and p['name'] != 'Thor Hammer']
    Should Not Be Empty    ${products}    No purchasable product on the first page of /products.
    RETURN    ${products}[0]

Open Product Detail Page
    [Documentation]    Opens a purchasable product and proves the detail page rendered.
    ${product}=    Get Purchasable Product
    New Page    ${BASE_URL}${ROUTE_PREFIX}/product/${product}[id]
    Wait For Elements State    ${ADD_TO_CART}    enabled    timeout=60s
    RETURN    ${product}
