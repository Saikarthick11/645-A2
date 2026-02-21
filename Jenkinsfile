pipeline {
    agent any

    environment {
        // Replace with your actual Docker Hub username
        DOCKERHUB_USER = 'saik11' 
        IMAGE_NAME = 'studentsurvey645'
        IMAGE_TAG = '0.5'
        // Replace with your actual GitHub Repo URL
        GIT_REPO_URL = 'https://github.com/Saikarthick11/645-A2.git'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Pulling source code from GitHub...'
                git "${GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image for AMD64 architecture...'
                    // Added --platform to fix the architecture mismatch issue
                    dockerImage = docker.build("${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}", "--platform linux/amd64 .")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Authenticating and pushing to Docker Hub...'
                    // Ensure you have created 'docker-hub-creds' in Jenkins Credentials
                    docker.withRegistry('[https://index.docker.io/v1/](https://index.docker.io/v1/)', 'docker-hub-creds') {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Update Kubernetes Deployment') {
            steps {
                script {
                    echo 'Applying Kubernetes manifests...'
                    sh """
                    # Update the image placeholder in the manifest if necessary
                    sed -i 's|<YOUR_DOCKERHUB_USER>/simple-webapp:latest|${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml
                    
                    # Apply the deployment and service
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed.'
        }
    }
}