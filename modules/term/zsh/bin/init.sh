#!/usr/bin/env zsh


function init() {
    case $1 in
        "purs")
            purs
            ;;
        "*")
            echo "wrong argument" 1>&2
            exit 1
            ;;
    esac
}

function purs() {
    git init
    yarn init --yes
    yarn add --dev purescript spago parcel purescript-psa purs-tidy purs-backend-es
    spago init
    spago install react-basic react-basic-dom react-basic-hooks
    spago build
}

function git() {
    git init
}

init $1
