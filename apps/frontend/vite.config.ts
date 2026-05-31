import { defineConfig } from 'vite';
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
        target: 'http://localhost:8081',
        rewrite: (path) => path.replace(/^\/api\/tasks/, ''),
      },
      '/health/users': {
        target: 'http://localhost:8080',
        rewrite: () => '/q/health',
      },
      '/health/tasks': {
        target: 'http://localhost:8081',
        rewrite: () => '/q/health',
      },
    },
  },
  test: {
    environment: 'happy-dom',
  },
});
