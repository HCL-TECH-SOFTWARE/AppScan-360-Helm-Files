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
     wget -O helmfile.tar.gz $(curl -s https://api.github.com/repos/helmfile/helmfile/releases/latest | grep browser_download_url | grep linux_amd64.tar.gz | cut -d '"' -f 4)
  2. Extract the downloaded file:
     ```bash
     tar -xvzf helmfile_*_linux_amd64.tar.gz
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

### Repository Structure
Once the repository is cloned, you will find the following directory structure.

```bash
AppScan-360-Helm-Files
├── Helm.d
├──  ├── helmfile-ASCP.yaml.gotmpl
├──  ├── helmfile-ASRA.yaml.gotmpl
│    ├── helmfile-SCA.yaml.gotmpl
├──  └── helmFileCustomization
├──         ├── singular-singular.clusterKit-Sample.yaml
└── helmfile.yaml.gotmpl
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


#### Optional: Include SCA Component
Software Composition Analysis (SCA) is included when you install AppScan 360° with a parameter.
##### Note: Software Composition Analysis (SCA) is not included in the AppScan 360° by default; you must enable it.

To install AppScan360 along with SCA:

```bash
  includeSCA=true helmfile sync
```
To uninstall AppScan360 along with SCA:

```bash
  includeSCA=true helmfile destroy
```

To enable automatic updates of the Software Composition Analysis (SCA) vulnerability database, set the following environment variables that point to the HCL Harbor registry with the correct credentials.

```bash
export SCA_AUTOUPDATER_REGISTRY_USERNAME=<HCL_HARBOR_USERNAME>
export SCA_AUTOUPDATER_REGISTRY_PASSWORD=<HCL_HARBOR_PASSWORD>
```
Important: If you do not set up automatic updates, you must update the vulnerability database manually.

#### Version support using Git tags and archives
AppScan 360° supports version-controlled installation using Git tags and archives.
To clone the latest version of AppScan 360° using Git:

```bash
git clone 
https://github.com/HCL-TECH-SOFTWARE/AppScan-360-Helm-Files.git
```
To clone a specific version of AppScan 360° using Git, where X.X.X is the specific version number:

```bash
git clone --branch vX.X.X 
https://github.com/HCL-TECH-SOFTWARE/AppScan-360-Helm-Files.git
```

To download an archive directly, where X.X.X is the specific version number:

```bash
wget https://github.com/HCL-TECH-SOFTWARE/AppScan-360-Helm-Files/archive/refs/tags/vX.X.X.zip
```

To extract a specific archive, where X.X.X is the specific version number:

```bash
unzip AppScan-360-Helm-Files-vX.X.X.zip
```
or

```bash
tar -xvzf AppScan-360-Helm-Files-vX.X.X.tar.gz
```

#### Environment List:
 Points to Harbor’s production project, which may not have the final images yet. 

#### RollBack:
Rollback to previous helmfile based installation to previous version 
```bash
helm rollback <release-name> <revision-number> -n <namespace>
```

Example release names:
- asra (namespace: hcl-appscan-asra)
- appscan360-ascp (namespace: hcl-appscan-ascp)
- scaservices (namespace: hcl-appscan-sca)

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
