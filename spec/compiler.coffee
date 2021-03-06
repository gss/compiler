if window?
  parser = require 'gss-compiler'
else
  chai = require 'chai' unless chai
  parser = require '../lib/gss-compiler'
  sinon = require 'sinon'

{assert, expect} = chai


# Helper function for expecting errors to be thrown when parsing.
#
# @param options [Object]
# @option options source [String] GSS statements.
# @option options name [String] The name of the expected error.
# @option options before [Function] Called before the spec runs.
# @option options after [Function] Called after the spec runs.
# @option options pending [Boolean] Whether the spec should be treated as
# pending.
#
expectError = (options) ->
  {after, before, name, pending, source} = options
  itFn = if pending then xit else it

  describe name, ->
    itFn "should throw an error named \"#{name}\"", ->
      before?()
      exercise = -> parser.compile source
      expect(exercise).to.throw Error
      after?()

      # Chai doesn't provide a way to verify an error's name,
      # so do it manually.
      try
        exercise()
      catch error
        expect(error.name).to.contain name


describe 'GSS compiler', ->
  it 'should provide the compile method', ->
    chai.expect(parser.compile).to.be.a 'function'
  
  describe 'with a statement containing only CCSS', ->
    statement = '#box[right] == #box2[left];'
    ast = [
      {     
        type: 'constraint'
        cssText: '#box[right] == #box2[left];'
        selectors: [
          '#box'
          '#box2'
        ]
        commands: [
          ['eq', ['get$','right',['$id','box']],['get$','x',['$id','box2']]]
        ]
      }    
    ]  
    it 'should be able to produce correct AST', ->
      results = parser.compile statement
      expect(ast).to.deep.equal results
      #assert results[0]._uuid? is true, 'has uuid'
      #for key, val of ast
      # expect(results[0][key]).to.eql val
      
  describe 'Virtual Elements', ->
    statement = '"box"[right] == "box2"[left];'
    ast = [
      {     
        type: 'constraint'
        cssText: '"box"[right] == "box2"[left];'
        selectors: [
        ]
        commands: [
          ['eq', ['get$','right',['$virtual','box']],['get$','x',['$virtual','box2']]]
        ]
      }    
    ]  
    it 'should be able to produce correct AST', ->
      results = parser.compile statement
      expect(ast).to.deep.equal results
      #assert results[0]._uuid? is true, 'has uuid'
      #for key, val of ast
      # expect(results[0][key]).to.eql val   

  describe '/ only VFL', ->
    statement = "@horizontal [#b1][#b2];"
    statement2 = "@h [#b1][#b2];"
    ast = [
      {
        type: 'directive'
        name: 'horizontal'
        terms: "[#b1][#b2]"
        selectors: ["#b1", "#b2"]
        commands: [
          ["eq", ["get$","right",['$id','b1']], ["get$","x",['$id','b2']]]
        ]
      }    
    ]
    ast2 = [
      {
        type: 'directive'
        name: 'h'
        terms: "[#b1][#b2]"
        selectors: ["#b1", "#b2"]
        commands: [
          ["eq", ["get$","right",['$id','b1']], ["get$","x",['$id','b2']]]
        ]
      }    
    ]
    it '/ long-form', ->
      results = parser.compile statement
      expect(ast).to.deep.equal results
    it '/ short-form', ->
      results = parser.compile statement2
      expect(ast2).to.deep.equal results
      
  describe 'with a statement containing CCSS & VFL', ->
    statement = """
    
      #box[right] == #box2[left];
      
      @horizontal [#b1][#b2];
    """
    ast = [
      {     
        type: 'constraint'
        cssText: '#box[right] == #box2[left];'
        selectors: [
          '#box'
          '#box2'
        ]
        commands: [
          ['eq', ['get$','right',['$id','box']],['get$','x',['$id','box2']]]
        ]
      }    
      {
        type: 'directive'
        name: 'horizontal'
        terms: "[#b1][#b2]"
        selectors: ["#b1", "#b2"]
        commands: [
          ["eq", ["get$","right",['$id','b1']], ["get$","x",['$id','b2']]]
        ]
      }    
    ]  
    it 'should be able to produce correct AST', ->
      results = parser.compile statement
      expect(ast).to.deep.equal results
      #assert results[0]._uuid? is true, 'has uuid'
      #for key, val of ast
      #  expect(results[0][key]).to.eql val
  
  
  
  
  describe 'w/ VGL', ->
    statement = """
        
      @grid-template simple "ab";
      
    """
    
    targetCCSS = [
      '@virtual "simple-a" "simple-b"'
      '::[simple-md-width] == ::[width] / 2 !require'
      '::[simple-md-height] == ::[height] !require'
      '"simple-a"[width] == ::[simple-md-width]'
      '"simple-b"[width] == ::[simple-md-width]'
      '"simple-a"[height] == ::[simple-md-height]'
      '"simple-b"[height] == ::[simple-md-height]'
      '"simple-a"[right] == "simple-b"[left]'
      '@h |["simple-a"] in(::)'
      '@v |["simple-a"] in(::)'
      '@v |["simple-b"] in(::)'
      '@h ["simple-b"]| in(::)'
      '@v ["simple-a"]| in(::)'
      '@v ["simple-b"]| in(::)'
    ]
    
    it 'should be able to produce correct AST', ->
      results = parser.compile statement
      
      # Due lazy resistance to writing compiled CSS, 
      # this is a naive, but good-enough test
      expect([ 'virtual', 'simple-a', 'simple-b' ]).to.eql results[0].commands[0]
      expect(targetCCSS.length).to.eql results[0].commands.length
      
      
      
  
  describe 'nested w/ conditional', ->
    statement = """
      @horizontal [#b1][#b2];
      
      #box[right] == #box2[left];
      
      #main {
        
        line-height: >= [col-size];
        
        @if [target] >= 960 {      
          width: == [big];
        }
        @else [target] >= 500 {      
          width: == [med];
        }
        @else {      
          width: == [small];
        }
        
      }
      
    """
    ast = [
      {
        type: 'directive'
        name: 'horizontal'
        terms: "[#b1][#b2]"
        selectors: ["#b1", "#b2"]
        commands: [
          ["eq", ["get$","right",['$id','b1']], ["get$","x",['$id','b2']]]
        ]
      }
      {     
        type: 'constraint'
        cssText: '#box[right] == #box2[left];'
        selectors: [
          '#box'
          '#box2'
        ]
        commands: [
          ['eq', ['get$','right',['$id','box']],['get$','x',['$id','box2']]]
        ]
      }
      {     
        type: 'ruleset'
        selectors: [
          '#main'
        ]
        rules: [
          {     
            type: 'constraint'
            cssText: '::[line-height] >= [col-size];'
            selectors: [ '::this' ]
            commands: [
              ['gte', ['get$','line-height',['$reserved','this']],['get','[col-size]']]
            ]
          }
          {
            type:'directive'
            name: 'if'            
            terms: '[target] >= 960'            
            rules: [
              {
                type:'constraint', 
                cssText:'::[width] == [big];'
                selectors: [ '::this' ]
                commands: [
                  ["eq", ["get$","width",["$reserved","this"]], ["get","[big]"]]
                ]
              }
            ]
            selectors: []
            clause: [ '?>=', [ 'get', '[target]' ], [ 'number', 960 ] ]
          }
          {
            type:'directive'
            name: 'else'            
            terms: '[target] >= 500'            
            rules: [
              {
                type:'constraint', 
                cssText:'::[width] == [med];', 
                selectors: [ '::this' ]
                commands: [
                  ["eq", ["get$","width",["$reserved","this"]],["get","[med]"]]
                ]
              }
            ]
            selectors: []
            clause: ["?>=",["get","[target]"],['number',500]]
          }
          {
            type:'directive'                
            name: 'else'            
            terms: ''            
            rules: [
              {
                type:'constraint', 
                cssText:'::[width] == [small];', 
                selectors: [ '::this' ]
                commands: [
                  ["eq", ["get$","width",["$reserved","this"]], ["get","[small]"]]
                ]
              }
            ]
            clause: null
          }
        ]
      }    
    ]  
    it 'should be able to produce correct AST', ->
      results = parser.compile statement
      expect(ast).to.deep.equal results
      #assert results[0]._uuid? is true, 'has uuid'
      #for key, val of ast
      #  expect(results[0][key]).to.eql val


  describe 'Errors', ->

    expectError
      name: 'Preparse error'
      source: '@'

    expectError
      name: 'VGL parse error'
      source: '@grid-template simple "";'

    expectError
      name: 'VGL generated VFL parse error'
      source: ''
      pending: true

    expectError
      name: 'VGL generated CCSS parse error'
      source: ''
      pending: true

    expectError
      name: 'VFL parse error'
      source: '@h [];'

    expectError
      name: 'VFL generated CCSS parse error'
      source: '@h |-[#box]-| !requirre;'
      before: ->
        sinon.stub console, 'info'
      after: ->
        expect(console.info.calledOnce).to.be.true

        infoMessageFixture = 'Generated by VFL statement:'
        expect(console.info.firstCall.args[0]).to.contain infoMessageFixture

        console.info.restore()

    expectError
      name: 'CCSS conditional parse error'
      source: '@if [target] === 960 {}'

    expectError
      name: 'Constraint parse error'
      source: '#box[right] === #box2[left];'
