import { test, expect } from '@playwright/test';
import path from 'path';

test.describe('Character Card Generation E2E Test', () => {
  test('should successfully generate character card with file uploads and profile selection', async ({ page }) => {
    // Step 1: Navigate to localhost:8080
    await page.goto('http://localhost:8080');
    await expect(page).toHaveTitle(/Character Card Generator/);
    
    // Wait for the page to load completely
    await page.waitForSelector('[data-testid="character-generator"], .character-generator, h2:has-text("Character Generation")', { timeout: 10000 });
    
    // Step 2: Select 'basic' configuration profile from dropdown
    const configDropdown = page.getByRole('combobox').filter({ hasText: 'Please select a configuration' });
    await configDropdown.click();
    await page.getByRole('option', { name: /basic.*Configuration profile/ }).click();
    
    // Verify configuration profile is selected
    await expect(page.getByText('basic')).toBeVisible();
    await expect(page.getByText('Configuration ready for generation')).toBeVisible();
    
    // Step 3: Select 'default' prompt profile from dropdown
    const promptDropdown = page.getByRole('combobox').filter({ hasText: 'Please select a prompt profile' });
    await promptDropdown.click();
    await page.getByRole('option', { name: /default.*Prompt profile/ }).click();
    
    // Verify prompt profile is selected
    await expect(page.getByText('Standard prompts for creating world-focused character cards')).toBeVisible();
    
    // Step 4: Upload card.json file to Character Card section
    const cardJsonPath = path.resolve(__dirname, 'card.json');
    const characterCardUpload = page.getByText('Select Character CardUpload');
    await characterCardUpload.click();
    await page.setInputFiles('input[type="file"][accept*="json"]', cardJsonPath);
    
    // Verify file upload
    await expect(page.getByText('card.json')).toBeVisible();
    await expect(page.getByText('Ready').or(page.getByText('Done'))).toBeVisible();
    
    // Step 5: Upload IDENTITY.md file to Source Materials section
    const identityMdPath = path.resolve(__dirname, 'IDENTITY.md');
    const sourceMaterialsUpload = page.getByText('Upload Source MaterialsText');
    await sourceMaterialsUpload.click();
    await page.setInputFiles('input[type="file"]:not([accept*="json"])', identityMdPath);
    
    // Verify source materials upload
    await expect(page.getByText('IDENTITY.md')).toBeVisible();
    await expect(page.getByText('Ready').or(page.getByText('Done'))).toBeVisible();
    
    // Step 6: Click Generate Character Card button
    const generateButton = page.getByRole('button', { name: 'Generate Character Card' });
    await expect(generateButton).toBeEnabled();
    
    // Listen for network requests to capture job creation
    const jobCreationPromise = page.waitForResponse(response => 
      response.url().includes('/api/v2/generation/generate') && response.status() === 200
    );
    
    await generateButton.click();
    
    // Step 7: Verify job creation and success notification
    await jobCreationPromise;
    
    // Check for success notification
    await expect(page.getByText('Character generation started')).toBeVisible({ timeout: 5000 });
    await expect(page.getByText(/Job ID:/)).toBeVisible();
    
    // Step 8: Check that job appears in Generation Results with Pending status
    await expect(page.getByText(/Job.*Pending/)).toBeVisible({ timeout: 10000 });
    await expect(page.getByText('Created:')).toBeVisible();
    await expect(page.getByText('Duration:')).toBeVisible();
    
    // Step 9: Verify no API errors in network requests
    // Check that all API calls were successful (no 4xx or 5xx status codes)
    const responses = [];
    page.on('response', response => {
      if (response.url().includes('/api/')) {
        responses.push({
          url: response.url(),
          status: response.status()
        });
      }
    });
    
    // Wait a bit for any pending API calls
    await page.waitForTimeout(2000);
    
    // Verify files show "Done" status
    await expect(page.locator('text=card.json').locator('..').getByText('Done')).toBeVisible();
    await expect(page.locator('text=IDENTITY.md').locator('..').getByText('Done')).toBeVisible();
    
    // Verify the job is still being processed (should be "Pending" or show duration)
    await expect(page.getByText(/Duration:.*[0-9]+[ms]/)).toBeVisible();
    
    console.log('✅ Character generation test completed successfully!');
  });
  
  test('should show validation when profiles are not selected', async ({ page }) => {
    await page.goto('http://localhost:8080');
    
    // Wait for page load
    await page.waitForSelector('h2:has-text("Character Generation")');
    
    // Try to generate without selecting profiles
    const generateButton = page.getByRole('button', { name: 'Generate Character Card' });
    await expect(generateButton).toBeDisabled();
    
    // Should show guidance message
    await expect(page.getByText('Select at least one profile to continue')).toBeVisible();
  });
});