with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Chat_Messages;
with Client_Collections;
with Ada.Command_Line;

procedure Chat_Server_2 is
   package LLU renames Lower_Layer_UDP;
	package ATIO renames Ada.Text_IO;
   package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;
	package CC renames Client_Collections;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Buffer: aliased LLU.Buffer_Type(1024);
   Request: ASU.Unbounded_String;
   Reply: ASU.Unbounded_String;
	Maquina: ASU.Unbounded_String := ASU.To_Unbounded_String(LLU.Get_Host_Name);
	IP: String := LLU.To_IP(ASU.To_String(Maquina));
	Expired: Boolean;
	Mess: CM.Message_Type;
	Nick: ASU.Unbounded_String;
	Reader_List: CC.Collection_Type;
	Writer_List: CC.Collection_Type;
	Collection: ASU.Unbounded_String;
	--Max_Client: Integer := 50;
	--Min_Client: Integer := 2;
	Max_Clients: Integer;

begin

	Max_Clients:= ACL.Argument(2);
	if Max_Clients < 2 or Max_Clients > 50 then
		ATIO.Put_Line("2 < Number of clients < 50");
		LLU.Finalize;
	end if;

   -- construye un End_Point en una dirección y puerto concretos:
	--IP: la de la maquina en la que se ejecute el programa
	--Puerto: el que se le pasa por la linea de comandos
   Server_EP := LLU.Build (IP, Integer'Value(ACL.Argument(1)));

   LLU.Bind (Server_EP, Server_Handler.Handler'Access);

   loop
      LLU.Reset(Buffer);
      LLU.Receive (Server_EP, Buffer'Access, 1000.0, Expired);

      if Expired then
         Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
      else
			Mess := CM.Message_Type'Input(Buffer'Access);
			if Mess = CM.Init then
				Client_EP := LLU.End_Point_Type'Input(Buffer'Access);
				Nick := ASU.Unbounded_String'Input(Buffer'Access);
				if Nick = "reader" then
					CC.Add_Client(Reader_List, Client_EP, Nick, False);
					ATIO.Put_Line("INIT received from " & ASU.To_String(Nick));
				elsif Nick /= "reader" then
					begin
						CC.Add_Client(Writer_List, Client_EP, Nick, True);
						ATIO.Put_Line("INIT received from " & ASU.To_String(Nick));
         			LLU.Reset (Buffer);
						Mess := CM.Server;
						CM.Message_Type'Output(Buffer'Access, Mess);
         			ASU.Unbounded_String'Output (Buffer'Access, ASU.To_Unbounded_String("server"));
						Reply := ASU.To_Unbounded_String(ASU.To_String(Nick)
																	& " joins the chat");
         			ASU.Unbounded_String'Output (Buffer'Access, Reply);
						CC.Send_To_All(Reader_List, Buffer'Access);
						exception
							when CC.Client_Collection_Error =>
								ATIO.Put_Line("INIT received from " & ASU.To_String(Nick)
													& ". IGNORED, nick already used");
					end;
				end if;
			elsif Mess = CM.Writer then
				Client_EP := LLU.End_Point_Type'Input(Buffer'Access);
				Reply := ASU.Unbounded_String'Input(Buffer'Access);
				begin
					Nick := CC.Search_Client(Writer_List, Client_EP);
					ATIO.Put_Line("Writer received from " & ASU.To_String(Nick)
										& ": " & ASU.To_String(Reply));
         		LLU.Reset (Buffer);
					Mess := CM.Server;
					CM.Message_Type'Output(Buffer'Access, Mess);
					ASU.Unbounded_String'Output(Buffer'Access, Nick);
					ASU.Unbounded_String'Output(Buffer'Access, Reply);
					CC.Send_To_All(Reader_List, Buffer'Access);
					Collection := ASU.To_Unbounded_String(CC.Collection_Image(Writer_List));
					exception
						when CC.Client_Collection_Error =>
							ATIO.Put_Line("WRITER received from unknown client. IGNORED");
				end;
			end if;
      end if;
   end loop;

exception
   when Ex:others =>
      ATIO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Server_2;
