class FamilyView extends AbstractView
    _template = null

    modal: null
    searchAttr: ["name": 1]

    constructor: (args...) ->
        _template = _.template $('#family-teplete').html()
        @modal = $ '#add_family-modal'
        _.extend @, args[0]
        @collection = @families
        super args...

    initialize: => @setElement @_create()

    events: =>
        @model.on 'destroy', => @$el.remove()
        @model.on 'change',  @_reload
        'click .fa-remove': '_remove'
        'click .fa-pencil': '_update'
        'click .fa-group':  '_createTree'
        'setNumberOfRow': '_setNumberOfRow'

    _create: => $ _template num: 0, name: @model.get('name')

    _createTree: => @trigger 'tree', @model

