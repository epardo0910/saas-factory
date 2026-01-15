import { test, expect } from '@playwright/test'

test.describe('Home Page', () => {
    test('should load the home page', async ({ page }) => {
        await page.goto('/')

        // Verify page title
        await expect(page).toHaveTitle(/SaaS/)

        // Verify main content is visible
        await expect(page.locator('main')).toBeVisible()
    })

    test('should have navigation links', async ({ page }) => {
        await page.goto('/')

        // Check for login/signup links
        const loginLink = page.getByRole('link', { name: /login/i })
        const signupLink = page.getByRole('link', { name: /sign up/i })

        // At least one should be present
        const hasAuth = await loginLink.isVisible() || await signupLink.isVisible()
        expect(hasAuth).toBeTruthy()
    })
})

test.describe('Authentication', () => {
    test('should show login page', async ({ page }) => {
        await page.goto('/login')

        // Look for email/password inputs
        await expect(page.getByPlaceholder(/email/i)).toBeVisible()
    })
})
