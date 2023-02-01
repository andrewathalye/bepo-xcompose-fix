with Ada.Text_IO; use Ada.Text_IO;

with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
	use Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
	use Ada.Strings.UTF_Encoding;

with Interfaces.C;
	use Interfaces;
	use Interfaces.C;

procedure XCompose_Fix is
	Output_Unavailable : exception;

	-- Imported subprograms from libxkbcommon
	function XKB_Keysym_From_Name (Name : String; Flags : int := 0) return Unsigned_32
	with
		Import => True,
		Convention => C;
	
	function XKB_Keysym_To_UTF32 (Keysym : Unsigned_32) return Unsigned_32
	with
		Import => True,
		Convention => C;

	-- From Hex String
	function Codepoint_To_String (Codepoint : String) return String
	is (UTF_8_String'(
		Encode (
			Wide_Wide_Character'Val (
				Integer'Value ("16#" & Codepoint & "#")) & "")));
	
	-- From Unsigned_32
	function Codepoint_To_String (Codepoint : Unsigned_32) return String
	is (UTF_8_String'(
		Encode (
			Wide_Wide_Character'Val (Codepoint) & "")));

	function Process_Line (Original : String) return String
	is
		Delimiter_Pos : constant Natural := Index (Original, ":", Original'First);
		Header_S : constant String := Original (Original'First .. Delimiter_Pos + 1);
		Body_S : constant String := Original (Delimiter_Pos + 2 .. Original'Last);
	begin
		if Delimiter_Pos = 0 then
			return Original;
		end if;

		-- If line begins U[0-9] there is a good chance it is a unicode character
		-- Otherwise it is either unknown or an X11 XKB character name
		if Body_S (Body_S'First) /= 'U' or Body_S (Body_S'First + 1) not in '0' .. '9' then
			if Body_S (Body_S'First) = '"' then -- Already in the right format
				Put_Line (Standard_Error, Original & "| UNSUPPORTED FORMAT");
			else -- X11 character names
				return Header_S & '"' & Codepoint_To_String (
					XKB_Keysym_To_UTF32 (
						XKB_Keysym_From_Name (Body_S & ASCII.NUL)))
					& '"' & " " & Body_S;
			end if;

			raise Output_Unavailable;
		end if;

		declare
			Codepoint : constant String := Body_S (Body_S'First + 1 .. Body_S'Last);
		begin
			return Header_S & '"' & Codepoint_To_String (Codepoint) & '"' & " " & Body_S; 
		end;
	end Process_Line;
begin
	while not End_Of_File (Standard_Input) loop
		begin
			Put_Line (Process_Line (Get_Line));
		exception
			when Output_Unavailable => null;
		end;
	end loop;
end XCompose_Fix;
