preparser = require('gss-preparser')
ccss      = require('ccss-compiler')
vfl       = require('vfl-compiler')
vgl       = require('vgl-compiler')

uuid = () ->
  "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
    r = Math.random() * 16 | 0
    v = (if c is "x" then r else (r & 0x3 | 0x8))
    v.toString 16

compile = (gss) ->
  try
    rules = preparser.parse(gss.trim())
  catch error
    error.name = 'Preparse error'
    throw error
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
          
          when 'grid-template', '-gss-grid-template', 'grid-rows', '-gss-rows', 'grid-cols', '-gss-grid-cols'
            try              
              subrules = vgl.parse "@#{chunk.name} #{chunk.terms}"
            catch error
              error.name = "VGL parse error: @#{chunk.name} #{chunk.terms}"
              throw error
            parsed = {
              selectors:[]
              commands:[]
            }            
            for ccssRule in subrules.ccss
              try                 
                subParsed = ccss.parse(ccssRule)
              catch error
                error.name = 'VGL generated CCSS parse error'
                throw error
              parsed.selectors = parsed.selectors.concat(subParsed.selectors)
              parsed.commands = parsed.commands.concat(subParsed.commands)
            for vflRule in subrules.vfl
              try                 
                subParsed = ccss.parse(vfl.parse(vflRule).join("; "))
              catch error
                error.name = 'VGL generated VFL parse error'
                throw error
              parsed.selectors = parsed.selectors.concat(subParsed.selectors)
              parsed.commands = parsed.commands.concat(subParsed.commands)
            #console.log "!!!!!", parsed
          
          when 'horizontal', 'vertical', '-gss-horizontal', '-gss-vertical', 'h', 'v', '-gss-h', '-gss-v'
            try
              ccssRules = vfl.parse "@#{chunk.name} #{chunk.terms}"
            catch error
              error.name = "VFL parse error: @#{chunk.name} #{chunk.terms}"
              throw error
            parsed = {
              selectors:[]
              commands:[]
            }
            for ccssRule in ccssRules
              try                 
                subParsed = ccss.parse(ccssRule)
              catch error
                error.name = 'VFL generated CCSS parse error'
                throw error
              parsed.selectors = parsed.selectors.concat(subParsed.selectors)
              parsed.commands = parsed.commands.concat(subParsed.commands)
          
          when 'if','elseif','else'
            if chunk.terms.length > 0
              try              
                parsed = ccss.parse "@cond" + chunk.terms + ";"
              catch error
                error.name = 'CCSS conditional parse error'
                throw error
              parsed.clause = parsed.commands[0]
              delete parsed.commands
            else
              parsed.clause = null
      
      #   
      when 'constraint'
        try
          parsed = ccss.parse chunk.cssText
        catch error
          error.name = 'Constraint parse error'
          throw error
      
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

