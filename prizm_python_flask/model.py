from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
# from sqlalchemy import Table, Column, Integer, String, Date, Float
import config 
 
# DB class
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] =  config.DB_URI
db = SQLAlchemy(app)
 
# DB classess
class User(db.Model):
 
    id = db.Column(db.Integer, primary_key=True)
    forename = db.Column(db.String(80))
    surname = db.Column(db.String(80))
    middle_name = db.Column(db.String(80))
    street = db.Column(db.String(80))
    city = db.Column(db.String(24))
    state = db.Column(db.String(24))
    zipcode = db.Column(db.Integer)
    dob = db.Column(db.String(10))
    data = db.Column(db.Text)
    gender = db.Column(db.String(6))
    height = db.Column(db.Integer)
    weight = db.Column(db.Integer)
    hair = db.Column(db.String(3))
    eyes = db.Column(db.String(3))
    twitter = db.Column(db.String(80))
    instagram = db.Column(db.String(80))
 
    def __init__(self, data=None, forename=None, surname=None, middle_name=None, dob=None):
        self.data = data
        self.forename = forename
        self.surname = surname
        self.middle_name = middle_name
        self.dob = dob
 
    def __repr__(self):
        return '<User %s %s %s>' % (self.id, self.forename, self.surname)