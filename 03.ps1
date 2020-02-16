# Polarisを触ってみる
# ---------------------------

# Polarisの導入
Import-Module Polaris

# Polarisの停止・クリア
Stop-Polaris
Clear-Polaris

# JSON => obj 変換ミドルウェアの作成
New-PolarisRouteMiddleware -Name JsonBodyParser -Scriptblock {
  if ($Request.BodyString -ne $null) {
    Write-Host "ミドルウェア実行"
    $Request.Body = $Request.BodyString | ConvertFrom-Json
  }
}

# POSTのルート作成
New-PolarisPostRoute -Path "/" -Scriptblock {
  Write-Host $Request.Body
  if ($Request.Body -ne $null -and $Request.Body.page -eq "01") {
    $Response.Send("page.01")
  } else {
    $Response.Send("none")
  }
}

# Polaris起動
Start-Polaris