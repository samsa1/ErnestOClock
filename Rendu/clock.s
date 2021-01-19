#r00 : clock ; r01, r02 : secondes ; r03, r04 : minutes ; r05, r06 : heures ;  
#r07, r08 : jours ; r09, r10, r11 : mois ; r12, r13, r14 : année
#r15 : calcul bissextile ; r16 : changement de mois
#r17 : addresse ram ; r18 : argument ; r19 : stockage de la position de ccp
    mov %r20 $4
    add (%r20) $3600
debut:
    mov %r20 $4
    mov %r28 (%r20)
	mov %r26 $86400
	mov %r25 %r26
	jmp "ew1"
bw1:
	lsl %r25 $1
ew1:
	cmp %r28 %r25
	jb "bw1"
	mov %r27 $0
bw2:
	lsl %r27 $1
	cmp %r28 %r25
	ja "ew2"
	add %r27 $1
	sub %r28 %r25
ew2:
	lsr %r25 $1
	cmp %r25 %r26
	jge "bw2"
saveDate_in_r24:
	mov %r24 %r27
compute_DizaineH:
	mov %r26 $36000
	mov %r25 %r26
	jmp "ew3"
bw3:
	lsl %r25 $1
ew3:
	cmp %r28 %r25
	jg "bw3"
	mov %r27 $0
bw4:
	lsl %r27 $1
	cmp %r28 %r25
	ja "ew4"
	add %r27 $1
	sub %r28 %r25
ew4:
	lsr %r25 $1
	cmp %r25 %r26
	jge "bw4"
	mov %r06 %r27
compute_UniteH:
	mov %r26 $3600
	mov %r25 %r26
	jmp "ew5"
bw5:
	lsl %r25 $1
ew5:
	cmp %r28 %r25
	jg "bw5"
	mov %r27 $0
bw6:
	lsl %r27 $1
	cmp %r28 %r25
	ja "ew6"
	add %r27 $1
	sub %r28 %r25
ew6:
	lsr %r25 $1
	cmp %r25 %r26
	jge "bw6"
	mov %r05 %r27
compute_DizaineM:
	mov %r26 $600
	mov %r25 %r26
	jmp "ew7"
bw7:
	lsl %r25 $1
ew7:
	cmp %r28 %r25
	jg "bw7"
	mov %r27 $0
bw8:
	lsl %r27 $1
	cmp %r28 %r25
	ja "ew8"
	add %r27 $1
	sub %r28 %r25
ew8:
	lsr %r25 $1
	cmp %r25 %r26
	jge "bw8"
	mov %r04 %r27
compute_UniteM:
	mov %r26 $60
	mov %r25 %r26
	jmp "ew9"
bw9:
	lsl %r25 $1
ew9:
	cmp %r28 %r25
	jg "bw9"
	mov %r27 $0
bw10:
	lsl %r27 $1
	cmp %r28 %r25
	ja "ew10"
	add %r27 $1
	sub %r28 %r25
ew10:
	lsr %r25 $1
	cmp %r25 %r26
	jge "bw10"
	mov %r03 %r27
compute_Sec:
	mov %r26 $10
	mov %r25 %r26
	jmp "ew11"
bw11:
	lsl %r25 $1
ew11:
	cmp %r28 %r25
	jg "bw11"
	mov %r27 $0
bw12:
	lsl %r27 $1
	cmp %r28 %r25
	jl "ew12"
	add %r27 $1
	sub %r28 %r25
ew12:
	lsr %r25 $1
	cmp %r25 %r26
	jge "bw12"
	mov %r02 %r27
	mov %r01 %r28
calcul_date:
    mov %r22 $70
    mov %r23 $19
    jmp "ew13"
bw13:
    test %r22 $3
    je "mul4"
    sub %r24 $365
    incr %r22
    cmp %r22 $100
    jne "ew13"
    mov %r22 $0
    incr %r23
    jmp "ew13"
mul4:
    cmp %r22 $0
    jne "bissextile"
    test %r23 $3
    je "bissextile"
    sub %r24 $365
    incr %r22
    jmp "ew13"
bissextile:
    sub %r24 $366
    incr %r22
ew13:
    cmp %r24 $365
    jb "bw13"
    jne "decomposeAnne"
    test %r22 $3
    je "mul4bis"
    sub %r24 $365
    incr %r22
    cmp %r22 $100
    jne "decomposeAnne"
    mov %r22 $0
    incr %r23
    jmp "decomposeAnne"
mul4bis:
    cmp %r22 $0
    jne "decomposeAnne"
    test %r23 $3
    je "decomposeAnne"
    sub %r24 $365
    incr %r22
decomposeAnne:
    mov %r14 %r23
    mov %r28 %r22
    mov %r25 $10
    mov %r26 %r25
    jmp "ew14"
bw14:
    lsl %r25 $1
ew14:
    cmp %r28 %r25
    jg "bw14"
    mov %r27 $0
bw15:
    lsl %r27 $1
    cmp %r28 %r25
    ja "ew15"
    add %r27 $1
    sub %r28 %r25
ew15:
    lsr %r25 $1
    cmp %r25 %r26
    jge "bw15"
    mov %r13 %r27
    mov %r12 %r28
calculMois:
    mov %r22 $1
    cmp %r24 $31
    jae "finMois"
    sub %r24 $31
    mov %r22 $2
    mov %r23 %r13
    lsl %r23 $1
    add %r23 %r12
    test %r23 $3
    jne "pasBissextile"
    cmp %r12 $0
    jne "estBissextile"
    cmp %r13 $0
    jne "estBissextile"
    test %r14 $3
    jne "pasBissextile"
estBissextile:
    mov %r15 $1
    mov %r23 $29
    jmp "fevrierCalc"
pasBissextile:
    mov %r15 $0
    mov %r23 $28
fevrierCalc:
    cmp %r24 %r23
    jae "finMois"
    sub %r24 %r23
    mov %r22 $3
    cmp %r24 $31
    jae "finMois"
    sub %r24 $31
    mov %r22 $4
    cmp %r24 $30
    jae "finMois"
    sub %r24 $30
    mov %r22 $5
    cmp %r24 $31
    jae "finMois"
    sub %r24 $31
    mov %r22 $6
    cmp %r24 $30
    jae "finMois"
    sub %r24 $30
    mov %r22 $7
    cmp %r24 $31
    jae "finMois"
    sub %r24 $31
    mov %r22 $8
    cmp %r24 $31
    jae "finMois"
    sub %r24 $31
    mov %r22 $9
    cmp %r24 $30
    jae "finMois"
    sub %r24 $30
    mov %r22 $10
    cmp %r24 $31
    jae "finMois"
    sub %r24 $31
    mov %r22 $11
    cmp %r24 $30
    jae "finMois"
    sub %r24 $30
    mov %r22 $12
finMois:
    mov %r10 $0
    mov %r11 %r22
    mov %r09 %r22
    cmp %r09 $10
    jae "decomposeJour"
    mov %r10 $1
    sub %r09 $10
decomposeJour:
    incr %r24
    mov %r28 %r24
    mov %r25 $10
    mov %r26 %r25
    jmp "ew16"
bw16:
    lsl %r25 $1
ew16:
    cmp %r28 %r25
    jg "bw16"
    mov %r27 $0
bw17:
    lsl %r27 $1
    cmp %r28 %r25
    ja "ew17"
    add %r27 $1
    sub %r28 %r25
ew17:
    lsr %r25 $1
    cmp %r25 %r26
    jge "bw17"
    mov %r08 %r27
    mov %r07 %r28
affichage:
affichage_unite_Mois:
    mov %r26 $2
    mov %r28 $0
    cmp %r09 $0
    move %r28 $95
    cmp %r09 $1
    move %r28 $3
    cmp %r09 $2
    move %r28 $118
    cmp %r09 $3
    move %r28 $115
    cmp %r09 $4
    move %r28 $43
    cmp %r09 $5
    move %r28 $121
    cmp %r09 $6
    move %r28 $125
    cmp %r09 $7
    move %r28 $67
    cmp %r09 $8
    move %r28 $127
    cmp %r09 $9
    move %r28 $123
    lsl %r28 $24
    mov %r27 %r28
    mov (%r26) %r27
affichage_dizaines_Mois:
    mov %r28 $0
    cmp %r10 $0
    move %r28 $95
    cmp %r10 $1
    move %r28 $3
    lsl %r28 $16
    or %r27 %r28
    mov (%r26) %r27
affichage_unite_Annee:
    mov %r28 $0
    cmp %r12 $0
    move %r28 $95
    cmp %r12 $1
    move %r28 $3
    cmp %r12 $2
    move %r28 $118
    cmp %r12 $3
    move %r28 $115
    cmp %r12 $4
    move %r28 $43
    cmp %r12 $5
    move %r28 $121
    cmp %r12 $6
    move %r28 $125
    cmp %r12 $7
    move %r28 $67
    cmp %r12 $8
    move %r28 $127
    cmp %r12 $9
    move %r28 $123
    lsl %r28 $8
    or %r27 %r28
    mov (%r26) %r27
affichage_dizaines_Annee:
    mov %r28 $0
    cmp %r13 $0
    move %r28 $95
    cmp %r13 $1
    move %r28 $3
    cmp %r13 $2
    move %r28 $118
    cmp %r13 $3
    move %r28 $115
    cmp %r13 $4
    move %r28 $43
    cmp %r13 $5
    move %r28 $121
    cmp %r13 $6
    move %r28 $125
    cmp %r13 $7
    move %r28 $67
    cmp %r13 $8
    move %r28 $127
    cmp %r13 $9
    move %r28 $123
    or %r27 %r28
    mov (%r26) %r27
affichage_unite_Heure:
    mov %r26 $1
    mov %r28 $0
    cmp %r05 $0
    move %r28 $95
    cmp %r05 $1
    move %r28 $3
    cmp %r05 $2
    move %r28 $118
    cmp %r05 $3
    move %r28 $115
    cmp %r05 $4
    move %r28 $43
    cmp %r05 $5
    move %r28 $121
    cmp %r05 $6
    move %r28 $125
    cmp %r05 $7
    move %r28 $67
    cmp %r05 $8
    move %r28 $127
    cmp %r05 $9
    move %r28 $123
    lsl %r28 $24
    mov %r27 %r28
    mov (%r26) %r27
affichage_dizaines_Heure:
    mov %r28 $0
    cmp %r06 $0
    move %r28 $95
    cmp %r06 $1
    move %r28 $3
    cmp %r06 $2
    move %r28 $118
    lsl %r28 $16
    or %r27 %r28
    mov (%r26) %r27
affichage_unite_Jour:
    mov %r28 $0
    cmp %r07 $0
    move %r28 $95
    cmp %r07 $1
    move %r28 $3
    cmp %r07 $2
    move %r28 $118
    cmp %r07 $3
    move %r28 $115
    cmp %r07 $4
    move %r28 $43
    cmp %r07 $5
    move %r28 $121
    cmp %r07 $6
    move %r28 $125
    cmp %r07 $7
    move %r28 $67
    cmp %r07 $8
    move %r28 $127
    cmp %r07 $9
    move %r28 $123
    lsl %r28 $8
    or %r27 %r28
    mov (%r26) %r27
affichage_dizaines_Jour:
    mov %r28 $0
    cmp %r08 $0
    move %r28 $95
    cmp %r08 $1
    move %r28 $3
    cmp %r08 $2
    move %r28 $118
    cmp %r08 $3
    move %r28 $115
    or %r27 %r28
    mov (%r26) %r27
    xor %r26 %r26
affichage_unite_Secondes:
    cmp %r01 $5
    jge "us_59"
    mov %r28 $95
    cmp %r01 $1
    move %r28 $3
    cmp %r01 $2
    move %r28 $118
    cmp %r01 $3
    move %r28 $115
    cmp %r01 $4
    move %r28 $43
    jmp "us_fin"
us_59:
    mov %r28 $125
    move %r28 $121
    cmp %r01 $7
    move %r28 $67
    cmp %r01 $8
    move %r28 $127
    cmp %r01 $9
    move %r28 $123
us_fin:
    lsl %r28 $25
    mov (%r26) %r28
affichage_dizaines_Secondes:
    mov %r28 $95
    cmp %r02 $1
    move %r28 $3
    cmp %r02 $2
    move %r28 $118
    cmp %r02 $3
    move %r28 $115
    cmp %r02 $4
    move %r28 $43
    cmp %r02 $5
    move %r28 $121
    lsl %r28 $18
    or (%r26) %r28
affiche_unite_Minutes:
    mov %r28 $95
    cmp %r03 $1
    move %r28 $3
    cmp %r03 $2
    move %r28 $118
    cmp %r03 $3
    move %r28 $115
    cmp %r03 $4
    move %r28 $43
    cmp %r03 $5
    move %r28 $121
    cmp %r03 $6
    move %r28 $125
    cmp %r03 $7
    move %r28 $67
    cmp %r03 $8
    move %r28 $127
    cmp %r03 $9
    move %r28 $123
    lsl %r28 $11
    or (%r26) %r28
affichage_dizaines_Minutes:
    mov %r28 $95
    cmp %r04 $1
    move %r28 $3
    cmp %r04 $2
    move %r28 $118
    cmp %r04 $3
    move %r28 $115
    cmp %r04 $4
    move %r28 $43
    cmp %r04 $5
    move %r28 $121
    lsl %r28 $4
    or (%r26) %r28
    mov %r00 %r01
    and %r00 $1
    or (%r26) %r00
    or (%r26) $2
    mov %r00 $0
    test %r01 $1
    je "casPair"
casImpair:
    test (%r00) $1
    jne "casImpair"
    jmp "condfin"
casPair:
    test (%r00) $1
    je "casPair"
condfin:
    incr %r01
    cmp %r01 $10
    jne "affichage_unite_Secondes"

    mov %r01 $0
    incr %r02
    cmp %r02 $6
    jne "affichage_unite_Secondes"

    mov %r02 $0
    incr %r03
    cmp %r03 $10
    jne "affichage_unite_Secondes"

    mov %r03 $0
    incr %r04
    cmp %r04 $6
    jne "affichage_unite_Secondes"

    mov %r04 $0
    incr %r05

    cmp %r05 $4
    je "incr_day"

    cmp %r05 $10
    jne "affichage"
    mov %r05 $0
    incr %r06
    jmp "affichage"

incr_day:
    cmp %r06 $2
    jne "affichage"
    mov %r05 $0
    mov %r06 $0
    test %r11 $8
    je "supEgal8"
    test %r11 $1
    je "impairMois"
    cmp %r09 $2
    je "fevrier"
    cmp %r08 $3
    je "finAJ"
    incr %r07
    cmp %r07 $10
    jne "affichage"
    mov %r07 $0
    incr %r08
    jmp "affichage"
finAJ:
    mov %r08 $0
    mov %r07 $1
    incr %r09
    incr %r11
    jmp "affichage"
fevrier:
    cmp %r08 $2
    jne "debutFevrier"
    mov %r00 $8
    add %r00 %r15
    cmp %r07 %r00
    jne "pasFinFev"
    mov %r07 $1
    mov %r08 $0
    incr %r09
    incr %r11
    jmp "affichage"
pasFinFev:
    incr %r07
    jmp "affichage"
debutFevrier:
    incr %r07
    cmp %r07 $10
    jne "affichage"
    mov %r07 $0
    incr %r08
    jmp "affichage"
impairMois:
    cmp %r08 $3
    je "j31_30"
    incr %r07
    cmp %r07 $10
    jne "affichage"
    mov %r07 $0
    incr %r08
    jmp "affichage"
j31_30:
    cmp %r07 $1
    je "j31_31"
    incr %r07
    jmp "affichage"
j31_31:
    mov %r08 $0
    incr %r09
    incr %r11
    jmp "affichage"

supEgal8:
    test %r11 $1
    jne "n31"
    cmp %r08 $3
    je "n30_30"
    incr %r07
    cmp %r07 $10
    jne "affichage"
    mov %r07 $0
    incr %r08
    jmp "affichage"
n30_30:
    mov %r08 $0
    mov %r07 $1
    incr %r09
    incr %r11
    cmp %r09 $10
    jne "affichage"
    mov %r09 $0
    incr %r10
    jmp "affichage"
n31:
    cmp %r08 $3
    je "n31_30"
    incr %r07
    cmp %r07 $10
    jne "affichage"
    mov %r07 $0
    incr %r08
n31_30:
    cmp %r08 $0
    jne "finMoisFinAnnee"
    incr %r07
    jmp "affichage"
finMoisFinAnnee:
    mov %r08 $0
    mov %r07 $1
    incr %r09
    incr %r11
    cmp %r09 $3
    jne "affichage"
    mov %r07 $1
    mov %r08 $0
    mov %r09 $1
    mov %r10 $0
    mov %r11 $1
    incr %r12
    cmp %r12 $10
    jne "calcBissextile"
    mov %r12 $0
    incr %r13
    cmp %r13 $10
    jne "calcBissextile"
    mov %r13 $0
    incr %r14
calcBissextile:
    mov %r00 %r13
    lsl %r00 $2
    add %r00 %r12
    test %r00 $3
    je "multiple4"
    mov %r15 $0
    jmp "affichage"
multiple4:
    cmp %r00 $0
    je "multiple100"
    mov %r15 $1
    jmp "affichage"
multiple100:
    test %r14 $3
    je "multiple400"
    mov %r15 $0
    jmp "affichage"
multiple400:
    mov %r15 $1
    jmp "affichage"

