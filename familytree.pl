:- dynamic module(familytree,[]).
	/*person(name,lastName,gender,birthDate,fatherName,motherName,deathDate,maritalStat,PartnerName).*/
	/* Family members to be added, here is an example */
	addPerson:- assert(person(ayse,'',female,01/01/1925,'','','',married,mehmet)),
				assert(person(mehmet,'',male,01/01/1920,'','','',married,ayse)),
				assert(person(hasan,'',male,01/01/1950,mehmet,ayse,'',married,sevim)),
				assert(person(sevim,'',female,01/01/1949,'','','',married,erdi)),
				assert(person(fatma,'',female,01/01/1952,mehmet,ayse,'',married,ali)),
				assert(person(ali,'',male,01/01/1948,'','','',married,fatma)),
				assert(person(faruk,'',male,01/01/1960,mehmet,ayse,'',married,deniz)),
				assert(person(deniz,'',female,01/01/1960,'','','',married,faruk)),
				assert(person(serap,'',female,01/01/1961,mehmet,ayse,01/01/2000,married,ahmet)),
				assert(person(ahmet,'',male,01/01/1960,'','','',married,serap)),
				assert(person(hatice,'',female,01/01/1980,erdi,sevim,'',single,'')),
				assert(person(kader,'',female,01/01/1975,ali,fatma,'',single,'')),
				assert(person(hakan,'',male,01/01/1978,ali,fatma,'',single,'')),
				assert(person(derya,'',female,01/01/1982,faruk,deniz,'',single,'')),
				assert(person(kaya,'',male,01/01/1982,ahmet,serap,'',single,'')).
				
	/* returns the birth year*/
	getBirthYear(X,T):- person(X,_,_,_/_/T,_,_,_,_,_).
	
	/* returns the death year*/
	getDeathYear(X,T):- not(isAlive(X)),
						person(X,_,_,_,_,_,_/_/T,_,_).
						
	/* returns the year of today*/
	today(Year) :- get_time(X),
				   format_time(atom(Today), '%Y', X),
				   atom_number(Today, Year).
				   
	/*calculates the age*/
	calcAge(X,Y):- getBirthYear(X,T),
				   today(Today),
				   Y is (Today - T).
				   
	/*checks if the person is alive or not*/
	isAlive(X):- person(X,_,_,_,_,_,T,_,_),
				 T == ''.
				 
	/*checks if the person is male */
	male(X):- person(X,_,male,_,_,_,_,_,_).
	
	/*checks if the person is female*/
	female(X):- person(X,_,female,_,_,_,_,_,_).
	
	/*checks if the person is married*/
	isMarried(X):- person(X,_,_,_,_,_,_,married,_).
	
	/*checks if Y is mother of X*/
	isMother(Y,X):- female(Y),
					person(X,_,_,_,_,Y,_,_,_),
					person(Y,_,_,_,_,_,_,_,_).
					
	/*checks if Y is father of X*/
	isFather(Y,X):- male(Y),
					person(X,_,_,_,Y,_,_,_,_),
					person(Y,_,_,_,_,_,_,_,_).
	
	/*checks if Y and Z are the partner of X*/
	isParent(Y,Z,X):- male(Y),
					  female(Z),
					  person(Y,_,_,_,_,_,_,_,_),
					  person(Z,_,_,_,_,_,_,_,_),
					  person(X,_,_,_,Y,Z,_,_,_).
	
	/*checks if X is grandmother of Y*/
	isGrandMother(X,Y):- female(X),
						 isFather(Z,Y),
						 isMother(X,Z);
						 female(X),
						 isMother(Z,Y),
						 isMother(X,Z).
						 
	/*checks if X is grandfather of Y*/
	isGrandFather(X,Y):- male(X),
						 isFather(Z,Y),
						 isFather(X,Z);
						 male(X),
						 isMother(Z,Y),
						 isFather(X,Z).
						 
	/*checks if X is spouse of Y*/
	/*also checks the constraints for being married*/
	isSpouse(X,Y):- isMarried(X),
					isMarried(Y),
					calcAge(X,T),
					calcAge(Y,P),
					person(X,_,_,_,_,_,_,_,Y),
					person(Y,_,_,_,_,_,_,_,X),
					(T<18
					->write(" !("),
					write(X),
					write(" is younger than 18, and cannot be married.)"),
					false
					;true),
				    (P<18
				    ->write(" !("),
				    write(Y),
				    write(" is younger than 18, and cannot be married.)"),
				    false
				    ;true),
				    (isChild(X,Y)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				    ;isChild(Y,X)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				 	;true),
				    (isSibling(X,Y)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				    ;true),
				    (isNephew(X,Y)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				    ;isNephew(Y,X)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				    ;true),
				    (isGrandMother(X,Y)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				    ;isGrandMother(Y,X)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				    ;true),
				    (isGrandFather(X,Y)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				    ;isGrandFather(Y,X)
				    ->write(" (!"),
				    write(" cannot be married with a close relative)"),
				    false
				    ;true).
				    
	/*checks if X is brother of Y*/
	isBrother(X,Y):- male(Y),
					 isParent(T,Z,X),
					 isParent(T,Z,Y),
					 not(X=Y).
	
	/*checks if X is sister of Y*/
	isSister(X,Y):- female(Y),
					isParent(T,Z,X),
					isParent(T,Z,Y),
					not(X=Y).
					
	/*checks if X is a sibling of Y*/
	isSibling(X,Y):- isParent(T,Z,X),
					 isParent(T,Z,Y),
					 not(X=Y).
					 
	/*checks if X is son of Y*/
	isSon(X,Y):- male(X),
				 isFather(Y,X),
				 (not(isAlive(Y))
				 ->getDeathYear(Y,T),
				 getBirthYear(X,P),
				 (T<P
				 ->write("(! Father died before his son's birth date) \n"),
				   false
				   ;true)
				 ;true);
				 male(X),
				 isMother(Y,X),
				 (not(isAlive(Y))
				 ->getDeathYear(Y,T),
				 getBirthYear(X,P),
				 (T<P
				 ->write("(! Mother died before her son's birth date) \n"),
				   false
				  ;true)
				 ;true).

	/*checks if X is daughter of Y*/
	isDaughter(X,Y):- female(X),
				 	  isFather(Y,X),
				   	  (not(isAlive(Y))
				      ->getDeathYear(Y,T),
				      getBirthYear(X,P),
				      (T<P
				      ->write("(! Father died before his daughter's birth date) \n"),
				      	false
				      ;true)
				      ;true);
				 	  female(X),
					  isMother(Y,X),
					  (not(isAlive(Y))
				      ->getDeathYear(Y,T),
				      getBirthYear(X,P),
				      (T<P
				      ->write("(! Mother died before her daughter's birth date) \n"),
				      	false
				      ;true)
				      ;true).
				      
	/*checks if X is a child of Y*/
	isChild(X,Y):- isFather(Y,X),
				   (not(isAlive(Y))
				   ->getDeathYear(Y,T),
				   getBirthYear(X,P),
				   (T<P
				   ->write("(! Father died before the child's birth date) \n"),
				   false
				   ;true)
				   ;true),
				   generation(Y,G),
				   J is (G + 1),
				   (not(generation(X,J))
				   ->assert(generation(X,J))
				   ;true);
				   isMother(Y,X),
				   (not(isAlive(Y))
				   ->getDeathYear(Y,T),
				   getBirthYear(X,P),
				   (T<P
				   ->write("(! Mother died before the child's birth date )\n"),
				   false
				   ;true)
				   ;true),
				   generation(Y,G),
				   J is (G + 1),
				   (not(generation(X,J))
				   ->assert(generation(X,J))
				   ;true).
	
	/* Checks if X is elder sister of Y*/
	isElderSister(X,Y):- female(X),
				  isSister(Y,X),
				  calcAge(Y,T),
				  calcAge(X,P),
				  (P > T).
				  
	/* Checks if X is elder brother of Y*/
	isElderBrother(X,Y):- male(X),
				 isBrother(Y,X),
				 calcAge(Y,T),
				 calcAge(X,P),
				 (P > T).
	
	/* Checks if X is brother of Y's father or Y's mother*/
	isUncle(X,Y):- isFather(Z,Y),
				  isBrother(Z,X);
				  isMother(Z,Y),
				  isBrother(Z,X).
	
	/* Checks if X is sister of Y's father or Y's mother */
	isAunt(X,Y):- isFather(Z,Y),
				  isSister(Z,X);
				  isMother(Z,Y),
				  isSister(Z,X).
	
	/* Checks if X is Y's nephew*/
	isNephew(X,Y):- isMother(Z,X),
					isBrother(Z,Y);
					isMother(Z,X),
					isSister(Z,Y);
					isFather(Z,X),
					isBrother(Z,Y);
					isFather(Z,X),
					isSister(Z,Y).
					
	/* Checks if X is a cousin of Y*/
	isCousin(X,Y):- isMother(Z,Y),
					isNephew(X,Z);
					isFather(Z,Y),
					isNephew(X,Z).
	
	/* Checks if X is  husband of Y's sister or Y's aunt's husband*/
	isUncleOrBrotherInLaw(X,Y):- male(X),
					isSpouse(X,Z),
					isNephew(Y,Z);
					male(X),
					isSpouse(X,Z),
					isSister(Z,Y).
	
	/* Checks if X is wife of Y's brother or Y's uncle's wife*/
	isAuntOrSisterInLaw(X,Y):-	female(X),
					isSpouse(X,Z),
					isNephew(Y,Z);
					female(X),
					isSpouse(X,Z),
					isSibling(Z,Y).
	
	/* Checks if X is mother-in-law of Y*/
	isMotherInLaw(X,Y):- female(X),
						 isSpouse(Y,Z),
						 isMother(X,Z).
	
	/* Checks if X is father-in-law of Y */
	isFatherInLaw(X,Y):- male(X),
						 isSpouse(Y,Z),
						 isFather(X,Z).
	
	/* Checks if X is daughter-in-law of Y */
	isDaughterInLaw(X,Y):- female(X),
				   isSpouse(X,Z),
				   isSon(Z,Y).

	/* Checks if X is son-in-law of Y */
	isSonInLaw(X,Y):- male(X),
				   isSpouse(X,Z),
				   isDaughter(Z,Y).

	/* Checks if the wives of X and Y are sisters or 
	if X is Y's sister's husband (brother-in-law) */
	isBrotherInLaw(X,Y):- male(X),
					 male(Y),
					 isSpouse(X,Z),
					 isSpouse(Y,P),
					 isSister(Z,P);
					 male(X),
					 male(Y),
				     isSpouse(X,Z),
					 isSister(Y,Z).
	
	/* Checks if X is Y's wife's sister or if the husbands 
	of X and Y are brothers (sister-in-law) */
	isSisterInLaw(X,Y):- female(X),
					male(Y),
					isSpouse(Y,Z),
					isSister(X,Z);
					female(X),
				  	female(Y),
				  	isSpouse(X,Z),
				  	isSpouse(Y,P),
				  	isBrother(Z,P).
	
	/*displays the family tree diagram*/
	listchilds(X):- generation(A,0),
					(A==X
					->write(" |"),
					write(A),
					(isSpouse(A,Y)
					->write("--"),
					write(Y)
					;true),
					write("\n")
					;true),
					isChild(Z,X),
					generation(Z,T),
					(T==1
					->write("  |"),
					write(Z),
					(isSpouse(Z,P)
					->write("--"),
					generation(Z,G),
					assert(generation(P,G)),
					write(P)
					;true),
					write("\n")
					;T==2
					->write("   |"),
					write(Z),
					(isSpouse(Z,H)
					->write("--"),
					generation(Z,G),
					assert(generation(H,G)),
					write(H)
					;true),
					write("\n")
					;T==3
					->write("    |"),
					write(Z),
					(isSpouse(Z,U)
					->write("--"),
					generation(Z,G),
					assert(generation(U,G)),
					write(U)
					;true),
					write("\n")
					;true),
					listchilds(Z).

	/*Changes the name of X with Y*/
	updateName(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(Y,A,S,D,F,G,H,J,K)),
					   retract(person(X,A,S,D,F,G,H,J,K)).
	
	/*Changes the last name of X with Y*/
	updateLastName(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(X,Y,S,D,F,G,H,J,K)),
					   retract(person(X,A,S,D,F,G,H,J,K)).
	
	/*Changes the gender of X with Y*/
	updateGender(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(X,A,Y,D,F,G,H,J,K)),
					   retract(person(X,A,S,D,F,G,H,J,K)).
	
	/*Changes the birth date of X with Y*/
	updateBirthDate(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(X,A,S,Y,F,G,H,J,K)),
					   retract(person(X,A,S,D,F,G,H,J,K)).
	
	/*Changes the father name of X with Y*/
	updateFatherName(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(X,A,S,D,Y,G,H,J,K)),
					   retract(person(X,A,S,D,F,G,H,J,K)).
	
	/*Changes the mother name of X with Y*/
	updateMotherName(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(X,A,S,D,F,Y,H,J,K)),
					   retract(person(X,A,S,D,F,G,H,J,K)).
	
	/*Changes the death date of X with Y*/
	updateDeathDate(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(X,A,S,D,F,G,Y,J,K)),
					   retract(person(X,A,S,D,F,G,H,J,K)).
	
	/*Changes the marital status of X with Y*/
	updateMaritalStat(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(X,A,S,D,F,G,H,Y,K)),
					   retract(person(X,A,S,D,F,G,H,J,K)).
	
	/*Changes the partner name of X with Y*/
	updatePartnerName(X,Y) :- person(X,A,S,D,F,G,H,J,K),
					   assert(person(X,A,S,D,F,G,H,J,Y)),
					   retract(person(X,A,S,D,F,G,H,J,K)).

	
	/*For displaying the basic info of person X*/
	getBasicInfo(X) :- generation(X,Y),
						write("Generation level: "),
						write(Y),
						write("\n"),
						calcAge(X,T),
						write("Age: "),
						write(T),
						write("\n"),
						(isAlive(X)
						->write("Alive")
						;write("Dead")).

	/*Finds the relationship among X and Y and prints the related statement*/
	findRelation(X,Y) :-(isMother(X,Y)
						  ->write(X),
						  write(" is mother of "),
						  write(Y)
						  ;isFather(X,Y)
						  ->write(X),
						  write(" is father of "),
						  write(Y)
						  ;isGrandMother(X,Y)
						  ->write(X),
						  write(" is grandmother of "),
						  write(Y)
						  ;isGrandFather(X,Y)
						  ->write(X),
						  write(" is grandfather of "),
						  write(Y)
						  ;isSpouse(X,Y)
						  ->write(X),
						  write(" is wife of "),
						  write(Y)
						  ;isElderSister(X,Y)
						  ->write(X),
						  write(" is elder sister of "),
						  write(Y)
						  ;isElderBrother(X,Y)
						  ->write(X),
						  write(" is elder brother of "),
						  write(Y)
						  ;isBrother(X,Y)
						  ->write(X),
						  write(" is brother of "),
						  write(Y)
						  ;isSister(X,Y)
						  ->write(X),
						  write(" is sister of "),
						  write(Y)
						  ;isSon(X,Y)
						  ->write(X),
						  write(" is son of "),
						  write(Y)
						  ;isDaughter(X,Y)
						  ->write(X),
						  write(" is daughter of "),
						  write(Y)
						  ;isUncle(X,Y)
						  ->write(X),
						  write(" is uncle of "),
						  write(Y)
						  ;isAunt(X,Y)
						  ->write(X),
						  write(" is aunt of "),
						  write(Y)
						  ;isUncle(X,Y)
						  ->write(X),
						  write(" is uncle of "),
						  write(Y)
						  ;isAunt(X,Y)
						  ->write(X),
						  write(" is aunt of "),
						  write(Y)
						  ;isNephew(X,Y)
						  ->write(X),
						  write(" is newphew of "),
						  write(Y)
						  ;isCousin(X,Y)
						  ->write(X),
						  write(" is cousin of "),
						  write(Y)
						  ;isUncleOrBrotherInLaw(X,Y)
						  ->write(X),
						  write(" is  uncle or brother-in-law of "),
						  write(Y)
						  ;isAuntOrSisterInLaw(X,Y)
						  ->write(X),
						  write(" is aunt or sister-in-law of "),
						  write(Y)
						  ;isMotherInLaw(X,Y)
						  ->write(X),
						  write(" is mother-in-law of "),
						  write(Y)
						  ;isFatherInLaw(X,Y)
						  ->write(X),
						  write(" is father-in-law of "),
						  write(Y)
						  ;isDaughterInLaw(X,Y)
						  ->write(X),
						  write(" is daugher-in-law of "),
						  write(Y)
						  ;isSonInLaw(X,Y)
						  ->write(X),
						  write(" is son-in-law of "),
						  write(Y)
						  ;isBrotherInLaw(X,Y)
						  ->write(X),
						  write(" is brother-in-law of "),
						  write(Y)
						  ;isSisterInLaw(X,Y)
						  ->write(X),
						  write(" is sister-in-law of "),
						  write(Y)
						  ;isSisterInLaw(X,Y)
						  ->write(X),
						  write(" is sister-in-law of "),
						  write(Y)
						  ;isBrotherInLaw(X,Y)
						  ->write(X),
						  write(" is brother in law of "),
						  write(Y)
						  ).
	
	/*Removes all the generation facts*/
	clearGeneration:-retract(generation(_,_)),
						clearGeneration.
	
	/*Removes all the persons*/
	removePerson:- retract(person(_,_,_,_,_,_,_,_,_)),
					   removePerson.


	/*to display the tree*/
	 displaytree(X):- not(clearGeneration),
	 				  assert(generation(X,0)),
	 				  listchilds(X).
	/* menu*/
	 menu:-
		 write("\nPress 1 to display the tree\n"),
		 write("Press 2 to display the user info\n"),
		 write("Press 3 to display the relationship of two people\n"),
		 write("Press 4 to update a person\n"),
		 write("Press 5 to revert the database to original version\n"),
		 write("Press 0 to exit\n"),
		 write("Enter your choice: "),
		 read(C),
		 (C==1
		 ->write("Enter root's name: "),
		 read(T),
		 write("\n"),
		 not(displaytree(T))
		 ;C==2
		 ->write("Enter the person's name: "),
		 read(N),
		 write("\n"),
		 getBasicInfo(N),
		 write("\n")
		 ;C==3
		 ->write("Enter the first person's name: "),
		 read(P1),
		 write("Enter the second person's name: "),
		 read(P2),
		 write("\n"),
		 findRelation(P1,P2),
		 write("\n")
		 ;C==4
		 ->write("\nPress 1 to update the name\n"),
		 write("Press 2 to update the last name\n"),
		 write("Press 3 to update the gender\n"),
		 write("Press 4 to update the birth date\n"),
		 write("Press 5 to update father name\n"),
		 write("Press 6 to update mother name\n"),
		 write("Press 7 to update death date\n"),
		 write("Press 8 to update marital status\n"),
		 write("Press 9 to update partner name\n"),
		 read(U),
		 write("\n"),
		 write("Enter the person's name: "),
		 read(N),
		 write("Enter the updated information: "),
		 read(D),
		 write("\n"),
		 (U==1
		 ->updateName(N,D),
		 write("\n")
		 ;U==2
		 ->updateLastName(N,D),
		 write("\n")
		 ;U==3
		 ->updateGender(N,D),
		 write("\n")
		 ;U==4
		 ->updateBirthDate(N,D),
		 write("\n")
		 ;U==5
		 ->updateFatherName(N,D),
		 write("\n")
		 ;U==6
		 ->updateMotherName(N,D),
		 write("\n")
		 ;U==7
		 ->updateDeathDate(N,D),
		 write("\n")
		 ;U==8
		 ->updateMaritalStat(N,D),
		 write("\n")
		 ;U==9
		 ->updatePartnerName(N,D),
		 write("\n"))
		 ;C==5
		 ->not(removePerson),
		 addPerson
		 ;C==0
		 ->false),
		 menu.






	
