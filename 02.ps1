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
  $turn = 1

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

      # クリックイベントハンドラの設定
      $btn.Add_Click({
        
        # $thisで自分自身（ボタン）を、$_でイベントを発生させた主体（マウスなど）を取得できる
        Write-Host $this.index

        # 上：-$x_num
        # 下：+$x_num
        # 左：-1
        # 右：+1
        # 左上：-$x_num-1
        # 左下：+$x_num-1
        # 右上：-$x_num+1
        # 右下：+$x_num+1

        if ($turn % 2 -ne 0) {  # 先行
          $your_color = [System.Drawing.Color]::SlateGray
        
        } else {  # 後攻
          $your_color = [System.Drawing.Color]::MintCream
        
        }

        if ($this.BackColor -eq [System.Drawing.Color]::teal) {  # 初期状態：敵の色を挟めたら塗れる
          
          # 上のチェック


          $this.BackColor = $your_color
        
        } elseif ($this.BackColor -eq [System.Drawing.Color]::MintCream) {
          $this.BackColor = [System.Drawing.Color]::SlateGray

        } else {
          $this.BackColor = [System.Drawing.Color]::SlateGray
        }

        # ターン経過
        $turn++
      })

      $frm.Controls.Add($btn)
      $null = $btn_list.Add($btn)
      $count++
    
    }
  }

  # フォーム表示
  $frm.ShowDialog()
  $frm.Focus()
}