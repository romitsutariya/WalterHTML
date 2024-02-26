from lambda_function import lambda_handler
import json

def read_json_file(file_path):
    try:
        # Open the JSON file and read its contents
        with open(file_path, 'r') as file:
            data = json.load(file)
        return data
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        return None
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON in file '{file_path}': {e}")
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None  
  
result = lambda_handler(read_json_file("simple.json"), None)
print(result)

