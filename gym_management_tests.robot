*** Settings ***
Resource         resources.robot
Library          String
Suite Setup      Create Sessions

*** Variables ***
${GYMS_ENDPOINT}  /gyms

*** Test Cases ***
Test Create Gym With Valid Data
    [Tags]  POST
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{location}=  Create Dictionary  latitude=37.7749  longitude=-122.4194  placeId=ChIJVQV1ZSF-j4AR7e4yEh4YZxI
    &{options}=  Create Dictionary  name=Basic Plan  description=Monthly Membership  months=1  price=50
    &{data}=  Create Dictionary  name=Example Gym  location=${location}  options=${options}
    ${response}=  POST On Session  FitGoAPI  ${GYMS_ENDPOINT}  json=${data}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  201
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test Get All Gyms
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${GYMS_ENDPOINT}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure
    # Assuming the JSON response is an array of gyms, get the ID of the first gym
    ${gym_id}=  Get From Dictionary  ${json[0]}  _id
    Set Suite Variable  ${GYM_ID}  ${gym_id}

Test Get Gym By ID
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${GYMS_ENDPOINT}/${GYM_ID}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure
    
Test Update Gym
    [Tags]  PUT
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{location}=  Create Dictionary  latitude=40.7128  longitude=-74.0060  placeId=ChIJOwg_06VPwokRYv534QaPC8g
    &{options}=  Create Dictionary  name=Premium Plan  description=Yearly Membership  months=12  price=500
    &{data}=  Create Dictionary  name=Updated Gym  location=${location}  options=${options}
    ${response}=  PUT On Session  FitGoAPI  ${GYMS_ENDPOINT}/${GYM_ID}  json=${data}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test Delete Gym
    [Tags]  DELETE
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  DELETE On Session  FitGoAPI  ${GYMS_ENDPOINT}/${GYM_ID}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure
