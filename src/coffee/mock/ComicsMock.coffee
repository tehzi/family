window.mock = _.extend window.mock || {}, ComicsMock: null

log = (args...) -> console.log.apply console, args if window.console and window.console.log

class ComicsMock
    constructor: ->
        deferred = $.Deferred()
        $.ajax = (options) =>
            deferred = $.Deferred()
            log "ajax ", options
            switch options.type
                when "GET"
                    what = options.url.match(/([a-z]+)\/([0-9]+)\/?$/)[1]
                    switch what
                        when 'next'
                            page = parseInt options.url.match(/next\/([0-9]+)\/?$/)[1]
                            next = page + 1
                            if 0 < next < 9
                                log 'resolve ',
                                    next: next
                                    url: "/furries/other/comic/#{next}.jpeg"
                                deferred.resolve
                                    next: next
                                    url: "/furries/other/comic/#{next}.jpeg"
                            else
                                log 'error', 'not found'
                                deferred.reject error: 'not found'
                        when 'prev'
                            page = parseInt options.url.match(/prev\/([0-9]+)\/?$/)[1]
                            prev = page - 1
                            if 0 < prev < 9
                                log 'resolve ',
                                    prev: prev
                                    url: "/furries/other/comic/#{prev}.jpeg"
                                deferred.resolve
                                    prev: prev
                                    url: "/furries/other/comic/#{prev}.jpeg"
                            else
                                log 'error', 'not found'
                                deferred.reject error: 'not found'
                    if options.url.match(/^\/rest/)
                        page = parseInt options.url.match(/strip\/([0-9]+)$/)[1]
                        if 0 < page < 9
                            log 'resolve ',
                                page: page
                                url: "/furries/other/comic/#{page}.jpeg"
                            deferred.resolve
                                page: page
                                url: "/furries/other/comic/#{page}.jpeg"
                        else
                            log 'error', 'not found'
                            deferred.reject error: 'not found'
            deferred

window.mock.ComicsMock = ComicsMock

