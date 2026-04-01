pipeline {
    agent any
    environment {
        // Replace with your Docker Hub username and repo name
        DOCKERHUB_REGISTRY = 'docker.io'
        IMAGE_NAME = 'koventhan/trend'
        TAG = "latest"
        IMAGE_URI = "${DOCKERHUB_REGISTRY}/${IMAGE_NAME}:${TAG}"
        // Replace with your Jenkins Docker Hub credentials ID
        DOCKERHUB_CREDENTIALS_ID = 'Dockerregistry'
      }
    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Koventhan28/Trend.git', branch: 'master'
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
        
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    withAWS(credentials: 'AWS-Credentials')
                    sh "aws sts get-caller-identity"
                    sh 'aws eks update-kubeconfig --name mycluster --region us-east-1'
                    // Update the deployment manifest with the new image URI
                    // sh "sed -i 's|your_image_placeholder|${IMAGE_NAME}:${TAG}|g' deployment.yaml"
                    // Apply changes to EKS cluster
                    sh "kubectl apply -f deployment.yaml"
                    sh "kubectl apply -f service.yaml"
                }
            }
        }
    }
}
