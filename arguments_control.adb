package body Arguments_Control is
   function Max_Clients_Arg return Integer is
      Max_Clients: Integer;
   begin
      Max_Clients := Integer'Value(ACL.Argument(2));
      return Max_Clients;
      exception
      	When CONSTRAINT_ERROR =>
            return 0;
   end Max_Clients_Arg;
end Arguments_Control;
