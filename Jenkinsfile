pipeline {
    agent any

    // This block tells Jenkins to find and use Maven
    tools {
        maven 'maven3' 
    }

    environment {
        AWS_ACCOUNT_ID = '690824934965'
        AWS_DEFAULT_REGION = 'us-east-1'
        IMAGE_NAME = 'tomcat-hello-world'
        IMAGE_TAG = "${BUILD_NUMBER}"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}"
    }

    stages {
        stage('Build WAR') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${REPOSITORY_URI}:${IMAGE_TAG} ."
                    sh "docker tag ${REPOSITORY_URI}:${IMAGE_TAG} ${REPOSITORY_URI}:latest"
                }
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
    }

    post {
        always {
            // The '|| true' ensures the pipeline doesn't fail if the image wasn't created yet
            sh "docker rmi ${REPOSITORY_URI}:${IMAGE_TAG} || true"
            sh "docker rmi ${REPOSITORY_URI}:latest || true"
            sh "docker system prune -f"
        }
    }
}
