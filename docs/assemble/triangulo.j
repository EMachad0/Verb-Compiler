.source tests/triangulos-dados.ve
.class public output/Verb
.super java/lang/Object

.method public <init>()V
	aload_0
	invokenonvirtual java/lang/Object/<init>()V
	return
.end method

.method public static main([Ljava/lang/String;)V
.limit locals 100
.limit stack 100
; code start
.line 1
.line 9
.line 10

; CRIACAO DAS VARIAVEIS PONTO FLUTUANTE

invokestatic output/Verb/input_float()F
invokestatic output/Verb/input_float()F
invokestatic output/Verb/input_float()F
fstore 1
fstore 2
fstore 3

.line 11

; IMPRESSOES NA TELA

.line 12

; carrega a string "a = " pra stack
ldc "a = "

; carrega o método out pra stack
getstatic java/lang/System/out Ljava/io/PrintStream;

; swap para ficar primeiro a string dps o método no topo da pilha
swap

; chama o metodo print passando o tipo string
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V

; imprimir um float na tela
fload 3
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(F)V

; por final printar o \n

; REPETE TD PARA OS OUTROS PRINTS

getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
.line 13
ldc "b = "
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
fload 2
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(F)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
.line 14
ldc "c = "
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
fload 1
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(F)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
.line 15
ldc "\n"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
.line 16
ldc "Análise dos lados de um triângulo\n"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V

; FINAL DOS PRIMEIROS PRINTS

.line 17
.line 18
.line 19
.line 20
.line 21
.line 22
.line 23
.line 24
.line 25
.line 26
.line 27

; SUBTRACAO E CRIACAO DAS VARIAVEIS

fload 2
fload 1
fsub               ; subtrai os dois primeiros da pilha
fstore 4           ; armazena na variavel

; repeticao de subtracoes

.line 28
fload 3
fload 1
fsub
fstore 5
.line 29
fload 3
fload 2
fsub
fstore 6
.line 30

.line 31

; COMECO DOS IFS

fload 4               ; carrega a variável 4
ldc 0.000000          ; carrega 0.0 pra stack
fcmpg                 ; compara os floats e coloca o resultado na pilha
iflt L_1              ; se o resultado for menor que 0 vai pra L1
iconst_0              ; senão carrega 0
goto L_2
L_1:
iconst_1              ; carrega 1
L_2:
ifeq L_3              ; se o topo for 0 vai pra L3
fload 4               ; senao atribui a variavel
fneg                  ; o valor negado
fstore 4              ; e armazena
goto L_4              ; e vai pro fim
L_3:
.line 32

; repeticao dos de ifs

L_4:
fload 5
ldc 0.000000
fcmpg
iflt L_5
iconst_0
goto L_6
L_5:
iconst_1
L_6:
ifeq L_7
fload 5
fneg
fstore 5
goto L_8
L_7:
.line 33
L_8:
fload 6
ldc 0.000000
fcmpg
iflt L_9
iconst_0
goto L_10
L_9:
iconst_1
L_10:
ifeq L_11
fload 6
fneg
fstore 6
goto L_12
L_11:
.line 34
.line 35

; COMECO DO IF GRANDE

; condicoes do if

L_12:
fload 3
fload 4
fcmpg
ifgt L_13
iconst_0
goto L_14
L_13:
iconst_1
L_14:
fload 3
fload 2
fload 1
fadd
fcmpg
iflt L_15
iconst_0
goto L_16
L_15:
iconst_1
L_16:
iand
fload 2
fload 5
fcmpg
ifgt L_17
iconst_0
goto L_18
L_17:
iconst_1
L_18:
fload 2
fload 3
fload 1
fadd
fcmpg
iflt L_19
iconst_0
goto L_20
L_19:
iconst_1
L_20:
iand
iand
fload 1
fload 6
fcmpg
ifgt L_21
iconst_0
goto L_22
L_21:
iconst_1
L_22:
fload 1
fload 3
fload 2
fadd
fcmpg
iflt L_23
iconst_0
goto L_24
L_23:
iconst_1
L_24:
iand
iand
ifeq L_63

; instrucoes caso entre no if

.line 36
ldc "\nOk-> dados validados!"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
.line 37

; criacao das variaveis dentro do if

fconst_0
fstore 7
fconst_0
fstore 8
fconst_0
fstore 9
fconst_0
fstore 10

; if de dentro

.line 38
fload 3
fload 2
fcmpg
ifgt L_25
iconst_0
goto L_26
L_25:
iconst_1
L_26:
fload 3
fload 1
fcmpg
ifgt L_27
iconst_0
goto L_28
L_27:
iconst_1
L_28:
iand
ifeq L_29
.line 39
ldc 1
i2f
fstore 10
.line 40
fload 3
fstore 9
.line 41
fload 2
fstore 8
.line 42
fload 1
fstore 7
.line 43
goto L_42

; comeco do else de dentro

L_29:

; mais um if dentro do else

.line 44
fload 2
fload 3
fcmpg
ifgt L_30
iconst_0
goto L_31
L_30:
iconst_1
L_31:
fload 2
fload 1
fcmpg
ifgt L_32
iconst_0
goto L_33
L_32:
iconst_1
L_33:
iand
ifeq L_34

; instrucoes caso entre no if

.line 45
ldc 2
i2f
fstore 10
.line 46
fload 2
fstore 9
.line 47
fload 3
fstore 8
.line 48
fload 1
fstore 7
.line 49
goto L_41

; else do if de dentro do else

L_34:
.line 50

; mais um if dentro do else que ta dentro do else

fload 1
fload 3
fcmpg
ifgt L_35
iconst_0
goto L_36
L_35:
iconst_1
L_36:
fload 1
fload 2
fcmpg
ifgt L_37
iconst_0
goto L_38
L_37:
iconst_1
L_38:
iand
ifeq L_39
.line 51
ldc 3
i2f
fstore 10
.line 52
fload 1
fstore 9
.line 53
fload 3
fstore 8
.line 54
fload 2
fstore 7
.line 55
goto L_40

; else do if de dentro do else de dentro do else

L_39:
ldc 4
i2f
fstore 10
L_40:
.line 56
L_41:
.line 57

; final do primeiro if de dentro do if

L_42:
.line 58
.line 59
.line 60

; COMECO DO SEGUNDO IF DE DENTRO DO IF

fload 10
ldc 4.000000
fcmpg
ifeq L_43
iconst_0
goto L_44
L_43:
iconst_1
L_44:
ifeq L_45

; caso entre só printa

ldc "\nTrata-se de um triângulo equilátero!\n(lados e ângulos iguais...)"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
goto L_62

; se não vai pro else

L_45:


.line 61
.line 62

; e aqui tem o print de dentro do else

fload 3
fload 2
fcmpg
ifeq L_46
iconst_0
goto L_47
L_46:
iconst_1
L_47:
fload 2
fload 1
fcmpg
ifeq L_48
iconst_0
goto L_49
L_48:
iconst_1
L_49:
ior
fload 1
fload 3
fcmpg
ifeq L_50
iconst_0
goto L_51
L_50:
iconst_1
L_51:
ior
ifeq L_52

; caso entre no if

ldc "\nTrata-se de um triângulo isósceles!"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
goto L_53

; caso nao entre no if

L_52:
.line 63
ldc "\nTrata-se de um triângulo escaleno!"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
L_53:
.line 64

; criacao das variaveis e multiplicacao

fload 9                         ; carrega a variavel
fload 9                         ; carrega a variavel
fmul                            ; multiplica
fstore 11                       ; e a armazena

; repeticao das multiplicacoes

.line 65
fload 8
fload 8
fmul
fstore 12
.line 66
fload 7
fload 7
fmul
fstore 13
.line 67


; mais um if

; condicoes

fload 11
fload 12
fload 13
fadd
fcmpg
iflt L_54
iconst_0
goto L_55
L_54:
iconst_1
L_55:
ifeq L_56

; se entrar

ldc "Trata-se de um triângulo acutângulo!"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
goto L_61

; se não entrar

L_56:
.line 68
.line 69

; ultimo if

; condicoes

fload 11
fload 12
fload 13
fadd
fcmpg
ifeq L_57
iconst_0
goto L_58
L_57:
iconst_1
L_58:
ifeq L_59

; se entrar

ldc "Trata-se de um triângulo retângulo!"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
goto L_60

; ultimo else

L_59:
.line 70
ldc "Trata-se de um triângulo obtusângulo!"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V
L_60:
.line 71
L_61:
.line 72
L_62:
.line 73
goto L_64
L_63:

; se não entrar no primeiro if

ldc "\nNão se trata de um triângulo!"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
getstatic java/lang/System/out Ljava/io/PrintStream;
invokevirtual java/io/PrintStream/println()V

; e acabou

L_64:
.line 74
.line 75
; code end
return
.end method
