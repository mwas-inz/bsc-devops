import { describe, it, expect, vi, beforeEach } from 'vitest';
import { listTasks, createTask, completeTask, deleteTask } from './tasks';

const mockFetch = vi.fn();
vi.stubGlobal('fetch', mockFetch);

function ok(body: unknown) {
  return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(body) });
}
function err() {
  return Promise.resolve({ ok: false, status: 500, json: () => Promise.resolve(null) });
}

beforeEach(() => mockFetch.mockReset());

const task = {
  id: 5, userId: 1, title: 'T', content: 'C',
  status: 'created' as const, createdAt: '', completedAt: null,
};

describe('listTasks', () => {
  it('calls GET /api/tasks/users/:userId/tasks', async () => {
    mockFetch.mockReturnValue(ok([task]));
    const result = await listTasks(1);
    expect(mockFetch).toHaveBeenCalledWith('/api/tasks/users/1/tasks');
    expect(result).toEqual([task]);
  });

  it('throws on non-ok response', async () => {
    mockFetch.mockReturnValue(err());
    await expect(listTasks(1)).rejects.toThrow('Failed to list tasks');
  });
});

describe('createTask', () => {
  it('calls POST /api/tasks/users/:userId/tasks with title and content', async () => {
    mockFetch.mockReturnValue(ok(task));
    const result = await createTask(1, 'T', 'C');
    expect(mockFetch).toHaveBeenCalledWith('/api/tasks/users/1/tasks', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: 'T', content: 'C' }),
    });
    expect(result).toEqual(task);
  });

  it('throws on non-ok response', async () => {
    mockFetch.mockReturnValue(err());
    await expect(createTask(1, 'T', 'C')).rejects.toThrow('Failed to create task');
  });
});

describe('completeTask', () => {
  it('calls PATCH /api/tasks/users/:userId/tasks/:taskId with status done', async () => {
    const done = { ...task, status: 'done' as const, completedAt: '2024-01-01' };
    mockFetch.mockReturnValue(ok(done));
    const result = await completeTask(1, 5);
    expect(mockFetch).toHaveBeenCalledWith('/api/tasks/users/1/tasks/5', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: 'done' }),
    });
    expect(result).toEqual(done);
  });

  it('throws on non-ok response', async () => {
    mockFetch.mockReturnValue(err());
    await expect(completeTask(1, 5)).rejects.toThrow('Failed to complete task');
  });
});

describe('deleteTask', () => {
  it('calls DELETE /api/tasks/users/:userId/tasks/:taskId', async () => {
    mockFetch.mockReturnValue(ok(null));
    await deleteTask(1, 5);
    expect(mockFetch).toHaveBeenCalledWith('/api/tasks/users/1/tasks/5', { method: 'DELETE' });
  });

  it('throws on non-ok response', async () => {
    mockFetch.mockReturnValue(err());
    await expect(deleteTask(1, 5)).rejects.toThrow('Failed to delete task');
  });
});
