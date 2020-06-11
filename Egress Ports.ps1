
function Get-EgressPorts {
   <#
    .SYNOPSIS
    This module will

    Function: Get-HostCapabilities
    Author: Sean Hall
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
      This module will perform specified egress port testing, and an outbound ICMP scan.

    .EXAMPLE
    C:\PS> Get-HostCapabilities

   #>

   Param
   (
    [Parameter(Position = 0, Mandatory = $False)]
    [switch]
    $QuickScan = $false
   )

   # Egress Ports
   $ports = @()
   $portnum = 0

   1..1024 | % {
     $test= new-object system.Net.Sockets.TcpClient

     $wait = $test.beginConnect("allports.exposed",$_,$null,$null)
     $resp = ($wait.asyncwaithandle.waitone(250,$false))

     if($test.Connected)
     {
        $portnum = $portnum + 1
        $ports += $_
     }
   }




   #ICMP Outbound
   $icmp = ping 8.8.8.8 | select-string TTL | measure
   if ($icmp.Count -gt 0){$OutboundICMP = "allowed"}

   $ecap = New-Object -TypeName PSObject
   $ecap | Add-Member -MemberType NoteProperty -Name OpenPortNum -Value $portnum
   $ecap | Add-Member -MemberType NoteProperty -Name OpenPorts -Value $ports
   $ecap | Add-Member -MemberType NoteProperty -Name OutboundICMP -Value $OutboundICMP
   $ecap | ConvertTo-Json
}
