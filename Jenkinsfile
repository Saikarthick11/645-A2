pipeline {
    agent any

    environment {
        // Your Docker Hub username
        DOCKERHUB_USER = 'saik11' 
        IMAGE_NAME = 'studentsurvey645'
        
        /* IMAGE LOGIC: Using build ID ensures a unique tag for every run. */
        IMAGE_TAG = "${env.BUILD_ID}"
        
        GIT_REPO_URL = 'https://github.com/Saikarthick11/645-A2.git'
        BRANCH_NAME = 'sai' 
        
        // Reference to the Credentials IDs stored in Jenkins
        DOCKER_CREDS_ID = 'docker-hub-creds'
        // This is the ID of the 'Secret File' credential you created in Jenkins
        KUBECONFIG_ID = 'kubeconfig-id'
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
                    
                    /* FIXED: Using standard withCredentials instead of withKubeConfig.
                       This injects the Kubeconfig file path into the KUBECONFIG variable,
                       which kubectl uses automatically for authentication.
                    */
                    withCredentials([file(credentialsId: "${KUBECONFIG_ID}", variable: 'KUBECONFIG')]) {
                        sh """
                        # Update the manifest with the new image tag
                        sed -i 's|image:.*|image: ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' deployment.yaml
                        
                        # Apply changes using the injected KUBECONFIG environment variable
                        kubectl apply --kubeconfig=\$KUBECONFIG -f deployment.yaml --validate=false
                        kubectl apply --kubeconfig=\$KUBECONFIG -f service.yaml --validate=false
                        
                        # Force a rolling update
                        kubectl rollout restart --kubeconfig=\$KUBECONFIG deployment/studentsurvey-deployment
                        """
                    }
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