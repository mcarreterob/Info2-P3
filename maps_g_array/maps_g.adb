with Ada.Text_IO;
package body Maps_G is
	package ATIO renames Ada.Text_IO;
	procedure Get(M: Map;
				     Key: in Key_Type;
				     Value: out Value_Type;
				     Success: out Boolean) is

		Index: Natural := 1;
	begin
		Success := False;
		if M.P_Array /= null then
			while Index <= Max_Size and not Success loop
				if M.P_Array(Index).Full then
					if M.P_Array(Index).Key = Key then
						Value := M.P_Array(Index).Value;
						Success := True;
					end if;
				end if;
				--AVANZA:
				Index := Index + 1;
			end loop;
		end if;
	end Get;

	procedure Put(M: in out Map;
				     Key: in Key_Type;
				     Value: in Value_Type) is

		Index: Natural;
		Found: Boolean;
	begin
		if M.P_Array = null then
			M.P_Array := new Cell_Array;
		end if;
		Found := False;
		Index := 1;
		while Index <= Max_Size and not Found loop
			if M.P_Array(Index).Full then
				if M.P_Array(Index).Key = Key then
					M.P_Array(Index).Value := Value;
					Found := True;
				end if;
			end if;
			--AVANZA:
			Index := Index + 1;
		end loop;
		--REINICIAMOS el CONTADOR:
		--Index := 1;
		if not Found then
			if M.Length < Max_Size then
				Index := 1;
				--AÑADE al FINAL:
				while Index <= Max_Size and not Found loop
					if not M.P_Array(Index).Full then
						M.P_Array(Index).Key := Key;
            		M.P_Array(Index).Value := Value;
            		M.P_Array(Index).Full := True;
						M.Length := M.Length + 1;
						Found :=  True;
					end if;
					Index := Index + 1;
				end loop;
			else
				raise Full_Map;
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
		C: Cursor;
	begin
		if M.Length /= 0 then
			while Index <= Max_Size and not Found loop
				Found := M.P_Array(Index).Full;
				if not Found then
					Index := Index + 1;
				end if;
			end loop;
			C.M := M;
			C.Element := Index;
			return (C.M, C.Element);
		else
			C.M.P_Array:=null;
			C.Element := 0;
			return (C.M, C.Element);
		end if;
	end First;

	procedure Next (C: in out Cursor) is
		Found: Boolean := False;
	begin
		if C.Element /= 0 then
			C.Element := C.Element + 1;
			while C.Element <= Max_Size and not Found loop
				Found := C.M.P_Array(C.Element).Full;
				if not Found then
					C.Element := C.Element + 1;
				end if;
			end loop;
			if not Found then
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
		Element: Element_Type;
	begin
		if C.Element /= 0 then
			Element.Key := C.M.P_Array(C.Element).Key;
			Element.Value := C.M.P_Array(C.Element).Value;
			return (Element.Key, Element.Value);
		else
			raise No_Element;
		end if;

	end Element;
end Maps_G;
