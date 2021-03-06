request = require 'supertest'
expect = require 'expect.js'
mongoose = require 'mongoose'
app = require '../server'
dbURI = 'mongodb://127.0.0.1/app'
user = require '../models/user'
clearDB = require('mocha-mongoose')(dbURI)


describe "Web Server", ->

  it "Should get hello world", (done) ->
    request(app).get('/').end (err, res) ->
      expect(res.status).to.be 200
      expect(err).to.eql null
      do done


describe "User auth", (done) ->

  # beforeEach (done) ->
  #   return done()  if mongoose.connection.db
  #   mongoose.connect dbURI, done

  it "Should sing up new user", (done) ->
    request(app).post('/signup')
    .send('username': 'scott', 'password': '1234')
    .end (err, res) ->
      expect(err).to.be null
      expect(res.status).to.be 201
      expect(res.body).to.be.an 'object'
      expect(res.body).to.have.property '_id'
      expect(res.body).to.have.property 'salt'
      expect(res.body).to.have.property 'password'
      do done

  it "Should not let new user sign in", (done) ->
    request(app).post('/login')
    .send('username': 'dookey', 'password': '1234')
    .end (err, res) ->
      expect(res.status).to.be 401
      do done

  it "Should not be logged in if user didn't log in", (done) ->
    request(app).get('/loggedin').end (err, res) ->
      expect(res.status).to.be 200
      expect(res.body).to.eql {}
      do done

describe "Auth with Fitbit", (done) ->

  it "Should not auth with fitbit if not logged in", (done) ->
    request(app).get('/connect/fitbit').end (err, res) ->
      expect(res.status).to.be 401
      expect(err).to.be null
      do done

  it "Should not auth with fitbit callback", (done) ->
    request(app).get('/connect/fitbit/callback').end (err, res) ->
      expect(res.status).to.be 401
      expect(err).to.be null
      do done

describe 'API access', (done) ->

  it 'Should not be able to access user api withouth auth', (done) ->
    request(app).get('/api/user').end (err, res) ->
      expect(res.status).to.be 401
      expect(err).to.be null
      do done

  it 'Should not be able to access users api without auth', (done) ->
    request(app).get('/api/users').end (err, res) ->
      expect(res.status).to.be 401
      expect(err).to.be null
      do done

  it 'Should not be able to access compare api without auth', (done) ->
    request(app).get('/api/compare/12324343345345').end (err, res) ->
      expect(err).to.be null
      expect(res.status).to.be 401
      do done
