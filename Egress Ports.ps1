
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

   if($QuickScan) {
      20,21,22,23,24,25,53,80,100,106,109,110,111,113,119,125,135,139,143,144,146,161,163,179,199,211,212,222,254,425,427,443,444,445,3389,8080,9000 | % {
        $test= new-object system.Net.Sockets.TcpClient

        $wait = $test.beginConnect("portquiz.net",$_,$null,$null)
        $resp = ($wait.asyncwaithandle.waitone(250,$false))

        if($test.Connected)
        {
           $portnum = $portnum + 1
           $ports += $_
        }
      }
    } else {
      1..1024 | % {
        $test= new-object system.Net.Sockets.TcpClient

        $wait = $test.beginConnect("portquiz.net",$_,$null,$null)
        $resp = ($wait.asyncwaithandle.waitone(250,$false))

        if($test.Connected)
        {
           $portnum = $portnum + 1
           $ports += $_
        }
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
