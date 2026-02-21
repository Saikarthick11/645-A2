pipeline {
    agent any

    environment {
        // Replace with your actual Docker Hub username
        DOCKERHUB_USER = 'saik11' 
        IMAGE_NAME = 'studentsurvey645'
        IMAGE_TAG = "${env.BUILD_ID}"
        // Replace with your actual GitHub Repo URL
        GIT_REPO_URL = 'https://github.com/Saikarthick11/645-A2.git'
        // Try changing this to 'master' if the build fails again with 'main'
        BRANCH_NAME = 'sai' 
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Pulling source code from ${GIT_REPO_URL} (branch: ${BRANCH_NAME})..."
                    try {
                        checkout([$class: 'GitSCM', 
                            branches: [[name: "*/${BRANCH_NAME}"]], 
                            doGenerateSubmoduleConfigurations: false, 
                            extensions: [], 
                            submoduleCfg: [], 
                            userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]
                        ])
                    } catch (Exception e) {
                        echo "Failed to find branch '${BRANCH_NAME}'. Trying fallback to 'master'..."
                        checkout([$class: 'GitSCM', 
                            branches: [[name: "*/master"]], 
                            doGenerateSubmoduleConfigurations: false, 
                            extensions: [], 
                            submoduleCfg: [], 
                            userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]
                        ])
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Verifying workspace contents before build...'
                    sh "ls -la"
                    
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
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-creds') {
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
                    # Ensure directories exist
                    mkdir -p k8s
                    
                    # Update the image placeholder in the manifest if necessary
                    # We use '|| true' to prevent script failure if the file doesn't exist yet
                    if [ -f k8s/deployment.yaml ]; then
                        sed -i 's|<YOUR_DOCKERHUB_USER>/studentsurvey645:0.4|${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' deployment.yaml
                        kubectl apply -f deployment.yaml
                    fi
                    
                    if [ -f k8s/service.yaml ]; then
                        kubectl apply -f service.yaml
                    fi
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