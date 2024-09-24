# Set the subscription ID and Azure resource group variables
. .\0.parameters.ps1

az aks get-credentials --resource-group $resourceGroupName --name $clusterName --overwrite-existing
# Install Chaos Mesh onto the AKS cluster using Helm
Write-Output "Installing Chaos Mesh onto the AKS cluster..."
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --set controller.service.type=LoadBalancer


# Kubernetes ClusterRoleBinding to give the user cluster-admin rights
# Assign cluster admin role to the user for the particular AKS resource 
$RoleAssignmentCommandFormat = "az role assignment create --assignee `{0}` --role `"Azure Kubernetes Service RBAC Cluster Admin`" --scope `"/subscriptions/{1}/resourcegroups/{2}/providers/Microsoft.ContainerService/managedClusters/{3}`""

# Replace placeholders with actual values
$RoleAssignmentCommand = $RoleAssignmentCommandFormat -f $userOrServicePrincipal, $SubscriptionId, $ResourceGroupName, $ClusterName

# Execute the role assignment command
Invoke-Expression $RoleAssignmentCommand

$clusterRoleBinding = @"
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: aks-cluster-admin-binding
subjects:
- kind: User
  name: "$userOrServicePrincipal" # This name should match the subject you use to authenticate to your AKS cluster
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
"@

# Apply the ClusterRoleBinding
$clusterRoleBinding | kubectl apply -f -


kubectl create ns chaos-testing
helm install chaos-mesh chaos-mesh/chaos-mesh --namespace=chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock

# Wait for Chaos Mesh pods to get up and running
Start-Sleep -Seconds 30
kubectl get po -n chaos-testing

# Enable Chaos Studio on your AKS cluster by creating a target and capability

az deployment sub create --template-file "..\..\infra\bicep\aks_chaos\main.bicep" --location $Location --parameters subscriptionId=$SubscriptionId resourceGroupName=$resourceGroupName clusterName=$clusterName

# Expose Chaos Dashboard using an lb
kubectl apply -f ..\..\k8s\chaos-dashboard-lb-service.yaml

# Give permissions to access to chaos dashboard 
kubectl apply -f ..\..\k8s\rbac.yaml

# Get a token and save it to a file
$token = kubectl create token account-chaos-testing-manager-fywav --namespace=chaos-testing -o jsonpath='{.status.token}'
$tokeName='account-chaos-testing-manager-fywav'
$tokeName | Out-File -FilePath "chaos_dashboard_token_name.txt"
$token | Out-File -FilePath "chaos_dashboard_token.txt"

