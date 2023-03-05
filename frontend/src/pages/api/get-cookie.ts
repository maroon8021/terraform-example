// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from "next";
import { NextResponse } from "next/server";

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<any>
) {
  const response = NextResponse.next();
  response.cookies.set("nextcookie", "nextcookieisin");
  res
    .status(200)
    .json({
      data: "cookie is set",
      cookieOnRequest: `${req.cookies.nextcookie}`,
    });
}
