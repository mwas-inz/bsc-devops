import { describe, it, expect, vi, beforeEach } from 'vitest';
import { listUsers, createUser, deleteUser } from './users';

const mockFetch = vi.fn();
vi.stubGlobal('fetch', mockFetch);

function ok(body: unknown) {
  return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(body) });
}
function err() {
  return Promise.resolve({ ok: false, status: 500, json: () => Promise.resolve(null) });
}

beforeEach(() => mockFetch.mockReset());

describe('listUsers', () => {
  it('calls GET /api/users and returns parsed body', async () => {
    const users = [{ id: 1, name: 'Alice', email: 'alice@example.com' }];
    mockFetch.mockReturnValue(ok(users));
    const result = await listUsers();
    expect(mockFetch).toHaveBeenCalledWith('/api/users');
    expect(result).toEqual(users);
  });

  it('throws on non-ok response', async () => {
    mockFetch.mockReturnValue(err());
    await expect(listUsers()).rejects.toThrow('Failed to list users');
  });
});

describe('createUser', () => {
  it('calls POST /api/users with name and email JSON body', async () => {
    const user = { id: 2, name: 'Bob', email: 'bob@example.com' };
    mockFetch.mockReturnValue(ok(user));
    const result = await createUser('Bob', 'bob@example.com');
    expect(mockFetch).toHaveBeenCalledWith('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'Bob', email: 'bob@example.com' }),
    });
    expect(result).toEqual(user);
  });

  it('throws on non-ok response', async () => {
    mockFetch.mockReturnValue(err());
    await expect(createUser('Bob', 'bob@example.com')).rejects.toThrow('Failed to create user');
  });
});

describe('deleteUser', () => {
  it('calls DELETE /api/users/:id', async () => {
    mockFetch.mockReturnValue(ok(null));
    await deleteUser(1);
    expect(mockFetch).toHaveBeenCalledWith('/api/users/1', { method: 'DELETE' });
  });

  it('throws on non-ok response', async () => {
    mockFetch.mockReturnValue(err());
    await expect(deleteUser(1)).rejects.toThrow('Failed to delete user');
  });
});
