$user = "guest"
$password = "guest"
$pair = "${user}:${password}"
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
Do
{
    $deleted=$false
    $port = 15672 + $portIdx
    $baseAddress = "http://shostakovich:$port/api/queues"
    # $request="${baseAddress}?page=${page}&page_size=${pageSize}&name=${nameFilter}&use_regex=false&pagination=true"
    $request="${baseAddress}?page=${page}&page_size=${pageSize}&pagination=true"
    Write-Host "[INFO] request: $request"
    try
    {
        $result = Invoke-WebRequest -Method Get -Headers $Headers -URI $request
    }
    catch
    {
        Write-Host $Error[0]
        Write-Warning "No more pages to process"
        $finished=$true
    }
    $data = $result | ConvertFrom-Json
    Write-Host "[INFO] request data: " $data
    Write-Host "[INFO] request data.items[0]: " $data.items[0]
 
    $page++

    if ($portIdx -ge 2) {
        $portIdx = 0
    } else {
        $portIdx++
    }
} While ($finished -eq $false)
