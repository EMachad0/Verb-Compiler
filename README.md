<h1 align="center">Compilador Verb</h1>

Compilador para a linguagem de própria autoria "Verb" feito usando [flex e bison](https://web.iitd.ac.in/~sumeet/flex__bison.pdf), a linguagem é compilada para [assembly JVM](https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-1.html) e pode ser executada usando [jasmin](http://jasmin.sourceforge.net/about.html) e java.

<p align="center">
  <a href="#1-linguagem">Linguagem</a>
  •
  <a href="#2-análise-léxica">Análise Léxica</a>
  •
  <a href="#3-gramática">Gramática</a>
  •
  <a href="#4-geração-de-bytecode">Geração de Bytecode</a>
  •
  <a href="#5-reconhecimento-de-erros">Reconhecimento de erros</a>
  <br>
  <a href="#6-comentários-sobre-a-linguagem">Comentários Sobre a Linguagem</a>
  •
  <a href="#7-comentários-sobre-as-ferramentas">Comentários Sobre as Ferramentas</a>
  •
  <a href="#8-melhorias">Melhorias</a>
  <br>
  <a href="#9-trabalhos-de-referência-e-inspirações">Trabalhos de Referência e Inspirações</a>
</p>

* Para compilar use o comando: 
    ```
    make f=<verb-file>.ve
    ```
    Substituindo `<verb-file>` por um código verb, você pode usar um dos exemplos em `./tests/`.

* Para mais instruções use:
    ```
    make help
    ```

## 1. Linguagem

Nomeada *Verb*, a linguagem tem como objetivo ser menos verbosa que as linguagens populares, para isso na linguagem desenvolvida todas as palavras reservadas são um caractere maiúsculo ou um símbolo, ela possibilita tanto o uso de código que não está em funções, quanto definição e chamada de funções. A definição dos blocos é dada como em C, com abertura e fechamento de colchetes ({}), e, assim como em C, a abertura de bloco só é necessária em *if*'s, *while*'s, *for*'s quando há mais de uma instrução no corpo do comando. Ela é fortemente tipada, portanto, na criação de uma variável ou função é necessário informar qual o tipo do dado. As condicionais dos blocos devem ser delimitadas por parenteses.

Como a proposta é de cada palavra reservada tenha somente um caractere, é necessário ter uma lista de comandos para que o programador que está tendo seu primeiro contato saber qual o significado de cada comando:

#### Tipos

* I: `int`
* D: `float`
* S: `string`

#### Comandos de Fluxo

* ? = `if`
* \$ = `else if`
* : = `else`
* W = `while`
* F = `for`

Foi optado por não implementar os comandos de fluxo `do-while` e `switch` pois os autores tem a visão de que esses comandos são desnecessários e/ou redundantes.

#### Funções Built-In

* P() = `print()`
    * Pode receber como parâmetro, inteiros, ponto flutuantes e strings. E também pode receber mais de um parâmetro, dessa forma imprimindo todos os valores passados e um `\n` no final.
* R() = `input()`
    * Aceita inteiros e ponto flutuantes.

#### Funções Definidas pelo Usuário

A função tem suporte para funções definidas pelo usuário, mas elas deve ser todas definidas no começo do arquivo e a sintaxe de definição de função é a seguinte:

```
@ <tipo> <nome-func>(<lista-param>) {
    = <retorno>;
}
```

#### Exemplo

Com isso já é possível ter uma visão geral sobre a linguagem, para finalizar essa introdução a seguir está um código de exemplo que visa apenas apresentar a sintaxe:

```c
D a = R(D), b = R(D), c = R(D);    // recebe três floats do usúario

D media = (2*a + 3*b + 5*c) / 10;  // calcula a média ponderada

P("MEDIA = ", media);              // imprime a média para o terminal 
```

O código acima mostra a resolução de um problema de média ponderada;

## 2. Análise Léxica

A análise léxica foi auxiliada pela ferramenta **flex** e nela forma definidos os tokens e seus respectívos *regex*. Durante a análise léxica também foi salva a estrutura do código para o tratamento de erros, por exemplo: linha é incrementada quando um `\n` é encontrado, quando palavras são encontradas o início e final são marcados, etc. Enumerando alguns dos *regex*'es e seus tokens:

```
/* numeros */
DIGITO          [0-9]
INTEIRO         {DIGITO}+
FLUTUANTE       {INTEIRO}\.{DIGITO}*|{INTEIRO}*\.{DIGITO}+

/* palavras reservadas */
KEYWORD         [DFIPRSVW?@]

/* variaveis */
ID              [a-z_][a-z0-9_]*

/* strings */
CHARACTER       [^"]
TEXTO           ["]{CHARACTER}*["]

/* operadores */
SCO_OP          [=|^&<>+\-*/%!~]
ATT_OP          ([+\-*/%&^|]|<<|>>|\*\*)=
BOOL_OP         \&\&|\|\|
CMP_OP          [=!<>]=
BITSHIFT_OP     <<|>>
UNARY_OP        \+\+|\-\-
EXP_OP          \*\*

/* comentarios */
LINE_COMMENT    \/\/[^\n]*
BLOCK_COMMENT   \/\*[^*]*\*\/
```

Observe que não podem haver variáveis com **letra maiúscula**, pois foi decidido que as letras maiúsculas seriam somente para palavras reservadas.

## 3. Gramática

A gramática da linguagem ficou definida como a seguinte:

<details>
<summary>Gramática</summary>

```c
00 $accept: program $end
01 $@1: %empty
02 $@2: %empty
03 program: function_list block
04        | error program
05 block: %empty
06      | statement block
07      | flux block
08 statement: declaration ';'
09          | assignment ';'
10          | print ';'
11          | '=' expr ';'
12 optional_block: statement
13               | '{' block '}'
14 type: 'I'
15     | 'D'
16     | 'S'
17     | 'V'
18 value: INTEGER
19      | FLOAT
20      | STRING
21 expr: value
22     | call
23     | expr '' expr
24     | expr '' expr
25     | expr CMPOP expr
26     | expr '|' expr
27     | expr '^' expr
28     | expr '' expr
29     | expr BOOLOP expr
30     | expr BITSHIFTOP expr
31     | expr '+' expr
32     | expr '-' expr
33     | expr '*' expr
34     | expr '/' expr
35     | expr '%' expr
36     | '-' expr
37     | '!' expr
38     | '(' type expr ')'
39     | '(' expr ')'
40 declaration: type decla_or_assign_list
41 decla_or_assign_list: decla_or_assign
42                     | decla_or_assign ',' decla_or_assign_list
43 decla_or_assign: ID
44                | ID '=' expr
45 assignment: ID '=' expr
46           | ID ATTOP expr
47           | ID UNARYOP
48           | UNARYOP ID
49 call: ID
50     | ID UNARYOP
51     | UNARYOP ID
52     | 'R' '(' type ')'
53     | ID '(' ')'
54     | ID '(' expr_list ')'
55 expr_list: expr
56          | expr ',' expr_list
57 assignment_list: assignment
58                | assignment ',' assignment_list
59 flux: if
60     | while
61     | for
62 if: '?' '(' expr ')' ifeq optional_block goto label elseif else label
63 elseif: %empty
64       | '$' '(' expr ')' ifeq optional_block goto label elseif
65 else: %empty
66     | ':' optional_block
67 while: 'W' label '(' expr ')' ifeq optional_block goto label
68 for: 'F' '(' declaration ';' label expr ifeq goto ';' label assignment_list goto ')' label optional_block goto label
69 $@3: %empty
70 function: '@' type ID '(' ')' $@3 optional_block
71 $@4: %empty
72 function: '@' type ID '(' declaration_list ')' $@4 optional_block
73 function_list: %empty
74              | function function_list
75 simple_declaration: type ID
76 declaration_list: simple_declaration
77                 | simple_declaration ',' declaration_list
78 print_list: expr
79 $@5: %empty
80 print_list: expr $@5 ',' print_list
81 print: 'P' '(' print_list ')'
82 label: %empty
83 goto: %empty
84 ifeq: %empty
```

</details>

A gramatica foi desenvolvida sem nenhuma ambiguidade de shift/reduce ou reduce/reduce, optou-se por impedir conflitos como o *Dangling else problem* obrigando o usuario a escrever um codigo sem ambiguidade.

## 4. Geração de Bytecode

Tendo a gramática e as regras sitáticas escritas no **bison**, a geração de bytecode foi feita utilizando da estrutura do bison, fazendo as chamadas necessárias e salvando o código em um array dinâmico, e após o término o *bytecode* salvo é impresso no arquivo alvo(`verb.j`).

Para a geração do bytecode foram implementadas duas estruturas genéricas: **hashmap** e **vector**. No hashmap são salvos as variáveis (*ids*), principalmente com seu nome e a posição em que foram armazenadas no *assembly*. Já o vector é usado para salvar todo o código antes de ser salvo no arquivo de saída, e também em momentos em que é necessário armazenar listas.

Nas próximas seções será introduzido como as principais funcionalidades são traduzidas para o bytecode.

#### Definição de Variáveis:

Para criar uma variável em assembly da JVM, é necessário carregar um valor inicial para a *stack*, e dar o comando \<tipo\>store, em que o tipo é **i** para inteiro, **f** para float. Então por exemplo a criação de uma variável inteira na linguagem verb é traduzida da seguinte forma:

```
I a;
```

```
iconst_0
istore 1
```

Não é suportada somente a definição de uma variável do tipo **string**, ela deve ser atribuída no momento da definição.


#### Atribuição de Valores Constantes a Variáveis

A atribuição se dá colocando o valor a ser atribuído no topo da *stack* e dando o comando respectívo ao tipo da variável. Por exemplo, a definição de um inteiro e atribuição fica como segue:

```
I a;
a = 1;
```

```
.line 1        ; I a;
iconst_0
istore 1
.line 2        ; a = 1;
ldc 1
istore 1
```

É possível definir e atribuir resultados na mesma linha, tal operação se traduz no caso de uma **string** como segue:

```
S a = "Hello World";
```

```
ldc "Hello World"
astore 1
```

#### Comando `if`, `else`, `else-if`

O comando de fluxo `if` é traduzido para algumas operações. Como pode ser visto na gramática, o if pode receber qualquer expressão como condição, então a lógica usada para traduzir um if foi: deixar o resultado da expressão no topo da pilha e se o resultado for diferente de zero o fluxo é quebrado para entrar proceder com as instruções entrando no `if`, e no final dessas instruções há sempre uma quebra para fora do `if`; se não, o fluxo é quebrado para a próxima instrução, que pode ser um `else-if`, o else fica sempre como última label na qual somente entra se não entrar em nenhum dos outros comandos. Por exemplo:

```
I a;
? (1 == 1) {
    a = 1;
} $ (1 == 2) {
    a = 2;
} : {
    a = 3;
}
```

```
.line 1            ; I a;
iconst_0
istore 1
.line 2            ; ? (1 == 1) {
ldc 1
ldc 1
if_icmpeq L_1
iconst_0
goto L_2
L_1:
iconst_1
L_2:
ifeq L_3
.line 3            ;     a = 1;
ldc 1
istore 1
.line 4            ; } $ (1 == 2) {
goto L_7
L_3:
ldc 1
ldc 2
if_icmpeq L_4
iconst_0
goto L_5
L_4:
iconst_1
L_5:
ifeq L_6
.line 5            ;     a = 2;
ldc 2
istore 1
.line 6            ; } : {
goto L_7
L_6:
.line 7            ;     a = 3;
ldc 3
istore 1
.line 8            ; }
L_7:
```

#### Comando `while`

O comando `while`, assim como o `if` recebe uma expressão como condição, pois como a expressão por sua vez deixa o seu resultado no topo da *stack*, o while só compara se o topo da pilha é igual a zero para quebrar o fluxo para o final das instruções, se não o fluxo é quebrado para as instruções de dentro do `while`, e essas instruções tem no final um `goto` que faz o loop com o começo das comparações.

```
I a = 0;
W (a < 10) {
    a++;
}
```
```
.line 1            ; I a = 0;
ldc 0
istore 1
.line 2            ; W (a < 10) {
L_1:
iload 1
ldc 10
if_icmplt L_2
iconst_0
goto L_3
L_2:
iconst_1
L_3:
ifeq L_4
.line 3            ;     a++;
iload 1
iinc 1 1
pop
.line 4            ; }
goto L_1
L_4:
```

#### Comando `for`

O comando *for* é similar ao comando while, no entando a declaração é feita na mesma linha e são gerados dois jumps a mais pois as instruções de atribuição que seriam executadas dentro do *while* agora são executadas no cabeçalho do *for*.

Os autores cogitaram a implementação de versões auternativas de loop, no entando por questões externas estas não foram implementadas e ficaram como propostas de melhorias.

```
F (I i = 0; i<10; i++) {
    
}
```
```
ldc 0          ; i = 0
istore 0
L_0:
iload 0        ; i < 10
ldc 10
if_icmplt L_1
iconst_0
goto L_2
L_1:
iconst_1
L_2:
ifeq L_5
goto L_4
L_3:
iinc 0 1        ; i++
goto L_0        ; vai para condições
L_4:            ; corpo do for
goto L_3        ; vai para incrementos
L_5:
```


## 5. Reconhecimento de erros

Com o objetivo de tratar erros léxicos e semânticos, utilizou-se as diretivas abaixo, estas possibilitaram o rastreio das posições dos erros, a construção de mensagens de erro completamente customizadas, o controle dos dados passados entre o analisador léxico e sintático e a utilização da estrutura *user_context* definida pelos autores para o armazenamento da linha do erro.

```
%locations
%define api.pure full
%define parse.error custom
%define parse.lac full
%param { user_context* uctx }
```

Os erros podem ser divididos em três categorias:

### 5.1 Erros Léxicos

Um erro léxico é obtido quando um caractere não é reconhecido por nenhum dos regex. Nesse caso o erro é reconhecido pelo analizador léxico e é informado ao usuário.

### 5.2 Erros Sintáticos

Erros sintáticos são configurados por problemas na escrita da sintáxe da linguagem, ou seja, palavras escritas corretamente mas que não juntam em uma frase correta.

### 5.3 Erros Semânticos

O compilador tem suporte para identificação de alguns erros semânticos, que são caracterizados pela escrita correta e pela sintaxe correta, porém com problemas no seu contexto. Por exemplo: tentar usar uma variável que nunca foi definida, tentar definir uma variável que já foi definida, usar um operador exclusivo para inteiros com dois números ponto flutuante, tentar somar duas *strings*, etc.

Abaixo segue um exemplo do reconhecimento de erros na compilação de um arquivo, pode se notar a implementação do sistema *error recovery* pois o compilador identifica mais de um erro por arquivo, por fim vale resaltar que todas as mensagens são de autoria dos autores alem dos sistema de coloração do erro, impresão da linha e contagem de linhas e colunas.

![exemplos de erros](https://i.imgur.com/e4OEuPO.png)


## 6. Comentários Sobre a Linguagem

Esta seção tem como objetivo apresentar a visão dos autores sobre a própria linguagem e compilador e portanto servir como exposição do conhecimento adequirido por meio da implementação dos mesmos visando ajudar os que buscam a realização da própria implementação.

### Atribuição, Declaração, Atribuição-Declaração ...

Inicialmente, cogitou-se a ideia de inferencia de tipos, no entanto decidiu-se pelo contrario para simplificar a implementação e melhorar a performance.

Para dar suporte a declaração, atribuição, atribuição e declaração juntos, varias atribuição e declarações na mesma linha alem de dinguindir o operator "=" dos outros operadores de atribuição os autores implementaram diversar regras e logicas complexas envolvendo vetores dedicadas para isso.

Os autores estão muito felizes com este aspecto da linguagem e sentem que atingiram o melhor resultado posivel no quesito a declaração e atribuição de variaveis.

### Expressões

Foram tomadas três decisões que guiaram a implementação de expressões:

1. Não haveria diferenciação entre expressões e expressões booleanas, assim *verdadeiro* e *falso* seriam representados por *1* e *0* respectivamente.
2. Todas as operações seriam executadas na pilha, o compilador não sabe em nenhum momento o resultado das expressões.
3. Expressões deveriam começar com a pilha vazia e terminar com o resultado na pilha.

Estas decisões foram tomadas de modo a simplificar a utilização de expressões e expressões bolleanas, e de fato compriram com o objetivo simplificando consideravelmente a implementações de if, else-if, for e while detalhadas na seção 4.

No entanto estas decisões tambem resultaram em efeitos colaterias, alguns pequenos como ser impossivel apenas uma linha com uma expressão sem significado ou os operadores unarios de incremento serem utilizados em ambas as regras de atribuição e outros efeitos colaterias significativos como o grande impacto nos operadores booleanos.

As instruções de aritmética da JVM já recebem valores da pilha e colocam na pilha o resultado, no entando não acontece o mesmo para as expressões booleanas e assim houve a nescessidade de um formular o seguinte padrão:

```
1 == 0;
```

```
ldc 1          ; 1
ldc 0          ; 0
if_icmpeq L_0  ; comparator booleano, neste caso o ==
iconst_0       ; esta linha só executa se a condição for falsa adicionando o 0 na pilha
goto L_1
L_0:
iconst_1       ; só executa se a condição for verdadeira adicionando o 1 na pilha
L_1:
```

Desta forma as operações booleanas se adequam as três regras acima, embora provavelmente haja um custo computacional grande neste padrão alem da geração excessiva de linhas e labels, por fim, as operações de comparação permitiram aos autores a utilização dos operadores de *bitwise and* e *bitwise or* como *&&* e *||* respectivamente, note que os dois ultimos não tem comando corespondente no bytecode JVM.

Os três tipos utilizados não seguem nenhum padrao em relação aos operadores suportados, o tipo *string* possui apenas os operadores "==" e "!=", o tipo *float* possui os operadores aritimeticos mas nenhum operador *bitwise*, possui todos os operadores de comparação embora esta talvez tenha sido a parte mais feia da implementação pois não há suporte do bytecode JVM para comparação de float e assim houve a nescesside da conversão para inteiro e depois um comando especial de comparação, o tipo *inteiro* possui todos os operadores disponiveis pela bytecode JVM, incluindo bitshift, modulo e incremento unario, alem de uma implementação rustica do operator booleano de negação.

Alguns operatores que os autores desejavam implementar, como exponenciação, *bitwise not*, gcd e etc, não possuem suporte da jvm e portanto não foram implementados por questões externas e ficaram apenas como propostas de melhorias

Em conclusão, embora os autores tenham uma avaliação positiva do resultado, pois a implementação cumpriu o proposto e se mostrou superior em relação a trabalhos similares encontrados, ainda sentem que deve haver a possibilidade de uma melhor implementação.

### Funções

Inicialmente a proposta de funções era permitir a criação de funções em qualquer momento do codigo, no entanto devido as estruturas utilizadas os autores desidiram restringir a declaração de funções apenas para o cabeçalho de arquivo.

Foi utilizado o símbolo '@' no inicio da função para remover erros de *shift/reduce* e permitar a linguagem uma transição invisivel da declaração de funções para a função main.

### Arrays

Embora os autores reconheçam a importancia de arrays para uma linguagem, por questões externas e portanto ficaram como propostas de melhorias.

## 7. Comentários Sobre as Ferramentas

As ferramentas usadas se mostraram muito interessantes e robustas, principalmente algumas *features* que foram descobertas durante a execução e leitura de documentação. Portanto, essa seção se destina a fazer os comentários sobre essas ferramentas e quais as versões usadas.

### [Flex 2.6.4](https://en.wikipedia.org/wiki/Flex_(lexical_analyser_generator))

### Bison 3.7

* [Documentação](https://www.gnu.org/software/bison/manual/)

Este trabalho não seria possivel sem a ferramenta bison, os autores leram e consideram de extrema importancia a leitura de **toda** a documentação da ferramenta para qualquer um que deseje implementar um trabalho similar. Além disso recomenda-se o download manual, pois não está disponivel nos gerenciadores de pacote, da versão mais recente da feramenta para utilização da *feature* de *counterexamples*.

### Jasmin 2.4 e JVM

* [Jasmin](http://jasmin.sourceforge.net/instructions.html)
* [JVM](https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-6.html)

Vale resaltar a insatisfação para com a documentaçao precaria da feramenta *Jasmin* e a falta de exemplos online que utilizam bytecode JVM, portanto os autores recomendam a leitura da documentação JVM para criação de familiaridade com as instruções em bytecode JVM. 

## 8. Melhorias

Apesar dos autores considerarem que o trabalho foi concluído com exito é possível pontuar algumas melhorias visíveis que podem ser feitas. Melhorias em alguns sentidos: definição de mais operadores, suporte para estruturas de dados, bibliotecas, mais palavras reservadas e comandos, e implementação alguns outros sistemas importantes.

Para endereçar essas melhorias elas serão colocadas nas *issues* no repositório do github, para que outras pessoas possam ver e opinar. De mesma forma qualquer *issue*, com sugestões, report de problemas, ou dúvidas é bem vinda:

https://github.com/EMachad0/Verb-Compilator/issues

<!-- TODO list, a lista provavelmente vai ficar so nas issues -->
<!-- faltam dois operadoes -->
<!-- for com int só -->
<!-- bibliotecas padrao -->
<!-- ponderação sobre implementação de variaveis locais -->
<!-- sintax highlighting pra VSCode -->
<!-- arrays -->
<!-- linker -->
<!-- break, continue -->
<!-- else no for e while -->

## 9. Trabalhos de Referência e Inspirações

Trabalho desenvolvido para a disciplina de Compiladores na Universidade do Estado de Santa Catarina.
O desenvolvimento parcial do trabalho com a implementação de árvore sintatica pode ser encontrado na branch *only-sintax* 

* [Exemplo de Parser Bison](https://github.com/akimd/bison/blob/master/examples/c/bistromathic/parse.y)
    Parser que foi usado como base para a parte da gramática e da identificação de erros.

* [Exemplo de Compilador que usa Flex, Bison e Jasmin](https://github.com/romaad/compilersPhase3)
    Exemplo fornecido como base para o trabalho desenvolvido. Esse exemplo foi estudado vastamente para o entendimento do funcionameto de um compilador feito em flex e bison que compila para assembly JVM.
    
* [Exemplos de input e output em jasmin](https://saksagan.ceng.metu.edu.tr/courses/ceng444/link/jvm-cpm.html)
    Artigo que explica sobre input e output que também usa a ferramenta Jasmin. Foi usado como base para fazer as funções que lêem inteiros e ponto flutuante do terminal.

* [Estruturas de Dados em C](https://github.com/IgorFroehner/DataStructuresC)

    Uma etapa importante para o denvovimento foi a decisão das estruturas de dados usadas, e após essa decisão uma implementação genérica da estrutura seria necessária, no caso **hashmap** e **vector**. Como base, foram usadas as implementações que se encontram nesse repositório, e elas foram adaptadas para que se tornassem úteis ao contexto aplicado. 
