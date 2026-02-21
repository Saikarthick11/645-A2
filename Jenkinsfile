pipeline {
    agent any

    environment {
        // Your Docker Hub username
        DOCKERHUB_USER = 'saik11' 
        IMAGE_NAME = 'studentsurvey645'
        
        /* IMAGE LOGIC: Using build ID ensures a unique tag for every run.
           This triggers Kubernetes to pull the new version because the 
           image name/tag combination changes every time.
        */
        IMAGE_TAG = "${env.BUILD_ID}"
        
        GIT_REPO_URL = 'https://github.com/Saikarthick11/645-A2.git'
        BRANCH_NAME = 'sai' 
        
        // Reference to the Credentials ID stored in Jenkins
        DOCKER_CREDS_ID = 'docker-hub-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Pulling source code from branch: ${BRANCH_NAME}..."
                    checkout([$class: 'GitSCM', 
                        branches: [[name: "*/${BRANCH_NAME}"]], 
                        userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]
                    ])
                }
            }
        }

        stage('Build & Push') {
            steps {
                script {
                    echo "Building version: ${IMAGE_TAG}"
                    
                    // Build directly from the source (Dockerfile handles packaging)
                    sh "docker build --platform linux/amd64 -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                    
                    // Secure Login and Push using Jenkins Docker DSL
                    // This handles special characters in passwords and avoids shell interpolation issues
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDS_ID}") {
                        sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying version ${IMAGE_TAG} to Rancher..."
                    /* IMAGE LOGIC: The sed command specifically finds the 'image:' key 
                       and replaces the entire line to match the new dynamic tag.
                    */
                    sh """
                    sed -i 's|image:.*|image: ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' deployment.yaml
                    kubectl apply -f deployment.yaml --validate=false
                    kubectl apply -f service.yaml --validate=false
                    
                    # Force Kubernetes to recognize the change and pull the new image
                    kubectl rollout restart deployment/studentsurvey-deployment
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo "Successfully deployed version ${IMAGE_TAG}"
        }
    }
}