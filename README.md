## Cloud API scanning

### Report size estimation

Chose one account from each of the cloud providers (AWS, GCP, AZURE). 
We want to estimate conservitivly so please try to choose the 3 largest accounts on each
cloud. 

---
Large accounts would be those containing the most inspec cloud resources; for AWS this would include things like S3 bucket, IAM users and security groups. The more of these resources the more control checks inspec will execute and the larget the report size will be.

---
### Process
Clone the repo onto a system with docker installed,  we run 3 scans in parrallel so the more vcpu the better.
The tar file contains 3 inspec profiles (one for each cloud).  

---
```
admin-cis-aws-benchmark-level2-1.0.0-2.tar.gz  admin-cis-azure-foundations-level2-1.1.0-4.tar.gz  admin-cis-gcp-benchmark-level2-1.0.0-2.tar.gz get_size.sh  README.md
```
First edit the get_size.sh script

```
#!/bin/bash

docker run -it -e CHEF_LICENSE="accept" \
  -e AWS_REGION='<ANY REGION>' \ # just need to specify one, it will scan all
  -e AWS_ACCESS_KEY_ID="<ACCOUNT ACCESS KEY>" \
  -e AWS_SECRET_ACCESS_KEY="<ACCOUNT SECRET ACCESS KEY>" \
  -e AWS_SESSION_TOKEN="<ACCOUNT SESSION TOKEN>" \ # this may not be needed, depends on the account settings (just remove if not needed)
  --rm -v $(pwd):/share chef/inspec exec \
  /share/admin-cis-aws-benchmark-level2-1.0.0-2.tar.gz \
  -t aws:// --reporter=cli json:aws_out.json &

docker run -it -e CHEF_LICENSE="accept" \
  -e AZURE_SUBSCRIPTION_ID="<ACCOUNT SUBSCRIPTION ID>"  \
  -e AZURE_CLIENT_ID="<ACCOUNT CLIENT ID>" \
  -e AZURE_TENANT_ID="<ACCOUNT TENANT ID>" \
  -e AZURE_CLIENT_SECRET="<ACCOUNT CLIENT SECRET>" \
  --rm -v $(pwd):/share chef/inspec exec \
  /share/admin-cis-azure-foundations-level2-1.1.0-4.tar.gz \
  -t azure:// --reporter=cli json:azure_out.json &

docker run -it -e CHEF_LICENSE="accept" \
  -e GOOGLE_APPLICATION_CREDENTIALS="/creds/application_default_credentials.json" \ # change application_default_credentials.json to match your credentials.json (keep the /creds)
  --rm -v $(pwd):/share -v ~/.config/gcloud:/creds chef/inspec exec \ # set the ~/.config/gcloud to the directory containing your credentials.json 
  /share/admin-cis-gcp-benchmark-level2-1.0.0-2.tar.gz \
  -t gcp:// --input gcp_project_id='<PROJECT ID>' --reporter=cli json:gcp_out.json & # fill in your project id
``` 
Replace the values in between the <> with the correct credentials for the large cloud accounts. Note the gcp inspec scan also mounts your `~/.config/gcloud` directory by default.  So that either needs to be created or changed to a location containing the service accont credentials for the large GCP account.

---
Once get_size.sh has been updated execute it `./get_size.sh`. once running it will start 3 docker contianers running inspec in the background and exit the script. when all three contianers have finished running you will have 3 JSON files in the working directory:
```
aws_out.json  azure_out.json  gcp_out.json
```
record the sizes of these files and tar them up to send to Chef.
