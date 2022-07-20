#! /usr/bin/env groovy

pipeline {
  agent any

  environment {
    COMPOSE_PROJECT_NAME = "${env.JOB_NAME}-${env.BUILD_ID}".replaceAll("/", "-").replaceAll(" ", "").toLowerCase()
    COMPOSE_FILE = "docker-compose.yml"
    RAILS_ENV = "test"
    DOCKER_REF = "${(env.GERRIT_EVENT_TYPE == 'change-merged') ? env.GERRIT_BRANCH : env.GERRIT_REFSPEC}"
    DOCKER_TAG = env.DOCKER_REF.replace("refs/changes/", "").replaceAll("/", ".")
  }

  stages {
    stage('Start') {
      steps {
        sh 'echo "send start message to slack"'
      }
    }
    stage('Build') {
      steps {
        sh 'docker-compose build --pull'
        sh 'docker-compose up -d db'
      }
    }
    stage('dependencies') {
      steps {
        sh 'docker-compose run web bundle install'
      }
    }
    stage('Prepare') {
      steps {
        sh 'docker-compose run --rm -T web bundle exec rake db:setup'
      }
    }
    stage('DB') {
      steps {
        sh 'docker-compose run --rm -T web bundle exec rake db:drop db:create db:migrate'
      }
    }
    stage('Rspec') {
      steps {
        sh 'docker-compose run --rm -T --name=$COMPOSE_PROJECT_NAME-rspec web bundle exec rake spec'
      }
    }
    stage('Test') {
      parallel {
        stage('Database Dependent Suites') {
          stages {
            stage('RSpec') {
              steps {
                sh 'docker-compose run --rm -T --name=$COMPOSE_PROJECT_NAME-rspec web bundle exec rake spec'
              }
            }
            stage('Cucumber') {
              steps {
                sh 'docker-compose run --rm -T --name=$COMPOSE_PROJECT_NAME-cucumber web bash bin/cucumber'
              }
            }
          }
        }
        stage('Jasmine') {
          steps {
            sh 'docker-compose run --rm -T --name=$COMPOSE_PROJECT_NAME-jasmine web bundle exec rake spec:javascript'
          }
        }
        stage('Brakeman') {
          steps {
            sh 'docker-compose run --rm -T --name=$COMPOSE_PROJECT_NAME-brakeman web bundle exec brakeman'
          }
        }
        stage('Synk') {
          when { environment name: "GERRIT_EVENT_TYPE", value: "change-merged"}
          steps {
            withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_TOKEN')]) {
              sh 'docker pull snyk/snyk-cli:rubygems'
              sh 'docker run --rm -v "$(pwd):/project" -e SNYK_TOKEN snyk/snyk-cli:rubygems monitor --project-name=rollcall-attendance:ruby'
            }
          }
        }
        stage('Docker Image') {
          steps {
            sh 'docker build -t $DOCKER_REGISTRY_FQDN/jenkins/rollcall:$DOCKER_TAG .'
            sh 'docker push $DOCKER_REGISTRY_FQDN/jenkins/rollcall:$DOCKER_TAG'
          }
        }
      }
    }
  }

  post {
    cleanup {
      sh 'docker-compose down --remove-orphans --rmi all'
      
      deleteDir()
      }
  }
}
