aws s3api create-bucket --bucket frontendchartrakshit
helm s3 init --force s3://frontendchartrakshit/frontend-foldername
sleep 5
helm package .
helm repo add frontendchartrakshit s3://frontendchartrakshit/frontend-foldername
helm s3 push --force frontend-0.1.0.tgz frontendchartrakshit
