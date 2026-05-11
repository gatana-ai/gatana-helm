# Gatana Helm Chart

Gatana Helm Chart and Release Notes.

## Quick start

```sh
kubectl create namespace gatana
kubectl -n gatana create secret docker-registry gatana-registry \
  --docker-server=REGISTRY_URL_FROM_GATANA_CONTACT \
  --docker-username=<user> \
  --docker-password=<token>

# 3. Copy values
wget https://raw.githubusercontent.com/gatana-ai/gatana-helm/refs/heads/main/values.yaml

# 4. Adapts values.yaml to your scenario, and install the chart:
helm install gatana oci://ghcr.io/gatana-ai/charts/gatana \
  --namespace gatana \
  -f values.yaml

# 5. Create the first tenant + admin user via the sign-up form
open https://gatana.your-corp.com/signup
```

See [`values.yaml`](./values.yaml) for the full reference.
