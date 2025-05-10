pipeline {
    agent any

    environment {
        // Use credentials binding for secure handling of secrets. The SSH private key will be added to the Jenkins credentials proactivly.
        SSH_CREDS = credentials('ssh-to-access-the-private-ec2')
        // Reference the global environment variables directly
        EC2_PRIVATE_IP = "${env.EC2_PRIVATE_IP}"
        BASTION_HOST_IP = "${env.BASTION_HOST_IP}"
        APP_NAME = "${env.APP_NAME}"
        GIT_REPO = "${env.GIT_REPO}"
        // Set default values for container port and host port
        CONTAINER_PORT = '3000'
        HOST_PORT = '3000'
        // Use Jenkins build number for versioning
        VERSION_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clean workspace before cloning
                cleanWs()
                // Clone the repository containing the app code
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Copy Files to Bastion Host') {
            steps {
                script {
                    // Create a deployment directory on the bastion host
                    sshagent(['ssh-to-access-the-private-ec2']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@${BASTION_HOST_IP} "mkdir -p /home/ubuntu/deployments/${APP_NAME}"
                        """
                    }
                    
                    // Copy the application files to the Bastion host
                    sshagent(['ssh-to-access-the-private-ec2']) {
                        sh """
                            scp -o StrictHostKeyChecking=no -r ./* ubuntu@${BASTION_HOST_IP}:/home/ubuntu/deployments/${APP_NAME}/
                        """
                    }
                }
            }
        }

        stage('Deploy to EC2 Through Bastion Host') {
            steps {
                script {
                    // SSH into the Bastion host, and from there SSH into the private EC2 instance
                    sshagent(['ssh-to-access-the-private-ec2']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@${BASTION_HOST_IP} "
                                ssh -o StrictHostKeyChecking=no ubuntu@${EC2_PRIVATE_IP} 'mkdir -p /home/ubuntu/deployments/${APP_NAME}'
                                
                                scp -o StrictHostKeyChecking=no -r /home/ubuntu/deployments/${APP_NAME}/* ubuntu@${EC2_PRIVATE_IP}:/home/ubuntu/deployments/${APP_NAME}/
                                
                                ssh -o StrictHostKeyChecking=no ubuntu@${EC2_PRIVATE_IP} '
                                    cd /home/ubuntu/deployments/${APP_NAME}
                                    
                                    docker build -t ${APP_NAME}:${VERSION_TAG} .
                                    
                                    docker stop ${APP_NAME} || true
                                    docker rm ${APP_NAME} || true
                                    
                                    docker run -d --name ${APP_NAME} \\
                                        -p ${HOST_PORT}:${CONTAINER_PORT} \\
                                        --restart unless-stopped \\
                                        ${APP_NAME}:${VERSION_TAG}
                                    
                                    docker image prune -a --filter "until=24h" --force || true
                                '
                            "
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    // Verify the container is running on the private EC2
                    sshagent(['ssh-to-access-the-private-ec2']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@${BASTION_HOST_IP} "
                                ssh -o StrictHostKeyChecking=no ubuntu@${EC2_PRIVATE_IP} '
                                    # Check if container is running
                                    if docker ps | grep -q ${APP_NAME}; then
                                        echo "Container ${APP_NAME} is running successfully"
                                        exit 0
                                    else
                                        echo "Container ${APP_NAME} is not running"
                                        exit 1
                                    fi
                                '
                            "
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'App deployed successfully!'
            // Add notification logic here if needed (e.g., Slack)
        }
        failure {
            echo 'Deployment failed.'
            // Add notification logic here if needed (e.g., Slack)
        }
        always {
            // Perform any needed cleanup
            echo "Cleaning up workspace"
        }
    }
}