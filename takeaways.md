1. Give the namespace SA permissions

Error from server (Forbidden): subscriptions.operators.coreos.com "amq-broker-rhel8" is forbidden: User "system:serviceaccount:amq-operator-cluster:default" cannot get resource "subscriptions" in API group "operators.coreos.com" in the namespace "amq-operator-cluster"

2. Helm

helm install amq --values=examples\values-cluster-operator.yaml --debug .

Helm upgrade does not work if configmap or job are alredy deployed

helm uninstall  amq  --debug 

3. Issue while testing

constraints not satisfiable: 
subscription amq-broker-rhel8 requires redhat-operators/openshift-marketplace/7.10.x/amq-broker-operator.v7.10.2-opr-2-0.1680622941.p, 
subscription amq-broker-rhel8 exists, clusterserviceversion amq-broker-operator.v7.10.2-opr-2 exists and is not referenced by a subscription, 
redhat-operators/openshift-marketplace/7.10.x/amq-broker-operator.v7.10.2-opr-2-0.1680622941.p and 
@existing/amq-operator-cluster//amq-broker-operator.v7.10.2-opr-2 provide ActiveMQArtemis (broker.amq.io/v2alpha3)

constraints not satisfiable: 
subscription amq-broker-rhel8 exists, 
subscription amq-broker-rhel8 requires redhat-operators/openshift-marketplace/7.10.x/amq-broker-operator.v7.10.2-opr-2-0.1680622941.p, 
redhat-operators/openshift-marketplace/7.10.x/amq-broker-operator.v7.10.2-opr-2-0.1680622941.p and 
@existing/amq-operator-cluster//amq-broker-operator.v7.10.2-opr-2 provide ActiveMQArtemisAddress (broker.amq.io/v2alpha1), 
clusterserviceversion amq-broker-operator.v7.10.2-opr-2 exists and is not referenced by a subscription

constraints not satisfiable: 
redhat-operators/openshift-marketplace/7.10.x/amq-broker-operator.v7.10.2-opr-2-0.1680622941.p and 
@existing/amq-operator-cluster//amq-broker-operator.v7.10.2-opr-2 provide ActiveMQArtemisScaledown (broker.amq.io/v1beta1), 
subscription amq-broker-rhel8 requires redhat-operators/openshift-marketplace/7.10.x/amq-broker-operator.v7.10.2-opr-2-0.1680622941.p, 
subscription amq-broker-rhel8 exists, clusterserviceversion amq-broker-operator.v7.10.2-opr-2 exists and is not referenced by a subscription