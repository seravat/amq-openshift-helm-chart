# This scripts checks if "startingCSV" is set on the Subscription and in that case approves only the InstallPlan with the wanted CSV
echo 'Install Plan Approval Script'

approval=$(oc get subscription.operators.coreos.com {{ .Values.amq.name }} -o jsonpath='{.spec.installPlanApproval}')
if [ "$approval" == "Manual" ]; then
    echo 'Waiting for InstallPlan to show up'
    WHILECMD='[ -z "$(oc get installplan -n {{ .Release.Namespace }} -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Release.Namespace }} -oname)" ]'
    timeout 5m sh -c "while $WHILECMD; do echo Waiting; sleep 10; done"

    # Search InstallPlan based on startingCSV
    echo 'Search InstallPlan based on startingCSV'
    startingCSV="$(oc get subscription.operators.coreos.com {{ .Values.amq.name }} -n {{ .Release.Namespace }} -o jsonpath='{.spec.startingCSV}')"
    if [ -z "$startingCSV" ]; then
        # no startingCSV: check all InstallPlans
        echo 'Subscription does not have StartingCSV ! ABORTING...'
        exit 1;
    else
        # startingCSV is set: get the InstallPlan with matching "clusterServiceVersionNames" to avoid unexpected upgrades.
        echo 'StartingCSV is set on subscription: {{ .Values.subscription.startingCSV }}'
        # This should return max one InstallPlan, unless multiple operators are installed in the same namespace
        installplan="$(oc get installplan -n {{ .Release.Namespace }} -l operators.coreos.com/{{ .Values.amq.name }}.{{ .Release.Namespace }} -oname)"
    fi

    # No InstallPlan found
    if [ -z "$installplan" ]; then
        echo "No InstallPlan was found for operator with label operators.coreos.com/{{ .Values.amq.name }}.{{ .Release.Namespace }}. This indicates a failure about operator installation."
        exit 1;
    fi

    # Approve the InstallPlan
    if [ "$(oc get $installplan -o jsonpath='{.spec.approved}')" == "false" ]; then
        echo "Approving install plan $installplan"
        oc patch $installplan -n {{ .Release.Namespace }} --type=json -p='[{"op":"replace","path": "/spec/approved", "value": true}]'
    else
        echo "Install Plan '$installplan' was already approved"
        exit 1;
    fi
else
    echo 'Approval must be Manual ! ABORTING...'
    exit 1;
fi
sleep 20