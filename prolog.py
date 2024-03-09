from pyswip import Prolog
import requests


def to_array_string(board):
    res = "["
    for i in range(0, len(board)):
        if i != 0:
            res += ","
        res += str(board[i])
    res += "]"
    return res


class PrologService:

    def __init__(self):
        self.base_url = "http://localhost:8079"

    def generate_board(self, difficulty, size):
        response = requests.get(f"{self.base_url}/generate-board", params={'difficulty': difficulty, 'size': size})
        if response.status_code == 200:
            return response.json()['board']
        else:
            return None

    def move_empty_tile(self, board, size, direction):
        response = requests.get(f"{self.base_url}/move-empty-tile", params={'board': to_array_string(board), 'size': size, 'direction': direction})
        if response.status_code == 200:
            return response.json()['board']
        else:
            return None

    def is_solved(self, board):
        response = requests.get(f"{self.base_url}/is-solved", params={'board': to_array_string(board)})
        if response.status_code == 200:
            return response.json()['solved'] == "true"
        else:
            return False

    def solve(self, board):
        response = requests.get(f"{self.base_url}/solve", params={'board': to_array_string(board)})
        if response.status_code == 200:
            return response.json()['moves']
        else:
            return None
