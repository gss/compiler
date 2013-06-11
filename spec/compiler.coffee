if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  parser = require '../lib/gss-compiler'
else
  parser = require 'gss-compiler'

describe 'GSS compiler', ->
  it 'should provide the compile method', ->
    chai.expect(parser.compile).to.be.a 'function'
