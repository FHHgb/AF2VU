UNIT Formatting;

	INTERFACE
		PROCEDURE printTitle( s : STRING );
		PROCEDURE printHeader( s : STRING );

	IMPLEMENTATION
		USES Crt;
		
		PROCEDURE printTitle( s : STRING );
		VAR
			i : INTEGER;
		BEGIN
			TextBackground(Blue);
			TextColor(LightGreen);
			WriteLn(s);
			FOR i := 1 TO Length(s) DO
				Write('=');
			WriteLn();
			NormVideo();
			WriteLn();
		END;
		
		PROCEDURE printHeader( s : STRING );
		BEGIN
			TextColor(Blue);
			WriteLn(s);
			NormVideo();
		END;
		
		PROCEDURE printHeader( s : STRING; c : BYTE) overload; 
		BEGIN
			TextColor(c);
			WriteLn(s);
			NormVideo();
		END;

BEGIN
END.
		