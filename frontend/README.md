# next-ssr/frontend

## memo

```
2022-12-12T23:09:00.303Z	undefined	ERROR	Uncaught Exception 	{
    "errorType": "Runtime.ImportModuleError",
    "errorMessage": "Error: Cannot find module 'styled-jsx'\nRequire stack:\n- /var/task/node_modules/next/dist/build/webpack/require-hook.js\n- /var/task/node_modules/next/dist/server/initialize-require-hook.js\n- /var/task/node_modules/next/dist/server/next-server.js\n- /var/task/lambda.js\n- /var/runtime/index.mjs",
    "stack": [
        "Runtime.ImportModuleError: Error: Cannot find module 'styled-jsx'",
        "Require stack:",
        "- /var/task/node_modules/next/dist/build/webpack/require-hook.js",
        "- /var/task/node_modules/next/dist/server/initialize-require-hook.js",
        "- /var/task/node_modules/next/dist/server/next-server.js",
        "- /var/task/lambda.js",
        "- /var/runtime/index.mjs",
        "    at _loadUserApp (file:///var/runtime/index.mjs:1000:17)",
        "    at async Object.UserFunction.js.module.exports.load (file:///var/runtime/index.mjs:1035:21)",
        "    at async start (file:///var/runtime/index.mjs:1200:23)",
        "    at async file:///var/runtime/index.mjs:1206:1"
    ]
}

```

-> 一旦 `styled-jsx` 入れてみるか。。。
