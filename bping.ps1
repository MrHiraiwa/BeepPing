# コマンドライン引数を処理
if ($args.Count -eq 0) {
    # 引数が指定されていない場合のデフォルトIPリスト
    $ipList = "8.8.8.8,8.8.4.4"
    $threshold = $null  # 閾値なし（音を鳴らさない）
} elseif ($args.Count -eq 1) {
    # 引数がIPリストのみ指定された場合
    $ipList = $args[0]
    $threshold = $null  # 閾値なし（音を鳴らさない）
} elseif ($args.Count -eq 2) {
    # 引数にIPリストと閾値が指定された場合
    $ipList = $args[0]
    $threshold = [int]$args[1] # 閾値を設定
} else {
    Write-Host "Usage: script.ps1 <ipList> <optional: responseTimeThreshold>"
    exit
}

# IPアドレスリストをカンマで分割してトリム（余分なスペースを除去）
$ipAddresses = $ipList -split ',' | ForEach-Object { $_.Trim() }

# 監視間隔（秒）
$interval = 1

# ログファイル名に日付を付ける関数
function Get-LogFilePath {
    $date = Get-Date -Format "yyyy-MM-dd"
    $logFile = ".\ping_log_$date.txt" # ログファイルの保存場所を適宜変更
    return $logFile
}

# Pingが失敗した場合に音を鳴らす関数
function Play-AlertSound {
    [console]::beep(1000, 500)
}

# ログを残す関数
function Log-Message {
    param (
        [string]$message
    )
    # 現在時刻を取得してメッセージと共にログに書き込み
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    $logFile = Get-LogFilePath
    Add-Content -Path $logFile -Value $logEntry
    return $logEntry # 表示用に返す
}

# 応答時間に応じて色を決定する関数
function Get-Color {
    param (
        [int]$responseTime
    )
    if ($responseTime -le 10) {
        return "White"
    } elseif ($responseTime -le 30) {
        return "Cyan"
    } elseif ($responseTime -le 50) {
        return "Green"
    } elseif ($responseTime -le 100) {
        return "Yellow"
    } else {
        return "Red"
    }
}

# メインのループ
while ($true) {
    foreach ($ip in $ipAddresses) {
        try {
            # Test-Connection に ErrorAction を追加してエラーをキャッチ可能にする
            $pingResults = Test-Connection -ComputerName $ip -Count 1 -ErrorAction Stop

            if (-not $pingResults) {
                # Ping失敗時のメッセージ（赤色）
                $logEntry = Log-Message "Ping failed: $ip"
                Write-Host $logEntry -ForegroundColor Red
                Play-AlertSound
            } else {
                # Ping成功時のメッセージ
                $time = $pingResults.ResponseTime
                $ttl = $pingResults.TimeToLive
                $color = Get-Color -responseTime $time
                $logEntry = Log-Message "Ping succeeded: $ip, time=$time ms, TTL=$ttl"
                Write-Host $logEntry -ForegroundColor $color

                # 閾値が設定されている場合、かつ応答時間が閾値を上回る場合にビープ音を鳴らす
                if ($threshold -ne $null -and $time -gt $threshold) {
                    Play-AlertSound
                }
            }
        } catch {
            # エラー発生時の処理
            $logEntry = Log-Message "Error: Unable to ping $ip"
            Write-Host $logEntry -ForegroundColor Red
            Play-AlertSound
        }
    }
    Start-Sleep -Seconds $interval
}

