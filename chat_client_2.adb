with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Chat_Messages;
with Ada.Command_Line;
with Client_Handler;

procedure Chat_Client_2 is
   package CH renames Client_Handler;
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
	package ATIO renames Ada.Text_IO;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;

   Server_EP: LLU.End_Point_Type;
   Client_EP_Receive: LLU.End_Point_Type;
   Client_EP_Handler: LLU.End_Point_Type;
   Buffer: aliased LLU.Buffer_Type(1024);
   -- Request: ASU.Unbounded_String;
   Comentario: ASU.Unbounded_String;
   Expired : Boolean;
	Mess: CM.Message_Type;
	Maquina: ASU.Unbounded_String := ASU.To_Unbounded_String(ACL.Argument(1));
	Nick: ASU.Unbounded_String;
	IP: String := LLU.To_IP(ASU.To_String(Maquina));
	Puerto: Integer;
	Finish: Boolean := False;
   Acogido: Boolean;

   Usage_Error: exception;
   Name_Error: exception;
   Server_Error: exception;
   Welcomed_Error: exception;

begin
	--Maquina := ASU.To_Unbounded_String(ACL.Argument(1));
	--IP := ASU.To_String(ASU.To_Unbounded_String(LLU.To_IP(Maquina)));
	Puerto := Integer'Value(ACL.Argument(2));
	Nick := ASU.To_Unbounded_String(ACL.Argument(3));

	if ACL.Argument_Count /= 3 then
		raise Usage_Error;
	end if;

	if Nick = "server" then
		raise Name_Error;
	else
      -- EP del Server
      Server_EP := LLU.Build(IP, Puerto);
      -- Donde recibire el Welcome
      LLU.Bind_Any(Client_EP_Receive);
      -- Donde recibire mensajes del Server
      LLU.Bind_Any(Client_EP_Handler, CH.Handler_Client'Access);
   	LLU.Reset(Buffer);
		Mess := CM.Init;
		CM.Message_Type'Output(Buffer'Access, Mess);
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive);
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
   	ASU.Unbounded_String'Output(Buffer'Access, Nick);
   	LLU.Send(Server_EP, Buffer'Access);
   	LLU.Reset(Buffer);
		LLU.Receive(Client_EP_Receive, Buffer'Access, 10.0, Expired);
      Mess := CM.Message_Type'Input(Buffer'Access);
      Acogido := Boolean'Input(Buffer'Access);
      if Expired then
         raise Server_Error;
      end if;
      if Acogido then
         -- MODO ESCRITOR
         ATIO.Put_Line("Mini-Chat v2.0: Welcome " & ASU.To_String(Nick));
         while not Finish loop
            LLU.Reset(Buffer);
            ATIO.Put(">>");
            Mess := CM.Writer;
            CM.Message_Type'Output(Buffer'Access, Mess);
            LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
            ASU.Unbounded_String'Output(Buffer'Access, Nick);
            Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
            ASU.Unbounded_String'Output(Buffer'Access, Comentario);
         	LLU.Send(Server_EP, Buffer'Access);
            if Comentario = ".quit" then
               Finish := True;
               Mess := CM.Logout;
               CM.Message_Type'Output(Buffer'Access, Mess);
               LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
               ASU.Unbounded_String'Output(Buffer'Access, Nick);
            	LLU.Send(Server_EP, Buffer'Access);
               LLU.Finalize;
            end if;
         end loop;
      else
         raise Welcomed_Error;
      end if;
	end if;

   LLU.Finalize;

exception
   when Welcomed_Error =>
      ATIO.Put_Line("Mini-Chat v2.0: IGNORED new user "
                     & ASU.To_String(Nick) & ", nick already used");
      LLU.Finalize;
	when Usage_Error =>
		ATIO.Put_Line("usage: ./chat_client_2 <host_name> <port> <nick>");
		LLU.Finalize;
	when Name_Error =>
		ATIO.Put_Line("Is not allowed to use 'server' as Nick");
		LLU.Finalize;
   when Server_Error =>
      ATIO.Put_Line("Unracheable server.");
      LLU.Finalize;
   when Ex:others =>
      ATIO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Client_2;
