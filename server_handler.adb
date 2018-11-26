package body Server_Handler is

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
   begin
      Mess:= CM.Message_Type'Input(P_Buffer);
      if Mess = CM.Init then
         Client_EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
         Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
         Nick := ASU.Unbounded_String'Input(P_Buffer);
         LLU.Reset(P_Buffer.all);
         ATIO.Put("INIT received from " & ASU.To_String(Nick) & ": ");
         Active_Clients.Get(Map_Active, Client_Value, Success);
         if not Success then
            ATIO.Put_Line("ACCEPTED");
            Comentario := ASU.To_Unbounded_String(ASU.To_String(Nick)
                                                & " joins the chat.");
            Hora_entrada := Ada.Calendar.Clock;
            -- Meto los valores en la tabla
            Datos_Cliente.Client_EP_Handler := Client_EP_Handler;
            Datos_Cliente.Last_Connection := Hora_entrada;
