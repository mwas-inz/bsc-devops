<script setup lang="ts">
import { ref, onMounted } from 'vue';
import type { User, Task } from './api/types';
import { listUsers, deleteUser } from './api/users';
import { listTasks, completeTask, deleteTask } from './api/tasks';
import AppHeader from './components/AppHeader.vue';
import UserPanel from './components/UserPanel.vue';
import TaskPanel from './components/TaskPanel.vue';

const users = ref<User[]>([]);
const tasks = ref<Task[]>([]);
const selectedUser = ref<User | null>(null);
const userError = ref<string | null>(null);
const taskError = ref<string | null>(null);

async function fetchUsers() {
  try {
    users.value = await listUsers();
    userError.value = null;
  } catch (e) {
    userError.value = (e as Error).message;
  }
}

async function fetchTasks() {
  if (!selectedUser.value) return;
  try {
    tasks.value = await listTasks(selectedUser.value.id);
    taskError.value = null;
  } catch (e) {
    taskError.value = (e as Error).message;
  }
}

async function handleSelectUser(user: User) {
  selectedUser.value = user;
  tasks.value = [];
  await fetchTasks();
}

async function handleDeleteUser(user: User) {
  try {
    await deleteUser(user.id);
    if (selectedUser.value?.id === user.id) {
      selectedUser.value = null;
      tasks.value = [];
    }
    await fetchUsers();
    userError.value = null;
  } catch (e) {
    userError.value = (e as Error).message;
  }
}

async function handleCompleteTask(task: Task) {
  try {
    await completeTask(task.userId, task.id);
    await fetchTasks();
    taskError.value = null;
  } catch (e) {
    taskError.value = (e as Error).message;
  }
}

async function handleDeleteTask(task: Task) {
  try {
    await deleteTask(task.userId, task.id);
    await fetchTasks();
    taskError.value = null;
  } catch (e) {
    taskError.value = (e as Error).message;
  }
}

onMounted(fetchUsers);
</script>

<template>
  <div class="app">
    <AppHeader />
    <div class="body">
      <UserPanel
        :users="users"
        :selected-user="selectedUser"
        :error="userError"
        @select-user="handleSelectUser"
        @delete-user="handleDeleteUser"
        @refresh="fetchUsers"
      />
      <TaskPanel
        :tasks="tasks"
        :selected-user="selectedUser"
        :error="taskError"
        @complete-task="handleCompleteTask"
        @delete-task="handleDeleteTask"
        @refresh="fetchTasks"
      />
    </div>
  </div>
</template>

<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: system-ui, -apple-system, sans-serif;
  background: #1a1a2e;
  color: #e0e0e0;
  height: 100vh;
}
#app { height: 100vh; }
</style>

<style scoped>
.app { height: 100vh; display: flex; flex-direction: column; }
.body { flex: 1; display: flex; overflow: hidden; }
</style>
