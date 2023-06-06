$user="guest"
$password="guest"
$pair="${user}:${password}"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{
    Authorization = $basicAuthValue
}
$nameFilter = "delete-me-"
$page = 1
$pageSize = 500
$totalDeleted = 0
$finished = $false
 
$portIdx = 0
DO {
    $deleted=$false
    # $port = 15672 + $portIdx
    $port = 15672
    $baseAddress = "http://shostakovich:$port/api/queues"
    $request="${baseAddress}?page=${page}&page_size=${pageSize}&name=${nameFilter}&use_regex=false&pagination=true"
    # Write-Host "Get queues: " $request
    try {
        # $result = Invoke-WebRequest -Method Get -Headers $Headers -URI $request -Verbose
        $result = Invoke-WebRequest -Method Get -Headers $Headers -URI $request
    } catch {
        Write-Host $Error[0]
        Write-Warning "No more pages to process"
        $finished=$true
    }
    $data = $result | ConvertFrom-Json
 
    $origProgressPreference = $ProgressPreference
    try
    {
        foreach ($item in $data.items)
        {
            ## if ($item.consumers -eq 0 -And $item.messages -eq 0)
            ## {
                $escapedName = $item.name -replace ":","%3A"
                $escapedName = $escapedName -replace "/","%2F"
                $escapedName = $escapedName -replace " ","%20"
                try
                {
                    Invoke-WebRequest -Method Delete -Headers $Headers -URI "${baseAddress}/%2F/${escapedName}" | Out-Null
                }
                catch
                {
                    Write-Warning "Failed to delete queue ${item.name}" $Error[0]
                    continue
                }
                Write-Host "Deleted queue: " $item.name
                Write-Host "Total deleted queues: " $totalDeleted
                $totalDeleted++
                $deleted = $true
            ## }
            ## else
            ## {
            ##     Write-Host "NOT deleting queue: " $item.name
            ## }
        }
    }
    finally
    {
        $ProgressPreference = $origProgressPreference
    }
 
    if ($deleted -eq $false) {
        $page++
    }

    if ($portIdx -ge 2) {
        $portIdx = 0
    } else {
        $portIdx++
    }
} While ($finished -eq $false)
