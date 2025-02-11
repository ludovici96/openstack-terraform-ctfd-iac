#!/bin/bash

set -o pipefail

TERRAFORM_DIR="./terraform-openstack"

function check_terraform_directory {
    if [[ ! -d "${TERRAFORM_DIR}" ]]; then
        printf "Error: Terraform directory does not exist.\n" >&2
        return 1
    fi
}

function create_vm {
    pushd "${TERRAFORM_DIR}" > /dev/null || return 1
    if ! terraform init; then
        printf "Failed to initialize Terraform.\n" >&2
        popd > /dev/null || return 1
        return 1
    fi
    if ! terraform apply -auto-approve; then
        printf "Failed to create VM.\n" >&2
        popd > /dev/null || return 1
        return 1
    fi
    popd > /dev/null || return 1
}

function destroy_vm {
    pushd "${TERRAFORM_DIR}" > /dev/null || return 1
    if ! terraform destroy -auto-approve; then
        printf "Failed to destroy VM.\n" >&2
        popd > /dev/null || return 1
        return 1
    fi
    popd > /dev/null || return 1
}

function display_nginx_ip {
    local ip_address
    ip_address=$(awk '/nginx:/{getline; getline; sub(/:$/, "", $1); print $1}' ./terraform-openstack/ansible/inventory/staging.yml)
    if [[ -z "$ip_address" ]]; then
        printf "Failed to fetch IP address or there are no instances running.\n" >&2
        return 1
    fi
    printf "\e[34m
    \n------------------------------------------------
    \n %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    \n        CTfd Website IP: %s
    \n %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    \n------------------------------------------------\n" "$ip_address"
    printf "\e[0m"
}

function display_menu {
    printf "\e[34m"
    cat << "EOF"
  _______                   __                     
 |__   __|                 / _|                    
    | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___  
    | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \ 
    | |  __/ |  | | | (_| | || (_) | |  | | | | | |
    |_|\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_|
EOF
    printf "\e[0m"
    cat << "EOF"

Choose an option for terraform VM creation:
1) Create VM's
2) Destroy VM's
3) Display IP to access CTFd website
4) Exit
EOF
    printf "Enter choice: "
}

function main {
    local choice
    while true; do
        display_menu
        read -r choice
        case $choice in
            1)
                if ! check_terraform_directory || ! create_vm; then
                    printf "Operation failed.\n" >&2
                    continue
                fi
                printf "VM created successfully.\n"
                ;;
            2)
                if ! check_terraform_directory || ! destroy_vm; then
                    printf "Operation failed.\n" >&2
                    continue
                fi
                printf "VM destroyed successfully.\n"
                ;;  
            3)
                if ! display_nginx_ip; then
                    printf "Operation failed.\n" >&2
                    continue
                fi
                ;;
            4)
                printf "Exiting...\n"
                break
                ;;
            *)
                printf "Invalid option. Please enter 1, 2, 3, or 4.\n"
                ;;
        esac
    done
}

main
