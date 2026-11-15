export const metadata = { title: 'Free Cloud Stack', description: 'Deployed on Cloudflare Pages + Workers + Supabase + R2' };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (<html lang="ar" dir="rtl"><body className="min-h-screen bg-gray-50 p-8">{children}</body></html>);
}