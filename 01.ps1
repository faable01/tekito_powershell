Add-Type -AssemblyName System.Windows.Forms

# 現在のパス
$path = (pwd).Path

# フォーム設定
$frm = New-Object System.Windows.Forms.Form
$frm.Text = "powershell_gui_01"
$frm.ClientSize = [System.Drawing.Size]::new(800, 800)  # "ClientSize" doesn't mean "Window Size"
$frm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
$frm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# ボタン１設定
$btn1 = New-Object System.Windows.Forms.Button
$btn1.Text = "button1"
$btn1.Top = 0
$btn1.Left = 0
$btn1.Width = $frm.ClientRectangle.Width * 0.5
$btn1.Height = $frm.ClientRectangle.Height * 0.5
$btn1.Add_Click({
    #$frm.Close()
    Write-Host $btn1.ClientRectangle.Height
    Write-Host $btn1.ClientRectangle.Width
})

# ボタン２設定
$btn2 = New-Object System.Windows.Forms.Button
$btn2.Text = "button2"
$btn2.Top = 0
$btn2.Left = $frm.ClientRectangle.Width * 0.5
$btn2.Width = $frm.ClientRectangle.width * 0.5
$btn2.Height = $frm.ClientRectangle.Height * 0.5
$btn2.Add_Click({
    Write-Host $btn2.ClientRectangle.Height
    Write-Host $btn2.ClientRectangle.Width
})

# ボタン３設定
$btn3 = New-Object System.Windows.Forms.Button
$btn3.Text = "button3"
$btn3.Top = $frm.ClientRectangle.Height * 0.5
$btn3.Left = 0
$btn3.Width = $frm.ClientRectangle.width * 0.5
$btn3.Height = $frm.ClientRectangle.Height * 0.5
$btn2.Add_Click({
    Write-Host $btn3.ClientRectangle.Height
    Write-Host $btn3.ClientRectangle.Width
})

# ボタン４設定
$btn4 = New-Object System.Windows.Forms.Button
$btn4.Text = "button4"
$btn4.Top = $frm.ClientRectangle.Height * 0.5
$btn4.Left = $frm.ClientRectangle.Width * 0.5
$btn4.Width = $frm.ClientRectangle.width * 0.5
$btn4.Height = $frm.ClientRectangle.Height * 0.5
$btn2.Add_Click({
    Write-Host $btn4.ClientRectangle.Height
    Write-Host $btn4.ClientRectangle.Width
})

# 部品の配置と表示
$frm.Controls.Add($btn1)
$frm.Controls.Add($btn2)
$frm.Controls.Add($btn3)
$frm.Controls.Add($btn4)
$frm.ShowDialog()
$frm.Focus()