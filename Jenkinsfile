pipeline {
    agent {
        kubernetes {
            // Définition du Pod avec les ressources nécessaires
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
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Install & Test') {
            steps {
                container('python') {
                    // On augmente le timeout et on ajoute des retries pour éviter le "Read timeout"
                    sh 'pip install --default-timeout=100 --retries 5 -r requirements.txt'
                    sh 'python test.py'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    // Construction de l'image. 
                    // Note: 'flask-app' doit correspondre au nom utilisé dans votre deployment.yaml
                    sh 'docker build -t flask-app:latest .'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    // Application des fichiers de configuration Kubernetes
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'
                    
                    // Optionnel : Forcer le redémarrage pour prendre en compte la nouvelle image
                    sh 'kubectl rollout restart deployment flask-deployment || echo "Premier déploiement"'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès ! L\'application est déployée.'
        }
        failure {
            echo 'Le pipeline a échoué. Vérifiez les erreurs ci-dessus.'
        }
    }
}
