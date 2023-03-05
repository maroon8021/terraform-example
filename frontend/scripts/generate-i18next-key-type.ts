#!/usr/bin/env ts-node

import * as fs from "fs";

type Json = {
  [key in string]: string;
};

const main = async () => {
  const data = require("../public/locales/ja/common.json") as Json;

  const exportDeclaration = `export type TranslationKeys =`;
  const fileData = Object.keys(data).map((key, index) => {
    if (index === 0) {
      return `${exportDeclaration} "${key}"`;
    }
    return `  | "${key}"`;
  });

  fs.writeFileSync("./@types/translation-keys.ts", fileData.join("\n"));
};

main();
