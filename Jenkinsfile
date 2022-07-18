pipeline {
    agent { dockerfile true }
    stages {
        stage('build') {
             when {
                   branch 'dockerjt' 
                 }
            steps {
                sh 'ruby --version'
                sh 'ls'
                sh 'printenv'
            }
        }
        stage('Clone Sources') {
           when {
                   branch 'dockerjt' 
                 }
         steps {
           sh 'printenv'
           sh 'echo "bundle install"'
          }
        }
	stage('Build') {
	      when {
                   branch 'dockerjt' 
                 }
            steps {
                sh 'ls -lrth'
		    withEnv(['POSTGRES_USERNAME=postgres', 'POSTGRES_PASSWPRD=postgres']) {
			    sh 'pwd && ls && ls -al && bundle install && bundle exec rake db:create' }
            }
        }
	 stage('DB-aux') {
		 environment {
         POSTGRES_HOST = 'localhost'
        POSTGRES_USER = 'myuser'
          }

           steps {
            script {
		    echo 'Testing..'
		    sh 'pwd'
            docker.image('postgres:9.6').withRun(
                "-h ${env.POSTGRES_HOST} -e POSTGRES_USER=${env.POSTGRES_USER}"
            ) { db ->
                  // You can your image here but you need psql to be installed inside
                docker.image('ruby').inside("--link ${db.id}:db") {
                  sh '''
                  psql --version
                  until psql -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
                  echo "Waiting for postgres server, $((RETRIES-=1)) remaining attempts..."
                  sleep 1
                       done
                    '''
                  sh 'echo "your commands here"'
                }
              }
            }
           }
	 }	    
	stage('DB') {
            steps {
                echo 'Testing..'
		    sh 'pwd'
                withEnv(['POSTGRES_USERNAME=postgres', 'POSTGRES_PASSWPRD=postgres']) {
                sh 'bundle install && ls && bundle exec rake db:migrate db:create'}
            }
        }
    }

    post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '**/*',  type: 'INCLUDE'], [pattern: '~/workspace/scmfolder', type: 'INCLUDE'],
 		    [pattern: '.propsfile', type: 'EXCLUDE']]) 
	           
		
	        deleteDir()
                   dir("${env.WORKSPACE}@tmp") {
                       deleteDir()
                                }
	
	          }
	   
        }
}

