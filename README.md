# aws-sandbox
This project defines an AWS sandbox infrastructure with Terraform.io

## Key pair
If you do not already have a suitable key pair created in AWS, you will need to create one.
Go to the _EC2 Dashboard_ and find _Network & Security_ -> _Key Pairs_.
Click the _Create Key Pair_ button and enter "sandbox".
(You can name it differently, but you will need to modify the terraform files in this project to match.)
Save the downloaded `sandbox.pem` file somewhere safe.