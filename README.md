# OWASP ZAP Automated Scanning :zap:
<p align="center"> <br> :exclamation: :exclamation:  <b> ONLY RUN THIS AGAINST APPLICATIONS / APIs YOU HAVE PERMISSION TO ATTACK </b> :exclamation: :exclamation: <br><br> </p>

Provides the ability to execute a [Full Scan](https://github.com/zaproxy/zaproxy/wiki/ZAP-Full-Scan) against a web application or a API Scan with a supplied Swagger / OPENApi Definition using the OWASP ZAP Docker image within an Azure DevOps pipeline. This generates:

1. the standard OWASP ZAP Html report
2. an NUnit test report to publish the results to the pipeline

## Getting Started
These instructions will enable you to get the [Full Scan](https://github.com/zaproxy/zaproxy/wiki/ZAP-Full-Scan) incorporated into an Azure DevOps pipeline. 

### Pre-requisites
Docker needs to be installed on the machine the agent will be running on.

### Incorporate into an Azure DevOps Pipeline - UKHO
This can be incorporated into an Azure Devops Pipeline by copying the [azure-pipelines.yml](https://github.com/UKHO/owasp-zap-ui-scan/blob/master/azure-pipelines.yml) and using this within a pipeline created against your repository for running the Zap scan. 

All that needs to be done is to add a pipeline variable called **ApplicationUrl**, which will be the base URL of the application under test.

    resources:
	    repositories:
		    - repository: owaspzapui
		      type: github
		      endpoint: UKHO
		      name: UKHO/owasp-zap-ui-scan
		      ref: refs/heads/master
	jobs:
	- template: owasp-zap-ui-scan-template.yml@owaspzapui
	  parameters:
	  url: $(ApplicationUrl)
	  
This yaml will use the contents of the master branch for this repository, using [owasp-zap-ui-scan-template.yml](https://github.com/UKHO/owasp-zap-ui-scan/blob/master/owasp-zap-ui-scan-template.yml), [ZapTransform.ps1](https://github.com/UKHO/owasp-zap-ui-scan/blob/master/src/ZapTransform.ps1) and [ZapTransformTemplate.xslt](https://github.com/UKHO/owasp-zap-ui-scan/blob/master/src/ZapTransformTemplate.xslt). 

### Incorporate into an Azure DevOps Pipeline - External to UKHO

<br> :construction: <b> UNDER CONSTRUCTION </b> :construction: <br><br>

### The YAML file explained 
The yaml template [(owasp-zap-ui-scan-template.yml)](https://github.com/UKHO/owasp-zap-ui-scan/blob/master/owasp-zap-ui-scan-template.yml) needs the url parameter passed in, this will be the base URL for the application under test.

    parameters:
      url: ''

A single job is executed called Run_Owasp_Zap_Scan, this will execute the steps defined below

    jobs:    
    - job: Run_Owasp_Zap_Scan
      pool: UKHO Ubuntu 1804
      
      workspace:
        clean: all

The first stage is to copy the files ZapTransform.ps1 and ZapTransformTemplate.xslt into the Build.ArtifactStagingDirectory of the repo that is using the template. This allows the template to access the files, as the template yaml is essentially cloned into the repository that is referencing it.

    - script: |
        wget -O $(Build.ArtifactStagingDirectory)/ZapTransform.ps1 "https://raw.githubusercontent.com/UKHO/owasp-zap-ui-scan/master/src/ZapTransform.ps1"
      displayName: "Download ZapTransform.ps1 to ArtifactStagingDirectory"
      
    - script: |
        wget -O $(Build.ArtifactStagingDirectory)/ZapTransformTemplate.xslt "https://raw.githubusercontent.com/UKHO/owasp-zap-ui-scan/master/src/ZapTransformTemplate.xslt"
      displayName: "Download ZapTransformTemplate.xslt to ArtifactStagingDirectory"

This next stage ensures that the agent has access to the pre-defined $(Build.ArtifactStagingDirectory) location, this may or may not be needed - this is used here as we are running on Linux.

    - task: CmdLine@2
      inputs:
          script: 'chmod 777 -R $(Build.ArtifactStagingDirectory)'
          displayName: "Set chmod permissions (ArtifactStagingDirectory)"

Then the Full Scan is executed using the **owasp/zap2docker-stable** docker image, and the inbuilt zap-full-scan python script. The reports are then stored in the $(Build.ArtifactStagingDirectory) location.

    - task: CmdLine@2
	  inputs:
	      script: 'docker run --rm --mount type=bind,source=$(Build.ArtifactStagingDirectory),target=/zap/wrk/ -t owasp/zap2docker-stable zap-full-scan.py -t $(ApplicationUrl) -g gen.conf -r OWASP-Zap-Report.html -x Report.xml || true' 
	  displayName: "Run OWASP ZAP Full Scan"
		  
Next up is to convert the OWASP Zap xml report into an NUnit Test Results file and publish the results. This uses the [ZapTransform.ps1](https://github.com/UKHO/owasp-zap-ui-scan/blob/master/src/ZapTransform.ps1 "ZapTransform.ps1") and the [ZapTransformTemplate.xslt](https://github.com/UKHO/owasp-zap-ui-scan/blob/master/src/ZapTransformTemplate.xslt "ZapTransformTemplate.xslt").

    - task: CmdLine@2  
      inputs:
          script: docker run --rm --mount type=bind,source=$(Build.SourcesDirectory)/src,target=/tmp/nunit/ --mount type=bind,source=$(Build.ArtifactStagingDirectory),target=/tmp/report/ mcr.microsoft.com/powershell:ubuntu-18.04 pwsh -File '/tmp/nunit/ZapTransform.ps1'
      displayName: "Create Nunit Test Report"
    
    - task: PublishTestResults@2
      inputs:
          testResultsFormat: 'NUnit'
          testResultsFiles: 'Converted-OWASP-ZAP-Report.xml'
          searchFolder: '$(Build.ArtifactStagingDirectory)'
      displayName: "Publish OWASP ZAP Test Report"

All of the artifacts are then published to the pipeline.

    - task: PublishBuildArtifacts@1
	  inputs:
          PathtoPublish: '$(Build.ArtifactStagingDirectory)'
          ArtifactName: 'Owasp Zap HTML Report'
          publishLocation: 'Container'
      displayName: "Publish OWASP ZAP Report"

The chmod permissions are then reverted.

    - task: CmdLine@2
      inputs:
          script: 'chmod 755 -R $(Build.ArtifactStagingDirectory)'
      displayName: "Revert chmod permissions (ArtifactStagingDirectory)"

## References
 - [OWASP ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project)
 - [OWASP ZAP Docker (GitHub)](https://github.com/zaproxy/zaproxy/wiki/Docker)
 - [OWASP ZAP Packaged Scans](https://github.com/zaproxy/zaproxy/wiki/Packaged-Scans) 
 - [ZAP Full Scan](https://github.com/zaproxy/zaproxy/wiki/ZAP-Full-Scan)

## License 
This project is licensed under the MIT License - see the [LICENSE](https://github.com/UKHO/owasp-zap-ui-scan/blob/master/LICENSE) file for details

## Security Disclosure
The UK Hydrographic Office (UKHO) collects and supplies hydrographic and geospatial data for the merchant shipping and the Royal Navy, to protect lives at sea. Maintaining the confidentially, integrity and availability of our services is paramount. Found a security bug? You might be saving a life by reporting it to us at UKHO-ITSO@ukho.gov.uk
