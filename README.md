# avd-all-in-one-container

> AVD container with Ansible AVD and Ansible AVD collections installed

## WARNINGS AND NEWS

### AVD All-in-one Container Moves to GHCR

> New versions of AVD all-in-one container are not available on Docker Hub. The last version available on Docker Hub is avd 3.8.2, cvp3.6.0.
> New images are available on Github Container Registry: `docker pull ghcr.io/arista-netdevops-community/avd-all-in-one-container/avd-all-in-one:<tag>`

### AVD All-in-one Container Supports ARM64

The AVD all-in-one container is multi-platform now. You can pull it directly from GHCR on M1 Mac for example instead of building it locally.

### Breaking change in avd3.3.3_cvp3.3.1_debian and later

- the default collection path `/home/avd/.ansible/collections/ansible_collections` will be used to install collections in the container.
- `collections_paths` must be default and must NOT be set explicitly in the `ansible.cfg`

## Overview

`avd-all-in-one` is a close replica of `avd-base` container. The major difference is that Ansible AVD and Ansible CVP collections are pre-installed and container is ready to use.
For details, check [avd-base container documentation](https://github.com/arista-netdevops-community/docker-avd-base). This readme only includes essential how-to instructions to avoid double maintenance.

### Before avd3.3.3_cvp3.3.1_debian

`ansible.cfg` in AVD inventory repository must have following settings for avd-all-in-one container to work correctly: `collections_paths = /home/avd/ansible-cvp:/home/avd/ansible-avd:/home/avd/.ansible/collections/ansible_collections`
If you have to override that for development purposes, mount ansible-avd or ansible-cvp repositories from your machine to `/home/avd/ansible-cvp` or `/home/avd/ansible-avd` manually or using similar settings in `vscode.json`:

```json
"mounts": [
    "source=${localWorkspaceFolder}/../ansible-avd,target=/home/avd/ansible-avd,type=bind,consistency=cached,readonly=true"
   ],
```

### avd3.3.3_cvp3.3.1_debian and later

`ansible.cfg` in AVD inventory repository must use the default collection path. `collections_paths` must NOT be set explicitly.
If you have to override that for development purposes, mount ansible-avd or ansible-cvp repositories from your machine to `/home/avd/.ansible/collections/ansible_collections/arista/avd` and `/home/avd/.ansible/collections/ansible_collections/arista/cvp`

```json
"mounts": [
    "source=${localWorkspaceFolder}/../ansible-avd,target=/home/avd/.ansible/collections/ansible_collections/arista/avd,type=bind,consistency=cached,readonly=true"
   ],
```

In case of concerns, check your ansible environment with `ansible-galaxy collection list`.

## How-To

### run AVD container manually

Execute following command to run the avd-all-in-one container manually:
`docker run --rm -it -v $(pwd):/home/avd/projects/ avdteam/avd-all-in-one`
Type `exit` to leave the container environment.

### use avd-all-in-one as VSCode devcontainer

Create `.devcontainer` directory in your AVD inventory repository. Create `devcontainer.json` inside this directory.
Use following `devcontainer.json` to start:

```jsonc
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


### run avd-all-in-one in k8s

[k8s-avd-cvp.yml](k8s-avd-cvp.yml) is an example pod definition for running avd-all-in-one on CloudVision (CentOS), however
it should work on other linux distributions (the CVP env vars won't be needed in that case).

The below example is for running the pod on one specific node (set by the `nodeName: $PRIMARY_HOSTNAME` node selection in the spec)

1. Download the docker image: `docker pull avdteam/avd-all-in-one`
2. Create avd group and user: `groupadd -g 1000 avd && useradd avd -u 1000 -g 1000`
3. Create projects in `/home/avd`
4. Deploy the k8s pod: `envsubst < /cvpi/conf/kubernetes/avd.yml | kubectl apply -f -`

> Note that the pod can be also deployed on any node by removing the `nodeName` field from the spec, however that would also require
> pulling the image onto all nodes and synchronozing the project files between all nodes.

## Multi-Platform Builds

It is possible to build avd-all-in-one using Docker desktop's buildx framework for multiple architectures (e.g. x86 and arm64).  This requires setup of a 'docker-container' builder using:

```
docker buildx create --name mybuilder --driver docker-container --bootstrap --use
```

For more information see the [Docker documentation](https://docs.docker.com/build/building/multi-platform/).

Also note that it is not currently possible to build a multi-platform container and export to the local image store.  See (https://github.com/docker/buildx/issues/59) for more information.

## Known Caveats

### Curly Brackets May Not Work as Expected

`-v ${pwd}/:/home/avd/projects` in `docker run` command may not work as expected in MacOS or some Linux distributions. Use `-v $(pwd)/:/home/avd/projects` instead.

### Incorrect Inventory Permissions

On a Linux system incorrect permissions set on an AVD inventory repository can break execution of Ansible commands inside the AVD container.
