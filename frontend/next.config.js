/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  output: "standalone",
  generateBuildId: async () => {
    return process.env.BUILD_ID;
  },
};

module.exports = nextConfig;
