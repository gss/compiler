if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  parser = require '../lib/gss-compiler'
else
  parser = require 'gss-compiler'

describe 'GSS compiler', ->
  it 'should provide the compile method', ->
    chai.expect(parser.compile).to.be.a 'function'
  
  describe 'with a statement containing only CCSS', ->
    statement = '#box[right] == #box2[left];'
    ast =
      selectors: [
        '#box'
        '#box2'
      ]
      commands: [
        ['var', '#box[x]', 'x', ['$id','box']]
        ['var', '#box[width]', 'width', ['$id', 'box']]
        ['varexp', '#box[right]', ['plus',['get','#box[x]'],['get','#box[width]']], ['$id','box']]
        ['var', '#box2[left]', 'left', ['$id','box2']]
        ['eq', ['get','#box[right]'],['get','#box2[left]']]
      ]      
      css: ''
    it 'should be able to produce correct AST', ->
      result = parser.compile statement
      chai.expect(result).to.eql ast

  describe 'with a statement containing only VFL', ->
    statement = "@horizontal [#b1][#b2];"
    ast =
      selectors: ["#b1", "#b2"]
      commands: [
        ["var", "#b1[x]", "x", ["$id", "b1"]]
        ["var", "#b1[width]", "width", ["$id", "b1"]]
        ['varexp', '#b1[right]', ['plus',['get','#b1[x]'],['get','#b1[width]']], ['$id','b1']]
        ["var", "#b2[left]", "left", ["$id", "b2"]]
        ["eq", ["get", "#b1[right]"], ["get", "#b2[left]"]]
      ]      
      css: ''
    result = null
    it 'should be able to produce correct AST', ->
      result = parser.compile statement
      chai.expect(result).to.eql ast
