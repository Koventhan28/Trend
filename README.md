# This is the  Repository link for downloading the repo: https://github.com/Koventhan28/Trend.git
Once you clone the Repository move to the directory and use the below commands commands 
Note: The application files are already built so no need to again build using npm commands.
If you want to locally build the docker images you can use the just use the below command 
```
docker build -t <image-name>:<version> .
```
Once the images is build you can check the images details using the 
```
docker images <image-name>
```
You can use the below command to run the docker locally
```
docker run -p 80:3000 -d <image-name>
```
Can access the site in the localhost using 
```
http:\\localhost:3000
```
For the infrastrucute to work,you can use the below link to install terraform 
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
we have a main.tf file for Deploying the Infrastructure i.e Deploying jenkins in an EC2 Instance.
Below are the set of command for initialing,planning and deploying the jenkins infrastruture.
```
terraform init
```
Using the below command for checking if the configuration is working 
```
terraform plan 
```
We are using auto-approve since instead of manually approving the configuration
```
terraform apply -auto-approve
```
Once the Jenkins is up and running on the AWS cloud .for the first time you need to get the credentials from the below file path 
```
/var/lib/jenkins/secrets/initialAdminPassword
```
Login to Jenkins and create the admin user and credentials.
For adding the Docker hub credentails which is used for building the pushing the container to dockerhub
```
Manage Jenkins-> Credentials -> Add-Credentials -> Username and password
```
Similarly for adding the AWS credentials you need to have aws-credentials plugin installed
```
Manage Jenkins-> Credentials -> Add-Credentials -> AWS Credential
```
Creating the EKS cluster from the local machine using below command 
```
eksctl create cluster   --name mycluster   --region us-east-1   --nodes 1   --node-type t2.medium   --nodes-min 1   --nodes-max 
```
You can use the below command to get the cluster is its created and the kubectl command to check if the instance is up
```
eksctl get cluster
kubectl get nodes
```
Once the Trend Application jenkins-pipeline is created
add the github project detail and the github hook trigger with the Pipeline with SCM option for building the Jenkinspipeline

For Linking the github webhook with jenkins
```
Go Github Repo -> Settings->Webhooks-> Add-Weebhook
```
Add the jenkins website link with /github-webhook/ at the end and once its added it will show for succesful for a push request.
Once git push happens the pipeline automatically starts and Pipeline runs for building,Pushing and the Deploying the application to EKS

# Monitoring

Make sure you install the helm on the servers before you proceed on installing the prometheus and grafana
```
helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create namespace prometheus
kubectl get ns
helm install stable prometheus-community/kube-prometheus-stack -n prometheus
kubectl get pods -n prometheus
kubectl get svc -n prometheus
kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
Modify the type of the kubenetes service from ClusterIp to LoadBalancer
kubectl get svc -n prometheus
kubectl edit svc stable-grafana -n prometheus
Modify the type of the kubenetes service from ClusterIp to LoadBalancer
kubectl get svc -n prometheus
```

The below command is for getting the credentail for the fist time login on the server and the login username for the grafana will be admin
```
kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```