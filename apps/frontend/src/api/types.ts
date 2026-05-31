export interface User {
  id: number;
  name: string;
  email: string;
}

export type TaskStatus = 'created' | 'done';

export interface Task {
  id: number;
  userId: number;
  title: string;
  content: string;
  status: TaskStatus;
  createdAt: string;
  completedAt: string | null;
}
