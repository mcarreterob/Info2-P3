package body Server_Handler is
   use type CM.Message_Type;

   procedure Send_To_All (M: in Active_Clients.Map;
                           P_Buffer: access LLU.Buffer_Type;
                           No_Send_Nick: in ASU.Unbounded_String ) is
   Cursor: Active_Clients.Cursor := Active_Clients.First(Map_Active);
   Element: Active_Clients.Element_Type;
   begin
      while Active_Clients.Has_Element(Cursor) loop
         Element := Active_Clients.Element(Cursor);
         if Element.Key /= ASU.To_String(No_Send_Nick) then
            LLU.Send (Element.Value.Client_EP_Handler, P_Buffer);
         end if;
         Active_Clients.Next(Cursor);
      end loop;
   end Send_To_All;

   procedure Handler (From: in LLU.End_Point_Type;
                     To: in LLU.End_Point_Type;
                     P_Buffer: access LLU.Buffer_Type) is
      Client_EP_Receive: LLU.End_Point_Type;
      Client_EP_Handler: LLU.End_Point_Type;
      Datos_Cliente: Client_Data; -- TABLA DE SIMBOLOS
      Mess: CM.Message_Type;
      Nick: ASU.Unbounded_String;
      Comentario: ASU.Unbounded_String;
      Acogido: Boolean := False;
      Hora_entrada: Ada.Calendar.Time;
      Full_Map:Boolean;
      Cursor: Active_Clients.Cursor;
      Oldest_Client: Active_Clients.Element_Type;
      C_Actual: Active_Clients.Element_Type;
      Success: Boolean;
   begin
      Mess:= CM.Message_Type'Input(P_Buffer);
      --ATIO.Put_line(CM.Message_Type'Image(Mess));
      if Mess = CM.Init then
         Client_EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
         Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
         Nick := ASU.Unbounded_String'Input(P_Buffer);
         LLU.Reset(P_Buffer.all);
         ATIO.Put("INIT received from " & ASU.To_String(Nick) & ": ");
         Active_Clients.Get(Map_Active, Nick, Datos_Cliente, Success);
         if not Success then
            Mess := CM.Welcome;
            CM.Message_Type'Output(P_Buffer, Mess);
            Acogido := True;
            Boolean'Output(P_Buffer, Acogido);
            LLU.Send(Client_EP_Receive, P_Buffer);
            ATIO.Put_Line("ACCEPTED");
            Comentario := ASU.To_Unbounded_String(ASU.To_String(Nick)
                                                & " joins the chat.");
            LLU.Reset(P_Buffer.all);
            Mess := CM.Server;
            CM.Message_Type'Output(P_Buffer, Mess);
            ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
            ASU.Unbounded_String'Output(P_Buffer, Comentario);
            Send_To_All(Map_Active, P_Buffer, Nick);
            Hora_entrada := Ada.Calendar.Clock;
            -- Meto los valores en la tabla
            Datos_Cliente.Client_EP_Handler := Client_EP_Handler;
            Datos_Cliente.Last_Connection := Hora_entrada;
            Full_Map := False;
            begin
               Full_Map := False;
               if Active_Clients.Map_Length(Map_Active) = 50 then
                  Full_Map := True;
               else
                  Active_Clients.Put(Map_Active, Nick, (Client_EP_Handler, Hora_entrada));
               end if;
               exception
                  when Active_Clients.Full_Map =>
                     Full_Map := True;
            end;
            if Full_Map then
               -- Fijo el cursor en el primero y lo voy moviendo con la
               -- funcion Next del paquete maps_g
               Cursor := Active_Clients.First(Map_Active);
               -- Guardo como Oldest_Client el elemento al que apunta Cursor
               Oldest_Client := Active_Clients.Element(Cursor);
               Active_Clients.Next(Cursor);
               -- Mientras la lista tenga elementos, comprobamos la
               -- ultima conexion
               while Active_Clients.Has_Element(Cursor) loop
                  C_Actual := Active_Clients.Element(Cursor);
                  if C_Actual.Value.Last_Connection < Oldest_Client.Value.Last_Connection then
                     Oldest_Client := C_Actual;
                  end if;
                  Active_Clients.Next(Cursor);
               end loop;
               LLU.Reset(P_Buffer.all);
               Mess := CM.Server;
               Comentario := ASU.To_Unbounded_String(ASU.To_String(Oldest_Client.Key)
                                                      & " banned being idle too long");
               ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
               ASU.Unbounded_String'Output(P_Buffer,Comentario);
               Send_To_All(Map_Active, P_Buffer, Oldest_Client.Key);
               Active_Clients.Delete(Map_Active, Oldest_Client.Key, Success);
               if Success then
                  begin
                     Hora_entrada := Ada.Calendar.Clock;
                     Inactive_Clients.Put(Map_Inactive, Oldest_Client.Key, Hora_entrada);
                     exception
                        when Inactive_Clients.Full_Map =>
                           ATIO.Put("Lista de clientes inactivos llena.");
                           ATIO.Put_Line("No se ha podido añadir");
                  end;
               end if;
            end if;
         else
            ATIO.Put_Line("IGNORED. Nick already used.");
            LLU.Reset(P_Buffer.all);
            CM.Message_Type'Output(P_Buffer, Mess);
            Boolean'Output(P_Buffer, Acogido);
            LLU.Send(Client_EP_Receive, P_Buffer);
         end if;
      elsif Mess = CM.Writer then
         Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
         Nick := ASU.Unbounded_String'Input(P_Buffer);
         Comentario := ASU.Unbounded_String'Input(P_Buffer);
         Active_Clients.Get(Map_Active, Nick, Datos_Cliente, Success);
         if Success then
            if Datos_Cliente.Client_EP_Handler = Client_EP_Handler then
               ATIO.Put_Line("Writer received from " & ASU.To_String(Nick)
                              & ": " & ASU.To_String(Comentario));
               Datos_Cliente.Client_EP_Handler := Client_EP_Handler;
               Datos_Cliente.Last_Connection := Ada.Calendar.Clock;
               Active_Clients.Put(Map_Active, Nick, Datos_Cliente);
               LLU.Reset(P_Buffer.all);
               Mess := CM.Server;
               CM.Message_Type'Output(P_Buffer, Mess);
               ASU.Unbounded_String'Output(P_Buffer, Nick);
               ASU.Unbounded_String'Output(P_Buffer, Comentario);
               Send_To_All(Map_Active, P_Buffer, Nick);
            end if;
         end if;
      elsif Mess = CM.Logout then
         Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
         Nick := ASU.Unbounded_String'Input(P_Buffer);
         Active_Clients.Get(Map_Active, Nick, Datos_Cliente, Success);
         if Success then
            if Datos_Cliente.Client_EP_Handler = Client_EP_Handler then
               Active_Clients.Delete(Map_Active, Nick, Success);
               ATIO.Put_Line("Logout received from: " & ASU.To_String(Nick));
               Inactive_Clients.Put(Map_Inactive, Nick, Ada.Calendar.Clock);
               LLU.Reset(P_Buffer.all);
               Mess := CM.Server;
               CM.Message_Type'Output(P_Buffer, Mess);
               Comentario := Nick & ASU.To_Unbounded_String(" leaves the chat");
               ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
               ASU.Unbounded_String'Output(P_Buffer, Comentario);
               Send_To_All(Map_Active, P_Buffer, Nick);
            end if;
         end if;
      end if;
   end Handler;
end Server_Handler;
