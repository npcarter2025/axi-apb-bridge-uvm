#!/bin/bash
# Run all 4 pipeline configurations

echo "============================================================================"
echo "Testing All Pipeline Configurations"
echo "============================================================================"
echo ""

PASSED=0
FAILED=0

# Test configuration 1: PIPE_REQ=0 PIPE_RESP=0
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1/4: PIPE_REQ=0 PIPE_RESP=0 (No pipelining)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
make clean > /dev/null 2>&1
if make PIPE_REQ=0 PIPE_RESP=0 2>&1 | tee sim_pipe00.log | tail -5 | grep -q "Simulation PASSED"; then
    echo "✅ PASSED: PIPE_REQ=0 PIPE_RESP=0"
    ((PASSED++))
else
    echo "❌ FAILED: PIPE_REQ=0 PIPE_RESP=0"
    ((FAILED++))
fi
echo ""

# Test configuration 2: PIPE_REQ=0 PIPE_RESP=1
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2/4: PIPE_REQ=0 PIPE_RESP=1 (Response path pipelined)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
make clean > /dev/null 2>&1
if make PIPE_REQ=0 PIPE_RESP=1 2>&1 | tee sim_pipe01.log | tail -5 | grep -q "Simulation PASSED"; then
    echo "✅ PASSED: PIPE_REQ=0 PIPE_RESP=1"
    ((PASSED++))
else
    echo "❌ FAILED: PIPE_REQ=0 PIPE_RESP=1"
    ((FAILED++))
fi
echo ""

# Test configuration 3: PIPE_REQ=1 PIPE_RESP=0
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3/4: PIPE_REQ=1 PIPE_RESP=0 (Request path pipelined)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
make clean > /dev/null 2>&1
if make PIPE_REQ=1 PIPE_RESP=0 2>&1 | tee sim_pipe10.log | tail -5 | grep -q "Simulation PASSED"; then
    echo "✅ PASSED: PIPE_REQ=1 PIPE_RESP=0"
    ((PASSED++))
else
    echo "❌ FAILED: PIPE_REQ=1 PIPE_RESP=0"
    ((FAILED++))
fi
echo ""

# Test configuration 4: PIPE_REQ=1 PIPE_RESP=1
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 4/4: PIPE_REQ=1 PIPE_RESP=1 (Full pipeline)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
make clean > /dev/null 2>&1
if make PIPE_REQ=1 PIPE_RESP=1 2>&1 | tee sim_pipe11.log | tail -5 | grep -q "Simulation PASSED"; then
    echo "✅ PASSED: PIPE_REQ=1 PIPE_RESP=1"
    ((PASSED++))
else
    echo "❌ FAILED: PIPE_REQ=1 PIPE_RESP=1"
    ((FAILED++))
fi
echo ""

# Summary
echo "============================================================================"
echo "Test Summary"
echo "============================================================================"
echo "Passed: $PASSED / 4"
echo "Failed: $FAILED / 4"
echo ""
echo "Detailed logs:"
echo "  - sim_pipe00.log (PIPE_REQ=0 PIPE_RESP=0)"
echo "  - sim_pipe01.log (PIPE_REQ=0 PIPE_RESP=1)"
echo "  - sim_pipe10.log (PIPE_REQ=1 PIPE_RESP=0)"
echo "  - sim_pipe11.log (PIPE_REQ=1 PIPE_RESP=1)"
echo ""

if [ $PASSED -eq 4 ]; then
    echo "🎉 ALL TESTS PASSED! Your DUT works correctly in all pipeline configurations!"
    exit 0
else
    echo "⚠️  Some tests failed. Check the logs above for details."
    exit 1
fi
