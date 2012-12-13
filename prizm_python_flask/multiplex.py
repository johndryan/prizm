#!/usr/bin/python
# -*- coding: utf-8 -*-

# IMPORTS + SETUP
# ---------------------------------------------------------------------

connected = True
debug = True
arduinoPort = "/dev/tty.usbmodemfa131"  # Front USB port on MacBook Pro

from flask import Flask
from flask import render_template
from flask import request
app = Flask(__name__)

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
    
        # NAME
        name = line_one[1].split('$')
        user.forename = name[1].capitalize()
        user.surname = name[0].capitalize()
        if len(name) > 2:
            user.middle_name = name[2].capitalize()
    
        # OTHER DETAILS
        user.dob = datetime.strptime(lines[1][21:29],"%Y%m%d")  
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
        # TODO: Fall back if not read correctly?
        
        db.session.add(user)
        db.session.commit()
        
        return render_template('manual.html', userid = user.id)

@app.route('/photo/', methods=['POST', 'GET'])
def photo():
    if connected:
        os.system("python ext_scripts/cv2_cam.py face current_user")
    switch_led(2)
    print("Taking photo of FACE for user %i" % current_user)
    #time.sleep(2)
    return render_template('photo.html')

@app.route('/fingerprints/')
def fingerprints():
    if connected:
        os.system("python ext_scripts/cv2_cam.py hand current_user")
    switch_led(3)
    return render_template('fingerprints.html')

@app.route('/services/')
def services():
    return render_template('services.html')

@app.route('/twitter/', methods=['POST', 'GET'])
def twitter():
    username=request.form['twitter']
    api = twitter.Api()
    statuses = api.GetUserTimeline(username)
    return render_template('twitter.html',statuses=statuses)

# MISC FUNCTIONS
# ---------------------------------------------------------------------
def switch_led( led ):
    if connected:
        s.write('~L%s\n' % led)

# MAIN
# ---------------------------------------------------------------------

if __name__ == '__main__':
    #Setup Arduino
    if connected :
        s = serial.Serial(port=arduinoPort, baudrate=9600)

    current_user = 0

    if debug :
        app.debug = True
    app.run()