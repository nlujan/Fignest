'use strict'

var Mongo = require('./mongo');
Mongo.connect().then((err) => {
  run();
}).catch((err) => {
  console.log(err);
});

function run() {

  var express = require('express');
  var app = express();
  var bodyParser = require('body-parser');
  app.use(bodyParser.json());

  var Event = require('./event');
  var User = require('./user');
  var db = Mongo.db();

  // var Place = require('./place');
  // var YelpApi = require('./yelp-api');
  // var _ = require('underscore');



  // API
  app.get('/users', (req, res) => {
    User.allUsers().then((users) => {
      res.status(200).json(users.map((user) => user.asJson() ));
    }).catch((err) => {
      res.status(500).json(err);
    });
  });

  app.post('/users', (req, res) => {
    var user = User.fromJson(req.body);
    user.save().then((user) => {
      res.status(200).json(user.asJson());
    }).catch((err) => {
      res.status(500).json(err);
    });
  });

  app.get('/users/:userId/invitations', (req, res) => {
    User.fromId(req.params.userId).then((user) => {
      return user.getInvitations();
    }).then((invitations) => {
      res.status(200).json(invitations.map((inv) => inv.asJson() ));
    }).catch((err) => {
      res.status(500).json(err);
    });
  });

  app.get('/events/:eventId', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      res.status(200).json(event.asJson());
    }).catch((err) => {
      res.status(500).json(err);
    });
  });

  app.post('/events', (req, res) => {
    var event = Event.fromJson(req.body);
    event.save().then((val) => {
      res.status(200).json(val.asJson());
    }).catch((err) => {
      res.status(500).json(err);
    });
  });

  app.get('/events/:eventId/places', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      return event.getPlaces();
    }).then((places) => {
      res.status(200).json(places.map((place) => place.asJson() ));
    }).catch((err) => {
      console.log(`Error in GET /events/:eventId/places`, err);
      res.status(500).json(err);
    });
  });

  app.get('/events/:eventId/solution', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      return event.getSolution();
    }).then((solution) => {
      res.status(200).json(solution.asJson());
    }).catch((err) => {
      console.log(`Error in GET /events/:eventId/solution`, err);
      res.status(500).json(err);
    });
  });

  app.post('/events/:eventId/actions', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      return event.saveActions(req.body);
    }).then((actions) => {
      res.status(200).json(actions.map((action) => action.asJson() ));
    }).catch((err) => {
      console.log(`Error in POST /events/:eventId/actions`, err);
      res.status(500).json(err);
    })
  });

  // Start server
  app.listen(3010, function() {
    console.log('App server started...');
  });
}

