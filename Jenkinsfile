pipeline {
    agent any
    
    environment {
        DEPLOY_TIME = sh(script: 'date "+%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()
    }
    
    stages {
        stage('Determine Active Environment') {
            steps {
                script {
                    // Read nginx.conf to determine current active environment
                    def nginxConf = readFile('nginx.conf')
                    env.CURRENT_ENV = nginxConf.contains('proxy_pass http://blue') ? 'blue' : 'green'
                    env.TARGET_ENV = env.CURRENT_ENV == 'blue' ? 'green' : 'blue'
                    echo "Current environment is ${env.CURRENT_ENV}, deploying to ${env.TARGET_ENV}"
                }
            }
        }
        
        stage('Deploy New Version') {
            steps {
                script {
                    // Deploy to target environment
                    sh "docker-compose down"
                    
                    // Ensure network exists
                    sh "docker network create deploy-net || true"
                    
                    sh "docker-compose up -d --build ${env.TARGET_ENV}"
                    // Wait a few seconds for container to start
                    sleep 5
                }
            }
        }
        
        stage('Switch Traffic') {
            steps {
                script {
                    // Update nginx config
                    sh """
                        sed -i 's/proxy_pass http:\\/\\/${env.CURRENT_ENV}/proxy_pass http:\\/\\/${env.TARGET_ENV}/g' nginx.conf
                        docker-compose exec -T nginx nginx -s reload
                    """
                    echo "Traffic switched to ${env.TARGET_ENV}"
                }
            }
        }
    }
}
