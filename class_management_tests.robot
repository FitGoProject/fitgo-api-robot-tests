*** Settings ***
Resource         resources.robot
Library          String
Suite Setup      Create Sessions

*** Variables ***
${CLASSES_ENDPOINT}  /classes
${GYM_ID}  643b1e272c040f2a062ab9c8

*** Test Cases ***
Test Create Class With Valid Data
    [Tags]  POST
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{data}=  Create Dictionary  gymId=${GYM_ID}  name=Example Class  description=Fitness class
    ${response}=  POST On Session  FitGoAPI  ${CLASSES_ENDPOINT}  json=${data}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  201
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test Get All Classes
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${CLASSES_ENDPOINT}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure
    # Assuming the JSON response is an array of classes, get the ID of the first class
    ${class_id}=  Get From Dictionary  ${json[0]}  _id
    Set Suite Variable  ${CLASS_ID}  ${class_id}

Test Get Class By ID
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${CLASSES_ENDPOINT}/${CLASS_ID}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test Update Class
    [Tags]  PUT
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{data}=  Create Dictionary  name=Updated Class  description=Updated fitness class
    ${response}=  PUT On Session  FitGoAPI  ${CLASSES_ENDPOINT}/${CLASS_ID}  json=${data}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test Delete Class
    [Tags]  DELETE
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  DELETE On Session  FitGoAPI  ${CLASSES_ENDPOINT}/${CLASS_ID}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure
