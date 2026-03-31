pipeline {
    agent any
   
    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'koventhan/trend'
        DOCKER_IMAGE_NAME = '<Your-IMG-NAME>'
        KUBECONFIG = "/var/lib/jenkins/.kube/config" //locate in jenkins EC2 serevr
    }
    environment {
        // Replace with your Docker Hub username and repo name
        DOCKERHUB_REGISTRY = 'docker.io'
        IMAGE_NAME = 'koventhan/trend'
        TAG = "latest"
        IMAGE_URI = "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:${TAG}"
        // Replace with your Jenkins Docker Hub credentials ID
        DOCKERHUB_CREDENTIALS_ID = 'Dockerregistry'
    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/your-org/your-repo.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${TAG} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID,
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin ${DOCKERHUB_REGISTRY}
                    docker push ${IMAGE_NAME}:${TAG}
                    """
                }
            }
        

        stage('Deploy to EKS') {
            steps {
                script {
                    // Update the deployment manifest with the new image URI
                    sh "sed -i 's|your_image_placeholder|${IMAGE_NAME}:${TAG}|g' deployment.yaml"
                    // Apply changes to EKS cluster
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }
}