import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { executeReadOnlyParameterized } from "@/lib/db";

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    Credentials({
      credentials: {
        username: { label: "Логин", type: "text" },
        password: { label: "Пароль", type: "password" },
      },
      async authorize(credentials) {
        const login = credentials?.username as string;
        if (!login) return null;

        const { rows } = await executeReadOnlyParameterized(
          "SELECT id, full_name FROM employees WHERE login = $1",
          [login]
        );

        if (rows.length === 0) return null;

        const user = rows[0];
        return {
          id: user.id as string,
          name: user.full_name as string,
        };
      },
    }),
  ],
  session: { strategy: "jwt" },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user && token.id) {
        session.user.id = token.id as string;
      }
      return session;
    },
    async authorized({ auth }) {
      return !!auth?.user;
    },
  },
  pages: {
    signIn: "/login",
  },
});
