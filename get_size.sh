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
