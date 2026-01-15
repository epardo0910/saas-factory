'use client'

import { ReactNode, useState } from 'react'

interface Column<T> {
    key: keyof T | string
    header: string
    render?: (value: unknown, row: T) => ReactNode
    sortable?: boolean
}

interface TableProps<T> {
    data: T[]
    columns: Column<T>[]
    emptyMessage?: string
    onRowClick?: (row: T) => void
}

export function Table<T extends Record<string, unknown>>({
    data,
    columns,
    emptyMessage = 'No data available',
    onRowClick,
}: TableProps<T>) {
    const [sortKey, setSortKey] = useState<string | null>(null)
    const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc')

    const handleSort = (key: string) => {
        if (sortKey === key) {
            setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc')
        } else {
            setSortKey(key)
            setSortDirection('asc')
        }
    }

    const sortedData = sortKey
        ? [...data].sort((a, b) => {
            const aValue = a[sortKey]
            const bValue = b[sortKey]
            if (aValue === bValue) return 0
            const comparison = aValue! > bValue! ? 1 : -1
            return sortDirection === 'asc' ? comparison : -comparison
        })
        : data

    const getValue = (row: T, key: string) => {
        return key.split('.').reduce((obj: unknown, k) => {
            if (obj && typeof obj === 'object' && k in obj) {
                return (obj as Record<string, unknown>)[k]
            }
            return undefined
        }, row)
    }

    return (
        <div className="overflow-x-auto rounded-lg border border-gray-200 dark:border-gray-700">
            <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead className="bg-gray-50 dark:bg-gray-800">
                    <tr>
                        {columns.map((column) => (
                            <th
                                key={String(column.key)}
                                className={`px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500 dark:text-gray-400 ${column.sortable ? 'cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700' : ''
                                    }`}
                                onClick={() => column.sortable && handleSort(String(column.key))}
                            >
                                <div className="flex items-center gap-2">
                                    {column.header}
                                    {column.sortable && sortKey === column.key && (
                                        <span>{sortDirection === 'asc' ? '↑' : '↓'}</span>
                                    )}
                                </div>
                            </th>
                        ))}
                    </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white dark:divide-gray-700 dark:bg-gray-900">
                    {sortedData.length === 0 ? (
                        <tr>
                            <td
                                colSpan={columns.length}
                                className="px-4 py-8 text-center text-gray-500 dark:text-gray-400"
                            >
                                {emptyMessage}
                            </td>
                        </tr>
                    ) : (
                        sortedData.map((row, index) => (
                            <tr
                                key={index}
                                onClick={() => onRowClick?.(row)}
                                className={`${onRowClick ? 'cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800' : ''
                                    }`}
                            >
                                {columns.map((column) => (
                                    <td
                                        key={String(column.key)}
                                        className="whitespace-nowrap px-4 py-3 text-sm text-gray-900 dark:text-gray-100"
                                    >
                                        {column.render
                                            ? column.render(getValue(row, String(column.key)), row)
                                            : String(getValue(row, String(column.key)) ?? '')}
                                    </td>
                                ))}
                            </tr>
                        ))
                    )}
                </tbody>
            </table>
        </div>
    )
}
