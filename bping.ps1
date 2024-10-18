# Process command-line arguments
if ($args.Count -eq 0) {
    # Default IP list when no arguments are provided
    $ipList = "8.8.8.8,8.8.4.4"
    $threshold = $null  # No threshold (no sound)
} elseif ($args.Count -eq 1) {
    # If only the IP list is provided as an argument
    $ipList = $args[0]
    $threshold = $null  # No threshold (no sound)
} elseif ($args.Count -eq 2) {
    # If both IP list and threshold are provided as arguments
    $ipList = $args[0]
    $threshold = [int]$args[1] # Set threshold
} else {
    Write-Host "Usage: script.ps1 <ipList> <optional: responseTimeThreshold>"
    exit
}

# Split the IP address list by commas and trim (remove extra spaces)
$ipAddresses = $ipList -split ',' | ForEach-Object { $_.Trim() }

# Monitoring interval (seconds)
$interval = 1

# Function to append date to the log file name
function Get-LogFilePath {
    $date = Get-Date -Format "yyyy-MM-dd"
    $logFile = ".\ping_log_$date.txt" # Modify log file save location as needed
    return $logFile
}

# Function to play sound when ping fails
function Play-AlertSound {
    [console]::beep(1000, 500)
}

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    # Get the current time and write the message to the log
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    $logFile = Get-LogFilePath
    Add-Content -Path $logFile -Value $logEntry
    return $logEntry # Return for display purposes
}

# Function to determine color based on response time
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

# Main loop
while ($true) {
    foreach ($ip in $ipAddresses) {
        try {
            # Add ErrorAction to Test-Connection to catch errors
            $pingResults = Test-Connection -ComputerName $ip -Count 1 -ErrorAction Stop

            if (-not $pingResults) {
                # Message when ping fails (red color)
                $logEntry = Log-Message "Ping failed: $ip"
                Write-Host $logEntry -ForegroundColor Red
                Play-AlertSound
            } else {
                # Message when ping succeeds
                $time = $pingResults.ResponseTime
                $ttl = $pingResults.TimeToLive
                $color = Get-Color -responseTime $time
                $logEntry = Log-Message "Ping succeeded: $ip, time=$time ms, TTL=$ttl"
                Write-Host $logEntry -ForegroundColor $color

                # If threshold is set and response time exceeds it, play sound
                if ($threshold -ne $null -and $time -gt $threshold) {
                    Play-AlertSound
                }
            }
        } catch {
            # Error handling
            $logEntry = Log-Message "Error: Unable to ping $ip"
            Write-Host $logEntry -ForegroundColor Red
            Play-AlertSound
        }
    }
    Start-Sleep -Seconds $interval
}
