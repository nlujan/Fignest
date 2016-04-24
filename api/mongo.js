'use strict';

var MongoClient = require('mongodb').MongoClient;
// var ObjectId = require('mongodb').ObjectID;
const mongoUrlLocal = 'mongodb://localhost:27017/test';
const mongoUrlTest = 'mongodb://localhost:27017/testing';
// var url = process.env.MONGOLAB_URI || mongoUrlTest;
var url = process.env.MONGOLAB_URI || mongoUrlLocal;
var _db;

class Mongo {
  static connect() {
    return new Promise((resolve, reject) => {
      MongoClient.connect(url, (err, db) => {
        _db = db;
        if (err) {
          console.log('Error connecting to mongo');
          reject(err);
        }
        console.log(`Connected to mongo at ${url}`);
        resolve();
      });
    });
  }

  static close() {

  }

  static db() {
    return _db;
  }
}

module.exports = Mongo;