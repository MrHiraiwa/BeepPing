# BeepPing
Powershell that sends pings to multiple targets in a Windows environment and emits a beep when the pings fail.


# function
It has the following functions.

- It runs on a Windows terminal running Powershell.

- Periodically sends pings (icmp packets) to multiple configured IP addresses.

- If communication fails, it will be displayed in red on the Powershell console.

- If communication fails, you will be notified by a beep.

- If you set a threshold value as an argument, you will be notified with a beep sound even when the response time exceeds the threshold value.

- Records logs in a file.

- Since it is a PowerShell script, it can circumvent the customer environment's "free software is prohibited" policy.
