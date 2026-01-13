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
                sh "docker build -t $$   {ECR_REPO}:   $${IMAGE_TAG} ."
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-push']]) {
                    sh '''
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 690824934965.dkr.ecr.us-east-1.amazonaws.com
                    docker push $$   {ECR_REPO}:   $${IMAGE_TAG}
                    '''
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
