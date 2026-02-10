pipeline {
    agent {
        kubernetes {
            // Définition du Pod avec 4 conteneurs (jnlp, python, docker, kubectl)
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

    triggers {
        // Vérification automatique toutes les 2 minutes
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Install & Test') {
            steps {
                container('python') {
                    sh 'pip install -r requirements.txt'
                    // Exécution des tests unitaires
                    sh 'python test.py'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    // Construction de l'image locale
                    sh 'docker build -t flask-app:latest .'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    // Application des manifestes YAML sur le cluster local
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'
                }
            }
        }
    }

    post {
        success {
            echo 'Félicitations ! Build, Test et Déploiement réussis.'
        }
        failure {
            echo 'Le pipeline a échoué. Vérifiez les logs des conteneurs.'
        }
    }
}
