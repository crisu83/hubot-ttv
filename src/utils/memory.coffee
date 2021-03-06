lunr = require "lunr"
shortid = require "shortid"
Store = require "./store"

class Memory extends Store
  STORAGE_KEY: "acolyte.memory"

  constructor: (@robot) ->
    @index = lunr ->
      @ref "id"
      @field "body"
      @field "time"
    @recall()

  recall: ->
    data = @load()
    num = 0
    for item in data
      @index.add item
      num++
    @robot.logger.info "MEMORY: Recalled #{num} things"

  tell: (thing) ->
    data = @load()
    item = @createItem thing
    @index.add item
    data[item.id] = item.body
    unless @save data
      @robot.logger.error "ERROR: Failed to learn a new thing."
    @robot.logger.info "MEMORY: Learned that '#{thing}' (#{item.id})"

  ask: (query) ->
    data = @load()
    @robot.logger.info "MEMORY: Trying to answer '#{query}'"
    result = @index.search query
    @robot.logger.debug "result=#{JSON.stringify result} data=#{JSON.stringify data}"
    if result.length isnt 0
      items = []
      for match in result
        items.push data[match.ref]
      items.sort (a, b) ->
        a.time - b.time
      answer = items[0]
      @robot.logger.info "MEMORY: Found answer '#{answer}' to question '#{query}'"
      answer
    else
      @robot.logger.info "MEMORY: Could not answer question '#{query}'"
      null

  forget: (id) ->
    data = @load()
    @index.remove id
    item = data[id]
    delete data[id]
    @robot.logger.info "MEMORY: Forgot '#{item.body}' (#{item.id})"
    true

  createItem: (thing) ->
    item =
      id: shortid.generate()
      body: thing
      time: +new Date()

exports.use = (robot) ->
  @instance = if @instance then @instance else new Memory robot
