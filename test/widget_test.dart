void main() {
  test('Basic test', () {
    // Basic test to ensure testing framework works
    expect(true, true);
  });
}

void test(String description, Function testFunction) {
  print('Running test: $description');
  try {
    testFunction();
    print('✓ Test passed: $description');
  } catch (e) {
    print('✗ Test failed: $description - $e');
  }
}

void expect(dynamic actual, dynamic matcher) {
  if (actual == matcher) {
    return;
  }
  throw Exception('Expected $matcher but got $actual');
}
