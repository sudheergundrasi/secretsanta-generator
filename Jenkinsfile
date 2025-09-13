pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'                 // Replace with your EKS cluster region
        EKS_CLUSTER_NAME = 'terraform-eks'     // Replace with your cluster name
    }

    stages {
        stage('Cloning the Code') {
            steps {
                git 'https://github.com/sudheergundrasi/secretsanta-generator.git'
            }
        }

        stage('Code Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Code Quality Analysis') {
            steps {
                sh '''
                    mvn clean verify sonar:sonar \
                    -Dsonar.projectKey=poc-sonar \
                    -Dsonar.host.url=http://54.166.212.99:9000 \
                    -Dsonar.login=sqp_a38d7e312fe4fa95094a857c0bcd893b1e98ff08
                '''
            }
        }

        stage('Build the Code') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Build the Docker Image') {
            steps {
                sh 'docker build -t secretsanta123 .'
            }
        }

        stage('Trivy Scan Docker Image') {
            steps {
                sh '''
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest image \
                        --exit-code 0 --severity LOW,MEDIUM,HIGH,CRITICAL secretsanta123
                '''
            }
        }

        stage('Push the Image to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker tag secretsanta123 gundrasisudheer/secretsanta123:latest
                            docker push gundrasisudheer/secretsanta123:latest
                        '''
                    }
                }
            }
        }

        stage('Configure Kubeconfig for EKS') {
            steps {
                withKubeConfig([credentialsId: 'jenkins-kubeconfig']) {
                    sh 'kubectl get nodes'
                    sh 'kubectl apply -f deploymentsvc.yaml'
                }
            }
        }
    }
}
