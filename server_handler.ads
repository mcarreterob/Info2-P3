with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Ada.Command_Line;
with Ada.Calendar;
with Maps_G;

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

	type Client_Data is record
		Client_EP_Handler: LLU.End_Point_Type;
		Last_Connection: Ada.Calendar.Time;
	end record;

   package Inactive_Clients is new Maps_G (Key_Type => ASU.Unbounded_String,
                                           Value_Type => Ada.Calendar.Time,
                                           Max_Size => 150,
                                           "=" => ASU."=");

   package Active_Clients is new Maps_G (Key_Type => ASU.Unbounded_String,
                                         Value_Type => Client_Data,
                                         Max_Size => Integer'Value(ACL.Argument(2)),
                                         "=" => ASU."=");



   --TABLA DE SIMBOLOS
   Map_Active: Active_Clients.Map;
   Map_Inactive: Inactive_Clients.Map;

   procedure Handler (From: in LLU.End_Point_Type;
                     To: in LLU.End_Point_Type;
                     P_Buffer: access LLU.Buffer_Type);
end Server_Handler;
