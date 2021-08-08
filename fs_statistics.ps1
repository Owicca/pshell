param([String]$Path)

# Get all files in a given folder including subfolders and
#display a result that shows the total number of files,
#the total size of all files, the average file size, the computer name,
#and the date when you ran the command.

$Statistics = @{
    ComputerName = Get-ComputerInfo -Property CsName | Select-Object -ExpandProperty CsName
    Date = Get-Date
    FileTotalCount = 0
    FileTotalSize = 0
    FileAvgSize = 0
}

$Shlwapi = Add-Type -MemberDefinition '[DllImport("Shlwapi.dll", CharSet=CharSet.Auto)]public static extern int StrFormatByteSize(long fileSize, System.Text.StringBuilder pwszBuff, int cchBuff);' `
-Name "ShlwapiFunctions" -Namespace ShlwapiFunction -PassThru

function Format-ByteSize
{
    param([Int]$Size)

    $Bytes = New-Object Text.StringBuilder 20
    $Return = $Shlwapi::StrFormatByteSize($Size, $Bytes, $Bytes.Capacity)

    if ($Return) {
        $Bytes.ToString()
    }
}

Get-ChildItem -File -Force -Path $Path -Recurse | `
ForEach-Object -Process {
    $Statistics.FileTotalCount++
    $Statistics.FileTotalSize += $psitem.Length
}
$Statistics.FileAvgSize = $Statistics.FileTotalSize / $Statistics.FileTotalCount

Write-Host ("
Computer name: {0}
Date: {1}
Total file count: {2}
Total file size: {3}
Average file size: {4}" -f `
$Statistics.ComputerName,$Statistics.Date,`
$Statistics.FileTotalCount,`
(Format-ByteSize $Statistics.FileTotalSize),`
(Format-ByteSize $Statistics.FileAvgSize))