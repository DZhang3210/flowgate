import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '3m',
};

export default function () {
  const res = http.get('http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/health');
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
  sleep(1);
}