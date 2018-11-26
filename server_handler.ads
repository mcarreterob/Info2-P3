with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Ada.Command_Line;
with Ada.Calendar;

package Server_Handler is
   package ATIO renames Ada.Text_IO;
   package LLU renames Lower_Layer_UDP;
   package CM renames Chat_Messages;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   use type CM.Message_Type;
	use type ASU.Unbounded_String;
   use type Ada.Calendar.Time;
   use type LLU.End_Point_Type;

   procedure Handler (From: in LLU.End_Point_Type;
                     To: in LLU.End_Point_Type;
                     P_Buffer: access LLU.Buffer_Type);

   --TABLA DE SIMBOLOS
	type Client_Data is record
		Client_EP_Handler: LLU.End_Point_Type;
		Last_Connection: Ada.Calendar.Time;
	end record;

   --CLIENTES INACTIVOS: Nick, Hora y Max:
   package Inactive_Clients is new Maps_G (Key_Type => ASU.Unbounded_String,
                                           Value_Type => Ada.Calendar.Time,
                                           Max_Size => 150,
                                           "=" => ASU."=");

   --CLIENTES ACTIVOS: Nick, (EP_Handler, Hora) y Max:
   package Active_Clients is new Maps_G (Key_Type => ASU.Unbounded_String,
                                         Value_Type => Client_Info,
                                         Max_Size => Integer'Value(CL.Argument(2)),
                                         "=" => ASU."=");



   Map_Active: Active_Clients.Map;
   Map_Inactive: Inactive_Clients.Map;
end Server_Handler;
