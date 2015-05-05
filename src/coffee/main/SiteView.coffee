class SiteView extends Backbone.View
    _instance = null
    _clearFlag = yes
    _model = null
    _relationTemplate = null

    parent: null
    people: null
    families: null
    tree: null

    constructor: (args...) ->
        _.extend @, args[0]
        @people = new PeopleCollection
        @families = new FamilyCollection
        @people.fetch()
        @families.fetch()
        _relationTemplate = _.template $('#relation-template').html()
        super args...

    initialize: =>
        @createTestCollections() if @people.isEmpty() and @families.isEmpty()
        @tree = new FamilyTreeView parent: @, people: @people, families: @families
        @render()

    events: =>
        @people.on 'add',   (model) => @renderTable $('#people'), @people, ((args...) => new PeopleView args...), model
        @families.on 'add', (model) => @renderTable $('#families'), @families, ((args...) => new FamilyView args...), model
        @families.on 'change', (model) =>
            @_loadFamilyInSelect()
            @people.each (human) => human.trigger('change') if human.get('family').indexOf(model.get('id')) isnt -1
        'keyup #search': '_search'
        'submit #add_human-form':  '_saveHuman'
        'submit #add_family-form': '_saveFamily'
        'shown.bs.modal #add_human-modal': '_humanModalOpen'
        'shown.bs.modal #add_family-modal': '_familyModalOpen'
        'click #clear_storage': '_clearStorage'

    createTestCollections: =>
        @families.create {name: 'Пупкины', id: 1}
        @families.create {name: 'Ивановы', id: 2}
        @families.create {name: 'Егоровы', id: 3}
        @people.create {name: 'Александр Пупкин',             gender: 'male',   family: [1],    relation: 2, id: 1}
        @people.create {name: 'Татьяна Пупкина',              gender: 'female', family: [1],    relation: 1, id: 2}
        @people.create {name: 'Сергей Иванов',                gender: 'male',   family: [2],    relation: 4, id: 3}
        @people.create {name: 'Валентина Иванова',            gender: 'female', family: [2],    relation: 3, id: 4}
        @people.create {name: 'Василий Александрович Пупкин', gender: 'male',   family: [1],    relation: 6, parent: [1, 2], id: 5}
        @people.create {name: 'Анастасия Сергеевна Иванова',  gender: 'female', family: [1, 2], relation: 5, parent: [3, 4], id: 6}
        @people.create {name: 'Ирина Васильевна Пупкина',     gender: 'female', family: [1, 2],              parent: [5, 6], id: 7}
        @people.create {name: 'Антон Егоров',                 gender: 'male',   family: [3],    relation: 9, id: 8}
        @people.create {name: 'Марина Егорова',               gender: 'female', family: [3],    relation: 8, id: 9}

    render: =>
        @renderTable $('#people'),   @people,   ((args...) => new PeopleView args...)
        @renderTable $('#families'), @families, ((args...) => new FamilyView args...)
        $('[data-toggle="tooltip"]').tooltip()
        $('[data-toggle="select2"]').select2()
        @_loadFamilyInSelect()

    renderTable: ($table, collection, view_factory, model) =>
        if collection.length and not model?
            $table.removeClass 'hide'
            collection.each (model) => @renderTable $table, collection, view_factory, model
        else if model?
            model.view = view_factory model: model, people: @people, families: @families
            model.view.on 'edit', @_edit
                      .on 'tree', @tree.open
                      .on 'relation', @_editFamily
                      .render()
                      .appendTo $table.find('tbody')
                      .trigger 'setNumberOfRow'

    _clearStorage: =>
        localStorage.clear()
        @createTestCollections()
        location.href = location.href

    _saveHuman: (e) =>
        $form = $ e.currentTarget
        human = _model || new PeopleModel _.extend id: @people.max('id').get('id') + 1, $form.serializeObject()
        human.set $form.serializeObject() if _model?
        human.on 'invalid', @_validate
        @_clearForm($form)
        if human.isValid()
            if not _model?
                @people.create human
            else
                _model.save()
                _model = null
            $('#add_human-modal').modal('hide')

    _saveFamily: (e) =>
        $form = $ e.currentTarget
        family = _model || new FamilyModel _.extend id: @families.max('id').get('id') + 1, $form.serializeObject()
        family.set $form.serializeObject() if _model?
        family.on 'invalid', @_validate
        @_clearForm($form)
        if family.isValid()
            if not _model?
                @families.create family
            else
                _model.save()
                _model = null
            $('#add_family-modal').modal('hide')

    _search: (e) =>
        $form = $ e.currentTarget
        @people.each (model) => model.view.search $form.val()
        @families.each (model) => model.view.search $form.val()

    _loadFamilyInSelect: =>
        $select = $('#add_human_family-select')
        $select.find('option').remove()
        $select.select2
            data: @families.map (element) => id: element.get('id'), text: element.get('name')
            placeholder: "Выбери семью",
            maximumSelectionLength: 2

    _humanModalOpen: (e) =>
        if _clearFlag
            $modal = $ e.currentTarget
            $modal.find('input').val ''
            @_clearForm($('#add_human-form'))
            $('#add_human_gender-input').val('none').trigger 'change'
            $('#add_human_family-select').val('').trigger 'change'
            _model = null
        _clearFlag = yes

    _familyModalOpen: (e) =>
        if _clearFlag
            $modal = $ e.currentTarget
            $modal.find('input').val ''
            _model = null
        _clearFlag = yes

    _edit: (model) =>
        _clearFlag = no
        _model = model
        $modal = model.view.modal
        $form = $modal.find('form')
        $modal.modal 'show'
        $form.find("[name='#{key}'], [name='#{key}[]']").val(val).trigger('change') for key, val of model.toJSON()

    _editFamily: (model) =>
        children = @people.filter (m) -> _.intersection([model.get('id')], m.get('parent')).length
        $tbody = $('#geneologic_editor-modal').find 'table tbody'
        $('#geneologic_editor-man').html model.get 'name'
        $('#geneologic_editor-modal')
            .find('table tbody td')
            .filter (index) => index > 0
            .remove()
        $('#geneologic_editor-modal').modal 'show'
        $('#add_relation').off()
                          .click => $tbody.append @_relationFactory {related: no, child_for: no, parent: no}, model
        $tbody.append @_relationFactory {related: yes, child_for: no, parent: no}, model                                                    if model.get('relation')?
        _.each model.get('parent'), (parent) => $tbody.append @_relationFactory {related: no, child_for: yes, parent: no}, model, parent    if model.get('parent').length
        _.each children, (child) => $tbody.append @_relationFactory {related: no, child_for: no, parent: yes}, model, child.get("id") if children.length
        $tbody.append @_relationFactory {related: no, child_for: no, parent: no}, model

    _relationFactory: (option, model, _id) =>
        relation = $ _relationTemplate _.extend option, man: model.get('name')
        relation_bind = (e, addition) =>
            id = model.get 'id'
            collection = null
            $select = relation.find('[data-toggle="select2"]').eq 0
            $relation2 = relation.find('[data-toggle="select2"]').eq 1
            $relation2
                .find 'option'
                .filter (index) => index > 0
                .remove()
            switch $select.val()
                when 'related'
                    collection = new PeopleCollection(@people.filter (model) -> model.isMale())   if model.isFemale()
                    collection = new PeopleCollection(@people.filter (model) -> model.isFemale()) if model.isMale()
                when 'child_for'
                    collection = new PeopleCollection @people.filter (m) ->
                        not _.isEmpty(model.get 'family') and
                        m.get('relation')? and
                        _.intersection(m.get('family'), model.get('family')).length and
                        [id, parseInt(model.get 'relation')].indexOf(m.get 'id') is -1
                when 'parent'
                    collection = new PeopleCollection @people.filter (m) ->
                        if _id? and m.get("id") is _id then return yes
                        not _.isEmpty model.get('family') and
                        _.isEmpty(m.get 'parent') and
                        _.intersection(m.get('family'), model.get('family')).length and
                        model.get('relation')? and
                        [id, parseInt(model.get 'relation')].indexOf(m.get 'id') is -1
            $relation2.select2(data: collection.map (model) => id: model.get('id'), text: model.get('name')) if collection?
        save_bind = (e, _id) =>
            $select = relation.find('[data-toggle="select2"]').eq 0
            $relation2 = relation.find('[data-toggle="select2"]').eq 1
            if $relation2.val() != 'none'
                switch $select.val()
                    when 'related'
                        mate = parent = @people.findWhere id: parseInt $relation2.val()
                        model.set 'relation', parseInt $relation2.val()
                        mate.set 'relation', model.get 'id'
                        model.save()
                    when 'child_for'
                        parent = @people.findWhere id: parseInt $relation2.val()
                        if parent.get("relation")?
                            model.set 'parent', [parent.get("id"), parent.get("relation")]
                            model.save()
                    when 'parent'
                        child = @people.findWhere id: parseInt $relation2.val()
                        if model.get("relation")?
                            child.set 'parent', [model.get("id"), model.get("relation")]
                            child.save()
            else
                switch $select.val()
                    when 'related'
                        model.set 'relation', null
                        model.save()
                    when 'child_for'
                        model.set 'parent', []
                        model.save()
                    when 'parent'
                        child = @people.findWhere id: _id
                        child.set 'parent', []
                        child.save()
                relation.remove()
        relation.find '[data-toggle="select2"]'
                .select2()
                .eq 0
                .on "select2:select", relation_bind
                .end()
                .eq 1
                .on "select2:select", (e) -> save_bind e, _id
        if option.related or option.child_for or option.parent
            relation_bind()
            $relation2 = relation.find('[data-toggle="select2"]').eq 1
            $relation2.val(_id).trigger('change')                                                  if (option.parent or option.child_for) and _id?
            $relation2.val(@people.findWhere(id: model.get 'relation').get 'id').trigger('change') if option.related
        relation

    _clearForm: ($form) =>
        if $form? and $form.length
            $form.find '.has-error'
                 .removeClass 'has-error'
                 .end()
                 .find '.text-danger, input[name="id"]'
                 .remove()

    _validate: (model, [input, error]) =>
        input.parents '.form-group'
             .addClass 'has-error'
             .append "<div class='text-danger'>#{error}</div>"

    @getSiteView: (args...) => if _instance is null then _instance = new SiteView args... else _instance

$ -> main.view = SiteView.getSiteView parent: main, el: '.main'

