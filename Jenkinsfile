pipeline {
	agent {
        label 'linux'
    }
    options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    durabilityHint('PERFORMANCE_OPTIMIZED')
    disableConcurrentBuilds()
   }
    environment {
	git_credential = "github-login1"
        aws_credential = "AWS-CRED-JENKINS-MYUSER"
        git_tool_name = "default"
        bucket = "jenkins.myuser"
        region = "eu-west-2"
	    S3_PATH = "jenkinscicd"
	    S3_PATHE = "testfolder/"
	    api_res_url = "https://${bucket}.${region}.amazonaws.com/${bucket}/${S3_PATH}"
        auth_res_url = "https://${bucket}.s3.${region}.amazonaws.com/${bucket}/${S3_PATH}"
        notify_t = "image upload to s3 bucket, in path ${S3_PATH}"
    }
    triggers {
        pollSCM 'H/5 * * * *'
    }
    stages {
        stage('Create NEW SCM workspace') {
		when {
                   branch 'feature/*' 
                 }
           steps {
		  dir('/home/dockuser/workspace') {
	      sh 'mkdir scmfolder'
		     }
           }
        }
	    stage('Create clone workspace') {
		  when {
                   branch 'develop' 
                 }
           steps {
		  dir('/home/dockuser/workspace') {
	      sh 'mkdir clonefolder'
		     }
           }
        }
        stage('Manual Checkout SCM in NEW workspace') {
		  when {
                   branch 'feature/*' 
                 }
           steps {
		    dir('/home/dockuser/workspace/scmfolder') {
	        checkout scm
	         getGitCommit()
		     sh "echo Branch Name: $BRANCH_NAME"
		     sh 'echo "$BRANCH_NAME branch checked out into scmfolder"'
		    }
           }
        }
	    stage ('Start') {
               steps {
                slackSend (color: '#FFFF00', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
	           }
        }
	        
	    stage('Dependencies') {
                 when {
                     anyOf { branch 'feature/*'; branch 'develop' }
                 }
                steps {
                    script {
	    		CI_ERROR = "Failed: Dependencies"
	    		CI_OK = "Success: Dependencies"
                sh '''#!/bin/bash -l
                rvm list
                rvm use $(cat .ruby-version) --install
	    	     '''
                   }
                }
            }
	    stage('Build') {
              when {
                     anyOf { branch 'feature/*'; branch 'develop' }
            }
            steps {
                script {
			    CI_ERROR = "Failed: Build App"
			    CI_OK = "Success: Build App"
                    sh '''#!/bin/bash -l
		    bundle install
                         '''
               }
            }
        }
        stage('DB test') {
              when {
                   branch 'feature/dev' 
                 }
            steps {
                script {
			    CI_ERROR = "Failed: DB Test"
			    CI_OK = "Success: DB Test"
                           sh '''#!/bin/bash -l
		        RAILS_ENV=test bundle exec rake db:create
			    ls 
		        RAILS_ENV=test bundle exec rake db:migrate && rails db:test:prepare --trace
			    echo "go here"
                bundle exec rake test
                         '''
               }
            }
            post {
                  success {
	    	      slackSend color : "good", message: "Success - DB Test", channel: '#cicd'
                      }
	          failure{
                      slackSend color : "danger", message: "Failed - DB Test", channel: '#cicd'
                      }
                 }
        }
	    stage ('Test') {
	    	 when {
                   branch 'feature/*' 
                 }
	     steps {
	    	script {
	    		CI_ERROR = "Failed: Rspec Test"
	    		CI_OK = "Success: Rspec Test"
                        sh '''#!/bin/bash -l                
	    	        echo "bundle exec rspec --format RspecJunitFormatter --out rspec.xml"
                             ''' 
	               }
	     }
             post {
                  success {
	    	         slackSend color : "good", message: "rspec test was SUCCESSFUL", channel: '#cicd'
                        }
	          failure{
                        slackSend color : "danger", message: "rspec test FAILED", channel: '#cicd'
                    }
                 }
             }
        stage("Upload"){
          steps{
	       script {
		        echo 'Uploading content with AWS creds'
		        sh 'ls -lrth'
		        sh "echo $WORKSPACE"
		        sh 'pwd'
		        sh 'echo "to simulate gettig our rspec xml file" > rspec.xml'
		        def xml_files = findFiles(glob: "**/*.xml")
                        xml_files.each {
		        echo "XML found: ${it}"
                     withAWS(region:"${region}", credentials:"${aws_credential}"){
                      s3Upload(file:"${it}", pathStyleAccessEnabled: true, bucket:"${bucket}", path:"${S3_PATHE}")
                  }    
		        }
               }
	         }
          post {
                  success{
                      slackSend color : "good", message: "${notify_t}", channel: '#cicd'
                  }
                  failure{
                      slackSend color : "danger", message: "${notify_t}", channel: '#cicd'
                  }
              }
          }  
	    	 
	    stage('Pull Request') {
	        when {
                   branch 'feature/*' 
                 }
            steps {
              script {
		      datetime = new Date().format("yyyy-MM-dd HH:mm:ss");
		      CI_ERROR = "Failed: Pull Request"
		      CI_OK = "Success: Pull Request"
		      dir('/home/dockuser/workspace/scmfolder') {
                withCredentials([gitUsernamePassword(credentialsId: "${git_credential}", gitToolName: "${git_tool_name}")]) {
                // Get some code from a GitHub repository
                sh ("""
                  git checkout HEAD
	              git status
	              git branch
                  git branch -a
	              ls
	              echo "${env.WORKSPACE}"
	              git checkout develop  
                  git diff develop origin/develop > gitdiff.xml 
		          ls -lrth
                  echo "pulled the code"				 
                   """)
		} }
               }
             }
	        post {
                  success {
                    script {
			  dir('/home/dockuser/workspace/scmfolder') {
		          sh 'echo "Uploading git diff"'
		          def txt_files = findFiles(glob: "**/*.xml")
                          txt_files.each {
		          echo "XML found: ${it}"
                         withAWS(region:"${region}", credentials:"${aws_credential}"){
                          s3Upload(file:"${it}", pathStyleAccessEnabled: true, bucket:"${bucket}", path:"${S3_PATH}")
			 }   } 
		        sh 'rm gitdiff.xml'
	              }
                    }
	          }
                  failure {
                   echo "Pull Request failed"
               }
            }
         }
	    
	    stage('Push to Develop') {
	        when {
                   branch 'feature/*' 
                 }
               steps {
                 script {
		      CI_ERROR = "Failed: Push to Develop"
		      CI_OK = "Success: Push to Develop"
		      dir('/home/dockuser/workspace/scmfolder') {
                withCredentials([gitUsernamePassword(credentialsId: "${git_credential}", gitToolName: "${git_tool_name}")]) {
                sh ("""
                 git pull origin $BRANCH_NAME
	              git status
	              git branch
		      git diff develop origin/develop
                git branch -a
		      echo Branch Name: $BRANCH_NAME
	              ls -lrth
	              echo "${env.WORKSPACE}"
                git push
                  echo "pushed the code"
                   """)
	             }
               }
             } 
           }
	}
        stage('Pre-deploy') {
              when {
                expression {
                  currentBuild.result == null || currentBuild.result == 'SUCCESS' 
                }
              }
              steps {
                  echo "Proceed to deploy to staging"
              }
         }
	    
	 
	    
        stage('Deploy to Staging') {
              when {
                  branch 'develop'
                }
              steps {
		 script {
		   CI_ERROR = "Failed: Deploy to Staging"
		   CI_OK = "Success: Deploy to Staging"
	          dir('/home/dockuser/workspace/scmfolder') {
			  checkout scm
                  sh '''#!/bin/bash -l
		  
		  git branch 
		  echo "11"
		  ls
		  git branch -a
		  echo "22"
		  git checkout develop
		  echo "33"
		  ls -lrth
                   bundle exec cap staging deploy         
          	     ''' }
                  }
	      }
	      post {
                  success{
                      slackSend color : "good", message: "Deploy to staging environment successful", channel: '#cicd'
                  }
                  failure{
                      slackSend color : "danger", message: "Failed to deploy to staging environment, check the logs and confirm error", channel: '#cicd'
                  }
              }
          }
       stage('Final') {
              when {
                expression {
                  currentBuild.result == null || currentBuild.result == 'SUCCESS' 
                }
              }
              steps {
		  script {
		   CI_ERROR = "Failed: THIS FAILED AT ONE OF THE STAGES"
		   CI_OK = "Success: ALL STAGES PASSED"
                  echo "Pipeline finished and was successful"
		  } }
         }
      
    }
    post {
        always {
	        script {
		      CONSOLE_LOG = "${env.BUILD_URL}/console"
	              BUILD_STATUS = currentBuild.currentResult
		      if (currentBuild.currentResult == 'SUCCESS') { CI_ERROR = "NA" }
	               }
		        sendSlackNotifcation()
	    
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
		           dir("/home/dockuser/workspace/scmfolder") {
                    deleteDir()
                    }
		           dir("/home/dockuser/workspace/scmfolder@tmp") {
                    deleteDir()
                   }
		           dir("/home/dockuser/workspace/clonefolder") {
                    deleteDir()
                   }
	          }
	   
        }
}



def sendSlackNotifcation() 
{ 
	if ( currentBuild.currentResult == "SUCCESS" ) {
		buildSummary = "Job:  ${env.JOB_NAME}\n Status: *SUCCESS*\n Description: *${CI_OK}* \n"

		slackSend color : "good", message: "${buildSummary}", channel: '#cicd'
		}
	else {
		buildSummary = "Job:  ${env.JOB_NAME}\n Status: *FAILURE*\n Error description: *${CI_ERROR}* \n"
		slackSend color : "danger", message: "${buildSummary}", channel: '#cicd'
		}
}



def getGitCommit() {
    git_commit = sh (
        script: 'git rev-parse HEAD',
        returnStdout: true
    ).trim()
    return git_commit
}
