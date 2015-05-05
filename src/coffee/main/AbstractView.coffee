class AbstractView extends Backbone.View
    families: null
    people: null
    collection: null
    modal: null

    constructor: (args...) -> super args...

    render: => @$el

    search: (search) =>
        flag = no
        for attr in @searchAttr
            if _.isObject(attr)
                if _.keys(attr).length is 1
                    $td = @$el.find('td').eq _.values(attr)[0]
                    $search_text = $td.find('.search-text')
                    $td.find('.text-warning').each -> $(@).replaceWith $(@).text()
                    if @model.get(_.keys(attr)[0]).toLowerCase().indexOf(search.toLowerCase()) isnt -1
                        $search_text.html $search_text.html().replace new RegExp("(#{search})", 'i'), "<span class='text-warning bg-primary'>$1</span>"
                        flag = yes
                else if _.has(attr, 'eq') and _.has(attr, 'key')
                    $td = @$el.find('td').eq attr.eq
                    $search_text = $td.find('.search-text')
                    collection = @[_.first _.keys _.omit attr, ['eq', 'key']]
                    models = _.map @model.get(_.keys(attr.key)[0]), (find) => collection.findWhere _.object [_.values(attr.key)[0]], [find]
                    $td.find('.text-warning').each -> $(@).replaceWith $(@).text()
                    _.each models, (model) =>
                        if model? and model.get(_.first _.values _.omit attr, ['eq', 'key']).toLowerCase().indexOf(search.toLowerCase()) isnt -1
                            $search_text.html $search_text.html().replace new RegExp("(#{search})", 'i'), "<span class='text-warning bg-primary'>$1</span>"
                            flag = yes
        @$el[if flag or not search then 'show' else 'hide']()

    _remove: => bootbox.confirm "Вы уверены?", (result) => @model.destroy() if result

    _update: => @trigger 'edit', @model

    _create: => $()

    _reload: =>
        el = @_create()
        $.when @$el.replaceWith el
         .then =>
            @setElement el
            @$el.trigger 'setNumberOfRow'

    _setNumberOfRow: => @$el.find('td').eq(0).text @$el.parents('table').find('tr').index(@el)

