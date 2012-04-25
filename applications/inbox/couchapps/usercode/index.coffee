do (jQuery) ->
  defaults =
    limit: 100
    sort: 'by_type'

  sort_descending =
    'by_date': true
    'by_type': false

  $ = jQuery

  inbox_tpl = $.compile_template ->
    div class:'inbox', ->
      div class:'inbox_header', ->
        span 'Show '
        select name:'inbox_limit', class:'inbox_limit', ->
          option value:100, -> '100'
          option value:200, -> '200'
          option value:500, -> '500'
        select name:'inbox_sort', class:'inbox_sort', ->
          option value:'by_type', -> 'By type'
          option value:'by_date', -> 'By date'
      div class:'inbox_content'


  default_list_tpl = $.compile_template ->
    div class:"inbox_item #{@type}", type:@type, ->
      div class:'inbox_item_header', ->
        span class:'date', -> @date ? ''
        span class:'time', -> @time ? ''
        span class:'subject', -> @list
      div class:'inbox_item_body', ->
        @form

  inbox_item = (doc) ->
    type = doc.type
    if type? and Inbox.registered(type)
      try
        d = new Date(doc.updated_at)
        element = $ default_list_tpl
          type: type
          date: d.toLocaleDateString()
          time: d.toLocaleTimeString()
          list: Inbox.list type,doc
          form: Inbox.form type,doc
      catch error
        console.log "Rendering #{type} failed: #{error}"
      element.data 'doc', doc
      # Hide the body at startup
      element.children('.inbox_item_body').hide()
      # Clicking on the header will show/hide the body.
      element.children('.inbox_item_header').click ->
        element.children('.inbox_item_body').toggle()
      # (This is one interaction model. Clicking on the header could e.g. open a dialog.)
      return element

  $.fn.inbox = (app,inbox_model) ->

    app.swap do inbox_tpl

    insert_docs = (docs) =>
      content = @find('.inbox_content')
      content.html ''
      for doc in docs
        do (doc) ->
          content.append inbox_item doc

    current_limit = =>
      @find('.inbox_limit').val() ? defaults.limit

    current_sort = =>
      @find('.inbox_sort').val() ? defaults.sort

    refill = =>
      inbox_model.viewDocs 'inbox/' + current_sort(),
        include_docs: true
        descending: sort_descending[current_sort()]
        limit: current_limit()
      , insert_docs

    @data 'changes', inbox_model.changes (results) =>
      content = @find('.inbox_content')
      for r in results
        do (r) ->
          # FIXME Remove potentially existing document from the displayed list.
          return if r.deleted
          inbox_model.get r.id, (doc) ->
            content.prepend inbox_item doc

    @find('.inbox_limit').change ->
      refill()

    @find('.inbox_sort').change ->
      refill()

    refill()
    return @


###
  Sammy code to start the inbox.
###

do (jQuery) ->
  $ = jQuery
  container = '#content'
  profile = $(container).data 'profile'

  $(document).ready ->
    $.sammy container, ->

      inbox_model = @createModel 'inbox'

      @get '#/inbox', =>
        $(container).inbox(@,inbox_model)
