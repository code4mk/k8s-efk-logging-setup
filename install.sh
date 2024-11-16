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
    echo "5. Exit"
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
    echo "Installing Elasticsearch..."
    helm install elasticsearch elastic/elasticsearch -f ek/elasticsearch-values.yaml -n logging || { echo "Failed to install Elasticsearch"; exit 1; }
}

install_kibana() {
    echo "Installing Kibana..."
    helm install kibana elastic/kibana -f ek/kibana-values.yaml -n logging || { echo "Failed to install Kibana"; exit 1; }
}

install_fluentbit() {
    echo "Installing Fluent Bit..."
    helm install fluentbit fluent/fluent-bit -f fluentbit/values.yaml -n logging || { echo "Failed to install Fluent Bit"; exit 1; }
}

# Add sleep function with loading animation
wait_with_loader() {
    local seconds=$1
    local message="Please wait while the system initializes"
    local spin='-\|/'
    local i=0
    
    echo "Quote: $(get_random_quote)"
    for ((s=seconds; s>0; s--)); do
        i=$(( (i+1) %4 ))
        printf "\r${message} ${spin:$i:1} (${s}s remaining)"
        sleep 1
    done
    printf "\r${message} Done!\n"
}

# Main execution
main() {
    print_banner
    
    show_menu
    read -p "Enter your choice (1-5): " choice
    
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
            wait_with_loader 110
            
            install_kibana
            wait_with_loader 110
            
            install_fluentbit
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select 1-5."
            exit 1
            ;;
    esac
    
    echo "Operation completed!"
}

main