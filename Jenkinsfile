pipeline {
    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git credentialsId: 'github-credentials-id', 
                    url: 'https://github.com/iam-PJ/django-todo.git',
                    branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    echo 'Building Docker Image...'
                    docker build -t prathmeshj476/django-todo:${BUILD_NUMBER} .
                    '''
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', 
                        passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        echo 'Pushing Docker Image...'
                        docker push prathmeshj476/django-todo:${BUILD_NUMBER}
                        '''
                    }
                }
            }
        }
        
        stage('Checkout K8S Manifest Repo') {
            steps {
                git credentialsId: 'github-credentials-id', 
                    url: 'https://github.com/iam-PJ/k8s-manifests.git',
                    branch: 'master'
            }
        }

        stage('Update Kubernetes Manifest & Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-credentials-id', 
                        passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh '''
                        echo "Checking current deploy.yaml..."
                        cat deploy.yaml

                        echo "Updating image version in deploy.yaml..."
                        sed -i "s|image: prathmeshj476/.*|image: prathmeshj476/django-todo:${BUILD_NUMBER}|g" deploy.yaml

                        echo "Verifying changes..."
                        cat deploy.yaml

                        if git diff --quiet; then
                          echo "No changes detected in deploy.yaml. Skipping commit."
                        else
                          git add deploy.yaml
                          git commit -m 'Updated deployment image | Jenkins Pipeline'
                          git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/iam-PJ/k8s-manifests.git HEAD:master
                        fi
                        '''                        
                    }
                }
            }
        }

        stage('Deploy to Kubernetes Cluster') {
            steps {
                script {
                    sshagent(['Key']) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@34.215.175.120 <<EOF
                            echo "Cloning latest Kubernetes manifests..."
                            rm -rf k8s-manifests
                            git clone https://github.com/iam-PJ/k8s-manifests.git

                            echo "Applying Kubernetes deployment..."
                            sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f k8s-manifests/deploy.yaml --validate=false
                            sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f k8s-manifests/service.yaml --validate=false

                            echo "Deployment completed!"
EOF
                        '''
                    }
                }
            }
        }
    }
}

