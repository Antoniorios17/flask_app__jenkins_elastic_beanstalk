# KuraLabs

Deployment 2
Build, test and archive a flask application on Jenkins and deploy using AWS Elastic Beanstalk.

## Table of contents

1. Pre-requisites
2. Install jenkins
3. Create A Pipeline Build On Jenkins
4. Jenkins CI/CD Pipeline
5. Extract Build From EC2
6. Deploy Application to Elastic Beanstalk
7. System Design

## Pre-requisites

First we need to install the necessary plugins for the pipeline.

Follow these steps:

* Select Dashboard 
  * Select Manage Jenkins
  * Within System configuration look for "Plugins"
  * From the available plugins look for "Pipeline Utility Steps"
  * Install the plugin
  * Restart the jenkins Controller to apply the changes
    * Run the command: 
    ```
    sudo systemctl restart jenkins 
    ```


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
    * Use the automatic script installation for jenkins [here](https://github.com/Antoniorios17/flask-app-jenkins-deployment/blob/main/scripts/jenkins-installer.sh)

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

## Jenkins CI/CD Pipeline

Once the credentials are complete Jenkins will start the pipeline

* Pull repository from github
  * Clone the repository onto the EC2 instance
  * Look for a Jenkinfile inside the repository
  * This is the Jenkinsfile for this project

    ```
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
  * Successful execution of all stages can be seen in the Jenkins GUI
  
![jenkins-stages](https://github.com/Antoniorios17/flask-app-jenkins-deployment/blob/main/images/d2-jenkins-stages.png)

## Extract build from EC2

* Once the pipeline finishes running you have a build created in zip form
  * The application files have been compressed into a build that can be used along elastic beanstalk
  * Follow these steps to extract the file from the EC2 instance to your local computer
    * Find the zip file on the workspace directory
      ```
      /var/lib/jenkins/workspace/{project-name}/build/{build-version}
      ```
    * Create an ssh key from your local computer using :
      ```
      ssh-keygen
      ```
    * On the EC2 instance lookg for the .ssh directory in the /home/user directory.
    * Edit the file authorized_users to include the public key of the local computer using nano
    * From your local computer open the terminal and execute:
      ```
      scp ubuntu@{EC2-public-ip-address}:/var/lib/jenkins/workspace/{project-name}/build/{build-version}/archive.zip .
      ```
      This command will retrieve the file over ssh in a secure way to your local computer

## Elastic Beanstalk Flask App Deployment

1. Open AWS Console: [Elastic Beanstalk](us-east-1.console.aws.amazon.com/elasticbeanstalk).

2. Click "Create application".

3. Enter "url-shortener" as the app name.

4. Choose "Python" platform.

5. Select "Python 3.9 running on 64bit Amazon Linux 2023".

6. Upload your zipped app code.

7. Set version label to "v1".

8. Select "ElasticEC2" instance profile.

9. Choose your default VPC and an Availability Zone.

10. Configure storage: 10 GB size, "General Purpose (SSD)".

11. For instance types, select "T.2 MICRO".

12. Click "Submit".

13. Once environment health is "OK", note your Domain Name.

![elastic-beanstalk](https://github.com/Antoniorios17/flask-app-jenkins-deployment/blob/main/images/d2-eb-ok-health.png)

14. The Flask app is now deployed on Elastic Beanstalk. Access it using the provided Domain Name.

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