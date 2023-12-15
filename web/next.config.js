/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    NEXTAUTH_URL: "http://localhost:3000",
    NEXTAUTH_SECRET: "nextauth-secret",
  },
  output: "standalone",
};

module.exports = nextConfig;
