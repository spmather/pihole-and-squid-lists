# author : spmather
# date   : 2025-09-01

#to copy and paste fast between windows use
#  . $pshome/powershell.txt -executionpolicy bypass
#  . ./path/to/script.ps1
#  resolve(gcb) | sortme


#simple function for using reverse dns resolution

function resolve([string]$name) {
  $NameRes = resolve-dnsname $name -erroraction silentlycontinue
  $cb      = @()
  $cb     += "0.0.0.0 $name"
  foreach ($resolvedname in ($NameRes).ipaddress) {
      $NameHost = (resolve-dnsname $resolvedname -erroraction silentlycontinue).NameHost
      $NameHost
      if ($null -ne $namehost) {
        $cb += "0.0.0.0 $($NameHost)"
      }
    }
  set-clipboard -value $cb
}

#simple function for sorting and removing duplicates

function sortme {
  (gcb).trim() | select -unique | sort | scb
  write-output "done"
}

#fin