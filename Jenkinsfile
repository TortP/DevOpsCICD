pipeline {
  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:3273.v4cfe589b_fd83-1
      args: ['$(JENKINS_SECRET)', '$(JENKINS_NAME)']
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2-debug
      command: ['/busybox/cat']
      tty: true
      volumeMounts:
        - name: kaniko-docker-config
          mountPath: /kaniko/.docker
          readOnly: true
    - name: git
      image: alpine/git:2.45.2
      command: ['cat']
      tty: true
  volumes:
    - name: kaniko-docker-config
      secret:
        secretName: kaniko-secret
'''
    }
  }

  parameters {
    string(name: 'AWS_ACCOUNT_ID', defaultValue: '', description: 'AWS account ID for the ECR registry')
  }

  options {
    disableConcurrentBuilds()
    timestamps()
  }

  environment {
    AWS_REGION = 'us-west-2'
    ECR_REPOSITORY_NAME = 'woolf-goit-app-ecr-usw2'
    GITOPS_REPOSITORY = 'github.com/TortP/DevOpsCICD.git'
    GITOPS_BRANCH = 'final-project'
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
          if (!params.AWS_ACCOUNT_ID?.trim()) {
            error('AWS_ACCOUNT_ID parameter is required')
          }

          env.ECR_REPOSITORY = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPOSITORY_NAME}"

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

sed -i -E "s|(^[[:space:]]*repository:[[:space:]]*\").*(\"[[:space:]]*)$|\\1${ECR_REPOSITORY}\\2|" "${HELM_VALUES_PATH}"
sed -i -E "s|(^[[:space:]]*tag:[[:space:]]*\").*(\"[[:space:]]*)$|\\1${IMAGE_TAG}\\2|" "${HELM_VALUES_PATH}"

git config user.email "jenkins@local"
git config user.name "jenkins-ci"

git add "${HELM_VALUES_PATH}"
if git diff --cached --quiet; then
  echo "No changes in Helm values file"
  exit 0
fi

git commit -m "ci: update django image tag to ${IMAGE_TAG} [skip ci]"
git push origin "HEAD:${GITOPS_BRANCH}"
'''
          }
        }
      }
    }
  }
}
