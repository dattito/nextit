import prisma from "@/lib/prisma";
import { PrismaAdapter } from "@auth/prisma-adapter";
import NextAuth from "next-auth";
import AuthentikProvider from "next-auth/providers/authentik";

export const authOptions = {
  adapter: PrismaAdapter(prisma),
  providers: [
    AuthentikProvider({
      name: "nextit-Auth",
      clientId: process.env.AUTHENTIK_CLIENTID,
      clientSecret: process.env.AUTHENTIK_CLIENTSECRET,
      issuer: process.env.AUTHENTIK_ISSUER,
    }),
  ],
};

const handler = NextAuth(authOptions);

export { handler as GET, handler as POST };
