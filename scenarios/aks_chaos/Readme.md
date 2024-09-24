# Detailed Steps for AKS Chaos Scenario

The AKS Chaos Scenario is a sequence of orchestrated chaos experiments designed to test and improve the resilience of your Azure Kubernetes Services (AKS) infrastructure. Here's how to configure and execute these experiments step by step:

## Preliminary Configuration

Before conducting chaos experiments, configuration scripts need to be initialized with specific parameters.

1. **Configure Parameters:**
   Set your Azure subscription ID, resource group, cluster name, region, tenant ID, and any other required credentials in the `0.parameters.ps1` script. This script pre-defines the necessary variables for subsequent operations.

## Running the Chaos Experiments

Once you've set the parameters, run the following PowerShell scripts in sequential order:

2. **Login to Azure:**
   Execute `1.login.ps1` to authenticate into Azure. This script ensures that you have the necessary permissions and access to manage resources and conduct experiments.

   ```powershell
   .\scenarios\aks_chaos\1.login.ps1
   ```

3. **Deploy AKS Cluster:**
   Run `2.deploy_aks.ps1` to deploy the AKS cluster using Azure CLI commands or Azure Bicep templates. This automated deployment will set up the AKS environment where chaos experiments will be executed.

   ```powershell
   .\scenarios\aks_chaos\2.deploy_aks.ps1
   ```

4. **Install Chaos Mesh:**
   Use `3.install_chaos_mesh.ps1` to install Chaos Mesh into your AKS cluster. This script utilizes Helm to deploy Chaos Mesh to the designated namespace (`chaos-testing`) and creates a LoadBalancer service to expose the Chaos Mesh dashboard.

   ```powershell
   .\scenarios\aks_chaos\3.install_chaos_mesh.ps1
   ```

5. **Deploy HelloWorld Application:**
   Deploy a sample application to witness the effects of chaos experiments. You can use the `kubectl` commands provided above to deploy a basic "HelloWorld" web server on your cluster. This is done already inside the scripts provided, no need to do it yourself.

   ```shell
   kubectl create deployment hello-world --image=k8s.gcr.io/echoserver:1.4
   kubectl expose deployment hello-world --type=LoadBalancer --name=my-service --port=8080 --target-port=8080
   ```

6. **Create Experiments:**
   With `4.create_experiments.ps1`, you can prepare the chaos experiments defined in JSON files, replacing the necessary placeholders with your actual environment values set in the parameters.

   ```powershell
   .\scenarios\aks_chaos\4.create_experiments.ps1
   ```

7. **Run Experiments:**
   Finally, use `5.run_experiment.ps1` to start executing the chaos experiments. The script communicates with Chaos Studio to begin injecting faults such as network failures, pod deletions, and resource constraints.

   ```powershell
   .\scenarios\aks_chaos\5.run_experiment.ps1
   ```

## Post-Experiment Monitoring

After the chaos experiments, monitoring the response and behavior of both the AKS cluster and the "HelloWorld" application is crucial.

8. **Monitor through Azure Portal:**
   Access the Chaos Studio dashboard within Azure Portal to monitor ongoing experiments, check their status, and view any logs or results generated during the tests.

9. **Access Chaos Mesh Dashboard:**
   Observe real-time information on the Chaos Mesh dashboard by visiting the external IP provided by the LoadBalancer. This allows for proper visualization and management of experiments.

Through this well-defined process, you'll comprehensively test the resiliency of your AKS infrastructure, leading to improved strategies for fault tolerance and ensuring your cloud applications' robustness and reliability.