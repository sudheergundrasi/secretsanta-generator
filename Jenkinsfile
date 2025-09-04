pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git 'https://github.com/jaiswaladi246/secretsanta-generator.git'
            }
        }

        stage('Code Compile') {
            steps {
                sh "mvn clean compile"
            }
        }

        stage('Unit Tests') {
            steps {
                sh "mvn test"
            }
        }

        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=Santa \
                        -Dsonar.java.binaries=. \
                        -Dsonar.projectKey=Santa
                    '''
                }
            }
        }

        stage('Code Build') {
            steps {
                sh "mvn clean package"
            }
        }

        stage('Docker Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker build -t santa123 .
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag santa123 gundrasisudheer/santa123:latest
                        docker push gundrasisudheer/santa123:latest
                    '''
                }
            }
        }

        stage('Deploy with Ansible') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            ansiblePlaybook(
                playbook: 'ansible/deploy.yml',
                inventory: 'ansible/inventory.ini',
                extras: "-e docker_user=$DOCKER_USER -e docker_pass=$DOCKER_PASS"
            )
        }
    }
}
