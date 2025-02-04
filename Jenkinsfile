pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'prathmeshj476'
        IMAGE_NAME = 'new-django-todo'  // Image Name
        IMAGE_TAG = 'latest'
        REMOTE_SERVER = 'ubuntu@18.223.188.173'  // Server Cred.
        CONTAINER_NAME = 'django'  // container Name
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checkout stage'
                checkout changelog: false, poll: false, 
                scm: scmGit(branches: [[name: '*/main']], 
                            extensions: [], 
                            userRemoteConfigs: [[url: 'https://github.com/iam-PJ/django-todo.git']])
            }
        }

        stage('Build') {
            steps {
                echo 'Build Stage'
                sh "docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo 'Pushing Image to DockerHub'
                withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', 
                                                  usernameVariable: 'DOCKER_USER', 
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push "$DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG"
                    '''
                }
            }
        }

        stage('Deploy on Remote Server') {
            steps {
                echo 'Deploying Docker container on remote server'
                sshagent(['Key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no $REMOTE_SERVER << EOF
                        docker pull $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true
                        docker run -d --name $CONTAINER_NAME -p 80:8000 $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                        exit
                    EOF
                    """
                }
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning up local Docker images'
                sh "docker rmi $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG || true"
            }
        }
    }

    post {
        always {
            echo 'Logging out from Docker Hub'
            sh "docker logout"
        }
    }
}
