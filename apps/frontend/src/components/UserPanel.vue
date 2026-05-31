<script setup lang="ts">
import { ref } from 'vue';
import type { User } from '../api/types';
import { createUser } from '../api/users';
import UserCard from './UserCard.vue';

const props = defineProps<{
  users: User[];
  selectedUser: User | null;
  error: string | null;
}>();

const emit = defineEmits<{
  selectUser: [user: User];
  deleteUser: [user: User];
  refresh: [];
}>();

const name = ref('');
const email = ref('');
const creating = ref(false);
const createError = ref<string | null>(null);

async function handleCreate() {
  if (!name.value.trim() || !email.value.trim()) return;
  creating.value = true;
  createError.value = null;
  try {
    await createUser(name.value.trim(), email.value.trim());
    name.value = '';
    email.value = '';
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
      <div class="label">USERS</div>
      <UserCard
        v-for="user in users"
        :key="user.id"
        :user="user"
        :selected="selectedUser?.id === user.id"
        @select="emit('selectUser', $event)"
        @delete="emit('deleteUser', $event)"
      />
    </div>
    <div class="form-area">
      <p v-if="error" class="error">{{ error }}</p>
      <p v-if="createError" class="error">{{ createError }}</p>
      <div class="form-label">NEW USER</div>
      <input v-model="name" placeholder="Name" @keyup.enter="handleCreate" />
      <input v-model="email" placeholder="Email" @keyup.enter="handleCreate" />
      <button :disabled="creating" @click="handleCreate">
        {{ creating ? 'Creating…' : 'Create User' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.panel {
  width: 200px;
  flex-shrink: 0;
  border-right: 1px solid #2a2a3e;
  background: #16213e;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.list {
  flex: 1;
  overflow-y: auto;
  padding: 12px 10px 0;
}
.label {
  font-size: 9px;
  color: #7c9cbf;
  letter-spacing: 1px;
  margin-bottom: 8px;
}
.form-area {
  border-top: 1px solid #2a2a3e;
  padding: 10px;
  background: #12192e;
  display: flex;
  flex-direction: column;
  gap: 5px;
}
.form-label {
  font-size: 9px;
  color: #7c9cbf;
  letter-spacing: 1px;
}
.error { font-size: 10px; color: #ef4444; }
input {
  background: #1e2d4a;
  border: 1px solid #2a3a5e;
  border-radius: 4px;
  padding: 5px 8px;
  font-size: 11px;
  color: #e0e0e0;
  outline: none;
}
input:focus { border-color: #3b82f6; }
button {
  background: #3b82f6;
  border: none;
  border-radius: 4px;
  padding: 5px;
  font-size: 11px;
  color: #fff;
  font-weight: 600;
  cursor: pointer;
  margin-top: 2px;
}
button:disabled { opacity: 0.5; cursor: default; }
</style>
