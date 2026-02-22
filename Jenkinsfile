pipeline {
    agent any

    environment {
 
        DOCKERHUB_USER = 'saik11' 
        IMAGE_NAME = 'studentsurvey645'
        IMAGE_TAG = "${env.BUILD_ID}"
        GIT_REPO_URL = 'https://github.com/Saikarthick11/645-A2.git'
        BRANCH_NAME = 'sai' 
        DOCKER_CREDS_ID = 'docker-hub-creds'
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
                    
                    sh "docker build --platform linux/amd64 -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
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
                    
                    withCredentials([file(credentialsId: "${KUBECONFIG_ID}", variable: 'KUBECONFIG')]) {
                        sh """
                        # Update the manifest with the new image tag
                        sed -i 's|image:.*|image: ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}|g' deployment.yaml
                        
                        # FIXED: Using 'replace --force' to resolve the 'Conflict/Object modified' error.
                        # This replaces the cluster state with your local manifest.
                        kubectl replace --kubeconfig=\$KUBECONFIG --force -f deployment.yaml
                        
                        # Ensure service is up to date
                        kubectl apply --kubeconfig=\$KUBECONFIG -f service.yaml --validate=false
                        
                        # Verify the rollout
                        kubectl rollout status --kubeconfig=\$KUBECONFIG deployment/swe-645-a2-cluster
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