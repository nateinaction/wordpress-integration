# WordPress Integration Test Docker

This docker environment sets up a WordPress integration environment that can be used to test WordPress plugins and themes.

```bash
docker run --rm -v `pwd`:/workspace nateinaction/wordpress-integration "./vendor/bin/phpunit" -c "./test/phpunit.xml" --testsuite="integration-tests"
```
