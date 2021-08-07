$BaseUri = "https://xkcd.com/"
$Headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:90.0) Gecko/20100101 Firefox/90.0"
    "Host" = "xkcd.com"
    # "If-Modified-Since" = "Wed, 21 Oct 2015 00:00:00 GMT"
}

$cwd = Get-Location | select -ExpandProperty path
$outDir = $cwd + "\data\"
$inc = 1
$SleepTime = 1

$wc = New-Object System.Net.WebClient

if(![System.IO.Directory]::Exists($outDir)) {
    $DirInfo = [System.IO.Directory]::CreateDirectory($outDir)
    Write-Host ("Created '{0}' directory" -f $outDir)
}
Exit

function Save-WebImageToFile
{
param ([String]$Uri,[String]$OutFile)

$wc.DownloadFile($Uri, $OutFile)
Write-Host ("[Info] Saved {0} to {1}" -f $Uri,$OutFile)

}

$LastStatusCode = 200

While ($LastStatusCode -ne 404) {
    $PageUri = $BaseUri + $inc + "/"
    $Res = Invoke-WebRequest `
    -Method "GET" `
    -Uri $PageUri `
    -Headers $Headers
    Write-Host ("[Debug] Requested page {0} ({1})" -f $inc,$PageUri)

    $LastStatusCode = $Res.StatusCode

    $Res.Images | Where-Object {
        if ($psitem.src -like "*imgs.xkcd.com/comics/*") {
            $Uri = "https:{0}" -f $psitem.src
            $File = "{0}.jpg" -f $inc
            $OutFile = $outDir + $File
            if([System.IO.File]::Exists($OutFile)) {
                Write-Host ("[Warning] File {0} already exists!" -f $OutFile)
            }
            Save-WebImageToFile $Uri $OutFile
            $inc++
        }
    }
    Write-Host ("[Info] Sleep for {0}" -f $SleepTime)
    Start-Sleep -Seconds $SleepTime
}
Write-Host "[Info] Finished processing"