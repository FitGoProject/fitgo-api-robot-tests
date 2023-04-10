*** Settings ***
Library          Collections
Library          RequestsLibrary

*** Variables ***
${BASE_URL}  https://fit-go-api.onrender.com/api

*** Keywords ***
Create Sessions
    Create Session  FitGoAPI  ${BASE_URL}
