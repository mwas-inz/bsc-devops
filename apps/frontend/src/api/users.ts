import type { User } from './types';

export async function listUsers(): Promise<User[]> {
  const res = await fetch('/api/users');
  if (!res.ok) throw new Error(`Failed to list users: ${res.status}`);
  return res.json();
}

export async function createUser(name: string, email: string): Promise<User> {
  const res = await fetch('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name, email }),
  });
  if (!res.ok) throw new Error(`Failed to create user: ${res.status}`);
  return res.json();
}

export async function deleteUser(id: number): Promise<void> {
  const res = await fetch(`/api/users/${id}`, { method: 'DELETE' });
  if (!res.ok) throw new Error(`Failed to delete user: ${res.status}`);
}
