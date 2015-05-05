class PeopleModel extends Backbone.Model
    _form = null

    defaults:
        parent: []
        relation: null
        family: []
        gender: null
        name: ""
        id: 0
    view: null
    localStorage: new Backbone.LocalStorage "People"

    initialize: => _form = $ '#add_human-form'

    isMale: => this.get('gender') == 'male'

    isFemale: => this.get('gender') == 'female'

    getOneLetter: =>
        gender = "M" if @isMale()
        gender = "Ж" if @isFemale()
        gender

    validate: (attrs, options) =>
        @set 'family', @get('family').map (val) -> parseInt val
        if _.isEmpty attrs.name    then return [_form.find('input[name="name"]'),    "Заполните поле имя"]
        if attrs.gender == 'none'  then return [_form.find('select[name="gender"]'), "Выберите пол"]
        if attrs.family.length > 2 then return [_form.find('select[name="family"]'), "Не больше двух семей"]

