$logfilepath="D:\Log.txt"
$logmessage="This is a test message for the PowerShell create log file"
if(Test-Path $logfilepath)
{
    Remove-Item $logfilepath
}
$logmessage +" - "+ (Get-Date).ToString() >> $logfilepath

Get-Disk | Where-Object partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -DriveLetter F | Format-Volume -FileSystem NTFS -NewFileSystemLabel "data" -Confirm:$false