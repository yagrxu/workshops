import os
import io
import boto3
import json
import csv

# grab environment variables
ENDPOINT_NAME = 'huggingface-pytorch-training-2023-07-03-15-02-46-247'
runtime= boto3.client('runtime.sagemaker')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    data = {
        "inputs": ["I am super happy"],
        "parameters": {
      #"early_stopping": True,
      #"length_penalty": 2.0,
    #   "max_new_tokens": 50,
    #   "temperature": 0,
    #   "min_length": 10,
    #   "no_repeat_ngram_size": 2,
    }

    }
    payload = json.dumps(data)
    print(payload)
    
    response = runtime.invoke_endpoint(EndpointName=ENDPOINT_NAME,
                                       ContentType="application/json",
                                       # ContentType='text/csv',
                                       Body=payload)
    print(response)
    result = json.loads(response['Body'].read().decode())
    print(result)
    # pred = int(result['predictions'][0]['score'])
    # predicted_label = 'M' if pred == 1 else 'B'
    
    return result