pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo 'Building Image'
        sh '''echo "Git Commit :: ${GIT_COMMIT}"
#docker system prune -a -f
docker build -t moove/webapp:"build-2.$BUILD_NUMBER" -t moove/webapp:latest -t 482532497705.dkr.ecr.ap-south-1.amazonaws.com/webapp:build-2.${BUILD_NUMBER} .'''
        echo '''\n BUILD COMPLETED'''
      }
    }
//     stage('Test Env Setup') {
//       agent any
//       steps {
//         echo 'Populate env for web'
//         sh '''echo "Remove env file before populating values"
//         cp test.env .env
//         cat .env'''
//         echo 'Run Docker '
//         sh '''set +e
// docker stop $(docker ps -aq)
// docker-compose down -v
// sleep 10
// eval $(aws ecr get-login --no-include-email)
// aws s3 cp s3://moove-db-dump/moove-init2.sql .
// docker-compose up -d --force-recreate --build
// sleep 30
// docker-compose exec -T mysql mysql -u root --password=root moove_test < moove-init2.sql
// docker-compose exec -T web bundle exec rake db:migrate
// set -e'''
//         echo '''\n TEST ENV SETUP COMPLETED'''
//       }
//     }
//     stage('RSpec Tests') {
//       steps {
//         echo 'RSpec'
//         sh '''
//             cp test.env .env
//             set +e
//             docker exec -i $(docker ps -q --filter publish=80) bundle exec rake spec | tee -a /tmp/TestAutomationPipeline-RSpec-${BUILD_NUMBER}.txt
//             aws s3 cp /tmp/TestAutomationPipeline-RSpec-${BUILD_NUMBER}.txt s3://moove-infra-assets/auto_test_reports/
//             report_url="https://s3.console.aws.amazon.com/s3/buckets/moove-infra-assets/auto_test_reports/?region=us-east-1&tab=overview&prefixSearch=TestAutomationPipeline-RSpe-${BUILD_NUMBER}"
//             rspec_issue_body="{\\"title\\":\\"${JOB_NAME}-${BUILD_NUMBER}-RSpec Test failures\\", \\"body\\": \\"Report URL: $report_url\\"}"
//             curl --user "shunyeka:hymjug-wimta4-ceFboh" -i -H "Content-Type: application/json" -X POST -d "${rspec_issue_body}" https://api.github.com/repos/Mahindra-Logistics/moove-webapp/issues
//             set -e
//             '''
//         echo '''\n RSPEC TESTS COMPLETED'''
//       }
//     }
//     stage('Cucumber Tests') {
//       steps {
//         echo 'cucumber'
//         sh '''
//             cp test.env .env
//             set +e
//             docker exec -i $(docker ps -q --filter publish=80) bundle exec rake cucumber | tee -a /tmp/TestAutomationPipeline-cucumber-${BUILD_NUMBER}.txt
//             aws s3 cp /tmp/TestAutomationPipeline-cucumber-${BUILD_NUMBER}.txt s3://moove-infra-assets/auto_test_reports/
//             report_url="https://s3.console.aws.amazon.com/s3/buckets/moove-infra-assets/auto_test_reports/?region=us-east-1&tab=overview&prefixSearch=TestAutomationPipeline-cucumber-${BUILD_NUMBER}"
//             rspec_issue_body="{\\"title\\":\\"${JOB_NAME}-${BUILD_NUMBER}-Coverage Test failures\\", \\"body\\": \\"Report URL: $report_url\\"}"
//             curl --user "shunyeka:hymjug-wimta4-ceFboh" -i -H "Content-Type: application/json" -X POST -d "${rspec_issue_body}" https://api.github.com/repos/Mahindra-Logistics/moove-webapp/issues
//             set -e
//             '''
//         echo '''\n CUCUMBER TESTS COMPLETED'''
//       }
//     }
//     stage('Junit/Coverage Tests') {
//       steps {
//         echo 'Junit/Coverage'
//         sh '''
//             set +
//             cp test.env .env
//             set +e
//             docker exec -i $(docker ps -q --filter publish=80) bundle exec rake tests:coverage | tee -a /tmp/TestAutomationPipeline-coverage-${BUILD_NUMBER}.txt
//             aws s3 cp /tmp/TestAutomationPipeline-coverage-${BUILD_NUMBER}.txt s3://moove-infra-assets/auto_test_reports/
//             report_url="https://s3.console.aws.amazon.com/s3/buckets/moove-infra-assets/auto_test_reports/?region=us-east-1&tab=overview&prefixSearch=TestAutomationPipeline-coverage-${BUILD_NUMBER}"
//             rspec_issue_body="{\\"title\\":\\"${JOB_NAME}-${BUILD_NUMBER}-Coverage Test failures\\", \\"body\\": \\"Report URL: $report_url\\"}"
//             curl --user "shunyeka:hymjug-wimta4-ceFboh" -i -H "Content-Type: application/json" -X POST -d "${rspec_issue_body}" https://api.github.com/repos/Mahindra-Logistics/moove-webapp/issues
//             set -e
//             '''
//         echo '''\n JUNIT TESTS COMPLETED'''
//       }
//     }
//     stage('Perf/JMeter Tests') {
//       steps {
//         echo 'Perf/JMeter Test'
//         sh '''
//             cp test.env .env
//             set +e
//             docker exec -i $(docker ps -q --filter publish=80) bundle exec rake tests:performance | tee -a /tmp/TestAutomationPipeline-JMeter-${BUILD_NUMBER}.txt
//             aws s3 cp /tmp/TestAutomationPipeline-JMeter-${BUILD_NUMBER}.txt s3://moove-infra-assets/auto_test_reports/
//             report_url="https://s3.console.aws.amazon.com/s3/buckets/moove-infra-assets/auto_test_reports/?region=us-east-1&tab=overview&prefixSearch=TestAutomationPipeline-JMeter-${BUILD_NUMBER}"
//             rspec_issue_body="{\\"title\\":\\"${JOB_NAME}-${BUILD_NUMBER}-JMeter Test failures\\", \\"body\\": \\"Report URL: $report_url\\"}"
//             curl --user "shunyeka:hymjug-wimta4-ceFboh" -i -H "Content-Type: application/json" -X POST -d "${rspec_issue_body}" https://api.github.com/repos/Mahindra-Logistics/moove-webapp/issues
//             set -e
//             '''
//         echo '''\n PERF/JMeter TESTS COMPLETED'''
//       }
//     }
    stage('Push To ECS') {
      steps {
        // echo "Down the test env"
        // sh 'docker-compose down -v'
        echo 'Push To ECS'
        sh 'docker push 482532497705.dkr.ecr.ap-south-1.amazonaws.com/webapp:build-2.${BUILD_NUMBER}'
        echo '''\n PUSH TO ECS COMPLETED'''
      }
    }
  }
}
