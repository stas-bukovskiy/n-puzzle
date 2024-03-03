# N-Puzzle game
Simple N-Puzzle game with 3x3, 4x4 or 5x5 board. The goal is to arrange the tiles in ascending order from left to right and top to bottom, with the empty tile in the bottom-right corner.
Application consts prolog server and python client for N-Puzzle game. Server has core login of game and client is the GUI for the game.
# Run the application
To run the application you need to have installed python 3.7 and prolog 7.6.4.
Open swi-prolog and consult server.pl file. 
Then run the server with command:
```
start_server(8080).
```
And then run the client with command:
```
python3 main.py
```
Hooraay! You can play the game now!