from json2table import convert
import boto3
import uuid

s3_client = boto3.client('s3')
object_key = 'HtmlToJson'
bucket_name = 'html-parser-rsutariya'

def convert_to_html(json_object, build_direction="LEFT_TO_RIGHT", table_attributes=None):
    build_direction = "LEFT_TO_RIGHT"
    table_attributes = {"class" : "table table-striped","border": "1","style": "border-collapse: collapse;width:100%; width: 100%;"}
    html = convert(
    json_object, build_direction=build_direction, table_attributes=table_attributes)
    return html

def save_content_to_file(html_data):
    random_key = f"{object_key}_random_{uuid.uuid4()}.html"
    s3_client.put_object(Bucket=bucket_name, Key=random_key, Body=html_data)
    print(f"File '{random_key}' created successfully in bucket")

def lambda_handler(event, context):
    html_data=convert_to_html(event)
    save_content_to_file(html_data)
    return "Processed the message!"
