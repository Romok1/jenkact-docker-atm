pipeline {
    // agent { dockerfile true
	agent {
	dockerfile {
	   filename 'Dockerfile'
        additionalBuildArgs  '--build-arg version=1.0.2'
        args '-u root:root'
	  }
	}
    stages {
        stage('build') {
             when {
                   branch 'wolox-for-multibranch' 
                 }
            steps {
                sh 'ruby --version'
                sh 'ls'
                sh 'printenv'
            }
        }
	 stage("run script") {
	     when {
                   branch 'wolox-for-multibranch' 
                 }
            steps {
		script {
		sh '''#/bin/bash -l
		    chmod +x /tmp/testscriptdock.sh
                    ./tmp/testscriptdock.sh 
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
		    chmod +x /tmp/testscriptdockRM.sh
                    ./tmp/testscriptdockRM.sh 
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

