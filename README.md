# AppScan360 Helm Based Installation Documentation

## Overview

**AppScan360 Helm Based Installation**  is a Helmfile-based installation solution for **AppScan360**. This document provides step-by-step instructions for setting up and configuring the AppScan-360-Helm-Files repository, including how to clone the repository, generate an access token, and customize the installation files for specific customer requirements.

---

## Pre-Requisites
1. Good Internet Connection
2. Prepare A Ubuntu 22.04 LTS or newer
3. Hardware Specifications remains same as of Standalone
4. Kubernetes, Helm, Docker, Ingress, Cert-Manager, Storage Class with AccessMode ReadWriteMany needs to be installed 
5. Access to Harbor is required.

 ### Get helm binary file to run the helm based installation for AppScan360, can be obtained from 

  1. Download the Helmfile binary:
     ```bash
     wget https://github.com/helmfile/helmfile/releases/download/v0.169.1/helmfile_0.169.1_linux_amd64.tar.gz
     ```
  2. Extract the downloaded file:
     ```bash
     tar -xvzf helmfile_0.169.1_linux_amd64.tar.gz
     ```
  3. Move the helmfile binary to the appropriate directory:
     ```bash
     sudo mv helmfile /usr/local/bin/
     ```
  4. Set the binary to be executable:
     ```bash
     sudo chmod +x /usr/local/bin/helmfile
     ```
  5. Verify the installation:
     ```bash
      helmfile --version
     ```
        
  **Note** 
  Post helmfile binary installation and customer has harbor access
  Perform harbor login by either of the below steps:
        
  #### 1. docker login hclcr.io(use your username and password obtained from the cli-secret). **OR**
  #### 2. environment variable HCLCR_USERNAME (harbor username) and HCLCR_PASSWORD (harbor password/cli secret). **OR**
  #### 3. env AS360_KNI_JSON_CONFIG_AS_BASE64 which would have base64 value of .docker/config.json 
              
                   {
                    "auths": {
                            "hclcr.io": {
                                    "auth": "secretvalue"
                            }
                        }
                    }               



## Git Installation 

The repository for **AppScan-360-Helm-Files** is hosted on a GitHub server. To clone the repository, follow these steps:

### Clone Command

To clone the repository, use the following command:

git clone --branch main https://Access-Token@github.com/HCL-TECH-SOFTWARE/AppScan-360-Helm-Files.git

1. Access-Token: Replace this placeholder with your personal GitHub access token.

### Generate Access-Token
To generate a personal access token for cloning the repository, follow these steps:

1. Navigate to Settings in GitHub.
2. Go to Developer Settings.
3. Under Developer Settings, select Personal Access Tokens.
4. Click on Generate New Token.
5. Follow the prompts to create your token with the necessary permissions (ensure that the token has permissions to access the repository).
6. Use the generated token in the clone command where the Access-Token placeholder is specified.

### Repository Structure
Once the repository is cloned, you will find the following directory structure.

```bash
AppScan-360-Helm-Files
├── Helm.d
├──  ├── helmfile-ASCP.yaml
├──  ├── helmfile-ASRA.yaml
├──  └── helmFileCustomization
├──         ├── clusterKit.yaml
├──         ├── singular-singular.clusterKit-Sample.yaml
├──         └── siteKit.yaml
└── helmfile.yaml
```
      
singular-singular.clusterKit-Sample.yaml: A file specific to the customer, requiring customization according to customer specifications which needs to be renamed to singular-singular.clusterKit.yaml.

### Customization of singular-singular.clusterKit.yaml

The singular-singular.clusterKit.yaml file must be tailored to each customer's environment. It is important to update the details in this file to accurately reflect the customer's setup. Not doing so may cause deployment configurations to be incorrect. The `CUSTOMIZE_ME` in each section contains the details that the customer needs to fill in each sections. Customers should replace the `CUSTOMIZE_ME` placeholders with the appropriate information based on their environment and configuration requirements. Failure to do this may result in incorrect deployment settings.

For each upgrade, run git pull inside the cloned repository(AppScan-360-Helm-Files) to update the files. Pay attention to the ReadMe and singular-singular.clusterKit-Sample.yaml for any updates that may need to be incorporated into the customer's customized file during an upgrade.


### Run HelmFile:

#### Install AppScan360:
1. Navigate to the cloned AppScan-360-Helm-Files folder.
2. Run the following commands:

    ```bash
     helmfile sync
    ```

#### Uninstall AppScan360:
1. Navigate to the cloned AppScan-360-Helm-Files folder.
2. Run the following commands:
 
    ```bash
     helmfile destroy
    ```

#### Environment List:
 Points to Harbor’s production project, which may not have the final images yet. 

#### RollBack:
Rollback to previous helmfile based installation to previous version 
```bash
helm rollback <release-name> <revision-number> -n <namespace>
```

Example release names:
- appscan-secinfo (namespace: hcl-appscan-secinfo)
- appscan360-ascp (namespace: hcl-appscan-ascp)

You can find the available revision numbers using:
```bash 
helm history <release-name> -n <namespace>
``` 

#### Troubleshooting
Common issues that can be encountered:

1. **no state file found. It must be named helmfile.d/*** : When we navigate inside AppScan-360-Helm-Files -> helm.d -> run helmfile sync, this command needs to be run from AppScan-360-Helm-Files
2. **in ./helmfile.yaml: in .helmfiles[0]: in helm.d/helmfile-ASCP.yaml: failed processing release appscan360-ascp**: values file matching "helmFileCustomizations/singular-singular.clusterKit.yaml" does not exist in ".": When singular-singular.clusterKit.yaml is missing
3. **Failed to pull helm-packages or docker images**: When docker login is missing or HCLCR_USERNAME and HCLCR_PASSWORD environment variable is missing
4. **Failed to get pull secret**: When .docker/config.json file is missing or AS360_KNI_JSON_CONFIG_AS_BASE64 with appropriate value is not defined
