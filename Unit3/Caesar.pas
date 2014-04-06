PROGRAM Caesar;
	USES sysutils, Crt;

	CONST
		ASCII = 255;

	TYPE 
		operation = (encrypt, decrypt);

VAR
	srcFile, destFile : STRING;
	src, dest : FILE OF CHAR;
	c : CHAR;
	op : operation;
	validParam : BOOLEAN;
	key : INTEGER;

	
	PROCEDURE init;
	BEGIN
		srcFile := '';
		destFile := '';
		key := 0;
		validParam := FALSE;
		op := encrypt;
	END;//init
	
	
	PROCEDURE raiseError( t : STRING; m : STRING );
	BEGIN
		TextColor(Red);
		WriteLn('ERROR => ', t );
		WriteLn('Message: ', m);
		NormVideo();
	END;//raiseError
	
	
	PROCEDURE showUsage;
	BEGIN
		WriteLn;
		TextColor(green);
		WriteLn('---------------------------------------------------------------------------');
		WriteLn('Please use parameters as described below!');
		WriteLn('[-e  : (default/optional), specifies operation encryption');
		WriteLn(' | -d] : (optional), specifies operation decryption');
		WriteLn('key : required, key as integer used for en-/decryption');
		WriteLn('inputFile : required, full path to file you want to encrypt');
		WriteLn('[outputFile] : optional, full path to file you want to save encryption');
		WriteLn('---------------------------------------------------------------------------');
		NormVideo();
		WriteLn;
	END;
	
	
	PROCEDURE setParamValidation ( v : BOOLEAN );
	BEGIN
		validParam := v;
	END;//setParamValidation
	
	
	FUNCTION isParamValid : BOOLEAN;
	BEGIN
		isParamValid := validParam;
	END;//isParamValid
	
	
	PROCEDURE setSourceFile ( f : STRING );
	BEGIN
		srcFile := f;
	END;//setSourceFile
	
	
	FUNCTION getSourceFile : STRING;
	BEGIN
		getSourceFile := srcFile;
	END;//getSourceFile
	
	
	PROCEDURE setDestinationFile ( f : STRING );
	BEGIN
		destFile := f;
	END;//setDestinationFile
	
	
	FUNCTION getDestinationFile : STRING;
	BEGIN
		getDestinationFile := destFile;
	END;//getDestinationFile
	
	
	PROCEDURE setCryptKey ( k : INTEGER ); OVERLOAD;
	BEGIN
		key := k;
	END;//setCryptKey;
	
	
	PROCEDURE setCryptKey ( k : STRING ); OVERLOAD;
	BEGIN
    key := StrToIntDef(k, 0);
		IF (key = 0) THEN BEGIN
			raiseError('CRYPT KEY', 'Invalid Crypt Key was set to 0.');
		END;//if
	END;//setCryptKey;
	
	
	FUNCTION getCryptKey : INTEGER;
	BEGIN
		getCryptKey := key;
	END;//getCryptKey
	
	
	PROCEDURE setOperation( o : operation );
	BEGIN
		op := o;
	END;//setOperation
	
	
	FUNCTION getOperation : operation;
	BEGIN
			getOperation := op;
	END;//getOperation
	
	
	FUNCTION encryptString ( s : STRING; key : INTEGER ) : STRING;
	VAR
		i : INTEGER;
		e : STRING;
	BEGIN
		FOR i := 1 TO Length(s) DO 
			e[i] := Char( (Ord(s[i]) + key) MOD ASCII );
		
		encryptString := e;
	END;//encryptString

	
	FUNCTION encryptChar ( c : CHAR; key : INTEGER ) : CHAR;
	BEGIN
		//WriteLn('e = ', c, ' ord = ', ord(c), ' n = ', Char ( (Ord(c) + ( key MOD ASCII) ) ), ' ord = ', (Ord(c) + ( key MOD ASCII ) ) );
		encryptChar := Char ( (Ord(c) + (key MOD ASCII)) ); 
	END;//encryptChar
	

	FUNCTION decryptString ( s : STRING; key : INTEGER ) : STRING;
	VAR
		i : INTEGER;
		d : STRING;
	BEGIN
		FOR i := 1 TO Length(s) DO 
			d[i] := Char( (Ord(s[i]) - key) MOD ASCII );
		
		decryptString := d;
	END;//decryptString
	
	
	FUNCTION decryptChar ( c : CHAR; key : INTEGER ) : CHAR;
	BEGIN
		//WriteLn('d = ', c, ' ord = ', ord(c), ' n = ', Char ( (Ord(c) - ( key MOD ASCII) ) ), ' ord = ', (Ord(c) - ( key MOD ASCII ) ) );
		decryptChar := Char ( (Ord(c) - (key MOD ASCII)) ); 
	END;//decryptChar
	

BEGIN
	init;
	
	// check Console Parameters and do actions
	IF ParamCount = 0 THEN BEGIN
		// no parameters provided
		raiseError('CMD PARAM', 'unknown command');
		showUsage;
		HALT;
	END ELSE IF ParamCount < 2 THEN BEGIN
		// key + input file not provided
		raiseError('CMD PARAM', 'unknown command');
		showUsage;
		HALT;
	END ELSE IF ( ParamStr(1) = '-e' ) THEN BEGIN
		// encrypt file option
		setCryptKey(ParamStr(2));
		setSourceFile(ParamStr(3));
		setParamValidation(true);
		//if destination file specified
		IF ( Length(ParamStr(4)) > 0 ) THEN
			setDestinationFile(ParamStr(4));
	END ELSE IF ( ParamStr(1) = '-d' ) THEN BEGIN
		// decrypt file option
		setOperation(decrypt);
		setCryptKey(ParamStr(2));
		setSourceFile(ParamStr(3));
		setParamValidation(true);
		//if destination file specified
		IF ( Length(ParamStr(4)) > 0 ) THEN
			setDestinationFile(ParamStr(4));
	END ELSE BEGIN
		// default case key + input file
		setCryptKey(ParamStr(1));
		setSourceFile(ParamStr(2));
		setParamValidation(true);
		// if destination file specified
		IF ( Length(ParamStr(3)) > 0) THEN
			setDestinationFile(ParamStr(3));
	END;//if

	Assign(src, getSourceFile);
	
	(*$I-*)	
		Reset(src);
	(*$I+*)

	IF (IOResult <> 0) THEN BEGIN
		raiseError('IO SRC', 'Error during source file handling');
	END ELSE BEGIN
		Assign(dest, getDestinationFile);
		
		IF (Length(getDestinationFile) > 0) THEN BEGIN
			(*$I-*)
				Rewrite(dest);
			(*$I+*)
				IF (IOResult <> 0) THEN
					raiseError('IO DEST', 'Error writing destination file!');
		END;//if
		
		WriteLn;
		
		WHILE ( (NOT EOF(src)) AND (isParamValid) ) DO BEGIN
			Read(src, c);
				
			IF (Length(getDestinationFile) > 0) THEN BEGIN
				IF (getOperation = encrypt) THEN
					Write(dest, encryptChar(c, getCryptKey))
				ELSE
					Write(dest, decryptChar(c, getCryptKey));
			END ELSE BEGIN
				IF (getOperation = encrypt) THEN
					Write(encryptChar(c, getCryptKey))
				ELSE
					Write(decryptChar(c, getCryptKey));
			END;//if
				
		END;//while
		WriteLn;
		TextColor(green);
		WriteLn('...OPERATION "', op, '" DONE...');
		NormVideo();
		
		IF (Length(getDestinationFile) > 0) THEN 
			Close(dest);
		
		Close(src);
		
	END; //if
	
END.