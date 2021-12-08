#!/usr/bin/env groovy
node ('master'){
    library('BL-Shared')

    def deployLabel = null
    def package_contents = ["build/*", "src/systemd"] as String[]
    def codacy_project_token = ""
    
    try{
        stage('Checkout SCM') {
            checkout scm
        }
        stage('Build') {
            try{
                sh label: 'Debug: Print env vars', script: '''printenv | sort'''
                sh label: 'Installing dependencies.', returnStdout: true, script: '''npm install'''
                sh label: 'Building project.', returnStdout: true, script: '''npm run build'''
            } catch(e) { 
                currentBuild.result = 'FAILURE'
                throw e 
            }
            finally {
               jiraSendBuildInfo site: 'cybercents.atlassian.net'
            }
        }

        /*stage('Unit Test') {
            try {
                sh label: 'Running tests.', script: ''' '''
            } catch(e) { throw e }
            finally {
                junit 'pipeline/artifacts/test_results.xml'
                publishCoberturaCoverage 'pipeline/artifacts/coverage/coverage.xml'
                uploadCoverageToCodacy(codacy_project_token, "ruby", "pipeline/artifacts/coverage/coverage.xml")
            }
        }*/
    
        stage('Package') {
            createProjectTar(package_contents)
            copyPackageToCCAnsible()
            getDeploymentHost()
            deployLabel = getTargetEnv()
        }
    
        stage("""Deploy $deployLabel""") {
            when (env.TARGET_ENV != null && env.TARGET_HOSTS != null){
                try {
                    deployToTarget()
                } catch(e) { 
                    currentBuild.result = 'FAILURE'
                    throw e 
                }
                finally {
                    jiraSendDeploymentInfo site: 'cybercents.atlassian.net', environmentId: """${env.TARGET_ENV}""", environmentName: """${env.TARGET_ENV}""", environmentType: 'development'
                }
                
            }
        }
    }catch (e) {
        throw e
    } finally {
        sendSlackNotification('#slamr-api-gateway')
    }
}
