*** Settings ***
Resource     resources.robot
Suite Setup  Create Sessions

*** Variables ***
${SUBSCRIPTIONS_ENDPOINT}    ${BASE_URL}/subscriptions

*** Test Cases ***

Create Subscription
    [Tags]    POST
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{data}=    Create Dictionary    userId=60a8fadb48fbee001fd29b1c    gymId=60a9000448fbee001fd29b1e    optionId=60a9072d48fbee001fd29b20    total=150    startDate=2023-04-16    endDate=2023-05-16
    ${response}=    POST On Session    FitGoAPI    ${SUBSCRIPTIONS_ENDPOINT}    json=${data}  headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    201
    ${json}=    Set Variable    ${response.json()}
    Set Global Variable    ${SUBSCRIPTION_ID}    ${json["_id"]}

Get All Subscriptions
    [Tags]    GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    FitGoAPI    ${SUBSCRIPTIONS_ENDPOINT}  headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}

Get All Subscriptions Without Authentication
    ${response}=  GET On Session  FitGoAPI  ${SUBSCRIPTIONS_ENDPOINT}  expected_status=401
    ${json}=  Set Variable  ${response.json()}

Get Subscription By ID
    [Tags]    GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=    GET On Session    FitGoAPI    ${SUBSCRIPTIONS_ENDPOINT}/${SUBSCRIPTION_ID}  headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}

Update Subscription
    [Tags]    PUT
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{data}=    Create Dictionary    total=180    startDate=2023-04-17    endDate=2023-05-17
    ${response}=    PUT On Session    FitGoAPI    ${SUBSCRIPTIONS_ENDPOINT}/${SUBSCRIPTION_ID}    json=${data}  headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}

Delete Subscription
    [Tags]    DELETE
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=    DELETE On Session    FitGoAPI    ${SUBSCRIPTIONS_ENDPOINT}/${SUBSCRIPTION_ID}  headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    204
