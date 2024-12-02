CREATE OR REPLACE FUNCTION
your_catalog.default.deidentify_string (
 input_text STRING COMMENT 'The string to be de-identified.'
)
RETURNS STRING
LANGUAGE PYTHON
DETERMINISTIC
COMMENT 'Deidentify a string using the Skyflow API. Removes any sensitive data from the string and returns a safe string with placeholders in place of sensitive data tokens.'
AS $$
  import sys
 import json
 import requests
 from io import StringIO

 # Retrieve the token from Databricks secrets
 # TODO: replace this with your Skyflow API key
 bearer_token = "-skyflow-api-key-"

 sys_stdout = sys.stdout
 redirected_output = StringIO()
 sys.stdout = redirected_output

 # TODO: replace with your Vault ID from Skyflow
 vault_id = "q7248cbd0b6f484185b277a4aea9098f"
 # TODO: replace 'cluster' with the cluster identifier from your Skyflow Vault URL
 api_url = "https://ebfc9bee4242.vault.skyflowapis.com/v1/detect/deidentify/string"
 headers = {
     "Authorization": f"Bearer {bearer_token}",
     "Content-Type": "application/json",
 }
 json_body = {
     "vault_id": vault_id,
     "text": input_text,
 }
 
 # TODO, optional: you can customize the entity types to be deidentified by passing values in "restrict_entities", for example: 
 #  "restrict_entities": ["NAME"]

 try:
     api_response = requests.post(api_url, headers=headers, json=json_body)
     api_response.raise_for_status()  # Raise an exception for HTTP errors
     external_data = api_response.json()  # Assuming the response is in JSON format
     result = external_data.get('processed_text', 'No processed_text found')
 except requests.exceptions.RequestException as e:
     result = f"Error calling external API: {str(e)}"

 sys.stdout = sys_stdout
 return result
$$