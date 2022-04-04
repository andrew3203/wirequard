from flask import Flask, request
import os
import subprocess
import dotenv
from pathlib import Path
import json


BASE_DIR = Path(__file__).resolve().parent.parent
dotenv_file = BASE_DIR / ".env"
if os.path.isfile(dotenv_file):
    dotenv.load_dotenv(dotenv_file)


app = Flask(__name__)


LIM_CLIENTS = os.getenv('LIM_CLIENTS', 50)


def check_user(request_data):
    if request_data:
        token = request_data.get('token', '')
        with open("tokens.json", "r") as f:
            keys = json.load(f)
            if keys.get(token, -1) >= 0:
                keys[token] += 1
                with open("tokens.json", "w") as fo:
                    json.dump(keys, fo)
                return True

    return False


@app.route("/", methods=['GET', 'POST'])
def servers_info():
    request_data = request.get_json()
    if check_user(request_data):
        with open("tokens.json", "r") as f:
            return json.load(f)
    else:
        return {'status': 'token error'}


@app.route("/add-client", methods=['POST'])
def add_client():
    request_data = request.get_json()
    if check_user(request_data):
        clients_count = subprocess.call(
            ["bash clientsAmount.sh"], stdin=subprocess.PIPE)
        if LIM_CLIENTS <= 1 + clients_count:
            return {'status': 'ok', 'result': f'lim clients ({LIM_CLIENTS}) exceeded'}
        config_file = subprocess.call(
            ["bash addClient.sh"], stdin=subprocess.PIPE)

        try:
            with open(config_file, 'r') as f:
                res = f.read()
                return {'status': 'ok', 'result': res}
        except Exception as e:
            return {'status': f'add client error: {e}'}
    else:
        return {'status': 'token error'}


@app.route("/revokeClient/<int:client_id>", methods=['POST'])
def revoke_client(client_id):
    request_data = request.get_json()
    if check_user(request_data):
        result = subprocess.call(
            ["bash revokeClient.sh", client_id], stdin=subprocess.PIPE)
        return {'status': 'ok', 'result': result}
    else:
        return {'status': 'token error'}


@app.route("/clientData/<int:client_id>", methods=['GET'])
def client_data(client_id):
    # TODO
    request_data = request.get_json()
    if check_user(request_data):
        file_info = subprocess.call(
            ["bash clientData.sh", client_id], stdin=subprocess.PIPE)
        with open(file_info, 'r') as f:
            res = f.read()
            return {'status': 'ok', 'result': res}
    else:
        return {'status': 'token error'}


@app.route("/clientsAmount/", methods=['GET'])
def clients_amount():
    # TODO
    request_data = request.get_json()
    if check_user(request_data):
        result = subprocess.call([" bash clientsAmount.sh"], stdin=subprocess.PIPE)
        return {'status': 'ok', 'result': result}
    else:
        return {'status': 'token error'}


@app.route("/activeClients/", methods=['GET'])
def active_clients():
    # TODO
    request_data = request.get_json()
    if check_user(request_data):
        file_info = subprocess.call(
            ["./activeClients.sh"], stdin=subprocess.PIPE)
        with open(file_info, 'r') as f:
            res = f.read()
            return {'status': 'ok', 'result': res}
    else:
        return {'status': 'token error'}


if __name__ == '__main__':
    # run app in debug mode on port 5000
    app.run(debug=True, port=5000)
