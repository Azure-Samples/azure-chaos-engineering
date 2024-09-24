# Installs Azure Functions Core Tools, Azure CLI, PowerShell 7, Python, Static Web Apps CLI, Visual Studio Code, Git, and Git Bash

# Set Execution Policy to Bypass
Set-ExecutionPolicy Bypass -Scope Process -Force

# Refresh the environment to make sure Chocolatey is in the PATH
RefreshEnv.cmd

# Install PowerShell 7 using Chocolatey
choco install powershell-core -y

# Install Python 3 using Chocolatey
choco install python --version=3.8.0 -y

# Install Kubectx using Chocolatey
choco install kubernetes-cli -y

# install helm

choco install kubernetes-helm -y

# Install Azure CLI using MSI

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi

# Add Azure CLI to the system PATH environment variable

$azureCliPath = "C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin"
$env:Path += ";$azureCliPath"
[System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::Machine)


# Add Git to the system PATH environment variable
$gitPath = "C:\Program Files\Git\cmd"
$env:Path += ";$gitPath"
[System.Environment]::SetEnvironmentVariable('Path', $env:Path, [System.EnvironmentVariableTarget]::Machine)

# Refresh environment to include path updates
RefreshEnv.cmd

# Reboot the system to ensure changes take effect
Restart-Computer
