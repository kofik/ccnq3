###
# (c) 2010 Stephane Alnet
# Released under the GPL3 license
###

# Load Configuration
fs = require('fs')
config_location = 'register.config'
config = JSON.parse(fs.readFileSync(config_location, 'utf8'))

def config: config

# Load CouchDB
cdb = require process.cwd()+'/../../../lib/cdb.coffee'

def users_cdb: cdb.new (config.users_couchdb_uri)

# Content

client '/u/register': ->
  $(document).ready ->
    $('#register_container').load 'register.widget', ->
      $.getScript 'password.js'
      # Add any other script we need to load.

client '/u/password': ->
  $(document).ready ->
    password_charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-".split('')

    random_password = (l) ->
      return '' if l is 0
      return random_password(l-1)+password_charset[Math.floor(Math.random()*password_charset.length)]

    $('register #password').val -> random_password(16)

# HTML

get '/u/register.widget': -> widget 'register_widget'

using 'crypto'

put '/u/register.html': ->

  if not @first_name or not @last_name or not @email
    return error 'Invalid parameters, try again'

  # Currently assumes username = email
  username = @email
  db = portal_cdb
  db.exists (it_does) =>
    if it_does
      p = params
      p._id = 'org.couch.user:'+username
      p.name = username
      p.domain = request.header('Host')
      p.confirmation_code = crypto.createHash('sha1').update(Math.random()).digest('hex')
      p.confirmation_expires = (new Date()).valueOf() + 2*24*3600*1000
      p.status = 'send_confirmation'
      # PUT without _rev can only happen once
      db.put params, (r) ->
        if r.error?
          return error r.error
        else
          session.logged_in = username
          return redirect config.post_register_uri
    else
      return error 'Not connected to the database'

helper confirm_registration: (cb) ->
  db = portal_cdb
  db.get @email, (p) =>
    if p.error
      return error p.error

    if not p.confirmation_code? or not p.confirmation_expires?
      return error 'Nothing to confirm.'

    if p.confirmation_expires < (new Date()).valueOf()
      p.confirmation_code = Math.random()
      p.confirmation_expires = (new Date()).valueOf() + 2*24*3600*1000
      return db.put params, (r) ->
        if r.error?
          return error r.error
        else
          return error 'Your request is too old. A new confirmation code was sent to you.'

    if p.confirmation_code isnt @code
      return error 'Invalid confirmation code.'

    # Everything is OK
    p.status = 'confirmed'
    delete p.confirmation_code
    delete p.confirmation_expires
    db.put p, (r) ->
      if r.error?
        return error r.error
      else
        cb(p)

get '/u/register/confirm.html': ->
  if @email? and @code?
    confirm_registration (p) ->
      session.logged_in = p._id
      redirect config.post_register_confirmation_uri
  else
    page 'register_confirm'

view register_confirm: ->
  @title = 'Please confirm'

  form id: 'register', class: 'main validate', method: 'get', ->
    div ->
      label for: 'email', -> 'Email'
      input id: 'email', name: 'email'
    div ->
      label for: 'code', -> 'Confirmation code'
      input id: 'code', name: 'code'
    div ->
      input type: 'submit', value: 'Confirm'

view register_widget: ->

  l = (_id,_label,_class) ->
    label for: _id, -> _label
    if _class?
      input id: _id, name: _id, class: _class
    else
      input id: _id, name: _id

  lr = (_id,_label) -> l(_id,_label,'required')

  form id: 'register', class: 'main validate', method: 'post', ->
    input type: 'hidden', name: '_method', value: 'PUT'
    div -> lr 'first_name', 'First Name'
    div -> lr 'last_name', 'Last Name'
    div -> l  'email', 'Email', 'required email'
    # XXX TODO Captcha
    div ->
      lr 'password', 'Password'
      button id: 'generate', -> 'Generate'
    div ->
      input type: 'submit', value: 'Register'

