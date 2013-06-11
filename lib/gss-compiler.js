var preparser = require('gss-preparser');
var ccss = require('ccss-compiler');
var vfl = require('vfl-compiler');

var runCompiler = function (chunk) {
  switch (chunk[0]) {
    case 'ccss':
      return ccss.parse(chunk[1]);
    case 'vfl':
      return vfl.parse(chunk[1]);
    case 'gtl':
      return gtl.parse(chunk[1]);
  }
};

exports.compile = function (gss) {
  var chunks = preparser.parse(gss);
  var results = {
    selectors: [],
    vars: [],
    constraints: [],
    css: ''
  };
  chunks.forEach(function (chunk) {
    if (chunk[0] === 'css') {
      results.css += chunk[1];
      return;
    }
    var rules = runCompiler(chunk);
    results.selectors = results.selectors.concat(rules.selectors);
    results.vars = results.vars.concat(rules.vars);
    results.constraints = results.constraints.concat(rules.constraints);
  });
  return results;
};
