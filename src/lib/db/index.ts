import pg from "pg";

const MAX_ROWS = 1000;
const QUERY_TIMEOUT_MS = 30_000;

const WRITE_PATTERN =
  /^\s*(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|GRANT|REVOKE|EXECUTE)\b/i;

function isWriteQuery(sql: string): boolean {
  const statements = sql
    .split(";")
    .map((s) => s.trim())
    .filter(Boolean);
  return statements.some((stmt) => WRITE_PATTERN.test(stmt));
}

let pool: pg.Pool | null = null;

function getPool(): pg.Pool {
  if (!pool) {
    const connectionString = process.env.DATABASE_URL;
    if (!connectionString) {
      throw new Error("DATABASE_URL environment variable is not set");
    }
    pool = new pg.Pool({
      connectionString,
      max: 5,
      idleTimeoutMillis: 30_000,
      connectionTimeoutMillis: 10_000,
    });
  }
  return pool;
}

export async function executeReadOnly(
  sql: string,
  params?: string[],
): Promise<{ rows: Record<string, unknown>[]; rowCount: number }> {
  if (isWriteQuery(sql)) {
    throw new Error(
      "Write operations (INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, CREATE, GRANT, REVOKE) are not allowed. Only SELECT queries are permitted."
    );
  }

  const client = await getPool().connect();
  try {
    await client.query("SET TRANSACTION READ ONLY");
    await client.query(`SET statement_timeout = ${QUERY_TIMEOUT_MS}`);
    const result = await client.query({ text: sql, values: params });
    const rows = result.rows as Record<string, unknown>[];
    const limited = rows.slice(0, MAX_ROWS);
    return { rows: limited, rowCount: result.rowCount ?? rows.length };
  } finally {
    await client.query("SET statement_timeout = 0");
    client.release();
  }
}

export async function executeReadOnlyParameterized(
  sql: string,
  params: string[],
): Promise<{ rows: Record<string, unknown>[]; rowCount: number }> {
  const client = await getPool().connect();
  try {
    await client.query("SET TRANSACTION READ ONLY");
    await client.query(`SET statement_timeout = ${QUERY_TIMEOUT_MS}`);
    const result = await client.query({ text: sql, values: params });
    const rows = result.rows as Record<string, unknown>[];
    const limited = rows.slice(0, MAX_ROWS);
    return { rows: limited, rowCount: result.rowCount ?? rows.length };
  } finally {
    await client.query("SET statement_timeout = 0");
    client.release();
  }
}

export { MAX_ROWS, isWriteQuery };
