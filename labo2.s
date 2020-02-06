.global main

// Entree: lit deux entiers positifis de 64 bits: a, b
// Il est assume que les nombres sont valides
// Les nombres ne causent pas de debordement avec leur valeur unique
// Sortie:
//		Somme de a et b
//		Message citant s'il y a eu debordement ou non
//		Multiplication de a et b
// Usage des registres:
//		w19 -- a
// 		w20 -- b
// 		w21 -- a+b
//		w23 -- a*b
main:
	// Lire a
	adr   	x0, fmtEntree
	adr   	x1, nombre
	bl    	scanf                   // scanf(&fmtEntree, &nombre)
	adr		x1, nombre				// x1 <- adr[nombre]
	// ldrsh utilise parce que nbre rep sur 2 octets (16 bits)
	// ldrsh:
	// 	remplit les 32 bits de poids faible du registre avec le nombre
	//	remplit les 32 bits de poids faible avec le bit de signe
	ldrsh	w19, [x1]

	// Lire b
	adr   	x0, fmtEntree
	adr   	x1, nombre
	bl    	scanf					// scanf(&fmtEntree, &nombre)
	adr		x1, nombre              // x1 <- adr[nombre]
	ldrsh	w20, [x1]


	add   	w21, w19, w20			// w21 <- w19+w20

	// Sortie du resultat de l'addition
	adr		x0, fmtSortie
	mov 	x1, x21
	bl		printf

	// Verification du debordement
	// nbre maximale causant un debordement sur 16 bits:
	// 		-32768
	// 		32767
	mov		w22, 32767
	mov		w23, -32768
	cmp		w21, w22
	b.gt	debordement					// if(w21>w22){branch debordement}
	cmp		w21, w23
	b.lt	debordement					// if(w21<w23){branch debordement}
	b		pasDebordement				// else{branch pasDebordement}

// Sortie message debordement
debordement:
	adr		x0, msgDebordement
	bl		printf
	b		finDebordement

// Sortie message non-debordement
pasDebordement:
	adr		x0, msgSansDebordement
	bl		printf

// Debut de la multiplication
// Usage des registres de la section multiplication:
//		w22 -- compteur
// 		w23 -- resultat de la multiplication
//		w24 -- copie de b
// 		w25	-- copie de a
finDebordement:
	//pour les 32 bits representant a et b
	mov		w22, 0						// w22 <- 0
	mov		w23, 0						// w23 <- 0
	mov		w24, w20					// w24 <- w20
	mov		w25, w19					// w25 <- w19

// valeur b est utilisee pour nbre d'iterations
debutMultiplication:
	tbnz	w24, 0, additionTerme		// if(w24==0){branch addition terme}
	b		sansAddition				// else{branch sansAddition}

// valeur a est ajoutee au resultat un nbre b de fois
additionTerme:
	add		w23, w23, w25				// w23 += w25

sansAddition:
	//Decalement du resultat vers la gauche pour la copie du nombre a
	lsl		w25, w25, 1
	//Decalement du resultat vers la droite pour la copie du nombre b
	lsr		w24, w24, 1
	add		w22, w22, 1					// w22++
	cmp		w22, 31
	b.hi	finMultiplication			// if(w22>31){branch finMultiplication}
	b 		debutMultiplication			// else{branch debutMultiplication}

// Sortie du resultat de la multiplication
finMultiplication:
	adr		x0, fmtSortie
	mov 	x1, x23
	bl		printf

	// quit
    mov     x0, 0
    bl      exit

// Section des donnees
.section ".bss"
         	.align  8
nombre:     .skip   8

.section ".rodata"
fmtEntree:          .asciz  "%hd"
fmtSortie:          .asciz  "%d\n"
msgDebordement:     .asciz  "débordement\n"
msgSansDebordement: .asciz  "sans débordement\n"
