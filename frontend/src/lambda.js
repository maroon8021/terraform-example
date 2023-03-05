process.chdir(__dirname);

const serverlessHttp = require("serverless-http");
const NextServer = require("next/dist/server/next-server").default;
const path = require("path");

const app = new NextServer({
  dev: false,
  dir: path.join(__dirname),
  conf: {
    distDir: "./.next",
    amp: { canonicalBase: "" },
    publicRuntimeConfig: {},
    experimental: {
      appDir: false,
    },
  },
});

const handle = app.getRequestHandler();

// ここなんとかしたい
const getErrMessage = (e) => ({
  message: "Server failed to respond.",
  details: e,
});

exports.handler = serverlessHttp(
  async (req, res) => {
    try {
      await handle(req, res);
    } catch (error) {
      // Log into Cloudwatch for easier debugging.
      console.error(`NextJS request failed due to:`);
      console.error(error);

      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify(getErrMessage(error), null, 3));
    }
  },
  {
    provider: "aws",
  }
);
