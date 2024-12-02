
# Skyflow for Databricks: AI examples

This repository contains a collection of examples demonstrating how Skyflow's Data Privacy Platform can ensure safe handling of sensitive private data in, on, and for a Databricks Lakehouse.

Note: these examples are not an officially-supported product or recommended for production deployment without further review, testing, and hardening. Use with caution, this is sample code only.

## Create an Agent with a Skyflow Deidentify Tool

In this example we will create an AI Agent using the Mosaic AI Agent Framework with the ability to deidentify sensitive data using a custom Unity Catalog Function tool.

To learn more about this process, see the [Create an Agent](https://docs.databricks.com/en/generative-ai/agent-framework/create-agent.html) documentation.

### Prerequisites

**Configure Secrets**

- Create or log into your account at [skyflow.com](https://skyflow.com) and generate an API key: [docs.skyflow.com](https://docs.skyflow.com/api-authentication/)
- Copy your API key, Vault URL, and Vault ID


### Create a simple Deidentification Tool

An agent "tool" is a function the agent can choose to invoke to perform some action. In this example, we'll create a simple tool which will enable the agent to deidentify a string and remove all possibly-sensitive data from the unstructured text.

#### Python code

First let's examine the Python code for the function itself. To use this in your own account, complete the TODOs in the sample code below:

```py
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
 api_url = "https://cluster.vault.skyflowapis.dev/v1/detect/deidentify/string"
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
```


### Create a tool as a function in Databricks Unity Catalog

To create this function in Databricks Unity Catalog, click 'Create a Query' and run the query below. 

```sql
CREATE OR REPLACE FUNCTION
your_catalog.default.deidentify_string (
 input_text STRING COMMENT 'The string to be de-identified.'
)
RETURNS STRING
LANGUAGE PYTHON
DETERMINISTIC
COMMENT 'Deidentify a string using the Skyflow API. Removes any sensitive data from the string and returns a safe string with placeholders in place of sensitive data tokens.'
AS $$
 # python code from the previous step
$$
```

1. Be sure to complete the TODOs in the Python code to make this functional. 
2. Specify the name of the catalog you want to use in place of "your_catalog". You will need write permissions to the catalog, 
3. Copy and paste your Python code where it says "# python code from the previous step".
4. Run the query.

### Create an Agent using the Agent Builder

1. Open the [AI Playground](https://docs.databricks.com/en/large-language-models/ai-playground.html) in Databricks.
2. Select a tool-enabled Large Language Model, like any of the Meta Llama 3.1 models.
3. Click 'Tools'.
4. On the 'Hosted Function' tab, select the function we created above: `your_catalog.default.deidentify_string`
5. Test out your prototype Agent with a prompt like:

> Please deidentify the following text: “Hi, this is Johnathan Smith, and I’m calling because I noticed a strange charge on my checking account. My account number is 3478-2215-9876, and the charge is for $250.50 to a store I don’t recognize. It posted yesterday, November 13th. I live at 123 Maple Avenue, Springfield, IL 62704, and my phone number is 555-123-4567. Can you help me figure out what’s going on? Oh, and just to confirm, my email is john.smith@example.com, if you need to send me any updates. Thank you!”

### Export and deploy your new Agent

Databricks makes it easy to export and deploy your new Agent. Follow the [instructions from Databricks](https://docs.databricks.com/en/generative-ai/agent-framework/create-agent.html#export-and-deploy-ai-playground-agents).

## Learn more

To learn more about Skyflow Detect, the API for protecting privacy in unstructured data, visit [docs.skyflow.com](https://docs.skyflow.com/detect-overview/).