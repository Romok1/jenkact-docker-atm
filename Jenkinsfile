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
		sh 'cd db && pwd && ls'
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

