#!groovy

def message = "";
def author = "";

def getLastCommitMessage = {
    message = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
}

def getGitAuthor = {
    def commit = sh(returnStdout: true, script: 'git rev-parse HEAD')
    author = sh(returnStdout: true, script: "git --no-pager show -s --format='%an' ${commit}").trim()
}

pipeline {
    agent any
    options {
        timeout(time: 1, unit: 'DAYS')
        disableConcurrentBuilds()
    }
    stages {
        stage("Init RoR and DB") {
          agent any
          steps { initialize() }
        }
        stage("Tests") {
          agent any
          steps { test() }
          post {
            success {
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '/var/jenkins_home/workspace/VPX-open-source/coverage/', reportFiles: 'index.html', reportName: 'RspecCoverage', reportTitles: ''])
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '/var/jenkins_home/workspace/VPX-open-source/coverage/lcov-report', reportFiles: 'index.html', reportName: 'JestCoverage', reportTitles: ''])
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '/var/jenkins_home/workspace/VPX-open-source/reports/', reportFiles: 'eslint.html', reportName: 'Eslint', reportTitles: ''])
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '/var/jenkins_home/workspace/VPX-open-source/reports/', reportFiles: 'rubocop.html', reportName: 'Rubocop', reportTitles: ''])
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '/var/jenkins_home/workspace/VPX-open-source/reports/rubycritic/', reportFiles: 'overview.html', reportName: 'Rubycritic', reportTitles: ''])
            }
          }
        }
    }
    post {
      failure {
        script {
          getLastCommitMessage()
          getGitAuthor()
        }
        rocketSend channel: 'myproject-ci', emoji: ':x:', message: "Build failed - Commit : '${message}' by ${author}", rawMessage: true
      }
   }
}

def initialize() {
    sh 'docker-compose -f docker-compose.yml up --build --detach'
}

def test() {
  try {

    retry(3){
        sleep 25
        HEALTH = sh (
          script: 'docker inspect -f \'{{json .State.Health.Status}}\' vpx-web-test',
          returnStdout: true
        ).trim()
        echo "${HEALTH}"

        if(HEALTH == "starting"){
          return true
        }
    }

    sh 'docker exec vpx-web-test sh -c "cd app/ && RAILS_ENV=test bundle exec rspec -f documentation"'
    sh 'docker exec vpx-web-test sh -c "cd app/ && yarn test"'

    sh 'docker exec vpx-web-test sh -c "cd app/ && yarn test --coverage > reports/jest-coverage.html"'
    sh 'docker exec vpx-web-test sh -c "cd app/ && yarn lint --f html reports/eslint.html ; exit 0"'
    sh 'docker exec vpx-web-test sh -c "cd app/ && rubycritic app/ --no-browser -p reports/rubycritic"'
    sh 'docker exec vpx-web-test sh -c "cd app/ && rubocop app/ --format html -o reports/rubocop.html --fail-level error"'
  }
  catch (exc) {
    error("Build failed")
  }
  finally{
    sh 'docker-compose -f docker-compose.yml down'
  }
}
