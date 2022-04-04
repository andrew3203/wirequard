import requests


url = 'http://164.92.132.100:5000'
url_loc = 'http://127.0.0.1:5000/'

data = {
    'token': 'a86d141798be009a2d0981e1dd76b32962a09700f1637c417c2251c96b2939d1'
}
resp = requests.post(url=url_loc, json=data)
print(resp, resp.json())