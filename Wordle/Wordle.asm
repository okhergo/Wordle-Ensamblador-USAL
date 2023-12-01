			.module 	Wordle
 
fin			.equ		0xFF01
teclado		.equ 		0xFF02
pantalla	.equ 		0xFF00

menu:
			.ascii		"\n\nWORDLE\n"
			.ascii		"Elige una opcion: \n"		
			.ascii		"1) VER DICCIONARIO \n"
			.ascii		"2) JUGAR \n"
			.asciz 		"3) SALIR \n"

intento:	.byte		0
leida:		.asciz		"      "
secreta:	.asciz		"      "
	
			 
			.globl		palabras
			.globl 		imprime_cadena
			.globl 		almacena_palabra
			.globl 		selecciona_palabra
			.globl		num_ascii
			.globl		leida
			.globl		tabla2
			.globl		secreta
			.globl		programa
			 
programa:
			clr			intento
			lds 		#0xF000
			ldy			#0x2000
			ldd			#ver_diccionario 		;dirección de la subrutina 1
			std			0,y						;almacena en la primera posición
			ldd			#jugar					;dirección de la subrutina 2 
			std			2,y						;almacena en la segunda posición

bucle_menu:
			ldx			#menu
			jsr			imprime_cadena			;saca por pantalla la interfaz del menu
			ldb 		teclado					;carga el valor del apartado seleccionado
			cmpb		#'1
			blo			bucle_menu				;comprueba que el valor introducido es >= 1 y en caso negativo vuelve a pedir otro numero
			cmpb		#'3
			bhi			bucle_menu				;comprueba que el valor introducido es <= 3 y en caso negativo vuelve a pedir otro numero
			cmpb		#'3
			lbeq		acabar					;comprueba que el valor introducido es = 3 y en caso afirmativo termina el programa

			;transformar de ascii a numérico
			subb		#'1
			lslb

			jsr			[b,y]					;salta a la subrutina seleccionada
			bra 		programa

ver_diccionario:
			ldx			#palabras
			jsr			imprime_cadena			;saca por pantalla la lista de palabras del diccionario
			jsr			cuenta_palabras			;cuenta y saca por pantalla el numero de palabras del diccionario 
			rts

cp_cuantas:
			.byte		0
cuenta_palabras:
			ldx			#palabras
			clr			cp_cuantas				;pone el contador de palabras a 0
			ldb			#0
cp_sgte:
			lda			,x+						;carga un caracter
			beq			cp_retorno				;compara si es el 0 y en caso afirmativo sale
			incb								;incrementa en 1 el contador auxiliar
			cmpb		#6					
			bne			cp_sgte					;si no es igual a 6 (5+\n) vuelve a contar
			inc			cp_cuantas				;incrementa en 1 el contador de palabras 
			clrb
			bra			cp_sgte	

cp_retorno:
			lda			cp_cuantas				;carga el numero de palabras
			jsr			num_ascii				;transforma de numérico a ascii
			rts

tabla1: 
			.ascii		"\n  |JUEGO|ESTAN|BIEN |\n" 
			.ascii		"  -------------------\n"		 
			.ascii		"  |12345|12345|12345|\n" 
			.asciz		"  -------------------\n"
tabla2:	 
			.ascii		"1 |_____|_____|_____|\n" 
			.ascii		"2 |_____|_____|_____|\n" 
			.ascii		"3 |_____|_____|_____|\n" 
			.ascii		"4 |_____|_____|_____|\n" 
			.ascii		"5 |_____|_____|_____|\n" 
			.asciz		"6 |_____|_____|_____|\n" 
pedir_palabra:
			.asciz		"\nPALABRA: "
sin_intentos:
			.asciz		"\nTE HAS QUEDADO SIN INTENTOS"
victoria:
			.asciz		"\nHAS ACERTADO LA PALABRA"

;variables temporales empleadas en bucles
cuenta_caracter:
			.byte		0
cuenta_letras_acertadas:
			.byte		0
variable1:
			.byte		0
variable2:
			.byte 		0
jugar:    
			jsr			selecciona_palabra			;selecciona la palabra que hay que adivinar del diccionario
j_inicio:
			clr			cuenta_letras_acertadas
			lda 		intento
			cmpa		#6
			bne			j_empieza					;comprueba si te quedan intentos y en caso negativo acaba el juego
			ldx			#sin_intentos
			jsr			imprime_cadena
			rts
j_empieza:
			ldx			#pedir_palabra
			jsr			imprime_cadena
			jsr			almacena_palabra 			;lee una palabra de teclado
			ldy			#tabla2 
			lda			intento 
			ldb			#22 
			mul 
			addd		#3 
			leay		d,y 						;se coloca en la posicion de la tabla donde debe escribir
					
			ldb			#0
			ldx			#leida
j_sgte: 											;escribe la palabra leida en la primera columna
			lda			,x+ 
			incb
			cmpb		#6
			beq			estan_bien
			sta			,y+ 
			bra			j_sgte 

estan_bien:											;bucle que comprueba los caracteres de la palabra leida que coinciden con la secreta en la misma posicion
			ldy			#tabla2 
			lda			intento 
			ldb			#22 
			mul 
			addd		#15 
			leay		d,y  						;se coloca en la posicion de la tabla donde debe escribir						
					
			ldx			#leida
			ldu			#secreta
			ldb			cuenta_caracter
eb_bucle:
			cmpb		#5
			beq			estan						;cuando ya ha leido los 5 caracteres sale del bucle y continua con el programa
			incb									;incrementa el registro b que cuenta los caracteres leidos
			lda			,x+							;carga en a el caracter en la posicion 'b' de la palabra leida 		
			cmpa		,u+							;lo compara con el caracter en la posicion 'b' de la palabra secreta 		
			bne			eb_no_iguales				;si son iguales lo escribe y sino salta a la siguiente iteración tras dejar el hueco					
			sta			,y+
			inc			cuenta_letras_acertadas
			bra			eb_bucle
eb_no_iguales:
			lda			#'_						
			sta			,y+
			bra			eb_bucle		 

estan:												;bucle que comprueba los caracteres de la palabra leida que coinciden con la secreta en la misma posicion
			ldy			#tabla2 
			lda			intento			 
			ldb			#22			  
			mul 
			addd		#9 
			leay		d,y  						;se coloca en la posicion de la tabla donde debe escribir

			ldx			#leida
			lda			variable1					
e_bucle1:											;bucle que simula un for para hacer el recorrido por la palabra leida
			cmpa		#5
			beq			e_final

			lda			,x+							;carga en a el caracter en la posicion 'variable1' de la palabra leida
			ldb			variable2					
			ldu			#secreta
e_bucle2:											;bucle que simula un for anidado al for anterior para hacer el recorrido por la palabra secreta
			cmpb		#5							
			beq			e_no_iguales
			inc			variable2					;incrementa 'variable 2' que cuenta las iteraciones del bucle for anidado (hace 5, una por cada letra de la palabra secreta)
			ldb 		variable2					

			cmpa		,u+							;compara el caracter en la posicion 'variable1' de la palabra leida con el caracter en la posicion 'variable2' de la palabra secreta
			bne			e_bucle2					;si ambos caracteres son iguales lo almacena, sino vuelve a iterar el bucle
			
			clr			variable2
			sta			,y+							

e_bucle2_final:										;aqui salta cuando termina de iterar el bucle anidado
			inc			variable1					;incrementa 'variable 1' que cuenta las iteraciones del bucle for principal (hace 5, una por cada letra de la palabra leida)
			lda			variable1				
			clr			variable2
			bra			e_bucle1
e_no_iguales:										;aqui salta cuando termina de iterar el bucle anidado y no encontro ninguna letra 
			lda			#'_
			sta			,y+
			bra			e_bucle2_final
e_final:											;aqui salta cuando terminan de iterar los dos bucles
			inc			intento	

			;limpia las variables para la siguiente iteracion					
			clr			cuenta_caracter	
			clr			variable1
			clr			variable2

			;muetsra por pantalla la tabla
			ldx			#tabla1
			jsr			imprime_cadena
			ldx			#tabla2
			jsr			imprime_cadena

			lda			cuenta_letras_acertadas
			cmpa		#5							;comprueba si ya has acertado la palabra (las letras acertadas son 5)
			lbne		j_inicio					;en caso negativo continua con el juego pidiendo otra palabra y etc...
			ldx			#victoria					;en caso afirmativo muestra por pantalla que hemos acertado la palabra y vuelve a cargar el menu
			jsr			imprime_cadena
			lda			#6
			sta			intento
			lbra		j_inicio
			

acabar:
			clra
			sta 		fin
 
 
			.area		FIJA(ABS)
			.org 		0xFFFE
			.word 		programa

