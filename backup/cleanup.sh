#!/bin/bash 

# KISS: one operator per ns, use chart release namespace, this is after HELM UNNINSTALL

echo "*************************************************************"
echo "* The script uses tags/labels to list and delete resources. *"
echo "* Ensure operator yaml manifests have cosistent labels set. *"
echo "* Feel free to adapt the script to your needs.              *"
echo "************************************************************"


echo "Working in Namespace: {{ .Release.Namespace }}"
## Use the chart release.namespace instead of a parameter
#oc project {{ .Release.Namespace }}

#Handle CSV not there
echo "Deleting {{ .Values.subscription.startingCSV }}  CSV..."
CSV_NAME=$(oc get csv -n {{ .Release.Namespace }} -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Release.Namespace }} -o name)
oc delete $CSV_NAME

#Helm unninstall will delete the subs
# echo "Deleting {{ .Values.operator.subscription.name }} Subscription..."
# oc delete Subscription/{{ .Values.subscription.name }} || true;

#Lets assume only one operator per namespace - we can just delete all IPs in the namespace
#This only deletes unnaproved IPs - the one we approved does not have that label

# DELETE ALL IPs in the NS
echo "Deleting all operator Install Plans in namespace {{ .Release.Namespace }}..."
for IP in $(oc get installplan.operators.coreos.com -n {{ .Release.Namespace }} | cut -d' ' -f 1); 
do 
    echo "===> Deleting InstallPlan: \"$IP\""; 
    oc delete installplan.operators.coreos.com/$IP || true;
done


# for IP in $(oc get installplan.operators.coreos.com -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Release.Namespace }} | cut -d' ' -f 1); 
# do 
#     echo "===> Deleting InstallPlan: \"$IP\""; 
#     oc delete installplan.operators.coreos.com/$IP || true;
# done

# for IP in $(oc get installplan.operators.coreos.com -l {{ .Values.amq.name }}.{{ .Release.Namespace }}='approved' | cut -d' ' -f 1); 
# do 
#     echo "===> Deleting InstallPlan: \"$IP\""; 
#     oc delete installplan.operators.coreos.com/$IP || true;
# done

sleep 10