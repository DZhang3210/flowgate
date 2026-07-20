#!/bin/bash
source ./tests/load/.env.local   # not tracked in git

# k6 run -e BASE_URL=$BASE_URL -e API_KEY=$API_KEY tests/load/k6_smoke_test.js

k6 run -e BASE_URL=$BASE_URL -e API_KEY=$API_KEY tests/load/k6_correctness_test.js

# k6 run -e BASE_URL=$BASE_URL -e API_KEY=$API_KEY tests/load/k6_load_test.js --summary-trend-stats "avg,min,med,max,p(90),p(95),p(99)"

# k6 run -e BASE_URL=$BASE_URL -e API_KEY=$API_KEY tests/load/k6_stress_test.js

# k6 run -e BASE_URL=$BASE_URL -e API_KEY=$API_KEY tests/load/k6_soak_test.js #10:05 PM