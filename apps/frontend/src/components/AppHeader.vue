<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';

const usersStatus = ref<'ok' | 'error'>('ok');
const tasksStatus = ref<'ok' | 'error'>('ok');

async function checkHealth(url: string): Promise<'ok' | 'error'> {
  try {
    const res = await fetch(url);
    return res.ok ? 'ok' : 'error';
  } catch {
    return 'error';
  }
}

async function pollHealth() {
  [usersStatus.value, tasksStatus.value] = await Promise.all([
    checkHealth('/health/users'),
    checkHealth('/health/tasks'),
  ]);
}

let interval: ReturnType<typeof setInterval>;

onMounted(() => {
  pollHealth();
  interval = setInterval(pollHealth, 10_000);
});

onUnmounted(() => clearInterval(interval));
</script>

<template>
  <header>
    <span class="title">■ DevOps Demo</span>
    <div class="health">
      <span :class="['dot', usersStatus]">● users :8080</span>
      <span :class="['dot', tasksStatus]">● tasks :8081</span>
    </div>
  </header>
</template>

<style scoped>
header {
  background: #0f3460;
  padding: 8px 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid #1a4a8a;
  flex-shrink: 0;
}
.title { font-weight: bold; font-size: 14px; color: #e0e0e0; }
.health { display: flex; gap: 16px; font-size: 11px; }
.dot.ok { color: #2ecc71; }
.dot.error { color: #ef4444; }
</style>
