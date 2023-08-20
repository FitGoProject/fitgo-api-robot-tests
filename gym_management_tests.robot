*** Settings ***
Resource         resources.robot
Library          String
Suite Setup      Create Sessions

*** Variables ***
${GYMS_ENDPOINT}   /gyms
${USERS_ENDPOINT}  /users
${CLASSES_ENDPOINT}  /classes
${GYM_ID}  643b1e272c040f2a062ab9c8

*** Test Cases ***
Test Create Classes With Valid Data
    [Tags]  POST
    Log To Console    message=${TOKEN}
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}

    # Create Zumba Class
    &{zumba_data}=  Create Dictionary  gymId=${GYM_ID}  name=Zumba  description=Zumba Fitness class
    ${response_zumba}=  POST On Session  FitGoAPI  ${CLASSES_ENDPOINT}  json=${zumba_data}  headers=${headers}
    Should Be Equal As Strings  ${response_zumba.status_code}  201
    ${json_zumba}=  Set Variable  ${response_zumba.json()}
    # Capture the Zumba class ID and store it as a suite variable
    ${zumba_class_id}=  Get From Dictionary  ${json_zumba}  _id
    Set Suite Variable  ${ZUMBA_CLASS_ID}  ${zumba_class_id}

    # Create Crossfit Class
    &{crossfit_data}=  Create Dictionary  gymId=${GYM_ID}  name=Crossfit  description=Crossfit Fitness class
    ${response_crossfit}=  POST On Session  FitGoAPI  ${CLASSES_ENDPOINT}  json=${crossfit_data}  headers=${headers}
    Should Be Equal As Strings  ${response_crossfit.status_code}  201
    ${json_crossfit}=  Set Variable  ${response_crossfit.json()}
    # Capture the Crossfit class ID and store it as a suite variable
    ${crossfit_class_id}=  Get From Dictionary  ${json_crossfit}  _id
    Set Suite Variable  ${CROSSFIT_CLASS_ID}  ${crossfit_class_id}

Test Get All Classes
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${CLASSES_ENDPOINT}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    ${class_id}=  Get From Dictionary  ${json[0]}  _id
    Set Suite Variable  ${CLASS_ID}  ${class_id}

Get Existing Admin ID
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${USERS_ENDPOINT}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}
    # Capture the admin ID and store it as a suite variable
    ${admin_id}=  Get From Dictionary  ${json[0]}  _id
    Set Suite Variable  ${ADMIN_ID}  ${admin_id}

Test Create Gym With Valid Data
    [Tags]  POST
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{location}=  Create Dictionary  latitude=37.7749  longitude=-122.4194  placeId=ChIJVQV1ZSF-j4AR7e4yEh4YZxI
    &{data}=  Create Dictionary  name=Example Gym  location=${location}  admins=${ADMIN_ID}
    Log To Console    message=${data}
    ${response}=  POST On Session  FitGoAPI  ${GYMS_ENDPOINT}  json=${data}  headers=${headers}
    Log To Console    message=${response.text}
    Run Keyword If  '${response.status_code}' == '500'  Log  ${response.content}
    Should Be Equal As Strings  ${response.status_code}  201
    ${json}=  Set Variable  ${response.json()}
    Should Contain  ${json}  _id
    Should Contain  ${json}  name
    Should Contain  ${json}  location
    Set Suite Variable  ${GYM_ID}  ${json['_id']}

Test Get All Gyms
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${GYMS_ENDPOINT}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}

Test Get Gym By ID
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${GYMS_ENDPOINT}/${GYM_ID}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}

Test Create Option For Gym
    [Tags]  POST
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${options_endpoint}=  Set Variable  ${GYMS_ENDPOINT}/${GYM_ID}/options
    Set Suite Variable  ${OPTIONS_ENDPOINT}  ${options_endpoint}
    @{classes_ids}=  Create List  ${CLASS_ID}
    &{data}=  Create Dictionary  name=Basic Plan  description=Monthly Membership  months=1  price=50  classes=${classes_ids}  weekly=3  monthly=12
    ${response}=  POST On Session  FitGoAPI  ${OPTIONS_ENDPOINT}  json=${data}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  201
    ${json}=  Set Variable  ${response.json()}
    Set Suite Variable  ${OPTION_ID}  ${json['_id']}

Test Get Options For Gym
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${OPTIONS_ENDPOINT}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}

Test Get Specific Option For Gym
    [Tags]  GET
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    ${response}=  GET On Session  FitGoAPI  ${OPTIONS_ENDPOINT}/${OPTION_ID}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}

Test Update Option For Gym
    [Tags]  PUT
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    # Assuming you have the ObjectIds for Zumba and Crossfit classes stored in variables
    @{classes_ids}=  Create List  ${ZUMBA_CLASS_ID}  ${CROSSFIT_CLASS_ID}
    &{data}=  Create Dictionary  name=Premium Plan  description=Yearly Membership  months=12  price=500  classes=${classes_ids}  weekly=5  monthly=20
    ${response}=  PUT On Session  FitGoAPI  ${OPTIONS_ENDPOINT}/${OPTION_ID}  json=${data}  headers=${headers}
    Should Be Equal As Strings  ${response.status_code}  200
    ${json}=  Set Variable  ${response.json()}

Test Update Gym
    [Tags]  PUT
    ${headers}=  Create Dictionary  Authorization=Bearer ${TOKEN}
    &{location}=  Create Dictionary  latitude=40.7128  longitude=-74.0060  placeId=ChIJOwg_06VPwokRYv534QaPC8g
    @{options_ids}=  Create List  ${OPTION_ID}  # Assuming OPTION_ID is the ObjectId of the option you created earlier
    &{data}=  Create Dictionary  name=Updated Gym  location=${location}  options=${options_ids}
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
