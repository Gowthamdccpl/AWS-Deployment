param ([string]$deployName,[string]$dbType,[string]$inlineSpc,[string]$Version)
# Usage: deploy.ps1 appdev001 sql/oracle
# Usage: deploy.ps1 appdev001 sql/oracle N 8.9.7 (if you are providing version dbType is mandatory)

#TODO: Add this hostname to hosts automatically
Write-Host "Confirm that $deployName-app.opcentercore.com is in this machine's hosts file (and an ipconfig /flushdns is done)..."
Write-Host -NoNewLine "Press Enter to continue the deployment ..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

[String]$CTTDir = "C:\Program Files\Opcenter Execution Core\Transaction Tester\"
[String]$CTTScriptDir = "C:\ALMFiles\CTT\QA Test Scripts\"
if(-not($deployName)) { Throw "You must supply a DeployName parameter (eg: .\deploy.ps1 appdev001)" }
if(-not($dbType)) {Throw "You must supply a dbType parameter (eg: .\deploy.ps1 appdev001 sql/oracle)" }
if(-not($inlineSpc)) { Throw "You must supply an InLineSpc Installation parameter (eg: Y/N)" }
if(-not($Version)) {$Version = "8.9"}
$deployName = $deployName.ToLower()# Some Kubernetes objects must be lower case
$dbType = $dbType.ToLower()
$inlineSpc = $inlineSpc.ToLower()
$sqlQuery = "exec sp_create_account('$deployName'); 
			 exit"
if($dbType -eq 'sql') {
	$dbHost = 'SQLServerName'
	$dbPort = 1433
	$dbType = 'SQLServer'
	$dbName = $deployName
	}
else {
	$dbHost = 'OracleServerName'
	$dbPort = 1521
	$dbType = 'Oracle'
	$dbName = 'opcenter'
	}

$LicenseServer = "29000@salt-license-server.shared.svc.cluster.local"
$enableInlineSpc = "False"

if($inlineSpc -eq 'y')
{
	$enableInlineSpc = "True"	
}

Function RunCTT
{
   Param (
     [string]$scriptName,
	 [string]$hostName
   ) 
	Write-Host "Running CTT script $scriptName ..."
	[String]$CTTDir = "C:\Program Files\Opcenter Execution Core\Transaction Tester"

	$scriptFile = resolve-path($scriptName)
	[String]$outputFile = $scriptFile.Path

	[xml]$XmlDocument = Get-Content -Path $scriptFile
	$XmlDocument.CamstarLoadTester.Host = "$hostName-app.opcentercore.com"
	$XmlDocument.CamstarLoadTester.StopOnError = "True"
	if($scriptFile -like "*SPCConfiguration*")
	{
		($XmlDocument.CamstarLoadTester.GlobalParameters.GlobalParameter | Where-Object { $_.Name -eq 'SPCCalculationAPI' }).SubstitutionValue = "http://inlinespc/InlineSPC/api/Statistic"
	}
	$XmlDocument.Save([String]$outputFile)

	$proc = (Start-Process -FilePath "$CTTDir\CamstarTransactionTesterConsole.exe" -ArgumentList "CFG=`"$scriptFile`" RUNS=1 ResultFile=`"output.csv`" CloseOnComplete=True" -Wait -NoNewWindow -PassThru)

	# TODO: Maybe parse the output file to look for "error"?
}
function Create-Deployment-Files 
{
	[String]$newFile = (Get-Content -path .\deploy-values-AWS.yaml -Raw) -replace '%DEPLOYNAME%', $deployName
	$newFile = $newFile -replace "%VER%", $Version
	$newFile = $newFile -replace "%DBType%", $dbType
	$newFile = $newFile -replace "%DBHost%", $dbHost
	$newFile = $newFile -replace "%DBPort%", $dbPort
	$newFile = $newFile -replace "%DBName%", $dbName
	$newFile = $newFile -replace "%licenseServerUrl%", $LicenseServer
	$newFile = $newFile -replace "%enableInlineSpc%", $enableInlineSpc
	Set-Content -Path ".\$deployName-values.yaml" $newFile

	[String]$newFile = (Get-Content -path .\deploy-dbcreate-values-AWS.yaml -Raw) -replace '%DEPLOYNAME%', $deployName
	$newFile = $newFile -replace "%VER%", $Version
	Set-Content -Path ".\$deployName-dbcreate-values.yaml" $newFile
}
function Create-DB-User 
{	
	echo "Creating database for user $deployName on primary node."

	sqlcmd -S SQLServerName -U sa -P "Password" -Q "EXEC SP_CREATE_ACCOUNT @pnv_ServerLogin='$deployName', @pnv_DBFilePath='C:\Data\', @pnv_LogFilePath='C:\Log\',@pnv_Recovery='Full'"
}

function Helm-Deploy
{
	kubectl create namespace $deployName
	#kubectl create namespace shared
	#helm install $deployName-shared ./opcenter-core-shared --namespace shared --values ./shared-namespace-values-AWS.yaml

	
	helm install $deployName-config ./opcenter-core-config --namespace $deployName --values ./$deployName-values.yaml 
	helm install $deployName-dbcreate ./opcenter-core-dbupdate --namespace $deployName --values ./$deployName-dbcreate-values.yaml

	echo "Waiting for DB Create to complete..."
	# # #kubectl logs -f job/$deployName-dbcreate -c dbupdate -n $deployName
	kubectl wait --for=condition=complete job/$deployName-dbcreate-opcenter-core-dbupdate -n $deployName --timeout=-1s
    helm install $deployName-deploy ./opcenter-core --namespace $deployName --values ./$deployName-values.yaml
}
function Create-TLS-Secrets
{
	kubectl create secret tls opcenter-app-server-tls --cert=.\certs\opcore.crt --key=.\certs\opcore.key -n $deployName
	kubectl create secret tls opcenter-portal-tls --cert=.\certs\opcore.crt --key=.\certs\opcore.key -n $deployName
	kubectl rollout status -n $deployName deploy/app-server
}
function Run-CTT-Scripts
{
	RunCTT -scriptName "$CTTScriptDir\1 FullQAImportlLoaderScript.cfg" -hostName $deployName
	RunCTT -scriptName "$CTTScriptDir\2 MDSLoaderScript.cfg" -hostName $deployName
	RunCTT -scriptName "$CTTScriptDir\3 QESLoaderScript.cfg" -hostName $deployName
	RunCTT -scriptName "$CTTScriptDir\4 MFGPortallLoaderScript.cfg" -hostName $deployName
	if($inlineSpc -eq 'y')
	{
		if($dbType -eq 'SQLServer')
		{
			RunCTT -scriptName "$CTTScriptDir\5 SPCConfiguration.cfg" -hostName $deployName
		}
		else
		{
			RunCTT -scriptName "$CTTScriptDir\6 SPCConfiguration.ORA.cfg" -hostName $deployName
		}
	} 
}
# TODO
#   Edit CTT scripts <HostName>
#   Run CTT scripts using CamstarTransactionTesterConsole.exe
#   DB Backup?
  Create-Deployment-Files 
  Create-DB-User 
  Helm-Deploy
  Create-TLS-Secrets
# Run-CTT-Scripts

echo "Deployment $deployName complete."