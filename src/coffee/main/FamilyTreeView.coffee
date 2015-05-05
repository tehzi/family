class FamilyTreeView extends Backbone.View
    _model = null
    _tree = null
    _svgTree = []
    _svgCache = []
    _lines = [[]]
    _linesSvg = []

    people: null
    families: null
    parent: null
    svg: null
    params:
        width: 870
        height: 300
        padding:
            top: 8
            right: 8
            bottom: 8
            left: 8
        margin:
            left: 8
            right: 10
            top: 20
            bottom: 8
        family:
            margin:
                left: 20
                right: 20

    constructor: (args...) ->
        _.extend @, args[0]
        super args...

    initialize: => @setElement $ '#geneologic_tree-modal'

    events: =>
        'show.bs.modal': '_open'
        'hide.bs.modal': '_close'

    open: (model) =>
        _model = model
        @$el.modal 'show'

    _open: => @_createSvg()

    _close: =>
        @_clearSvg()
        _model = null
        _tree = null

    _createSvg: =>
        if @svg is null
            @svg = d3.select(@$el.find('.modal-body').get 0).append "svg"
            @svg.attr "width",  @params.width
                .attr "height", @params.height
                .attr "class", "tree"
            @svg.append "g"
                .attr "class", "lines"
        _tree = @people.tree _model
        @_draw _tree, null

    _clearSvg: =>
        @svg = null
        @$el.find '.modal-body'
            .html ''

    _draw: (tree, parent) =>
        _family = @_family
        _person = @_person
        tree_nodes = @svg.selectAll "svg.c#{new String(Math.random() * (10 ** 16)).slice(0,10)}"
                         .data tree
        tree_nodes
            .enter()
            .append "svg"
            .attr 'id', (family) -> if not (family instanceof PeopleModel) then "family_#{family.husband.get('id')}-#{family.wife.get('id')}" else "person_#{family.get('id')}"
            .attr 'class', (family) -> if not (family instanceof PeopleModel) then 'family' else 'person'
            .attr 'visibility', 'hidden'
            .each (family, index) ->
                if not (family instanceof PeopleModel)
                    _family @, family, index, tree, parent
                else
                    _person @, family, index, tree, parent

    _family: (element, family, index, root, parents) =>
        element = d3.select element
        family_svg_group = _.map [family.husband, family.wife], (human, index) =>
            svg = element.append "svg"
                         .attr "id",    if not index then "husband-#{element.attr('id')}" else "wife-#{element.attr('id')}"
                         .attr "class", if not index then "husband" else "wife"
            @_text human.get( "name"), svg
            svg
        _.last(_lines).push family
        wait_for_append = (wait) =>
            node = family_svg_group[0].node()
            try   bbox = node.getBBox()
            catch error
                bbox =
                    x:      node.clientLeft
                    y:      node.clientTop
                    width:  node.clientWidth
                    height: node.clientHeight
            if bbox.width > 0 and bbox.height > 0
                @_showFamilyElement element, family, index, root, parents, bbox
                clearInterval wait
        wait = setInterval (-> wait_for_append wait), 10

    _person: (element, person, index, root, parents) =>
        element = d3.select element
        @_text person.get( "name"), element
        _.last(_lines).push person
        wait_for_append = (wait) =>
            node = element.node()
            try   bbox = node.getBBox()
            catch error
                bbox =
                    x:      node.clientLeft
                    y:      node.clientTop
                    width:  node.clientWidth
                    height: node.clientHeight
            if bbox.width > 0 and bbox.height > 0
                @_showPersonElement element, person, index, root, parents, bbox
                clearInterval wait
        wait = setInterval (-> wait_for_append wait), 10

    _text: (text, parent) =>
        text = parent.append 'text'
                     .text text

    _rect: (parent) =>
        bbox = parent.node().getBBox()
        text = parent.select 'text'
        text_bbox = text.node().getBBox()
        parent.insert "rect", ":first-child"
              .attr "width",  bbox.width + @params.padding.left + @params.padding.right
              .attr "height", bbox.height + @params.padding.top + @params.padding.bottom
              .attr "ry", "5"
              .attr "rx", "5"
        text.attr 'y', text_bbox.height + @params.padding.top - text_bbox.y
            .attr 'x', text_bbox.x + @params.padding.left

    _line: (a, b) =>
        x1 = (parseInt($(a.node()).attr('x')) || 0) + (parseInt($(a.node()).parents('svg').attr('x')) || 0)
        x2 = (parseInt($(b.node()).attr('x')) || 0) + (parseInt($(b.node()).parents('svg').attr('x')) || 0)
        y1 = (parseInt($(a.node()).attr('y')) || 0) + (parseInt($(a.node()).parents('svg').attr('y')) || 0)
        y2 = (parseInt($(b.node()).attr('y')) || 0) + (parseInt($(b.node()).parents('svg').attr('y')) || 0)
        width1 = a.node().getBBox().width
        width2 = b.node().getBBox().width
        height1 = a.node().getBBox().height
        height2 = b.node().getBBox().height
        start = x1 + (width1 // 2)
        end =   x2 + (width2 // 2)
        start_y = y1 + (height1 // 2)
        end_y = y2 + (height2 // 2)
        @svg.select ".lines"
            .append "path"
            .attr "d", "M #{start} #{start_y} L #{end} #{end_y}"

    _endLine: (parent) =>
        children = []
        _lines.push []
        _.each parent, (family) => _.each family.children, (child) => children.push child if children.indexOf(child) is -1
        @_draw children, parent if children.length

    _center: (last_element) =>
        $last_element = $(last_element.node())
        x = parseInt($last_element.attr 'x') || 0
        width = last_element.node().getBBox().width
        line = $last_element.prevAll().andSelf().filter -> $(@).attr('y') == $last_element.attr('y')
        offset = (@params.width // 2) - ((x + width) // 2)
        line.each -> $(@).attr 'x', offset + parseInt $(@).attr 'x'
        line.each (index, element) => @_line d3.select($(element).find('.husband').get(0)), d3.select($(element).find('.wife').get(0)) if $(element).attr('class') == 'family'
        _linesSvg.push line

    _lineTree: (element, family) =>
        husband = element.select('.husband')
        wife = element.select('.wife')
        parent1 = @svg.select "#family_#{family.husband.get("parent").join("-")}"
        parent2 = @svg.select "#family_#{family.wife.get("parent").join("-")}"
        x = parseInt(element.attr 'x') || 0
        x_wife = x + parseInt(wife.attr 'x')
        y = parseInt(element.attr 'y') || 0
        center3 = [husband.node().getBBox().width // 2
                   husband.node().getBBox().height // 2]
        center4 = [wife.node().getBBox().width // 2
                   wife.node().getBBox().height // 2]
        if parent1.size()
            x1 = parseInt(parent1.attr 'x') || 0
            y1 = parseInt(parent1.attr 'y') || 0
            center1 = [parseInt($(parent1.select('.wife').node()).attr 'x') - (@params.family.margin.left // 2)
                       parent1.node().getBBox().height // 2]
            @svg.select ".lines"
                .append "path"
                .attr "d", """M #{x1 + center1[0]} #{y1 + center1[1]}
                              l 0 25
                              q0,3 #{if x + center3[0] > x1 + center1[0] then "3" else "-3"},3
                              L #{x + center3[0] + if x + center3[0] > x1 + center1[0] then -3 else 3} #{y1 + center1[1] + 28}
                              q#{if x + center3[0] > x1 + center1[0] then "3" else "-3"},0 #{if x + center3[0] > x1 + center1[0] then "3" else "-3"},3
                              L #{x + center3[0]} #{y + center3[1]}"""
        if parent2.size()
            x2 = parseInt(parent2.attr 'x') || 0
            y2 = parseInt(parent2.attr 'y') || 0
            center2 = [parseInt($(parent2.select('.wife').node()).attr 'x') - (@params.family.margin.left // 2)
                       parent2.node().getBBox().height // 2]
            @svg.select ".lines"
                .append "path"
                .attr "d", """M #{x2 + center2[0]} #{y2 + center2[1]}
                              l 0 25
                              q0,3 #{if x_wife + center4[0] > x2 + center2[0] then "3" else "-3"},3
                              L #{x_wife + center4[0] + 3} #{y1 + center1[1] + 28}
                              q#{if x_wife + center4[0] > x2 + center2[0] then "3" else "-3"},0 #{if x_wife + center4[0] > x2 + center2[0] then "3" else "-3"},3
                              L #{x_wife + center4[0]} #{y + center4[1]}"""

    _lineTreePerson: (element, person) =>
        parent = @svg.select "#family_#{person.get("parent").join("-")}"
        x = parseInt(element.attr 'x') || 0
        y = parseInt(element.attr 'y') || 0
        x1 = parseInt(parent.attr 'x') || 0
        y1 = parseInt(parent.attr 'y') || 0
        center = [element.node().getBBox().width // 2
                  element.node().getBBox().height // 2]
        center1 = [parseInt($(parent.select('.wife').node()).attr 'x') - (@params.family.margin.left // 2)
                   parent.node().getBBox().height // 2]
        @svg.select ".lines"
            .append "path"
            .attr "d", """M #{x1 + center1[0]} #{y1 + center1[1]}
                          l 0 25
                          L #{x + center[0]} #{y + center[1]}"""

    _showFamilyElement: (element, family, index, root, parents, bbox) =>
        y = 0
        husband = element.select '.husband'
        wife = element.select '.wife'
        if parents?
            parents_line = _.last _linesSvg
            $first_parent = $ _.first parents_line
            y = (parseInt($first_parent.attr 'y') || 0) + $first_parent.get(0).getBBox().height + @params.margin.top
        _.each [husband, wife], (d3) =>
            d3.select "text"
              .attr 'x', 0
              .attr 'y', d3.select('text').node().getBBox().height
            @_rect d3
        wife.attr "x", husband.node().getBBox().width + @params.family.margin.left
        prev = $(element.node()).prev('svg').filter -> not _.contains _.last(_linesSvg), @
        if prev.length
            bbox = prev.get(0).getBBox()
            element.attr "x", (parseInt prev.attr 'x') + bbox.width + @params.margin.left + @params.margin.right
        else
            element.attr "x", @params.margin.left
        element.attr "y", y
        if root.length == (index + 1)
            @_center element
            @_endLine _.last _lines
        @_lineTree element, family if root.length == (index + 1) and parents?
        $(element.node()).removeAttr 'visibility'

    _showPersonElement: (element, person, index, root, parents, bbox) =>
        y = 0
        if parents?
            parents_line = _.last _linesSvg
            $first_parent = $ _.first parents_line
            y = (parseInt($first_parent.attr 'y') || 0) + $first_parent.get(0).getBBox().height + @params.margin.top
        element.select "text"
               .attr 'x', 0
               .attr 'y', element.select('text').node().getBBox().height
        @_rect element
        prev = $(element.node()).prev('svg').filter -> not _.contains _.last(_linesSvg), @
        if prev.length
            bbox = prev.get(0).getBBox()
            element.attr "x", bbox.x + bbox.width + @params.margin.left + @params.margin.right
        else
            element.attr "x", @params.margin.left
        element.attr "y", y
        @_center element if root.length == (index + 1)
        @_lineTreePerson element, person if root.length == (index + 1) and parents?
        $(element.node()).removeAttr 'visibility'

