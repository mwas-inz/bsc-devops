const GRADIENTS: [string, string][] = [
  ['#3b82f6', '#6366f1'],
  ['#10b981', '#059669'],
  ['#f59e0b', '#ef4444'],
  ['#8b5cf6', '#6366f1'],
  ['#ec4899', '#f43f5e'],
];

export function avatarGradient(name: string): string {
  const idx = name.charCodeAt(0) % GRADIENTS.length;
  const [from, to] = GRADIENTS[idx];
  return `linear-gradient(135deg, ${from}, ${to})`;
}

export function avatarInitial(name: string): string {
  return name.charAt(0).toUpperCase();
}
