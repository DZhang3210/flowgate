import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';

export const options = {
  vus: 50,
  duration: '3m',
};

const BASE_URL = __ENV.BASE_URL;
const API_KEY = __ENV.API_KEY; // must be a free-tier key

const successCount = new Counter('successful_requests');
const rateLimitedCount = new Counter('rate_limited_requests');

export function setup() {
  const msIntoMinute = Date.now() % 60000;
  const msUntilNextMinute = 60000 - msIntoMinute;
  sleep(msUntilNextMinute / 1000);
}

export default function () {
  const res = http.get(`${BASE_URL}/api/data`, {
    headers: { Authorization: `Bearer ${API_KEY}` },
  });

  check(res, {
    'no server errors': (r) => r.status !== 500,
  });

  if (res.status === 200) {
    successCount.add(1);
  } else if (res.status === 429) {
    rateLimitedCount.add(1);
  }
}