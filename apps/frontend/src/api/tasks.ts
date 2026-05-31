import type { Task } from './types';

export async function listTasks(userId: number): Promise<Task[]> {
  const res = await fetch(`/api/tasks/users/${userId}/tasks`);
  if (!res.ok) throw new Error(`Failed to list tasks: ${res.status}`);
  return res.json();
}

export async function createTask(userId: number, title: string, content: string): Promise<Task> {
  const res = await fetch(`/api/tasks/users/${userId}/tasks`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title, content }),
  });
  if (!res.ok) throw new Error(`Failed to create task: ${res.status}`);
  return res.json();
}

export async function completeTask(userId: number, taskId: number): Promise<Task> {
  const res = await fetch(`/api/tasks/users/${userId}/tasks/${taskId}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ status: 'done' }),
  });
  if (!res.ok) throw new Error(`Failed to complete task: ${res.status}`);
  return res.json();
}

export async function deleteTask(userId: number, taskId: number): Promise<void> {
  const res = await fetch(`/api/tasks/users/${userId}/tasks/${taskId}`, { method: 'DELETE' });
  if (!res.ok) throw new Error(`Failed to delete task: ${res.status}`);
}
