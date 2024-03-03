:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).

:- consult("n-puzzle.pl").

% Define the handler for the /generate-board endpoint
:- http_handler('/generate-board', handle_generate_board, []).
:- http_handler('/move-empty-tile', handle_move_empty_tile, []).
:- http_handler('/is-solved', handle_is_solved, []).
:- http_handler('/solve', handle_solve, []).


% Start the server on port 8080
start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Handler for the /generate-board endpoint
handle_generate_board(Request) :-
    % Parse query parameters
    http_parameters(Request, [
        size(Size, [integer]),
        difficulty(Difficulty, [atom])
    ]),
    % Generate the board
    generate_board(Difficulty, Size, Board),
    % Respond with the generated board as JSON
    reply_json(json([board=Board])).

% Handler for the /move-empty-tile endpoint
handle_move_empty_tile(Request) :-
    http_parameters(Request, [
        board(BoardString, [atom]),
        size(Size, [integer]),
        direction(Direction, [atom])
    ]),
    term_string(Board, BoardString),
    move_empty_tile(Board, Size, Direction, NewBoard),
    reply_json(json([board=NewBoard])).

% Handler for the /is-solved endpoint
handle_is_solved(Request) :-
    http_parameters(Request, [
        board(BoardString, [atom])
    ]),
    term_string(Board, BoardString),
    (   is_solved(Board)
    ->  reply_json(json([solved=true]))
    ;   reply_json(json([solved=false]))
    ).

% Handler for the /solve endpoint
handle_solve(Request) :-
    http_parameters(Request, [
        board(BoardString, [atom])
    ]),
    term_string(Board, BoardString),
    solve(Board, Moves),
    reply_json(json([moves=Moves])).

% Example usage:
% Start the server with start_server(8080).
% Access http://localhost:8080/generate-board?size=4&difficulty=2 in your browser or via a tool like curl.
