equals(A,A).

notEquals(A,B):- equals(A, B)
    , !
    , fail.
notEquals(A,B).

head([H|T], H).

concat([],L,L).
concat([H|T],L2,[H|L3])  :-  concat(T,L2,L3).

command(add, [double, double], double).
command(add, [int, int], int).
command(subtract, [double, double], double).
command(subtract, [int, int], int).
command(divide, [double, double], double).
command(divide, [int, int], int).
command(multiply, [double, double], double).
command(multiply, [int, int], int).
command(terminal, [], int).
command(terminal, [], double).
command(terminal, [], float).
command(terminal, [], boolean).
command(variable, [], int).
command(variable, [], double).
command(variable, [], boolean).
command(variable, [], float).
command(constant, [], int).
command(constant, [], double).
command(constant, [], boolean).
command(constant, [], float).
command(ann, [double, float], double).
command(ann, [double, double, float, float], double).

arity(COMMAND, OUTPUTTYPE, R):- command(COMMAND, X, OUTPUTTYPE)
    , length(X, R).

getAllFunctions(OUTPUTTYPE, L):- findall(command(X, Y, OUTPUTTYPE), (command(X, Y, OUTPUTTYPE), length(Y, R), R > 0), L).

terminals([terminal, variable, constant]).

getRandomTerminal(OUTPUTTYPE, R):- findall(command(X, Y, OUTPUTTYPE), (command(X, Y, OUTPUTTYPE), terminals(Z), member(X,Z), length(Y, A), A = 0), T)
    , length(T, L)
    , TEMP is L + 1
    , random(1, TEMP, AT)
    , nth(AT, T, R).

getRandomFunction(OUTPUTTYPE, F):- getAllFunctions(OUTPUTTYPE, L)
    , length(L, LEN)
    , TEMP is LEN + 1
    , random(1, TEMP, AT)
    , nth(AT, L, F).

notTerminal(COMMAND):- (COMMAND = command(terminal, X, Y)
    ; COMMAND = command(constant, X, Y)
    ; COMMAND = command(variable, X, Y))
    , !
    , fail.
notTerminal(COMMAND).

mutants(add, [subtract, multiply, divide]).
mutants(subtract, [add, multiply, divide]).
mutants(multiply, [add, subtract, divide]).
mutants(divide, [add, subtract, multiply]).

pickRandomProgram(R, OUTPUTTYPE, F):- R >= 0.01
    , getRandomFunction(OUTPUTTYPE, F).
pickRandomProgram(R, OUTPUTTYPE, F):- R < 0.01
    , getRandomTerminal(OUTPUTTYPE, F).

randomNode(R, SIZE, CURRENT, OUTPUTTYPE, NODE):- getAllFunctions(OUTPUTTYPE, F)
    , length(F, 0)
    , getRandomTerminal(OUTPUTTYPE, NODE)
    , !.
randomNode(R, SIZE, CURRENT, OUTPUTTYPE, NODE):- CURRENT > SIZE
    , getRandomTerminal(OUTPUTTYPE, NODE)
    , !.
randomNode(R, SIZE, CURRENT, OUTPUTTYPE, NODE):- TEMP is SIZE - CURRENT
    , N is 1.0 - (TEMP / SIZE)
    , R > N
    , getRandomFunction(OUTPUTTYPE, NODE)
    , !.
randomNode(R, SIZE, CURRENT, OUTPUTTYPE, NODE):- TEMP is SIZE - CURRENT
    , N is 1.0 - (TEMP / SIZE)
    , R =< N
    , getRandomTerminal(OUTPUTTYPE, NODE)
    , !.

randomTree(0, SIZE, CHILDCOUNT, [], [], [], []).
randomTree(-1, SIZE, CHILDCOUNT, [H], [H|T], [A|X], [C|D]):- randomize
    , random(R)
    , pickRandomProgram(R, H, E)
    , E = command(C, TYPES, H)
    , length(TYPES, A)
    , TEMP is A+CHILDCOUNT+1
    , randomTree(0, SIZE, TEMP, TYPES, T, X, D)
    , !.
randomTree(0, SIZE, CHILDCOUNT, [H|T], [H|M], [X|Z], [C|D]):- randomize
    , random(R)
    , randomNode(R, SIZE, CHILDCOUNT, H, N)
    , N = command(C, B, H)
    , length(B, X)
    , concat(T, B, NEWB)
    , SUM is CHILDCOUNT + X + 1
    , randomTree(0, SIZE, SUM, NEWB, M, Z, D)
    , !.
