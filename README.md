# OWASP ZAP UI Automated Scanning :zap:
<p align="center"> <br> :exclamation: :exclamation:  <b> ONLY RUN THIS AGAINST APPLICATIONS YOU HAVE PERMISSION TO ATTACK </b> :exclamation: :exclamation: <br><br> </p>

Provides the ability to execute a [Full Scan](https://github.com/zaproxy/zaproxy/wiki/ZAP-Full-Scan]) against a web application using the OWASP ZAP Docker image within a Azure DevOps pipeline. This generates the standard OWASP ZAP Html report and an NUnit test report to publish the results to the pipeline. 

## Getting Started
These instructions will enable you to get the Full Scan incorporated into an Azure DevOps pipeline. 

### Pre-requisites
Docker needs to be installed on the machine the agent will be running on.

### The YAML file explained
This first stage ensures that the agent has access to the pre-defined $(Build.ArtifactStagingDirectory) location, this may or may not be needed - this is used here as we are running on Linux.

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
