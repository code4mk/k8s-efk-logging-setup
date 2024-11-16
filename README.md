# EFK Stack Installation for Kubernetes

This repository contains scripts and configurations for deploying the EFK (Elasticsearch, Fluent Bit, Kibana) stack on a Kubernetes cluster for centralized logging.

## Overview

The EFK stack consists of:
- **Elasticsearch**: Database to store and index logs
- **Fluent Bit**: Lightweight log collector and forwarder
- **Kibana**: Web UI for visualizing and analyzing logs

## Prerequisites

- Kubernetes cluster
- Helm 3.x installed
- `kubectl` configured to access your cluster
- Sufficient cluster resources as defined in the values files

## Installation

### Option 1: Automated Installation

Run the installation script:

```bash
./install.sh
```

The script will present you with the following options:
1. Install Elasticsearch only
2. Install Kibana only
3. Install Fluent Bit only
4. Install Complete Stack
5. Exit

### Option 2: Manual Installation

1. Create the logging namespace:
```bash
kubectl create namespace logging
```

2. Add the Elastic and Fluent Bit Helm repositories:
```bash
helm repo add elastic https://helm.elastic.co
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
```

3. Install Elasticsearch:
```bash
helm install elasticsearch elastic/elasticsearch -f ek/elasticsearch-values.yaml -n logging
```

* it will take about 110 seconds to be ready

4. Install Kibana:
```bash
helm install kibana elastic/kibana -f ek/kibana-values.yaml -n logging
```

* it will also take about 110 seconds to be ready

5. Install Fluent Bit:
```bash
helm install fluent-bit fluent/fluent-bit -f fluentbit/values.yaml -n logging
```

## Accessing Kibana

```bash
kubectl port-forward svc/kibana-kibana 5601:5601 -n logging
```
* `http://localhost:5601`

* get the elastic user's password

```bash
$ kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
```

* `username` is `elastic`

# sample project deploy

```bash
kubectl create namespace backend
kubectl apply -f project.yml
```

---
<div align="center">
  
💼 **Need DevOps expertise?**  
📧 [hiremostafa@gmail.com](mailto:hiremostafa@gmail.com)  
🚀 Available for hire
  
</div>
