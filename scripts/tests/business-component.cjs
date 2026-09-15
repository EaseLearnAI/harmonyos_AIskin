'use strict';

const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const repoRoot = path.resolve(__dirname, '../..');

function loadTypeScript() {
  if (process.env.AISKIN_TYPESCRIPT_PATH) {
    // An explicitly configured compiler must load successfully; do not hide typos.
    return require(path.resolve(process.env.AISKIN_TYPESCRIPT_PATH));
  }
  try {
    return require(require.resolve('typescript', { paths: [repoRoot, __dirname] }));
  } catch (error) {
    if (error.code !== 'MODULE_NOT_FOUND') throw error;
  }
  const studio = process.env.DEVECO_STUDIO_HOME || '/Applications/DevEco-Studio.app';
  const bundled = path.join(studio, 'Contents/tools/hvigor/hvigor/node_modules/typescript/lib/typescript.js');
  if (fs.existsSync(bundled)) return require(bundled);
  throw new Error(
    'TypeScript is required. Install it in this checkout, set DEVECO_STUDIO_HOME to your macOS DevEco Studio app, ' +
    'or set AISKIN_TYPESCRIPT_PATH to the installed typescript/lib/typescript.js file. See scripts/tests/README.md.'
  );
}

const ts = loadTypeScript();

function readComponentSource(relativePath) {
  const sourcePath = path.resolve(repoRoot, relativePath);
  if (!sourcePath.startsWith(repoRoot + path.sep)) throw new Error('Component must be inside this checkout');
  return fs.readFileSync(sourcePath, 'utf8');
}

/**
 * Execute the checked-out component's fields and business methods, not a copied model.
 * This bounded adapter intentionally stops before ArkUI build/@Builder declarations.
 * It does not implement ArkUI state tracking, rendering, propagation, or lifecycle events.
 */
function extractBusinessComponent(relativePath, componentName, requiredMethods) {
  const source = readComponentSource(relativePath);
  const declaration = `export struct ${componentName}`;
  const start = source.indexOf(declaration);
  if (start < 0) throw new Error(`Missing ${declaration} in ${relativePath}`);
  const component = source.slice(start);
  const rendering = /^[ \t]*(?:@(?:Builder|LocalBuilder)\b|build[ \t]*\()/m.exec(component);
  if (!rendering) throw new Error(`Cannot identify ArkUI rendering boundary in ${relativePath}`);
  const business = component.slice(0, rendering.index)
    .replace(declaration, `class ${componentName}`)
    .replace(/@(?:State|Prop)\s+/g, '')
    .replace(/@Watch\((?:'[^']*'|"[^"]*")\)\s*/g, '');
  if (/^[ \t]*@/m.test(business)) {
    throw new Error(`Unsupported decorator in ${relativePath}; update the adapter explicitly`);
  }
  const transformed = `${business}\n}\nmodule.exports = ${componentName};\n`;
  return compileBusinessClass(relativePath, componentName, transformed, requiredMethods);
}

/** Extract a service class through the TypeScript parser; imports and other classes are not executed. */
function extractBusinessService(relativePath, className, requiredMethods) {
  const source = readComponentSource(relativePath);
  const parsed = ts.createSourceFile(relativePath, source, ts.ScriptTarget.ES2020, true, ts.ScriptKind.TS);
  const declaration = parsed.statements.find(item => ts.isClassDeclaration(item) && item.name?.text === className);
  if (!declaration) throw new Error(`Missing class ${className} in ${relativePath}`);
  const business = source.slice(declaration.getStart(parsed), declaration.end)
    .replace(new RegExp(`^export\\s+class\\s+${className}\\b`), `class ${className}`);
  return compileBusinessClass(relativePath, className, `${business}\nmodule.exports = ${className};\n`, requiredMethods);
}

function compileBusinessClass(relativePath, componentName, transformed, requiredMethods) {
  const result = ts.transpileModule(transformed, {
    fileName: `${componentName}.ts`,
    reportDiagnostics: true,
    compilerOptions: { target: ts.ScriptTarget.ES2020, module: ts.ModuleKind.CommonJS }
  });
  const errors = (result.diagnostics || []).filter(item => item.category === ts.DiagnosticCategory.Error);
  if (errors.length) {
    throw new Error(errors.map(item => ts.flattenDiagnosticMessageText(item.messageText, '\n')).join('\n'));
  }
  const script = new vm.Script(result.outputText, { filename: `${relativePath} (business methods)` });
  return function instantiate(stubs) {
    const context = { ...stubs, module: { exports: {} } };
    script.runInNewContext(context, { timeout: 1000 });
    const Component = context.module.exports;
    for (const method of requiredMethods) {
      if (typeof Component.prototype[method] !== 'function') {
        throw new Error(`${componentName}.${method} was not extracted; source layout may have changed`);
      }
    }
    return new Component();
  };
}

function deferred() {
  let resolve;
  let reject;
  const promise = new Promise((success, failure) => { resolve = success; reject = failure; });
  return { promise, resolve, reject };
}

const nextTurn = () => new Promise(resolve => setImmediate(resolve));

module.exports = { extractBusinessComponent, extractBusinessService, readComponentSource, deferred, nextTurn, typeScriptVersion: ts.version };
