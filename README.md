
<h1>Setup Requirements</h1><br />

NOTE: For users following along in their own environments as opposed to the ACG provided environments, please install python's `boto3` module before proceeding.


```
1. Terraform binary => 0.13.x # wget -c https://releases.hashicorp.com/terraform/0.13.0/terraform_0.13.0_linux_amd64.zip
2. Python3 & PIP needs to be installed on all nodes(on most , modern Linux systems it's available by default) # yum -y install python3-pip
3. AWS CLI (install via pip) # pip3 install awscli --user 
4. jq (install via package manager) - OPTIONAL # yum -y install jq
```


<h2>Notes and Instructions</h2><br />

*For Terraform Part*
```
The regional AWS providers are defined in providers.tf
Terraform configuration and backend is defined in backend.tf.


If you want to read and understand the deployment in sequence. Read through templates in the following order:
1. network_setup.tf
2. instances.tf --> local-exec provisioners in this templates kick-off Ansible playbooks in ansible_templates/
3. alb_acm.tf
4. dns.tf
```
*S3 Backend*
```
This project requires an S3 backend for storing Terraform state file, therefore in the terraform block in the backend.tf file you'll need to plug in the an actual bucket name before you can run "terraform init".
Please also note that the "terraform" block does not allow usage of variables so values HAVE to be hardcoded.
```
Sample command for bucket creation via CLI:
```
aws s3api create-bucket --bucket <YOUR-UNIQUE-BUCKET-NAME-GOES-HERE>
```

Example
```
aws s3api create-bucket --bucket myawesomebucketthatmayormaynotexistalready
```

<h2>Supplementary files </h2> <br />

```
1. aws_get_cp_hostedzone #An AWS CLI command for fetching your hosted zone for DNS part of this project
2. null_provisioners.tf #For setting up and deleting Ansible inventory files 
3. variables.tf #Defines variables and default values for them for the TF templates
4. outputs.tf #Defines the outputs presented at successful completion of execution of TF apply.
```
<h2>Additional </h2> <br />

Change user ignat in connect section to your username and generate ssh key:
command: "ssh-keygen"

```
