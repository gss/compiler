preparser = require('gss-preparser')
ccss      = require('ccss-compiler')
vfl       = require('vfl-compiler')

runCompiler = (chunk) ->
  switch chunk[0]
    when 'ccss'
      return ccss.parse(chunk[1])
    when 'vfl'
      return vfl.parse(chunk[1])
    when 'gtl'
      return gtl.parse(chunk[1])

compile = (gss) ->
  chunks = preparser.parse(gss)
  results = 
    css: ''

  for chunk in chunks

    if chunk[0] is 'css'
      results.css += chunk[1]
            
    else
      rules = runCompiler(chunk)
      for part of rules    
        if !results[part]
          results[part] = []
        results[part] = results[part].concat(rules[part])      
  
  return results

exports.compile = compile

