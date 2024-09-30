# Output file to store the contents of the code files
$OutputFile = ".\all_code_contents.txt"

# Clean the output file if it already exists, or create a new one
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile
}

# Define patterns/extensions to exclude
$excludeExtensions = @('.md', '.png', '.jpg', '.gif', '.bmp', '.jpeg')

# Get the full path to the output file to prevent it from reading itself
$ScriptPath = (Get-Item -Path ".\" -Verbose).FullName
$OutputFilePath = Join-Path -Path $ScriptPath -ChildPath $OutputFile

# Recursively get all files, excluding the defined patterns and the output file
Get-ChildItem -Path . -Recurse -File |
Where-Object {
    # Check if the path contains the .git folder or matches one of the excluded extensions, or is the output file
    $_.FullName -notmatch '\\\.git\\' -and
    $excludeExtensions -notcontains $_.Extension -and
    $_.FullName -ne $OutputFilePath
} |
ForEach-Object {
    # Write the file path to the output file
    "File: $($_.FullName)" | Out-File -Append -FilePath $OutputFile
    "====================" | Out-File -Append -FilePath $OutputFile

    # Write the content of the file to the output file
    Get-Content -Path $_.FullName | Out-File -Append -FilePath $OutputFile
    "`n" | Out-File -Append -FilePath $OutputFile
}

Write-Host "All code files have been written to $OutputFile"
