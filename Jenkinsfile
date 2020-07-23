def name = 'UNKNOWN'
def version = 'UNKNOWN'
def project = 'UNKNOWN'
def docker_registry = 'UNKNOWN'

pipeline {
    // agent  any 
    agent { 
        docker { 
            //image 'python:3.7.5' 
            image 'harbor-01.newtech.com.ar/newcos-automation/newcos-jenkins-agent:1.0.0'
            registryUrl 'https://harbor-01.newtech.com.ar/'
            registryCredentialsId '3'
        } 
    }
    stages {
        stage('Setting environment') { 
            steps {
                echo "Running build ${env.BUILD_ID} on ${env.JENKINS_URL}"
                echo "Installing building requirements..."
                sh 'ls'
                // sh 'apt update --fix-missing'
                // sh 'apt install sshpass -y'
                // sh 'apt install ansible -y'
                // sh 'pip install pymsteams'
                script{
                    name = sh(returnStdout: true, script: 'cd utilities && python environment.py NAME')
                    version = sh(returnStdout: true, script: 'cd utilities && python environment.py VERSION')
                    project = sh(returnStdout: true, script: 'cd utilities && python environment.py PROJECT')
                    docker_registry = sh(returnStdout: true, script: 'cd utilities && python environment.py DOCKER_REGISTRY')
                    image = docker_registry+'/'+project+'/'+name+':'+version+'-dev'.trim()
                }

                echo "name: ${name}"
                echo "version: ${version}"
                echo "project: ${project}"
                echo "docker registry: ${docker_registry}"
                echo "image: ${image}"
            }
        }
        stage('Build') { 
            steps {
                echo "Building docker image for build ${image}"
                sh "docker build -t ${image} ."
            }
        }
        stage('Authenticate with Harbor') { 
            steps {
                echo "Docker registry ${docker_registry} authentication..."
                sh "docker login ${docker_registry} -u newcos -p Newcosnet_2020"
            }
        }
        stage('Push Harbor') { 
            steps {
                echo "pushing docker image ${image} to harbor repository..."
                sh "docker push ${image}"
            }
        }
        stage('Cleanup') { 
            steps {
                echo 'Cleaning dangling and stale docker images..'
                sh '''
                docker rmi $(docker images -f 'dangling=true' -q) || true
                docker rmi $(docker images | sed 1,2d | awk '{print $3}') || true
                '''
            }
        }
        stage('Deploy') { 
            steps {
                echo 'Deploy service within docker swarm dev cluster...'
                // setting env var docker compose
                sh "export DEPLOY_IMAGE=${image} && cd utilities/deploy && ansible-playbook -i inventory dispatcher.yml"
            }
        }
        stage('Mail notification') { 
            steps {
                echo 'Sending mail notification...'
                mail bcc: '', body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}", cc: '', from: '', replyTo: '', subject: "Jenkins project ${name} version ${version} Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}", to: 'dev@newtech.com.ar'           
            }
        }
        stage('MS Teams Channel notification') { 
            steps {
                echo 'Sending MS Teams DEVOPS channel notification...'
                script{
                    message = "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} - More info at: ${env.BUILD_URL}"
                    sh(returnStdout: true, script: "cd utilities && python message.py '${message}'")
                }
            }
        }
    }
    
    post {
        always {
            echo 'This will always run'
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
            echo 'Sending MS Teams DEVOPS channel notification...'
            script{
                message = "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} - More info at: ${env.BUILD_URL}"
                sh(returnStdout: true, script: "cd utilities && python message.py '${message}'")
            }
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}