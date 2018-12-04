with Ada.Command_Line;
with Ada.Text_IO;
with Lower_Layer_UDP;

package Arguments_Control is
   package ACL renames Ada.Command_Line;
   package ATIO renames Ada.Text_IO;
   package LLU renames Lower_Layer_UDP;

   function Max_Clients_Arg return Integer;
end Arguments_Control;
