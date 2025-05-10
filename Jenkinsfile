pipeline {
    agent any

    environment {
        SSH_CREDS = credentials('ssh-to-access-the-private-ec2')
        EC2_PRIVATE_IP = "${env.EC2_PRIVATE_IP}"
        BASTION_HOST_IP = "${env.BASTION_HOST_IP}"
        APP_NAME = "${env.APP_NAME}"
        GIT_REPO = "${env.GIT_REPO}"
        CONTAINER_PORT = '3000'
        HOST_PORT = '3000'
        VERSION_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                cleanWs()
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Deploy to EC2 Through Bastion Host') {
            steps {
                script {
                    sshagent(['ssh-to-access-the-private-ec2']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no -J ubuntu@${BASTION_HOST_IP} ubuntu@${EC2_PRIVATE_IP} \\
                                'mkdir -p /home/ubuntu/deployments/${APP_NAME}'

                            scp -o StrictHostKeyChecking=no -o ProxyJump=ubuntu@${BASTION_HOST_IP} \\
                                -r ./* ubuntu@${EC2_PRIVATE_IP}:/home/ubuntu/deployments/${APP_NAME}/

                            ssh -o StrictHostKeyChecking=no -J ubuntu@${BASTION_HOST_IP} ubuntu@${EC2_PRIVATE_IP} << EOF
                                cd /home/ubuntu/deployments/${APP_NAME}

                                docker build -t ${APP_NAME}:${VERSION_TAG} .

                                docker stop ${APP_NAME} || true
                                docker rm ${APP_NAME} || true

                                docker run -d --name ${APP_NAME} \\
                                    -p ${HOST_PORT}:${CONTAINER_PORT} \\
                                    --restart unless-stopped \\
                                    ${APP_NAME}:${VERSION_TAG}

                                docker image prune -a --filter "until=24h" --force || true
                            EOF
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sshagent(['ssh-to-access-the-private-ec2']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no -J ubuntu@${BASTION_HOST_IP} ubuntu@${EC2_PRIVATE_IP} << EOF
                                if docker ps | grep -q ${APP_NAME}; then
                                    echo "Container ${APP_NAME} is running successfully"
                                    exit 0
                                else
                                    echo "Container ${APP_NAME} is not running"
                                    exit 1
                                fi
                            EOF
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'App deployed successfully!'
        }
        failure {
            echo 'Deployment failed.'
        }
        always {
            echo "Cleaning up workspace"
        }
    }
}
