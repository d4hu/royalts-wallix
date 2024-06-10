# RoyalTS Wallix Dynamic Folder
A dynamic folder for [RoyalTS or RoyalTSX](https://www.royalapps.com/) apps that automatically pull targets from Wallix Admin Bastion API.

## Requirements
- Powershell 5.0 or above
- RoyalTS(X) 6.2 or above

## How to
1. Download the lastest [release](https://github.com/d4hu/royalts-wallix/releases)
2. Open RoyalTS app
3. Create a new document
4. Edit the properties of the document and setup encryption in security tab
5. Save the document in a safe place
6. Select "File" -> "Import" -> "Dynamic Folder" and open "WallixAdminBastion.rdfx" file
7. Edit the properties of "Wallix Admin Bastion" dynamic folder
8. Go to "Credentials" pane and provide valid credentials for Wallix Admin Bastion. Make sure to use the full qualified user name (eg. john.do@internaldomain.com)
9. Go to "Custom Properties" pane and provide Wallix Bastion FQDN (eg. bastion.domain.com)
10. Apply and close properties
11. Make right click on Wallix Bastion dynamic folder and select "Reload".
