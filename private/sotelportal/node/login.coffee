###
(c) 2010 Stephane Alnet
Released under the GPL3 license
###

# Load Configuration
fs = require('fs')
config_location = 'login.config'
login_config = JSON.parse(fs.readFileSync(config_location, 'utf8'))

def login_config: login_config

# Load CouchDB
cdb = require process.cwd()+'/../../../lib/cdb.coffee'

def cdb: cdb

using 'url'
using 'querystring'

client login: ->
  $(document).ready ->

    # Log into the main portal (this application).
    main_login = (next) ->
      ajax_options =
        type: 'post'
        url: '/u/login.json'
        data:
          username: $('#login_username').val()
          password: $('#login_password').val()
        dataType: 'json'
        success: (data) ->
          if not data.ok
            $('#login_error').html('Login failed')
            return
          next()

      $('#login_error').html("")
      $.ajax(ajax_options)

    # Use data.couchdb to login as well
    couchdb_login = (next) ->
      couchdb_options =
        type: 'get'
        url: '/_session'
        username: $('#login_username').val()
        password: $('#login_password').val()
        dataType:'json'
        success: (data) ->
          if not data.ok
            $('#login_error').html('Database login failed.')
            return
          next()

      $('#login_error').html('Logging you into the database.')
      $.ajax(couchdb_options)

    login_done = ->
      # All done.
      $('#login_error').html('')
      $('#login').dialog('close')
      window.location.reload()

    $('#login_container').load '/u/login.widget', ->
      $('#login_buttons').buttonset()
      $('form.main').addClass('ui-widget-content')
      $('form.validate').validate()
      $('button,input[type="submit"],input[type="reset"]').button()

      $('#login').dialog({ autoOpen: false, modal: true, resizable: false })

      $('#login_window').submit ->
        $('#login').dialog('open')
        return false

      $('#cancel_login').click ->
        $('#login').dialog('close')
        return false

      $('#login').submit ->
        main_login -> couchdb_login -> login_done()

          # Log into the voice portal
          # Log into the ticket portal
          # Redirect (in a frame?) to couchdb

        return false

      $('#logout').submit ->
        ajax_options =
          url: '/u/logout.json'
          success: (data) ->
            if data.ok
              window.location.reload()
        $.ajax(ajax_options)
        return false

get '/login.widget': -> widget 'login_widget'

view login_widget: ->

  div id: 'login_buttons', ->
    if @session.logged_in?
      a href: '/u/profile/', -> @session.logged_in
      form id: 'logout', ->
        input type: 'submit', value: 'Logout'
    else
      form id: 'login_window', ->
        input type: 'submit', value: 'Login'

  form id: 'login', class: 'main validate', title: 'Login', ->
    span id: 'login_error', class: 'error'
    div ->
      label for: 'login_username', -> 'Username'
      input id: 'login_username', class: 'required'
    div ->
      label for: 'login_password', -> 'Password'
      input type: 'password', id: 'login_password', class: 'required'
    div ->
      input type: 'submit', value: 'Login'
      button id: 'cancel_login', -> 'Cancel'

post '/login.json': ->
  if not @username? and not @password?
    return send {error:'Missing parameters'}

  uri = url.parse login_config.session_couchdb_uri
  uri.auth = "#{querystring.escape @username}:#{querystring.escape @password}"
  delete uri.href
  delete uri.host
  session_cdb = cdb.new url.format uri
  session_cdb.get '', (p) =>
    if p.error?
      return send p
    session.logged_in = p.name
    session.roles     = p.roles
    return send ok:true

get '/logout.json': ->
  delete session.logged_in
  return send ok:true

