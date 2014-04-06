PROGRAM Regex;
		USES Formatting;

	(* --------------------------------------------------------------------------------------- *)
	
	FUNCTION BruteForceA ( s, p : STRING) : INTEGER;
	VAR
		sLen, pLen, i, j, pos : INTEGER;
	BEGIN
		sLen := Length(s);
		pLen := Length(p);
		pos := 0;
		i := 1; // erste Stelle im String
		
		// solange nicht gefunden -> pos = 0
		// und noch nicht das Ende erreicht
		WHILE (pos = 0) AND (i <= sLen - pLen + 1) DO BEGIN
			j := 1;
			
			WHILE (j <= pLen) AND (s[i + j - 1] = p[j]) DO
				Inc(j);
				
			IF j > pLen THEN
				pos := i
			ELSE
				Inc(i);
			
		END;//while
		BruteForceA := pos;
	END;//BruteForceA
	
	(* --------------------------------------------------------------------------------------- *)	
	FUNCTION Split(text: STRING; startIdx, endIdx: INTEGER): STRING;
	VAR 
	 s: STRING;
	 i: INTEGER;
	BEGIN
	 s := '';
	 // Validate range
	 IF (startIdx <= endIdx) AND (startIdx >= 1) AND (endIdx <= Length(text)) THEN BEGIN

		FOR i := startIdx TO endIdx DO BEGIN
		 s := s + text[i];
		END;//for
	 END;//if
	 
	 Split := s;
	END;//Split

	(* --------------------------------------------------------------------------------------- *)
	FUNCTION checkRegex ( p : STRING ) : BOOLEAN;
	VAR
		i,pos : INTEGER;
		valid : BOOLEAN;
		spl : STRING;
	BEGIN
		valid := TRUE;
		spl := '';
		i := 0;
		pos := 0;
		
		IF (p[Length(p)] = '^') THEN
			valid := FALSE
		ELSE BEGIN
			
			WHILE (valid) AND (i <= Length(p)) DO BEGIN
				IF (p[i] = '^') AND (p[i+1] = '.') THEN
					valid := FALSE
				ELSE IF (p[i] = '[') THEN BEGIN
					spl := Split(p, i+1, Length(p)); 
					pos :=  BruteForceA(spl, ']');
					
					IF pos = 0 THEN BEGIN
						valid := FALSE; // no closing bracket
					END ELSE BEGIN
						spl := Split(spl, 1, pos-1);
						
						IF ( (Length(spl) = 0) OR 
						     (BruteForceA(spl, '^') <> 0 ) OR
							   ( BruteForceA(spl, '.') <> 0 ) OR 
							   ( // inner range check
								   (Length(spl) = 3) AND
								   (spl[2] = '-') AND
								   ( Ord(spl[1]) > Ord(spl[3]) )
							   )
                ) THEN
										valid := FALSE;
						
						i := i + pos; // pos : closing bracket
					END;//if
				END ELSE IF (p[i] = ']') THEN 
					valid := FALSE;
				Inc(i);
			END;//while

		END;//if
	
		checkRegex := valid;
	END;//checkRegex

	
	(* --------------------------------------------------------------------------------------- *)
	FUNCTION getPatternLength ( p : STRING; start : INTEGER ) : INTEGER;
	VAR
		i, spos, epos : INTEGER;
	BEGIN
		spos := 0;
		epos := 0;
		
		FOR i := start TO Length(p) DO BEGIN
			IF (p[i] = '^') THEN
				spos := i
			ELSE IF (p[i] = '[') THEN
				spos := i
			ELSE IF (p[i] = ']') THEN
				epos := i;
		END;//for
		getPatternLength := epos - spos -1;
	END;//getPatternLength

	
	(* --------------------------------------------------------------------------------------- *)
	FUNCTION stringMatchesRegEx( s : CHAR; p : STRING; start : INTEGER ) : BOOLEAN;
	VAR
		i : INTEGER;
		modPattern : STRING;
		matchResult, negation : BOOLEAN;
	BEGIN
		i := 0;
		matchResult := FALSE;
		negation := p[1] = '^';
		
		IF negation THEN
			modPattern := split(p, 3, BruteForceA(p, ']')-1)
		ELSE
			modPattern := split(p, 2, BruteForceA(p, ']')-1);

		IF ((Length(modPattern) = 3) AND
				 (modPattern[2] = '-')) THEN BEGIN
			IF ( 
				 (Ord(s) >= Ord(modPattern[1])) AND 
				 (Ord(s) <= Ord(modPattern[3])) 
				) THEN
				matchResult := TRUE;
		END ELSE BEGIN
			WHILE (i <= Length(modPattern)) AND (matchResult = FALSE) DO BEGIN
				IF (s = modPattern[i]) THEN 
					matchResult := TRUE;
				Inc(i);
			END;//while
		END; //if

		IF negation THEN
			matchResult := NOT matchResult;

		stringMatchesRegEx := matchResult;
	END;//stringMatchesRegEx
	
	
	(* --------------------------------------------------------------------------------------- *)
	FUNCTION BruteForceRegEx ( s, p : STRING) : INTEGER;
	VAR
		sLen, pLen, i, j, index, pos : INTEGER;
		spl : STRING;
		valid : BOOLEAN;
	BEGIN
		sLen := Length(s);
		pLen := Length(p);
		pos := 0;
		spl := '';
		i := 1; // erste Stelle im String

	// begin only if regex is valid
	IF (checkRegex(p)) THEN BEGIN
		
		WHILE (pos = 0) AND (i <= sLen) DO BEGIN
			valid := TRUE;
			j := 1;
			index := 0;
			WHILE ( (j <= pLen) AND (valid = TRUE) AND (index <= sLen) ) DO BEGIN
				IF ( (p[j] = '.' ) OR (p[j] = s[i + index]) ) THEN
					Inc(j)
				ELSE IF (
									(p[j] = '^') AND 
									(p[j+1] = '[') AND
									(stringMatchesRegEx(s[i + index], Split(p, j, pLen), j))
								)  THEN BEGIN
									spl := Split(p, j+2, pLen); 
									j := j + BruteForceA(spl, ']') + 2;
				END ELSE IF (
											(p[j] = '[') AND
											(stringMatchesRegEx(s[i + index  ], Split(p, j, pLen), j))
										)  THEN BEGIN
									spl := Split(p, j+1, pLen);
									j := j + BruteForceA(spl, ']') + 1;
				
				END ELSE IF (
												(p[j] = '^') AND
												(p[j+1] <> '[') AND
												(p[j+1] <> s[i + index])
										) THEN 
												j := j + 2
				ELSE 
						valid := FALSE;
				index := index + 1;
			END;//while
				
				IF ( (valid = TRUE) AND (j > pLen) ) THEN
					pos := i;
					
				Inc(i);
		END;//while
	
	END;//if
		BruteForceRegEx := pos;
	END;//BruteForceRegEx

	
VAR 
	pos : INTEGER;
BEGIN
	printTitle('Mini Regex');
	
// PART 1
		printHeader('BruteForce (1)');
	pos := BruteForceA('Hagenbrg', 'brg');
		Write('Hagenbrg | brg: '); WriteLn(pos);
	pos := BruteForceA('Hagenberg', 'berg');
		Write('Hagenberg | berg: '); WriteLn(pos);
	pos := BruteForceA('Hagenburg', 'berg');
		Write('Hagenburg | berg: '); WriteLn(pos);
	WriteLn;

// PART 2
		printHeader('BruteForce (2)');
	pos := BruteForceRegEx('Hagenbrg', 'b.rg');
		WriteLn('Hagenbrg | b.rg: ', pos); 
	pos := BruteForceRegEx('Hagenberg', 'b.rg');
		WriteLn('Hagenberg | b.rg: ', pos); 
	pos := BruteForceRegEx('Hagenburg', 'b.rg');
		WriteLn('Hagenburg | b.rg: ', pos); 
	pos := BruteForceRegEx('Hagenberg', 'b..rg');
		WriteLn('Hagenberg | b..rg: ', pos); 
		WriteLn;		

// Split
	printHeader('Split');
	WriteLn('String [2-4] = ', Split('String', 2, 4));
	WriteLn('HelloWorld [1-6] = ', Split('HelloWorld', 1, 6));
	WriteLn('Pascal [2-5] = ', Split('Pascal', 2, 5));
	WriteLn;
		
// PART 3
		printHeader('BruteForce RegEx (3)');
	pos := BruteForceRegEx('Hagenberg', 'b[eu]rg');
		WriteLn('Hagenberg | b[eu]rg: ', pos);
	pos := BruteForceRegEx('Hagenburg', 'b[eu]rg');
		WriteLn('Hagenburg | b[eu]rg: ', pos); 
	pos := BruteForceRegEx('Hagenborg', 'b[aeiu]rg');
		WriteLn('Hagenborg | b[aeiu]rg: ', pos);
	pos := BruteForceRegEx('Hagenbeurg', 'b[eu]rg');
		WriteLn('Hagenbeurg | b[eu]rg: ', pos); 
		BruteForceRegEx('Hagenberg', 'b^[a-b]r[f-g]');
		Write('Hagenberg | b^[a-b]r[f-g]: '); WriteLn(pos);
		WriteLn;

// PART 4
		printHeader('BruteForce RegEx (4)');
	pos := BruteForceRegEx('Hagenberg', 'genbe[a-z]g');
		WriteLn('Hagenberg | genbe[a-z]g: ', pos);
	pos := BruteForceRegEx('Hagenborg7', 'borg[0-9]');
		WriteLn('Hagenborg7 | borg[0-9]: ', pos); 
	pos := BruteForceRegEx('Hagenbeurg', '[A-Z]agen[c-f]');
		WriteLn('Hagenbeurg | [A-Z]agen[c-f]: ', pos);
		WriteLn;

// PART 5
		printHeader('BruteForce (5)');
	pos := BruteForceRegEx('Hagenbergburg', 'b^erg');
		WriteLn('Hagenbergburg | b^erg: ', pos); 
	pos := BruteForceRegEx('Hagenborg7', 'borg[0-9]');
		WriteLn('Hagenborg7 | borg[0-9]: ', pos); 
	pos := BruteForceRegEx('Hagenbeurg', '[A-Z]agen[c-f]');
		WriteLn('Hagenbeurg | [A-Z]agen[c-f]: ', pos);
	pos := BruteForceRegEx('Hagenberg', '^Iagenb^[a-d]rg');
		WriteLn('Hagenberg | ^Iagenb^[a-d]rg: ', pos);
		WriteLn;
	
END.