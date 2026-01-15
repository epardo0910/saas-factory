import Google from 'next-auth/providers/google'
import GitHub from 'next-auth/providers/github'
import Credentials from 'next-auth/providers/credentials'
import type { NextAuthConfig } from 'next-auth'
import { loginSchema } from '@/lib/validations/auth'
import { prisma } from '@/lib/db'
import bcrypt from 'bcryptjs'

export default {
    providers: [
        // Google OAuth
        Google({
            clientId: process.env.GOOGLE_CLIENT_ID,
            clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        }),

        // GitHub OAuth
        GitHub({
            clientId: process.env.GITHUB_CLIENT_ID,
            clientSecret: process.env.GITHUB_CLIENT_SECRET,
        }),

        // Credentials (email/password)
        Credentials({
            name: 'credentials',
            credentials: {
                email: { label: 'Email', type: 'email' },
                password: { label: 'Password', type: 'password' },
            },
            async authorize(credentials) {
                const validatedFields = loginSchema.safeParse(credentials)

                if (!validatedFields.success) {
                    return null
                }

                const { email, password } = validatedFields.data

                const user = await prisma.user.findUnique({
                    where: { email },
                })

                if (!user || !user.password) {
                    return null
                }

                const passwordsMatch = await bcrypt.compare(password, user.password)

                if (!passwordsMatch) {
                    return null
                }

                return {
                    id: user.id,
                    email: user.email,
                    name: user.name,
                }
            },
        }),
    ],
    callbacks: {
        async jwt({ token, user, account }) {
            if (user) {
                token.id = user.id
            }
            if (account?.provider && account.provider !== 'credentials') {
                token.provider = account.provider
            }
            return token
        },
        async session({ session, token }) {
            if (session.user) {
                session.user.id = token.id as string
            }
            return session
        },
    },
    pages: {
        signIn: '/login',
        error: '/login',
    },
} satisfies NextAuthConfig
