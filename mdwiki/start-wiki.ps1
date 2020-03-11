
New-PSDrive 'S' -PSProvider FileSystem -Root 'C:\Users\atno1\Desktop\powershell\tekito_powershell\mdwiki'
Import-Module S://Polaris/Polaris.psd1

# リクエストのBodyをJSONとして解釈するよう設定
Use-PolarisJsonBodyParserMiddleware

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

# ファイル作成
New-PolarisPostRoute -Path /api -Scriptblock {
  $item = New-Item -ItemType File "S://page/$($Request.Body.title).md"
  if ($item) {
    Set-Content -Path $item.FullName -Value $Request.Body.content -Encoding UTF8
    $Response.Send("新規作成しました：$($item.FullName)")
  } else {
    $Response.Send("")
  }
} -Force

# ファイル参照
New-PolarisGetRoute -Path /api -Scriptblock {
  $item = Get-Item "S://page/$($Request.Query['title']).md"
  if ($item) {
    $Response.Send((Get-Content $item.FullName -Encoding UTF8) -join "`n")
  } else {
    $Response.Send("")
  }
} -Force

# ファイル更新
New-PolarisPutRoute -Path /api -Scriptblock {
  $item = Get-Item "S://page/$($Request.Body.title).md"
  if ($item) {
    Set-Content -Path $item.FullName -Value $Request.Body.content -Encoding UTF8
    $Response.Send("更新しました：$($item.FullName)")
  } else {
    $Response.Send("")
  }
} -Force

# ファイル削除
New-PolarisDeleteRoute -Path /api -Scriptblock {
  $item = Get-Item "S://page/$($Request.Body.title).md"
  if ($item) {
    Remove-Item $item.FullName
    $Response.Send("削除しました：$($item.FullName)")
  } else {
    $Response.Send("")
  }
} -Force

# index.md参照（必須ファイルなので参照と更新のみ. 削除と作成のメソッドは不要）
New-PolarisGetRoute -Path /api/index -Scriptblock {
  $item = Get-Item "S://index.md"
  if ($item) {
    $Response.Send((Get-Content $item.FullName -Encoding UTF8) -join "`n")
  } else {
    $Response.Send("")
  }
} -Force

# index.md更新（必須ファイルなので参照と更新のみ. 削除と作成のメソッドは不要）
New-PolarisPutRoute -Path /api/index -Scriptblock {
  $item = Get-Item "S://index.md"
  if ($item) {
    Set-Content -Path $item.FullName -Value $Request.Body.content -Encoding UTF8
    $Response.Send("更新しました：$($item.FullName)")
  } else {
    $Response.Send("")
  }
} -Force


# wiki起動
$app = Start-Polaris -Port 8099 -MinRunspaces 2 -MaxRunspaces 10 -Verbose

# ブラウザ起動
start http://localhost:8099/wiki