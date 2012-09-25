#!/usr/bin/env coffee
###
(c) 2010 Stephane Alnet
Released under the AGPL3 license
###

# Create a username for the new host's main process so that it can bootstrap its own installation.
host = require './host.coffee'

pico = require 'pico'

# Load Configuration
ccnq3 = require 'ccnq3'
ccnq3.config (config) ->

  hostname = config.host

  if config.admin?.system
    # Manager host

    # Install the local (bootstrap/master) host in the database.
    users = pico config.users.couchdb_uri

    host.create_user users, hostname, (password) ->

      host.update_config password, config, (config) ->

        ccnq3.config.update config

  else

    pico(config.provisioning.local_couchdb_uri).create ->
