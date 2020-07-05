from bs4 import BeautifulSoup
import requests
from textblob import TextBlob
import random
import math
import re
import flask
from flask import request, jsonify
import csv, json

app = flask.Flask(__name__)
app.config["DEBUG"] = True

cities = []
with open("worldcities.csv") as csvfile:
    reader = csv.reader(csvfile, quoting=csv.QUOTE_NONNUMERIC) # change contents to floats
    for i, row in enumerate(reader): # each row is a list
        if (i > 0) & (i <= 1000) & (row[9] != ''):
            try:
                num = int(row[9])
            except ValueError:
                num = int(float(row[9]))
            if (num > 500000):
                city = {"name": row[1], "lng": float(row[3]), "lat": float(row[2]), "pop": num}
            cities.append(city)


def followedBy(sentence, word, char):
    index = sentence.find(word) + len(word)
    return (sentence[index] == char) | ((sentence[index] == " ") & (index + 1 < len(sentence)) & (sentence[index + 1] == char))

def removeExtra(sentence):
    sentence = list(sentence)
    inside = False
    newSentence = []
    for item in sentence:
        #print(item)
        #print(inside)
        if (item == "[") | (item == "("):
            inside = True
        if (not inside):
            newSentence.append(item)
        if (item == "]") | (item == ")"):
            inside = False

    return "".join(newSentence)


def candidates(tags, name, sentence):
    tags.append(("a", "a"))
    list = []
    i = 0
    while (i < len(tags)):
        #print(list)
        item = tags[i]
        str = ""
        while (i < len(tags)) & (item[1] == "CD"):
            str += item[0] + " "
            i += 1
            item = tags[i]
        if (str != ""):
            list.append(str.strip())
        str = ""
        while (i < len(tags)) & ((item[1] == "NNP") & (not followedBy(sentence, item[1], ","))):
            str += item[0] + " "
            i += 1
            item = tags[i]
        if (str != ""):
            list.append(str.strip())
        i += 1
    if name in list:
        list.remove(name)
    return list

def randomNumber(low, high):
    range = high - low
    return int(math.floor(range * random.random())) + low


@app.route('/questions', methods=['GET'])
def question():
    if ('name' in request.args) & ('city' in request.args):
        city = request.args['city']
        name = request.args['name']
    else:
        return "Error: name not provided in request."

    URL = 'https://en.wikipedia.org/wiki/' + name.replace(" ", "_")
    page = requests.get(URL)
    soup = BeautifulSoup(page.content, 'html.parser')
    content = soup.find_all('div', class_='mw-parser-output')
    if (len(content) == 0) | (len(content[0].find_all('p')) <= 1):
        URL = 'https://en.wikipedia.org/wiki/' + name.replace(" ", "_") + "_(" + city.replace(" ", "_") + ")"
        print(URL)
        page = requests.get(URL)
        soup = BeautifulSoup(page.content, 'html.parser')
        content = soup.find_all('div', class_='mw-parser-output')

    p = content[0].find_all('p')

    c = []
    p1 = ""

    while (len(c) == 0):
        par = p[randomNumber(1, len(p))]

        par = removeExtra(par.text)
        p1 = par.split(". ")[0].strip()
        blob = TextBlob(p1)

        c = candidates(blob.tags, name, p1)

    final = []
    for item in c:
        final.append(re.sub(item, '_______', p1))
    print(final)

    r = randomNumber(0, len(final))
    selection = final[r]
    answer = c[r]

    result = {"question": selection, "answer": answer}

    return jsonify(result)

@app.route('/cities', methods=['GET'])
def returnCities():
    result = {"cities": cities}
    return jsonify(result)

app.run()



