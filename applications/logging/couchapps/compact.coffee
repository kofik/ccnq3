#!/usr/bin/env coffee

pico = require 'pico'

require('ccnq3').config (config) ->

  logging_uri = config.logging?.couchdb_uri
  if logging_uri?
    logging = pico logging_uri
    logging.compact pico.log
    logging.compact_design 'replicate', pico.log
