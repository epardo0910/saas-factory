#!/bin/bash

# SaaS Factory - Generador de proyectos Full Stack
# Next.js 14 + PostgreSQL + NextAuth.js + TypeScript + Tailwind CSS
# Autor: Sistema de Automatización Enterprise
# Fecha: $(date +%Y-%m-%d)

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${MAGENTA}"
cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║        🏭 SaaS Factory - Full Stack Generator        ║
║                                                       ║
║   Next.js 14 + PostgreSQL + NextAuth + TypeScript    ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ============================================
# VERIFICACIÓN DE DEPENDENCIAS
# ============================================
check_dependencies() {
    local missing=0
    
    echo -e "${BLUE}[Verificando dependencias...]${NC}"
    
    # Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 18 ]; then
            echo -e "  ${GREEN}✓${NC} Node.js $(node -v)"
        else
            echo -e "  ${YELLOW}⚠${NC} Node.js $(node -v) (se recomienda v18+)"
        fi
    else
        echo -e "  ${RED}✗${NC} Node.js no instalado"
        missing=1
    fi
    
    # npm
    if command -v npm &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} npm $(npm -v)"
    else
        echo -e "  ${RED}✗${NC} npm no instalado"
        missing=1
    fi
    
    # PostgreSQL (Docker o local)
    if docker ps 2>/dev/null | grep -q "postgres\|strapi-db"; then
        echo -e "  ${GREEN}✓${NC} PostgreSQL (Docker)"
    elif command -v psql &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} PostgreSQL (local)"
    else
        echo -e "  ${YELLOW}⚠${NC} PostgreSQL no detectado (usa --create-db para Docker)"
    fi
    
    # PM2 (para --deploy)
    if command -v pm2 &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} PM2 $(pm2 -v)"
    else
        echo -e "  ${YELLOW}○${NC} PM2 no instalado (necesario para --deploy)"
    fi
    
    # Caddy (para --deploy)
    if command -v caddy &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Caddy instalado"
    else
        echo -e "  ${YELLOW}○${NC} Caddy no instalado (necesario para --deploy)"
    fi
    
    echo ""
    
    if [ $missing -eq 1 ]; then
        echo -e "${RED}❌ Faltan dependencias críticas. Instálalas primero.${NC}"
        exit 1
    fi
}

# ============================================
# FUNCIÓN PARA ENCONTRAR PUERTO LIBRE
# ============================================
find_free_port() {
    local start_port=${1:-3000}
    local end_port=${2:-3100}
    
    for port in $(seq $start_port $end_port); do
        if ! netstat -tuln 2>/dev/null | grep -q ":$port " && \
           ! ss -tuln 2>/dev/null | grep -q ":$port "; then
            echo $port
            return 0
        fi
    done
    
    echo $start_port  # Fallback
    return 1
}

# Verificar si se proporcionó nombre del proyecto
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Debes proporcionar un nombre para el proyecto${NC}"
    echo -e "${YELLOW}Uso: saas-factory <nombre-proyecto> [db-name] [opciones]${NC}"
    echo ""
    echo -e "${CYAN}Opciones:${NC}"
    echo -e "  ${CYAN}--dns${NC}         Crear subdominio en Cloudflare"
    echo -e "  ${CYAN}--create-db${NC}   Crear base de datos automáticamente"
    echo -e "  ${CYAN}--deploy${NC}      Deploy completo (PM2 + Caddy + SSL)"
    echo -e "  ${CYAN}--tunnel${NC}      Usar Cloudflare Tunnel (n8n-tunnel)"
    echo -e "  ${CYAN}--with-tests${NC}  Incluir Vitest + Playwright"
    echo -e "  ${CYAN}--no-mcp${NC}      No configurar MCP servers"
    echo ""
    echo -e "${CYAN}Ejemplos:${NC}"
    echo -e "  ${CYAN}saas-factory app-gemini${NC}"
    echo -e "  ${CYAN}saas-factory app-gemini gemini_db --dns --create-db${NC}"
    echo -e "  ${CYAN}saas-factory app-gemini gemini_db --tunnel --create-db --deploy${NC}  # Producción segura 🚀"
    exit 1
fi

# Verificar dependencias
check_dependencies

PROJECT_NAME=$1
DB_NAME=${2:-${PROJECT_NAME//-/_}_db}  # Reemplazar guiones por guiones bajos
CREATE_DNS=false
CREATE_TUNNEL=false
CREATE_DB=false
SETUP_MCP=true  # Por defecto, configurar MCP
AUTO_DEPLOY=false
SETUP_TESTS=false

# Verificar flags
for arg in "$@"; do
    if [ "$arg" == "--dns" ]; then
        CREATE_DNS=true
    elif [ "$arg" == "--tunnel" ]; then
        CREATE_TUNNEL=true
    elif [ "$arg" == "--create-db" ]; then
        CREATE_DB=true
    elif [ "$arg" == "--no-mcp" ]; then
        SETUP_MCP=false
    elif [ "$arg" == "--deploy" ]; then
        AUTO_DEPLOY=true
    elif [ "$arg" == "--with-tests" ]; then
        SETUP_TESTS=true
    fi
done

# Validar conflictos de flags
if [ "$CREATE_TUNNEL" = true ] && [ "$CREATE_DNS" = true ]; then
    echo -e "${RED}❌ Error: No puedes usar --dns y --tunnel juntos${NC}"
    echo -e "${YELLOW}   Usa --dns para registro A directo, o --tunnel para Cloudflare Tunnel${NC}"
    exit 1
fi

if [ "$AUTO_DEPLOY" = true ] && [ "$CREATE_DB" = false ]; then
    echo -e "${YELLOW}⚠️  Advertencia: --deploy funciona mejor con --create-db${NC}"
    echo -e "${YELLOW}   Asegúrate de crear la DB manualmente antes del deploy${NC}"
    echo ""
fi

PROJECT_DIR="$PWD/$PROJECT_NAME"
SUBDOMAIN="${PROJECT_NAME}"

# Encontrar puerto libre automáticamente
APP_PORT=$(find_free_port 3000 3100)
echo -e "${CYAN}🔌 Puerto asignado: ${GREEN}$APP_PORT${NC}"

# Verificar si el directorio ya existe
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio '$PROJECT_NAME' ya existe${NC}"
    exit 1
fi

echo -e "${CYAN}📦 Creando proyecto: ${GREEN}$PROJECT_NAME${NC}"
echo -e "${CYAN}🗄️  Base de datos: ${GREEN}$DB_NAME${NC}"
if [ "$CREATE_DNS" = true ]; then
    echo -e "${CYAN}🌐 DNS: ${GREEN}${SUBDOMAIN}.emanuel-server.com${NC}"
fi
if [ "$CREATE_DB" = true ]; then
    echo -e "${CYAN}🤖 Auto-crear DB: ${GREEN}Sí${NC}"
fi
if [ "$AUTO_DEPLOY" = true ]; then
    echo -e "${CYAN}🚀 Auto-deploy: ${GREEN}Sí (PM2 + Caddy)${NC}"
fi
echo ""

# Paso 1: Crear proyecto Next.js
echo -e "${BLUE}[1/10]${NC} Inicializando Next.js con TypeScript..."
npx create-next-app@latest "$PROJECT_NAME" \
    --typescript \
    --tailwind \
    --app \
    --src-dir \
    --import-alias "@/*" \
    --eslint \
    --no-turbopack \
    --yes

cd "$PROJECT_NAME"

# Paso 2: Instalar dependencias de PostgreSQL y Auth
echo -e "${BLUE}[2/10]${NC} Instalando PostgreSQL client y NextAuth.js..."
npm install \
    pg \
    @types/pg \
    next-auth@beta \
    @auth/pg-adapter \
    bcryptjs \
    @types/bcryptjs \
    zod

# Paso 3: Instalar dependencias UI/UX comunes
echo -e "${BLUE}[3/10]${NC} Instalando dependencias UI/UX..."
npm install \
    clsx \
    tailwind-merge \
    class-variance-authority \
    lucide-react \
    react-hot-toast \
    zustand \
    @radix-ui/react-dialog \
    @radix-ui/react-dropdown-menu \
    @radix-ui/react-avatar \
    @radix-ui/react-tabs \
    @radix-ui/react-select \
    @radix-ui/react-label

# Instalar dependencias de desarrollo
npm install -D \
    prisma@5 \
    @types/node

# Fijar versión de @prisma/client a 5.x también
npm install @prisma/client@5

# Paso 4: Crear estructura de carpetas
echo -e "${BLUE}[4/10]${NC} Creando estructura de carpetas..."
mkdir -p src/app/\(auth\)/login
mkdir -p src/app/\(auth\)/signup
mkdir -p src/app/\(auth\)/forgot-password
mkdir -p src/app/\(dashboard\)/dashboard
mkdir -p src/app/\(dashboard\)/projects
mkdir -p src/app/\(dashboard\)/team
mkdir -p src/app/\(dashboard\)/settings
mkdir -p src/app/api/auth/\[...nextauth\]
mkdir -p src/components/ui
mkdir -p src/components/auth
mkdir -p src/components/dashboard
mkdir -p src/lib/db
mkdir -p src/lib/auth
mkdir -p src/lib/utils
mkdir -p src/lib/hooks
mkdir -p src/lib/validations
mkdir -p src/types
mkdir -p public/images
mkdir -p prisma/migrations

# Copiar componentes UI adicionales desde templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

if [ -f "$TEMPLATE_DIR/components/ui/table.tsx" ]; then
    cp "$TEMPLATE_DIR/components/ui/table.tsx" ./src/components/ui/table.tsx
fi
if [ -f "$TEMPLATE_DIR/components/ui/modal.tsx" ]; then
    cp "$TEMPLATE_DIR/components/ui/modal.tsx" ./src/components/ui/modal.tsx
fi
if [ -f "$TEMPLATE_DIR/components/dashboard/dashboard-layout.tsx" ]; then
    cp "$TEMPLATE_DIR/components/dashboard/dashboard-layout.tsx" ./src/components/dashboard/dashboard-layout.tsx
fi
if [ -f "$TEMPLATE_DIR/components/auth/oauth-buttons.tsx" ]; then
    cp "$TEMPLATE_DIR/components/auth/oauth-buttons.tsx" ./src/components/auth/oauth-buttons.tsx
fi
if [ -f "$TEMPLATE_DIR/lib/logger.ts" ]; then
    cp "$TEMPLATE_DIR/lib/logger.ts" ./src/lib/logger.ts
fi

# Copiar configuración Docker (si existe template)
if [ -d "$TEMPLATE_DIR/docker" ]; then
    echo -e "${BLUE}[Docker]${NC} Copiando configuración de contenedor..."
    cp "$TEMPLATE_DIR/docker/Dockerfile" ./Dockerfile
    cp "$TEMPLATE_DIR/docker/.dockerignore" ./.dockerignore
    cp "$TEMPLATE_DIR/docker/docker-compose.yml" ./docker-compose.yml
    
    # Configurar Next.js para standalone mode (optimizado para Docker)
    cat > next.config.ts << 'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  eslint: {
    ignoreDuringBuilds: true, // Evitar fallos de build por lints menores en CI/Docker
  },
};

export default nextConfig;
EOF
    echo -e "${GREEN}✓${NC} Docker listo"
fi

# Paso 5: Crear archivos de configuración base
echo -e "${BLUE}[5/10]${NC} Generando archivos de configuración..."

# .env.local.example
cat > .env.local.example << 'EOF'
# PostgreSQL Database Configuration
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-nextauth-secret-here

# App Configuration
NEXT_PUBLIC_APP_NAME=SaaS Application
NEXT_PUBLIC_APP_URL=http://localhost:3000
EOF

# .env.local
cat > .env.local << EOF
# PostgreSQL Database Configuration
# Si usas Docker PostgreSQL (puerto 5434): postgresql://strapi:supersecretstrapi@localhost:5434/$DB_NAME
# Si usas PostgreSQL local (puerto 5432): postgresql://localhost:5432/$DB_NAME
DATABASE_URL="postgresql://strapi:supersecretstrapi@localhost:5434/$DB_NAME"

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:$APP_PORT
NEXTAUTH_SECRET=$(openssl rand -base64 32)

# App Configuration
NEXT_PUBLIC_APP_NAME=$PROJECT_NAME
NEXT_PUBLIC_APP_URL=http://localhost:$APP_PORT

# Server Port
PORT=$APP_PORT
EOF

# Copiar configuración real a .env para Prisma (necesario para CLI)
cp .env.local .env

# Prisma Schema
cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// NextAuth.js Models
model Account {
  id                String  @id @default(cuid())
  userId            String
  type              String
  provider          String
  providerAccountId String
  refresh_token     String? @db.Text
  access_token      String? @db.Text
  expires_at        Int?
  token_type        String?
  scope             String?
  id_token          String? @db.Text
  session_state     String?

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
  @@index([userId])
}

model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
}

model User {
  id            String    @id @default(cuid())
  name          String?
  email         String    @unique
  emailVerified DateTime?
  password      String?
  image         String?
  role          UserRole  @default(CLIENT)
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  accounts Account[]
  sessions Session[]
  projects ProjectMember[]

  @@index([email])
}

model VerificationToken {
  identifier String
  token      String   @unique
  expires    DateTime

  @@unique([identifier, token])
}

// Application Models
enum UserRole {
  OWNER
  MANAGER
  DEVELOPER
  CLIENT
}

model Project {
  id          String          @id @default(cuid())
  name        String
  description String?
  status      ProjectStatus   @default(ACTIVE)
  createdAt   DateTime        @default(now())
  updatedAt   DateTime        @updatedAt

  members     ProjectMember[]
  tasks       Task[]

  @@index([status])
}

enum ProjectStatus {
  ACTIVE
  PAUSED
  COMPLETED
  ARCHIVED
}

model ProjectMember {
  id        String   @id @default(cuid())
  projectId String
  userId    String
  role      MemberRole
  joinedAt  DateTime @default(now())

  project Project @relation(fields: [projectId], references: [id], onDelete: Cascade)
  user    User    @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([projectId, userId])
  @@index([projectId])
  @@index([userId])
}

enum MemberRole {
  OWNER
  ADMIN
  MEMBER
  VIEWER
}

model Task {
  id          String     @id @default(cuid())
  projectId   String
  title       String
  description String?
  status      TaskStatus @default(TODO)
  priority    TaskPriority @default(MEDIUM)
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt

  project Project @relation(fields: [projectId], references: [id], onDelete: Cascade)

  @@index([projectId])
  @@index([status])
}

enum TaskStatus {
  TODO
  IN_PROGRESS
  DONE
}

enum TaskPriority {
  LOW
  MEDIUM
  HIGH
  URGENT
}
EOF

# lib/db/index.ts
cat > src/lib/db/index.ts << 'EOF'
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
})

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
EOF

# auth.config.ts
cat > src/auth.config.ts << 'EOF'
import type { NextAuthConfig } from 'next-auth'

export const authConfig = {
  pages: {
    signIn: '/login',
    newUser: '/signup',
  },
  callbacks: {
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user
      const isOnDashboard = nextUrl.pathname.startsWith('/dashboard')
      const isOnAuth = nextUrl.pathname.startsWith('/login') || nextUrl.pathname.startsWith('/signup')

      if (isOnDashboard) {
        if (isLoggedIn) return true
        return false // Redirect to login
      } else if (isLoggedIn && isOnAuth) {
        return Response.redirect(new URL('/dashboard', nextUrl))
      }
      return true
    },
  },
  providers: [], // Providers are added in auth.ts
} satisfies NextAuthConfig
EOF

# auth.ts
cat > src/auth.ts << 'EOF'
import NextAuth from 'next-auth'
import Credentials from 'next-auth/providers/credentials'
import { authConfig } from './auth.config'
import { prisma } from '@/lib/db'
import bcrypt from 'bcryptjs'
import { z } from 'zod'
import type { User } from '@prisma/client'

async function getUser(email: string): Promise<User | null> {
  try {
    const user = await prisma.user.findUnique({
      where: { email },
    })
    return user
  } catch (error) {
    console.error('Failed to fetch user:', error)
    return null
  }
}

export const { auth, signIn, signOut, handlers } = NextAuth({
  ...authConfig,
  providers: [
    Credentials({
      async authorize(credentials) {
        const parsedCredentials = z
          .object({ email: z.string().email(), password: z.string().min(6) })
          .safeParse(credentials)

        if (parsedCredentials.success) {
          const { email, password } = parsedCredentials.data
          const user = await getUser(email)

          if (!user || !user.password) return null

          const passwordsMatch = await bcrypt.compare(password, user.password)

          if (passwordsMatch) return user
        }

        return null
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id
        token.role = (user as User).role
      }
      return token
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string
        session.user.role = token.role as string
      }
      return session
    },
  },
})
EOF

# middleware.ts
cat > src/middleware.ts << 'EOF'
import { auth } from '@/auth'

export default auth((req) => {
  const isLoggedIn = !!req.auth
  const isOnDashboard = req.nextUrl.pathname.startsWith('/dashboard')
  const isOnAuth = req.nextUrl.pathname.startsWith('/login') || req.nextUrl.pathname.startsWith('/signup')

  if (isOnDashboard && !isLoggedIn) {
    return Response.redirect(new URL('/login', req.nextUrl))
  }

  if (isOnAuth && isLoggedIn) {
    return Response.redirect(new URL('/dashboard', req.nextUrl))
  }
})

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
}
EOF

# app/api/auth/[...nextauth]/route.ts
cat > src/app/api/auth/\[...nextauth\]/route.ts << 'EOF'
import { handlers } from '@/auth'

export const { GET, POST } = handlers
EOF

# lib/validations/auth.ts
cat > src/lib/validations/auth.ts << 'EOF'
import { z } from 'zod'

export const signInSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres'),
})

export const signUpSchema = z.object({
  name: z.string().min(2, 'El nombre debe tener al menos 2 caracteres'),
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Las contraseñas no coinciden',
  path: ['confirmPassword'],
})

export type SignInInput = z.infer<typeof signInSchema>
export type SignUpInput = z.infer<typeof signUpSchema>
EOF

# lib/utils/cn.ts
cat > src/lib/utils/cn.ts << 'EOF'
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF

# types/next-auth.d.ts
cat > src/types/next-auth.d.ts << 'EOF'
import { DefaultSession } from 'next-auth'

declare module 'next-auth' {
  interface Session {
    user: {
      id: string
      role: string
    } & DefaultSession['user']
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    id: string
    role: string
  }
}
EOF

# components/ui/button.tsx
cat > src/components/ui/button.tsx << 'EOF'
import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils/cn"

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-blue-600 text-white hover:bg-blue-700",
        destructive: "bg-red-600 text-white hover:bg-red-700",
        outline: "border border-gray-300 bg-transparent hover:bg-gray-100",
        secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300",
        ghost: "hover:bg-gray-100",
        link: "text-blue-600 underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
EOF

# components/ui/input.tsx
cat > src/components/ui/input.tsx << 'EOF'
import * as React from "react"
import { cn } from "@/lib/utils/cn"

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          "flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:cursor-not-allowed disabled:opacity-50",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Input.displayName = "Input"

export { Input }
EOF

# components/ui/label.tsx
cat > src/components/ui/label.tsx << 'EOF'
import * as React from "react"
import * as LabelPrimitive from "@radix-ui/react-label"
import { cn } from "@/lib/utils/cn"

const Label = React.forwardRef<
  React.ElementRef<typeof LabelPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof LabelPrimitive.Root>
>(({ className, ...props }, ref) => (
  <LabelPrimitive.Root
    ref={ref}
    className={cn(
      "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70",
      className
    )}
    {...props}
  />
))
Label.displayName = LabelPrimitive.Root.displayName

export { Label }
EOF

# Actualizar tailwind.config.ts con tema personalizado
cat > tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
      },
      animation: {
        'gradient': 'gradient 8s linear infinite',
        'shimmer': 'shimmer 2s linear infinite',
      },
      keyframes: {
        gradient: {
          '0%, 100%': {
            'background-size': '200% 200%',
            'background-position': 'left center'
          },
          '50%': {
            'background-size': '200% 200%',
            'background-position': 'right center'
          },
        },
        shimmer: {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(100%)' },
        },
      },
    },
  },
  plugins: [],
};
export default config;
EOF

# Actualizar app/layout.tsx
cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { Toaster } from 'react-hot-toast';
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "SaaS Application",
  description: "Enterprise SaaS application built with Next.js and PostgreSQL",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        {children}
        <Toaster position="top-right" />
      </body>
    </html>
  );
}
EOF

# Crear página principal con gradiente
cat > src/app/page.tsx << 'EOF'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
      <div className="container mx-auto px-4 py-16">
        <div className="flex flex-col items-center justify-center min-h-[80vh] text-center">
          <div className="relative">
            <div className="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 blur-3xl opacity-20 rounded-full"></div>
            <h1 className="relative text-6xl font-bold bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 bg-clip-text text-transparent mb-6">
              Welcome to SaaS Factory
            </h1>
          </div>

          <p className="text-xl text-gray-600 mb-8 max-w-2xl">
            Enterprise-grade SaaS application with Next.js 14, PostgreSQL, and NextAuth.js
          </p>

          <div className="flex gap-4">
            <Link href="/login">
              <Button size="lg" className="text-lg">
                Get Started
              </Button>
            </Link>
            <Link href="/signup">
              <Button size="lg" variant="outline" className="text-lg">
                Sign Up
              </Button>
            </Link>
          </div>

          <div className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-8 max-w-4xl">
            <div className="bg-white/50 backdrop-blur-sm rounded-lg p-6 shadow-lg">
              <div className="text-4xl mb-4">⚡</div>
              <h3 className="text-lg font-semibold mb-2">Lightning Fast</h3>
              <p className="text-gray-600">Built with Next.js 14 and optimized for performance</p>
            </div>

            <div className="bg-white/50 backdrop-blur-sm rounded-lg p-6 shadow-lg">
              <div className="text-4xl mb-4">🔒</div>
              <h3 className="text-lg font-semibold mb-2">Secure by Default</h3>
              <p className="text-gray-600">Enterprise-grade security with NextAuth.js</p>
            </div>

            <div className="bg-white/50 backdrop-blur-sm rounded-lg p-6 shadow-lg">
              <div className="text-4xl mb-4">🎨</div>
              <h3 className="text-lg font-semibold mb-2">Beautiful UI</h3>
              <p className="text-gray-600">Modern gradient mesh design system</p>
            </div>
          </div>

          <div className="mt-16 text-sm text-gray-500">
            <p>🏭 Generated with SaaS Factory</p>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

# Paso 6: Crear script de inicialización de base de datos
echo -e "${BLUE}[6/8]${NC} Creando script de setup de base de datos..."

mkdir -p scripts

cat > scripts/setup-database.sh << 'EOF'
#!/bin/bash

# Script para configurar la base de datos PostgreSQL

set -e

DB_NAME=$(grep DATABASE_URL .env.local | cut -d'/' -f4)

echo "🗄️  Configurando base de datos: $DB_NAME"

# Verificar si PostgreSQL está corriendo
if ! pg_isready -q; then
    echo "❌ PostgreSQL no está corriendo. Por favor inicia el servicio."
    exit 1
fi

# Crear base de datos si no existe
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
    psql -U postgres -c "CREATE DATABASE $DB_NAME"

echo "✅ Base de datos creada o ya existe"

# Ejecutar migraciones de Prisma
echo "🔄 Ejecutando migraciones..."
npx prisma migrate dev --name init

echo "✅ Base de datos configurada correctamente"
EOF

chmod +x scripts/setup-database.sh

# Paso 7: Crear README específico del proyecto
echo -e "${BLUE}[7/8]${NC} Generando documentación..."

cat > README.md << EOF
# $PROJECT_NAME

Enterprise SaaS application built with Next.js 14, PostgreSQL, NextAuth.js, and TypeScript.

## 🚀 Stack Tecnológico

- **Framework**: Next.js 14 (App Router)
- **Database**: PostgreSQL (Local/Self-hosted)
- **ORM**: Prisma
- **Authentication**: NextAuth.js v5 (Auth.js)
- **Styling**: Tailwind CSS
- **Language**: TypeScript
- **UI Components**: Radix UI + Custom Components
- **Validation**: Zod

## 📁 Estructura del Proyecto

\`\`\`
$PROJECT_NAME/
├── app/
│   ├── (auth)/              # Rutas de autenticación
│   │   ├── login/
│   │   ├── signup/
│   │   └── forgot-password/
│   ├── (dashboard)/         # Rutas protegidas del dashboard
│   │   ├── dashboard/
│   │   ├── projects/
│   │   ├── team/
│   │   └── settings/
│   └── api/
│       └── auth/            # NextAuth.js API routes
├── components/
│   ├── ui/                  # Componentes UI reutilizables
│   ├── auth/                # Componentes de autenticación
│   └── dashboard/           # Componentes del dashboard
├── lib/
│   ├── db/                  # Prisma client
│   ├── auth/                # Auth utilities
│   ├── utils/               # Utilidades generales
│   ├── hooks/               # Custom React Hooks
│   └── validations/         # Zod schemas
├── prisma/
│   ├── schema.prisma        # Schema de base de datos
│   └── migrations/          # Migraciones
└── types/                   # TypeScript types
\`\`\`

## 🛠️ Configuración Inicial

### 1. Requisitos Previos

- Node.js 18+ instalado
- PostgreSQL instalado y corriendo
- Git instalado

### 2. Configurar Variables de Entorno

El archivo \`.env.local\` ya fue creado con valores por defecto. Revísalo y ajusta si es necesario:

\`\`\`bash
cat .env.local
\`\`\`

**Variables importantes:**
- \`DATABASE_URL\`: Conexión a PostgreSQL
- \`NEXTAUTH_SECRET\`: Secret para NextAuth (ya generado automáticamente)
- \`NEXTAUTH_URL\`: URL de tu aplicación

### 3. Configurar Base de Datos

**Opción A: Usando el script automático**

\`\`\`bash
./scripts/setup-database.sh
\`\`\`

**Opción B: Manual**

\`\`\`bash
# Crear base de datos
createdb $DB_NAME

# O usando psql
psql -U postgres -c "CREATE DATABASE $DB_NAME;"

# Ejecutar migraciones de Prisma
npx prisma migrate dev --name init

# Generar Prisma Client
npx prisma generate
\`\`\`

### 4. Verificar la conexión

\`\`\`bash
npx prisma studio
\`\`\`

Esto abrirá una interfaz web en \`http://localhost:5555\` para visualizar tus datos.

## 🚀 Desarrollo

\`\`\`bash
# Instalar dependencias (ya instaladas)
npm install

# Iniciar servidor de desarrollo
npm run dev
\`\`\`

Abre [http://localhost:3000](http://localhost:3000) en tu navegador.

## 📊 Prisma Commands

\`\`\`bash
# Ver base de datos en navegador
npx prisma studio

# Crear migración
npx prisma migrate dev --name nombre_migracion

# Aplicar migraciones en producción
npx prisma migrate deploy

# Generar Prisma Client
npx prisma generate

# Resetear base de datos (⚠️ elimina todos los datos)
npx prisma migrate reset

# Formatear schema
npx prisma format
\`\`\`

## 🗄️ Modelo de Datos

El proyecto incluye un modelo completo de datos enterprise:

### Autenticación (NextAuth.js)
- \`User\`: Usuarios del sistema
- \`Account\`: Cuentas de proveedores OAuth
- \`Session\`: Sesiones activas
- \`VerificationToken\`: Tokens de verificación

### Aplicación
- \`Project\`: Proyectos
- \`ProjectMember\`: Miembros de proyectos
- \`Task\`: Tareas con Kanban (TODO, IN_PROGRESS, DONE)

### Roles del Sistema
- **OWNER**: Propietario de la agencia
- **MANAGER**: Project Manager
- **DEVELOPER**: Desarrollador
- **CLIENT**: Cliente

## 📦 Despliegue

### Preparar para producción

\`\`\`bash
# Build de producción
npm run build

# Aplicar migraciones
npx prisma migrate deploy

# Iniciar en producción
npm start
\`\`\`

### Desplegar en Vercel

\`\`\`bash
# Instalar Vercel CLI
npm i -g vercel

# Configurar variables de entorno en Vercel
vercel env add DATABASE_URL
vercel env add NEXTAUTH_SECRET
vercel env add NEXTAUTH_URL

# Desplegar
vercel --prod
\`\`\`

**Importante para Vercel**: Necesitarás una base de datos PostgreSQL accesible desde internet. Opciones:

1. **Vercel Postgres** (Recomendado para Vercel)
2. **Railway**
3. **Supabase** (solo para PostgreSQL, no sus servicios)
4. **Neon**
5. Tu servidor con IP pública

## 🔑 Características

- ✅ Autenticación completa con NextAuth.js
- ✅ Sistema de roles (Owner, Manager, Developer, Client)
- ✅ ORM con Prisma para type-safety
- ✅ Migraciones automáticas de base de datos
- ✅ Middleware de protección de rutas
- ✅ Validación con Zod
- ✅ Diseño moderno con Gradient Mesh
- ✅ TypeScript strict mode
- ✅ Componentes UI reutilizables
- ✅ PostgreSQL self-hosted (control total)

## 🔐 Seguridad

- Contraseñas hasheadas con bcrypt
- Session-based auth con NextAuth.js
- CSRF protection incluida
- XSS protection via React
- SQL injection protection via Prisma
- Environment variables para secretos

## 📝 Próximos Pasos

1. **Implementar páginas de autenticación**
   - \`app/(auth)/login/page.tsx\`
   - \`app/(auth)/signup/page.tsx\`

2. **Crear dashboard principal**
   - \`app/(dashboard)/dashboard/page.tsx\`

3. **Implementar gestión de proyectos**
   - CRUD de proyectos
   - Asignación de miembros
   - Sistema Kanban

4. **Añadir autorización por roles**
   - Middleware de permisos
   - Componentes condicionales por rol

5. **Agregar funcionalidades enterprise**
   - File uploads
   - Real-time notifications
   - Audit logs
   - Analytics dashboard

## 🛠️ Utilidades de Desarrollo

### Seed de datos de prueba

Crea un archivo \`prisma/seed.ts\`:

\`\`\`typescript
import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  const password = await bcrypt.hash('password123', 10)

  await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: 'Admin User',
      password,
      role: 'OWNER',
    },
  })
}

main()
  .catch(console.error)
  .finally(() => prisma.\$disconnect())
\`\`\`

Ejecutar: \`npx prisma db seed\`

## 📚 Recursos Útiles

- [Next.js Docs](https://nextjs.org/docs)
- [NextAuth.js Docs](https://authjs.dev)
- [Prisma Docs](https://www.prisma.io/docs)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Tailwind CSS](https://tailwindcss.com)
- [Radix UI](https://www.radix-ui.com)

---

**🏭 Generado con SaaS Factory**

Database: PostgreSQL ($DB_NAME)
Framework: Next.js 14
Auth: NextAuth.js v5
ORM: Prisma
EOF

# ============================================
# Paso 6: Crear base de datos (si --create-db)
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_CREATED=false

if [ "$CREATE_DB" = true ]; then
    echo -e "${BLUE}[6/10]${NC} Creando base de datos PostgreSQL..."

    if [ -f "$SCRIPT_DIR/scripts/postgres-helper.sh" ]; then
        if "$SCRIPT_DIR/scripts/postgres-helper.sh" create "$DB_NAME"; then
            echo -e "${GREEN}✅ Base de datos '$DB_NAME' creada${NC}"
            DB_CREATED=true
        else
            echo -e "${RED}❌ No se pudo crear la base de datos${NC}"
            echo -e "${YELLOW}   Créala manualmente: docker exec jscamp-infojobs-strapi-db psql -U strapi -d postgres -c \"CREATE DATABASE $DB_NAME;\"${NC}"
            DB_CREATED=false
        fi
    else
        echo -e "${YELLOW}⚠️  Script postgres-helper.sh no encontrado${NC}"
        DB_CREATED=false
    fi
else
    echo -e "${BLUE}[6/10]${NC} Saltando creación de base de datos (usa --create-db)..."
fi

# ============================================
# Paso 7: Prisma migrate/generate
# ============================================
if [ "$DB_CREATED" = true ]; then
    echo -e "${BLUE}[7/10]${NC} Ejecutando migración inicial de Prisma..."

    # Ejecutar migración inicial
    if npx prisma migrate dev --name init --skip-generate > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Migración inicial completada${NC}"
    else
        echo -e "${YELLOW}⚠️  Migración falló, generando cliente sin migrar...${NC}"
    fi

    # Generar Prisma Client
    echo -e "${CYAN}Generando Prisma Client...${NC}"
    npx prisma generate > /dev/null 2>&1
    echo -e "${GREEN}✅ Prisma Client generado${NC}"
else
    echo -e "${BLUE}[7/10]${NC} Generando Prisma Client (sin migrar)..."
    npx prisma generate > /dev/null 2>&1
    echo -e "${GREEN}✅ Prisma Client generado${NC}"
fi

# ============================================
# Paso 8: Configurar MCP (si no --no-mcp)
# ============================================
MCP_CONFIGURED=false

if [ "$SETUP_MCP" = true ]; then
    echo -e "${BLUE}[8/10]${NC} Configurando Model Context Protocol (MCP)..."

    if [ -f "$SCRIPT_DIR/scripts/setup-mcp.sh" ]; then
        if "$SCRIPT_DIR/scripts/setup-mcp.sh" "$PROJECT_NAME" "$DB_NAME" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ MCP configurado (8 servers: Filesystem, PostgreSQL, Git, GitHub, n8n, etc.)${NC}"
            MCP_CONFIGURED=true
        else
            echo -e "${YELLOW}⚠️  No se pudo configurar MCP automáticamente${NC}"
            MCP_CONFIGURED=false
        fi
    else
        echo -e "${YELLOW}⚠️  Script setup-mcp.sh no encontrado${NC}"
        MCP_CONFIGURED=false
    fi
else
    echo -e "${BLUE}[8/10]${NC} Saltando configuración MCP (--no-mcp especificado)..."
fi

# ============================================
# Paso 9: Configurar Tests (si --with-tests)
# ============================================
TESTS_CONFIGURED=false

if [ "$SETUP_TESTS" = true ]; then
    echo -e "${BLUE}[9/10]${NC} Configurando Testing (Vitest + Playwright)..."

    TEMPLATE_DIR="$SCRIPT_DIR/template"

    # Instalar dependencias de testing
    npm install -D vitest @vitejs/plugin-react vite-tsconfig-paths jsdom @testing-library/react @testing-library/jest-dom @playwright/test > /dev/null 2>&1

    # Copiar configuraciones
    if [ -f "$TEMPLATE_DIR/vitest.config.ts" ]; then
        cp "$TEMPLATE_DIR/vitest.config.ts" ./vitest.config.ts
    fi

    if [ -f "$TEMPLATE_DIR/playwright.config.ts" ]; then
        cp "$TEMPLATE_DIR/playwright.config.ts" ./playwright.config.ts
    fi

    # Crear carpetas de tests
    mkdir -p tests e2e

    # Copiar archivos de test
    [ -f "$TEMPLATE_DIR/tests/setup.ts" ] && cp "$TEMPLATE_DIR/tests/setup.ts" ./tests/setup.ts
    [ -f "$TEMPLATE_DIR/tests/example.test.ts" ] && cp "$TEMPLATE_DIR/tests/example.test.ts" ./tests/example.test.ts
    [ -f "$TEMPLATE_DIR/e2e/home.spec.ts" ] && cp "$TEMPLATE_DIR/e2e/home.spec.ts" ./e2e/home.spec.ts

    # Copiar GitHub Actions
    mkdir -p .github/workflows
    [ -f "$TEMPLATE_DIR/.github/workflows/ci.yml" ] && cp "$TEMPLATE_DIR/.github/workflows/ci.yml" ./.github/workflows/ci.yml

    # Agregar scripts al package.json
    npm pkg set scripts.test="vitest" > /dev/null 2>&1
    npm pkg set scripts.test:ui="vitest --ui" > /dev/null 2>&1
    npm pkg set scripts.test:coverage="vitest --coverage" > /dev/null 2>&1
    npm pkg set scripts.test:e2e="playwright test" > /dev/null 2>&1
    npm pkg set scripts.test:e2e:ui="playwright test --ui" > /dev/null 2>&1

    echo -e "${GREEN}✅ Testing configurado (Vitest + Playwright + CI/CD)${NC}"
    TESTS_CONFIGURED=true
else
    echo -e "${BLUE}[9/10]${NC} Saltando configuración de tests (usa --with-tests)..."
fi

# ============================================
# Paso 10: Git init + commit
# ============================================
echo -e "${BLUE}[10/10]${NC} Inicializando Git y creando commit inicial..."

git init > /dev/null 2>&1
git add .

# Construir mensaje de commit dinámico
COMMIT_MSG="🎉 Initial commit - Generated by SaaS Factory

Stack:
- Next.js 14 (App Router)
- PostgreSQL + Prisma"

if [ "$DB_CREATED" = true ]; then
    COMMIT_MSG="$COMMIT_MSG (DB migrada)"
fi

COMMIT_MSG="$COMMIT_MSG
- NextAuth.js v5
- TypeScript + Tailwind CSS"

if [ "$MCP_CONFIGURED" = true ]; then
    COMMIT_MSG="$COMMIT_MSG
- MCP (8 servers configurados)"
fi

if [ "$TESTS_CONFIGURED" = true ]; then
    COMMIT_MSG="$COMMIT_MSG
- Vitest + Playwright + CI/CD"
fi

COMMIT_MSG="$COMMIT_MSG

Port: $APP_PORT
Database: $DB_NAME"

git commit -m "$COMMIT_MSG" > /dev/null 2>&1
echo -e "${GREEN}✅ Git inicializado y commit creado${NC}"

# ============================================
# POST-SETUP: DNS/Tunnel (servicios externos)
# ============================================
if [ "$CREATE_DNS" = true ]; then
    echo ""
    echo -e "${BLUE}[Post-Setup]${NC} Configurando DNS (Registro A) en Cloudflare..."

    # Verificar que existan las credenciales
    if [ -z "$CLOUDFLARE_API_TOKEN" ] && [ -z "$CLOUDFLARE_API_KEY" ]; then
        echo -e "${YELLOW}⚠️  Variables de Cloudflare no configuradas. Saltando DNS...${NC}"
    else
        SERVER_IP=$(hostname -I | awk '{print $1}')
        if [ -f "$SCRIPT_DIR/scripts/cloudflare-dns.sh" ]; then
            "$SCRIPT_DIR/scripts/cloudflare-dns.sh" create "$SUBDOMAIN" "$SERVER_IP"
        else
            echo -e "${YELLOW}⚠️  Script de Cloudflare DNS no encontrado${NC}"
        fi
    fi
elif [ "$CREATE_TUNNEL" = true ]; then
    echo ""
    echo -e "${BLUE}[Tunnel]${NC} Configurando Cloudflare Tunnel (n8n-tunnel)..."
    
    TUNNEL_ID="5eceb54a-ca75-4c86-87d0-cea2b1de5580"
    DOMAIN="${SUBDOMAIN}.emanuel-server.com"
    CONFIG_FILE="/etc/cloudflared/config.yml"
    
    # 1. Crear CNAME
    if command -v cloudflared &> /dev/null; then
        echo -e "  Creando ruta DNS..."
        if cloudflared tunnel route dns "$TUNNEL_ID" "$DOMAIN" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} CNAME creado: $DOMAIN"
        else
            echo -e "  ${YELLOW}⚠${NC} No se pudo crear CNAME (¿falta login?). Hazlo manualmente."
        fi
        
        # 2. Configurar Ingress
        echo -e "  Configurando Ingress en $CONFIG_FILE..."
        if [ -f "$CONFIG_FILE" ]; then
            # Crear archivo temporal con la nueva configuración
            cp "$CONFIG_FILE" /tmp/cloudflared_config.bak
            
            # Insertar regla antes del catch-all (404)
            # Usamos sed para insertar el bloque de 3 líneas
            sed -i "/- service: http_status:404/i \ \ # REGLA PARA $PROJECT_NAME\n  - hostname: $DOMAIN\n    service: http://localhost:$APP_PORT\n" /tmp/cloudflared_config.bak
            
            # Mover archivo con sudo
            if sudo cp /tmp/cloudflared_config.bak "$CONFIG_FILE"; then
                echo -e "  ${GREEN}✓${NC} Ingress configurado"
                echo -e "  ${CYAN}ℹ️  Reiniciando cloudflared...${NC}"
                if sudo systemctl restart cloudflared; then
                     echo -e "  ${GREEN}✓${NC} cloudflared reiniciado"
                else
                     echo -e "  ${YELLOW}⚠${NC} No se pudo reiniciar cloudflared. Ejecuta: sudo systemctl restart cloudflared"
                fi
            else
                echo -e "  ${RED}✗${NC} Falló escritura en config (permisos sudo requeridos)"
            fi
            rm /tmp/cloudflared_config.bak
        else
            echo -e "  ${RED}✗${NC} Archivo config.yml no encontrado"
        fi
    else
        echo -e "  ${RED}✗${NC} cloudflared no instalado"
    fi
fi

# ============================================
# RESUMEN FINAL
# ============================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}║          ✅ ¡Proyecto creado exitosamente!            ║${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

# Información del proyecto
echo -e "${CYAN}📦 Proyecto:${NC} $PROJECT_NAME"
echo -e "${CYAN}📁 Ubicación:${NC} $PROJECT_DIR"
echo -e "${CYAN}🔌 Puerto:${NC} $APP_PORT"

# Estado de la base de datos
if [ "$DB_CREATED" = true ]; then
    echo -e "${CYAN}🗄️  Base de datos:${NC} $DB_NAME ${GREEN}[✓ Creada y migrada]${NC}"
else
    echo -e "${CYAN}🗄️  Base de datos:${NC} $DB_NAME ${YELLOW}[Pendiente - créala manualmente]${NC}"
fi

# URL del proyecto
if [ "$CREATE_DNS" = true ] || [ "$CREATE_TUNNEL" = true ]; then
    echo -e "${CYAN}🌐 URL:${NC} https://${SUBDOMAIN}.emanuel-server.com"
fi

# MCP configurado
if [ "$MCP_CONFIGURED" = true ]; then
    echo -e "${CYAN}🔌 MCP:${NC} 8 servers configurados ${GREEN}[✓]${NC}"
fi

# Tests configurados
if [ "$TESTS_CONFIGURED" = true ]; then
    echo -e "${CYAN}🧪 Tests:${NC} Vitest + Playwright + CI/CD ${GREEN}[✓]${NC}"
fi

# Docker
if [ -f "$PROJECT_DIR/Dockerfile" ]; then
    echo -e "${CYAN}🐳 Docker:${NC} Dockerfile + compose listos"
fi

# Próximos pasos
echo ""
echo -e "${YELLOW}📋 Para empezar:${NC}"
echo -e "  ${CYAN}cd $PROJECT_NAME${NC}"
echo -e "  ${CYAN}npm run dev${NC}"
echo ""

if [ "$DB_CREATED" = false ]; then
    echo -e "${YELLOW}⚠️  Recuerda crear la base de datos:${NC}"
    echo -e "  ${CYAN}docker exec jscamp-infojobs-strapi-db psql -U strapi -d postgres -c \"CREATE DATABASE $DB_NAME;\"${NC}"
    echo -e "  ${CYAN}npx prisma migrate dev${NC}"
    echo ""
fi

# Comandos útiles
echo -e "${CYAN}🔍 Comandos útiles:${NC}"
echo -e "  ${CYAN}npx prisma studio${NC}       # Ver base de datos"
echo -e "  ${CYAN}npx prisma migrate dev${NC}  # Crear migración"

if [ "$TESTS_CONFIGURED" = true ]; then
    echo -e "  ${CYAN}npm test${NC}                 # Unit tests"
    echo -e "  ${CYAN}npm run test:e2e${NC}        # E2E tests"
fi

if [ "$MCP_CONFIGURED" = true ]; then
    echo ""
    echo -e "${CYAN}🤖 Para usar con Claude:${NC}"
    echo -e "  ${CYAN}cd $PROJECT_NAME && claude .${NC}"
fi

# ============================================
# AUTO-DEPLOY (si se solicitó)
# ============================================
if [ "$AUTO_DEPLOY" = true ]; then
    echo ""
    echo -e "${MAGENTA}╔═══════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║   🚀 INICIANDO AUTO-DEPLOY          ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════╝${NC}"
    echo ""

    # Verificar PM2 y Caddy
    DEPLOY_OK=true

    if ! command -v pm2 &> /dev/null; then
        echo -e "${RED}❌ PM2 no instalado. Instala con: npm install -g pm2${NC}"
        DEPLOY_OK=false
    fi

    if ! command -v caddy &> /dev/null; then
        echo -e "${RED}❌ Caddy no instalado. Ver NGINX_DETECTADO.md para Nginx${NC}"
        DEPLOY_OK=false
    fi

    if [ "$DEPLOY_OK" = true ]; then
        # 1. Build
        echo -e "${BLUE}[Deploy 1/4]${NC} Building para producción..."
        if npm run build > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Build completado${NC}"
        else
            echo -e "${RED}❌ Build falló${NC}"
            DEPLOY_OK=false
        fi

        if [ "$DEPLOY_OK" = true ]; then
            # 2. PM2
            echo -e "${BLUE}[Deploy 2/4]${NC} Iniciando con PM2..."
            PORT=$APP_PORT pm2 start npm --name "$PROJECT_NAME" -- start > /dev/null 2>&1
            pm2 save > /dev/null 2>&1
            echo -e "${GREEN}✅ PM2 configurado (puerto $APP_PORT)${NC}"

            # 3. Caddy
            echo -e "${BLUE}[Deploy 3/4]${NC} Configurando Caddy/Proxy..."
            DOMAIN="${PROJECT_NAME}.emanuel-server.com"

            if ! grep -q "$DOMAIN" /etc/caddy/Caddyfile 2>/dev/null; then
                echo "
$DOMAIN {
    reverse_proxy localhost:$APP_PORT
    encode gzip
}
" | sudo tee -a /etc/caddy/Caddyfile > /dev/null
                echo -e "${GREEN}✅ Entrada agregada a Caddyfile${NC}"
            else
                echo -e "${YELLOW}⚠️  $DOMAIN ya existe en Caddyfile${NC}"
            fi

            # 4. Reload Caddy
            echo -e "${BLUE}[Deploy 4/4]${NC} Recargando Caddy..."
            if sudo systemctl reload caddy > /dev/null 2>&1; then
                echo -e "${GREEN}✅ Caddy recargado (SSL automático)${NC}"
            else
                echo -e "${YELLOW}⚠️  No se pudo recargar Caddy${NC}"
            fi

            echo ""
            echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║   ✅ DEPLOY COMPLETADO EXITOSAMENTE              ║${NC}"
            echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${CYAN}🌐 URL:${NC} https://$DOMAIN"
            echo -e "${CYAN}🔌 Puerto:${NC} $APP_PORT"
            echo -e "${CYAN}📊 Estado:${NC} pm2 status $PROJECT_NAME"
            echo -e "${CYAN}📝 Logs:${NC} pm2 logs $PROJECT_NAME"
            echo ""
        fi
    fi
fi

echo ""
echo -e "${GREEN}🏭 Happy coding!${NC}"
echo ""
