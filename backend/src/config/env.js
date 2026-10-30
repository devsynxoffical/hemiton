import dotenv from 'dotenv';
import { z } from 'zod';

// Load environment variables
dotenv.config();

// Normalize empty strings to undefined so Zod .default() values apply cleanly on Railway/Docker
const sanitizedProcessEnv = Object.fromEntries(
  Object.entries(process.env).map(([key, val]) => [
    key,
    typeof val === 'string' && val.trim() === '' ? undefined : val,
  ])
);

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('production').catch('production'),
  PORT: z.coerce.number().positive().default(8080).catch(8080),
  DATABASE_URL: z.string().default(
    sanitizedProcessEnv.DATABASE_URL ||
    sanitizedProcessEnv.DATABASE_PUBLIC_URL ||
    'postgresql://postgres:postgres@localhost:5432/hemiton'
  ),
  PRISMA_LOG_QUERIES: z.preprocess((val) => {
    if (typeof val === 'string') return val.toLowerCase() === 'true' || val === '1';
    return Boolean(val);
  }, z.boolean()).default(false).catch(false),
  REDIS_URL: z.string().default(
    sanitizedProcessEnv.REDIS_URL ||
    sanitizedProcessEnv.REDIS_PUBLIC_URL ||
    'redis://localhost:6379'
  ),

  // Public Domain & CORS
  CORS_ORIGIN: z.string().default('http://localhost:5173,http://localhost:5174,https://hemi-ton-backend-production.up.railway.app,https://hemiton.live,https://admin.hemiton.live,*'),
  SOCKET_CORS_ORIGIN: z.string().default('http://localhost:5173,http://localhost:5174,https://hemi-ton-backend-production.up.railway.app,https://hemiton.live,https://admin.hemiton.live,*'),
  PUBLIC_API_URL: z.string().default(
    sanitizedProcessEnv.PUBLIC_API_URL ||
    (sanitizedProcessEnv.RAILWAY_PUBLIC_DOMAIN ? `https://${sanitizedProcessEnv.RAILWAY_PUBLIC_DOMAIN}` : 'https://hemi-ton-backend-production.up.railway.app')
  ),

  // Authentication & Security
  JWT_SECRET: z.string().min(16).default('super-secret-hemiton-jwt-key-change-in-prod-2026').catch('super-secret-hemiton-jwt-key-change-in-prod-2026'),
  JWT_EXPIRES_IN: z.string().default('15m').catch('15m'),
  REFRESH_TOKEN_EXPIRES_IN: z.string().default('7d').catch('7d'),

  // OTP & Communications
  OTP_PROVIDER: z.enum(['mock', 'twilio', 'aws_sns']).default('mock').catch('mock'),
  OTP_EXPIRY_SECONDS: z.coerce.number().default(300).catch(300),
  OTP_MAX_ATTEMPTS: z.coerce.number().default(5).catch(5),
  OTP_RATE_LIMIT_MAX: z.coerce.number().default(5).catch(5),

  // Cryptography & Financial
  PAYMENT_ENCRYPTION_KEY: z.string().min(16).default('hemiton-payment-encryption-master-key-32b!').catch('hemiton-payment-encryption-master-key-32b!'),
  OTP_ENCRYPTION_KEY: z.string().min(16).default('hemiton-otp-encryption-master-key-32b!').catch('hemiton-otp-encryption-master-key-32b!'),

  // Agora Realtime Streaming & Calling
  AGORA_APP_ID: z.string().default('mock_agora_app_id_test_environment_12345').catch('mock_agora_app_id_test_environment_12345'),
  AGORA_APP_CERTIFICATE: z.string().default('mock_agora_app_cert_test_environment_67890').catch('mock_agora_app_cert_test_environment_67890'),
  AGORA_TOKEN_EXPIRY_SECONDS: z.coerce.number().min(60).max(86400).default(3600).catch(3600),
  AGORA_MOCK_MODE: z.coerce.boolean().default(false).catch(false),

  // Socket.IO & Redis Adapter
  SOCKET_REDIS_ENABLED: z.coerce.boolean().default(true).catch(true),

  // Bootstrap Administrative Credentials
  SUPER_ADMIN_USERNAME: z.string().default('admin').catch('admin'),
  SUPER_ADMIN_EMAIL: z.string().email().default('admin@hemiton.live').catch('admin@hemiton.live'),
  SUPER_ADMIN_PASSWORD: z.string().min(6).default('admin12345').catch('admin12345'),
  OWNER_EMAIL: z.string().email().default('owner@hemiton.live').catch('owner@hemiton.live'),
  OWNER_PASSWORD: z.string().min(6).default('owner12345').catch('owner12345'),
});

const _env = envSchema.safeParse(sanitizedProcessEnv);

if (!_env.success) {
  console.error('❌ Invalid environment configuration:');
  console.error(JSON.stringify(_env.error.format(), null, 2));
  process.exit(1);
}

export const env = _env.data;
export default env;
