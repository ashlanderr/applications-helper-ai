"use client";

import { useChat } from "@ai-sdk/react";
import { DefaultChatTransport, isToolUIPart, getToolName, type UIMessage } from "ai";
import { useState, useRef, useEffect, useCallback, useMemo } from "react";
import ApplicationForm from "./ApplicationForm";
import MarkdownRenderer from "./MarkdownRenderer";
import type { Template, TemplateField } from "@/types";

const transport = new DefaultChatTransport({ api: "/api/chat" });

interface FormFromTool {
  template: Template;
  params: Record<string, unknown>;
  comment: string | null;
}

function extractFormsFromMessages(
  messages: ReturnType<typeof useChat>["messages"]
): Map<string, FormFromTool[]> {
  const result = new Map<string, FormFromTool[]>();

  for (const msg of messages) {
    if (msg.role !== "assistant") continue;
    const msgForms: FormFromTool[] = [];

    for (const part of msg.parts) {
      if (!isToolUIPart(part)) continue;
      if (part.state !== "output-available") continue;
      if (getToolName(part) !== "submit_application") continue;

      const output = part.output as Record<string, unknown>;
      if (output.error) continue;
      if (!output.template || !output.params) continue;

      const t = output.template as Record<string, unknown>;
      const schemaDef = t.schema as Record<string, Record<string, unknown>>;
      const fields: TemplateField[] = Object.entries(schemaDef).map(
        ([key, def]) => ({
          id: key,
          label: (def.description as string) || key,
          type: (def.enum ? "select" : def.type === "number" ? "number" : "text") as TemplateField["type"],
          options: def.enum as string[] | undefined,
        })
      );

      msgForms.push({
        template: {
          id: t.slug as string,
          name: t.title as string,
          description: (t.description as string) || "",
          fields,
        },
        params: output.params as Record<string, unknown>,
        comment: (output.comment as string) || null,
      });
    }

    if (msgForms.length > 0) {
      result.set(msg.id, msgForms);
    }
  }

  return result;
}

interface StreamSegment {
  type: "text" | "tool";
  text?: string;
  toolName?: string;
  toolLabel?: string;
  toolInput?: unknown;
  toolOutput?: unknown;
  toolState?: string;
}

function buildStreamSegments(msg: UIMessage): StreamSegment[] {
  const segments: StreamSegment[] = [];
  let currentText = "";

  for (const part of msg.parts) {
    if (part.type === "text") {
      currentText += part.text as string;
    } else if (isToolUIPart(part)) {
      if (currentText) {
        segments.push({ type: "text", text: currentText });
        currentText = "";
      }

      const toolName = getToolName(part);
      const label = getToolLabel(toolName, part.input as Record<string, unknown>);

      segments.push({
        type: "tool",
        toolName,
        toolLabel: label,
        toolInput: part.input,
        toolOutput: part.state === "output-available" ? part.output : undefined,
        toolState: part.state as string,
      });
    }
  }

  if (currentText) {
    segments.push({ type: "text", text: currentText });
  }

  return segments;
}

function getToolLabel(
  toolName: string,
  input: Record<string, unknown> | undefined
): string {
  switch (toolName) {
    case "pg_query":
      return `SQL-запрос`;
    case "pg_list_tables":
      return "Получаю список таблиц";
    case "pg_describe_table":
      return `Описываю таблицу: ${input?.table || "?"}`;
    case "submit_application":
      return `Подготавливаю заявку: ${input?.template_slug || "?"}`;
    default:
      return toolName;
  }
}

function getToolResultLabel(
  toolName: string,
  output: unknown
): string | null {
  if (typeof output === "string") {
    if (toolName === "pg_query") {
      const match = output.match(/\((\d+) rows? returned\)/);
      return match ? `${match[1]} строк` : null;
    }
    return null;
  }

  if (!output || typeof output !== "object") return null;
  const o = output as Record<string, unknown>;
  if (o.error) return `Ошибка: ${o.error}`;

  switch (toolName) {
    case "pg_query": {
      const rowCount = o.rowCount;
      return typeof rowCount === "number" ? `${rowCount} строк` : null;
    }
    case "pg_list_tables":
      return "Таблицы загружены";
    case "pg_describe_table":
      return "Структура таблицы загружена";
    case "submit_application":
      return o.template ? "Форма заявки готова" : null;
    default:
      return null;
  }
}

export default function ChatInterface() {
  const { messages, sendMessage, status, error } = useChat({ transport });
  const [input, setInput] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const formsByMessage = useMemo(
    () => extractFormsFromMessages(messages),
    [messages]
  );

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages, scrollToBottom]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!input.trim() || status === "streaming" || status === "submitted") return;
    sendMessage({ text: input.trim() });
    setInput("");
  }

  const isLoading = status === "streaming" || status === "submitted";

  function handleOptionClick(value: string) {
    if (isLoading) return;
    sendMessage({ text: value });
  }

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 && (
          <div className="text-center text-gray-400 mt-20">
            <div className="text-4xl mb-4">💬</div>
            <p className="text-lg font-medium mb-1">Начните диалог</p>
            <p className="text-sm">
              Задайте вопрос о заявках или попросите создать новую
            </p>
            <div className="mt-6 space-y-2 text-sm">
              <p className="text-gray-400">Примеры запросов:</p>
              <div className="flex flex-wrap justify-center gap-2">
                {[
                  "Покажи мои заявки",
                  "Какие заявки были на прошлой неделе?",
                  "Создай заявку на доступ к ресурсу",
                  "Какие таблицы есть в базе?",
                ].map((example) => (
                  <button
                    key={example}
                    onClick={() => setInput(example)}
                    className="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 rounded-full text-gray-600 transition-colors"
                  >
                    {example}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {messages.map((msg) => {
          if (msg.role === "user") {
            const userText = msg.parts
              .filter(
                (p): p is typeof p & { type: "text" } => p.type === "text"
              )
              .map((p) => p.text)
              .join("");
            return (
              <div key={msg.id} className="flex justify-end">
                <div className="bg-blue-600 text-white rounded-2xl rounded-br-md px-4 py-2 max-w-[75%]">
                  {userText}
                </div>
              </div>
            );
          }

          const segments = buildStreamSegments(msg);
          const forms = formsByMessage.get(msg.id) || [];
          let formIdx = 0;

          return (
            <div key={msg.id} className="flex flex-col gap-2">
              {segments.map((seg, i) => {
                if (seg.type === "text" && seg.text) {
                  return (
                    <div
                      key={i}
                      className="bg-gray-100 text-gray-800 rounded-2xl rounded-bl-md px-4 py-2 max-w-[75%] text-sm"
                    >
                      <MarkdownRenderer content={seg.text} />
                    </div>
                  );
                }

                if (seg.type === "tool") {
                  if (seg.toolName === "ask_user") {
                    const askOutput = seg.toolOutput as { question?: string; options?: { value: string; label?: string }[] } | undefined;
                    const askInput = seg.toolInput as { question?: string; options?: { value: string; label?: string }[] } | undefined;
                    const data = askOutput || askInput;
                    const isPending = seg.toolState !== "output-available";

                    if (data?.question && data?.options) {
                      return (
                        <div key={i} className="flex flex-col gap-2 max-w-[85%]">
                          <div className="bg-gray-100 text-gray-800 rounded-2xl rounded-bl-md px-4 py-2 text-sm">
                            <MarkdownRenderer content={data.question} />
                          </div>
                          <div className="flex flex-wrap gap-2">
                            {data.options.map((opt, idx) => (
                              <button
                                key={idx}
                                onClick={() => handleOptionClick(opt.value)}
                                disabled={isLoading}
                                className="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 rounded-full text-gray-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                              >
                                {opt.label || opt.value}
                              </button>
                            ))}
                          </div>
                        </div>
                      );
                    }

                    return (
                      <div key={i} className="flex flex-col gap-2">
                        <ToolCallBlock
                          label={seg.toolLabel!}
                          input={seg.toolInput}
                          output={seg.toolOutput}
                          resultLabel={null}
                          isPending={isPending}
                        />
                      </div>
                    );
                  }

                  const resultLabel = seg.toolOutput
                    ? getToolResultLabel(seg.toolName!, seg.toolOutput)
                    : null;
                  const isPending = seg.toolState !== "output-available";
                  const isSubmitApp = seg.toolName === "submit_application";
                  const form =
                    isSubmitApp && seg.toolOutput && formIdx < forms.length
                      ? forms[formIdx++]
                      : null;

                  return (
                    <div key={i} className="flex flex-col gap-2">
                      <ToolCallBlock
                        label={seg.toolLabel!}
                        input={seg.toolInput}
                        output={seg.toolOutput}
                        resultLabel={resultLabel}
                        isPending={isPending}
                      />
                      {form && (
                        <div className="max-w-lg">
                          <ApplicationForm
                            template={form.template}
                            prefilledData={form.params}
                            comment={form.comment}
                          />
                        </div>
                      )}
                    </div>
                  );
                }

                return null;
              })}
            </div>
          );
        })}

        {isLoading && messages.length > 0 && (
          <div className="flex items-center gap-2 text-gray-400 text-sm">
            <span className="animate-bounce">●</span>
            <span>Агент думает...</span>
          </div>
        )}

        {error && (
          <div className="bg-red-50 text-red-600 rounded-lg px-4 py-2 text-sm">
            Ошибка: {error.message}
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      <form
        onSubmit={handleSubmit}
        className="border-t border-gray-200 bg-white p-4"
      >
        <div className="flex gap-2">
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Опишите вашу заявку..."
            disabled={isLoading}
            className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 text-gray-900"
          />
          <button
            type="submit"
            disabled={isLoading || !input.trim()}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed font-medium"
          >
            {isLoading ? "..." : "→"}
          </button>
        </div>
      </form>
    </div>
  );
}

function ToolCallBlock({
  label,
  input,
  output,
  resultLabel,
  isPending,
}: {
  label: string;
  input: unknown;
  output: unknown;
  resultLabel: string | null;
  isPending: boolean;
}) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="bg-gray-50 border border-gray-200 rounded-lg px-4 py-2">
      <div
        className="flex items-center gap-2 text-sm cursor-pointer select-none"
        onClick={() => setExpanded(!expanded)}
      >
        {isPending ? (
          <span className="animate-pulse text-blue-500">●</span>
        ) : (
          <span className="text-green-500">✓</span>
        )}
        <span className="font-medium text-gray-700">{label}</span>
        {resultLabel && (
          <span className="text-xs text-gray-500">— {resultLabel}</span>
        )}
        <span className="text-gray-400 text-xs ml-auto">
          {expanded ? "▾" : "▸"}
        </span>
      </div>
      {expanded && (
        <div className="mt-2 space-y-2">
          {input !== undefined && (
            <div>
              <p className="text-xs text-gray-400 mb-1">Вход:</p>
              <pre className="text-xs bg-white border border-gray-200 rounded p-2 overflow-x-auto max-h-48 overflow-y-auto text-gray-700">
                {JSON.stringify(input, null, 2)}
              </pre>
            </div>
          )}
          {output !== undefined && (
            <div>
              <p className="text-xs text-gray-400 mb-1">Результат:</p>
              <pre className="text-xs bg-white border border-gray-200 rounded p-2 overflow-x-auto max-h-48 overflow-y-auto text-gray-700">
                {typeof output === "string"
                  ? output
                  : JSON.stringify(output, null, 2)}
              </pre>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
