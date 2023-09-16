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
7. Troubleshooting
8. System Design
9. Additions

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

* Change your working directory to the workspace of Jenkins

  ```bash
  cd /var/lib/jenkins/workspace/
  ```

* Once inside the workspace directory and your branch directory
  
  ```bash
  # Initialize Elastic Beanstalk
  eb init
  
  # Create the elastic Beanstalk environment
  eb create
  ```

## Jenkins CI/CD Pipeline

Once the credentials are complete Jenkins will start the pipeline

* Pull repository from github
  * Clone the repository onto the EC2 instance
  * Look for a Jenkinfile inside the repository
  * This is the Jenkinsfile for this project

  ```jenkinsfile
    pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        python3 -m venv test3
        source test3/bin/activate
        pip install pip --upgrade
        pip install -r requirements.txt
        export FLASK_APP=application
        flask run &
        '''
     }
   }
    stage ('test') {
      steps {
        sh '''#!/bin/bash
        source test3/bin/activate
        py.test --verbose --junit-xml test-reports/results.xml
        ''' 
      }
    
      post{
        always {
          junit 'test-reports/results.xml'
        }
       
      }
    }
    stage ('Deploy') { 
      steps { 
        sh '/var/lib/jenkins/.local/bin/eb deploy' 
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
    * Deploy the application to elastic beanstalk
* Successful execution of all stages can be seen in the Jenkins GUI

  
![jenkins-stages](https://github.com/Antoniorios17/flask_app_jenkins_elastic_beanstalk/blob/main/images/jenkins-stages-3.png)

deployed to elastic beanstalk

![elastic-beanstalk](https://github.com/Antoniorios17/flask_app_jenkins_elastic_beanstalk/blob/main/images/eb-console-ok.png)

1. The Flask app is now deployed on Elastic Beanstalk. Access it using the provided Domain Name.

![url-shortenet-webpage](https://github.com/Antoniorios17/flask_app_jenkins_elastic_beanstalk/blob/main/images/url-shorterner-website.png)

## Troubleshooting

* Build stage fails
  * The build failed becuase it was missing python virtual environment
  * Solutions:
  * run the command on the terminal:

       ```bash
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

## Additions

* Setup a Webhook
  * Go to Github.com
  * Enter the repository
  * Click on settings
  * Go to webhooks
  * Add webhooks
  * In the payload URL
    * http://{public-ip-address}:8080/github-webhook/
* If the webhook is set up correctly you will see a 200 ok http response code

![webhook](https://github.com/Antoniorios17/flask_app_jenkins_elastic_beanstalk/blob/main/images/webhook.png)

To test the webhook in my deployment I updated the colors of the website and let jenkins automate the changes on elastic beanstalk

![website-modified](https://github.com/Antoniorios17/flask_app_jenkins_elastic_beanstalk/blob/main/images/url-shortener-modified.png)


* More improvements
  * Create email notification
  * Create monitoring of the application
  * Create metrics to track website success visits
  * Connect slack notification with the pipeline
  * Add manual authorization to run execute a stage in the pipeline
  * Implement different branches for production and staging