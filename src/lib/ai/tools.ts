import { tool } from "ai";
import { z } from "zod";
import { executeReadOnly, executeReadOnlyParameterized } from "@/lib/db";

export const pgQueryTool = tool({
  description:
    "Execute a read-only SQL query against PostgreSQL. Use this to answer questions about data. Only SELECT queries are allowed — no INSERT, UPDATE, DELETE, or DDL.",
  inputSchema: z.object({
    sql: z.string().describe("The SQL SELECT query to execute"),
  }),
  execute: async ({ sql }) => {
    try {
      const { rows, rowCount } = await executeReadOnly(sql);
      if (rows.length === 0) {
        return `(0 rows)`;
      }
      const output = JSON.stringify(rows, null, 2);
      return `${output}\n\n(${rowCount} rows returned)`;
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      return `Query error: ${message}`;
    }
  },
});

export const pgListTablesTool = tool({
  description:
    "List all tables in the public schema with approximate row counts. Use this to discover what tables exist in the database.",
  inputSchema: z.object({}),
  execute: async () => {
    try {
      const { rows } = await executeReadOnly(`
        SELECT
          t.table_name,
          c.reltuples::bigint AS approximate_row_count
        FROM information_schema.tables t
        LEFT JOIN pg_class c ON c.relname = t.table_name
        WHERE t.table_schema = 'public'
          AND t.table_type = 'BASE TABLE'
        ORDER BY t.table_name
      `);
      if (rows.length === 0) return "(0 tables)";
      return JSON.stringify(rows, null, 2);
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      return `Error: ${message}`;
    }
  },
});

export const pgDescribeTableTool = tool({
  description:
    "Describe the columns of a table: names, data types, nullability, and default values. Use this to understand a table's structure before querying.",
  inputSchema: z.object({
    table: z.string().describe("The table name to describe"),
  }),
  execute: async ({ table }) => {
    try {
      const { rows } = await executeReadOnlyParameterized(
        `
          SELECT
            column_name,
            data_type,
            is_nullable,
            column_default
          FROM information_schema.columns
          WHERE table_schema = 'public'
            AND table_name = $1
          ORDER BY ordinal_position
        `,
        [table]
      );
      if (rows.length === 0) {
        return `Table "${table}" not found in the public schema.`;
      }
      return JSON.stringify(rows, null, 2);
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      return `Error: ${message}`;
    }
  },
});

export const submitApplicationTool = tool({
  description:
    "Prepare an application form for review. Fetches the template, validates params against the template schema, and returns structured form data for display. Does NOT insert into database.",
  inputSchema: z.object({
    template_slug: z.string().describe("The template slug (e.g., 'access-request')"),
    params: z.record(z.string(), z.unknown()).describe("Form field values matching the template schema"),
    comment: z.string().optional().describe("Optional comment for the application"),
  }),
  execute: async ({ template_slug, params, comment }) => {
    try {
      const { rows: templates } = await executeReadOnlyParameterized(
        "SELECT id, slug, title, description, params AS schema_def FROM templates WHERE slug = $1",
        [template_slug]
      );

      if (templates.length === 0) {
        return { error: `Template "${template_slug}" not found` };
      }

      const template = templates[0];
      const schemaDef = template.schema_def as Record<string, { type: string; description?: string; enum?: string[] }>;

      const errors: string[] = [];
      const validatedParams: Record<string, unknown> = {};

      for (const [key, def] of Object.entries(schemaDef)) {
        const value = params[key];

        if (value === undefined || value === null || value === "") {
          if (def.enum) {
            errors.push(`Field "${key}" is required (${def.description || key})`);
          }
          continue;
        }

        if (def.enum && !def.enum.includes(value as string)) {
          errors.push(`Field "${key}" must be one of: ${def.enum.join(", ")}`);
          continue;
        }

        validatedParams[key] = value;
      }

      if (errors.length > 0) {
        return {
          error: "Validation failed",
          errors,
          template: {
            slug: template.slug,
            title: template.title,
            description: template.description,
            schema: schemaDef,
          },
        };
      }

      return {
        template: {
          slug: template.slug,
          title: template.title,
          description: template.description,
          schema: schemaDef,
        },
        params: validatedParams,
        comment: comment || null,
        status: "черновик",
      };
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      return { error: `Failed to prepare application: ${message}` };
    }
  },
});

export const agentTools = {
  pg_query: pgQueryTool,
  pg_list_tables: pgListTablesTool,
  pg_describe_table: pgDescribeTableTool,
  submit_application: submitApplicationTool,
};
