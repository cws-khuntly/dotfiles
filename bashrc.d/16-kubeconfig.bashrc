#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  A02-git
#         USAGE:  . A02-git
#   DESCRIPTION:  Useful git aliases
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#
#==============================================================================

[[ -d "${HOME}/.kube" ]] || return;

declare -x KUBECONFIG="${HOME}/.kube/fedora";

printf '\e[31m%s\e[0m\n' "*** KUBECONFIG SET TO DEFAULT. DONT FORGET TO CHANGE.";

function setKubeConfig()
{
    if [[ -f "${HOME}/.kube/${1}" ]]; then
        declare -x KUBECONFIG="${HOME}/.kube/${1}";

        printf '\e[32m%s\e[0m\n' "*** KUBECONFIG SET TO ${KUBECONFIG}";
    else
        read -p "File ${HOME}/.kube/${1} does not exist. Do you want to create it? (y/n): " response;

        case ${response} in
            [Yy])
                touch "${HOME}/.kube/${1}";
                declare -x KUBECONFIG="${HOME}/.kube/${1}";

                printf '\e[32m%s\e[0m\n' "*** KUBECONFIG SET TO ${KUBECONFIG}";
                ;;
            *)
                printf '\e[31m%s\e[0m\n' "*** FILE ${1} NOT FOUND. KUBECONFIG NOT CHANGED.";
                ;;
        esac
    fi

    [[ -n "${response}" ]] && unset -v response;
}
