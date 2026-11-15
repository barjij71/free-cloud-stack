import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { SupabaseClient, createClient } from '@supabase/supabase-js';

type Bindings = {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  R2_BUCKET: R2Bucket;
  KV: KVNamespace;
};

const app = new Hono<{ Bindings: Bindings }>();
app.use('*', cors());

// Health check
app.get('/health', (c) => c.json({ 
  status: 'ok', 
  timestamp: new Date().toISOString(),
  services: { worker: 'up' }
}));

// Supabase test
app.get('/api/db/test', async (c) => {
  const supabase = createClient(c.env.SUPABASE_URL, c.env.SUPABASE_ANON_KEY);
  const { data, error } = await supabase.from('health_check').select('*').limit(1);
  if (error) return c.json({ error: error.message }, 500);
  return c.json({ data, supabase: 'connected' });
});

// R2 upload (public URL pattern - for presigned URLs use @aws-sdk/s3-request-presigner)
app.post('/api/upload/presign', async (c) => {
  const { key, contentType } = await c.req.json();
  const accountId = c.env.CLOUDFLARE_ACCOUNT_ID || 'your-account-id';
  const url = `https://${accountId}.r2.cloudflarestorage.com/free-cloud-assets/${key}`;
  return c.json({ uploadUrl: url, key, method: 'PUT', note: 'Use AWS SDK for real presigned URLs' });
});

// R2 download (public URL pattern)
app.get('/api/download/presign', async (c) => {
  const key = c.req.query('key');
  if (!key) return c.json({ error: 'key required' }, 400);
  const accountId = c.env.CLOUDFLARE_ACCOUNT_ID || 'your-account-id';
  const url = `https://${accountId}.r2.cloudflarestorage.com/free-cloud-assets/${key}`;
  return c.json({ downloadUrl: url });
});

// KV cache example
app.get('/api/cache/:key', async (c) => {
  const key = c.req.param('key');
  const value = await c.env.KV.get(key);
  if (!value) return c.json({ error: 'not found' }, 404);
  return c.json({ key, value });
});

app.post('/api/cache/:key', async (c) => {
  const key = c.req.param('key');
  const { value, ttl } = await c.req.json();
  await c.env.KV.put(key, JSON.stringify(value), { expirationTtl: ttl || 3600 });
  return c.json({ success: true });
});

export default app;