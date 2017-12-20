Param
(
    [Parameter(Mandatory=$True)]
    [string]$pwd,
    [Parameter(Mandatory=$True)]
    [string]$cname,       
    [Parameter(Mandatory=$True)]
    [string]$uname
)

$password = $pwd | ConvertTo-SecureString -asPlainText -Force
$remotingCredential = New-Object System.Management.Automation.PSCredential("$cname\$uname",$password)

$session = $null
$i = 0
$done = $false
$endDate = (Get-Date) + "00:15:00"
Write-Host "Connection loop will end at $endDate."
while ($done -eq $false -and (Get-Date) -lt $endDate)
{
    $i = $i + 1
    try
    {        
        $now = Get-Date
    `	Write-Host "[$now] Attempting to connect to $cname. Try: $i."
        $session = New-PSSession -ComputerName $cname -Credential $remotingCredential -UseSSL -Authentication Negotiate -ErrorAction Stop
    	Write-Host "Connected to $cname."

        Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock {
            Write-Host "Checking if TermService is running..."
            $svc = Get-Service TermService -ErrorAction Stop
            $svc.WaitForStatus('Running', "00:00:30")
            Write-Host "TermService is running."
        }
        $done = $true
    }
    catch 
    {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Error: $ErrorMessage"
    }
}

