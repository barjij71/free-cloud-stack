/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: { unoptimized: true },
  experimental: { serverActions: { bodySizeLimit: '2mb' } },
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'https://barjij71.workers.dev/api/:path*',
      },
    ];
  },
};

const withNextOnPages = require('@cloudflare/next-on-pages');
module.exports = withNextOnPages(nextConfig);