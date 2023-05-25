1. Give the namespace SA permissions

Error from server (Forbidden): subscriptions.operators.coreos.com "amq-broker-rhel8" is forbidden: User "system:serviceaccount:amq-operator-cluster:default" cannot get resource "subscriptions" in API group "operators.coreos.com" in the namespace "amq-operator-cluster"

2. Helm

helm upgrade --force --install amq --values=values-operator.yaml --debug .

Helm upgrade does not work if configmap or job are alredy deployed

