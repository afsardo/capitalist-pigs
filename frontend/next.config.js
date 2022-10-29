/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  // TEMP: Arweave deployment requires assetPrefix: '.'
  // assetPrefix: './'
};

module.exports = nextConfig;
