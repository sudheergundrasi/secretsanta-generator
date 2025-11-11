// pipeline {
//     agent any

//     environment {
//         AWS_REGION = 'us-east-1'                 // Replace with your EKS cluster region
//         EKS_CLUSTER_NAME = 'terraform-eks'     // Replace with your cluster name
//     }

//     stages {
//         stage('Cloning the Code') {
//             steps {
//                 git 'https://github.com/sudheergundrasi/secretsanta-generator.git'
//             }
//         }

//         stage('Code Compile') {
//             steps {
//                 sh 'mvn clean compile'
//             }
//         }

//         stage('Unit Tests') {
//             steps {
//                 sh 'mvn test'
//             }
//         }

//         stage('Code Quality Analysis') {
//             steps {
//                 sh '''
//                     mvn clean verify sonar:sonar \
//                     -Dsonar.projectKey=poc-sonar \
//                     -Dsonar.host.url=http://54.166.212.99:9000 \
//                     -Dsonar.login=sqp_a38d7e312fe4fa95094a857c0bcd893b1e98ff08
//                 '''
//             }
//         }

//         stage('Build the Code') {
//             steps {
//                 sh 'mvn package'
//             }
//         }

//         stage('Build the Docker Image') {
//             steps {
//                 sh 'docker build -t secretsanta123 .'
//             }
//         }

//         stage('Trivy Scan Docker Image') {
//             steps {
//                 sh '''
//                     docker run --rm \
//                         -v /var/run/docker.sock:/var/run/docker.sock \
//                         aquasec/trivy:latest image \
//                         --exit-code 0 --severity LOW,MEDIUM,HIGH,CRITICAL secretsanta123
//                 '''
//             }
//         }

//         stage('Push the Image to DockerHub') {
//             steps {
//                 script {
//                     withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
//                         sh '''
//                             echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
//                             docker tag secretsanta123 gundrasisudheer/secretsanta123:latest
//                             docker push gundrasisudheer/secretsanta123:latest
//                         '''
//                     }
//                 }
//             }
//         }

//         stage('Configure Kubeconfig for EKS') {
//             steps {
//                 withKubeConfig([credentialsId: 'jenkins-kubeconfig']) {
//                     sh 'kubectl get nodes'
//                     sh 'kubectl apply -f deploymentsvc.yaml'
//                 }
//             }
//         }
//     }
// }
// ----------------------------------------------------------------------------------------------
    pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://34.229.163.9:9000'
        SONAR_TOKEN   = credentials('sonar-cred')
    }

    stages {
        stage('Clone the Code') {
            steps {
                git 'https://github.com/sudheergundrasi/secretsanta-generator.git'
            }
        }

        stage('Build the Code') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh """
                    mvn verify sonar:sonar \
                        -Dsonar.projectKey=poc \
                        -Dsonar.host.url=${SONARQUBE_URL} \
                        -Dsonar.login=${SONAR_TOKEN}
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t secretsanta .'
            }
        }

        stage('Trivy Scan Docker Image') {
            steps {
                sh """
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest image \
                        --exit-code 0 \
                        --severity HIGH,CRITICAL \
                        secretsanta
                """
            }
        }

        stage('Push the Image to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-cred',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker tag secretsanta gundrasisudheer/secretsanta:latest
                            docker push gundrasisudheer/secretsanta:latest
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    export KUBECONFIG=/var/lib/jenkins/.kube/config
                    kubectl get nodes   # quick test
                    kubectl apply -f deploymentsvc.yaml
                '''
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build succeeded! \nCheck console: ${env.BUILD_URL}",
                to: "gundrasisudheer@gmail.com"
            )
        }
        failure {
            emailext(
                subject: "❌ FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build failed! \nCheck console: ${env.BUILD_URL}",
                to: "gundrasisudheer@gmail.com"
            )
        }
    }
}
