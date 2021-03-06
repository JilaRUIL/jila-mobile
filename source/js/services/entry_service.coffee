class Service
  constructor: (@$q, @$analytics) ->
    entriesIndex: []
    entryBackButtonURL: null
  entries_for: (categoryId) =>
    deferred = @$q.defer()
    Lawnchair {name: 'entries', adapter: 'dom'}, (store) =>
      store.where "_.contains(record.value.categories, #{categoryId})", (entries) ->
        deferred.resolve entries.map (e) -> e.value
    return deferred.promise
  get: (entryId) =>
    deferred = @$q.defer()
    Lawnchair {name: 'entries', adapter: 'dom'}, (store) ->
      store.get entryId, (entry) ->
        deferred.resolve entry.value
    return deferred.promise
  all: () =>
    deferred = @$q.defer()
    Lawnchair {name: 'entries', adapter: 'dom'}, (store) ->
      store.all (entries) ->
        deferred.resolve entries.map (e) -> e.value
    return deferred.promise
  entries_for_letter: (letter) =>
    deferred = @$q.defer()
    Lawnchair {name: 'entries', adapter: 'dom'}, (store) ->
      store.all (entry_data) ->
        entries = entry_data.map (e) -> e.value
        deferred.resolve entries.filter (e) -> e.entry_word[0].toUpperCase() == letter
    return deferred.promise

  save: (entry) =>
    deferred = @$q.defer()
    Lawnchair {name: 'entries', adapter: 'dom'}, (store) ->
      deferred.resolve store.save {key: entry.id, value: entry}
    return deferred.promise

  search_for: (query) =>
    deferred = @$q.defer()
    Lawnchair {name: 'entries', adapter: 'dom'}, (store) =>
      store.where "record.value.entry_word.toLowerCase().indexOf('#{query.toLowerCase()}') !== -1 ||
      record.value.translation.toLowerCase().indexOf('#{query.toLowerCase()}') !== -1" , (entries) =>
        if entries.length == 0
          @$analytics.eventTrack 'SearchNotFound',
              category: 'SearchNotFound'
              label: query
        deferred.resolve entries.map (e) -> e.value
    return deferred.promise
  clear: () =>
    Lawnchair {name: 'entries', adapter: 'dom'}, (store) ->
      store.nuke()

angular.module('app').service 'entryService', ['$q', '$analytics', Service]
