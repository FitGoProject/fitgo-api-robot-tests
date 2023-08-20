*** Settings ***
Resource     resources.robot
Library      String
Suite Setup  Create Sessions

*** Variables ***
${REGISTER_ENDPOINT}  /users/register
${LOGIN_ENDPOINT}     /users/login
${USERS_ENDPOINT}     /users

*** Test Cases ***
Test User Registration With Valid Data
    [Tags]  POST
    ${random_username}=  Generate Random String  10  [LETTERS][NUMBERS]
    ${email}=  Catenate  ${random_username}  @email.com
    Set Suite Variable  ${EMAIL}  ${email}
    Set Suite Variable  ${PASSWORD}  securePass123
    &{data}=  Create Dictionary  name=John  lastName=Doe  email=${email}  password=${PASSWORD}  phone=1234567890  personalId=987654321  roles=["user"]
    ${response}=  POST On Session  FitGoAPI  ${REGISTER_ENDPOINT}  json=${data}
    Should Be Equal As Strings  ${response.status_code}  201
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test User Registration With Invalid Data
    [Tags]  POST
    &{data}=  Create Dictionary  name=  lastName=  email=  password=  phone=  personalId=  roles=[]
    ${response}=  POST On Session  FitGoAPI  ${REGISTER_ENDPOINT}  json=${data}  expected_status=400
    ${json}=  Set Variable  ${response.json()}
    Should Be Equal As Strings  ${json["error"]}  Some fields are empty

Test User Login With Valid Credentials
    [Tags]  POST
    &{data}=  Create Dictionary  email=${EMAIL}  password=${PASSWORD}
    ${response}=  POST On Session  FitGoAPI  ${LOGIN_ENDPOINT}  json=${data}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    ${token}=  Get From Dictionary  ${json}  token
    Set Suite Variable  ${TOKEN}  ${token}
    # Add appropriate assertions based on your API response structure

Test User Login With Invalid Credentials
    [Tags]  POST
    &{data}=  Create Dictionary  email=${EMAIL}  password=wrongPass
    ${response}=  POST On Session  FitGoAPI  ${LOGIN_ENDPOINT}  json=${data}  expected_status=401
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test Get All Users
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${USERS_ENDPOINT}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Assuming the JSON response is an array of users, get the ID of the first user
    ${user_id}=  Get From Dictionary  ${json[0]}  _id
    Set Suite Variable  ${USER_ID}  ${user_id}
    # Add appropriate assertions based on your API response structure

Test Get User By ID
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${USERS_ENDPOINT}/${USER_ID}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test Update User
    [Tags]  PUT
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{data}=  Create Dictionary  name=NewName  lastName=NewLastName  email=newemail@email.com  phone=0987654321  personalId=123456789  roles=["user"]
    ${response}=  PUT On Session  FitGoAPI  ${USERS_ENDPOINT}/${USER_ID}  json=${data}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

Test Delete User
    [Tags]  DELETE
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    # Fetch user's ID
    Get User ID  ${headers}
    ${response}=  DELETE On Session  FitGoAPI  ${USERS_ENDPOINT}/${USER_ID}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Add appropriate assertions based on your API response structure

*** Keywords ***
Get User ID
    [Arguments]  ${headers}
    ${all_users_response}=  GET On Session  FitGoAPI  ${USERS_ENDPOINT}  headers=${headers}
    ${all_users_json}=  Set Variable  ${all_users_response.json()}
    # Assuming the response is an array of users, get the ID of the first user that's not the test user
    ${new_user_id}=  Set Variable  ${EMPTY}
    FOR  ${user}  IN  @{all_users_json}
        ${current_email}=  Get From Dictionary  ${user}  email
        IF  '${current_email}' != 'testing@email.com'
            ${new_user_id}=  Get From Dictionary  ${user}  _id
            Exit For Loop
        END
    END
    Should Not Be Empty  ${new_user_id}  No other user found for deletion
    Set Suite Variable  ${USER_ID}  ${new_user_id}
