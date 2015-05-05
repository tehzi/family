class PeopleView extends AbstractView
    _template = null

    searchAttr: [name: 1, {families: 'name', eq: 3, key: {family: 'id'}}]

    constructor: (args...) ->
        _template = _.template $('#people-templete').html()
        @modal = $ '#add_human-modal'
        _.extend @, args[0]
        @collection = @people
        super args...

    initialize: => @setElement @_create()

    events: =>
        @model.on 'destroy', => @$el.remove()
        @model.on 'change',  @_reload
        'click .fa-remove': '_remove'
        'click .fa-pencil': '_update'
        'click .fa-group':  '_editRelation'
        'setNumberOfRow': '_setNumberOfRow'

    _create: =>
        try
            family = (@families.findWhere(id: parseInt family).get('name') for family in @model.get 'family').join(', ') if _.isArray @model.get('family')
        catch error
            family = null
        $el = $ _template
            num: 0
            name: @model.get('name')
            gender: @model.getOneLetter()
            family: family || "Нет семьи"
        $el.find('td').eq(2).html('<span class="fa fa-male"></span>')   if @model.isMale()
        $el.find('td').eq(2).html('<span class="fa fa-female"></span>') if @model.isFemale()
        $el

    _editRelation: => @trigger 'relation', @model

