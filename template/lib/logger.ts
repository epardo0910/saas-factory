type LogLevel = 'debug' | 'info' | 'warn' | 'error'

interface LogEntry {
    level: LogLevel
    message: string
    timestamp: string
    context?: Record<string, unknown>
}

const LOG_LEVELS: Record<LogLevel, number> = {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3,
}

const currentLevel = (process.env.LOG_LEVEL as LogLevel) || 'info'

function shouldLog(level: LogLevel): boolean {
    return LOG_LEVELS[level] >= LOG_LEVELS[currentLevel]
}

function formatLog(entry: LogEntry): string {
    const { level, message, timestamp, context } = entry
    const contextStr = context ? ` ${JSON.stringify(context)}` : ''
    return `[${timestamp}] [${level.toUpperCase()}] ${message}${contextStr}`
}

function createLogEntry(
    level: LogLevel,
    message: string,
    context?: Record<string, unknown>
): LogEntry {
    return {
        level,
        message,
        timestamp: new Date().toISOString(),
        context,
    }
}

export const logger = {
    debug: (message: string, context?: Record<string, unknown>) => {
        if (!shouldLog('debug')) return
        const entry = createLogEntry('debug', message, context)
        console.debug(formatLog(entry))
    },

    info: (message: string, context?: Record<string, unknown>) => {
        if (!shouldLog('info')) return
        const entry = createLogEntry('info', message, context)
        console.info(formatLog(entry))
    },

    warn: (message: string, context?: Record<string, unknown>) => {
        if (!shouldLog('warn')) return
        const entry = createLogEntry('warn', message, context)
        console.warn(formatLog(entry))
    },

    error: (message: string, error?: Error, context?: Record<string, unknown>) => {
        if (!shouldLog('error')) return
        const entry = createLogEntry('error', message, {
            ...context,
            error: error
                ? {
                    name: error.name,
                    message: error.message,
                    stack: error.stack,
                }
                : undefined,
        })
        console.error(formatLog(entry))
    },

    // For request logging
    request: (method: string, path: string, duration: number, status: number) => {
        const level = status >= 500 ? 'error' : status >= 400 ? 'warn' : 'info'
        const entry = createLogEntry(level, `${method} ${path}`, {
            duration: `${duration}ms`,
            status,
        })
        console[level](formatLog(entry))
    },
}

export type Logger = typeof logger
