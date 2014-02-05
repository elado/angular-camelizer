app = angular.module 'camelizer', []

app.provider 'Camelizer', ->
  deepTransformKeysInObject = (object, fn) ->
    if _.isPlainObject(object)
      _.chain(object).keys().each (key) ->
        value = object[key]
        delete object[key]
        object[fn(key)] = deepTransformKeysInObject(value, fn)
        return
      object
    else if _.isArray(object)
      _.map object, (item) ->
        deepTransformKeysInObject(item, fn)
    else
      object

  $get: ->
    camelizeObject: (object) ->
      deepTransformKeysInObject object, (k) -> S(k).camelize().s

    underscoreObject: (object) ->
      deepTransformKeysInObject object, (k) -> S(k).underscore().s

app.config(($httpProvider, CamelizerProvider) ->
  Camelizer = CamelizerProvider.$get()
  jsonRx = /^application\/json/

  $httpProvider.defaults.transformRequest.push (data, headerGetter) ->
    # if data && jsonRx.test(headerGetter('Content-Type'))
    if data && jsonRx.test(headerGetter()['Content-Type'])
      data = angular.fromJson(data)

      data = Camelizer.underscoreObject data

      data = angular.toJson(data)

    data

  $httpProvider.defaults.transformResponse.push (data, headerGetter) ->
    if jsonRx.test(headerGetter('Content-Type'))
      data = Camelizer.camelizeObject data

    data
)
