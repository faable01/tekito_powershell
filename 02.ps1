<#
.Description
引数に指定した縦横のグリッド数に応じて、ボタンだけで構成されたフォームをつくる
※注意：powershellのfunctionは 【create(2, 3)】 という形式ではなく 【create 2 3】 という形式で使用する
#>
function create($y_num, $x_num) {

  Add-Type -AssemblyName System.Windows.Forms

  # クライアント領域の縦の長さ
  $y_size = 800

  # クライアント領域の横の長さ
  $x_size = 800

  # フォーム設定
  $frm = New-Object System.Windows.Forms.Form
  $frm.Text = "powershell_gui_02"
  $frm.ClientSize = [System.Drawing.Size]::new($x_size, $y_size)  # "ClientSize" doesn't mean "Window Size"
  $frm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
  $frm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

  # コンソール用のTextBoxオブジェクト作成（ログ出力に使いたいからここに宣言する）
  $t = New-Object System.Windows.Forms.RichTextBox

  $write = { param($msg) 
    Write-Host $msg
    $t.Focus()
    $t.AppendText("`n$($msg)")  # AppendText()はTextBox内の末尾に文字列を追加するだけではなく、「末尾までスクロールする」効果もあるっぽい
  }

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
      #$btn.Text = "button$($count)"
      $btn.BackColor = [System.Drawing.Color]::teal
      $btn.Top = $frm.ClientRectangle.Height / $y_num * ($_y - 1)
      $btn.Left = $frm.ClientRectangle.Width / $x_num * ($_x - 1)
      $btn.Height = $frm.ClientRectangle.Height / $y_num
      $btn.Width = $frm.ClientRectangle.Width / $x_num
      $btn | Add-Member -NotePropertyName index -NotePropertyValue ($count-1)

      if ($_y -eq 1 -or $_y -eq $y_num -or $_x -eq 1 -or $_x -eq $x_num) {  # 壁には印（doesNotHaveNextプロパティ）をうつ
        $btn | Add-Member -NotePropertyName doesNotHaveNext -NotePropertyValue $true
      }

      # -------- AddClickここから --------
      # クリックイベントハンドラの設定 ※スクリプトブロック内は外部と別スコープ。外から内に持ってくることはできるが、内から外に影響を及ぼせるのはオブジェクトのプロパティだけ（という気がする）
      $btn.Add_Click({

        # 先行・後攻の判定と、対応する自分の色の設定（黒色：先行, 白色：後攻）
        if ($frm.turn % 2 -ne 0) {  # 先行
          $my_color = [System.Drawing.Color]::SlateGray
          $your_color = [System.Drawing.Color]::MintCream
        
        } else {  # 後攻
          $my_color = [System.Drawing.Color]::MintCream
          $your_color = [System.Drawing.Color]::SlateGray
        
        }

        ## 【デバッグ用】 クリック時にボタンごとに設定されている独自プロパティ「index」の値を出力する
        ## （$thisで自分自身（ボタン）を、$_でイベントを発生させた主体（マウスなど）を取得できる）
        #if ($my_color -eq [System.Drawing.Color]::SlateGray) {
        #  & $write "$($frm.turn)ターン目_黒がクリックしたインデックス：$($this.index)"
        #
        #} else {
        #  & $write "$($frm.turn)ターン目_白がクリックしたインデックス：$($this.index)"
        #}

        if ($this.BackColor -eq [System.Drawing.Color]::teal) {  # 初期状態：敵の色を挟めたら塗れる
          
          $this | Add-Member -Force -NotePropertyName done -NotePropertyValue $false
          $self = $this

          $scriptblock = { param($num)
            $n_list = New-Object System.Collections.ArrayList
            $n = $this.index + $num

            if ($this.doesNotHaveNext) {  # 自分自身が壁の場合
            
              if ($this.index -eq 0) {  # 左上角なら

                if (1 -eq $num) {  # 右方向チェックなら

                  while ($n -le $x_num-1) {
                    $n_list.Add($n)
                    $n = $n + $num
                  }
                
                } elseif ($x_num -eq $num) {  # 下方向チェックなら
                
                  while ($n -le $y_num*$x_num-$x_num) {
                    $n_list.Add($n)
                    $n = $n + $num
                  }

                } else {  # その他方向なら（斜め）
                  while ($n -ge 0 -and $n -le $x_num*$y_num) {
                    $n_list.Add($n)
                  
                    if ($btn_list[$n].doesNotHaveNext) {
                      break
                  
                    } else {
                      $n = $n + $num
                    }
                  }
                }
              
              } elseif ($this.index -eq $x_num-1) {  # 右上角なら
              
                if (-1 -eq $num) {  # 左方向チェックなら

                  while ($n -ge 0) {
                    $n_list.Add($n)
                    $n = $n + $num
                  }
                
                } elseif ($x_num -eq $num) {  # 下方向チェックなら
                
                  while ($n -le $y_num*$x_num-1) {
                    $n_list.Add($n)
                    $n = $n + $num
                  }

                } else {  # その他方向なら（斜め）
                  while ($n -ge 0 -and $n -le $x_num*$y_num) {
                    $n_list.Add($n)
                  
                    if ($btn_list[$n].doesNotHaveNext) {
                      break
                  
                    } else {
                      $n = $n + $num
                    }
                  }
                }
              
              } elseif ($this.index -eq $y_num*$x_num-$x_num) {  # 左下角なら
              
                if (1 -eq $num) {  # 右方向チェックなら

                  while ($n -le $y_num*$x_num-1) {
                    $n_list.Add($n)
                    $n = $n + $num
                  }
                
                } elseif (-$x_num -eq $num) {  # 上方向チェックなら
                
                  while ($n -ge 0) {
                    $n_list.Add($n)
                    $n = $n + $num
                  }

                } else {  # その他方向なら（斜め）
                  while ($n -ge 0 -and $n -le $x_num*$y_num) {
                    $n_list.Add($n)
                  
                    if ($btn_list[$n].doesNotHaveNext) {
                      break
                  
                    } else {
                      $n = $n + $num
                    }
                  }
                }
              
              } elseif ($this.index -eq $y_num*$x_num-1) {  # 右下角なら
              
                if (-1 -eq $num) {  # 左方向チェックなら

                  while ($n -ge $y_num*$x_num-$x_num) {
                    $n_list.Add($n)
                    $n = $n + $num
                  }
                
                } elseif (-$x_num -eq $num) {  # 上方向チェックなら
                
                  while ($n -ge $x_num-1) {
                    $n_list.Add($n)
                    $n = $n + $num
                  }

                } else {  # その他方向なら（斜め）
                  while ($n -ge 0 -and $n -le $x_num*$y_num) {
                    $n_list.Add($n)
                  
                    if ($btn_list[$n].doesNotHaveNext) {
                      break
                  
                    } else {
                      $n = $n + $num
                    }
                  }
                }
              
              } elseif ($this.index -lt $x_num -and (1, -1) -contains $num) {  # 上の行で横方向チェックの場合（四隅を除く）

                while ($n -ge 0 -and $n -le $x_num-1) {
                  $n_list.Add($n)
                  $n = $n + $num
                }
              
              } elseif ($this.index -ge $y_num*$x_num-$x_num -and (1, -1) -contains $num) {  # 下の行で横方向チェックの場合（四隅を除く）

                while ($n -ge $y_num*$x_num-$x_num -and $n -le $y_num*$x_num-1) {
                  $n_list.Add($n)
                  $n = $n + $num
                }
              
              } elseif ($this.index % $x_num -eq 0 -and ($x_num, -$x_num) -contains $num) {  # 左の行で縦方向チェックの場合（四隅を除く）

                while ($n -ge 0 -and $n -le $y_num*$x_num-$x_num) {
                  $n_list.Add($n)
                  $n = $n + $num
                }

              } elseif ($this.index % $x_num -eq 7 -and ($x_num, -$x_num) -contains $num) {  # 右の行で縦方向チェックの場合（四隅を除く）

                while ($n -ge $x_num-1 -and $n -le $y_num*$x_num-1) {
                  $n_list.Add($n)
                  $n = $n + $num
                }

              } else {  # 自身が壁にいることを考慮せずとも問題ない方向の場合
                while ($n -ge 0 -and $n -le $x_num*$y_num) {
                  $n_list.Add($n)

                  if ($btn_list[$n].doesNotHaveNext) {
                    break

                  } else {
                    $n = $n + $num
                  }
                }
              }

            } else {  # 自分自身は壁ではない場合
              while ($n -ge 0 -and $n -le $x_num*$y_num) {
                $n_list.Add($n)

                if ($btn_list[$n].doesNotHaveNext) {
                  break

                } else {
                  $n = $n + $num
                }
              }
            }

            if ($n_list.Length -gt 0 -and $btn_list[$n_list[0]].BackColor -eq $your_color) {  # もし隣接するマスが相手の色なら
            
              $done = $false
              $l = New-Object System.Collections.ArrayList
              $doesContinue = $true
              $n_list | % {

                if ($doesContinue -and ($my_color, $your_color) -contains $btn_list[$_].BackColor) {  # 相手か自分の色が連続する限り
                  $l.Add($_)

                } else {  # 途中でまだなにも置かれていないマスがあれば
                  $doesContinue = $false
                }
                
                if ($doesContinue -and (-not $done) -and $btn_list[$_].BackColor -eq $my_color) {
                  $this.BackColor = $my_color

                  $l | % {

                    $btn_list[$_].BackColor = $my_color
                  }
                  $done = $true
                  $self.done = $true
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
          & $scriptblock (+$x_num)
          #
          ## 左方向のチェック
          & $scriptblock (-1)
          #
          ## 右方向のチェック
          & $scriptblock (+1)
          #
          ## 左上方向のチェック
          & $scriptblock (-$x_num-1)
          #
          ## 左下方向のチェック
          & $scriptblock (+$x_num-1)
          #
          ## 右上方向のチェック
          & $scriptblock (-$x_num+1)
          #
          ## 右下方向のチェック
          & $scriptblock (+$x_num+1)

          if ($self.done) {
            # ターン経過
            & $write "ターン経過($($frm.turn))"
            if ($your_color -eq [System.Drawing.Color]::MintCream) {
              & $write "次は白の番"
            
            } else {
              & $write "次は黒の番"
            }
            $frm.turn++
            $self.done = $null
          }
        }
      })
      # -------- AddClickここまで --------

      $frm.Controls.Add($btn)
      $null = $btn_list.Add($btn)
      $count++
    
    }
  }

  $btn_list[$x_num*$y_num/2-$x_num/2-1].BackColor = [System.Drawing.Color]::SlateGray
  $btn_list[$x_num*$y_num/2-$x_num/2].BackColor = [System.Drawing.Color]::SlateGray
  $btn_list[$x_num*$y_num/2+$x_num/2-1].BackColor = [System.Drawing.Color]::MintCream
  $btn_list[$x_num*$y_num/2+$x_num/2].BackColor = [System.Drawing.Color]::MintCream

  # コンソール作成
  $frm.ClientSize = [System.Drawing.Size]::new($x_size, $y_size/4*5)
  $t.Top = $y_size
  $t.Left = 0
  $t.Height = $y_size/4
  $t.Width = $x_size
  $t.Multiline = $true
  $t.BackColor = [System.Drawing.Color]::FromArgb(75, 75, 125)
  $t.ForeColor = [System.Drawing.Color]::White
  $t.Font = [System.Drawing.Font]::new("Arial", $y_size/8/8)
  
  $frm.Controls.Add($t)

  # フォーム表示
  $frm.ShowDialog()
  $frm.Focus()
}