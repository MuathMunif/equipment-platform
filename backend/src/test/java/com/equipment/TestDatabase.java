package com.equipment;

import java.util.Set;
import org.springframework.jdbc.core.JdbcTemplate;

final class TestDatabase {
  private static final String DEFAULT_URL = "jdbc:postgresql://127.0.0.1:55433/equipment_test";
  private static final Set<String> ALLOWED_URLS = Set.of(
      DEFAULT_URL,
      "jdbc:postgresql://127.0.0.1:55434/equipment_test");

  private TestDatabase() {}

  static String url() {
    String configured = System.getenv("EQUIPMENT_TEST_DB_URL");
    String url = configured == null || configured.isBlank() ? DEFAULT_URL : configured;
    if (!ALLOWED_URLS.contains(url)) {
      throw new IllegalStateException("Backend tests require an approved loopback equipment_test database");
    }
    return url;
  }

  static void requireIsolated(JdbcTemplate db) throws Exception {
    try (var connection = db.getDataSource().getConnection()) {
      if (!url().equals(connection.getMetaData().getURL())) {
        throw new IllegalStateException("Refusing to reset a non-test database");
      }
    }
  }
}
