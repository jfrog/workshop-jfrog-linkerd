#! /bin/bash

if [ "$CIVO_API_KEY" == "" ]; then
    printf "CIVO_API_KEY is not set. Visit the Security tab in your Civo\n"
    printf "account settings page to get your key, then set it with the command"
    printf "\n\n\texport CIVO_API_KEY=<key value>\n\n"
    printf "then run this script again\n"
    exit 1
fi

if ! type jq > /dev/null; then
    echo "\n\nVisit https://stedolan.github.io/jq/ to install jq to parse"
    echo "Civo API responses\n\n"
    exit 1
fi

echo "CIVO_API_KEY is set"

USERNAME=`whoami`
CIVO_API_URL="https://api.civo.com/v2"
KUBECONFIG=null
NETWORKD_ID=null
CLUSTER_ID=null

echo "Creating cluster $USERNAME-jfrog-linkerd"
AUTH_HEADER="Authorization: bearer $CIVO_API_KEY"

# curl -H "$AUTH_HEADER" $CIVO_API_URL/kubernetes/clusters

NETWORK_ID=$(curl -s -H "$AUTH_HEADER" \
    $CIVO_API_URL/networks | jq '.[].id' -r)

CLUSTER_ID=$(curl -s -H "$AUTH_HEADER" -X POST $CIVO_API_URL/kubernetes/clusters \
    -d "name=$USERNAME-jfrog-linkerd&target_nodes_size=g4s.kube.medium&num_target_nodes=2&network_id=$NETWORK_ID" |
    jq '.id' -r)

printf "\n\n\tCluster ID is $CLUSTER_ID\n\n"

while [ "$KUBECONFIG" == "null" ];do
    echo "Sleeping for 30 seconds before getting the kubeconfig file"
    sleep 30
    KUBECONFIG=$(curl -s -H "$AUTH_HEADER" \
        $CIVO_API_URL/kubernetes/clusters/$CLUSTER_ID | jq .kubeconfig -r)
    #echo "new kubeconfig $KUBECONFIG"
done

echo $CLUSTER_ID > .clusterid
echo $NETWORK_ID > .networkid
echo "$KUBECONFIG" > .civo-kubeconfig

kubectl get po -n kube-system
kubectl get node

printf "\n\nYour cluster has been created with id $CLUSTER_ID which you can"
printf "find in the .clusterid file"
printf "Run the following command to set the KUBECONFIG environment variable"
printf "to use the .civo-kubeconfig file"
printf "\n\n\texport KUBECONFIG=`pwd`/.civo-kubeconfig\n\n"