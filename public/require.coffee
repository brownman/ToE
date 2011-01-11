window.require = do ->
  library = {}

  return (handle) ->
    return library[name] if library[handle]?
    
    throw "#{handle} not found" unless window.modules[handle]?
    
    module = library[handle] = exports: new Object
    
    window.modules[handle](require, module, module.exports)
    
    return module.exports