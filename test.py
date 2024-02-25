from lambda_function import lambda_handler

event = {
  "key1":"Romit"
}
result = lambda_handler(event, None)
print(result)