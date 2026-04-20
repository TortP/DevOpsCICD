pipeline {
  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:3273.v4cfe589b_fd83-1
      args: ['$(JENKINS_SECRET)', '$(JENKINS_NAME)']
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2-debug
      command: ['/busybox/cat']
      tty: true
    - name: git
      image: alpine/git:2.45.2
      command: ['cat']
      tty: true
'''
    }
  }

  options {
    disableConcurrentBuilds()
    timestamps()
  }

  environment {
    AWS_REGION = 'us-west-2'
    ECR_REPOSITORY = '<AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/woolf-goit-app-ecr-usw2'
    GITOPS_REPOSITORY = 'github.com/YOUR_GITHUB_USERNAME/lesson-8-9.git'
    GITOPS_BRANCH = 'main'
    HELM_VALUES_PATH = 'charts/django-app/values.yaml'
  }

  stages {
    stage('Checkout source') {
      steps {
        checkout scm
      }
    }

    stage('Prepare image tag') {
      steps {
        script {
          def shortSha = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
          env.IMAGE_TAG = "${env.BUILD_NUMBER}-${shortSha}"
          echo "IMAGE_TAG=${env.IMAGE_TAG}"
        }
      }
    }

    stage('Build and push image to ECR') {
      steps {
        container('kaniko') {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
            sh '''#!/busybox/sh
set -e
/kaniko/executor \
  --context "${WORKSPACE}" \
  --dockerfile "${WORKSPACE}/Dockerfile" \
  --destination "${ECR_REPOSITORY}:${IMAGE_TAG}" \
  --destination "${ECR_REPOSITORY}:latest"
'''
          }
        }
      }
    }

    stage('Update Helm values and push to main') {
      steps {
        container('git') {
          withCredentials([string(credentialsId: 'git-token', variable: 'GIT_TOKEN')]) {
            sh '''#!/bin/sh
set -e
rm -rf gitops-repo

git clone "https://oauth2:${GIT_TOKEN}@${GITOPS_REPOSITORY}" gitops-repo
cd gitops-repo

git checkout "${GITOPS_BRANCH}"

sed -i -E "s|(^[[:space:]]*tag:[[:space:]]*\").*(\"[[:space:]]*)$|\\1${IMAGE_TAG}\\2|" "${HELM_VALUES_PATH}"

git config user.email "jenkins@local"
git config user.name "jenkins-ci"

git add "${HELM_VALUES_PATH}"
if git diff --cached --quiet; then
  echo "No changes in Helm values file"
  exit 0
fi

git commit -m "ci: update django image tag to ${IMAGE_TAG}"
git push origin "HEAD:${GITOPS_BRANCH}"
'''
          }
        }
      }
    }
  }
}
