import concurrent
import time
import tkinter as tk
from tkinter import ttk
from prolog import PrologService

# Colors
white = "#fffff0"
gray = "#FFF8CA"
green = "#81b29a"
dark_green = "#6AA789"
black = "#000814"
yellow = "#f2cc8f"
dark_yellow = "#FFCA76"
light_purple = "#52567B"
purple = "#3d405b"
orange = "#e07a5f"
dark_orange = "#CC6143"

start_time = time.time()
elapsed_time = 0
moves = 0
mode = "User"
is_solving = False


def create_custom_theme():
    style = ttk.Style()
    style.theme_create('CustomTheme', parent='clam', settings={
        'TButton': {
            'configure': {'padding': 5, 'background': purple, 'foreground': white},
            'map': {'background': [('active', light_purple), ('disabled', 'grey')]},
        },
        'TLabel': {
            'configure': {'background': 'lightblue', 'foreground': black}
        },
        'TRadiobutton': {
            'configure': {'background': white, 'foreground': black, 'indicatorbackground': white},
            'map': {'background': [('active', white), ('selected', white), ('disabled', white)]}
        },
        'TFrame': {
            'configure': {'background': white}
        }
    })
    style.theme_use('CustomTheme')


def update_timer():
    if time_label is None:
        return

    global elapsed_time, start_time
    elapsed_time = int(time.time() - start_time)
    minutes, seconds = divmod(elapsed_time, 60)
    time_label.config(text=f"{minutes:02d}:{seconds:02d}")
    root.after(1000, update_timer)


def get_tile_color(value, index):
    if value == 0 and index == size ** 2 - 1:
        return green, dark_green
    elif index == value - 1:
        return green, dark_green
    else:
        return orange, dark_orange


def create_grid(frame, board, size):
    global buttons, mode
    buttons = []
    for i in range(size):
        row_buttons = []
        for j in range(size):
            index = i * size + j
            number = board[index]
            bg_color, color = get_tile_color(number, index)

            callback = None
            if mode == "User":
                callback = lambda r=i, c=j: button_click(r, c)

            if number == 0:
                btn = tk.Button(frame, text="", width=5, height=2, command=callback, background=bg_color,
                                activebackground=color)
            else:
                btn = tk.Button(frame, text=str(number), width=5, height=2, command=callback, background=bg_color,
                                activebackground=color)
            btn.grid(row=i, column=j, padx=5, pady=5)
            row_buttons.append(btn)
        buttons.append(row_buttons)
    return buttons


def start_game():
    global size, board, mode, is_solving
    size = int(size_var.get())
    difficulty = difficulty_var.get()
    mode = mode_var.get()

    # Generate the board
    board = prolog_service.generate_board(difficulty, size)
    print(f"d: {difficulty}, size: {size}, board: {board}")

    # You can add your game logic here
    show_game_page(board, mode)
    if mode == "Computer":
        is_solving = True
        solve()
    else:
        is_solving = False


def show_start_window():
    global start_frame, time_label
    time_label = None

    start_frame = tk.Frame(root)
    start_frame.configure(bg=white)
    start_frame.place(relx=0.5, rely=0.5, anchor="center")

    # Create a frame for the title and subtitle
    title_frame = tk.Frame(start_frame)
    title_frame.configure(bg=white)
    title_frame.pack(pady=40)

    # Add title and subtitle
    title = tk.Label(title_frame, text="N-Puzzle Game", font=("Arial", 24))
    title.pack()
    title.configure(bg=white)
    subtitle = tk.Label(title_frame, text="by Stanislav Bukovskyi", font=("Arial", 16))
    subtitle.configure(bg=white)
    subtitle.pack()

    # Create a frame for the options
    options_frame = tk.Frame(start_frame)
    options_frame.configure(bg=white)
    options_frame.pack(pady=20)

    # Add radio buttons for size selection
    size_label = tk.Label(options_frame, text="Size:", font=("Arial", 14))
    size_label.configure(bg=white)
    size_label.grid(row=0, column=0, padx=10, pady=10, sticky="w")
    sizes = {3: "3x3", 4: "4x4", 5: "5x5"}
    i = 0
    for key, value in sizes.items():
        rb = ttk.Radiobutton(options_frame, text=value, value=key, variable=size_var)
        rb.grid(row=0, column=i + 1, padx=10, sticky="w")
        i += 1

    # Add radio buttons for difficulty selection
    difficulty_label = tk.Label(options_frame, text="Difficulty:", font=("Arial", 14))
    difficulty_label.configure(bg=white)
    difficulty_label.grid(row=1, column=0, padx=10, pady=10, sticky="w")
    for i, difficulty in enumerate(["easy", "medium", "hard", "random"]):
        rb = ttk.Radiobutton(options_frame, text=difficulty, value=difficulty, variable=difficulty_var)
        rb.grid(row=1, column=i + 1, padx=10, sticky="w")

    # Add radio buttons for mode
    mode_label = tk.Label(options_frame, text="Mode:", font=("Arial", 14))
    mode_label.configure(bg=white)
    mode_label.grid(row=2, column=0, padx=10, pady=10, sticky="w")
    for i, mode in enumerate(["Computer", "User"]):
        rb = ttk.Radiobutton(options_frame, text=mode, value=mode, variable=mode_var)
        rb.grid(row=2, column=i + 1, padx=10, sticky="w")

    # Create a start button
    start_button = ttk.Button(start_frame, text="Start", command=start_game)
    start_button.pack(padx=20, pady=10)


def show_game_page(board, mode):
    global time_label, elapsed_time, moves, start_time, moves_label, game_frame, back_button, solve_button, game_board_label
    start_frame.destroy()  # Hide the start window

    game_frame = tk.Frame(root)
    game_frame.configure(bg=white)
    game_frame.place(relx=0.5, rely=0.5, anchor="center")

    game_board_label = tk.Label(game_frame, text="Let's play!", font=("Arial", 20), bg=white)
    game_board_label.pack(pady=20)

    labels_frame = tk.Frame(game_frame, bg=white)
    time_label = tk.Label(labels_frame, text="00:00", font=("Arial", 14), bg=white)
    time_label.pack(pady=5, padx=30, side="left")
    moves_label = tk.Label(labels_frame, text="Moves: 0", font=("Arial", 14), bg=white)
    moves_label.pack(pady=5, padx=30, side="right")

    labels_frame.pack()

    board_grid_frame = tk.Frame(game_frame, bg=white)
    board_grid_frame.pack(pady=10)
    create_grid(board_grid_frame, board, int(size_var.get()))

    solve_button = None
    if mode == "User":
        button_frame = tk.Frame(game_frame, bg=white)
        solve_button = ttk.Button(button_frame, text="Solve", command=solve)
        solve_button.pack(pady=10, padx=10, side="left")

        back_button = ttk.Button(button_frame, text="Back", command=lambda: [game_frame.destroy(), show_start_window()])
        back_button.pack(pady=10, padx=10, side="right")

        button_frame.pack(pady=10)
    else:
        back_button = ttk.Button(game_frame, text="Back", command=lambda: [game_frame.destroy(), show_start_window()])
        back_button.pack(pady=10, padx=10)

    elapsed_time = 0
    moves = 0
    start_time = time.time()
    update_timer()


def solve():
    global is_solving
    is_solving = True

    directions = prolog_service.solve(board)
    for i in range(1, len(directions) + 1):
        root.after(1000 * i, lambda m=directions[i - 1]: move_tile(m) if time_label is not None else None)


def update_solving_board(new_board):
    global board
    board = new_board
    update_board_gui()


def button_click(row, column):
    global moves, is_solving
    if is_solving:
        return

    empty_row, empty_column = find_empty_tile()
    direction = determine_direction(empty_row, empty_column, row, column)
    move_tile(direction)


def move_tile(direction):
    global board, size
    if direction:
        update_moves()
        new_board = prolog_service.move_empty_tile(board, size, direction)
        if new_board:
            board = new_board
            print(f"Moved {direction}: {board}")
            update_board_gui()

    if prolog_service.is_solved(board):
        show_win_window()


def show_win_window():
    global time_label
    time_label = None
    game_board_label.config(text="You won!")
    back_button.config(state=tk.NORMAL)


def find_empty_tile():
    for i in range(size):
        for j in range(size):
            if board[i * size + j] == 0:
                return i, j
    return None, None


def determine_direction(empty_row, empty_column, row, column):
    if row == empty_row and column == empty_column + 1:
        return 'right'
    elif row == empty_row and column == empty_column - 1:
        return 'left'
    elif row == empty_row + 1 and column == empty_column:
        return 'down'
    elif row == empty_row - 1 and column == empty_column:
        return 'up'
    return None


def update_board_gui():
    state = tk.DISABLED if is_solving else tk.NORMAL
    back_button.config(state=state)
    if solve_button is not None:
        solve_button.config(state=state)

    for i in range(size):
        for j in range(size):
            index = i * size + j
            number = board[index]
            bg_color, color = get_tile_color(number, index)

            buttons[i][j].config(text=str(number) if number != 0 else "", background=bg_color,
                                 activebackground=color)


def update_moves():
    global moves_label, moves
    moves += 1
    moves_label.config(text=f"Moves: {moves}")


# Init the prolog
prolog_service = PrologService()

# Create the main window
root = tk.Tk()
root.geometry("600x600")
root.title("N-Puzzle Game")
root.configure(bg=white)
create_custom_theme()

# Variables to hold the selected options
size_var = tk.StringVar(value="3")
difficulty_var = tk.StringVar(value="easy")
mode_var = tk.StringVar(value="Computer")

show_start_window()

# Run the application
root.mainloop()
