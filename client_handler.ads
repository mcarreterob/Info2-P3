with Lower_Layer_UDP;
with Ada.Calendar;
with Ada.Strings.Unbounded;
with Maps_G;
with Ada.Text_IO;
with Chat_Messages;

package Client_Handler is
   package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;
   package CM renames Chat_Messages;
   use type CM.Message_Type;

	--Muestra la cadena de texto recibida.
	procedure Handler_Client (From: LLU.End_Point_Type;
							  To: LLU.End_Point_Type;
							  P_Buffer: access LLU.Buffer_Type);

end Client_Handler;
