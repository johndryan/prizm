#!/usr/local/bin/python
# -*- coding: utf-8 -*-

# IMPORTS + SETUP
# ---------------------------------------------------------------------

connected = True
arduinoPort = "/dev/tty.usbmodemfa131"  # Front USB port on MacBook Pro

from flask import Flask
from flask import render_template
from flask import request
app = Flask(__name__)
#app.run(host= 'johnryan.artcenter.edu') 
app.debug = False

from datetime import *
import time

import os
import twitter

# Arduino
import serial

from flask import Flask, jsonify, request
from model import db, app, User

# FLASK PAGES
# ---------------------------------------------------------------------

@app.route('/')
def index():
    # a.digital_write(9, firmata.HIGH)
    switch_led(1)
    return render_template('index.html')

@app.route('/license/', methods=['POST', 'GET'])
def license():
    switch_led(4)
    
    # Check if first letter is % or ;
    # If CA format: lines[0][1:3] = CA
    
    # GET USER ID
    
    # DECODE LICENSE
    data = request.form['license_data']
    user = User(data)
    # RECORD data TO MYSQL ANYWAY?
    if data[1:3] == "CA":
        lines = data.split('\n')
        line_one = lines[0].split('^')

        # # ADDRESS
        user.street = line_one[2].title()
        user.state = lines[0][1:3]
        user.city = line_one[0][3:].title()
        user.zipcode = lines[2][3:8]
        
        #googleImage(user.city)
        
        # NAME
        name = line_one[1].split('$')
        user.forename = name[1].capitalize()
        user.surname = name[0].capitalize()
        if len(name) > 2:
            user.middle_name = name[2].capitalize()
    
        # OTHER DETAILS
        month = int(lines[1][25:27])
        if month > 12: month = 9
        # user.dob = datetime.strptime(lines[1][21:29],"%Y%m%d")
        user.dob = "%s-%02d-%s" % (lines[1][21:25], month, lines[1][27:29])
        if lines[2][30:31] == 'M':
            user.gender = 'Male'
        else: user.gender = 'Female'
        user.height = int(lines[2][31])*12 + int(lines[2][32:34])
        user.weight = lines[2][34:37]
        user.hair = lines[2][37:40]
        user.eyes = lines[2][40:43]
        user.drivers_license = lines[1][9:16]
        
        db.session.add(user)
        db.session.commit()
        
        return render_template('license.html', user=user)
    else:
        switch_led(3)
        # TODO: Fall back if not read correctly?
        
        db.session.add(user)
        db.session.commit()
        
        return render_template('manual.html', user_id = user.id)

@app.route('/photo/', methods=['POST', 'GET'])
def photo():
    user_id = request.form['user_id']
    if request.form['manual'] == "true":
        print "Manual - user #%s" % user_id
        #Manually added
        user = User.query.get(user_id)
        user.forename = request.form['forename']
        user.surname = request.form['surname']
        user.city = request.form['city']
        db.session.commit()
    else:
        print "Automatic - user #%s" % user_id
    if connected:
        os.system("python ext_scripts/cv2_face.py face %s" % user_id)
    switch_led(2)
    #print("Taking photo of FACE for user %s" % user_id)
    #time.sleep(2)
    return render_template('photo.html', user_id = user_id)

@app.route('/fingerprints/', methods=['POST', 'GET'])
def fingerprints():
    user_id = request.form['user_id']
    if connected:
        os.system("python ext_scripts/cv2_face.py hand %s" % user_id)
    switch_led(3)
    return render_template('fingerprints.html', user_id = user_id)

@app.route('/services/', methods=['POST', 'GET'])
def services():
    user_id = request.form['user_id']
    return render_template('services.html', user_id = user_id)

@app.route('/twitter/', methods=['POST', 'GET'])
def twitter():
    username=request.form['twitter']
    api = twitter.Api()
    statuses = api.GetUserTimeline(username)
    return render_template('twitter.html',statuses=statuses)

@app.route('/thank_you/', methods=['POST', 'GET'])
def thank_you():
    return render_template('thank_you.html', user_id = user_id)

@app.errorhandler(404)
def error_handler(e):
    return render_template('manual.html'), 404

# MISC FUNCTIONS
# ---------------------------------------------------------------------
def switch_led( led ):
    if connected:
        s.write('~L%s\n' % led)

def googleImage( city ):
    print city

# MAIN
# ---------------------------------------------------------------------

if __name__ == '__main__':
    #Setup Arduino
    if connected :
        s = serial.Serial(port=arduinoPort, baudrate=9600)
        
    app.run()