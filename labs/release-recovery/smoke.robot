*** Settings ***
Library    http_checks.py

*** Variables ***
${BASE_URL}    http://127.0.0.1:18080
${READY_STATUS}    ready
${READY_CODE}    200

*** Test Cases ***
Process Is Healthy
    Endpoint Should Report    ${BASE_URL}    /health    ok    200

Readiness Matches Expectation
    Endpoint Should Report    ${BASE_URL}    /ready    ${READY_STATUS}    ${READY_CODE}

Unknown Route Returns Not Found
    Endpoint Should Report    ${BASE_URL}    /does-not-exist    not found    404
