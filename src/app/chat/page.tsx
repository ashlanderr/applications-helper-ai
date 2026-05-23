import Header from "@/components/Header";
import ChatInterface from "@/components/ChatInterface";

export const metadata = {
  title: "Чат — Помощник заявок",
};

export default function ChatPage() {
  return (
    <div className="flex flex-col h-screen">
      <Header />
      <main className="flex-1 overflow-hidden mx-auto w-full max-w-5xl px-4">
        <ChatInterface />
      </main>
    </div>
  );
}
