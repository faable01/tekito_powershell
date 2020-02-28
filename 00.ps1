# _______________________________
#
# 便利関数
# ============

# [usage] Create-List-Of-Pcl 3 (2, 1, 2) => PCL-1-1, PCL-1-2, PCL-2-1, PCL-3-1, PCL-3-2
function Create-List-Of-Pcl($maxpcl, $listOfLength) { $result = New-Object System.Collections.ArrayList; 1..$maxpcl | % { $__ = $_; $max = $listOfLength[$_-1]; 1..$max | % { $name = "PCL-$($__)-$($_)"; $null = $result.Add($name);}  }; return $result }

function grep([string]$str) {
  <#
    .SYNOPSIS
    配下ディレクトリに対してざっくりとしたgrep検索をします
    .DESCRIPTION
    再帰的に配下ディレクトリのファイルの中身を正規表現で検索し、ヒットしたファイルのパスと行数を表示します
    結果はオブジェクトとして返却しているので、各種プロパティを参照することもできる
    .PARAMETER str
    grep検索する正規表現
  #>
  Get-ChildItem -Recurse -File | ? {
    (Get-Content $_.FullName) -match $str

  } | % {
    $__=$_
    $__ | Add-Member -NotePropertyName "hit_lines" -NotePropertyValue (New-Object System.Collections.ArrayList)
    $line=0
    (Get-Content $__.FullName) | % {
      $line++
      if ((New-Object regex($str)).IsMatch($_)) {
        $__.hit_lines.Add($line)
      }
    }
    $__ | Format-Table -Property "FullName", "hit_lines"
  }
}


# _______________________________
#
# コマンド覚え書き
# =============

# コマンドの定義場所の確認
Get-Command Get-UDDashboard | Format-List

# 環境変数PATHの確認
$env:Path

# 一時的に環境変数PATHにjdk追加
$env:Path = $env:Path + "C:\pleiades\java\8\bin;"

# 一時的に環境変数JAVA_HOME設定
$env:JAVA_HOME = "C:\pleiades\java\8"


# _________________________________
#
# powershellと関係ないメモ
# ----------------------

# 研修直後につくったアプリ（spring bootのアプリは設定いじってwarにしてもwildfly10では動かない気配）
cd C:\Users\atno1\.m2\repository\com\example\Madeleine\eat01

# wildfly18の場所
cd C:\wildfly-18.0.1.Final\bin

# wildfly10の場所（Java8なら動く、9は知らない、10は不具合ある雰囲気?）
cd C:\wildfly-10.0.0.Final\bin