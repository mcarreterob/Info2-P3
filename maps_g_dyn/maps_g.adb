with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded;

package body Maps_G is
   package ASU renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);

   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux: Cell_A;
   begin
      Value := ASU.Null_Unbounded_String;
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= Null loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;

   procedure Put (M     : in out Map;
                  Key   : in Key_Type;
                  Value : in Value_Type) is
      P_Aux: Cell_A;
      Success: Boolean;
   begin
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= Null loop
         if P_Aux.Key = Key then
            P_Aux.Value := Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
      if not Success then
         if M.Length < Max_Size then
            M.P_First := new Cell'(Key, Value, M.P_First);
            P_Aux := M.P_First;
            if M.Length = 0 then
               M.P_Last := M.P_First;
            else
               P_Aux.Previous := M.P_First;
            end if;
            M.Length := M.Length + 1;
         else
            raise Full_Map;
         end if;
      else
         P_Aux.Value := Value;
      end if;
   end Put;

   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Previous: Cell_A;
      P_Current: Cell_A;
   begin
      Success:= False;
      P_Previous:= Null;
      P_Current:= M.P_First;
      while not Success and P_Current /= Null loop
         if P_Current.Key = Key then
            Success:= True;
            M.Length := M.Length - 1;
            if P_Previous /= Null then
               P_Previous.Next := P_Current.Next;
               if P_Previous.Next = Null then
                  M.P_Last := P_Previous;
               else
                  P_Current.Next.Previous := P_Previous;
               end if;
            end if;
            if M.P_First = P_Current then
               M.P_First := M.P_First.Next;
               if M.P_First = Null then
                  M.P_Last := Null;
               else
                  M.P_First.Previous := Null;
               end if;
            end if;
            Free(P_Current);
         else
            P_Previous := P_Current;
            P_Current := P_Current.Next;
         end if;
      end loop;
   end Delete;

   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;
