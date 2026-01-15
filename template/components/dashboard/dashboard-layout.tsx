'use client'

import { ReactNode, useState } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

interface SidebarItem {
    label: string
    href: string
    icon?: ReactNode
}

interface DashboardLayoutProps {
    children: ReactNode
    sidebarItems?: SidebarItem[]
    userName?: string
    userEmail?: string
    onLogout?: () => void
}

const defaultSidebarItems: SidebarItem[] = [
    { label: 'Dashboard', href: '/dashboard' },
    { label: 'Projects', href: '/dashboard/projects' },
    { label: 'Team', href: '/dashboard/team' },
    { label: 'Settings', href: '/dashboard/settings' },
]

export function DashboardLayout({
    children,
    sidebarItems = defaultSidebarItems,
    userName = 'User',
    userEmail = 'user@example.com',
    onLogout,
}: DashboardLayoutProps) {
    const pathname = usePathname()
    const [sidebarOpen, setSidebarOpen] = useState(false)

    return (
        <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
            {/* Mobile sidebar backdrop */}
            {sidebarOpen && (
                <div
                    className="fixed inset-0 z-40 bg-black/50 lg:hidden"
                    onClick={() => setSidebarOpen(false)}
                />
            )}

            {/* Sidebar */}
            <aside
                className={`fixed left-0 top-0 z-50 h-full w-64 transform bg-white dark:bg-gray-800 shadow-lg transition-transform duration-200 lg:translate-x-0 ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'
                    }`}
            >
                {/* Logo */}
                <div className="flex h-16 items-center justify-between border-b px-4 dark:border-gray-700">
                    <span className="text-xl font-bold text-gray-900 dark:text-white">
                        🏭 SaaS Factory
                    </span>
                    <button
                        onClick={() => setSidebarOpen(false)}
                        className="lg:hidden"
                    >
                        ✕
                    </button>
                </div>

                {/* Navigation */}
                <nav className="mt-4 space-y-1 px-2">
                    {sidebarItems.map((item) => {
                        const isActive = pathname === item.href
                        return (
                            <Link
                                key={item.href}
                                href={item.href}
                                className={`flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors ${isActive
                                        ? 'bg-blue-50 text-blue-600 dark:bg-blue-900/50 dark:text-blue-400'
                                        : 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-700'
                                    }`}
                            >
                                {item.icon}
                                {item.label}
                            </Link>
                        )
                    })}
                </nav>

                {/* User section */}
                <div className="absolute bottom-0 left-0 right-0 border-t p-4 dark:border-gray-700">
                    <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-medium">
                            {userName.charAt(0).toUpperCase()}
                        </div>
                        <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium text-gray-900 dark:text-white truncate">
                                {userName}
                            </p>
                            <p className="text-xs text-gray-500 dark:text-gray-400 truncate">
                                {userEmail}
                            </p>
                        </div>
                    </div>
                    {onLogout && (
                        <button
                            onClick={onLogout}
                            className="mt-3 w-full rounded-lg bg-gray-100 px-3 py-2 text-sm text-gray-700 hover:bg-gray-200 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600"
                        >
                            Logout
                        </button>
                    )}
                </div>
            </aside>

            {/* Main content */}
            <div className="lg:pl-64">
                {/* Top header */}
                <header className="sticky top-0 z-30 flex h-16 items-center gap-4 border-b bg-white/80 backdrop-blur-sm px-4 dark:bg-gray-800/80 dark:border-gray-700">
                    <button
                        onClick={() => setSidebarOpen(true)}
                        className="lg:hidden"
                    >
                        ☰
                    </button>
                    <div className="flex-1" />
                    {/* Add header actions here */}
                </header>

                {/* Page content */}
                <main className="p-6">{children}</main>
            </div>
        </div>
    )
}
