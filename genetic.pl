equals(A,A).

notEquals(A,B):- equals(A, B)
    , !
    , fail.
notEquals(A,B).

head([H|T], H).

concat([],L,L).
concat([H|T],L2,[H|L3])  :-  concat(T,L2,L3).

command(1, add, [double, double], double).
command(1, add, [int, int], int).
command(1, subtract, [double, double], double).
command(1, subtract, [int, int], int).
command(1, divide, [double, double], double).
command(1, divide, [int, int], int).
command(1, multiply, [double, double], double).
command(1, multiply, [int, int], int).
command(1, terminal, [], int).
command(1, terminal, [], double).
command(1, terminal, [], float).
command(1, terminal, [], boolean).
command(1, variable, [], int).
command(1, variable, [], double).
command(1, variable, [], boolean).
command(1, variable, [], float).
command(1, constant, [], int).
command(1, constant, [], double).
command(1, constant, [], boolean).
command(1,  constant, [], float).
command(1, ann, [double, double, float, float], double).
command(1, ann, [double, double, double, double, float, float, float, float], double).
command(2, add, [double, double], double).
command(2, add, [int, int], int).
command(2, subtract, [double, double], double).
command(2, subtract, [int, int], int).
command(2, divide, [double, double], double).
command(2, divide, [int, int], int).
command(2, multiply, [double, double], double).
command(2, multiply, [int, int], int).
command(2, terminal, [], int).
command(2, terminal, [], double).
command(2, terminal, [], float).
command(2, terminal, [], boolean).
command(2, variable, [], int).
command(2, variable, [], double).
command(2, variable, [], boolean).
command(2, variable, [], float).
command(2, constant, [], int).
command(2, constant, [], double).
command(2, constant, [], boolean).
command(2,  constant, [], float).
command(2, ann, [double, double, float, float], double).
command(2, ann, [double, double, double, double, float, float, float, float], double).

getAllFunctions(INDEX, OUTPUTTYPE, L):- findall(command(INDEX, X, Y, OUTPUTTYPE), (command(INDEX, X, Y, OUTPUTTYPE), length(Y, R), R > 0), L).

terminals([terminal, variable, constant]).

getRandomTerminal(INDEX, OUTPUTTYPE, R):- findall(command(INDEX, X, Y, OUTPUTTYPE), (command(INDEX, X, Y, OUTPUTTYPE), terminals(Z), member(X,Z), length(Y, A), A = 0), T)
    , length(T, L)
    , TEMP is L + 1
    , random(1, TEMP, AT)
    , nth(AT, T, R).

getRandomFunction(INDEX, OUTPUTTYPE, F):- getAllFunctions(INDEX, OUTPUTTYPE, L)
    , length(L, LEN)
    , TEMP is LEN + 1
    , random(1, TEMP, AT)
    , nth(AT, L, F).

notTerminal(COMMAND):- terminals(L)
    , member(COMMAND, L)
    , !
    , fail.
notTerminal(COMMAND).

mutants(1, add, [subtract, multiply, divide]).
mutants(1, subtract, [add, multiply, divide]).
mutants(1, multiply, [add, subtract, divide]).
mutants(1, divide, [add, subtract, multiply]).
mutants(2, add, [subtract, multiply, divide]).
mutants(2, subtract, [add, multiply, divide]).
mutants(2, multiply, [add, subtract, divide]).
mutants(2, divide, [add, subtract, multiply]).

pickRandomProgram(INDEX, R, OUTPUTTYPE, F):- R >= 0.01
    , getRandomFunction(INDEX, OUTPUTTYPE, F).
pickRandomProgram(INDEX, R, OUTPUTTYPE, F):- R < 0.01
    , getRandomTerminal(INDEX, OUTPUTTYPE, F).

randomNode(INDEX, R, SIZE, CURRENT, OUTPUTTYPE, NODE):- getAllFunctions(INDEX, OUTPUTTYPE, F)
    , length(F, 0)
    , getRandomTerminal(INDEX, OUTPUTTYPE, NODE)
    , !.
randomNode(INDEX, R, SIZE, CURRENT, OUTPUTTYPE, NODE):- CURRENT > SIZE
    , getRandomTerminal(INDEX, OUTPUTTYPE, NODE)
    , !.
randomNode(INDEX, R, SIZE, CURRENT, OUTPUTTYPE, NODE):- TEMP is SIZE - CURRENT
    , N is 1.0 - (TEMP / SIZE)
    , R > N
    , getRandomFunction(INDEX, OUTPUTTYPE, NODE)
    , !.
randomNode(INDEX, R, SIZE, CURRENT, OUTPUTTYPE, NODE):- TEMP is SIZE - CURRENT
    , N is 1.0 - (TEMP / SIZE)
    , R =< N
    , getRandomTerminal(INDEX, OUTPUTTYPE, NODE)
    , !.

randomTree(0, INDEX, SIZE, CHILDCOUNT, [], [], [], []).
randomTree(-1, INDEX, SIZE, CHILDCOUNT, [H], [H|T], [A|X], [C|D]):- randomize
    , random(R)
    , pickRandomProgram(INDEX, R, H, E)
    , E = command(INDEX, C, TYPES, H)
    , length(TYPES, A)
    , TEMP is A+CHILDCOUNT+1
    , randomTree(0, INDEX, SIZE, TEMP, TYPES, T, X, D)
    , !.
randomTree(0, INDEX, SIZE, CHILDCOUNT, [H|T], [H|M], [X|Z], [C|D]):- randomize
    , random(R)
    , randomNode(INDEX, R, SIZE, CHILDCOUNT + 1, H, N)
    , N = command(INDEX, C, B, H)
    , length(B, X)
    , concat(T, B, NEWB)
    , SUM is CHILDCOUNT + X + 1
    , randomTree(0, INDEX, SIZE, SUM, NEWB, M, Z, D)
    , !.

randomTrees(INDEX, [], [], []):- !.
randomTrees(INDEX, [SIZE|A], [OUTPUTTYPE|B], [H|T]):- randomTree(-1, INDEX, SIZE, 0, [OUTPUTTYPE], TYPES, CHILDCOUNT, COMMAND)
    , H = gene(TYPES, CHILDCOUNT, COMMAND)
    , TEMP is INDEX + 1
    , randomTrees(TEMP, A, B, T).

/*
* EXAMPLES
* randomPopulation(10, [double], [13], R).
* randomPopulation(7, [double, double], [15, 30], R).
*/


randomPopulation(0, OUTPUTTYPES, SIZES, []):- !.
randomPopulation(AMOUNT, OUTPUTTYPES, SIZES, [H|T]):- randomTrees(1, SIZES, OUTPUTTYPES, R)
    , H = candidate(R)
    , TEMP is AMOUNT - 1
    , randomPopulation(TEMP, OUTPUTTYPES, SIZES, T).
