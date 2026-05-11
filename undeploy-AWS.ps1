param ([string]$DeployName,[string]$dbType,[string]$Hostnames) 
# Usage: undeploy.ps1 appdev001 sql/oracle

# Input Parameters  
$fileShareName="//filedomain.fileshare.com/share" #For future use

if(-not($DeployName)) { Throw "You must supply a DeployName parameter (eg appdev001)" }
if(-not($dbType)) {Throw "You must supply a DB Type parameter (eg: .\undeploy.ps1 appdev001 sql)" }
if(-not($Hostnames)) { Throw "You must supply a DB Host parameter" }
$sqlQuery = "exec sp_drop_account('$deployName'); 
			 exit"

kubectl delete secret opcenter-app-server-tls -n $DeployName
kubectl delete secret opcenter-portal-tls -n $DeployName
helm uninstall $DeployName-deploy --namespace $DeployName 
helm uninstall $DeployName-dbcreate --namespace $DeployName
helm uninstall $DeployName-config --namespace $DeployName
kubectl delete namespace $DeployName
$DeployName = $DeployName.ToUpper()
if($dbType -eq "sql") {
	sqlcmd -S $Hostnames -U sa -P "Password" -Q "EXEC SP_DROP_ACCOUNT '$deployName'"
}
else {
	$sqlQuery | sqlplus -S sys/'Password'@OracleServerName:1521/opcenter as sysdba   #TODO : ORACLE PARAMETER
}

