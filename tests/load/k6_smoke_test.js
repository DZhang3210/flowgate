
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 5,
  duration: '1m',
};

const BASE_URL = __ENV.BASE_URL; // your ALB DNS name
const API_KEY = __ENV.API_KEY;   // a valid, active key

export default function () {
  const res = http.get(`${BASE_URL}/api/data`, {
    headers: { Authorization: `Bearer ${API_KEY}` },
  });

  check(res, {
    'status is 200 or 429': (r) => r.status === 200 || r.status === 429,
  });
}