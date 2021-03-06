User                  = require '../../models/user'
Stats                 = require '../../models/stat'
moment                = require 'moment'
{getDailyActivities}  = require './helpers'
{saveStats}           = require './helpers'
{dateRange}           = require './helpers'


module.exports =

  #==========================
  # static assets
  #==========================

  index: (req, res) ->
    # by default express will send index.html on  GET '/'
    # so this is just optional
    # send back splash/landing instead
    # of jsut login/signup
    res.sendfile('index.html')

  #==========================
  # CRUD ops
  #==========================

  # logout helper
  logout: (req, res) ->
    id = req.user._id
    User.findById id, (err, user) ->
      if err
        throw new Error err, ' cannot find user to log'
      if user
        user.lastLoggedIn = Date.now()
        user.save (err) ->
          throw new Error err if err
      req.logout()
      res.redirect '/'

  # get curent user on the fly if need it, should not need this, security issue
  getUser: (req, res) ->
    id = req.params.id
    res.send 401 if id isnt String req.user._id # can only get logged in user
    User.findById id, (err, user) ->
      if err
        throw new Error err, 'User.findOne error '

      if not user
        # user isn't in the db
        res.send 204
      if user
        res.json user

  userActivity: (req, res) ->
    # define the DB query to get results
    today = moment().subtract('days', 1).format 'YYYY-MM-DD'
    query = user: req.user._id
    dateRange today, today, query
    Stats.find query, (err, stats) ->
      if err
        throw new Error err, 'error getting api/user data'
      else if stats.length
      # if stats, send back reqested range of stats along with user data
        data =
          username: req.user.username
          pic: req.user.authData.fitbit.avatar
          stats: stats[0]
        res.json data
      else if !stats.length
        # if no stats in db, go to fitbit and get 7 days
        # worth of stats and save to db
        date = moment().subtract('days', 7)

        toDate = moment().subtract('days', 1)
        query =
          'user': req.user._id
          'date': toDate.format 'YYYY-MM-DD'


        while date <= toDate
          # helper function that goes to fitbit and gets a weeks data set
          getDailyActivities req, res, date.format('YYYY-MM-DD'), saveStats
          date = date.add 'days', 1

  deleteUser: (req, res) ->
    id = req.user._id
    User.findById id, (err, user) ->
      if err
        throw new Error err, 'could not find user to delete'
      if not user
        # user is not in DB anyways..
        res.send 204
      else
        user.remove (err, user) -> # remove user record
          if err
            throw new Error err, 'could not delete user'
          req.logout()
          res.redirect '/'

  # helper to protect angular routes on client
  loggedIn: (req, res) ->
    res.send if req.isAuthenticated() then req.user else "0"

