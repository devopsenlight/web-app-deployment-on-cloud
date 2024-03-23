aws s3api create-bucket --bucket backendchartrakshit
helm s3 init --force s3://backendchartrakshit/backend-foldername
sleep 5
helm package .
helm repo add backendchartrakshit s3://backendchartrakshit/backend-foldername
helm s3 push --force backend-0.1.0.tgz backendchartrakshit
