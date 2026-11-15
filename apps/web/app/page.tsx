'use client';
import { useState, useEffect } from 'react';

export default function Home() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch('/api/health').then(r => r.json()).then(setData).catch(e => setError(e.message)).finally(() => setLoading(false));
  }, []);

  const services = [
    { title: 'Frontend', desc: 'Next.js on Cloudflare Pages', status: 'Unlimited bandwidth' },
    { title: 'Backend API', desc: 'Hono on Cloudflare Workers', status: '100k req/day free' },
    { title: 'Database', desc: 'Supabase (PostgreSQL)', status: '500MB + 1TB egress' },
    { title: 'Storage', desc: 'Cloudflare R2', status: '10GB + free egress' },
    { title: 'CI/CD', desc: 'GitHub Actions', status: '2000 min/mo (self-hosted = unlimited)' },
    { title: 'Compute', desc: 'Oracle Arm VM', status: '4 OCPU + 24GB RAM' }
  ];

  return (
    <main className="max-w-3xl mx-auto space-y-6">
      <header>
        <h1 className="text-3xl font-bold text-gray-900">Free Cloud Stack</h1>
        <p className="text-gray-600 mt-2">Cloudflare Pages + Workers + Supabase + R2 + Oracle VM</p>
      </header>

      <section className="grid gap-4 md:grid-cols-2">
        {services.map((item, i) => (
          <div key={i} className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
            <h3 className="font-semibold text-lg">{item.title}</h3>
            <p className="text-gray-500 text-sm mt-1">{item.desc}</p>
            <span className="inline-block mt-3 text-sm text-green-700 bg-green-50 px-3 py-1 rounded">{item.status}</span>
          </div>
        ))}
      </section>

      <section className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
        <h2 className="font-semibold text-xl mb-4">API Health Check</h2>
        {loading && <p>Checking...</p>}
        {error && <p className="text-red-600">Error: {error}</p>}
        {data && !loading && (
          <pre className="bg-gray-100 p-4 rounded overflow-auto text-sm">{JSON.stringify(data, null, 2)}</pre>
        )}
      </section>

      <footer className="text-center text-sm text-gray-500">
        <p>Built on Free Tier only - Zero monthly cost</p>
      </footer>
    </main>
  );
}