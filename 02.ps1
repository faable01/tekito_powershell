<#
.Description
引数に指定した縦横のグリッド数に応じて、ボタンだけで構成されたフォームをつくる
※注意：powershellのfunctionは 【create(2, 3)】 という形式ではなく 【create 2 3】 という形式で使用する
#>
function create($y_num, $x_num) {

  Add-Type -AssemblyName System.Windows.Forms

  # フォーム設定
  $frm = New-Object System.Windows.Forms.Form
  $frm.Text = "powershell_gui_02"
  $frm.ClientSize = [System.Drawing.Size]::new(800, 800)  # "ClientSize" doesn't mean "Window Size"
  $frm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
  $frm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

  # ボタン数カウント
  $count = 1

  # ターンカウント
  $frm | Add-Member -NotePropertyName turn -NotePropertyValue 1

  $btn_list = New-Object System.Collections.ArrayList

  1..$y_num | % {  # 縦列のループ

    # 縦ループの回数（「何行目か」を示す）
    $_y = $_

    1..$x_num | % {  # 横列のループ

      # 横ループの回数（「何列目か」を示す）
      $_x = $_

      $btn = New-Object System.Windows.Forms.Button
      $btn.Text = "button$($count)"
      $btn.BackColor = [System.Drawing.Color]::teal
      $btn.Top = $frm.ClientRectangle.Height / $y_num * ($_y - 1)
      $btn.Left = $frm.ClientRectangle.Width / $x_num * ($_x - 1)
      $btn.Height = $frm.ClientRectangle.Height / $y_num
      $btn.Width = $frm.ClientRectangle.Width / $x_num
      $btn | Add-Member -NotePropertyName index -NotePropertyValue ($count-1)

      # クリックイベントハンドラの設定 ※スクリプトブロック内は外部と別スコープ。外から内に持ってくることはできるが、内から外に影響を及ぼせるのはオブジェクトのプロパティだけ（という気がする）
      $btn.Add_Click({
        
        # $thisで自分自身（ボタン）を、$_でイベントを発生させた主体（マウスなど）を取得できる
        Write-Host "$($frm.turn)ターン目_クリックしたインデックス：$($this.index)"

        if ($frm.turn % 2 -ne 0) {  # 先行
          $my_color = [System.Drawing.Color]::SlateGray
          $your_color = [System.Drawing.Color]::MintCream
        
        } else {  # 後攻
          $my_color = [System.Drawing.Color]::MintCream
          $your_color = [System.Drawing.Color]::SlateGray
        
        }

        if ($this.BackColor -eq [System.Drawing.Color]::teal) {  # 初期状態：敵の色を挟めたら塗れる
          
          $scriptblock = { param($num)
            $n_list = New-Object System.Collections.ArrayList
            $n = $this.index + $num
            while ($n -ge 0) {
              $n_list.Add($n)
              $n = $n + $num
            }
            if ($btn_list[$n_list[0]].BackColor -eq $your_color) {
            
              $done = $false
              $l = New-Object System.Collections.ArrayList
              $n_list.RemoveAt(0)
              $n_list | % {
                $l.Add($_)
                if ((-not $done) -and $btn_list[$_].BackColor -eq $my_color) {
                  $this.BackColor = $my_color
                  $l | % {
                    $btn_list[$_].BackColor = $my_color
                  }
                  $done = $true
                }
              }
            }
          }
          

          # 上：-$x_num
          # 下：+$x_num
          # 左：-1
          # 右：+1
          # 左上：-$x_num-1
          # 左下：+$x_num-1
          # 右上：-$x_num+1
          # 右下：+$x_num+1

          # 上方向のチェック
          & $scriptblock (-$x_num)

          ## 下方向のチェック
          #& $scriptblock (+$x_num)
          #
          ## 左方向のチェック
          #& $scriptblock (-1)
          #
          ## 右方向のチェック
          #& $scriptblock (+1)
          #
          ## 左上方向のチェック
          #& $scriptblock (-$x_num-1)
          #
          ## 左下方向のチェック
          #& $scriptblock (+$x_num-1)
          #
          ## 右上方向のチェック
          #& $scriptblock (-$x_num+1)
          #
          ## 右下方向のチェック
          #& $scriptblock (+$x_num+1)

        }

        # ターン経過
        Write-Host "ターン経過($($frm.turn))"
        $frm.turn++
      })

      $frm.Controls.Add($btn)
      $null = $btn_list.Add($btn)
      $count++
    
    }
  }

  $btn_list[$x_num*$y_num/2-$x_num/2-1].BackColor = [System.Drawing.Color]::SlateGray
  $btn_list[$x_num*$y_num/2-$x_num/2].BackColor = [System.Drawing.Color]::SlateGray
  $btn_list[$x_num*$y_num/2+$x_num/2-1].BackColor = [System.Drawing.Color]::MintCream
  $btn_list[$x_num*$y_num/2+$x_num/2].BackColor = [System.Drawing.Color]::MintCream

  # フォーム表示
  $frm.ShowDialog()
  $frm.Focus()
}