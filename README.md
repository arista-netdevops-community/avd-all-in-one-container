# avd-all-in-one-container

> AVD container with Ansible AVD and Ansible AVD collections installed

## Overview

`avd-all-in-one` is a close replica of `avd-base` container. The major difference is that Ansible AVD and Ansible CVP collections are pre-installed and container is ready to use.
For details, check [avd-base container documentation](https://github.com/arista-netdevops-community/docker-avd-base). This readme only includes essential how-to instructions to avoid double maintenance.

`ansible.cfg` in AVD inventory repository must have following settings for avd-all-in-one container to work correctly: `collections_paths = /home/avd/ansible-cvp:/home/avd/ansible-avd`  
If you have to override that for development purposes, mount ansible-avd or ansible-cvp repositories from your machine to `/home/avd/ansible-cvp` or `/home/avd/ansible-avd` manually or using similar settings in `vscode.json`:

```json
"mounts": [
    "source=${localWorkspaceFolder}/../ansible-avd,target=/home/avd/ansible-avd,type=bind,consistency=cached,readonly=true"
   ],
```

## How-To

### run AVD container manually

Execute following command to run the avd-all-in-one container manually:
`docker run --rm -it -v $(pwd):/home/avd/projects/ ankudinov/avd-base`
Type `exit` to leave the container environment.

### use avd-all-in-one as VSCode devcontainer

Create `.devcontainer` directory in your AVD inventory repository. Create `devcontainer.json` inside this directory.
Use following `devcontainer.json` to start:

```json
// For format details, see https://aka.ms/devcontainer.json. For config options, see the README at:
// https://github.com/microsoft/vscode-dev-containers/tree/v0.183.0/containers/python-3
{
    "name": "AVD",
    "image": "avdteam/avd-all-in-one:latest",

    // Set *default* container specific settings.json values on container create.
    "settings": { 
        "python.testing.pytestPath": "/root/.local/bin/pytest",

        "python.pythonPath": "/usr/local/bin/python",
        "python.languageServer": "Pylance",
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "python.formatting.autopep8Path": "/usr/local/py-utils/bin/autopep8",
        "python.formatting.blackPath": "/usr/local/py-utils/bin/black",
        "python.formatting.yapfPath": "/usr/local/py-utils/bin/yapf",
        "python.linting.banditPath": "/usr/local/py-utils/bin/bandit",
        "python.linting.flake8Path": "/usr/local/py-utils/bin/flake8",
        "python.linting.mypyPath": "/usr/local/py-utils/bin/mypy",
        "python.linting.pycodestylePath": "/usr/local/py-utils/bin/pycodestyle",
        "python.linting.pydocstylePath": "/usr/local/py-utils/bin/pydocstyle",
        "python.linting.pylintPath": "/usr/local/py-utils/bin/pylint"
    },

    // Add the IDs of extensions you want installed when the container is created.
    "extensions": [
        "ms-python.python",
        "vscoss.vscode-ansible",
        "timonwong.ansible-autocomplete",
        "codezombiech.gitignore",
        "tuxtina.json2yaml",
        "jebbs.markdown-extended",
        "donjayamanne.python-extension-pack",
        "njpwerner.autodocstring",
        "quicktype.quicktype",
        "jack89ita.copy-filename",
        "mhutchie.git-graph",
        "eamodio.gitlens",
        "yzhang.markdown-all-in-one",
        "davidanson.vscode-markdownlint",
        "christian-kohler.path-intellisense",
        "ms-python.vscode-pylance",
        "tht13.python"
   ],
   "containerEnv": {
        "ANSIBLE_CONFIG": "./ansible.cfg"
   },

    // Comment out connect as root instead. More info: https://aka.ms/vscode-remote/containers/non-root.
    "remoteUser": "avd"
}
```

### use avd-all-in-one with VSCode Remote-SSH Plugin

Unfortunately `devcontainer.json` is not yet supported with VScode Remote-SSH plugin. You can track recent development [here](https://github.com/microsoft/vscode-remote-release/issues/2994).
The easiest way to use avd-all-in-one container with remote SSH is creating a simple alias: `alias avd="sudo docker run --rm -it -v $(pwd):/home/avd/projects/ avdteam/avd-all-in-one"`

## Known Caveats

### Curly Brackets May Not Work as Expected

`-v ${pwd}/:/home/avd/projects` in `docker run` command may not work as expected in MacOS or some Linux distributions. Use `-v $(pwd)/:/home/avd/projects` instead.

### Incorrect Inventory Permissions

On a Linux system incorrect permissions set on an AVD inventory repository can break execution of Ansible commands inside the AVD container.
