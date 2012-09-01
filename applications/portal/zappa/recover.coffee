###
# (c) 2010 Stephane Alnet
# Released under the AGPL3 license
###

@include = ->
  pico = require 'pico'
  url = require 'url'
  querystring = require 'querystring'

  config = null
  require('ccnq3_config').get (c) ->
    config = c

  @coffee '/u/recover.js': ->
    $(document).ready ->

      $('#password_recovery_container').load '/u/recover.widget', ->
        $('#recover_buttons').buttonset()
        $('form.main').addClass('ui-widget-content')
        $('form.validate').validate()
        $('button,input[type="submit"],input[type="reset"]').button()

        $('#recover').dialog({ autoOpen: false, modal: true, resizable: false })

        $('#recover_window').submit ->
          $('#recover').dialog('open')
          return false

        $('#cancel_recover').click ->
          $('#recover').dialog('close')
          return false

        $('#recover').submit ->
          ajax_options =
            type: 'post'
            url: '/u/recover.json'
            data:
              email: $('#recover_email').val()
            dataType: 'json'
            success: (data) ->
              if not data.ok
                $('#recover_error').html('Operation failed')
              else
                $('#login_error').html('')
                $('#login').dialog('close')
                window.location.reload()

          $('#recover_error').html("")
          $.ajax(ajax_options)

          return false


  @get '/u/recover.widget': -> @render 'recover_widget', layout:no

  @view recover_widget: ->

    div id: 'recover_buttons', ->
      form id: 'recover_window', ->
        input type: 'submit', value: 'Recover password'

    form id: 'recover', class: 'main validate', method: 'get', ->
      span id: 'recover_error', class: 'error'
      div ->
        label for: 'recover_email', -> 'Email'
        input id: 'recover_email', name: 'email'
      # XXX Captcha
      div ->
        input type: 'submit', value: 'Confirm'

  @post '/u/recover.json': ->
    email = @body.email
    if not email?
      return @send error:'Missing username'

    users_db = pico config.users.couchdb_uri
    users_db.get "org.couchdb.user:#{email}", (e,r,p) =>
      if e?
        return @send error: 'Please make sure you register first.'

      # Everything is OK
      p.send_password = true
      users_db.put p, (e) =>
        if e?
          return @send error:e
        else
          return @send ok:true
