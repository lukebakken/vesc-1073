$uris = @(
    'http://shostakovich:15672/api/health/checks/alarms',
    'http://shostakovich:15672/api/nodes',
    'http://shostakovich:15672/api/health/checks/local-alarms',
    'http://shostakovich:15672/api/nodes/rabbit-1@shostakovich',
    'http://shostakovich:15673/api/health/checks/local-alarms',
    'http://shostakovich:15673/api/nodes/rabbit-2@shostakovich',
    'http://shostakovich:15674/api/health/checks/local-alarms',
    'http://shostakovich:15674/api/nodes/rabbit-3@shostakovich'
)

$user = "guest"
$password = "guest"
$pair = "${user}:${password}"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{
    Authorization = $basicAuthValue
}
 
Remove-Item -Force -Verbose -ErrorAction Continue output.txt

foreach ($uri in $uris)
{
    $result = Invoke-WebRequest -Method Get -Headers $Headers -URI $uri

    Add-Content -Path output.txt -Value $uri
    Add-Content -Path output.txt -Value $result
}
