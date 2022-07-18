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
           sh 'bundle install'
          }
        }
    }

    post {
        always {
	        script {
		      sh 'docker rmi -f $(docker images -aq)'
	               }
   
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

