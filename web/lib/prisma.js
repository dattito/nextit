/** @typedef {import('@prisma/client')} Prisma */

// @ts-ignore 7017 is used to ignore the error that the global object is not
// defined in the global scope. This is because the global object is only
// defined in the global scope in Node.js and not in the browser.

import { PrismaClient } from "@prisma/client";

/**
 * @typedef {Object} GlobalForPrisma
 * @property {PrismaClient} prisma
 */

/** @type {GlobalForPrisma} */
const globalForPrisma = global;

/** @type {PrismaClient} */
export const prisma = globalForPrisma.prisma || new PrismaClient();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;

export default prisma;
