import http from 'k6/http';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 }, // ramp up
    { duration: '5m', target: 100 }, // hold
    { duration: '2m', target: 0 },   // ramp down
  ],
};

const BASE_URL = __ENV.BASE_URL;
const RUN_ID = Date.now(); // keeps emails unique across repeated runs

let vuApiKey = null; // cached per VU after first iteration

function setupVuTenant() {
  const tenantRes = http.post(
    `${BASE_URL}/tenants`,
    JSON.stringify({
      name: `load-test-vu-${__VU}`,
      email: `load-test-${RUN_ID}-vu${__VU}@example.com`,
      plan: 'free',
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  check(tenantRes, { 'tenant created': (r) => r.status === 201 });
  const tenantId = tenantRes.json('id');

  const keyRes = http.post(
    `${BASE_URL}/tenants/${tenantId}/keys`,
    JSON.stringify({ label: 'load-test' }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  check(keyRes, { 'key issued': (r) => r.status === 201 });

  return keyRes.json('key');
}

export default function () {
  if (!vuApiKey) {
    vuApiKey = setupVuTenant();
  }

  const res = http.get(`${BASE_URL}/api/data`, {
    headers: { Authorization: `Bearer ${vuApiKey}` },
  });

  check(res, {
    'no server errors': (r) => r.status !== 500,
  });
}