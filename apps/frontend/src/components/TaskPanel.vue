<script setup lang="ts">
import { ref } from 'vue';
import type { Task, User } from '../api/types';
import { createTask } from '../api/tasks';
import TaskCard from './TaskCard.vue';

const props = defineProps<{
  tasks: Task[];
  selectedUser: User | null;
  error: string | null;
}>();

const emit = defineEmits<{
  completeTask: [task: Task];
  deleteTask: [task: Task];
  refresh: [];
}>();

const title = ref('');
const content = ref('');
const creating = ref(false);
const createError = ref<string | null>(null);

async function handleCreate() {
  if (!props.selectedUser || !title.value.trim()) return;
  creating.value = true;
  createError.value = null;
  try {
    await createTask(props.selectedUser.id, title.value.trim(), content.value.trim());
    title.value = '';
    content.value = '';
    emit('refresh');
  } catch (e) {
    createError.value = (e as Error).message;
  } finally {
    creating.value = false;
  }
}
</script>

<template>
  <div class="panel">
    <div class="list">
      <div class="label">
        {{ selectedUser ? `TASKS — ${selectedUser.name}` : 'TASKS' }}
      </div>
      <div v-if="!selectedUser" class="empty">← Select a user to view their tasks</div>
      <TaskCard
        v-for="task in tasks"
        :key="task.id"
        :task="task"
        @complete="emit('completeTask', $event)"
        @delete="emit('deleteTask', $event)"
      />
    </div>
    <div class="form-area">
      <p v-if="error" class="error">{{ error }}</p>
      <p v-if="createError" class="error">{{ createError }}</p>
      <template v-if="selectedUser">
        <div class="form-label">NEW TASK FOR {{ selectedUser.name.toUpperCase() }}</div>
        <div class="form-row">
          <div class="inputs">
            <input v-model="title" placeholder="Title" @keyup.enter="handleCreate" />
            <input v-model="content" placeholder="Content (optional)" />
          </div>
          <button :disabled="creating" @click="handleCreate">
            {{ creating ? '…' : 'Create' }}
          </button>
        </div>
      </template>
      <div v-else class="form-label muted">Select a user first</div>
    </div>
  </div>
</template>

<style scoped>
.panel {
  flex: 1;
  background: #1a1a2e;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.list {
  flex: 1;
  overflow-y: auto;
  padding: 12px 12px 0;
}
.label {
  font-size: 9px;
  color: #7c9cbf;
  letter-spacing: 1px;
  margin-bottom: 8px;
}
.empty { font-size: 11px; color: #444; font-style: italic; }
.form-area {
  border-top: 1px solid #2a2a3e;
  padding: 10px 12px;
  background: #141420;
}
.form-label {
  font-size: 9px;
  color: #7c9cbf;
  letter-spacing: 1px;
  margin-bottom: 6px;
}
.form-label.muted { color: #444; }
.error { font-size: 10px; color: #ef4444; margin-bottom: 4px; }
.form-row { display: flex; gap: 6px; align-items: flex-start; }
.inputs { flex: 1; display: flex; flex-direction: column; gap: 4px; }
input {
  background: #1e2d4a;
  border: 1px solid #2a3a5e;
  border-radius: 4px;
  padding: 5px 8px;
  font-size: 11px;
  color: #e0e0e0;
  outline: none;
  width: 100%;
}
input:focus { border-color: #3b82f6; }
button {
  background: #3b82f6;
  border: none;
  border-radius: 4px;
  padding: 5px 10px;
  font-size: 11px;
  color: #fff;
  font-weight: 600;
  cursor: pointer;
  align-self: stretch;
  white-space: nowrap;
}
button:disabled { opacity: 0.4; cursor: default; }
</style>
