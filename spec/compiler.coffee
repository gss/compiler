if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  parser = require '../lib/gss-compiler'
else
  parser = require 'gss-compiler'

describe 'GSS compiler', ->
  it 'should provide the compile method', ->
    chai.expect(parser.compile).to.be.a 'function'

  describe 'with a statement containing only CCSS', ->
    statement = '#button3[width] == #button4[height];'
    ast =
      selectors: [
        '#button3'
        '#button4'
      ]
      vars: [
        ['get', '#button3[width]', 'width', ['$id', 'button3']]
        ['get', '#button4[height]', 'height', ['$id', 'button4']]
      ]
      constraints: [
        ['eq', ['get', '#button3[width]'], ['get', '#button4[height]']]
      ]
      css: ''
    it 'should be able to produce correst AST', ->
      result = parser.compile statement
      chai.expect(result).to.eql ast
