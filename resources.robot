*** Settings ***
Library          Collections
Library          RequestsLibrary

*** Variables ***
${BASE_URL}           http://localhost:3000/api
# ${BASE_URL}           https://fit-go-api.onrender.com/api
${GYMS_ENDPOINT}      /gyms
${LOGIN_ENDPOINT}     /users/login

*** Keywords ***
Create Sessions
    Create Session  FitGoAPI  ${BASE_URL}
    Get FitGo token

Get FitGo token
    &{data}=  Create Dictionary  email=testing@email.com  password=testpassword
    ${response}=  POST On Session  FitGoAPI  ${LOGIN_ENDPOINT}  json=${data}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    ${token}=  Get From Dictionary  ${json}  token
    Set Suite Variable  ${TOKEN}  ${token}