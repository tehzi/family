class PeopleCollection extends Backbone.Collection
    _tree = []
    _treeCache = {}

    localStorage: new Backbone.LocalStorage "People"
    model: null

    constructor: (args...) ->
        @model = PeopleModel
        super args...

    tree: (family) =>
        _tree = []
        _treeCache = {}
        family_id = family.get 'id'
        members = new PeopleCollection @models.filter (model) => model.get('family').indexOf(family_id) isnt -1
        roots =   new PeopleCollection members.filter (model) => _.isEmpty model.get 'parent'
        roots.each (model) =>
            family = @_createFamily members, model
            if not _.contains _tree, family
                if not (family instanceof PeopleModel)
                    _tree.push family if _.isEmpty(family.husband.get 'parent') and _.isEmpty(family.wife.get 'parent')
                else
                    _tree.push family
        _.each _tree, (model) =>
            if not (model instanceof PeopleModel)
                relation = @_findRelationFamily @, model
                _tree = _tree.concat relation if relation?
        _tree.sort @_sort
        _tree

    _createFamily: (members, model) =>
        family = {}
        mate = members.findWhere(relation: model.get 'id')
        if mate
            _.each [mate, model], (model) =>
                _.extend family, husband: model if model.isMale()
                _.extend family, wife: model    if model.isFemale()
            if not _treeCache["#{family.husband.get('id')}-#{family.wife.get('id')}"]?
                _.extend family, children: @_findChildren members, family.husband, family.wife
                _treeCache["#{family.husband.get('id')}-#{family.wife.get('id')}"] = family
            else
                _treeCache["#{family.husband.get('id')}-#{family.wife.get('id')}"]
        else
            model

    _findChildren: (collection, husband, wife) =>
        husband_id = husband.get('id')
        wife_id = wife.get('id')
        children_with_family = []
        children = collection.filter (model) =>
            parent = model.get('parent')
            _.isEmpty(_.difference parent, [husband_id, wife_id]) and not _.isEmpty parent
        _.each children, (model) =>
            family = @_createFamily @, model
            children_with_family.push family if not _.contains children_with_family, family
        _.each children_with_family, (model) =>
            if not (model instanceof PeopleModel)
                relation = @_findRelationFamily @, model
                children_with_family = children_with_family.concat relation if relation?
        children_with_family.sort @_sort
        children_with_family

    _findRelationFamily: (collection, model) =>
        if model.children.length
            relation = []
            _.each model.children, (children) =>
                not_in_family = null
                if not (children instanceof PeopleModel)
                    _.each [children.husband, children.wife], (child) =>
                        parent = child.get('parent')
                        not_in_family = child if not _.isEmpty(_.difference [model.wife.get('id'), model.husband.get('id')], parent) and not _.isEmpty parent
                relation.push @_createFamily @, @findWhere id: not_in_family.get('parent')[0] if not_in_family?
            relation

    _sort: (a, b) =>
        isFamilies = not (a instanceof PeopleModel) and not (b instanceof PeopleModel)
        hasChildren = isFamilies and a.children? and b.children? and a.children[0]? and b.children[0]?
        isChildrenFamilies = hasChildren and not (a.children[0] instanceof PeopleModel) and not (b.children[0] instanceof PeopleModel)
        isSameChild = isChildrenFamilies and a.children[0] is b.children[0]
        isHusbandChild = isSameChild and a.children[0].husband.get('parent').indexOf(a.husband.get('id')) isnt -1
        if not isHusbandChild          then  1
        else if not isChildrenFamilies then -1
        else                                 0


