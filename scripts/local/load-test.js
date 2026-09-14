// Usage: see scripts/local/measure-resources.sh (runs this file in the grafana/k6 container).
//
// Load profile used for the resource-usage analysis in the thesis (Operate stage).
// Each iteration walks the full request path of the system:
//   Traefik -> tasks (PostgreSQL) -> PATCH -> DELETE -> Pulsar -> task-archiver.
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE = __ENV.BASE_URL || 'http://localhost';
const USERS = 10;
const JSON_HEADERS = { headers: { 'Content-Type': 'application/json' } };

export const options = {
    stages: [
        { duration: '1m', target: 50 },
        { duration: '3m', target: 50 },
        { duration: '30s', target: 0 },
    ],
    thresholds: {
        http_req_failed: ['rate<0.01'],
    },
};

export function setup() {
    const ids = [];
    for (let i = 0; i < USERS; i++) {
        const res = http.post(`${BASE}/api/users`,
            JSON.stringify({ name: `load-${i}`, email: `load-${i}@example.com` }), JSON_HEADERS);
        ids.push(res.json('id'));
    }
    // tasks learns about users asynchronously from the user-events topic (Pulsar).
    sleep(5);
    return { ids };
}

export default function (data) {
    const userId = data.ids[__VU % data.ids.length];
    const tasks = `${BASE}/api/tasks/users/${userId}/tasks`;

    // Group URLs containing IDs under one metric name — keeps k6's own time series bounded.
    const tagged = (name) => ({ ...JSON_HEADERS, tags: { name } });

    const created = http.post(tasks,
        JSON.stringify({ title: `task-${__ITER}`, content: 'load test' }), tagged('POST tasks'));
    check(created, { 'task created': (r) => r.status === 200 });
    const taskId = created.json('id');

    check(http.get(tasks, tagged('GET tasks')), { 'tasks listed': (r) => r.status === 200 });
    check(http.patch(`${tasks}/${taskId}`, JSON.stringify({ status: 'done' }), tagged('PATCH task')),
        { 'task closed': (r) => r.status === 200 });
    check(http.del(`${tasks}/${taskId}`, null, tagged('DELETE task')),
        { 'deletion scheduled': (r) => r.status === 200 });

    sleep(0.2);
}

export function teardown(data) {
    data.ids.forEach((id) => http.del(`${BASE}/api/users/${id}`));
}
