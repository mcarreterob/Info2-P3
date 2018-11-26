package body Client_Handler is

   procedure Handler_Client (From: LLU.End_Point_Type;
							  To: LLU.End_Point_Type;
							  P_Buffer: access LLU.Buffer_Type) is

      Mess: CM.Message_Type;
      Nick: ASU.Unbounded_String;
      Comentario: ASU.Unbounded_String;
   begin
      Mess := CM.Message_Type'Input(P_Buffer);
      Nick := ASU.Unbounded_String'Input(P_Buffer);
      Comentario := ASU.Unbounded_String'Input(P_Buffer);
      ATIO.Put_Line(ASU.To_String(Nick) & ": "
                     & ASU.To_String(Comentario));
      ATIO.Put(">>");
   end Handler_Client;
end Client_Handler;
