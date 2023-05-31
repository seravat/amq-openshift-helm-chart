#!/bin/bash 

# KISS: one operator per ns, use chart release namespace, this is after HELM UNNINSTALL

echo "*************************************************************"
echo "* The script uses tags/labels to list and delete resources. *"
echo "* Ensure operator yaml manifests have cosistent labels set. *"
echo "* Feel free to adapt the script to your needs.              *"
echo "************************************************************"

echo "Working in Namespace: {{ .Release.Namespace }}"

#Handle CSV not there
echo "Deleting {{ .Values.subscription.startingCSV }}  CSV..."
CSV_NAME=$(oc get csv -n {{ .Release.Namespace }} -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Release.Namespace }} -o name)
oc delete $CSV_NAME -n {{ .Release.Namespace }}

#Lets assume only one operator per namespace - we can just delete all IPs in the namespace
echo "Deleting all operator Install Plans in namespace {{ .Release.Namespace }}..."
for IP in $(oc get installplan.operators.coreos.com -n {{ .Release.Namespace }} -o name); 
do 
    echo "===> Deleting InstallPlan: \"$IP\""; 
    oc delete $IP -n {{ .Release.Namespace }} || true;
done

sleep 10