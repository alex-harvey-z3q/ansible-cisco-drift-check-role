# Ansible + Cisco DevNet Sandbox – Config Drift Detection (Role-Based)

This project sets up a minimal Python virtual environment and Ansible configuration  
to compare a Cisco IOS-XE device running configuration against a golden config  
using an Ansible role.

If any drift is detected, the playbook fails.

---

## Prerequisites

- macOS (or Linux etc)
- Homebrew (for libssh)
- Python 3.10+
- Working SSH access to the Cisco DevNet Sandbox device

---

## Initial Setup

Create the virtual environment and install all dependencies (including dev tools):

    make venv

This will:

- Create a Python virtual environment (`.venv`)
- Install Ansible
- Install ansible-lint
- Install required Ansible collections:
  - `cisco.ios`
  - `ansible.netcommon`

---

## Configure LibSSH (macOS only)

On macOS, `ansible-pylibssh` requires Homebrew libssh headers.

    export LIBSSH_PREFIX="$(brew --prefix libssh)"
    export CPPFLAGS="-I${LIBSSH_PREFIX}/include"
    export LDFLAGS="-L${LIBSSH_PREFIX}/lib"
    export PKG_CONFIG_PATH="${LIBSSH_PREFIX}/lib/pkgconfig"

---

## Create Sandbox in Cisco DevNet

1. Log in:
   https://developer.cisco.com/site/sandbox/

2. Launch Sandbox
3. Launch the Catalyst 8000 Always-on Sandbox
4. Once provisioning finishes, click on the provisioned device
5. Write down the hostname, username, and password

Export these:

    export CISCO_HOST=devnetsandboxiosxec8k.cisco.com
    export CISCO_PASS=xxxxxxxxxxxx
    export CISCO_USER=alexharv074

---

## Project Structure

This repository is structured as a standalone role project:

    .
    ├── goldens
    │   └── sandbox.cfg
    ├── inventory.yml
    ├── Makefile
    ├── test.yml
    ├── README.md
    ├── requirements-dev.txt
    ├── requirements.txt
    └── roles
        └── cisco_config_drift
            ├── defaults
            │   └── main.yml
            └── tasks
                └── main.yml

- `test.yml` is a thin test runner that applies the role for testing purposes only.
- `goldens/` contains the intended configuration files.

---

## Create Initial Golden Config

To make the current running config your golden baseline:

    ansible -i inventory.yml sandbox \
      -m cisco.ios.ios_command \
      -a '{"commands":["show running-config"]}' \
      -o | awk -F'=> ' '{print $2}' | jq -r '.stdout[0]' > goldens/sandbox.cfg

This captures the raw running configuration and saves it as the intended configuration.

---

## Run Drift Check

    ansible-playbook -i inventory.yml test.yml --diff

- If no drift exists → playbook succeeds.
- If drift exists → unified diff is shown and the playbook fails.

The role compares:

    Running config  vs  goldens/<inventory_hostname>.cfg

---

## Forcing a Test Drift

SSH to the sandbox device:

    ssh $CISCO_USER@$CISCO_HOST

Enter configuration mode:

    conf t
    banner motd ^DRIFT TEST^
    end

Re-run the playbook:

    ansible-playbook -i inventory.yml playbook.yml --diff

It should now:

- Show a unified diff
- Fail with `CONFIG DRIFT DETECTED`

Remove the banner to return to compliant state.

---

## Linting

Run:

    make lint

This executes `ansible-lint` against the project.

---

## Licence

MIT
