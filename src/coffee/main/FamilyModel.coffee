class FamilyModel extends Backbone.Model
    _instance = null
    _form = null

    defaults:
        name: ""
        id: 0
    collection: null
    people: null
    localStorage: new Backbone.LocalStorage "Family"

    initialize: => _form = $ '#add_family-form'

    validate: (attrs, options) =>
        if _.isEmpty attrs.name then return [_form.find('input[name="name"]'), "Заполните поле имя"]

