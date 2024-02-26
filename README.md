🚀 Excited to share my latest learning project on LinkedIn! 🚀

📁 Converting JSON to HTML seamlessly with AWS Components 📁
Ever found yourself needing to convert JSON files to HTML effortlessly?
Look no further! I've developed a robust solution using AWS services, and I'm thrilled to share it with you.

Here's how it works:
1️⃣ User uploads a JSON file into AWS S3.
2️⃣ S3 triggers events that are sent to SQS (Simple Queue Service).
3️⃣ SQS then triggers a Lambda function.
4️⃣ Using Python code, Lambda dynamically converts the JSON files into HTML.
5️⃣ The HTML files are then put back into S3 for easy access.

🛠️ What's under the hood? 🛠️
AWS S3: For file storage and event triggers.
AWS SQS: For message queuing between S3 and Lambda.
AWS Lambda: Executes the Python code to convert JSON to HTML.
Terraform: I've built the entire infrastructure using Terraform for easy deployment and management.

🌟 Why is this solution awesome? 🌟
Seamless Conversion: Say goodbye to manual conversion processes.
Scalable: Handles large volumes of files effortlessly.
Automated: Once set up, the process runs smoothly without manual intervention.

Request you to provide some suggestions for further improvements.
