package body Server_Handler is

   procedure Handler (From: in LLU.End_Point_Type;
                     To: in LLU.End_Point_Type;
                     P_Buffer: access LLU.Buffer_Type) is
      Client_EP_Receive: LLU.End_Point_Type;
      Client_EP_Handler: LLU.End_Point_Type;
      Mess: CM.Message_Type;
      Nick: ASU.Unbounded_String;
      Comentario: ASU.Unbounded_String;
      Acogido: Boolean := False;
   begin
      Mess:= CM.Message_Type'Input(P_Buffer);
      if Mess = CM.Init then
         Client_EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
         Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
         Nick := ASU.Unbounded_String'Input(P_Buffer);
         LLU.Reset(P_Buffer.all);
