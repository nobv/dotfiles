# for homebrew
eval $(/opt/homebrew/bin/brew shellenv)

# locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# dotfiles
export DOTFILES=$HOME/.dotfiles

# kubernetes
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export KUBECONFIG=~/.kube/config-oci-k3s

# PATH
export PATH="$HOME/.local/bin:$PATH"
