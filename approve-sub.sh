# This scripts checks if "startingCSV" is set on the Subscription and in that case approves only the InstallPlan with the wanted CSV
echo 'Install Plan Approval Script'

approval=$(oc get subscription.operators.coreos.com {{ .Values.amq.name }} -o jsonpath='{.spec.installPlanApproval}')
if [ "$approval" == "Manual" ]; then
    echo 'Waiting for InstallPlan to show up'
    WHILECMD="[ -z "$(oc get installplan -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Values.amq.operator.namespace }} -oname)" ]"
    timeout 15m sh -c "while $WHILECMD; do echo Waiting; sleep 10; done"

    # Search InstallPlan based on startingCSV
    echo 'Search InstallPlan based on startingCSV'
    startingCSV=$(oc get subscription.operators.coreos.com {{ .Values.amq.name }} -o jsonpath='{.spec.startingCSV}')
    if [ -z "$startingCSV" ]; then
        # no startingCSV: check all InstallPlans
        echo 'Subscription does not have StartingCSV ! ABORTING...'
        oc delete subscription.operators.coreos.com {{ .Values.amq.name }}
        exit 1;
    else
        # startingCSV is set: get the InstallPlan with matching "clusterServiceVersionNames" to avoid unexpected upgrades.
        echo 'StartingCSV is set on subscription: {{ .Values.amq.operator.subscription.startingCSV }}'
        # This should return max one InstallPlan, unless multiple operators are installed in the same namespace
        installplan=$(oc get ip -ojson | jq -r '.items[] | select( .spec.clusterServiceVersionNames[] == "{{ .Values.amq.operator.subscription.startingCSV }}") | .metadata.name')
        # This returns multiple InstallPlans becase of the contains, eg: amq-broker-operator.v7.10.2-opr-2 and amq-broker-operator.v7.10.2-opr-2-0.1680622941.p
        #installplans=$(oc get ip -ojson | jq -r '.items[] | select( .spec.clusterServiceVersionNames[] | contains("amq-broker-operator.v7.10.2-opr-2")) | .metadata.name')
        # Could also filter for "approved == false" in one command, then we wouldn't need to check later
        #installplans=$(oc get ip -ojson | jq -r '.items[] | select( (.spec.clusterServiceVersionNames[] | contains("amq-broker-operator.v7.11.0-opr-3")) and .spec.approved == false )  | .metadata.name')
    fi

    # No InstallPlan found
    if [ -z "$installplan" ]; then
        echo "No InstallPlan was found for operator with label operators.coreos.com/{{ .Values.amq.name }}.{{ .Values.amq.operator.namespace }}. This indicates a failure about operator installation."
        /bin/bash /cleanup/cleanup.sh
        exit 1;
    fi

    # Approve the InstallPlan
    if [ "$(oc get ip $installplan -o jsonpath='{.spec.approved}')" == "false" ]; then
        echo "Approving install plan $installplan"
        oc patch ip $installplan --type=json -p='[{"op":"replace","path": "/spec/approved", "value": true}]'
    else
        echo "Install Plan '$installplan' was already approved"
    fi
else
    echo 'Approval must be Manual ! ABORTING...'
    /bin/bash /cleanup/cleanup.sh
    exit 1;
fi
sleep 20