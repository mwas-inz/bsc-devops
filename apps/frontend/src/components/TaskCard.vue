<script setup lang="ts">
import type { Task } from '../api/types';

const props = defineProps<{ task: Task }>();

const emit = defineEmits<{
  complete: [task: Task];
  delete: [task: Task];
}>();
</script>

<template>
  <div class="task-card" :class="task.status">
    <div class="body">
      <div class="title-row">
        <span class="badge" :class="task.status">{{ task.status }}</span>
        <span class="title">{{ task.title }}</span>
      </div>
      <div v-if="task.content" class="content">{{ task.content }}</div>
    </div>
    <div class="actions">
      <button v-if="task.status === 'created'" class="done" @click="emit('complete', task)">
        ✓ Done
      </button>
      <button class="delete" @click="emit('delete', task)" title="Delete task">✕</button>
    </div>
  </div>
</template>

<style scoped>
.task-card {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  background: #16213e;
  border-radius: 4px;
  padding: 8px 10px;
  margin-bottom: 5px;
}
.task-card.done { opacity: 0.55; }
.body { flex: 1; }
.title-row {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 3px;
}
.badge {
  padding: 1px 7px;
  border-radius: 10px;
  font-size: 8px;
  font-weight: 700;
  flex-shrink: 0;
}
.badge.created { background: #f59e0b; color: #000; }
.badge.done { background: #166534; color: #4ade80; }
.title { font-size: 12px; font-weight: 600; color: #e0e0e0; }
.task-card.done .title { text-decoration: line-through; color: #888; }
.content { font-size: 10px; color: #666; }
.actions { display: flex; flex-direction: column; gap: 4px; flex-shrink: 0; }
.done {
  background: #166534;
  color: #4ade80;
  border: none;
  border-radius: 4px;
  padding: 2px 8px;
  font-size: 10px;
  cursor: pointer;
  white-space: nowrap;
}
.delete {
  background: none;
  border: none;
  color: #ef4444;
  opacity: 0.4;
  cursor: pointer;
  font-size: 11px;
  padding: 2px 4px;
  line-height: 1;
}
.delete:hover { opacity: 1; }
</style>
