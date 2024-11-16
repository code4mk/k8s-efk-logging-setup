#!/bin/bash

# Print banner
print_banner() {
    echo "----------------------------------------"
    echo "EFK Stack Installation Script"
    echo "Elasticsearch + Fluent Bit + Kibana"
    echo "----------------------------------------"
}

# Display menu options
show_menu() {
    echo "Please select an option:"
    echo "1. Install Elasticsearch"
    echo "2. Install Kibana"
    echo "3. Install Fluent Bit"
    echo "4. Install Complete Stack"
    echo "5. Uninstall Complete Stack"
    echo "6. Exit"
}

# Setup namespace
setup_namespace() {
    if ! kubectl get namespace | grep -q "logging"; then
        echo "Creating 'logging' namespace..."
        kubectl create namespace logging || { echo "Failed to create namespace"; exit 1; }
    else
        echo "The 'logging' namespace already exists."
    fi
}

# Setup Helm repo
setup_helm_repo_elastic() {
    if ! helm repo list | grep -q "https://helm.elastic.co"; then
        echo "Adding Elastic Helm repo..."
        helm repo add elastic https://helm.elastic.co || { echo "Failed to add Helm repo"; exit 1; }
    else
        echo "Elastic Helm repo is already added."
    fi
    echo "Updating Helm repositories..."
    helm repo update
}

setup_helm_repo_fluentbit() {
    if ! helm repo list | grep -q "https://fluent.github.io/helm-charts"; then
        echo "Adding Fluent Bit Helm repo..."
        helm repo add fluent https://fluent.github.io/helm-charts || { echo "Failed to add Helm repo"; exit 1; }
    else
        echo "Fluent Bit Helm repo is already added."
    fi
}

# Install components
install_elasticsearch() {
    echo "Checking Elasticsearch installation..."
    if helm list -n logging | grep -q "elasticsearch"; then
        echo "Elasticsearch already exists, upgrading..."
        helm upgrade elasticsearch elastic/elasticsearch -f ek/elasticsearch-values.yaml -n logging || { echo "Failed to upgrade Elasticsearch"; exit 1; }
    else
        echo "Installing Elasticsearch..."
        helm install elasticsearch elastic/elasticsearch -f ek/elasticsearch-values.yaml -n logging || { echo "Failed to install Elasticsearch"; exit 1; }
    fi
}

install_kibana() {
    echo "Checking Kibana installation..."
    if helm list -n logging | grep -q "kibana"; then
        echo "Kibana already exists, upgrading..."
        helm upgrade kibana elastic/kibana -f ek/kibana-values.yaml -n logging || { echo "Failed to upgrade Kibana"; exit 1; }
    else
        echo "Installing Kibana..."
        helm install kibana elastic/kibana -f ek/kibana-values.yaml -n logging || { echo "Failed to install Kibana"; exit 1; }
    fi
}

install_fluentbit() {
    echo "Checking Fluent Bit installation..."
    if helm list -n logging | grep -q "fluentbit"; then
        echo "Fluent Bit already exists, upgrading..."
        helm upgrade fluentbit fluent/fluent-bit -f fluentbit/values.yaml -n logging || { echo "Failed to upgrade Fluent Bit"; exit 1; }
    else
        echo "Installing Fluent Bit..."
        helm install fluentbit fluent/fluent-bit -f fluentbit/values.yaml -n logging || { echo "Failed to install Fluent Bit"; exit 1; }
    fi
}

# Add sleep function with loading animation
wait_with_loader() {
    local seconds=$1
    local message="${2:-Please wait while the system initializes}"
    local spin='-\|/'
    local i=0
    
    for ((s=seconds; s>0; s--)); do
        i=$(( (i+1) %4 ))
        printf "\r${message} ${spin:$i:1} (${s}s remaining)"
        sleep 1
    done
    printf "\r${message} Done!\n"
}

# Add new uninstall function
uninstall_stack() {
    echo "Uninstalling EFK Stack..."
    
    # Uninstall Fluent Bit
    if helm list -n logging | grep -q "fluentbit"; then
        echo "Uninstalling Fluent Bit..."
        helm uninstall fluentbit -n logging || echo "Failed to uninstall Fluent Bit"
    fi
    
    # Uninstall Kibana
    if helm list -n logging | grep -q "kibana"; then
        echo "Uninstalling Kibana..."
        helm uninstall kibana -n logging || echo "Failed to uninstall Kibana"
    fi
    
    # Uninstall Elasticsearch
    if helm list -n logging | grep -q "elasticsearch"; then
        echo "Uninstalling Elasticsearch..."
        helm uninstall elasticsearch -n logging || echo "Failed to uninstall Elasticsearch"
    fi
    
    # Delete namespace
    echo "Deleting logging namespace..."
    kubectl delete namespace logging --timeout=60s || echo "Failed to delete namespace"
}

# Main execution
main() {
    print_banner
    
    show_menu
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            setup_namespace
            setup_helm_repo_elastic
            install_elasticsearch
            ;;
        2)
            setup_namespace
            setup_helm_repo_elastic
            install_kibana
            ;;
        3)
            setup_namespace
            setup_helm_repo_fluentbit
            install_fluentbit
            ;;
        4)
            setup_namespace
            setup_helm_repo_elastic
            setup_helm_repo_fluentbit
            
            install_elasticsearch
            wait_with_loader 110 "Waiting for Elasticsearch to be ready ..."
            
            install_kibana
            wait_with_loader 110 "Waiting for Kibana to be ready ..."
            
            install_fluentbit
            ;;
        5)
            uninstall_stack
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select 1-6."
            exit 1
            ;;
    esac
    
    echo "Operation completed!"
}

main