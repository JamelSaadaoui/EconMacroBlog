** Setup program to install required packages

if _rc == 111 {
	quietly cap ado uninstall grc1leg.pkg
    quietly net install grc1leg.pkg
    }

