# aws-sandbox
This project defines an AWS sandbox infrastructure with Terraform.io.

## Purpose
I created this project firstly to demonstrate how to use Terraform with AWS.
After running `apply.sh`, you will have everything you need to begin deploying production-ready applications in AWS.
Secondly, this infrastructure definition serves as a basis for other projects I have in the works.

## Projects using aws-sandbox
[lift-jetty-cluster-aws](https://github.com/joescii/lift-jetty-cluster-aws)

## Prerequisite: Key pair
If you do not already have a suitable key pair created in AWS, you will need to create one.
Go to the _EC2 Dashboard_ and find _Network & Security_ -> _Key Pairs_.
Click the _Create Key Pair_ button and enter "sandbox".
(You can name it differently, but you will need to modify the terraform files in this project to match.)
Save the downloaded `sandbox.pem` file somewhere safe.

If you already have a key pair, or you gave it a different name, then update the default value for `key_name` in `variables.tf`.

## Prerequisite: Upload blank.tfstate to S3
After Terraform applies infrastructure, it will store the state of your infrastructure in a file named `terraform.tfstate`.
Each subsequent run of Terraform needs this file so it knows what already exists and can apply only the delta to your infrastructure.

This project uses an AWS S3 bucket for storing your Terraform state file.
Hence you will need to get the ball rolling by putting a blank `terraform.tfstate` file in S3.
Go to the _S3 Dashboard_ and create a bucket, or open an existing bucket.
Within the bucket, decide a folder location where you would like to store the state file.
Upload `blank.tfstate` to this location.
The name of the file doesn't matter, but I certainly recommend you give it a meaningful name like `vpc.tfstate`.

Take note of the bucket and key names, as you will need to define them as environment variables as highlighted below.
If the path to your file is _All Buckets / team-bucket / sandbox / vpc.tfstate_, then the bucket is `team-bucket` and the key is `sandbox/vpc.tfstate`.

## Environment
The `apply.sh` script needs to run in a unix environment with the following variables set:
`AWS_ACCESS_KEY_ID`
`AWS_SECRET_ACCESS_KEY`
`AWS_DEFAULT_REGION`: The region you want to build the infrastructure in.
The Terraform plans in this repo are configured for `us-west-1`.
If you choose a different region, update `variables.tf` accordingly.
`TF_STATE_BUCKET`: The S3 bucket where you want to store the Terraform state.
`TF_STATE_KEY`: The S3 key within the bucket where you want to store the Terraform state.

I recommend using [Codeship](http://codeship.io) as your CI for running Terraform, as that is where this has been tested.
It is 100% free to use (up to a certain number of builds per month).