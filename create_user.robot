*** Settings ***
Resource     resources.robot
Library      String
Suite Setup  Create Sessions

*** Variables ***
${REGISTER_ENDPOINT}  /users/register
${LOGIN_ENDPOINT}     /users/login
${USERS_ENDPOINT}     /users
${email}=  danorrev87@gmail.com

*** Test Cases ***
Test User Registration With Valid Data
    [Tags]  POST
    ${random_username}=  Generate Random String  10  [LETTERS][NUMBERS]
    ${email}=  Catenate  ${random_username}  @email.com
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    Set Suite Variable  ${PASSWORD}  Password123
    &{data}=  Create Dictionary  name=Orrego  lastName=Danilo  email=${email}  password=${PASSWORD}  phone=1234567890  personalId=987654321  roles=["user"]
    ${response}=  POST On Session  FitGoAPI  ${REGISTER_ENDPOINT}  json=${data}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  201
    ${json}=  Set Variable  ${response.json()}

