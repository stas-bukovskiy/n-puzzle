% 1. if the board is solvable

% count_inversions(+List, -Count)
% Count the number of inversions in the list
count_inversions([], 0).
count_inversions([H|T], Count) :-
    count_inversions(T, CountRest),
    count_less_than(H, T, CountLess),
    Count is CountRest + CountLess.

% count_less_than(+List, +Element, -Count)
% Count the number of elements less than X in the list
count_less_than(_, [], 0).
count_less_than(X, [H|T], Count) :-
    count_less_than(X, T, CountRest),
    (X > H, H \= 0 -> Count is CountRest + 1; Count = CountRest).

% blank_row(+Board, +N, -Row)
% Find the row number of the blank space (0), counting from the bottom
blank_row(Board, N, Row) :-
    length(Board, Len),
    nth0(Index, Board, 0),
    Row is ((Len - Index) // N) + 1.

% is_solvable(+Board)
% Check if the 15-puzzle board is solvable
is_solvable(Board) :-
    length(Board, Len),
    N is round(sqrt(Len)),
    count_inversions(Board, InvCount),
    blank_row(Board, N, BlankRow),
    (
        (N mod 2 =:= 1, InvCount mod 2 =:= 0);
        (N mod 2 =:= 0, BlankRow mod 2 =:= 0, InvCount mod 2 =:= 1);
        (N mod 2 =:= 0, BlankRow mod 2 =:= 1, InvCount mod 2 =:= 0)
    ).


% Examples
% is_solvable([1, 3, 2, 4, 5, 6, 7, 0]) % false
% is_solvable([1, 3, 2, 5, 4, 6, 7, 8, 0]) % true


% Ganarating new boards

% generate_board(+Difficulty, +Size, -Board)
% Generate a board with a given difficulty and size
generate_board(Difficulty, Size, Board) :-
    generate_initital_board(Size, InitialBoard),
    difficulty_moves(Difficulty, Moves),
    ( Moves =:= 0
    ->  (
          repeat,
            random_permutation(InitialBoard, Board),
        	is_solvable(Board)
        );
    	(
          make_random_moves(InitialBoard, Size, Moves, Board)
   		)
    ).

% generate_initital_board(+Size, -InitialBoard)
% Generate a solved board with the given size
generate_initital_board(Size, InitialBoard) :-
	NumTiles is Size * Size,
    MaxTile is NumTiles - 1,
    findall(Num, between(1, MaxTile, Num), Tiles),
    append(Tiles, [0], InitialBoard).


% Define the number of moves for each difficulty level
% difficulty_moves(+Difficulty, -NumOfMoves)
difficulty_moves(easy, 30).
difficulty_moves(medium, 60).
difficulty_moves(hard, 120).
difficulty_moves(random, 0).

% make_random_moves(+Board, +Size, +Moves, -FinalBoard)
% Make a specified number of random valid moves
make_random_moves(Board, _, 0, Board).
make_random_moves(Board, Size, Moves, FinalBoard) :-
    Moves > 0,
    NextMoves is Moves - 1,
    make_random_move(Board, Size, NewBoard),
    make_random_moves(NewBoard, Size, NextMoves, FinalBoard).

% make_random_move(+Board, +Size, -NewBoard) :-
% Make a random valid move on the board
make_random_move(Board, Size, NewBoard) :-
    nth0(BlankIndex, Board, 0),
    findall(Direction, valid_move(Size, BlankIndex, Direction), Directions),
    random_member(SelectedDirection, Directions),
    move_empty_tile(Board, Size, SelectedDirection, NewBoard).


% Examples
% generate_board(hard, 5, Board)
% generate_board(random, 3, Board)


% Moving an empty tile

% valid_move(+Size, +BlankIndex, +Direction)
% Validate move of the empty tile
valid_move(Size, BlankIndex, left) :-
    BlankIndex mod Size =\= 0.
valid_move(Size, BlankIndex, right) :-
    (BlankIndex + 1) mod Size =\= 0.
valid_move(Size, BlankIndex, up) :-
    BlankIndex >= Size.
valid_move(Size, BlankIndex, down) :-
    BlankIndex < Size * (Size - 1).

% move_empty_tile(+Board, +Size, +Direction, -NewBoard)
% Move the empty tile to the given direction 
move_empty_tile(Board, Size, Direction, NewBoard) :-
    nth0(BlankIndex, Board, 0),
    valid_move(Size, BlankIndex, Direction),
    move_index(BlankIndex, Size, Direction, NewIndex),
    swap_elements(Board, BlankIndex, NewIndex, NewBoard).

% move_index(+BlankIndex, +Size, +Direction, -NewIndex)
% Return index of an empty tile after it was moved to the given direction
move_index(BlankIndex, _, left, NewIndex) :-
    NewIndex is BlankIndex - 1.
move_index(BlankIndex, _, right, NewIndex) :-
    NewIndex is BlankIndex + 1.
move_index(BlankIndex, Size, up, NewIndex) :-
    NewIndex is BlankIndex - Size.
move_index(BlankIndex, Size, down, NewIndex) :-
    NewIndex is BlankIndex + Size.

% swap_elements(+List, +Index1, +Index2, -NewList)
% Swap the elements in list by its indexes
swap_elements(List, Index1, Index2, NewList) :-
    nth0(Index1, List, Elem1),
    nth0(Index2, List, Elem2),
    replace_nth(Index1, Elem2, List, TempList),
    replace_nth(Index2, Elem1, TempList, NewList).

% replace_nth(+Index, +Element, +List, -NewList)
% Replece nth element in list
replace_nth(0, Elem, [_|T], [Elem|T]).
replace_nth(N, Elem, [H|T], [H|R]) :-
    N > 0,
    N1 is N - 1,
    replace_nth(N1, Elem, T, R).


% Examples
% move_empty_tile([1, 2, 3, 4, 0, 5, 6, 7, 8], 3, up, Board)
% move_empty_tile([0, 2, 3, 4, 1, 5, 6, 7, 8], 3, up, Board) % false


% is_solved(+Board)
% Check if the given board is solved
is_solved(Board) :-
    length(Board, Len),
    NumTiles is Len - 1,
    findall(Num, between(1, NumTiles, Num), SolvedTiles),
    append(SolvedTiles, [0], SolvedBoard),
    Board = SolvedBoard.


% Examples
% is_solved([1, 2, 3, 4, 5, 6, 7, 8, 0]) % true


% Couniting manhattan distance

% manhattan(+Current, +Gaol, +Size, -Res)
% Is the result of manhattan heuristic for Board
manhattan(Current, Gaol, Size, Res) :-
    Num is Size * Size - 1,
    manhattan_helper(Current, Gaol, Size, Num, Res).

% manhattan_helper(+Current, +Final, +Size, +Num, -Sum)
manhattan_helper(_, _, _, 0, 0).
manhattan_helper(Current, Final, Size, Num, Sum) :-
    nth0(Index, Current, Num),
    nth0(FinalIndex, Final, Num),
    index(Index, Size, X1, Y1),
    index(FinalIndex, Size, X2, Y2),
    Num1 is Num - 1,
    manhattan_helper(Current, Final, Size, Num1, Sum1),
    Sum is abs(X1 - X2) + abs(Y1 - Y2) + Sum1.

% index(+I, +Size, ?X, ?Y)
% Convert I-th index to (X, Y) index in NxN square
index(I, Size, X, Y) :- divmod(I, Size, X, Y).

% divmod(+Dividend, +Divisor, -Quotient, -Remainder)
% This predicate is a shorthand for computing both the Quotient and Remainder of two integers in a single operation. 
divmod(Dividend, Divisor, Quotient, Remainder) :-
        Quotient  is Dividend div Divisor,
        Remainder is Dividend mod Divisor.


% Examples
% ?- manhattan([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 0, 15], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0], 4, Distance).
% Distance = 1.
% ?- manhattan([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0], 4, Distance).
% Distance = 0.
% ?- manhattan([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 0, 13, 14, 15], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0], 4, Distance).
% Distance = 3.


% solve_astar(+Current,+Size, +Final, +Limit, -Moves)
% solver npuzzle problem by using A* and Manhatten distance heuristics
solve_astar(Current,Size, Final, Limit, Moves) :-
    solve_astar(Current, Size, Final, [Current], [], Limit, Moves).

solve_astar(Final, _, Final, _, MovesBackwards, Limit, Moves) :-
    Limit >= 0,
    reverse(MovesBackwards, Moves).

solve_astar(Current, Size, Final, StateAcc, MovesBackwards, Limit, Moves) :-
    manhattan(Current, Final, Size, H),
    Limit >= H,
    L1 is Limit - 1,
    move_empty_tile(Current, Size, Direction, NewState),
    \+member(NewState, StateAcc),
    solve_astar(NewState, Size, Final, [NewState|StateAcc], [Direction|MovesBackwards], L1, Moves).

% solve_idastar(+Current, +Final, -Moves)
% IDA* search from Current to Final
% 80 is the max number of moves to solve a solvable Puzzle
solve_idastar(Current, Size, Final, Moves):-
    manhattan(Current, Final, Size, H),
    between(H, 80, Limit),
    solve_astar(Current,Size, Final, Limit, Moves).

% solve(+Board, -Moves)
% IDA* search to the final state, check solvability first
solve(Board, Moves) :-
    is_solvable(Board),
    length(Board, Len),
    Size is round(sqrt(Len)),
	generate_initital_board(Size, GoalBoard),
    solve_idastar(Board, Size, GoalBoard, Moves).

% Examples
% solve([1, 2, 3, 4, 8, 5, 7, 6, 0], M)


