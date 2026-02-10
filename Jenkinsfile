pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: python
    image: python:3.7-slim
    command: ['cat']
    tty: true
  - name: docker
    image: docker:latest
    command: ['cat']
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  - name: kubectl
    image: lachlanevenson/k8s-kubectl:v1.17.2
    command: ['cat']
    tty: true
  - name: jnlp
    image: jenkins/inbound-agent:alpine
    env:
    - name: JENKINS_URL
      value: "http://host.docker.internal:9090/"
    - name: JENKINS_TUNNEL
      value: "host.docker.internal:50000"
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }

    stages {
        stage('Install & Test') {
            steps {
                container('python') {
                    sh 'pip install --default-timeout=100 --retries 5 -r requirements.txt'
                    sh 'python test.py'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh 'docker build -t flask-app:latest .'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    // Vérifie la présence des fichiers dans le workspace
                    sh 'ls -la' 
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'
                    sh 'kubectl rollout restart deployment flask-deployment || echo "Nouveau déploiement"'
                }
            }
        }
    }

    post {
        success {
            echo 'Application déployée avec succès !'
        }
        failure {
            echo 'Le pipeline a échoué. Vérifiez si les fichiers .yaml sont à la racine du dépôt.'
        }
    }
}
