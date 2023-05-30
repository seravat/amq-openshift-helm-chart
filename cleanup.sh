#!/bin/bash 

echo "*************************************************************"
echo "* The script uses tags/labels to list and delete resources. *"
echo "* Ensure operator yaml manifests have cosistent labels set. *"
echo "* Feel free to adapt the script to your needs.              *"
echo "************************************************************"

set +e

function remove_finalizers(){
    NAME_KIND=$1
    sleep 10
    echo "Removing resources locked by finalizers if any: $NAME_KIND"
    oc patch $NAME_KIND --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]' || true
    sleep 5
    oc patch $NAME_KIND --type json --patch='[ { "op": "remove", "path": "/status/finalizers" } ]' || true
    sleep 5
    oc patch $NAME_KIND --type json --patch='[ { "op": "remove", "path": "/spec/finalizers" } ]' || true
    sleep 5
}


echo "Working in Namespace: {{ .Values.amq.operator.namespace }}"
oc project {{ .Values.amq.operator.namespace }}

echo "Deleting {{ .Values.amq.operator.subscription.startingCSV }}  CSV..."
CSV_NAME=$(oc get csv -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Values.amq.operator.namespace }} -o name)
oc delete $CSV_NAME
#remove_finalizers "$CSV_NAME"

echo "Deleting {{ .Values.amq.operator.subscription.name }} Subscription..."
oc delete Subscription/{{ .Values.amq.operator.subscription.name }} || true;

#This only deletes unnaproved IPs - the one we approved does not have that label
echo "Deleting {{ .Values.amq.name }} operator Install Plans..."
for IP in $(oc get installplan.operators.coreos.com -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Values.amq.operator.namespace }} | cut -d' ' -f 1); 
do 
    echo "===> Deleting InstallPlan: \"$IP\""; 
    oc delete installplan.operators.coreos.com/$IP || true;
    #remove_finalizers "installplan.operators.coreos.com/$IP"
done

for IP in $(oc get installplan.operators.coreos.com -l {{ .Values.amq.name }}.{{ .Values.amq.operator.namespace }}='approved' | cut -d' ' -f 1); 
do 
    echo "===> Deleting InstallPlan: \"$IP\""; 
    oc delete installplan.operators.coreos.com/$IP || true;
    #remove_finalizers "installplan.operators.coreos.com/$IP"
done

sleep 10

#oc delete all -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Values.amq.operator.namespace }}

sleep 10
set -e