define = $.fn.select2.amd.define
require = $.fn.select2.amd.require
define 'select2/i18n/ru', [], ->
    errorLoading: -> "Нельзя отобразить результаты поиска."
    inputTooLong: (args) ->
        overChars = args.input.length - args.maximum
        message = "Количество символов в строке превышена на: #{overChars} "
    inputTooShort: -> "Слишком короткая строка поиска"
    loadingMore: -> 'Загрузка результатов...'
    maximumSelected: (args) -> "Выможете выбрать максимум #{args.maximum} пунктов"
    noResults: -> "Ничего не найдено"
    searching: -> "Поиск..."

$.fn.select2.defaults.set 'language', require 'select2/i18n/ru'

window.ui = _.extend window.ui || {}, ComicsSelector: null

class window.ui.ComicsSelector
    _searchIconTemplate = _.template '<span class="fa fa-search"></span>'
    _selector: ''
    _toolbarSelector: null

    select2: null
    $el: null
    $toolbar: null
    $go: null

    constructor: (@_toolbarSelector, @_selector) ->
        @$toolbar = $ @_toolbarSelector
        @$go = $ '#go'
        @$go.click @go
        @$el = $(@_selector).eq 0
        $(window).load =>
            @select2 = @$el.data('select2')
            @$el.on 'select2:open', @_open
                .on 'select2:closing', @_closeing
            @_updateTemplate()

    go: (e) => $(@).trigger 'go', [@$el.val()]

    value: (val) =>
        if val? then @$el.val(val).trigger 'change' else @$el.val()

    _open: (e) =>
        @select2.$results
                .parents '.select2-results'
                .mCustomScrollbar "destroy"
                .mCustomScrollbar
                    theme: 'dark-2'
                    axis: 'y'

    _closeing: (e) =>
        @select2.$results
                .parents '.select2-results'
                .mCustomScrollbar "destroy"

    _updateTemplate: =>
        $search = @select2.dropdown.$searchContainer
        $search.append _searchIconTemplate {}
        @select2.$results.unmousewheel()


