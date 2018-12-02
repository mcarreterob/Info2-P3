package body Maps_G is

	procedure Get(M: Map;
				     Key: in Key_Type;
				     Value: out Value_Type;
				     Success: out Boolean) is

		Index: Natural := 1;
		
	begin
		Success := False;
		while Index <= Max_Size and not Success loop
			Success := M.P_Array(Index).Key = Key;
			if not M.P_Array(Index).Empty and Success then
				Value := M.P_Array(Index).Value;
			end if;
			--AVANZA:
			Index := Index + 1;
		end loop;
	end Get;

	procedure Put(M: in out Map;
				     Key: in Key_Type;
				     Value: in Value_Type) is

		Index: Natural:= 1;
		Found: Boolean:= False;
	begin
		while Index <= Max_Size and not Found loop
			Found:= M.P_Array(Index).Key = Key;
			if not M.P_Array(Index).Empty and Found then
				M.P_Array(Index).Value := Value;
			end if;
			--AVANZA:
			Index := Index + 1;
		end loop;
		--REINICIAMOS el CONTADOR:
		Index := 1;
		if not Found then
			--AÑADE al FINAL:
			while Index <= Max_Size and not Found loop
				Index := Index + 1;
			end loop;
			--NUEVO:
			M.P_Array(Index) := (Key, Value, False);
		end if;
	end Put;

	procedure Delete(M: in out Map;
					     Key: in Key_Type;
					     Success: out Boolean) is
		Index: Natural := 1;
	begin
		Success:= False;
		while Index <= 1 and not Success loop
			Success := M.P_Array(Index).Key = Key;
			if not M.P_Array(Index).Empty and Success then
				M.P_Array(Index).Empty := True;
			end if;
			--AVANZA:
			Index := Index + 1;
		end loop;
	end Delete;

	function Map_Length (M: Map) return Natural is
	begin
		return Max_Size;
	end Map_Length;

   function First(M: Map) return Cursor is
		Index: Natural := 1;
		Found: Boolean := False;
	begin
		while Index <= Max_Size and not Found loop
			if not M.P_Array(Index).Empty then
				Found := True;
			else
				Index := Index + 1;
			end if;
		end loop;
		if Index > Max_Size then
			Index := 0;
		end if;
		return (M => M, Position => Index);
	end First;
	
	procedure Next (C: in out Cursor) is
		Index: Natural := C.Position + 1;
	begin
		while Index <= Max_Size and C.M.P_Array(Index).Empty loop
			Index := Index + 1;
		end loop;
		if Index > Max_Size then
			Index := 0;
		end if;
		C.Position:= Index;
	end Next;
	
	function Has_Element (C: Cursor) return Boolean is
		Index: Natural := C.Position;
	begin
		return C.M.P_Array(Index).Empty;
	end Has_Element;
	
	function Element (C: Cursor) return Element_Type is
		Index: Natural:= C.Position;
	begin
		if Index = 0 then
			raise No_Element;
		end if;

		return (Key => C.M.P_Array(Index).Key,
				Value => C.M.P_Array(Index).Value);
	end Element;
end Maps_G;
