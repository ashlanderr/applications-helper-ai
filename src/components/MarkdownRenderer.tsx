"use client";

import Markdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { type ReactNode } from "react";

interface MarkdownRendererProps {
  content: string;
}

function TableWrapper({ children }: { children: ReactNode }) {
  return <div className="table-wrapper">{children}</div>;
}

export default function MarkdownRenderer({ content }: MarkdownRendererProps) {
  return (
    <div className="markdown-body">
      <Markdown
        remarkPlugins={[remarkGfm]}
        components={{
          table: ({ children }) => (
            <TableWrapper>
              <table>{children}</table>
            </TableWrapper>
          ),
        }}
      >
        {content}
      </Markdown>
    </div>
  );
}
