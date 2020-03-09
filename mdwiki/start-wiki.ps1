
Import-Module Polaris
New-PSDrive 'S' -PSProvider FileSystem -Root 'C:\Users\atno1\Desktop\powershell\tekito_powershell\mdwiki'

Stop-Polaris; Clear-Polaris;

# http://localhost:8099/page/ にpageディレクトリ配下のアイテムを展開
New-PolarisStaticRoute -FolderPath S://page -RoutePath /page -EnableDirectoryBrowser $True -Force

# mdwikiから読み取られる
New-PolarisGetRoute -Path /index.md -Scriptblock {
  $Response.setContentType('text/html')
  $t = (Get-Content S://index.md -Encoding UTF8) -join "`n"
  $Response.send($t)
} -Force

# mdwiki
New-PolarisGetRoute -Path /wiki -Scriptblock {
  $Response.setContentType('text/html')
  $t = (Get-Content S://mdwiki-latest-debug.html -Encoding UTF8) -join "`n"
  $Response.send($t)  
} -Force

# wiki起動
$app = Start-Polaris -Port 8099 -MinRunspaces 2 -MaxRunspaces 10 -Verbose