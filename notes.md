# Elastic notes

NOTES:
1. Watch all cluster members come up.
  $ kubectl get pods --namespace=logging -l app=elasticsearch-master -w
2. Retrieve elastic user's password.
  $ kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
3. Test cluster health using Helm test.
  $ helm --namespace=logging test elasticsearch
Operation completed!

## Elasticsearch credentials
username: elastic
password: TMmHEzomyWma3xMb
---

# kibana notes
NOTES:
1. Watch all containers come up.
  $ kubectl get pods --namespace=logging -l release=kibana -w
2. Retrieve the elastic user's password.
  $ kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
3. Retrieve the kibana service account token.
  $ kubectl get secrets --namespace=logging kibana-kibana-es-token -ojsonpath='{.data.token}' | base64 -d
Operation completed!

token: AAEAAWVsYXN0aWMva2liYW5hL2tpYmFuYS1raWJhbmE6NGlLRmFKUDNUdzJiV2dpMWlfY1hJdw


# kibana port-forward
kubectl port-forward service/kibana-service 5601:5601
