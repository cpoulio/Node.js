# Path to your shell script
$shellScriptPath = "C:\Users\chris\Music\nodjs\script.sh"

# Fetch the latest Node.js version from the latest directory
$latestNodeJsVersion = Invoke-RestMethod -Uri "https://nodejs.org/dist/latest/" -UseBasicParsing | Select-String -Pattern 'node-v(\d+\.\d+\.\d+)-win-x64.zip' | ForEach-Object { $_.Matches.Groups[1].Value }

# Construct the download URL
$downloadUrl = "https://nodejs.org/dist/latest/node-v$latestNodeJsVersion-win-x64.zip"
echo $downloadUrl

# Path to save the downloaded file
$downloadPath = "C:\Users\chris\Music\nodjs\node-v$latestNodeJsVersion-win-x64.zip"
echo $downloadPath

# Ensure the directory exists
$downloadDirectory = [System.IO.Path]::GetDirectoryName($downloadPath)
if (-not (Test-Path -Path $downloadDirectory)) {
    New-Item -Path $downloadDirectory -ItemType Directory
}
echo $downloadDirectory

# Download the latest Node.js binaries using HttpClient
Add-Type -AssemblyName "System.Net.Http"
$client = New-Object System.Net.Http.HttpClient
$response = $client.GetAsync($downloadUrl).Result
$response.EnsureSuccessStatusCode()
$stream = $response.Content.ReadAsStreamAsync().Result
$fileStream = [System.IO.File]::Create($downloadPath)
$stream.CopyTo($fileStream)
$fileStream.Close()

# Update the shell script with the new version number
(Get-Content $shellScriptPath) -replace "VERSION=\d+\.\d+\.\d+", "VERSION=$latestNodeJsVersion" | Set-Content $shellScriptPath

Write-Output "Node.js version $latestNodeJsVersion has been downloaded and the script has been updated."
