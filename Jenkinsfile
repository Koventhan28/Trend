pipeline {
    agent any
   
    environment {
        AWS_REGION = '<REGION-CODE>'
        ECR_REPO = 'koventhan/trend'
        DOCKER_IMAGE_NAME = '<Your-IMG-NAME>'
        KUBECONFIG = "/var/lib/jenkins/.kube/config" //locate in jenkins EC2 serevr
    }
    stages {
        stage('Build Image') {
            steps {
                script {
                    // Build the image from a Dockerfile in your source repo
                    def customImage = docker.build("${ECR_REPO}:${env.BUILD_NUMBER}")
                }
            }
        }
        stage('Push Image') {
            steps {
                // Push the image to Docker Hub, using stored credentials in Jenkins
                docker.withRegistry('https://registry.hub.docker.com', 'Dockerregistry') {
                    customImage.push()
                    customImage.push("latest")
                }
            }
        }
    }
}
/*
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    docker.build("$DOCKER_IMAGE_NAME:${env.GIT_COMMIT}")
                }
            }
        }
       
        stage('Tag Docker Image') {
            steps {
                script {
                    // Tag Docker image using Docker command directly
                    sh "docker tag $DOCKER_IMAGE_NAME:${env.GIT_COMMIT} $ECR_REPO:${env.GIT_COMMIT}"
                }
            }
        }
*/

        stage('Deploy to EKS') {
            steps {
                script {
                    // Set KUBECONFIG environment variable
                    withEnv(["KUBECONFIG=${KUBECONFIG}"]) {
                        // Get the latest image tag from the GIT_COMMIT environment variable
                        def imageTag = env.BUILD_NUMBER
                        
                        // Replace the placeholder ${IMAGE_TAG} in deployment.yaml with the actual image tag
                        //sh "sed -i 's|\${IMAGE_TAG}|${imageTag}|' deployment.yaml"
                        
                        // Apply deployment.yaml to the EKS cluster
                        sh "kubectl apply -f deployment.yaml"
                        sh "kubectl apply -f service.yaml"
                    }
                }
            }
        }
    }
}