window.modules['test'] =
  foo: 'bar'

window.require = do ->
  library = {}
  modules = window.modules

  return (handle) ->
    return library[name] if library[handle]?
    
    throw "#{handle} not found" unless modules[handle]?
    
    module = library[handle] = exports: new Object
    
    modules[handle](require, module, module.exports)
    
    return module.exports