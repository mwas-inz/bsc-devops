<script setup lang="ts">
import type { User } from '../api/types';
import { avatarGradient, avatarInitial } from '../utils/avatar';

const props = defineProps<{
  user: User;
  selected: boolean;
}>();

const emit = defineEmits<{
  select: [user: User];
  delete: [user: User];
}>();
</script>

<template>
  <div class="user-card" :class="{ selected }" @click="emit('select', user)">
    <div class="avatar" :style="{ background: avatarGradient(user.name) }">
      {{ avatarInitial(user.name) }}
    </div>
    <div class="info">
      <div class="name">{{ user.name }}</div>
      <div class="email">{{ user.email }}</div>
    </div>
    <button class="delete" @click.stop="emit('delete', user)" title="Delete user">✕</button>
  </div>
</template>

<style scoped>
.user-card {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: background 0.15s;
  border-left: 3px solid transparent;
  margin-bottom: 3px;
}
.user-card:hover { background: #1e2d4a; }
.user-card.selected { background: #0f3460; border-left-color: #3b82f6; }
.avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  color: #fff;
  flex-shrink: 0;
}
.info { flex: 1; min-width: 0; }
.name {
  font-size: 12px;
  font-weight: 600;
  color: #e0e0e0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.email {
  font-size: 10px;
  color: #7c9cbf;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.delete {
  background: none;
  border: none;
  color: #ef4444;
  opacity: 0.4;
  cursor: pointer;
  font-size: 11px;
  padding: 2px 4px;
  flex-shrink: 0;
  line-height: 1;
}
.delete:hover { opacity: 1; }
</style>
