*** Settings ***
Library     Browser
Resource    ../variables/env.resource

*** Keywords ***
Open Browser To Application
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context

Close Application Browser
    Close Browser
