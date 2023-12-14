import prisma from "@/lib/prisma";
import { PrismaAdapter } from "@auth/prisma-adapter";
import NextAuth from "next-auth";
import AuthentikProvider from "next-auth/providers/authentik";

const handler = NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    AuthentikProvider({
      name: "nextit-Auth",
      clientId: "nextid-clientid",
      clientSecret: "nextit-clientsecret",
      issuer: "http://localhost:9000/application/o/nextit",
    }),
  ],
});

export { handler as GET, handler as POST };
