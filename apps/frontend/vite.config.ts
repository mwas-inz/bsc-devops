import { defineConfig } from 'vitest/config';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      '/api/users': {
        target: 'http://localhost:8080',
        rewrite: (path) => path.replace(/^\/api\/users/, '/users'),
      },
      '/api/tasks': {
        target: 'http://localhost:8080',
        rewrite: (path) => path.replace(/^\/api\/tasks/, ''),
      },
      '/health/users': {
        target: 'http://localhost:8080',
        rewrite: () => '/q/health/live',
      },
      '/health/tasks': {
        target: 'http://localhost:8080',
        rewrite: () => '/q/health/live',
      },
    },
  },
  test: {
    environment: 'happy-dom',
  },
});
