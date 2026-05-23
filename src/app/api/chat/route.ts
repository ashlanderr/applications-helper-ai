import { streamText, UIMessage, convertToModelMessages } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { auth } from "@/lib/auth/config";
import { SYSTEM_PROMPT } from "@/lib/ai/prompts";
import { agentTools } from "@/lib/ai/tools";
import { executeReadOnlyParameterized } from "@/lib/db";

export async function POST(req: Request) {
  const session = await auth();
  if (!session?.user?.id) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { messages }: { messages: UIMessage[] } = await req.json();

  const { rows } = await executeReadOnlyParameterized(
    `SELECT e.id, e.full_name, e.job_title, d.name AS department_name, e.login
     FROM employees e
     LEFT JOIN departments d ON d.id = e.department_id
     WHERE e.id = $1`,
    [session.user.id]
  );

  const user = rows[0];

  const userPrompt = user
    ? `\n\nИнформация о сотруднике:\n- ID: ${user.id}\n- ФИО: ${user.full_name}\n- Должность: ${user.job_title}\n- Отдел: ${user.department_name}\n- Логин: ${user.login}`
    : "";

  const result = streamText({
    model: anthropic("claude-haiku-4-5"),
    system: SYSTEM_PROMPT + userPrompt,
    messages: await convertToModelMessages(messages),
    tools: agentTools,
    stopWhen: ({ steps }) => steps.length >= 16,
    onFinish: async () => {},
  });

  return result.toUIMessageStreamResponse({
    onError: (error) => {
      console.error("Agent error:", error);
      if (error instanceof Error) return error.message;
      return "Произошла ошибка при обработке запроса";
    },
  });
}
