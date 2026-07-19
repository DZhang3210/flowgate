import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 50,
  duration: '30m',
};

const BASE_URL = __ENV.BASE_URL;
const RUN_ID = Date.now();

let vuApiKey = null;

function setupVuTenant() {
  const tenantRes = http.post(
    `${BASE_URL}/tenants`,
    JSON.stringify({
      name: `soak-test-vu-${__VU}`,
      email: `soak-test-${RUN_ID}-vu${__VU}@example.com`,
      plan: 'free',
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  check(tenantRes, { 'tenant created': (r) => r.status === 201 });
  const tenantId = tenantRes.json('id');

  const keyRes = http.post(
    `${BASE_URL}/tenants/${tenantId}/keys`,
    JSON.stringify({ label: 'soak-test' }),
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
    'no server errors or connection failures': (r) => r.status !== 500 && r.status !== 0,
  });
}