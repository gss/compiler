preparser = require('gss-preparser')
ccss      = require('ccss-compiler')
vfl       = require('vfl-compiler')

uuid = () ->
  "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
    r = Math.random() * 16 | 0
    v = (if c is "x" then r else (r & 0x3 | 0x8))
    v.toString 16

runCompiler = (chunk) ->
  switch chunk[0]
    when 'ccss'
      return ccss.parse(chunk[1])
    when 'vfl'
      return vfl.parse(chunk[1])
    when 'gtl'
      return gtl.parse(chunk[1])

compile = (gss) ->
  rules = preparser.parse(gss)
  rules = parseRules rules
  return rules
  
  # TODO: flatten?
  
  
  
parseRules = (rules) ->
  
  css = ""
  
  for chunk in rules
        
    
    parsed = {}
    
    switch chunk.type
    
      # TODO: move this stuff to plugins
      when 'directive'      
        switch chunk.name
          when 'horizontal', 'vertical', '-gss-horizontal', '-gss-vertical', 'h', 'v', '-gss-h', '-gss-v'
            try
              ccssRules = vfl.parse "@#{chunk.name} #{chunk.terms}"
            catch e
              console.log "VFL Parse Error: @#{chunk.name} #{chunk.terms}", e
            parsed = {
              selectors:[]
              commands:[]
            }
            for ccssRule in ccssRules
              try                 
                subParsed = ccss.parse(ccssRule)
              catch e
                console.log "VFL generated CCSS parse Error", e              
              parsed.selectors = parsed.selectors.concat(subParsed.selectors)
              parsed.commands = parsed.commands.concat(subParsed.commands)
          
          when 'if','elseif','else'
            if chunk.terms.length > 0
              try              
                parsed = ccss.parse "?(" + chunk.terms + ");"
              catch e
                console.log "CCSS conditional parse Error", e
              parsed.clause = parsed.commands[0]
              delete parsed.commands
            else
              parsed.clause = null
      
      #   
      when 'constraint'
        try
          parsed = ccss.parse chunk.cssText
        catch e
          console.log "Constraint Parse Error", e
      
      # 
      #when 'style'
      #  css += " " + chunk.key + ":" + chunk.val + ";"
    
    # TODO: remove
    #delete parsed.css
    
    
    for key, val of parsed
      chunk[key] = val        
    
    # recurse
    if chunk.rules
      parseRules chunk.rules

  #inject chunks
  
  #rules.css = css
  
  return rules
  

# Inject chunks with _uuid & _selectorContext

inject = (chunks) ->
  
  _inject = (_rules, parent) ->
    for rule in _rules
      rule._uuid = uuid()
      if parent
        rule._parent_uuid = parent._uuid
      if rule.rules?.length > 0
        _inject rule.rules, rule
  
  _inject chunks
  
  return chunks

      

exports.compile = compile

