#!/usr/bin/env coffee

couchapp = require 'couchapp'
pico = require 'pico'

push_script = (uri,script,cb) ->
  couchapp.createApp require("./#{script}"), uri, (app)-> app.push(cb)

cfg = require 'ccnq3_config'
cfg.get (config) ->

  provisioning_uri = config.provisioning.local_couchdb_uri
  provisioning = pico provisioning_uri
  provisioning.create ->
    push_script provisioning_uri, 'registrant'
