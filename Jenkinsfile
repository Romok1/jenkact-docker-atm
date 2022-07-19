pipeline {
    // agent { dockerfile true
	agent any
    stages {
        stage('build') {
             when {
                   branch 'wolox-for-multibranch' 
                 }
            steps {
                sh 'echo "yes"'
            }
        }
	 stage("run script") {
	     when {
                   branch 'wolox-for-multibranch' 
                 }
            steps {
		script {
		sh '''#/bin/bash -l
		     cd tmp
		     ls
		    chmod +x testscriptdock.sh
                    ./testscriptdock.sh 
		    '''
		}	    
            }
        }
	 stage("remove images") {
	     when {
                   branch 'wolox-for-multibranch' 
                 }
            steps {
		script {
		sh '''#/bin/bash -l
		     cd tmp
		     ls
		    chmod +x testscriptdockRM.sh
                    ./testscriptdockRM.sh 
		    '''
		}	    
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

