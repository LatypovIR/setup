#!/usr/bin/env bash

set -euo pipefail

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl git zsh

if command -v zsh >/dev/null 2>&1; then
  current_user="$(id -un)"
  chsh -s "$(command -v zsh)" "$current_user" || true
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom/plugins}"
mkdir -p "$ZSH_CUSTOM_PLUGINS"

if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting"
fi

ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
  if grep -q '^plugins=' "$ZSHRC"; then
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
  else
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
  fi
fi

SSH_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfLtkTiUt/170SxTpXpJijOfL/DuKpnQYb/BFbRNCH0 ilatypov@i113861350"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"
touch "$AUTHORIZED_KEYS"
if ! grep -qxF "$SSH_PUBLIC_KEY" "$AUTHORIZED_KEYS"; then
  printf '%s\n' "$SSH_PUBLIC_KEY" >> "$AUTHORIZED_KEYS"
fi
chmod 600 "$AUTHORIZED_KEYS"
