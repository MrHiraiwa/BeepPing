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

# procedure

1. Enter the following command on the Powershell console to change the policy so that the script can be executed.

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

2. Move the current to the script installation folder. (The following is an example when the script location is set to c:\temp)

cd c:\temp

3. Set destination as argument and send ping
By setting the destination address as a script argument, you can change the destination each time the script is executed without editing the script. Specify multiple argument addresses separated by commas. You can also specify a name if name resolution is possible.
The following is an example of execution when arguments are given.

.\bping.ps1 8.8.8.8,google.com

4. Set destination and threshold as arguments and send ping
By setting a threshold in addition to the destination address, it is possible to make a beep sound when the response time (ms) exceeds the threshold.
The following is an example of execution when threshold value 1 "10" (ms) is given to the argument.

.\bping.ps1 8.8.8.8,google.com 10
