package body Maps_G is

	procedure Get(M: Map;
				     Key: in Key_Type;
				     Value: out Value_Type;
				     Success: out Boolean) is

		Index: Natural := 1;

	begin
		Success := False;
		if M.P_Array /= null then
			while Index <= Max_Size and not Success loop
				--Success := M.P_Array(Index).Key = Key;
				if M.P_Array(Index).Full and then M.P_Array(Index).Key = Key then
					Value := M.P_Array(Index).Value;
					Success := True;
				else
					--AVANZA:
					Index := Index + 1;
				end if;
			end loop;
		end if;
	end Get;

	procedure Put(M: in out Map;
				     Key: in Key_Type;
				     Value: in Value_Type) is

		Index: Natural:= 1;
		Found: Boolean:= False;
	begin
		if M.P_Array /= null then
			while Index <= Max_Size and not Found loop
				--Found:= M.P_Array(Index).Key = Key;
				if M.P_Array(Index).Full and M.P_Array(Index).Key = Key then
					M.P_Array(Index).Value := Value;
					Found := True;
				else
					--AVANZA:
					Index := Index + 1;
				end if;
			end loop;
			--REINICIAMOS el CONTADOR:
			Index := 1;
			if not Found then
				--AÑADE al FINAL:
				while Index <= Max_Size and not Found loop
					if not M.P_Array(Index).Full then
						M.P_Array(Index) := (Key, Value, True);
						M.Length := M.Length + 1;
						Found :=  True;
					else
						Index := Index + 1;
					end if;
				end loop;
				if Index > Max_Size then
					raise Full_Map;
				end if;
			end if;
		end if;
	end Put;

	procedure Delete(M: in out Map;
					     Key: in Key_Type;
					     Success: out Boolean) is
		Index: Natural := 1;
	begin
		Success:= False;
		if M.P_Array /= null then
			while Index <= Max_Size and not Success loop
				--Success := M.P_Array(Index).Key = Key;
				if M.P_Array(Index).Full and then M.P_Array(Index).Key=Key then
					M.P_Array(Index).Full := False;
					M.Length := M.Length - 1;
				else
					--AVANZA:
					Index := Index + 1;
				end if;
			end loop;
		end if;
	end Delete;

	function Map_Length (M: Map) return Natural is
	begin
		return M.Length;
	end Map_Length;

   function First(M: Map) return Cursor is
		Index: Natural := 1;
		Found: Boolean := False;
	begin
		if M.P_Array /= null then
			while Index <= Max_Size and not Found loop
				if M.P_Array(Index).Full then
					Found := True;
				else
					Index := Index + 1;
				end if;
			end loop;
			if Index > Max_Size then
				Index := 0;
			end if;
		end if;
		return (M => M, Element => Index);
	end First;

	procedure Next (C: in out Cursor) is
		Found: Boolean := False;
	begin
		if C.M.P_Array /= null then
			C.Element := C.Element + 1;
			while C.Element <= Max_Size and not Found loop
				if not C.M.P_Array(C.Element).Full then
					C.Element := C.Element + 1;
				else
					Found := True;
				end if;
			end loop;
			if C.Element > Max_Size then
				C.Element := 0;
			end if;
		end if;
	end Next;

	function Has_Element (C: Cursor) return Boolean is
	begin
		if C.Element /= 0 then
			return True;
		else
			return False;
		end if;
	end Has_Element;

	function Element (C: Cursor) return Element_Type is
	begin
		if C.Element /= 0 then
			return (Key => C.M.P_Array(C.Element).Key,
					  Value => C.M.P_Array(C.Element).Value);
		else
			raise No_Element;
		end if;

	end Element;
end Maps_G;
