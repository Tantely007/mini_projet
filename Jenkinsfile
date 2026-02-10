pipeline {
    agent {
        kubernetes {
            // Définition du Pod qui va exécuter le build
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
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }

    triggers {
        // Vérifie les changements sur GitHub toutes les 2 minutes
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Install & Test') {
            steps {
                container('python') {
                    sh 'pip install -r requirements.txt'
                    // On lance les tests (assurez-vous que test.py existe)
                    sh 'python test.py'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    // Construction de l'image (le nom doit correspondre à votre déploiement K8s)
                    sh 'docker build -t flask-app:latest .'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    // Déploiement dans le cluster local
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'
                }
            }
        }
    }

    post {
        success {
            echo 'Application déployée avec succès sur Kubernetes !'
        }
        failure {
            echo 'Le pipeline a échoué. Vérifiez les logs.'
        }
    }
}
