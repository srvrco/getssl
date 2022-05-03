# Generate PFX for IIS (Internet Information Service)

# Load libraries
#Add-Type -AssemblyName 'C:\Windows\System32\inetsrv\Microsoft.Web.Administration.dll'
using assembly C:\Windows\System32\inetsrv\Microsoft.Web.Administration.dll

$FullDomain = $args[0]
$DebugPreference = "Continue"
# $DebugPreference="SilentlyContinue"
$IIS_SiteName = $args[1]
$Path = $args[2]
# Files

$PfxFile = "$Path$FullDomain.pfx"
$CrtFile = "$Path$FullDomain.crt"
$KeyFile = "$Path$FullDomain.key"

Write-Debug "Generating pfx certificate"
openssl pkcs12 -inkey "$KeyFile" -in "$CrtFile" -password pass:$FullDomain -export -out "$PfxFile"

# Delete old certificate and install the new PFX Certificate

# Get all certificates
$Store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "LocalMachine")
$Store.Open("MaxAllowed")      

# Loop over all and delete matching certificate for the current domain

$Ssc = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection

for ($i = 0; $i -lt $Store.Certificates.Count; $i++) {
	
	$Item = $Store.Certificates.Item($i)

	if ($Item.subject.Contains($FullDomain)) {

		Write-Debug "Adding $FullDomain certificate for deletion!"		
		$result=$Ssc.Add($Item)
	}
}

for ($i = 0; $i -lt $Ssc.Count; $i++) {

	Write-Debug "Deleting $FullDomain certificate!"

	$Store.RemoveRange($Ssc.Item($i))
}


# $X509KeyStorageFlags Enums
$X509KeyStorageFlagsExportable = 4
$X509KeyStorageFlagsPersistKeySet = 16
$X509KeyStorageFlagsMachineKeySet = 2

<# 
$X509KeyStorageFlagsDefaultKeySet=0
$X509KeyStorageFlagsUserKeySet=1
$X509KeyStorageFlagsUserProtected=8
$X509KeyStorageFlagsEphemeralKeySet=32
#>

# Prepare for loading new certificated
$PFXCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($PfxFile, $FullDomain, 
	(
		$X509KeyStorageFlagsExportable + 
		$X509KeyStorageFlagsPersistKeySet + 
		$X509KeyStorageFlagsMachineKeySet
	)
)

#Save New Cert
$Store.Add($PFXCert);
$Store.Close();

# IIS Binding - Need to rebind the domain to the new certificate
$Manager = New-Object Microsoft.Web.Administration.ServerManager
$Site = $Manager.Sites[$IIS_SiteName] 


for ($i = 0; $i -lt $Site.Bindings.Count; $i++) {
	
	$Bind = $Site.Bindings.Item($i);

	$Protocol = $Bind.Protocol
	$hostname = $Bind.Host

	if ($Protocol -eq "https") {
		Write-Debug "Binding ${protocol}://${hostname}"
		$Bind.CertificateHash = $PFXCert.GetCertHash()
	}
}

$Manager.CommitChanges()

Write-Debug "PFX complete!"