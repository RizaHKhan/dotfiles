# Emre`s dotfiles

> **⚠️ Caution**  
>  Before using these dotfiles, you should **fork this repository**, review the code, and remove anything you **don’t want or need**.  
⚠ **Use at your own risk!**

<img src="./examples/screenshot.png" style="border-radius: 8px;" alt="example" />
&nbsp;

## Installation

### Ansible Setup (Recommended)

This repository includes an Ansible playbook for automated setup. **This is the recommended way to install and manage your dotfiles.**


#### Running the Playbook

To apply the dotfiles to your system:

```bash
ansible-playbook ansible/playbook.yml --ask-become-pass
```

Kitty is the primary terminal configuration. The playbook no longer deploys
iTerm or WezTerm settings.

### Local secrets

Do not put credentials, tokens, or private keys in this repository. During the
Fish migration, machine-specific values belong in the unmanaged,
Git-ignored `~/.config/fish/local.fish` (see
`config/fish/local.fish.example`). Fish is the managed interactive and login
shell; applying Ansible with `--ask-become-pass` registers it in `/etc/shells`
and sets it as the macOS account login shell.

### Herdr

Herdr and its plugins are managed by Ansible. The playbook installs Herdr Lazy,
then restores the repository's `config/herdr/herdr-lazy/plugins.lock`; plugin
checkouts themselves are deliberately not committed.

#### Testing with `ansible/test.sh`

The script `ansible/test.sh` allows you to test your Ansible playbook within a Docker container. This is useful for verifying your playbook works as expected before running it on your actual system.

---

### Install Script (Deprecated)
#### **1. Clone the Repository**
```sh
git clone https://github.com/emrearmagan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### **2. Run the Setup Script**
```sh
sh setup.sh
```
This script will:
- Create **symlinks** for configuration files in your home directory.
- Set up **iTerm2 preferences** (if installed).
- Install **Homebrew packages** from the `Brewfile`.

You will also want a [Nerd Font](https://www.nerdfonts.com/).

---


## **Folder Structure**
```
dotfiles/
│── bat/          # Configuration for bat (better cat)
│── git/          # Git config and global ignore
│── homebrew/     # Homebrew setup and Brewfile
│── iterm/        # iTerm2 preferences
│── neovim/       # Neovim configuration
│── system/       # System-wide aliases and functions
│── fish/         # Fish config and functions
│── zsh/          # Zsh config files (.zshrc, .zprofile; rollback)
│── setup.sh      # Setup script to symlink files and install dependencies
```

---

## **License**
MIT License – Use freely, but **at your own risk**.
