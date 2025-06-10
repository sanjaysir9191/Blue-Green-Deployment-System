# FILE: Jenkinsfile
# ==============================================
pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/my-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh 'docker build -t my-app:${IMAGE_TAG} .'
                }
            }
        }
        
        stage('Test') {
            steps {
                sh './scripts/health-check.sh'
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}
                        docker tag my-app:${IMAGE_TAG} ${ECR_REPOSITORY}:${IMAGE_TAG}
                        docker push ${ECR_REPOSITORY}:${IMAGE_TAG}
                    '''
                }
            }
        }
        
        stage('Deploy to Green') {
            steps {
                sh './scripts/deploy.sh green ${IMAGE_TAG}'
                sh './scripts/health-check.sh green'
            }
        }
        
        stage('Switch Traffic') {
            when {
                expression { params.SWITCH_TRAFFIC == true }
            }
            steps {
                sh './scripts/switch-traffic.sh green'
            }
        }
    }
    
    post {
        failure {
            sh './scripts/rollback.sh blue'
        }
    }
}
