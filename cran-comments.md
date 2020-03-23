This resubmission addresses the following concerns:

>    Found the following (possibly) invalid URLs:
>      URL: https://cran.r-project.org/web/packages/birankr/index.html
>        From: README.md
>        Status: 200
>        Message: OK
>        CRAN URL not in canonical form
>      The canonical URL of the CRAN page for a package is
>        https://CRAN.R-project.org/package=pkgname
> 
>    Found the following (possibly) invalid file URIs:
>      URI: examples/Marvel_social_network.md
>        From: README.md
>      URI: birankr.pdf
>        From: README.md
>      URI: examples/Marvel_social_network.ipynb
>        From: README.md
>      URI: birankpy/README.md
>        From: README.md

Done. I have changed links in the readme to use absolute path names and I provided the canonical URL for the CRAN page. 


## Test environments
* local Windows 10 install, R 3.4.1
* x86_64-redhat-linux-gnu, R 3.5.2

## R CMD check results
There were no ERRORs, WARNINGs, or NOTEs. 

## Downstream dependencies
There are currently no downstream dependencies for this package