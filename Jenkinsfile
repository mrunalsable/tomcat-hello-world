pipeline {
    agent any

    tools {
        maven 'maven3'
    }

    environment {
        AWS_ACCOUNT_ID = '690824934965'
        AWS_DEFAULT_REGION = 'us-east-1'
        IMAGE_REPO_NAME = 'tomcat-hello-world'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        TOMCAT_IP = '44.222.76.184' 
    }

    stages {
        stage('Build WAR') {
            steps {
                // 'clean' ensures old code is deleted before building fresh
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${REPOSITORY_URI}:${IMAGE_TAG} ."
                sh "docker tag ${REPOSITORY_URI}:${IMAGE_TAG} ${REPOSITORY_URI}:latest"
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker push ${REPOSITORY_URI}:latest"
                }
            }
        }

        stage('Deploy to Tomcat EC2') {
            steps {
                sshagent(['tomcat-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ec2-user@${TOMCAT_IP} "
                            # Login to ECR
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

                            # Stop and remove old container
                            docker stop my-tomcat-app || true
                            docker rm my-tomcat-app || true

                            # Force pull the SPECIFIC build version to bypass cache issues
                            docker pull ${REPOSITORY_URI}:${IMAGE_TAG}

                            # Run the new container using the new tag
                            docker run -d -p 8081:8080 --name my-tomcat-app ${REPOSITORY_URI}:${IMAGE_TAG}
                        "
                    """
                }
            }
        }
    }

    post {
        always {
            // Cleanup local images on the Jenkins server to save disk space
            sh "docker rmi ${REPOSITORY_URI}:${IMAGE_TAG} || true"
            sh "docker rmi ${REPOSITORY_URI}:latest || true"
            sh "docker system prune -f || true"
        }
    }
}
