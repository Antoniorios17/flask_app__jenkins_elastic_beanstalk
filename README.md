# KuraLabs

Deployment 3
Build, test and deploy  a flask application on AWS Elastic Beanstalk.
Automated pipeline with Jenkins

## Table of contents

1. Install jenkins
2. Pre-requisites
3. Create A Pipeline Build On Jenkins
4. Install AWS CLI
5. Install Elastic Beanstalk CLI
6. Jenkins CI/CD Pipeline
7. 
8. 
9. System Design

## Install Jenkins

* Open the AWS website
* Get to the AWS console
* Type in the search bar EC2
* Select the following options:
  * OS: Ubuntu 22.04
  * Instance type : t2.micro
  * Security groups: enable ports
    * 8080 (Jenkins)
    * 22 (ssh)
  * Storage 8 Gib gp2
  * Advance details:
    * Use the automatic script installation for jenkins [here](https://github.com/Antoniorios17/flask_app_jenkins_elastic_beanstalk/blob/main/scripts/jenkins-installer.sh)

## Pre-requisites

Before we start the working on jenkins we need to run the following commands:

* Install python virtual environment

  ```bash
  sudo apt install python3.10-venv -y
  ```

* Install pip | python package manager

  ```bash
  sudo apt install python3-pip -y
  ```

* Install unzip

  ```bash
  sudo apt install unzip
  ```

## Create a pipeline build on Jenkins

* Create a new item
  * Select multibranch pipeline
* Add source: Github
* Create a new personal access token on github
  * Log in to github
  * Access the setting
  * Select developer settings
  * Select Token (Classic)
  * Generate new token
  * Check the boxes for repo, admin:org and admin:repo_hook
* Add github credentials
  * Add github username
  * Add repository link
  * Add personal access token as password
  * Validate connection to the repository
  * Apply and save configuration

## Install AWS CLI

Follow these steps:

* Log in to the aws console
* Look for IAM service
* Click on users
  * Under Security Credentials click on create access keys
  * The Use case is Command Line Interface (CLI)
  * Name your description Tag Value
  * Select Create Access Key
  * You will be shown your Access Key and Secret Access Key
  * Make sure to store the values in a safe place you will not be able to see them again.
* Access the EC2 running Jenkins through SSH
* Run the following commands to install AWS CLI:

    ```bash
    # Download the files
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    
    # Unzip the zip file
    unzip awscliv2.zip
    
    # Run the installation file
    sudo ./aws/install

    # Check the installation was successfull
    aws --version
    ```

* Configure the AWS credentials

    ```bash
    # Run this command
    aws configure

    # Insert Access key
    # Insert Secret Access key

    # Region us-east-1

    # Default Output format: json
    ```

## Install Elastic Beanstalk CLI

* Connect to the EC2 instace running Jenkins
* Create a password for the Jenkins User
* Log it as the Jenkins user
  
  ```bash
  sudo su jenkins
  ```

* Install Elastic Beanstalk CLI
  
  ```bash
  pip install awsebcli --upgrade --user

  # Run this command
  export PATH=$PATH:$HOME/.local/bin
  ```
* 



















  

## Jenkins CI/CD Pipeline

Once the credentials are complete Jenkins will start the pipeline

* Pull repository from github
  * Clone the repository onto the EC2 instance
  * Look for a Jenkinfile inside the repository
  * This is the Jenkinsfile for this project

    ```jenkinsfile
        pipeline {
    agent any
    environment {
        PACKAGE_VERSION = "1.0.0.${BUILD_NUMBER}"
        ZIP_SOURCE_DIR = "${WORKSPACE}"
        ZIP_OUTFILE = "${WORKSPACE}/build/${PACKAGE_VERSION}.zip"
    }
    stages {
        stage ('Build') {
            steps {
                sh '''#!/bin/bash
                sudo apt install python3.10-venv -y
                python3 -m venv test3
                source test3/bin/activate
                pip install pip --upgrade
                pip install -r requirements.txt
                export FLASK_APP=application
                '''
            }
        }
        stage ('Test') {
            steps {
                sh '''#!/bin/bash
                source test3/bin/activate
                py.test --verbose --junit-xml test-reports/results.xml
                '''
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }
        stage ('Packaging the output files') {
            steps {
                 input(message: 'Proceed to the next step?', ok: 'Continue')
                zip dir: env.ZIP_SOURCE_DIR, exclude: '', glob: '', zipFile: env.ZIP_OUTFILE, overwrite: true
            }
        }
    }

}
    ```

* Stages declared in the pipeline
  * Build
    * Install all the dependencies of the Flask application
    * Create a virtual environment
  * Test
    * Run pytest to test functionality of the application
  * Packaging the output files
    * Manually authorize to take all the application files and zip it.
  * Deploy
    * deploy to elastic beanstalk
    * 
* Successful execution of all stages can be seen in the Jenkins GUI

  
![jenkins-stages](https://github.com/Antoniorios17/flask-app-jenkins-deployment/blob/main/images/d2-jenkins-stages.png)

deployed to elastic beanstalk

![elastic-beanstalk](https://github.com/Antoniorios17/flask-app-jenkins-deployment/blob/main/images/d2-eb-ok-health.png)

1.  The Flask app is now deployed on Elastic Beanstalk. Access it using the provided Domain Name.

![url-shortenet-webpage](https://github.com/Antoniorios17/flask-app-jenkins-deployment/blob/main/images/d2-app-website.png)

## Troubleshooting

* Issues to troubleshoot
  * The pipeline doesn't run after connecting to the repository
    * Solutions:
      * Installing the plugin "Pipeline Utility Steps"
      * Important step! restart the controller after installing new plugins
  * Build stage fails
    * The build failed becuase it was missing python virtual environment
      * Solutions:
        * run the command on the terminal:

          ```
          sudo apt install python3.10-venv -y
          ```

        * This will install the virtual environment library to run the build stage

* Important information
  * When using the jenkins installation script it will take a few minutes to run completely when added to userdata

## System Design

Jenkins Pipeline

![system-design-pipeline](https://github.com/Antoniorios17/flask-app-jenkins-deployment/blob/main/images/d2-jenkins-pipeline.png)

Elastic Beanstalk Diagram

![system-design-eb](https://github.com/Antoniorios17/flask-app-jenkins-deployment/blob/main/images/d2-jenkins-eb-diagram.png)
