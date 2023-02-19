# os-setup-scripts

These are my script files for setting up a new OS. So far, all they do is create ssh keys and add them to github.

### Quick start
```
export TOKEN_DIR=/tmp/token
git clone https://github.com/zwhitchcox/bootstrap-os $HOME/os-setup-scripts
cd $HOME/os-setup-scripts
```

### Prerequisites

Some scripts require an environment variable called `GH_TOKEN` with your personal access token (see [Creating a Github Personal Access Token](#Creating a Github Personal Access Token)). You can do this manually or use the following scripts on Linux to store your token on a USB drive:

#### [`provision_usb_drive.sh`](./scripts/provision_usb_drive.sh) (linux only)
*Wipes USB drive at specified mount point and creates a 512MiB FAT32 partition with the label `token` and a ext4 partition labelled data in the rest of the space.*
*prompts you enter your github personal access token and stores it in a file called `github` on the `token` partition, which will be sued in later scripts*

#### [`copy_token_files.sh`](./scripts/copy_token_files.sh) (linux only)
Copies github personal access token from USB drive to `TOKEN_DIR`, which will be used in later scripts.

### ssh scripts

#### [`create_ssh_keys.sh`](./scripts/create_ssh_keys.sh)
*Creates an ssh key using the email address attached to your github*

#### [`add_ssh_key_to_github.sh`](./scripts/add_ssh_key_to_github.sh)
*Adds ssh keys to your github account*

#### Creating a Github Personal Access Token
* **create personal access token**
  Go to https://github.com/settings/tokens and create a personal access token with preferably all permissions checked.
  To check all permissions, you can paste this script in the browser console:
  ```
  Array.from(document.querySelectorAll('input[type=checkbox]')).forEach(box => box.click()) 
  ```
