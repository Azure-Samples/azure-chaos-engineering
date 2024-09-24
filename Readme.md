# Azure Chaos Engineering Solution Accelerator

![Chaos Engineering Logo](media/chaos-logo.png)

Azure Chaos Engineering is a comprehensive solution designed to test the resilience of your Azure-based applications by introducing faults and observing how the system responds. By leveraging Azure's Chaos Studio and a suite of custom tools, you can simulate real-world outages and disruptions, helping to identify and mitigate potential points of failure before they impact your production environment.

This solution guides you through simple configurations, deployment, and execution of various chaos experiments to ensure your systems are robust and reliable.

## Solution Overview

Azure Chaos Engineering provides a variety of scenarios to test different aspects of your Azure environment, including Kubernetes services (AKS), network stability, virtual machine reliability, and more. Each scenario is captured as a JSON file, describing specific chaos experiments that can be injected into your cloud resources.

By simulating conditions such as DNS failures, HTTP chaos, or Redis cache reboots, you can validate your application's fault tolerance and improve its overall resilience.

## Getting Started

To begin using Azure Chaos Engineering, you must install certain prerequisites and execute PowerShell scripts to log in to Azure, configure your environment, deploy resources, and run experiments.

### Prerequisites

The following tools and frameworks must be installed:

- .NET Framework 4.8
- Chocolatey for package management
- Azure CLI
- PowerShell 7
- Python
- Git
- Kubernetes CLI (`kubectl`)

Refer to the scripts provided in `prerequisites` directory of the repository to install necessary components.

### Running the Experiments

Once prerequisites are installed and configured:

1. **Log in to Azure:** Use the Azure CLI to authenticate to your Azure account
2. **Configure and Deploy Resources:** Execute the provided Bicep templates and PowerShell scripts to set up your Azure resources and associated Chaos targets
3. **Run Chaos Experiments:** Use the JSON experiment definitions to initiate chaos experiments against your deployed resources using Chaos Studio or other custom tools
4. **Monitor and Analyze:** Observe the system's behavior and analyze the results to uncover potential weaknesses in your setup

Each experiment scenario includes a set of PowerShell scripts that guide you through the steps required to execute the chaos tests.

## Scenarios and Capabilities

The repository contains several scenarios, each with its own unique set of chaos experiments:

- **AKS Chaos:** Focuses on Kubernetes services, simulating various disruptions and failures within the AKS environment
- **Redis Chaos:** Tests the resilience of Azure Cache for Redis instances by triggering controlled disruptions such as reboots
- **Network Chaos:** Evaluates network reliability by introducing latency, packet loss, or other network anomalies

Each scenario folder includes PowerShell scripts that sequentially perform the necessary steps to execute the experiments.

To execute a particular scenario, navigate to its directory and run the PowerShell scripts in sequential order, starting with the login script (e.g., `1.login.ps1`), followed by the steps to configure and deploy resources (e.g., `2.deploy_aks.ps1`), and finally, execute the experiments (e.g., `5.run_experiment.ps1`).

## How to Run

Follow these steps to run an experiment:

1. Open PowerShell as an administrator.
2. Navigate to the root directory of the Azure Chaos Engineering repository.
3. Choose one of the scenarios for example aks_chaos.
3. Modify the parameters to match your environment in 0.parameters.ps1
3. Execute the login script to authenticate with Azure:

   ```powershell
   .\scenarios\<scenario_name>\1.login.ps1
   ```

4. Deploy the required resources and set up chaos targets by executing the scripts in order.
5. Run each experiment by executing the corresponding PowerShell script:

   ```powershell
   .\scenarios\<scenario_name>\5.run_experiment.ps1
   ```

6. Monitor the results through the Chaos Studio dashboard or logs to analyze the impact and identify the next steps towards improving system resilience.

For detailed instructions on running each scenario, consult the README files within their respective directories.

Please ensure you have the necessary permissions in your Azure subscription to create and manage resources and conduct chaos experiments.

## TODOs 

[ ] Implement tracking for each chaos experiment run and automate the collection of detailed logs and results.
[ ] Set up diagnostic logging for all chaos-impacted resources and integrate with Azure Monitor or Log Analytics workspaces.
[ ] Expand the library of chaos experiments to include additional Azure resources such as VMs, Network services, etc.
[ ] Develop and integrate dashboards for real-time visualization and analysis of chaos experiment data using Azure Monitor, Grafana, or similar tools.