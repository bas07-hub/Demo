param(
    [Parameter(Mandatory)]
    [string]$Config,

    [Parameter(Mandatory)]
    [string[]]$T
)

if (-not (Get-Module -ListAvailable -Name powershell-yaml))
{
    Write-Host "powershell-yaml not found. Installing..."

    Install-Module powershell-yaml `
        -Scope CurrentUser `
        -Force `
        -AllowClobber
}

Import-Module powershell-yaml -ErrorAction Stop

$configData = Get-Content $Config -Raw | ConvertFrom-Yaml

$outputFolder = $configData.paths.outputFolder

if (!(Test-Path $outputFolder))
{
    New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
}

# Select commands
if ($T -contains "all")
{
    $selectedCommands = $configData.commands
}
else
{
    $requestedIds = $T | ForEach-Object {
        [int]$_
    }

    $selectedCommands = $configData.commands | Where-Object {
        $_.id -in $requestedIds
    }
}

foreach ($item in $selectedCommands)
{
    Write-Host ""
    Write-Host "Executing: $($item.technique)"

    # If filename ends with $, do not create output file
    $skipOutput = $false

    if ($item.file_name -match '\$$')
    {
        $skipOutput = $true
    }
    else
    {
        $outfile = Join-Path $outputFolder "$($item.file_name).txt"
    }

    try
    {
        switch ($item.executor.ToLower())
        {
            "cmd"
            {
                if ($skipOutput)
                {
                    cmd.exe /c $item.command
                }
                else
                {
                    cmd.exe /c $item.command *> $outfile
                }
            }

            "pwsh"
            {
                if ($skipOutput)
                {
                    powershell.exe -ExecutionPolicy Bypass -Command $item.command
                }
                else
                {
                    powershell.exe -ExecutionPolicy Bypass -Command $item.command *> $outfile
                }
            }

            "powershell"
            {
                if ($skipOutput)
                {
                    powershell.exe -ExecutionPolicy Bypass -Command $item.command
                }
                else
                {
                    powershell.exe -ExecutionPolicy Bypass -Command $item.command *> $outfile
                }
            }

            default
            {
                Write-Host "Unknown executor: $($item.executor)"
                continue
            }
        }

        if (-not $skipOutput)
        {
            Write-Host "Output -> $outfile"
        }
        else
        {
            Write-Host "Output handled by command itself (skipped .txt creation)"
        }
    }
    catch
    {
        if (-not $skipOutput)
        {
            $_ | Out-File $outfile
        }

        Write-Host "Error: $_"
    }
}