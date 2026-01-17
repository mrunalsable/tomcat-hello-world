pipeline {
    agent any  // Runs on Jenkins master (your EC2)

    environment {
        ECR_REPO = '690824934965.dkr.ecr.us-east-1.amazonaws.com/tomcat-hello-world'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/mrunalsable/tomcat-hello-world.git'
            }
        }

        stage('Build WAR') {
            steps {
                sh 'mvn clean package'
            }
        }
	stage('Build Docker Image') {
            steps {
                // Use single quotes for the command if you don't want Groovy to interpolate, 
                // OR use clean double quotes like this:
                sh "docker build -t ${REPOSITORY_URI}:${IMAGE_TAG} ."
                sh "docker tag ${REPOSITORY_URI}:${IMAGE_TAG} ${REPOSITORY_URI}:latest"
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    // Authenticate Docker to ECR
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    
                    // Push the specific build number tag
                    sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
                    
                    // Push the latest tag
                    sh "docker push ${REPOSITORY_URI}:latest"
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout 690824934965.dkr.ecr.us-east-1.amazonaws.com || true'
        }
    }
}
