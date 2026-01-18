pipeline {
    agent any
    
    // This tells Jenkins to use the Maven version you named 'maven3' 
    // in Manage Jenkins -> Tools
    tools {
        maven 'maven3'
    }

    environment {
        AWS_ACCOUNT_ID = '690824934965'
        AWS_DEFAULT_REGION = 'us-east-1'
        IMAGE_REPO_NAME = 'tomcat-hello-world'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }

    stages {
        stage('Build WAR') {
            steps {
                // Now 'mvn' will be recognized
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Builds image using the Dockerfile in your repo
                    sh "docker build -t ${REPOSITORY_URI}:${IMAGE_TAG} ."
                    sh "docker tag ${REPOSITORY_URI}:${IMAGE_TAG} ${REPOSITORY_URI}:latest"
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    // Logs into AWS ECR and pushes both the build number and 'latest' tags
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker push ${REPOSITORY_URI}:latest"
                }
            }
        }
    }
    
    post {
        always {
            // Cleans up images locally on the Jenkins EC2 to save disk space
            sh "docker rmi ${REPOSITORY_URI}:${IMAGE_TAG} || true"
            sh "docker rmi ${REPOSITORY_URI}:latest || true"
            // Deletes unused Docker data to prevent that "Disk Full" error again
            sh "docker system prune -f || true"
        }
    }
}
