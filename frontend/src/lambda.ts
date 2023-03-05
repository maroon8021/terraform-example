import next from "next";
import serverlessHttp from "serverless-http";

const app = next({
  dev: false,
});

const handle = app.getRequestHandler();

// ここなんとかしたい
const getErrMessage = (e: any) => ({
  message: "Server failed to respond.",
  details: e,
});

export const handler = serverlessHttp(
  //@ts-ignore
  async (req, res) => {
    await handle(req, res).catch((e) => {
      // Log into Cloudwatch for easier debugging.
      console.error(`NextJS request failed due to:`);
      console.error(e);

      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify(getErrMessage(e), null, 3));
    });
  },
  {
    provider: "aws",
  }
);
