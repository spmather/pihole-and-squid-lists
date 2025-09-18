#!/bin/pwsh

# Author : spmather
# Date   : 2025-09-17

# fix -replace to be better

#################################################
#
#     WARNING:  This function will search the web for results.  
#               The intended use is for gathering quanities of website domains to block them by name.  
#               Due to the proliferation of adult sites being greater than any one person can maintain,
#               this will assist with keeping up to date lists of adult sites.  By using this, you
#               are searching for terms in DuckDuckGo that you may not want "held against" you.
#               
#         
#################################################

function getweb($termlist, $pscout) {

  Write-Output @'

WARNING:  This function will search the web for results.  
          The intended use is for gathering quanities of website domains to block them by name.  
          Due to the proliferation of adult sites being greater than any one person can maintain,
          this will assist with keeping up to date lists of adult sites.  By using this, you
          are searching for terms in DuckDuckGo that you may not want "held against" you.
'@

  $confirm = read-host 'Did you read the warning (yes/NO)'
  if ($confirm -ne "yes") {
    exit
  }

  if (test-path $psscriptroot\multipleterms.txt) {
    $termlist = gc $psscriptroot\multipleterms.txt
  }

  foreach ($term in $termlist) {
    
    $timer = (60..600) | get-random
    timeout $timer

    $websitesraw = invoke-webrequest -uri "https://html.duckduckgo.com/html?q=$term"
    
    if (!(test-path /temp)) {
        new-item /temp -itemtype directory
        $createdtemp = $true
    }
    else {
        $createdtemp = $false
    }
    $websitesraw.links | out-file /temp/out.txt
    
    $startchar   = '%3A%2F%2F'
    $endchar     = '%2F'
    
    $websiteslinks = (gc /temp/out.txt) `
        -replace '^.*?(?=%3A%2F%2F)', ''  `
        -replace $startchar, ''           `
        -replace '%2F.*$', ''             `
        -replace $endchar, ''             `
        -replace '<a.*$', ''              `
        -replace '%2D', '-'
    $websitesimage = $websitesraw.images.outerhtml                                                                            `
        -replace '<img class="result__icon__img" width="16" height="16" alt="" src="//external-content.duckduckgo.com/ip3/', '' `
        -replace '.ico" name="i15" />', ''                                                                                      `
        -replace '<img src="//duckduckgo.com/t/sl_h"/>', ''                                                                     `
        -replace '%2D', '-'

    if ($createdtemp) {
        remove-item /temp -recurse -force
    }

    if ($pscout) {

        $out = [pscustomobject]@{
        generallinks = $websiteslinks
        imagelinks   = $websitesimage
        }

        return $out
    }
    else {
        $websiteslinks | out-file $home\desktop\Domains_of_Evil.txt -append
        $websitesimage | out-file $home\desktop\Domains_of_Evil.txt -append
    }
  }

  
  # need to replace 'outerHTML' and '---------' can do it manually later
  # also need to insert the actual format for pihole, i.e. 0.0.0.0 <domain>

  (gc $home\desktop\Domains_of_Evil.txt) | select -unique | sort | set-content $home\desktop\Domains_of_Evil.txt
  write-output "done"

}

#fin