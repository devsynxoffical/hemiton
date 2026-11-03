import { createClient } from 'redis';
import env from './env.js';

let redisClient = null;
let redisFallbackLogged = false;
const memoryStore = new Map();

export function getRedisClient() {
  if (!redisClient) {
    redisClient = createClient({
      url: env.REDIS_URL,
      socket: {
        connectTimeout: 3000,
        reconnectStrategy: (retries) => {
          if (retries >= 2) {
            if (!redisFallbackLogged && env.NODE_ENV !== 'test') {
              redisFallbackLogged = true;
              console.warn(`⚠️ Redis not reachable at ${env.REDIS_URL} — using in-memory fallback.`);
            }
            return false; // Stop infinite reconnect spam when Redis is not running locally
          }
          return Math.min(retries * 500, 2000);
        },
      },
    });

    redisClient.on('error', (err) => {
      // Log only once and handle AggregateError empty message on Windows
      if (env.NODE_ENV !== 'test' && !redisFallbackLogged) {
        const msg = err?.message || err?.code || 'Connection refused';
        console.warn(`⚠️ Redis Connection Notice: ${msg}`);
      }
    });

    redisClient.on('connect', () => {
      redisFallbackLogged = false;
      console.log('🔌 Redis Client Connected');
    });
  }
  return redisClient;
}

export const redisProxy = {
  get isOpen() {
    return Boolean(redisClient && redisClient.isOpen);
  },
  get: async (key) => {
    if (redisClient?.isOpen) return redisClient.get(key);
    const entry = memoryStore.get(key);
    if (!entry) return null;
    if (entry.expiresAt && Date.now() > entry.expiresAt) {
      memoryStore.delete(key);
      return null;
    }
    return entry.value;
  },
  set: async (key, val, opts) => {
    if (redisClient?.isOpen) return redisClient.set(key, val, opts);
    const ttlSeconds = opts?.EX || opts?.ex || null;
    memoryStore.set(key, {
      value: String(val),
      expiresAt: ttlSeconds ? Date.now() + ttlSeconds * 1000 : null,
    });
    return 'OK';
  },
  del: async (key) => {
    if (redisClient?.isOpen) return redisClient.del(key);
    return memoryStore.delete(key) ? 1 : 0;
  },
  incr: async (key) => {
    if (redisClient?.isOpen) return redisClient.incr(key);
    const current = Number((await redisProxy.get(key)) || 0) + 1;
    const existing = memoryStore.get(key);
    memoryStore.set(key, { value: String(current), expiresAt: existing?.expiresAt || null });
    return current;
  },
  expire: async (key, seconds) => {
    if (redisClient?.isOpen) return redisClient.expire(key, seconds);
    const existing = memoryStore.get(key);
    if (!existing) return 0;
    existing.expiresAt = Date.now() + Number(seconds) * 1000;
    return 1;
  },
  ttl: async (key) => {
    if (redisClient?.isOpen) return redisClient.ttl(key);
    const existing = memoryStore.get(key);
    if (!existing || !existing.expiresAt) return -1;
    return Math.max(0, Math.ceil((existing.expiresAt - Date.now()) / 1000));
  },
  ping: async () => {
    if (redisClient?.isOpen) return redisClient.ping();
    return 'PONG_MEMORY';
  },
  duplicate: () => getRedisClient().duplicate(),
  connect: () => getRedisClient().connect(),
  disconnect: () => redisClient?.disconnect(),
  quit: () => redisClient?.quit(),
};

export default redisProxy;
