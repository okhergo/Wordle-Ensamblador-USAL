			.module		Cadenas

pantalla	.equ 		0xFF00
teclado		.equ 		0xFF02

			.globl 		imprime_cadena
			.globl 		almacena_palabra
			.globl 		selecciona_palabra
			.globl		num_ascii
			.globl		leida
			.globl		secreta
			.globl		tabla2
			.globl		palabras

imprime_cadena:
;saca por pantalla la cadena apuntada por x / Entrada:X / Salida: / Reg:X,CC
			pshs		a
ic_sgte:
			lda			,x+
			beq			ic_retorno
			sta			pantalla
			bra			ic_sgte
ic_retorno:
			puls 		a
			rts

almacena_palabra:
;almacena una palabra de 5 caracteres leida por teclado
			ldy			#leida
			ldb			#0
ap_sgte: 
			lda			teclado 
			incb
			cmpb		#6
			beq			ap_retorno
			sta			,y+ 
			bra			ap_sgte 
ap_retorno: 
			rts  

selecciona_palabra:
;selecciona una palabra del diccionario 
			ldx			#palabras 
			ldy			#secreta
			ldb			#0
sp_sgte: 
			lda			,x+					;carga un caracter 
			beq			sp_retorno			;compara si es el 0 y en caso afirmativo sale 
			sta			,y+					;carga el caracter en secreta
			incb							;incrementa en 1 el contador auxiliar 
			cmpb		#5					
			bne			sp_sgte				;compara el contador auxiliar con 5: si es igual a 5 termina y sino vuelve a contar 
sp_retorno:
			rts

num_ascii:
;convierte de numerico a ascii (AVELLANO)

			; primera cifra
		    ldb			#'0
		    cmpa		#100
		    blo 		Menor100
		    suba 		#100
		    incb
		    cmpa 		#100
		    blo 		Menor200
		    incb
		    suba		#100
Menor100:
Menor200:
		    stb 		pantalla

		    ; segunda cifra.  En A quedan las dos Ultimas cifras
		    clrb
		    cmpa 		#80
		    blo 		Menor80
		    incb
		    suba 		#80
Menor80:
			lslb
		    cmpa 		#40
		    blo 		Menor40
		    incb
		    suba		 #40
Menor40:
			lslb
		    cmpa 		#20
		    blo 		Menor20
		    incb
		    suba 		#20
Menor20:
			lslb
		    cmpa 		#10
		    blo 		Menor10
		    incb
		    suba 		#10
Menor10:
			addb 		#'0
		    stb 		pantalla
		    adda		 #'0
		    sta 		pantalla

		    ; imprimimos un salto de lInea
		    ldb 		#'\n 	
			rts
