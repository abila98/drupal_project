pipeline { 
    environment { 
        registry = "abila98/mydrupal" 
        registryCredential = 'mydockercreds' 
        dockerImage = '' 
    }
    agent any 
    stages { 
          stage('Cloning Deploy Repo') { 
            steps { 

                checkout([
        $class: 'GitSCM', 
        branches: [[name: '*/main']], 
        doGenerateSubmoduleConfigurations: false,
        submoduleCfg: [], 
        userRemoteConfigs: [[credentialsId: 'mygitcreds', url: 'https://github.com/abila98/drupal_project.git']]
    ])
            
            }
        }
        stage('Building our image') { 
            steps { 
                script { 
                    dockerImage = docker.build registry + ":$BUILD_NUMBER" 
                }
            } 
        }
        stage('Deploy our image') { 
            steps { 
                script { 
                    docker.withRegistry( '', registryCredential ) { 
                        dockerImage.push() 
                    }
                } 
            }
        } 
        stage('Cleaning up') { 
            steps { 
                sh "docker rmi $registry:$BUILD_NUMBER" 
            }
        } 
           
    }
}
