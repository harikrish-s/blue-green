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
                    sh "docker-compose up -d --build ${env.TARGET_ENV}"
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    // Wait for container to be ready
                    sleep 10
                    
                    def port = env.TARGET_ENV == 'blue' ? '8081' : '8082'
                    
                    // Perform health check
                    def status = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:${port}/health.html", returnStdout: true).trim()
                    
                    if (status != '200') {
                        error "Health check failed with status ${status}"
                    }
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
    
    post {
        failure {
            script {
                echo "Deployment failed, rolling back..."
                sh "docker-compose stop ${env.TARGET_ENV}"
            }
        }
    }
}