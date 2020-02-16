# Universal Dashboard使ってみる
# 
# コード引用元：
#  【PowerShell だけでダッシュボート Web アプリが作れる】
#  https://qiita.com/nimzo6689/items/f9d107c30b1012fb6e32

$dashboard = New-UDDashboard -Title "Hardware Capacity" -Content {

    New-UDLayout -Columns 2 {

        $cpuMonitorSettings = @{
            Title                = "CPU (% processor time)"
            Type                 = 'Line'
            DataPointHistory     = 40
            RefreshInterval      = 4
            ChartBackgroundColor = '#804ca6ae'
            ChartBorderColor     = '#ff4ca6ae'
            Endpoint             = {
                try {
                    (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue | Out-UDMonitorData
                } catch {
                    -1 | Out-UDMonitorData
                }
            }
        }

        New-UDMonitor @cpuMonitorSettings

        New-UDChart -Title "C Drive Disk Space" -Type Doughnut -Endpoint {

            $chartDataSettings = @{
                DataProperty         = "Data"
                LabelProperty        = "Label"
                BackgroundColor      = @("#80db3e23", "#80f4c5bd")
                HoverBackgroundColor = @("#80db3e23", "#80f4c5bd")
                BorderColor          = @("#80db3e23", "#80f4c5bd")
                HoverBorderColor     = @("#db3e23", "#f4c5bd")
            }

            try {
                Get-PSDrive -Name C | ForEach-Object {
                    @(
                        [PSCustomObject]@{
                            Label = "Used Space"
                            Data  = [Math]::Round(($_.Used) / 1GB, 2);
                        },
                        [PSCustomObject]@{
                            Label = "Free Space"
                            Data  = [Math]::Round($_.Free / 1GB, 2);
                        }
                    ) | Out-UDChartData @chartDataSettings
                }
            } catch {
                0 | Out-UDChartData -DataProperty "Data" -LabelProperty "Label"
            }
        }
    }

}

Start-UDDashboard -Dashboard $dashboard -Port 1000